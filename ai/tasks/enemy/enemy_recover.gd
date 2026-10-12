@tool
extends BTAction

@export var duration_var: StringName = &"recovery_duration"

var _remaining := 0.0
var _just_entered := false


func _enter() -> void:
	_remaining = float(blackboard.get_var(duration_var))
	_just_entered = true
	agent.call("ai_begin_recovery")


func _tick(delta: float) -> Status:
	if _just_entered:
		# Do not spend the strike frame's delta a second time on recovery.
		_just_entered = false
		return RUNNING
	_remaining = maxf(_remaining - delta, 0.0)
	if _remaining > 0.0:
		return RUNNING
	agent.call("ai_idle")
	return SUCCESS


func _exit() -> void:
	_remaining = 0.0
	_just_entered = false
