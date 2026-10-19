@tool
extends EditorPlugin

const Dock = preload("res://addons/laema_dev_portal/focus_dock.gd")
const Debugger = preload("res://addons/laema_dev_portal/portal_debugger.gd")
const MoveInspector = preload("res://addons/laema_dev_portal/move_style_inspector.gd")

var _dock
var _debugger: EditorDebuggerPlugin
var _move_inspector: EditorInspectorPlugin


func _enter_tree() -> void:
	_move_inspector = MoveInspector.new()
	_move_inspector.edit_attack_requested.connect(_edit_attack)
	add_inspector_plugin(_move_inspector)
	_debugger = Debugger.new()
	add_debugger_plugin(_debugger)
	_dock = Dock.new()
	_dock.name = "Laema Dev Portal"
	_dock.setup(_debugger)
	_dock.run_gym_requested.connect(_run_gym)
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)


func _run_gym() -> void:
	EditorInterface.play_custom_scene("res://scenes/gym.tscn")


func _edit_attack(move_id: StringName) -> void:
	EditorInterface.open_scene_from_path("res://scenes/player/player.tscn")
	await get_tree().process_frame
	var scene := EditorInterface.get_edited_scene_root()
	if scene == null or scene.scene_file_path != "res://scenes/player/player.tscn":
		return
	var player := scene.get_node("AnimationPlayer") as AnimationPlayer
	if not player.has_animation(move_id):
		return
	player.assigned_animation = move_id
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(player)
	EditorInterface.edit_node(player)
	EditorInterface.set_main_screen_editor("2D")


func _exit_tree() -> void:
	if _move_inspector != null:
		remove_inspector_plugin(_move_inspector)
	if is_instance_valid(_dock):
		remove_control_from_docks(_dock)
		_dock.queue_free()
	if _debugger != null:
		remove_debugger_plugin(_debugger)
	_debugger = null
