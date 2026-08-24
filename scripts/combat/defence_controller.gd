class_name DefenceController
extends Node

signal guard_changed(current_value: float, maximum_value: float)
signal guard_warning
signal guard_broken
signal parry_window_changed(active: bool)

enum Mode {
	NONE,
	BLOCK,
	PARRY,
}

var _config: Dictionary = {}
var _mode := Mode.NONE
var _holding := false
var _active := false
var _rearm_required := false
var _guard := 0.0
var _parry_remaining := 0.0
var _warning_sent := false


func configure(config: Dictionary) -> void:
	_config = config
	_guard = float(_config["guard_capacity"])
	guard_changed.emit(_guard, float(_config["guard_capacity"]))


func begin(school: StringName) -> bool:
	if _config.is_empty() or _holding or _rearm_required:
		return false
	if school == &"water":
		_mode = Mode.BLOCK
		_guard = float(_config["guard_capacity"])
		_warning_sent = false
	elif school == &"fire":
		_mode = Mode.PARRY
		_parry_remaining = float(_config["parry_window"])
		parry_window_changed.emit(true)
	else:
		return false
	_holding = true
	_active = true
	guard_changed.emit(_guard, float(_config["guard_capacity"]))
	return true


func update(delta: float, heat_controller) -> void:
	if not _holding:
		return
	if _mode == Mode.BLOCK and _active:
		heat_controller.drain(float(_config["heat_drain_per_second"]) * delta)
	elif _mode == Mode.PARRY and _active:
		_parry_remaining -= delta
		if _parry_remaining <= 0.0:
			_active = false
			parry_window_changed.emit(false)


func intercept(event: HealthEvent) -> int:
	if not _holding or not _active:
		return HealthResult.Outcome.APPLIED
	if _mode == Mode.PARRY:
		_active = false
		_rearm_required = true
		parry_window_changed.emit(false)
		return HealthResult.Outcome.PARRIED
	if _mode == Mode.BLOCK:
		_guard = maxf(
			_guard - event.amount * float(_config["blocked_damage_to_guard"]),
			0.0
		)
		guard_changed.emit(_guard, float(_config["guard_capacity"]))
		var ratio := _guard / float(_config["guard_capacity"])
		if not _warning_sent and ratio <= float(_config["guard_warning_ratio"]):
			_warning_sent = true
			guard_warning.emit()
		if _guard <= 0.0:
			_active = false
			_rearm_required = true
			guard_broken.emit()
		return HealthResult.Outcome.BLOCKED
	return HealthResult.Outcome.APPLIED


func end_hold() -> void:
	if _mode == Mode.PARRY and _active:
		parry_window_changed.emit(false)
	_holding = false
	_active = false
	_rearm_required = false
	_mode = Mode.NONE
	_parry_remaining = 0.0


func force_cancel() -> void:
	end_hold()


func get_defensive_level() -> int:
	if _mode == Mode.BLOCK and _holding and _active:
		return int(_config["water_block_defensive_level"])
	return 0


func is_holding() -> bool:
	return _holding


func get_guard() -> float:
	return _guard


func get_guard_break_recovery() -> float:
	return float(_config["guard_break_recovery"])
