extends Node2D

const CONFIG_PATH := "res://config/prototype_combat.json"
const ConfigLoader = preload("res://scripts/config/prototype_config_loader.gd")
const DeveloperOverlay = preload("res://scripts/ui/developer_overlay.gd")

@onready var player = $Player
@onready var enemy = $Enemy
@onready var hud = $HUD

var _config: Dictionary = {}
var _developer_overlay


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
	_configure_default_input_map()
	hud.configure(_config)
	_connect_feedback()
	enemy.configure(_config)
	player.configure(_config)
	_create_developer_overlay()


func _connect_feedback() -> void:
	player.heat_changed.connect(hud.update_heat)
	player.combo_sequence_changed.connect(hud.update_combo)
	player.combo_completed.connect(hud.complete_combo)
	player.combo_reset.connect(hud.reset_combo)
	player.active_school_changed.connect(hud.update_active_school)
	player.health_changed.connect(hud.update_player_health)
	player.defence_status_changed.connect(hud.update_defence)
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
	enemy.apply_runtime_tuning()
	return validation


func _save_runtime_tuning() -> Dictionary:
	return ConfigLoader.validate_and_save(CONFIG_PATH, _config)


func _configure_default_input_map() -> void:
	_bind_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_bind_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_bind_axis(&"move_up", JOY_AXIS_LEFT_Y, -1.0)
	_bind_axis(&"move_down", JOY_AXIS_LEFT_Y, 1.0)
	_bind_key(&"move_left", KEY_A)
	_bind_key(&"move_right", KEY_D)
	_bind_key(&"move_up", KEY_W)
	_bind_key(&"move_down", KEY_S)
	_bind_key(&"select_fire", KEY_1)
	_bind_key(&"select_water", KEY_2)
	_bind_key(&"select_air", KEY_3)
	_bind_key(&"select_earth", KEY_4)
	_bind_key(&"defend", KEY_SHIFT)
	_bind_mouse_button(&"light_attack", MOUSE_BUTTON_LEFT)
	_bind_mouse_button(&"finisher", MOUSE_BUTTON_RIGHT)
	_bind_button(&"light_attack", JOY_BUTTON_X)
	_bind_button(&"finisher", JOY_BUTTON_Y)
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
