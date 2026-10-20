extends SceneTree
## Run through test-dev-portal.py in an isolated project. Geometry fixtures are
## distinguished from the ordinary physics/input and rendered Gym checks below.

const Geometry = preload("res://scripts/combat/attack_geometry.gd")
const FIRE_POINTS := {
	"fire_x1": [[Vector2(176, 254), Vector2(78, 236)], [Vector2(176, 198), Vector2(253, 163)], [Vector2(316, 277), Vector2(408, 291)], [Vector2(245, 315), Vector2(310, 365)]],
	"fire_x2": [[Vector2(172, 317), Vector2(95, 371)], [Vector2(148, 270), Vector2(74, 298)], [Vector2(147, 262), Vector2(61, 258)]],
	"fire_x3": [[Vector2(153, 270), Vector2(61, 262)], [Vector2(150, 290), Vector2(69, 294)], [Vector2(296, 315), Vector2(390, 323)], [Vector2(250, 325), Vector2(312, 368)]],
	"fire_x4": [[Vector2(200, 210), Vector2(296, 211)], [Vector2(194, 221), Vector2(285, 223)], [Vector2(244, 277), Vector2(243, 204)], [Vector2(300, 249), Vector2(366, 220)], [Vector2(296, 247), Vector2(355, 211)]],
	"fire_x5": [[Vector2(199, 205), Vector2(113, 176)], [Vector2(274, 222), Vector2(343, 170)], [Vector2(215, 321), Vector2(144, 386)], [Vector2(218, 331), Vector2(164, 388)]]
}
const PIKE_POINTS := [[Vector2(404, 309), Vector2(447, 234)], [Vector2(408, 318), Vector2(490, 260)], [Vector2(415, 327), Vector2(501, 285)], [Vector2(416, 337), Vector2(525, 290)], [Vector2(432, 350), Vector2(567, 319)], [Vector2(447, 350), Vector2(606, 350)], [Vector2(432, 350), Vector2(568, 319)], [Vector2(415, 339), Vector2(525, 290)], [Vector2(414, 319), Vector2(502, 263)], [Vector2(404, 309), Vector2(447, 234)], [Vector2(404, 309), Vector2(447, 234)]]

var gym
var player
var enemy
var fixture: StaticBody2D
var checks := 0
var failures: Array[String] = []
var capture := false
var output := ""
var captures: Array[String] = []
var samples: Array = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures.append(label)
		printerr("FAILED: ", label)

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func fresh() -> void:
	if is_instance_valid(gym):
		for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
			audio.stop()
		current_scene = null
		gym.free()
		await process_frame
	gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await frames(2)
	player = gym.player
	enemy = gym.get("_current_area").get_targets()[0]
	# Keep AI/stage activation on: disabling it deliberately removes solidity and
	# ordinary gravity. Minimal perception/zero movement is a private fixture.
	gym._config["enemy_ai"]["aggro_range"] = 1.0
	gym._config["enemy_ai"]["movement_speed"] = 0.0
	gym._config["enemy_ai"]["attack_range"] = 1.0
	check(bool(gym._apply_runtime_tuning()["ok"]), "stationary fixture tuning accepted")
	player.global_position.x = -240
	enemy.global_position.x = 240
	await frames(24)
	check(player.is_on_floor() and enemy.is_on_floor(), "actors settle on Gym floor")

func freeze_fixture() -> void:
	gym.get_node("ContactEvaluation").set_physics_process(false)
	player.movement.set_physics_process(false)
	player.set_process(false)
	enemy.set_physics_process(false)
	enemy.set_process(false)

func start_player(move: String, facing: int) -> void:
	player.reset_for_stage()
	player.might.try_select_school(&"fire")
	player.input_combo._clear()
	for i in range(int(move.right(1))):
		player.input_combo.accept_light(&"fire")
	player.might._state = 1
	var action: Dictionary = player.might._make_light_action(Vector2(facing, 0), &"fire")
	player.might._start_action(action)
	player.sync_combat_body_profile()
	player.might._frame_action_id = action.source_action_id

