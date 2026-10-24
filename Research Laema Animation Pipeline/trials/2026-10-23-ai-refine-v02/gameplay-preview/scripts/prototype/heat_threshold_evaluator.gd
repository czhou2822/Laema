class_name HeatThresholdEvaluator
extends ObjectiveEvaluator

var _threshold := 80.0
var _completed := false
var _row_id := &""

func configure(objective: Dictionary) -> void:
	_threshold = float(objective["threshold"])
	_completed = false
	var presentation: Dictionary = objective["presentation"]
	var rows: Array = presentation["rows"]
	_row_id = StringName(rows[0]["id"])


func get_row_state() -> Dictionary:
	return {_row_id: {"completed": _completed}}

func consume_heat(value: float, _level: int, _speed_multiplier: float) -> Dictionary:
	if not _completed and value > _threshold:
		_completed = true
		return {"kind": &"completed", "progress": 0}
	return {"kind": &"unchanged"}
