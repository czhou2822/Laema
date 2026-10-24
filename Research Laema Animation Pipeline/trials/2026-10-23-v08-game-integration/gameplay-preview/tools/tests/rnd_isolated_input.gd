extends "res://tools/tests/rnd_gameplay_capture.gd"
## Test fixture only: keep existing button/axis semantics, select synthetic device7.
## The copied game's Player/Might/Magic/input code is untouched.
const RND_DEVICE := 7
var _rnd_routed := false

func _initialize() -> void:
	root.set_flag(Window.FLAG_NO_FOCUS, true)
	super._initialize()

func _tick() -> void:
	if not _rnd_routed and InputMap.has_action(&"casting") and not InputMap.action_get_events(&"casting").is_empty():
		for action in InputMap.get_actions():
			InputMap.action_erase_events(action)
			Input.action_release(action)
		_rnd_routed = true
		_metadata["input_routing_fixture"] = "Scheduled InputEventAction events, original action names and strengths, synthetic device7; hardware bindings excluded inside test process only. No OS device settings or game code changed. This is action-level integration, not hardware/controller validation."
		_metadata["routing_driver_sha256"] = FileAccess.get_sha256("res://tools/tests/rnd_isolated_input.gd")
		_record("rnd_device_routing", {"device":RND_DEVICE,"gameplay_rules_changed":false})
	super._tick()

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
	event.set_meta(INPUT_TAG,_session)
	_held[action] = {"pressed":pressed,"value":value,"binding":event}
	_record("scheduled_input",{"action":action,"pressed":pressed,"value":value,"at_ms":scheduled.get("at_ms",-1),"lateness_ms":late_ms,"event":event.as_text()})
	Input.parse_input_event(event)
