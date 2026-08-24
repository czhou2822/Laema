extends Node

signal movement_lock_changed(locked: bool)
signal active_school_changed(school: StringName)
signal attack_started(kind: StringName, school: StringName, direction: Vector2)
signal finisher_started(school: StringName, direction: Vector2)
signal defence_status_changed(label: String, current_guard: float, maximum_guard: float)

enum CombatState {
	READY,
	COMBO_ACTIVE,
	DEFENDING,
	GUARD_BROKEN,
	HIT_REACTING,
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
var _actions_suppressed := false
var _guard_break_remaining := 0.0
var _air_speed_multiplier := 1.0
var _air_speed_remaining := 0.0


func configure(
	config: Dictionary,
	owner_entity: Entity,
	animation_player: AnimationPlayer,
	attack_cast: ShapeCast2D,
	input_combo,
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
	if _state == CombatState.DEFENDING:
		_defence.update(delta, _heat)
	elif _state == CombatState.GUARD_BROKEN:
		_guard_break_remaining = maxf(_guard_break_remaining - delta, 0.0)
		if _guard_break_remaining <= 0.0 and not _defence.is_holding():
			_enter_ready()

	if _state != CombatState.COMBO_ACTIVE or _current_action.is_empty() or not _animation_player.is_playing():
		return
	var progress := get_normalized_attack_progress()
	var combat_config: Dictionary = _config["combat"]
	if not _hit_emitted and progress >= float(combat_config["hit_phase"]):
		_hit_emitted = true
		_perform_hit_query()
	if _current_action["kind"] == &"light":
		_window_open = (
			progress >= float(combat_config["input_window_start"])
			and progress <= float(combat_config["input_window_end"])
		)
		if progress > float(combat_config["input_window_end"]) and _pending_action.is_empty():
			_reset_combo()
	else:
		_window_open = false


func handle_input_event(event: InputEvent, attack_direction: Vector2) -> void:
	if event.is_echo():
		return
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
		return
	if event.is_action_pressed(&"finisher"):
		_try_finisher(attack_direction)


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


func on_hit_reaction_started() -> void:
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
	movement_lock_changed.emit(true)


func on_hit_reaction_ended() -> void:
	if _state == CombatState.HIT_REACTING:
		_enter_ready()


func _try_select_school(school: StringName) -> void:
	if school == _active_school:
		return
	if _state == CombatState.READY:
		_active_school = school
		active_school_changed.emit(_active_school)
		return
	if _state != CombatState.COMBO_ACTIVE or not _window_open:
		return
	if not _is_mixed_combo_school(school) or not _is_mixed_combo_school(_active_school):
		return
	if _input_combo.accept_switch(_active_school, school):
		_active_school = school
		active_school_changed.emit(_active_school)


func _try_light_attack(direction: Vector2) -> void:
	if not _is_functional_school(_active_school):
		return
	if _state == CombatState.READY:
		if not _input_combo.accept_light(_active_school):
			return
		_state = CombatState.COMBO_ACTIVE
		movement_lock_changed.emit(true)
		_start_attack({
			"kind": &"light",
			"school": _active_school,
			"direction": direction,
		})
		return
	if _state != CombatState.COMBO_ACTIVE or not _window_open or not _pending_action.is_empty():
		return
	if _input_combo.accept_light(_active_school):
		_pending_action = {
			"kind": &"light",
			"school": _active_school,
			"direction": direction,
		}


func _try_finisher(direction: Vector2) -> void:
	if not _is_functional_school(_active_school):
		return
	if _state != CombatState.COMBO_ACTIVE or not _window_open or not _pending_action.is_empty():
		return
	var resolution: Dictionary = _input_combo.accept_finisher(_active_school)
	if not bool(resolution.get("valid", false)):
		return
	_pending_action = {
		"kind": &"heavy",
		"school": _active_school,
		"direction": direction,
		"resolution": resolution,
	}
	finisher_started.emit(_active_school, direction)


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


func _start_attack(action: Dictionary) -> void:
	_current_action = action
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_refresh_attack_speed()
	_animation_player.play(&"attack_clock")
	attack_started.emit(action["kind"], action["school"], action["direction"])


func _perform_hit_query() -> void:
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
		return
	if _current_action["kind"] == &"light":
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
		return
	_apply_finisher_resolution(
		hits[0]["target"],
		hits[0]["contact_point"],
		direction,
		_current_action["resolution"]
	)


func _apply_finisher_resolution(
	contact_target: Entity,
	contact_point: Vector2,
	direction: Vector2,
	resolution: Dictionary
) -> void:
	_apply_school_effect(contact_target, contact_point, direction, resolution["primary"])
	var secondary: Dictionary = resolution["secondary"]
	if not secondary.is_empty():
		_apply_school_effect(contact_target, contact_point, direction, secondary)


func _apply_school_effect(
	contact_target: Entity,
	contact_point: Vector2,
	direction: Vector2,
	effect: Dictionary
) -> void:
	var school: StringName = effect["school"]
	var level := int(effect["level"])
	match school:
		SCHOOL_FIRE:
			_fire_resolver.call("apply", _owner_entity, contact_target, level, _config["combat"], direction, contact_point)
		SCHOOL_WATER:
			_water_resolver.call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_point, direction, level, _config["combat"], _config["water"])
		SCHOOL_AIR:
			_air_resolver.call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_target, contact_point, direction, level, _config["combat"], _config["air"])
			if level == 1:
				_apply_air_speed_buff()
		SCHOOL_EARTH:
			_earth_resolver.call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_point, direction, level, _config["combat"], _config["earth"])


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name != &"attack_clock" or _state != CombatState.COMBO_ACTIVE:
		return
	if not _pending_action.is_empty():
		_start_attack(_pending_action)
		return
	if not _current_action.is_empty() and _current_action["kind"] == &"heavy":
		_input_combo.complete()
		_enter_ready()
	else:
		_reset_combo()


