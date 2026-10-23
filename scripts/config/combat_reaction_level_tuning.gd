@tool
class_name CombatReactionLevelTuning
extends Resource

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
