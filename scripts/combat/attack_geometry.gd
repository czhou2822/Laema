@tool
extends RefCounted
## Native Animation tracks own melee geometry. JSON carries active-start value mirrors.

const DIRECTORY := "res://config/attack_animations/"
const POSITION := NodePath("AttackCast:position")
const TARGET := NodePath("AttackCast:target_position")
const RADIUS := NodePath("AttackCast:shape:radius")


static func move_ids() -> Array[String]:
	var ids: Array[String] = []
	for school in ["fire", "water", "air", "earth"]:
		for index in range(1, 6):
			ids.append("%s_x%d" % [school, index])
	ids.append("melee_swing")
	return ids


static func load_clock(id: String) -> Animation:
	# Reload this data resource only; never reload live Script dependencies.
	return ResourceLoader.load(DIRECTORY + id + ".tres", "", ResourceLoader.CACHE_MODE_IGNORE) as Animation


static func sample(clock: Animation, time: float) -> Dictionary:
	var pose: Dictionary = {}
	for pair in [[POSITION, "position"], [TARGET, "target"], [RADIUS, "radius"]]:
		var track := clock.find_track(pair[0], Animation.TYPE_VALUE)
		if track < 0 or not clock.track_is_enabled(track) or clock.track_get_key_count(track) == 0:
			return {}
		pose[pair[1]] = clock.value_track_interpolate(track, time)
	return pose


static func valid(pose: Dictionary) -> bool:
	return pose.get("position") is Vector2 and Vector2(pose["position"]).is_finite() \
		and pose.get("target") is Vector2 and Vector2(pose["target"]).is_finite() \
		and is_finite(float(pose.get("radius", -1.0))) and float(pose.get("radius", -1.0)) > 0.0


static func active_start(clock: Animation) -> Dictionary:
	if clock == null or not clock.has_marker(&"active_start"):
		return {}
	return sample(clock, clock.get_marker_time(&"active_start"))


static func read_config(config: Dictionary) -> Dictionary:
	for id in move_ids() + ["cast_fire", "cast_water", "cast_air", "cast_earth", "attack_clock"]:
		var clock := load_clock(id)
		var error := validate_clock(clock, id.begins_with("cast_") or id == "attack_clock")
		if not error.is_empty():
			return {"ok": false, "error": "%s: %s" % [id, error]}
	for id in move_ids():
		var pose := active_start(load_clock(id))
		if not valid(pose):
			return {"ok": false, "error": "Invalid active-window geometry in %s%s.tres. Keep enabled position, target_position and shape:radius value tracks and active_start/active_end markers." % [DIRECTORY, id]}
		var values: Dictionary = config["enemy_ai"] if id == "melee_swing" else config["moves"][id]
		values["hitbox_reach" if id == "melee_swing" else "shape_reach"] = Vector2(pose["target"]).length()
		values["hitbox_radius" if id == "melee_swing" else "shape_radius"] = float(pose["radius"])
	return {"ok": true, "error": ""}


static func set_active_size(clock: Animation, reach: float, radius: float) -> void:
	var pose := active_start(clock)
	var target: Vector2 = pose["target"]
	if target.is_zero_approx():
		target = Vector2.RIGHT
	var time := clock.get_marker_time(&"active_start")
	# Touch only changed active-start keys; preserve all other frames, offsets and angles.
	if not is_equal_approx(Vector2(pose["target"]).length(), reach):
		clock.track_insert_key(clock.find_track(TARGET, Animation.TYPE_VALUE), time, target.normalized() * reach)
	if not is_equal_approx(float(pose["radius"]), radius):
		clock.track_insert_key(clock.find_track(RADIUS, Animation.TYPE_VALUE), time, radius)


static func validate_sizes(config: Dictionary) -> Dictionary:
	for id in move_ids():
		var values: Dictionary = config["enemy_ai"] if id == "melee_swing" else config["moves"][id]
		var radius := float(values["hitbox_radius" if id == "melee_swing" else "shape_radius"])
		if not is_finite(radius) or radius <= 0.0:
			return {"ok": false, "error": "%s active-start radius must be greater than zero." % id}
	return {"ok": true, "error": ""}


