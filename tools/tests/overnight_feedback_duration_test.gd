extends "res://tools/tests/overnight_feedback_layout_test.gd"
## R18 two-value presentation experiment. Actual E combat is separate from
## labeled layout-only examples. No combat/timer/HP/orb/AI setup mutations.
var expected_duration := 2.0
var selected_case := ""
var combat_only := false
var lifecycle: Array = []
var lifecycle_context: Dictionary = {}
var pair_samples: Array = []
var retry_inputs: Array = []

func register_label(node: Node, role: String, mode: String, channel := "") -> Dictionary:
	if not node is Label or node.name == "HealthLabel":
		return {}
	var entry := {"label": node, "channel": channel if not channel.is_empty() else ("cast" if " Lv." in node.text else "damage"), "school": "observed real result" if mode == "actual combat" else "layout example", "text": node.text, "created_frame": Engine.get_physics_frames() - int(lifecycle_context.base_frame), "creation_physics_frame": Engine.get_physics_frames(), "creation_process_frame": Engine.get_process_frames(), "owner": role, "mode": mode, "key": role + "_" + str(lifecycle.size()), "context": lifecycle_context}
	lifecycle.append(entry)
	node.tree_exiting.connect(func():
		entry["exit_frame"] = Engine.get_physics_frames() - int(entry.context.base_frame)
		entry["exit_process_frame"] = Engine.get_process_frames()
		entry["exit_alpha"] = node.modulate.a
		entry["exit_reason"] = entry.context.reason)
	return entry

func live_entries(role: String) -> Array:
	return lifecycle.filter(func(e): return e.owner == role and is_instance_valid(e.label))

func lifecycle_data() -> Array:
	var result: Array = []
	for entry in lifecycle:
		var data: Dictionary = entry.duplicate()
		data.erase("label")
		data.erase("context")
		data["alive"] = is_instance_valid(entry.label)
		if data.has("exit_frame"):
			data["observed_lifetime_ticks"] = int(data.exit_frame) - int(data.created_frame)
			data["observed_lifetime_seconds"] = float(data.observed_lifetime_ticks) / 60.0
		result.append(data)
	return result

func sample_pair(key: String, reasons: Array = []) -> Dictionary:
	var scheduled := Engine.get_physics_frames() - start_frame
	var npc := await take_sample(enemy, live_entries("npc"), key)
	var data := {"key": key, "reasons": reasons, "scheduled_frame": scheduled, "frame": Engine.get_physics_frames() - start_frame, "npc": npc, "player": measure(gym.player, live_entries("player"), key + "_player", capture_enabled)}
	if capture_enabled:
		check(int(data.frame) == scheduled, "Actual capture stays on scheduled physics frame")
	pair_samples.append(data)
	return data

func check_duration() -> void:
	check(is_equal_approx(float(gym.player.feedback.get("_duration")), expected_duration) and is_equal_approx(float(enemy.feedback.get("_duration")), expected_duration), "Both real feedback owners use expected Gym duration")

func keyboard(code: Key, pressed: bool) -> void:
	retry_inputs.append({"frame": Engine.get_physics_frames() - start_frame, "keycode": code, "pressed": pressed})
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func retry_case(key: String) -> Dictionary:
	release_all()
	retry_inputs = []
	lifecycle_context.reason = "actual UI Retry scene teardown"
	for code in [KEY_ESCAPE, KEY_DOWN, KEY_ENTER]:
		keyboard(code, true)
		await frames(1)
		keyboard(code, false)
	await frames(6)
	gym = current_scene
	enemy = gym.get("_current_area").get_targets()[0]
	check(not paused and owner_labels(gym.player).is_empty() and owner_labels(enemy).is_empty(), "Actual pause-menu Retry clears both feedback owners")
	check(gym.player.health.get_current() == 100.0 and enemy.health.get_current() == 200.0 and gym.player.magic.get_snapshot().is_empty() and gym.player.heat.get_value() == 0.0, "Actual Retry restores ordinary health/resources")
	check_duration()
	var reset := {"inputs": retry_inputs.duplicate(true), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "heat": gym.player.heat.get_value(), "duration": enemy.feedback.get("_duration"), "player_label_count": owner_labels(gym.player).size(), "npc_label_count": owner_labels(enemy).size()}
	reset["sample"] = await sample_pair(key + "_post_retry")
	return reset

