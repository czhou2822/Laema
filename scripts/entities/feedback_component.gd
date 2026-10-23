class_name FeedbackComponent
extends Node

signal impact_confirmed(cue: Dictionary)

const IMPACT_SECONDS := 0.12
var _impact_options: Dictionary = {}
var _impact_pending: Dictionary = {}
var _impact_seen: Dictionary = {}
var _impact_entries: Array[Dictionary] = []
var _impact_layer: CanvasLayer

var _owner_entity: Entity
var _duration := 2.0
const VIEWPORT_MARGIN := 12.0


func configure(owner_entity: Entity, duration: float, ui: Dictionary = {}) -> void:
	_owner_entity = owner_entity
	_duration = duration
	_impact_options = ui
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)


func apply_runtime_tuning(duration: float) -> void:
	_duration = duration


func show_cast_level(school: StringName, level: int) -> void:
	if _owner_entity == null or level < 1:
		return
	var label := Label.new()
	label.text = "%s Lv.%d" % [String(school).capitalize(), level]
	var local_offset := Vector2(-48.0, -118.0)
	label.position = local_offset
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", _school_color(school))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	_owner_entity.add_child(label)
	_clamp_label_to_viewport(label, local_offset)
	var entry_duration := _duration
	get_tree().create_timer(entry_duration).timeout.connect(label.queue_free)


func show_damage(school: StringName, amount: float) -> void:
	if _owner_entity == null:
		return
	var label := Label.new()
	label.text = "%.0f" % amount
	var local_offset := Vector2(-10.0, -186.0)
	label.position = local_offset
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", _school_color(school))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	_owner_entity.add_child(label)
	_clamp_label_to_viewport(label, local_offset)
	var tween := _owner_entity.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 20.0, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, _duration)
	tween.chain().tween_callback(label.queue_free)


func show_dot_damage(school: StringName, amount: float) -> void:
	if _owner_entity == null:
		return
	var label := Label.new()
	label.text = "%.0f" % amount
	var local_offset := Vector2(-8.0, -154.0)
	label.position = local_offset
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", _school_color(school))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	_owner_entity.add_child(label)
	_clamp_label_to_viewport(label, local_offset)
	var tween := _owner_entity.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 30.0, _duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, _duration)
	tween.chain().tween_callback(label.queue_free)


func _clamp_label_to_viewport(label: Label, local_offset: Vector2) -> void:
	var viewport := _owner_entity.get_viewport()
	var canvas_transform: Transform2D = viewport.get_canvas_transform()
	var inverse_canvas_transform: Transform2D = canvas_transform.affine_inverse()
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var label_size: Vector2 = label.get_combined_minimum_size()
	var screen_position: Vector2 = canvas_transform * (_owner_entity.global_position + local_offset)
	screen_position.x = clampf(screen_position.x, VIEWPORT_MARGIN, viewport_size.x - label_size.x - VIEWPORT_MARGIN)
	screen_position.y = clampf(screen_position.y, VIEWPORT_MARGIN, viewport_size.y - label_size.y - VIEWPORT_MARGIN)
	label.global_position = inverse_canvas_transform * screen_position


func _school_color(school: StringName) -> Color:
	match school:
		&"fire": return Color("ff493d")
		&"water": return Color("3a96ff")
		&"air": return Color("f4f6ff")
		&"earth": return Color("8b5a2b")
	return Color.WHITE

# The resolver calls this only on the receiver, never on the instigator.
static func qualifies_impact(result: HealthResult) -> bool:
	return result != null and result.event != null \
		and result.outcome == HealthResult.Outcome.APPLIED \
		and result.event.is_direct_damage() and result.health_delta < 0.0 \
		and result.event.contact_point.is_finite()


func accept_impact(result: HealthResult) -> void:
	if not qualifies_impact(result) or not is_instance_valid(_owner_entity):
		return
	if result.event.target != _owner_entity:
		return
	if not bool(_impact_options.get("impact_contact_enabled", false)) and not bool(_impact_options.get("impact_camera_enabled", false)):
		return
	if get_tree().paused:
		return
	var event := result.event
	var source := event.instigator.get_instance_id() if is_instance_valid(event.instigator) else 0
	# Zero-ID callers have no shared action identity; do not merge unrelated hits.
	var action := event.source_action_id if event.source_action_id != 0 else event.get_instance_id()
	var key := "%d/%d/%d" % [source, action, _owner_entity.get_instance_id()]
	if _impact_seen.has(key):
		return
	var level := result.final_reaction_level if _owner_entity.uses_combat_hit_reaction() else 0
	if _impact_pending.has(key):
		_impact_pending[key]["level"] = maxi(int(_impact_pending[key]["level"]), level)
		return
	_impact_pending[key] = {"point": event.contact_point, "direction": event.contact_direction,
		"school": event.school, "level": level}
	# Both mixed-Cast layers finish before cosmetic dispatch; no combat state changes.
	call_deferred("_flush_impacts")


