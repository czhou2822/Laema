extends SceneTree
# Focused cosmetic contract checks; run only after Combat clears primary capture.
const Arena = preload("res://scripts/prototype/prototype_arena.gd")
const Loader = preload("res://scripts/config/prototype_config_loader.gd")
var failures: Array[String] = []
var checks := 0
var cues: Array[Dictionary] = []

class Fighter:
	extends Entity
	func uses_combat_hit_reaction() -> bool:
		return true


class TeardownArea:
	extends StageArea
	var target_queries := 0
	func get_targets() -> Array[Node]:
		target_queries += 1
		return super.get_targets()


class CameraArenaFixture:
	extends "res://scripts/prototype/prototype_arena.gd"
	func _ready() -> void:
		pass # Exercise only the real camera lifecycle, not scene startup/gameplay.
	func _process(_delta: float) -> void:
		pass


class QuietTuningBridge:
	extends CombatTuningBridge
	func _ready() -> void:
		pass


func _initialize() -> void:
	call_deferred("_run")


func check(ok: bool, description: String) -> void:
	checks += 1
	if not ok:
		failures.append(description)
		printerr("FAILED: ", description)


func result(target: Entity, id: int, level: int = 1) -> HealthResult:
	var event := HealthEvent.damage(target, target, 10.0, 30, HealthEvent.Delivery.DIRECT,
		&"fire", {}, Vector2.RIGHT, Vector2(130.0, 220.0), id)
	return HealthResult.create(event, HealthResult.Outcome.APPLIED, -10.0, level, false, false)


