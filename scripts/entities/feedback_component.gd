class_name FeedbackComponent
extends Node

var _owner_entity: Entity
var _duration := 2.0
const VIEWPORT_MARGIN := 12.0


func configure(owner_entity: Entity, duration: float) -> void:
	_owner_entity = owner_entity
	_duration = duration


func apply_runtime_tuning(duration: float) -> void:
	_duration = duration


func show_cast_level(school: StringName, level: int) -> void:
	if _owner_entity == null or level < 1:
		return
	var label := Label.new()
	label.text = "%s Lv.%d" % [String(school).capitalize(), level]
	var local_offset := Vector2(-48.0, -118.0)
	label.position = local_offset
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", _school_color(school))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	_owner_entity.add_child(label)
	_clamp_label_to_viewport(label, local_offset)
	var entry_duration := _duration
	get_tree().create_timer(entry_duration).timeout.connect(label.queue_free)


func show_damage(school: StringName, amount: float) -> void:
	if _owner_entity == null:
		return
	var label := Label.new()
	label.text = "%.0f" % amount
	var local_offset := Vector2(-10.0, -238.0)
	label.position = local_offset
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", _school_color(school))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	_owner_entity.add_child(label)
	_clamp_label_to_viewport(label, local_offset)
	var tween := _owner_entity.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 20.0, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, _duration)
	tween.chain().tween_callback(label.queue_free)


func show_dot_damage(school: StringName, amount: float) -> void:
	if _owner_entity == null:
		return
	var label := Label.new()
	label.text = "%.0f" % amount
	var local_offset := Vector2(-8.0, -206.0)
	label.position = local_offset
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", _school_color(school))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	_owner_entity.add_child(label)
	_clamp_label_to_viewport(label, local_offset)
	var tween := _owner_entity.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30.0, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, _duration)
	tween.chain().tween_callback(label.queue_free)


func _clamp_label_to_viewport(label: Label, local_offset: Vector2) -> void:
	var viewport := _owner_entity.get_viewport()
	var canvas_transform: Transform2D = viewport.get_canvas_transform()
	var inverse_canvas_transform: Transform2D = canvas_transform.affine_inverse()
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var label_size: Vector2 = label.get_combined_minimum_size()
	var screen_position: Vector2 = canvas_transform * (_owner_entity.global_position + local_offset)
	screen_position.x = clampf(screen_position.x, VIEWPORT_MARGIN, viewport_size.x - label_size.x - VIEWPORT_MARGIN)
	screen_position.y = clampf(screen_position.y, VIEWPORT_MARGIN, viewport_size.y - label_size.y - VIEWPORT_MARGIN)
	label.global_position = inverse_canvas_transform * screen_position


func _school_color(school: StringName) -> Color:
	match school:
		&"fire": return Color("ff493d")
		&"water": return Color("3a96ff")
		&"air": return Color("f4f6ff")
		&"earth": return Color("8b5a2b")
	return Color.WHITE
