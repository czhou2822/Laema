extends SceneTree

const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
var checks := 0
var failures: Array[String] = []
var reference: Dictionary


func _initialize() -> void:
	call_deferred("_run")


func check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		printerr("FAILED: ", message)


func fixture(path: String):
	var scene = load(path).instantiate()
	root.add_child(scene)
	current_scene = scene
	for frame in range(5):
		await process_frame
	scene.player.movement.set_physics_process(false)
	scene.player.might.set_physics_process(false)
	scene.player.combat.set_process(false)
	for target in scene.get("_current_area").get_targets():
		target.set_physics_process(false)
	return scene


func release_scene(scene: Node) -> void:
	for audio in scene.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	await create_timer(0.15).timeout
	scene.free()
	await process_frame


func damage(scene: Node, enemy, impact: int = 20, amount: float = 1.0):
	var event_class = load("res://scripts/entities/health_event.gd")
	return enemy.receive_health_event(event_class.damage(scene.player, enemy, amount, impact,
		event_class.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT, enemy.global_position))


func check_scene(path: String) -> void:
	var scene = await fixture(path)
	var enemy = scene.get("_current_area").get_node("FinalEnemy")
	var config: Dictionary = scene.get("_config")
	check(config == reference, "Identical shared configuration: " + path)
	check(scene.player.health.get_maximum() == 100.0 and enemy.health.get_maximum() == 200.0, "Shared Health: " + path)
	check(enemy.get_poise() == 10 and config["moves"]["final_enemy_attack"]["impact"] == 20, "Shared Poise/Impact: " + path)
	check(not enemy.status_controller.get("_endurance_enabled"), "Shared resistance disabled: " + path)
	check(scene.combat_tuning.persistence_enabled, "Shared Portal save enabled: " + path)
	var switch := InputEventAction.new()
	switch.action = &"select_water"
	switch.pressed = true
	Input.parse_input_event(switch)
	await process_frame
	check(scene.player.combat.get_active_school() == &"water", "School input reaches Player: " + path)
	switch.pressed = false
	Input.parse_input_event(switch)
	scene.player.select_stage_school(&"fire")
	var starts := {"count": 0, "inside_tree": 0}
	enemy.hit_reaction.reaction_started.connect(func(_level, _direction, _distance, _duration):
		starts["count"] += 1
		if enemy.get("_ticking_tree"):
			starts["inside_tree"] += 1
	)
	enemy.ai_begin_windup(scene.player)
	var result = damage(scene, enemy)
	check(result.outcome == result.Outcome.APPLIED and result.final_reaction_level == 1, "Qualifying hit resolves normally: " + path)
	check(starts["count"] == 1 and starts["inside_tree"] == 1, "Tree starts reaction synchronously exactly once: " + path)
	check(enemy.hit_reaction.is_invincible() and not enemy.has_pending_combat_hit_reaction(), "Reaction consumes request and protects immediately: " + path)
	check(enemy.get("_attack_id") == 0 and not enemy.attack_animation.is_playing(), "Incoming hit cancels windup: " + path)
	check(damage(scene, enemy).outcome == result.Outcome.INVINCIBLE and starts["count"] == 1, "Repeat hit cannot restart or damage protected Enemy: " + path)
	var remaining: float = enemy.hit_reaction.get("_remaining")
	config["hit_reaction"]["combat_levels"][0]["duration"] = 0.37
	config["hit_reaction"]["combat_levels"][0]["distance"] = 13.0
	check(scene._apply_runtime_tuning()["ok"], "Portal reaction edit applies: " + path)
	check(is_equal_approx(enemy.hit_reaction.get("_remaining"), remaining), "Portal edit preserves running reaction: " + path)
	enemy._physics_process(remaining)
	check(not enemy.hit_reaction.is_invincible(), "One shared lifetime completes: " + path)
	enemy._physics_process(0.0)
	check(enemy.get("_state") == enemy.State.IDLE, "Reaction action completes without added timer: " + path)
	enemy._reset_ai_execution()
	damage(scene, enemy)
	check(is_equal_approx(enemy.hit_reaction.get("_remaining"), 0.37), "Next tree-triggered reaction uses Portal duration: " + path)
	check(is_equal_approx(Vector2(enemy.hit_reaction.get("_push_velocity")).length(), 13.0 / 0.37), "Portal distance shares the same lifetime: " + path)
	# Request inside a running task: protection starts at contact, dispatch waits
	# until the abandoned task unwinds. These are API/lifecycle probes, not play.
	enemy._reset_ai_execution()
	enemy.set("_ticking_tree", true)
	damage(scene, enemy)
	check(enemy.has_pending_combat_hit_reaction() and not enemy.hit_reaction.is_invincible(), "In-task reaction is queued without recursive tree tick: " + path)
	check(damage(scene, enemy).outcome == result.Outcome.INVINCIBLE, "Pending reaction closes same-frame protection gap: " + path)
	config["hit_reaction"]["combat_levels"][0]["duration"] = 0.91
	scene._apply_runtime_tuning()
	enemy.set("_ticking_tree", false)
	enemy._update_ai_tree(0.0)
	check(not enemy.has_pending_combat_hit_reaction() and is_equal_approx(enemy.hit_reaction.get("_remaining"), 0.37), "Tree dispatch preserves captured tuning: " + path)
	check(starts["count"] == starts["inside_tree"], "Every Enemy reaction started inside its tree: " + path)
	enemy._reset_ai_execution()
	# Mixed layers retain one strongest reaction, with no reaction between layers.
	var count_before: int = starts["count"]
	enemy.begin_hit_transaction()
	damage(scene, enemy, 20)
	damage(scene, enemy, 40)
	check(starts["count"] == count_before, "Mixed layers defer reaction until transaction completion: " + path)
	enemy.end_hit_transaction()
	check(starts["count"] == count_before + 1 and is_equal_approx(enemy.hit_reaction.get("_remaining"), float(config["hit_reaction"]["combat_levels"][2]["duration"])), "Tree executes strongest mixed reaction once: " + path)
	enemy._reset_ai_execution()
	config["enemy_ai"]["enabled"] = false
	scene._apply_runtime_tuning()
	damage(scene, enemy)
	check(enemy.hit_reaction.is_invincible() and not enemy.get("_stage_enabled"), "Disabled offensive AI still executes combat reaction through tree: " + path)
	enemy._physics_process(1.0)
	check(not enemy.hit_reaction.is_invincible() and not enemy.attack_animation.is_playing(), "Disabled-AI reaction finishes without starting attacks: " + path)
	config["enemy_ai"]["enabled"] = true
	config["elemental_endurance"]["enabled"] = true
	scene._apply_runtime_tuning()
	check(enemy.status_controller.get("_endurance_enabled"), "Shared resistance switch reaches Enemy: " + path)
	damage(scene, enemy, 0)
	var hits: int = enemy.status_controller.get("_endurance_hits")
	scene._apply_runtime_tuning()
	check(enemy.status_controller.get("_endurance_hits") == hits, "Unchanged settings do not reset resistance: " + path)
	config["elemental_endurance"]["enabled"] = false
	scene._apply_runtime_tuning()
	check(not enemy.status_controller.get("_endurance_enabled"), "Resistance switch disables consistently: " + path)
	# Player death and reset belong to the reusable actor, independently of result UI.
	var event_class = load("res://scripts/entities/health_event.gd")
	scene.player.receive_health_event(event_class.damage(enemy, scene.player, 1000, 0, event_class.Delivery.DIRECT, &"fire"))
	check(scene.player.health.is_zero() and scene.player.get("_stage_input_locked"), "Shared Player death locks actions: " + path)
	scene.player.reset_for_stage()
	check(scene.player.health.get_current() == 100.0 and not scene.player.get("_stage_input_locked"), "Shared Player reset restores actions: " + path)
	await release_scene(scene)


