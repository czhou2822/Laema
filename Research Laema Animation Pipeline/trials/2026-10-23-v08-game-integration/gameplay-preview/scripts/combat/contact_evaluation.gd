extends Node
## Scene-local physics barrier. Actors keep their clocks, geometry and hit records;
## all clocks reach the same sample before any contact resolves.

var _actors: Array[WeakRef] = []


static func register(actor: Node) -> void:
	var scene: Node = actor.get_tree().current_scene
	if scene == null:
		scene = actor
		while scene.get_parent() != actor.get_tree().root:
			scene = scene.get_parent()
	var evaluator := scene.get_node_or_null("ContactEvaluation")
	if evaluator == null:
		evaluator = load("res://scripts/combat/contact_evaluation.gd").new()
		evaluator.name = "ContactEvaluation"
		evaluator.process_physics_priority = 2
		scene.add_child(evaluator)
	evaluator.call("_register_actor", actor)


func _register_actor(actor: Node) -> void:
	for reference in _actors:
		if reference.get_ref() == actor:
			return
	_actors.append(weakref(actor))


func _physics_process(delta: float) -> void:
	var actors: Array[Node] = []
	for index in range(_actors.size() - 1, -1, -1):
		var actor: Node = _actors[index].get_ref()
		if not is_instance_valid(actor):
			_actors.remove_at(index)
		elif actor.can_process() and bool(actor.call("contact_evaluation_enabled")):
			actors.append(actor)
	for actor in actors:
		actor.call("begin_contact_frame")
	var remaining := delta
	_evaluate(actors, 0.0)
	while remaining > 0.0000001:
		# Bound interpolation gaps, also visiting authored markers/geometry keys.
		var step := minf(remaining, 1.0 / 120.0)
		for actor in actors:
			if is_instance_valid(actor) and actor.can_process():
				step = minf(step, float(actor.call("contact_step_limit", step)))
		_evaluate(actors, step)
		remaining = maxf(remaining - step, 0.0)
	for actor in actors:
		if is_instance_valid(actor) and actor.can_process():
			actor.call("finish_contact_frame", delta)


func _evaluate(actors: Array[Node], step: float) -> void:
	for actor in actors:
		if is_instance_valid(actor) and actor.can_process():
			actor.call("advance_contact_clock", step)
	var events: Array[HealthEvent] = []
	for actor in actors:
		if is_instance_valid(actor) and actor.can_process():
			events.append_array(actor.call("collect_melee_contacts"))
	HealthResolver.resolve_melee_contacts(events)
	for actor in actors:
		if is_instance_valid(actor) and actor.can_process():
			actor.call("finish_contact_sample")
