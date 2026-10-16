@tool
extends BTCondition


func _tick(_delta: float) -> Status:
	return SUCCESS if bool(agent.call("ai_is_reacting")) else FAILURE