func actual_case(facing: int, overlay: bool) -> void:
	paused = false
	var key := ("right" if facing > 0 else "left") + ("_on" if overlay else "_off")
	await fresh("actual_" + key)
	enemy.global_position.x = gym.player.global_position.x + 56.0 * facing
	if facing < 0:
		input(&"move_left", true)
		await frames(1)
		input(&"move_left", false)
	set_private_overlay(overlay)
	check_duration()
	lifecycle = []
	lifecycle_context = {"base_frame": start_frame, "reason": "normal owner lifetime"}
	pair_samples = []
	gym.player.child_entered_tree.connect(func(node): register_label(node, "player", "actual combat"))
	enemy.child_entered_tree.connect(func(node): register_label(node, "npc", "actual combat"))
	input(&"casting", true)
	await frames(1)
	await tap(&"light_attack")
	var return_sent := false
	var first_incoming := -1
	var incoming_frames: Array = []
	var seen_incoming := 0
	for index in range(330):
		if index == 31:
			input(&"casting", false)
		if count_event("cast_launched") == 1 and not return_sent and gym.player.might.can_begin_defence() and not gym.player.combat.is_attack_playing():
			await tap(&"light_attack")
			return_sent = true
		await frames(1)
		var now := Engine.get_physics_frames() - start_frame
		var incoming := events.filter(func(e): return e.get("kind") == "player_contact_evaluated")
		if incoming.size() > seen_incoming:
			seen_incoming = incoming.size()
			incoming_frames.append(int(incoming.back().frame))
			if first_incoming < 0:
				first_incoming = int(incoming.back().frame)
		var reasons: Array = []
		if now == 148:
			reasons.append("historical absolute combat frame148")
		if first_incoming >= 0 and now - first_incoming in [2, 12, 48, 72, 84]:
			reasons.append("first actual incoming age%d ticks" % (now - first_incoming))
		if incoming_frames.size() >= 2 and now == int(incoming_frames[1]) + 2:
			reasons.append("fresh second native incoming contact plus2 ticks")
		# Capture first real NPC melee/Cast feedback fresh, once per birth frame.
		if lifecycle.any(func(e): return e.owner == "npc" and now == int(e.created_frame) + 2):
			reasons.append("fresh NPC HealthResult/Cast label plus2 ticks")
		if not reasons.is_empty():
			await sample_pair(key + "_f%03d" % now, reasons)
	check(return_sent and count_event("light_contact_resolved") == 2 and count_event("orb_created") == 2, "Real melee Generates, Cast launches, legal next melee returns")
	check(count_event("cast_committed") == 1 and count_event("cast_launched") == 1, "Actual held Charging release commits/launches exactly once")
	check(incoming_frames.size() >= 3 and gym.player.health.get_current() < 100.0, "Repeated ordinary E hits produce actual Player damage feedback")
	var result := {"case": key, "facing": facing, "overlay": overlay, "setup": "initial gap56 and bound facing input only; real held L2/X/release/next X; ordinary E enabled; zero initial resources", "first_incoming_frame": first_incoming, "incoming_frames": incoming_frames, "events": events.duplicate(true), "phases": phases.duplicate(true), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "heat": gym.player.heat.get_value(), "return_sent": return_sent, "samples": pair_samples.duplicate(true)}
	result["retry"] = await retry_case(key)
	result["lifecycle"] = lifecycle_data()
	report["combat_cases"].append(result)
	print("DURATION_COMBAT ", key, " first=", first_incoming, " contacts=", incoming_frames, " hp=", result.player_hp, "/", result.enemy_hp)

