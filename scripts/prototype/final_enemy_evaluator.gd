class_name FinalEnemyEvaluator
extends ObjectiveEvaluator

var _encounter_id := &"final_enemy"
var _completed := false


func configure(objective: Dictionary) -> void:
	_encounter_id = StringName(objective["encounter_id"])
	_completed = false


func consume_outcome(outcome: Dictionary) -> Dictionary:
	if _completed:
		return {"kind": &"unchanged"}
	if StringName(outcome.get("kind", &"")) != &"final_enemy_defeated":
		return {"kind": &"unchanged"}
	if StringName(outcome.get("encounter_id", &"")) != _encounter_id:
		return {"kind": &"unchanged"}
	_completed = true
	return {"kind": &"completed"}
