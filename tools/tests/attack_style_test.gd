extends SceneTree

const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Style = preload("res://scripts/combat/attack_style.gd")
const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Fields = preload("res://scripts/ui/developer_settings_fields.gd")
const Settings = preload("res://scripts/config/combat_tuning_settings.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")
const Bridge = preload("res://scripts/config/combat_tuning_bridge.gd")
const Geometry = preload("res://scripts/combat/attack_geometry.gd")

var checks := 0
var failures: Array[String] = []
var config: Dictionary
var contacts := 0


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: ", description)


func player_fixture():
	var actor = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(actor)
	var fixture := config.duplicate(true)
	fixture["movement"]["gravity_scale"] = 0.0
	actor.configure(fixture)
	actor.set_process(false)
	actor.set_physics_process(false)
	actor.movement.set_physics_process(false)
	actor.might.set_physics_process(false)
	actor.heat.set_process(false)
	actor.might.outcome_published.connect(func(outcome):
		if outcome.get_kind() == &"light_contact_resolved":
			contacts += 1
	)
	return actor


func free_player(actor) -> void:
	for audio in actor.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	actor.free()


func advance_action(actor) -> void:
	var action_id := int(actor.might.get("_current_action").get("source_action_id", -1))
	for step in range(600):
		if not actor.might.is_attack_playing() or int(actor.might.get("_current_action").get("source_action_id", -1)) != action_id:
			return
		actor.might._physics_process(0.01)
	check(false, "Action must finish or hand off within the bounded animation drive")


func advance_to_phase(actor, phase: float) -> void:
	for step in range(600):
		if not actor.might.is_attack_playing() or actor.might.get_normalized_attack_progress() >= phase:
			return
		actor.might._physics_process(0.005)
	check(false, "Action must reach its input phase within the bounded animation drive")


func prepare_cast_input(actor, school: StringName) -> void:
	actor.combat.set_process(false)
	actor.magic.set_process(false)
	Input.action_release(&"casting")
	actor.combat._process(0.0)
	Input.action_press(&"casting", 1.0)
	actor.combat._process(0.0)
	actor.magic.add_orb(school)
	actor.magic._process(float(config["casting"]["charge_step_duration"]))
	check(actor.magic.has_marked_orbs(), "L2 hold charges the available orb before the Cast comparison")


