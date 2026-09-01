class_name ObjectiveWidget
extends Control

var _panel: PanelContainer
var _panel_style: StyleBoxFlat
var _stage_label: Label
var _label: Label
var _tokens: HBoxContainer
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
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 20)
	layout.add_child(_label)
	_tokens = HBoxContainer.new()
	_tokens.alignment = BoxContainer.ALIGNMENT_CENTER
	_tokens.add_theme_constant_override("separation", 8)
	layout.add_child(_tokens)
	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 16)
	layout.add_child(_prompt)


func present(snapshot: Dictionary) -> void:
	var stage_number := int(snapshot.get("stage_number", 0))
	_stage_label.visible = stage_number > 0
	_stage_label.text = "STAGE %d" % stage_number if stage_number > 0 else ""
	_label.text = str(snapshot.get("label", ""))
	var completed := bool(snapshot.get("completed", false))
	_apply_completion_style(completed)
	_label.modulate = Color("68dc81") if completed else Color.WHITE
	_prompt.text = str(snapshot.get("prompt", ""))
	_prompt.modulate = Color("68dc81") if completed else Color.WHITE
	for child in _tokens.get_children():
		child.queue_free()
	var tokens: Array = snapshot.get("tokens", [])
	var progress := int(snapshot.get("progress", 0))
	var highlight_index := int(snapshot.get("highlight_index", -1))
	for index in range(tokens.size()):
		var token := Label.new()
		token.text = str(tokens[index])
		token.add_theme_font_size_override("font_size", 26)
		if completed or index < progress:
			token.modulate = Color("68dc81")
		elif index == highlight_index:
			token.modulate = Color.WHITE
		else:
			token.modulate = Color("d7e7f1")
		_tokens.add_child(token)
	if bool(snapshot.get("flinch", false)):
		_flinch()


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
