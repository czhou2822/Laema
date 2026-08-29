class_name HeatComponent
extends Node

signal heat_changed(value: float, level: int, speed_multiplier: float)

var _config: Dictionary = {}
var _bonus_points := 0.0
var _reset_remaining := 0.0


func configure(config: Dictionary) -> void:
	_config = config
	_bonus_points = 0.0
	_reset_remaining = 0.0
	_emit_state()


func apply_runtime_tuning() -> void:
	_bonus_points = clampf(_bonus_points, 0.0, _maximum_bonus())
	_emit_state()


func _process(delta: float) -> void:
	if _reset_remaining <= 0.0:
		return
	_reset_remaining = maxf(_reset_remaining - delta, 0.0)
	if _reset_remaining <= 0.0 and _bonus_points > 0.0:
		_bonus_points = 0.0
		_emit_state()


func gain_from_commit(consumed_count: int) -> void:
	if consumed_count <= 0:
		return
	_bonus_points = minf(
		_bonus_points + float(consumed_count) * float(_config["attack_speed_gain_per_orb"]),
		_maximum_bonus()
	)
	_reset_remaining = float(_config["heat_reset_timer"])
	_emit_state()


func remove_for_player_hit() -> void:
	_apply_loss(float(_config["attack_speed_loss_per_hit"]))


func drain(amount: float) -> void:
	_apply_loss(amount)


func get_speed_multiplier() -> float:
	return 1.0 + _bonus_points / 100.0


func get_value() -> float:
	return 100.0 + _bonus_points


func get_level() -> int:
	return 0


func _apply_loss(amount: float) -> void:
	if amount <= 0.0 or _bonus_points <= 0.0:
		return
	_bonus_points = maxf(_bonus_points - amount, 0.0)
	_emit_state()


func _maximum_bonus() -> float:
	return float(_config["max_attack_speed_percent"]) - 100.0


func _emit_state() -> void:
	heat_changed.emit(get_value(), 0, get_speed_multiplier())
