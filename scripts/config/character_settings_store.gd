@tool
extends RefCounted
## Adapter between character-owned native Resources and the existing runtime config.
## Rooms never provide combat defaults. Portal and Inspector persist the same assets.

const PLAYER_SCENE := "res://scenes/player/player.tscn"
const ENEMY_SCENE := "res://scenes/enemy/combat_enemy.tscn"
const SECTIONS := ["player", "movement", "combat", "casting", "heat", "defence",
	"fire", "water", "air", "earth", "moves", "enemy", "enemy_ai", "elemental_endurance", "hit_reaction"]


static func _settings(scene_path: String) -> Resource:
	var scene := ResourceLoader.load(scene_path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if scene == null:
		return null
	var state := scene.get_state()
	for index in range(state.get_node_property_count(0)):
		if state.get_node_property_name(0, index) == &"settings":
			var resource: Resource = state.get_node_property_value(0, index)
			if resource == null or resource.resource_path.is_empty():
				return null
			return ResourceLoader.load(resource.resource_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	return null


static func load_resources(refresh_external_leaves: bool = true) -> Dictionary:
	var player := _settings(PLAYER_SCENE) as PlayerCombatSettings
	var enemy := _settings(ENEMY_SCENE) as EnemyCombatSettings
	if player == null or enemy == null or player.hit_reaction == null or enemy.hit_reaction == null:
		return {"ok": false, "error": "Player and CombatEnemy require Settings and Hit Reaction Resources on their roots."}
	if player.hit_reaction.resource_path != enemy.hit_reaction.resource_path:
		return {"ok": false, "error": "Player and CombatEnemy must reference the same shared Hit Reaction Resource."}
	var reaction: CharacterReactionSettings = player.hit_reaction
	if refresh_external_leaves:
		reaction = ResourceLoader.load(player.hit_reaction.resource_path, "", ResourceLoader.CACHE_MODE_IGNORE) as CharacterReactionSettings
	if reaction == null:
		return {"ok": false, "error": "Cannot load the character Hit Reaction Resource."}
	player.hit_reaction = reaction
	enemy.hit_reaction = reaction
	# Refresh external leaves without reloading live Script resources.
	var ids: Dictionary = {}
	for index in range(player.attack_styles.size()):
		var style := player.attack_styles[index]
		if style == null:
			return {"ok": false, "error": "Player Settings contain a missing attack style."}
		if ids.has(style.move_id) or not player.moves.has(String(style.move_id)):
			return {"ok": false, "error": "Player Settings require unique, known attack-style IDs."}
		ids[style.move_id] = true
		if refresh_external_leaves:
			player.attack_styles[index] = ResourceLoader.load(style.resource_path, "", ResourceLoader.CACHE_MODE_IGNORE) as MoveStyleTuning
			if player.attack_styles[index] == null:
				return {"ok": false, "error": "Cannot load Player attack style: %s" % style.resource_path}
	if player.attack_styles.size() != 20:
		return {"ok": false, "error": "Player Settings require all twenty school attack styles."}
	return {"ok": true, "error": "", "player": player, "enemy": enemy, "reaction": reaction}


static func apply_to_config(config: Dictionary) -> Dictionary:
	var resources := load_resources()
	if not resources["ok"]:
		return resources
	resources["player"].apply_to_config(config)
	resources["enemy"].apply_to_config(config)
	return {"ok": true, "error": ""}


static func scene_config(config: Dictionary) -> Dictionary:
	var result := config.duplicate(true)
	for section in SECTIONS:
		result.erase(section)
	if result.get("tutorial") is Dictionary:
		result["tutorial"].erase("initial_school")
	return result


static func save_config(config: Dictionary) -> Dictionary:
	var resources := load_resources()
	if not resources["ok"]:
		return resources
	for key in ["player", "enemy", "reaction"]:
		var resource: Resource = resources[key]
		if resource.resource_path.is_empty() or resource.is_built_in():
			return {"ok": false, "error": "Save character Settings to an external .tres asset before using Portal Save."}
		resource.read_from_config(config)
	# Save external styles first, then the parent references.
	for style in resources["player"].attack_styles:
		var error := ResourceSaver.save(style, style.resource_path)
		if error != OK:
			return {"ok": false, "error": "Cannot save %s: %s" % [style.resource_path, error_string(error)]}
	for key in ["reaction", "player", "enemy"]:
		var resource: Resource = resources[key]
		var error := ResourceSaver.save(resource, resource.resource_path)
		if error != OK:
			return {"ok": false, "error": "Cannot save %s: %s" % [resource.resource_path, error_string(error)]}
	return {"ok": true, "error": ""}


static func source_hash() -> String:
	var hashes := FileAccess.get_sha256(PLAYER_SCENE) + FileAccess.get_sha256(ENEMY_SCENE)
	# Fingerprint assigned paths and bytes; load/save still refresh and validate leaves.
	var resources := load_resources(false)
	if not resources["ok"]:
		return hashes + str(resources["error"])
	for key in ["player", "enemy", "reaction"]:
		hashes += FileAccess.get_sha256(resources[key].resource_path)
	for style in resources["player"].attack_styles:
		hashes += FileAccess.get_sha256(style.resource_path)
	return hashes
