extends "res://tools/tests/overnight_gym_input_test.gd"
## Manual fixture geometry is separated from real InputMap chain observations.
const Geometry = preload("res://scripts/combat/attack_geometry.gd")
var diagnostics: Array = []
var evaluating: Array = []
var record_real := false

func contact_geometry() -> Dictionary:
	var action: Dictionary = gym.player.might.get("_current_action")
	if action.is_empty():
		return {}
	var pose: Dictionary = action.get("geometry", {})
	var shape := CircleShape2D.new()
	shape.radius = float(pose.radius)
	var transform: Transform2D = gym.player.global_transform
	transform.origin = gym.player.to_global(pose.position)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = transform
	query.collision_mask = gym.player.attack_cast.collision_mask
	var independent := root.world_2d.direct_space_state.intersect_shape(query)
	var target_shape: CollisionShape2D = enemy.get_node("CollisionShape2D")
	var capsule := target_shape.shape as CapsuleShape2D
	var colliders: Array = []
	for index in range(gym.player.attack_cast.get_collision_count()):
		colliders.append(str(gym.player.attack_cast.get_collider(index).get_path()))
	var clock: Animation = gym.player.animation_player.get_animation(StringName(action.move_id))
	return {"frame": Engine.get_physics_frames() - start_frame, "move": str(action.move_id), "chain_position": gym.player.combat.get_current_chain_position(), "action_id": action.source_action_id, "clock": gym.player.animation_player.current_animation_position, "contact_marker": clock.get_marker_time(&"contact"), "active_start": clock.get_marker_time(&"active_start"), "active_end": clock.get_marker_time(&"active_end"), "captured_geometry": pose, "live_position": str(gym.player.attack_cast.position), "live_target": str(gym.player.attack_cast.target_position), "live_radius": gym.player.attack_cast.shape.radius, "player_transform": str(gym.player.global_transform), "world_center": str(transform.origin), "world_radius": shape.radius * transform.x.length(), "enemy_origin": str(enemy.global_position), "enemy_collider_center": str(target_shape.global_position), "enemy_collider_bounds": str(target_shape.global_transform * capsule.get_rect()), "capsule_radius": capsule.radius, "capsule_height": capsule.height, "mask": query.collision_mask, "layer": enemy.collision_layer, "margin": gym.player.attack_cast.margin, "horizontal_axis_distance": absf(transform.origin.x - target_shape.global_position.x), "radii_sum": shape.radius * transform.x.length() + capsule.radius, "independent_target_contact": independent.any(func(hit): return hit.collider == enemy), "cached_colliders": colliders, "hit_emitted": gym.player.might.get("_hit_emitted"), "enemy_hp": enemy.health.get_current(), "invincible": enemy.hit_reaction.is_invincible(), "enemy_state": str(enemy._state_name())}

func on_outcome(outcome) -> void:
	super.on_outcome(outcome)
	if record_real and outcome.get_kind() == &"light_contact_resolved":
		var data := contact_geometry()
		data["public_result"] = str(outcome.get_fact(&"result"))
		diagnostics.append(data)

func collect(snapshot: Dictionary) -> void:
	evaluating.append(snapshot.duplicate(true))

func manual_case(position: int, separation: float, left: bool, waits: int = 1) -> void:
	var mighty = gym.player.might
	gym.player.reset_for_stage()
	enemy._reset_ai_execution()
	enemy.health.reset_to_maximum()
	gym.player.global_position = Vector2(-80, 0)
	enemy.global_position = gym.player.global_position + Vector2(-separation if left else separation, 16)
	await frames(waits)
	for previous in range(position - 1):
		mighty.get("_input_combo").accept_light(&"fire")
	enemy.ai_begin_windup(gym.player)
	evaluating = []
	mighty.try_light_attack(Vector2.LEFT if left else Vector2.RIGHT)
	var before := contact_geometry()
	mighty._physics_process(float(gym.get("_config")["moves"]["fire_x%d" % position]["windup_duration"]) + 0.001)
	var after := contact_geometry()
	var applied: bool = enemy.health.get_current() == 190.0
	check(bool(before.independent_target_contact) == applied, "Independent native overlap matches actual contact at %s/%s/%s" % [position, separation, left])
	check(after.move == "fire_x%d" % position and bool(after.hit_emitted) and float(after.clock) >= float(after.contact_marker), "Selected move crosses its own marker and queries once")
	if separation == 64.0 or (separation == 48.0 and not left and position in [2, 3]):
		check(applied and evaluating.size() == 1 and int(evaluating[0].level) == position - 1, "Default GymPoise10 inside contact keeps damage and Levels0–4")
	elif separation == 180.0 or (separation == 16.0 and position in [2, 3]):
		check(not applied and evaluating.is_empty() and not enemy.hit_reaction.is_invincible(), "Authored outside placement is a genuine miss")
	var hp: float = enemy.health.get_current()
	var orbs: int = gym.player.magic.get_snapshot().size()
	mighty._physics_process(0.1)
	check(enemy.health.get_current() == hp and gym.player.magic.get_snapshot().size() == orbs, "No second contact or orb after the once-only query")
	var data := {"type": "fixture-only selected chain position/manual clock; no lunge movement", "position": position, "separation": separation, "left": left, "synchronization_wait_ticks": waits, "before": before, "after": after, "evaluations": evaluating.duplicate(true), "applied": applied}
	report["manual_cases"].append(data)
	print("SPATIAL: ", JSON.stringify({"move": before.move, "gap": separation, "left": left, "waits": waits, "center": before.world_center, "target_center": before.enemy_collider_center, "distance": before.horizontal_axis_distance, "radii_sum": before.radii_sum, "independent": before.independent_target_contact, "applied": applied, "clock": after.clock, "marker": after.contact_marker}))

