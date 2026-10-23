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
	print("Impact feedback: %d checks, %d failures" % [checks, failures.size()])
	quit(0 if failures.is_empty() else 1)
