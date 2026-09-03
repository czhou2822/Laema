extends "res://scripts/entities/entity.gd"

signal heat_changed(value: float, level: int, speed_multiplier: float)
signal health_changed(current_value: float, maximum_value: float)
signal combo_sequence_changed(tokens: Array)
signal combo_completed(tokens: Array)
signal combo_reset
signal active_school_changed(school: StringName)
signal defence_status_changed(label: String, current_guard: float, maximum_guard: float)
signal orb_queue_changed(snapshot: Array, marked_count: int, marking_progress: float)
signal spell_projectile_requested(payload: Dictionary)

const FireResolver = preload("res://scripts/combat/fire_resolver.gd")
const WaterResolver = preload("res://scripts/combat/water_resolver.gd")
const AirResolver = preload("res://scripts/combat/air_resolver.gd")
const EarthResolver = preload("res://scripts/combat/earth_resolver.gd")
const SHARED_IDLE: Texture2D = preload("res://assets/prototype/player/animation/shared_idle.png")
const SHARED_WALK: Texture2D = preload("res://assets/prototype/player/animation/shared_walk.png")
const SHARED_CAST: Texture2D = preload("res://assets/prototype/player/animation/shared_cast.png")
const HURT_TEXTURE: Texture2D = preload("res://assets/prototype/player/animation/hurt.png")
const FIRE_X1: Texture2D = preload("res://assets/prototype/player/animation/fire_x1.png")
const FIRE_X2: Texture2D = preload("res://assets/prototype/player/animation/fire_x2.png")
const FIRE_X3: Texture2D = preload("res://assets/prototype/player/animation/fire_x3.png")
const FIRE_X4: Texture2D = preload("res://assets/prototype/player/animation/fire_x4.png")
const FIRE_X5: Texture2D = preload("res://assets/prototype/player/animation/fire_x5.png")
const WATER_X1: Texture2D = preload("res://assets/prototype/player/animation/water_x1.png")
const WATER_X2: Texture2D = preload("res://assets/prototype/player/animation/water_x2.png")
const WATER_X3: Texture2D = preload("res://assets/prototype/player/animation/water_x3.png")
const WATER_X4: Texture2D = preload("res://assets/prototype/player/animation/water_x4.png")
const WATER_X5: Texture2D = preload("res://assets/prototype/player/animation/water_x5.png")
const AIR_X1: Texture2D = preload("res://assets/prototype/player/animation/air_x1.png")
const AIR_X2: Texture2D = preload("res://assets/prototype/player/animation/air_x2.png")
const AIR_X3: Texture2D = preload("res://assets/prototype/player/animation/air_x3.png")
const AIR_X4: Texture2D = preload("res://assets/prototype/player/animation/air_x4.png")
const AIR_X5: Texture2D = preload("res://assets/prototype/player/animation/air_x5.png")
const EARTH_X1: Texture2D = preload("res://assets/prototype/player/animation/earth_x1.png")
const EARTH_X2: Texture2D = preload("res://assets/prototype/player/animation/earth_x2.png")
const EARTH_X3: Texture2D = preload("res://assets/prototype/player/animation/earth_x3.png")
const EARTH_X4: Texture2D = preload("res://assets/prototype/player/animation/earth_x4.png")
const EARTH_X5: Texture2D = preload("res://assets/prototype/player/animation/earth_x5.png")
const ATTACK_SWING_STREAM_PATHS := [
	"res://assets/prototype/audio/combat/swing_01.wav",
	"res://assets/prototype/audio/combat/swing_02.wav",
	"res://assets/prototype/audio/combat/swing_03.wav",
]
const SCHOOL_ATTACK_STREAM_PATHS := {
	&"fire": [
		"res://assets/prototype/audio/combat/fire_attack_01.ogg",
		"res://assets/prototype/audio/combat/fire_attack_02.ogg",
		"res://assets/prototype/audio/combat/fire_attack_03.ogg",
		"res://assets/prototype/audio/combat/fire_attack_04.ogg",
		"res://assets/prototype/audio/combat/fire_attack_05.ogg",
	],
	&"water": [
		"res://assets/prototype/audio/combat/water_attack_01.ogg",
		"res://assets/prototype/audio/combat/water_attack_02.ogg",
		"res://assets/prototype/audio/combat/water_attack_03.ogg",
		"res://assets/prototype/audio/combat/water_attack_04.ogg",
		"res://assets/prototype/audio/combat/water_attack_05.ogg",
	],
	&"air": [
		"res://assets/prototype/audio/combat/air_attack_01.ogg",
		"res://assets/prototype/audio/combat/air_attack_02.ogg",
		"res://assets/prototype/audio/combat/air_attack_03.ogg",
		"res://assets/prototype/audio/combat/air_attack_04.ogg",
		"res://assets/prototype/audio/combat/air_attack_05.ogg",
	],
	&"earth": [
		"res://assets/prototype/audio/combat/earth_attack_01.ogg",
		"res://assets/prototype/audio/combat/earth_attack_02.ogg",
		"res://assets/prototype/audio/combat/earth_attack_03.ogg",
		"res://assets/prototype/audio/combat/earth_attack_04.ogg",
		"res://assets/prototype/audio/combat/earth_attack_05.ogg",
	],
}
const CAST_STREAM_PATHS := {
	&"fire": "res://assets/prototype/audio/casting/fire_cast.ogg",
	&"water": "res://assets/prototype/audio/casting/water_cast.ogg",
	&"air": "res://assets/prototype/audio/casting/air_cast.ogg",
	&"earth": "res://assets/prototype/audio/casting/earth_cast.ogg",
}
const EMPOWERED_CAST_STREAM_PATH := "res://assets/prototype/audio/casting/empowered_cast.ogg"
const CAST_FAIL_STREAM_PATH := "res://assets/prototype/audio/casting/cast_fail.ogg"
const ORB_CREATED_STREAM_PATH := "res://assets/prototype/audio/casting/orb_created.ogg"
const MARK_ORB_STREAM_PATH := "res://assets/prototype/audio/casting/mark_orb.ogg"
const CELL_SIZE := Vector2(128.0, 128.0)
const IDLE_FRAMES := 6
const WALK_FRAMES := 12
const CAST_FRAMES := 10
const HURT_FRAMES := 4
const IDLE_FPS := 8.0
const WALK_FPS := 10.0
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
@onready var might: MightComponent = $Combat/Might
@onready var magic: MagicComponent = $Combat/Magic
@onready var input_combo = $Combat/Might/InputCombo
@onready var heat: HeatComponent = $Combat/Heat
@onready var defence: DefenceController = $Combat/Defence
@onready var guard_warning_audio: AudioStreamPlayer = $GuardWarningAudio
@onready var attack_swing_audio: AudioStreamPlayer = $AttackSwingAudio
@onready var element_audio: AudioStreamPlayer = $ElementAudio
@onready var cast_audio: AudioStreamPlayer = $CastAudio
@onready var empowered_cast_audio: AudioStreamPlayer = $EmpoweredCastAudio
@onready var cast_fail_audio: AudioStreamPlayer = $CastFailAudio
@onready var orb_audio: AudioStreamPlayer = $OrbAudio
@onready var mark_audio: AudioStreamPlayer = $MarkAudio
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
var _last_orb_count := 0
var _last_marked_count := 0
var _stage_input_locked := false
var _hit_reaction_tween: Tween
var _hit_visual_active := false
var _hit_visual_time := 0.0
var _hit_visual_duration := 0.0


