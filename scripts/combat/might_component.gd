class_name MightComponent
extends Node

const CombatOutcomeResource = preload("res://scripts/combat/combat_outcome.gd")
const ImpactProbe = preload("res://scripts/debug/impact_probe.gd")
const Style = preload("res://scripts/combat/attack_style.gd")
const Geometry = preload("res://scripts/combat/attack_geometry.gd")

signal movement_lock_changed(locked: bool)
signal active_school_changed(school: StringName)
signal attack_started(kind: StringName, school: StringName, direction: Vector2)
signal empowered_cast_started(school: StringName, direction: Vector2)
signal cast_failed
signal cast_attempt_resolved(result: Dictionary)
signal outcome_published(outcome)

enum State {
	READY,
	COMBO_ACTIVE,
	HIT_REACTING,
}

const SCHOOL_FIRE := &"fire"
const SCHOOL_WATER := &"water"
const SCHOOL_AIR := &"air"
const SCHOOL_EARTH := &"earth"

var _state := State.READY
var _config: Dictionary = {}
var _owner_entity: Entity
var _animation_player: AnimationPlayer
var _attack_cast: ShapeCast2D
var _input_combo
var _magic: MagicComponent
var _heat: HeatComponent
var _active_school := SCHOOL_FIRE
var _current_action: Dictionary = {}
var _pending_action: Dictionary = {}
var _window_open := false
var _hit_emitted := false
var _launch_emitted := false
var _actions_suppressed := false
var _buffered_request: Dictionary = {}
var _failed_cast_reaction_pending := false
var _next_attempt_id := 1
var _resolved_attempt_ids: Dictionary = {}
var _attempt_contexts: Dictionary = {}
var _next_source_action_id := 1


func configure(
	config: Dictionary,
	owner_entity: Entity,
	animation_player: AnimationPlayer,
	attack_cast: ShapeCast2D,
	input_combo,
	magic: MagicComponent,
	heat: HeatComponent
) -> void:
	_config = config
	_owner_entity = owner_entity
	_animation_player = animation_player
	Geometry.make_private(_animation_player)
	_attack_cast = attack_cast
	_input_combo = input_combo
	_magic = magic
	_heat = heat
	# Player input and the existing Movement node run first; queries see moved bodies.
	process_physics_priority = 1
	_animation_player.animation_finished.connect(_on_animation_finished)
	_heat.heat_changed.connect(_on_heat_changed)
	apply_runtime_tuning()
	active_school_changed.emit(_active_school)


func apply_runtime_tuning() -> void:
	if _config.is_empty() or _animation_player == null or _attack_cast == null:
		return
	Geometry.apply_player_preview(_animation_player, _config)
	_refresh_action_speed()


func _physics_process(delta: float) -> void:
	if _state != State.COMBO_ACTIVE or _current_action.is_empty() or not _animation_player.is_playing():
		return
	var clock: Animation = _animation_player.get_animation(_animation_player.current_animation)
	var contact_time := clock.get_marker_time(&"contact")
	var time := _animation_player.current_animation_position
	_refresh_action_speed()
	var speed := _animation_player.speed_scale
	var action_id := int(_current_action["source_action_id"])
	var needs_contact := not _hit_emitted if _current_action["kind"] == &"light" else not _launch_emitted
	var advanced := 0.0
	# Visit the contact marker even if a fast frame would cross animation end.
	if speed > 0.0 and ((needs_contact and time >= contact_time) or (time < contact_time and time + delta * speed >= contact_time)):
		advanced = clampf((contact_time - time) / speed, 0.0, delta)
		_animation_player.advance(advanced)
		if needs_contact and _current_action["kind"] == &"light":
			_hit_emitted = true
			_perform_light_hit_query()
		elif needs_contact:
			_launch_emitted = true
			_emit_projectile_launch()
	if _state != State.COMBO_ACTIVE or _current_action.is_empty() or int(_current_action["source_action_id"]) != action_id:
		return
	_refresh_action_speed()
	_animation_player.advance(maxf(delta - advanced, 0.0))
	if _state != State.COMBO_ACTIVE or _current_action.is_empty() or int(_current_action["source_action_id"]) != action_id:
		return
	_window_open = get_normalized_attack_progress() >= float(_config["combat"]["input_window_start"])
	_promote_buffered_request_if_ready()


