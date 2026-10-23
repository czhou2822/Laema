@tool
extends VBoxContainer
## Native controls shared by the editor dock and runtime Portal.

signal value_changed(keys: Array, value: Variant)
signal series_requested(table: Dictionary)

const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")
const Series = preload("res://scripts/config/developer_settings_series.gd")

var _data: Dictionary = {}
var _entries: Array = []
var _metadata: Dictionary = {}
var _inputs: Dictionary = {}
var _captions: Dictionary = {}
var _reaction_headings: Dictionary = {}
var _range_error: Label
var _section := ""
var _foldout_state: Dictionary = {}
var _foldout_bodies: Dictionary = {}
var _foldout_buttons: Dictionary = {}
var _summary_labels: Dictionary = {}
var _reaction_levels_body: VBoxContainer
var _reaction_levels_toggle: Button


func configure(data: Dictionary, section: String, saved: Dictionary = {}, active: Dictionary = {}, baseline: Dictionary = {}, options: Dictionary = {}) -> void:
	_data = data
	_section = section
	_foldout_state = options.get("foldout_state", {})
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_metadata.clear()
	_inputs.clear()
	_captions.clear()
	_reaction_headings.clear()
	_range_error = null
	_foldout_bodies.clear()
	_foldout_buttons.clear()
	_summary_labels.clear()
	_reaction_levels_body = null
	_reaction_levels_toggle = null
	_entries = Catalog.fields(data, section)
	add_theme_constant_override("separation", 9)
	if section in ["hit_reaction", "moves", "attack_styles"]:
		_build_foldouts(bool(options.get("series", false)))
		update_snapshots(saved, active, baseline)
		return
	if section == "legacy_reactions":
		var notice := Label.new()
		notice.text = Catalog.LEGACY_REACTION_NOTICE
		notice.tooltip_text = Catalog.LEGACY_REACTION_HELP
		notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		add_child(notice)
	var previous_group := ""
	var pair: HBoxContainer
	for field in _entries:
		var group: String = field["group"]
		if group != previous_group and not group.is_empty():
			var heading := Label.new()
			heading.text = group
			heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			add_child(heading)
			pair = null
			if str(field["id"]).contains(".combat_levels."):
				pair = HBoxContainer.new()
				pair.add_theme_constant_override("separation", 12)
				add_child(pair)
		previous_group = group
		_add_field(field, pair)
	update_snapshots(saved, active, baseline)


func _build_foldouts(with_series: bool) -> void:
	var toolbar := HBoxContainer.new()
	add_child(toolbar)
	for expanded in [true, false]:
		var button := Button.new()
		button.text = "Expand all" if expanded else "Collapse all"
		button.pressed.connect(_set_all_foldouts.bind(expanded))
		toolbar.add_child(button)
	if _section == "hit_reaction":
		_reaction_levels_toggle = Button.new()
		_reaction_levels_toggle.toggle_mode = true
		_reaction_levels_toggle.alignment = HORIZONTAL_ALIGNMENT_LEFT
		add_child(_reaction_levels_toggle)
		_reaction_levels_body = VBoxContainer.new()
		_reaction_levels_body.add_theme_constant_override("separation", 9)
		add_child(_reaction_levels_body)
		_range_error = Label.new()
		_range_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_reaction_levels_body.add_child(_range_error)
		var levels_open: bool = _foldout_state.get("hit_reaction/Levels 1–5", false)
		_reaction_levels_toggle.set_pressed_no_signal(levels_open)
		_on_reaction_levels_toggled(levels_open)
		_reaction_levels_toggle.toggled.connect(_on_reaction_levels_toggled)
	var groups: Dictionary = {}
	for field in _entries:
		var group: String = field["group"]
		if not groups.has(group):
			groups[group] = []
		groups[group].append(field)
	var tables := Series.tables(_data, _section) if with_series and _section == "moves" else []
	for group in groups:
		var target: VBoxContainer = self
		if _reaction_levels_body != null and str(groups[group][0]["id"]).contains(".combat_levels."):
			target = _reaction_levels_body
			var heading := Label.new()
			heading.text = group
			heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			target.add_child(heading)
			_reaction_headings[groups[group][0]["path"][2]] = heading
			_add_field(groups[group][0], null, target)
			var level_fields := HBoxContainer.new()
			level_fields.add_theme_constant_override("separation", 12)
			target.add_child(level_fields)
			for field in groups[group].slice(1):
				_add_field(field, level_fields, target)
			target.add_child(HSeparator.new())
			continue
		var header := Button.new()
		header.toggle_mode = true
		header.alignment = HORIZONTAL_ALIGNMENT_LEFT
		header.clip_text = true
		header.tooltip_text = group
		if _section == "hit_reaction":
			header.tooltip_text = Catalog.LEGACY_REACTION_HELP
		target.add_child(header)
		_foldout_buttons[group] = header
		var summary := Label.new()
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		summary.modulate.a = 0.8
		target.add_child(summary)
		_summary_labels[group] = summary
		var body := VBoxContainer.new()
		body.add_theme_constant_override("separation", 9)
		target.add_child(body)
		_foldout_bodies[group] = body
		if _section == "hit_reaction":
			var notice := Label.new()
			notice.text = Catalog.LEGACY_REACTION_NOTICE
			notice.tooltip_text = Catalog.LEGACY_REACTION_HELP
			notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			body.add_child(notice)
		for table in tables:
			if table["group"] == group:
				var fill := Button.new()
				fill.text = "Fill X1–X5 series…"
				fill.pressed.connect(func(): series_requested.emit(table))
				body.add_child(fill)
		for field in groups[group]:
			_add_field(field, null, body)
		var open: bool = _foldout_state.get(_section + "/" + group, false)
		header.set_pressed_no_signal(open)
		_on_foldout_toggled(open, group)
		header.toggled.connect(_on_foldout_toggled.bind(group))
		target.add_child(HSeparator.new())


