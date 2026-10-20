extends "res://tools/tests/overnight_gym_input_test.gd"
## Poise A/B: scene setup is labeled; every attack, parry and move is real input.
## Initial orbs are used only for isolated Cast-level formula cases.

var variant := "unspecified"
var output_dir := ""
var capture_enabled := false
var samples: Array = []
var captures: Array = []
var capture_keys: Dictionary = {}
const CAPTURE_FRAMES := [17, 45, 48, 49, 64, 83, 95, 110, 120]

func parry_trigger_time() -> float:
	# Current retained contract; fixed0.68 remains in archived losing-policy data.
	return enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact") - 0.12

func capture_frame_targets() -> Array:
	return CAPTURE_FRAMES

func enemy_result(data: Dictionary) -> void:
	var snapshot := data.duplicate(true)
	snapshot["kind"] = "enemy_contact_evaluated"
	snapshot["frame"] = Engine.get_physics_frames() - start_frame
	snapshot["phase_after_resolution"] = str(enemy._state_name())
	snapshot["enemy_action_id"] = enemy.get("_attack_id")
	events.append(snapshot)

func record_state() -> Dictionary:
	return {"frame": Engine.get_physics_frames() - start_frame, "enemy_phase": str(enemy._state_name()), "enemy_clock": enemy_clock(), "enemy_action_id": enemy.get("_attack_id"), "enemy_strike_emitted": enemy.get("_strike_emitted"), "enemy_hp": enemy.health.get_current(), "player_hp": gym.player.health.get_current(), "player_action": str(gym.player.might.get("_current_action").get("kind", "")), "player_progress": gym.player.combat.get_normalized_attack_progress(), "ready": gym.player.might.can_begin_defence(), "defending": gym.player.combat.is_defending(), "player_x": gym.player.global_position.x, "enemy_x": enemy.global_position.x, "orbs": gym.player.magic.get_snapshot().size(), "charged": gym.player.magic.get_marked_count()}

func observe() -> void:
	var data := record_state()
	samples.append(data)
	if capture_enabled and capture_frame_targets().has(int(data.frame)) and not capture_keys.has(data.frame):
		capture_keys[data.frame] = true
		var frame: int = data.frame
		await RenderingServer.frame_post_draw
		data = record_state()
		check(int(data.frame) == frame, "Capture stays on scheduled physics tick")
		var image := root.get_texture().get_image()
		var path := output_dir.path_join("%s_%s_f%03d.png" % [variant, scenario, frame])
		check(image.save_png(path) == OK and not image.is_empty(), "Actual full viewport capture: " + path)
		data["png"] = path
		data["width"] = image.get_width()
		data["height"] = image.get_height()
		captures.append(data)

func tick(count: int = 1) -> void:
	for frame in range(count):
		await frames(1)
		await observe()

func begin_case(label: String, ai_enabled := true, initial_gap := 56.0) -> void:
	await fresh(label, initial_gap)
	samples = []
	capture_keys = {}
	enemy.health_resolver.reaction_evaluated.connect(enemy_result)
	if not ai_enabled:
		gym.get("_config")["enemy_ai"]["enabled"] = false
		gym._apply_runtime_tuning()

func results(kind: String) -> Array:
	return events.filter(func(event): return event.get("kind") == kind)

func save_case(extra: Dictionary = {}) -> void:
	var enemy_hits := results("enemy_contact_evaluated")
	var player_hits := results("player_contact_evaluated")
	var data := {"scenario": scenario, "poise": enemy.get_poise(), "events": events.duplicate(true), "phases": phases.duplicate(true), "samples": samples.duplicate(true), "final": record_state(), "enemy_contact_count": enemy_hits.size(), "player_contact_count": player_hits.size(), "cast_launches": results("cast_launched").size(), "generated_orbs": results("orb_created").size()}
	data.merge(extra)
	report["scenarios"].append(data)
	print("POISE_OBSERVATION: ", JSON.stringify({"scenario": scenario, "poise": data.poise, "final": data.final, "cast_launches": data.cast_launches, "generated_orbs": data.generated_orbs}))