func seek_player(time: float) -> void:
	# Restart before a fixture seek: Godot's discrete track cache retains a later
	# sprite value when a playing clip is scrubbed backward without a restart.
	var clip: StringName = player.animation_player.assigned_animation
	player.animation_player.stop()
	player.animation_player.play(clip)
	player.animation_player.seek(time, true)
	player.might._sample_time = time
	player.might._sample_action_id = player.might._current_action.source_action_id
	player.sync_combat_body_profile()
	player._update_attack_visual()

func start_enemy(facing: int) -> void:
	player.global_position.x = enemy.global_position.x + facing * 400
	enemy.ai_begin_windup(player)
	enemy._frame_action_id = enemy._attack_id

func seek_enemy(time: float) -> void:
	enemy.attack_animation.stop()
	enemy.attack_animation.play(&"melee_swing")
	enemy.attack_animation.seek(time, true)
	enemy._sample_time = time
	enemy._sample_action_id = enemy._attack_id

func weapon_probe(actor, pose: Dictionary, point: Vector2) -> bool:
	fixture.global_position = point
	await frames(1)
	var cast: ShapeCast2D = actor.attack_cast
	var old_mask := cast.collision_mask
	cast.collision_mask = 32
	cast.position = pose.position
	cast.target_position = pose.target
	(cast.shape as CircleShape2D).radius = pose.radius
	cast.force_shapecast_update()
	var found := false
	for i in range(cast.get_collision_count()):
		found = found or cast.get_collider(i) == fixture
	cast.collision_mask = old_mask
	return found

func shot(label: String) -> void:
	if not capture:
		return
	# Native ShapeCast debug shows its restored authoring pose; the actor's yellow
	# overlay shows the committed query. Hide the former to avoid two envelopes.
	player.attack_cast.hide()
	enemy.attack_cast.hide()
	# Flush queued visual changes and the renderer before reading the viewport.
	for i in range(3):
		player.queue_redraw()
		enemy.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
	var path := output.path_join(label + ".png")
	samples.append({"capture": label, "player_region": str(player.sprite.region_rect), "player_texture": player.sprite.texture.resource_path, "player_clock": player.animation_player.current_animation_position if player.animation_player.current_animation != &"" else -1.0, "player_sample": player.might._sample_time, "player_geometry": str(player.might.get_attack_geometry()), "enemy_region": str(enemy.body_visual.region_rect), "enemy_sample": enemy._sample_time, "enemy_geometry": str(enemy.get_attack_geometry()) if enemy._attack_id != 0 else "inactive"})
	check(root.get_texture().get_image().save_png(path) == OK, label + " rendered capture saved")
	captures.append(path)

func check_body(actor, expected_size: Vector2, bottom: float) -> void:
	var collision: CollisionShape2D = actor.get_node("CollisionShape2D")
	var bounds := collision.shape.get_rect()
	check((bounds.size * actor.global_scale).is_equal_approx(expected_size), actor.name + " body dimensions")
	check(is_equal_approx(collision.position.y + bounds.end.y, bottom), actor.name + " floor anchor unchanged")
	var center := collision.global_position
	for offset in [-expected_size.y * 0.5 + 12.0, 0.0, expected_size.y * 0.5 - 12.0]:
		var query := PhysicsPointQueryParameters2D.new()
		query.position = center + Vector2(0, offset)
		query.collision_mask = actor.collision_layer
		var hits: Array = actor.get_world_2d().direct_space_state.intersect_point(query)
		check(hits.any(func(hit): return hit.collider == actor), actor.name + " receives head/torso/leg contact %.1f" % offset)
	for offset in [Vector2(0, -expected_size.y * 0.5 - 12), Vector2(expected_size.x * 0.5 + 12, 0)]:
		var query := PhysicsPointQueryParameters2D.new()
		query.position = center + offset
		query.collision_mask = actor.collision_layer
		check(not actor.get_world_2d().direct_space_state.intersect_point(query).any(func(hit): return hit.collider == actor), actor.name + " excludes space outside body")

