class_name PrototypeConfigLoader
extends RefCounted

const REQUIRED_SECTIONS := [
	"movement",
	"audio",
	"player",
	"enemy",
	"enemy_ai",
	"combat",
	"casting",
	"heat",
	"fire",
	"water",
	"air",
	"earth",
	"defence",
	"elemental_endurance",
	"hit_reaction",
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
		["enemy_ai", "aggro_range", 1.0, INF],
		["enemy_ai", "attack_range", 1.0, INF],
		["enemy_ai", "movement_speed", 0.0, INF],
		["enemy_ai", "windup_duration", 0.001, INF],
		["enemy_ai", "recovery_duration", 0.0, INF],
		["enemy_ai", "damage", 0.0, INF],
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
		["casting", "trigger_release_max", 0.0, 1.0],
		["casting", "trigger_charge_min", 0.0, 1.0],
		["casting", "empowered_primary_multiplier", 0.001, INF],
		["casting", "projectile_screen_ratio", 0.001, 1.0],
		["casting", "projectile_travel_duration", 0.001, INF],
		["heat", "max_heat", 100.0, 100.0],
		["heat", "gain_per_charged_orb", 0.0, INF],
		["heat", "loss_per_direct_hit", 0.0, INF],
		["heat", "reset_timer", 0.001, INF],
		["heat", "depletion_per_second", 0.0, INF],
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
		["elemental_endurance", "hit_6_damage_percent", 0.0, 1.0],
		["elemental_endurance", "hit_7_damage_percent", 0.0, 1.0],
		["elemental_endurance", "hit_8_damage_percent", 0.0, 1.0],
		["elemental_endurance", "hit_9_damage_percent", 0.0, 1.0],
		["elemental_endurance", "hit_10_damage_percent", 0.0, 1.0],
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
	var player: Dictionary = data["player"]
	if not player.has("one_hp_floor_enabled") or typeof(player["one_hp_floor_enabled"]) != TYPE_BOOL:
		return "player.one_hp_floor_enabled must be Boolean."
	var heat: Dictionary = data["heat"]
	for obsolete_heat_key in ["max_attack_speed_percent", "attack_speed_gain_per_orb", "attack_speed_loss_per_hit", "heat_reset_timer"]:
		if heat.has(obsolete_heat_key):
			return "heat.%s is obsolete." % obsolete_heat_key
	for obsolete_air_key in ["attack_speed_multiplier", "buff_duration"]:
		if data["air"].has(obsolete_air_key):
			return "air.%s is obsolete." % obsolete_air_key
	if not combat.has("collect_orb_without_contact") or typeof(combat["collect_orb_without_contact"]) != TYPE_BOOL:
		return "combat.collect_orb_without_contact must be Boolean."
	if float(combat["x_buffer_width"]) > float(combat["input_window_start"]):
		return "combat.x_buffer_width must not exceed combat.input_window_start."
	var audio_error := _validate_audio(data["audio"])
	if not audio_error.is_empty():
		return audio_error
	var tutorial_error := _validate_tutorial(data["tutorial"])
	if not tutorial_error.is_empty():
		return tutorial_error
	var casting: Dictionary = data["casting"]
	if float(casting["trigger_release_max"]) >= float(casting["trigger_charge_min"]):
		return "casting.trigger_release_max must be lower than casting.trigger_charge_min."
	var integer_error := _validate_integer(data, "combat", "direct_impact", 0, 5)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "enemy", "defensive_level", 0, 2147483647)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "enemy_ai", "impact", 0, 5)
	if not integer_error.is_empty():
		return integer_error
	if not data["enemy_ai"].has("enabled") or typeof(data["enemy_ai"]["enabled"]) != TYPE_BOOL:
		return "enemy_ai.enabled must be Boolean."
	integer_error = _validate_integer(data, "defence", "water_block_defensive_level", 0, 2147483647)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "air", "max_chain_targets", 1, 32)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "casting", "max_marked_capacity", 5, 5)
	if not integer_error.is_empty():
		return integer_error
	integer_error = _validate_integer(data, "casting", "max_storage_capacity", 10, 10)
	if not integer_error.is_empty():
		return integer_error

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
	var feedback_error := _validate_number(data, "ui", "cast_feedback_duration", 0.1, 20.0)
	if not feedback_error.is_empty():
		return feedback_error

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


