extends SceneTree
## Independent source-pixel truth; manual geometry fixtures and real input runs
## are reported separately. Run only in an isolated project/profile.

const Geometry = preload("res://scripts/combat/attack_geometry.gd")
var poses: Array[Dictionary] = []
var move_id := ""
var atlas_path := ""
var move_position := 1
var gym
var player
var enemy
var fixture: StaticBody2D
var checks := 0
var failures: Array[String] = []
var evidence: Array[Dictionary] = []
var capture := false
var fixtures_only := false
var output := ""


func _initialize() -> void:
	call_deferred("run")


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("FAILED: ", label)


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func fresh() -> void:
	if is_instance_valid(gym):
		gym.get("_current_area").set_lifecycle(StageArea.Lifecycle.RETIRED)
		player.reset_for_stage()
		for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
			audio.stop()
		current_scene = null
		gym.queue_free()
		await process_frame
		await process_frame
	gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await frames(8)
	player = gym.player
	enemy = gym.get("_current_area").get_targets()[0]


func start_fixture(facing: int, heat: bool) -> void:
	player.reset_for_stage()
	player.might.try_select_school(&"fire")
	if heat:
		player.heat.gain_from_commit(1000)
	player.heat.set_process(false)
	player.input_combo._clear()
	for index in range(move_position):
		player.input_combo.accept_light(&"fire")
	player.might._state = MightComponent.State.COMBO_ACTIVE
	player.might._start_action(player.might._make_light_action(Vector2(facing, 0), &"fire"))
	player.sync_combat_body_profile()
	player.might._frame_action_id = player.might._current_action.source_action_id


func seek_fixture(time: float) -> void:
	player.animation_player.stop()
	player.animation_player.play(StringName(move_id))
	player.animation_player.seek(time, true)
	player.might._sample_time = time
	player.might._sample_action_id = player.might._current_action.source_action_id
	player.sync_combat_body_profile()
	player._update_attack_visual()


func source_world(point: Vector2) -> Vector2:
	# Derive registration from the real Sprite rect, offset, scale and facing.
	var local: Vector2 = point + player.sprite.get_rect().position
	if player.sprite.flip_h:
		local.x *= -1.0
	return player.sprite.to_global(local)


func source_cell(region: Rect2) -> int:
	var columns := maxi(int(player.sprite.texture.get_width() / 448), 1)
	return int(region.position.x / 448) + int(region.position.y / 448) * columns


func measured_cell(cell: int) -> Dictionary:
	for pose in poses:
		if int(pose.cell) == cell:
			return pose
	assert(false, "Missing independent source-cell measurement: " + str(cell))
	return {}


func probe(pose: Dictionary, point: Vector2) -> bool:
	fixture.global_position = point
	await frames(1)
	var cast: ShapeCast2D = player.attack_cast
	var prior := {"mask": cast.collision_mask, "position": cast.position, "target": cast.target_position, "radius": cast.shape.radius}
	cast.collision_mask = 32
	cast.position = pose.position
	cast.target_position = pose.target
	cast.shape.radius = pose.radius
	cast.force_shapecast_update()
	var found := false
	for index in range(cast.get_collision_count()):
		found = found or cast.get_collider(index) == fixture
	cast.collision_mask = prior.mask
	cast.position = prior.position
	cast.target_position = prior.target
	cast.shape.radius = prior.radius
	return found


func record(label: String) -> Dictionary:
	var sample := {"label": label, "kind": "manually_sought_fixture", "clock": player.animation_player.current_animation_position,
		"sample_clock": player.might._sample_time, "geometry": str(player.might.get_attack_geometry()),
		"sprite_rect": str(player.sprite.get_rect()), "offset": str(player.sprite.offset),
		"sprite_scale": str(player.sprite.global_scale), "actor_scale": str(player.global_scale),
		"sprite_region": str(player.sprite.region_rect), "flip_h": player.sprite.flip_h,
		"screen_origin": str(player.get_global_transform_with_canvas().origin),
		"heat": player.heat.get_value(), "heat_speed": player.heat.get_speed_multiplier(), "position": str(player.global_position)}
	evidence.append(sample)
	return sample


func shot(label: String) -> void:
	if not capture:
		return
	player.attack_cast.hide()
	enemy.attack_cast.hide()
	for overlay in [false, true]:
		player.set_attack_hitbox_debug_enabled(overlay)
		for index in range(2):
			player.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
		var name := label + ("_overlay" if overlay else "_plain")
		check(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK, "Actual viewport capture: " + name)
		record("capture_" + name)


