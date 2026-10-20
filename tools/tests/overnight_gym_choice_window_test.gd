extends "res://tools/tests/overnight_gym_poise_test.gd"
## A/B/C observation. Existing legality/rules; no direct player health/resources
## or action edits. Tutorial stage lifecycle calls are labeled control probes.

func parry_trigger_time() -> float:
	return enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact") - 0.12

func capture_frame_targets() -> Array:
	return [17, 47, 49, 60, 67, 78, 96, 98, 110, 146, 150, 152, 164, 185]

func on_reaction(snapshot: Dictionary) -> void:
	super.on_reaction(snapshot)
	events.back()["source_enemy_action_id"] = enemy.get("_attack_id")

func check_actual_formula() -> void:
	for event in results("enemy_contact_evaluated"):
		if bool(event.get("calculated", false)):
			check(int(event.value) == int(event.incoming_impact) - int(event.receiver_poise) - int(event.active_contribution), "Real Enemy contact retains receiver formula")
	var seen: Dictionary = {}
	for event in results("player_contact_evaluated"):
		var action_id := int(event.get("source_enemy_action_id", 0))
		if action_id > 0:
			check(not seen.has(action_id), "Committed Enemy action emits only one Player contact")
			seen[action_id] = true

func continuation_probe() -> void:
	await begin_case("continuous_melee_observation")
	for frame in range(1100):
		if gym.attempt_result != &"":
			break
		input(&"light_attack", false)
		var distance := gap()
		input(&"move_right", distance > 55.0)
		input(&"move_left", distance < -55.0)
		var queueable: bool = gym.player.combat.is_attack_playing() and gym.player.combat.get_normalized_attack_progress() >= 0.5 and gym.player.might.get("_pending_action").is_empty()
		if absf(distance) <= 65.0 and (gym.player.might.can_begin_defence() or queueable):
			input(&"light_attack", true)
		await tick()
	release_all()
	check_actual_formula()
	save_case({"policy": "unchanged simple melee distance/window policy, close initial setup; no resource or action state edits"})

func opener_disengage_cast() -> void:
	await begin_case("opener_READY_disengage_charge_cast_melee")
	await tap(&"light_attack")
	var ready_frame := -1
	var pivot_frame := -1
	var release_frame := -1
	var followup_sent := false
	for frame in range(220):
		if ready_frame < 0 and not results("orb_created").is_empty() and gym.player.might.can_begin_defence():
			ready_frame = Engine.get_physics_frames() - start_frame
			input(&"casting", true)
			input(&"move_left", true)
		if ready_frame >= 0 and pivot_frame < 0 and absf(gap()) >= 135.0:
			input(&"move_left", false)
			input(&"move_right", true)
			await tick()
			input(&"move_right", false)
			pivot_frame = Engine.get_physics_frames() - start_frame
		if pivot_frame >= 0 and release_frame < 0 and gym.player.magic.get_marked_count() > 0 and gym.player.might.can_begin_defence():
			input(&"casting", false)
			release_frame = Engine.get_physics_frames() - start_frame
		var action: Dictionary = gym.player.might.get("_current_action")
		if not followup_sent and str(action.get("kind", "")).begins_with("cast") and gym.player.combat.get_normalized_attack_progress() >= 0.6:
			await tap(&"light_attack")
			followup_sent = true
		await tick()
	release_all()
	check(results("orb_created").size() >= 1, "Opener genuinely generates a resource")
	check_actual_formula()
	save_case({"ready_frame": ready_frame, "pivot_frame": pivot_frame, "release_frame": release_frame, "followup_input_sent": followup_sent, "policy": "X1 without L2; after actual READY start L2 and retreat to gap>=135; pivot toward Enemy1 tick; when charged and READY release; queue melee only at actual Cast progress>=0.6; no initial resources/parry/action cancels"})

func committed_miss() -> void:
	await begin_case("committed_retreat_miss")
	var origin: Vector2 = enemy.get("_committed_attack_origin")
	var facing: Vector2 = enemy.get("_facing")
	await tick(10)
	input(&"move_left", true)
	await tick(30)
	input(&"move_left", false)
	for frame in range(90):
		await tick()
		if bool(enemy.get("_strike_emitted")):
			break
	check(gym.player.health.get_current() == 100.0 and results("player_contact_evaluated").is_empty(), "Real retreat evades committed hit query")
	check(Vector2(enemy.get("_committed_attack_origin")) == origin and Vector2(enemy.get("_facing")) == facing, "Attack preserves committed origin/facing after target leaves")
	var contact_state := record_state()
	await tick(20)
	check(phases.filter(func(phase): return phase.phase == "RECOVERY").is_empty(), "Active end equals clip end; no added recovery tail")
	save_case({"first_contact_state": contact_state, "setup": "gap56, real retreat after commitment; no hit or timer shortcuts"})

