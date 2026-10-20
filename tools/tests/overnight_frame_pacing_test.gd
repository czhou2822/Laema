extends SceneTree
## R15 validation only. Never uses the inherited physics+process frames helper.
## Inputs are bound hardware events, held >=2 process callbacks. Physics remains60.
class Observer extends Node:
	signal sampled
	var processes := 0
	var physics := 0
	var process_time := 0.0
	var physics_time := 0.0
	var process_deltas: Array = []
	var physics_deltas: Array = []
	var steps_per_process: Array = []
	var previous_physics := 0
	func _process(delta: float) -> void:
		processes += 1
		process_time += delta
		process_deltas.append(delta)
		steps_per_process.append(physics - previous_physics)
		previous_physics = physics
		sampled.emit()
	func _physics_process(delta: float) -> void:
		physics += 1
		physics_time += delta
		physics_deltas.append(delta)

var observer: Observer
var gym
var enemy
var checks := 0
var failures: Array = []
var events: Array = []
var cases: Array = []
var buttons: Dictionary = {}
var label := ""
var rate := 60
var output := ""
var capture := false
var captures: Array = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures.append(label + ": " + message)
		printerr("FAILED: ", label, ": ", message)

func stamp() -> Dictionary:
	return {"process_frame": Engine.get_process_frames(), "physics_frame": Engine.get_physics_frames(), "observed_processes": observer.processes, "observed_physics": observer.physics, "process_seconds": observer.process_time, "physics_seconds": observer.physics_time, "wall_usec": Time.get_ticks_usec()}

func step(count := 1) -> void:
	for i in range(count):
		await observer.sampled

func seconds(duration: float) -> void:
	var until := observer.process_time + duration
	while observer.process_time < until:
		await step()

func input(action: String, pressed: bool) -> void:
	if buttons.get(action, false) == pressed:
		return
	buttons[action] = pressed
	var event: InputEvent
	if action == "casting":
		var axis := InputEventJoypadMotion.new()
		axis.axis = JOY_AXIS_TRIGGER_LEFT
		axis.axis_value = 1.0 if pressed else 0.0
		event = axis
	elif action == "light_attack":
		var button := InputEventJoypadButton.new()
		button.button_index = JOY_BUTTON_X
		button.pressed = pressed
		event = button
	else:
		var key := InputEventKey.new()
		key.keycode = {"left": KEY_A, "right": KEY_D, "pause": KEY_ESCAPE, "down": KEY_DOWN, "accept": KEY_ENTER}[action]
		key.physical_keycode = key.keycode
		key.pressed = pressed
		event = key
	var entry := stamp()
	entry.merge({"kind": "fixture_input", "action": action, "pressed": pressed})
	events.append(entry)
	Input.parse_input_event(event)

func tap(action: String) -> void:
	input(action, true)
	await step(2)
	input(action, false)
	await step(2)

func release_all() -> void:
	for action in buttons.keys():
		input(action, false)

func on_outcome(outcome) -> void:
	var data: Dictionary = outcome.snapshot()
	data.merge(stamp())
	events.append(data)

func on_reaction(snapshot: Dictionary) -> void:
	var data := snapshot.duplicate(true)
	data.merge(stamp())
	data["kind"] = "incoming_contact"
	data["native_enemy_attack_id"] = enemy.get("_attack_id")
	events.append(data)

func on_enemy_reaction(snapshot: Dictionary) -> void:
	var data := snapshot.duplicate(true)
	data.merge(stamp())
	data["kind"] = "enemy_health_result"
	events.append(data)

func count(kind: String) -> int:
	return events.filter(func(e): return str(e.get("kind", "")) == kind).size()

func ready() -> bool:
	return gym.player.might.can_begin_defence() and not gym.player.movement.get("_locked") and not gym.player.hit_reaction.is_active() and gym.player.might.get("_current_action").is_empty() and gym.player.might.get("_pending_action").is_empty() and gym.player.might.get("_buffered_request").is_empty()