func fixtures() -> void:
	await fresh()
	player.global_position.x = 0
	enemy.global_position.x = 300
	await frames(16)
	gym.get_node("ContactEvaluation").set_physics_process(false)
	player.movement.set_physics_process(false)
	player.set_process(false)
	enemy.set_physics_process(false)
	enemy.set_process(false)
	fixture = StaticBody2D.new()
	fixture.collision_layer = 32
	fixture.collision_mask = 0
	var collision := CollisionShape2D.new()
	var point := CircleShape2D.new()
	point.radius = 0.5
	collision.shape = point
	fixture.add_child(collision)
	gym.add_child(fixture)
	for heat in [false, true]:
		for facing in [1, -1]:
			start_fixture(facing, heat)
			var clock: Animation = player.animation_player.get_animation(StringName(move_id))
			for key_index in range(clock.track_get_key_count(2)):
				var begin := maxf(clock.get_marker_time(&"active_start"), clock.track_get_key_time(2, key_index))
				var end := minf(clock.get_marker_time(&"active_end"), clock.track_get_key_time(2, key_index + 1) if key_index + 1 < clock.track_get_key_count(2) else clock.length)
				if end <= begin:
					continue
				var cell := source_cell(clock.track_get_key_value(2, key_index))
				var truth := measured_cell(cell)
				var next_cell := source_cell(clock.track_get_key_value(2, key_index + 1)) if key_index + 1 < clock.track_get_key_count(2) else cell
				for time in [begin, (begin + end) * 0.5, end - minf(0.001, (end - begin) * 0.01), end - 0.00001]:
					seek_fixture(time)
					var label := "hold%d_cell%d_face%d_heat%d_t%.6f" % [key_index, cell, facing, int(heat), time]
					var actual_frame := source_cell(player.sprite.region_rect)
					# The native discrete sampler's near-key comparison can choose
					# the next pose just before its printed key. Test the displayed
					# steel, not a Python/GDScript floor-time approximation.
					check(actual_frame == cell or (actual_frame == next_cell and absf(time - end) < 0.0001), label + " native held source cell/boundary")
					var displayed := measured_cell(actual_frame)
					check(player.sprite.get_rect().position.is_equal_approx(Vector2(-224, -348)), label + " engine-derived source root224,348")
					check(source_world(Vector2(224, 400)).is_equal_approx(player.to_global(Vector2(0, 26))), label + " feet registration unchanged")
					var pose: Dictionary = player.might.get_attack_geometry()
					var native := Geometry.facing_pose(Geometry.sample(clock, time), Vector2(facing, 0))
					check(pose == native and is_equal_approx(float(pose.radius), 3.5), label + " committed query/overlay share unchanged-radius native sample")
					for key in ["base", "middle", "tip"]:
						check(await probe(pose, source_world(displayed[key])), label + " physical displayed blade " + key)
					var base: Vector2 = source_world(displayed.base)
					var tip: Vector2 = source_world(displayed.tip)
					var middle: Vector2 = source_world(displayed.middle)
					var direction := (tip - base).normalized()
					check(not await probe(pose, tip + direction * 14), label + " excludes beyond physical tip")
					check(not await probe(pose, base - direction * 14), label + " excludes behind physical blade base")
					for sign_value in [-1, 1]:
						check(not await probe(pose, middle + direction.orthogonal() * 12 * sign_value), label + " excludes side " + str(sign_value))
					var sample := record(label)
					sample["key_index"] = key_index
					sample["nominal_source_cell"] = cell
					sample["displayed_source_cell"] = actual_frame
					sample["boundary_tolerance_sample"] = absf(time - end) < 0.0001
				seek_fixture((begin + end) * 0.5)
				if not heat or cell == int(poses[-1].cell):
					await shot("%s_hold%d_cell%d_face%d_heat%d" % [move_id.trim_prefix("fire_"), key_index, cell, facing, int(heat)])
			seek_fixture(clock.get_marker_time(&"active_start") - 0.00001)
			check(player.might.collect_melee_contacts().is_empty(), "Pre-active request cannot produce contact")
			seek_fixture(clock.get_marker_time(&"active_end") + 0.00001)
			check(player.might.collect_melee_contacts().is_empty(), "Post-active request cannot produce contact")
			# An earlier miss must not spend later contact; the actual collector is
			# exercised against the unchanged Enemy body, not the point fixture.
			start_fixture(facing, heat)
			seek_fixture(0.5)
			enemy.global_position.x = 400
			await frames(1)
			check(player.might.collect_melee_contacts().is_empty(), "Initial active miss leaves late contact available")
			seek_fixture(0.7)
			var pose: Dictionary = player.might.get_attack_geometry()
			var target: Vector2 = player.to_global(Vector2(pose.position) + Vector2(pose.target) * 0.5)
			enemy.global_position = target - Vector2(-11, -59)
			await frames(1)
			var events: Array[HealthEvent] = player.might.collect_melee_contacts()
			check(events.size() == 1, "Late body contact through actual Entity collector")
			check(player.might.collect_melee_contacts().is_empty(), "One target spends contact once per action")
			if events.size() == 1:
				var hp: float = enemy.health.get_current()
				var orbs: int = player.magic.get_snapshot().size()
				enemy.hit_reaction.execute_combat(0, Vector2(facing, 0))
				var result_facts: Dictionary = {}
				var record_result: Callable = func(facts: Dictionary): result_facts.merge(facts, true)
				enemy.health_resolver.reaction_evaluated.connect(record_result)
				HealthResolver.resolve_melee_contacts(events)
				enemy.health_resolver.reaction_evaluated.disconnect(record_result)
				check(result_facts.get("outcome", "") == "INVINCIBLE" and enemy.health.get_current() == hp, "Invincible late target rejects real contact without damage")
				evidence.append({"kind": "collector_rejected_contact", "facing": facing, "max_heat": heat, "result": result_facts})
				check(player.magic.get_snapshot().size() == orbs and player.might.collect_melee_contacts().is_empty(), "Rejected contact remains spent and grants no orb")
				enemy.hit_reaction.reset_for_stage()
				enemy._finish_hit_visual()
			events.clear()
			player.might.cancel_for_player_hit()
			check(player.might.collect_melee_contacts().is_empty(), "Cancellation leaves no contact")
			enemy.global_position = Vector2(300, 21)
	fixture.free()


