extends "res://tools/tests/overnight_gym_input_test.gd"
## Cast A/B: actual InputMap events and engine ticks. Initial orbs and disabled
## Enemy AI are explicit setup in timing cases; no direct Cast/action calls.

var variant := "unspecified"
var capture_enabled := false
var output_dir := ""
var release_frame := -1
var samples: Array = []
var captures: Array = []
var capture_keys: Dictionary = {}
var initial_resource_setup := 0
const CAST_CAPTURE_OFFSETS := [0, 16, 18, 25, 26, 70, 71, 72, 78]

func event_list(kind: String) -> Array:
	return events.filter(func(event): return event.get("kind") == kind)

func cast_starts() -> Array:
	return events.filter(func(event): return event.get("kind") == "action_accepted" and str(event.get("action_kind", "")).begins_with("cast"))

func state_sample() -> Dictionary:
	var projectiles: Array = []
	for child in gym.get_children():
		if child is SpellProjectile and not child.is_queued_for_deletion():
			projectiles.append({"position": str(child.global_position), "visible_in_tree": child.is_visible_in_tree(), "visual_visible": child.visual.is_visible_in_tree()})
	var action: Dictionary = gym.player.might.get("_current_action")
	return {"frame": Engine.get_physics_frames() - start_frame, "release_offset": Engine.get_physics_frames() - start_frame - release_frame, "action": str(action.get("kind", "")), "action_id": action.get("source_action_id", 0), "pending": str(gym.player.might.get("_pending_action").get("kind", "")), "clock": gym.player.animation_player.current_animation_position if not action.is_empty() and gym.player.animation_player.is_playing() else -1.0, "sprite": str(gym.player.get_node("Sprite").region_rect), "player_x": gym.player.global_position.x, "enemy_x": enemy.global_position.x, "enemy_phase": str(enemy._state_name()), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "charged": gym.player.magic.get_marked_count(), "heat": gym.player.heat.get_value(), "projectiles": projectiles, "cast_audio_playing": gym.player.cast_audio.playing, "paused": paused}

func observe() -> void:
	if not is_instance_valid(gym) or not is_instance_valid(enemy):
		return
	var data := state_sample()
	samples.append(data)
	if not capture_enabled or release_frame < 0:
		return
	var starts := cast_starts()
	var cast_offset := int(data.frame) - int(starts[0].frame) if not starts.is_empty() else -1
	var key := "release" if int(data.frame) == release_frame else ("cast_%03d" % cast_offset if CAST_CAPTURE_OFFSETS.has(cast_offset) else "")
	if key.is_empty() or capture_keys.has(key):
		return
	capture_keys[key] = true
	var scheduled_frame: int = data.frame
	await RenderingServer.frame_post_draw
	# Annotate the state actually present after this viewport was rendered.
	data = state_sample()
	data["scheduled_frame"] = scheduled_frame
	data["post_draw_frame"] = Engine.get_physics_frames() - start_frame
	check(scheduled_frame == int(data.post_draw_frame), "Capture remains on recorded physics frame")
	var path := output_dir.path_join("%s_%s_%s.png" % [variant, scenario, key])
	var image := root.get_texture().get_image()
	check(image.save_png(path) == OK and not image.is_empty(), "Actual full-viewport PNG: " + path)
	data["png"] = path
	data["width"] = image.get_width()
	data["height"] = image.get_height()
	captures.append(data)

func tick(count: int = 1) -> void:
	for index in range(count):
		await frames(1)
		await observe()

func setup_case(label: String, initial_orbs: int, close_target := false) -> void:
	await fresh(label, 56.0 if close_target else -1.0)
	gym.get("_config")["enemy_ai"]["enabled"] = false
	check(gym._apply_runtime_tuning()["ok"], "Explicit timing-fixture AI setup validates")
	initial_resource_setup = initial_orbs
	for orb in range(initial_orbs):
		gym.player.magic.add_orb(&"fire")
	release_frame = -1
	samples = []
	capture_keys = {}

func charge_to(level: int) -> void:
	input(&"casting", true)
	for index in range(360):
		await tick()
		if gym.player.magic.get_marked_count() >= level:
			return
	check(false, "Real held L2 reaches requested charge level")

