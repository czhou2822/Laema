@tool
extends VBoxContainer

signal run_gym_requested

const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")
const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Fields = preload("res://scripts/ui/developer_settings_fields.gd")
const Series = preload("res://scripts/config/developer_settings_series.gd")
const LAYOUT_PATH := "res://.godot/editor/laema_dev_portal_layout.cfg"

var _debugger
var _base: Dictionary = {}
var _saved_file: Dictionary = {}
var _draft: Dictionary = {}
var _active: Dictionary = {}
var _packet: Dictionary = {}
var _connected := false
var _external := false
var _file_valid := false
var _connection_reason := "Game stopped · editing available"
var _hash := ""
var _elapsed := 0.0
var _category_tabs: TabBar
var _section_buttons: Dictionary = {}
var _section_group: ButtonGroup
var _section_grid: GridContainer
var _section_order: Array = []
var _category_order: Dictionary = {}
var _section_key := ""
var _section_categories: Dictionary = {}
var _page_title: Label
var _connection: Label
var _description: Label
var _fields: VBoxContainer
var _body: VBoxContainer
var _summary: Label
var _feedback: Label
var _save: Button
var _revert: Button
var _apply: Button
var _review: ConfirmationDialog
var _reload_confirm: ConfirmationDialog
var _category_key := ""
var _series_dialog: ConfirmationDialog
var _series_controls: Dictionary = {}
var _series_preview: GridContainer
var _series_scroll: ScrollContainer
var _series_error: Label
var _series_table: Dictionary = {}
var _series_base_data: Dictionary = {}
var _foldout_state: Dictionary = {}


func setup(debugger) -> void:
	_debugger = debugger
	_debugger.state_received.connect(_on_state_received)
	_debugger.availability_changed.connect(_on_availability_changed)


func _ready() -> void:
	_load_navigation_layout()
	custom_minimum_size.x = 300
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_theme_constant_override("separation", 9)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 10)
	margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(margin)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 9)
	margin.add_child(_body)
	var title := Label.new()
	title.text = "Laema Dev Portal"
	_body.add_child(title)
	_connection = _label(_connection_reason)
	_body.add_child(_connection)
	_section_grid = GridContainer.new()
	_section_grid.columns = 3
	_section_group = ButtonGroup.new()
	for section in Catalog.NAVIGATION:
		var button := Button.new()
		button.text = section[1]
		button.toggle_mode = true
		button.button_group = _section_group
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.tooltip_text = "Click to open. Drag onto another section to reorder."
		button.set_meta("section_key", str(section[0]))
		button.set_drag_forwarding(_section_drag_data.bind(str(section[0])), _can_drop_section.bind(str(section[0])), _drop_section.bind(str(section[0])))
		button.pressed.connect(_select_section.bind(str(section[0])))
		_section_buttons[section[0]] = button
		_section_grid.add_child(button)
	for index in range(_section_order.size()):
		_section_grid.move_child(_section_buttons[_section_order[index]], index)
	_body.add_child(_section_grid)
	_category_tabs = TabBar.new()
	_category_tabs.clip_tabs = true
	_category_tabs.scrolling_enabled = true
	_category_tabs.drag_to_rearrange_enabled = true
	_category_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_category_tabs.tab_changed.connect(_on_category_selected)
	_category_tabs.active_tab_rearranged.connect(_on_category_rearranged)
	_body.add_child(_category_tabs)
	_page_title = _label("")
	_body.add_child(_page_title)
	_description = _label("")
	_body.add_child(_description)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size.y = 260
	_body.add_child(scroll)
	_fields = VBoxContainer.new()
	_fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_fields)
	var source := _label("res://config/prototype_combat.json")
	source.tooltip_text = "One saved configuration shared with the in-game Portal."
	_body.add_child(source)
	var reload_button := Button.new()
	reload_button.text = "Reload file"
	reload_button.pressed.connect(_request_reload)
	_body.add_child(reload_button)
	_body.add_child(HSeparator.new())
	_summary = _label("")
	_body.add_child(_summary)
	var row := HBoxContainer.new()
	_body.add_child(row)
	_revert = Button.new()
	_revert.text = "Revert draft"
	_revert.pressed.connect(_reload_file)
	row.add_child(_revert)
	_save = Button.new()
	_save.text = "Review & save"
	_save.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_save.pressed.connect(_review_changes)
	row.add_child(_save)
	_apply = Button.new()
	_apply.text = "Apply saved to game"
	_apply.pressed.connect(_apply_saved)
	_body.add_child(_apply)
	var gym_button := Button.new()
	gym_button.name = "RunGym"
	gym_button.text = "Run gym"
	gym_button.tooltip_text = "Run the gym using saved settings. Unsaved draft edits are not saved or applied."
	gym_button.pressed.connect(func(): run_gym_requested.emit())
	_body.add_child(gym_button)
	_feedback = _label("Saved values load on the next run.")
	_body.add_child(_feedback)
	_review = ConfirmationDialog.new()
	_review.title = "Save Laema configuration"
	_review.ok_button_text = "Save configuration"
	_review.confirmed.connect(_save_changes)
	add_child(_review)
	_reload_confirm = ConfirmationDialog.new()
	_reload_confirm.title = "Reload configuration"
	_reload_confirm.dialog_text = "Discard the unsaved draft and reload the configuration file?"
	_reload_confirm.confirmed.connect(_reload_file)
	add_child(_reload_confirm)
	_select_section(_section_key)
	_reload_file()


