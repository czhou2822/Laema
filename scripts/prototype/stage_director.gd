class_name StageDirector
extends Node

const SequenceObjectiveEvaluatorScript = preload("res://scripts/prototype/sequence_objective_evaluator.gd")
const FinalEnemyEvaluatorScript = preload("res://scripts/prototype/final_enemy_evaluator.gd")
const HeatThresholdEvaluatorScript = preload("res://scripts/prototype/heat_threshold_evaluator.gd")
const HeatGuardSequenceEvaluatorScript = preload("res://scripts/prototype/heat_guard_sequence_evaluator.gd")

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
var _default_stage_id := ""


func configure(tutorial: Dictionary) -> void:
	_stages.clear()
	for descriptor_variant in tutorial["stages"]:
		_stages.append(Dictionary(descriptor_variant).duplicate(true))
	_default_stage_id = str(tutorial["default_stage_id"])
	_index = 0
	for stage_index in range(_stages.size()):
		if str(_stages[stage_index]["id"]) == _default_stage_id:
			_index = stage_index
			break
	_active_descriptor = {}
	_lifecycle = Lifecycle.ACTIVE


func get_initial_descriptor() -> Dictionary:
	return _stages[_index].duplicate(true)


func get_next_descriptor() -> Dictionary:
	if _index + 1 >= _stages.size():
		return {}
	return _stages[_index + 1].duplicate(true)


func get_stage_options() -> Array[Dictionary]:
	var options: Array[Dictionary] = []
	for stage_index in range(_stages.size()):
		var descriptor: Dictionary = _stages[stage_index]
		options.append({
			"index": stage_index,
			"label": str(descriptor["display_name"]),
			"active": stage_index == _index,
		})
	return options


func select_debug_stage(stage_index: int) -> Dictionary:
	if stage_index < 0 or stage_index >= _stages.size():
		return {}
	_dispose_evaluator()
	_index = stage_index
	_active_descriptor = {}
	_lifecycle = Lifecycle.ACTIVE
	return _stages[_index].duplicate(true)


func activate_stage(descriptor: Dictionary) -> void:
	_active_descriptor = descriptor.duplicate(true)
	_evaluator = _create_evaluator(Dictionary(_active_descriptor["objective"]))
	add_child(_evaluator)
	_evaluator.configure(Dictionary(_active_descriptor["objective"]))
	_lifecycle = Lifecycle.FINAL_ACTIVE if bool(_active_descriptor.get("final", false)) else Lifecycle.ACTIVE
	_emit_objective(false, false)


func consume_outcome(outcome) -> void:
	if _evaluator == null or _lifecycle == Lifecycle.FREE_PRACTICE:
		return
	var snapshot: Dictionary = outcome.snapshot() if outcome != null and outcome.has_method("snapshot") else {}
	if snapshot.is_empty():
		return
	var result: Dictionary = _evaluator.consume_outcome(snapshot)
	match StringName(result.get("kind", &"unchanged")):
		&"progress":
			_emit_objective(false, false)
		&"invalidated":
			_emit_objective(false, true)
		&"completed":
			_on_objective_completed()

func consume_heat(value: float, level: int, speed_multiplier: float) -> void:
	if _evaluator == null or not _evaluator.has_method("consume_heat"):
		return
	_consume_result(_evaluator.call("consume_heat", value, level, speed_multiplier))

func _consume_result(result: Dictionary) -> void:
	match StringName(result.get("kind", &"unchanged")):
		&"progress":
			_emit_objective(false, false)
		&"invalidated":
			_emit_objective(false, true)
		&"completed":
			_on_objective_completed()


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


func _on_objective_completed() -> void:
	if _lifecycle == Lifecycle.FINAL_ACTIVE:
		_lifecycle = Lifecycle.FREE_PRACTICE
		_dispose_evaluator()
		presentation_changed.emit({"stage_number": 0, "rows": _free_practice_rows(), "completed": true, "prompt": "", "flinch": false})
		free_practice_entered.emit()
		return
	_lifecycle = Lifecycle.COMPLETED_WAITING_FOR_EXIT
	_emit_objective(true, false)
	stage_completed.emit(_active_descriptor.duplicate(true))


func _emit_objective(completed: bool, flinch: bool) -> void:
	var objective: Dictionary = _active_descriptor["objective"]
	presentation_changed.emit({
		"stage_number": _index + 1,
		"rows": _merge_rows(Dictionary(objective["presentation"])),
		"completed": completed,
		"prompt": "moving on ->" if completed else "",
		"flinch": flinch,
	})


func _merge_rows(presentation: Dictionary) -> Array:
	var row_state: Dictionary = _evaluator.get_row_state()
	var rows: Array = []
	for row_variant in presentation["rows"]:
		var row: Dictionary = Dictionary(row_variant).duplicate(true)
		var state: Dictionary = Dictionary(row_state.get(StringName(row["id"]), {}))
		row["progress"] = int(state.get("progress", 0))
		row["highlight_index"] = int(state.get("highlight_index", -1))
		row["completed"] = bool(state.get("completed", false))
		rows.append(row)
	return rows


func _free_practice_rows() -> Array:
	var presentation: Dictionary = _active_descriptor["free_practice_presentation"]
	var rows: Array = []
	for row_variant in presentation["rows"]:
		var row: Dictionary = Dictionary(row_variant).duplicate(true)
		row["progress"] = 0
		row["highlight_index"] = -1
		row["completed"] = true
		rows.append(row)
	return rows


func _create_evaluator(objective: Dictionary) -> ObjectiveEvaluator:
	match StringName(objective["type"]):
		&"sequence":
			return SequenceObjectiveEvaluatorScript.new()
		&"heat_threshold":
			return HeatThresholdEvaluatorScript.new()
		&"heat_guard_sequence":
			return HeatGuardSequenceEvaluatorScript.new()
		&"final_enemy":
			return FinalEnemyEvaluatorScript.new()
	push_error("Unsupported tutorial evaluator: %s" % objective["type"])
	return ObjectiveEvaluator.new()


func _dispose_evaluator() -> void:
	if _evaluator != null:
		_evaluator.queue_free()
		_evaluator = null
