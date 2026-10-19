extends SceneTree

const Geometry = preload("res://scripts/combat/attack_geometry.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")

var checks := 0
var failures: Array[String] = []


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: " + description)


func _initialize() -> void:
	call_deferred("_run")


func check_enemy_rest_pose(config: Dictionary) -> void:
	var packed := load("res://scenes/enemy/combat_enemy.tscn") as PackedScene
	var authored = packed.instantiate()
	var sprite := authored.get_node("BodyVisual") as Sprite2D
	check(sprite.texture.resource_path.ends_with("Idle.png"), "Enemy scene previews the same standing idle artwork as gameplay")
	var frame := sprite.texture.get_image().get_region(Rect2i(0, 0, 128, 128))
	var feet_y := float(frame.get_used_rect().end.y) - 64.0
	var collision := authored.get_node("CollisionShape2D") as CollisionShape2D
	var capsule := collision.shape as CapsuleShape2D
	check(capsule != null and is_equal_approx(capsule.height, 68.7) and is_equal_approx(capsule.radius, 12.4) and is_equal_approx(collision.position.x, -11.0), "Enemy keeps the user's capsule dimensions and horizontal offset")
	var capsule_bottom := collision.position.y + capsule.height * 0.5
	var feet := sprite.transform * Vector2(0, feet_y)
	check(is_equal_approx(capsule_bottom, feet.y), "Authored capsule bottom aligns with the opaque standing feet")
	# Non-default position, scale and rotation expose configure-time overrides.
	sprite.position = Vector2(7, -33)
	sprite.scale = Vector2(0.8, 1.15)
	sprite.rotation = 0.12
	var rest_transform := sprite.transform
	root.add_child(authored)
	authored.configure(config)
	authored.set_process(false)
	authored.set_physics_process(false)
	check(sprite.transform.is_equal_approx(rest_transform), "Enemy configuration preserves the scene-authored sprite transform")
	authored._process(0.0)
	check(sprite.transform.is_equal_approx(rest_transform), "Idle playback preserves the scene-authored sprite transform")
	authored.hit_reaction.execute(1, Vector2.RIGHT)
	authored.hit_reaction._process(10.0)
	check(sprite.transform.is_equal_approx(rest_transform), "Legacy reaction recovery returns to the authored rest transform")
	authored.hit_reaction.execute_combat(1, Vector2.LEFT)
	authored.hit_reaction.consume_body_motion(10.0)
	authored.hit_reaction.finish_body_motion()
	check(sprite.transform.is_equal_approx(rest_transform), "Combat hurt recovery preserves the authored rest transform")
	authored.set_stage_active(false)
	check(sprite.transform.is_equal_approx(rest_transform), "Stage reset preserves the authored rest transform")
	for audio in authored.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	authored.free()
	# Settle the saved scene against an actual floor through the existing mover.
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 4
	floor_body.collision_mask = 0
	var floor_collision := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(400, 32)
	floor_collision.shape = floor_shape
	floor_body.position = Vector2(0, 16)
	floor_body.add_child(floor_collision)
	root.add_child(floor_body)
	var grounded = packed.instantiate()
	grounded.position = Vector2(0, -100)
	root.add_child(grounded)
	grounded.configure(config)
	grounded.set_process(false)
	grounded.set_physics_process(false)
	for step in range(180):
		await physics_frame
		grounded._apply_gravity_and_move(1.0 / 60.0)
		if grounded.is_on_floor():
			break
	check(grounded.is_on_floor(), "Enemy's authored capsule settles onto the physics floor")
	var world_feet: Vector2 = grounded.body_visual.to_global(Vector2(0, feet_y))
	check(absf(world_feet.y) < 0.2, "Visible idle feet meet the floor within the body's collision margin")
	grounded.free()
	floor_body.free()


