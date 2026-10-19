extends "res://scripts/prototype/prototype_arena.gd"
## One local Fire encounter. Shared combat rules and persisted tuning stay intact.

const AREA_PATH := "res://scenes/stages/fire_benchmark_area.tscn"
const SCHOOL_ACTIONS := [&"select_fire", &"select_water", &"select_air", &"select_earth"]

@export_category("Fire benchmark - provisional encounter tuning")
@export_range(1.0, 1000.0, 1.0, "or_greater") var player_health := 100.0
@export_range(1.0, 1000.0, 1.0, "or_greater") var opponent_health := 200.0
@export_range(0, 100) var opponent_poise := 1
@export_range(0, 100) var opponent_impact := 20
@export_range(0.01, 5.0, 0.01, "or_greater") var opponent_windup := 0.6
@export_range(0.0, 5.0, 0.01, "or_greater") var opponent_recovery := 0.9

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
	_build_result_panel()
	player.health_changed.connect(_on_player_health_changed)
	stage_director.free_practice_entered.connect(_queue_result.bind(&"victory"))


func _load_configuration() -> Dictionary:
	var loaded := ConfigLoader.load_and_validate(CONFIG_PATH)
	if not loaded["ok"]:
		return loaded
	var config: Dictionary = loaded["data"].duplicate(true)
	config["player"]["max_health"] = player_health
	config["enemy"]["max_health"] = opponent_health
	config["enemy_ai"]["poise"] = opponent_poise
	config["enemy_ai"]["impact"] = opponent_impact
	config["enemy_ai"]["enabled"] = true
	config["enemy_ai"]["windup_duration"] = opponent_windup
	config["enemy_ai"]["recovery_duration"] = opponent_recovery
	config["moves"]["final_enemy_attack"]["impact"] = opponent_impact
	config["ui"]["attack_hitbox_visible"] = false
	config["ui"]["developer_overlay_visible"] = true
	_enforce_encounter_settings(config)
	# Never synchronize this encounter's mirror into a cached ordinary scene Resource.
	combat_tuning.persistence_enabled = false
	combat_tuning.settings = combat_tuning.settings.duplicate(true)
	return ConfigLoader.validate(config)


func _enforce_encounter_settings(config: Dictionary) -> void:
	config["combat"]["collect_orb_without_contact"] = false
	config["player"]["one_hp_floor_enabled"] = false
	config["tutorial"]["initial_school"] = "fire"


func _get_tutorial_configuration() -> Dictionary:
	var tutorial: Dictionary = _config["tutorial"].duplicate(true)
	for stage in tutorial["stages"]:
		if bool(stage["final"]):
			var descriptor: Dictionary = stage.duplicate(true)
			descriptor["id"] = "fire_benchmark"
			descriptor["display_name"] = "Fire benchmark"
			descriptor["area_scene"] = AREA_PATH
			descriptor["objective"]["presentation"]["rows"] = [{"id": "objective", "label": "FIRE ONLY\nDefeat the opponent"}]
			descriptor["free_practice_presentation"]["rows"] = [{"id": "complete", "label": "Fire benchmark complete"}]
			tutorial["default_stage_id"] = "fire_benchmark"
			tutorial["stages"] = [descriptor]
			return tutorial
	return tutorial


func _prepare_area(area: StageArea) -> void:
	super._prepare_area(area)
	for target in area.get_targets():
		# Keep is_final_enemy and its completion event; remove only school-switch resistance.
		target.status_controller.set_elemental_endurance_enabled(false)


func _input(event: InputEvent) -> void:
	for action in SCHOOL_ACTIONS:
		if event.is_action(action):
			get_viewport().set_input_as_handled()
			return


func _apply_runtime_tuning() -> Dictionary:
	if bool(_config["combat"]["collect_orb_without_contact"]) or bool(_config["player"]["one_hp_floor_enabled"]) or _config["tutorial"]["initial_school"] != "fire":
		return {"ok": false, "error": "Fire benchmark keeps Fire-only startup, contact-required orbs and genuine defeat."}
	return super._apply_runtime_tuning()


func _save_runtime_tuning() -> Dictionary:
	return {"ok": false, "error": "Fire benchmark tuning is run-only; retry restores the scene settings."}


func apply_saved_developer_config(_expected_active: Dictionary) -> Dictionary:
	return {"ok": false, "error": "Fire benchmark uses its own scene settings. Shared settings cannot be applied here."}


func _get_pause_restart_label() -> String:
	return "Retry Fire benchmark"


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
	_developer_overlay._set_open(false)
	pause_menu.close()
	call_deferred("_reload_benchmark")


func _reload_benchmark() -> void:
	for audio in find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	var error := get_tree().reload_current_scene()
	if error != OK:
		_retry_pending = false
		push_error("Cannot retry Fire benchmark: %s" % error_string(error))


func _load_stage_from_developer(_stage_index: int) -> void:
	_restart_current_encounter()


func _build_result_panel() -> void:
	_result_layer = CanvasLayer.new()
	_result_layer.name = "BenchmarkResult"
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
	explanation.text = "FIRE BENCHMARK\nRetry with full health, no orbs and no Heat."
	explanation.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(explanation)
	_retry_button = Button.new()
	_retry_button.text = "Retry"
	_retry_button.custom_minimum_size = Vector2(280, 48)
	_retry_button.pressed.connect(_restart_current_encounter)
	content.add_child(_retry_button)
	_result_layer.hide()
