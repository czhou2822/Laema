extends Node

signal movement_lock_changed(locked: bool)
signal active_school_changed(school: StringName)
signal attack_started(kind: StringName, school: StringName, direction: Vector2)
signal empowered_cast_started(school: StringName, direction: Vector2)
signal cast_launch_requested(payload: Dictionary)
signal cast_failed
signal defence_status_changed(label: String, current_guard: float, maximum_guard: float)

enum CombatState {
	READY,
	COMBO_ACTIVE,
	DEFENDING,
	GUARD_BROKEN,
	HIT_REACTING,
}

enum PressureState {
	INTERMEDIATE,
	DEPLETING,
	CHARGING,
	CAST,
}

const SCHOOL_FIRE := &"fire"
const SCHOOL_WATER := &"water"
const SCHOOL_AIR := &"air"
const SCHOOL_EARTH := &"earth"

var _state := CombatState.READY
var _config: Dictionary = {}
var _owner_entity: Entity
var _animation_player: AnimationPlayer
var _attack_cast: ShapeCast2D
var _input_combo
var _orb_casting
var _heat
var _defence: DefenceController
var _fire_resolver
var _water_resolver
var _air_resolver
var _earth_resolver
var _active_school := SCHOOL_FIRE
var _current_action: Dictionary = {}
var _pending_action: Dictionary = {}
var _window_open := false
var _hit_emitted := false
var _launch_emitted := false
var _actions_suppressed := false
var _guard_break_remaining := 0.0
var _air_speed_multiplier := 1.0
var _air_speed_remaining := 0.0
var _pressure_initialized := false
var _pressure_state := PressureState.INTERMEDIATE
var _buffered_request: Dictionary = {}


func configure(
	config: Dictionary,
	owner_entity: Entity,
	animation_player: AnimationPlayer,
	attack_cast: ShapeCast2D,
	input_combo,
	orb_casting,
	heat,
	defence: DefenceController,
	fire_resolver,
	water_resolver,
	air_resolver,
	earth_resolver
) -> void:
	_config = config
	_owner_entity = owner_entity
	_animation_player = animation_player
	_attack_cast = attack_cast
	_input_combo = input_combo
	_orb_casting = orb_casting
	_heat = heat
	_defence = defence
	_fire_resolver = fire_resolver
	_water_resolver = water_resolver
	_air_resolver = air_resolver
	_earth_resolver = earth_resolver
	apply_runtime_tuning()

	_animation_player.animation_finished.connect(_on_animation_finished)
	_heat.heat_changed.connect(_on_heat_changed)
	_defence.guard_changed.connect(_on_guard_changed)
	_defence.guard_warning.connect(_on_guard_warning)
	_defence.guard_broken.connect(_on_guard_broken)
	_defence.parry_window_changed.connect(_on_parry_window_changed)
	active_school_changed.emit(_active_school)


func apply_runtime_tuning() -> void:
	if _config.is_empty() or _animation_player == null or _attack_cast == null:
		return
	var clock: Animation = _animation_player.get_animation(&"attack_clock")
	clock.length = float(_config["combat"]["attack_duration"])
	var cast_shape := _attack_cast.shape as CircleShape2D
	cast_shape.radius = float(_config["combat"]["shape_radius"])


func _process(delta: float) -> void:
	_update_air_speed_buff(delta)
	_update_casting_pressure()
	if _state == CombatState.DEFENDING:
		_defence.update(delta, _heat)
	elif _state == CombatState.GUARD_BROKEN:
		_guard_break_remaining = maxf(_guard_break_remaining - delta, 0.0)
		if _guard_break_remaining <= 0.0 and not _defence.is_holding():
			_enter_ready()

	if _state != CombatState.COMBO_ACTIVE or _current_action.is_empty() or not _animation_player.is_playing():
		return
	var progress: float = get_normalized_attack_progress()
	var combat_config: Dictionary = _config["combat"]
	if _current_action["kind"] == &"light":
		if not _hit_emitted and progress >= float(combat_config["hit_phase"]):
			_hit_emitted = true
			_perform_light_hit_query()
	elif not _launch_emitted and progress >= float(combat_config["hit_phase"]):
		_launch_emitted = true
		_emit_projectile_launch()
	_window_open = progress >= float(combat_config["input_window_start"])
	_promote_buffered_request_if_ready()


