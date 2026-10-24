@tool
extends BTAction


func _enter() -> void:
	agent.call("ai_begin_recovery")


func _tick(_delta: float) -> Status:
	if not bool(agent.call("ai_recovery_finished")):
		return RUNNING
	agent.call("ai_idle")
	return SUCCESS
