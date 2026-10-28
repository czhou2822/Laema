@tool
class_name CombatTuningSettings
extends Resource

const Style = preload("res://scripts/combat/attack_style.gd")
const Config = preload("res://scripts/config/prototype_config_loader.gd")

# Inactive compatibility data, never a competing camera profile.
@export_storage var impact_precise_camera_strength := float(Config.IMPACT_CAMERA_DEFAULTS["impact_precise_camera_strength"]):
	set(value):
		impact_precise_camera_strength = value
		emit_changed()
@export_storage var impact_precise_camera_duration := float(Config.IMPACT_CAMERA_DEFAULTS["impact_precise_camera_duration"]):
	set(value):
		impact_precise_camera_duration = value
		emit_changed()
@export_storage var impact_weight_camera_strength := float(Config.IMPACT_CAMERA_DEFAULTS["impact_weight_camera_strength"]):
	set(value):
		impact_weight_camera_strength = value
		emit_changed()
@export_storage var impact_weight_camera_duration := float(Config.IMPACT_CAMERA_DEFAULTS["impact_weight_camera_duration"]):
	set(value):
		impact_weight_camera_duration = value
		emit_changed()

@export_group("Character Poise")
@export_range(0, 100, 1) var player_poise := 0:
	set(value):
		player_poise = value
		emit_changed()
@export_range(0, 100, 1) var final_enemy_poise := 0:
	set(value):
		final_enemy_poise = value
		emit_changed()

@export_group("Move Impact")
@export var moves: Array[MoveImpactTuning] = []:
	set(value):
		moves = value
		emit_changed()

@export_group("Combat Hit Reaction - Levels 1 to 5")
@export var combat_levels: Array[CombatReactionLevelTuning] = []:
	set(value):
		combat_levels = value
		emit_changed()

@export_group("School Attack Styles - X1 to X5")
@export var attack_styles: Array[MoveStyleTuning] = []:
	set(value):
		attack_styles = value
		emit_changed()

@export_group("Legacy Practice - Defence - Failed Cast")
@export_range(0.001, 60.0, 0.01, "or_greater") var legacy_base_duration := 0.14:
	set(value):
		legacy_base_duration = value
		emit_changed()
@export_range(0.0, 60.0, 0.01, "or_greater") var legacy_duration_per_level := 0.07:
	set(value):
		legacy_duration_per_level = value
		emit_changed()
@export_range(0.0, 1000.0, 0.1, "or_greater") var legacy_base_distance := 7.0:
	set(value):
		legacy_base_distance = value
		emit_changed()
@export_range(0.0, 1000.0, 0.1, "or_greater") var legacy_distance_per_level := 3.5:
	set(value):
		legacy_distance_per_level = value
		emit_changed()


func save_resources(path: String, save_external_styles: bool = true) -> Dictionary:
	# Saving the parent stores external references, not changes inside those files.
	for style in attack_styles:
		if style == null:
			return {"ok": false, "error": "Cannot save a missing attack-style Resource."}
		if not save_external_styles:
			continue # Coordinated saves already persisted the character-owned styles.
		var style_path := style.resource_path
		if style_path.is_empty() or style_path.contains("::"):
			continue
		var style_error := ResourceSaver.save(style, style_path)
		if style_error != OK:
			return {"ok": false, "error": "Cannot save %s: %s" % [style_path, error_string(style_error)]}
	var error := ResourceSaver.save(self, path)
	if error != OK:
		return {"ok": false, "error": "Cannot save combat tuning Resource: %s" % error_string(error)}
	return {"ok": true, "error": ""}


static func save_config_mirror(
	config: Dictionary,
	path: String,
	save_external_styles: bool = true
) -> Dictionary:
	# A separate graph avoids applying Portal saves to a running Inspector view.
	# Ignore only the parent cache: reloading live Script dependencies is unsafe.
	var mirror := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as CombatTuningSettings
	if mirror == null:
		return {"ok": false, "error": "Cannot load combat tuning Resource: %s" % path}
	var source_styles: Dictionary = {}
	for index in range(mirror.attack_styles.size()):
		var source: MoveStyleTuning = mirror.attack_styles[index]
		if source == null:
			return {"ok": false, "error": "Cannot save a missing attack-style Resource."}
		source_styles[source.move_id] = source
		mirror.attack_styles[index] = source.duplicate()
	mirror.read_from_config(config)
	for index in range(mirror.attack_styles.size()):
		var style: MoveStyleTuning = mirror.attack_styles[index]
		var source: MoveStyleTuning = source_styles.get(style.move_id)
		if source == null or source.resource_path.is_empty() or source.is_built_in():
			continue
		if save_external_styles:
			var error := ResourceSaver.save(style, source.resource_path)
			if error != OK:
				return {"ok": false, "error": "Cannot save %s: %s" % [source.resource_path, error_string(error)]}
		# Serialize the original file reference without changing its cached values.
		mirror.attack_styles[index] = source
	var error := ResourceSaver.save(mirror, path)
	if error != OK:
		return {"ok": false, "error": "Cannot save combat tuning Resource: %s" % error_string(error)}
	return {"ok": true, "error": ""}


func get_data() -> Dictionary:
	var impacts: Dictionary = {}
	for move in moves:
		if move == null or impacts.has(String(move.move_id)):
			return {}
		impacts[String(move.move_id)] = move.impact
	var levels: Array = []
	for level in combat_levels:
		if level == null:
			return {}
		levels.append(level.get_data())
	var styles: Dictionary = {}
	for style in attack_styles:
		if style == null or styles.has(String(style.move_id)):
			return {}
		styles[String(style.move_id)] = style.get_data()
	var reaction := {
		"base_duration": legacy_base_duration,
		"duration_per_level": legacy_duration_per_level,
		"base_distance": legacy_base_distance,
		"distance_per_level": legacy_distance_per_level,
		"combat_levels": levels,
	}
	return {
		"player_poise": player_poise,
		"final_enemy_poise": final_enemy_poise,
		"moves": impacts,
		"attack_styles": styles,
		"hit_reaction": reaction,
	}


