@tool
class_name AttackStyle
extends RefCounted
## Per-X pacing and attacker lunge. Native Animation curves alone own geometry.

const DEFAULTS := {
	"windup_duration": 0.0, "recovery_duration": 0.0,
}
const LUNGE_DEFAULTS := {"distance": 0.0, "start_phase": 0.0, "end_phase": 0.5}
# Migration keys only: no retained controls, capture fields or runtime overrides.
const RETIRED_FIELDS := ["shape_reach", "shape_radius", "push_scale", "push_motion_duration"]


static func strip_retired_fields(config: Dictionary) -> void:
	if config.get("combat") is Dictionary:
		config["combat"].erase("shape_reach")
		config["combat"].erase("shape_radius")
	if not config.get("moves") is Dictionary:
		return
	for school in ["fire", "water", "air", "earth"]:
		for position in range(1, 6):
			var id := "%s_x%d" % [school, position]
			if config["moves"].get(id) is Dictionary:
				for key in RETIRED_FIELDS:
					config["moves"][id].erase(key)


static func read_move(move: Dictionary) -> Dictionary:
	var result := DEFAULTS.duplicate()
	for key in DEFAULTS:
		result[key] = move.get(key, DEFAULTS[key])
	result["forward_lunge"] = move["forward_lunge"].duplicate(true) if move.get("forward_lunge") is Dictionary else LUNGE_DEFAULTS.duplicate()
	return result


static func capture(move: Dictionary, combat: Dictionary) -> Dictionary:
	var result := read_move(move)
	result["shared_duration"] = float(combat["attack_duration"])
	return result


static func phase_speed(clock: Animation, profile: Dictionary, time: float, heat_speed: float) -> float:
	if profile.is_empty():
		return heat_speed * clock.length / float(profile.get("shared_duration", 0.8))
	var split := clock.get_marker_time(&"timing_split") if clock.has_marker(&"timing_split") else clock.get_marker_time(&"active_start")
	var before_split := time < split
	var span := split if before_split else clock.length - split
	var duration := float(profile["windup_duration"] if before_split else profile["recovery_duration"])
	if duration <= 0.0:
		duration = float(profile["shared_duration"]) * span / clock.length
	return heat_speed * span / maxf(duration, 0.000001)


static func predict_time(clock: Animation, profile: Dictionary, time: float, delta: float, heat_speed: float) -> float:
	var split := clock.get_marker_time(&"timing_split") if clock.has_marker(&"timing_split") else clock.get_marker_time(&"active_start")
	var remaining := maxf(delta, 0.0)
	var position := time
	if position < split:
		var speed := phase_speed(clock, profile, position, heat_speed)
		if speed <= 0.0:
			return position
		var step := minf(remaining, (split - position) / speed)
		position = minf(position + step * speed, split)
		remaining -= step
	return minf(position + remaining * phase_speed(clock, profile, position, heat_speed), clock.length)


static func lunge_fraction(phase: float, lunge: Dictionary) -> float:
	return clampf((phase - float(lunge["start_phase"])) / (float(lunge["end_phase"]) - float(lunge["start_phase"])), 0.0, 1.0)