func try_select_school(school: StringName) -> void:
	if school == _active_school:
		return
	var previous_school := _active_school
	_active_school = school
	active_school_changed.emit(_active_school)
	_publish_outcome(&"school_switched", {"from_school": previous_school, "to_school": school, "position": _input_combo.get_current_position()})
	_trace(&"school_switched", {"from": previous_school, "to": school, "position": _input_combo.get_current_position()})


func try_light_attack(direction: Vector2) -> void:
	if _actions_suppressed:
		return
	if not _is_functional_school(_active_school):
		_trace_light_attempt("rejected", "nonfunctional_school")
		return
	if _state == State.READY:
		if not _input_combo.accept_light(_active_school):
			_trace_light_attempt("rejected", "five_position_limit_or_input_combo_rejection")
			return
		_state = State.COMBO_ACTIVE
		movement_lock_changed.emit(true)
		_start_action(_make_light_action(direction))
		_trace_light_attempt("accepted-started", "accepted")
		return
	if _state != State.COMBO_ACTIVE or not _pending_action.is_empty():
		_trace_light_attempt("rejected", "wrong_combat_state" if _state != State.COMBO_ACTIVE else "pending_action_occupied")
		return
	if not _current_action.is_empty() and not _window_open:
		if _is_chainable_action() and _is_buffer_zone(get_normalized_attack_progress()):
			_buffer_light_attack(direction)
		else:
			_trace_light_attempt("rejected", "before_buffer")
		return
	if _current_action.is_empty() and not _magic.has_active_marking_state() and not _input_combo.is_active():
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


func try_cast_trigger(external_block_reason: StringName = &"") -> void:
	if _is_chainable_action() and not _window_open:
		var buffer_progress := get_normalized_attack_progress()
		if _is_buffer_zone(buffer_progress):
			if not _buffered_request.is_empty():
				_trace(&"input_buffer_rejected", {"kind": "cast", "reason": "first_request_wins", "progress": buffer_progress})
				return
	var attempt_id := _begin_cast_attempt()
	if external_block_reason != &"":
		_resolve_cast_attempt(attempt_id, &"failed", {"reason": external_block_reason})
		return
	if _actions_suppressed:
		_resolve_cast_attempt(attempt_id, &"failed", {"reason": &"actions_suppressed"})
		return
	if _state == State.HIT_REACTING:
		_resolve_cast_attempt(attempt_id, &"failed", {"reason": &"hit_reaction"})
		return
	_promote_buffered_request_if_ready()
	if not _pending_action.is_empty():
		_resolve_cast_attempt(attempt_id, &"failed", {"reason": &"pending_action_occupied"})
		return
	if _is_chainable_action() and not _window_open:
		var buffer_progress := get_normalized_attack_progress()
		if _is_buffer_zone(buffer_progress):
			if not _magic.has_marked_orbs():
				_trace(&"cast_rejected", {"reason": "no_marked_orbs", "state": _state})
				_fail_cast(attempt_id, &"no_marked_orbs")
				return
			_buffer_cast_request(attempt_id)
			return
	if not _magic.has_marked_orbs():
		_trace(&"cast_rejected", {"reason": "no_marked_orbs", "state": _state})
		_fail_cast(attempt_id, &"no_marked_orbs")
		return
	if _state == State.COMBO_ACTIVE and not _current_action.is_empty():
		if not _window_open:
			var current_progress := get_normalized_attack_progress()
			_trace(&"cast_rejected", {"reason": "before_buffer" if not _is_buffer_zone(current_progress) else "full_press_before_window", "progress": current_progress})
			_fail_cast(attempt_id, &"before_cast_window")
			return
		var progression: Dictionary = _input_combo.accept_cast(_active_school)
		if not bool(progression["valid"]):
			_trace(&"cast_rejected", {"reason": "invalid_chain_progression"})
			_fail_cast(attempt_id, &"invalid_chain_progression")
			return
		var commitment := _commit_cast(true, _current_action["direction"])
		if not bool(commitment["valid"]):
			_fail_cast(attempt_id, &"orb_consumption_failed")
			return
		var empowered_action := _make_cast_action(int(commitment["commit_id"]), bool(progression["endpoint"]), true, attempt_id)
		if empowered_action.is_empty():
			_fail_cast(attempt_id, &"commitment_missing")
			return
		_pending_action = empowered_action
		_trace(&"cast_classified", {"outcome": "endpoint" if bool(progression["endpoint"]) else "empowered", "commit_id": commitment["commit_id"]})
		empowered_cast_started.emit(StringName(empowered_action["school"]), empowered_action["direction"])
		return
	var continuation: Dictionary = _input_combo.accept_cast(_active_school)
	if not bool(continuation["valid"]):
		_trace(&"cast_rejected", {"reason": "invalid_chain_progression"})
		_fail_cast(attempt_id, &"invalid_chain_progression")
		return
	var continuation_endpoint := bool(continuation["endpoint"])
	var normal_commitment := _commit_cast(false, _current_facing_direction())
	if not bool(normal_commitment["valid"]):
		_fail_cast(attempt_id, &"orb_consumption_failed")
		return
	if _state == State.READY:
		_state = State.COMBO_ACTIVE
		movement_lock_changed.emit(true)
	var normal_action := _make_cast_action(int(normal_commitment["commit_id"]), continuation_endpoint, false, attempt_id)
	if normal_action.is_empty():
		_fail_cast(attempt_id, &"commitment_missing")
		return
	_trace(&"cast_classified", {"outcome": "normal", "commit_id": normal_commitment["commit_id"]})
	_start_action(normal_action)


