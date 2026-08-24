extends CanvasLayer

@onready var heat_bar: ProgressBar = $HeatPanel/HeatLayout/HeatBar
@onready var heat_level_label: Label = $HeatPanel/HeatLayout/HeatLevel
@onready var player_health: ProgressBar = $HeatPanel/HeatLayout/PlayerHealth
@onready var enemy_health: ProgressBar = $HeatPanel/HeatLayout/EnemyHealth
@onready var defence_state: Label = $HeatPanel/HeatLayout/DefenceState
@onready var active_school_label: Label = $ComboPanel/ComboLayout/ActiveSchool
@onready var current_combo: HBoxContainer = $ComboPanel/ComboLayout/CurrentCombo
@onready var completed_combos: VBoxContainer = $ComboPanel/ComboLayout/CompletedCombos
@onready var startup_error: Label = $StartupError

var _combo_display_duration := 0.0


func configure(config: Dictionary) -> void:
	apply_runtime_tuning(config)
	heat_bar.value = 0.0
	startup_error.visible = false
	update_active_school(&"fire")
	update_heat(0.0, 0, 1.0)
	update_player_health(float(config["player"]["max_health"]), float(config["player"]["max_health"]))
	update_enemy_health(float(config["enemy"]["max_health"]), float(config["enemy"]["max_health"]))


func apply_runtime_tuning(config: Dictionary) -> void:
	heat_bar.max_value = float(config["heat"]["max_value"])
	heat_bar.value = minf(heat_bar.value, heat_bar.max_value)
	_combo_display_duration = float(config["ui"]["completed_combo_display_duration"])


func show_startup_error(message: String) -> void:
	startup_error.text = "PROTOTYPE CONFIGURATION ERROR\n%s" % message
	startup_error.visible = true


func update_heat(value: float, level: int, speed_multiplier: float) -> void:
	heat_bar.value = value
	heat_level_label.text = "Level %d   ×%.2f speed" % [level, speed_multiplier]


func update_active_school(school: StringName) -> void:
	active_school_label.text = String(school).to_upper()
	active_school_label.modulate = _school_color(school)


func update_player_health(current_value: float, maximum_value: float) -> void:
	player_health.max_value = maximum_value
	player_health.value = current_value


func update_enemy_health(current_value: float, maximum_value: float) -> void:
	enemy_health.max_value = maximum_value
	enemy_health.value = current_value


func update_defence(label: String, current_guard: float, maximum_guard: float) -> void:
	defence_state.text = "DEFENCE: %s   GUARD %.0f / %.0f" % [label, current_guard, maximum_guard]
	match label:
		"GUARD WARNING":
			defence_state.modulate = Color("ffbf3f")
		"GUARD BROKEN":
			defence_state.modulate = Color("ff493d")
		_:
			defence_state.modulate = Color.WHITE


func update_combo(tokens: Array) -> void:
	_rebuild_token_row(current_combo, tokens)


func reset_combo() -> void:
	_clear_children(current_combo)


func complete_combo(tokens: Array) -> void:
	_clear_children(current_combo)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	completed_combos.add_child(row)
	_rebuild_token_row(row, tokens)
	_remove_completed_after_delay(row)


func _remove_completed_after_delay(row: HBoxContainer) -> void:
	await get_tree().create_timer(_combo_display_duration).timeout
	if is_instance_valid(row):
		row.queue_free()


func _rebuild_token_row(row: HBoxContainer, tokens: Array) -> void:
	_clear_children(row)
	for token in tokens:
		var label := Label.new()
		label.text = String(token["input"])
		label.modulate = _school_color(token["school"])
		label.add_theme_font_size_override("font_size", 28)
		row.add_child(label)


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _school_color(school: StringName) -> Color:
	match school:
		&"fire":
			return Color("ff493d")
		&"water":
			return Color("3a96ff")
		&"air":
			return Color("ffffff")
		&"earth":
			return Color("8b5a2b")
	return Color.WHITE