static func save_changes(before: Dictionary, after: Dictionary) -> Dictionary:
	for id in move_ids():
		var old_values: Dictionary = before["enemy_ai"] if id == "melee_swing" else before["moves"][id]
		var values: Dictionary = after["enemy_ai"] if id == "melee_swing" else after["moves"][id]
		var reach_key := "hitbox_reach" if id == "melee_swing" else "shape_reach"
		var radius_key := "hitbox_radius" if id == "melee_swing" else "shape_radius"
		if old_values[reach_key] == values[reach_key] and old_values[radius_key] == values[radius_key]:
			continue
		var path := DIRECTORY + id + ".tres"
		var clock := load_clock(id)
		if not valid(active_start(clock)):
			return {"ok": false, "error": "Cannot save invalid animation geometry: " + path}
		# A Portal draft must not overwrite a newer native animation edit.
		var pose := active_start(clock)
		if not is_equal_approx(Vector2(pose["target"]).length(), float(old_values[reach_key])) or not is_equal_approx(float(pose["radius"]), float(old_values[radius_key])):
			return {"ok": false, "error": "Animation changed while saving. Reload before saving: " + path}
		set_active_size(clock, float(values[reach_key]), float(values[radius_key]))
		var error := ResourceSaver.save(clock, path)
		if error != OK:
			return {"ok": false, "error": "Cannot save %s: %s" % [path, error_string(error)]}
	return {"ok": true, "error": ""}


static func make_private(player: AnimationPlayer) -> void:
	var source := player.get_animation_library(&"")
	var library := AnimationLibrary.new()
	for id in source.get_animation_list():
		# A saved Portal/native edit may be newer than the scene's cached reference.
		var animation := load_clock(str(id)) if FileAccess.file_exists(DIRECTORY + str(id) + ".tres") else source.get_animation(id)
		library.add_animation(id, animation.duplicate())
	player.remove_animation_library(&"")
	player.add_animation_library(&"", library)


static func apply_player_preview(player: AnimationPlayer, config: Dictionary) -> void:
	for id in move_ids():
		if id == "melee_swing":
			continue
		var values: Dictionary = config["moves"][id]
		var reach := float(values["shape_reach"])
		var radius := float(values["shape_radius"])
		# Legacy custom JSON profiles may omit both fields. Native zero-length casts
		# are valid point queries and must remain zero when a radius is authored.
		if radius <= 0.0:
			radius = float(config["combat"]["shape_radius"])
			if reach <= 0.0:
				reach = float(config["combat"]["shape_reach"])
		set_active_size(player.get_animation(id), reach, radius)


static func facing_pose(pose: Dictionary, direction: Vector2) -> Dictionary:
	var result := pose.duplicate()
	var facing := -1.0 if direction.x < 0.0 else 1.0
	result["position"] = Vector2(Vector2(pose["position"]).x * facing, Vector2(pose["position"]).y)
	result["target"] = Vector2(Vector2(pose["target"]).x * facing, Vector2(pose["target"]).y)
	return result



static func validate_clock(clock: Animation, casting: bool) -> String:
	if clock == null or clock.length <= 0.0:
		return "Missing or empty native Animation."
	for marker in [&"active_start", &"active_end"]:
		if not clock.has_marker(marker):
			return "Missing marker: %s" % marker
	var start := clock.get_marker_time(&"active_start")
	var end := clock.get_marker_time(&"active_end")
	if start < 0.0 or start >= end or end > clock.length:
		return "Require 0 <= active_start < active_end <= length."
	if clock.has_marker(&"contact"):
		return "Retired contact marker: use active markers for melee or launch for Cast."
	if casting:
		if not clock.has_marker(&"launch") or clock.get_marker_time(&"launch") < 0.0 or clock.get_marker_time(&"launch") > clock.length:
			return "Cast requires one launch marker inside the Animation."
		return ""
	if clock.has_marker(&"timing_split") and (clock.get_marker_time(&"timing_split") <= 0.0 or clock.get_marker_time(&"timing_split") >= clock.length):
		return "Optional pacing-only timing_split must be inside the Animation."
	var times: Array[float] = [start, end]
	for path in [POSITION, TARGET, RADIUS]:
		var track := clock.find_track(path, Animation.TYPE_VALUE)
		if track < 0:
			return "Missing animated hitbox track: %s" % path
		for key in range(clock.track_get_key_count(track)):
			var time := clock.track_get_key_time(track, key)
			if time >= start and time <= end:
				times.append(time)
	for time in times:
		if not valid(sample(clock, time)):
			return "Invalid geometry inside active window."
	return ""


static func step_limit(clock: Animation, time: float, speed: float, limit: float) -> float:
	if speed <= 0.0:
		return limit
	var next := time + limit * speed
	for marker in clock.get_marker_names():
		var boundary := clock.get_marker_time(marker)
		if boundary > time + 0.0000001:
			next = minf(next, boundary)
	for track in range(clock.get_track_count()):
		for key in range(clock.track_get_key_count(track)):
			var boundary := clock.track_get_key_time(track, key)
			if boundary > time + 0.0000001:
				next = minf(next, boundary)
	return minf(limit, maxf((next - time) / speed, 0.0000001))
