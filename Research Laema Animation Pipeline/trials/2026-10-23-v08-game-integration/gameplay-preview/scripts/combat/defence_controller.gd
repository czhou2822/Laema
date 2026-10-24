class_name DefenceController
extends Node

signal guard_changed(current_value: float, maximum_value: float)
signal guard_warning
signal guard_broken
signal parry_window_changed(active: bool)
signal fire_state_changed

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
var _warning_sent := false
# Fire captures its profile on press; tuning affects the next attempt.
var _fire_settings: Dictionary = {}
var _fire_elapsed := 0.0
var _fire_parry_until := 0.0
var _fire_control_until := 0.0
var _fire_reuse_remaining := 0.0
var _fire_tap_committed := false
var _fire_succeeded := false


func configure(config: Dictionary) -> void:
	_config = config
	_guard = float(_config["guard_capacity"])
	guard_changed.emit(_guard, float(_config["guard_capacity"]))


func can_begin(school: StringName) -> bool:
	if _config.is_empty() or _holding or _rearm_required or blocks_actions():
		return false
	if school == &"fire":
		return _fire_reuse_remaining <= 0.0
	return school == &"water"


func begin(school: StringName) -> bool:
	if not can_begin(school):
		return false
	_holding = true
	_active = true
	if school == &"water":
		_mode = Mode.BLOCK
		_guard = float(_config["guard_capacity"])
		_warning_sent = false
	else:
		_mode = Mode.PARRY
		_fire_settings = _config.duplicate(true)
		_fire_elapsed = 0.0
		_fire_parry_until = float(_fire_settings["parry_window"])
		_fire_control_until = 0.0
		_fire_tap_committed = false
		_fire_succeeded = false
		parry_window_changed.emit(true)
	guard_changed.emit(_guard, float(_config["guard_capacity"]))
	if is_fire_mode():
		fire_state_changed.emit()
	_trace(&"entered", {"mode": "block" if _mode == Mode.BLOCK else "parry", "guard": _guard})
	return true


func update(delta: float, heat_controller) -> void:
	var previous_reuse := _fire_reuse_remaining
	_fire_reuse_remaining = maxf(_fire_reuse_remaining - delta, 0.0)
	if is_fire_mode():
		var was_parrying := is_fire_parry_active()
		_fire_elapsed += delta
		if was_parrying and not is_fire_parry_active():
			parry_window_changed.emit(false)
			if _fire_tap_committed and not _fire_succeeded:
				# A large frame consumes the part of recovery already elapsed.
				_fire_reuse_remaining = maxf(float(_fire_settings["fire_miss_recovery"]) - (_fire_elapsed - _fire_parry_until), 0.0)
		if not _holding and not blocks_actions() and _fire_reuse_remaining <= 0.0 and (not _fire_succeeded or _fire_elapsed >= float(_fire_settings["fire_control_commitment"])):
			_mode = Mode.NONE
			_fire_tap_committed = false
			_active = false
		fire_state_changed.emit()
	elif _mode == Mode.BLOCK and _holding and _active:
		heat_controller.drain(float(_config["heat_drain_per_second"]) * delta)
	elif previous_reuse > 0.0 and _mode == Mode.NONE:
		fire_state_changed.emit()


func intercept(event: HealthEvent) -> int:
	if is_fire_mode():
		return _intercept_fire(event)
	if not _holding or not _active:
		return HealthResult.Outcome.APPLIED
	if _mode == Mode.BLOCK:
		_guard = maxf(_guard - event.amount * float(_config["blocked_damage_to_guard"]), 0.0)
		guard_changed.emit(_guard, float(_config["guard_capacity"]))
		var ratio := _guard / float(_config["guard_capacity"])
		if not _warning_sent and ratio <= float(_config["guard_warning_ratio"]):
			_warning_sent = true
			guard_warning.emit()
		if _guard <= 0.0:
			_active = false
			_rearm_required = true
			guard_broken.emit()
			_trace(&"guard_broken", {"incoming_amount": event.amount})
		else:
			_trace(&"blocked", {"incoming_amount": event.amount, "guard": _guard})
		return HealthResult.Outcome.BLOCKED
	return HealthResult.Outcome.APPLIED