func can_begin_defence() -> bool:
	return not _actions_suppressed and _state == State.READY


func can_handle_pressure() -> bool:
	return not _actions_suppressed and _state != State.HIT_REACTING


func release_movement_for_orb_state() -> void:
	if _current_action.is_empty():
		movement_lock_changed.emit(false)


func set_effect_actions_suppressed(suppressed: bool) -> void:
	_actions_suppressed = suppressed


func cancel_for_player_hit() -> void:
	_clear_buffered_request(&"player_hit", false)
	_resolve_active_cast_attempt(&"player_hit")
	if _animation_player != null:
		_animation_player.stop()
	if _input_combo.is_active():
		_publish_outcome(&"chain_terminated", {"reason": &"interruption"})
		_input_combo.timeout_reset()
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	_publish_outcome(&"action_interrupted", {"reason": &"player_hit"})


func enter_hit_reaction() -> void:
	_state = State.HIT_REACTING
	movement_lock_changed.emit(true)


func on_hit_reaction_ended() -> void:
	if _state == State.HIT_REACTING:
		_enter_ready()


func consume_failed_cast_reaction() -> bool:
	if not _failed_cast_reaction_pending:
		return false
	_failed_cast_reaction_pending = false
	return true


func is_combo_active() -> bool:
	return _state == State.COMBO_ACTIVE


func is_attack_playing() -> bool:
	return not _current_action.is_empty() and _animation_player != null and _animation_player.is_playing()


func get_normalized_attack_progress() -> float:
	# Cancelled/completed actions no longer own progress; stop() clears native playback.
	if _animation_player == null or _current_action.is_empty():
		return 0.0
	var length := _animation_player.current_animation_length
	if length <= 0.0:
		return 0.0
	return clampf(_animation_player.current_animation_position / length, 0.0, 1.0)


func get_current_attack_school() -> StringName:
	return _active_school if _current_action.is_empty() else _current_action["school"]


func get_active_school() -> StringName:
	return _active_school


func get_current_chain_position() -> int:
	return _input_combo.get_current_position()


func _is_chainable_action() -> bool:
	return _state == State.COMBO_ACTIVE and _input_combo.is_active() and not _current_action.is_empty() and _animation_player.is_playing()


func _is_buffer_zone(progress: float) -> bool:
	var combat_config: Dictionary = _config["combat"]
	var buffer_start := float(combat_config["input_window_start"]) - float(combat_config["x_buffer_width"])
	return progress >= buffer_start and progress < float(combat_config["input_window_start"])


func _buffer_light_attack(direction: Vector2) -> void:
	if not _buffered_request.is_empty():
		_trace_light_attempt("rejected", "first_request_wins")
		return
	_buffered_request = {"kind": &"light", "school": _active_school, "direction": direction}
	_publish_outcome(&"action_buffered", {"kind": &"light", "school": _active_school})
	_trace_light_attempt("buffered", "x_buffered")


