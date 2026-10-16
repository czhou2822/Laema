@tool
extends EditorPlugin

const Dock = preload("res://addons/laema_dev_portal/focus_dock.gd")
const Debugger = preload("res://addons/laema_dev_portal/portal_debugger.gd")

var _dock
var _debugger: EditorDebuggerPlugin


func _enter_tree() -> void:
	_debugger = Debugger.new()
	add_debugger_plugin(_debugger)
	_dock = Dock.new()
	_dock.name = "Laema Dev Portal"
	_dock.setup(_debugger)
	_dock.run_gym_requested.connect(_run_gym)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)


func _run_gym() -> void:
	EditorInterface.play_custom_scene("res://scenes/gym.tscn")


func _exit_tree() -> void:
	if is_instance_valid(_dock):
		remove_control_from_docks(_dock)
		_dock.queue_free()
	if _debugger != null:
		remove_debugger_plugin(_debugger)
	_debugger = null