func _flush_impacts() -> void:
	var pending := _impact_pending
	_impact_pending = {}
	if not is_inside_tree() or get_tree().paused:
		return
	for key in pending:
		_impact_seen[key] = true
		var cue: Dictionary = pending[key]
		if bool(_impact_options.get("impact_contact_enabled", false)):
			_spawn_contact(cue)
		if bool(_impact_options.get("impact_camera_enabled", false)):
			impact_confirmed.emit(cue)


func _spawn_contact(cue: Dictionary) -> void:
	if _impact_layer == null:
		_impact_layer = CanvasLayer.new()
		_impact_layer.layer = 50
		add_child(_impact_layer)
	var accent := Node2D.new()
	_impact_layer.add_child(accent)
	var weight: bool = _impact_options.get("impact_treatment", "precise") == "weight"
	var strong := int(cue["level"]) >= 3
	var footprint := (38.0 if strong else 28.0) if weight else (24.0 if strong else 20.0)
	var duration := 0.11 if weight else (0.10 if strong else 0.09)
	var transform := _owner_entity.get_viewport().get_canvas_transform()
	var direction: Vector2 = cue["direction"]
	var screen_direction := (transform * direction - transform.origin).normalized()
	accent.rotation = screen_direction.angle() if not screen_direction.is_zero_approx() else 0.0
	var polygons := contact_polygons(weight)
	for points in polygons:
		var shape := Polygon2D.new()
		var scaled := PackedVector2Array()
		for point in points:
			scaled.append(point * footprint)
		shape.polygon = scaled
		shape.color = _school_color(StringName(cue["school"]))
		if not weight:
			# A concentrated white inner highlight, not a brighter whole-body flash.
			shape.vertex_colors = PackedColorArray([Color.WHITE, shape.color, shape.color, shape.color])
			shape.color = Color.WHITE
		accent.add_child(shape)
	if weight:
		# Fixed viewport pixels before the existing shared expansion/rotation/fade.
		var edge := Polygon2D.new()
		edge.name = "WeightEdge"
		edge.polygon = PackedVector2Array([Vector2(-4, -3), Vector2(4, -3), Vector2(4, 3), Vector2(-4, 3)])
		edge.color = Color.BLACK
		accent.add_child(edge)
		var center := Polygon2D.new()
		center.name = "WeightCenter"
		center.polygon = PackedVector2Array([Vector2(-3, -2), Vector2(3, -2), Vector2(3, 2), Vector2(-3, 2)])
		center.color = Color.WHITE
		accent.add_child(center)
	accent.position = transform * Vector2(cue["point"])
	accent.scale = Vector2.ONE * (0.65 if weight else 1.0)
	_impact_entries.append({"node": accent, "point": cue["point"], "started": Time.get_ticks_msec(),
		"duration": duration, "weight": weight})


static func contact_polygons(weight: bool) -> Array[PackedVector2Array]:
	# Coordinates fit a radius-0.5 disk: complete width AND height remain capped
	# by footprint even after arbitrary direction rotation and expansion to scale 1.
	if weight:
		return [
			PackedVector2Array([Vector2(-0.12, -0.09), Vector2(0.50, 0.0), Vector2(0.35, 0.20), Vector2(-0.15, 0.10)]),
			PackedVector2Array([Vector2(-0.42, -0.20), Vector2(-0.38, -0.32), Vector2(-0.25, -0.24)]),
			PackedVector2Array([Vector2(-0.24, 0.29), Vector2(-0.30, 0.38), Vector2(-0.12, 0.31)]),
		]
	return [
		PackedVector2Array([Vector2(0.10, -0.05), Vector2(0.40, -0.30), Vector2(0.48, -0.12), Vector2(0.15, 0.05)]),
		PackedVector2Array([Vector2(-0.10, 0.05), Vector2(-0.40, 0.30), Vector2(-0.48, 0.12), Vector2(-0.15, -0.05)]),
	]


func _process(_delta: float) -> void:
	if get_tree().paused:
		clear_impact_feedback()
		return
	for index in range(_impact_entries.size() - 1, -1, -1):
		var entry: Dictionary = _impact_entries[index]
		var age := float(Time.get_ticks_msec() - int(entry["started"])) / 1000.0
		var accent: Node2D = entry["node"]
		var duration := float(entry["duration"])
		if age >= duration or not bool(_impact_options.get("impact_contact_enabled", false)):
			accent.free()
			_impact_entries.remove_at(index)
		else:
			accent.position = _owner_entity.get_viewport().get_canvas_transform() * Vector2(entry["point"])
			accent.modulate.a = 1.0 - age / duration
			if bool(entry["weight"]):
				accent.scale = Vector2.ONE * lerpf(0.65, 1.0, minf(age / 0.03, 1.0))


func clear_impact_feedback(clear_history: bool = false) -> void:
	_impact_pending.clear()
	for entry in _impact_entries:
		if is_instance_valid(entry["node"]):
			entry["node"].free()
	_impact_entries.clear()
	if clear_history:
		_impact_seen.clear()


func _exit_tree() -> void:
	clear_impact_feedback(true)