func _buffer_cast_request(attempt_id: int) -> void:
	var commitment := _commit_cast(true, _current_action["direction"])
	if not bool(commitment["valid"]):
		_trace(&"cast_rejected", {"reason": "orb_consumption_failed"})
		_fail_cast(attempt_id, &"orb_consumption_failed")
		return
	_buffered_request = {
		"kind": &"cast",
		"casting_school": _active_school,
		"commit_id": int(commitment["commit_id"]),
		"attempt_id": attempt_id,
	}
	_publish_outcome(&"action_buffered", {"kind": &"cast", "commit_id": commitment["commit_id"], "attempt_id": attempt_id})
	_trace(&"input_buffered", {"kind": "cast", "reason": "full_press_buffered", "commit_id": commitment["commit_id"], "progress": get_normalized_attack_progress()})


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
		_clear_buffered_request(&"unknown_request_kind")


func _is_normal_window_open() -> bool:
	return _is_chainable_action() and get_normalized_attack_progress() >= float(_config["combat"]["input_window_start"])


func _promote_buffered_light(request: Dictionary) -> void:
	if not _is_chainable_action() or not _pending_action.is_empty():
		_clear_buffered_request(&"light_revalidation_failed")
		return
	var school := StringName(request["school"])
	if not _is_functional_school(school) or not _input_combo.accept_light(school):
		_clear_buffered_request(&"light_input_combo_rejection")
		return
	_pending_action = _make_light_action(Vector2(request["direction"]), school)
	_buffered_request.clear()
	_publish_outcome(&"action_buffer_promoted", {"kind": &"light", "school": school, "position": _input_combo.get_current_position()})
	_trace(&"input_buffer_promoted", {"kind": "light", "outcome": "accepted-queued", "school": school, "position": _input_combo.get_current_position()})


func _promote_buffered_cast(request: Dictionary) -> void:
	if not _is_chainable_action() or not _pending_action.is_empty():
		_clear_buffered_request(&"cast_revalidation_failed")
		return
	var progression: Dictionary = _input_combo.accept_cast(StringName(request["casting_school"]))
	if not bool(progression["valid"]):
		_clear_buffered_request(&"cast_input_combo_rejection")
		return
	var action := _make_cast_action(int(request["commit_id"]), bool(progression["endpoint"]), true, int(request["attempt_id"]))
	if action.is_empty():
		_clear_buffered_request(&"cast_commitment_missing")
		return
	_pending_action = action
	_buffered_request.clear()
	_publish_outcome(&"action_buffer_promoted", {"kind": &"cast", "commit_id": request["commit_id"], "attempt_id": request["attempt_id"], "position": _input_combo.get_current_position()})
	_trace(&"input_buffer_promoted", {"kind": "cast", "outcome": "endpoint" if bool(progression["endpoint"]) else "empowered", "commit_id": request["commit_id"]})
	empowered_cast_started.emit(StringName(action["school"]), action["direction"])


func _clear_buffered_request(reason: StringName, discard_cast_commitment := true, resolve_attempt := true) -> void:
	if _buffered_request.is_empty():
		return
	var kind := StringName(_buffered_request.get("kind", &""))
	if kind == &"cast" and discard_cast_commitment:
		_magic.discard_committed_cast(int(_buffered_request.get("commit_id", -1)), reason)
	if kind == &"cast" and resolve_attempt:
		_resolve_cast_attempt(int(_buffered_request.get("attempt_id", -1)), &"interrupted", {"reason": reason, "commit_id": int(_buffered_request.get("commit_id", -1))})
	_buffered_request.clear()
	_publish_outcome(&"action_buffer_cleared", {"kind": kind, "reason": reason})
	_trace(&"input_buffer_cleared", {"kind": kind, "reason": reason, "progress": get_normalized_attack_progress()})


func _commit_cast(empowered: bool, direction: Vector2) -> Dictionary:
	var multiplier := 1.0
	if empowered:
		multiplier = float(_config["casting"]["empowered_primary_multiplier"])
	return _magic.commit_cast(_active_school, empowered, multiplier, direction, _owner_entity)


func _make_light_action(direction: Vector2, school: StringName = &"") -> Dictionary:
	var attack_school := _active_school if school == &"" else school
	var position: int = clampi(int(_input_combo.get_current_position()), 1, 5)
	var move_id := StringName("%s_x%d" % [attack_school, position])
	return {
		"move_id": move_id,
		"hit_targets": [],
		"kind": &"light",
		"school": _active_school if school == &"" else school,
		"direction": direction,
		"end_chain_after_action": false,
		"source_action_id": _allocate_source_action_id(),
	}


