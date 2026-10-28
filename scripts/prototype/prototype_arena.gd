extends Node2D

const CONFIG_PATH := "res://config/prototype_combat.json"
const ConfigLoader = preload("res://scripts/config/prototype_config_loader.gd")
const DeveloperOverlay = preload("res://scripts/ui/developer_overlay.gd")
const SpellProjectileScene = preload("res://scenes/combat/spell_projectile.tscn")
const AMBIENT_STREAM_PATH := "res://assets/prototype/audio/ambience/wind.ogg"
const MUSIC_STREAM_PATH := "res://assets/prototype/audio/music/fairy_battles.ogg"
const PROJECTILE_IMPACT_STREAM_PATHS := {
	&"fire": "",
	&"water": "",
	&"air": "",
	&"earth": "",
}
const DevStore = preload("res://scripts/config/developer_config_store.gd")
const DevSession = preload("res://scripts/config/developer_portal_session.gd")
const Creatures = preload("res://scripts/config/creature_catalog.gd")

const AUDIO_BUS_NAMES := {"ambient": &"Ambient", "sfx": &"SFX", "bgm": &"BGM"}
const CREATURE_SHORTCUTS := {
	KEY_1: [["pikeman", "halberdier"], ["skeleton", "skeleton_warrior"]],
	KEY_2: [["archer", "marksman"], ["walking_dead", "zombie"]],
	KEY_3: [["griffin", "royal_griffin"], ["wight", "wraith"]],
	KEY_4: [["swordsman", "crusader"], ["vampire", "vampire_lord"]],
	KEY_5: [["monk", "zealot"], ["lich", "power_lich"]],
	KEY_6: [["cavalier", "champion"], ["black_knight", "dread_knight"]],
	KEY_7: [["angel", "archangel"], ["bone_dragon", "ghost_dragon"]],
}

@onready var combat_tuning: CombatTuningBridge = $Player/CombatTuning
@onready var player = $Player
@onready var hud = $HUD
@onready var pause_menu = $PauseMenu
@onready var stage_director: StageDirector = $StageDirector
@onready var stage_areas: Node2D = $StageAreas
@onready var transition_camera: Camera2D = $Camera2D
@onready var ambient_audio: AudioStreamPlayer = $AmbientAudio
@onready var music_audio: AudioStreamPlayer = $MusicAudio
@onready var projectile_impact_audio: AudioStreamPlayer = $ProjectileImpactAudio

var _config: Dictionary = {}
var _persisted_config: Dictionary = {}
var _developer_overlay
var _current_area: StageArea
var _next_area: StageArea
var _current_descriptor: Dictionary = {}
var _next_descriptor: Dictionary = {}
var _preloaded_next_scene: PackedScene
var _transitioning := false
var _impact_camera_started := -1
var _impact_camera_level := 0
var _impact_camera_profile: Dictionary = {}
var _impact_camera_direction := Vector2.RIGHT
var _impact_camera_applied := Vector2.ZERO