func example_lifetimes() -> void:
	paused = false
	await fresh("layout_only_unpaused_NPC_lifetimes")
	check_duration()
	lifecycle = []
	lifecycle_context = {"base_frame": start_frame, "reason": "normal owner lifetime"}
	pair_samples = []
	var hp: float = enemy.health.get_current()
	for spec in [["damage", &"fire", 0], ["damage", &"fire", 10], ["dot", &"water", 0], ["dot", &"water", 3], ["cast", &"fire", 1], ["cast", &"water", 4], ["cast", &"air", 8]]:
		var entry := add_example(enemy, spec[0], spec[1], spec[2])
		register_label(entry.label, "npc", "layout-only API example; not a HealthEvent or gameplay Cast", spec[0])
	var onset := Engine.get_physics_frames() - start_frame
	for index in range(135):
		await frames(1)
		var age := Engine.get_physics_frames() - start_frame - onset
		if age in [2, 12, 48, 72, 84, 120, 123]:
			await sample_pair("layout_only_NPC_examples_age%03d" % age, ["API examples age%d; real Enemy remains enabled" % age])
	check(enemy.health.get_current() == hp, "Presentation-only NPC examples do not change NPC Health")
	for entry in lifecycle:
		check(entry.has("exit_frame") and absf(float(int(entry.exit_frame) - int(entry.created_frame)) - expected_duration * 60.0) <= 3.0, "Observed API lifetime follows configured duration within callback granularity: " + entry.text)
	report["example_lifetimes"] = {"mode": "layout-only NPC direct0/10, DoT0/3, Cast level1/4/8; no gameplay DoT or level8 combat; ordinary E may independently hit Player", "duration": expected_duration, "npc_hp": enemy.health.get_current(), "player_hp": gym.player.health.get_current(), "lifecycle": lifecycle_data(), "samples": pair_samples.duplicate(true)}

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture": capture_enabled = true
		elif arg == "--combat-only": combat_only = true
		elif arg.begins_with("--variant="): variant = arg.trim_prefix("--variant=")
		elif arg.begins_with("--expected-duration="): expected_duration = float(arg.trim_prefix("--expected-duration="))
		elif arg.begins_with("--case="): selected_case = arg.trim_prefix("--case=")
		elif arg.begins_with("--output="): output_dir = arg.trim_prefix("--output=")
	if output_dir.is_empty(): output_dir = ProjectSettings.globalize_path("res://duration-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: actual renderer required")
		quit(1)
		return
	report = {"variant": variant, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "expected_duration": expected_duration, "capture": capture_enabled, "combat_cases": [], "layout_cases": [], "limits": "Control bounds are not glyph outline extents. Source geometry/styles unchanged. Shorter reading time/faster fade and drift are presentation tradeoffs, not gameplay improvements."}
	for facing in [1, -1]:
		for overlay in [true, false]:
			var key := ("right" if facing > 0 else "left") + ("_on" if overlay else "_off")
			if selected_case.is_empty() or selected_case == key:
				await actual_case(facing, overlay)
	check(not report.combat_cases.is_empty(), "Selected actual combat case exists")
	if not combat_only:
		for role in ["npc", "player"]:
			await layout_case(role, true)
			await layout_case(role, false)
			await layout_case(role, true, true)
		await example_lifetimes()
		await lifetime_pause_reset()
		check_duration()
		report["lifetime"]["retry_duration"] = enemy.feedback.get("_duration")
		lifecycle = []
		await sample_pair("pause_probe_post_retry")
	var shared := JSON.parse_string(FileAccess.get_file_as_string("res://config/prototype_combat.json")) as Dictionary
	check(is_equal_approx(float(shared.ui.cast_feedback_duration), 2.0), "Shared/tutorial feedback duration stays2.0")
	report["shared_default"] = shared.ui.cast_feedback_duration
	report["captures"] = captures
	report["checks"] = checks
	report["failures"] = failures
	var file := FileAccess.open(output_dir.path_join(variant + "-duration.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false): audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	OS.delay_msec(100)
	print("DURATION_CHECKS ", checks, " failures=", failures.size())
	quit(0 if failures.is_empty() else 1)