func check_cast_followups() -> void:
	var schools := [&"fire", &"water", &"air", &"earth"]
	for index in schools.size():
		for mode in ["after_melee", "windowed", "buffered"]:
			var actor = player_fixture()
			var school: StringName = schools[index]
			# The committed orb, rather than the selected melee school, chooses the clip.
			var cast_school: StringName = schools[(index + 1) % schools.size()]
			actor.might.try_select_school(school)
			var launches: Array[Dictionary] = []
			actor.combat.cast_launch_requested.connect(func(payload): launches.append(payload))
			prepare_cast_input(actor, cast_school)
			actor.might.try_light_attack(Vector2.RIGHT)
			if mode == "after_melee":
				advance_action(actor)
			else:
				advance_to_phase(actor, 0.30 if mode == "buffered" else 0.60)
			Input.action_release(&"casting")
			actor.combat._process(0.0)
			if mode == "buffered":
				check(actor.might.get("_buffered_request").get("kind") == &"cast", "L2 release enters the melee Cast buffer")
				advance_to_phase(actor, 0.60)
			if mode != "after_melee":
				check(actor.might.get("_pending_action").get("move_id") == &"cast", "Melee window queues the committed Cast")
				advance_action(actor)
			check(actor.animation_player.assigned_animation == StringName("cast_" + str(cast_school)) and actor.might.is_attack_playing(), "Melee hands off to the committed school Cast: %s/%s" % [school, mode])
			advance_to_phase(actor, 0.60)
			check(launches.size() == 1, "Melee follow-up Cast launches exactly once: " + mode)
			actor.might.try_light_attack(Vector2.RIGHT)
			check(not actor.might.get("_pending_action").is_empty(), "Cast window accepts the next melee action")
			advance_action(actor)
			check(actor.animation_player.assigned_animation == StringName("%s_x3" % school) and actor.might.is_attack_playing(), "Cast completion starts queued melee: %s/%s" % [school, mode])
			advance_action(actor)
			check(actor.might.get("_current_action").is_empty() and actor.might.get("_pending_action").is_empty() and actor.might.can_begin_defence(), "Melee/Cast follow-ups return control after completion")
			check(launches.size() == 1, "Later melee does not repeat the committed projectile")
			free_player(actor)
	# Reproduce the reported retained-orb symptom after a Cast has queued melee.
	var retry_actor = player_fixture()
	var launches: Array[Dictionary] = []
	retry_actor.combat.cast_launch_requested.connect(func(payload): launches.append(payload))
	prepare_cast_input(retry_actor, &"fire")
	retry_actor.might.try_light_attack(Vector2.RIGHT)
	advance_to_phase(retry_actor, 0.60)
	Input.action_release(&"casting")
	retry_actor.combat._process(0.0)
	advance_action(retry_actor)
	advance_to_phase(retry_actor, 0.60)
	retry_actor.might.try_light_attack(Vector2.RIGHT)
	advance_action(retry_actor)
	prepare_cast_input(retry_actor, &"fire")
	advance_to_phase(retry_actor, 0.60)
	Input.action_release(&"casting")
	retry_actor.combat._process(0.0)
	check(not retry_actor.magic.has_marked_orbs(), "Repeat L2 release consumes charged orbs after the Cast/melee handoff")
	check(retry_actor.might.get("_pending_action").get("move_id") == &"cast", "Stale queued melee cannot block the next release-Cast")
	advance_action(retry_actor)
	advance_action(retry_actor)
	check(launches.size() == 2 and retry_actor.might.get("_current_action").is_empty() and not retry_actor.movement.get("_locked"), "Repeated melee-to-Cast launches again and releases movement")
	free_player(retry_actor)
	# The sixth-slot Cast completes the chain, rather than leaving a stale action.
	var actor = player_fixture()
	var completed: Array = []
	actor.input_combo.combo_completed.connect(func(tokens): completed.append(tokens))
	prepare_cast_input(actor, &"fire")
	for position in range(1, 6):
		actor.might.try_light_attack(Vector2.RIGHT)
		if position < 5:
			advance_action(actor)
	advance_to_phase(actor, 0.60)
	Input.action_release(&"casting")
	actor.combat._process(0.0)
	advance_action(actor)
	check(actor.might.get("_current_action").get("kind") == &"cast_endpoint", "X5 hands off to its sixth-slot Cast")
	advance_action(actor)
	check(completed.size() == 1 and not actor.input_combo.is_active() and actor.might.can_begin_defence(), "Endpoint Cast finishes the chain and releases control")
	free_player(actor)
	Input.action_release(&"casting")


func check_cast_after_contact() -> void:
	for charge_before_melee in [false, true]:
		var actor = player_fixture()
		actor.combat.set_process(false)
		actor.magic.set_process(false)
		actor.get("_config")["combat"]["collect_orb_without_contact"] = false
		var target = load("res://scenes/enemy/enemy.tscn").instantiate()
		target.position = actor.to_global(Vector2(30, 11))
		root.add_child(target)
		target.configure(actor.get("_config"))
		await physics_frame
		var launches: Array[Dictionary] = []
		actor.combat.cast_launch_requested.connect(func(payload): launches.append(payload))
		Input.action_release(&"casting")
		actor.combat._process(0.0)
		for cycle in range(2):
			if charge_before_melee:
				Input.action_press(&"casting", 1.0)
				actor.combat._process(0.0)
			actor.might.try_light_attack(Vector2.RIGHT)
			advance_action(actor)
			check(not actor.magic.get_snapshot().is_empty(), "Real melee contact generates the orb for the release-Cast")
			if not charge_before_melee:
				Input.action_press(&"casting", 1.0)
				actor.combat._process(0.0)
			actor.magic._process(float(config["casting"]["charge_step_duration"]))
			check(actor.magic.has_marked_orbs(), "L2 charges the melee-generated orb")
			Input.action_release(&"casting")
			actor.combat._process(0.0)
			check(actor.animation_player.assigned_animation == &"cast_fire" and actor.might.is_attack_playing(), "L2 release starts Cast after a real melee hit")
			advance_action(actor)
			check(launches.size() == cycle + 1 and actor.might.get("_current_action").is_empty(), "Repeated melee/charge/release cycles launch once and clear the completed action")
			check(not actor.movement.get("_locked"), "Completed Cast releases its movement lock")
		free_player(target)
		free_player(actor)
	Input.action_release(&"casting")


