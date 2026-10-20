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
	var player = load("res://scenes/player/player.tscn").instantiate()
	var player_sprite := player.get_node("Sprite") as Sprite2D
	player_sprite.texture = load("res://assets/prototype/player/animation/shared_idle.png")
	player_sprite.region_rect = Rect2(0, 0, 128, 128)
	var player_collision := player.get_node("CollisionShape2D") as CollisionShape2D
	var player_feet: Vector2 = player.transform * (player_sprite.transform * Vector2(0, 64))
	var player_bottom: Vector2 = player.transform * (player_collision.transform * Vector2(0, player_collision.shape.get_rect().end.y))
	var ground_art_offset := player_feet.y - player_bottom.y
	check(is_equal_approx(ground_art_offset, 12.0) and is_equal_approx(feet.y - capsule_bottom, ground_art_offset), "Enemy matches Player's existing world-space offset between the body bottom and idle feet")
	player.free()
	# Non-default position, scale and rotation expose configure-time overrides.
	sprite.position = Vector2(7, -33)
	sprite.scale = Vector2(0.8, 1.15)
	sprite.rotation = 0.12
	var rest_transform := sprite.transform
	root.add_child(authored)
	# StageArea._ready() prepares the Enemy before Arena calls configure().
	authored.set_stage_active(false)
	check(sprite.transform.is_equal_approx(rest_transform), "Stage preparation before configuration preserves the authored sprite transform")
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


func visible_feet_y(sprite: Sprite2D) -> float:
	var frame := sprite.texture.get_image().get_region(Rect2i(sprite.region_rect))
	var feet_y := sprite.get_rect().position.y + float(frame.get_used_rect().end.y)
	return sprite.to_global(Vector2(0, feet_y)).y


func check_gym_fighter(actor: CharacterBody2D, sprite: Sprite2D, room: StageArea, phase: String) -> void:
	var floor_collision := room.get_node("Floor/CollisionShape2D") as CollisionShape2D
	var floor_top := floor_collision.to_global(Vector2(0, floor_collision.shape.get_rect().position.y)).y
	var ground := room.get_node("GroundD") as Sprite2D
	var visible_top := ground.to_global(ground.get_rect().position).y
	var collision := actor.get_node("CollisionShape2D") as CollisionShape2D
	var body_bottom := collision.to_global(Vector2(0, collision.shape.get_rect().end.y)).y
	check(actor.is_on_floor() and absf(body_bottom - floor_top) < 0.2, phase + ": collision body remains on the actual Gym floor")
	check(absf(visible_feet_y(sprite) - visible_top) < 0.2, phase + ": visible feet meet the actual ground artwork")


