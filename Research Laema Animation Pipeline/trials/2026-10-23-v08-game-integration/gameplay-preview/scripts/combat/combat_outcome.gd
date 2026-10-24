class_name CombatOutcome
extends RefCounted

var _kind: StringName
var _facts: Dictionary


static func create(outcome_kind: StringName, source_facts: Dictionary = {}) -> CombatOutcome:
	var outcome := CombatOutcome.new()
	outcome._kind = outcome_kind
	outcome._facts = source_facts.duplicate(true)
	return outcome


func get_kind() -> StringName:
	return _kind


func get_fact(key: StringName, fallback = null):
	return _facts.get(key, fallback)


func snapshot() -> Dictionary:
	var result := _facts.duplicate(true)
	result["kind"] = _kind
	return result