func _ready() -> void:
	var result := _load_configuration()
	if not bool(result["ok"]):
		var message := str(result["error"])
		push_error(message)
		hud.show_startup_error(message)
		set_process(false)
		set_physics_process(false)
		return
	_config = result["data"]
	var tuning_result := combat_tuning.initialize(_config, _apply_runtime_tuning)
	if not bool(tuning_result["ok"]):
		push_error(str(tuning_result["error"]))
		hud.show_startup_error(str(tuning_result["error"]))
		set_process(false)
		set_physics_process(false)
		return
	_persisted_config = _config.duplicate(true)
	combat_tuning.inspector_tuning_applied.connect(_refresh_portal_tuning)
	_apply_audio_settings()
	_configure_default_input_map()
	hud.configure(_config)
	player.configure(_config)
	_bind_impact_feedback(player)
	get_tree().process_frame.connect(_update_impact_camera)
	pause_menu.opening_requested.connect(_clear_impact_feedback)
	player.heat_changed.connect(hud.update_heat)
	player.heat_changed.connect(stage_director.consume_heat)
	player.combo_sequence_changed.connect(hud.update_combo)
	player.combo_completed.connect(hud.complete_combo)
	player.combo_reset.connect(hud.reset_combo)
	player.active_school_changed.connect(hud.update_active_school)
	player.health_changed.connect(hud.update_player_health)
	player.defence_status_changed.connect(hud.update_defence)
	player.orb_queue_changed.connect(hud.update_orb_queue)
	player.spell_projectile_requested.connect(_spawn_spell_projectile)
	player.combat.outcome_published.connect(_consume_public_outcome)
	stage_director.presentation_changed.connect(hud.update_tutorial_objective)
	stage_director.stage_completed.connect(_on_stage_completed)
	stage_director.transition_requested.connect(_on_transition_requested)
	stage_director.configure(_get_tutorial_configuration())
	_start_loop(ambient_audio, _load_audio_stream(AMBIENT_STREAM_PATH))
	_start_loop(music_audio, _load_audio_stream(MUSIC_STREAM_PATH))
	_create_developer_overlay()
	pause_menu.configure(func(): return not _transitioning and _current_area != null, _get_pause_restart_label())
	pause_menu.opening_requested.connect(func(): _developer_overlay._set_open(false))
	_developer_overlay.opening_requested.connect(pause_menu.close)
	_developer_overlay.opening_requested.connect(_clear_impact_feedback)
	pause_menu.restart_requested.connect(_restart_current_encounter)
	player.set_attack_hitbox_debug_enabled(bool(_config["ui"]["attack_hitbox_visible"]))
	var dev_session := DevSession.new()
	add_child(dev_session)
	dev_session.initialize(self)
	call_deferred("_start_initial_stage")


func _load_configuration() -> Dictionary:
	return ConfigLoader.load_and_validate(CONFIG_PATH)


func _get_tutorial_configuration() -> Dictionary:
	return _config["tutorial"]


func _get_pause_restart_label() -> String:
	return "Restart encounter"


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.alt_pressed or event.ctrl_pressed or event.meta_pressed:
		return
	var tier_pairs: Array = CREATURE_SHORTCUTS.get(event.physical_keycode, [])
	if tier_pairs.is_empty() or _config.is_empty() or _transitioning or _current_area == null:
		return
	if _current_area.get_node_or_null("FinalEnemy") == null:
		return
	if _developer_overlay._overlay_root.visible or pause_menu.is_open():
		return
	var selected_id := str(_config["ui"].get("enemy_creature", Creatures.DEFAULT_ID))
	var creature_id: String
	if event.shift_pressed:
		# Shift toggles the chosen tier within the current faction, never factions.
		var faction_index := 0
		for pairs in CREATURE_SHORTCUTS.values():
			if selected_id in pairs[1]:
				faction_index = 1
				break
		var pair: Array = tier_pairs[faction_index]
		creature_id = str(pair[0] if selected_id == pair[1] else pair[1])
	else:
		# Another tier starts at Castle; repeating this tier alternates its bases.
		var next_faction := 1 if selected_id in tier_pairs[0] else 0
		creature_id = str(tier_pairs[next_faction][0])
	get_viewport().set_input_as_handled()
	_on_creature_spawn_requested(creature_id)


func _process(_delta: float) -> void:
	if _current_area == null or _transitioning:
		return
	var bounds := _current_area.get_camera_world_bounds()
	transition_camera.global_position = Vector2(clampf(player.global_position.x, bounds.x, bounds.y), _current_area.get_camera_world_position().y)


