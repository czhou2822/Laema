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
const IMPACT_CAMERA_LEVEL_DEFAULTS := CombatReactionLevelTuning.CAMERA_DEFAULTS

@export var combat_levels: Array[CombatReactionLevelTuning] = []

# Inactive compatibility data. Retained on explicit save, hidden in the Inspector.
@export_storage var impact_precise_camera_strength := float(IMPACT_CAMERA_DEFAULTS["impact_precise_camera_strength"]):
	set(value):
		impact_precise_camera_strength = value
		emit_changed()
@export_storage var impact_precise_camera_duration := float(IMPACT_CAMERA_DEFAULTS["impact_precise_camera_duration"]):
	set(value):
		impact_precise_camera_duration = value
		emit_changed()
@export_storage var impact_weight_camera_strength := float(IMPACT_CAMERA_DEFAULTS["impact_weight_camera_strength"]):
	set(value):
		impact_weight_camera_strength = value
		emit_changed()
@export_storage var impact_weight_camera_duration := float(IMPACT_CAMERA_DEFAULTS["impact_weight_camera_duration"]):
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
		levels.append(level.get_data())
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
		level.read_camera_data(data["combat_levels"][index], index)