func configure(config: Dictionary) -> void:
	_config = config
	_sprite_rest_position = sprite.position
	_sprite_rest_scale = sprite.scale
	_sprite_rest_rotation = sprite.rotation
	movement.facing_changed.connect(_on_facing_changed)
	combat.movement_lock_changed.connect(movement.set_movement_locked)
	combat.active_school_changed.connect(_on_active_school_changed)
	combat.attack_started.connect(_on_attack_started)
	combat.empowered_cast_started.connect(_on_empowered_cast_started)
	combat.cast_launch_requested.connect(_on_cast_launch_requested)
	combat.cast_failed.connect(_on_cast_failed)
	combat.defence_status_changed.connect(_on_defence_status_changed)
	combat.heat_changed.connect(_on_heat_changed)
	combat.combo_sequence_changed.connect(_on_combo_sequence_changed)
	combat.combo_completed.connect(_on_combo_completed)
	combat.combo_reset.connect(_on_combo_reset)
	combat.orb_queue_changed.connect(_on_orb_queue_changed)
	defence.guard_warning.connect(_on_guard_warning)
	health.health_changed.connect(_on_health_changed)
	status_controller.effect_state_changed.connect(_on_effect_state_changed)
	hit_reaction.reaction_started.connect(_on_hit_reaction_started)
	hit_reaction.reaction_ended.connect(_on_hit_reaction_ended)

	movement.configure(self, config["movement"])
	combat.configure(
		config,
		self,
		animation_player,
		attack_cast,
		input_combo,
		might,
		magic,
		heat,
		defence,
		{
			&"fire": FireResolver.new(),
			&"water": WaterResolver.new(),
			&"air": AirResolver.new(),
			&"earth": EarthResolver.new(),
		}
	)
	configure_entity(
		float(config["player"]["max_health"]),
		0,
		false,
		config["hit_reaction"],
		config,
		defence
	)
	_update_school_outline(combat.get_active_school())


