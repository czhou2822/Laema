class_name StageDirector
extends Node

const CombatOutcomeResource = preload("res://scripts/combat/combat_outcome.gd")

signal objective_changed(objective: Dictionary)
signal tutorial_completed
signal feedback_requested(text: String)

var _objectives: Array[Dictionary] = []
var _failure_feedback := "No"
var _index := 0
var _completed := false


func configure(tutorial_data: Dictionary) -> void:
	_objectives.clear()
	for objective in tutorial_data["objectives"]:
		_objectives.append(Dictionary(objective).duplicate(true))
	_failure_feedback = str(tutorial_data["failure_feedback"])
	_index = 0
	_completed = false
	_emit_current_objective()


func consume_outcome(outcome) -> void:
	if _completed or _index >= _objectives.size() or not is_instance_of(outcome, CombatOutcomeResource):
		return
	var snapshot: Dictionary = outcome.snapshot()
	var objective := _objectives[_index]
	if _matches(snapshot, objective["success"]):
		_advance_for_success(snapshot)
		return
	for failure in objective["failures"]:
		if _matches(snapshot, failure):
			feedback_requested.emit(str(failure.get("feedback", _failure_feedback)))
			return


func _advance_for_success(snapshot: Dictionary) -> void:
	if _index == _objectives.size() - 1:
		if StringName(snapshot["kind"]) != &"final_enemy_defeated":
			return
		_completed = true
		_index += 1
		tutorial_completed.emit()
		return
	_index += 1
	_emit_current_objective()


func _emit_current_objective() -> void:
	if _index >= _objectives.size():
		return
	objective_changed.emit(_objectives[_index].duplicate(true))


func _matches(snapshot: Dictionary, rule: Dictionary) -> bool:
	if StringName(snapshot.get("kind", &"")) != StringName(rule["kind"]):
		return false
	var required_facts: Dictionary = rule["facts"]
	for key in required_facts:
		if not snapshot.has(key) or snapshot[key] != required_facts[key]:
			return false
	return true