func opener_probe(policy: String, mirror := false, wall := false) -> void:
	await begin_case(policy + ("_mirror" if mirror else "") + ("_wall" if wall else ""), true, -1.0 if mirror or wall else 56.0)
	if mirror or wall:
		gym.player.global_position.x = (560.0 if mirror else -560.0) if wall else 0.0
		enemy.global_position.x = gym.player.global_position.x + (-56.0 if mirror else 56.0)
		# Actual direction input establishes the mirrored attack facing.
		input(&"move_left" if mirror else &"move_right", true)
		await tick()
		input(&"move_left" if mirror else &"move_right", false)
	var ready_frame := -1
	var defend_frame := -1
	var retreat_frame := -1
	var attacked := false
	var parry_received := false
	if policy != "parry_then_X_READY_spacing":
		await tap(&"light_attack")
		attacked = true
	for frame in range(150):
		var player_contacts := results("player_contact_evaluated")
		if policy == "parry_then_X_READY_spacing" and not attacked:
			if gym.player.might.can_begin_defence() and enemy._state_name() == &"WINDUP" and enemy_clock() >= parry_trigger_time():
				input(&"defend", true)
			if player_contacts.any(func(event): return event.get("outcome") == "PARRIED"):
				input(&"defend", false)
				await tap(&"light_attack")
				attacked = true
				parry_received = true
		if attacked and not results("light_contact_resolved").is_empty() and gym.player.might.can_begin_defence() and ready_frame < 0:
			ready_frame = Engine.get_physics_frames() - start_frame
		if ready_frame >= 0:
			if policy == "X_READY_parry" and gym.player.might.can_begin_defence() and enemy._state_name() == &"WINDUP" and enemy_clock() >= parry_trigger_time() and defend_frame < 0:
				input(&"defend", true)
				defend_frame = Engine.get_physics_frames() - start_frame
			elif policy in ["X_READY_spacing", "parry_then_X_READY_spacing"]:
				input(&"move_right" if mirror else &"move_left", true)
				if retreat_frame < 0:
					retreat_frame = Engine.get_physics_frames() - start_frame
		if policy == "X_READY_parry" and defend_frame >= 0 and not player_contacts.is_empty():
			input(&"defend", false)
		await tick()
	release_all()
	check(results("orb_created").size() == 1, "Single real opener generates exactly one orb: " + scenario)
	var hit := results("enemy_contact_evaluated")
	check(not hit.is_empty() and int(hit[0].value) == 10 - enemy.get_poise(), "X1 receiver formula remains unchanged: " + scenario)
	check(is_equal_approx(enemy.health.get_current(), 190.0), "Nonqualifying X1 still deals ten damage: " + scenario)
	if policy == "X_READY_parry":
		check(results("player_contact_evaluated").any(func(event): return event.get("outcome") == "PARRIED"), "Existing READY-gated parry can succeed: " + scenario)
	if policy == "parry_then_X_READY_spacing":
		check(parry_received, "Parry-first spacing probe used actual parry")
	var contact_frames := results("player_contact_evaluated").map(func(event): return event.frame)
	save_case({"policy": policy, "ready_frame": ready_frame, "defend_input_frame": defend_frame, "retreat_input_frame": retreat_frame, "player_contact_frames": contact_frames, "mirror": mirror, "wall": wall, "setup": "initial gap/optional wall placement; all actions real input; no Charging to preserve READY eligibility"})

func higher_melee(index: int) -> void:
	await begin_case("higher_melee_X" + str(index), false)
	input(&"casting", true)
	await tick()
	for position in range(1, index + 1):
		if position == index:
			gym.get("_config")["enemy_ai"]["enabled"] = true
			gym._apply_runtime_tuning()
		await tap(&"light_attack")
		for frame in range(180):
			await tick()
			if not gym.player.combat.is_attack_playing() and not enemy.hit_reaction.is_active():
				break
		if position == index:
			break
	var hits := results("enemy_contact_evaluated")
	check(hits.size() >= index, "Real chain reaches requested higher hit: " + scenario)
	if hits.size() >= index:
		var contact: Dictionary = hits[index - 1]
		check(int(contact.incoming_impact) == index * 10 and int(contact.value) == index * 10 - enemy.get_poise() - int(contact.active_contribution), "Higher melee uses existing reaction formula: " + scenario)
		check(bool(contact.eligible), "Qualifying higher hit retains reaction eligibility: " + scenario)
	save_case({"setup": "AI disabled for real prefix hits; held L2 preserves chain across existing invincibility waits; AI enabled for the tested higher move; no initial orbs"})

