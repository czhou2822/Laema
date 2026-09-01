class_name HeatGuardSequenceEvaluator
extends ObjectiveEvaluator

const SequenceObjectiveEvaluatorScript = preload("res://scripts/prototype/sequence_objective_evaluator.gd")

var _sequence: SequenceObjectiveEvaluator
var _objective: Dictionary = {}
var _threshold := 80.0
var _heat_above := false
var _attempt_started := false

func configure(objective: Dictionary) -> void:
	_objective = objective.duplicate(true)
	_threshold = float(_objective["threshold"])
	_sequence = SequenceObjectiveEvaluatorScript.new()
	add_child(_sequence)
	_sequence.configure(_objective)
	_heat_above = false
	_attempt_started = false

func consume_heat(value: float, _level: int, _speed_multiplier: float) -> Dictionary:
	_heat_above = value > _threshold
	if _attempt_started and not _heat_above:
		_reset_attempt()
		return {"kind": &"invalidated", "progress": 0, "highlight_index": -1}
	return {"kind": &"unchanged"}

func consume_outcome(outcome: Dictionary) -> Dictionary:
	if not _heat_above:
		return {"kind": &"unchanged"}
	if not _attempt_started:
		if StringName(outcome.get("kind", &"")) != &"light_contact_resolved" or StringName(outcome.get("result", &"")) != &"hit":
			return {"kind": &"unchanged"}
	var result := _sequence.consume_outcome(outcome)
	var kind := StringName(result.get("kind", &"unchanged"))
	if kind == &"progress" or kind == &"completed":
		_attempt_started = true
	elif kind == &"invalidated":
		_attempt_started = false
	return result

func _reset_attempt() -> void:
	_sequence.configure(_objective)
	_attempt_started = false
