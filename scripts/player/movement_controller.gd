extends Node

signal facing_changed(direction: Vector2)

var _body: CharacterBody2D
var _config: Dictionary = {}
var _locked := false
var _facing := Vector2.RIGHT
var _effect_multiplier := 1.0
var _grounded_known := false
var _was_grounded := false
var _attack_motion: Callable
var _dodge_body_exceptions: Array[Dictionary] = []


func configure(body: CharacterBody2D, config: Dictionary) -> void:
	_body = body
	_config = config
	apply_runtime_tuning()


func apply_runtime_tuning() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if _body == null or _config.is_empty():
		return
	if _body.has_method("sync_combat_body_profile"):
		_body.call("sync_combat_body_profile")
	var input_direction := _sample_input_direction()
	if not input_direction.is_zero_approx():
		if not _locked:
			_set_facing(input_direction)
	var entity := _body as Entity
	var reacting := entity != null and entity.hit_reaction.is_invincible()
	var push := entity.hit_reaction.consume_body_motion(_delta) if reacting else Vector2.ZERO
	var attack_push: Vector2 = _attack_motion.call(_delta) if not reacting and _attack_motion.is_valid() else Vector2.ZERO
	var locked_velocity := attack_push.x / _delta if _delta > 0.0 else 0.0
	_body.velocity.x = push.x / _delta if reacting and _delta > 0.0 else (locked_velocity if _locked else input_direction.x * float(_config["speed"]) * _effect_multiplier)
	if not _body.is_on_floor():
		var default_gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0))
		_body.velocity.y += default_gravity * float(_config["gravity_scale"]) * _delta
	elif _body.velocity.y > 0.0:
		_body.velocity.y = 0.0
	_body.move_and_slide()
	if reacting:
		entity.hit_reaction.finish_body_motion()
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


func set_attack_motion_provider(provider: Callable) -> void:
	_attack_motion = provider


func set_effect_multiplier(multiplier: float) -> void:
	_effect_multiplier = maxf(multiplier, 0.0)


func sample_attack_direction() -> Vector2:
	var input_direction := _sample_input_direction()
	return input_direction.normalized() if not input_direction.is_zero_approx() else _facing


func commit_attack_direction(direction: Vector2) -> void:
	if not is_zero_approx(direction.x):
		_set_facing(Vector2(signf(direction.x), 0.0))


func get_facing_direction() -> Vector2:
	return _facing


func get_motion() -> Vector2:
	return Vector2.ZERO if _body == null else _body.velocity


func get_normal_movement_speed() -> float:
	return 0.0 if _config.is_empty() else float(_config["speed"]) * _effect_multiplier


func sample_dodge_direction(device: int) -> Vector2:
	if Input.get_connected_joypads().has(device):
		var axis := Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
		if absf(axis) >= InputMap.action_get_deadzone(&"move_left"):
			return Vector2.LEFT if axis < 0.0 else Vector2.RIGHT
	return _facing


func begin_dodge(direction: Vector2) -> void:
	_set_facing(direction)
	# Body exceptions do not remove the target from damage/contact queries.
	for target in get_tree().get_nodes_in_group(&"status_targets"):
		var other := target as PhysicsBody2D
		if other == null or other == _body:
			continue
		if (_body.collision_mask & other.collision_layer) == 0 and (other.collision_mask & _body.collision_layer) == 0:
			continue
		var add_forward := not _body.get_collision_exceptions().has(other)
		var add_reverse := not other.get_collision_exceptions().has(_body)
		if add_forward:
			_body.add_collision_exception_with(other)
		if add_reverse:
			other.add_collision_exception_with(_body)
		_dodge_body_exceptions.append({"body": weakref(other), "forward": add_forward, "reverse": add_reverse})


func end_dodge() -> void:
	for entry in _dodge_body_exceptions:
		var other: PhysicsBody2D = entry["body"].get_ref()
		if not is_instance_valid(other) or not is_instance_valid(_body):
			continue
		if bool(entry["forward"]):
			_body.remove_collision_exception_with(other)
		if bool(entry["reverse"]):
			other.remove_collision_exception_with(_body)
	_dodge_body_exceptions.clear()
	if is_instance_valid(_body):
		_body.velocity.x = 0.0


func has_dodge_end_overlap() -> bool:
	if _body == null or _dodge_body_exceptions.is_empty():
		return false
	var body_shape := _body.get_node("CollisionShape2D") as CollisionShape2D
	if body_shape.disabled or body_shape.shape == null:
		return false
	for entry in _dodge_body_exceptions:
		var other := entry["body"].get_ref() as Entity
		if not is_instance_valid(other) or other.is_player_combatant() or not other.uses_combat_hit_reaction() or other.health.is_zero():
			continue
		if not _body.get_collision_exceptions().has(other) and not other.get_collision_exceptions().has(_body):
			continue
		var other_shape := other.get_node("CollisionShape2D") as CollisionShape2D
		if other_shape.disabled or other_shape.shape == null:
			continue
		# Actual current body transforms, independent of pass-through exceptions.
		if body_shape.shape.collide(body_shape.global_transform, other_shape.shape, other_shape.global_transform):
			return true
	return false


func _exit_tree() -> void:
	end_dodge()


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