func handle_input_event(event: InputEvent, attack_direction: Vector2) -> void:
	if event.is_echo():
		return
	_promote_buffered_request_if_ready()
	for school_action in [
		[&"select_fire", SCHOOL_FIRE],
		[&"select_water", SCHOOL_WATER],
		[&"select_air", SCHOOL_AIR],
		[&"select_earth", SCHOOL_EARTH],
	]:
		if event.is_action_pressed(school_action[0]):
			_try_select_school(school_action[1])
			return
	if event.is_action_pressed(&"defend"):
		_try_defend()
		return
	if event.is_action_released(&"defend"):
		_release_defend()
		return
	if _actions_suppressed:
		return
	if event.is_action_pressed(&"light_attack"):
		_try_light_attack(attack_direction)


func is_combo_active() -> bool:
	return _state == CombatState.COMBO_ACTIVE


func is_attack_playing() -> bool:
	return not _current_action.is_empty() and _animation_player != null and _animation_player.is_playing()


func is_defending() -> bool:
	return _state == CombatState.DEFENDING


func get_normalized_attack_progress() -> float:
	if _animation_player == null or _animation_player.current_animation_length <= 0.0:
		return 0.0
	return clampf(
		_animation_player.current_animation_position / _animation_player.current_animation_length,
		0.0,
		1.0
	)


func get_current_attack_school() -> StringName:
	return _active_school if _current_action.is_empty() else _current_action["school"]


func get_active_school() -> StringName:
	return _active_school


func set_effect_actions_suppressed(suppressed: bool) -> void:
	_actions_suppressed = suppressed


func handle_outgoing_health_result(result: HealthResult) -> void:
	if result == null or result.event == null:
		return
	if result.event.instigator != _owner_entity:
		return
	if result.event.is_direct_damage() and result.health_delta < 0.0:
		_heat.add_direct_hit()


func resolve_spell_projectile_impact(target: Entity, contact_point: Vector2, payload: Dictionary) -> void:
	if target == null or payload.is_empty():
		return
	var direction: Vector2 = payload["direction"]
	var primary: Dictionary = {
		"school": StringName(payload["primary_school"]),
		"level": int(payload["primary_level"]),
		"damage_multiplier": float(payload["primary_damage_multiplier"]),
	}
	_apply_spell_effect(target, contact_point, direction, primary)
	var secondary_school := StringName(payload.get("secondary_school", &""))
	var secondary_level := int(payload.get("secondary_level", 0))
	if secondary_school != &"" and secondary_level >= 1:
		_apply_spell_effect(target, contact_point, direction, {
			"school": secondary_school,
			"level": secondary_level,
			"damage_multiplier": 1.0,
		})


func on_hit_reaction_started() -> void:
	_clear_buffered_request("hit_reaction")
	if _animation_player != null:
		_animation_player.stop()
	if _input_combo.is_active():
		_input_combo.timeout_reset()
	_defence.force_cancel()
	_state = CombatState.HIT_REACTING
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	movement_lock_changed.emit(true)


func on_hit_reaction_ended() -> void:
	if _state == CombatState.HIT_REACTING:
		_enter_ready()


