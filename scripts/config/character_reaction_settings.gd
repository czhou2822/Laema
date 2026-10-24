@tool
class_name CharacterReactionSettings
extends Resource
## Both characters reference this one reaction definition. The component owns execution.

const IMPACT_CAMERA_DEFAULTS := {
	"impact_precise_camera_strength": 1.0,
	"impact_precise_camera_duration": 0.08,
	"impact_weight_camera_strength": 3.0,
	"impact_weight_camera_duration": 0.11,
}

@export var combat_levels: Array[CombatReactionLevelTuning] = []

@export_group("Cosmetic impact feedback")
@export_subgroup("Precise camera", "impact_precise_camera_")
## Maximum viewport-pixel amplitude before the existing reaction-level scaling.
## Shared Hit Reaction is authoritative in every playable scene.
@export_range(0.0, 3.0, 0.05) var impact_precise_camera_strength := float(IMPACT_CAMERA_DEFAULTS["impact_precise_camera_strength"]):
	set(value):
		impact_precise_camera_strength = value
		emit_changed()
## Cue duration in seconds; applies to the next qualifying camera cue.
@export_range(0.001, 0.12, 0.001) var impact_precise_camera_duration := float(IMPACT_CAMERA_DEFAULTS["impact_precise_camera_duration"]):
	set(value):
		impact_precise_camera_duration = value
		emit_changed()
@export_subgroup("Weight camera", "impact_weight_camera_")
## Maximum viewport-pixel amplitude before the existing reaction-level scaling.
@export_range(0.0, 3.0, 0.05) var impact_weight_camera_strength := float(IMPACT_CAMERA_DEFAULTS["impact_weight_camera_strength"]):
	set(value):
		impact_weight_camera_strength = value
		emit_changed()
## Cue duration in seconds; applies to the next qualifying camera cue.
@export_range(0.001, 0.12, 0.001) var impact_weight_camera_duration := float(IMPACT_CAMERA_DEFAULTS["impact_weight_camera_duration"]):
	set(value):
		impact_weight_camera_duration = value
		emit_changed()
@export_group("Practice, Defence and Failed Cast")
@export var base_duration := 0.14
@export var duration_per_level := 0.07
@export var base_distance := 7.0
@export var distance_per_level := 3.5


func get_data() -> Dictionary:
	var levels: Array = []
	for level in combat_levels:
		if level == null:
			return {}
		levels.append({"minimum_value": level.minimum_value, "duration": level.duration,
			"motion_duration": level.motion_duration, "distance": level.distance})
	var data := {"combat_levels": levels, "base_duration": base_duration,
		"duration_per_level": duration_per_level, "base_distance": base_distance,
		"distance_per_level": distance_per_level}
	for key in IMPACT_CAMERA_DEFAULTS:
		data[key] = get(key)
	return data


func read_from_config(config: Dictionary) -> void:
	var data: Dictionary = config["hit_reaction"]
	for key in IMPACT_CAMERA_DEFAULTS:
		set(key, float(data.get(key, IMPACT_CAMERA_DEFAULTS[key])))
	for key in ["base_duration", "duration_per_level", "base_distance", "distance_per_level"]:
		set(key, float(data[key]))
	for index in range(combat_levels.size()):
		var level: CombatReactionLevelTuning = combat_levels[index]
		level.minimum_value = int(data["combat_levels"][index]["minimum_value"])
		level.duration = float(data["combat_levels"][index]["duration"])
		level.motion_duration = float(data["combat_levels"][index].get("motion_duration", level.duration))
		level.distance = float(data["combat_levels"][index]["distance"])