static func _validate_tutorial(tutorial: Dictionary) -> String:
	if tutorial.has("objectives") or tutorial.has("failure_feedback"):
		return "tutorial.objectives and tutorial.failure_feedback are obsolete."
	if not tutorial.has("initial_school") or StringName(tutorial["initial_school"]) not in [&"fire", &"water", &"air", &"earth"]:
		return "tutorial.initial_school must be a functional school."
	if not tutorial.has("default_stage_id") or typeof(tutorial["default_stage_id"]) != TYPE_STRING or String(tutorial["default_stage_id"]).is_empty():
		return "tutorial.default_stage_id must be a non-empty string."
	if not tutorial.has("transition_duration") or not _is_number(tutorial["transition_duration"]):
		return "tutorial.transition_duration must be numeric."
	if float(tutorial["transition_duration"]) < 0.1 or float(tutorial["transition_duration"]) > 5.0:
		return "tutorial.transition_duration must be between 0.1 and 5.0."
	if not tutorial.has("stages") or typeof(tutorial["stages"]) != TYPE_ARRAY or tutorial["stages"].is_empty():
		return "tutorial.stages must be a non-empty array."
	var ids: Dictionary = {}
	for index in range(tutorial["stages"].size()):
		var stage = tutorial["stages"][index]
		if typeof(stage) != TYPE_DICTIONARY:
			return "tutorial.stages[%d] must be an object." % index
		for key in ["id", "area_scene", "objective", "final"]:
			if not stage.has(key):
				return "tutorial.stages[%d].%s is required." % [index, key]
		if typeof(stage["id"]) != TYPE_STRING or String(stage["id"]).is_empty() or ids.has(stage["id"]):
			return "tutorial stage ids must be unique non-empty strings."
		ids[stage["id"]] = true
		if typeof(stage["area_scene"]) != TYPE_STRING or not ResourceLoader.exists(str(stage["area_scene"]), "PackedScene"):
			return "tutorial.stages[%d].area_scene must reference a loadable PackedScene." % index
		if typeof(stage["final"]) != TYPE_BOOL or bool(stage["final"]) != (index == tutorial["stages"].size() - 1):
			return "tutorial must have exactly one final stage at the end."
		var objective = stage["objective"]
		if typeof(objective) != TYPE_DICTIONARY or typeof(objective.get("type", null)) != TYPE_STRING or typeof(objective.get("label", null)) != TYPE_STRING:
			return "tutorial.stages[%d].objective must define type and label." % index
		match StringName(objective["type"]):
			&"sequence":
				var sequence_error := _validate_sequence_objective(objective)
				if not sequence_error.is_empty():
					return sequence_error
			&"final_enemy":
				if StringName(objective.get("encounter_id", &"")) != &"final_enemy" or not stage.has("free_practice_text") or typeof(stage["free_practice_text"]) != TYPE_STRING:
					return "final_enemy requires final_enemy encounter_id and free_practice_text."
			&"heat_threshold":
				if not _is_number(objective.get("threshold", null)):
					return "heat_threshold requires numeric threshold."
			&"heat_guard_sequence":
				if not _is_number(objective.get("threshold", null)):
					return "heat_guard_sequence requires numeric threshold."
				var guarded_sequence_error := _validate_sequence_objective(objective)
				if not guarded_sequence_error.is_empty():
					return guarded_sequence_error
			_:
				return "tutorial objective type is unsupported."
	if not ids.has(tutorial["default_stage_id"]):
		return "tutorial.default_stage_id must reference a configured stage."
	return ""


static func _validate_sequence_objective(objective: Dictionary) -> String:
	for key in ["tokens", "success_steps", "prestart", "active", "completion_progress"]:
		if not objective.has(key):
			return "sequence.%s is required." % key
	if typeof(objective["tokens"]) != TYPE_ARRAY or typeof(objective["success_steps"]) != TYPE_ARRAY or objective["success_steps"].is_empty():
		return "sequence requires tokens and a non-empty success_steps array."
	if typeof(objective["prestart"]) != TYPE_DICTIONARY or typeof(objective["active"]) != TYPE_DICTIONARY or not _is_number(objective["completion_progress"]):
		return "sequence prestart, active, and completion_progress are invalid."
	if objective.has("highlight_next") and typeof(objective["highlight_next"]) != TYPE_BOOL:
		return "sequence.highlight_next must be Boolean."
	for step_variant in objective["success_steps"]:
		if typeof(step_variant) != TYPE_DICTIONARY:
			return "sequence success steps must be objects."
		var step: Dictionary = step_variant
		var step_type := StringName(step.get("type", &""))
		if step_type not in [&"light", &"cast", &"switch"]:
			return "sequence step type is unsupported."
		if step.has("school") and StringName(step["school"]) not in [&"fire", &"water", &"air", &"earth"]:
			return "sequence light school must be functional."
		if step.has("required_level") and (not _is_number(step["required_level"]) or int(step["required_level"]) < 1 or int(step["required_level"]) > 5):
			return "sequence required_level must be an integer from 1 through 5."
		if step.has("endpoint") and typeof(step["endpoint"]) != TYPE_BOOL:
			return "sequence endpoint must be Boolean."
		if step.has("chain_position") and (not _is_number(step["chain_position"]) or not is_equal_approx(float(step["chain_position"]), round(float(step["chain_position"])) )):
			return "sequence chain_position must be an integer."
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
