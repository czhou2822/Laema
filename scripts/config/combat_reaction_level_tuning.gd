@tool
class_name CombatReactionLevelTuning
extends Resource

@export_range(0, 2147483647, 1) var minimum_value := 0:
	set(value):
		minimum_value = value
		emit_changed()

@export_range(0.001, 60.0, 0.01, "or_greater") var duration := 0.3:
	set(value):
		duration = value
		emit_changed()

@export_range(0.0, 1000.0, 1.0, "or_greater") var distance := 5.0:
	set(value):
		distance = value
		emit_changed()
