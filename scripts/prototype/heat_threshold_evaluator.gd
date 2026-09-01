class_name HeatThresholdEvaluator
extends ObjectiveEvaluator

var _threshold := 80.0
var _completed := false

func configure(objective: Dictionary) -> void:
	_threshold = float(objective["threshold"])
	_completed = false

func consume_heat(value: float, _level: int, _speed_multiplier: float) -> Dictionary:
	if not _completed and value > _threshold:
		_completed = true
		return {"kind": &"completed", "progress": 0}
	return {"kind": &"unchanged"}
