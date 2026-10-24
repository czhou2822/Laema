class_name HeatComponent
extends Node

signal heat_changed(value: float, level: int, speed_multiplier: float)

var _config: Dictionary = {}
var _value := 0.0
var _reset_remaining := 0.0

func configure(config: Dictionary) -> void:
	_config = config
	reset_for_stage()

func apply_runtime_tuning() -> void:
	_value = clampf(_value, 0.0, _maximum())
	_emit_state()

func _process(delta: float) -> void:
	if _value <= 0.0:
		return
	if _reset_remaining > 0.0:
		_reset_remaining = maxf(_reset_remaining - delta, 0.0)
		return
	_value = maxf(_value - float(_config["depletion_per_second"]) * delta, 0.0)
	_emit_state()

func gain_from_commit(consumed_count: int) -> void:
	if consumed_count <= 0:
		return
	_value = minf(_value + float(consumed_count) * float(_config["gain_per_charged_orb"]), _maximum())
	_reset_remaining = float(_config["reset_timer"])
	_emit_state()

func refresh_from_landed_direct_hit() -> void:
	_reset_remaining = float(_config["reset_timer"])
	_emit_state()

func remove_for_player_hit() -> void:
	_apply_loss(float(_config["loss_per_direct_hit"]))

func drain(amount: float) -> void:
	_apply_loss(amount)

func get_speed_multiplier() -> float:
	return 1.0 + 0.5 * _value / _maximum()

func get_value() -> float:
	return _value

func get_level() -> int:
	return 0

func reset_for_stage() -> void:
	_value = 0.0
	_reset_remaining = 0.0
	_emit_state()

func _apply_loss(amount: float) -> void:
	if amount <= 0.0:
		return
	_value = maxf(_value - amount, 0.0)
	_emit_state()

func _maximum() -> float:
	return float(_config["max_heat"])

func _emit_state() -> void:
	if not _config.is_empty():
		heat_changed.emit(_value, 0, get_speed_multiplier())
