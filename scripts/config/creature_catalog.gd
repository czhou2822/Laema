@tool
extends RefCounted
## One roster for Portal choices, encounter loading and creature shortcuts.

const DEFAULT_ID := "pikeman"
const ENTRIES := {
	"pikeman": {
		"label": "Pikeman", "scene": "res://scenes/enemy/combat_enemy.tscn",
		"faction": "castle", "tier": 1, "upgraded": false,
	},
	"archer": {
		"label": "Archer", "scene": "res://scenes/enemy/archer.tscn",
		"faction": "castle", "tier": 2, "upgraded": false,
	},
	"griffin": {
		"label": "Griffin", "scene": "res://scenes/enemy/griffin.tscn",
		"faction": "castle", "tier": 3, "upgraded": false,
	},
	"swordsman": {
		"label": "Swordsman", "scene": "res://scenes/enemy/swordsman.tscn",
		"faction": "castle", "tier": 4, "upgraded": false,
	},
	"monk": {
		"label": "Monk", "scene": "res://scenes/enemy/monk.tscn",
		"faction": "castle", "tier": 5, "upgraded": false,
	},
	"cavalier": {
		"label": "Cavalier", "scene": "res://scenes/enemy/cavalier.tscn",
		"faction": "castle", "tier": 6, "upgraded": false,
	},
	"angel": {
		"label": "Angel", "scene": "res://scenes/enemy/angel.tscn",
		"faction": "castle", "tier": 7, "upgraded": false,
	},
	"halberdier": {
		"label": "Halberdier", "scene": "res://scenes/enemy/halberdier.tscn",
		"faction": "castle", "tier": 1, "upgraded": true,
	},
	"marksman": {
		"label": "Marksman", "scene": "res://scenes/enemy/marksman.tscn",
		"faction": "castle", "tier": 2, "upgraded": true,
	},
	"royal_griffin": {
		"label": "Royal Griffin", "scene": "res://scenes/enemy/royal_griffin.tscn",
		"faction": "castle", "tier": 3, "upgraded": true,
	},
	"crusader": {
		"label": "Crusader", "scene": "res://scenes/enemy/crusader.tscn",
		"faction": "castle", "tier": 4, "upgraded": true,
	},
	"zealot": {
		"label": "Zealot", "scene": "res://scenes/enemy/zealot.tscn",
		"faction": "castle", "tier": 5, "upgraded": true,
	},
	"champion": {
		"label": "Champion", "scene": "res://scenes/enemy/champion.tscn",
		"faction": "castle", "tier": 6, "upgraded": true,
	},
	"archangel": {
		"label": "Archangel", "scene": "res://scenes/enemy/archangel.tscn",
		"faction": "castle", "tier": 7, "upgraded": true,
	},
	"skeleton": {
		"label": "Skeleton", "scene": "res://scenes/enemy/skeleton.tscn",
		"faction": "necropolis", "tier": 1, "upgraded": false,
	},
	"skeleton_warrior": {
		"label": "Skeleton Warrior", "scene": "res://scenes/enemy/skeleton_warrior.tscn",
		"faction": "necropolis", "tier": 1, "upgraded": true,
	},
	"walking_dead": {
		"label": "Walking Dead", "scene": "res://scenes/enemy/walking_dead.tscn",
		"faction": "necropolis", "tier": 2, "upgraded": false,
	},
	"zombie": {
		"label": "Zombie", "scene": "res://scenes/enemy/zombie.tscn",
		"faction": "necropolis", "tier": 2, "upgraded": true,
	},
	"wight": {
		"label": "Wight", "scene": "res://scenes/enemy/wight.tscn",
		"faction": "necropolis", "tier": 3, "upgraded": false,
	},
	"wraith": {
		"label": "Wraith", "scene": "res://scenes/enemy/wraith.tscn",
		"faction": "necropolis", "tier": 3, "upgraded": true,
	},
	"vampire": {
		"label": "Vampire", "scene": "res://scenes/enemy/vampire.tscn",
		"faction": "necropolis", "tier": 4, "upgraded": false,
	},
	"vampire_lord": {
		"label": "Vampire Lord", "scene": "res://scenes/enemy/vampire_lord.tscn",
		"faction": "necropolis", "tier": 4, "upgraded": true,
	},
	"lich": {
		"label": "Lich", "scene": "res://scenes/enemy/lich.tscn",
		"faction": "necropolis", "tier": 5, "upgraded": false,
	},
	"power_lich": {
		"label": "Power Lich", "scene": "res://scenes/enemy/power_lich.tscn",
		"faction": "necropolis", "tier": 5, "upgraded": true,
	},
	"black_knight": {
		"label": "Black Knight", "scene": "res://scenes/enemy/black_knight.tscn",
		"faction": "necropolis", "tier": 6, "upgraded": false,
	},
	"dread_knight": {
		"label": "Dread Knight", "scene": "res://scenes/enemy/dread_knight.tscn",
		"faction": "necropolis", "tier": 6, "upgraded": true,
	},
	"bone_dragon": {
		"label": "Bone Dragon", "scene": "res://scenes/enemy/bone_dragon.tscn",
		"faction": "necropolis", "tier": 7, "upgraded": false,
	},
	"ghost_dragon": {
		"label": "Ghost Dragon", "scene": "res://scenes/enemy/ghost_dragon.tscn",
		"faction": "necropolis", "tier": 7, "upgraded": true,
	},
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


static func shortcut_target(tier: int, selected_id: String, shift_pressed: bool) -> String:
	var selected: Dictionary = ENTRIES.get(selected_id, {})
	var faction := str(selected.get("faction", "castle"))
	var same_tier := int(selected.get("tier", 0)) == tier
	# Shift on another tier selects its upgrade; only that selected upgrade toggles back.
	var upgraded := shift_pressed and not (same_tier and bool(selected.get("upgraded", false)))
	if not shift_pressed:
		faction = "necropolis" if same_tier and faction == "castle" else "castle"
	for creature_id in ENTRIES:
		var entry: Dictionary = ENTRIES[creature_id]
		if entry["tier"] == tier and entry["faction"] == faction and entry["upgraded"] == upgraded:
			return str(creature_id)
	return ""
