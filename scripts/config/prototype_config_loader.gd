class_name PrototypeConfigLoader
extends RefCounted

const REQUIRED_SECTIONS := [
	"movement",
	"audio",
	"player",
	"enemy",
	"combat",
	"casting",
	"heat",
	"fire",
	"water",
	"air",
	"earth",
	"defence",
	"hit_reaction",
	"spell_loadout",
	"tutorial",
	"ui",
]


static func load_and_validate(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return _failure("Configuration file is missing: %s" % path)

	var json := JSON.new()
	var parse_error := json.parse(FileAccess.get_file_as_string(path))
	if parse_error != OK:
		return _failure(
			"Configuration parse error at line %d: %s"
			% [json.get_error_line(), json.get_error_message()]
		)

	if typeof(json.data) != TYPE_DICTIONARY:
		return _failure("Configuration root must be a JSON object.")

	var data: Dictionary = json.data
	var validation_error := _validate(data)
	if not validation_error.is_empty():
		return _failure(validation_error)

	return {
		"ok": true,
		"data": data.duplicate(true),
		"error": "",
	}


static func validate(data: Dictionary) -> Dictionary:
	var validation_error := _validate(data)
	if not validation_error.is_empty():
		return _failure(validation_error)
	return {
		"ok": true,
		"data": data.duplicate(true),
		"error": "",
	}


static func validate_and_save(path: String, data: Dictionary) -> Dictionary:
	var validation_error := _validate(data)
	if not validation_error.is_empty():
		return _failure(validation_error)

	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return _failure("Cannot save configuration: %s" % path)
	file.store_string(JSON.stringify(data, "\t") + "\n")
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return _failure("Cannot save configuration: %s" % error_string(write_error))

	return {
		"ok": true,
		"data": data.duplicate(true),
		"error": "",
	}


static func _validate(data: Dictionary) -> String:
	for section_name in REQUIRED_SECTIONS:
		if not data.has(section_name) or typeof(data[section_name]) != TYPE_DICTIONARY:
			return "Missing or invalid configuration section: %s" % section_name

	var checks := [
		["movement", "speed", 0.001, INF],
		["movement", "gravity_scale", 0.001, INF],
		["player", "max_health", 0.001, INF],
		["enemy", "max_health", 0.001, INF],
		["combat", "attack_duration", 0.001, INF],
		["combat", "hit_phase", 0.0, 1.0],
		["combat", "input_window_start", 0.0, 1.0],
		["combat", "x_buffer_width", 0.0, 1.0],
		["combat", "shape_radius", 0.001, INF],
		["combat", "shape_reach", 0.001, INF],
		["combat", "light_damage", 0.0, INF],
		["combat", "casting_damage", 0.0, INF],
		["casting", "orb_lifetime", 0.001, INF],
		["casting", "charge_step_duration", 0.001, INF],
		["casting", "trigger_deplete_max", 0.0, 1.0],
		["casting", "trigger_charge_center", 0.0, 1.0],
		["casting", "trigger_charge_half_width", 0.0, 0.5],
		["casting", "trigger_cast_min", 0.0, 1.0],
		["casting", "empowered_primary_multiplier", 0.001, INF],
		["casting", "projectile_screen_ratio", 0.001, 1.0],
		["casting", "projectile_travel_duration", 0.001, INF],
		["heat", "max_value", 0.001, INF],
		["heat", "gain_per_hit", 0.0, INF],
		["heat", "inactivity_grace", 0.0, INF],
		["fire", "dot_duration", 0.001, INF],
		["fire", "dot_tick_interval", 0.001, INF],
		["fire", "damage_per_stack", 0.0, INF],
		["fire", "visual_motion_exponent", 0.001, INF],
		["fire", "vfx_fps", 0.001, INF],
		["water", "base_radius", 0.001, INF],
		["water", "radius_per_level", 0.0, INF],
		["water", "visual_motion_exponent", 0.001, INF],
		["water", "vfx_fps", 0.001, INF],
		["air", "visual_motion_exponent", 0.001, INF],
		["air", "attack_speed_multiplier", 0.001, INF],
		["air", "buff_duration", 0.001, INF],
		["air", "chain_radius", 0.001, INF],
		["air", "damage_per_level", 0.0, INF],
		["earth", "base_radius", 0.001, INF],
		["earth", "radius_per_level", 0.0, INF],
		["earth", "visual_motion_exponent", 0.001, INF],
		["defence", "guard_capacity", 0.001, INF],
		["defence", "blocked_damage_to_guard", 0.0, INF],
		["defence", "guard_warning_ratio", 0.0, 1.0],
		["defence", "parry_window", 0.001, INF],
		["defence", "guard_break_recovery", 0.0, INF],
		["defence", "heat_drain_per_second", 0.0, INF],
		["hit_reaction", "base_distance", 0.0, INF],
		["hit_reaction", "distance_per_level", 0.0, INF],
		["hit_reaction", "base_duration", 0.001, INF],
		["hit_reaction", "duration_per_level", 0.0, INF],
		["ui", "completed_combo_display_duration", 0.0, INF],
	]

	for check in checks:
		var error := _validate_number(
			data,
			str(check[0]),
			str(check[1]),
			float(check[2]),
			float(check[3])
		)
		if not error.is_empty():
			return error

	var combat: Dictionary = data["combat"]
	if not combat.has("collect_orb_without_contact") or typeof(combat["collect_orb_without_contact"]) != TYPE_BOOL:
		return "combat.collect_orb_without_contact must be Boolean."
	if float(combat["x_buffer_width"]) > float(combat["input_window_start"]):
		return "combat.x_buffer_width must not exceed combat.input_window_start."
	var audio_error := _validate_audio(data["audio"])
	if not audio_error.is_empty():
		return audio_error
	var loadout_error := _validate_spell_loadout(data["spell_loadout"])
	if not loadout_error.is_empty():
		return loadout_error
	var tutorial_error := _validate_tutorial(data["tutorial"])
	if not tutorial_error.is_empty():
		return tutorial_error
	var casting: Dictionary = data["casting"]
	var charge_lower: float = float(casting["trigger_charge_center"]) - float(casting["trigger_charge_half_width"])
	var charge_upper: float = float(casting["trigger_charge_center"]) + float(casting["trigger_charge_half_width"])
	if float(casting["trigger_deplete_max"]) >= charge_lower or charge_lower >= charge_upper or charge_upper >= float(casting["trigger_cast_min"]):
		return "casting pressure bands must be ordered deplete, charge, then cast."
	if charge_lower < 0.0 or charge_upper > 1.0:
		return "casting charge band must remain between 0 and 1."
	var integer_error := _validate_integer(data, "combat", "direct_impact", 0, 5)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "enemy", "defensive_level", 0, 2147483647)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "defence", "water_block_defensive_level", 0, 2147483647)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "air", "max_chain_targets", 1, 32)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "casting", "max_marked_capacity", 5, 5)
	if not integer_error.is_empty():
		return integer_error

	var heat: Dictionary = data["heat"]
	if not heat.has("levels") or typeof(heat["levels"]) != TYPE_ARRAY or heat["levels"].is_empty():
		return "heat.levels must be a non-empty array."

	var previous_ratio := -1.0
	for index in range(heat["levels"].size()):
		var level = heat["levels"][index]
		if typeof(level) != TYPE_DICTIONARY:
			return "heat.levels[%d] must be an object." % index
		for key in ["fill_ratio", "speed_multiplier"]:
			if not level.has(key) or not _is_number(level[key]):
				return "heat.levels[%d].%s must be numeric." % [index, key]
		if level["fill_ratio"] < 0.0 or level["fill_ratio"] > 1.0:
			return "heat.levels[%d].fill_ratio must be between 0 and 1." % index
		if level["fill_ratio"] <= previous_ratio:
			return "heat.levels fill ratios must be strictly increasing."
		if level["speed_multiplier"] <= 0.0:
			return "heat.levels[%d].speed_multiplier must be positive." % index
		previous_ratio = level["fill_ratio"]

	if heat["levels"][0]["fill_ratio"] != 0.0:
		return "The first Heat level must begin at fill_ratio 0."

	var water: Dictionary = data["water"]
	if not water.has("levels") or typeof(water["levels"]) != TYPE_ARRAY or water["levels"].size() != 5:
		return "water.levels must contain exactly five entries."
	var expected_statuses := ["wet", "wet", "slow", "slow", "frozen"]
	for index in range(water["levels"].size()):
		var water_level = water["levels"][index]
		if typeof(water_level) != TYPE_DICTIONARY:
			return "water.levels[%d] must be an object." % index
		for key in ["status", "duration", "slow_percent"]:
			if not water_level.has(key):
				return "water.levels[%d].%s is required." % [index, key]
		if str(water_level["status"]) != expected_statuses[index]:
			return "water.levels[%d].status must be %s." % [index, expected_statuses[index]]
		if not _is_number(water_level["duration"]) or float(water_level["duration"]) <= 0.0:
			return "water.levels[%d].duration must be positive." % index
		if not _is_number(water_level["slow_percent"]):
			return "water.levels[%d].slow_percent must be numeric." % index
		var slow_percent := float(water_level["slow_percent"])
		if slow_percent < 0.0 or slow_percent > 1.0:
			return "water.levels[%d].slow_percent must be between 0 and 1." % index

	var earth: Dictionary = data["earth"]
	if not earth.has("levels") or typeof(earth["levels"]) != TYPE_ARRAY or earth["levels"].size() != 5:
		return "earth.levels must contain exactly five entries."
	for index in range(earth["levels"].size()):
		var earth_level = earth["levels"][index]
		if typeof(earth_level) != TYPE_DICTIONARY:
			return "earth.levels[%d] must be an object." % index
		for key in ["duration", "slow_percent"]:
			if not earth_level.has(key) or not _is_number(earth_level[key]):
				return "earth.levels[%d].%s must be numeric." % [index, key]
		if float(earth_level["duration"]) <= 0.0:
			return "earth.levels[%d].duration must be positive." % index
		var earth_slow := float(earth_level["slow_percent"])
		if earth_slow < 0.0 or earth_slow > 1.0:
			return "earth.levels[%d].slow_percent must be between 0 and 1." % index

	var ui: Dictionary = data["ui"]
	if not ui.has("developer_overlay_visible") or typeof(ui["developer_overlay_visible"]) != TYPE_BOOL:
		return "ui.developer_overlay_visible must be Boolean."

	return ""