func _on_reaction_levels_toggled(open: bool) -> void:
	_foldout_state["hit_reaction/Levels 1–5"] = open
	_reaction_levels_body.visible = open
	_reaction_levels_toggle.text = ("▼ " if open else "▶ ") + "Levels 1–5"


func _on_foldout_toggled(open: bool, group: String) -> void:
	_foldout_state[_section + "/" + group] = open
	_foldout_bodies[group].visible = open
	_foldout_buttons[group].text = ("▼ " if open else "▶ ") + group


func _set_all_foldouts(open: bool) -> void:
	if _reaction_levels_toggle != null:
		_reaction_levels_toggle.set_pressed_no_signal(open)
		_on_reaction_levels_toggled(open)
	for group in _foldout_buttons:
		_foldout_buttons[group].set_pressed_no_signal(open)
		_on_foldout_toggled(open, group)


func _add_field(field: Dictionary, pair: HBoxContainer = null, target: VBoxContainer = null) -> void:
	if target == null:
		target = self
	if pair != null:
		var column := VBoxContainer.new()
		column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pair.add_child(column)
		var caption := Label.new()
		caption.text = field["label"]
		_captions[field["id"]] = caption
		column.add_child(caption)
		var input := _make_control(field)
		input.tooltip_text = str(field["description"]) + "\n" + str(field["id"])
		column.add_child(input)
		_inputs[field["id"]] = input
		var note := Label.new()
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		note.modulate.a = 0.75
		column.add_child(note)
		_metadata[field["id"]] = note
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	target.add_child(row)
	var caption := VBoxContainer.new()
	caption.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(caption)
	var label := Label.new()
	label.text = field["label"] + (" (fixed)" if field["readonly"] else "")
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.tooltip_text = str(field["description"]) + "\n" + str(field["id"])
	_captions[field["id"]] = label
	caption.add_child(label)
	if not str(field["casting_usage_note"]).is_empty():
		var usage_note := Label.new()
		usage_note.text = field["casting_usage_note"]
		usage_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		usage_note.modulate.a = 0.75
		usage_note.tooltip_text = field["description"]
		caption.add_child(usage_note)
	var metadata := Label.new()
	metadata.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	metadata.modulate.a = 0.75
	caption.add_child(metadata)
	_metadata[field["id"]] = metadata
	var control := _make_control(field)
	control.tooltip_text = label.tooltip_text
	row.add_child(control)
	_inputs[field["id"]] = control
	target.add_child(HSeparator.new())


