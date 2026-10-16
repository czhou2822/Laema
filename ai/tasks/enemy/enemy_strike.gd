@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var damage_var: StringName = &"damage"
@export var impact_var: StringName = &"impact"


func _tick(_delta: float) -> Status:
	var target: Node2D = blackboard.get_var(target_var, null)
	if not is_instance_valid(target):
		return FAILURE
	if not bool(agent.call("ai_strike", target, float(blackboard.get_var(damage_var)), int(blackboard.get_var(impact_var)))):
		return FAILURE
	return SUCCESS if bool(agent.call("ai_strike_finished")) else RUNNING