func _make_cast_action(commit_id: int, endpoint: bool, empowered: bool, attempt_id: int) -> Dictionary:
	var payload := _magic.get_committed_cast(commit_id)
	if payload.is_empty():
		return {}
	var classification: StringName = &"cast_endpoint" if endpoint else (&"cast_empowered" if empowered else &"cast_normal")
	var chain_position: int = int(_input_combo.get_current_position())
	var source_action_id := _allocate_source_action_id()
	_magic.set_committed_source_action_id(commit_id, source_action_id)
	_attempt_contexts[attempt_id] = {
		"chain_position": chain_position,
		"classification": classification,
		"endpoint": endpoint,
		"commit_id": commit_id,
		"source_action_id": source_action_id,
	}
	return {
		"move_id": &"cast",
		"kind": classification,
		"source_action_id": source_action_id,
		"school": StringName(payload["primary_school"]),
		"direction": payload["direction"],
		"commit_id": commit_id,
		"attempt_id": attempt_id,
		"chain_position": chain_position,
		"endpoint": endpoint,
		"end_chain_after_action": endpoint,
	}


func _start_action(action: Dictionary) -> void:
	_current_action = action
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	var move: Dictionary = _config["moves"][String(action["move_id"])]
	if action["kind"] == &"light":
		_current_action["style"] = Style.capture(move, _config["combat"])
		_current_action["lunge_fraction"] = 0.0
		_current_action["geometry"] = Geometry.facing_pose(Geometry.contact(_animation_player.get_animation(StringName(move["animation"]))), action["direction"])
	ImpactProbe.record("action_started", {"actor": str(_owner_entity.get_path()), "move_id": action["move_id"], "action_id": action.get("source_action_id", 0), "impact": move["impact"]})
	# Casts retain the prior school-specific frame pacing in native tracks too.
	var animation_name := StringName(move["animation"]) if action["kind"] == &"light" else StringName("cast_" + str(action["school"]))
	_animation_player.play(animation_name)
	_refresh_action_speed()
	_animation_player.advance(0.0)
	var action_facts := {"kind": action["kind"], "school": action["school"], "position": _input_combo.get_current_position()}
	if action.has("attempt_id"):
		action_facts["attempt_id"] = action["attempt_id"]
		action_facts["commit_id"] = action["commit_id"]
	if action.has("endpoint"):
		action_facts["endpoint"] = action["endpoint"]
	_trace(&"action_started", action_facts)
	attack_started.emit(action["kind"], action["school"], action["direction"])
	action_facts["action_kind"] = action_facts["kind"]
	action_facts.erase("kind")
	_publish_outcome(&"action_accepted", action_facts)


