@tool
class_name EnemyCombatSettings
extends Resource
## The CombatEnemy's authored stats and decisions, independent of its room.

@export_group("Health")
@export var enemy: Dictionary = {}
@export_group("AI Decisions and Impact")
## Windup and recovery come from AnimationPlayer, never from this dictionary.
@export var enemy_ai: Dictionary = {}
@export var attack: Dictionary = {}
@export_group("Elemental Endurance")
@export var elemental_endurance: Dictionary = {}
@export_group("Shared Hit Reaction")
@export var hit_reaction: CharacterReactionSettings


func apply_to_config(config: Dictionary) -> void:
	config["enemy"] = enemy.duplicate(true)
	config["enemy_ai"] = enemy_ai.duplicate(true)
	config["enemy_ai"]["impact"] = int(attack["impact"])
	config["moves"]["final_enemy_attack"] = attack.duplicate(true)
	config["elemental_endurance"] = elemental_endurance.duplicate(true)


func read_from_config(config: Dictionary) -> void:
	enemy = config["enemy"].duplicate(true)
	enemy_ai = config["enemy_ai"].duplicate(true)
	# Retired compatibility keys must not become Inspector controls again.
	enemy_ai.erase("impact")
	enemy_ai.erase("windup_duration")
	enemy_ai.erase("recovery_duration")
	enemy_ai.erase("hitbox_reach")
	enemy_ai.erase("hitbox_radius")
	attack = config["moves"]["final_enemy_attack"].duplicate(true)
	elemental_endurance = config["elemental_endurance"].duplicate(true)