func release_cast() -> void:
	release_frame = Engine.get_physics_frames() - start_frame
	input(&"casting", false)
	await observe()

func save_case(extra: Dictionary = {}) -> void:
	var starts := cast_starts()
	var launches := event_list("cast_launched")
	var projectile_frames := samples.filter(func(sample): return not sample.projectiles.is_empty())
	var audio_frames := samples.filter(func(sample): return sample.cast_audio_playing)
	var metrics := {"release_frame": release_frame, "cast_start_frames": starts.map(func(event): return event.frame), "launch_frames": launches.map(func(event): return event.frame), "first_render_eligible_projectile_frame": projectile_frames[0].frame if not projectile_frames.is_empty() else -1, "first_cast_audio_playing_frame": audio_frames[0].frame if not audio_frames.is_empty() else -1, "action_finishes": event_list("action_finished").map(func(event): return event.frame), "light_starts": events.filter(func(event): return event.get("kind") == "action_accepted" and event.get("action_kind") == "light").map(func(event): return event.frame)}
	var result := {"scenario": scenario, "initial_resource_setup": initial_resource_setup, "metrics": metrics, "samples": samples.duplicate(true), "events": events.duplicate(true), "phases": phases.duplicate(true), "final": state_sample()}
	result.merge(extra)
	report["scenarios"].append(result)
	print("CAST_OBSERVATION: ", scenario, " ", JSON.stringify(metrics))

func matched_case(level: int, queued: bool) -> void:
	await setup_case(("queued_" if queued else "normal_") + str(level), level)
	await charge_to(level)
	if queued:
		# Deliberate missed predecessor: initial resources isolate timing from target reactions.
		await tap(&"light_attack")
		while gym.player.combat.is_attack_playing() and gym.player.combat.get_normalized_attack_progress() < 0.5:
			await tick()
	await release_cast()
	var followup_sent := false
	for index in range(170):
		var action: Dictionary = gym.player.might.get("_current_action")
		if not followup_sent and str(action.get("kind", "")).begins_with("cast") and gym.player.combat.get_normalized_attack_progress() >= 0.6:
			await tap(&"light_attack")
			followup_sent = true
		await tick()
	check(event_list("cast_committed").size() == 1 and event_list("cast_launched").size() == 1, "One input release commits/launches once: " + scenario)
	var commits := event_list("cast_committed")
	check(not commits.is_empty() and int(commits[0].primary_level) == level and bool(commits[0].empowered) == queued, "Requested normal/empowered charge level retained: " + scenario)
	check(followup_sent and gym.player.might.get("_current_action").is_empty() and gym.player.might.get("_pending_action").is_empty(), "Queued melee completes without stale action: " + scenario)
	save_case({"requested_level": level, "queued": queued, "target_setup": "ordinary spawn; AI disabled; initial Fire orbs; predecessor deliberately misses"})

