extends Node
## Debug builds only; all communication uses Godot's existing debugger connection.

const PREFIX := "laema_dev_portal"
var _arena: Node
var _last_packet := ""
var _elapsed := 0.0


func initialize(arena: Node) -> void:
	_arena = arena
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not OS.is_debug_build() or not EngineDebugger.is_active():
		set_process(false)
		return
	EngineDebugger.register_message_capture(PREFIX, _capture)
	_publish()


func _exit_tree() -> void:
	if EngineDebugger.has_capture(PREFIX):
		EngineDebugger.unregister_message_capture(PREFIX)


func _capture(command: String, data: Array) -> bool:
	if command not in ["snapshot", "apply", "load_stage", "spawn_creature", "pause"]:
		return false
	if data.size() == 1 and data[0] is Dictionary:
		call_deferred("_execute", command, data[0])
	return true


func _execute(command: String, payload: Dictionary) -> void:
	var error := ""
	match command:
		"apply":
			var result: Dictionary = _arena.apply_saved_developer_config(payload.get("expected_active", {}))
			if not result["ok"]:
				error = result["error"]
		"load_stage":
			var stage_id := str(payload.get("stage_id", ""))
			var options: Array = _arena.get_developer_stage_options()
			var found := false
			for stage in options:
				if stage["id"] == stage_id:
					_arena.call_deferred("_load_stage_from_developer", int(stage["index"]))
					found = true
					break
			if not found:
				error = "Stage is not available in the current session."
		"pause":
			_arena.set_game_paused(not get_tree().paused)
		"spawn_creature":
			var result: Dictionary = _arena.spawn_developer_creature(str(payload.get("creature_id", "")))
			if not result["ok"]:
				error = str(result["error"])
	_publish(error, true)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= 0.75:
		_elapsed = 0.0
		_publish()


func _publish(error: String = "", force: bool = false) -> void:
	var packet: Dictionary = _arena.get_developer_config_state()
	packet["error"] = error
	var fingerprint := JSON.stringify(packet)
	if force or fingerprint != _last_packet:
		_last_packet = fingerprint
		EngineDebugger.send_message(PREFIX + ":state", [packet])
