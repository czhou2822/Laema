extends "res://scripts/prototype/prototype_arena.gd"
## Development-only encounter; the saved tutorial and combat tuning stay shared.

const GYM_AREA := "res://scenes/stages/gym_area.tscn"
const CombatReadout = preload("res://scripts/ui/gym_combat_readout.gd")
var combat_readout


func _ready() -> void:
	super._ready()
	if _config.is_empty() or not is_processing():
		return
	combat_readout = CombatReadout.new()
	combat_readout.name = "GymCombatReadout"
	add_child(combat_readout)
	hud.developer_readout.visibility_changed.connect(_sync_formula_visibility)
	_sync_formula_visibility()
	combat_readout.visibility_toggle_requested.connect(_toggle_developer_readouts)
	player.health_resolver.reaction_evaluated.connect(combat_readout.consume_reaction)


func _toggle_developer_readouts() -> void:
	_developer_overlay._on_setting_changed(["ui", "developer_overlay_visible"], not bool(_config["ui"]["developer_overlay_visible"]))
	_refresh_portal_tuning()


func _sync_formula_visibility() -> void:
	if is_instance_valid(combat_readout):
		combat_readout.set_readout_visible(hud.developer_readout.is_visible_in_tree())


func _bind_active_area(area: StageArea) -> void:
	super._bind_active_area(area)
	if combat_readout == null:
		return
	var targets := area.get_targets()
	var enemy: Entity = targets[0] if not targets.is_empty() else null
	combat_readout.bind_combatants(player, enemy)
	if enemy != null:
		enemy.health_resolver.reaction_evaluated.connect(combat_readout.consume_reaction)


func _get_pause_restart_label() -> String:
	return "Reset gym"


func _get_tutorial_configuration() -> Dictionary:
	var tutorial: Dictionary = _config["tutorial"].duplicate(true)
	# Keep the current Final Enemy's evaluator/completion contract and change only
	# this scene's in-memory encounter selection and physical area.
	for stage in tutorial["stages"]:
		if bool(stage["final"]):
			var descriptor: Dictionary = stage.duplicate(true)
			descriptor["id"] = "gym"
			descriptor["display_name"] = "Gym — Player vs Final Enemy"
			descriptor["area_scene"] = GYM_AREA
			descriptor["objective"]["presentation"]["rows"][0]["label"] = "Gym — combat practice"
			tutorial["default_stage_id"] = "gym"
			tutorial["stages"] = [descriptor]
			return tutorial
	return tutorial
