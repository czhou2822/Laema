class_name HitReaction
extends Node

signal reaction_started(level: int, direction: Vector2, distance: float, duration: float)
signal reaction_ended

var _config: Dictionary = {}
var _remaining := 0.0
var _active := false


func configure(config: Dictionary) -> void:
	_config = config
	set_process(_active)


func execute(level: int, direction: Vector2) -> void:
	if level <= 0 or _config.is_empty():
		return
	var bounded_level := clampi(level, 1, 5)
	var distance := (
		float(_config["base_distance"])
		+ float(_config["distance_per_level"]) * float(bounded_level - 1)
	)
	var duration := (
		float(_config["base_duration"])
		+ float(_config["duration_per_level"]) * float(bounded_level - 1)
	)
	_active = true
	_remaining = duration
	set_process(true)
	reaction_started.emit(bounded_level, direction.normalized(), distance, duration)


func _process(delta: float) -> void:
	if not _active:
		return
	_remaining -= delta
	if _remaining > 0.0:
		return
	_active = false
	_remaining = 0.0
	set_process(false)
	reaction_ended.emit()


func is_active() -> bool:
	return _active