func press(action: StringName, pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = pressed
	Input.parse_input_event(event)


func ordinary_shot(label: String) -> void:
	if not capture:
		return
	player.attack_cast.hide()
	enemy.attack_cast.hide()
	player.set_attack_hitbox_debug_enabled(true)
	player.queue_redraw()
	await RenderingServer.frame_post_draw
	check(root.get_texture().get_image().save_png(output.path_join(label + ".png")) == OK, "Ordinary live viewport: " + label)
	evidence.append({"kind": "ordinary_input_capture", "label": label, "clock": player.animation_player.current_animation_position,
		"pose": str(player.might.get_attack_geometry()), "sprite_region": str(player.sprite.region_rect),
		"player": str(player.global_position), "enemy": str(enemy.global_position), "enemy_hp": enemy.health.get_current(),
		"action_id": player.might.get("_current_action").get("source_action_id", 0), "heat_speed": player.heat.get_speed_multiplier()})


func ordinary_result(facts: Dictionary, context: Dictionary) -> void:
	if str(facts.get("attacker_move", "")) != move_id:
		return
	var result := context.duplicate()
	result["kind"] = "ordinary_contact_result"
	result["reaction"] = facts.duplicate(true)
	result["action_id"] = player.might.get("_current_action").get("source_action_id", 0)
	result["clock"] = player.animation_player.current_animation_position if player.animation_player.current_animation != &"" else 0.0
	result["enemy_hp"] = enemy.health.get_current()
	evidence.append(result)


func ordinary(facing: int, heat: bool, approach: bool) -> void:
	await fresh()
	var result_observer := ordinary_result.bind({"facing": facing, "initial_max_heat": heat, "approached": approach})
	enemy.health_resolver.reaction_evaluated.connect(result_observer)
	if facing == -1:
		player.global_position.x = 80
		enemy.global_position.x = -80
		press(&"move_left", true)
		await frames(1)
		press(&"move_left", false)
	if approach:
		var move: StringName = &"move_right" if facing == 1 else &"move_left"
		press(move, true)
		for index in range(90):
			await frames(1)
			if absf(player.global_position.x - enemy.global_position.x) <= 95:
				break
		press(move, false)
	if heat:
		player.heat.gain_from_commit(1000)
	var requested: Dictionary = {}
	var saw_x2 := false
	var x2_id := 0
	var x2_events := 0
	var hp_at_start := 200.0
	var captured := false
	for tick in range(600):
		var action: Dictionary = player.might.get("_current_action")
		var action_id := int(action.get("source_action_id", 0))
		var ready: bool = int(player.might.get("_state")) == MightComponent.State.READY
		if tick == 0 or (not saw_x2 and ready) or (action_id > 0 and not requested.has(action_id) and action.get("move_id", &"") != StringName(move_id) and player.combat.get_current_chain_position() < move_position and player.combat.get_normalized_attack_progress() >= 0.35):
			requested[action_id] = true
			press(&"light_attack", true)
			press(&"light_attack", false)
		await frames(1)
		action = player.might.get("_current_action")
		if action.get("move_id", &"") == StringName(move_id):
			if not saw_x2:
				saw_x2 = true
				x2_id = int(action.source_action_id)
				hp_at_start = enemy.health.get_current()
			x2_events = maxi(x2_events, action.hit_targets.size())
			var actual_frame := source_cell(player.sprite.region_rect)
			if bool(player.might.get_melee_snapshot().get("active", false)):
				var measured := measured_cell(actual_frame)
				var pose: Dictionary = player.might.get_attack_geometry()
				var base: Vector2 = player.to_global(pose.position)
				var tip: Vector2 = player.to_global(Vector2(pose.position) + Vector2(pose.target))
				for key in ["base", "middle", "tip"]:
					var physical := source_world(measured[key])
					check(Geometry2D.get_closest_point_to_segment(physical, base, tip).distance_to(physical) <= 7.001, "Ordinary visible blade matches sampled query, " + key)
			evidence.append({"kind": "ordinary_input_physics", "tick": tick, "facing": facing, "initial_max_heat": heat, "approached": approach,
				"player": str(player.global_position), "enemy": str(enemy.global_position), "enemy_phase": str(enemy._state_name()),
				"action_id": action.source_action_id, "clock": player.animation_player.current_animation_position,
				"frame": int(player.sprite.region_rect.position.x / 448), "pose": str(player.might.get_attack_geometry()),
				"spent_targets": action.hit_targets.size(), "enemy_hp": enemy.health.get_current(), "heat_speed": player.heat.get_speed_multiplier()})
			if actual_frame == int(poses[-1].cell) and not captured:
				captured = true
				await ordinary_shot("ordinary_%s_face%d_heat%d_approach%d" % [move_id.trim_prefix("fire_"), facing, int(heat), int(approach)])
		elif saw_x2:
			break
	check(saw_x2 and x2_id > 0, "Ordinary input starts committed " + move_id + ", facing%d heat%d" % [facing, int(heat)])
	check(x2_events <= 1 and hp_at_start - enemy.health.get_current() >= 0.0 and hp_at_start - enemy.health.get_current() <= 10.0, "Ordinary selected move spends no more than one saved-damage contact, facing%d heat%d approach%d" % [facing, int(heat), int(approach)])
	if approach and move_position <= 2:
		check(x2_events == 1, "Normal-input approach places " + move_id + " in reach, facing%d heat%d" % [facing, int(heat)])
	enemy.health_resolver.reaction_evaluated.disconnect(result_observer)


func run() -> void:
	root.size = Vector2i(1280, 720)
	var truth: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://probe_points.json"))
	move_id = str(truth["move_id"])
	atlas_path = "res://" + str(truth["atlas"])
	move_position = int(move_id.right(1))
	for pose in truth["poses"]:
		var point: Dictionary = pose.duplicate(true)
		point["cell"] = int(pose.get("cell", pose.get("frame", -1)))
		for key in ["base", "middle", "tip"]:
			point[key] = Vector2(float(pose[key][0]), float(pose[key][1]))
		poses.append(point)
	check(FileAccess.get_sha256(atlas_path) == truth["atlas_sha256"], "Independent current-atlas hash")
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture":
			capture = true
		elif arg == "--fixtures-only":
			fixtures_only = true
		elif arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
	if output.is_empty():
		output = ProjectSettings.globalize_path("user://" + move_id + "-geometry")
	DirAccess.make_dir_recursive_absolute(output)
	await fixtures()
	if not fixtures_only:
		for heat in [false, true]:
			for facing in [1, -1]:
				for approach in [false, true]:
					await ordinary(facing, heat, approach)
	var report := {"engine": Engine.get_version_info(), "checks": checks, "failures": failures, "events": evidence,
		"move_id": move_id, "source_atlas_sha256": FileAccess.get_sha256(atlas_path),
		"fixture_sha256": FileAccess.get_sha256("res://dev_portal_test.gd"), "points_sha256": FileAccess.get_sha256("res://probe_points.json"),
		"animation_sha256": FileAccess.get_sha256("res://config/attack_animations/" + move_id + ".tres"),
		"limits": "Point/collector/manual-seek fixtures are distinct from ordinary input/physics. No saved tuning, art, body or AI changes. Capture is not human feel acceptance."}
	var file := FileAccess.open(output.path_join("report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	gym.get("_current_area").set_lifecycle(StageArea.Lifecycle.RETIRED)
	player.reset_for_stage()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	current_scene = null
	gym.queue_free()
	await process_frame
	await process_frame
	if failures.is_empty():
		print("PASSED: %d %s geometry checks" % [checks, move_id])
	else:
		printerr("FAILED: %d/%d %s geometry checks" % [failures.size(), checks, move_id])
	quit(0 if failures.is_empty() else 1)
