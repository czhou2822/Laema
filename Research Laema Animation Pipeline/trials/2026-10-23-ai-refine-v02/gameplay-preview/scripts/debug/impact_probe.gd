extends RefCounted
## Debug-only structured facts captured by Godot's normal file log.


static func record(stage: String, facts: Dictionary) -> void:
	if not OS.is_debug_build():
		return
	var entry := facts.duplicate(true)
	entry["stage"] = stage
	entry["physics_frame"] = Engine.get_physics_frames()
	entry["ticks_ms"] = Time.get_ticks_msec()
	print("[PROBE][IMPACT] " + JSON.stringify(entry))