static func _validate_number(
	data: Dictionary,
	section_name: String,
	key: String,
	minimum: float,
	maximum: float
) -> String:
	var section: Dictionary = data[section_name]
	if not section.has(key) or not _is_number(section[key]):
		return "%s.%s must be numeric." % [section_name, key]
	var value := float(section[key])
	if value < minimum or value > maximum:
		return "%s.%s must be between %s and %s." % [section_name, key, minimum, maximum]
	return ""


static func _validate_audio(audio: Dictionary) -> String:
	for group_name in ["ambient", "sfx", "bgm"]:
		if not audio.has(group_name) or typeof(audio[group_name]) != TYPE_DICTIONARY:
			return "audio.%s must be an object." % group_name
		var group: Dictionary = audio[group_name]
		if not group.has("enabled") or typeof(group["enabled"]) != TYPE_BOOL:
			return "audio.%s.enabled must be Boolean." % group_name
		if not group.has("volume_db") or not _is_number(group["volume_db"]):
			return "audio.%s.volume_db must be numeric." % group_name
		var volume_db := float(group["volume_db"])
		if volume_db < -80.0 or volume_db > 24.0:
			return "audio.%s.volume_db must be between -80 and 24." % group_name
	return ""


static func _validate_spell_loadout(loadout: Dictionary) -> String:
	for school in ["fire", "water", "air", "earth"]:
		if not loadout.has(school) or typeof(loadout[school]) != TYPE_DICTIONARY:
			return "spell_loadout.%s must be an object." % school
		var school_loadout: Dictionary = loadout[school]
		for level in range(1, 6):
			var key := str(level)
			if not school_loadout.has(key) or typeof(school_loadout[key]) != TYPE_STRING:
				return "spell_loadout.%s.%s must be a spell identifier." % [school, key]
			if school_loadout[key] != "%s_default" % school:
				return "spell_loadout.%s.%s must retain the prototype default spell." % [school, key]
	return ""


