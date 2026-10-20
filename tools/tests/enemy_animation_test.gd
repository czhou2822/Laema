extends SceneTree

const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")

var checks := 0
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: " + description)


func start_attack(gym: Node, enemy: Entity) -> void:
	gym.player.reset_for_stage()
	enemy._reset_ai_execution()
	enemy.health.reset_to_maximum()
	enemy.global_position = gym.player.global_position + Vector2(60, 16)
	enemy._physics_process(0.0)


func tuning_fixture(tutorial: bool):
	var scene = load("res://scenes/prototype_arena.tscn" if tutorial else "res://scenes/gym.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	for frame in range(5):
		await process_frame
	var enemy = scene.get("_current_area").get_node("FinalEnemy")
	enemy.set_physics_process(false)
	scene.player.movement.set_physics_process(false)
	scene.player.might.set_physics_process(false)
	scene.player.combat.set_process(false)
	start_attack(scene, enemy)
	enemy._physics_process(0.2)
	return scene


func release_fixture(scene: Node) -> void:
	for audio in scene.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	OS.delay_msec(20)
	current_scene = null
	scene.free()
	await process_frame


func check_initial_tuning_snapshot() -> void:
	# Configuration/lifecycle API probes. Manual physics/HealthEvent setup below
	# is not real-input gameplay evidence; the separate overnight suite owns that.
	for tutorial in [false, true]:
		var context := "tutorial" if tutorial else "Gym"
		for key in ["enabled", "aggro_range", "attack_range", "movement_speed", "damage"]:
			var scene = await tuning_fixture(tutorial)
			var enemy = scene.get("_current_area").get_node("FinalEnemy")
			var config: Dictionary = scene.get("_config")
			var old_value = config["enemy_ai"][key]
			var before_id: int = enemy.get("_attack_id")
			config["enemy_ai"][key] = false if key == "enabled" else old_value + (12 if key in ["aggro_range", "attack_range"] else 1)
			check(enemy.get("_ai_config")[key] == old_value, "Initial cached setting survives live mutation: %s/%s" % [context, key])
			check(scene._apply_runtime_tuning()["ok"], "Normal parent apply validates: %s/%s" % [context, key])
			check(int(enemy.get("_attack_id")) == 0 and not enemy.attack_animation.is_playing(), "First changed decision setting cancels pending windup: %s/%s" % [context, key])
			if key == "enabled":
				var hp: float = scene.player.health.get_current()
				enemy.set_physics_process(false)
				enemy._physics_process(2.0)
				check(not enemy.get("_stage_enabled") and enemy._state_name() == &"DORMANT" and scene.player.health.get_current() == hp, "First disable prevents the old strike: " + context)
				enemy.hit_reaction.execute_combat(1, Vector2.RIGHT)
				var remaining: float = enemy.hit_reaction.get("_remaining")
				scene._apply_runtime_tuning()
				check(enemy.hit_reaction.is_invincible() and is_equal_approx(enemy.hit_reaction.get("_remaining"), remaining), "Already-disabled no-op preserves existing reaction lifetime: " + context)
				config["enemy_ai"]["enabled"] = true
				scene._apply_runtime_tuning()
				enemy.set_physics_process(false)
				enemy._physics_process(0.0)
				check(enemy.get("_stage_enabled") and int(enemy.get("_attack_id")) > before_id and enemy_clock_zero(enemy), "Re-enable reassesses with a new action: " + context)
			else:
				check(enemy.bt_player.blackboard.get_var(StringName(key)) == config["enemy_ai"][key], "Changed setting reaches existing blackboard consumer: %s/%s" % [context, key])
				enemy.set_physics_process(false)
				if key == "aggro_range":
					enemy.global_position.x = scene.player.global_position.x + float(old_value) + 6.0
				elif key == "attack_range":
					enemy.global_position.x = scene.player.global_position.x + float(old_value) + 6.0
				elif key == "movement_speed":
					enemy.global_position.x = scene.player.global_position.x + 200.0
				enemy._physics_process(0.0)
				if key == "aggro_range":
					check(enemy._state_name() == &"APPROACH", "New awareness range admits the formerly out-of-range target: " + context)
				elif key == "attack_range":
					check(enemy._state_name() == &"WINDUP", "New attack range commits at the non-default distance: " + context)
				elif key == "movement_speed":
					enemy._physics_process(0.01)
					check(is_equal_approx(absf(enemy.velocity.x), float(config["enemy_ai"][key])), "Approach consumes new movement speed: " + context)
				else:
					var hp: float = scene.player.health.get_current()
					enemy._physics_process(enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact") + 0.01)
					check(is_equal_approx(hp - scene.player.health.get_current(), float(config["enemy_ai"]["damage"])), "Next committed contact consumes new damage: " + context)
			await release_fixture(scene)
		# First no-op and non-decision changes retain the current committed action.
		for category in ["unchanged", "geometry", "reaction", "legacy"]:
			var scene = await tuning_fixture(tutorial)
			var enemy = scene.get("_current_area").get_node("FinalEnemy")
			var config: Dictionary = scene.get("_config")
			var id: int = enemy.get("_attack_id")
			var position: float = enemy.attack_animation.current_animation_position
			var origin: Vector2 = enemy.get("_committed_attack_target_position")
			if category == "geometry":
				config["enemy_ai"]["hitbox_reach"] += 5.0
			elif category == "reaction":
				config["hit_reaction"]["combat_levels"][0]["duration"] += 0.01
			else:
				if category == "legacy":
					config["enemy_ai"]["windup_duration"] = 23.0
					config["enemy_ai"]["recovery_duration"] = 37.0
			check(scene._apply_runtime_tuning()["ok"], "Nonreset apply validates: %s/%s" % [context, category])
			check(int(enemy.get("_attack_id")) == id and is_equal_approx(enemy.attack_animation.current_animation_position, position), "Non-decision apply retains action/clock: %s/%s" % [context, category])
			check(Vector2(enemy.get("_committed_attack_target_position")) == origin, "Nonreset apply retains committed geometry: %s/%s" % [context, category])
			if category == "geometry":
				enemy.cancel_combat_attack()
				enemy.set_physics_process(false)
				enemy._physics_process(0.0)
				check(is_equal_approx(Vector2(enemy.get("_committed_attack_target_position")).length(), float(config["enemy_ai"]["hitbox_reach"])), "Next attack consumes geometry-only edit: " + context)
			await release_fixture(scene)
		for phase in ["active", "recovery", "reaction", "dead", "retired", "initial_disabled"]:
			var scene = await tuning_fixture(tutorial)
			var area = scene.get("_current_area")
			var enemy = area.get_node("FinalEnemy")
			var config: Dictionary = scene.get("_config")
			if phase == "active":
				enemy._physics_process(enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"active_start") - enemy.attack_animation.current_animation_position + 0.01)
			elif phase == "recovery":
				# Private tail beyond authored active_end; stock1.3 has no tail.
				var private_clock: Animation = enemy.attack_animation.get_animation(&"melee_swing")
				private_clock.length = private_clock.get_marker_time(&"active_end") + 0.3
				enemy._physics_process(private_clock.get_marker_time(&"active_end") - enemy.attack_animation.current_animation_position + 0.1)
			elif phase == "reaction":
				enemy.hit_reaction.execute_combat(1, Vector2.RIGHT)
			elif phase == "dead":
				enemy.receive_health_event(HealthEvent.damage(scene.player, enemy, 2000.0, 0, HealthEvent.Delivery.DIRECT, &""))
			elif phase == "retired":
				area.set_lifecycle(StageArea.Lifecycle.RETIRED)
			else:
				enemy.free()
				config["enemy_ai"]["enabled"] = false
				enemy = load("res://scenes/enemy/combat_enemy.tscn").instantiate()
				enemy.name = "FinalEnemy"
				area.add_child(enemy)
				enemy.configure(config)
				enemy.set_stage_active(true)
				check(not enemy.get("_stage_enabled") and enemy._state_name() == &"DORMANT", "Initially disabled configuration stays dormant: " + context)
			var expected_phase := {"active": &"ACTIVE", "recovery": &"RECOVERY", "reaction": &"HIT_REACTING", "dead": &"DEAD", "retired": &"DORMANT", "initial_disabled": &"DORMANT"}
			check(enemy._state_name() == expected_phase[phase], "Lifecycle probe reached its named phase: %s/%s" % [context, phase])
			config["enemy_ai"]["enabled"] = false
			check(scene._apply_runtime_tuning()["ok"], "Lifecycle disable validates: %s/%s" % [context, phase])
			check(not enemy.get("_stage_enabled") and int(enemy.get("_attack_id")) == 0 and not enemy.attack_animation.is_playing(), "Disable abandons current lifecycle action: %s/%s" % [context, phase])
			if phase == "reaction":
				check(not enemy.hit_reaction.is_active(), "Changed decision tuning retains existing reaction-reset policy: " + context)
			config["enemy_ai"]["enabled"] = true
			scene._apply_runtime_tuning()
			if phase in ["dead", "retired"]:
				check(not enemy.get("_stage_enabled") and enemy._state_name() == (&"DEAD" if phase == "dead" else &"DORMANT"), "Enable cannot resurrect dead/retired actor: %s/%s" % [context, phase])
			else:
				check(enemy.get("_stage_enabled") and enemy._state_name() == &"IDLE", "Enable uses existing reset/reassessment policy: %s/%s" % [context, phase])
			await release_fixture(scene)


func enemy_clock_zero(enemy) -> bool:
	return is_zero_approx(enemy.attack_animation.current_animation_position)


func _run() -> void:
	await check_initial_tuning_snapshot()
	var source_hash := Store.source_hash()
	var gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	for frame in range(5):
		await process_frame
	var enemy = gym.get("_current_area").get_node("FinalEnemy")
	enemy.set_physics_process(false)
	enemy.set_process(false)
	gym.player.movement.set_physics_process(false)
	gym.player.might.set_physics_process(false)
	await physics_frame
	var config: Dictionary = gym.get("_config")
	check(not gym.get_property_list().any(func(property): return property["name"] in ["opponent_windup", "opponent_recovery"]), "Gym has no windup/recovery override property")
	var fields := Catalog.fields(config, "enemy_ai")
	check(not fields.any(func(field): return field["id"] in ["enemy_ai.windup_duration", "enemy_ai.recovery_duration"]), "Both Portal surfaces omit the obsolete Enemy timing controls")
	check(not enemy.bt_player.blackboard.has_var(&"windup_duration") and not enemy.bt_player.blackboard.has_var(&"recovery_duration"), "Behavior tree has no independent windup/recovery timers")
	# Old profiles remain readable, but their timing values never rescale playback.
	config["enemy_ai"]["windup_duration"] = 90.0
	config["enemy_ai"]["recovery_duration"] = 90.0
	enemy.apply_runtime_tuning()
	start_attack(gym, enemy)
	await physics_frame
	check(enemy.attack_animation.speed_scale == 1.0, "Enemy plays the saved animation at authored speed despite legacy profile values")
	var stock: Animation = enemy.attack_animation.get_animation(&"melee_swing")
	check(is_equal_approx(stock.get_marker_time(&"active_start"), 1.1) and is_equal_approx(stock.get_marker_time(&"contact"), 1.1) and is_equal_approx(stock.get_marker_time(&"active_end"), 1.3) and is_equal_approx(stock.length, 1.3), "Retained stock markers1.1/end1.3 have no recovery tail")
	enemy._physics_process(1.09)
	check(enemy.get("_state") == enemy.State.WINDUP and gym.player.health.get_current() == 100.0, "Stock animation remains in windup before its1.1 marker")
	enemy._physics_process(0.02)
	check(enemy.get("_state") == enemy.State.ACTIVE and gym.player.health.get_current() == 90.0, "Stock animation contacts at1.1 without the Gym multiplier")
	enemy._physics_process(0.2)
	check(enemy.get("_state") == enemy.State.IDLE and not enemy.attack_animation.is_playing(), "Stock animation ends at1.3 with no added recovery wait")
	# Different authored boundaries expose code that still relies on old timers.
	var source_clock: Animation = enemy.attack_animation.get_animation(&"melee_swing")
	var clock := Animation.new()
	for track in range(source_clock.get_track_count()):
		source_clock.copy_track(track, clock)
	clock.add_marker(&"active_start", 0.31)
	clock.add_marker(&"contact", 0.37)
	clock.add_marker(&"active_end", 0.48)
	clock.length = 0.81
	var library: AnimationLibrary = enemy.attack_animation.get_animation_library(&"")
	library.remove_animation(&"melee_swing")
	library.add_animation(&"melee_swing", clock)
	start_attack(gym, enemy)
	await physics_frame
	enemy._physics_process(0.15)
	var action_id: int = enemy.get("_attack_id")
	config["enemy_ai"]["windup_duration"] = 13.0
	config["enemy_ai"]["recovery_duration"] = 17.0
	enemy.apply_runtime_tuning()
	check(enemy.get("_attack_id") == action_id and is_equal_approx(enemy.attack_animation.current_animation_position, 0.15), "Changing obsolete profile timings does not reset an attack")
	enemy._physics_process(0.15)
	check(enemy.get("_state") == enemy.State.WINDUP, "Custom windup waits for the native active_start marker")
	enemy._physics_process(0.02)
	check(enemy.get("_state") == enemy.State.ACTIVE and gym.player.health.get_current() == 100.0 and enemy.get_melee_snapshot()["active"], "Active frames can begin before contact without an early hit")
	enemy._physics_process(0.06)
	check(gym.player.health.get_current() == 90.0 and enemy.get("_strike_emitted"), "Custom contact marker applies one hit")
	enemy._physics_process(0.11)
	check(enemy.get("_state") == enemy.State.RECOVERY and enemy.attack_animation.is_playing() and enemy.get_melee_snapshot().is_empty(), "After active_end, authored recovery keeps playing and contributes no active move Impact")
	enemy._process(0.0)
	check(enemy.body_visual.texture.resource_path.ends_with("Attack_1.png"), "Recovery preserves the native animation artwork")
	enemy._physics_process(0.2)
	check(enemy.get("_state") == enemy.State.RECOVERY and gym.player.health.get_current() == 90.0, "Recovery lasts to the authored clip end without repeating contact")
	enemy._physics_process(0.13)
	check(enemy.get("_state") == enemy.State.IDLE and not enemy.attack_animation.is_playing(), "Custom recovery completes at animation length")
	enemy._physics_process(0.0)
	check(enemy.get("_state") == enemy.State.WINDUP and enemy.get("_attack_id") > action_id and is_zero_approx(enemy.attack_animation.current_animation_position), "Next behavior-tree cycle starts a fresh animation")
	start_attack(gym, enemy)
	await physics_frame
	enemy._physics_process(2.0)
	check(gym.player.health.get_current() == 90.0 and enemy.get("_hit_targets").size() == 1, "A frame crossing contact and animation end still applies exactly one connected hit")
	check(enemy.get("_state") == enemy.State.IDLE and not enemy.attack_animation.is_playing(), "A large frame finishes authored recovery without starting a second attack")
	# Cancellation must prevent the future native contact from firing.
	start_attack(gym, enemy)
	await physics_frame
	enemy._physics_process(0.2)
	var result: HealthResult = enemy.receive_health_event(HealthEvent.damage(gym.player, enemy, 1.0, 60, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT))
	check(result.outcome == HealthResult.Outcome.APPLIED and enemy.hit_reaction.is_invincible() and not enemy.attack_animation.is_playing(), "Qualifying hurt interrupts the native animation")
	enemy._physics_process(0.5)
	check(gym.player.health.get_current() == 100.0 and enemy.get("_attack_id") == 0, "Interrupted attack cannot emit its later contact")
	start_attack(gym, enemy)
	enemy.set_stage_active(false)
	enemy._physics_process(2.0)
	check(gym.player.health.get_current() == 100.0 and not enemy.attack_animation.is_playing() and enemy.get("_state") == enemy.State.DORMANT, "Stage deactivation cancels native playback and pending damage")
	check(Store.source_hash() == source_hash, "Timing checks and private animation edits never save shared data")
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d authored Enemy timing checks" % checks)
	quit(0 if failures.is_empty() else 1)
