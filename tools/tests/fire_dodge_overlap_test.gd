extends SceneTree
## Controlled real-physics fixtures, not rendered/controller or gameplay-feel proof.

const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const PLAYER_SCENE = preload("res://scenes/player/player.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy/combat_enemy.tscn")
const DODGE_PATH := "res://config/attack_animations/fire_dodge.tres"

class FrameObserver extends Node:
	var sample: Callable

	func _physics_process(_delta: float) -> void:
		sample.call()

var checks := 0
var failures: Array[String] = []
var config: Dictionary
var arena: Node2D
var player
var enemy
var samples: Array[Dictionary] = []
var starts: Array[int] = []
var endings: Array[Dictionary] = []
var observing := false
var probe_extension := false
var probed := false


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


func add_wall(position_value: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 4
	body.collision_mask = 0
	body.position = position_value
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	arena.add_child(body)


func dispose() -> void:
	observing = false
	Input.action_release(&"move_left")
	Input.action_release(&"move_right")
	if is_instance_valid(arena):
		player.set_stage_input_locked(true)
		for audio in arena.find_children("*", "AudioStreamPlayer", true, false):
			audio.stop()
		current_scene = null
		arena.queue_free()
		await process_frame
		await process_frame


func fresh(enemy_center: float, wall := false, wide := false) -> void:
	await dispose()
	arena = Node2D.new()
	arena.name = "DodgeFixture"
	root.add_child(arena)
	current_scene = arena
	add_wall(Vector2(0, 72), Vector2(4000, 40))
	if wall:
		add_wall(Vector2(140, -100), Vector2(40, 400))
	player = PLAYER_SCENE.instantiate()
	player.name = "Player"
	arena.add_child(player)
	var tuning := config.duplicate(true)
	tuning["movement"]["speed"] = 300.0
	player.configure(tuning)
	player.select_stage_school(&"fire")
	enemy = ENEMY_SCENE.instantiate()
	enemy.name = "Enemy"
	# The authored capsule center is root(-11,-59), with its feet at rootY31.
	enemy.position = Vector2(enemy_center + 11.0, 21.0)
	arena.add_child(enemy)
	enemy.configure(tuning.duplicate(true))
	enemy.set_physics_process(false)
	enemy.set_process(false)
	if wide:
		var collision: CollisionShape2D = enemy.get_node("CollisionShape2D")
		var shape := CapsuleShape2D.new()
		shape.radius = 120.0
		shape.height = 300.0
		collision.shape = shape
	var observer := FrameObserver.new()
	observer.process_physics_priority = 3 # After Movement and ContactEvaluation.
	observer.sample = sample_frame
	arena.add_child(observer)
	player.combat.dodge_started.connect(func(_direction): starts.append(Engine.get_physics_frames()))
	player.combat.dodge_finished.connect(func(): endings.append({
		"frame": Engine.get_physics_frames(), "position": player.global_position,
		"cooldown": player.might.get("_dodge_cooldown_remaining"),
	}))
	await frames(2)
	samples.clear()
	starts.clear()
	endings.clear()
	probed = false
	probe_extension = false


func sample_frame() -> void:
	if not observing:
		return
	# Exercise the real presentation selector at this physics boundary, without
	# depending on how many render/process frames the headless host schedules.
	player._process(0.0)
	var action: Dictionary = player.might.get("_current_action")
	var extended := bool(action.get("overlap_extended", false))
	samples.append({"frame": Engine.get_physics_frames(), "position": player.global_position,
		"dodging": player.might.is_dodging(), "extended": extended,
		"protected": player.is_combat_invincible(), "pose": player.sprite.region_rect,
		"mode": player.get("_last_visual_mode"), "facing_left": player.sprite.flip_h,
		"exceptions": player.get_collision_exceptions().has(enemy),
		"cooldown": player.might.get("_dodge_cooldown_remaining")})
	if extended and probe_extension and not probed:
		probed = true
		var health_before: float = player.health.get_current()
		var event := HealthEvent.damage(enemy, player, 10.0, 20,
			HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.LEFT)
		var result: HealthResult = player.receive_health_event(event)
		check(result.outcome == HealthResult.Outcome.INVINCIBLE and player.health.get_current() == health_before,
			"The extension retains actual resolver protection")
		for action_name in [&"light_attack", &"select_water", &"defend"]:
			var input := InputEventAction.new()
			input.action = action_name
			input.pressed = true
			player.combat.handle_input_event(input, Vector2.LEFT)
		player.combat.try_dodge(Vector2.LEFT, 300.0)
		check(player.might.is_dodging() and player.combat.get_active_school() == &"fire" and starts.size() == 1,
			"Extension ignores attack/school/defence/repeated dodge without restarting")


func start(direction: int) -> void:
	samples.clear()
	starts.clear()
	endings.clear()
	observing = true
	player.combat.try_dodge(Vector2(direction, 0), player.movement.get_normal_movement_speed())
	check(starts.size() == 1 and player.might.is_dodging(), "Available Fire dodge starts once")


func wait_for_end() -> void:
	for index in range(50):
		if not endings.is_empty():
			return
		await frames(1)
	check(false, "Dodge must end within the bounded fixture")


func check_completed(direction: int, extended: bool, expected_distance: float = -1.0) -> void:
	if starts.is_empty() or endings.is_empty():
		return
	var expected_ticks := roundi((0.5 if extended else 0.4) * float(Engine.physics_ticks_per_second))
	check(int(endings[0]["frame"]) - starts[0] == expected_ticks,
		"Actual completion is the bounded 0.4/0.5-second physics boundary")
	check(endings.size() == 1 and is_equal_approx(float(endings[0]["cooldown"]), 0.37),
		"One actual finish starts the unchanged full 0.37-second cooldown")
	if expected_distance >= 0.0:
		check(absf(Vector2(endings[0]["position"]).x - float(direction) * expected_distance) < 0.1,
			"Captured normal-speed motion matches the exact base/extended budget")
	var base_ticks := roundi(0.4 * float(Engine.physics_ticks_per_second))
	var final_pose: Rect2 = player.animation_player.get_animation(&"fire_dodge").track_get_key_value(2, 11)
	for sample in samples:
		var tick := int(sample["frame"]) - starts[0]
		if tick < expected_ticks:
			check(sample["dodging"] and sample["protected"] and sample["exceptions"],
				"Action/protection/owned exceptions remain coherent before actual finish")
		if tick >= base_ticks and tick <= expected_ticks:
			check(sample["pose"] == final_pose and sample["mode"] == &"attack",
				"Native endpoint hold tick%d/%d: pose=%s expected=%s mode=%s" % [tick, expected_ticks, sample["pose"], final_pose, sample["mode"]])
		if sample["dodging"]:
			check(bool(sample["facing_left"]) == (direction < 0), "Committed dodge facing stays locked")
	check(not player.get_collision_exceptions().has(enemy) and not enemy.get_collision_exceptions().has(player),
		"Completion restores the collision exceptions owned by this dodge")
	check(is_equal_approx(player.animation_player.get_animation(&"fire_dodge").length, 0.4),
		"The native dodge clip is never stretched")


func clear_case(direction: int, high_heat: bool) -> void:
	await fresh(500.0 * float(direction))
	if high_heat:
		player.heat.gain_from_commit(1000)
	start(direction)
	await wait_for_end()
	check_completed(direction, false, 120.0)
	check(not samples.any(func(sample): return sample["extended"]), "Clear rolls acquire no generic grace or travel")


func overlap_case(direction: int) -> void:
	await fresh(80.0 * float(direction))
	probe_extension = true
	start(direction)
	await wait_for_end()
	check_completed(direction, true, 150.0)
	check(probed, "Real end-overlap reached the protected input probe")
	var base_ticks := roundi(0.4 * float(Engine.physics_ticks_per_second))
	var boundary: Array = samples.filter(func(sample): return int(sample["frame"]) - starts[0] == base_ticks)
	check(boundary.size() == 1 and bool(boundary[0]["extended"]) and absf(Vector2(boundary[0]["position"]).x - float(direction) * 120.0) < 0.1,
		"Overlap is tested after all 120 units of the final base body step")
	check(not player.might.try_dodge(Vector2(direction, 0), 300.0), "Fresh dodge is rejected at cooldown start")
	await frames(21)
	check(not player.might.try_dodge(Vector2(direction, 0), 300.0), "Post-completion cooldown still rejects before 0.37s")
	await frames(3)
	check(player.might.try_dodge(Vector2(direction, 0), 300.0), "A fresh press works after the unchanged cooldown")
	player.set_stage_input_locked(true)


func wall_cases() -> void:
	await fresh(500.0, true)
	Input.action_press(&"move_right")
	start(1)
	await wait_for_end()
	check_completed(1, false)
	check(Vector2(endings[0]["position"]).x < 91.0, "Walls stop base travel without granting an extension")
	await frames(1)
	player._process(0.0)
	check(player.get("_last_visual_mode") == &"idle", "Held input at a wall does not create a false Walk handoff")
	Input.action_release(&"move_right")
	await fresh(150.0, true, true)
	start(1)
	await wait_for_end()
	check_completed(1, true)
	check(Vector2(endings[0]["position"]).x < 91.0, "Blocked extension consumes time instead of storing movement")
	var own_shape: CollisionShape2D = player.get_node("CollisionShape2D")
	var other_shape: CollisionShape2D = enemy.get_node("CollisionShape2D")
	check(own_shape.shape.collide(own_shape.global_transform, other_shape.shape, other_shape.global_transform),
		"Wide/wall fixture really remains overlapping at the bounded endpoint")
	check(not player.might.is_dodging() and not player.get_collision_exceptions().has(enemy),
		"Wide/wall overlap cannot repeat extension or leave indefinite pass-through")


func pause_and_reset_cases() -> void:
	await fresh(80.0)
	start(1)
	for index in range(35):
		if bool(player.might.get("_current_action").get("overlap_extended", false)):
			break
		await frames(1)
	check(player.might.is_dodging(), "Pause/reset fixture reaches the extension")
	var elapsed: float = player.might.get("_current_action")["motion_elapsed"]
	var position_before: Vector2 = player.global_position
	paused = true
	await create_timer(0.06, true, false, true).timeout
	check(player.global_position == position_before and is_equal_approx(float(player.might.get("_current_action")["motion_elapsed"]), elapsed),
		"Pause freezes the shared motion/lifetime budget")
	check(player.is_combat_invincible() and player.get_collision_exceptions().has(enemy), "Pause retains extension protection and owned exceptions")
	paused = false
	await frames(2)
	check(player.might.is_dodging() and player.global_position.x > position_before.x,
		"Unpausing resumes remaining protected motion, not a new roll")
	player.reset_for_stage()
	check(not player.might.is_dodging() and player.might.get("_current_action").is_empty() and is_zero_approx(float(player.might.get("_dodge_cooldown_remaining"))),
		"Reset clears the extended action and cooldown immediately")
	check(player.movement.get("_dodge_body_exceptions").is_empty() and player.get("_dodge_visual_handoff_frame") == -1,
		"Reset clears owned collision state and the completion-frame pose latch")
	check(player.might.try_dodge(Vector2.RIGHT, 300.0) and not bool(player.might.get("_current_action")["overlap_extended"]),
		"A subsequent action starts with a fresh one-shot allowance")
	player.set_stage_input_locked(true)
	check(not player.might.is_dodging() and player.movement.get("_dodge_body_exceptions").is_empty(),
		"Stage lock cancels immediately without waiting for grace")
	await fresh(500.0)
	player.add_collision_exception_with(enemy)
	enemy.add_collision_exception_with(player)
	start(1)
	await wait_for_end()
	check(player.get_collision_exceptions().has(enemy) and enemy.get_collision_exceptions().has(player),
		"Existing pre-roll exceptions are not removed by completion")
	player.remove_collision_exception_with(enemy)
	enemy.remove_collision_exception_with(player)


func run() -> void:
	var loaded := Loader.load_and_validate("res://config/prototype_combat.json")
	check(bool(loaded["ok"]), "Shared character/style configuration validates")
	if not loaded["ok"]:
		printerr(loaded["error"])
		quit(1)
		return
	config = loaded["data"]
	var native_hash := FileAccess.get_sha256(DODGE_PATH)
	check(Catalog.fields(config, "attack_styles").size() == 161, "Existing style catalog includes exactly the approved X5 control")
	for direction in [1, -1]:
		await clear_case(direction, false)
		await clear_case(direction, true)
		await overlap_case(direction)
	await wall_cases()
	await pause_and_reset_cases()
	await dispose()
	check(FileAccess.get_sha256(DODGE_PATH) == native_hash, "The focused fixture changes no native animation resource")
	if failures.is_empty():
		print("PASSED: %d Fire dodge overlap/lifetime/pose checks" % checks)
	else:
		printerr("FAILED: %d/%d Fire dodge overlap checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)
