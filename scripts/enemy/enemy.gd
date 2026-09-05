extends "res://scripts/entities/entity.gd"

signal enemy_health_changed(current_value: float, maximum_value: float)
signal outcome_published(outcome)

const CombatOutcomeResource = preload("res://scripts/combat/combat_outcome.gd")
const VFX_ROOT := "res://assets/prototype/vfx"
const IDLE_CELL_SIZE := Vector2(32.0, 96.0)
const IDLE_FRAME_COUNT := 1
const IDLE_FPS := 1.0
const VFX_FRAME_COUNTS := {
	"fire": 10,
	"water": 11,
	"ice": 13,
}
const ENDURANCE_ICONS := {
	&"fire": preload("res://assets/prototype/ui/elemental_endurance/endurance_fire.png"),
	&"water": preload("res://assets/prototype/ui/elemental_endurance/endurance_water.png"),
	&"air": preload("res://assets/prototype/ui/elemental_endurance/endurance_air.png"),
	&"earth": preload("res://assets/prototype/ui/elemental_endurance/endurance_earth.png"),
}
const VIEWPORT_MARGIN := 12.0
const HEALTH_READOUT_OFFSET := Vector2(-70.0, -88.0)
const STATUS_READOUT_OFFSET := Vector2(-130.0, -176.0)

@onready var body_visual: Sprite2D = $BodyVisual
@onready var health_label: Label = $HealthLabel
@onready var status_display: HBoxContainer = $StatusDisplay
@onready var vfx: AnimatedSprite2D = $VFX
@onready var hit_reaction_audio: AudioStreamPlayer = $HitReactionAudio

@export var encounter_id: StringName = &"practice_target"
@export var refills_at_zero := true
@export var is_final_enemy := false

var _config: Dictionary = {}
var _idle_time := 0.0
var _flinch_tween: Tween
var _vfx_cache: Dictionary = {}
var _status_badges: Dictionary = {}
var _defeated := false
var _stage_active := true


func configure(config: Dictionary) -> void:
	_config = config
	_defeated = false
	_build_status_badges()
	health.health_changed.connect(_on_health_changed)
	status_controller.status_changed.connect(_on_status_changed)
	status_controller.effect_applied.connect(_on_effect_applied)
	hit_reaction.reaction_started.connect(_on_reaction_started)
	configure_entity(
		float(config["enemy"]["max_health"]),
		int(config["enemy"]["defensive_level"]),
		refills_at_zero,
		config["hit_reaction"],
		config
	)
	status_controller.set_elemental_endurance_enabled(is_final_enemy)
	_on_status_changed(status_controller.get_snapshot())
	_publish_outcome(&"encounter_activated", {"encounter_id": encounter_id, "final_enemy": is_final_enemy})


func apply_runtime_tuning() -> void:
	health.set_maximum(float(_config["enemy"]["max_health"]))
	hit_reaction.configure(_config["hit_reaction"])
	apply_feedback_runtime_tuning(float(_config["ui"]["cast_feedback_duration"]))


func set_stage_active(active: bool) -> void:
	_stage_active = active
	set_process(active)
	set_collision_layer_value(2, active and not _defeated)
	set_collision_mask_value(1, false)


func receive_health_event(event: HealthEvent) -> HealthResult:
	if not _stage_active:
		return HealthResult.new()
	return super.receive_health_event(event)


func receive_health_result(result: HealthResult) -> void:
	if result != null and result.event != null and result.event.target == self and result.outcome == HealthResult.Outcome.APPLIED:
		if result.event.is_direct_damage():
			feedback.show_damage(result.event.school, -result.health_delta)
		elif result.event.delivery == HealthEvent.Delivery.DOT_TICK:
			feedback.show_dot_damage(result.event.school, -result.health_delta)
	if not _stage_active or result == null or result.event == null or result.event.target != self or not result.zero_reached or _defeated:
		return
	_publish_outcome(&"enemy_zero_health", {"encounter_id": encounter_id, "final_enemy": is_final_enemy})
	if refills_at_zero:
		_publish_outcome(&"practice_target_refilled", {"encounter_id": encounter_id})
		return
	_defeated = true
	if is_final_enemy:
		set_collision_layer_value(2, false)
		_publish_outcome(&"final_enemy_defeated", {"encounter_id": encounter_id})
	else:
		_publish_outcome(&"enemy_defeated", {"encounter_id": encounter_id})