func _perform_light_hit_query() -> void:
	var direction: Vector2 = _current_action["direction"]
	var profile: Dictionary = _current_action["style"]
	var pose: Dictionary = _current_action["geometry"]
	var live_position := _attack_cast.position
	var live_target := _attack_cast.target_position
	var live_radius := (_attack_cast.shape as CircleShape2D).radius
	_attack_cast.position = pose["position"]
	_attack_cast.target_position = pose["target"]
	(_attack_cast.shape as CircleShape2D).radius = float(pose["radius"])
	_attack_cast.force_shapecast_update()
	ImpactProbe.record("contact_query", {"actor": str(_owner_entity.get_path()), "move_id": _current_action["move_id"], "action_id": _current_action["source_action_id"], "collisions": _attack_cast.get_collision_count()})
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
		hits.append({"target": target, "contact_point": _attack_cast.get_collision_point(index)})
	# Return the node to canonical animation space; facing applies only to the query.
	_attack_cast.position = live_position
	_attack_cast.target_position = live_target
	(_attack_cast.shape as CircleShape2D).radius = live_radius
	if hits.is_empty():
		if bool(_config["combat"]["collect_orb_without_contact"]):
			_magic.add_orb(StringName(_current_action["school"]))
			_publish_outcome(&"light_contact_resolved", {"result": &"orb_without_contact", "school": _current_action["school"], "position": _input_combo.get_current_position()})
			_trace(&"light_contact_resolved", {"result": "orb_without_contact", "school": _current_action["school"], "position": _input_combo.get_current_position()})
			return
		_publish_outcome(&"light_contact_resolved", {"result": &"miss", "school": _current_action["school"], "position": _input_combo.get_current_position()})
		_trace(&"light_contact_resolved", {"result": "miss", "school": _current_action["school"], "position": _input_combo.get_current_position()})
		return
	var action: Dictionary = _current_action.duplicate(true)
	var move: Dictionary = _config["moves"][String(action["move_id"])]
	var applied_contact := false
	var generates_orb := false
	for hit in hits:
		if _current_action.is_empty() or int(_current_action.get("source_action_id", -1)) != int(action["source_action_id"]):
			return
		var event := HealthEvent.damage(_owner_entity, hit["target"], float(_config["combat"][move["damage_key"]]), int(move["impact"]), HealthEvent.Delivery.DIRECT, StringName(action["school"]), {}, direction, hit["contact_point"], int(action["source_action_id"]), [StringName(action["school"])])
		event.melee_contact = true
		event.push_scale = float(profile["push_scale"])
		ImpactProbe.record("contact_event", {"actor": str(_owner_entity.get_path()), "move_id": action["move_id"], "action_id": event.source_action_id, "target": str(event.target.get_path()), "impact": event.impact, "target_poise": event.target.get_poise()})
		var result: HealthResult = hit["target"].receive_health_event(event)
		if result.outcome == HealthResult.Outcome.APPLIED:
			if not _current_action.is_empty():
				_current_action["hit_targets"].append(hit["target"].get_instance_id())
			applied_contact = true
			if result.resolution_tag != &"elemental_endurance_full_resist":
				generates_orb = true
	if _current_action.is_empty():
		return
	if generates_orb:
		_magic.add_orb(StringName(action["school"]))
	if not applied_contact:
		return
	_publish_outcome(&"light_contact_resolved", {"result": &"hit", "school": _current_action["school"], "position": _input_combo.get_current_position(), "target_count": hits.size()})
	_trace(&"light_contact_resolved", {"result": "hit", "school": _current_action["school"], "position": _input_combo.get_current_position(), "target_count": hits.size()})


func _emit_projectile_launch() -> void:
	var payload := _magic.launch_committed_cast(int(_current_action["commit_id"]))
	if payload.is_empty():
		_resolve_cast_attempt(int(_current_action.get("attempt_id", -1)), &"interrupted", {"reason": &"commitment_missing_at_launch", "commit_id": int(_current_action["commit_id"])})
		return
	_resolve_cast_attempt(int(_current_action.get("attempt_id", -1)), &"launched", {"commit_id": int(_current_action["commit_id"]), "primary_level": int(payload["primary_level"])})
	_publish_outcome(&"cast_launch_phase_reached", {"commit_id": _current_action["commit_id"], "attempt_id": _current_action.get("attempt_id", -1)})


func _on_animation_finished(animation_name: StringName) -> void:
	# Casts use school-specific native clips; assigned_animation survives completion.
	if _current_action.is_empty() or animation_name != _animation_player.assigned_animation or _state != State.COMBO_ACTIVE:
		return
	_trace(&"action_finished", {"kind": _current_action.get("kind", &""), "school": _current_action.get("school", &""), "pending_action": not _pending_action.is_empty(), "marking_state_active": _magic.has_active_marking_state()})
	_publish_outcome(&"action_finished", {"kind": _current_action.get("kind", &""), "school": _current_action.get("school", &"")})
	if not _pending_action.is_empty():
		_start_action(_pending_action)
		return
	if bool(_current_action.get("end_chain_after_action", false)):
		_complete_chain_and_clear()
		return
	if _input_combo.get_current_position() >= 5:
		_end_chain_preserving_orbs()
		return
	if StringName(_current_action.get("kind", &"")) == &"cast_empowered":
		_current_action = {}
		_window_open = false
		_hit_emitted = false
		_launch_emitted = false
		movement_lock_changed.emit(false)
		return
	if _magic.has_active_marking_state():
		_current_action = {}
		_window_open = false
		_hit_emitted = false
		_launch_emitted = false
		movement_lock_changed.emit(false)
		return
	_end_chain_preserving_orbs()


