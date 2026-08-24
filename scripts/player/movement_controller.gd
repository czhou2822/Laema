extends Node

signal facing_changed(direction: Vector2)

var _body: CharacterBody2D
var _config: Dictionary = {}
var _locked := false
var _facing := Vector2.RIGHT
var _effect_multiplier := 1.0


func configure(body: CharacterBody2D, config: Dictionary) -> void:
	_body = body
	_config = config
	apply_runtime_tuning()


func apply_runtime_tuning() -> void:
	if _config.is_empty():
		return
	var deadzone := float(_config["stick_deadzone"])
	InputMap.action_set_deadzone(&"move_left", deadzone)
	InputMap.action_set_deadzone(&"move_right", deadzone)
	InputMap.action_set_deadzone(&"move_up", deadzone)
	InputMap.action_set_deadzone(&"move_down", deadzone)


func _physics_process(_delta: float) -> void:
	if _body == null or _config.is_empty():
		return
	var input_direction := _sample_input_direction()
	if not input_direction.is_zero_approx():
		_set_facing(input_direction)
	_body.velocity = (
		Vector2.ZERO
		if _locked
		else input_direction * float(_config["speed"]) * _effect_multiplier
	)
	_body.move_and_slide()


func set_movement_locked(locked: bool) -> void:
	_locked = locked


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
	return Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")


func _set_facing(direction: Vector2) -> void:
	var normalized := direction.normalized()
	if normalized.is_equal_approx(_facing):
		return
	_facing = normalized
	facing_changed.emit(_facing)
