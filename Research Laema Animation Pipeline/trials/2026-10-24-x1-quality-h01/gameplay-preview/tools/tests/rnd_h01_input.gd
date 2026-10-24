extends "res://tools/tests/rnd_gameplay_capture.gd"
const RND_DEVICE := 7
var _rnd_routed := false
var _h01_started := false

func _initialize() -> void:
	root.set_flag(Window.FLAG_NO_FOCUS, true)
	paused = true
	super._initialize()

func _tick() -> void:
	if not _rnd_routed and InputMap.has_action(&"casting") and not InputMap.action_get_events(&"casting").is_empty():
		for action in InputMap.get_actions():
			InputMap.action_erase_events(action)
			Input.action_release(action)
		_rnd_routed = true
		_metadata["input_routing_fixture"] = "H01 initialized paused until synthetic device7 routing was installed; original scheduled action events then run at normal clock. Normal gameplay code/settings unchanged. Not physical-controller validation."
		paused = false
		_record("rnd_device_routing", {"device":7,"startup_pause_released":true,"gameplay_rules_changed":false})
	super._tick()
	if not _command.is_empty():
		_h01_started = true
	elif _h01_started and not _stopping:
		_stop(0)

func _binding(action: StringName, analog: bool) -> InputEvent:
	var event := InputEventAction.new()
	event.action = action
	event.device = RND_DEVICE
	return event

func _send_control(scheduled: Dictionary, late_ms := 0) -> void:
	var action: StringName = scheduled["action"]
	var pressed: bool = scheduled["pressed"]
	var value := float(scheduled["value"])
	var event := InputEventAction.new()
	event.action = action
	event.device = RND_DEVICE
	event.pressed = pressed
	event.strength = value if pressed else 0.0
	event.set_meta(INPUT_TAG, _session)
	_held[action] = {"pressed":pressed,"value":value,"binding":event}
	_record("scheduled_input", {"action":action,"pressed":pressed,"value":value,"at_ms":scheduled.get("at_ms",-1),"lateness_ms":late_ms,"event":event.as_text()})
	Input.parse_input_event(event)