func _make_control(field: Dictionary) -> Control:
	var value: Variant = Store.read_value(_data, field["path"])
	match field["kind"]:
		"bool":
			var toggle := CheckButton.new()
			toggle.button_pressed = bool(value)
			toggle.text = "On" if value else "Off"
			toggle.disabled = field["readonly"]
			toggle.toggled.connect(func(enabled: bool):
				toggle.text = "On" if enabled else "Off"
				value_changed.emit(field["path"], enabled)
			)
			return toggle
		"choice":
			var selector := OptionButton.new()
			selector.custom_minimum_size.x = 115
			selector.size_flags_horizontal = Control.SIZE_SHRINK_END
			selector.fit_to_longest_item = false
			selector.clip_text = true
			for option in field["options"]:
				selector.add_item(option[1])
				if option[0] == value:
					selector.select(selector.item_count - 1)
			selector.item_selected.connect(func(index: int): value_changed.emit(field["path"], field["options"][index][0]))
			return selector
		"text":
			var text := Label.new()
			text.text = str(value)
			return text
	var spin := SpinBox.new()
	spin.custom_minimum_size.x = 112
	spin.min_value = field["minimum"]
	spin.max_value = field["maximum"]
	spin.step = field["step"]
	spin.allow_greater = field["allow_greater"]
	spin.editable = not field["readonly"]
	spin.suffix = field["unit"]
	spin.value = _display_number(value, field)
	spin.value_changed.connect(func(number: float):
		var next: Variant = int(round(number)) if field["integer"] else number
		if field["kind"] == "volume":
			next = -80.0 if number <= 0.0 else linear_to_db(number / 100.0)
		value_changed.emit(field["path"], next)
	)
	return spin


func update_snapshots(saved: Dictionary, active: Dictionary = {}, baseline: Dictionary = {}) -> void:
	if _range_error != null:
		var levels: Array = _data["hit_reaction"]["combat_levels"]
		_range_error.text = Catalog.ReactionRanges.validation_error(levels)
		_range_error.visible = not _range_error.text.is_empty()
		for index in _reaction_headings:
			_reaction_headings[index].text = "Level %d / hit-reaction value %s" % [index + 1, Catalog.ReactionRanges.range_text(levels, index)]
	for field in _entries:
		var keys: Array = field["path"]
		if (keys[0] == "moves" and keys.back() == "impact") or field["id"] in ["player.poise", "enemy_ai.poise"]:
			field["description"] = Catalog.impact_tooltip(_data)
		elif str(field["id"]).contains(".combat_levels.") and keys.back() != "minimum_value":
			field["description"] = Catalog.reaction_field_tooltip(_data, str(keys.back()))
		var tooltip: String = str(field["description"]) + "\n" + str(field["id"])
		_inputs[field["id"]].tooltip_text = tooltip
		_captions[field["id"]].tooltip_text = tooltip
		var label: Label = _metadata[field["id"]]
		label.visible = not saved.is_empty()
		if saved.is_empty():
			continue
		var saved_value: Variant = Store.read_value(saved, field["path"])
		var draft_value: Variant = Store.read_value(_data, field["path"])
		var baseline_value: Variant = saved_value if baseline.is_empty() else Store.read_value(baseline, field["path"])
		label.text = "Saved %s" % _format(saved_value, field)
		if baseline_value != draft_value:
			label.text += " · edited"
		elif baseline_value != saved_value:
			label.text += " · file updated"
		if not active.is_empty():
			label.text += " / Game %s" % _format(Store.read_value(active, field["path"]), field)
	for group in _summary_labels:
		var parts: PackedStringArray = []
		for field in _entries:
			if field["group"] == group:
				parts.append("%s: %s" % [field["label"], _format(Store.read_value(_data, field["path"]), field).strip_edges()])
		_summary_labels[group].text = " · ".join(parts)


func _format(value: Variant, field: Dictionary) -> String:
	if value == null:
		return "—"
	if typeof(value) == TYPE_BOOL:
		return "On" if value else "Off"
	if field["kind"] in ["number", "volume"]:
		return "%s %s" % [str(snappedf(_display_number(value, field), 0.001)), field["unit"]]
	return str(value)


func _display_number(value: Variant, field: Dictionary) -> float:
	if field["kind"] == "volume":
		return roundf(clampf(db_to_linear(float(value)) * 100.0, 0.0, 100.0))
	return float(value)
