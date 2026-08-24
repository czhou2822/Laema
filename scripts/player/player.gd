extends "res://scripts/entities/entity.gd"

signal heat_changed(value: float, level: int, speed_multiplier: float)
signal health_changed(current_value: float, maximum_value: float)
signal combo_sequence_changed(tokens: Array)
signal combo_completed(tokens: Array)
signal combo_reset
signal active_school_changed(school: StringName)
signal defence_status_changed(label: String, current_guard: float, maximum_guard: float)

const FireResolver = preload("res://scripts/combat/fire_resolver.gd")
const WaterResolver = preload("res://scripts/combat/water_resolver.gd")
const AirResolver = preload("res://scripts/combat/air_resolver.gd")
const EarthResolver = preload("res://scripts/combat/earth_resolver.gd")
const IDLE_TEXTURE: Texture2D = preload("res://assets/prototype/player/Shinobi_Idle.png")
const WALK_TEXTURE: Texture2D = preload("res://assets/prototype/player/Shinobi_Walk.png")
const ATTACK_TEXTURE: Texture2D = preload("res://assets/prototype/player/Shinobi_Attack_1.png")
const ATTACK_2_TEXTURE: Texture2D = preload("res://assets/prototype/player/Shinobi_Attack_2.png")
const ATTACK_3_TEXTURE: Texture2D = preload("res://assets/prototype/player/Shinobi_Attack_3.png")
const FIGHTER_IDLE: Texture2D = preload("res://assets/prototype/player/Fighter_Idle.png")
const FIGHTER_WALK: Texture2D = preload("res://assets/prototype/player/Fighter_Walk.png")
const FIGHTER_ATTACK_1: Texture2D = preload("res://assets/prototype/player/Fighter_Attack_1.png")
const FIGHTER_ATTACK_2: Texture2D = preload("res://assets/prototype/player/Fighter_Attack_2.png")
const FIGHTER_ATTACK_3: Texture2D = preload("res://assets/prototype/player/Fighter_Attack_3.png")
const SABER_IDLE: Texture2D = preload("res://assets/prototype/player/Saber_Idle.png")
const SABER_WALK: Texture2D = preload("res://assets/prototype/player/Saber_Walk.png")
const SABER_ATTACK_1: Texture2D = preload("res://assets/prototype/player/Saber_Attack_1.png")
const SABER_ATTACK_2: Texture2D = preload("res://assets/prototype/player/Saber_Attack_2.png")
const SABER_ATTACK_3: Texture2D = preload("res://assets/prototype/player/Saber_Attack_3.png")
const SAMURAI_IDLE: Texture2D = preload("res://assets/prototype/player/Samurai_Idle.png")
const SAMURAI_WALK: Texture2D = preload("res://assets/prototype/player/Samurai_Walk.png")
const FIRE_FINISHER_VFX: Texture2D = preload("res://assets/prototype/vfx/fire/fire1.png")
const WATER_FINISHER_VFX: Texture2D = preload("res://assets/prototype/vfx/water/water1.png")

const CELL_SIZE := Vector2(128.0, 128.0)
const IDLE_FRAMES := 6
const WALK_FRAMES := 8
const WALK_START_FRAME := 2
const ATTACK_FRAMES := 5
const ATTACK_2_FRAMES := 3
const ATTACK_3_FRAMES := 4
const ATTACK_HITBOX_DEBUG_WINDOW := 0.14
const ATTACK_HITBOX_DEBUG_FILL := Color(1.0, 0.78, 0.12, 0.24)
const ATTACK_HITBOX_DEBUG_OUTLINE := Color(1.0, 0.9, 0.35, 0.95)
const SCHOOL_COLORS := {
	&"fire": Color("ff3b30"),
	&"water": Color("248cff"),
	&"air": Color("ffffff"),
	&"earth": Color("8b5a2b"),
}
const SCHOOL_TINTS := {
	&"fire": Color("ffd0cc"),
	&"water": Color("c9ddff"),
	&"air": Color("f4f6ff"),
	&"earth": Color("d6b38a"),
}

