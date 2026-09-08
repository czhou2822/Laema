class_name ObjectiveWidget
extends Control

var _panel: PanelContainer
var _panel_style: StyleBoxFlat
var _stage_label: Label
var _rows: VBoxContainer
var _prompt: Label
var _tween: Tween
var _rest_position := Vector2.ZERO


func _ready() -> void:
	_rest_position = position
	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)
	_panel_style = StyleBoxFlat.new()
	_panel_style.border_width_left = 2
	_panel_style.border_width_top = 2
	_panel_style.border_width_right = 2
	_panel_style.border_width_bottom = 2
	_panel_style.corner_radius_top_left = 8
	_panel_style.corner_radius_top_right = 8
	_panel_style.corner_radius_bottom_left = 8
	_panel_style.corner_radius_bottom_right = 8
	_panel.add_theme_stylebox_override("panel", _panel_style)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	_panel.add_child(layout)
	_stage_label = Label.new()
	_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stage_label.add_theme_font_size_override("font_size", 14)
	_stage_label.modulate = Color("8db9cb")
	layout.add_child(_stage_label)
	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override("separation", 4)
	layout.add_child(_rows)
	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 16)
	layout.add_child(_prompt)


func present(snapshot: Dictionary) -> void:
	var stage_number := int(snapshot.get("stage_number", 0))
	_stage_label.visible = stage_number > 0
	_stage_label.text = "STAGE %d" % stage_number if stage_number > 0 else ""
	var completed := bool(snapshot.get("completed", false))
	_apply_completion_style(completed)
	_prompt.text = str(snapshot.get("prompt", ""))
	_prompt.modulate = Color("68dc81") if completed else Color.WHITE
	for child in _rows.get_children():
		child.queue_free()
	for row_variant in snapshot.get("rows", []):
		_add_row(Dictionary(row_variant), completed)
	if bool(snapshot.get("flinch", false)):
		_flinch()


func _add_row(row: Dictionary, whole_completed: bool) -> void:
	var row_layout := VBoxContainer.new()
	row_layout.add_theme_constant_override("separation", 2)
	_rows.add_child(row_layout)
	var row_completed := whole_completed or bool(row.get("completed", false))
	var label := Label.new()
	label.text = str(row["label"])
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.modulate = Color("68dc81") if row_completed else Color.WHITE
	row_layout.add_child(label)
	var tokens: Array = Array(row.get("tokens", []))
	if tokens.is_empty():
		return
	var token_layout := HBoxContainer.new()
	token_layout.alignment = BoxContainer.ALIGNMENT_CENTER
	token_layout.add_theme_constant_override("separation", 8)
	row_layout.add_child(token_layout)
	var progress := int(row.get("progress", 0))
	var highlight_index := int(row.get("highlight_index", -1))
	var token_font_size := 18 if _uses_compact_token_font(tokens) else 26
	for index in range(tokens.size()):
		var token := Label.new()
		token.text = str(tokens[index])
		token.add_theme_font_size_override("font_size", token_font_size)
		if row_completed or index < progress:
			token.modulate = Color("68dc81")
		elif index == highlight_index:
			token.modulate = Color.WHITE
		else:
			token.modulate = Color("d7e7f1")
		token_layout.add_child(token)


func _uses_compact_token_font(tokens: Array) -> bool:
	for token in tokens:
		if str(token).length() > 4:
			return true
	return false


func _flinch() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	position = _rest_position
	_tween = create_tween()
	_tween.tween_property(self, "position:x", _rest_position.x + 8.0, 0.05)
	_tween.tween_property(self, "position:x", _rest_position.x - 8.0, 0.08)
	_tween.tween_property(self, "position:x", _rest_position.x, 0.06)


func _apply_completion_style(completed: bool) -> void:
	if completed:
		_panel_style.bg_color = Color(0.04, 0.22, 0.11, 0.92)
		_panel_style.border_color = Color("68dc81")
	else:
		_panel_style.bg_color = Color(0.015, 0.025, 0.055, 0.86)
		_panel_style.border_color = Color(0.18, 0.55, 0.72, 0.85)