func state() -> Dictionary:
	var data := stamp()
	data.merge({"player_x": gym.player.global_position.x, "enemy_x": enemy.global_position.x, "facing": str(gym.player.get_facing_direction()), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "charged": gym.player.magic.get_marked_count(), "heat": gym.player.heat.get_value(), "ready": ready(), "action": gym.player.might.get("_current_action").duplicate(true), "pending": gym.player.might.get("_pending_action").duplicate(true), "buffer": gym.player.might.get("_buffered_request").duplicate(true), "paused": paused, "enemy_phase": enemy._state_name()})
	return data

func shot(key: String) -> void:
	if not capture:
		return
	var scheduled := stamp()
	await RenderingServer.frame_post_draw
	var data := state()
	data["scheduled"] = scheduled
	var path := output.path_join("%s_%s.png" % [label, key])
	var pixels := root.get_texture().get_image()
	check(not pixels.is_empty() and pixels.save_png(path) == OK, "actual viewport " + key)
	data["png"] = path
	captures.append(data)

func bind() -> void:
	gym = current_scene
	enemy = gym.get("_current_area").get_targets()[0]
	gym.player.combat.outcome_published.connect(on_outcome)
	gym.player.health_resolver.reaction_evaluated.connect(on_reaction)
	enemy.health_resolver.reaction_evaluated.connect(on_enemy_reaction)

func fresh(name: String, controlled: bool, facing: int = 1) -> void:
	release_all()
	if is_instance_valid(gym):
		for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
			audio.stop()
		current_scene = null
		gym.free()
		await step(3)
	gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await step(3)
	label = name
	events = []
	bind()
	if controlled:
		gym.get("_config")["enemy_ai"]["enabled"] = false
		check(gym._apply_runtime_tuning()["ok"], "private no-pressure AI setup")
	# Initial placement only, before commands. No actor/resource edits thereafter.
	enemy.global_position.x = gym.player.global_position.x + 56.0 * facing
	if facing < 0:
		await tap("left")
	await seconds(0.1)

func save_case(setup: String) -> void:
	var native: Dictionary = {}
	var committed: Dictionary = {}
	var launched: Dictionary = {}
	var applied := 0
	for event in events:
		if event.get("kind") == "enemy_health_result" and event.get("outcome") == "APPLIED" and str(event.get("attacker_move", "")).begins_with("fire_x"):
			applied += 1
		if event.get("kind") in ["cast_committed", "cast_launched"]:
			var cast_id := str(event.get("commit_id", -1))
			var counts: Dictionary = committed if event.kind == "cast_committed" else launched
			counts[cast_id] = int(counts.get(cast_id, 0)) + 1
		if event.get("kind") == "incoming_contact" and int(event.get("native_enemy_attack_id", 0)) > 0:
			var id := str(event.native_enemy_attack_id)
			native[id] = int(native.get(id, 0)) + 1
	for id in native:
		check(native[id] == 1, "native enemy contact once per action " + id)
	for id in committed:
		check(committed[id] == 1 and launched.get(id, 0) <= 1, "one commit / at most one launch per commitment " + id)
	check(count("orb_created") == applied, "exactly one generated orb per APPLIED melee")
	check(count("cast_launched") <= count("cast_committed"), "no launch without commitment")
	cases.append({"name": label, "setup": setup, "events": events.duplicate(true), "final": state(), "native_contacts": native, "commit_counts": committed, "launch_counts": launched, "applied_melee": applied})
	print("PACING_CASE ", label, " commits=", count("cast_committed"), " launches=", count("cast_launched"), " incoming=", count("incoming_contact"))

func wait_ready(limit := 3.0) -> void:
	var until := observer.process_time + limit
	while observer.process_time < until and not ready():
		await step()
	check(ready(), "returns to READY with empty current/pending/buffer")

func generate() -> void:
	input("casting", true)
	await step(2)
	await tap("light_attack")
	var until := observer.process_time + 2.0
	while observer.process_time < until:
		if gym.player.magic.get_marked_count() > 0 and (ready() or gym.player.combat.get_normalized_attack_progress() >= 0.6):
			break
		await step()
	check(gym.player.magic.get_marked_count() > 0, "real melee generates then held input charges")
	await shot("charged_%d" % count("orb_created"))