func _update_casting_pressure() -> void:
	if _config.is_empty():
		return
	var raw_strength: float = Input.get_action_raw_strength(&"casting")
	var candidate := _classify_pressure(raw_strength)
	if candidate == PressureState.INTERMEDIATE:
		return
	if not _pressure_initialized:
		_pressure_initialized = true
		_pressure_state = candidate
		_trace(&"pressure_state_changed", {"raw_strength": raw_strength, "state": _pressure_state_name(candidate), "initial": true})
		_apply_pressure_state(candidate)
		return
	if candidate == _pressure_state:
		return
	_pressure_state = candidate
	_trace(&"pressure_state_changed", {"raw_strength": raw_strength, "state": _pressure_state_name(candidate), "initial": false})
	_apply_pressure_state(candidate)


func _apply_pressure_state(state: int) -> void:
	match state:
		PressureState.DEPLETING:
			_try_start_depleting()
		PressureState.CHARGING:
			_try_start_charging()
		PressureState.CAST:
			_try_cast_trigger()


func _pressure_state_name(state: int) -> String:
	match state:
		PressureState.DEPLETING:
			return "DEPLETING"
		PressureState.CHARGING:
			return "CHARGING"
		PressureState.CAST:
			return "CAST"
	return "INTERMEDIATE"


func _classify_pressure(raw_strength: float) -> int:
	var casting: Dictionary = _config["casting"]
	if raw_strength <= float(casting["trigger_deplete_max"]):
		return PressureState.DEPLETING
	var charge_lower: float = float(casting["trigger_charge_center"]) - float(casting["trigger_charge_half_width"])
	var charge_upper: float = float(casting["trigger_charge_center"]) + float(casting["trigger_charge_half_width"])
	if raw_strength >= charge_lower and raw_strength <= charge_upper:
		return PressureState.CHARGING
	if raw_strength >= float(casting["trigger_cast_min"]):
		return PressureState.CAST
	return PressureState.INTERMEDIATE


func _try_start_charging() -> void:
	if _actions_suppressed or _state in [CombatState.DEFENDING, CombatState.GUARD_BROKEN, CombatState.HIT_REACTING]:
		return
	_orb_casting.start_charging()


func _try_start_depleting() -> void:
	if _actions_suppressed or _state in [CombatState.DEFENDING, CombatState.GUARD_BROKEN, CombatState.HIT_REACTING]:
		return
	_orb_casting.start_depleting()


func _try_select_school(school: StringName) -> void:
	if school == _active_school:
		return
	if _state == CombatState.READY:
		var previous_school := _active_school
		_active_school = school
		active_school_changed.emit(_active_school)
		_trace(&"school_selected", {"from": previous_school, "to": school})
		return
	if _state != CombatState.COMBO_ACTIVE:
		return
	var can_switch: bool = _window_open or (_current_action.is_empty() and _orb_casting.has_active_marking_state())
	if not can_switch:
		return
	if _input_combo.accept_switch(_active_school, school):
		var previous_school := _active_school
		_active_school = school
		active_school_changed.emit(_active_school)
		_trace(&"school_switched", {"from": previous_school, "to": school, "position": _input_combo.get_current_position()})


func _try_light_attack(direction: Vector2) -> void:
	if not _is_functional_school(_active_school):
		_trace_light_attempt("rejected", "nonfunctional_school")
		return
	if _state == CombatState.READY:
		if not _input_combo.accept_light(_active_school):
			_trace_light_attempt("rejected", "five_position_limit_or_input_combo_rejection")
			return
		_state = CombatState.COMBO_ACTIVE
		movement_lock_changed.emit(true)
		_start_action(_make_light_action(direction))
		_trace_light_attempt("accepted-started", "accepted")
		return
	if _state != CombatState.COMBO_ACTIVE or not _pending_action.is_empty():
		_trace_light_attempt(
			"rejected",
			"wrong_combat_state" if _state != CombatState.COMBO_ACTIVE else "pending_action_occupied"
		)
		return
	if not _current_action.is_empty() and not _window_open:
		if _is_chainable_action() and _is_buffer_zone(get_normalized_attack_progress()):
			_buffer_light_attack(direction)
		else:
			_trace_light_attempt("rejected", "before_buffer")
		return
	if _current_action.is_empty() and not _orb_casting.has_active_marking_state():
		_trace_light_attempt("rejected", "post_action_chain_not_preserved")
		return
	if not _input_combo.accept_light(_active_school):
		_trace_light_attempt("rejected", "five_position_limit_or_input_combo_rejection")
		return
	var action := _make_light_action(direction)
	if _current_action.is_empty():
		_start_action(action)
		_trace_light_attempt("accepted-started", "accepted")
	else:
		_pending_action = action
		_trace_light_attempt("accepted-queued", "accepted")


