@tool
extends BTCondition

@export var target_var: StringName = &"target"
@export var aggro_range_var: StringName = &"aggro_range"


func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	var distance := absf(target.global_position.x - (agent as Node2D).global_position.x)
	return SUCCESS if distance <= float(blackboard.get_var(aggro_range_var)) else FAILURE
