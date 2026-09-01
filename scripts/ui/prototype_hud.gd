extends CanvasLayer

const SCHOOL_COLORS := {
	&"fire": Color("ff493d"),
	&"water": Color("3a96ff"),
	&"air": Color("f4f6ff"),
	&"earth": Color("8b5a2b"),
}

@onready var developer_readout: Control = $DeveloperReadout
@onready var heat_bar: ProgressBar = $DeveloperReadout/HeatPanel/HeatLayout/HeatBar
@onready var heat_level_label: Label = $DeveloperReadout/HeatPanel/HeatLayout/HeatLevel
@onready var player_health: ProgressBar = $DeveloperReadout/HeatPanel/HeatLayout/PlayerHealth
@onready var enemy_health: ProgressBar = $DeveloperReadout/HeatPanel/HeatLayout/EnemyHealth
@onready var defence_state: Label = $DeveloperReadout/HeatPanel/HeatLayout/DefenceState
@onready var active_school_label: Label = $DeveloperReadout/ComboPanel/ComboLayout/ActiveSchool
@onready var current_combo: HBoxContainer = $DeveloperReadout/ComboPanel/ComboLayout/CurrentCombo
@onready var completed_combos: VBoxContainer = $DeveloperReadout/ComboPanel/ComboLayout/CompletedCombos
@onready var raw_pressure: ProgressBar = $DeveloperReadout/PressurePanel/PressureLayout/RawPressure
@onready var raw_pressure_label: Label = $DeveloperReadout/PressurePanel/PressureLayout/RawPressureLabel
@onready var game_heat_bar: ProgressBar = $GameUI/HeatPanel/HeatLayout/HeatBar
@onready var game_heat_label: Label = $GameUI/HeatPanel/HeatLayout/HeatLabel
@onready var orb_panel: PanelContainer = $GameUI/OrbPanel
@onready var orb_queue: HBoxContainer = $GameUI/OrbPanel/OrbLayout/OrbQueue
@onready var mark_progress: ProgressBar = $GameUI/OrbPanel/OrbLayout/MarkProgress
@onready var mark_label: Label = $GameUI/OrbPanel/OrbLayout/MarkLabel
@onready var objective_widget: ObjectiveWidget = $GameUI/ObjectiveWidget
@onready var startup_error: Label = $StartupError

class LifetimeOrb extends Control:
	const SIZE := 32.0
	const CENTER := Vector2(16.0, 16.0)
	const RADIUS := 13.0

	var fill_ratio := 1.0
	var fill_color := Color.WHITE
	var marked := false

	func _draw() -> void:
		var right_edge := -RADIUS + RADIUS * 2.0 * clampf(fill_ratio, 0.0, 1.0)
		var x := -RADIUS
		while x <= right_edge:
			var half_height := sqrt(maxf(RADIUS * RADIUS - x * x, 0.0))
			draw_line(
				CENTER + Vector2(x, -half_height),
				CENTER + Vector2(x, half_height),
				fill_color,
				1.0
			)
			x += 1.0
		if marked:
			draw_arc(CENTER, RADIUS, 0.0, TAU, 32, Color("ffd700"), 2.0)


var _combo_display_duration := 0.0
var _max_marked_capacity := 5
var _max_storage_capacity := 10
var _last_marked_count := -1
var _last_mark_progress_step := -1
var _orb_panel_rest_position := Vector2.ZERO
var _orb_panel_flinch_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_orb_panel_rest_position = orb_panel.position


func _process(_delta: float) -> void:
	if developer_readout == null or not developer_readout.visible:
		return
	var raw_strength: float = Input.get_action_raw_strength(&"casting")
	raw_pressure.value = raw_strength * 100.0
	raw_pressure_label.text = "R2 RAW  %.0f%%" % raw_pressure.value


func configure(config: Dictionary) -> void:
	apply_runtime_tuning(config)
	heat_bar.value = 0.0
	mark_progress.value = 0.0
	startup_error.visible = false
	update_active_school(&"fire")
	update_heat(0.0, 0, 1.0)
	update_player_health(float(config["player"]["max_health"]), float(config["player"]["max_health"]))
	update_enemy_health(float(config["enemy"]["max_health"]), float(config["enemy"]["max_health"]))
	update_orb_queue([], 0, 0.0)
	objective_widget.present({"label": "", "tokens": [], "progress": 0, "completed": false, "prompt": "", "flinch": false})