func _start_initial_stage() -> void:
	_current_descriptor = stage_director.get_initial_descriptor()
	_current_area = _instantiate_stage(_current_descriptor, null)
	stage_areas.add_child(_current_area)
	await get_tree().process_frame
	_prepare_area(_current_area)
	stage_director.activate_stage(_current_descriptor)
	_bind_active_area(_current_area)
	_current_area.set_lifecycle(StageArea.Lifecycle.ACTIVE)
	_current_area.authorize_exit(false)
	player.global_position = _current_area.get_spawn_world_position()
	player.select_stage_school(StringName(_config["tutorial"]["initial_school"]))
	transition_camera.global_position = _current_area.get_camera_world_position()
	_trace(&"stage_activated", {"stage_id": _current_descriptor["id"], "initial": true})


func _instantiate_stage(descriptor: Dictionary, previous_area: StageArea) -> StageArea:
	var scene: PackedScene
	if _preloaded_next_scene != null and _next_descriptor.get("id", "") == descriptor.get("id", ""):
		scene = _preloaded_next_scene
	else:
		scene = load(str(descriptor["area_scene"])) as PackedScene
	var area := scene.instantiate() as StageArea
	_replace_encounter_creature(area)
	var entry_anchor := area.get_node("EntryAnchor") as Marker2D
	if previous_area == null:
		area.global_position = -entry_anchor.position
	else:
		area.global_position = previous_area.get_exit_world_position() - entry_anchor.position
	return area


func _replace_encounter_creature(area: StageArea) -> void:
	var creature_id := str(_config["ui"].get("enemy_creature", Creatures.DEFAULT_ID))
	if creature_id == Creatures.DEFAULT_ID:
		return
	var previous := area.get_node_or_null("FinalEnemy") as Node2D
	if previous == null:
		return
	var scene := load(Creatures.scene_path(creature_id)) as PackedScene
	var creature := scene.instantiate() as Node2D
	creature.name = previous.name
	creature.transform = previous.transform
	for property in [&"encounter_id", &"refills_at_zero", &"is_final_enemy"]:
		creature.set(property, previous.get(property))
	var index := previous.get_index()
	area.remove_child(previous)
	previous.free()
	area.add_child(creature)
	area.move_child(creature, index)


func _prepare_area(area: StageArea) -> void:
	area.exit_reached.connect(stage_director.report_exit_reached)
	for target in area.get_targets():
		target.call("configure", _config)
		if target.has_method("set_stage_active"):
			target.call("set_stage_active", false)
	area.set_lifecycle(StageArea.Lifecycle.PREPARED)


func _bind_active_area(area: StageArea) -> void:
	for target in area.get_targets():
		_bind_impact_feedback(target)
		target.connect(&"outcome_published", _consume_public_outcome)
		target.connect(&"enemy_health_changed", hud.update_enemy_health)


func _on_stage_completed(descriptor: Dictionary) -> void:
	if _current_area == null:
		return
	_current_area.authorize_exit(true)
	_next_descriptor = stage_director.get_next_descriptor()
	_preloaded_next_scene = load(str(_next_descriptor["area_scene"])) as PackedScene
	_trace(&"stage_completed", {"stage_id": descriptor["id"], "next_preloaded": _next_descriptor["id"]})


func _on_transition_requested(next_descriptor: Dictionary) -> void:
	if _transitioning or _current_area == null:
		return
	_transitioning = true
	_next_descriptor = next_descriptor.duplicate(true)
	player.set_stage_input_locked(true)
	_clear_root_owned_projectiles()
	_next_area = _instantiate_stage(_next_descriptor, _current_area)
	stage_areas.add_child(_next_area)
	await get_tree().process_frame
	_prepare_area(_next_area)
	player.global_position = _next_area.get_spawn_world_position()
	player.reset_for_stage()
	var duration := float(_config["tutorial"]["transition_duration"])
	var tween := create_tween()
	tween.tween_property(transition_camera, "global_position", _next_area.get_camera_world_position(), duration)
	await tween.finished
	_current_area.set_lifecycle(StageArea.Lifecycle.RETIRED)
	_current_area.queue_free()
	_current_area = _next_area
	_current_descriptor = _next_descriptor
	_next_area = null
	stage_director.report_transition_finished()
	_bind_active_area(_current_area)
	_current_area.set_lifecycle(StageArea.Lifecycle.ACTIVE)
	_current_area.authorize_exit(false)
	player.set_stage_input_locked(false)
	_transitioning = false
	_trace(&"stage_activated", {"stage_id": _current_descriptor["id"], "initial": false})