@onready var sprite: Sprite2D = $Sprite
@onready var movement = $Movement
@onready var combat = $Combat
@onready var input_combo = $InputCombo
@onready var heat = $Heat
@onready var defence: DefenceController = $Defence
@onready var guard_warning_audio: AudioStreamPlayer = $GuardWarningAudio
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_cast: ShapeCast2D = $AttackCast

var _config: Dictionary = {}
var _visual_time := 0.0
var _last_visual_mode := &""
var _visual_attack_direction := Vector2.RIGHT
var _visual_attack_kind := &""
var _visual_light_position := 0
var _attack_hitbox_debug_enabled := true
var _facing_left := false
var _sprite_rest_position := Vector2.ZERO
var _sprite_rest_scale := Vector2.ONE
var _sprite_rest_rotation := 0.0


func configure(config: Dictionary) -> void:
	_config = config
	_sprite_rest_position = sprite.position
	_sprite_rest_scale = sprite.scale
	_sprite_rest_rotation = sprite.rotation
	movement.facing_changed.connect(_on_facing_changed)
	combat.movement_lock_changed.connect(movement.set_movement_locked)
	combat.active_school_changed.connect(_on_active_school_changed)
	combat.attack_started.connect(_on_attack_started)
	combat.finisher_started.connect(_on_finisher_started)
	combat.defence_status_changed.connect(_on_defence_status_changed)
	defence.guard_warning.connect(_on_guard_warning)
	heat.heat_changed.connect(_on_heat_changed)
	health.health_changed.connect(_on_health_changed)
	input_combo.sequence_changed.connect(_on_combo_sequence_changed)
	input_combo.combo_completed.connect(_on_combo_completed)
	input_combo.combo_reset.connect(_on_combo_reset)
	status_controller.effect_state_changed.connect(_on_effect_state_changed)
	hit_reaction.reaction_started.connect(_on_hit_reaction_started)
	hit_reaction.reaction_ended.connect(_on_hit_reaction_ended)

	movement.configure(self, config["movement"])
	heat.configure(config["heat"])
	defence.configure(config["defence"])
	configure_entity(
		float(config["player"]["max_health"]),
		0,
		false,
		config["hit_reaction"],
		config,
		defence
	)
	combat.configure(
		config,
		self,
		animation_player,
		attack_cast,
		input_combo,
		heat,
		defence,
		FireResolver.new(),
		WaterResolver.new(),
		AirResolver.new(),
		EarthResolver.new()
	)
	_update_school_outline(combat.get_active_school())


func apply_runtime_tuning() -> void:
	movement.apply_runtime_tuning()
	combat.apply_runtime_tuning()
	heat.apply_runtime_tuning()
	health.set_maximum(float(_config["player"]["max_health"]))
	hit_reaction.configure(_config["hit_reaction"])
	defence.configure(_config["defence"])


func receive_health_result(result: HealthResult) -> void:
	combat.handle_outgoing_health_result(result)


func get_defensive_level() -> int:
	if combat != null and combat.is_defending():
		return defence.get_defensive_level()
	return 0


func set_attack_hitbox_debug_enabled(enabled: bool) -> void:
	_attack_hitbox_debug_enabled = enabled
	queue_redraw()


func is_attack_hitbox_debug_enabled() -> bool:
	return _attack_hitbox_debug_enabled


func _unhandled_input(event: InputEvent) -> void:
	if _config.is_empty():
		return
	combat.handle_input_event(event, _get_attack_direction())


func _process(delta: float) -> void:
	if _config.is_empty():
		return
	_visual_time += delta
	if combat.is_attack_playing():
		_update_attack_visual()
	elif not movement.get_motion().is_zero_approx():
		_update_locomotion_visual(&"walk", _get_walk_texture(combat.get_active_school()), _get_walk_frames(combat.get_active_school()), float(_config["movement"]["walk_fps"]))
	else:
		_update_locomotion_visual(&"idle", _get_idle_texture(combat.get_active_school()), IDLE_FRAMES, float(_config["movement"]["idle_fps"]))
	queue_redraw()


