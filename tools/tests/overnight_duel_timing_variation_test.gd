extends "res://tools/tests/overnight_duel_policy_test.gd"
## R17 validation only. Existing policy, input bindings, authored markers and
## eligibility are reused. Uniform offsets are drawn ONCE per native attack ID.
const SEEDS := [1701, 9419]
var random := RandomNumberGenerator.new()
var jitter_radius := 0
var jitter_seed := 0
var selected_case := ""
var draws: Dictionary = {}
var guard_presses: Array = []
var contact_records: Array = []
var state_faults: Array = []
var interruption_records: Array = []
var retry_keys: Array = []

func matrix() -> Array:
	var specs: Array = []
	for layout in ["default", "mirrored", "wall"]:
		specs.append({"name": "control_" + layout, "layout": layout, "radius": 0, "seed": 0})
	for seed_value in SEEDS:
		for layout in ["default", "mirrored", "wall"]:
			specs.append({"name": "j3_s%d_%s" % [seed_value, layout], "layout": layout, "radius": 3, "seed": seed_value})
	for seed_value in SEEDS:
		specs.append({"name": "j6_s%d_default" % seed_value, "layout": "default", "radius": 6, "seed": seed_value})
	return specs

func native_id() -> int:
	# _attack_id can become0 during native cancellation. Last-issued ID remains
	# available without manufacturing an attack/result or rerolling the RNG.
	return int(enemy.get("_next_attack_id")) - 1

func input(action: StringName, pressed: bool) -> void:
	if action == &"defend" and pressed and not buttons.get(action, false) and is_instance_valid(enemy):
		var id := native_id()
		guard_presses.append({"frame": frame_now(), "process_frame": Engine.get_process_frames(), "physics_frame": Engine.get_physics_frames(), "native_action_id": id, "live_action_id": enemy.get("_attack_id"), "enemy_clock": enemy_clock(), "offset_ticks": press_offset, "ready": gym.player.might.can_begin_defence(), "defending_before": gym.player.combat.is_defending(), "draw_present": draws.has(str(id)), "player_hp": gym.player.health.get_current()})
	super.input(action, pressed)

func on_reaction(data: Dictionary) -> void:
	super.on_reaction(data)
	var snapshot := data.duplicate(true)
	snapshot.merge({"frame": frame_now(), "process_frame": Engine.get_process_frames(), "physics_frame": Engine.get_physics_frames(), "native_action_id": native_id(), "live_action_id": enemy.get("_attack_id"), "enemy_clock": enemy_clock(), "offset_ticks": press_offset, "player_hp": gym.player.health.get_current()})
	contact_records.append(snapshot)

func on_outcome(outcome) -> void:
	super.on_outcome(outcome)
	if outcome.get_kind() == &"action_interrupted":
		interruption_records.append({"frame": frame_now(), "event": outcome.snapshot(), "native_action_id": native_id()})

func policy_parry() -> void:
	var id: int = enemy.get("_attack_id")
	if id > 0 and not draws.has(str(id)):
		var offset := random.randi_range(-jitter_radius, jitter_radius) if jitter_radius > 0 else 0
		var marker: float = enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact")
		draws[str(id)] = {"native_action_id": id, "draw_frame": frame_now(), "enemy_clock_at_draw": enemy_clock(), "offset_ticks": offset, "trigger_seconds": marker - 0.12 + float(offset) / 60.0}
	if draws.has(str(id)):
		press_offset = int(draws[str(id)].offset_ticks)
	# All approach/eligibility/defend-release/one-punish logic stays in the parent.
	super.policy_parry()

func tick() -> void:
	await super.tick()
	var data := snapshot()
	var might = gym.player.might
	# A finished empowered chain or held defence can be intentionally non-READY.
	# Only assert an operational READY state, outside defence/reaction/result.
	if data.ready and not data.defending and not gym.player.hit_reaction.is_active() and gym.attempt_result == &"":
		if data.movement_locked or data.pending_action or data.buffered_request or not might.get("_current_action").is_empty():
			state_faults.append(data)