func _consume_public_outcome(outcome) -> void:
	if outcome != null and outcome.get_kind() == &"orb_overflow":
		hud.flinch_orb_widget()
	stage_director.consume_outcome(outcome)


func _clear_root_owned_projectiles() -> void:
	for child in get_children():
		if child is SpellProjectile or child.is_in_group("enemy_projectiles"):
			child.queue_free()


func _spawn_spell_projectile(payload: Dictionary) -> void:
	var projectile: SpellProjectile = SpellProjectileScene.instantiate() as SpellProjectile
	var world_width := get_viewport().get_visible_rect().size.x / maxf(transition_camera.zoom.x, 0.001)
	var casting: Dictionary = _config["casting"]
	projectile.initialize(payload, world_width * float(casting["projectile_screen_ratio"]), float(casting["projectile_travel_duration"]))
	add_child(projectile)
	projectile.impact.connect(_on_spell_projectile_impact)


func _on_spell_projectile_impact(target: Entity, contact_point: Vector2, payload: Dictionary) -> void:
	var primary_school := StringName(payload.get("primary_school", &"fire"))
	var stream := _load_audio_stream(str(PROJECTILE_IMPACT_STREAM_PATHS.get(primary_school, PROJECTILE_IMPACT_STREAM_PATHS[&"fire"])))
	if stream != null:
		projectile_impact_audio.stream = stream
		projectile_impact_audio.play()
	player.combat.resolve_spell_projectile_impact(target, contact_point, payload)


func _create_developer_overlay() -> void:
	if _developer_overlay != null:
		return
	_developer_overlay = DeveloperOverlay.new()
	_developer_overlay.name = "DeveloperOverlay"
	add_child(_developer_overlay)
	_developer_overlay.configure(_config, _apply_runtime_tuning, _save_runtime_tuning, player.is_attack_hitbox_debug_enabled, player.set_attack_hitbox_debug_enabled, stage_director.get_stage_options, _load_stage_from_developer)
	_developer_overlay.creature_spawn_requested.connect(_on_creature_spawn_requested)


func _load_stage_from_developer(stage_index: int) -> void:
	if _transitioning:
		return
	var descriptor := stage_director.select_debug_stage(stage_index)
	if descriptor.is_empty():
		return
	_transitioning = true
	_clear_impact_feedback()
	player.set_stage_input_locked(true)
	_clear_root_owned_projectiles()
	if _next_area != null:
		_next_area.set_lifecycle(StageArea.Lifecycle.RETIRED)
		_next_area.queue_free()
		_next_area = null
	if _current_area != null:
		_current_area.set_lifecycle(StageArea.Lifecycle.RETIRED)
		_current_area.queue_free()
	_preloaded_next_scene = null
	_next_descriptor = {}
	_current_descriptor = descriptor
	_current_area = _instantiate_stage(_current_descriptor, null)
	stage_areas.add_child(_current_area)
	await get_tree().process_frame
	_prepare_area(_current_area)
	player.global_position = _current_area.get_spawn_world_position()
	player.reset_for_stage()
	transition_camera.global_position = _current_area.get_camera_world_position()
	stage_director.activate_stage(_current_descriptor)
	_bind_active_area(_current_area)
	_current_area.set_lifecycle(StageArea.Lifecycle.ACTIVE)
	_current_area.authorize_exit(false)
	player.set_stage_input_locked(false)
	_transitioning = false
	_trace(&"developer_stage_loaded", {"stage_id": _current_descriptor["id"]})


