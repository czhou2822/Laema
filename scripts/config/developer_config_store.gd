@tool
extends RefCounted
## One persisted authority. Merge edited leaves against a fresh validated file.

const CONFIG_PATH := "res://config/prototype_combat.json"
const Loader = preload("res://scripts/config/prototype_config_loader.gd")


static func load_config(path: String = CONFIG_PATH) -> Dictionary:
	return Loader.load_and_validate(path)


static func changes(base: Variant, draft: Variant, prefix: Array = []) -> Array:
	var result: Array = []
	if typeof(base) == TYPE_DICTIONARY and typeof(draft) == TYPE_DICTIONARY:
		for key in draft:
			if not base.has(key):
				result.append({"path": prefix + [key], "before": null, "after": draft[key]})
			else:
				result.append_array(changes(base[key], draft[key], prefix + [key]))
	elif typeof(base) == TYPE_ARRAY and typeof(draft) == TYPE_ARRAY and base.size() == draft.size():
		for index in range(draft.size()):
			result.append_array(changes(base[index], draft[index], prefix + [index]))
	elif base != draft:
		result.append({"path": prefix, "before": base, "after": draft})
	return result


static func read_value(data: Variant, keys: Array) -> Variant:
	var current: Variant = data
	for key in keys:
		if typeof(current) == TYPE_DICTIONARY and current.has(key):
			current = current[key]
		elif typeof(current) == TYPE_ARRAY and typeof(key) == TYPE_INT and key >= 0 and key < current.size():
			current = current[key]
		else:
			return null
	return current


static func set_value(data: Dictionary, keys: Array, value: Variant) -> void:
	var current: Variant = data
	for index in range(keys.size() - 1):
		current = current[keys[index]]
	current[keys.back()] = value


static func merge(base: Dictionary, draft: Dictionary, latest: Dictionary) -> Dictionary:
	var candidate := latest.duplicate(true)
	var conflicts: Array[String] = []
	for change in changes(base, draft):
		var current: Variant = read_value(latest, change["path"])
		if current != change["before"] and current != change["after"]:
			conflicts.append(path_label(change["path"]))
		else:
			set_value(candidate, change["path"], change["after"])
	if not conflicts.is_empty():
		return {"ok": false, "error": "Configuration changed elsewhere: %s. Reload before saving." % ", ".join(conflicts)}
	return {"ok": true, "error": "", "data": candidate}


static func save_changes(base: Dictionary, draft: Dictionary, path: String = CONFIG_PATH) -> Dictionary:
	var expected_hash := FileAccess.get_sha256(path)
	var loaded := load_config(path)
	if not bool(loaded["ok"]):
		return loaded
	var result := merge(base, draft, loaded["data"])
	if not bool(result["ok"]):
		return result
	return Loader.validate_and_save(path, result["data"], expected_hash)


static func path_label(keys: Array) -> String:
	var parts: PackedStringArray = []
	for key in keys:
		parts.append(str(key))
	return ".".join(parts)


static func copy_into(target: Dictionary, source: Dictionary) -> void:
	# Preserve dictionaries retained by gameplay components.
	for key in source:
		if source[key] is Dictionary and target.get(key) is Dictionary:
			copy_into(target[key], source[key])
		elif source[key] is Array and target.get(key) is Array and source[key].size() == target[key].size():
			for index in range(source[key].size()):
				if source[key][index] is Dictionary and target[key][index] is Dictionary:
					copy_into(target[key][index], source[key][index])
				else:
					target[key][index] = source[key][index]
		else:
			target[key] = source[key].duplicate(true) if source[key] is Dictionary or source[key] is Array else source[key]
