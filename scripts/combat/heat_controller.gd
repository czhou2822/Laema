class_name HeatComponent
extends Node

signal heat_changed(value: float, level: int, speed_multiplier: float)

var _config: Dictionary = {}
var _value := 0.0
var _time_since_contact := 0.0
var _has_contact := false
var _level := 0
var _speed_multiplier := 1.0


func configure(config: Dictionary) -> void:
	_config = config
	_value = 0.0
	_time_since_contact = 0.0
	_has_contact = false
	_recalculate_level()
	_emit_state()


func apply_runtime_tuning() -> void:
	if _config.is_empty():
		return
	_value = minf(_value, float(_config["max_value"]))
	_recalculate_level()
	_emit_state()


func _process(delta: float) -> void:
	if _config.is_empty() or not _has_contact or _value <= 0.0:
		return
	_time_since_contact += delta
	if _time_since_contact >= float(_config["inactivity_grace"]):
		_value = 0.0
		_time_since_contact = 0.0
		_has_contact = false
		_recalculate_level()
		_emit_state()
		_trace(&"expired", {"value": _value, "level": _level})


func add_direct_hit() -> void:
	if _config.is_empty():
		return
	_value = minf(_value + float(_config["gain_per_hit"]), float(_config["max_value"]))
	_time_since_contact = 0.0
	_has_contact = true
	_recalculate_level()
	_emit_state()
	_trace(&"direct_hit", {"value": _value, "level": _level, "speed_multiplier": _speed_multiplier})


func drain(amount: float) -> void:
	if _config.is_empty() or amount <= 0.0 or _value <= 0.0:
		return
	_value = maxf(_value - amount, 0.0)
	if _value <= 0.0:
		_has_contact = false
		_time_since_contact = 0.0
	_recalculate_level()
	_emit_state()


func get_speed_multiplier() -> float:
	return _speed_multiplier


func get_value() -> float:
	return _value


func get_level() -> int:
	return _level


func _recalculate_level() -> void:
	if _config.is_empty():
		_level = 0
		_speed_multiplier = 1.0
		return
	var fill_ratio := _value / float(_config["max_value"])
	var levels: Array = _config["levels"]
	_level = 0
	_speed_multiplier = float(levels[0]["speed_multiplier"])
	for index in range(levels.size()):
		if fill_ratio >= float(levels[index]["fill_ratio"]):
			_level = index
			_speed_multiplier = float(levels[index]["speed_multiplier"])


func _emit_state() -> void:
	heat_changed.emit(_value, _level, _speed_multiplier)


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][HEAT] %s %s" % [event_name, data])
