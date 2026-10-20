extends SceneTree
## Current retained regressions, including native-marker-relative parry.
## Archived Round0/fixed0.68 observations keep their original policy identity.
## Run in an isolated imported project with --fixed-fps 60.
## Setup: fresh actual Gym, optional initial X gap. Gameplay: InputMap-bound
## keyboard/joypad events only; no direct combat, timer or physics method calls.

var gym
var enemy
var checks := 0
var failures: Array[String] = []
var report: Dictionary = {"engine": Engine.get_version_info(), "scenarios": []}
var events: Array = []
var phases: Array = []
var scenario := ""
var start_frame := 0
var last_phase := ""
var buttons: Dictionary = {}
var approach_flips := 0
var previous_approach_direction := 0

func enemy_clock() -> float:
	return enemy.attack_animation.current_animation_position if enemy.attack_animation.current_animation != &"" else -1.0

func _initialize() -> void:
	call_deferred("_run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("FAILED: ", label)

func input(action: StringName, pressed: bool) -> void:
	if buttons.get(action, false) == pressed:
		return
	buttons[action] = pressed
	var event: InputEvent
	if action in [&"move_left", &"move_right", &"ui_accept"]:
		var key := InputEventKey.new()
		key.physical_keycode = KEY_A if action == &"move_left" else (KEY_D if action == &"move_right" else KEY_ENTER)
		key.keycode = key.physical_keycode
		key.pressed = pressed
		event = key
	elif action == &"casting":
		var axis := InputEventJoypadMotion.new()
		axis.device = 0
		axis.axis = JOY_AXIS_TRIGGER_LEFT
		axis.axis_value = 1.0 if pressed else 0.0
		event = axis
	else:
		var button := InputEventJoypadButton.new()
		button.device = 0
		button.button_index = JOY_BUTTON_X if action == &"light_attack" else JOY_BUTTON_LEFT_SHOULDER
		button.pressed = pressed
		event = button
	Input.parse_input_event(event)

func release_all() -> void:
	for action in buttons.keys():
		input(action, false)

func frames(count: int) -> void:
	for frame in range(count):
		await physics_frame
		await process_frame
		if is_instance_valid(enemy):
			var phase: String = enemy._state_name()
			if phase == "APPROACH" and not is_zero_approx(enemy.velocity.x):
				var direction := int(signf(enemy.velocity.x))
				if previous_approach_direction != 0 and direction != previous_approach_direction:
					approach_flips += 1
				previous_approach_direction = direction
			if phase != last_phase:
				phases.append({"frame": Engine.get_physics_frames() - start_frame, "phase": phase, "gap": gap(), "clock": enemy_clock(), "enemy_x": enemy.global_position.x, "player_x": gym.player.global_position.x, "committed_origin": str(enemy.get("_committed_attack_origin")), "facing": str(enemy.get("_facing"))})
				last_phase = phase

func gap() -> float:
	return enemy.global_position.x - gym.player.global_position.x

func on_outcome(outcome) -> void:
	var data: Dictionary = outcome.snapshot()
	data["frame"] = Engine.get_physics_frames() - start_frame
	events.append(data)

func on_reaction(snapshot: Dictionary) -> void:
	var data := snapshot.duplicate(true)
	data["kind"] = "player_contact_evaluated"
	data["frame"] = Engine.get_physics_frames() - start_frame
	events.append(data)

func fresh(label: String, initial_gap := -1.0) -> void:
	release_all()
	if is_instance_valid(gym):
		for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
			audio.stop()
		current_scene = null
		gym.free()
		await process_frame
	gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await process_frame
	await process_frame
	enemy = gym.get("_current_area").get_targets()[0]
	if initial_gap >= 0.0:
		enemy.global_position.x = gym.player.global_position.x + initial_gap
	scenario = label
	start_frame = Engine.get_physics_frames()
	events = []
	phases = []
	last_phase = ""
	approach_flips = 0
	previous_approach_direction = 0
	gym.player.combat.outcome_published.connect(on_outcome)
	gym.player.health_resolver.reaction_evaluated.connect(on_reaction)
	await frames(3)

func count_event(kind: String) -> int:
	return events.filter(func(event): return event.get("kind") == kind).size()

func finish(extra: Dictionary = {}) -> void:
	var result := {"scenario": scenario, "frames": Engine.get_physics_frames() - start_frame, "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "charged": gym.player.magic.get_marked_count(), "gap": gap(), "result": gym.attempt_result, "approach_direction_reversals": approach_flips, "events": events.duplicate(true), "phases": phases.duplicate(true)}
	result.merge(extra)
	report["scenarios"].append(result)
	print("OBSERVATION: ", scenario, " ", JSON.stringify({"frames": result.frames, "player_hp": result.player_hp, "enemy_hp": result.enemy_hp, "orbs": result.orbs, "gap": result.gap, "result": result.result, "casts": count_event("cast_launched"), "contacts": count_event("light_contact_resolved")}))

func tap(action: StringName) -> void:
	input(action, true)
	await frames(1)
	input(action, false)

func _run() -> void:
	root.size = Vector2i(1280, 720)
	await fresh("movement_default_spawn")
	var origin: Vector2 = gym.player.global_position
	input(&"move_right", true)
	await frames(10)
	input(&"move_right", false)
	check(gym.player.global_position.x - origin.x >= 40.0, "Bound D movement advances real Player body")
	finish({"movement_x": gym.player.global_position.x - origin.x})

	await fresh("charge_melee_cast_followup", 56.0)
	input(&"casting", true)
	await frames(1)
	await tap(&"light_attack")
	await frames(32)
	check(count_event("orb_created") > 0, "Real X contact generates an orb")
	check(gym.player.magic.get_marked_count() > 0, "Held L2 charges during real melee playback")
	var release_frame := Engine.get_physics_frames() - start_frame
	input(&"casting", false)
	await frames(3)
	var accepted_after_release: int = count_event("cast_committed")
	await frames(65)
	await tap(&"light_attack")
	await frames(65)
	check(accepted_after_release > 0 and count_event("cast_launched") > 0, "Release L2 commits and launches through normal gameplay")
	check(gym.player.might.get("_current_action").is_empty() and gym.player.might.get("_pending_action").is_empty(), "Cast and subsequent melee finish without stale action occupancy")
	finish({"release_frame": release_frame})

	await fresh("stationary_enemy_cadence_and_defeat", 60.0)
	await frames(2400)
	check(gym.attempt_result == &"defeat", "Natural Enemy strikes produce Gym defeat")
	finish()
	await tap(&"ui_accept")
	await frames(6)
	gym = current_scene
	enemy = gym.get("_current_area").get_targets()[0]
	check(gym.attempt_result == &"" and gym.player.health.get_current() == 100.0 and enemy.health.get_current() == 200.0 and gym.player.magic.get_snapshot().is_empty(), "Bound Enter retries actual scene and clears encounter state")

	await fresh("committed_miss_retreat", 60.0)
	await frames(12)
	var committed_origin: Vector2 = enemy.get("_committed_attack_origin")
	input(&"move_left", true)
	await frames(30)
	input(&"move_left", false)
	await frames(18)
	check(gym.player.health.get_current() == 100.0, "Real retreat evades first committed strike")
	finish({"initial_committed_origin": str(committed_origin)})

	await fresh("fire_parry_punish", 60.0)
	# Current regression is marker-relative; archived fixed0.68 reports stay historical.
	while enemy_clock() < enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact") - 0.12:
		await frames(1)
	input(&"defend", true)
	await frames(10)
	input(&"defend", false)
	await frames(2)
	check(gym.player.health.get_current() == 100.0, "Bound L1 during actual Enemy contact preserves HP")
	check(events.any(func(event): return event.get("kind") == "player_contact_evaluated" and event.get("outcome") == "PARRIED"), "Actual Enemy hit resolver reports PARRIED")
	await tap(&"light_attack")
	await frames(35)
	check(enemy.health.get_current() < 200.0, "Real melee can punish after timed Fire parry")
	finish()

	for strategy in ["melee_first", "parry_marker_relative", "spacing_cast"]:
		await fresh(strategy)
		var parry_release_at := -1
		for frame in range(1800):
			if gym.attempt_result != &"":
				break
			input(&"light_attack", false)
			var distance := gap()
			var playing: bool = gym.player.combat.is_attack_playing()
			var ready: bool = gym.player.might.can_begin_defence()
			var clock: float = enemy_clock()
			var enemy_phase: String = enemy._state_name()
			var can_queue: bool = playing and gym.player.combat.get_normalized_attack_progress() >= 0.5 and gym.player.might.get("_pending_action").is_empty()
			input(&"move_right", distance > 55.0)
			input(&"move_left", distance < -55.0)
			if strategy == "melee_first":
				if absf(distance) <= 65.0 and (ready or can_queue):
					input(&"light_attack", true)
			elif strategy == "parry_marker_relative":
				if parry_release_at >= 0 and frame >= parry_release_at:
					input(&"defend", false)
					parry_release_at = -1
					input(&"light_attack", true)
				elif ready and enemy_phase == "WINDUP" and clock >= enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact") - 0.12 and parry_release_at < 0:
					input(&"defend", true)
					parry_release_at = frame + 10
				elif enemy_phase in ["ACTIVE", "RECOVERY"] and ready and not buttons.get(&"defend", false):
					input(&"light_attack", true)
			else:
				if gym.player.magic.get_marked_count() > 0 and (not playing or can_queue):
					input(&"casting", false)
				elif gym.player.magic.get_snapshot().is_empty() and not playing:
					input(&"casting", true)
					if absf(distance) <= 65.0:
						input(&"light_attack", true)
				if not gym.player.magic.get_snapshot().is_empty() or (playing and gym.player.might.get("_current_action").get("kind") == &"cast"):
					input(&"move_right", false)
					input(&"move_left", distance > 0.0 and distance < 150.0)
			await frames(1)
		finish({"policy": "deterministic telemetry-driven observation; no claim of optimal human play"})

	release_all()
	var output := FileAccess.open("res://overnight-input-report.json", FileAccess.WRITE)
	output.store_string(JSON.stringify(report, "  "))
	output.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	# Allow the Dummy audio mixing thread to release stopped playback handles.
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d overnight real-input baseline checks" % checks)
	else:
		printerr("FAILED: %d / %d overnight real-input checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)