func _reset_combo() -> void:
	_animation_player.stop()
	_input_combo.timeout_reset()
	_enter_ready()


func _enter_ready() -> void:
	_state = CombatState.READY
	_current_action = {}
	_pending_action = {}
	_window_open = false
	_hit_emitted = false
	_guard_break_remaining = 0.0
	movement_lock_changed.emit(false)
	defence_status_changed.emit("READY", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _is_functional_school(school: StringName) -> bool:
	return school in [SCHOOL_FIRE, SCHOOL_WATER, SCHOOL_AIR, SCHOOL_EARTH]


func _is_mixed_combo_school(school: StringName) -> bool:
	return school == SCHOOL_FIRE or school == SCHOOL_WATER


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
		_animation_player.speed_scale = (
			_heat.get_speed_multiplier() * _air_speed_multiplier
		)


func _on_heat_changed(_value: float, _level: int, speed_multiplier: float) -> void:
	if _animation_player != null:
		_animation_player.speed_scale = speed_multiplier * _air_speed_multiplier


func _on_guard_changed(current_value: float, maximum_value: float) -> void:
	if _state != CombatState.DEFENDING:
		defence_status_changed.emit("READY", current_value, maximum_value)
		return
	var warning_threshold := float(_config["defence"]["guard_warning_ratio"])
	var warning_active := (
		maximum_value > 0.0
		and current_value / maximum_value <= warning_threshold
	)
	defence_status_changed.emit(
		"GUARD WARNING" if warning_active else "BLOCK",
		current_value,
		maximum_value
	)


func _on_guard_warning() -> void:
	defence_status_changed.emit("GUARD WARNING", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _on_guard_broken() -> void:
	_state = CombatState.GUARD_BROKEN
	_guard_break_remaining = _defence.get_guard_break_recovery()
	movement_lock_changed.emit(true)
	defence_status_changed.emit("GUARD BROKEN", 0.0, float(_config["defence"]["guard_capacity"]))


func _on_parry_window_changed(active: bool) -> void:
	defence_status_changed.emit("PARRY" if active else "PARRY CLOSED", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))
