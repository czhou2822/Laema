class_name HitReaction
extends Node

const ImpactProbe = preload("res://scripts/debug/impact_probe.gd")
const ReactionRanges = preload("res://scripts/config/combat_reaction_ranges.gd")

signal reaction_started(level: int, direction: Vector2, distance: float, duration: float)
signal reaction_ended

var _config: Dictionary = {}
var _remaining := 0.0
var _active := false
var _combat_reaction := false
var _push_velocity := Vector2.ZERO


func configure(config: Dictionary) -> void:
	_config = config
	set_process(_active and not _combat_reaction)


static func level_from_difference(difference: int, levels: Array) -> int:
	return ReactionRanges.level_for_value(difference, levels)


func level_for_value(value: int) -> int:
	return level_from_difference(value, _config["combat_levels"])


func execute_combat(difference: int, direction: Vector2, push_scale: float = 1.0) -> void:
	execute_captured_combat(capture_combat(difference, direction, push_scale))


func capture_combat(difference: int, direction: Vector2, push_scale: float = 1.0) -> Dictionary:
	var level := level_for_value(difference)
	var tuning: Dictionary = _config["combat_levels"][level - 1]
	return {"difference": difference, "level": level, "direction": direction.normalized(),
		"duration": float(tuning["duration"]), "distance": float(tuning["distance"]) * maxf(push_scale, 0.0)}


func execute_captured_combat(reaction: Dictionary) -> void:
	var difference := int(reaction["difference"])
	if is_invincible():
		ImpactProbe.record("reaction_skipped", {"target": str(get_parent().get_path()), "difference": difference, "reason": "already_invincible"})
		return
	var level := int(reaction["level"])
	var duration := float(reaction["duration"])
	var distance := float(reaction["distance"])
	var direction: Vector2 = reaction["direction"]
	ImpactProbe.record("reaction_started", {"target": str(get_parent().get_path()), "difference": difference, "reaction_level": level, "duration": duration, "distance": distance})
	_active = true
	_combat_reaction = true
	_remaining = duration
	_push_velocity = direction.normalized() * distance / duration
	set_process(false)
	reaction_started.emit(level, direction.normalized(), distance, duration)


func execute(level: int, direction: Vector2) -> void:
	# Failed Cast and the retained practice/defence reactions grant no invincibility.
	if level <= 0 or _config.is_empty() or is_invincible():
		return
	var bounded_level := clampi(level, 1, 5)
	var distance := float(_config["base_distance"]) + float(_config["distance_per_level"]) * float(bounded_level - 1)
	var duration := float(_config["base_duration"]) + float(_config["duration_per_level"]) * float(bounded_level - 1)
	_active = true
	_combat_reaction = false
	_remaining = duration
	_push_velocity = Vector2.ZERO
	set_process(true)
	reaction_started.emit(bounded_level, direction.normalized(), distance, duration)


func consume_body_motion(delta: float) -> Vector2:
	# The body's existing physics owner calls this once before its collision movement.
	if not _active or not _combat_reaction:
		return Vector2.ZERO
	var step := minf(delta, _remaining)
	var displacement := _push_velocity * step
	_remaining = maxf(_remaining - step, 0.0)
	return displacement


func finish_body_motion() -> void:
	# End only after the final collision-aware displacement has been applied.
	if _active and _combat_reaction and _remaining <= 0.0:
		_finish()


func _process(delta: float) -> void:
	if not _active or _combat_reaction:
		return
	_remaining -= delta
	if _remaining <= 0.0:
		_finish()


func _finish() -> void:
	_active = false
	_combat_reaction = false
	_remaining = 0.0
	_push_velocity = Vector2.ZERO
	set_process(false)
	reaction_ended.emit()


func is_active() -> bool:
	return _active


func is_invincible() -> bool:
	return _active and _combat_reaction


func reset_for_stage() -> void:
	_active = false
	_combat_reaction = false
	_remaining = 0.0
	_push_velocity = Vector2.ZERO
	set_process(false)
