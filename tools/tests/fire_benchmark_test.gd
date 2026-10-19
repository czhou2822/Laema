extends SceneTree

const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const BENCHMARK := "res://scenes/fire_benchmark.tscn"
var checks := 0
var failures: Array[String] = []
var benchmark
var json_hash: String
var mirror_hash: String


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: ", description)


func settle() -> void:
	for index in range(5):
		await process_frame


func opponent():
	return benchmark.get("_current_area").get_targets()[0]


func freeze_fighters() -> void:
	opponent().set_physics_process(false)
	benchmark.player.movement.set_physics_process(false)


func expect_fresh() -> void:
	check(benchmark.attempt_result == &"" and not benchmark.get("_result_layer").visible, "Fresh attempt has no result modal")
	check(benchmark.player.health.get_current() == 100.0 and opponent().health.get_current() == 200.0, "Fresh attempt restores both health pools")
	check(benchmark.player.magic.get_snapshot().is_empty() and benchmark.player.heat.get_value() == 0.0, "Fresh attempt has no orbs or Heat")
	check(not benchmark.player.hit_reaction.is_active() and not opponent().hit_reaction.is_active(), "Fresh attempt clears reactions")
	check(benchmark.player.combat.get_active_school() == &"fire", "Fresh attempt selects Fire")
	check(benchmark.player.might.get("_buffered_request").is_empty() and not benchmark.player.combat.is_combo_active(), "Fresh attempt has no chain or buffered action")
	check(benchmark.player.process_mode != Node.PROCESS_MODE_DISABLED and bool(opponent().get("_stage_active")), "Fresh attempt enables the fighters")


func retry() -> void:
	benchmark._restart_current_encounter()
	await settle()
	benchmark = current_scene
	freeze_fighters()
	expect_fresh()


func damage(target: Entity, source: Entity, amount: float, impact: int = 0) -> HealthResult:
	return target.receive_health_event(HealthEvent.damage(source, target, amount, impact, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT))


func stop_audio(arena: Node) -> void:
	for audio in arena.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()


func projectile_count() -> int:
	var count := 0
	for child in benchmark.get_children():
		if child is SpellProjectile:
			count += 1
	return count