func _intercept_fire(event: HealthEvent) -> int:
	if _fire_succeeded or not event.is_direct_damage() or not _is_facing(event):
		return HealthResult.Outcome.APPLIED
	if is_fire_parry_active():
		event.fire_defence = true
		_fire_succeeded = true
		_fire_tap_committed = false
		_active = false
		_rearm_required = _holding
		_fire_reuse_remaining = 0.0
		parry_window_changed.emit(false)
		fire_state_changed.emit()
		_trace(&"parried", {"incoming_amount": event.amount})
		return HealthResult.Outcome.PARRIED
	if _holding:
		event.fire_defence = true
		event.block_damage_multiplier = 1.0 - float(_fire_settings["fire_block_absorption"])
		return HealthResult.Outcome.BLOCKED
	return HealthResult.Outcome.APPLIED


func _is_facing(event: HealthEvent) -> bool:
	var receiver := event.target as Node2D
	if receiver == null or not receiver.has_method("get_facing_direction"):
		return false
	var facing: Vector2 = receiver.call("get_facing_direction")
	var source := event.instigator as Node2D
	if event.melee_contact and is_instance_valid(source):
		return (source.global_position.x < receiver.global_position.x) == (facing.x < 0.0)
	if not event.contact_direction.is_zero_approx():
		return -event.contact_direction.normalized().dot(facing) >= cos(PI * 0.4)
	return is_instance_valid(source) and (source.global_position.x < receiver.global_position.x) == (facing.x < 0.0)


func end_hold() -> void:
	if is_fire_mode():
		if not _holding:
			return
		var was_parrying := is_fire_parry_active()
		_holding = false
		_rearm_required = false
		if not _fire_succeeded and _fire_elapsed < float(_fire_settings["fire_tap_parry_window"]):
			_fire_tap_committed = true
			_fire_parry_until = float(_fire_settings["fire_tap_parry_window"])
			_fire_control_until = float(_fire_settings["fire_control_commitment"])
			if not was_parrying:
				parry_window_changed.emit(true)
		else:
			_mode = Mode.NONE
			_active = false
		fire_state_changed.emit()
		return
	_holding = false
	_active = false
	_rearm_required = false
	_mode = Mode.NONE


func force_cancel(clear_reuse := true) -> void:
	var was_fire := is_fire_mode()
	var was_parrying := is_fire_parry_active()
	_holding = false
	_active = false
	_rearm_required = false
	_mode = Mode.NONE
	_fire_settings = {}
	_fire_elapsed = 0.0
	_fire_parry_until = 0.0
	_fire_control_until = 0.0
	if clear_reuse:
		_fire_reuse_remaining = 0.0
	_fire_tap_committed = false
	_fire_succeeded = false
	if was_parrying:
		parry_window_changed.emit(false)
	if was_fire:
		fire_state_changed.emit()


func is_fire_mode() -> bool:
	return _mode == Mode.PARRY


func is_fire_parry_active() -> bool:
	return is_fire_mode() and not _fire_succeeded and (_holding or _fire_tap_committed) and _fire_elapsed < _fire_parry_until


func get_fire_visual_snapshot() -> Dictionary:
	# Presentation reads the captured attempt; it never advances or changes it.
	if not is_fire_mode():
		return {}
	return {
		"holding": _holding,
		"parrying": is_fire_parry_active(),
		"succeeded": _fire_succeeded,
		"elapsed": _fire_elapsed,
		"parry_until": _fire_parry_until,
		"control_until": _fire_control_until,
		"control_locked": blocks_actions(),
		"raise_duration": float(_fire_settings["parry_window"]),
	}


func blocks_actions() -> bool:
	if is_fire_mode():
		return not _fire_succeeded and (_holding or (_fire_tap_committed and _fire_elapsed < _fire_control_until))
	return _mode == Mode.BLOCK and _holding and _active


func fire_status() -> String:
	if _fire_succeeded and is_fire_mode():
		return "PARRIED - RELEASE R1" if _holding else "PARRIED"
	if is_fire_parry_active():
		return "PARRY %.2fs" % (_fire_parry_until - _fire_elapsed)
	if is_fire_mode() and _holding:
		return "BLOCK %.0f%%" % (float(_fire_settings["fire_block_absorption"]) * 100.0)
	if _fire_reuse_remaining > 0.0:
		return "PARRY RECOVERY %.2fs" % _fire_reuse_remaining
	if is_fire_mode() and blocks_actions():
		return "DEFENCE RECOVERY %.2fs" % (_fire_control_until - _fire_elapsed)
	return "READY"


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


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][DEFENCE] %s %s" % [event_name, data])