func _draw() -> void:
	if not _is_attack_hitbox_debug_visible():
		return
	var cast_shape := attack_cast.shape as CircleShape2D
	if cast_shape == null:
		return
	var start := attack_cast.position
	var direction := _visual_attack_direction.normalized()
	var end := start + direction * float(_config["combat"]["shape_reach"])
	var radius := cast_shape.radius
	var edge_offset := direction.orthogonal() * radius
	draw_line(start, end, ATTACK_HITBOX_DEBUG_FILL, radius * 2.0, true)
	draw_circle(start, radius, ATTACK_HITBOX_DEBUG_FILL)
	draw_circle(end, radius, ATTACK_HITBOX_DEBUG_FILL)
	draw_line(start + edge_offset, end + edge_offset, ATTACK_HITBOX_DEBUG_OUTLINE, 2.0, true)
	draw_line(start - edge_offset, end - edge_offset, ATTACK_HITBOX_DEBUG_OUTLINE, 2.0, true)
	draw_arc(start, radius, 0.0, TAU, 32, ATTACK_HITBOX_DEBUG_OUTLINE, 2.0, true)
	draw_arc(end, radius, 0.0, TAU, 32, ATTACK_HITBOX_DEBUG_OUTLINE, 2.0, true)


func _is_attack_hitbox_debug_visible() -> bool:
	if not _attack_hitbox_debug_enabled or not combat.is_attack_playing():
		return false
	var progress: float = combat.get_normalized_attack_progress()
	var hit_phase := float(_config["combat"]["hit_phase"])
	return progress >= hit_phase and progress <= minf(hit_phase + ATTACK_HITBOX_DEBUG_WINDOW, 1.0)


func _update_attack_visual() -> void:
	var school: StringName = combat.get_current_attack_school()
	var texture := _get_attack_texture(school, _visual_light_position)
	var frame_count := _get_attack_frames(school, _visual_light_position)
	var mode := &"attack_heavy"
	if _visual_attack_kind == &"light":
		mode = StringName("attack_x%d" % _visual_light_position)
	_set_visual_mode(mode, texture)
	_update_side_facing(_visual_attack_direction)
	_reset_sprite_motion()
	if _visual_attack_kind == &"light":
		sprite.position += _get_light_attack_anchor_offset(_visual_light_position)
	var exponent := float(_config[String(school)]["visual_motion_exponent"])
	var visual_progress := pow(combat.get_normalized_attack_progress(), exponent)
	var frame := mini(int(floor(visual_progress * frame_count)), frame_count - 1)
	_set_region(frame)


func _update_locomotion_visual(
	mode: StringName,
	texture: Texture2D,
	frame_count: int,
	fps: float
) -> void:
	_set_visual_mode(mode, texture)
	_reset_sprite_motion()
	_update_side_facing(movement.get_facing_direction())
	var start_frame := WALK_START_FRAME if mode == &"walk" else 0
	var frame := (int(floor(_visual_time * fps)) + start_frame) % frame_count
	_set_region(frame)


func _get_idle_texture(school: StringName) -> Texture2D:
	match school:
		&"fire": return FIGHTER_IDLE
		&"water": return SABER_IDLE
		&"earth": return SAMURAI_IDLE
	return IDLE_TEXTURE


func _get_walk_texture(school: StringName) -> Texture2D:
	match school:
		&"fire": return FIGHTER_WALK
		&"water": return SABER_WALK
		&"earth": return SAMURAI_WALK
	return WALK_TEXTURE


func _get_walk_frames(school: StringName) -> int:
	return 12 if school == &"water" else WALK_FRAMES


func _get_attack_texture(school: StringName, combo_position: int) -> Texture2D:
	var position := clampi(combo_position, 1, 3)
	if school == &"fire":
		return [FIGHTER_ATTACK_1, FIGHTER_ATTACK_2, FIGHTER_ATTACK_3][position - 1]
	if school == &"water":
		return [SABER_ATTACK_1, SABER_ATTACK_2, SABER_ATTACK_3][position - 1]
	return [ATTACK_TEXTURE, ATTACK_2_TEXTURE, ATTACK_3_TEXTURE][position - 1]


