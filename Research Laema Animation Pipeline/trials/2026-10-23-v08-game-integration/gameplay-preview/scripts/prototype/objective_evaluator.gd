class_name ObjectiveEvaluator
extends Node

func configure(_objective: Dictionary) -> void:
	pass


func consume_outcome(_outcome: Dictionary) -> Dictionary:
	return {"kind": &"unchanged"}


func consume_heat(_value: float, _level: int, _speed_multiplier: float) -> Dictionary:
	return {"kind": &"unchanged"}


func get_row_state() -> Dictionary:
	return {}
