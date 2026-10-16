extends CanvasLayer

signal opening_requested

const TOGGLE_KEY := KEY_QUOTELEFT
const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Fields = preload("res://scripts/ui/developer_settings_fields.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")
const GENERAL_SECTION_ORDER := Catalog.GENERAL_SECTION_ORDER
const COMBAT_SECTION_ORDER := Catalog.COMBAT_SECTION_ORDER

var _config: Dictionary = {}
var _apply_tuning: Callable
var _save_tuning: Callable
var _get_hitbox_enabled: Callable
var _set_hitbox_enabled: Callable
var _get_stage_options: Callable
var _load_stage: Callable
var _overlay_root: Control
var _general_fields: VBoxContainer
var _combat_fields: Dictionary = {}
var _audio_fields: VBoxContainer
var _status_label: Label
var _hitbox_check: CheckBox
var _pause_button: Button
var _was_tree_paused := false
var _foldout_state: Dictionary = {}

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_overlay_root.visible = false

func configure(config: Dictionary, apply_tuning: Callable, save_tuning: Callable, get_hitbox_enabled: Callable, set_hitbox_enabled: Callable, get_stage_options: Callable, load_stage: Callable) -> void:
	_config = config
	_apply_tuning = apply_tuning
	_save_tuning = save_tuning
	_get_hitbox_enabled = get_hitbox_enabled
	_set_hitbox_enabled = set_hitbox_enabled
	_get_stage_options = get_stage_options
	_load_stage = load_stage
	_rebuild_fields()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == TOGGLE_KEY or event.physical_keycode == TOGGLE_KEY):
		_set_open(not _overlay_root.visible)
		get_viewport().set_input_as_handled()

func _exit_tree() -> void:
	if _overlay_root != null and _overlay_root.visible and get_tree() != null:
		get_tree().paused = _was_tree_paused

func _build_ui() -> void:
	_overlay_root = Control.new()
	_overlay_root.name = "DeveloperOverlayRoot"
	_overlay_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay_root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.04, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root.add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.08
	panel.anchor_top = 0.06
	panel.anchor_right = 0.92
	panel.anchor_bottom = 0.94
	_overlay_root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	margin.add_child(body)

	var header := HBoxContainer.new()
	body.add_child(header)
	var title := Label.new()
	title.text = "LAEMA DEV PORTAL  ·  ` TOGGLE"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	header.add_child(title)
	_status_label = Label.new()
	_status_label.text = "RUN-ONLY"
	header.add_child(_status_label)
	_pause_button = Button.new()
	_pause_button.name = "PauseButton"
	_pause_button.pressed.connect(_toggle_game_paused)
	header.add_child(_pause_button)
	var save_button := Button.new()
	save_button.text = "Save Tuning"
	save_button.pressed.connect(_on_save_pressed)
	header.add_child(save_button)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_set_open.bind(false))
	header.add_child(close_button)
	_update_pause_button()

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(tabs)

	var general_tab := VBoxContainer.new()
	general_tab.name = "General"
	tabs.add_child(general_tab)
	_general_fields = _add_tab_scroll(general_tab)

	var audio_tab := VBoxContainer.new()
	audio_tab.name = "Audio"
	tabs.add_child(audio_tab)
	_audio_fields = _add_tab_scroll(audio_tab)

	var combat_tab := VBoxContainer.new()
	combat_tab.name = "Combat"
	tabs.add_child(combat_tab)
	var combat_tabs := TabContainer.new()
	combat_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	combat_tab.add_child(combat_tabs)
	_combat_fields.clear()
	for section_name in COMBAT_SECTION_ORDER:
		var category_tab := VBoxContainer.new()
		category_tab.name = "IMPACT" if section_name == "moves" else ("HIT-REACTION LEVELS" if section_name == "hit_reaction" else str(section_name).to_upper().replace("_", " "))
		combat_tabs.add_child(category_tab)
		if section_name == "combat":
			_hitbox_check = CheckBox.new()
			_hitbox_check.text = "Show attack hitbox"
			_hitbox_check.toggled.connect(_on_hitbox_toggled)
			category_tab.add_child(_hitbox_check)
		_combat_fields[section_name] = _add_tab_scroll(category_tab)


