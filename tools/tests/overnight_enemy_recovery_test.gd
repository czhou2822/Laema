extends "res://tools/tests/overnight_gym_input_test.gd"
## Recovery A/B fixture, extending the unchanged real-input baseline helpers.
## Setup may place fighters / set initial HP; lifecycle probes explicitly call
## existing owner APIs. Attacks, parry, movement and damage use real bound input.
## -- --capture enables actual full-viewport PNGs with a graphical renderer only.

var capture_enabled := false
var output_dir := ""
var variant := "unspecified"
var clip_length := 0.0
var contact_time := 0.0
var active_end_time := 0.0
var context := "gym"
var commitment_frame := 0
var captures: Array = []
func observation_offsets() -> Array:
	return [int(round((contact_time - 0.05) * 60.0)), int(round((contact_time + 0.02) * 60.0)), int(round((active_end_time + 0.1) * 60.0)), int(round((clip_length - 0.02) * 60.0)), int(round((clip_length + 0.05) * 60.0))]

func offset() -> int:
	return Engine.get_physics_frames() - start_frame - commitment_frame

func snapshot() -> Dictionary:
	return {"offset_frame": offset(), "seconds": float(offset()) / 60.0, "phase": str(enemy._state_name()), "clock": enemy_clock(), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "enemy_x": enemy.global_position.x, "player_x": gym.player.global_position.x, "facing": str(enemy.get("_facing")), "origin": str(enemy.get("_committed_attack_origin")), "animation_frame": str(enemy.body_visual.region_rect), "texture": enemy.body_visual.texture.resource_path}

func capture_sample() -> Dictionary:
	var data := snapshot()
	if capture_enabled:
		await RenderingServer.frame_post_draw
		data["post_draw_offset_frame"] = offset()
		check(offset() == int(data["offset_frame"]), "Rendered sample stays on its recorded physics tick")
		var path := output_dir.path_join("%s_%s_f%03d.png" % [variant, scenario, int(data["offset_frame"])])
		var image := root.get_texture().get_image()
		var error := image.save_png(path)
		check(error == OK and image.get_width() == 1280 and image.get_height() == 720, "Full rendered viewport capture: " + path)
		data["png"] = path
		data["width"] = image.get_width()
		data["height"] = image.get_height()
		captures.append(data.duplicate(true))
	return data

func setup_case(label: String, tutorial := false, facing_right := false, at_wall := false) -> void:
	context = "tutorial" if tutorial else "gym"
	if not tutorial:
		await fresh(label, -1.0)
	else:
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
		scenario = label
		events = []
		phases = []
		last_phase = ""
		start_frame = Engine.get_physics_frames()
		gym.player.combat.outcome_published.connect(on_outcome)
		gym.player.health_resolver.reaction_evaluated.connect(on_reaction)
	# Explicit setup only: initial positions. No action/animation/timer shortcuts.
	if at_wall:
		gym.player.global_position.x = 575.0 if facing_right else -575.0
	else:
		# Tutorial's area has a translated origin; world zero is beside its left wall.
		gym.player.global_position.x = gym.get("_current_area").get_spawn_world_position().x if tutorial else 0.0
	enemy.global_position.x = gym.player.global_position.x + (-60.0 if facing_right else 60.0)
	# The ordinary Gym may have approached briefly; wait for its real commitment.
	for frame in range(90):
		await frames(1)
		if enemy._state_name() == &"WINDUP":
			break
	commitment_frame = Engine.get_physics_frames() - start_frame - int(round(enemy_clock() * 60.0))
	check(enemy._state_name() == &"WINDUP", "Natural tree begins committed windup: " + label)

func save_case(samples: Array, extra: Dictionary = {}) -> void:
	var data := {"scenario": scenario, "context": context, "clip_length": clip_length, "samples": samples, "events": events.duplicate(true), "phases": phases.duplicate(true), "commitment_frame": commitment_frame, "final": snapshot()}
	data.merge(extra)
	report["scenarios"].append(data)
	print("RECOVERY_OBSERVATION: ", JSON.stringify({"scenario": scenario, "context": context, "final": data.final}))

func cycle_case(label: String, miss := false, tutorial := false, facing_right := false, at_wall := false) -> void:
	await setup_case(label, tutorial, facing_right, at_wall)
	var committed: Vector2 = enemy.get("_committed_attack_origin")
	var committed_facing: Vector2 = enemy.get("_facing")
	var samples: Array = []
	while offset() <= int(observation_offsets().max()) + 1:
		if miss:
			input(&"move_right" if facing_right else &"move_left", offset() >= 15 and offset() < 45)
		if observation_offsets().has(offset()):
			samples.append(await capture_sample())
		if offset() == int(round(contact_time * 60.0)) + 1:
			check(Vector2(enemy.get("_committed_attack_origin")).is_equal_approx(committed) and Vector2(enemy.get("_facing")) == committed_facing, "First contact preserves origin/facing: " + label)
		await frames(1)
	release_all()
	var contacts: Array = events.filter(func(event): return event.get("kind") == "player_contact_evaluated")
	check(contacts.size() == (0 if miss else 1), "First cycle has exactly one hit query outcome or a full miss: " + label)
	var recovery := phases.filter(func(phase): return phase.phase == "RECOVERY")
	var recovery_ticks := int(round((clip_length - active_end_time) * 60.0))
	if recovery_ticks > 0:
		check(not recovery.is_empty(), "Tail enters RECOVERY: " + label)
		var idle := phases.filter(func(phase): return phase.phase == "IDLE" and phase.frame > commitment_frame + 50)
		check(not idle.is_empty() and not recovery.is_empty() and int(idle[0].frame) - int(recovery[0].frame) == recovery_ticks, "Hit/miss recovery matches length minus active_end: " + label)
	else:
		check(recovery.is_empty(), "Baseline has no sustained sampled recovery: " + label)
	var windups := phases.filter(func(phase): return phase.phase == "WINDUP" and phase.frame > commitment_frame + 5)
	if not windups.is_empty():
		check(int(windups[0].frame) - commitment_frame >= int(round(clip_length * 60.0)), "New commitment starts only after clip end: " + label)
	save_case(samples, {"first_contacts": contacts.size(), "miss": miss, "at_wall": at_wall, "facing_right": facing_right})

