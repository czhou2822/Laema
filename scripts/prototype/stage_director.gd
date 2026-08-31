class_name StageDirector
extends Node

const SequenceObjectiveEvaluatorScript = preload("res://scripts/prototype/sequence_objective_evaluator.gd")
const FinalEnemyEvaluatorScript = preload("res://scripts/prototype/final_enemy_evaluator.gd")

signal presentation_changed(snapshot: Dictionary)
signal stage_completed(descriptor: Dictionary)
signal transition_requested(next_descriptor: Dictionary)
signal free_practice_entered

enum Lifecycle {
	ACTIVE,
	COMPLETED_WAITING_FOR_EXIT,
	TRANSITIONING,
	FINAL_ACTIVE,
	FREE_PRACTICE,
}

var _stages: Array[Dictionary] = []
var _index := 0
var _lifecycle := Lifecycle.ACTIVE
var _evaluator: ObjectiveEvaluator
var _active_descriptor: Dictionary = {}


func configure(tutorial: Dictionary) -> void:
	_stages.clear()
	for descriptor_variant in tutorial["stages"]:
		_stages.append(Dictionary(descriptor_variant).duplicate(true))
	_index = 0
	_active_descriptor = {}
	_lifecycle = Lifecycle.ACTIVE


func get_initial_descriptor() -> Dictionary:
	return _stages[0].duplicate(true)


func get_next_descriptor() -> Dictionary:
	if _index + 1 >= _stages.size():
		return {}
	return _stages[_index + 1].duplicate(true)


func activate_stage(descriptor: Dictionary) -> void:
	_active_descriptor = descriptor.duplicate(true)
	_evaluator = _create_evaluator(Dictionary(_active_descriptor["objective"]))
	add_child(_evaluator)
	_evaluator.configure(Dictionary(_active_descriptor["objective"]))
	_lifecycle = Lifecycle.FINAL_ACTIVE if bool(_active_descriptor.get("final", false)) else Lifecycle.ACTIVE
	_emit_objective(false, 0, false, _evaluator.get_highlight_index() if _evaluator.has_method("get_highlight_index") else -1)


func consume_outcome(outcome) -> void:
	if _evaluator == null or _lifecycle == Lifecycle.FREE_PRACTICE:
		return
	var snapshot: Dictionary = outcome.snapshot() if outcome != null and outcome.has_method("snapshot") else {}
	if snapshot.is_empty():
		return
	var result: Dictionary = _evaluator.consume_outcome(snapshot)
	match StringName(result.get("kind", &"unchanged")):
		&"progress":
			_emit_objective(false, int(result["progress"]), false, int(result.get("highlight_index", -1)))
		&"invalidated":
			_emit_objective(false, 0, true, int(result.get("highlight_index", -1)))
		&"completed":
			_on_objective_completed(int(result.get("progress", 0)))


func report_exit_reached() -> void:
	if _lifecycle != Lifecycle.COMPLETED_WAITING_FOR_EXIT:
		return
	_lifecycle = Lifecycle.TRANSITIONING
	transition_requested.emit(_stages[_index + 1].duplicate(true))


func report_transition_finished() -> void:
	if _lifecycle != Lifecycle.TRANSITIONING:
		return
	_dispose_evaluator()
	_index += 1
	activate_stage(_stages[_index])


func is_exit_authorized() -> bool:
	return _lifecycle == Lifecycle.COMPLETED_WAITING_FOR_EXIT


func _on_objective_completed(progress: int) -> void:
	if _lifecycle == Lifecycle.FINAL_ACTIVE:
		_lifecycle = Lifecycle.FREE_PRACTICE
		_dispose_evaluator()
		presentation_changed.emit({"label": str(_active_descriptor.get("free_practice_text", "now you are free")), "tokens": [], "progress": 0, "completed": true, "prompt": "", "flinch": false})
		free_practice_entered.emit()
		return
	_lifecycle = Lifecycle.COMPLETED_WAITING_FOR_EXIT
	_emit_objective(true, progress, false, -1)
	stage_completed.emit(_active_descriptor.duplicate(true))


func _emit_objective(completed: bool, progress: int, flinch: bool, highlight_index: int) -> void:
	var objective: Dictionary = _active_descriptor["objective"]
	presentation_changed.emit({
		"label": str(objective["label"]),
		"tokens": Array(objective.get("tokens", [])).duplicate(),
		"progress": progress,
		"highlight_index": highlight_index,
		"completed": completed,
		"prompt": "moving on ->" if completed else "",
		"flinch": flinch,
	})


func _create_evaluator(objective: Dictionary) -> ObjectiveEvaluator:
	match StringName(objective["type"]):
		&"sequence":
			return SequenceObjectiveEvaluatorScript.new()
		&"final_enemy":
			return FinalEnemyEvaluatorScript.new()
	push_error("Unsupported tutorial evaluator: %s" % objective["type"])
	return ObjectiveEvaluator.new()


func _dispose_evaluator() -> void:
	if _evaluator != null:
		_evaluator.queue_free()
		_evaluator = null