func _apply_runtime_tuning() -> Dictionary:
	var validation := ConfigLoader.validate(_config)
	if not bool(validation["ok"]):
		return validation
	combat_tuning.sync_from_config(_config)
	player.set_attack_hitbox_debug_enabled(bool(_config["ui"]["attack_hitbox_visible"]))
	hud.apply_runtime_tuning(_config)
	player.apply_runtime_tuning()
	if _current_area != null:
		for target in _current_area.get_targets():
			target.call("apply_runtime_tuning")
	_apply_audio_settings()
	return validation


func _save_runtime_tuning() -> Dictionary:
	var result := DevStore.save_changes(_persisted_config, _config)
	if not bool(result["ok"]):
		return result
	_persisted_config = _config.duplicate(true)
	return result


func _refresh_portal_tuning() -> void:
	if _developer_overlay != null:
		_developer_overlay.call_deferred("refresh_tuning_fields")


func get_developer_stage_options() -> Array:
	return stage_director.get_stage_options()


func spawn_developer_creature(creature_id: String) -> Dictionary:
	if not Creatures.available(creature_id):
		return {"ok": false, "error": "The selected creature is unavailable."}
	if _transitioning or _current_area == null:
		return {"ok": false, "error": "Wait for the current encounter to finish loading."}
	if _current_area.get_node_or_null("FinalEnemy") == null:
		return {"ok": false, "error": "Load Gym or Final Arena to spawn a combat creature."}
	_config["ui"]["enemy_creature"] = creature_id
	_developer_overlay._set_open(false)
	pause_menu.close()
	_restart_current_encounter()
	return {"ok": true, "error": ""}


func _on_creature_spawn_requested(creature_id: String) -> void:
	var result := spawn_developer_creature(creature_id)
	if not result["ok"]:
		_developer_overlay.show_spawn_error(str(result["error"]))


func set_game_paused(paused: bool) -> void:
	if paused:
		_clear_impact_feedback()
	_developer_overlay._set_open(false)
	pause_menu.set_open(paused)
	# An explicit editor resume also clears a pause set outside the pause menu.
	if not paused:
		get_tree().paused = false


func _restart_current_encounter() -> void:
	if _transitioning or _current_area == null:
		return
	for option in stage_director.get_stage_options():
		if option["active"]:
			pause_menu.close()
			call_deferred("_load_stage_from_developer", int(option["index"]))
			return


func get_developer_config_state() -> Dictionary:
	return {
		"config": _config.duplicate(true),
		"unsaved": not DevStore.changes(_persisted_config, _config).is_empty(),
		"paused": get_tree().paused,
		"stages": get_developer_stage_options(),
	}


func apply_saved_developer_config(expected_active: Dictionary) -> Dictionary:
	if _config != expected_active:
		return {"ok": false, "error": "Game tuning changed after the editor snapshot. Try applying again."}
	if not DevStore.changes(_persisted_config, _config).is_empty():
		return {"ok": false, "error": "Save unsaved in-game tuning before applying the editor configuration."}
	var loaded := DevStore.load_config()
	if not loaded["ok"]:
		return loaded
	if loaded["data"]["tutorial"]["stages"] != _config["tutorial"]["stages"]:
		return {"ok": false, "error": "Tutorial stage definitions changed. Restart the game to load them."}
	var previous := _config.duplicate(true)
	DevStore.copy_into(_config, loaded["data"])
	var result := _apply_runtime_tuning()
	if not result["ok"]:
		DevStore.copy_into(_config, previous)
		return result
	_persisted_config = _config.duplicate(true)
	_refresh_portal_tuning()
	return {"ok": true, "error": ""}