func check_gym_grounding() -> void:
	var gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	for frame in range(5):
		await process_frame
	var room: StageArea = gym.get("_current_area")
	var enemy = room.get_node("FinalEnemy")
	# Exercise a real recovery phase authored after active_end in this private clip.
	var clock: Animation = enemy.attack_animation.get_animation(&"melee_swing")
	clock.length = clock.get_marker_time(&"active_end") + 0.3
	check(enemy.body_visual.position == Vector2(0, -21) and enemy.get("_body_rest_position") == Vector2(0, -21), "Real Gym preparation and configuration retain the saved Enemy rest position")
	for step in range(30):
		await physics_frame
	check(enemy.get("_state") == enemy.State.APPROACH, "Grounding check exercises real Enemy walking")
	check_gym_fighter(gym.player, gym.player.sprite, room, "Player idle")
	check_gym_fighter(enemy, enemy.body_visual, room, "Enemy walking")
	var saw_windup := false
	var saw_attack := false
	var saw_recovery := false
	for step in range(180):
		await physics_frame
		if not saw_windup and enemy.get("_state") == enemy.State.WINDUP:
			saw_windup = true
			check_gym_fighter(enemy, enemy.body_visual, room, "Enemy windup")
		if not saw_attack and enemy.get("_state") == enemy.State.ACTIVE:
			saw_attack = true
			check_gym_fighter(enemy, enemy.body_visual, room, "Enemy attack")
		if saw_attack and enemy.get("_state") == enemy.State.RECOVERY:
			saw_recovery = true
			check_gym_fighter(enemy, enemy.body_visual, room, "Enemy recovery")
			check_gym_fighter(gym.player, gym.player.sprite, room, "Player after Enemy strike")
			break
	check(saw_windup and saw_attack and saw_recovery, "Actual Gym completes walking, windup, attack and recovery")
	var result: HealthResult = enemy.receive_health_event(HealthEvent.damage(gym.player, enemy, 1.0, 11, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT))
	check(result.outcome == HealthResult.Outcome.APPLIED and enemy.hit_reaction.is_invincible(), "Actual Gym starts a qualifying Enemy hurt reaction")
	await physics_frame
	check_gym_fighter(enemy, enemy.body_visual, room, "Enemy hurt")
	for step in range(120):
		await physics_frame
		if not enemy.hit_reaction.is_active():
			break
	check(not enemy.hit_reaction.is_active() and enemy.body_visual.position == Vector2(0, -21), "Enemy hurt recovery restores the saved sprite position")
	check_gym_fighter(enemy, enemy.body_visual, room, "Enemy after hurt")
	gym._restart_current_encounter()
	for frame in range(5):
		await process_frame
	gym = current_scene
	room = gym.get("_current_area")
	enemy = room.get_node("FinalEnemy")
	for step in range(30):
		await physics_frame
	check(enemy.body_visual.position == Vector2(0, -21), "Retry repeats stage initialization without shifting Enemy artwork")
	check_gym_fighter(gym.player, gym.player.sprite, room, "Player after Retry")
	check_gym_fighter(enemy, enemy.body_visual, room, "Enemy after Retry")
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	current_scene = null
	gym.free()


func _run() -> void:
	Engine.max_fps = 60
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
	enemy.attack_animation.seek(enemy.attack_animation.get_animation(&"melee_swing").get_marker_time(&"contact"), true)
	check(enemy.body_visual.texture.resource_path.ends_with("Attack_1.png") and enemy.body_visual.region_rect.position.x == 384.0, "Enemy native scrubbing previews the attack frame without gameplay setup")
	check(enemy.attack_cast.target_position.length() == 51.0 and (enemy.attack_cast.shape as CircleShape2D).radius == 8.0, "Enemy scrubbed hitbox matches saved native geometry")
	enemy.attack_animation.stop()
	enemy.configure(loaded)
	var target = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(target)
	target.position = Vector2(-100, 0)
	enemy.ai_begin_windup(target)
	check(enemy.get("_committed_attack_target_position") == Vector2(-51, 0) and enemy.get("_committed_attack_radius") == 8.0, "Enemy mirrors authored reach, independently of AI approach range")
	loaded["enemy_ai"]["hitbox_reach"] = 120.0
	loaded["enemy_ai"]["hitbox_radius"] = 12.0
	enemy.apply_runtime_tuning()
	check(enemy.get("_committed_attack_target_position") == Vector2(-51, 0) and enemy.get("_committed_attack_radius") == 8.0, "Enemy committed geometry survives a later Portal edit")
	check(Vector2(Geometry.contact(enemy.attack_animation.get_animation(&"melee_swing"))["target"]).length() == 120.0, "Enemy preview updates its private animation for subsequent attacks")
	target.free()
	enemy.free()
	check_enemy_rest_pose(base)
	await check_gym_grounding()
	for id in hashes:
		check(FileAccess.get_sha256(Geometry.DIRECTORY + id + ".tres") == hashes[id], "Seeking never saves an animation: " + id)
	clock = null
	saved = null
	await process_frame
	if failures.is_empty():
		print("PASSED: %d native attack-authoring checks" % checks)
	quit(0 if failures.is_empty() else 1)