func _is_chainable_action() -> bool:
	return (
		_state == CombatState.COMBO_ACTIVE
		and _input_combo.is_active()
		and not _current_action.is_empty()
		and _animation_player != null
		and _animation_player.is_playing()
	)


func _is_buffer_zone(progress: float) -> bool:
	var combat_config: Dictionary = _config["combat"]
	var buffer_start := float(combat_config["input_window_start"]) - float(combat_config["x_buffer_width"])
	return progress >= buffer_start and progress < float(combat_config["input_window_start"])


func _buffer_light_attack(direction: Vector2) -> void:
	if not _buffered_request.is_empty():
		_trace_light_attempt("rejected", "first_request_wins")
		return
	_buffered_request = {
		"kind": &"light",
		"school": _active_school,
		"direction": direction,
	}
	_trace_light_attempt("buffered", "x_buffered")


func _buffer_cast_request() -> void:
	if not _buffered_request.is_empty():
		_trace(&"input_buffer_rejected", {"kind": "cast", "reason": "first_request_wins", "progress": get_normalized_attack_progress()})
		return
	var resolution: Dictionary = _orb_casting.consume_marked_orbs()
	if not bool(resolution["valid"]):
		_trace(&"cast_rejected", {"reason": "orb_consumption_failed"})
		_fail_cast()
		return
	_buffered_request = {
		"kind": &"cast",
		"casting_school": _active_school,
		"direction": _current_action["direction"],
		"resolution": resolution.duplicate(true),
		"empowered": true,
		"primary_damage_multiplier": float(_config["casting"]["empowered_primary_multiplier"]),
		"instigator": _owner_entity,
	}
	_trace(&"input_buffered", {
		"kind": "cast",
		"reason": "full_press_buffered",
		"primary_school": resolution["primary_school"],
		"primary_level": resolution["primary_level"],
		"secondary_school": resolution["secondary_school"],
		"secondary_level": resolution["secondary_level"],
		"progress": get_normalized_attack_progress(),
	})


func _promote_buffered_request_if_ready() -> void:
	if _buffered_request.is_empty() or not _is_normal_window_open():
		return
	var request: Dictionary = _buffered_request.duplicate(true)
	var kind := StringName(request["kind"])
	if kind == &"light":
		_promote_buffered_light(request)
	elif kind == &"cast":
		_promote_buffered_cast(request)
	else:
		_clear_buffered_request("unknown_request_kind")


func _is_normal_window_open() -> bool:
	return _is_chainable_action() and get_normalized_attack_progress() >= float(_config["combat"]["input_window_start"])


func _promote_buffered_light(request: Dictionary) -> void:
	if not _is_chainable_action() or not _pending_action.is_empty():
		_clear_buffered_request("light_revalidation_failed")
		return
	var school := StringName(request["school"])
	if not _is_functional_school(school) or not _input_combo.accept_light(school):
		_clear_buffered_request("light_input_combo_rejection")
		return
	_pending_action = _make_light_action(Vector2(request["direction"]), school)
	_buffered_request.clear()
	_trace(&"input_buffer_promoted", {"kind": "light", "outcome": "accepted-queued", "school": school, "position": _input_combo.get_current_position()})


