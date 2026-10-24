@tool
class_name CombatReactionLevelTuning
extends Resource

# Provisional starting pairs: viewport pixels and seconds, indexed by reaction level.
const CAMERA_DEFAULTS := [Vector2(0.5, 0.04), Vector2(1.0, 0.06),
	Vector2(1.5, 0.08), Vector2(2.0, 0.10), Vector2(3.0, 0.12)]

@export_range(0, 2147483647, 1) var minimum_value := 0:
	set(value):
		minimum_value = value
		emit_changed()

## Stun lifetime in seconds: hurt animation, control lock and invulnerability.
## Independent from shove motion time; the existing Enemy post-reaction wait is separate.
@export_range(0.001, 60.0, 0.01, "or_greater") var duration := 0.3:
	set(value):
		duration = value
		emit_changed()

## Seconds used to deliver the shared distance uniformly through collision movement.
## Capped at Duration; a shorter shove does not end stun or invulnerability early.
@export_range(0.001, 60.0, 0.01, "or_greater") var motion_duration := 0.3:
	set(value):
		motion_duration = value
		emit_changed()

## Total victim-body displacement in pixels. Walls consume blocked motion.
## No Player X move multiplies this value.
@export_range(0.0, 1000.0, 1.0, "or_greater") var distance := 5.0:
	set(value):
		distance = value
		emit_changed()

@export_group("Camera shake")
## Viewport-pixel amplitude for this resolved reaction level. No level multiplier.
## Cosmetic only; the global camera switch still controls whether it plays.
@export_range(0.0, 3.0, 0.05) var camera_strength := 0.5:
	set(value):
		camera_strength = value
		emit_changed()

## Shake duration in seconds, independent of victim motion and stun.
@export_range(0.001, 0.12, 0.001) var camera_duration := 0.04:
	set(value):
		camera_duration = value
		emit_changed()


func get_data() -> Dictionary:
	return {"minimum_value": minimum_value, "duration": duration,
		"motion_duration": motion_duration, "distance": distance,
		"camera_strength": camera_strength, "camera_duration": camera_duration}


func read_camera_data(data: Dictionary, index: int) -> void:
	# Missing old-format fields gain presets; explicit authored values always win.
	var defaults: Vector2 = CAMERA_DEFAULTS[index]
	camera_strength = float(data.get("camera_strength", defaults.x))
	camera_duration = float(data.get("camera_duration", defaults.y))