func apply_runtime_tuning() -> void:
	movement.apply_runtime_tuning()
	combat.apply_runtime_tuning()
	health.set_maximum(float(_config["player"]["max_health"]))
	hit_reaction.configure(_config["hit_reaction"])
	apply_feedback_runtime_tuning(float(_config["ui"]["cast_feedback_duration"]))


func receive_health_result(result: HealthResult) -> void:
	combat.handle_health_result(result)


func get_defensive_level() -> int:
	return combat.get_defensive_level() if combat != null else 0


func set_attack_hitbox_debug_enabled(enabled: bool) -> void:
	_attack_hitbox_debug_enabled = enabled
	queue_redraw()


func is_attack_hitbox_debug_enabled() -> bool:
	return _attack_hitbox_debug_enabled


func set_stage_input_locked(locked: bool) -> void:
	_stage_input_locked = locked
	combat.set_stage_input_locked(locked)
	movement.set_movement_locked(locked)


func reset_for_stage() -> void:
	combat.reset_for_stage()
	status_controller.clear_for_stage()
	hit_reaction.reset_for_stage()
	health.reset_to_maximum()
	velocity = Vector2.ZERO


func select_stage_school(school: StringName) -> void:
	combat.select_stage_school(school)


func _unhandled_input(event: InputEvent) -> void:
	if _config.is_empty():
		return
	combat.handle_input_event(event, _get_attack_direction())


func _process(delta: float) -> void:
	if _config.is_empty():
		return
	_visual_time += delta
	if _hit_visual_active:
		_update_hit_reaction_visual(delta)
	elif combat.is_attack_playing():
		_update_attack_visual()
	elif not movement.get_motion().is_zero_approx():
		_update_locomotion_visual(&"walk", _get_walk_texture(combat.get_active_school()), _get_walk_frames(combat.get_active_school()), WALK_FPS)
	else:
		_update_locomotion_visual(&"idle", _get_idle_texture(combat.get_active_school()), IDLE_FRAMES, IDLE_FPS)
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
	var texture: Texture2D = SHARED_CAST
	var frame_count := CAST_FRAMES
	var mode := &"cast"
	if _visual_attack_kind == &"light":
		texture = _get_attack_texture(school, _visual_light_position)
		frame_count = _get_attack_frames(school, _visual_light_position)
		mode = StringName("attack_x%d" % _visual_light_position)
	_set_visual_mode(mode, texture)
	_update_side_facing(_visual_attack_direction)
	_reset_sprite_motion()
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
	var frame := int(floor(_visual_time * fps)) % frame_count
	_set_region(frame)


func _get_idle_texture(_school: StringName) -> Texture2D:
	return SHARED_IDLE


func _get_walk_texture(_school: StringName) -> Texture2D:
	return SHARED_WALK


func _get_walk_frames(_school: StringName) -> int:
	return WALK_FRAMES


func _get_attack_texture(school: StringName, combo_position: int) -> Texture2D:
	var position := clampi(combo_position, 1, 5)
	match school:
		&"fire": return [FIRE_X1, FIRE_X2, FIRE_X3, FIRE_X4, FIRE_X5][position - 1]
		&"water": return [WATER_X1, WATER_X2, WATER_X3, WATER_X4, WATER_X5][position - 1]
		&"air": return [AIR_X1, AIR_X2, AIR_X3, AIR_X4, AIR_X5][position - 1]
		&"earth": return [EARTH_X1, EARTH_X2, EARTH_X3, EARTH_X4, EARTH_X5][position - 1]
	return FIRE_X1


func _get_attack_frames(school: StringName, combo_position: int) -> int:
	var position := clampi(combo_position, 1, 5)
	match school:
		&"fire": return [5, 3, 11, 9, 11][position - 1]
		&"water": return [5, 5, 4, 5, 5][position - 1]
		&"air": return [9, 7, 7, 6, 8][position - 1]
		&"earth": return [4, 3, 4, 5, 4][position - 1]
	return 5


func _reset_sprite_motion() -> void:
	if not _hit_visual_active:
		sprite.position = _sprite_rest_position
	sprite.scale = _sprite_rest_scale
	sprite.rotation = _sprite_rest_rotation


func _update_hit_reaction_visual(delta: float) -> void:
	_hit_visual_time += delta
	_set_visual_mode(&"hurt", HURT_TEXTURE)
	var duration := maxf(_hit_visual_duration, 0.001)
	var frame := clampi(int(floor(_hit_visual_time / duration * float(HURT_FRAMES))), 0, HURT_FRAMES - 1)
	_set_region(frame)


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


func get_facing_direction() -> Vector2:
	return _get_attack_direction()


func _sync_attack_cast_direction() -> void:
	if _config.is_empty():
		return
	attack_cast.target_position = _get_attack_direction() * float(_config["combat"]["shape_reach"])


