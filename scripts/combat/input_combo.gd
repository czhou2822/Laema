extends Node

signal sequence_changed(tokens: Array)
signal combo_completed(tokens: Array)
signal combo_reset

const MAX_LIGHT_ATTACKS := 5

var _tokens: Array[Dictionary] = []
var _x_schools: Array[StringName] = []
var _switch_count := 0
var _active := false


func is_active() -> bool:
	return _active


func light_count() -> int:
	return _x_schools.size()


func accept_light(school: StringName) -> bool:
	if _x_schools.size() >= MAX_LIGHT_ATTACKS:
		return false
	_active = true
	_x_schools.append(school)
	_tokens.append({"input": &"X", "school": school})
	sequence_changed.emit(_tokens.duplicate(true))
	return true


func accept_switch(from_school: StringName, to_school: StringName) -> bool:
	if not _active or from_school == to_school or _switch_count >= 1:
		return false
	_switch_count += 1
	return true


func accept_finisher(finishing_school: StringName) -> Dictionary:
	if not _active or _x_schools.is_empty():
		return {"valid": false}

	_tokens.append({"input": &"Y", "school": finishing_school})
	sequence_changed.emit(_tokens.duplicate(true))

	var full_level := _x_schools.size()
	var earlier_school: StringName = &""
	for school in _x_schools:
		if school != finishing_school:
			earlier_school = school
			break

	var secondary: Dictionary = {}
	var secondary_level := full_level - 2
	if earlier_school != &"" and secondary_level >= 1:
		secondary = {
			"school": earlier_school,
			"level": secondary_level,
		}

	return {
		"valid": true,
		"primary": {
			"school": finishing_school,
			"level": full_level,
		},
		"secondary": secondary,
	}


func complete() -> void:
	if not _active:
		return
	combo_completed.emit(_tokens.duplicate(true))
	_clear()


func timeout_reset() -> void:
	if not _active:
		return
	_clear()
	combo_reset.emit()


func _clear() -> void:
	_tokens.clear()
	_x_schools.clear()
	_switch_count = 0
	_active = false
