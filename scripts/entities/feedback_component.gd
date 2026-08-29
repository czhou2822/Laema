class_name FeedbackComponent
extends Node

var _owner_entity: Entity
var _duration := 2.0


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
	label.position = Vector2(-48.0, -118.0)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", _school_color(school))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	_owner_entity.add_child(label)
	var entry_duration := _duration
	get_tree().create_timer(entry_duration).timeout.connect(label.queue_free)


func _school_color(school: StringName) -> Color:
	match school:
		&"fire": return Color("ff493d")
		&"water": return Color("3a96ff")
		&"air": return Color("f4f6ff")
		&"earth": return Color("8b5a2b")
	return Color.WHITE
