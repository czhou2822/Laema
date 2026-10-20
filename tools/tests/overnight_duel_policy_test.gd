extends "res://tools/tests/overnight_gym_input_test.gd"
## Full ordinary-state encounters. Public action outcomes/eligibility, native
## marker time and visible positions drive policies; no direct action/HP/resource edits.
var variant := "unspecified"
var suite := "full"
var selected_policy := "parry"
var selected_layout := "default"
var capture_enabled := false
var output_dir := ""
var current_kind := ""
var phase := "plan"
var phase_started := 0
var decision_log: Array = []
var enemy_results: Array = []
var samples: Array = []
var capture_keys: Dictionary = {}
var captures: Array = []
var light_release_at := -1
var pivot_until := -1
var followup_sent := false
var consumed_contacts := 0
var pivoted := false
var press_offset := 0
var gap_threshold := 135.0
var max_stagnant_ticks := 0
var stagnant_ticks := 0
var last_progress_signature := ""
var input_log: Array = []

func input(action: StringName, pressed: bool) -> void:
	if buttons.get(action, false) != pressed and is_instance_valid(gym):
		input_log.append({"frame": frame_now(), "action": str(action), "pressed": pressed, "policy_phase": phase})
	super.input(action, pressed)

func frame_now() -> int:
	return Engine.get_physics_frames() - start_frame

func transition(next: String, reason: String) -> void:
	if phase == next:
		return
	decision_log.append({"frame": frame_now(), "from": phase, "to": next, "reason": reason, "gap": gap(), "ready": gym.player.might.can_begin_defence(), "orbs": gym.player.magic.get_snapshot().size(), "charged": gym.player.magic.get_marked_count()})
	phase = next
	phase_started = frame_now()

func on_outcome(outcome) -> void:
	super.on_outcome(outcome)
	if outcome.get_kind() == &"action_accepted":
		current_kind = str(outcome.get_fact(&"action_kind", ""))
	elif outcome.get_kind() in [&"action_finished", &"action_interrupted", &"chain_terminated"]:
		current_kind = ""

func enemy_evaluation(data: Dictionary) -> void:
	var snapshot := data.duplicate(true)
	snapshot["frame"] = frame_now()
	enemy_results.append(snapshot)

func snapshot() -> Dictionary:
	return {"frame": frame_now(), "policy_phase": phase, "public_action_kind": current_kind, "ready": gym.player.might.can_begin_defence(), "playing": gym.player.combat.is_attack_playing(), "progress": gym.player.combat.get_normalized_attack_progress(), "defending": gym.player.combat.is_defending(), "player_x": gym.player.global_position.x, "enemy_x": enemy.global_position.x, "gap": gap(), "enemy_phase": str(enemy._state_name()), "enemy_clock": enemy_clock(), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "charged": gym.player.magic.get_marked_count(), "heat": gym.player.heat.get_value(), "movement_locked": gym.player.movement.get("_locked"), "pending_action": not gym.player.might.get("_pending_action").is_empty(), "buffered_request": not gym.player.might.get("_buffered_request").is_empty(), "result": str(gym.attempt_result), "result_ui_visible": gym.get("_result_layer").visible}

func capture_frame(key: String) -> void:
	if not capture_enabled or capture_keys.has(key):
		return
	capture_keys[key] = true
	var expected := frame_now()
	await RenderingServer.frame_post_draw
	var data := snapshot()
	check(int(data.frame) == expected, "Capture remains on scheduled physics frame")
	var image := root.get_texture().get_image()
	var path := output_dir.path_join("%s_%s_%s_f%04d.png" % [variant, scenario, key, expected])
	check(image.save_png(path) == OK and not image.is_empty(), "Actual duel viewport capture: " + key)
	data["png"] = path
	data["width"] = image.get_width()
	data["height"] = image.get_height()
	captures.append(data)

