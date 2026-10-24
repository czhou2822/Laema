@tool
class_name PlayerCombatSettings
extends Resource
## Authored on the reusable Player, shared by every scene that instances it.

const Style = preload("res://scripts/combat/attack_style.gd")

@export var initial_school := "fire"

@export_group("Player")
@export var player: Dictionary = {}:
	set(value):
		player = value
		emit_changed()
@export_group("Movement")
@export var movement: Dictionary = {}:
	set(value):
		movement = value
		emit_changed()
@export_group("Combat")
@export var combat: Dictionary = {}:
	set(value):
		combat = value
		emit_changed()
@export_group("Casting")
@export var casting: Dictionary = {}:
	set(value):
		casting = value
		emit_changed()
@export_group("Heat")
@export var heat: Dictionary = {}:
	set(value):
		heat = value
		emit_changed()
@export_group("Defence")
@export var defence: Dictionary = {}:
	set(value):
		defence = value
		emit_changed()
@export_group("Fire")
@export var fire: Dictionary = {}:
	set(value):
		fire = value
		emit_changed()
@export_group("Water")
@export var water: Dictionary = {}:
	set(value):
		water = value
		emit_changed()
@export_group("Air")
@export var air: Dictionary = {}:
	set(value):
		air = value
		emit_changed()
@export_group("Earth")
@export var earth: Dictionary = {}:
	set(value):
		earth = value
		emit_changed()

@export_group("Moves")
@export var moves: Dictionary = {}:
	set(value):
		moves = value
		emit_changed()
@export var attack_styles: Array[MoveStyleTuning] = []
@export_group("Shared Hit Reaction")
@export var hit_reaction: CharacterReactionSettings


func apply_to_config(config: Dictionary) -> void:
	if config.get("tutorial") is Dictionary:
		config["tutorial"]["initial_school"] = initial_school
	config["player"] = player.duplicate(true)
	config["movement"] = movement.duplicate(true)
	config["combat"] = combat.duplicate(true)
	config["casting"] = casting.duplicate(true)
	config["heat"] = heat.duplicate(true)
	config["defence"] = defence.duplicate(true)
	config["fire"] = fire.duplicate(true)
	config["water"] = water.duplicate(true)
	config["air"] = air.duplicate(true)
	config["earth"] = earth.duplicate(true)
	config["moves"] = moves.duplicate(true)
	for style in attack_styles:
		if style != null and config["moves"].has(String(style.move_id)):
			config["moves"][String(style.move_id)].merge(style.get_data(), true)
	config["hit_reaction"] = hit_reaction.get_data()
	Style.strip_retired_fields(config)


func read_from_config(config: Dictionary) -> void:
	initial_school = str(config["tutorial"]["initial_school"])
	player = config["player"].duplicate(true)
	movement = config["movement"].duplicate(true)
	combat = config["combat"].duplicate(true)
	combat.erase("shape_reach")
	combat.erase("shape_radius")
	casting = config["casting"].duplicate(true)
	heat = config["heat"].duplicate(true)
	defence = config["defence"].duplicate(true)
	fire = config["fire"].duplicate(true)
	water = config["water"].duplicate(true)
	air = config["air"].duplicate(true)
	earth = config["earth"].duplicate(true)
	moves = config["moves"].duplicate(true)
	moves.erase("final_enemy_attack")
	for style in attack_styles:
		if style != null:
			for key in Style.DEFAULTS.keys() + Style.RETIRED_FIELDS + ["forward_lunge"]:
				moves[String(style.move_id)].erase(key)
	# Styles own their timing/motion; geometry is owned by native Animations.
	for style in attack_styles:
		if style != null:
			style.read_data(config["moves"][String(style.move_id)])
