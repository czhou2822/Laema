@tool
class_name MoveStyleTuning
extends Resource

const Style = preload("res://scripts/combat/attack_style.gd")

@export_group("Animation - scrub and edit in Player AnimationPlayer")
## Native Animation shared with Player/AnimationPlayer. Scrub and edit it there
## to author sprite frames, hitbox curves and active-window markers.
@export var animation: Animation

## Lookup key linking this style to its X move, for example fire_x5.
## Keep it matched to the assigned move; this is not a display name.
@export var move_id: StringName = &"":
	set(value):
		move_id = value
		emit_changed()
@export_group("Timing - seconds before Heat scaling")
## Playback seconds from animation start to timing_split (active_start if absent),
## before Heat scaling. Zero inherits this phase's share of the common duration.
@export_range(0.0, 5.0, 0.01, "or_greater") var windup_duration := 0.0:
	set(value):
		windup_duration = value
		emit_changed()
## Playback seconds from that pacing split to animation end, before Heat scaling.
## This can include active frames, not just recovery. Zero inherits shared timing.
@export_range(0.0, 5.0, 0.01, "or_greater") var recovery_duration := 0.0:
	set(value):
		recovery_duration = value
		emit_changed()
@export_group("Active geometry - animation active_start key, pixels")
## Hitbox target-vector length at active_start, in local pixels.
## Native Animation tracks own the full curve; edit other poses in AnimationPlayer.
@export_range(0.0, 400.0, 1.0, "or_greater") var shape_reach := 0.0:
	set(value):
		shape_reach = value
		emit_changed()
## Circle-query radius at active_start, in local pixels; larger means a wider hitbox.
## Native Animation tracks own the radius curve throughout the active window.
@export_range(0.001, 200.0, 1.0, "or_greater") var shape_radius := 0.001:
	set(value):
		shape_radius = value
		emit_changed()
@export_group("Forward body motion")
## Total attacker-body travel in pixels along the captured attack direction,
## between the lunge phases. Zero disables it; walls consume blocked motion.
@export_range(0.0, 400.0, 1.0, "or_greater") var lunge_distance := 0.0:
	set(value):
		lunge_distance = value
		emit_changed()
## When forward body travel begins: fraction of the full animation clock,
## from 0 (start) to 1 (end), not seconds. Must be below Lunge End Phase.
@export_range(0.0, 1.0, 0.01) var lunge_start_phase := 0.0:
	set(value):
		lunge_start_phase = value
		emit_changed()
## When the full lunge distance has been delivered: animation fraction 0 to 1.
## Must be above Lunge Start Phase; this does not set the attack hit window.
@export_range(0.0, 1.0, 0.01) var lunge_end_phase := 0.5:
	set(value):
		lunge_end_phase = value
		emit_changed()
@export_group("Qualifying hit reaction")
## Multiplies the defender's qualifying knockback distance: 2 means twice as far.
## Does not change damage, Impact/Poise, reaction lifetime or invulnerability.
## Stationary practice targets retain their separate legacy recoil.
@export_range(0.0, 5.0, 0.05, "or_greater") var push_scale := 1.0:
	set(value):
		push_scale = value
		emit_changed()
## Fire X5 only: seconds used to deliver the unchanged scaled knockback distance.
## Zero uses the full reaction lifetime; positive time is capped at that lifetime.
## Does not shorten hurt, control lock or invulnerability. Applies to the next X5.
@export_range(0.0, 5.0, 0.01, "or_greater") var push_motion_duration := 0.0:
	set(value):
		push_motion_duration = value
		emit_changed()


func get_data() -> Dictionary:
	return {
		"windup_duration": windup_duration, "recovery_duration": recovery_duration,
		"shape_reach": shape_reach, "shape_radius": shape_radius, "push_scale": push_scale,
		"push_motion_duration": push_motion_duration,
		"forward_lunge": {"distance": lunge_distance, "start_phase": lunge_start_phase, "end_phase": lunge_end_phase},
	}


func read_data(data: Dictionary) -> void:
	for key in Style.DEFAULTS:
		set(key, float(data[key]))
	lunge_distance = float(data["forward_lunge"]["distance"])
	lunge_start_phase = float(data["forward_lunge"]["start_phase"])
	lunge_end_phase = float(data["forward_lunge"]["end_phase"])