func _rebuild_fields() -> void:
	if _general_fields == null or _config.is_empty():
		return
	_hitbox_check.set_pressed_no_signal(bool(_config["ui"]["attack_hitbox_visible"]))
	_clear_fields(_general_fields)
	for section in GENERAL_SECTION_ORDER:
		_add_fields(_general_fields, section)
	_add_fields(_general_fields, "tutorial")
	_add_stage_action(_general_fields)
	_clear_fields(_audio_fields)
	_add_fields(_audio_fields, "audio")
	for section in COMBAT_SECTION_ORDER:
		var container: VBoxContainer = _combat_fields[section]
		_clear_fields(container)
		_add_fields(container, section)

func _clear_fields(container: VBoxContainer) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _add_fields(container: VBoxContainer, section: String) -> void:
	var heading := Label.new()
	heading.text = "Impact" if section == "moves" else ("Hit-reaction levels" if section == "hit_reaction" else section.replace("_", " ").capitalize())
	container.add_child(heading)
	if section == "moves":
		var help := Label.new()
		help.text = Catalog.IMPACT_HELP
		help.tooltip_text = Catalog.impact_tooltip(_config)
		help.set_meta("impact_help", true)
		help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		container.add_child(help)
	elif section == "hit_reaction":
		var help := Label.new()
		help.text = Catalog.REACTION_LEVEL_HELP
		help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		container.add_child(help)
	var fields := Fields.new()
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(fields)
	fields.configure(_config, section, {}, {}, {}, {"foldout_state": _foldout_state})
	fields.value_changed.connect(_on_setting_changed)

func _add_tab_scroll(tab: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	tab.add_child(scroll)
	var fields := VBoxContainer.new()
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(fields)
	return fields

func _add_stage_action(container: VBoxContainer) -> void:
	if not _get_stage_options.is_valid():
		return
	var row := HBoxContainer.new()
	container.add_child(row)
	var selector := OptionButton.new()
	selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selector.fit_to_longest_item = false
	selector.clip_text = true
	row.add_child(selector)
	for stage in _get_stage_options.call():
		selector.add_item(str(stage["label"]), int(stage["index"]))
	var button := Button.new()
	button.text = "Load Stage"
	row.add_child(button)
	button.pressed.connect(func():
		if selector.selected >= 0 and _load_stage.is_valid():
			_set_open(false)
			_load_stage.call(selector.get_selected_id())
	)

func _on_setting_changed(keys: Array, value: Variant) -> void:
	var previous: Variant = Store.read_value(_config, keys)
	Store.set_value(_config, keys, value)
	var result: Dictionary = _apply_tuning.call()
	if not bool(result["ok"]):
		Store.set_value(_config, keys, previous)
		_status_label.text = str(result["error"])
		call_deferred("_rebuild_fields")
	else:
		_status_label.text = "UNSAVED"
		_hitbox_check.set_pressed_no_signal(bool(_config["ui"]["attack_hitbox_visible"]))
		for container in _combat_fields.values():
			for child in container.get_children():
				if child.has_method("update_snapshots"):
					child.update_snapshots({})
				elif child.has_meta("impact_help"):
					child.tooltip_text = Catalog.impact_tooltip(_config)

func _on_hitbox_toggled(enabled: bool) -> void:
	_on_setting_changed(["ui", "attack_hitbox_visible"], enabled)

func _on_save_pressed() -> void:
	if not _save_tuning.is_valid():
		_status_label.text = "SAVE UNAVAILABLE"
		return
	var result: Dictionary = _save_tuning.call()
	_status_label.text = "SAVED" if result["ok"] else str(result["error"])

func refresh_tuning_fields() -> void:
	_rebuild_fields()

func _set_open(open: bool) -> void:
	if _overlay_root == null or _overlay_root.visible == open:
		return
	if open:
		opening_requested.emit()
	_overlay_root.visible = open
	if get_tree() == null:
		return
	if open:
		_was_tree_paused = get_tree().paused
		get_tree().paused = true
		_rebuild_fields()
	else:
		get_tree().paused = _was_tree_paused
	_update_pause_button()


func _toggle_game_paused() -> void:
	if get_tree() == null:
		return
	get_tree().paused = not get_tree().paused
	_update_pause_button()


func _update_pause_button() -> void:
	if _pause_button == null or get_tree() == null:
		return
	_pause_button.text = "Resume Game" if get_tree().paused else "Pause Game"
