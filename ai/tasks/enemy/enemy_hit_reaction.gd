@tool
extends BTAction


func _enter() -> void:
	agent.call("ai_execute_hit_reaction")


func _tick(_delta: float) -> Status:
	if bool(agent.call("ai_is_reacting")):
		agent.call("ai_hold_hit_reaction")
		return RUNNING
	agent.call("ai_idle")
	return SUCCESS