func _label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label


func _ordered_navigation_keys(saved: Variant, defaults: Array) -> Array:
	var result: Array = []
	if saved is Array:
		for key in saved:
			if defaults.has(key) and not result.has(key):
				result.append(key)
	for key in defaults:
		if not result.has(key):
			result.append(key)
	return result


func _load_navigation_layout() -> void:
	var layout := ConfigFile.new()
	layout.load(LAYOUT_PATH)
	var defaults: Array = []
	var saved_categories: Variant = layout.get_value("navigation", "categories", {})
	var selected_categories: Variant = layout.get_value("navigation", "selected_categories", {})
	_section_categories.clear()
	for section in Catalog.NAVIGATION:
		defaults.append(section[0])
		var saved: Variant = saved_categories.get(section[0], []) if saved_categories is Dictionary else []
		_category_order[section[0]] = _ordered_navigation_keys(saved, section[2])
		var selected: Variant = selected_categories.get(section[0], "") if selected_categories is Dictionary else ""
		_section_categories[section[0]] = selected if _category_order[section[0]].has(selected) else _category_order[section[0]][0]
	_section_order = _ordered_navigation_keys(layout.get_value("navigation", "sections", []), defaults)
	var selected_section: Variant = layout.get_value("navigation", "selected_section", "")
	_section_key = selected_section if _section_order.has(selected_section) else _section_order[0]


func _save_navigation_layout() -> void:
	var error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(LAYOUT_PATH.get_base_dir()))
	if error == OK:
		var layout := ConfigFile.new()
		layout.set_value("navigation", "sections", _section_order)
		layout.set_value("navigation", "categories", _category_order)
		layout.set_value("navigation", "selected_section", _section_key)
		layout.set_value("navigation", "selected_categories", _section_categories)
		error = layout.save(LAYOUT_PATH)
	if error != OK:
		_feedback.text = "Navigation preferences could not be saved: " + error_string(error)


func _section_drag_data(_position: Vector2, key: String) -> Variant:
	var preview := Label.new()
	preview.text = _section_buttons[key].text
	_section_buttons[key].set_drag_preview(preview)
	return {"kind": "laema_section", "dock": get_instance_id(), "key": key}


func _can_drop_section(_position: Vector2, data: Variant, key: String) -> bool:
	return data is Dictionary and data.get("kind") == "laema_section" and data.get("dock") == get_instance_id() and _section_buttons.has(data.get("key")) and data.get("key") != key


