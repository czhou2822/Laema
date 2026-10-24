@tool
extends BTAction

@export var target_var: StringName = &"target"


func _enter() -> void:
	var target: Node2D = blackboard.get_var(target_var, null)
	if is_instance_valid(target):
		agent.call("ai_begin_windup", target)


func _tick(_delta: float) -> Status:
	if not is_instance_valid(blackboard.get_var(target_var, null)):
		return FAILURE
	return SUCCESS if bool(agent.call("ai_windup_finished")) else RUNNING