func _configure_default_input_map() -> void:
	_bind_button(&"pause", JOY_BUTTON_START)
	_bind_key(&"pause", KEY_ESCAPE)
	_bind_button(&"ui_accept", JOY_BUTTON_A)
	_bind_button(&"ui_cancel", JOY_BUTTON_B)
	_bind_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_key(&"move_left", KEY_A)
	_bind_key(&"move_right", KEY_D)
	# Retire number-row school keys, including bindings from an earlier arena.
	for binding in [
		[&"select_fire", KEY_1], [&"select_water", KEY_2],
		[&"select_air", KEY_3], [&"select_earth", KEY_4],
	]:
		for key_event in InputMap.action_get_events(binding[0]):
			if not key_event is InputEventKey:
				continue
			if key_event.physical_keycode == binding[1] or key_event.keycode == binding[1]:
				InputMap.action_erase_event(binding[0], key_event)
	_bind_key(&"defend", KEY_SHIFT)
	_bind_mouse_button(&"light_attack", MOUSE_BUTTON_LEFT)
	_bind_mouse_button(&"casting", MOUSE_BUTTON_RIGHT)
	_bind_button(&"light_attack", JOY_BUTTON_X)
	_bind_button(&"dodge", JOY_BUTTON_B)
	_bind_axis(&"casting", JOY_AXIS_TRIGGER_LEFT, 1.0)
	_bind_button(&"select_fire", JOY_BUTTON_DPAD_UP)
	_bind_button(&"select_water", JOY_BUTTON_DPAD_DOWN)
	_bind_button(&"select_air", JOY_BUTTON_DPAD_LEFT)
	_bind_button(&"select_earth", JOY_BUTTON_DPAD_RIGHT)
	# Remove the former default when re-entering an arena in the same session.
	for defend_event in InputMap.action_get_events(&"defend"):
		if defend_event is InputEventJoypadButton and defend_event.button_index == JOY_BUTTON_LEFT_SHOULDER:
			InputMap.action_erase_event(&"defend", defend_event)
	_bind_button(&"defend", JOY_BUTTON_RIGHT_SHOULDER)


func _bind_axis(action: StringName, axis: JoyAxis, value: float) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventJoypadMotion.new()
	input_event.device = -1
	input_event.axis = axis
	input_event.axis_value = value
	if not InputMap.action_has_event(action, input_event):
		InputMap.action_add_event(action, input_event)