func interruption_case(lead_ticks: int, label: String) -> void:
	await setup_case(label, 1)
	await charge_to(1)
	# Enemy behind Player: its real committed strike cannot be cancelled by the
	# forward projectile, allowing matched pre-/between-/post-launch interruption.
	enemy.global_position.x = gym.player.global_position.x - 60.0
	gym.get("_config")["enemy_ai"]["enabled"] = true
	gym._apply_runtime_tuning()
	# Preserve before/between/after-launch strike offsets as Enemy contact changes.
	var actual_contact_ticks := int(round(enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact") * 60.0))
	var scheduled_lead := lead_ticks + actual_contact_ticks - 48
	await tick(scheduled_lead)
	await release_cast()
	for index in range(100):
		await tick()
		if gym.player.health.get_current() < 100.0:
			break
	# End the attack source after the measured first hit, avoiding another cycle.
	gym.get("_config")["enemy_ai"]["enabled"] = false
	gym._apply_runtime_tuning()
	await tick(10)
	check(event_list("cast_committed").size() == 1, "Interrupted Cast retains one resource commitment: " + label)
	check(gym.player.health.get_current() == 90.0 and event_list("action_interrupted").size() >= 1, "Real rear Enemy strike interrupts Player: " + label)
	check(event_list("cast_launched").size() <= 1, "Interrupted action never duplicates launch: " + label)
	save_case({"enemy_windup_lead_ticks": scheduled_lead, "intended_strike_after_release_ticks": 48 - lead_ticks, "setup": "one initial orb; actual marker-derived rear Enemy scheduling preserves pre/between/post launch semantics; no synthetic damage"})

func repeated_real_generation() -> void:
	await setup_case("three_real_generate_charge_cast_cycles", 0, true)
	for cycle in range(3):
		input(&"casting", true)
		await tick()
		await tap(&"light_attack")
		for index in range(90):
			await tick()
			if gym.player.magic.get_marked_count() > 0 and (not gym.player.combat.is_attack_playing() or gym.player.combat.get_normalized_attack_progress() >= 0.5):
				break
		check(gym.player.magic.get_marked_count() > 0, "Actual melee generates and held L2 charges cycle " + str(cycle))
		await release_cast()
		for index in range(140):
			await tick()
			if event_list("cast_launched").size() == cycle + 1 and not gym.player.combat.is_attack_playing():
				break
	check(event_list("orb_created").size() == 3 and event_list("cast_launched").size() == 3, "Three real generate/charge/release cycles launch once each")
	save_case({"setup": "no initial resources; AI disabled; actual melee contact generates each orb"})

func keyboard(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func pause_retry_case() -> void:
	await setup_case("pause_resume_and_ui_retry", 1)
	await charge_to(1)
	await release_cast()
	await tick(8)
	keyboard(KEY_ESCAPE, true)
	await tick()
	keyboard(KEY_ESCAPE, false)
	var clock: float = gym.player.animation_player.current_animation_position
	var count := event_list("cast_launched").size()
	await tick(15)
	check(paused and is_equal_approx(gym.player.animation_player.current_animation_position, clock) and event_list("cast_launched").size() == count, "Pause holds Cast clock and prevents launch")
	keyboard(KEY_ESCAPE, true)
	await tick()
	keyboard(KEY_ESCAPE, false)
	await tick(100)
	check(not paused and event_list("cast_launched").size() == 1, "Resume completes one Cast")
	keyboard(KEY_ESCAPE, true)
	await tick()
	keyboard(KEY_ESCAPE, false)
	keyboard(KEY_DOWN, true)
	await tick()
	keyboard(KEY_DOWN, false)
	keyboard(KEY_ENTER, true)
	await tick()
	keyboard(KEY_ENTER, false)
	await tick(6)
	gym = current_scene
	enemy = gym.get("_current_area").get_targets()[0]
	check(not paused and gym.player.health.get_current() == 100.0 and enemy.health.get_current() == 200.0 and gym.player.magic.get_snapshot().is_empty() and gym.player.heat.get_value() == 0.0, "Keyboard pause-menu Retry restores fresh Gym")
	save_case({"setup": "one initial orb; actual Esc/Down/Enter menu input"})

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
		output_dir = ProjectSettings.globalize_path("res://cast-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: graphical capture requires an actual renderer")
		quit(1)
		return
	report = {"variant": variant, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "capture_enabled": capture_enabled, "fire_contact": (load("res://config/attack_animations/cast_fire.tres") as Animation).get_marker_time(&"contact"), "scenarios": []}
	for level in ([1] if capture_enabled else [1, 4, 8]):
		await matched_case(level, false)
		await matched_case(level, true)
	if not capture_enabled:
		await interruption_case(36, "interruption_before_both_launches")
		await interruption_case(27, "interruption_between_launches")
		await interruption_case(15, "interruption_after_both_launches")
		await repeated_real_generation()
		await pause_retry_case()
	release_all()
	report["captures"] = captures
	report["checks"] = checks
	report["failures"] = failures
	var file := FileAccess.open(output_dir.path_join(variant + "-cast-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d real-input Cast timing checks (%s)" % [checks, variant])
	else:
		printerr("FAILED: %d / %d Cast timing checks (%s)" % [failures.size(), checks, variant])
	quit(0 if failures.is_empty() else 1)
