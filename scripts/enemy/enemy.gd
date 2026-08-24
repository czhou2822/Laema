extends "res://scripts/entities/entity.gd"

signal enemy_health_changed(current_value: float, maximum_value: float)

const VFX_ROOT := "res://assets/prototype/vfx"
const IDLE_CELL_SIZE := Vector2(64.0, 64.0)
const IDLE_FRAME_COUNT := 12
const IDLE_FPS := 8.0
const VFX_FRAME_COUNTS := {
	"fire": 10,
	"water": 11,
	"ice": 13,
}

@onready var body_visual: Sprite2D = $BodyVisual
@onready var health_label: Label = $HealthLabel
@onready var status_display: HBoxContainer = $StatusDisplay
@onready var vfx: AnimatedSprite2D = $VFX

var _config: Dictionary = {}
var _idle_time := 0.0
var _flinch_tween: Tween
var _vfx_cache: Dictionary = {}
var _status_badges: Dictionary = {}


func configure(config: Dictionary) -> void:
	_config = config
	_build_status_badges()
	health.health_changed.connect(_on_health_changed)
	status_controller.status_changed.connect(_on_status_changed)
	status_controller.effect_applied.connect(_on_effect_applied)
	hit_reaction.reaction_started.connect(_on_reaction_started)
	configure_entity(
		float(config["enemy"]["max_health"]),
		int(config["enemy"]["defensive_level"]),
		true,
		config["hit_reaction"],
		config
	)
	_on_status_changed(status_controller.get_snapshot())


func apply_runtime_tuning() -> void:
	health.set_maximum(float(_config["enemy"]["max_health"]))
	hit_reaction.configure(_config["hit_reaction"])


func _process(delta: float) -> void:
	_idle_time += delta
	var frame := int(floor(_idle_time * IDLE_FPS)) % IDLE_FRAME_COUNT
	body_visual.region_rect = Rect2(Vector2(frame, 0) * IDLE_CELL_SIZE, IDLE_CELL_SIZE)


func _on_health_changed(current_value: float, maximum_value: float) -> void:
	health_label.text = "HP %.0f / %.0f" % [current_value, maximum_value]
	enemy_health_changed.emit(current_value, maximum_value)


func _on_reaction_started(_level: int, direction: Vector2, distance: float, duration: float) -> void:
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
	body_visual.self_modulate = Color("6cb6ff") if bool(snapshot["frozen"]) else Color.WHITE


func _build_status_badges() -> void:
	if not _status_badges.is_empty():
		return
	_create_status_badge(&"fire", Color("8f211d"))
	_create_status_badge(&"water", Color("185d9b"))
	_create_status_badge(&"earth", Color("6f5425"))


func _create_status_badge(key: StringName, color: Color) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(64.0, 48.0)
	panel.visible = false
	var style := StyleBoxFlat.new()
	style.bg_color = color
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

	var label := Label.new()
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	_status_badges[key] = {
		"panel": panel,
		"label": label,
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
