@tool
class_name MoveStyleTuning
extends Resource

const Style = preload("res://scripts/combat/attack_style.gd")

@export_group("Animation - scrub and edit in Player AnimationPlayer")
@export var animation: Animation

@export var move_id: StringName = &"":
	set(value):
		move_id = value
		emit_changed()
@export_group("Timing - seconds before Heat scaling")
@export_range(0.0, 5.0, 0.01, "or_greater") var windup_duration := 0.0:
	set(value):
		windup_duration = value
		emit_changed()
@export_range(0.0, 5.0, 0.01, "or_greater") var recovery_duration := 0.0:
	set(value):
		recovery_duration = value
		emit_changed()
@export_group("Active geometry - animation active_start key, pixels")
@export_range(0.0, 400.0, 1.0, "or_greater") var shape_reach := 0.0:
	set(value):
		shape_reach = value
		emit_changed()
@export_range(0.001, 200.0, 1.0, "or_greater") var shape_radius := 0.001:
	set(value):
		shape_radius = value
		emit_changed()
@export_group("Forward body motion")
@export_range(0.0, 400.0, 1.0, "or_greater") var lunge_distance := 0.0:
	set(value):
		lunge_distance = value
		emit_changed()
@export_range(0.0, 1.0, 0.01) var lunge_start_phase := 0.0:
	set(value):
		lunge_start_phase = value
		emit_changed()
@export_range(0.0, 1.0, 0.01) var lunge_end_phase := 0.5:
	set(value):
		lunge_end_phase = value
		emit_changed()
@export_group("Qualifying hit reaction")
@export_range(0.0, 5.0, 0.05, "or_greater") var push_scale := 1.0:
	set(value):
		push_scale = value
		emit_changed()


func get_data() -> Dictionary:
	return {
		"windup_duration": windup_duration, "recovery_duration": recovery_duration,
		"shape_reach": shape_reach, "shape_radius": shape_radius, "push_scale": push_scale,
		"forward_lunge": {"distance": lunge_distance, "start_phase": lunge_start_phase, "end_phase": lunge_end_phase},
	}


func read_data(data: Dictionary) -> void:
	for key in Style.DEFAULTS:
		set(key, float(data[key]))
	lunge_distance = float(data["forward_lunge"]["distance"])
	lunge_start_phase = float(data["forward_lunge"]["start_phase"])
	lunge_end_phase = float(data["forward_lunge"]["end_phase"])