func apply_runtime_tuning(config: Dictionary) -> void:
	heat_bar.max_value = float(config["heat"]["max_heat"])
	game_heat_bar.max_value = float(config["heat"]["max_heat"])
	heat_bar.value = minf(heat_bar.value, heat_bar.max_value)
	_combo_display_duration = float(config["ui"]["completed_combo_display_duration"])
	_max_marked_capacity = int(config["casting"]["max_marked_capacity"])
	_max_storage_capacity = int(config["casting"]["max_storage_capacity"])
	set_developer_readout_visible(bool(config["ui"]["developer_overlay_visible"]))


func set_developer_readout_visible(is_visible: bool) -> void:
	developer_readout.visible = is_visible


func show_startup_error(message: String) -> void:
	startup_error.text = "PROTOTYPE CONFIGURATION ERROR\n%s" % message
	startup_error.visible = true


func update_heat(value: float, level: int, speed_multiplier: float) -> void:
	heat_bar.value = value
	heat_level_label.text = "HEAT %.0f   ×%.2f speed" % [value, speed_multiplier]
	game_heat_bar.value = value
	game_heat_label.text = "HEAT %.0f / 100   SPEED %.1f%%" % [value, speed_multiplier * 100.0]


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


func update_tutorial_objective(objective: Dictionary) -> void:
	objective_widget.present(objective)


func flinch_orb_widget() -> void:
	if _orb_panel_flinch_tween != null and _orb_panel_flinch_tween.is_valid():
		_orb_panel_flinch_tween.kill()
	orb_panel.position = _orb_panel_rest_position
	_orb_panel_flinch_tween = create_tween()
	_orb_panel_flinch_tween.tween_property(orb_panel, "position:x", _orb_panel_rest_position.x - 4.0, 0.04)
	_orb_panel_flinch_tween.tween_property(orb_panel, "position:x", _orb_panel_rest_position.x + 4.0, 0.04)
	_orb_panel_flinch_tween.tween_property(orb_panel, "position:x", _orb_panel_rest_position.x, 0.04)


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


func update_orb_queue(snapshot: Array, marked_count: int, marking_progress: float) -> void:
	_clear_children(orb_queue)
	var visible_orb_count := mini(snapshot.size(), _max_storage_capacity)
	for index in range(_max_storage_capacity):
		var slot := CenterContainer.new()
		slot.custom_minimum_size = Vector2(0.0, 34.0)
		slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if index < visible_orb_count:
			var orb: Dictionary = snapshot[index]
			slot.add_child(_create_orb_indicator(orb, index))
		orb_queue.add_child(slot)
	var total_marking_progress := (
		float(marked_count) + clampf(marking_progress, 0.0, 1.0)
	) / maxf(float(_max_marked_capacity), 1.0)
	mark_progress.value = clampf(total_marking_progress, 0.0, 1.0)
	mark_label.text = "MARK  %d / %d" % [marked_count, _max_marked_capacity]
	var progress_step := int(round(mark_progress.value * 20.0))
	if marked_count != _last_marked_count or progress_step != _last_mark_progress_step:
		_last_marked_count = marked_count
		_last_mark_progress_step = progress_step
		_trace(&"mark_progress_displayed", {"marked_count": marked_count, "partial_progress": marking_progress, "bar_value": mark_progress.value})


func _create_orb_indicator(orb: Dictionary, index: int) -> LifetimeOrb:
	var indicator := LifetimeOrb.new()
	indicator.custom_minimum_size = Vector2(LifetimeOrb.SIZE, LifetimeOrb.SIZE)
	indicator.fill_ratio = float(orb["remaining_ratio"]) if index == 0 else 1.0
	indicator.fill_color = _school_color(StringName(orb["school"]))
	indicator.marked = bool(orb["marked"])
	return indicator


func _remove_completed_after_delay(row: HBoxContainer) -> void:
	await get_tree().create_timer(_combo_display_duration).timeout
	if is_instance_valid(row):
		row.queue_free()


func _rebuild_token_row(row: HBoxContainer, tokens: Array) -> void:
	_clear_children(row)
	for token in tokens:
		var label := Label.new()
		label.text = String(token["input"])
		label.modulate = _school_color(StringName(token["school"]))
		label.add_theme_font_size_override("font_size", 28)
		row.add_child(label)


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _school_color(school: StringName) -> Color:
	var color: Color = SCHOOL_COLORS.get(school, Color.WHITE)
	return color


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][HUD] %s %s" % [event_name, data])
