class_name SequenceObjectiveEvaluator
extends ObjectiveEvaluator

enum Phase {
	PRESTART,
	ACTIVE,
	COMPLETED,
}

var _steps: Array[Dictionary] = []
var _phase := Phase.PRESTART
var _progress := 0
var _pending_attempt_id := -1
var _prestart_ignore_unexpected := false
var _prestart_fire_miss_invalid := false
var _highlight_enabled := false
var _active_rejected_switch_invalid := false
var _completion_progress := 0


func configure(objective: Dictionary) -> void:
	_steps.clear()
	for step_variant in objective["success_steps"]:
		_steps.append(Dictionary(step_variant).duplicate(true))
	_phase = Phase.PRESTART
	_progress = 0
	_pending_attempt_id = -1
	var prestart: Dictionary = Dictionary(objective.get("prestart", {}))
	_prestart_ignore_unexpected = bool(prestart.get("ignore_unexpected", false))
	_prestart_fire_miss_invalid = bool(prestart.get("fire_miss_invalid", false))
	_highlight_enabled = bool(objective.get("highlight_next", false))
	var active: Dictionary = Dictionary(objective.get("active", {}))
	_active_rejected_switch_invalid = bool(active.get("rejected_switch_invalid", false))
	_completion_progress = int(objective["completion_progress"])


func get_highlight_index() -> int:
	return _progress if _highlight_enabled and _phase != Phase.COMPLETED else -1


func consume_outcome(outcome: Dictionary) -> Dictionary:
	if _phase == Phase.COMPLETED:
		return {"kind": &"unchanged"}
	var kind := StringName(outcome.get("kind", &""))
	if kind == &"chain_terminated" and _phase == Phase.ACTIVE:
		return _invalidate()
	if kind == &"light_contact_resolved":
		return _consume_light_contact(outcome)
	if kind == &"action_accepted":
		return _consume_action_accepted(outcome)
	if kind == &"cast_attempt_resolved":
		return _consume_cast_attempt(outcome)
	if kind == &"school_switched":
		return _consume_school_switched(outcome)
	if kind == &"school_switch_rejected" and _phase == Phase.ACTIVE and (_expects(&"switch") or _active_rejected_switch_invalid):
		return _invalidate()
	return {"kind": &"unchanged"}


func _consume_light_contact(outcome: Dictionary) -> Dictionary:
	var school := StringName(outcome.get("school", &""))
	var result := StringName(outcome.get("result", &""))
	if _phase == Phase.PRESTART and _prestart_fire_miss_invalid and result in [&"miss", &"orb_without_contact"] and school == &"fire":
		return _invalidate()
	if _phase == Phase.PRESTART and _prestart_ignore_unexpected:
		if not _expects(&"light"):
			return {"kind": &"unchanged"}
		if _current_step().has("school") and school != StringName(_current_step()["school"]):
			return {"kind": &"unchanged"}
	if not _expects(&"light"):
		return _invalidate()
	var step := _current_step()
	if result != &"hit":
		return _invalidate()
	if step.has("school") and school != StringName(step["school"]):
		return _invalidate()
	return _advance()


func _consume_action_accepted(outcome: Dictionary) -> Dictionary:
	var action_kind := StringName(outcome.get("action_kind", &""))
	var is_cast := action_kind in [&"cast_normal", &"cast_empowered", &"cast_endpoint"]
	if _phase == Phase.PRESTART and _prestart_ignore_unexpected and not is_cast:
		return {"kind": &"unchanged"}
	if not is_cast:
		return _invalidate() if _expects(&"cast") else {"kind": &"unchanged"}
	if not _expects(&"cast"):
		return {"kind": &"unchanged"} if _phase == Phase.PRESTART and _prestart_ignore_unexpected else _invalidate()
	var step := _current_step()
	if step.has("endpoint") and bool(step["endpoint"]) != bool(outcome.get("endpoint", false)):
		return _invalidate()
	if step.has("chain_position") and int(outcome.get("position", -1)) != int(step["chain_position"]):
		return _invalidate()
	_pending_attempt_id = int(outcome.get("attempt_id", -1))
	if _pending_attempt_id <= 0:
		return _invalidate()
	_phase = Phase.ACTIVE
	return _presentation_result()


func _consume_cast_attempt(outcome: Dictionary) -> Dictionary:
	if _pending_attempt_id <= 0 or int(outcome.get("attempt_id", -1)) != _pending_attempt_id:
		return {"kind": &"unchanged"}
	_pending_attempt_id = -1
	if StringName(outcome.get("terminal", &"")) != &"launched":
		return _invalidate()
	var step := _current_step()
	if step.has("required_level") and int(outcome.get("primary_level", 0)) != int(step["required_level"]):
		return _invalidate()
	if step.has("endpoint") and bool(step["endpoint"]) != bool(outcome.get("endpoint", false)):
		return _invalidate()
	return _advance()


func _consume_school_switched(outcome: Dictionary) -> Dictionary:
	if _phase == Phase.PRESTART:
		return {"kind": &"unchanged"}
	if not _expects(&"switch"):
		return _invalidate()
	if StringName(outcome.get("from_school", &"")) == StringName(outcome.get("to_school", &"")):
		return _invalidate()
	if int(outcome.get("position", -1)) != int(_current_step().get("chain_position", -1)):
		return _invalidate()
	return _advance()


func _expects(step_type: StringName) -> bool:
	return _progress < _steps.size() and StringName(_current_step().get("type", &"")) == step_type


func _current_step() -> Dictionary:
	return _steps[_progress]


func _advance() -> Dictionary:
	_progress += 1
	_phase = Phase.ACTIVE
	if _progress >= _steps.size():
		_phase = Phase.COMPLETED
		return {"kind": &"completed", "progress": _completion_progress, "highlight_index": -1}
	return _presentation_result()


func _invalidate() -> Dictionary:
	_phase = Phase.PRESTART
	_progress = 0
	_pending_attempt_id = -1
	return {"kind": &"invalidated", "progress": 0, "highlight_index": get_highlight_index()}


func _presentation_result() -> Dictionary:
	return {"kind": &"progress", "progress": _progress, "highlight_index": get_highlight_index()}