func tick() -> void:
	await frames(1)
	if frame_now() % 15 == 0 or gym.attempt_result != &"":
		samples.append(snapshot())
	var signature := "%s/%s/%s/%s" % [gym.player.health.get_current(), enemy.health.get_current(), count_event("action_accepted"), count_event("cast_launched")]
	if signature == last_progress_signature:
		stagnant_ticks += 1
	else:
		stagnant_ticks = 0
		last_progress_signature = signature
	max_stagnant_ticks = maxi(max_stagnant_ticks, stagnant_ticks)
	if capture_enabled:
		if frame_now() == 5:
			await capture_frame("initial")
		if count_event("orb_created") > 0:
			await capture_frame("first_generated")
		if events.any(func(event): return event.get("kind") == "player_contact_evaluated" and event.get("outcome") == "PARRIED"):
			await capture_frame("first_parry")
		if phase == "retreat_charge":
			await capture_frame("first_retreat")
		if count_event("cast_launched") > 0:
			await capture_frame("first_cast")
		if followup_sent and current_kind == "light":
			await capture_frame("melee_return")
		if gym.attempt_result != &"":
			await capture_frame("final_" + str(gym.attempt_result))

func approach_target() -> void:
	input(&"move_right", gap() > 55.0)
	input(&"move_left", gap() < -55.0)

func stop_moving() -> void:
	input(&"move_left", false)
	input(&"move_right", false)

func move_away() -> void:
	input(&"move_left", gap() > 0.0)
	input(&"move_right", gap() < 0.0)

func attack_pulse() -> void:
	input(&"light_attack", true)
	light_release_at = frame_now() + 1

func policy_parry() -> void:
	var contacts := events.filter(func(event): return event.get("kind") == "player_contact_evaluated")
	if contacts.size() > consumed_contacts:
		var contact: Dictionary = contacts.back()
		consumed_contacts = contacts.size()
		input(&"defend", false)
		if contact.outcome == "PARRIED" and gym.player.might.can_begin_defence():
			attack_pulse()
			transition("punish", "actual parry; release L1 then one X")
		else:
			transition("recover", "incoming event was not a parry")
	if phase in ["punish", "recover"]:
		stop_moving()
		if not gym.player.combat.is_attack_playing() and not gym.player.hit_reaction.is_active() and gym.player.might.can_begin_defence():
			transition("guard", "full action/reaction ended; READY")
	if phase in ["plan", "guard"]:
		approach_target()
		var contact_time: float = enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact")
		var trigger: float = contact_time - 0.12 + float(press_offset) / 60.0
		if gym.player.might.can_begin_defence() and not gym.player.combat.is_defending() and enemy._state_name() == &"WINDUP" and enemy_clock() >= trigger:
			input(&"defend", true)
			transition("guard", "READY parry at native contact minus0.12 plus sensitivity offset")

func policy_spacing() -> void:
	if gym.player.hit_reaction.is_active():
		stop_moving()
		transition("recover", "actual hit reaction; no action cancel input")
		return
	if phase == "recover":
		if not gym.player.might.can_begin_defence():
			return
		if buttons.get(&"casting", false) and gym.player.magic.get_marked_count() == 0:
			# A real release after charge loss may incur the existing failed-Cast
			# cost. This is logged; no private marking-state reset is used.
			input(&"casting", false)
			transition("recover_release", "release lost charge through actual input")
			return
		transition("plan", "reaction ended through normal lifecycle")
	if phase == "recover_release":
		if frame_now() - phase_started >= 2 and gym.player.might.can_begin_defence():
			transition("plan", "normal failed/rejected release processing completed")
		return
	if phase == "plan":
		followup_sent = false
		pivoted = false
		if not gym.player.might.can_begin_defence():
			return
		if not gym.player.magic.get_snapshot().is_empty():
			input(&"casting", true)
			transition("retreat_charge", "use existing hit-generated resources")
		else:
			approach_target()
			if absf(gap()) <= 65.0:
				attack_pulse()
				transition("opener", "single X from READY; L2 remains released")
	if phase == "opener":
		if not gym.player.combat.is_attack_playing() and gym.player.might.can_begin_defence():
			transition("plan", "opener ended; inspect actual generated queue")
		return
	if phase == "retreat_charge":
		move_away()
		if absf(gap()) >= gap_threshold:
			stop_moving()
			input(&"move_right", gap() > 0.0)
			input(&"move_left", gap() < 0.0)
			pivot_until = frame_now() + 1
			transition("pivot", "safe threshold reached; one real turn tick")
	elif phase == "pivot":
		if frame_now() >= pivot_until:
			stop_moving()
			pivoted = true
			transition("await_charge", "pivot completed")
	elif phase == "await_charge":
		stop_moving()
		if gym.player.magic.get_marked_count() > 0 and gym.player.might.can_begin_defence():
			input(&"casting", false)
			transition("cast_wait", "actual charged resources and READY release")
	elif phase in ["cast_wait", "followup"]:
		stop_moving()
		if current_kind.begins_with("cast") and gym.player.combat.is_attack_playing() and gym.player.combat.get_normalized_attack_progress() >= 0.6 and not followup_sent:
			attack_pulse()
			followup_sent = true
			transition("followup", "one X queued in existing Cast window")
		if followup_sent and not gym.player.combat.is_attack_playing() and gym.player.might.can_begin_defence():
			transition("plan", "queued melee ended; adapt remaining hit-generated resources")

