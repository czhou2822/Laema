@tool
extends BTAction


func _tick(_delta: float) -> Status:
	agent.call("ai_idle")
	return SUCCESS