func _promote_buffered_cast(request: Dictionary) -> void:
	if not _is_chainable_action() or not _pending_action.is_empty():
		_clear_buffered_request("cast_revalidation_failed")
		return
	var progression: Dictionary = _input_combo.accept_cast(StringName(request["casting_school"]))
	if not bool(progression["valid"]):
		_clear_buffered_request("cast_input_combo_rejection")
		return
	var action := _make_cast_action(
		request["resolution"],
		bool(progression["endpoint"]),
		true,
		Vector2(request["direction"]),
		float(request["primary_damage_multiplier"]),
		request["instigator"]
	)
	_pending_action = action
	_buffered_request.clear()
	_trace(&"input_buffer_promoted", {"kind": "cast", "outcome": "endpoint" if bool(progression["endpoint"]) else "empowered", "primary_school": action["school"], "primary_level": action["resolution"]["primary_level"]})
	empowered_cast_started.emit(StringName(action["school"]), action["direction"])


func _clear_buffered_request(reason: String) -> void:
	if _buffered_request.is_empty():
		return
	var kind := StringName(_buffered_request.get("kind", &""))
	_buffered_request.clear()
	_trace(&"input_buffer_cleared", {"kind": kind, "reason": reason, "progress": get_normalized_attack_progress()})


func _trace_light_attempt(outcome: String, reason: String) -> void:
	var current_action_present := not _current_action.is_empty()
	var current_action_kind: StringName = _current_action.get("kind", &"")
	var current_action_school: StringName = _current_action.get("school", &"")
	var heat_speed_multiplier := 1.0
	if _heat != null:
		heat_speed_multiplier = float(_heat.get_speed_multiplier())
	_trace(&"light_attempt", {
		"outcome": outcome,
		"reason": reason,
		"active_school": _active_school,
		"combat_state": _state,
		"chain_position": _input_combo.get_current_position(),
		"action_progress": get_normalized_attack_progress(),
		"window_open": _window_open,
		"current_action_present": current_action_present,
		"current_action_kind": current_action_kind,
		"current_action_school": current_action_school,
		"pending_action_present": not _pending_action.is_empty(),
		"buffered_request_kind": _buffered_request.get("kind", &""),
		"animation_playing": _animation_player != null and _animation_player.is_playing(),
		"heat_speed_multiplier": heat_speed_multiplier,
	})


func _try_cast_trigger() -> void:
	if _actions_suppressed or _state in [CombatState.DEFENDING, CombatState.GUARD_BROKEN, CombatState.HIT_REACTING]:
		return
	_promote_buffered_request_if_ready()
	if not _pending_action.is_empty():
		return
	if _is_chainable_action() and not _window_open:
		var buffer_progress := get_normalized_attack_progress()
		if _is_buffer_zone(buffer_progress):
			if not _buffered_request.is_empty():
				_trace(&"input_buffer_rejected", {"kind": "cast", "reason": "first_request_wins", "progress": buffer_progress})
				return
			if not _orb_casting.has_marked_orbs():
				_trace(&"cast_rejected", {"reason": "no_marked_orbs", "state": _state})
				_fail_cast()
				return
			_buffer_cast_request()
			return
	if not _orb_casting.has_marked_orbs():
		if _state == CombatState.COMBO_ACTIVE or _orb_casting.has_active_marking_state():
			_trace(&"cast_rejected", {"reason": "no_marked_orbs", "state": _state})
			_fail_cast()
		return
	if _state == CombatState.COMBO_ACTIVE and not _current_action.is_empty():
		if not _window_open:
			var current_progress := get_normalized_attack_progress()
			_trace(&"cast_rejected", {"reason": "before_buffer" if not _is_buffer_zone(current_progress) else "full_press_before_window", "progress": current_progress})
			_fail_cast()
			return
		var progression: Dictionary = _input_combo.accept_cast(_active_school)
		if not bool(progression["valid"]):
			_trace(&"cast_rejected", {"reason": "invalid_chain_progression"})
			_fail_cast()
			return
		var resolution: Dictionary = _orb_casting.consume_marked_orbs()
		if not bool(resolution["valid"]):
			_trace(&"cast_rejected", {"reason": "orb_consumption_failed"})
			_fail_cast()
			return
		var empowered_action := _make_cast_action(
			resolution,
			bool(progression["endpoint"]),
			true,
			_current_action["direction"]
		)
		_pending_action = empowered_action
		_trace(&"cast_classified", {"outcome": "endpoint" if bool(progression["endpoint"]) else "empowered", "primary_school": resolution["primary_school"], "primary_level": resolution["primary_level"], "secondary_school": resolution["secondary_school"], "secondary_level": resolution["secondary_level"]})
		empowered_cast_started.emit(StringName(empowered_action["school"]), empowered_action["direction"])
		return

	var normal_resolution: Dictionary = _orb_casting.consume_marked_orbs()
	if not bool(normal_resolution["valid"]):
		_trace(&"cast_rejected", {"reason": "normal_orb_consumption_failed"})
		_fail_cast()
		return
	if _state == CombatState.READY:
		_state = CombatState.COMBO_ACTIVE
		movement_lock_changed.emit(true)
	_trace(&"cast_classified", {"outcome": "normal", "primary_school": normal_resolution["primary_school"], "primary_level": normal_resolution["primary_level"], "secondary_school": normal_resolution["secondary_school"], "secondary_level": normal_resolution["secondary_level"]})
	_start_action(_make_cast_action(normal_resolution, false, false, _current_facing_direction()))