func check_character_ownership() -> void:
	var store = load("res://scripts/config/developer_config_store.gd")
	var characters = load("res://scripts/config/character_settings_store.gd")
	var saved := characters.load_resources() as Dictionary
	check(saved["ok"], "Character roots expose loadable Settings Resources")
	var preferences: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(store.CONFIG_PATH))
	check(not characters.SECTIONS.any(func(section): return preferences.has(section)), "Level configuration contains no character combat settings")
	var standalone = load(characters.ENEMY_SCENE).instantiate()
	check(standalone.is_final_enemy and not standalone.refills_at_zero and standalone.encounter_id == &"final_enemy", "Reusable CombatEnemy owns its killable combat role without level overrides")
	standalone.free()
	var original_hash: String = store.source_hash()
	var player: PlayerCombatSettings = saved["player"]
	var enemy: EnemyCombatSettings = saved["enemy"]
	var reaction: CharacterReactionSettings = saved["reaction"]
	check(not enemy.enemy_ai.has("windup_duration") and not enemy.enemy_ai.has("recovery_duration"), "Enemy Settings expose no animation timing override")
	player.movement["speed"] = 273.0
	enemy.enemy["max_health"] = 234.0
	enemy.enemy_ai["damage"] = 19.0
	reaction.combat_levels[0].duration = 0.41
	for resource in [player, enemy, reaction]:
		check(ResourceSaver.save(resource, resource.resource_path) == OK, "Native Inspector resource save: " + resource.resource_path)
	check(store.source_hash() != original_hash, "Portal detects Inspector saves to character assets")
	var loaded: Dictionary = store.load_config()["data"]
	check(loaded["movement"]["speed"] == 273.0 and loaded["enemy"]["max_health"] == 234.0 and loaded["enemy_ai"]["damage"] == 19.0, "Startup reads saved character assets despite cached scene resources")
	check(is_equal_approx(loaded["hit_reaction"]["combat_levels"][0]["duration"], 0.41), "Startup reads the shared character reaction asset")
	var stale := reference.duplicate(true)
	stale["enemy_ai"]["damage"] = 21.0
	check(not store.save_changes(reference, stale)["ok"], "A Portal draft conflicts with a newer Inspector edit on the same character field")
	for path in ["res://scenes/gym.tscn", "res://scenes/prototype_arena.tscn"]:
		var scene = await fixture(path)
		var actor = scene.get("_current_area").get_node("FinalEnemy")
		check(scene.player.get("_config")["movement"]["speed"] == 273.0 and actor.health.get_maximum() == 234.0 and actor.bt_player.blackboard.get_var(&"damage") == 19.0, "Both character implementations use Inspector-authored settings: " + path)
		check(scene.player.settings.movement["speed"] == 273.0 and actor.settings.enemy_ai["damage"] == 19.0, "Live character Inspector reflects the actual configuration: " + path)
		await release_scene(scene)
	check(store.save_changes(loaded, reference)["ok"], "Restore original character settings through Portal save")
	check(store.load_config()["data"] == reference, "Inspector and Portal round trip the same actor data")
	# Follow the resource assigned on the character, rather than a hardcoded profile path.
	var scene_path := characters.ENEMY_SCENE as String
	var scene_text := FileAccess.get_file_as_string(scene_path)
	var alternate_path := "res://config/characters/test_enemy_settings.tres"
	check(ResourceSaver.save(enemy, alternate_path) == OK, "Alternate character asset fixture saves")
	var file := FileAccess.open(scene_path, FileAccess.WRITE)
	file.store_string(scene_text.replace("res://config/characters/combat_enemy.tres", alternate_path))
	file.close()
	var alternate: Dictionary = store.load_config()["data"]
	var draft := alternate.duplicate(true)
	draft["enemy_ai"]["damage"] = 23.0
	check(store.save_changes(alternate, draft)["ok"], "Portal saves through the character root's assigned Settings reference")
	var actual := ResourceLoader.load(alternate_path, "", ResourceLoader.CACHE_MODE_IGNORE) as EnemyCombatSettings
	check(actual.enemy_ai["damage"] == 23.0, "Portal writes the assigned character asset")
	file = FileAccess.open(scene_path, FileAccess.WRITE)
	file.store_string(scene_text)
	file.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(alternate_path))
	check(store.load_config()["data"] == reference, "Restoring the character reference restores canonical settings")


