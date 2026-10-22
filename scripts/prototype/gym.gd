extends "res://scripts/prototype/prototype_arena.gd"
## Combat Gym: shared actors/settings, a bounded encounter and formula readout.

const AREA_PATH := "res://scenes/stages/gym_area.tscn"
const CombatReadout = preload("res://scripts/ui/gym_combat_readout.gd")

const RETRY_VISIBILITY_META := &"laema_gym_retry_overlay_visible"
const RETRY_CREATURE_META := &"laema_gym_retry_creature"
var combat_readout
var _saved_creature_id := Creatures.DEFAULT_ID

var attempt_result: StringName = &""
var _result_pending := false
var _retry_pending := false
var _result_layer: CanvasLayer
var _result_title: Label
var _retry_button: Button


func _ready() -> void:
	super._ready()
	if _config.is_empty() or not is_processing():
		return
	# Retry carries a run-only selection; keep the real disk value as Save's base.
	_persisted_config["ui"]["enemy_creature"] = _saved_creature_id
	_build_result_panel()
	combat_readout = CombatReadout.new()
	combat_readout.name = "GymCombatReadout"
	add_child(combat_readout)
	hud.developer_readout.visibility_changed.connect(_sync_formula_visibility)
	_sync_formula_visibility()
	combat_readout.visibility_toggle_requested.connect(_toggle_developer_readouts)
	player.health_resolver.reaction_evaluated.connect(combat_readout.consume_reaction)
	player.health_changed.connect(_on_player_health_changed)
	stage_director.free_practice_entered.connect(_queue_result.bind(&"victory"))


func _load_configuration() -> Dictionary:
	var loaded := super._load_configuration()
	if not loaded["ok"]:
		return loaded
	_saved_creature_id = str(loaded["data"]["ui"].get("enemy_creature", Creatures.DEFAULT_ID))
	if get_tree().has_meta(RETRY_VISIBILITY_META):
		loaded["data"]["ui"]["developer_overlay_visible"] = bool(get_tree().get_meta(RETRY_VISIBILITY_META))
		get_tree().remove_meta(RETRY_VISIBILITY_META)
	if get_tree().has_meta(RETRY_CREATURE_META):
		loaded["data"]["ui"]["enemy_creature"] = str(get_tree().get_meta(RETRY_CREATURE_META))
		get_tree().remove_meta(RETRY_CREATURE_META)
	return loaded


func _get_tutorial_configuration() -> Dictionary:
	var tutorial: Dictionary = _config["tutorial"].duplicate(true)
	for stage in tutorial["stages"]:
		if bool(stage["final"]):
			var descriptor: Dictionary = stage.duplicate(true)
			descriptor["id"] = "gym"
			descriptor["display_name"] = "Gym"
			descriptor["area_scene"] = AREA_PATH
			descriptor["objective"]["presentation"]["rows"] = [{"id": "objective", "label": "Defeat the opponent"}]
			descriptor["free_practice_presentation"]["rows"] = [{"id": "complete", "label": "Gym complete"}]
			tutorial["default_stage_id"] = "gym"
			tutorial["stages"] = [descriptor]
			return tutorial
	return tutorial


func _get_pause_restart_label() -> String:
	return "Retry Gym"


func _on_player_health_changed(current_value: float, _maximum_value: float) -> void:
	if current_value <= 0.0:
		_queue_result(&"defeat")


func _queue_result(result: StringName) -> void:
	if attempt_result != &"" or _result_pending:
		return
	_result_pending = true
	# Finish the current HealthEvent transaction before freezing the room.
	call_deferred("_finish_attempt", result)


func _finish_attempt(result: StringName) -> void:
	_result_pending = false
	if attempt_result != &"":
		return
	# Victory requires surviving; a same-frame trade reaching zero is a defeat.
	attempt_result = &"defeat" if player.health.is_zero() else result
	player.set_stage_input_locked(true)
	player.velocity = Vector2.ZERO
	player.process_mode = Node.PROCESS_MODE_DISABLED
	_current_area.set_lifecycle(StageArea.Lifecycle.RETIRED)
	_current_area.process_mode = Node.PROCESS_MODE_DISABLED
	_clear_root_owned_projectiles()
	_developer_overlay._set_open(false)
	pause_menu.close()
	_result_title.text = "OPPONENT DEFEATED" if attempt_result == &"victory" else "YOU WERE DEFEATED"
	_result_title.modulate = Color("68dc81") if attempt_result == &"victory" else Color("ff8177")
	_result_layer.show()
	_retry_button.grab_focus()


func _restart_current_encounter() -> void:
	if _retry_pending:
		return
	_retry_pending = true
	get_tree().set_meta(RETRY_VISIBILITY_META, bool(_config["ui"]["developer_overlay_visible"]))
	get_tree().set_meta(RETRY_CREATURE_META, str(_config["ui"].get("enemy_creature", Creatures.DEFAULT_ID)))
	_developer_overlay._set_open(false)
	pause_menu.close()
	call_deferred("_reload_gym")


func _reload_gym() -> void:
	for audio in find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	var error := get_tree().reload_current_scene()
	if error != OK:
		get_tree().remove_meta(RETRY_VISIBILITY_META)
		get_tree().remove_meta(RETRY_CREATURE_META)
		_retry_pending = false
		push_error("Cannot retry Gym: %s" % error_string(error))


func _load_stage_from_developer(_stage_index: int) -> void:
	_restart_current_encounter()


func _build_result_panel() -> void:
	_result_layer = CanvasLayer.new()
	_result_layer.name = "GymResult"
	_result_layer.layer = 105
	_result_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_result_layer)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.05, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_result_layer.add_child(shade)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_result_layer.add_child(center)
	var panel := PanelContainer.new()
	center.add_child(panel)
	var margin := MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + edge, 24)
	panel.add_child(margin)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	margin.add_child(content)
	_result_title = Label.new()
	_result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_result_title.add_theme_font_size_override("font_size", 28)
	content.add_child(_result_title)
	var explanation := Label.new()
	explanation.text = "GYM / COMBAT\nRetry with full health, no orbs and no Heat."
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(explanation)
	_retry_button = Button.new()
	_retry_button.text = "Retry"
	_retry_button.custom_minimum_size = Vector2(280, 48)
	_retry_button.pressed.connect(_restart_current_encounter)
	content.add_child(_retry_button)
	_result_layer.hide()


func _toggle_developer_readouts() -> void:
	var shown := not bool(_config["ui"]["developer_overlay_visible"])
	_developer_overlay._on_setting_changed(["ui", "developer_overlay_visible"], shown)
	_developer_overlay._on_setting_changed(["ui", "attack_hitbox_visible"], shown)
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