func geometry_cases() -> void:
	await fresh()
	freeze_fixture()
	fixture = StaticBody2D.new()
	fixture.collision_layer = 32
	fixture.collision_mask = 0
	var fixture_collision := CollisionShape2D.new()
	var point_shape := CircleShape2D.new()
	point_shape.radius = 1.0
	fixture_collision.shape = point_shape
	fixture.add_child(fixture_collision)
	gym.add_child(fixture)
	gym._config.ui.attack_hitbox_visible = true
	player.set_attack_hitbox_debug_enabled(true)
	check_body(player, Vector2(60, 180), 26.0)
	check_body(enemy, Vector2(60, 180), 31.0)
	for facing in [1, -1]:
		for move in FIRE_POINTS:
			player.global_position.x = -140 if facing == 1 else 140
			enemy.global_position.x = 240 if facing == 1 else -240
			start_player(move, facing)
			var clock: Animation = player.animation_player.get_animation(move)
			var track := clock.find_track(NodePath("Sprite:region_rect"), Animation.TYPE_VALUE)
			var tested_contact := false
			for i in range(clock.track_get_key_count(track)):
				var time := clock.track_get_key_time(track, i)
				if time < clock.get_marker_time(&"active_start"):
					time = clock.get_marker_time(&"active_start")
				if time > clock.get_marker_time(&"active_end") or (i + 1 < clock.track_get_key_count(track) and clock.track_get_key_time(track, i + 1) <= time):
					continue
				seek_player(time)
				check(int(player.sprite.region_rect.position.x / 448) == i, "%s frame%d artwork and query share the sampled time" % [move, i])
				var pose: Dictionary = player.might.get_attack_geometry()
				var tip: Vector2 = FIRE_POINTS[move][i][1] - Vector2(224, 348)
				var hand: Vector2 = FIRE_POINTS[move][i][0] - Vector2(224, 348)
				tip.x *= facing
				hand.x *= facing
				# These world points come from measured atlas pixels, independently of query geometry.
				var origin: Vector2 = player.global_position
				check(await weapon_probe(player, pose, origin + tip), "%s facing%d frame%d blade-tip contact" % [move, facing, i])
				check(await weapon_probe(player, pose, origin + hand.lerp(tip, 0.15)), "%s facing%d frame%d guard-side contact" % [move, facing, i])
				check(not await weapon_probe(player, pose, origin + tip + (tip - hand).normalized() * 14), "%s facing%d frame%d misses beyond tip" % [move, facing, i])
				if move == "fire_x2":
					check(tip.x * facing < 0 and Vector2(pose.position).x * facing < 0, "X2 follows backward blade")
				if i + 1 < clock.track_get_key_count(track):
					var next_time := clock.track_get_key_time(track, i + 1)
					var held: Dictionary = Geometry.sample(clock, (time + next_time) * 0.5)
					check(Vector2(held.position).is_equal_approx(Vector2(Geometry.sample(clock, time).position)), move + " holds geometry with sprite pose")
				if not tested_contact:
					# Exercise the actual Entity-detecting collector, including its per-action hit record.
					enemy.global_position = origin + hand.lerp(tip, 0.5) - Vector2(-11, -59)
					await frames(1)
					check(player.might.collect_melee_contacts().size() == 1, move + " actor collector contacts body")
					check(player.might.collect_melee_contacts().is_empty(), move + " same target cannot contact twice")
					enemy.global_position = Vector2(240 if facing == 1 else -240, 21)
					tested_contact = true
				samples.append({"move": move, "facing": facing, "frame": i, "time": time, "position": str(pose.position), "target": str(pose.target), "radius": pose.radius})
			seek_player({"fire_x1": 0.7, "fire_x2": 0.6, "fire_x3": 0.65, "fire_x4": 0.75, "fire_x5": 0.7}[move])
			await shot("%s_%s" % [move, "right" if facing == 1 else "left"])
		# Query before the active marker remains empty.
		seek_player(0.0)
		check(player.might.collect_melee_contacts().is_empty(), "player cannot hit before active window")
		player.reset_for_stage()
		player.sync_combat_body_profile()
		enemy.global_position = Vector2(-120 if facing == 1 else 120, 21)
		start_enemy(facing)
		for i in range(5, 11):
			var time := float(i) * 0.1
			seek_enemy(time)
			check(int(enemy.body_visual.region_rect.position.x / 768) + int(enemy.body_visual.region_rect.position.y / 512) * 4 == i % 10, "pikeman frame%d artwork and query share the sampled time" % i)
			var pose: Dictionary = enemy.get_attack_geometry()
			var tip: Vector2 = PIKE_POINTS[i][1] - Vector2(384, 448)
			var hand: Vector2 = PIKE_POINTS[i][0] - Vector2(384, 448)
			tip.x *= facing
			hand.x *= facing
			var anchor: Vector2 = enemy.global_position + Vector2(-11, 31)
			check(await weapon_probe(enemy, pose, anchor + tip), "pikeman facing%d frame%d tip contact" % [facing, i])
			check(await weapon_probe(enemy, pose, anchor + hand.lerp(tip, 0.15)), "pikeman facing%d frame%d close contact" % [facing, i])
			check(not await weapon_probe(enemy, pose, anchor + tip + (tip - hand).normalized() * 14), "pikeman facing%d frame%d misses beyond tip" % [facing, i])
			if i == 5:
				player.global_position = anchor + hand.lerp(tip, 0.3) - Vector2(0, -38)
				await frames(1)
				check(enemy.collect_melee_contacts().size() == 1, "pikeman actor collector contacts player")
				check(enemy.collect_melee_contacts().is_empty(), "pikeman same target cannot contact twice")
				player.global_position = Vector2(180 if facing == 1 else -180, 0)
		seek_enemy(0.5)
		await shot("pikeman_%s" % ("right" if facing == 1 else "left"))
		enemy.cancel_combat_attack()
		check(enemy.collect_melee_contacts().is_empty(), "cancelled pikeman has no contact")
	fixture.queue_free()