func _run() -> void:
	root.size = Vector2i(1280, 720)
	reference = Loader.load_and_validate("res://config/prototype_combat.json")["data"]
	check(is_equal_approx(reference["moves"]["fire_x1"]["windup_duration"], 0.21) and is_equal_approx(reference["moves"]["fire_x1"]["recovery_duration"], 0.51), "Gym X1 pace is promoted once into shared settings")
	check(is_equal_approx(reference["combat"]["attack_duration"], 1.2), "Shared Cast duration retains Gym pace")
	check(Catalog.fields(reference, "elemental_endurance").any(func(field): return field["id"] == "elemental_endurance.enabled"), "Resistance switch is exposed in the shared Portal")
	await check_character_ownership()
	await check_scene("res://scenes/gym.tscn")
	await check_scene("res://scenes/prototype_arena.tscn")
	# Exercise the real Gym save path, then reload through the other scene.
	var gym = await fixture("res://scenes/gym.tscn")
	gym.get("_config")["enemy_ai"]["damage"] = 17.0
	gym.get("_config")["movement"]["speed"] = 281.0
	gym.get("_config")["hit_reaction"]["combat_levels"][0]["duration"] = 0.43
	check(gym._apply_runtime_tuning()["ok"] and gym._save_runtime_tuning()["ok"], "Gym saves through shared Portal/Inspector persistence")
	var owned: Dictionary = load("res://scripts/config/character_settings_store.gd").load_resources()
	check(owned["player"].movement["speed"] == 281.0 and owned["enemy"].enemy_ai["damage"] == 17.0 and is_equal_approx(owned["reaction"].combat_levels[0].duration, 0.43), "Portal persists Player, Enemy and reaction edits into character assets")
	await release_scene(gym)
	var arena = await fixture("res://scenes/prototype_arena.tscn")
	var enemy = arena.get("_current_area").get_node("FinalEnemy")
	check(arena.get("_config")["enemy_ai"]["damage"] == 17.0 and enemy.bt_player.blackboard.get_var(&"damage") == 17.0, "Gym save reaches prototype Enemy's actual tree parameter")
	await release_scene(arena)
	if failures.is_empty():
		print("PASSED: %d shared-combat parity and tree-reaction checks" % checks)
		call_deferred("quit", 0)
	else:
		call_deferred("quit", 1)