func _get_attack_frames(school: StringName, combo_position: int) -> int:
	var position := clampi(combo_position, 1, 3)
	if school == &"fire":
		return [4, 3, 4][position - 1]
	if school == &"water":
		return [6, 3, 4][position - 1]
	return [ATTACK_FRAMES, ATTACK_2_FRAMES, ATTACK_3_FRAMES][position - 1]


func _get_light_attack_anchor_offset(combo_position: int) -> Vector2:
	match combo_position:
		2:
			return Vector2(-1.0, 0.0)
		3:
			return Vector2(4.0, 0.0)
	return Vector2.ZERO


func _reset_sprite_motion() -> void:
	sprite.position = _sprite_rest_position
	sprite.scale = _sprite_rest_scale
	sprite.rotation = _sprite_rest_rotation


func _set_visual_mode(mode: StringName, texture: Texture2D) -> void:
	if mode == _last_visual_mode and sprite.texture == texture:
		return
	_last_visual_mode = mode
	_visual_time = 0.0
	sprite.texture = texture


func _set_region(frame: int) -> void:
	sprite.region_rect = Rect2(Vector2(frame, 0) * CELL_SIZE, CELL_SIZE)


func _update_side_facing(direction: Vector2) -> void:
	if not is_zero_approx(direction.x):
		_facing_left = direction.x < 0.0
	sprite.flip_h = _facing_left


func _on_facing_changed(direction: Vector2) -> void:
	_visual_time = 0.0
	_update_side_facing(direction)
	_visual_attack_direction = _get_attack_direction()
	_sync_attack_cast_direction()


func _get_attack_direction() -> Vector2:
	return Vector2.LEFT if _facing_left else Vector2.RIGHT


func _sync_attack_cast_direction() -> void:
	if _config.is_empty():
		return
	attack_cast.target_position = _get_attack_direction() * float(_config["combat"]["shape_reach"])


func _on_attack_started(kind: StringName, _school: StringName, direction: Vector2) -> void:
	_visual_attack_direction = direction
	_visual_attack_kind = kind
	_visual_light_position = clampi(input_combo.light_count(), 1, 5) if kind == &"light" else 0
	_visual_time = 0.0


func _on_finisher_started(school: StringName, direction: Vector2) -> void:
	if school != &"fire" and school != &"water":
		return
	var vfx := Sprite2D.new()
	vfx.texture = FIRE_FINISHER_VFX if school == &"fire" else WATER_FINISHER_VFX
	vfx.position = direction.normalized() * 28.0
	vfx.scale = Vector2(0.75, 0.75)
	add_child(vfx)
	get_tree().create_timer(0.25).timeout.connect(vfx.queue_free)


func _on_active_school_changed(school: StringName) -> void:
	_update_school_outline(school)
	active_school_changed.emit(school)


func _update_school_outline(school: StringName) -> void:
	var shader_material := sprite.material as ShaderMaterial
	shader_material.set_shader_parameter(&"outline_color", SCHOOL_COLORS[school])
	sprite.self_modulate = SCHOOL_TINTS[school]


func _on_heat_changed(value: float, level: int, speed_multiplier: float) -> void:
	heat_changed.emit(value, level, speed_multiplier)


func _on_health_changed(current_value: float, maximum_value: float) -> void:
	health_changed.emit(current_value, maximum_value)


func _on_combo_sequence_changed(tokens: Array) -> void:
	combo_sequence_changed.emit(tokens)


func _on_combo_completed(tokens: Array) -> void:
	combo_completed.emit(tokens)


func _on_combo_reset() -> void:
	combo_reset.emit()


func _on_effect_state_changed(snapshot: Dictionary) -> void:
	movement.set_effect_multiplier(float(snapshot["movement_multiplier"]))
	combat.set_effect_actions_suppressed(bool(snapshot["actions_suppressed"]))


func _on_hit_reaction_started(_level: int, _direction: Vector2, _distance: float, _duration: float) -> void:
	combat.on_hit_reaction_started()


func _on_hit_reaction_ended() -> void:
	combat.on_hit_reaction_ended()


func _on_defence_status_changed(label: String, current_guard: float, maximum_guard: float) -> void:
	defence_status_changed.emit(label, current_guard, maximum_guard)


func _on_guard_warning() -> void:
	guard_warning_audio.play()