func tutorial_setup(label: String) -> void:
	release_all()
	if is_instance_valid(gym):
		for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
			audio.stop()
		current_scene = null
		gym.free()
		await process_frame
	gym = load("res://scenes/prototype_arena.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await process_frame
	await process_frame
	enemy = gym.get("_current_area").get_node("FinalEnemy")
	enemy.global_position.x = gym.player.global_position.x + 56.0
	scenario = label
	events = []
	phases = []
	samples = []
	capture_keys = {}
	last_phase = ""
	start_frame = Engine.get_physics_frames()
	gym.player.combat.outcome_published.connect(on_outcome)
	gym.player.health_resolver.reaction_evaluated.connect(on_reaction)
	enemy.health_resolver.reaction_evaluated.connect(enemy_result)
	await tick(3)

func tutorial_idle_lifecycle() -> void:
	await tutorial_setup("shared_tutorial_idle_and_retire_reactivate")
	var poise_before: int = enemy.get_poise()
	await tick(260)
	var cadence_samples := samples.duplicate(true)
	var cadence_events := events.duplicate(true)
	gym.get("_current_area").set_lifecycle(StageArea.Lifecycle.RETIRED)
	var hp: float = gym.player.health.get_current()
	await tick(90)
	check(enemy._state_name() == &"DORMANT" and not enemy.attack_animation.is_playing() and gym.player.health.get_current() == hp, "Tutorial retirement abandons pending attack")
	gym.get("_current_area").set_lifecycle(StageArea.Lifecycle.ACTIVE)
	await tick()
	check(enemy._state_name() == &"WINDUP" and enemy_clock() <= 0.017, "Tutorial reactivation begins a fresh native clock")
	check(enemy.get_poise() == poise_before, "Tutorial retains actual unchanged configured Poise")
	check_actual_formula()
	save_case({"context": "actual shared tutorial", "actual_poise": poise_before, "cadence_events_before_retirement": cadence_events, "cadence_samples_before_retirement": cadence_samples, "setup": "initial target placement; no player inputs in cadence phase; explicit stage lifecycle owner APIs afterward"})

func tutorial_real_death() -> void:
	await tutorial_setup("shared_tutorial_real_melee_defeat_lifecycle")
	var school_step := 0
	for frame in range(2400):
		if enemy.health.is_zero():
			break
		input(&"light_attack", false)
		input(&"move_right", gap() > 55.0)
		var can_queue: bool = gym.player.combat.is_attack_playing() and gym.player.combat.get_normalized_attack_progress() >= 0.5 and gym.player.might.get("_pending_action").is_empty()
		if absf(gap()) <= 65.0 and (gym.player.might.can_begin_defence() or can_queue):
			# Ordinary tutorial school keys counter its unchanged Endurance;
			# no direct selection/state/resource method is called.
			var press := InputEventKey.new()
			press.keycode = [KEY_1, KEY_2, KEY_3, KEY_4][school_step % 4]
			press.physical_keycode = press.keycode
			press.pressed = true
			Input.parse_input_event(press)
			await tick()
			var release := press.duplicate() as InputEventKey
			release.pressed = false
			Input.parse_input_event(release)
			school_step += 1
			input(&"light_attack", true)
		await tick()
	release_all()
	check(enemy.health.is_zero() and enemy._state_name() == &"DEAD", "Actual tutorial melee reaches Enemy defeat")
	gym.get("_current_area").set_lifecycle(StageArea.Lifecycle.RETIRED)
	gym.get("_current_area").set_lifecycle(StageArea.Lifecycle.ACTIVE)
	await tick(10)
	check(enemy._state_name() == &"DEAD" and not enemy.attack_animation.is_playing(), "Stage activation cannot resurrect defeated tutorial Enemy")
	check_actual_formula()
	save_case({"context": "actual shared tutorial", "actual_poise": enemy.get_poise(), "setup": "initial gap56; real school keys rotate Fire/Water/Air/Earth before melee; stage lifecycle probe after real defeat; unchanged Endurance; no HP/resource edits"})

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for argument in OS.get_cmdline_user_args():
		if argument == "--capture":
			capture_enabled = true
		elif argument.begins_with("--variant="):
			variant = argument.trim_prefix("--variant=")
		elif argument.begins_with("--output="):
			output_dir = argument.trim_prefix("--output=")
	if output_dir.is_empty():
		output_dir = ProjectSettings.globalize_path("res://choice-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: graphical capture needs actual renderer")
		quit(1)
		return
	report = {"variant": variant, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "capture_enabled": capture_enabled, "scenarios": []}
	await opener_probe("X_no_defence")
	await opener_probe("X_READY_parry")
	await opener_disengage_cast()
	if not capture_enabled:
		await opener_probe("X_READY_spacing")
		await opener_probe("parry_then_X_READY_spacing")
		await continuation_probe()
		await pressure_cycle()
		await pressure_cycle(true, true)
		await higher_melee(2)
		await higher_melee(5)
		await committed_miss()
		await tutorial_idle_lifecycle()
		await tutorial_real_death()
	release_all()
	report["checks"] = checks
	report["failures"] = failures
	report["captures"] = captures
	var file := FileAccess.open(output_dir.path_join(variant + "-choice-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d real-input choice-window checks (%s)" % [checks, variant])
	else:
		printerr("FAILED: %d / %d choice-window checks (%s)" % [failures.size(), checks, variant])
	quit(0 if failures.is_empty() else 1)
