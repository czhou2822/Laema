extends SceneTree

const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Style = preload("res://scripts/combat/attack_style.gd")
const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Fields = preload("res://scripts/ui/developer_settings_fields.gd")
const Settings = preload("res://scripts/config/combat_tuning_settings.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")
const Bridge = preload("res://scripts/config/combat_tuning_bridge.gd")

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


func _run() -> void:
	var loaded := Loader.load_and_validate("res://config/prototype_combat.json")
	check(loaded["ok"], "Style fixture validates")
	if not loaded["ok"]:
		printerr(loaded["error"])
		quit(1)
		return
	config = loaded["data"]
	var original_hash := FileAccess.get_sha256("res://config/prototype_combat.json")
	var cast_before: Dictionary = config["moves"]["cast"].duplicate(true)
	var style_fields := Catalog.fields(config, "attack_styles")
	check(style_fields.size() == 160, "All 20 X moves expose eight style settings")
	check(Catalog.fields(config, "moves").size() == 22, "Impact page remains separate")
	var panel := Fields.new()
	root.add_child(panel)
	panel.configure(config, "attack_styles", config, config, config)
	check(panel.get("_inputs").size() == 160, "Shared editor/runtime field renderer creates all style inputs")
	for field in style_fields:
		check(not field["integer"], "Style field keeps fractional tuning: " + field["id"])
	panel.free()

	var library = load("res://config/combat_tuning.tres")
	for entry in library.attack_styles:
		var expected := "res://config/attack_styles/%s.tres" % str(entry.move_id)
		check(entry.resource_path == expected and ResourceLoader.exists(expected), "Move has a FileSystem asset: " + str(entry.move_id))
		check(not entry.is_built_in(), "Move is external rather than embedded: " + str(entry.move_id))
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