func _run() -> void:
	var actor := Fighter.new()
	for component in [HealthComponent.new(), HealthResolver.new(), Node.new(), HitReaction.new(), FeedbackComponent.new()]:
		component.name = ["Health", "HealthResolver", "Status", "HitReaction", "Feedback"][actor.get_child_count()]
		actor.add_child(component)
	root.add_child(actor)
	var options := {"impact_contact_enabled": false, "impact_camera_enabled": false, "impact_treatment": "precise"}
	actor.feedback.configure(actor, 2.0, options)
	actor.feedback.impact_confirmed.connect(func(cue: Dictionary): cues.append(cue))
	var accepted := result(actor, 1)
	check(FeedbackComponent.qualifies_impact(accepted), "actual direct Health loss qualifies")
	for outcome in [HealthResult.Outcome.BLOCKED, HealthResult.Outcome.PARRIED, HealthResult.Outcome.INVINCIBLE, HealthResult.Outcome.INVALID, HealthResult.Outcome.CLASH_LOST, HealthResult.Outcome.CANCELLED]:
		accepted.outcome = outcome
		check(not FeedbackComponent.qualifies_impact(accepted), "rejected outcomes never accent")
	accepted.outcome = HealthResult.Outcome.APPLIED
	for amount in [0.0, 1.0]:
		accepted.health_delta = amount
		check(not FeedbackComponent.qualifies_impact(accepted), "zero damage/healing never accent")
	accepted.health_delta = -10.0
	accepted.event.delivery = HealthEvent.Delivery.DOT_TICK
	check(not FeedbackComponent.qualifies_impact(accepted), "DoT never accents")
	accepted.event.delivery = HealthEvent.Delivery.DIRECT
	actor.feedback.accept_impact(accepted)
	actor.feedback._flush_impacts()
	check(cues.is_empty() and actor.feedback._impact_entries.is_empty(), "baseline flags disable both effects")
	options["impact_camera_enabled"] = true
	options["impact_contact_enabled"] = true
	actor.feedback.accept_impact(accepted)
	actor.feedback.accept_impact(result(actor, 1, 4))
	actor.feedback._flush_impacts()
	check(cues.size() == 1 and int(cues[0]["level"]) == 4, "mixed layers coalesce to strongest qualifying reaction")
	check(cues[0]["point"] == Vector2(130.0, 220.0), "exact world contact is retained")
	check(actor.feedback._impact_entries.size() == 1, "one contact accent per action/target")
	actor.feedback.accept_impact(accepted)
	actor.feedback._flush_impacts()
	check(cues.size() == 1, "repeat delivery of same action is deduplicated")
	actor.feedback.clear_impact_feedback(true)
	check(actor.feedback._impact_entries.is_empty(), "reset clears transients")
	paused = true
	actor.feedback.accept_impact(result(actor, 2))
	actor.feedback._flush_impacts()
	check(cues.size() == 1, "pause rejects new cues")
	paused = false
	# C2 contrast is Weight-only and shares the existing accent transform/lifetime.
	for treatment in ["precise", "weight"]:
		options["impact_treatment"] = treatment
		actor.feedback.clear_impact_feedback(true)
		actor.feedback.accept_impact(result(actor, 3, 4))
		actor.feedback._flush_impacts()
		var accent: Node2D = actor.feedback._impact_entries[0]["node"]
		if treatment == "precise":
			check(accent.get_child_count() == 2 and not accent.has_node("WeightCenter"), "Precise stays unchanged")
		else:
			check(accent.get_child_count() == 5, "Weight retains wedge/two flecks plus edge/center")
			var edge := accent.get_node("WeightEdge") as Polygon2D
			var center := accent.get_node("WeightCenter") as Polygon2D
			check(edge.color == Color.BLACK and center.color == Color.WHITE, "existing black/white palette only")
			check(edge.polygon == PackedVector2Array([Vector2(-4, -3), Vector2(4, -3), Vector2(4, 3), Vector2(-4, 3)]), "8x6 outer edge gives 1px black border")
			check(center.polygon == PackedVector2Array([Vector2(-3, -2), Vector2(3, -2), Vector2(3, 2), Vector2(-3, 2)]), "white center is 6x4px")
			for shape in [edge, center]:
				for point in shape.polygon:
					check(point.length() <= 5.0, "rotated center/edge stays inside smallest 28px footprint")
			check(is_equal_approx(float(actor.feedback._impact_entries[0]["duration"]), 0.11), "Weight keeps 110ms lifetime")
			check(accent.scale == Vector2.ONE * 0.65, "Weight keeps initial expansion scale")
		actor.feedback.clear_impact_feedback(true)
		check(actor.feedback._impact_entries.is_empty(), "center and edge share normal cleanup")
	for treatment in ["precise", "weight"]:
		var weight: bool = treatment == "weight"
		for polygon in FeedbackComponent.contact_polygons(weight):
			for point in polygon:
				check(point.length() <= 0.50001, "complete rotated footprint fits its diameter, not a radius cap")
		check(FeedbackComponent.contact_polygons(weight).size() == (3 if weight else 2), "wedge/two flecks or two tapered ticks, no ring/radial burst")
		for level in range(1, 6):
			for step in range(121):
				var age := float(step) / 1000.0
				var pixels := Arena.impact_camera_pixels(age, level, Vector2(1, 1), treatment)
				check(pixels.length() <= (3.00001 if weight else 1.00001), "camera stays within treatment viewport cap")
				if level < 3 or age >= Arena.impact_camera_duration(treatment):
					check(pixels == Vector2.ZERO, "weak or expired reaction has no camera response")
	var legacy := {"ui": {}}
	Loader._normalize_impact_feedback(legacy)
	check(not legacy["ui"]["impact_contact_enabled"] and not legacy["ui"]["impact_camera_enabled"], "legacy config remains off")
	check(legacy["ui"]["impact_treatment"] == "precise", "legacy treatment is stable")
	await _check_frame_labels(actor)
	actor.free()
	var arena := Arena.new()
	var camera := Camera2D.new()
	arena.add_child(camera)
	arena.transition_camera = camera
	camera.offset = Vector2(5.5, 9.0)
	arena._impact_camera_applied = Vector2(1.5, 0.0)
	arena._clear_impact_feedback()
	check(camera.offset == Vector2(4.0, 9.0), "cleanup removes only owned camera contribution")
	check(arena._impact_camera_started == -1, "cleanup cancels camera timer")
	var area := TeardownArea.new()
	for marker_name in ["EntryAnchor", "ExitAnchor", "PlayerSpawn", "CameraAnchor"]:
		var marker := Marker2D.new()
		marker.name = marker_name
		area.add_child(marker)
	var gate := StaticBody2D.new()
	gate.name = "RightGate"
	area.add_child(gate)
	var trigger := Area2D.new()
	trigger.name = "ExitTrigger"
	area.add_child(trigger)
	arena._current_area = area
	check(is_instance_valid(area) and not area.is_inside_tree(), "detached area remains instance-valid")
	arena._clear_impact_feedback()
	check(area.target_queries == 0, "detached cleanup never asks StageArea for group targets")
	root.add_child(area)
	arena._clear_impact_feedback()
	check(area.target_queries == 1, "normal in-tree cleanup still queries area targets")
	root.remove_child(area)
	camera.offset = Vector2(6.0, 10.0)
	arena._impact_camera_applied = Vector2(2.0, 1.0)
	arena._exit_tree()
	check(area.target_queries == 1, "exit after area removal does not query a null SceneTree")
	check(camera.offset == Vector2(4.0, 9.0), "detached teardown still restores only owned camera offset")
	area.free()
	arena.free()
	_check_detached_camera_callback()
	print("Impact feedback: %d checks, %d failures" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)


