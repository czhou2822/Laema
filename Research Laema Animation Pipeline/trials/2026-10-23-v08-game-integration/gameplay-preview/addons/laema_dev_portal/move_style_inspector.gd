@tool
extends EditorInspectorPlugin
## Navigation into Godot's native animation editor; no custom timeline.

signal edit_attack_requested(move_id: StringName)


func _can_handle(object: Object) -> bool:
	return object is MoveStyleTuning


func _parse_begin(object: Object) -> void:
	var style := object as MoveStyleTuning
	var button := Button.new()
	button.text = "Edit %s animation & hitbox" % style.move_id
	button.tooltip_text = "Open Player's native AnimationPlayer. Scrub the active_start..active_end window, select AttackCast, and key animated geometry. These native curves alone own Player X geometry; no scalar size override is applied. Save the animation and restart the scene to compare."
	button.pressed.connect(func(): edit_attack_requested.emit(style.move_id))
	add_custom_control(button)