func _run() -> void:
	var base: Dictionary = Store.load_config()["data"]
	var before_hash := Store.source_hash()
	var invalid := base.duplicate(true)
	invalid["moves"]["fire_x1"]["shape_radius"] = 0.0
	check(not Store.save_changes(base, invalid)["ok"] and Store.source_hash() == before_hash, "Zero radius is rejected before any saved file changes")
	var clock := Geometry.load_clock("fire_x1")
	var time := clock.get_marker_time(&"contact")
	var target_track := clock.find_track(Geometry.TARGET, Animation.TYPE_VALUE)
	var radius_track := clock.find_track(Geometry.RADIUS, Animation.TYPE_VALUE)
	var position_track := clock.find_track(Geometry.POSITION, Animation.TYPE_VALUE)
	clock.track_insert_key(target_track, time, Vector2(30, -40))
	clock.track_insert_key(radius_track, time, 7.0)
	clock.track_insert_key(position_track, time, Vector2(12, -8))
	clock.track_insert_key(target_track, 0.9, Vector2(12, -16))
	clock.track_insert_key(radius_track, 0.9, 4.0)
	check(ResourceSaver.save(clock, Geometry.DIRECTORY + "fire_x1.tres") == OK, "Native animation edit saves")
	check(Store.source_hash() != before_hash, "Native saves invalidate Portal and Inspector source watchers")
	var loaded: Dictionary = Store.load_config()["data"]
	check(is_equal_approx(float(loaded["moves"]["fire_x1"]["shape_reach"]), 50.0) and is_equal_approx(float(loaded["moves"]["fire_x1"]["shape_radius"]), 7.0), "Startup and Portal read native geometry over stale JSON")
	var stale := base.duplicate(true)
	stale["moves"]["fire_x1"]["shape_radius"] = 9.0
	var json_hash := FileAccess.get_sha256(Store.CONFIG_PATH)
	check(not Store.save_changes(base, stale)["ok"] and FileAccess.get_sha256(Store.CONFIG_PATH) == json_hash, "Stale Portal geometry conflicts before JSON is written")
	var draft := loaded.duplicate(true)
	draft["moves"]["fire_x1"]["shape_reach"] = 75.0
	draft["moves"]["fire_x1"]["shape_radius"] = 9.0
	check(Store.save_changes(loaded, draft)["ok"], "Portal saves contact-size edits to the shared animation")
	var saved := Geometry.load_clock("fire_x1")
	var contact := Geometry.contact(saved)
	check(Vector2(contact["target"]).is_equal_approx(Vector2(45, -60)) and Vector2(contact["position"]).is_equal_approx(Vector2(12, -8)) and is_equal_approx(float(contact["radius"]), 9.0), "Portal resizing preserves authored angle and offset")
	var recovery := Geometry.sample(saved, 0.9)
	check(recovery["target"] == Vector2(12, -16) and recovery["radius"] == 4.0, "Portal contact edits preserve other animation keys")
	# Startup must read saved geometry even when an old animation is cached by
	# the move-resource Inspector, and zero reach must remain a point query.
	loaded = Store.load_config()["data"]
	draft = loaded.duplicate(true)
	draft["moves"]["fire_x1"]["shape_reach"] = 0.0
	check(Store.save_changes(loaded, draft)["ok"], "Point-query geometry saves")
	var actor = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(actor)
	actor.configure(Store.load_config()["data"])
	actor.might.set_physics_process(false)
	actor.movement.set_physics_process(false)
	actor.might.try_light_attack(Vector2.LEFT)
	var runtime_pose: Dictionary = actor.might.get_attack_geometry()
	check(Vector2(runtime_pose["target"]).is_zero_approx() and Vector2(runtime_pose["position"]).is_equal_approx(Vector2(-12, -8)), "Runtime reloads saved native offsets and preserves zero reach")
	for audio in actor.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	actor.free()
	var untouched_hash := FileAccess.get_sha256(Geometry.DIRECTORY + "fire_x1.tres")
	loaded = Store.load_config()["data"]
	draft = loaded.duplicate(true)
	draft["player"]["poise"] += 1
	check(Store.save_changes(loaded, draft)["ok"] and FileAccess.get_sha256(Geometry.DIRECTORY + "fire_x1.tres") == untouched_hash, "Unrelated tuning saves leave native animation bytes unchanged")
	loaded = Store.load_config()["data"]
	draft = loaded.duplicate(true)
	draft["enemy_ai"]["hitbox_reach"] = 51.0
	draft["enemy_ai"]["hitbox_radius"] = 8.0
	check(Store.save_changes(loaded, draft)["ok"], "Enemy Portal geometry saves through the same animation path")
	loaded = Store.load_config()["data"]
	check(loaded["enemy_ai"]["hitbox_reach"] == 51.0 and loaded["enemy_ai"]["hitbox_radius"] == 8.0 and loaded["enemy_ai"]["attack_range"] == base["enemy_ai"]["attack_range"], "Enemy hitbox editing leaves AI approach distance unchanged")
	# Native seeking and independent instances must not write animation assets.
	var hashes: Dictionary = {}
	for id in Geometry.move_ids():
		hashes[id] = FileAccess.get_sha256(Geometry.DIRECTORY + id + ".tres")
	var enemy = load("res://scenes/enemy/combat_enemy.tscn").instantiate()
	root.add_child(enemy)
	enemy.attack_animation.play(&"melee_swing")
	enemy.attack_animation.seek(0.8, true)
	check(enemy.body_visual.texture.resource_path.ends_with("Attack_1.png") and enemy.body_visual.region_rect.position.x == 384.0, "Enemy native scrubbing previews the attack frame without gameplay setup")
	check(enemy.attack_cast.target_position.length() == 51.0 and (enemy.attack_cast.shape as CircleShape2D).radius == 8.0, "Enemy scrubbed hitbox matches saved native geometry")
	enemy.attack_animation.stop()
	enemy.configure(loaded)
	var target = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(target)
	target.position = Vector2(-100, 0)
	enemy.ai_begin_windup(target, 999.0, 0.6)
	check(enemy.get("_committed_attack_target_position") == Vector2(-51, 0) and enemy.get("_committed_attack_radius") == 8.0, "Enemy mirrors authored reach, independently of AI approach range")
	loaded["enemy_ai"]["hitbox_reach"] = 120.0
	loaded["enemy_ai"]["hitbox_radius"] = 12.0
	enemy.apply_runtime_tuning()
	check(enemy.get("_committed_attack_target_position") == Vector2(-51, 0) and enemy.get("_committed_attack_radius") == 8.0, "Enemy committed geometry survives a later Portal edit")
	check(Vector2(Geometry.contact(enemy.attack_animation.get_animation(&"melee_swing"))["target"]).length() == 120.0, "Enemy preview updates its private animation for subsequent attacks")
	target.free()
	enemy.free()
	await check_enemy_rest_pose(base)
	for id in hashes:
		check(FileAccess.get_sha256(Geometry.DIRECTORY + id + ".tres") == hashes[id], "Seeking never saves an animation: " + id)
	clock = null
	saved = null
	await process_frame
	if failures.is_empty():
		print("PASSED: %d native attack-authoring checks" % checks)
	quit(0 if failures.is_empty() else 1)