func apply_to_config(config: Dictionary) -> Dictionary:
	var data := get_data()
	if data.is_empty() or combat_levels.size() != 5 or moves.size() != Dictionary(config["moves"]).size():
		return {"ok": false, "error": "Combat tuning requires unique move entries and exactly five non-null reaction levels."}
	for id in data["moves"]:
		if not config["moves"].has(id):
			return {"ok": false, "error": "Unknown Inspector move: %s" % id}
	if attack_styles.size() != 20:
		return {"ok": false, "error": "Attack styles require all four schools' X1–X5 entries."}
	for id in data["attack_styles"]:
		if not config["moves"].has(id) or id in ["cast", "final_enemy_attack"]:
			return {"ok": false, "error": "Unknown Inspector attack style: %s" % id}
	apply_data_to_config(data, config)
	return {"ok": true, "error": ""}


static func apply_data_to_config(data: Dictionary, config: Dictionary) -> void:
	config["player"]["poise"] = data["player_poise"]
	config["enemy_ai"]["poise"] = data["final_enemy_poise"]
	for id in data["moves"]:
		config["moves"][id]["impact"] = data["moves"][id]
	for id in data.get("attack_styles", {}):
		config["moves"][id].merge(Style.read_move(data["attack_styles"][id]), true)
	Style.strip_retired_fields(config)
	for key in data["hit_reaction"]:
		config["hit_reaction"][key] = data["hit_reaction"][key].duplicate(true) if key == "combat_levels" else data["hit_reaction"][key]


func read_from_config(config: Dictionary) -> void:
	read_data(data_from_config(config))


static func data_from_config(config: Dictionary) -> Dictionary:
	var reaction: Dictionary = {}
	for key in ["base_duration", "duration_per_level", "base_distance", "distance_per_level", "combat_levels"]:
		reaction[key] = config["hit_reaction"][key].duplicate(true) if key == "combat_levels" else config["hit_reaction"][key]
	var styles: Dictionary = {}
	for school in ["fire", "water", "air", "earth"]:
		for position in range(1, 6):
			var id := "%s_x%d" % [school, position]
			styles[id] = Style.read_move(config["moves"][id])
	return {
		"player_poise": config["player"]["poise"],
		"final_enemy_poise": config["enemy_ai"]["poise"],
		"moves": _read_impacts(config["moves"]),
		"attack_styles": styles,
		"hit_reaction": reaction,
	}


func read_data(data: Dictionary) -> void:
	# Retain this mirror's inactive legacy fields without overwriting the shared
	# Resource's independent compatibility data through bridge synchronization.
	player_poise = int(data["player_poise"])
	final_enemy_poise = int(data["final_enemy_poise"])
	var next_moves: Array[MoveImpactTuning] = []
	var ids: Array = data["moves"].keys()
	ids.sort()
	for id in ids:
		var entry: MoveImpactTuning
		for existing in moves:
			if existing != null and String(existing.move_id) == String(id):
				entry = existing
				break
		if entry == null:
			entry = MoveImpactTuning.new()
			entry.move_id = StringName(id)
			entry.resource_name = String(id)
		entry.impact = int(data["moves"][id])
		next_moves.append(entry)
	moves = next_moves
	var next_styles: Array[MoveStyleTuning] = []
	for id in data.get("attack_styles", {}):
		var entry: MoveStyleTuning
		for existing in attack_styles:
			if existing != null and String(existing.move_id) == String(id):
				entry = existing
				break
		if entry == null:
			entry = MoveStyleTuning.new()
			entry.move_id = StringName(id)
			entry.resource_name = String(id)
		entry.read_data(data["attack_styles"][id])
		next_styles.append(entry)
	attack_styles = next_styles
	var next_levels: Array[CombatReactionLevelTuning] = []
	var values: Array = data["hit_reaction"]["combat_levels"]
	for index in range(values.size()):
		var entry: CombatReactionLevelTuning = combat_levels[index] if index < combat_levels.size() else null
		if entry == null:
			entry = CombatReactionLevelTuning.new()
			entry.resource_name = "Level %d" % (index + 1)
		entry.duration = float(values[index]["duration"])
		entry.motion_duration = float(values[index].get("motion_duration", entry.duration))
		entry.minimum_value = int(values[index]["minimum_value"])
		entry.distance = float(values[index]["distance"])
		entry.read_camera_data(values[index], index)
		next_levels.append(entry)
	combat_levels = next_levels
	legacy_base_duration = float(data["hit_reaction"]["base_duration"])
	legacy_duration_per_level = float(data["hit_reaction"]["duration_per_level"])
	legacy_base_distance = float(data["hit_reaction"]["base_distance"])
	legacy_distance_per_level = float(data["hit_reaction"]["distance_per_level"])
	notify_property_list_changed()


func get_nested_resources() -> Array[Resource]:
	var resources: Array[Resource] = [self]
	for move in moves:
		if move != null:
			resources.append(move)
	for style in attack_styles:
		if style != null:
			resources.append(style)
	for level in combat_levels:
		if level != null:
			resources.append(level)
	return resources


static func _read_impacts(moves_data: Dictionary) -> Dictionary:
	var values: Dictionary = {}
	for id in moves_data:
		values[id] = moves_data[id]["impact"]
	return values