func profile_cases() -> void:
	await fresh()
	freeze_fixture()
	for school in [&"water", &"air", &"earth", &"fire"]:
		player.might.try_select_school(school)
		player.sync_combat_body_profile()
		await frames(1)
		check_body(player, Vector2(60, 180) if school == &"fire" else Vector2(52, 60), 26.0)
	start_player("fire_x1", 1)
	seek_player(0.61)
	player.might.try_select_school(&"water")
	check(player.body_collision.shape.size == Vector2(30, 90), "committed Fire action retains Fire body after selected-school switch")
	player.might.cancel_for_player_hit()
	player.sync_combat_body_profile()
	check(player.body_collision.shape.size == Vector2(26, 30), "interruption restores selected legacy body")
	# Reverse direction: selecting Fire cannot enlarge a committed legacy clip.
	player.reset_for_stage()
	player.might.try_select_school(&"water")
	player.might.try_light_attack(Vector2.RIGHT)
	player.might.try_select_school(&"fire")
	player.sync_combat_body_profile()
	check(player.body_collision.shape.size == Vector2(26, 30), "committed legacy action retains legacy body after selecting Fire")
	player.might.cancel_for_player_hit()
	player.sync_combat_body_profile()
	check(player.body_collision.shape.size == Vector2(30, 90), "cancelled legacy action returns to selected Fire body")
	player.hit_reaction.execute_combat(20, Vector2.LEFT)
	player.sync_combat_body_profile()
	check(player._uses_fire_art() and player.body_collision.shape.size == Vector2(30, 90), "Fire Hurt uses Fire body")
	player.reset_for_stage()
	player.sync_combat_body_profile()
	check(not player.hit_reaction.is_active() and not player._hit_visual_active and player.body_collision.shape.size == Vector2(30, 90), "stage reset clears reaction and retains correct body")
	player.might.try_cast_trigger()
	player.sync_combat_body_profile()
	check(player._hit_visual_active and player.body_collision.shape.size == Vector2(30, 90), "failed Cast Hurt uses Fire body")
	player.reset_for_stage()
	await frames(2)
	check(not player._hit_visual_active and player.sprite.position == player._sprite_rest_position and player._hit_reaction_tween == null, "reset cancels failed-Cast visual tween and preserves registration")
	for school in [&"water", &"fire"]:
		player.reset_for_stage()
		player.might.try_select_school(school)
		player.magic.add_orb(school)
		player.magic._marked_capacity = 1
		player.might.try_cast_trigger()
		player.sync_combat_body_profile()
		check(str(player.animation_player.assigned_animation) == "cast_" + str(school), "normal Cast starts school clip")
		player.might.try_select_school(&"fire" if school == &"water" else &"water")
		player.sync_combat_body_profile()
		check(player.body_collision.shape.size == (Vector2(30, 90) if school == &"fire" else Vector2(26, 30)), "committed Cast retains matching body")
	player.reset_for_stage()
	player.might.try_select_school(&"fire")
	player.sync_combat_body_profile()
	player.health.apply_damage(1000)
	check(player.health.is_zero() and player.body_collision.shape.size == Vector2(30, 90), "death preserves grounded Fire body")
	var arena = load("res://scenes/stages/final_arena.tscn").instantiate()
	var found := false
	for actor in arena.find_children("*", "CharacterBody2D", true, false):
		if actor.get_script() == enemy.get_script():
			var shape: CapsuleShape2D = actor.get_node("CollisionShape2D").shape
			found = shape.radius == 30.0 and shape.height == 180.0
	check(found, "Final Arena instances reuse corrected pikeman capsule")
	arena.free()

