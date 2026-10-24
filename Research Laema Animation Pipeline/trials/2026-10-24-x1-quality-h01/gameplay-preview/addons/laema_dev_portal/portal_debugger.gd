@tool
extends EditorDebuggerPlugin

signal state_received(packet: Dictionary)
signal availability_changed(available: bool, reason: String)

var _ready_sessions: Dictionary = {}
var _active_session := -1


func _has_capture(capture: String) -> bool:
	return capture == "laema_dev_portal"


func _setup_session(session_id: int) -> void:
	if get_session(session_id).is_active():
		get_session(session_id).send_message("laema_dev_portal:snapshot", [{}])
	get_session(session_id).stopped.connect(func():
		_ready_sessions.erase(session_id)
		_update_availability()
	)


func _capture(message: String, data: Array, session_id: int) -> bool:
	if message != "laema_dev_portal:state":
		return false
	if data.size() != 1 or not data[0] is Dictionary:
		return true
	_ready_sessions[session_id] = true
	_update_availability()
	if _ready_sessions.size() == 1:
		state_received.emit(data[0])
	return true


func request(command: String, payload: Dictionary = {}) -> bool:
	if _ready_sessions.size() != 1:
		return false
	var session: EditorDebuggerSession = get_session(int(_ready_sessions.keys()[0]))
	if not session.is_active():
		return false
	session.send_message("laema_dev_portal:" + command, [payload])
	return true


func _update_availability() -> void:
	var available := _ready_sessions.size() == 1
	var selected := int(_ready_sessions.keys()[0]) if available else -1
	var changed := selected != _active_session
	_active_session = selected
	var reason := "Game stopped · editing available"
	if available:
		reason = "Game connected"
	elif _ready_sessions.size() > 1:
		reason = "Multiple game sessions · stop extra sessions to apply settings"
	availability_changed.emit(available, reason)
	if available and changed:
		get_session(selected).send_message("laema_dev_portal:snapshot", [{}])