func setup_attempt(label: String, layout: String) -> void:
	await fresh(label, -1.0)
	if layout == "mirrored":
		gym.player.global_position.x = 80.0
		enemy.global_position.x = -80.0
	elif layout == "wall":
		gym.player.global_position.x = -530.0
		enemy.global_position.x = -370.0
	current_kind = ""
	phase = "plan"
	phase_started = frame_now()
	decision_log = []
	enemy_results = []
	samples = []
	capture_keys = {}
	light_release_at = -1
	followup_sent = false
	consumed_contacts = 0
	pivoted = false
	max_stagnant_ticks = 0
	stagnant_ticks = 0
	last_progress_signature = ""
	input_log = []
	enemy.health_resolver.reaction_evaluated.connect(enemy_evaluation)
	check(gym.player.health.get_current() == 100.0 and enemy.health.get_current() == 200.0 and gym.player.magic.get_snapshot().is_empty() and gym.player.heat.get_value() == 0.0, "Ordinary initial health/resources/Heat")

func count_values(items: Array, key: String) -> Dictionary:
	var result: Dictionary = {}
	for item in items:
		var value := str(item.get(key, ""))
		result[value] = int(result.get(value, 0)) + 1
	return result

func attempt(policy: String, layout: String, limit: int, sensitivity := false) -> void:
	await setup_attempt("%s_%s_offset%s_gap%s" % [policy, layout, press_offset, gap_threshold], layout)
	var first_exchange_observed := false
	for frame in range(limit):
		if gym.attempt_result != &"":
			break
		if light_release_at >= 0 and frame_now() >= light_release_at:
			input(&"light_attack", false)
			light_release_at = -1
		if policy == "parry":
			policy_parry()
		else:
			policy_spacing()
		await tick()
		if sensitivity:
			if policy == "parry" and not gym.player.combat.is_attack_playing() and count_event("light_contact_resolved") >= 1:
				first_exchange_observed = true
				break
			if policy == "parry" and gym.player.health.get_current() < 100.0 and frame_now() > 140:
				first_exchange_observed = true
				break
			if policy == "spacing" and followup_sent and phase == "plan":
				first_exchange_observed = true
				break
	await frames(2)
	var player_contacts := events.filter(func(event): return event.get("kind") == "player_contact_evaluated")
	var melee := events.filter(func(event): return event.get("kind") == "light_contact_resolved")
	var blocked_samples := samples.filter(func(data): return data.policy_phase == "retreat_charge" and absf(float(data.gap)) < gap_threshold and (float(data.player_x) < -560.0 or float(data.player_x) > 560.0))
	var result := {"scenario": scenario, "policy": policy, "layout": layout, "sensitivity": sensitivity, "parry_offset_ticks": press_offset, "gap_threshold": gap_threshold, "duration_ticks": frame_now(), "result": str(gym.attempt_result) if gym.attempt_result != &"" else ("first_exchange_end" if sensitivity and first_exchange_observed else "timeout"), "first_exchange_observed": first_exchange_observed, "final": snapshot(), "casts": count_event("cast_launched"), "cast_attempts": events.filter(func(event): return event.get("kind") == "cast_attempt_resolved"), "melee_outcomes": count_values(melee, "result"), "enemy_contact_outcomes": count_values(player_contacts, "outcome"), "enemy_received_outcomes": count_values(enemy_results, "outcome"), "qualifying_enemy_reactions": enemy_results.filter(func(data): return bool(data.get("eligible", false))).size(), "generated": count_event("orb_created"), "max_no_health_action_progress_ticks": max_stagnant_ticks, "wall_wait_samples": blocked_samples.size(), "inputs": input_log.duplicate(true), "decisions": decision_log.duplicate(true), "events": events.duplicate(true), "enemy_results": enemy_results.duplicate(true), "phases": phases.duplicate(true), "samples": samples.duplicate(true)}
	if gym.attempt_result != &"":
		check(gym.get("_result_layer").visible, "Natural result has actual Gym result UI")
		release_all()
		input(&"ui_accept", true)
		await frames(1)
		input(&"ui_accept", false)
		await frames(6)
		gym = current_scene
		enemy = gym.get("_current_area").get_targets()[0]
		var reset := {"player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "heat": gym.player.heat.get_value(), "poise": enemy.get_poise(), "enemy_contact": enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact"), "enemy_length": enemy.attack_animation.get_animation(&"melee_swing").length, "result": str(gym.attempt_result), "player_reaction": gym.player.hit_reaction.is_active(), "enemy_reaction": enemy.hit_reaction.is_active(), "pending": not gym.player.might.get("_pending_action").is_empty(), "buffer": not gym.player.might.get("_buffered_request").is_empty()}
		check(reset.player_hp == 100.0 and reset.enemy_hp == 200.0 and reset.orbs == 0 and reset.heat == 0.0 and reset.result == "" and not reset.player_reaction and not reset.enemy_reaction and not reset.pending and not reset.buffer, "Actual Enter Retry resets retained candidate state")
		result["retry_reset"] = reset
	report["attempts"].append(result)
	print("DUEL_RESULT: ", JSON.stringify({"scenario": result.scenario, "result": result.result, "ticks": result.duration_ticks, "player_hp": result.final.player_hp, "enemy_hp": result.final.enemy_hp, "casts": result.casts, "melee": result.melee_outcomes, "enemy_contacts": result.enemy_contact_outcomes, "wall_wait_samples": result.wall_wait_samples, "final_phase": result.final.policy_phase}))

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for argument in OS.get_cmdline_user_args():
		if argument == "--capture": capture_enabled = true
		elif argument.begins_with("--variant="): variant = argument.trim_prefix("--variant=")
		elif argument.begins_with("--policy="): selected_policy = argument.trim_prefix("--policy=")
		elif argument.begins_with("--layout="): selected_layout = argument.trim_prefix("--layout=")
		elif argument.begins_with("--suite="): suite = argument.trim_prefix("--suite=")
		elif argument.begins_with("--output="): output_dir = argument.trim_prefix("--output=")
	if output_dir.is_empty(): output_dir = ProjectSettings.globalize_path("res://duel-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: actual renderer required")
		quit(1)
		return
	report = {"variant": variant, "engine": Engine.get_version_info(), "suite": suite, "policy": selected_policy, "capture_enabled": capture_enabled, "attempts": [], "policy_scope": "public telemetry deterministic policies, non-human/non-optimal; initial position setup only; no seeded resources/damage/actions"}
	if suite == "sensitivity":
		for offset in [-3, 0, 3]:
			press_offset = offset
			await attempt("parry", "default", 300, true)
		press_offset = 0
		for threshold in [130.0, 135.0, 145.0]:
			gap_threshold = threshold
			await attempt("spacing", "default", 480, true)
	else:
		for layout in ([selected_layout] if capture_enabled else ["default", "mirrored", "wall"]):
			await attempt(selected_policy, layout, 5400)
	release_all()
	report["checks"] = checks
	report["failures"] = failures
	report["captures"] = captures
	var file := FileAccess.open(output_dir.path_join("%s_%s_%s-duel-report.json" % [variant, suite, selected_policy]), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false): audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty(): print("PASSED: %d duel policy/state checks (%s/%s/%s)" % [checks, variant, suite, selected_policy])
	else: printerr("FAILED: %d / %d duel checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)