func check_progress_lifecycle() -> void:
	var unconfigured := MightComponent.new()
	check(unconfigured.get_normalized_attack_progress() == 0.0, "Unconfigured Might has no attack progress")
	unconfigured.free()
	var actor = player_fixture()
	check(actor.might.get_normalized_attack_progress() == 0.0, "Idle Player has zero progress without querying absent native playback")
	actor.might.try_light_attack(Vector2.RIGHT)
	advance_to_phase(actor, 0.35)
	var progress: float = actor.might.get_normalized_attack_progress()
	check(progress >= 0.35 and progress < 0.5, "Active melee retains its normalized progress")
	actor.animation_player.pause()
	check(is_equal_approx(actor.might.get_normalized_attack_progress(), progress), "Paused action retains progress despite empty native current_animation")
	actor.animation_player.play()
	advance_action(actor)
	check(actor.might.get("_current_action").is_empty() and actor.might.get_normalized_attack_progress() == 0.0, "Completed unpreserved action returns zero progress and releases its action")
	actor.might.try_light_attack(Vector2.RIGHT)
	advance_to_phase(actor, 0.35)
	actor.might.cancel_for_player_hit()
	actor.might.enter_hit_reaction()
	actor.might.try_light_attack(Vector2.RIGHT)
	check(actor.might.get_normalized_attack_progress() == 0.0 and actor.might.is_hit_reacting(), "Rejected X during stopped hit reaction safely reports zero progress")
	free_player(actor)


func check_fire_cast_cadence() -> void:
	# Focused manual-clock regression; real-input frame evidence stays in the
	# overnight Cast fixture. No new eligibility or duration policy is introduced.
	var actor = player_fixture()
	prepare_cast_input(actor, &"fire")
	var elapsed: Array[float] = [0.0]
	var launch_times: Array[float] = []
	actor.combat.cast_launch_requested.connect(func(_payload): launch_times.append(elapsed[0]))
	Input.action_release(&"casting")
	actor.combat._process(0.0)
	var action_id: int = actor.might.get("_current_action")["source_action_id"]
	var duration: float = float(config["combat"]["attack_duration"]) / actor.heat.get_speed_multiplier()
	var queued := false
	for step in range(2000):
		elapsed[0] += 0.001
		actor.might._physics_process(0.001)
		if int(actor.might.get("_current_action").get("source_action_id", -1)) != action_id:
			break
		if not queued and actor.might.get_normalized_attack_progress() >= 0.6:
			actor.might.try_light_attack(Vector2.RIGHT)
			queued = true
	check(launch_times.size() == 1 and absf(launch_times[0] - duration * 0.24) <= 0.0011, "Fire launch occurs once at the retained 0.24 clock marker")
	check(absf(elapsed[0] - duration) <= 0.0011, "Earlier Fire launch preserves full configured Cast duration")
	check(queued and actor.might.get("_current_action").get("kind") == &"light" and actor.might.get("_pending_action").is_empty(), "Unchanged Cast cadence hands off queued melee at completion")
	free_player(actor)