func real_retry() -> Dictionary:
	var first_input := input_log.size()
	retry_keys = []
	release_all()
	if gym.attempt_result == &"":
		# Honest timeout also uses actual pause-menu Retry; no direct reset calls.
		keyboard(KEY_ESCAPE, true)
		await frames(1)
		keyboard(KEY_ESCAPE, false)
		keyboard(KEY_DOWN, true)
		await frames(1)
		keyboard(KEY_DOWN, false)
		keyboard(KEY_ENTER, true)
		await frames(1)
		keyboard(KEY_ENTER, false)
	else:
		input(&"ui_accept", true)
		await frames(1)
		input(&"ui_accept", false)
	await frames(6)
	gym = current_scene
	enemy = gym.get("_current_area").get_targets()[0]
	var reset := {"player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "heat": gym.player.heat.get_value(), "result": str(gym.attempt_result), "player_reaction": gym.player.hit_reaction.is_active(), "enemy_reaction": enemy.hit_reaction.is_active(), "pending": not gym.player.might.get("_pending_action").is_empty(), "buffer": not gym.player.might.get("_buffered_request").is_empty(), "movement_locked": gym.player.movement.get("_locked"), "paused": paused}
	reset["input_events"] = input_log.slice(first_input)
	reset["keyboard_events"] = retry_keys.duplicate(true)
	check(reset.player_hp == 100.0 and reset.enemy_hp == 200.0 and reset.orbs == 0 and reset.heat == 0.0 and reset.result == "" and not reset.player_reaction and not reset.enemy_reaction and not reset.pending and not reset.buffer and not reset.movement_locked and not reset.paused, "Actual UI Retry resets ordinary encounter")
	return reset

func varied_attempt(spec: Dictionary) -> void:
	jitter_radius = spec.radius
	jitter_seed = spec.seed
	press_offset = 0
	draws = {}
	guard_presses = []
	contact_records = []
	state_faults = []
	interruption_records = []
	random.seed = jitter_seed
	await setup_attempt(spec.name, spec.layout)
	var started := Time.get_ticks_msec()
	# Include setup/post-result observation in the90-second logical fight bound.
	for frame in range(maxi(0, 5400 - frame_now() - 2)):
		if gym.attempt_result != &"" or not state_faults.is_empty():
			break
		if Time.get_ticks_msec() - started > 85000:
			state_faults.append({"reason": "wall-time watchdog", "frame": frame_now()})
			break
		if light_release_at >= 0 and frame_now() >= light_release_at:
			input(&"light_attack", false)
			light_release_at = -1
		policy_parry()
		await tick()
	await frames(2)
	var final := snapshot()
	var result_name := str(gym.attempt_result) if gym.attempt_result != &"" else ("state_fault" if not state_faults.is_empty() else "timeout")
	var presses_per_id: Dictionary = {}
	var contacts_per_id: Dictionary = {}
	for press in guard_presses:
		var key := str(press.native_action_id)
		presses_per_id[key] = int(presses_per_id.get(key, 0)) + 1
		check(press.draw_present and press.ready and not press.defending_before, "Guard input uses previously drawn action offset and legal READY")
		check(draws[key].offset_ticks == press.offset_ticks, "Action offset held without reroll through actual input")
	for contact in contact_records:
		var key := str(contact.native_action_id)
		contacts_per_id[key] = int(contacts_per_id.get(key, 0)) + 1
	for key in presses_per_id:
		check(presses_per_id[key] == 1, "At most one L1 press per native Enemy action")
	for key in contacts_per_id:
		check(contacts_per_id[key] == 1 and draws.has(key), "Native contact unique and has one fixed timing draw")
	var applied_melee := enemy_results.filter(func(e): return e.get("outcome") == "APPLIED" and str(e.get("attacker_move", "")).begins_with("fire_x")).size()
	check(applied_melee == count_event("orb_created") + count_event("orb_overflow"), "Each APPLIED melee generates once or reports existing full-queue overflow")
	check(count_event("cast_committed") == 0 and count_event("cast_launched") == 0, "Parry/punish policy adds no Cast/resource setup")
	check(state_faults.is_empty(), "No operational READY lock/queue/action fault")
	if gym.attempt_result != &"":
		check(gym.get("_result_layer").visible, "Natural full-duel result has actual UI")
	var result := {"scenario": scenario, "layout": spec.layout, "seed": jitter_seed, "jitter_radius_ticks": jitter_radius, "base_trigger": "actual native contact marker minus0.12 seconds", "duration_ticks": frame_now(), "wall_ms": Time.get_ticks_msec() - started, "result": result_name, "final": final, "draws": draws.duplicate(true), "guard_presses": guard_presses.duplicate(true), "contacts": contact_records.duplicate(true), "enemy_contact_outcomes": count_values(contact_records, "outcome"), "enemy_received_outcomes": count_values(enemy_results, "outcome"), "melee_outcomes": count_values(events.filter(func(e): return e.get("kind") == "light_contact_resolved"), "result"), "generated": count_event("orb_created"), "overflow": count_event("orb_overflow"), "applied_melee": applied_melee, "interruptions": interruption_records.duplicate(true), "state_faults": state_faults.duplicate(true), "max_no_health_action_progress_ticks": max_stagnant_ticks, "inputs": input_log.duplicate(true), "decisions": decision_log.duplicate(true), "events": events.duplicate(true), "enemy_results": enemy_results.duplicate(true), "samples": samples.duplicate(true), "phases": phases.duplicate(true)}
	if state_faults.is_empty():
		result["retry_reset"] = await real_retry()
	report["attempts"].append(result)
	print("VARIATION_RESULT ", JSON.stringify({"case": spec.name, "result": result_name, "ticks": result.duration_ticks, "player_hp": final.player_hp, "enemy_hp": final.enemy_hp, "outcomes": result.enemy_contact_outcomes, "generated": result.generated, "state_faults": state_faults.size()}))

func _run() -> void:
	root.size = Vector2i(1280, 720)
	variant = "round17"
	for argument in OS.get_cmdline_user_args():
		if argument == "--capture": capture_enabled = true
		elif argument.begins_with("--case="): selected_case = argument.trim_prefix("--case=")
		elif argument.begins_with("--output="): output_dir = argument.trim_prefix("--output=")
	if output_dir.is_empty(): output_dir = ProjectSettings.globalize_path("res://variation-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and (DisplayServer.get_name() == "headless" or selected_case.is_empty()):
		printerr("FAILED: capture requires actual renderer and one named --case")
		quit(1)
		return
	report = {"engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "capture": capture_enabled, "predeclared_matrix": matrix(), "attempts": [], "scope": "native telemetry machine policy; uniformly drawn once/action; fixed60; no human reaction/readability/feel claim"}
	for spec in matrix():
		if not selected_case.is_empty() and spec.name != selected_case:
			continue
		await varied_attempt(spec)
		if not state_faults.is_empty():
			break
	check(not report.attempts.is_empty(), "Named attempt exists in predeclared matrix")
	release_all()
	report["checks"] = checks
	report["failures"] = failures
	report["captures"] = captures
	var file := FileAccess.open(output_dir.path_join((selected_case if not selected_case.is_empty() else "matrix") + "-variation.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false): audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	OS.delay_msec(100)
	print("VARIATION_CHECKS ", checks, " failures=", failures.size())
	quit(0 if failures.is_empty() else 1)

func keyboard(code: Key, pressed: bool) -> void:
	retry_keys.append({"frame": frame_now(), "keycode": code, "pressed": pressed})
	var key := InputEventKey.new()
	key.keycode = code
	key.physical_keycode = code
	key.pressed = pressed
	Input.parse_input_event(key)
