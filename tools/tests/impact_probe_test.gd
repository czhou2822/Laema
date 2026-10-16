extends SceneTree
## Controlled real-animation/ShapeCast reproduction; run only in the isolated runner.

const Probe = preload("res://scripts/debug/impact_probe.gd")
var failures: Array[String] = []
var checks := 0


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: ", description)


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var saved_hash := FileAccess.get_sha256("res://config/prototype_combat.json")
	await _run_chain(-1)
	await _run_chain(41)
	check(FileAccess.get_sha256("res://config/prototype_combat.json") == saved_hash, "Probe leaves saved tuning untouched")
	if failures.is_empty():
		print("PASSED: %d Fire X5 Impact probe checks" % checks)
	quit(0 if failures.is_empty() else 1)


func _run_chain(override_impact: int) -> void:
	var gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await process_frame
	await process_frame
	var enemy = gym.get("_current_area").get_targets()[0]
	# Hold AI decisions in this isolated reproduction; retain collision and reaction physics.
	enemy.set("_stage_enabled", false)
	var config: Dictionary = gym.get("_config")
	if override_impact >= 0:
		config["moves"]["fire_x5"]["impact"] = override_impact
	var might: MightComponent = gym.player.get_node("Combat/Might")
	enemy.global_position.x = gym.player.global_position.x + 45.0
	for frame in range(5):
		await physics_frame
	Probe.record("scenario", {"name": "saved_config" if override_impact < 0 else "isolated_41_comparison", "fire_x5_impact": config["moves"]["fire_x5"]["impact"], "enemy_poise": enemy.get_poise(), "ai_decisions_held": true, "saved_config_sha256": FileAccess.get_sha256("res://config/prototype_combat.json")})
	var reactions: Array[Dictionary] = []
	enemy.hit_reaction.reaction_started.connect(func(level: int, _direction: Vector2, distance: float, duration: float):
		reactions.append({"move_id": str(might.get("_current_action").get("move_id", "")), "level": level, "duration": duration, "distance": distance, "start_x": enemy.global_position.x})
	)
	might.try_light_attack(Vector2.RIGHT)
	for position in range(1, 5):
		var ready := false
		for frame in range(120):
			await physics_frame
			if str(might.get("_current_action").get("move_id", "")) == "fire_x%d" % position and bool(might.get("_window_open")):
				ready = true
				break
		check(ready, "Fire X%d reaches the chain window" % position)
		if not ready:
			break
		might.try_light_attack(Vector2.RIGHT)
	var x5_reaction: Dictionary = {}
	for frame in range(120):
		await physics_frame
		for reaction in reactions:
			if reaction["move_id"] == "fire_x5":
				x5_reaction = reaction
		if not x5_reaction.is_empty():
			break
	check(not x5_reaction.is_empty(), "Real Fire X5 animation/ShapeCast reaches the enemy")
	if not x5_reaction.is_empty():
		var difference: int = int(config["moves"]["fire_x5"]["impact"]) - enemy.get_poise()
		var expected_level := HitReaction.level_from_difference(difference, config["hit_reaction"]["combat_levels"])
		var tuning: Dictionary = config["hit_reaction"]["combat_levels"][expected_level - 1]
		check(x5_reaction["level"] == expected_level and is_equal_approx(x5_reaction["duration"], tuning["duration"]) and is_equal_approx(x5_reaction["distance"], tuning["distance"]), "X5 selects the configured difference band and tuning")
		for frame in range(180):
			await physics_frame
			if not enemy.hit_reaction.is_active():
				break
		var actual_distance: float = enemy.global_position.x - float(x5_reaction["start_x"])
		check(not enemy.hit_reaction.is_active() and absf(actual_distance - float(tuning["distance"])) < 0.2, "Enemy body completes the selected knockback distance")
		Probe.record("scenario_result", {"impact": config["moves"]["fire_x5"]["impact"], "difference": difference, "reaction_level": x5_reaction["level"], "duration": x5_reaction["duration"], "expected_distance": tuning["distance"], "actual_distance": actual_distance})
	gym.ambient_audio.stop()
	gym.music_audio.stop()
	await create_timer(0.15).timeout
	gym.free()
	await process_frame