func _make_light_action(direction: Vector2, school: StringName = &"") -> Dictionary:
	var action_school := _active_school if school == &"" else school
	return {
		"kind": &"light",
		"school": action_school,
		"direction": direction,
		"end_chain_after_action": false,
	}


func _make_cast_action(
	resolution: Dictionary,
	endpoint: bool,
	empowered: bool,
	direction: Vector2,
	primary_damage_multiplier: float = -1.0,
	instigator: Entity = null
) -> Dictionary:
	var kind: StringName = &"cast_normal"
	if empowered:
		kind = &"cast_endpoint" if endpoint else &"cast_empowered"
	var resolved_multiplier := 1.0
	if empowered:
		resolved_multiplier = float(_config["casting"]["empowered_primary_multiplier"])
	if primary_damage_multiplier >= 0.0:
		resolved_multiplier = primary_damage_multiplier
	return {
		"kind": kind,
		"school": StringName(resolution["primary_school"]),
		"direction": direction,
		"resolution": resolution,
		"empowered": empowered,
		"primary_damage_multiplier": resolved_multiplier,
		"instigator": _owner_entity if instigator == null else instigator,
		"end_chain_after_action": not empowered or endpoint,
	}


func _try_defend() -> void:
	if _actions_suppressed or _state != CombatState.READY:
		return
	if not _is_functional_school(_active_school):
		return
	if _defence.begin(_active_school):
		_state = CombatState.DEFENDING
		movement_lock_changed.emit(true)
		defence_status_changed.emit("BLOCK" if _active_school == SCHOOL_WATER else "PARRY", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _release_defend() -> void:
	if _state != CombatState.DEFENDING and _state != CombatState.GUARD_BROKEN:
		return
	_defence.end_hold()
	if _state == CombatState.DEFENDING or _guard_break_remaining <= 0.0:
		_enter_ready()


func _start_action(action: Dictionary) -> void:
	_current_action = action
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	_refresh_attack_speed()
	_animation_player.play(&"attack_clock")
	_trace(&"action_started", {"kind": action["kind"], "school": action["school"], "direction": action["direction"], "position": _input_combo.get_current_position()})
	attack_started.emit(action["kind"], action["school"], action["direction"])


func _perform_light_hit_query() -> void:
	var direction: Vector2 = _current_action["direction"]
	_attack_cast.target_position = direction.normalized() * float(_config["combat"]["shape_reach"])
	_attack_cast.force_shapecast_update()
	var hits: Array[Dictionary] = []
	var seen: Dictionary = {}
	for index in range(_attack_cast.get_collision_count()):
		var target := _attack_cast.get_collider(index) as Entity
		if target == null:
			continue
		var target_id := target.get_instance_id()
		if seen.has(target_id):
			continue
		seen[target_id] = true
		hits.append({
			"target": target,
			"contact_point": _attack_cast.get_collision_point(index),
		})
	if hits.is_empty():
		if bool(_config["combat"]["collect_orb_without_contact"]):
			_orb_casting.add_orb(StringName(_current_action["school"]))
			_trace(&"light_contact_resolved", {"result": "orb_without_contact", "school": _current_action["school"], "position": _input_combo.get_current_position()})
			return
		_trace(&"light_contact_resolved", {"result": "miss", "school": _current_action["school"], "position": _input_combo.get_current_position()})
		return
	for hit in hits:
		var event := HealthEvent.damage(
			_owner_entity,
			hit["target"],
			float(_config["combat"]["light_damage"]),
			int(_config["combat"]["direct_impact"]),
			HealthEvent.Delivery.DIRECT,
			StringName(_current_action["school"]),
			{},
			direction,
			hit["contact_point"]
		)
		hit["target"].receive_health_event(event)
	_orb_casting.add_orb(StringName(_current_action["school"]))
	_trace(&"light_contact_resolved", {"result": "hit", "school": _current_action["school"], "position": _input_combo.get_current_position(), "target_count": hits.size()})


func _emit_projectile_launch() -> void:
	var resolution: Dictionary = _current_action["resolution"]
	var multiplier: float = float(_current_action.get("primary_damage_multiplier", 1.0))
	var launch_payload: Dictionary = {
		"instigator": _current_action.get("instigator", _owner_entity),
		"direction": _current_action["direction"],
		"primary_school": resolution["primary_school"],
		"primary_level": resolution["primary_level"],
		"secondary_school": resolution["secondary_school"],
		"secondary_level": resolution["secondary_level"],
		"empowered": bool(_current_action["empowered"]),
		"primary_damage_multiplier": multiplier,
	}
	_trace(&"projectile_launch_requested", {"primary_school": launch_payload["primary_school"], "primary_level": launch_payload["primary_level"], "secondary_school": launch_payload["secondary_school"], "secondary_level": launch_payload["secondary_level"], "empowered": launch_payload["empowered"]})
	cast_launch_requested.emit(launch_payload)


func _apply_spell_effect(contact_target: Entity, contact_point: Vector2, direction: Vector2, effect: Dictionary) -> void:
	var school: StringName = effect["school"]
	var level := int(effect["level"])
	var damage_multiplier := float(effect["damage_multiplier"])
	_trace(&"spell_effect_resolved", {"target": contact_target.name, "school": school, "level": level, "damage_multiplier": damage_multiplier, "contact_point": contact_point})
	match school:
		SCHOOL_FIRE:
			_fire_resolver.call("apply", _owner_entity, contact_target, level, _config["combat"], direction, contact_point, damage_multiplier)
		SCHOOL_WATER:
			_water_resolver.call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_point, direction, level, _config["combat"], _config["water"], damage_multiplier)
		SCHOOL_AIR:
			_air_resolver.call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_target, contact_point, direction, level, _config["combat"], _config["air"], damage_multiplier)
			if level == 1:
				_apply_air_speed_buff()
		SCHOOL_EARTH:
			_earth_resolver.call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_point, direction, level, _config["combat"], _config["earth"], damage_multiplier)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != &"attack_clock" or _state != CombatState.COMBO_ACTIVE:
		return
	_trace(&"action_finished", {"kind": _current_action.get("kind", &""), "school": _current_action.get("school", &""), "pending_action": not _pending_action.is_empty(), "marking_state_active": _orb_casting.has_active_marking_state()})
	if not _pending_action.is_empty():
		_start_action(_pending_action)
		return
	if bool(_current_action.get("end_chain_after_action", false)):
		_complete_chain_and_clear()
		return
	if _orb_casting.has_active_marking_state():
		_current_action = {}
		_window_open = false
		_hit_emitted = false
		_launch_emitted = false
		return
	_end_chain_preserving_orbs()


