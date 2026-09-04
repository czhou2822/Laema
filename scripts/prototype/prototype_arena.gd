extends Node2D

const CONFIG_PATH := "res://config/prototype_combat.json"
const ConfigLoader = preload("res://scripts/config/prototype_config_loader.gd")
const DeveloperOverlay = preload("res://scripts/ui/developer_overlay.gd")
const SpellProjectileScene = preload("res://scenes/combat/spell_projectile.tscn")
const AMBIENT_STREAM_PATH := "res://assets/prototype/audio/ambience/wind.ogg"
const MUSIC_STREAM_PATH := "res://assets/prototype/audio/music/fairy_battles.ogg"
const PROJECTILE_IMPACT_STREAM_PATHS := {
	&"fire": "res://assets/prototype/audio/projectile/fire_impact.ogg",
	&"water": "res://assets/prototype/audio/projectile/water_impact.wav",
	&"air": "res://assets/prototype/audio/projectile/air_impact.ogg",
	&"earth": "res://assets/prototype/audio/projectile/earth_impact.ogg",
}
const AUDIO_BUS_NAMES := {"ambient": &"Ambient", "sfx": &"SFX", "bgm": &"BGM"}

@onready var player = $Player
@onready var hud = $HUD
@onready var stage_director: StageDirector = $StageDirector
@onready var stage_areas: Node2D = $StageAreas
@onready var transition_camera: Camera2D = $Camera2D
@onready var ambient_audio: AudioStreamPlayer = $AmbientAudio
@onready var music_audio: AudioStreamPlayer = $MusicAudio
@onready var projectile_impact_audio: AudioStreamPlayer = $ProjectileImpactAudio

var _config: Dictionary = {}
var _developer_overlay
var _current_area: StageArea
var _next_area: StageArea
var _current_descriptor: Dictionary = {}
var _next_descriptor: Dictionary = {}
var _preloaded_next_scene: PackedScene
var _transitioning := false


func _ready() -> void:
	var result := ConfigLoader.load_and_validate(CONFIG_PATH)
	if not bool(result["ok"]):
		var message := str(result["error"])
		push_error(message)
		hud.show_startup_error(message)
		set_process(false)
		set_physics_process(false)
		return
	_config = result["data"]
	_apply_audio_settings()
	_configure_default_input_map()
	hud.configure(_config)
	player.configure(_config)
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
	stage_director.configure(_config["tutorial"])
	_start_loop(ambient_audio, _load_audio_stream(AMBIENT_STREAM_PATH))
	_start_loop(music_audio, _load_audio_stream(MUSIC_STREAM_PATH))
	_create_developer_overlay()
	call_deferred("_start_initial_stage")


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
	var entry_anchor := area.get_node("EntryAnchor") as Marker2D
	if previous_area == null:
		area.global_position = -entry_anchor.position
	else:
		area.global_position = previous_area.get_exit_world_position() - entry_anchor.position
	return area


func _prepare_area(area: StageArea) -> void:
	area.exit_reached.connect(stage_director.report_exit_reached)
	for target in area.get_targets():
		target.call("configure", _config)
		if target.has_method("set_stage_active"):
			target.call("set_stage_active", false)
	area.set_lifecycle(StageArea.Lifecycle.PREPARED)


func _bind_active_area(area: StageArea) -> void:
	for target in area.get_targets():
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
		if child is SpellProjectile:
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


func _load_stage_from_developer(stage_index: int) -> void:
	if _transitioning:
		return
	var descriptor := stage_director.select_debug_stage(stage_index)
	if descriptor.is_empty():
		return
	_transitioning = true
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
	hud.apply_runtime_tuning(_config)
	player.apply_runtime_tuning()
	if _current_area != null:
		for target in _current_area.get_targets():
			target.call("apply_runtime_tuning")
	_apply_audio_settings()
	return validation


func _save_runtime_tuning() -> Dictionary:
	return ConfigLoader.validate_and_save(CONFIG_PATH, _config)


func _configure_default_input_map() -> void:
	_bind_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_key(&"move_left", KEY_A)
	_bind_key(&"move_right", KEY_D)
	_bind_key(&"select_fire", KEY_1)
	_bind_key(&"select_water", KEY_2)
	_bind_key(&"select_air", KEY_3)
	_bind_key(&"select_earth", KEY_4)
	_bind_key(&"defend", KEY_SHIFT)
	_bind_mouse_button(&"light_attack", MOUSE_BUTTON_LEFT)
	_bind_mouse_button(&"casting", MOUSE_BUTTON_RIGHT)
	_bind_button(&"light_attack", JOY_BUTTON_X)
	_bind_axis(&"casting", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	_bind_button(&"select_fire", JOY_BUTTON_DPAD_UP)
	_bind_button(&"select_water", JOY_BUTTON_DPAD_DOWN)
	_bind_button(&"select_air", JOY_BUTTON_DPAD_LEFT)
	_bind_button(&"select_earth", JOY_BUTTON_DPAD_RIGHT)
	_bind_button(&"defend", JOY_BUTTON_LEFT_SHOULDER)


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
