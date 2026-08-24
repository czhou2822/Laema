class_name HealthComponent
extends Node

signal health_changed(current_value: float, maximum_value: float)

var _maximum := 1.0
var _current := 1.0


func configure(maximum_value: float) -> void:
	_maximum = maxf(maximum_value, 0.001)
	_current = _maximum
	_emit_state()


func set_maximum(maximum_value: float) -> void:
	_maximum = maxf(maximum_value, 0.001)
	_current = minf(_current, _maximum)
	_emit_state()


func apply_damage(amount: float) -> float:
	var removed := minf(maxf(amount, 0.0), _current)
	_current -= removed
	_emit_state()
	return -removed


func reset_to_maximum() -> void:
	_current = _maximum
	_emit_state()


func is_zero() -> bool:
	return _current <= 0.0


func get_current() -> float:
	return _current


func get_maximum() -> float:
	return _maximum


func _emit_state() -> void:
	health_changed.emit(_current, _maximum)