func _check_detached_camera_callback() -> void:
	var fixture := CameraArenaFixture.new()
	var player_stub := Fighter.new()
	player_stub.name = "Player"
	for component in [HealthComponent.new(), HealthResolver.new(), Node.new(), HitReaction.new(), FeedbackComponent.new()]:
		component.name = ["Health", "HealthResolver", "Status", "HitReaction", "Feedback"][player_stub.get_child_count()]
		player_stub.add_child(component)
	var bridge := QuietTuningBridge.new()
	bridge.name = "CombatTuning"
	player_stub.add_child(bridge)
	fixture.add_child(player_stub)
	for child_name in ["HUD", "PauseMenu"]:
		var child := Node.new()
		child.name = child_name
		fixture.add_child(child)
	var director := StageDirector.new()
	director.name = "StageDirector"
	fixture.add_child(director)
	var areas := Node2D.new()
	areas.name = "StageAreas"
	fixture.add_child(areas)
	var camera := Camera2D.new()
	camera.name = "Camera2D"
	fixture.add_child(camera)
	for audio_name in ["AmbientAudio", "MusicAudio", "ProjectileImpactAudio"]:
		var audio := AudioStreamPlayer.new()
		audio.name = audio_name
		fixture.add_child(audio)
	root.add_child(fixture)
	fixture._config = {"ui": {"impact_camera_enabled": true}}
	camera.offset = Vector2(4, 9)
	fixture._impact_camera_level = 4
	fixture._impact_camera_treatment = "weight"
	fixture._impact_camera_started = Time.get_ticks_msec() - 20
	process_frame.connect(fixture._update_impact_camera)
	check(fixture.is_inside_tree() and process_frame.is_connected(fixture._update_impact_camera), "valid arena owns process-frame callback")
	fixture._update_impact_camera()
	check(fixture._impact_camera_applied.length() > 0.0, "normal in-tree camera response still updates")
	root.remove_child(fixture)
	check(is_instance_valid(fixture) and not fixture.is_inside_tree(), "removed arena remains instance-valid but detached")
	check(not process_frame.is_connected(fixture._update_impact_camera), "arena exit disconnects its owned process-frame callback")
	check(camera.offset.is_equal_approx(Vector2(4, 9)), "normal exit restores only camera-owned offset")
	camera.offset = Vector2(6, 10)
	fixture._impact_camera_applied = Vector2(2, 1)
	fixture._update_impact_camera()
	check(camera.offset.is_equal_approx(Vector2(4, 9)), "late detached camera update restores contribution without querying tree")
	check(fixture._impact_camera_started == -1, "detached callback clears transient timer")
	fixture.free()


func _legacy_label_position(actor: Entity, label: Label, offset: Vector2) -> Vector2:
	var canvas := actor.get_viewport().get_canvas_transform()
	var screen := canvas * (actor.global_position + offset)
	var size := label.get_combined_minimum_size()
	var visible := actor.get_viewport().get_visible_rect().size
	screen.x = clampf(screen.x, 12.0, visible.x - size.x - 12.0)
	screen.y = clampf(screen.y, 12.0, visible.y - size.y - 12.0)
	return canvas.affine_inverse() * screen


func _check_family(actor: Entity, first: Label, second: Label, description: String) -> void:
	var a := actor.feedback._label_screen_bounds(first)
	var b := actor.feedback._label_screen_bounds(second)
	var viewport := actor.get_viewport().get_visible_rect()
	check(is_equal_approx(b.position.x - a.end.x, 8.0), description + " keeps 8 viewport px between outlined bounds")
	check(a.position.x >= viewport.position.x + 11.99 and b.end.x <= viewport.end.x - 11.99, description + " clamps whole family inside margins")
	check(is_equal_approx(first.global_position.y, second.global_position.y), description + " keeps the same vertical lane")


