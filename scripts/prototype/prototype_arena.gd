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
const AUDIO_BUS_NAMES := {
	"ambient": &"Ambient",
	"sfx": &"SFX",
	"bgm": &"BGM",
}

@onready var player = $Player
@onready var enemy = $Enemy
@onready var hud = $HUD
@onready var ambient_audio: AudioStreamPlayer = $AmbientAudio
@onready var music_audio: AudioStreamPlayer = $MusicAudio
@onready var projectile_impact_audio: AudioStreamPlayer = $ProjectileImpactAudio

var _config: Dictionary = {}
var _developer_overlay
var _enemies: Array[Node] = []


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
	_connect_feedback()
	_enemies = get_tree().get_nodes_in_group("status_targets")
	for target in _enemies:
		target.call("configure", _config)
	player.configure(_config)
	_start_loop(ambient_audio, _load_audio_stream(AMBIENT_STREAM_PATH))
	_start_loop(music_audio, _load_audio_stream(MUSIC_STREAM_PATH))
	_create_developer_overlay()


func _connect_feedback() -> void:
	player.heat_changed.connect(hud.update_heat)
	player.combo_sequence_changed.connect(hud.update_combo)
	player.combo_completed.connect(hud.complete_combo)
	player.combo_reset.connect(hud.reset_combo)
	player.active_school_changed.connect(hud.update_active_school)
	player.health_changed.connect(hud.update_player_health)
	player.defence_status_changed.connect(hud.update_defence)
	player.orb_queue_changed.connect(hud.update_orb_queue)
	player.spell_projectile_requested.connect(_spawn_spell_projectile)
	enemy.enemy_health_changed.connect(hud.update_enemy_health)


func _create_developer_overlay() -> void:
	if not OS.is_debug_build() or _developer_overlay != null:
		return
	_developer_overlay = DeveloperOverlay.new()
	_developer_overlay.name = "DeveloperOverlay"
	add_child(_developer_overlay)
	_developer_overlay.configure(
		_config,
		_apply_runtime_tuning,
		_save_runtime_tuning,
		player.is_attack_hitbox_debug_enabled,
		player.set_attack_hitbox_debug_enabled
	)


func _apply_runtime_tuning() -> Dictionary:
	var validation := ConfigLoader.validate(_config)
	if not bool(validation["ok"]):
		return validation
	hud.apply_runtime_tuning(_config)
	player.apply_runtime_tuning()
	for target in _enemies:
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
	if InputMap.action_has_event(action, input_event):
		return
	InputMap.action_add_event(action, input_event)


func _bind_button(action: StringName, button: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventJoypadButton.new()
	input_event.device = -1
	input_event.button_index = button
	if InputMap.action_has_event(action, input_event):
		return
	InputMap.action_add_event(action, input_event)


func _bind_key(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventKey.new()
	input_event.physical_keycode = keycode
	if InputMap.action_has_event(action, input_event):
		return
	InputMap.action_add_event(action, input_event)


func _bind_mouse_button(action: StringName, button: MouseButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	var input_event := InputEventMouseButton.new()
	input_event.button_index = button
	if InputMap.action_has_event(action, input_event):
		return
	InputMap.action_add_event(action, input_event)


func _spawn_spell_projectile(payload: Dictionary) -> void:
	var projectile: SpellProjectile = SpellProjectileScene.instantiate() as SpellProjectile
	var camera := get_viewport().get_camera_2d()
	var world_width := get_viewport().get_visible_rect().size.x
	if camera != null and camera.zoom.x > 0.0:
		world_width /= camera.zoom.x
	var casting: Dictionary = _config["casting"]
	var maximum_distance: float = world_width * float(casting["projectile_screen_ratio"])
	projectile.initialize(payload, maximum_distance, float(casting["projectile_travel_duration"]))
	add_child(projectile)
	projectile.impact.connect(_on_spell_projectile_impact)
	_trace(&"projectile_spawn_requested", {"primary_school": payload["primary_school"], "primary_level": payload["primary_level"], "maximum_distance": maximum_distance})


func _on_spell_projectile_impact(target: Entity, contact_point: Vector2, payload: Dictionary) -> void:
	var primary_school := StringName(payload.get("primary_school", &"fire"))
	var stream_path := str(PROJECTILE_IMPACT_STREAM_PATHS.get(primary_school, PROJECTILE_IMPACT_STREAM_PATHS[&"fire"]))
	var stream: AudioStream = _load_audio_stream(stream_path)
	if stream != null:
		projectile_impact_audio.stream = stream
		projectile_impact_audio.play()
	_trace(&"projectile_impact_routed", {"target": target.name, "primary_school": payload["primary_school"], "primary_level": payload["primary_level"], "contact_point": contact_point})
	player.combat.resolve_spell_projectile_impact(target, contact_point, payload)


func _start_loop(player: AudioStreamPlayer, stream: AudioStream) -> void:
	if stream == null:
		return
	player.stream = stream
	player.finished.connect(player.play)
	player.play()


func _load_audio_stream(path: String) -> AudioStream:
	return ResourceLoader.load(path, "AudioStream") as AudioStream


func _apply_audio_settings() -> void:
	var audio: Dictionary = _config["audio"]
	for group_name_variant in AUDIO_BUS_NAMES:
		var group_name := str(group_name_variant)
		var bus_name: StringName = AUDIO_BUS_NAMES[group_name]
		var bus_index: int = AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			push_error("Missing prototype audio bus: %s" % bus_name)
			continue
		var group: Dictionary = audio[group_name]
		AudioServer.set_bus_mute(bus_index, not bool(group["enabled"]))
		AudioServer.set_bus_volume_db(bus_index, float(group["volume_db"]))


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][ARENA] %s %s" % [event_name, data])