func lifecycle_case(operation: String, tutorial := false) -> void:
	await setup_case(("tutorial_lifecycle_" if tutorial else "lifecycle_") + operation, tutorial)
	# A PRIVATE tail is required to test recovery cancellation; stock1.3 ends
	# at active_end1.3 and therefore has no tail. No source animation is saved.
	enemy.attack_animation.get_animation(&"melee_swing").length = active_end_time + 0.3
	if operation in ["reaction", "death"]:
		# Preserve qualifying X1 interruption in a declared private Poise1 fixture.
		gym.get("_config")["enemy_ai"]["poise"] = 1
		gym._apply_runtime_tuning()
	# Timed real L1 protects the Player so a real X can exercise the tail.
	while offset() < int(round(contact_time * 60.0)) - 7:
		await frames(1)
	input(&"defend", true)
	while offset() < int(round(contact_time * 60.0)) + 3:
		await frames(1)
	input(&"defend", false)
	while offset() < int(round(active_end_time * 60.0)) + 1:
		await frames(1)
	var before := snapshot()
	if operation in ["reaction", "death"]:
		if operation == "death":
			# Initial Health setup for one real-hit death; not synthetic damage evidence.
			enemy.health.configure(10.0)
		await tap(&"light_attack")
		await frames(16)
		check(enemy._state_name() == (&"DEAD" if operation == "death" else &"HIT_REACTING"), "Real X interrupts/kills the current phase: " + operation)
		check(not enemy.attack_animation.is_playing() and int(enemy.get("_attack_id")) == 0, "Reaction/death cancels native playback and old action")
	elif operation in ["disable_ai", "disable_ai_after_snapshot"]:
		# Explicit runtime-control API probe; no gameplay input claim for this operation.
		if operation == "disable_ai_after_snapshot":
			# Establish the owner's detached tuning snapshot before the changed apply.
			enemy.apply_runtime_tuning()
		gym.get("_config")["enemy_ai"]["enabled"] = false
		gym._apply_runtime_tuning()
		await frames(90)
		check(enemy._state_name() == &"DORMANT" and not enemy.attack_animation.is_playing(), "AI disable cancels tail and pending contact")
	elif operation == "stage_retire":
		gym.get("_current_area").set_lifecycle(StageArea.Lifecycle.RETIRED)
		await frames(90)
		check(enemy._state_name() == &"DORMANT" and not enemy.attack_animation.is_playing(), "Stage retirement cancels tail")
	elif operation == "stage_reset":
		enemy.set_stage_active(false)
		enemy.set_stage_active(true)
		await frames(1)
		check(enemy._state_name() == &"WINDUP" and enemy_clock() <= 0.017, "Stage reset starts a new committed attack from zero")
	elif operation == "cancel":
		enemy.cancel_combat_attack()
		await frames(1)
		check(int(enemy.get("_attack_id")) == 0 or enemy_clock() <= 0.017, "Explicit cancellation never resumes the cancelled clock")
	save_case([before, snapshot()], {"operation": operation, "private_recovery_tail": 0.3, "private_poise1_for_qualifying_X1": operation in ["reaction", "death"], "operation_is_setup_api": operation not in ["reaction", "death"]})

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for argument in OS.get_cmdline_user_args():
		if argument == "--capture":
			capture_enabled = true
		elif argument.begins_with("--output="):
			output_dir = argument.trim_prefix("--output=")
		elif argument.begins_with("--variant="):
			variant = argument.trim_prefix("--variant=")
	if output_dir.is_empty():
		output_dir = ProjectSettings.globalize_path("res://recovery-captures")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: --capture requires an actual graphical renderer")
		quit(1)
		return
	var authored: Animation = load("res://config/attack_animations/melee_swing.tres")
	clip_length = authored.length
	contact_time = authored.get_marker_time(&"contact")
	active_end_time = authored.get_marker_time(&"active_end")
	report = {"variant": variant, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "clip_length": clip_length, "capture_enabled": capture_enabled, "scenarios": []}
	await cycle_case("gym_hit")
	await cycle_case("gym_miss", true)
	if not capture_enabled:
		await cycle_case("gym_hit_facing_right", false, false, true)
		await cycle_case("gym_miss_facing_right", true, false, true)
		await cycle_case("gym_left_wall_hit", false, false, false, true)
		await cycle_case("gym_right_wall_hit", false, false, true, true)
		await cycle_case("tutorial_hit", false, true)
		await cycle_case("tutorial_miss", true, true)
		for operation in ["reaction", "death", "disable_ai", "disable_ai_after_snapshot", "stage_retire", "stage_reset", "cancel"]:
			await lifecycle_case(operation)
		for operation in ["reaction", "death", "disable_ai_after_snapshot", "stage_retire", "stage_reset", "cancel"]:
			await lifecycle_case(operation, true)
	release_all()
	report["captures"] = captures
	report["checks"] = checks
	report["failures"] = failures
	var file := FileAccess.open(output_dir.path_join("%s-recovery-report.json" % variant), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d real-input recovery checks (%s)" % [checks, variant])
	else:
		printerr("FAILED: %d / %d recovery checks (%s)" % [failures.size(), checks, variant])
	quit(0 if failures.is_empty() else 1)