func _on_attack_started(kind: StringName, school: StringName, direction: Vector2) -> void:
	_visual_attack_direction = direction
	_visual_attack_kind = kind
	_visual_light_position = clampi(combat.get_current_chain_position(), 1, 5) if kind == &"light" else 0
	_visual_time = 0.0
	if kind == &"light":
		_play_audio(attack_swing_audio, _load_audio_stream(ATTACK_SWING_STREAM_PATHS[(_visual_light_position - 1) % ATTACK_SWING_STREAM_PATHS.size()]))
		_play_audio(element_audio, _school_attack_stream(school, _visual_light_position))


func _on_empowered_cast_started(school: StringName, direction: Vector2) -> void:
	var dot := Polygon2D.new()
	dot.polygon = PackedVector2Array([
		Vector2(-4.0, -4.0),
		Vector2(4.0, -4.0),
		Vector2(4.0, 4.0),
		Vector2(-4.0, 4.0),
	])
	dot.color = SCHOOL_COLORS[school]
	dot.position = direction.normalized() * 28.0
	dot.z_index = 4
	add_child(dot)
	get_tree().create_timer(0.22).timeout.connect(dot.queue_free)
	_play_audio(empowered_cast_audio, _load_audio_stream(EMPOWERED_CAST_STREAM_PATH))


func _on_cast_launch_requested(payload: Dictionary) -> void:
	var request: Dictionary = payload.duplicate(true)
	var direction: Vector2 = request["direction"]
	request["origin"] = global_position + direction.normalized() * 42.0
	var primary_school := StringName(request["primary_school"])
	_play_audio(cast_audio, _load_audio_stream(str(CAST_STREAM_PATHS.get(primary_school, CAST_STREAM_PATHS[&"fire"]))))
	spell_projectile_requested.emit(request)


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


func _on_orb_queue_changed(snapshot: Array, marked_count: int, marking_progress: float) -> void:
	var visible_marked_count := 0
	for orb in snapshot:
		if bool(orb.get("marked", false)):
			visible_marked_count += 1
	if snapshot.size() > _last_orb_count:
		_play_audio(orb_audio, _load_audio_stream(ORB_CREATED_STREAM_PATH))
	if visible_marked_count > _last_marked_count:
		_play_audio(mark_audio, _load_audio_stream(MARK_ORB_STREAM_PATH))
	_last_orb_count = snapshot.size()
	_last_marked_count = visible_marked_count
	orb_queue_changed.emit(snapshot, marked_count, marking_progress)


func _on_effect_state_changed(snapshot: Dictionary) -> void:
	movement.set_effect_multiplier(float(snapshot["movement_multiplier"]))
	combat.set_effect_actions_suppressed(bool(snapshot["actions_suppressed"]))


func _on_hit_reaction_started(_level: int, direction: Vector2, distance: float, duration: float) -> void:
	combat.on_hit_reaction_started()
	if _hit_reaction_tween != null and _hit_reaction_tween.is_valid():
		_hit_reaction_tween.kill()
	_hit_visual_active = true
	_hit_visual_time = 0.0
	_hit_visual_duration = duration
	var offset := direction.normalized() * distance
	sprite.position = _sprite_rest_position + offset
	_hit_reaction_tween = create_tween()
	_hit_reaction_tween.tween_property(sprite, "position", _sprite_rest_position, duration)
	_hit_reaction_tween.tween_callback(_finish_hit_visual)


func _on_hit_reaction_ended() -> void:
	combat.on_hit_reaction_ended()


func _finish_hit_visual() -> void:
	_hit_visual_active = false
	_hit_visual_time = 0.0
	_hit_visual_duration = 0.0
	sprite.position = _sprite_rest_position


func _on_defence_status_changed(label: String, current_guard: float, maximum_guard: float) -> void:
	defence_status_changed.emit(label, current_guard, maximum_guard)


func _on_guard_warning() -> void:
	guard_warning_audio.play()


func _on_cast_failed() -> void:
	_play_audio(cast_fail_audio, _load_audio_stream(CAST_FAIL_STREAM_PATH))


func _school_attack_stream(school: StringName, position: int) -> AudioStream:
	var stream_paths: Array = SCHOOL_ATTACK_STREAM_PATHS.get(school, SCHOOL_ATTACK_STREAM_PATHS[&"fire"])
	return _load_audio_stream(str(stream_paths[clampi(position - 1, 0, stream_paths.size() - 1)]))


func _play_audio(player: AudioStreamPlayer, stream: AudioStream) -> void:
	if stream == null:
		return
	player.stream = stream
	player.play()


func _load_audio_stream(path: String) -> AudioStream:
	return ResourceLoader.load(path, "AudioStream") as AudioStream