func cast_level(level: int) -> void:
	await begin_case("cast_level_" + str(level), false)
	for orb in range(level):
		gym.player.magic.add_orb(&"fire")
	input(&"casting", true)
	for frame in range(300):
		await tick()
		if gym.player.magic.get_marked_count() == level:
			break
	gym.get("_config")["enemy_ai"]["enabled"] = true
	gym._apply_runtime_tuning()
	var release_frame := Engine.get_physics_frames() - start_frame
	input(&"casting", false)
	await tick(85)
	var hits := results("enemy_contact_evaluated")
	check(results("cast_launched").size() == 1 and not hits.is_empty(), "Actual release launches/contacts once: " + scenario)
	if not hits.is_empty():
		check(int(hits[0].value) == level * 10 - enemy.get_poise() and int(hits[0].level) == (0 if level * 10 <= enemy.get_poise() else level - (1 if enemy.get_poise() == 10 else 0)), "Leveled Cast keeps the existing bands/formula: " + scenario)
	check(is_equal_approx(enemy.health.get_current(), 190.0), "Normal Cast damage stays ten at every tested level: " + scenario)
	save_case({"initial_resource_setup": level, "release_frame": release_frame, "setup": "initial Fire orbs; real L2 Charging/release; AI enabled together with release for actual windup/contact"})

func pressure_cycle(spaced := false, gap_retreat := false) -> void:
	await begin_case("parry_generate_gap135_cast_melee" if gap_retreat else ("parry_generate_retreat14_cast_melee" if spaced else "real_generate_charge_release_melee_under_pressure"))
	if spaced:
		for frame in range(90):
			if gym.player.might.can_begin_defence() and enemy._state_name() == &"WINDUP" and enemy_clock() >= parry_trigger_time():
				input(&"defend", true)
			await tick()
			if results("player_contact_evaluated").any(func(event): return event.get("outcome") == "PARRIED"):
				break
		input(&"defend", false)
	input(&"casting", true)
	await tick()
	await tap(&"light_attack")
	var release_frame := -1
	var followup_sent := false
	for frame in range(180):
		if spaced and release_frame < 0 and gym.player.magic.get_marked_count() > 0 and not gym.player.combat.is_attack_playing():
			# Legal movement after the action ends; held L2 preserves the chain.
			input(&"move_left", true)
			if gap_retreat:
				for step in range(60):
					await tick()
					if absf(gap()) >= 135.0:
						break
			else:
				await tick(14)
			input(&"move_left", false)
			input(&"move_right", true)
			await tick()
			input(&"move_right", false)
			input(&"casting", false)
			release_frame = Engine.get_physics_frames() - start_frame
		elif not spaced and release_frame < 0 and gym.player.magic.get_marked_count() > 0 and gym.player.combat.get_normalized_attack_progress() >= 0.48:
			input(&"casting", false)
			release_frame = Engine.get_physics_frames() - start_frame
		var action: Dictionary = gym.player.might.get("_current_action")
		if not followup_sent and str(action.get("kind", "")).begins_with("cast") and gym.player.combat.get_normalized_attack_progress() >= 0.6:
			await tap(&"light_attack")
			followup_sent = true
		await tick()
	check(results("orb_created").size() >= 1 and (results("cast_attempt_resolved").size() >= 1 if spaced else results("cast_committed").size() == 1), "Pressure policy generates resources and makes a real release request; success is observed separately")
	save_case({"release_frame": release_frame, "followup_input_sent": followup_sent, "policy": "parry first; hold L2 during X1; after action ends retreat to gap>=135 then face toward Enemy1 tick; release Cast and queue melee at progress>=0.6; no initial resources/cancels" if gap_retreat else ("parry first; hold L2 during real X1; after action ends retreat14 ticks then turn toward Enemy1 tick; release Cast and queue melee at progress>=0.6; no initial resources/cancels" if spaced else "hold L2 during X1; release once first orb charged and normal input window open; queue melee only during actual Cast at progress>=0.6; no defence cancel/retry or initial resources")})

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
		output_dir = ProjectSettings.globalize_path("res://poise-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: actual renderer required for capture")
		quit(1)
		return
	report = {"variant": variant, "engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "capture_enabled": capture_enabled, "scenarios": []}
	await opener_probe("X_no_defence")
	await opener_probe("X_READY_parry")
	await opener_probe("parry_then_X_READY_spacing")
	if not capture_enabled:
		await opener_probe("X_READY_spacing")
		await opener_probe("X_no_defence", true, false)
		await opener_probe("X_no_defence", false, true)
		await opener_probe("X_no_defence", true, true)
		for index in [2, 3, 4, 5]:
			await higher_melee(index)
		for level in [1, 2, 3, 4]:
			await cast_level(level)
		await pressure_cycle()
		await pressure_cycle(true)
		await pressure_cycle(true, true)
	release_all()
	report["checks"] = checks
	report["failures"] = failures
	report["captures"] = captures
	var file := FileAccess.open(output_dir.path_join(variant + "-poise-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d real-input Gym Poise checks (%s)" % [checks, variant])
	else:
		printerr("FAILED: %d / %d Poise checks (%s)" % [failures.size(), checks, variant])
	quit(0 if failures.is_empty() else 1)