func _process(delta: float) -> void:
	_idle_time += delta
	var frame := int(floor(_idle_time * IDLE_FPS)) % IDLE_FRAME_COUNT
	body_visual.region_rect = Rect2(Vector2(frame, 0) * IDLE_CELL_SIZE, IDLE_CELL_SIZE)
	_clamp_target_readouts()


func _clamp_target_readouts() -> void:
	_place_readout_in_viewport(health_label, HEALTH_READOUT_OFFSET)
	_place_readout_in_viewport(status_display, STATUS_READOUT_OFFSET)


func _place_readout_in_viewport(readout: Control, local_offset: Vector2) -> void:
	var viewport := get_viewport()
	var canvas_transform: Transform2D = viewport.get_canvas_transform()
	var inverse_canvas_transform: Transform2D = canvas_transform.affine_inverse()
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var readout_size: Vector2 = readout.get_combined_minimum_size()
	var screen_position: Vector2 = canvas_transform * (global_position + local_offset)
	screen_position.x = clampf(screen_position.x, VIEWPORT_MARGIN, viewport_size.x - readout_size.x - VIEWPORT_MARGIN)
	screen_position.y = clampf(screen_position.y, VIEWPORT_MARGIN, viewport_size.y - readout_size.y - VIEWPORT_MARGIN)
	readout.global_position = inverse_canvas_transform * screen_position


func _on_health_changed(current_value: float, maximum_value: float) -> void:
	health_label.text = "HP %.0f / %.0f" % [current_value, maximum_value]
	enemy_health_changed.emit(current_value, maximum_value)


func _on_reaction_started(level: int, direction: Vector2, distance: float, duration: float) -> void:
	if level > 0:
		hit_reaction_audio.play()
	if _flinch_tween != null and _flinch_tween.is_valid():
		_flinch_tween.kill()
	body_visual.position = Vector2.ZERO
	var offset := direction.normalized() * distance
	_flinch_tween = create_tween()
	_flinch_tween.tween_property(body_visual, "position", offset, duration * 0.4)
	_flinch_tween.tween_property(body_visual, "position", Vector2.ZERO, duration * 0.6)


func _on_status_changed(snapshot: Dictionary) -> void:
	var dot_stacks := int(snapshot["dot_stacks"])
	var water_status := StringName(snapshot["water_status"])
	_set_status_badge(&"fire", dot_stacks > 0, "DOT\nx%d" % dot_stacks)
	if water_status != &"":
		var remaining := float(snapshot["water_remaining"])
		var water_label := String(water_status).to_upper()
		if water_status == &"slow":
			water_label += " %.0f%%" % [float(snapshot["slow_percent"]) * 100.0]
		_set_status_badge(&"water", true, "%s\n%.1fs" % [water_label, remaining])
	else:
		_set_status_badge(&"water", false, "")
	var earth_remaining := float(snapshot["earth_remaining"])
	if earth_remaining > 0.0:
		_set_status_badge(
			&"earth",
			true,
			"SLOW %.0f%%\n%.1fs" % [
				float(snapshot["earth_slow_percent"]) * 100.0,
				earth_remaining,
			]
		)
	else:
		_set_status_badge(&"earth", false, "")
	var endurance_school := StringName(snapshot.get("endurance_school", &""))
	var endurance_percent := int(snapshot.get("endurance_percent", 100))
	_set_status_badge(&"endurance", endurance_school != &"" and endurance_percent < 100, "%d%%" % endurance_percent)
	if endurance_school != &"" and _status_badges.has(&"endurance"):
		var endurance_badge: Dictionary = _status_badges[&"endurance"]
		(endurance_badge["panel"] as PanelContainer).modulate = Color.WHITE
		(endurance_badge["icon"] as TextureRect).texture = ENDURANCE_ICONS[endurance_school]
	body_visual.self_modulate = Color("6cb6ff") if bool(snapshot["frozen"]) else Color.WHITE