func _drop_section(position: Vector2, data: Variant, key: String) -> void:
	if not _can_drop_section(position, data, key):
		return
	_section_grid.move_child(_section_buttons[data["key"]], _section_buttons[key].get_index())
	_section_order.clear()
	for button in _section_grid.get_children():
		_section_order.append(button.get_meta("section_key"))
	_save_navigation_layout()


func _on_category_rearranged(_index: int) -> void:
	var order: Array = []
	for index in range(_category_tabs.tab_count):
		order.append(_category_tabs.get_tab_metadata(index))
	_category_order[_section_key] = order
	_on_category_selected(_category_tabs.current_tab)


func _reload_file() -> void:
	var loaded := Store.load_config()
	_file_valid = bool(loaded["ok"])
	_hash = FileAccess.get_sha256(Store.CONFIG_PATH)
	if not _file_valid:
		_feedback.text = str(loaded["error"])
		_update_status()
		return
	_base = loaded["data"].duplicate(true)
	_saved_file = _base.duplicate(true)
	_draft = _base.duplicate(true)
	_external = false
	_feedback.text = "Configuration loaded. Saved values load on the next run."
	_render_fields()
	_update_status()


func _request_reload() -> void:
	if Store.changes(_base, _draft).is_empty():
		_reload_file()
	else:
		_reload_confirm.popup_centered()


func _on_category_selected(index: int) -> void:
	_category_key = str(_category_tabs.get_tab_metadata(index))
	_section_categories[_section_key] = _category_key
	_render_fields()
	_save_navigation_layout()


func _select_section(key: String) -> void:
	for section in Catalog.NAVIGATION:
		if section[0] != key:
			continue
		_section_key = key
		_category_tabs.set_block_signals(true)
		_category_tabs.clear_tabs()
		var remembered: String = _section_categories.get(key, _category_order[key][0])
		for category_key in _category_order[key]:
			var title := "Actions"
			for entry in Catalog.CATEGORIES:
				if entry[0] == category_key:
					title = str(entry[1]).get_slice(" / ", 1)
					break
			_category_tabs.add_tab(title)
			var index := _category_tabs.tab_count - 1
			_category_tabs.set_tab_metadata(index, category_key)
			_category_tabs.set_tab_tooltip(index, "Click to open. Drag left or right to reorder.")
			_category_tabs.set_tab_disabled(index, _base.is_empty())
			if category_key == remembered:
				_category_tabs.current_tab = index
		_category_tabs.set_block_signals(false)
		_category_key = str(_category_tabs.get_tab_metadata(_category_tabs.current_tab))
		_section_categories[key] = _category_key
		_category_tabs.visible = _category_tabs.tab_count > 1
		for section_key in _section_buttons:
			_section_buttons[section_key].set_pressed_no_signal(section_key == key)
		_render_fields()
		_save_navigation_layout()
		return
	_render_fields()


func _render_fields() -> void:
	_page_title.text = _category_tabs.get_tab_title(_category_tabs.current_tab)
	_description.tooltip_text = ""
	for child in _fields.get_children():
		_fields.remove_child(child)
		child.queue_free()
	if _base.is_empty():
		return
	if _category_key == "session":
		_description.text = "Run the gym from the editor. Stage loading and pause controls require a connected game session."
		_render_session()
		return
	_description.text = "Edit a draft, review it, then save. Apply saved settings separately while the game is running."
	if _category_key == "hit_reaction":
		_description.text = Catalog.REACTION_LEVEL_HELP
	elif _category_key == "legacy_reactions":
		_description.text = Catalog.LEGACY_REACTION_HELP
	elif _category_key in ["fire", "water", "air", "earth"]:
		_description.text = "Attack presentation is active. Individual effect settings unused by current Casting are marked below."
	elif _category_key == "tutorial":
		_description.text = "Startup stage and school take effect on the next run. Transition duration affects future pans."
	elif _category_key == "moves":
		_description.text = Catalog.IMPACT_HELP
		_description.tooltip_text = Catalog.impact_tooltip(_draft)
	elif _category_key == "attack_styles":
		_description.text = Catalog.STYLE_HELP
	for table in Series.tables(_draft, _category_key):
		if _category_key == "moves":
			continue # Each school's series action belongs inside its foldout.
		var fill_button := Button.new()
		fill_button.text = "Fill series…"
		fill_button.tooltip_text = "Fill numeric level settings using a starting value and an increment. Fixed entries are preserved."
		fill_button.pressed.connect(_show_level_series.bind(table))
		_fields.add_child(fill_button)
	var fields := Fields.new()
	_fields.add_child(fields)
	fields.configure(_draft, _category_key, _saved_file, _active, _base, {"foldout_state": _foldout_state, "series": true})
	fields.value_changed.connect(_on_value_changed)
	fields.series_requested.connect(_show_level_series)


