class_name HeatGuardSequenceEvaluator
extends ObjectiveEvaluator

const SequenceObjectiveEvaluatorScript = preload("res://scripts/prototype/sequence_objective_evaluator.gd")

var _sequence: SequenceObjectiveEvaluator
var _objective: Dictionary = {}
var _threshold := 80.0
var _heat_met := false
var _attempt_started := false
var _heat_row_id := &"heat"
var _completed := false

func configure(objective: Dictionary) -> void:
	_objective = objective.duplicate(true)
	_threshold = float(_objective["threshold"])
	_sequence = SequenceObjectiveEvaluatorScript.new()
	add_child(_sequence)
	_sequence.configure(_objective)
	_heat_met = false
	_attempt_started = false
	_completed = false
	var presentation: Dictionary = _objective["presentation"]
	for row_variant in presentation["rows"]:
		var row: Dictionary = row_variant
		if StringName(row["id"]) == &"heat":
			_heat_row_id = &"heat"

func consume_heat(value: float, _level: int, _speed_multiplier: float) -> Dictionary:
	if _completed:
		return {"kind": &"unchanged"}
	_heat_met = value >= _threshold
	if _attempt_started and not _heat_met:
		_reset_attempt()
		return {"kind": &"invalidated", "progress": 0, "highlight_index": -1}
	return {"kind": &"progress"}

func consume_outcome(outcome: Dictionary) -> Dictionary:
	if _completed:
		return {"kind": &"unchanged"}
	if not _heat_met:
		return {"kind": &"unchanged"}
	if not _attempt_started:
		if StringName(outcome.get("kind", &"")) != &"light_contact_resolved" or StringName(outcome.get("result", &"")) != &"hit" or int(outcome.get("position", -1)) != 1:
			return {"kind": &"unchanged"}
	var result := _sequence.consume_outcome(outcome)
	var kind := StringName(result.get("kind", &"unchanged"))
	if kind == &"progress" or kind == &"completed":
		_attempt_started = true
		_completed = kind == &"completed"
	elif kind == &"invalidated":
		_attempt_started = false
	return result

func _reset_attempt() -> void:
	_sequence.configure(_objective)
	_attempt_started = false


func get_row_state() -> Dictionary:
	var rows := _sequence.get_row_state()
	rows[_heat_row_id] = {"completed": _heat_met}
	return rows
