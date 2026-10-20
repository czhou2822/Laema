extends "res://tools/tests/overnight_contact_probe_test.gd"
## Shifted-circle comparison. Frozen geometry sweeps are fixture-only; chains
## use real InputMap events/physics. No damage/reaction/resource acceptance is forced.
var variant := "unspecified"
var capture_enabled := false
var output_dir := ""
var query_records: Array = []
var health_records: Array = []
var player_results: Array = []
var seen_queries: Dictionary = {}
var capture_keys: Dictionary = {}
var captures: Array = []
var pending_captures := 0
var last_enemy_hp := 200.0
var last_evaluated_hp := 200.0
var health_changes: Array = []

func fresh(label: String, initial_gap := -1.0) -> void:
	await super.fresh(label, initial_gap)
	if capture_enabled:
		# Private run-only use of existing hitbox drawing; no config/asset save.
		gym.get("_config")["ui"]["attack_hitbox_visible"] = true
		gym._apply_runtime_tuning()

func contact_geometry() -> Dictionary:
	var data := super.contact_geometry()
	if not data.is_empty():
		data["player_origin"] = str(gym.player.global_position)
		data["actual_root_separation"] = absf(enemy.global_position.x - gym.player.global_position.x)
		data["player_wall_contact"] = gym.player.is_on_wall()
		var bodies: Array = []
		for index in range(gym.player.get_slide_collision_count()):
			bodies.append(str(gym.player.get_slide_collision(index).get_collider().get_path()))
		data["player_slide_colliders"] = bodies
		data["motion_profile"] = gym.player.might.get("_current_action").get("style", {}).duplicate(true)
		data["consumed_lunge_fraction"] = gym.player.might.get("_current_action").get("lunge_fraction", 0.0)
	return data

func enemy_health(value: float, _maximum: float) -> void:
	health_changes.append({"frame": Engine.get_physics_frames() - start_frame, "delta": value - last_enemy_hp, "after": value})
	last_enemy_hp = value

func enemy_evaluation(snapshot: Dictionary) -> void:
	var data := contact_geometry()
	data["evaluation"] = snapshot.duplicate(true)
	data["health_delta_observed"] = enemy.health.get_current() - last_evaluated_hp
	last_evaluated_hp = enemy.health.get_current()
	data["frame"] = Engine.get_physics_frames() - start_frame
	health_records.append(data)

func player_evaluation(snapshot: Dictionary) -> void:
	var data := snapshot.duplicate(true)
	data["frame"] = Engine.get_physics_frames() - start_frame
	player_results.append(data)

func capture(data: Dictionary) -> void:
	if not capture_enabled or data.is_empty() or data.get("move") not in ["fire_x2", "fire_x3"]:
		return
	var key := "%s_%s" % [scenario, data.action_id]
	if capture_keys.has(key):
		return
	capture_keys[key] = true
	pending_captures += 1
	var frame: int = data.frame
	await RenderingServer.frame_post_draw
	var metadata := data.duplicate(true)
	metadata["post_draw_frame"] = Engine.get_physics_frames() - start_frame
	metadata["debug_setup"] = "existing private-run attack hitbox overlay"
	check(int(metadata.post_draw_frame) == frame, "Rendered contact remains on measured physics frame")
	var image := root.get_texture().get_image()
	var path := output_dir.path_join("%s_%s_%s_f%03d.png" % [variant, scenario, data.move, frame])
	check(image.save_png(path) == OK and not image.is_empty(), "Actual contact viewport PNG: " + path)
	metadata["png"] = path
	metadata["width"] = image.get_width()
	metadata["height"] = image.get_height()
	captures.append(metadata)
	pending_captures -= 1

func tick() -> void:
	await frames(1)
	var action: Dictionary = gym.player.might.get("_current_action")
	if not action.is_empty() and action.get("kind") == &"light" and bool(gym.player.might.get("_hit_emitted")):
		var id: int = action.source_action_id
		if not seen_queries.has(id):
			seen_queries[id] = true
			var data := contact_geometry()
			data["emission_type"] = "clash-consumed contact" if float(data.clock) < float(data.contact_marker) else "native once-only query"
			query_records.append(data)
			capture(data)

func spatial_sweep() -> void:
	await fresh("frozen_spatial_sweep", -1.0)
	enemy.set_physics_process(false)
	gym.player.movement.set_physics_process(false)
	gym.player.might.set_physics_process(false)
	var gaps := [16.0, 24.0, 25.0, 27.0, 28.0, 29.0, 30.0, 31.0, 44.0, 46.0, 47.0, 48.0, 49.0, 50.0, 51.0, 52.0, 53.0, 56.0, 64.0, 112.0, 113.0, 114.0, 115.0, 116.0, 117.0, 118.0, 119.0, 120.0, 130.0, 134.0, 135.0, 136.0, 137.0, 138.0, 139.0, 140.0, 141.0, 142.0, 180.0]
	for move in [2, 3]:
		for left in [false, true]:
			for separation in gaps:
				gym.player.reset_for_stage()
				enemy._reset_ai_execution()
				enemy.health.reset_to_maximum()
				gym.player.global_position = Vector2(-80, 0)
				enemy.global_position = gym.player.global_position + Vector2(-separation if left else separation, 16)
				await frames(1)
				for prefix in range(move - 1):
					gym.player.might.get("_input_combo").accept_light(&"fire")
				enemy.ai_begin_windup(gym.player)
				gym.player.might.try_light_attack(Vector2.LEFT if left else Vector2.RIGHT)
				var data := contact_geometry()
				gym.player.might._physics_process(float(gym.get("_config")["moves"]["fire_x%d" % move]["windup_duration"]) + 0.001)
				data["applied"] = enemy.health.get_current() == 190.0
				data["separation_setup"] = separation
				data["left"] = left
				data["setup"] = "frozen fixture chain-position selection/manual native clock; no body recovery/lunge"
				check(bool(data.independent_target_contact) == bool(data.applied), "Actual query agrees with transformed authored circle")
				check(float(data.live_radius) == 16.0 and str(data.live_target) == "(0.0, 0.0)", "Radius and zero-length point query remain unchanged")
				if separation == 180.0:
					check(not bool(data.applied), "Genuine far miss remains outside the shifted circle")
				var hp: float = enemy.health.get_current()
				gym.player.might._physics_process(0.05)
				check(enemy.health.get_current() == hp, "One native contact cannot apply a second hit")
				report["spatial_sweep"].append(data)