func _run() -> void:
	root.size = Vector2i(1280, 720)
	json_hash = FileAccess.get_sha256("res://config/prototype_combat.json")
	mirror_hash = FileAccess.get_sha256("res://config/combat_tuning.tres")
	var ordinary: Dictionary = Loader.load_and_validate("res://config/prototype_combat.json")["data"]
	benchmark = load(BENCHMARK).instantiate()
	root.add_child(benchmark)
	current_scene = benchmark
	await settle()
	freeze_fighters()
	var config: Dictionary = benchmark.get("_config")
	check(Loader.validate(config)["ok"], "Encounter profile passes the real validator")
	check(benchmark.get("_current_area").get_targets().size() == 1, "One opponent and no practice targets")
	var authored_room = load("res://scenes/stages/fire_benchmark_area.tscn").instantiate()
	check(absf(authored_room.get_node("FinalEnemy").position.x - authored_room.get_node("PlayerSpawn").position.x) == 160.0, "Existing room authors the fighters 160 pixels apart")
	authored_room.free()
	check(config["enemy_ai"]["poise"] == 1 and config["moves"]["final_enemy_attack"]["impact"] == 20, "Local provisional enemy tuning is applied")
	check(not config["combat"]["collect_orb_without_contact"] and not config["player"]["one_hp_floor_enabled"], "Real contact and defeat are enabled locally")
	check(not opponent().refills_at_zero and opponent().is_final_enemy, "Killable opponent retains final-enemy completion identity")
	check(not opponent().status_controller.get("_endurance_enabled"), "Single-school opponent has no Endurance")
	check(opponent().bt_player.behavior_tree.resource_path == "res://ai/trees/final_enemy.tres", "Opponent reuses the existing committed melee tree")
	check(benchmark.hud.objective_widget.get("_panel").get_minimum_size().x <= benchmark.hud.objective_widget.size.x, "Benchmark instruction fits the existing objective panel")
	expect_fresh()

	# Exercise the actual scene input route, including the controller/keyboard actions.
	for school in [&"select_water", &"select_air", &"select_earth", &"select_fire"]:
		var event := InputEventAction.new()
		event.action = school
		event.pressed = true
		Input.parse_input_event(event)
		await process_frame
		check(benchmark.player.combat.get_active_school() == &"fire", "School action stays Fire: " + str(school))
		Input.action_release(school)
	var keyboard := InputEventKey.new()
	keyboard.keycode = KEY_2
	keyboard.pressed = true
	Input.parse_input_event(keyboard)
	await process_frame
	check(benchmark.player.combat.get_active_school() == &"fire", "Keyboard school switch is blocked")
	keyboard.pressed = false
	Input.parse_input_event(keyboard)
	var controller := InputEventJoypadButton.new()
	controller.button_index = JOY_BUTTON_DPAD_DOWN
	controller.pressed = true
	Input.parse_input_event(controller)
	await process_frame
	check(benchmark.player.combat.get_active_school() == &"fire", "Controller school switch is blocked")
	controller.pressed = false
	Input.parse_input_event(controller)
	# A real missed X must not generate the debug orb.
	benchmark.player.might.try_light_attack(Vector2.LEFT)
	benchmark.player.might._physics_process(0.14)
	check(benchmark.player.magic.get_snapshot().is_empty(), "Missed melee creates no orb")
	check(not benchmark.player.might.can_begin_defence(), "Parry cannot cancel an active attack")
	benchmark.player.might._physics_process(0.5)
	check(benchmark.player.might.can_begin_defence(), "Parry becomes available after an unpreserved action ends")
	benchmark.player.magic.start_charging()
	benchmark.player.might.try_light_attack(Vector2.LEFT)
	benchmark.player.might._physics_process(0.7)
	check(not benchmark.player.combat.is_attack_playing() and not benchmark.player.might.can_begin_defence(), "Charging-preserved chain retains existing READY restriction")
	benchmark.player.reset_for_stage()

	# Parry negates one incoming event and preserves current Heat/charged resources.
	benchmark.player.magic.add_orb(&"fire")
	benchmark.player.magic.start_charging()
	benchmark.player.magic._process(0.5)
	benchmark.player.heat.gain_from_commit(5)
	benchmark.player.combat._try_defend()
	var parry := damage(benchmark.player, opponent(), 10.0, 20)
	check(parry.outcome == HealthResult.Outcome.PARRIED and benchmark.player.health.get_current() == 100.0, "Fire parry nullifies the incoming strike")
	check(benchmark.player.magic.get_marked_count() == 1 and benchmark.player.heat.get_value() >= 9.9, "Parry preserves charged orbs and Heat")
	benchmark.player.combat._release_defend()
	benchmark.player.combat._try_defend()
	benchmark.player.defence.update(0.21, benchmark.player.heat)
	var late := damage(benchmark.player, opponent(), 10.0, 20)
	check(late.outcome == HealthResult.Outcome.APPLIED and benchmark.player.health.get_current() == 90.0, "Expired parry is vulnerable")
	check(benchmark.player.magic.get_marked_count() == 0 and benchmark.player.heat.get_value() < 5.1, "Applied hit removes charged orbs and five Heat")
	await retry()
	# Resolve the real authored ShapeCast, not just a synthetic damage event.
	opponent().global_position = benchmark.player.global_position + Vector2(60.0, 16.0)
	await physics_frame
	opponent().ai_begin_windup(benchmark.player, 72.0, 0.6)
	opponent().attack_animation.advance(0.6)
	opponent().ai_strike(benchmark.player, 10.0, 20)
	check(benchmark.player.health.get_current() == 90.0, "Committed enemy geometry can damage the benchmark Player")
	await retry()

	# No level scaling or hidden Fire DoT is introduced; high charge buys Heat.
	for count in [1, 5]:
		benchmark.player.reset_for_stage()
		for index in range(count):
			benchmark.player.magic.add_orb(&"fire")
		benchmark.player.magic.start_charging()
		benchmark.player.magic._process(0.5 * count)
		var committed: Dictionary = benchmark.player.magic.commit_cast(&"fire", false, 1.0, Vector2.RIGHT, benchmark.player)
		var payload: Dictionary = benchmark.player.magic.launch_committed_cast(committed["commit_id"])
		var before: float = opponent().health.get_current()
		benchmark.player.magic.resolve_projectile_impact(opponent(), opponent().global_position, payload)
		check(is_equal_approx(before - opponent().health.get_current(), 10.0), "Generic Cast keeps 10 damage at level " + str(count))
		check(is_equal_approx(benchmark.player.heat.get_value(), 2.0 * count), "Cast commitment grants existing consumed-count Heat")
		check(opponent().status_controller.get("_dot_instances").is_empty(), "Fire Cast adds no deferred DoT")
	# More than ten same-school hits remain effective without changing completion events.
	for index in range(11):
		var event := HealthEvent.damage(benchmark.player, opponent(), 1.0, 0, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT, Vector2.ZERO, 100 + index, [&"fire"])
		check(opponent().receive_health_event(event).health_delta == -1.0, "Same-school hit remains effective: " + str(index + 1))

	# Every in-game persistence route refuses writes, including the shared mirror.
	config = benchmark.get("_config")
	check(not benchmark._save_runtime_tuning()["ok"], "In-game Save refuses shared JSON writes")
	check(not benchmark.combat_tuning.save_resource()["ok"], "Mirror save is disabled")
	benchmark.get("_developer_overlay")._on_save_pressed()
	check(benchmark.get("_developer_overlay").get("_status_label").text.contains("run-only"), "Portal Save reports that benchmark tuning is run-only")
	check(not benchmark.apply_saved_developer_config(config.duplicate(true))["ok"], "Shared editor apply cannot replace the encounter profile")
	var prior_poise: int = benchmark.combat_tuning.settings.player_poise
	benchmark.combat_tuning.settings.player_poise = 3
	await process_frame
	check(benchmark.get("_config")["player"]["poise"] == 3, "Remote Inspector tuning remains usable in memory")
	benchmark.combat_tuning.settings.player_poise = prior_poise
	config["combat"]["collect_orb_without_contact"] = true
	check(not benchmark._apply_runtime_tuning()["ok"], "Portal cannot enable contact-free orbs")
	config["combat"]["collect_orb_without_contact"] = false
	config["player"]["one_hp_floor_enabled"] = true
	check(not benchmark._apply_runtime_tuning()["ok"], "Portal cannot disable genuine defeat")
	config["player"]["one_hp_floor_enabled"] = false
	var bridge := CombatTuningBridge.new()
	bridge.persistence_enabled = false
	bridge.settings = benchmark.combat_tuning.settings.duplicate(true)
	root.add_child(bridge)
	var editor_before: int = bridge.settings.player_poise
	bridge.settings.player_poise = editor_before + 1
	bridge._apply_editor_change()
	check(bridge.settings.player_poise == editor_before, "Offline Inspector mirror edits are rejected without persistence")
	bridge.free()

	# Completion is observed through the existing real Enemy -> StageDirector path.
	damage(opponent(), benchmark.player, 1000.0)
	await settle()
	check(benchmark.attempt_result == &"victory" and opponent().health.is_zero(), "Enemy defeat completes the encounter without refill")
	check(benchmark.get("_result_layer").visible and benchmark.player.process_mode == Node.PROCESS_MODE_DISABLED, "Victory shows result and freezes combat")
	check(projectile_count() == 0, "Victory clears root-owned projectiles")
	check(benchmark.get("_retry_button").has_focus(), "Result focuses the controller/keyboard Retry button")
	benchmark.get("_retry_button").pressed.emit()
	await settle()
	benchmark = current_scene
	freeze_fighters()
	expect_fresh()
	damage(benchmark.player, opponent(), 1000.0, 20)
	await settle()
	check(benchmark.attempt_result == &"defeat" and benchmark.player.health.is_zero(), "Zero Player health produces genuine defeat")
	check(benchmark.get("_result_layer").visible and benchmark.player.process_mode == Node.PROCESS_MODE_DISABLED, "Defeat freezes actors and shows Retry")
	await retry()

	# Pause-menu retry uses the same fresh-scene path, rather than the ordinary Gym reload.
	benchmark.player.magic.add_orb(&"fire")
	benchmark.player.heat.gain_from_commit(2)
	benchmark.pause_menu.set_open(true)
	benchmark.pause_menu.restart_requested.emit()
	await settle()
	benchmark = current_scene
	freeze_fighters()
	check(not paused, "Pause-menu retry resumes the new attempt")
	expect_fresh()
	stop_audio(benchmark)
	await create_timer(0.3).timeout
	benchmark.free()
	current_scene = null

	# Original Gym/tutorial configuration and mirror remain unchanged after benchmark use.
	for path in ["res://scenes/gym.tscn", "res://scenes/prototype_arena.tscn"]:
		var arena = load(path).instantiate()
		root.add_child(arena)
		await settle()
		check(arena.get("_config") == ordinary, "Ordinary scene retains shared configuration: " + path)
		check(arena.combat_tuning.persistence_enabled, "Ordinary Inspector persistence remains enabled")
		check(arena.get("_current_area").get_targets()[0].status_controller.get("_endurance_enabled") == bool(arena.get("_current_area").get_targets()[0].is_final_enemy), "Ordinary Endurance policy is unchanged")
		stop_audio(arena)
		await create_timer(0.3).timeout
		arena.free()
	check(FileAccess.get_sha256("res://config/prototype_combat.json") == json_hash, "Shared JSON bytes are unchanged")
	check(FileAccess.get_sha256("res://config/combat_tuning.tres") == mirror_hash, "Shared Inspector mirror bytes are unchanged")
	await process_frame
	if failures.is_empty():
		print("PASSED: %d Fire benchmark checks" % checks)
		quit(0)
	else:
		printerr("FAILED: %d / %d Fire benchmark checks" % [failures.size(), checks])
		quit(1)