func _fail_cast(attempt_id: int, reason: StringName) -> void:
	_clear_buffered_request(&"failed_cast")
	if _animation_player != null:
		_animation_player.stop()
	_trace(&"cast_failed", {"attempt_id": attempt_id, "reason": reason, "state": _state, "position": _input_combo.get_current_position()})
	_magic.clear_after_failed_cast()
	cast_failed.emit()
	_publish_outcome(&"cast_failed", {"attempt_id": attempt_id, "reason": reason, "position": _input_combo.get_current_position()})
	_resolve_cast_attempt(attempt_id, &"failed", {"reason": reason})
	_publish_outcome(&"chain_terminated", {"reason": &"failed_cast"})
	_input_combo.timeout_reset()
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	_state = State.HIT_REACTING
	movement_lock_changed.emit(true)
	_failed_cast_reaction_pending = true
	var flinch_direction := -_current_facing_direction()
	_owner_entity.hit_reaction.execute(1, flinch_direction)


func _complete_chain_and_clear() -> void:
	_publish_outcome(&"chain_terminated", {"reason": &"completed"})
	_input_combo.complete()
	_publish_outcome(&"chain_completed")
	_enter_ready()


func _end_chain_preserving_orbs() -> void:
	_animation_player.stop()
	_publish_outcome(&"chain_terminated", {"reason": &"timeout"})
	_input_combo.timeout_reset()
	_publish_outcome(&"chain_reset", {"reason": &"action_finished_without_follow_up"})
	_enter_ready()


func _enter_ready() -> void:
	_clear_buffered_request(&"return_ready")
	_state = State.READY
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	movement_lock_changed.emit(false)


func reset_for_stage() -> void:
	var had_chain: bool = _input_combo != null and _input_combo.is_active()
	_clear_buffered_request(&"stage_transition", true, false)
	_resolve_active_cast_attempt(&"stage_transition", false)
	if _animation_player != null:
		_animation_player.stop()
	if had_chain:
		_publish_outcome(&"chain_terminated", {"reason": &"stage_transition"})
		_input_combo.timeout_reset()
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_launch_emitted = false
	_failed_cast_reaction_pending = false
	_state = State.READY
	movement_lock_changed.emit(false)


func _begin_cast_attempt() -> int:
	var attempt_id := _next_attempt_id
	_next_attempt_id += 1
	_attempt_contexts[attempt_id] = {
		"chain_position": _input_combo.get_current_position(),
		"classification": &"",
		"endpoint": false,
		"commit_id": -1,
	}
	return attempt_id


func _allocate_source_action_id() -> int:
	var source_action_id := _next_source_action_id
	_next_source_action_id += 1
	return source_action_id


func _resolve_active_cast_attempt(reason: StringName, publish_tutorial_result := true) -> void:
	if _current_action.is_empty() or not String(_current_action.get("kind", &"")).begins_with("cast_"):
		return
	if not publish_tutorial_result:
		return
	_resolve_cast_attempt(
		int(_current_action.get("attempt_id", -1)),
		&"interrupted",
		{"reason": reason, "commit_id": int(_current_action.get("commit_id", -1))}
	)


func _resolve_cast_attempt(attempt_id: int, terminal: StringName, facts: Dictionary = {}) -> void:
	if attempt_id <= 0 or _resolved_attempt_ids.has(attempt_id):
		return
	_resolved_attempt_ids[attempt_id] = true
	var result: Dictionary = Dictionary(_attempt_contexts.get(attempt_id, {})).duplicate(true)
	for key in facts:
		result[key] = facts[key]
	result["attempt_id"] = attempt_id
	result["terminal"] = terminal
	_attempt_contexts.erase(attempt_id)
	cast_attempt_resolved.emit(result)
	_trace(&"cast_attempt_resolved", result)


func _current_facing_direction() -> Vector2:
	if _owner_entity != null and _owner_entity.has_method("get_facing_direction"):
		return Vector2(_owner_entity.call("get_facing_direction"))
	return Vector2.RIGHT


func _is_functional_school(school: StringName) -> bool:
	return school in [SCHOOL_FIRE, SCHOOL_WATER, SCHOOL_AIR, SCHOOL_EARTH]


func _refresh_action_speed() -> void:
	if _animation_player != null:
		var duration := float(_config["combat"]["attack_duration"])
		var clock: Animation = _animation_player.get_animation(_animation_player.current_animation if _animation_player.current_animation != &"" else &"attack_clock")
		if _current_action.get("kind") == &"light" and _current_action.has("style"):
			_animation_player.speed_scale = Style.phase_speed(clock, _current_action["style"], _animation_player.current_animation_position, _heat.get_speed_multiplier())
		else:
			_animation_player.speed_scale = _heat.get_speed_multiplier() * clock.length / duration


