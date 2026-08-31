class_name FiveHitFireEvaluator
extends ObjectiveEvaluator

var _school := &"fire"
var _required_hits := 5
var _progress := 0
var _attempt_active := false
var _completed := false


func configure(objective: Dictionary) -> void:
	_school = StringName(objective["school"])
	_required_hits = int(objective["required_hits"])
	_progress = 0
	_attempt_active = false
	_completed = false


func consume_outcome(outcome: Dictionary) -> Dictionary:
	if _completed:
		return {"kind": &"unchanged"}
	var outcome_kind := StringName(outcome.get("kind", &""))
	if outcome_kind == &"light_contact_resolved":
		return _consume_light_contact(outcome)
	if outcome_kind == &"action_accepted" and _attempt_active:
		var action_kind := StringName(outcome.get("action_kind", &""))
		if action_kind in [&"cast_normal", &"cast_empowered", &"cast_endpoint"]:
			return _invalidate()
	if outcome_kind == &"chain_terminated" and _attempt_active:
		return _invalidate()
	return {"kind": &"unchanged"}


func _consume_light_contact(outcome: Dictionary) -> Dictionary:
	var school := StringName(outcome.get("school", &""))
	var result := StringName(outcome.get("result", &""))
	if result == &"hit" and school == _school:
		_attempt_active = true
		_progress += 1
		if _progress >= _required_hits:
			_completed = true
			return {"kind": &"completed", "progress": _progress}
		return {"kind": &"progress", "progress": _progress}
	if result == &"miss" or result == &"orb_without_contact":
		if school == _school or _attempt_active:
			return _invalidate()
	elif result == &"hit" and school != _school and _attempt_active:
		return _invalidate()
	return {"kind": &"unchanged"}


func _invalidate() -> Dictionary:
	_progress = 0
	_attempt_active = false
	return {"kind": &"invalidated", "progress": 0}
