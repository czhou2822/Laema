extends SceneTree

const Loader = preload("res://scripts/config/prototype_config_loader.gd")
var checks := 0
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: ", description)


func send_toggle(pressed: bool = true, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = KEY_F4
	event.physical_keycode = KEY_F4
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func ui_toggle(gym) -> CheckButton:
	for fields in gym.get("_developer_overlay").get("_general_fields").get_children():
		if fields.has_method("update_snapshots") and fields.get("_inputs").has("ui.developer_overlay_visible"):
			return fields.get("_inputs")["ui.developer_overlay_visible"]
	return null


func stop_audio(gym) -> void:
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var original_text := FileAccess.get_file_as_string("res://config/prototype_combat.json")
	var original_hash := FileAccess.get_sha256("res://config/prototype_combat.json")
	var gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	for frame in range(3):
		await process_frame
	var enemy: Entity = gym.get("_current_area").get_targets()[0]
	enemy.set("_stage_enabled", false)
	var readout = gym.combat_readout
	check(readout.get("_panel").visible == gym.get("_config")["ui"]["developer_overlay_visible"], "Gym formula follows the configured developer overlay visibility at startup")
	# Start from visible even if the user's saved default is hidden.
	gym.get("_developer_overlay")._on_setting_changed(["ui", "developer_overlay_visible"], true)
	readout.consume_reaction({"receiver_id": enemy.get_instance_id(), "attacker_id": gym.player.get_instance_id(), "attacker_move": "fire_x1", "incoming_impact": 10, "receiver_poise": 0, "active_contribution": 0, "value": 10, "level": 1, "calculated": true, "receiver_active": false, "outcome": "APPLIED"})
	var captured: Dictionary = readout.get("_last_evaluations").duplicate(true)
	var starting_hp: float = gym.player.health.get_current()
	send_toggle()
	await process_frame
	send_toggle(false)
	check(not readout.get("_panel").visible and not gym.get("_config")["ui"]["developer_overlay_visible"], "Native F4 input hides the panel and updates the shared runtime setting")
	check(not paused and gym.player.health.get_current() == starting_hp and not gym.hud.developer_readout.visible and gym.hud.game_heat_bar.is_visible_in_tree() and gym.hud.orb_panel.is_visible_in_tree(), "Shared toggle hides developer panels together without hiding gameplay HUD, pausing or changing Health")
	send_toggle(true, true)
	await process_frame
	send_toggle(false)
	check(not readout.get("_panel").visible, "Held-key repeat does not flicker visibility")
	readout.consume_reaction({"receiver_id": enemy.get_instance_id(), "attacker_id": gym.player.get_instance_id(), "attacker_move": "fire_x2", "incoming_impact": 12, "receiver_poise": 0, "active_contribution": 0, "value": 12, "level": 2, "calculated": true, "receiver_active": false, "outcome": "APPLIED"})
	send_toggle()
	await process_frame
	send_toggle(false)
	check(readout.get("_panel").visible and gym.hud.developer_readout.visible and readout.get("_last_evaluations")["Enemy"]["value"] == 12, "F4 restores all developer panels together with captures collected while hidden")
	check(captured["Enemy"]["value"] == 10, "Visibility and later captures do not mutate earlier snapshots")
	for frame in range(2):
		await process_frame
	var toggle := ui_toggle(gym)
	check(toggle != null, "In-game Portal exposes the single shared visibility checkbox")
	toggle.button_pressed = false
	check(not readout.get("_panel").visible and not gym.hud.developer_readout.visible, "One Portal checkbox immediately hides both telemetry and formula panels")
	gym.pause_menu.set_open(true)
	send_toggle()
	await process_frame
	send_toggle(false)
	check(paused and gym.pause_menu.is_open() and readout.get("_panel").visible, "Shortcut works while paused without closing or resuming the pause menu")
	var edit := LineEdit.new()
	edit.process_mode = Node.PROCESS_MODE_ALWAYS
	root.add_child(edit)
	edit.grab_focus()
	send_toggle()
	await process_frame
	send_toggle(false)
	check(readout.get("_panel").visible, "Shortcut leaves visibility alone while a text field is being edited")
	edit.release_focus()
	edit.free()
	gym.pause_menu.close()
	gym.get("_developer_overlay")._on_setting_changed(["ui", "developer_overlay_visible"], false)
	gym._load_stage_from_developer(0)
	for frame in range(3):
		await process_frame
	check(not readout.get("_panel").visible and readout.get("_last_evaluations").is_empty(), "Reset gym keeps the hidden state while clearing capture history")
	check(FileAccess.get_sha256("res://config/prototype_combat.json") == original_hash, "Shortcut, checkbox and Reset do not automatically save tuning")
	check(gym._save_runtime_tuning()["ok"] and not Loader.load_and_validate("res://config/prototype_combat.json")["data"]["ui"]["developer_overlay_visible"], "Explicit Save Tuning persists the visibility choice")
	stop_audio(gym)
	await create_timer(0.3).timeout
	gym.free()
	await process_frame
	gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	for frame in range(3):
		await process_frame
	check(not gym.combat_readout.get("_panel").visible, "A new gym run restores the saved hidden state")
	send_toggle()
	await process_frame
	send_toggle(false)
	check(gym.combat_readout.get("_panel").visible, "Shortcut can reveal a panel that started hidden")
	var legacy: Dictionary = JSON.parse_string(original_text)
	legacy["ui"]["developer_overlay_visible"] = false
	legacy["ui"]["gym_formula_visible"] = true
	var file := FileAccess.open("res://legacy-gym-visibility.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var legacy_hash := FileAccess.get_sha256("res://legacy-gym-visibility.json")
	var loaded := Loader.load_and_validate("res://legacy-gym-visibility.json")
	check(loaded["ok"] and not loaded["data"]["ui"]["developer_overlay_visible"] and not loaded["data"]["ui"].has("gym_formula_visible") and FileAccess.get_sha256("res://legacy-gym-visibility.json") == legacy_hash, "Existing master preference wins conflicting old flags, without startup file writes")
	var fields := preload("res://scripts/config/developer_settings_catalog.gd").fields(legacy, "ui")
	var visibility_controls := 0
	for field in fields:
		if field["id"] in ["ui.developer_overlay_visible", "ui.gym_formula_visible"]:
			visibility_controls += 1
	check(visibility_controls == 1, "Legacy dictionaries never expose a duplicate formula visibility control")
	legacy["ui"].erase("developer_overlay_visible")
	legacy["ui"]["gym_formula_visible"] = false
	file = FileAccess.open("res://legacy-gym-visibility.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	loaded = Loader.load_and_validate("res://legacy-gym-visibility.json")
	check(loaded["ok"] and not loaded["data"]["ui"]["developer_overlay_visible"] and not loaded["data"]["ui"].has("gym_formula_visible"), "An old formula-only preference migrates when no master preference exists")
	var invalid: Dictionary = loaded["data"].duplicate(true)
	invalid["ui"]["developer_overlay_visible"] = "off"
	check(not Loader.validate(invalid)["ok"], "Shared visibility requires a Boolean setting")
	stop_audio(gym)
	await create_timer(0.3).timeout
	gym.free()
	await process_frame
	file = FileAccess.open("res://config/prototype_combat.json", FileAccess.WRITE)
	file.store_string(original_text)
	file.close()
	check(FileAccess.get_sha256("res://config/prototype_combat.json") == original_hash, "Isolated checks restore their saved fixture exactly")
	if failures.is_empty():
		print("PASSED: %d gym formula visibility checks" % checks)
	quit(0 if failures.is_empty() else 1)