static func _validate_tutorial(tutorial: Dictionary) -> String:
	if not tutorial.has("failure_feedback") or typeof(tutorial["failure_feedback"]) != TYPE_STRING:
		return "tutorial.failure_feedback must be a string."
	if not tutorial.has("objectives") or typeof(tutorial["objectives"]) != TYPE_ARRAY or tutorial["objectives"].is_empty():
		return "tutorial.objectives must be a non-empty array."
	for index in range(tutorial["objectives"].size()):
		var objective = tutorial["objectives"][index]
		if typeof(objective) != TYPE_DICTIONARY:
			return "tutorial.objectives[%d] must be an object." % index
		for key in ["id", "label", "success", "failures"]:
			if not objective.has(key):
				return "tutorial.objectives[%d].%s is required." % [index, key]
		if typeof(objective["id"]) != TYPE_STRING or typeof(objective["label"]) != TYPE_STRING:
			return "tutorial.objectives[%d] id and label must be strings." % index
		var success = objective["success"]
		if typeof(success) != TYPE_DICTIONARY or typeof(success.get("kind", null)) != TYPE_STRING or typeof(success.get("facts", null)) != TYPE_DICTIONARY:
			return "tutorial.objectives[%d].success must define kind and facts." % index
		if typeof(objective["failures"]) != TYPE_ARRAY:
			return "tutorial.objectives[%d].failures must be an array." % index
		for failure in objective["failures"]:
			if typeof(failure) != TYPE_DICTIONARY or typeof(failure.get("kind", null)) != TYPE_STRING or typeof(failure.get("facts", null)) != TYPE_DICTIONARY:
				return "tutorial.objectives[%d].failures entries must define kind and facts." % index
			if failure.has("feedback") and typeof(failure["feedback"]) != TYPE_STRING:
				return "tutorial.objectives[%d] failure feedback must be a string." % index
	var final_success: Dictionary = tutorial["objectives"][tutorial["objectives"].size() - 1]["success"]
	if final_success["kind"] != "final_enemy_defeated" or final_success["facts"].get("encounter_id", "") != "final_enemy":
		return "The final tutorial objective must complete on final_enemy_defeated for final_enemy."
	return ""


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


static func _validate_integer(
	data: Dictionary,
	section_name: String,
	key: String,
	minimum: int,
	maximum: int
) -> String:
	var section: Dictionary = data[section_name]
	if not section.has(key) or not _is_number(section[key]):
		return "%s.%s must be an integer." % [section_name, key]
	var numeric_value := float(section[key])
	if not is_equal_approx(numeric_value, round(numeric_value)):
		return "%s.%s must be an integer." % [section_name, key]
	var value := int(round(numeric_value))
	if value < minimum or value > maximum:
		return "%s.%s must be between %d and %d." % [section_name, key, minimum, maximum]
	return ""


static func _failure(message: String) -> Dictionary:
	return {
		"ok": false,
		"data": {},
		"error": message,
	}