func cycle() -> void:
	var commits := count("cast_committed")
	var launches := count("cast_launched")
	await generate()
	input("casting", false)
	var sent := false
	var until := observer.process_time + 4.0
	while observer.process_time < until:
		var action: Dictionary = gym.player.might.get("_current_action")
		if not sent and str(action.get("kind", "")).begins_with("cast") and gym.player.combat.get_normalized_attack_progress() >= 0.6:
			await shot("cast_%d" % count("cast_committed"))
			await tap("light_attack")
			sent = true
		if sent and ready():
			break
		await step()
	check(count("cast_committed") == commits + 1 and count("cast_launched") == launches + 1, "one valid release commits and launches once")
	check(sent and ready(), "return melee completes with empty occupancy")

func retry() -> void:
	var old_player: int = gym.player.get_instance_id()
	await tap("pause")
	check(paused, "Esc opens real pause menu")
	await tap("down")
	await tap("accept")
	await step(5)
	bind()
	check(gym.player.get_instance_id() != old_player and not paused, "menu Retry replaces actual encounter")
	check(gym.player.health.get_current() == 100.0 and enemy.health.get_current() == 200.0 and gym.player.magic.get_snapshot().is_empty() and gym.player.heat.get_value() == 0.0 and ready(), "Retry clears health/resources/locks/pending/buffer")
	check(not gym.player.hit_reaction.is_active() and not enemy.hit_reaction.is_active(), "Retry clears both real reaction owners")
	var before := events.size()
	await seconds(0.25)
	check(events.size() == before, "no stale old-player outcomes after Retry")
	await shot("retry")