func _show_level_series(table: Dictionary) -> void:
	get_viewport().gui_release_focus()
	_series_table = table.duplicate(true)
	_series_base_data = _draft.duplicate(true)
	if is_instance_valid(_series_dialog):
		remove_child(_series_dialog)
		_series_dialog.free()
	_series_controls.clear()
	_build_series_dialog()
	_update_series_preview()
	_series_dialog.popup_centered_clamped(Vector2i(640, 540), 0.85)


func _build_series_dialog() -> void:
	_series_dialog = ConfirmationDialog.new()
	_series_dialog.title = "Fill series / " + str(_series_table.get("title", _page_title.text))
	_series_dialog.min_size = Vector2i(300, 260)
	_series_dialog.unresizable = false
	_series_dialog.ok_button_text = "Fill draft"
	_series_dialog.confirmed.connect(_fill_level_series)
	add_child(_series_dialog)
	# Keep the action buttons outside a bounded scroll area. The form may be wider
	# than a small editor window, but its table cells must never collapse or wrap.
	_series_scroll = ScrollContainer.new()
	_series_scroll.custom_minimum_size = Vector2(280, 180)
	_series_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_series_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_series_dialog.add_child(_series_scroll)
	var body := VBoxContainer.new()
	body.custom_minimum_size.x = 560
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	_series_scroll.add_child(body)
	body.add_child(_label("Start at each column's first editable level, then add the increment per level. Initial rules come from the first two editable values. Fixed entries are skipped."))
	var rules := GridContainer.new()
	rules.columns = 3
	rules.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rules.add_theme_constant_override("h_separation", 12)
	body.add_child(rules)
	for caption in ["Fill column", "Starting value", "Add per level"]:
		rules.add_child(_series_cell_label(caption))
	for column in _series_table["columns"]:
		var key: String = column["key"]
		var seed := Series.initial_rule(_series_base_data, column)
		var field: Dictionary = seed["field"]
		var enabled := CheckBox.new()
		enabled.text = column["label"]
		if seed["start_row"] != 0:
			enabled.text += " (from Level %d)" % (int(seed["start_row"]) + 1)
		enabled.button_pressed = true
		rules.add_child(enabled)
		var start := SpinBox.new()
		start.custom_minimum_size.x = 125
		start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		start.min_value = field["minimum"]
		start.max_value = field["maximum"]
		start.step = field["step"]
		start.suffix = column["unit"]
		start.allow_greater = field["allow_greater"]
		start.value = seed["start"]
		rules.add_child(start)
		var increment := SpinBox.new()
		increment.custom_minimum_size.x = 125
		increment.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		increment.min_value = -maxf(absf(start.max_value), 1.0)
		increment.max_value = -increment.min_value
		increment.allow_greater = true
		increment.allow_lesser = true
		increment.step = start.step
		increment.suffix = start.suffix
		increment.value = seed["increment"]
		rules.add_child(increment)
		_series_controls[key] = {"enabled": enabled, "start": start, "increment": increment}
		enabled.toggled.connect(func(_checked: bool): _update_series_preview())
		start.value_changed.connect(func(_number: float): _update_series_preview())
		increment.value_changed.connect(func(_number: float): _update_series_preview())
	body.add_child(HSeparator.new())
	_series_preview = GridContainer.new()
	_series_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_series_preview.columns = _series_table["columns"].size() + 1
	_series_preview.add_theme_constant_override("h_separation", 18)
	body.add_child(_series_preview)
	_series_error = _label("")
	body.add_child(_series_error)
	body.add_child(_label("Fills only selected editable numeric values in the draft. Review & save persists the result; Apply saved to game is separate. Status names, fixed values and unrelated settings are preserved."))


