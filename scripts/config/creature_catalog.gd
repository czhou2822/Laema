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
	"halberdier": {"label": "Halberdier", "scene": "res://scenes/enemy/halberdier.tscn"},
	"marksman": {"label": "Marksman", "scene": "res://scenes/enemy/marksman.tscn"},
	"royal_griffin": {"label": "Royal Griffin", "scene": "res://scenes/enemy/royal_griffin.tscn"},
	"crusader": {"label": "Crusader", "scene": "res://scenes/enemy/crusader.tscn"},
	"zealot": {"label": "Zealot", "scene": "res://scenes/enemy/zealot.tscn"},
	"champion": {"label": "Champion", "scene": "res://scenes/enemy/champion.tscn"},
	"archangel": {"label": "Archangel", "scene": "res://scenes/enemy/archangel.tscn"},
	"skeleton": {"label": "Skeleton", "scene": "res://scenes/enemy/skeleton.tscn"},
	"skeleton_warrior": {"label": "Skeleton Warrior", "scene": "res://scenes/enemy/skeleton_warrior.tscn"},
	"walking_dead": {"label": "Walking Dead", "scene": "res://scenes/enemy/walking_dead.tscn"},
	"zombie": {"label": "Zombie", "scene": "res://scenes/enemy/zombie.tscn"},
	"wight": {"label": "Wight", "scene": "res://scenes/enemy/wight.tscn"},
	"wraith": {"label": "Wraith", "scene": "res://scenes/enemy/wraith.tscn"},
	"vampire": {"label": "Vampire", "scene": "res://scenes/enemy/vampire.tscn"},
	"vampire_lord": {"label": "Vampire Lord", "scene": "res://scenes/enemy/vampire_lord.tscn"},
	"lich": {"label": "Lich", "scene": "res://scenes/enemy/lich.tscn"},
	"power_lich": {"label": "Power Lich", "scene": "res://scenes/enemy/power_lich.tscn"},
	"black_knight": {"label": "Black Knight", "scene": "res://scenes/enemy/black_knight.tscn"},
	"dread_knight": {"label": "Dread Knight", "scene": "res://scenes/enemy/dread_knight.tscn"},
	"bone_dragon": {"label": "Bone Dragon", "scene": "res://scenes/enemy/bone_dragon.tscn"},
	"ghost_dragon": {"label": "Ghost Dragon", "scene": "res://scenes/enemy/ghost_dragon.tscn"},
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