func _fail_cast() -> void:
	_clear_buffered_request("failed_cast")
	if _animation_player != null:
		_animation_player.stop()
	_trace(&"cast_failed", {"state": _state, "position": _input_combo.get_current_position()})
	cast_failed.emit()
	_input_combo.timeout_reset()
	_orb_casting.clear()
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	_state = CombatState.HIT_REACTING
	movement_lock_changed.emit(true)
	var flinch_direction := Vector2.LEFT
	if _owner_entity != null and _owner_entity.has_method("get_facing_direction"):
		flinch_direction = -Vector2(_owner_entity.call("get_facing_direction"))
	_owner_entity.hit_reaction.execute(1, flinch_direction)


func _complete_chain_and_clear() -> void:
	_input_combo.complete()
	_orb_casting.clear()
	_enter_ready()


func _end_chain_preserving_orbs() -> void:
	_animation_player.stop()
	_input_combo.timeout_reset()
	_enter_ready()


func _enter_ready() -> void:
	_clear_buffered_request("return_ready")
	_state = CombatState.READY
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	_guard_break_remaining = 0.0
	movement_lock_changed.emit(false)
	defence_status_changed.emit("READY", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _current_facing_direction() -> Vector2:
	if _owner_entity != null and _owner_entity.has_method("get_facing_direction"):
		return Vector2(_owner_entity.call("get_facing_direction"))
	return Vector2.RIGHT


func _is_functional_school(school: StringName) -> bool:
	return school in [SCHOOL_FIRE, SCHOOL_WATER, SCHOOL_AIR, SCHOOL_EARTH]


func _apply_air_speed_buff() -> void:
	_air_speed_multiplier = float(_config["air"]["attack_speed_multiplier"])
	_air_speed_remaining = float(_config["air"]["buff_duration"])
	_refresh_attack_speed()


func _update_air_speed_buff(delta: float) -> void:
	if _air_speed_remaining <= 0.0:
		return
	_air_speed_remaining = maxf(_air_speed_remaining - delta, 0.0)
	if _air_speed_remaining <= 0.0:
		_air_speed_multiplier = 1.0
		_refresh_attack_speed()


func _refresh_attack_speed() -> void:
	if _animation_player != null:
		_animation_player.speed_scale = _heat.get_speed_multiplier() * _air_speed_multiplier


func _on_heat_changed(_value: float, _level: int, speed_multiplier: float) -> void:
	if _animation_player != null:
		_animation_player.speed_scale = speed_multiplier * _air_speed_multiplier


func _on_guard_changed(current_value: float, maximum_value: float) -> void:
	if _state != CombatState.DEFENDING:
		defence_status_changed.emit("READY", current_value, maximum_value)
		return
	var warning_threshold := float(_config["defence"]["guard_warning_ratio"])
	var warning_active := maximum_value > 0.0 and current_value / maximum_value <= warning_threshold
	defence_status_changed.emit("GUARD WARNING" if warning_active else "BLOCK", current_value, maximum_value)


func _on_guard_warning() -> void:
	defence_status_changed.emit("GUARD WARNING", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _on_guard_broken() -> void:
	_state = CombatState.GUARD_BROKEN
	_guard_break_remaining = _defence.get_guard_break_recovery()
	movement_lock_changed.emit(true)
	defence_status_changed.emit("GUARD BROKEN", 0.0, float(_config["defence"]["guard_capacity"]))


func _on_parry_window_changed(active: bool) -> void:
	defence_status_changed.emit("PARRY" if active else "PARRY CLOSED", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][COMBAT] %s %s" % [event_name, data])