func _series_cell_label(text: String, minimum_width: float = 0.0) -> Label:
	# Paragraph labels deliberately wrap; table headings and numeric cells do not.
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.x = minimum_width
	return label


func _series_rules() -> Dictionary:
	var result: Dictionary = {}
	for key in _series_controls:
		var controls: Dictionary = _series_controls[key]
		var enabled: bool = controls["enabled"].button_pressed
		controls["start"].editable = enabled
		controls["increment"].editable = enabled
		if enabled:
			result[key] = {"start": controls["start"].value, "increment": controls["increment"].value}
	return result


func _update_series_preview() -> void:
	if not is_instance_valid(_series_preview) or _series_base_data.is_empty():
		return
	for child in _series_preview.get_children():
		_series_preview.remove_child(child)
		child.queue_free()
	var result := Series.fill(_series_base_data, _series_table, _series_rules())
	_series_error.text = str(result["error"])
	_series_error.visible = not _series_error.text.is_empty()
	_series_dialog.get_ok_button().disabled = not bool(result["ok"])
	if not result["ok"]:
		return
	_series_preview.add_child(_series_cell_label(str(_series_table.get("row_heading", "Level")), 48))
	for column in _series_table["columns"]:
		_series_preview.add_child(_series_cell_label(str(column["label"]) + (" (%s)" % column["unit"] if not str(column["unit"]).is_empty() else ""), 160))
	var levels: Array = Series.rows(_series_base_data, _series_table)
	for row in range(levels.size()):
		var row_labels: Array = _series_table.get("row_labels", [])
		_series_preview.add_child(_series_cell_label(str(row_labels[row]) if row < row_labels.size() else str(row + 1), 48))
		for column in _series_table["columns"]:
			var key: String = column["key"]
			var fixed := true
			for cell in column["cells"]:
				if cell["row"] == row:
					fixed = cell["readonly"]
			var before: Variant = levels[row].get(key)
			var after: Variant = result["levels"][row].get(key)
			var text := "%s (fixed)" % str(before) if fixed else "%s → %s" % [str(before), str(after)]
			_series_preview.add_child(_series_cell_label(text, 160))


func _fill_level_series() -> void:
	get_viewport().gui_release_focus()
	if Store.read_value(_draft, _series_table["path"]) != Store.read_value(_series_base_data, _series_table["path"]):
		_feedback.text = "Level values changed while the series preview was open. Open Fill series again to refresh."
		return
	var result := Series.fill(_series_base_data, _series_table, _series_rules())
	if not result["ok"]:
		_feedback.text = str(result["error"])
		return
	for change in result["changes"]:
		Store.set_value(_draft, change["path"], change["after"])
	_render_fields()
	_update_status()
	_feedback.text = "Level series filled in the draft. Review & save when ready."

func _on_value_changed(keys: Array, value: Variant) -> void:
	Store.set_value(_draft, keys, value)
	for child in _fields.get_children():
		if child.has_method("update_snapshots"):
			child.update_snapshots(_saved_file, _active, _base)
	_feedback.text = "Draft changed. Saving does not automatically apply it to the game."
	_update_status()


func _review_changes() -> void:
	# Finish editing a SpinBox's text before taking the review snapshot.
	get_viewport().gui_release_focus()
	var changes := Store.changes(_base, _draft)
	var lines: PackedStringArray = []
	for change in changes:
		lines.append("%s: %s → %s" % [Store.path_label(change["path"]), str(change["before"]), str(change["after"])])
	_review.dialog_text = "Save %d change(s)?\n\n%s" % [changes.size(), "\n".join(lines)]
	_review.popup_centered(Vector2i(560, 0))


