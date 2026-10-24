@tool
extends RefCounted
## Merge Portal edits against fresh character assets and scene/UI configuration.

const CONFIG_PATH := "res://config/prototype_combat.json"
const TUNING_PATH := "res://config/combat_tuning.tres"
const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Settings = preload("res://scripts/config/combat_tuning_settings.gd")
const Geometry = preload("res://scripts/combat/attack_geometry.gd")
const Characters = preload("res://scripts/config/character_settings_store.gd")
const Style = preload("res://scripts/combat/attack_style.gd")


static func source_hash() -> String:
	var hashes := FileAccess.get_sha256(CONFIG_PATH) + Characters.source_hash()
	for id in Geometry.move_ids():
		hashes += FileAccess.get_sha256(Geometry.DIRECTORY + id + ".tres")
	return hashes.sha256_text()


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
	# Old Portal caches cannot restore retired Player-X overrides or conflict on them.
	base = base.duplicate(true)
	draft = draft.duplicate(true)
	latest = latest.duplicate(true)
	for config in [base, draft, latest]:
		Style.strip_retired_fields(config)
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
	var expected_source_hash := source_hash() if path == CONFIG_PATH else expected_hash
	var loaded := load_config(path)
	if not bool(loaded["ok"]):
		return loaded
	var result := merge(base, draft, loaded["data"])
	if not bool(result["ok"]):
		return result
	if path == CONFIG_PATH:
		var sizes := Geometry.validate_sizes(result["data"])
		if not sizes["ok"]:
			return sizes
	if path == CONFIG_PATH and source_hash() != expected_source_hash:
		return {"ok": false, "error": "Character Settings changed while saving. Reload before saving."}
	result = Loader.validate_and_save(path, result["data"], expected_hash)
	if not bool(result["ok"]) or path != CONFIG_PATH:
		return result
	var actors := Characters.save_config(result["data"])
	if not actors["ok"]:
		return {"ok": false, "data": result["data"], "error": "Scene preferences saved; character Settings save failed: %s" % actors["error"]}
	var geometry := Geometry.save_changes(loaded["data"], result["data"])
	if not bool(geometry["ok"]):
		return {"ok": false, "data": result["data"], "error": "Preferences and character Settings saved; animation geometry save failed: %s" % geometry["error"]}
	var mirror := Settings.save_config_mirror(result["data"], TUNING_PATH)
	if not bool(mirror["ok"]):
		return {"ok": false, "data": result["data"], "error": "Preferences, character Settings and geometry saved; Inspector mirror save failed: %s" % mirror["error"]}
	return result


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
	# Remove only retired config leaves; keep other retained component dictionaries.
	Style.strip_retired_fields(target)
