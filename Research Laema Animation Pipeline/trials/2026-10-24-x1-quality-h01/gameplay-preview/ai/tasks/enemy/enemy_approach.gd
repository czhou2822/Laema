@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var aggro_range_var: StringName = &"aggro_range"
@export var attack_range_var: StringName = &"attack_range"
@export var speed_var: StringName = &"movement_speed"

var _just_entered := false


func _enter() -> void:
	_just_entered = true


func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	var distance := absf(target.global_position.x - (agent as Node2D).global_position.x)
	if distance > float(blackboard.get_var(aggro_range_var)):
		return FAILURE
	if distance <= float(blackboard.get_var(attack_range_var)):
		return SUCCESS
	agent.call("ai_begin_approach")
	if _just_entered:
		# Preserve the original idle-to-approach transition frame.
		_just_entered = false
		return RUNNING
	agent.call("ai_move_toward", target, float(blackboard.get_var(speed_var)))
	return RUNNING


func _exit() -> void:
	if is_instance_valid(agent):
		agent.call("ai_stop_moving")