func _check_frame_labels(actor: Entity) -> void:
	var saved_size := root.size
	root.size = Vector2i(1280, 720)
	actor.scale = Vector2(2, 2) # Include actor scale in actual outlined viewport bounds.
	actor.position = Vector2(640, 420)
	await process_frame
	await process_frame
	actor.feedback.show_damage(&"fire", 13.0)
	var first := actor.get_children().back() as Label
	check(first.global_position.is_equal_approx(_legacy_label_position(actor, first, Vector2(-10, -186))), "single damage anchor unchanged")
	var first_x := first.position.x
	var first_y := first.position.y
	actor.feedback.show_damage(&"water", 10.0)
	var second := actor.get_children().back() as Label
	check(first.text == "13" and second.text == "10", "13 and 10 stay separate, not aggregated")
	check(is_equal_approx(first.position.x, first_x), "first damage stays at its anchor when room exists")
	_check_family(actor, first, second, "center damage")
	check(first.get_theme_font_size("font_size") == 18 and first.get_theme_constant("outline_size") == 3, "damage font/outline unchanged")
	check(first.get_theme_color("font_color") == Color("ff493d") and second.get_theme_color("font_color") == Color("3a96ff"), "individual school colors retained")
	actor.feedback.show_cast_level(&"water", 4)
	var water := actor.get_children().back() as Label
	check(water.global_position.is_equal_approx(_legacy_label_position(actor, water, Vector2(-48, -118))), "single Cast anchor unchanged")
	var water_x := water.position.x
	actor.feedback.show_cast_level(&"fire", 2)
	var fire := actor.get_children().back() as Label
	check(water.text == "Water Lv.4" and fire.text == "Fire Lv.2", "mixed Cast captions remain individual in creation order")
	check(is_equal_approx(water.position.x, water_x), "first caption stays at its anchor when room exists")
	_check_family(actor, water, fire, "center captions")
	check(water.get_theme_font_size("font_size") == 16 and water.get_theme_constant("outline_size") == 3, "Cast font/outline unchanged")
	actor.feedback.show_dot_damage(&"fire", 5.0)
	var dot := actor.get_children().back() as Label
	check(dot.global_position.is_equal_approx(_legacy_label_position(actor, dot, Vector2(-8, -154))), "DoT position unchanged")
	check(dot.text == "5" and dot.get_theme_font_size("font_size") == 12 and dot.get_theme_constant("outline_size") == 2, "DoT text, 12px font and outline unchanged")
	check(is_equal_approx(first.position.x, first_x) and is_equal_approx(water.position.x, water_x), "independent families and DoT do not regroup each other")
	var labels: Array[Label] = [first, second, water, fire, dot]
	var center_positions := [first.position, second.position, water.position, fire.position]
	actor.position.x += 10.0
	await process_frame
	await process_frame
	for index in range(4):
		check(is_equal_approx(labels[index].position.x, Vector2(center_positions[index]).x), "in-margin owner translation leaves relative label x unchanged")
	# A newer batch at the same owner position must not reposition older in-margin groups.
	actor.feedback.show_damage(&"fire", 13.0)
	var newer_first := actor.get_children().back() as Label
	actor.feedback.show_damage(&"water", 10.0)
	var newer_second := actor.get_children().back() as Label
	actor.feedback.show_cast_level(&"water", 4)
	var newer_water := actor.get_children().back() as Label
	actor.feedback.show_cast_level(&"fire", 2)
	var newer_fire := actor.get_children().back() as Label
	labels.append_array([newer_first, newer_second, newer_water, newer_fire])
	for index in range(4):
		check(is_equal_approx(labels[index].position.x, Vector2(center_positions[index]).x), "newer batch alone does not reposition older in-margin labels")
	for edge_x in [0.0, 1280.0]:
		await process_frame
		await process_frame
		actor.position.x = edge_x
		actor.feedback.show_damage(&"fire", 13.0)
		var edge_first := actor.get_children().back() as Label
		actor.feedback.show_damage(&"water", 10.0)
		var edge_second := actor.get_children().back() as Label
		_check_family(actor, edge_first, edge_second, "viewport-edge damage")
		actor.feedback.show_cast_level(&"water", 4)
		var edge_water := actor.get_children().back() as Label
		actor.feedback.show_cast_level(&"fire", 2)
		var edge_fire := actor.get_children().back() as Label
		_check_family(actor, edge_water, edge_fire, "viewport-edge captions")
		labels.append_array([edge_first, edge_second, edge_water, edge_fire])
		var pixel_delta := -20.0 if edge_x == 0.0 else 20.0
		var inverse := actor.get_viewport().get_canvas_transform().affine_inverse()
		actor.global_position += inverse * Vector2(pixel_delta, 0.0) - inverse.origin
		await process_frame
		await process_frame
		var visible := actor.get_viewport().get_visible_rect()
		for family in [[edge_first, edge_second, "damage"], [edge_water, edge_fire, "captions"]]:
			var a := actor.feedback._label_screen_bounds(family[0])
			var b := actor.feedback._label_screen_bounds(family[1])
			var inside_margin := a.position.x >= visible.position.x + 11.99 and b.end.x <= visible.end.x - 11.99
			var inside_viewport := a.position.x >= visible.position.x - 0.01 and b.end.x <= visible.end.x + 0.01
			print("C6_EDGE_MOTION ", JSON.stringify({"edge": edge_x, "movement_viewport_px": pixel_delta, "family": family[2],
				"first_left": a.position.x, "first_right": a.end.x, "second_left": b.position.x, "second_right": b.end.x,
				"viewport_left": visible.position.x, "viewport_right": visible.end.x, "inside_12px_margin": inside_margin, "not_clipped": inside_viewport}))
			check(inside_margin, "moving owner keeps same-frame family within 12px margin")
			check(inside_viewport, "moving owner keeps same-frame family at least unclipped")
	# Paused processing must not correct positions, but live groups survive to resume.
	var last_first: Label = labels[-4]
	var last_second: Label = labels[-3]
	var paused_x := last_first.position.x
	paused = true
	actor.position.x += 20.0
	actor.feedback._process(0.0)
	check(is_equal_approx(last_first.position.x, paused_x), "pause does not translate labels")
	check(not actor.feedback._formed_label_groups.is_empty(), "pause retains needed live formed-group tracking")
	paused = false
	await process_frame
	await process_frame
	_check_family(actor, last_first, last_second, "resume clamps still-alive family")
	await create_timer(0.10).timeout
	check(is_instance_valid(first) and first.modulate.a < 1.0 and first.position.y < first_y, "existing damage upward/fade Tween still advances")
	check(is_instance_valid(dot) and dot.modulate.a < 1.0, "existing DoT Tween still advances")
	check(is_instance_valid(water) and is_equal_approx(water.modulate.a, 1.0), "Cast caption retains timer-only lifetime")
	var lifetime_refs: Array[WeakRef] = []
	for label in labels:
		lifetime_refs.append(weakref(label))
	await create_timer(2.10).timeout
	for reference in lifetime_refs:
		check(reference.get_ref() == null, "each original 2s lifetime cleans its label")
	await process_frame
	await process_frame
	check(actor.feedback._formed_label_groups.is_empty(), "expired families are pruned, not resurrected")
	actor.feedback.show_cast_level(&"water", 1)
	var freed := actor.get_children().back() as Label
	freed.free()
	actor.feedback.show_cast_level(&"fire", 2)
	var survivor := actor.get_children().back() as Label
	check(survivor.global_position.is_equal_approx(_legacy_label_position(actor, survivor, Vector2(-48, -118))), "freed same-frame sibling is pruned without stale-node access")
	var single_x := survivor.position.x
	actor.position.x += 20.0
	actor.feedback._process(0.0)
	check(is_equal_approx(survivor.position.x, single_x), "independent single label gets no lifetime edge correction")
	check(actor.feedback._formed_label_groups.is_empty(), "independent singles are never enrolled as formed groups")
	survivor.free()
	paused = true
	actor.feedback._process(0.0)
	check(actor.feedback._label_batches.is_empty(), "pause drops regrouping metadata without repositioning older labels")
	paused = false
	actor.feedback._exit_tree()
	check(actor.feedback._label_batches.is_empty(), "teardown leaves no stale frame-label bookkeeping")
	check(actor.feedback._formed_label_groups.is_empty(), "teardown clears formed-family tracking")
	root.size = saved_size