func run() -> void:
	root.size = Vector2i(1280, 720)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--rate-label="):
			rate = int(arg.trim_prefix("--rate-label="))
		elif arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
		elif arg == "--capture":
			capture = true
	if output.is_empty():
		output = ProjectSettings.globalize_path("res://pacing-evidence")
	DirAccess.make_dir_recursive_absolute(output)
	if capture and DisplayServer.get_name() == "headless":
		printerr("Graphical capture requires actual renderer")
		quit(1)
		return
	observer = Observer.new()
	observer.process_mode = Node.PROCESS_MODE_ALWAYS
	observer.process_priority = 1000
	observer.process_physics_priority = 1000
	root.add_child(observer)
	# Fixed-fps startup has a short accumulator correction. Preserve those samples,
	# then measure a separate settled window instead of assuming the first delta.
	await step(12)
	var startup := {"process_deltas": observer.process_deltas.duplicate(), "physics_deltas": observer.physics_deltas.duplicate(), "steps": observer.steps_per_process.duplicate()}
	var start_p := observer.processes
	var start_h := observer.physics
	var start_pt := observer.process_time
	var start_ht := observer.physics_time
	await seconds(2.0)
	var calibration := {"target_process_rate": rate, "physics_setting": Engine.physics_ticks_per_second, "process_count": observer.processes - start_p, "physics_count": observer.physics - start_h, "process_delta_sum": observer.process_time - start_pt, "physics_delta_sum": observer.physics_time - start_ht, "process_deltas": observer.process_deltas.slice(start_p), "physics_deltas": observer.physics_deltas.slice(start_h), "physics_steps_per_process": observer.steps_per_process.slice(start_p), "startup": startup}
	check(Engine.physics_ticks_per_second == 60, "physics remains configured60")
	check(absf(calibration.process_delta_sum / calibration.process_count - 1.0 / rate) < 0.00001, "CLI measured settled process delta matches requested rate")
	check(absf(calibration.physics_delta_sum / calibration.physics_count - 1.0 / 60) < 0.00001, "physics delta remains1/60")
	check(absf(float(calibration.physics_count) / calibration.process_count - 60.0 / rate) < 0.05, "actual callback ratio matches60/target")
	for facing in [1, -1]:
		await fresh("controlled_facing_%d" % facing, true, facing)
		for i in range(3):
			await cycle()
		var applied := events.filter(func(e): return e.get("kind") == "enemy_health_result" and e.get("outcome") == "APPLIED" and e.get("attacker_move") != "Cast").size()
		check(applied == 6 and count("orb_created") == applied, "six APPLIED melee contacts generate exactly six orbs")
		save_case("AI disabled via private live config; initial gap56/facing input; zero initial resources; three real loops")
	await fresh("actual_E_interruption", false)
	await generate()
	input("casting", false)
	var until := observer.process_time + 2.0
	while observer.process_time < until and gym.player.health.get_current() == 100.0:
		await step()
	check(gym.player.health.get_current() < 100.0 and count("action_interrupted") > 0, "actual default E interrupts active Player action")
	await shot("incoming")
	await wait_ready(0.8)
	var accepted := count("action_accepted")
	await tap("light_attack")
	check(count("action_accepted") > accepted, "first legal next melee accepted after real interruption")
	await seconds(4.2)
	check(count("incoming_contact") >= 3, "multiple ordinary native E actions observed")
	save_case("default E configuration; initial gap56; no resources or Health seeded; actual incoming strike")
	events = []
	label = "actual_E_retry"
	await retry()
	save_case("real menu Retry following native pressure; stale-event observation")
	await fresh("pause_release_resume", true)
	await generate()
	await tap("pause")
	check(paused, "actual pause while charged")
	var committed := count("cast_committed")
	var launched := count("cast_launched")
	var orbs: int = gym.player.magic.get_snapshot().size()
	var animation_time: float = gym.player.animation_player.current_animation_position
	input("casting", false)
	await seconds(0.3)
	check(count("cast_committed") == committed and count("cast_launched") == launched and gym.player.magic.get_snapshot().size() == orbs and is_equal_approx(gym.player.animation_player.current_animation_position, animation_time), "paused release does not advance actors or commit/launch")
	await shot("paused_release")
	await tap("pause")
	await seconds(1.6)
	check(not paused and count("cast_committed") == committed + 1 and count("cast_launched") == launched + 1, "resume samples held-to-released state once")
	# An empowered Cast intentionally keeps the chain open for the next melee.
	# Empty action occupancy here is legal; READY follows that melee's completion.
	check(not gym.player.movement.get("_locked") and gym.player.might.get("_current_action").is_empty() and gym.player.might.get("_pending_action").is_empty() and gym.player.might.get("_buffered_request").is_empty(), "completed empowered Cast unlocks movement and leaves no stale occupancy while chain awaits next input")
	var next_accepted := count("action_accepted")
	await tap("light_attack")
	check(count("action_accepted") == next_accepted + 1, "legal melee accepted after paused empowered Cast")
	await wait_ready()
	await shot("resumed_melee")
	save_case("private AI disable; real generated resources; release L2 during pause; resume once; next melee")
	events = []
	label = "pause_release_retry"
	await retry()
	save_case("real menu Retry following paused release")
	release_all()
	var report := {"engine": Engine.get_version_info(), "display": DisplayServer.get_name(), "capture": capture, "calibration": calibration, "cases": cases, "captures": captures, "checks": checks, "failures": failures, "final_clock": stamp(), "clock_note": "engine callback counters primary; accumulated observer times include callbacks completed before event; fixed-fps simulation time is not wall speed"}
	var file := FileAccess.open(output.path_join("pacing-%d.json" % rate), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	print("PACING_RESULT ", checks, " checks; failures=", failures.size(), " process_count=", calibration.process_count, " physics_count=", calibration.physics_count, " process_seconds=", calibration.process_delta_sum, " physics_seconds=", calibration.physics_delta_sum)
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	# Accelerated fixed-fps does not give Dummy audio's wall-time cleanup a frame
	# budget. This waits only after measurements, without altering any combat clock.
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await step(30)
	OS.delay_msec(100)
	quit(0 if failures.is_empty() else 1)