func consume_attack_body_motion(delta: float) -> Vector2:
	if _state != State.COMBO_ACTIVE or _current_action.get("kind") != &"light" or not _animation_player.is_playing():
		return Vector2.ZERO
	var profile: Dictionary = _current_action["style"]
	var lunge: Dictionary = profile["forward_lunge"]
	var clock: Animation = _animation_player.get_animation(_animation_player.current_animation)
	var predicted := Style.predict_time(clock, profile, _animation_player.current_animation_position, delta, _heat.get_speed_multiplier())
	var fraction := Style.lunge_fraction(predicted / clock.length, lunge)
	var step := maxf(fraction - float(_current_action["lunge_fraction"]), 0.0)
	_current_action["lunge_fraction"] = fraction
	# Blocked displacement is consumed, so walls cannot store up a later burst.
	return Vector2(signf(Vector2(_current_action["direction"]).x) * float(lunge["distance"]) * step, 0.0)


func get_attack_geometry() -> Dictionary:
	if _current_action.get("kind") == &"light":
		return _current_action["geometry"]
	return {"position": _attack_cast.position, "target": _attack_cast.target_position, "radius": (_attack_cast.shape as CircleShape2D).radius}


func _on_heat_changed(_value: float, _level: int, _speed_multiplier: float) -> void:
	_refresh_action_speed()


func _trace_light_attempt(outcome: String, reason: String) -> void:
	_trace(&"light_attempt", {
		"outcome": outcome,
		"reason": reason,
		"active_school": _active_school,
		"combat_state": _state,
		"chain_position": _input_combo.get_current_position(),
		"action_progress": get_normalized_attack_progress(),
		"window_open": _window_open,
		"current_action_present": not _current_action.is_empty(),
		"pending_action_present": not _pending_action.is_empty(),
		"buffered_request_kind": _buffered_request.get("kind", &""),
		"animation_playing": _animation_player != null and _animation_player.is_playing(),
		"heat_speed_multiplier": _heat.get_speed_multiplier(),
	})


func _publish_outcome(kind: StringName, facts: Dictionary = {}) -> void:
	outcome_published.emit(CombatOutcomeResource.create(kind, facts))


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][COMBAT] %s %s" % [event_name, data])


func get_melee_snapshot() -> Dictionary:
	if _state != State.COMBO_ACTIVE or _current_action.is_empty() or _current_action["kind"] != &"light":
		return {}
	var move: Dictionary = _config["moves"][String(_current_action["move_id"])]
	var clock: Animation = _animation_player.get_animation(StringName(move["animation"]))
	var time := _animation_player.current_animation_position
	return {
		"active": _animation_player.is_playing() and time >= clock.get_marker_time(&"active_start") and time <= clock.get_marker_time(&"active_end"),
		"move_id": _current_action["move_id"],
		"impact": int(move["impact"]),
		"damage": float(_config["combat"]["light_damage"]),
		"school": _current_action["school"],
		"action_id": _current_action["source_action_id"],
		"composition": [_current_action["school"]],
		"hit_targets": _current_action["hit_targets"].duplicate(),
		"push_scale": float(_current_action["style"]["push_scale"]),
	}


func on_clash_contact_resolved(result: HealthResult) -> void:
	if result.outcome != HealthResult.Outcome.APPLIED or _current_action.is_empty():
		return
	if int(_current_action.get("source_action_id", -1)) != result.event.source_action_id or _hit_emitted:
		return
	_hit_emitted = true
	_current_action["hit_targets"].append(result.event.target.get_instance_id())
	if result.resolution_tag != &"elemental_endurance_full_resist":
		_magic.add_orb(StringName(_current_action["school"]))
	_publish_outcome(&"light_contact_resolved", {"result": &"hit", "school": _current_action["school"], "position": _input_combo.get_current_position(), "target_count": 1})


func is_hit_reacting() -> bool:
	return _state == State.HIT_REACTING


func get_contact_phase() -> float:
	if _current_action.is_empty():
		return 0.0
	var clock: Animation = _animation_player.get_animation(_animation_player.current_animation)
	return clock.get_marker_time(&"contact") / clock.length