func chain_case(label: String, separation: float, left: bool, ai: bool, count := 3) -> void:
	await fresh(label, -1.0)
	diagnostics = []
	query_records = []
	health_records = []
	player_results = []
	health_changes = []
	seen_queries = {}
	record_real = true
	last_enemy_hp = enemy.health.get_current()
	last_evaluated_hp = enemy.health.get_current()
	enemy.health.health_changed.connect(enemy_health)
	enemy.health_resolver.reaction_evaluated.connect(enemy_evaluation)
	gym.player.health_resolver.reaction_evaluated.connect(player_evaluation)
	if not ai:
		gym.get("_config")["enemy_ai"]["enabled"] = false
		gym._apply_runtime_tuning()
	enemy.global_position.x = gym.player.global_position.x + (-separation if left else separation)
	if left:
		input(&"move_left", true)
		await tick()
		input(&"move_left", false)
	input(&"casting", true)
	await tick()
	await tap(&"light_attack")
	var queued: Dictionary = {}
	for frame in range(330 if count == 5 else 210):
		var action: Dictionary = gym.player.might.get("_current_action")
		if not action.is_empty() and action.get("kind") == &"light" and gym.player.combat.get_normalized_attack_progress() >= 0.5 and gym.player.might.get("_pending_action").is_empty():
			var index := int(str(action.move_id).right(1))
			if index < count and not queued.has(index + 1):
				await tap(&"light_attack")
				queued[index + 1] = true
		await tick()
	for event in health_records:
		var outcome: String = event.evaluation.outcome
		if outcome == "INVINCIBLE":
			check(float(event.health_delta_observed) == 0.0, "Spatial overlap during invincibility applies no damage")
		if bool(event.evaluation.get("calculated", false)):
			check(int(event.evaluation.value) == int(event.evaluation.incoming_impact) - int(event.evaluation.receiver_poise) - int(event.evaluation.active_contribution), "Existing receiver/clash formula remains unchanged")
	if separation == 180.0:
		check(enemy.health.get_current() == 200.0 and results_orb_count() == 0, "Real far chain generates neither damage nor orbs")
	var applied := health_records.filter(func(event): return event.evaluation.outcome == "APPLIED").size()
	var generated := results_orb_count()
	check(generated == applied, "Generation tracks applied contacts, not all spatial overlaps")
	if count == 3 and label in ["ordinary_close_right", "body_blocked_right", "body_blocked_left"]:
		check(applied == 3 and generated == 3 and enemy.health.get_current() == 170.0, "Retained close/body-blocked chain applies three contacts")
	report["chains"].append({"scenario": label, "initial_separation": separation, "left": left, "ai": ai, "requested_moves": count, "setup": "initial placement/optional AI disable; real L2/X/physics; body recovery/lunge preserved", "queries": query_records.duplicate(true), "health_results": health_records.duplicate(true), "health_changes": health_changes.duplicate(true), "player_results": player_results.duplicate(true), "public_contacts": diagnostics.duplicate(true), "events": events.duplicate(true), "phases": phases.duplicate(true), "generated": generated, "applied": applied, "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current()})
	print("CLOSE_CHAIN: ", label, " ", JSON.stringify({"generated": generated, "applied": applied, "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "contacts": diagnostics.map(func(data): return {"move": data.move, "result": data.public_result, "distance": data.horizontal_axis_distance, "frame": data.frame})}))
	record_real = false

func results_orb_count() -> int:
	return events.filter(func(event): return event.get("kind") == "orb_created").size()

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
		output_dir = ProjectSettings.globalize_path("res://close-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: actual renderer required")
		quit(1)
		return
	report = {"variant": variant, "engine": Engine.get_version_info(), "capture_enabled": capture_enabled, "debug_overlay_private_setup": capture_enabled, "spatial_sweep": [], "chains": []}
	if not capture_enabled:
		await spatial_sweep()
	await chain_case("ordinary_close_right", 56.0, false, true)
	await chain_case("inside_right", 64.0, false, false)
	if not capture_enabled:
		await chain_case("inside_left", 64.0, true, false)
		await chain_case("body_blocked_right", 30.0, false, true)
		await chain_case("body_blocked_left", 16.0, true, true)
		await chain_case("outer_right", 146.0, false, false)
		await chain_case("outer_left", 132.0, true, false)
		await chain_case("far_right", 180.0, false, false)
		await chain_case("far_left", 180.0, true, false)
		await chain_case("five_hit_invincibility", 64.0, false, false, 5)
	while pending_captures > 0:
		await process_frame
	release_all()
	report["checks"] = checks
	report["failures"] = failures
	report["captures"] = captures
	var file := FileAccess.open(output_dir.path_join(variant + "-close-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d close-contact spatial/real-input checks (%s)" % [checks, variant])
	else:
		printerr("FAILED: %d / %d close-contact checks (%s)" % [failures.size(), checks, variant])
	quit(0 if failures.is_empty() else 1)