func _bind_button(action: StringName, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventJoypadButton.new()
	input_event.device = -1
	input_event.button_index = button
	if not InputMap.action_has_event(action, input_event):
		InputMap.action_add_event(action, input_event)


func _bind_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventKey.new()
	input_event.physical_keycode = keycode
	if not InputMap.action_has_event(action, input_event):
		InputMap.action_add_event(action, input_event)


func _bind_mouse_button(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventMouseButton.new()
	input_event.button_index = button
	if not InputMap.action_has_event(action, input_event):
		InputMap.action_add_event(action, input_event)


func _start_loop(audio_player: AudioStreamPlayer, stream: AudioStream) -> void:
	if stream == null:
		return
	audio_player.stream = stream
	audio_player.finished.connect(audio_player.play)
	audio_player.play()


func _load_audio_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	return ResourceLoader.load(path, "AudioStream") as AudioStream


func _apply_audio_settings() -> void:
	for group_name_variant in AUDIO_BUS_NAMES:
		var group_name := str(group_name_variant)
		var bus_index := AudioServer.get_bus_index(AUDIO_BUS_NAMES[group_name])
		if bus_index < 0:
			push_error("Missing prototype audio bus: %s" % AUDIO_BUS_NAMES[group_name])
			continue
		var group: Dictionary = _config["audio"][group_name]
		AudioServer.set_bus_mute(bus_index, not bool(group["enabled"]))
		AudioServer.set_bus_volume_db(bus_index, float(group["volume_db"]))


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][ARENA] %s %s" % [event_name, data])


func _bind_impact_feedback(actor: Entity) -> void:
	if not actor.feedback.impact_confirmed.is_connected(_on_impact_confirmed):
		actor.feedback.impact_confirmed.connect(_on_impact_confirmed)


func _on_impact_confirmed(cue: Dictionary) -> void:
	if get_tree().paused or _transitioning or not bool(_config["ui"].get("impact_camera_enabled", false)):
		return
	var level := int(cue["level"])
	if level < 1 or level > 5: # Resolved combat reactions only, never legacy recoil.
		return
	if _impact_camera_started < 0 or float(Time.get_ticks_msec() - _impact_camera_started) / 1000.0 >= impact_camera_duration(_impact_camera_profile):
		_impact_camera_level = 0
	# Preserve stronger overlapping cues and their captured values. New equal or
	# stronger cues capture the matching authored pair; never retime it per frame.
	if level >= _impact_camera_level:
		var authored: Dictionary = _config["hit_reaction"]["combat_levels"][level - 1]
		_impact_camera_profile = {"camera_strength": authored["camera_strength"],
			"camera_duration": authored["camera_duration"]}
		_impact_camera_level = level
	_impact_camera_direction = Vector2(cue["direction"]).normalized()
	_impact_camera_started = Time.get_ticks_msec()


static func impact_camera_duration(authored: Dictionary) -> float:
	return float(authored.get("camera_duration", 0.0))


static func impact_camera_pixels(age: float, level: int, direction: Vector2, authored: Dictionary) -> Vector2:
	var duration := impact_camera_duration(authored)
	if age < 0.0 or age >= duration or level < 1 or level > 5:
		return Vector2.ZERO
	var amplitude := float(authored["camera_strength"])
	var phase := age / duration
	return direction.normalized() * amplitude * sin(phase * TAU) * (1.0 - phase)


func _update_impact_camera() -> void:
	if not is_inside_tree():
		_clear_impact_feedback()
		return
	if not is_instance_valid(transition_camera):
		return
	# Subtract only this cue's previous contribution, preserving other offsets.
	transition_camera.offset -= _impact_camera_applied
	_impact_camera_applied = Vector2.ZERO
	if _config.is_empty():
		return
	if get_tree().paused or _transitioning:
		_clear_impact_feedback()
		return
	if not bool(_config["ui"].get("impact_camera_enabled", false)):
		_impact_camera_started = -1
		_impact_camera_level = 0
		return
	if _impact_camera_started < 0:
		return
	var age := float(Time.get_ticks_msec() - _impact_camera_started) / 1000.0
	if age >= impact_camera_duration(_impact_camera_profile):
		_impact_camera_started = -1
		_impact_camera_level = 0
		return
	var pixels := impact_camera_pixels(age, _impact_camera_level, _impact_camera_direction, _impact_camera_profile)
	_impact_camera_applied = pixels / transition_camera.zoom
	transition_camera.offset += _impact_camera_applied


func _clear_impact_feedback() -> void:
	if is_instance_valid(transition_camera):
		transition_camera.offset -= _impact_camera_applied
	_impact_camera_applied = Vector2.ZERO
	_impact_camera_started = -1
	_impact_camera_level = 0
	_impact_camera_profile.clear()
	if is_instance_valid(player) and is_instance_valid(player.feedback):
		player.feedback.clear_impact_feedback(true)
	# An area can still be instance-valid after its SceneTree has gone away.
	# Its Feedback children own their exit cleanup; never query groups detached.
	if is_instance_valid(_current_area) and _current_area.is_inside_tree():
		for target in _current_area.get_targets():
			if target is Entity and is_instance_valid(target.feedback):
				target.feedback.clear_impact_feedback(true)


func _exit_tree() -> void:
	if is_inside_tree():
		var tree := get_tree()
		if tree.process_frame.is_connected(_update_impact_camera):
			tree.process_frame.disconnect(_update_impact_camera)
	_clear_impact_feedback()