func _run() -> void:
	var loaded := Loader.load_and_validate("res://config/prototype_combat.json")
	check(loaded["ok"], "Style fixture validates")
	if not loaded["ok"]:
		printerr(loaded["error"])
		quit(1)
		return
	config = loaded["data"]
	check_progress_lifecycle()
	check_fire_cast_cadence()
	var original_hash := FileAccess.get_sha256("res://config/prototype_combat.json")
	var cast_before: Dictionary = config["moves"]["cast"].duplicate(true)
	check_cast_followups()
	await check_cast_after_contact()
	var style_fields := Catalog.fields(config, "attack_styles")
	check(style_fields.size() == 161, "Twenty X moves expose base styles plus the Fire X5 motion control")
	check(Catalog.fields(config, "moves").size() == 22, "Impact page remains separate")
	var panel := Fields.new()
	root.add_child(panel)
	panel.configure(config, "attack_styles", config, config, config)
	check(panel.get("_inputs").size() == 161, "Shared editor/runtime field renderer creates all style inputs")
	for field in style_fields:
		check(not field["integer"], "Style field keeps fractional tuning: " + field["id"])
	panel.free()

	var library = load("res://config/combat_tuning.tres")
	for entry in library.attack_styles:
		var expected := "res://config/attack_styles/%s.tres" % str(entry.move_id)
		check(entry.resource_path == expected and ResourceLoader.exists(expected), "Move has a FileSystem asset: " + str(entry.move_id))
		check(not entry.is_built_in(), "Move is external rather than embedded: " + str(entry.move_id))
		check(entry.animation != null and entry.animation.resource_path == Geometry.DIRECTORY + str(entry.move_id) + ".tres", "Move settings lead to the same native animation asset: " + str(entry.move_id))
	# Seek the actual scene AnimationPlayer without configuring gameplay scripts,
	# just as the editor preview does. No script-driven frame selection is needed.
	var preview_actor = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(preview_actor)
	var other_actor = load("res://scenes/player/player.tscn").instantiate()
	root.add_child(other_actor)
	var counts := {"fire": [4, 3, 4, 5, 4], "water": [5, 5, 4, 5, 5], "air": [9, 7, 7, 6, 8], "earth": [5, 3, 11, 11, 9]}
	var visual_source := {"fire": "earth", "earth": "fire", "water": "water", "air": "air"}
	for entry in library.attack_styles:
		var id := str(entry.move_id)
		var school := id.get_slice("_", 0)
		var source_school: String = visual_source[school]
		var count: int = counts[school][int(id.right(1)) - 1]
		var native: Animation = preview_actor.animation_player.get_animation(id)
		check(native == entry.animation, "Scene and settings reference one shared animation: " + id)
		preview_actor.animation_player.play(id)
		preview_actor.animation_player.seek(0.0, true)
		var sheet_id := "%s_x%s" % [source_school, id.right(1)]
		if sheet_id == "fire_x4":
			sheet_id = "fire_x4_opposite_limb_trial"
		elif sheet_id == "fire_x5":
			sheet_id = "fire_x4"
		check(preview_actor.sprite.texture.resource_path == "res://assets/prototype/player/animation/%s.png" % sheet_id, "Native clip uses the assigned school's flipbook source: " + id)
		for phase in [0.0, 0.19, 0.36, 0.67, 0.999]:
			preview_actor.animation_player.seek(phase, true)
			var frame := mini(int(floor(pow(phase, float(config[source_school]["visual_motion_exponent"])) * count)), count - 1)
			check(preview_actor.sprite.region_rect.position.x == frame * 128.0, "Native scrubbing preserves the assigned flipbook's frame pacing: %s at %s" % [id, phase])
		preview_actor.animation_player.seek(native.get_marker_time(&"contact"), true)
		check(preview_actor.attack_cast.target_position.length() == entry.shape_reach and (preview_actor.attack_cast.shape as CircleShape2D).radius == entry.shape_radius, "Scrubbed contact pose matches the Portal geometry: " + id)
	check(preview_actor.attack_cast.shape != other_actor.attack_cast.shape, "Native shape tracks cannot resize another actor's hitbox")
	for school in counts:
		preview_actor.animation_player.play("cast_" + school)
		for phase in [0.0, 0.19, 0.36, 0.67, 0.999]:
			preview_actor.animation_player.seek(phase, true)
			var authored_phase: float = phase
			if school == "fire":
				# Inverse of the reviewed piecewise retiming; preserve the same poses.
				authored_phase = phase * (0.36 / 0.24) if phase <= 0.24 else 0.36 + (phase - 0.24) * (0.64 / 0.76)
			var frame := mini(int(floor(pow(authored_phase, float(config[school]["visual_motion_exponent"])) * 10)), 9)
			check(preview_actor.sprite.region_rect.position.x == frame * 128.0, "Native Cast scrubbing retains school frame pacing: " + school)
	var fire_clock: Animation = preview_actor.animation_player.get_animation(&"cast_fire")
	check(is_equal_approx(fire_clock.get_marker_time(&"contact"), 0.24) and is_equal_approx(fire_clock.get_marker_time(&"active_start"), 0.24), "Retained Fire anticipation markers are 0.24")
	check(is_equal_approx(fire_clock.length, 1.0) and is_equal_approx(fire_clock.get_marker_time(&"active_end"), 1.0), "Fire Cast retains its normalized action end")
	preview_actor.animation_player.play(&"cast_fire")
	preview_actor.animation_player.seek(0.24, true)
	check(preview_actor.sprite.region_rect.position.x == 384.0, "Retimed Fire launch preserves its original contact pose")
	preview_actor.animation_player.stop()
	free_player(preview_actor)
	free_player(other_actor)
	var settings = library.duplicate_deep(Resource.DEEP_DUPLICATE_ALL)
	check(settings.attack_styles[0] != library.attack_styles[0], "Run-only tuning duplicates do not share external move Resources")
	check(settings.attack_styles.size() == 20, "Serialized Inspector mirror includes all school moves")
	check(Store.changes(Settings.data_from_config(config), settings.get_data()).is_empty(), "Serialized Inspector and JSON style/Impact/reaction data match")
	if not Store.changes(Settings.data_from_config(config), settings.get_data()).is_empty():
		print("MIRROR DIFFERENCES: ", Store.changes(Settings.data_from_config(config), settings.get_data()))
	settings.read_from_config(config)
	var mirrored: Dictionary = config.duplicate(true)
	check(settings.apply_to_config(mirrored)["ok"] and Store.changes(config, mirrored).is_empty(), "Inspector round trip retains every unrelated field")
	if not Store.changes(config, mirrored).is_empty():
		print("ROUND TRIP DIFFERENCES: ", Store.changes(config, mirrored))
	settings.attack_styles[0].windup_duration += 0.01
	check(settings.apply_to_config(mirrored)["ok"] and Loader.validate(mirrored)["ok"], "Inspector edits produce valid tunable timing")
	check(Store.changes(cast_before, mirrored["moves"]["cast"]).is_empty(), "Inspector style edit does not alter Cast")
	if not Store.changes(cast_before, mirrored["moves"]["cast"]).is_empty():
		print("CAST DIFFERENCE: ", Store.changes(cast_before, mirrored["moves"]["cast"]))
	for mutation in ["negative", "phase_order", "nonfinite"]:
		var bad: Dictionary = config.duplicate(true)
		match mutation:
			"negative": bad["moves"]["air_x1"]["forward_lunge"]["distance"] = -1.0
			"phase_order": bad["moves"]["air_x1"]["forward_lunge"]["end_phase"] = 0.1
			"nonfinite": bad["moves"]["air_x1"]["shape_reach"] = NAN
		check(not Loader.validate(bad)["ok"], "Reject invalid style: " + mutation)

	var clock := Animation.new()
	clock.length = 1.0
	clock.add_marker(&"contact", 0.36)
	var profile := Style.capture(config["moves"]["air_x1"], config["combat"])
	profile["windup_duration"] = 0.24
	profile["recovery_duration"] = 0.36
	check(is_equal_approx(Style.predict_time(clock, profile, 0.0, 0.24, 1.0), 0.36), "Windup ends exactly at authored contact")
	check(is_equal_approx(Style.predict_time(clock, profile, 0.0, 0.60, 1.0), 1.0), "Large step crosses both timing phases")
	check(is_equal_approx(Style.predict_time(clock, profile, 0.0, 0.16, 1.5), 0.36), "Heat scales windup once")
	check(is_equal_approx(Style.predict_time(clock, profile, 0.36, 0.24, 1.5), 1.0), "Heat scales post-contact timing once")
	for position in range(1, 6):
		var totals: Dictionary = {}
		for school in ["fire", "water", "air", "earth"]:
			var move: Dictionary = config["moves"]["%s_x%d" % [school, position]]
			totals[school] = float(move["windup_duration"]) + float(move["recovery_duration"])
		check(totals["air"] < totals["fire"] and totals["air"] < totals["water"] and totals["earth"] > totals["fire"] and totals["earth"] > totals["water"], "Fast/medium/slow distinction at X%d" % position)

	var actor = player_fixture()
	# Author non-default offsets, angle and radius in the native tracks, then use
	# real contact queries in both directions. Config scalars cannot express this pose.
	var native: Animation = actor.animation_player.get_animation(&"fire_x1")
	var contact_time := native.get_marker_time(&"contact")
	for direction in [Vector2.RIGHT, Vector2.LEFT]:
		actor.reset_for_stage()
		native.track_insert_key(native.find_track(Geometry.POSITION, Animation.TYPE_VALUE), contact_time, Vector2(13, -100))
		native.track_insert_key(native.find_track(Geometry.TARGET, Animation.TYPE_VALUE), contact_time, Vector2(25, -10))
		native.track_insert_key(native.find_track(Geometry.RADIUS, Animation.TYPE_VALUE), contact_time, 6.0)
		var target = load("res://scenes/enemy/enemy.tscn").instantiate()
		target.position = actor.to_global(Vector2(30 * direction.x, -100))
		root.add_child(target)
		target.configure(actor.get("_config"))
		await physics_frame
		actor.might.try_light_attack(direction)
		var pose: Dictionary = actor.might.get_attack_geometry()
		check(pose["position"] == Vector2(13 * direction.x, -100) and pose["target"] == Vector2(25 * direction.x, -10) and pose["radius"] == 6.0, "Committed geometry follows native keys and mirrors horizontal coordinates only")
		# A tuning refresh mid-swing must not change the committed hit pose.
		actor.get("_config")["moves"]["fire_x1"]["shape_reach"] = 110.0
		actor.apply_runtime_tuning()
		check(actor.might.get_attack_geometry() == pose, "In-flight geometry survives later Portal changes")
		actor.might._physics_process(1.0)
		check(target.health.get_current() < target.health.get_maximum(), "Real contact hits the target at the authored offset in either facing")
		check(actor.attack_cast.position.x >= 0.0, "Contact query restores canonical editor-facing node coordinates")
		free_player(target)
	free_player(actor)
	actor = player_fixture()
	var x1: Dictionary = actor.get("_config")["moves"]["fire_x1"]
	x1["windup_duration"] = 0.24
	x1["recovery_duration"] = 0.36
	contacts = 0
	actor.might.try_light_attack(Vector2.RIGHT)
	actor.might._physics_process(0.12)
	check(not actor.might.get("_hit_emitted"), "No early hit before windup")
	actor.might._physics_process(0.12)
	check(actor.might.get("_hit_emitted") and contacts == 1, "Exactly one contact at windup boundary")
	actor.might._physics_process(0.18)
	check(contacts == 1 and actor.might.is_attack_playing(), "Post-contact timing does not repeat the hit")
	actor.might._physics_process(0.18)
	check(not actor.might.is_attack_playing(), "Action completes after its configured windup plus recovery")
	actor.reset_for_stage()
	actor.might.try_light_attack(Vector2.RIGHT)
	x1["forward_lunge"]["distance"] = 200.0
	check(actor.might.get("_current_action")["style"]["forward_lunge"]["distance"] != 200.0, "Active move captures its tuning; later edits apply to the next action")
	actor.might.cancel_for_player_hit()
	check(actor.might.consume_attack_body_motion(1.0) == Vector2.ZERO, "Cancellation discards remaining attack motion")
	actor.reset_for_stage()
	actor.heat.gain_from_commit(100)
	contacts = 0
	actor.might.try_light_attack(Vector2.RIGHT)
	actor.might._physics_process(0.16)
	check(actor.might.get("_hit_emitted") and contacts == 1, "Runtime Heat uses accelerated windup once")
	actor.reset_for_stage()
	actor.might.try_light_attack(Vector2.RIGHT)
	actor.might._physics_process(0.32)
	actor.might.try_select_school(&"air")
	actor.might.try_light_attack(Vector2.RIGHT)
	check(actor.might.get("_pending_action")["move_id"] == &"air_x2", "School switch selects current global position, not a local school counter")
	actor.might._physics_process(0.28)
	check(actor.might.get("_current_action")["move_id"] == &"air_x2", "Queued school move starts at prior action completion")
	for position in range(3, 6):
		actor.might._physics_process(0.2)
		actor.might.try_light_attack(Vector2.RIGHT)
		actor.might._physics_process(0.3)
		check(actor.input_combo.get_current_position() == position or position == 5, "Five-position progression reaches X%d" % position)
	free_player(actor)

	# Exercise real collision movement at the engine's physics delta.
	actor = player_fixture()
	var body_move: Dictionary = actor.get("_config")["moves"]["fire_x1"]
	body_move["forward_lunge"] = {"distance": 24.0, "start_phase": 0.0, "end_phase": 1.0}
	actor.might.try_light_attack(Vector2.LEFT)
	for index in range(60):
		actor.movement._physics_process(1.0 / 60.0)
		actor.might._physics_process(1.0 / 60.0)
	check(absf(actor.position.x + 24.0) < 0.1, "Body lunge follows committed left facing and consumes exactly its distance")
	actor.reset_for_stage()
	actor.position = Vector2.ZERO
	var wall := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(10.0, 200.0)
	collider.shape = rectangle
	wall.add_child(collider)
	wall.position = Vector2(30.0, 0.0)
	wall.collision_layer = actor.collision_mask
	root.add_child(wall)
	await physics_frame
	body_move["forward_lunge"]["distance"] = 100.0
	actor.might.try_light_attack(Vector2.RIGHT)
	for index in range(60):
		actor.movement._physics_process(1.0 / 60.0)
		actor.might._physics_process(1.0 / 60.0)
	check(actor.position.x < 25.0, "Existing body collision stops lunge at a wall")
	wall.free()
	check(actor.might.consume_attack_body_motion(1.0) == Vector2.ZERO, "Blocked motion does not accumulate for a later burst")
	free_player(actor)

	var reaction := HitReaction.new()
	root.add_child(reaction)
	reaction.configure(config["hit_reaction"])
	reaction.execute_combat(1, Vector2.RIGHT, 2.0)
	var duration: float = config["hit_reaction"]["combat_levels"][0]["duration"]
	check(is_equal_approx(reaction.consume_body_motion(duration).x, 10.0) and reaction.is_invincible(), "Push multiplier changes distance while retaining reaction duration and invincibility")
	reaction.finish_body_motion()
	check(not reaction.is_invincible(), "Scaled push ends invincibility through existing completion")
	reaction.free()
	# Save through the actual Inspector bridge, then reload the files independently.
	var bridge := Bridge.new()
	bridge.settings = library
	root.add_child(bridge)
	var preview := config.duplicate(true)
	check(bridge.initialize(preview, func(): return Loader.validate(preview))["ok"], "External move graph initializes through the Inspector bridge")
	var edited: MoveStyleTuning = bridge.settings.attack_styles[0]
	var asset_path := edited.resource_path
	edited.shape_reach = 73.25
	check(preview["moves"][str(edited.move_id)]["shape_reach"] == 73.25, "Inspector edits retain their existing runtime preview path")
	check(bridge.save_resource()["ok"], "Inspector saves parent and external move Resources")
	var reloaded = ResourceLoader.load(asset_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	check(reloaded.resource_path == asset_path and reloaded.shape_reach == 73.25, "Saved external move reloads with its stable path and edited value")
	var parent = ResourceLoader.load(Store.TUNING_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	check(parent.attack_styles[0].resource_path == asset_path and parent.attack_styles[0].shape_reach == 73.25, "Parent reload retains the external reference rather than rebundling the move")
	bridge.persistence_enabled = false
	var asset_hash := FileAccess.get_sha256(asset_path)
	edited.shape_radius += 1.0
	check(not bridge.save_resource()["ok"] and FileAccess.get_sha256(asset_path) == asset_hash, "Run-only bridge cannot persist external move edits")
	check(Settings.save_config_mirror(config, Store.TUNING_PATH)["ok"], "Configuration mirror saves external assets without a live bridge")
	var restored = ResourceLoader.load(asset_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	check(restored.shape_reach == config["moves"][str(edited.move_id)]["shape_reach"], "Configuration mirror restores the external file's matching data")
	check(edited.shape_reach == 73.25, "Mirror saving does not mutate the running Inspector graph")
	bridge.free()
	library = null
	parent = null
	reloaded = null
	restored = null
	edited = null
	check(FileAccess.get_sha256("res://config/prototype_combat.json") == original_hash, "Tests do not write saved tuning")
	settings = null
	clock = null
	await process_frame
	await process_frame
	await create_timer(0.2).timeout
	if failures.is_empty():
		print("PASSED: %d attack-style checks" % checks)
	quit(0 if failures.is_empty() else 1)
