extends SceneTree
## Isolated real-Gym regression: no AI/tuning overrides or manual action clocks.

var gym
var enemy
var checks := 0
var failures: Array[String] = []
var evidence: Array[Dictionary] = []
var output := ""
var capture := false
var pressure_only := false
var single_only := false
var windup_only := false
var pressure_case := ""


func _initialize() -> void:
	call_deferred("run")


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("FAILED: ", label)


func frames(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame


func snapshot(label: String, tick: int) -> Dictionary:
	var animation: AnimationPlayer = enemy.attack_animation
	var player_action: Dictionary = gym.player.might.get("_current_action")
	var slides: Array[Dictionary] = []
	for index in range(enemy.get_slide_collision_count()):
		var contact: KinematicCollision2D = enemy.get_slide_collision(index)
		slides.append({"collider": str(contact.get_collider().get_path()), "normal": str(contact.get_normal())})
	return {"case": label, "tick": tick, "phase": str(enemy._state_name()),
		"enemy": str(enemy.global_position), "player": str(gym.player.global_position),
		"distance": absf(enemy.global_position.x - gym.player.global_position.x),
		"attack_range": enemy.bt_player.blackboard.get_var(&"attack_range"),
		"velocity": str(enemy.velocity), "slides": slides,
		"attack_id": enemy.get("_attack_id"), "frame_action_id": enemy.get("_frame_action_id"),
		"playing": animation.is_playing(), "clock": animation.current_animation_position if animation.current_animation != &"" else 0.0,
		"facing": str(enemy.get("_facing")), "texture": enemy.body_visual.texture.resource_path,
		"frame_rect": str(enemy.body_visual.region_rect),
		"player_action_id": player_action.get("source_action_id", 0), "player_move": str(player_action.get("move_id", &"")),
		"player_progress": gym.player.combat.get_normalized_attack_progress(), "chain_position": gym.player.combat.get_current_chain_position(),
		"player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current()}


func shot(label: String) -> void:
	if not capture:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := output.path_join(label + ".png")
	check(root.get_texture().get_image().save_png(path) == OK, "Capture saved: " + label)
	evidence.append(snapshot("capture_" + label, Engine.get_physics_frames()))


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
	await frames(8)
	enemy = gym.get("_current_area").get_targets()[0]
	check(not paused and enemy.is_physics_processing() and gym.player.movement.is_physics_processing(), "Ordinary actor physics remains live")


func observe(label: String, count: int = 600) -> Dictionary:
	var prior := ""
	var windups := 0
	var active := 0
	var recoveries := 0
	var waits := 0
	var completed_waits := 0
	var wait_started := -1
	var wait_durations: Array[float] = []
	var late_shot := false
	var hp_before: float = gym.player.health.get_current()
	for tick in range(count):
		await frames(1)
		var phase: String = str(enemy._state_name())
		if phase != prior:
			if prior == "IDLE" and wait_started >= 0:
				completed_waits += 1
				wait_durations.append(float(tick - wait_started) / 60.0)
				wait_started = -1
			var sample := snapshot(label, tick)
			evidence.append(sample)
			print("AI_EVIDENCE: ", JSON.stringify(sample))
			if phase == "WINDUP":
				windups += 1
			elif phase == "ACTIVE":
				# Do not count an attack already in flight when pressure stops.
				if windups > active:
					active += 1
			elif phase == "IDLE" and prior == "ACTIVE" and windups > recoveries:
				# Zero-tail recovery enters/exits in one BT update. Its event is
				# also retained by the existing COMBAT_ENEMY state trace.
				recoveries += 1
				waits += 1
				wait_started = tick
			if windups == 1 and phase in ["WINDUP", "ACTIVE"]:
				await shot(label + "_" + phase.to_lower())
			prior = phase
		elif tick % 120 == 0:
			evidence.append(snapshot(label, tick))
		if not late_shot and active == 1 and enemy.attack_animation.is_playing() and enemy.attack_animation.current_animation_position >= 0.8:
			late_shot = true
			await shot(label + "_return")
		if gym.player.health.is_zero():
			break
		if windups >= 3 and active >= 3 and recoveries >= 3 and completed_waits >= 3:
			break
	var hp_after: float = gym.player.health.get_current()
	var result := {"case": label, "windups": windups, "active": active, "recoveries": recoveries, "waits": waits, "completed_waits": completed_waits, "wait_durations": wait_durations, "hp_before": hp_before, "hp_after": hp_after}
	evidence.append(result)
	check(windups >= 3 and active >= 3 and recoveries >= 3 and completed_waits >= 3, label + ": three natural attack/recovery/wait cycles")
	check(hp_before - hp_after >= 30.0 and is_zero_approx(fmod(hp_before - hp_after, 10.0)), label + ": at least three natural contacts apply the saved 10 damage each")
	await shot(label + "_end")
	return result


func press_x() -> void:
	for pressed in [true, false]:
		var event := InputEventAction.new()
		event.action = &"light_attack"
		event.pressed = pressed
		Input.parse_input_event(event)


func reaction_seen(facts: Dictionary) -> void:
	var sample := snapshot(pressure_case, Engine.get_physics_frames())
	sample["reaction"] = facts.duplicate(true)
	evidence.append(sample)
	print("AI_PRESSURE_CONTACT: ", JSON.stringify(sample))


func pressure_case_run(label: String, spam: bool, player_right: bool, single: bool = false) -> void:
	await fresh()
	if player_right:
		gym.player.global_position.x = 80.0
		enemy.global_position.x = -80.0
		# Ordinary movement input establishes the opposite attack facing.
		Input.action_press(&"move_left")
		await frames(1)
		Input.action_release(&"move_left")
	pressure_case = label
	enemy.health_resolver.reaction_evaluated.connect(reaction_seen)
	gym.player.health_resolver.reaction_evaluated.connect(reaction_seen)
	var previous := ""
	var requested: Dictionary = {}
	var captured: Dictionary = {}
	var presses := 0
	for tick in range(480):
		var action: Dictionary = gym.player.might.get("_current_action")
		var action_id := int(action.get("source_action_id", 0))
		var ready: bool = int(gym.player.might.get("_state")) == MightComponent.State.READY
		var send: bool = tick % 12 == 0 if spam else (ready or (not single and action_id > 0 and not requested.has(action_id) and gym.player.combat.get_normalized_attack_progress() >= 0.35))
		if send:
			requested[action_id] = true
			presses += 1
			var attempt := snapshot(label + "_input", tick)
			evidence.append(attempt)
			print("AI_PRESSURE_INPUT: ", JSON.stringify(attempt))
			press_x()
		await frames(1)
		var state := str(enemy._state_name())
		var key := "%s/%s/%s/%s/%s" % [state, enemy.get("_attack_id"), gym.player.might.get("_current_action").get("source_action_id", 0), gym.player.health.get_current(), enemy.health.get_current()]
		if key != previous:
			var sample := snapshot(label, tick)
			evidence.append(sample)
			print("AI_PRESSURE_STATE: ", JSON.stringify(sample))
			previous = key
			if state in ["APPROACH", "WINDUP", "ACTIVE", "HIT_REACTING"] and not captured.has(state):
				captured[state] = true
				await shot(label + "_" + state.to_lower())
		if gym.attempt_result != &"":
			break
	evidence.append({"case": label + "_summary", "presses": presses, "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current()})
	check(presses >= 5 and enemy.health.get_current() < 200.0, label + ": ordinary X inputs make real contacts")
	check(gym.attempt_result == &"", label + ": encounter remains live for recovery check")
	await observe(label + "_pressure_stopped")
	enemy.health_resolver.reaction_evaluated.disconnect(reaction_seen)
	gym.player.health_resolver.reaction_evaluated.disconnect(reaction_seen)


func x1_windup_case(player_right: bool) -> void:
	await fresh()
	if player_right:
		gym.player.global_position.x = 80.0
		enemy.global_position.x = -80.0
		Input.action_press(&"move_left")
		await frames(1)
		Input.action_release(&"move_left")
	pressure_case = "x1_windup_" + ("right" if player_right else "left")
	enemy.health_resolver.reaction_evaluated.connect(reaction_seen)
	for tick in range(180):
		await frames(1)
		if str(enemy._state_name()) == "WINDUP":
			break
	var committed_id := int(enemy.get("_attack_id"))
	check(committed_id > 0 and str(enemy._state_name()) == "WINDUP", pressure_case + ": natural committed windup")
	evidence.append(snapshot(pressure_case + "_before_x", Engine.get_physics_frames()))
	press_x()
	var cancelled := false
	for tick in range(60):
		await frames(1)
		if enemy.health.get_current() < 200.0 and str(enemy._state_name()) == "HIT_REACTING":
			cancelled = int(enemy.get("_attack_id")) == 0
			await shot(pressure_case + "_interrupted")
			break
	check(cancelled and gym.player.health.get_current() == 100.0, pressure_case + ": ordinary Fire X1 interrupts before the thrust hits")
	evidence.append({"case": pressure_case + "_cancelled", "committed_enemy_id": committed_id, "cancelled": cancelled})
	await observe(pressure_case + "_recovery")
	enemy.health_resolver.reaction_evaluated.disconnect(reaction_seen)


func run() -> void:
	root.size = Vector2i(1280, 720)
	for arg in OS.get_cmdline_user_args():
		if arg == "--capture":
			capture = true
		elif arg == "--pressure-only":
			pressure_only = true
		elif arg == "--single-only":
			pressure_only = true
			single_only = true
		elif arg == "--windup-only":
			pressure_only = true
			windup_only = true
		elif arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
	if output.is_empty():
		output = ProjectSettings.globalize_path("user://pikeman-ai-evidence")
	DirAccess.make_dir_recursive_absolute(output)
	debug_collisions_hint = capture
	if pressure_only:
		for right in [false, true]:
			if windup_only:
				await x1_windup_case(right)
			elif single_only:
				await pressure_case_run("single_x_" + ("right" if right else "left"), false, right, true)
			else:
				await pressure_case_run("spam_x_" + ("right" if right else "left"), true, right)
				await pressure_case_run("five_x_" + ("right" if right else "left"), false, right)
		await finish()
		return
	await fresh()
	await observe("saved_gym_player_left")
	await fresh()
	# Reverse actor sides only. Keep saved tuning, live physics and passive Player.
	gym.player.global_position.x = 80.0
	enemy.global_position.x = -80.0
	await observe("player_right")
	var previous_id: int = gym.player.get_instance_id()
	gym._restart_current_encounter()
	await frames(12)
	gym = current_scene
	enemy = gym.get("_current_area").get_targets()[0]
	check(gym.player.get_instance_id() != previous_id and gym.player.health.get_current() == 100.0, "Real Retry replaces actors and restores health")
	# Exercise ordinary scene input while Enemy decisions and contact remain live.
	var move := InputEventAction.new()
	move.action = &"move_right"
	move.pressed = true
	Input.parse_input_event(move)
	await frames(18)
	move = InputEventAction.new()
	move.action = &"move_right"
	move.pressed = false
	Input.parse_input_event(move)
	await observe("retry_ordinary_player_approach")
	# A direct real HealthEvent is the bounded interruption fixture; no clock
	# advancement or AI-state override is used. Observe recovery autonomously.
	for tick in range(180):
		await frames(1)
		if str(enemy._state_name()) == "WINDUP":
			break
	check(str(enemy._state_name()) == "WINDUP", "Interruption begins during a natural windup")
	var interrupted_id: int = enemy.get("_attack_id")
	var result: HealthResult = enemy.receive_health_event(HealthEvent.damage(gym.player, enemy, 1.0, 20, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT))
	check(result.health_delta == -1.0 and int(enemy.get("_attack_id")) == 0, "Applied HealthEvent cancels the windup")
	evidence.append({"case": "interruption", "interrupted_attack_id": interrupted_id, "outcome": result.outcome})
	await frames(1)
	check(str(enemy._state_name()) == "HIT_REACTING", "Enemy enters its existing hit-reaction branch")
	await shot("interruption_hurt")
	await observe("after_interruption")
	await finish()


func finish() -> void:
	var report := {"engine": Engine.get_version_info(), "checks": checks, "failures": failures, "events": evidence,
		"mode": "repeated_fire_input" if pressure_only else "baseline",
		"limits": "Actual Gym physics and BT; no AI, collision, timing, damage or geometry overrides. Side reversal is fixture positioning only. Pressure uses ordinary rising-edge X input; baseline includes one labeled injected HealthEvent interruption."}
	var file := FileAccess.open(output.path_join("report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d Pikeman approach checks" % checks)
	else:
		printerr("FAILED: %d/%d Pikeman approach checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)
