@tool
extends RefCounted
## Contiguous integer ranges: each level starts at its configured minimum.

const DEFAULT_STARTS := [0, 11, 21, 31, 41]


static func start(levels: Array, index: int) -> int:
	return int(levels[index].get("minimum_value", DEFAULT_STARTS[index]))


static func level_for_value(value: int, levels: Array) -> int:
	for index in range(levels.size() - 1, -1, -1):
		if value >= start(levels, index):
			return index + 1
	return 1 # Eligibility remains the resolver's responsibility.


static func range_text(levels: Array, index: int) -> String:
	return "%d+" % start(levels, index) if index == levels.size() - 1 else "%d–%d" % [start(levels, index), start(levels, index + 1) - 1]


static func validation_error(levels: Array) -> String:
	if levels.size() != 5:
		return "Hit-reaction configuration must contain exactly five levels."
	var previous := -1
	for index in range(levels.size()):
		if not levels[index] is Dictionary:
			return "Each hit-reaction level must be an object."
		var value: Variant = levels[index].get("minimum_value")
		if not (value is int or value is float) or not is_finite(float(value)) or float(value) != floorf(float(value)) or float(value) < 0.0 or float(value) > 2147483647.0:
			return "Level %d starting value must be a non-negative whole number." % (index + 1)
		if index == 0 and int(value) != 0:
			return "Level 1 must start at 0; changing ranges does not change hit eligibility."
		if int(value) <= previous:
			return "Starting values must increase: Level %d must start above Level %d." % [index + 1, index]
		previous = int(value)
	return ""


static func normalize_legacy(data: Dictionary) -> void:
	var reaction: Variant = data.get("hit_reaction")
	if not reaction is Dictionary or not reaction.get("combat_levels") is Array:
		return
	var levels: Array = reaction["combat_levels"]
	if levels.size() != 5:
		return
	for level in levels:
		if not level is Dictionary or level.has("minimum_value"):
			return # A partially specified table is invalid, not an old configuration.
	for index in range(5):
		levels[index]["minimum_value"] = DEFAULT_STARTS[index]