func _save_changes() -> void:
	var result := Store.save_changes(_base, _draft)
	if not bool(result["ok"]):
		_feedback.text = str(result["error"])
		return
	_reload_file()
	_feedback.text = "Configuration saved. Apply it when ready, or use it on the next run."


func _update_status() -> void:
	var count := Store.changes(_base, _draft).size()
	_summary.text = "%d unsaved edit(s)" % count if count else "No unsaved edits"
	_save.disabled = not _file_valid or count == 0
	_revert.disabled = count == 0
	for index in range(_category_tabs.tab_count):
		_category_tabs.set_tab_disabled(index, _base.is_empty())
	_apply.disabled = not _connected or not _file_valid or _active.is_empty() or bool(_packet.get("unsaved", false))
	_connection.text = _connection_reason
	if _connected and bool(_packet.get("unsaved", false)):
		_connection.text = "Game has unsaved tuning · save it in-game before applying"
	if _external:
		_connection.text += "\nConfig changed elsewhere · your draft is preserved"


func _apply_saved() -> void:
	if not _debugger.request("apply", {"expected_active": _active.duplicate(true)}):
		_feedback.text = "No single connected game session. Settings are still editable offline."
	else:
		_feedback.text = "Applying saved configuration…"


func _on_state_received(packet: Dictionary) -> void:
	var was_paused := bool(_packet.get("paused", false))
	var stages_changed: bool = _packet.get("stages", []) != packet.get("stages", [])
	_packet = packet
	_active = packet.get("config", {}).duplicate(true)
	if not packet.get("error", "").is_empty():
		_feedback.text = packet["error"]
	elif _feedback.text == "Applying saved configuration…":
		_feedback.text = "Saved configuration applied to the game."
	if _category_key == "session" and (stages_changed or was_paused != bool(packet.get("paused", false))):
		_render_fields()
	else:
		for child in _fields.get_children():
			if child.has_method("update_snapshots"):
				child.update_snapshots(_saved_file, _active, _base)
	_update_status()


func _on_availability_changed(available: bool, reason: String) -> void:
	var changed := available != _connected
	_connected = available
	_connection_reason = reason
	if not available:
		_active = {}
		_packet = {}
	if is_instance_valid(_connection):
		_update_status()
		if changed:
			_render_fields()


func _render_session() -> void:
	var selector := OptionButton.new()
	selector.name = "StageSelector"
	selector.fit_to_longest_item = false
	selector.clip_text = true
	selector.disabled = not _connected
	_fields.add_child(selector)
	var stages: Array = _packet.get("stages", [])
	for stage in stages:
		selector.add_item(str(stage["label"]))
		selector.set_item_metadata(selector.item_count - 1, stage["id"])
	var load_button := Button.new()
	load_button.text = "Load stage in current session"
	load_button.disabled = not _connected or stages.is_empty()
	load_button.pressed.connect(func():
		if selector.selected >= 0:
			_debugger.request("load_stage", {"stage_id": selector.get_item_metadata(selector.selected)})
	)
	_fields.add_child(load_button)
	var pause_button := Button.new()
	pause_button.text = "Resume game" if bool(_packet.get("paused", false)) else "Pause game"
	pause_button.disabled = not _connected
	pause_button.pressed.connect(func(): _debugger.request("pause"))
	_fields.add_child(pause_button)
	_fields.add_child(_label("Hitbox visibility is a saved setting in General / UI & debug."))


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < 1.0 or not is_instance_valid(_feedback):
		return
	_elapsed = 0.0
	var hash := FileAccess.get_sha256(Store.CONFIG_PATH)
	if hash == _hash:
		return
	if Store.changes(_base, _draft).is_empty():
		_reload_file()
	else:
		_hash = hash
		_external = true
		var result := Store.load_config()
		_file_valid = bool(result["ok"])
		if not _file_valid:
			_feedback.text = str(result["error"])
		else:
			_saved_file = result["data"].duplicate(true)
			for child in _fields.get_children():
				if child.has_method("update_snapshots"):
					child.update_snapshots(_saved_file, _active, _base)
		_update_status()
