extends Node

signal facing_changed(direction: Vector2)

var _body: CharacterBody2D
var _config: Dictionary = {}
var _locked := false
var _facing := Vector2.RIGHT
var _effect_multiplier := 1.0
var _grounded_known := false
var _was_grounded := false


func configure(body: CharacterBody2D, config: Dictionary) -> void:
	_body = body
	_config = config
	apply_runtime_tuning()


func apply_runtime_tuning() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if _body == null or _config.is_empty():
		return
	var input_direction := _sample_input_direction()
	if not input_direction.is_zero_approx():
		_set_facing(input_direction)
	_body.velocity.x = 0.0 if _locked else input_direction.x * float(_config["speed"]) * _effect_multiplier
	if not _body.is_on_floor():
		var default_gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))
		_body.velocity.y += default_gravity * float(_config["gravity_scale"]) * _delta
	elif _body.velocity.y > 0.0:
		_body.velocity.y = 0.0
	_body.move_and_slide()
	var grounded: bool = _body.is_on_floor()
	if not _grounded_known or grounded != _was_grounded:
		_grounded_known = true
		_was_grounded = grounded
		_trace(&"grounded_changed", {"grounded": grounded, "position": _body.global_position})


func set_movement_locked(locked: bool) -> void:
	if _locked != locked:
		_trace(&"movement_lock_changed", {"locked": locked})
	_locked = locked
	if _locked and _body != null:
		_body.velocity.x = 0.0


func set_effect_multiplier(multiplier: float) -> void:
	_effect_multiplier = maxf(multiplier, 0.0)


func sample_attack_direction() -> Vector2:
	var input_direction := _sample_input_direction()
	if not input_direction.is_zero_approx():
		_set_facing(input_direction)
	return _facing


func get_facing_direction() -> Vector2:
	return _facing


func get_motion() -> Vector2:
	return Vector2.ZERO if _body == null else _body.velocity


func _sample_input_direction() -> Vector2:
	return Vector2(Input.get_axis(&"move_left", &"move_right"), 0.0)


func _set_facing(direction: Vector2) -> void:
	var normalized := direction.normalized()
	if normalized.is_equal_approx(_facing):
		return
	_facing = normalized
	facing_changed.emit(_facing)
	_trace(&"facing_changed", {"direction": _facing})


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][MOVEMENT] %s %s" % [event_name, data])