func ordinary_physics_cases() -> void:
	await fresh()
	# Normal movement and collision callbacks remain live for this scenario.
	Input.action_press(&"move_right")
	await frames(110)
	Input.action_release(&"move_right")
	check(player.global_position.x < enemy.global_position.x, "solid fighters do not pass through one another")
	check(player.is_on_floor() and enemy.is_on_floor(), "movement keeps both feet grounded")
	var floor_y: float = gym._current_area.get_node("Floor/CollisionShape2D").global_position.y - 16
	check(absf(player.body_collision.global_position.y + 90 - floor_y) < 0.25, "Fire floor anchor survives ordinary movement")
	check(absf(enemy.get_node("CollisionShape2D").global_position.y + 90 - floor_y) < 0.25, "pikeman floor anchor survives ordinary movement")
	await shot("ordinary_body_contact")
	# Observe actual input-driven Fire X1 contact through the shared sample barrier.
	player.might.try_select_school(&"fire")
	var hp_before: float = enemy.health.get_current()
	var event := InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_X
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventJoypadButton.new()
	event.button_index = JOY_BUTTON_X
	event.pressed = false
	Input.parse_input_event(event)
	for i in range(100):
		await frames(1)
		if player.combat.is_attack_playing() and i % 4 == 0:
			samples.append({"ordinary": true, "frame": i, "time": player.animation_player.current_animation_position, "pose": str(player.might.get_attack_geometry()), "player": str(player.global_position), "enemy": str(enemy.global_position), "enemy_layer": enemy.collision_layer, "cast_mask": player.attack_cast.collision_mask})
	check(enemy.health.get_current() < hp_before, "real input-driven X1 damages adjacent pikeman")
	check(player.magic.get_snapshot().size() == 1, "one ordinary melee contact generates one orb")
	# Actual scene reload exercises Retry lifecycle and fresh profile initialization.
	var old_player: int = player.get_instance_id()
	gym._restart_current_encounter()
	await frames(8)
	gym = current_scene
	player = gym.player
	enemy = gym._current_area.get_targets()[0]
	check(player.get_instance_id() != old_player and player.health.get_current() == 100, "Retry replaces defeated/used actor state")
	check(player.body_collision.shape.size == Vector2(30, 90) and enemy.get_node("CollisionShape2D").shape.height == 180, "Retry restores both corrected bodies")

func run() -> void:
	root.size = Vector2i(1280, 720)
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture":
			capture = true
		elif arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
	if output.is_empty():
		output = ProjectSettings.globalize_path("user://art-hitbox-evidence")
	DirAccess.make_dir_recursive_absolute(output)
	if capture and DisplayServer.get_name() == "headless":
		printerr("Capture requires a renderer")
		quit(1)
		return
	debug_collisions_hint = capture
	await geometry_cases()
	await profile_cases()
	await ordinary_physics_cases()
	var report := {"engine": Engine.get_version_info(), "renderer": DisplayServer.get_name(), "checks": checks, "failures": failures, "captures": captures, "geometry_fixture_samples": samples, "limits": "Geometry/collector fixtures and ordinary input/physics checks are distinct. Captures require visual inspection. No human feel or balance acceptance."}
	var file := FileAccess.open(output.path_join("report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	if failures.is_empty():
		print("PASSED: %d art alignment checks" % checks)
	else:
		printerr("FAILED: %d/%d art alignment checks" % [failures.size(), checks])
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	current_scene = null
	gym.free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