func real_chain(label: String, separation: float, left: bool, ai_enabled: bool) -> void:
	await fresh(label, -1.0)
	diagnostics = []
	record_real = true
	if not ai_enabled:
		gym.get("_config")["enemy_ai"]["enabled"] = false
		gym._apply_runtime_tuning()
	enemy.global_position.x = gym.player.global_position.x + (-separation if left else separation)
	if left:
		input(&"move_left", true)
		await frames(1)
		input(&"move_left", false)
	input(&"casting", true)
	await frames(1)
	await tap(&"light_attack")
	var queued_two := false
	var queued_three := false
	for frame in range(210):
		var action: Dictionary = gym.player.might.get("_current_action")
		if gym.player.combat.is_attack_playing() and gym.player.combat.get_normalized_attack_progress() >= 0.5 and gym.player.might.get("_pending_action").is_empty():
			if action.get("move_id") == &"fire_x1" and not queued_two:
				await tap(&"light_attack")
				queued_two = true
			elif action.get("move_id") == &"fire_x2" and not queued_three:
				await tap(&"light_attack")
				queued_three = true
		await frames(1)
	check(queued_two and queued_three, "Actual InputMap X1→X2→X3 requests traverse native queue")
	if separation == 180.0:
		check(enemy.health.get_current() == 200.0 and diagnostics.all(func(data): return data.public_result == "miss"), "Real distant chain misses without inflating reach")
	elif separation == 64.0 and not ai_enabled:
		check(diagnostics.filter(func(data): return data.public_result == "hit").size() == 3 and enemy.health.get_current() == 170.0, "Real inside chain has three actual hits")
	elif separation == 56.0 and ai_enabled and not left:
		check(diagnostics.filter(func(data): return data.public_result == "hit").size() == 3 and enemy.health.get_current() == 170.0, "Retained close chain applies X1/X2/X3 contacts")
	report["real_chains"].append({"scenario": label, "initial_separation": separation, "left": left, "ai_enabled": ai_enabled, "setup": "initial target placement/optional AI disable only; actual L2 preserves chain, actual X presses and physics drive every move", "diagnostics": diagnostics.duplicate(true), "events": events.duplicate(true), "phases": phases.duplicate(true), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current()})
	print("REAL_CHAIN: ", label, " ", JSON.stringify(diagnostics.map(func(data): return {"move": data.move, "result": data.public_result, "distance": data.horizontal_axis_distance, "radii_sum": data.radii_sum, "frame": data.frame})))
	record_real = false

func _run() -> void:
	report = {"engine": Engine.get_version_info(), "manual_cases": [], "real_chains": []}
	await fresh("manual_geometry", -1.0)
	enemy.set_physics_process(false)
	gym.player.movement.set_physics_process(false)
	gym.player.might.set_physics_process(false)
	enemy.health_resolver.reaction_evaluated.connect(collect)
	for separation in [16.0, 48.0, 64.0, 180.0]:
		for left in [false, true]:
			for position in range(1, 6):
				await manual_case(position, separation, left)
	for position in [2, 3]:
		await manual_case(position, 48.0, false, 3)
	await real_chain("ordinary_close_right", 56.0, false, true)
	await real_chain("inside_right", 64.0, false, false)
	await real_chain("inside_left", 64.0, true, false)
	await real_chain("outside_right", 180.0, false, false)
	await real_chain("outside_left", 180.0, true, false)
	release_all()
	report["checks"] = checks
	report["failures"] = failures
	var file := FileAccess.open("res://contact-probe-report.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d contact geometry/real-input checks" % checks)
	else:
		printerr("FAILED: %d / %d contact probe checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)
