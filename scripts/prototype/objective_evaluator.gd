class_name ObjectiveEvaluator
extends Node

func configure(_objective: Dictionary) -> void:
	pass


func consume_outcome(_outcome: Dictionary) -> Dictionary:
	return {"kind": &"unchanged"}
