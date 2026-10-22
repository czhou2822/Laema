@tool
class_name CharacterReactionSettings
extends Resource
## Both characters reference this one reaction definition. The component owns execution.

@export var combat_levels: Array[CombatReactionLevelTuning] = []
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
	return {"combat_levels": levels, "base_duration": base_duration,
		"duration_per_level": duration_per_level, "base_distance": base_distance,
		"distance_per_level": distance_per_level}


func read_from_config(config: Dictionary) -> void:
	var data: Dictionary = config["hit_reaction"]
	for key in ["base_duration", "duration_per_level", "base_distance", "distance_per_level"]:
		set(key, float(data[key]))
	for index in range(combat_levels.size()):
		var level: CombatReactionLevelTuning = combat_levels[index]
		level.minimum_value = int(data["combat_levels"][index]["minimum_value"])
		level.duration = float(data["combat_levels"][index]["duration"])
		level.motion_duration = float(data["combat_levels"][index].get("motion_duration", level.duration))
		level.distance = float(data["combat_levels"][index]["distance"])