func _build_status_badges() -> void:
	if not _status_badges.is_empty():
		return
	_create_status_badge(&"fire", Color("8f211d"))
	_create_status_badge(&"water", Color("185d9b"))
	_create_status_badge(&"earth", Color("6f5425"))
	_create_status_badge(&"endurance", Color.WHITE)


func _school_color(school: StringName) -> Color:
	match school:
		&"fire": return Color("ff493d")
		&"water": return Color("3a96ff")
		&"air": return Color("f4f6ff")
		&"earth": return Color("8b5a2b")
	return Color.WHITE


func _create_status_badge(key: StringName, color: Color) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(48.0, 48.0) if key == &"endurance" else Vector2(64.0, 48.0)
	panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT if key == &"endurance" else color
	if key != &"endurance":
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = color.lightened(0.35)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	panel.add_theme_stylebox_override("panel", style)
	status_display.add_child(panel)
	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.visible = key == &"endurance"
	panel.add_child(icon)

	var label := Label.new()
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if key == &"endurance":
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.add_theme_font_size_override("font_size", 12)
	panel.add_child(label)
	_status_badges[key] = {
		"panel": panel,
		"label": label,
		"icon": icon,
	}


func _set_status_badge(key: StringName, is_visible: bool, text: String) -> void:
	if not _status_badges.has(key):
		return
	var badge: Dictionary = _status_badges[key]
	var panel: PanelContainer = badge["panel"]
	var label: Label = badge["label"]
	panel.visible = is_visible
	label.text = text


func _on_effect_applied(effect_type: StringName, payload: Dictionary) -> void:
	if effect_type == &"fire_dot":
		_play_one_shot_vfx(&"fire", float(_config["fire"]["vfx_fps"]), 1.0)
	elif effect_type == &"water_status":
		var radius := float(payload.get("radius", _config["water"]["base_radius"]))
		_play_water_status_vfx(StringName(payload["status"]), radius)


func _play_water_status_vfx(status: StringName, radius: float) -> void:
	var fps := float(_config["water"]["vfx_fps"])
	_play_vfx(&"water", fps, maxf(radius / 64.0, 0.5))
	await vfx.animation_finished
	if status == &"frozen" and vfx.animation == &"water":
		_play_vfx(&"ice", fps, maxf(radius / 64.0, 0.5))
		await vfx.animation_finished
	if vfx.animation == &"water" or vfx.animation == &"ice":
		vfx.visible = false


func _play_one_shot_vfx(family: StringName, fps: float, effect_scale: float) -> void:
	_play_vfx(family, fps, effect_scale)
	await vfx.animation_finished
	if vfx.animation == family:
		vfx.visible = false


func _play_vfx(family: StringName, fps: float, effect_scale: float) -> void:
	var frames: SpriteFrames = _vfx_cache.get(family)
	if frames == null:
		frames = _build_vfx_frames(family, fps)
		_vfx_cache[family] = frames
	vfx.sprite_frames = frames
	vfx.scale = Vector2.ONE * effect_scale
	vfx.visible = true
	vfx.play(family)


func _build_vfx_frames(family: StringName, fps: float) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	frames.add_animation(family)
	frames.set_animation_loop(family, false)
	frames.set_animation_speed(family, fps)
	var count: int = VFX_FRAME_COUNTS[String(family)]
	for index in range(1, count + 1):
		var path := "%s/%s/%s%d.png" % [VFX_ROOT, family, family, index]
		frames.add_frame(family, load(path))
	return frames


func _publish_outcome(kind: StringName, facts: Dictionary = {}) -> void:
	outcome_published.emit(CombatOutcomeResource.create(kind, facts))
