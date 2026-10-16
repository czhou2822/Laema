@tool
class_name MoveImpactTuning
extends Resource

@export var move_id: StringName = &"":
	set(value):
		move_id = value
		emit_changed()

@export_range(0, 100, 1) var impact := 1:
	set(value):
		impact = value
		emit_changed()
