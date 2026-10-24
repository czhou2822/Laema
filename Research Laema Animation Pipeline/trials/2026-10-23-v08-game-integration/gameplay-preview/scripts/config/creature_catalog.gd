@tool
extends RefCounted
## One creature identity shared by the editor Portal and runtime encounter loader.

const DEFAULT_ID := "pikeman"
const ENTRIES := {
	"pikeman": {"label": "Pikeman", "scene": "res://scenes/enemy/combat_enemy.tscn"},
	"archer": {"label": "Archer", "scene": "res://scenes/enemy/archer.tscn"},
	"griffin": {"label": "Griffin", "scene": "res://scenes/enemy/griffin.tscn"},
	"swordsman": {"label": "Swordsman", "scene": "res://scenes/enemy/swordsman.tscn"},
	"monk": {"label": "Monk", "scene": "res://scenes/enemy/monk.tscn"},
	"cavalier": {"label": "Cavalier", "scene": "res://scenes/enemy/cavalier.tscn"},
	"angel": {"label": "Angel", "scene": "res://scenes/enemy/angel.tscn"},
}


static func scene_path(creature_id: String) -> String:
	return str(ENTRIES.get(creature_id, {}).get("scene", ""))


static func available(creature_id: String) -> bool:
	var path := scene_path(creature_id)
	return not path.is_empty() and FileAccess.file_exists(path)


static func options() -> Array:
	var result: Array = []
	for creature_id in ENTRIES:
		if available(creature_id):
			result.append([creature_id, ENTRIES[creature_id]["label"]])
	return result
