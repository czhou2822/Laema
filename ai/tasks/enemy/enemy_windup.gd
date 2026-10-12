@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var attack_range_var: StringName = &"attack_range"
@export var duration_var: StringName = &"windup_duration"

var _remaining := 0.0
var _just_entered := false


func _enter() -> void:
	_remaining = float(blackboard.get_var(duration_var))
	_just_entered = true
	var target: Node2D = blackboard.get_var(target_var, null)
	if is_instance_valid(target):
		agent.call("ai_begin_windup", target, float(blackboard.get_var(attack_range_var)), _remaining)


func _tick(delta: float) -> Status:
	if not is_instance_valid(blackboard.get_var(target_var, null)):
		return FAILURE
	if _just_entered:
		# Entry commits geometry; countdown starts on the next physics update.
		_just_entered = false
		return RUNNING
	_remaining = maxf(_remaining - delta, 0.0)
	agent.call("ai_show_windup_remaining", _remaining)
	return SUCCESS if _remaining <= 0.0 else RUNNING


func _exit() -> void:
	_remaining = 0.0
	_just_entered = false
