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
const HURT_TEXTURE: Texture2D = preload("res://assets/prototype/player/animation/hurt.png")
const FIRE_ART_ROOT := "res://assets/prototype/player/fire_sword_shield_v01/"
const FIRE_IDLE: Texture2D = preload("res://assets/prototype/player/fire_sword_shield_v01/shared_idle.png")
const FIRE_WALK: Texture2D = preload("res://assets/prototype/player/fire_sword_shield_v01/shared_walk.png")
const FIRE_HURT: Texture2D = preload("res://assets/prototype/player/fire_sword_shield_v01/hurt.png")
const FIRE_DEFENCE: Texture2D = preload("res://assets/prototype/player/fire_sword_shield_v01/shield_catch/shield-catch-8x448.png")
const FIRE_DEFENCE_GUARD_FRAME := 3
const FIRE_DEFENCE_SPARK_FRAME := 4
const FIRE_DEFENCE_LAST_FRAME := 7
const FIRE_CELL_SIZE := Vector2(448.0, 448.0)
const FIRE_FOOT_ANCHOR := Vector2(224.0, 400.0)
const FIRE_BODY_SIZE := Vector2(30.0, 90.0)
const FIRE_BODY_POSITION := Vector2(0.0, -19.0)
const ATTACK_SWING_STREAM_PATHS := [
	"res://assets/prototype/audio/combat/SWRDATTK.wav",
]
const SCHOOL_ATTACK_STREAM_PATHS := {
	&"fire": [
		"",
		"",
		"",
		"",
		"",
	],
	&"water": [
		"",
		"",
		"",
		"",
		"",
	],
	&"air": [
		"",
		"",
		"",
		"",
		"",
	],
	&"earth": [
		"",
		"",
		"",
		"",
		"",
	],
}
const CAST_STREAM_PATHS := {
	&"fire": "res://assets/prototype/audio/casting/SPONTCOMB.wav",
	&"water": "res://assets/prototype/audio/casting/ICERAY.wav",
	&"air": "res://assets/prototype/audio/casting/LIGHTBLT.wav",
	&"earth": "res://assets/prototype/audio/casting/METEOR.wav",
}
const EMPOWERED_CAST_STREAM_PATH := "res://assets/prototype/audio/casting/BLESS.wav"
const CAST_FAIL_STREAM_PATH := "res://assets/prototype/audio/casting/DISPELL.wav"
const ORB_CREATED_STREAM_PATH := "res://assets/prototype/audio/casting/PICKUP04.wav"
const MARK_ORB_STREAM_PATH := "res://assets/prototype/audio/casting/charging_note_pickup03.wav"
const MARK_AUDIO_VOLUME_DB := 0.0
const MARK_AUDIO_BACKGROUND_REDUCTION_DB := 12.0
const MARK_AUDIO_PITCH_SCALES: Array[float] = [1.0, 9.0 / 8.0, 5.0 / 4.0, 4.0 / 3.0, 3.0 / 2.0, 5.0 / 3.0, 15.0 / 8.0, 2.0]
const CELL_SIZE := Vector2(128.0, 128.0)
const IDLE_FRAMES := 6
const WALK_FRAMES := 12
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

@export var settings: PlayerCombatSettings

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
@onready var hit_reaction_audio: AudioStreamPlayer = $HitReactionAudio
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_cast: ShapeCast2D = $AttackCast
@onready var body_collision: CollisionShape2D = $CollisionShape2D

var _config: Dictionary = {}
var _visual_time := 0.0
var _last_visual_mode := &""
var _dodge_visual_handoff_frame := -1
var _visual_attack_direction := Vector2.RIGHT
var _visual_light_position := 0
var _attack_hitbox_debug_enabled := true
var _facing_left := false
var _sprite_rest_position := Vector2.ZERO
var _sprite_rest_scale := Vector2.ONE
var _sprite_rest_rotation := 0.0
var _sprite_rest_offset := Vector2.ZERO
var _sprite_rest_filter := CanvasItem.TEXTURE_FILTER_PARENT_NODE
var _sprite_rest_material: Material
var _sprite_art_captured := false
var _fire_sprite_offset := Vector2.ZERO
var _legacy_body_shape: Shape2D
var _legacy_body_position := Vector2.ZERO
var _fire_body_shape: RectangleShape2D
var _last_orb_count := 0
var _last_marked_count := 0
var _pending_mark_audio_levels: Array[int] = []
var _mark_audio_draining := false
var _mark_audio_background_volumes: Dictionary = {}
var _stage_input_locked := false
var _hit_reaction_tween: Tween
var _hit_visual_active := false
var _hit_visual_time := 0.0
var _hit_visual_duration := 0.0
var _fire_defence_contact_remaining := 0.0
var _fire_defence_release_remaining := 0.0
var _fire_defence_was_guarding := false


func configure(config: Dictionary) -> void:
	_clear_pending_mark_audio()
	_last_orb_count = 0
	_last_marked_count = 0
	if settings != null:
		settings.read_from_config(config)
		settings.hit_reaction.read_from_config(config)
	_config = config
	_sprite_rest_position = sprite.position
	_sprite_rest_scale = sprite.scale
	_sprite_rest_rotation = sprite.rotation
	if not _sprite_art_captured:
		_sprite_rest_offset = sprite.offset
		_sprite_rest_filter = sprite.texture_filter
		_sprite_rest_material = sprite.material
		_sprite_art_captured = true
	# Both body profiles keep the authored floor reference and sprite registration.
	if _legacy_body_shape == null:
		_legacy_body_shape = body_collision.shape
		_legacy_body_position = body_collision.position
		_fire_body_shape = RectangleShape2D.new()
		_fire_body_shape.size = FIRE_BODY_SIZE
	var floor_anchor := body_collision.position + Vector2(0.0, body_collision.shape.get_rect().end.y)
	_fire_sprite_offset = FIRE_CELL_SIZE * 0.5 - FIRE_FOOT_ANCHOR + (floor_anchor - _sprite_rest_position) / _sprite_rest_scale
	movement.facing_changed.connect(_on_facing_changed)
	combat.movement_lock_changed.connect(movement.set_movement_locked)
	movement.set_attack_motion_provider(might.consume_attack_body_motion)
	combat.active_school_changed.connect(_on_active_school_changed)
	combat.attack_started.connect(_on_attack_started)
	combat.dodge_started.connect(_on_dodge_started)
	combat.dodge_finished.connect(_on_dodge_finished)
	combat.empowered_cast_started.connect(_on_empowered_cast_started)
	combat.cast_launch_requested.connect(_on_cast_launch_requested)
	combat.cast_failed.connect(_on_cast_failed)
	combat.defence_status_changed.connect(_on_defence_status_changed)
	combat.heat_changed.connect(_on_heat_changed)
	combat.combo_sequence_changed.connect(_on_combo_sequence_changed)
	combat.combo_completed.connect(_on_combo_completed)
	combat.combo_reset.connect(_on_combo_reset)
	combat.orb_queue_changed.connect(_on_orb_queue_changed)
	if not mark_audio.finished.is_connected(_on_mark_audio_finished):
		mark_audio.finished.connect(_on_mark_audio_finished)
	defence.guard_warning.connect(_on_guard_warning)
	defence.parry_window_changed.connect(_on_parry_window_changed)
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
	health.set_minimum(1.0 if bool(config["player"]["one_hp_floor_enabled"]) else 0.0)
	_update_school_outline(combat.get_active_school())


func apply_runtime_tuning() -> void:
	if settings != null:
		settings.read_from_config(_config)
		settings.hit_reaction.read_from_config(_config)
	movement.apply_runtime_tuning()
	combat.apply_runtime_tuning()
	health.set_maximum(float(_config["player"]["max_health"]))
	health.set_minimum(1.0 if bool(_config["player"]["one_hp_floor_enabled"]) else 0.0)
	hit_reaction.configure(_config["hit_reaction"])
	apply_feedback_runtime_tuning(float(_config["ui"]["cast_feedback_duration"]))


func receive_health_result(result: HealthResult) -> void:
	combat.handle_health_result(result)
	if result == null or result.event == null or result.event.target != self:
		return
	var fire_defended := result.event.fire_defence and result.outcome in [HealthResult.Outcome.PARRIED, HealthResult.Outcome.BLOCKED]
	if fire_defended and result.outcome == HealthResult.Outcome.PARRIED:
		_start_fire_defence_contact_visual()
	if fire_defended and guard_warning_audio.stream != null:
		guard_warning_audio.play()
	if result.outcome != HealthResult.Outcome.APPLIED and not (fire_defended and result.health_delta < 0.0):
		return
	if result.event.is_direct_damage():
		feedback.show_damage(result.event.school, -result.health_delta)
	elif result.event.delivery == HealthEvent.Delivery.DOT_TICK:
		feedback.show_dot_damage(result.event.school, -result.health_delta)


func get_defensive_level() -> int:
	return combat.get_defensive_level() if combat != null else 0


func set_attack_hitbox_debug_enabled(enabled: bool) -> void:
	_attack_hitbox_debug_enabled = enabled
	queue_redraw()


func is_attack_hitbox_debug_enabled() -> bool:
	return _attack_hitbox_debug_enabled


func set_stage_input_locked(locked: bool) -> void:
	_stage_input_locked = locked
	if locked:
		_clear_pending_mark_audio()
		_clear_fire_defence_visual()
	combat.set_stage_input_locked(locked)
	movement.set_movement_locked(locked)


func reset_for_stage() -> void:
	combat.reset_for_stage()
	_clear_fire_defence_visual()
	_clear_pending_mark_audio()
	status_controller.clear_for_stage()
	hit_reaction.reset_for_stage()
	_finish_hit_visual()
	health_resolver.reset_for_stage()
	health.reset_to_maximum()
	velocity = Vector2.ZERO
	set_stage_input_locked(false)
	sync_combat_body_profile()


func select_stage_school(school: StringName) -> void:
	combat.select_stage_school(school)


func _unhandled_input(event: InputEvent) -> void:
	if _config.is_empty():
		return
	if not event.is_echo() and event.is_action_pressed(&"dodge"):
		combat.try_dodge(movement.sample_dodge_direction(event.device), movement.get_normal_movement_speed())
		return
	combat.handle_input_event(event, _get_attack_direction())


func _process(delta: float) -> void:
	if _config.is_empty():
		return
	_visual_time += delta
	_fire_defence_contact_remaining = maxf(_fire_defence_contact_remaining - delta, 0.0)
	_fire_defence_release_remaining = maxf(_fire_defence_release_remaining - delta, 0.0)
	if _hit_visual_active:
		_update_hit_reaction_visual(delta)
	elif combat.is_attack_playing() or might.is_dodging():
		_update_attack_visual()
	elif _update_fire_defence_visual():
		pass
	elif _is_locomotion_visual_walking():
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
	var geometry: Dictionary = might.get_attack_geometry()
	var start: Vector2 = geometry["position"]
	var end: Vector2 = start + Vector2(geometry["target"])
	var direction := (end - start).normalized()
	var radius := float(geometry["radius"])
	# Match the editor's ShapeCast circle spacing using the committed query pose.
	var steps := maxi(2, int(start.distance_to(end) / (Vector2.ONE * radius * 2.0).length() * 4.0))
	for index in range(steps + 1):
		var center := start.lerp(end, float(index) / steps)
		draw_circle(center, radius, ATTACK_HITBOX_DEBUG_FILL)
		draw_arc(center, radius, 0.0, TAU, 32, ATTACK_HITBOX_DEBUG_OUTLINE, 1.0, true)
	if not direction.is_zero_approx():
		var arrow_size := minf(start.distance_to(end), clampf(start.distance_to(end) * 2.0 / 3.0, 1.4, 6.0))
		var arrow_base := end - direction * arrow_size
		var arrow_edge := direction.orthogonal() * arrow_size * 0.5
		draw_line(start, arrow_base, ATTACK_HITBOX_DEBUG_OUTLINE, 1.4, true)
		draw_colored_polygon(PackedVector2Array([end, arrow_base + arrow_edge, arrow_base - arrow_edge]), ATTACK_HITBOX_DEBUG_OUTLINE)


func _is_attack_hitbox_debug_visible() -> bool:
	if not _attack_hitbox_debug_enabled or not combat.is_attack_playing() or might.get_melee_snapshot().is_empty():
		return false
	return bool(might.get_melee_snapshot().get("active", false))


func _update_attack_visual() -> void:
	# Texture and sprite frames are authored alongside geometry in AnimationPlayer.
	_last_visual_mode = &"attack"
	_update_side_facing(_visual_attack_direction)
	_reset_sprite_motion()


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


func _is_locomotion_visual_walking() -> bool:
	# Completion clears dodge velocity before the next normal movement sample.
	# Read input for presentation only during that handoff; never move the body here.
	if Engine.get_physics_frames() == _dodge_visual_handoff_frame:
		return not _stage_input_locked and not health.is_zero() and not is_zero_approx(Input.get_axis(&"move_left", &"move_right"))
	return not movement.get_motion().is_zero_approx()


func _get_idle_texture(school: StringName) -> Texture2D:
	return FIRE_IDLE if school == &"fire" else SHARED_IDLE


func _update_fire_defence_visual() -> bool:
	if _stage_input_locked or _hit_visual_active or health.is_zero() or combat.is_attack_playing() or combat.get_active_school() != &"fire":
		_clear_fire_defence_visual()
		return false
	var state := defence.get_fire_visual_snapshot()
	if not bool(state.get("control_locked", false)) and not movement.get_motion().is_zero_approx():
		_clear_fire_defence_visual()
		return false
	var frame := -1
	if _fire_defence_contact_remaining > 0.0:
		var contact_elapsed := float(FIRE_DEFENCE_LAST_FRAME - FIRE_DEFENCE_SPARK_FRAME + 1) / WALK_FPS - _fire_defence_contact_remaining
		frame = clampi(FIRE_DEFENCE_SPARK_FRAME + int(contact_elapsed * WALK_FPS), FIRE_DEFENCE_SPARK_FRAME, FIRE_DEFENCE_LAST_FRAME)
	elif not state.is_empty() and not bool(state["succeeded"]):
		if bool(state["holding"]) or bool(state["parrying"]):
			_fire_defence_was_guarding = true
			_fire_defence_release_remaining = 0.0
			frame = mini(int(float(state["elapsed"]) * WALK_FPS), FIRE_DEFENCE_GUARD_FRAME)
	if frame < 0:
		if _fire_defence_was_guarding:
			_fire_defence_was_guarding = false
			_fire_defence_release_remaining = float(FIRE_DEFENCE_LAST_FRAME - FIRE_DEFENCE_SPARK_FRAME) / WALK_FPS
		if _fire_defence_release_remaining <= 0.0:
			return false
		var release_elapsed := float(FIRE_DEFENCE_LAST_FRAME - FIRE_DEFENCE_SPARK_FRAME) / WALK_FPS - _fire_defence_release_remaining
		# Misses and ordinary blocks never enter the baked-spark cell.
		frame = clampi(FIRE_DEFENCE_SPARK_FRAME + 1 + int(release_elapsed * WALK_FPS), FIRE_DEFENCE_SPARK_FRAME + 1, FIRE_DEFENCE_LAST_FRAME)
	_set_visual_mode(&"fire_defence", FIRE_DEFENCE)
	_reset_sprite_motion()
	_update_side_facing(movement.get_facing_direction())
	_set_region(frame)
	return true


func _start_fire_defence_contact_visual() -> void:
	if _stage_input_locked or health.is_zero() or combat.get_active_school() != &"fire":
		return
	_fire_defence_contact_remaining = float(FIRE_DEFENCE_LAST_FRAME - FIRE_DEFENCE_SPARK_FRAME + 1) / WALK_FPS
	_fire_defence_release_remaining = 0.0
	_fire_defence_was_guarding = false
	_update_fire_defence_visual()


func _clear_fire_defence_visual() -> void:
	_fire_defence_contact_remaining = 0.0
	_fire_defence_release_remaining = 0.0
	_fire_defence_was_guarding = false


func _on_parry_window_changed(active: bool) -> void:
	if active and defence.is_fire_mode():
		var state := defence.get_fire_visual_snapshot()
		if is_zero_approx(float(state["elapsed"])):
			_clear_fire_defence_visual()


func _get_walk_texture(school: StringName) -> Texture2D:
	return FIRE_WALK if school == &"fire" else SHARED_WALK


func _get_walk_frames(_school: StringName) -> int:
	return WALK_FRAMES


func _reset_sprite_motion() -> void:
	if not _hit_visual_active:
		sprite.position = _sprite_rest_position
	sprite.scale = _sprite_rest_scale
	sprite.rotation = _sprite_rest_rotation
	_apply_sprite_art_profile()


func _update_hit_reaction_visual(delta: float) -> void:
	_hit_visual_time += delta
	_set_visual_mode(&"hurt", FIRE_HURT if combat.get_active_school() == &"fire" else HURT_TEXTURE)
	_apply_sprite_art_profile()
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
	var cell_size := FIRE_CELL_SIZE if _uses_fire_art() else CELL_SIZE
	sprite.region_rect = Rect2(Vector2(frame, 0) * cell_size, cell_size)


func _uses_fire_art() -> bool:
	# Follow the committed clip's texture even if the selected school changes.
	return sprite.texture != null and sprite.texture.resource_path.begins_with(FIRE_ART_ROOT)


func _apply_sprite_art_profile() -> void:
	var fire_art := _uses_fire_art()
	sprite.offset = _fire_sprite_offset if fire_art else _sprite_rest_offset
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR if fire_art else _sprite_rest_filter
	# Preserve approved Fire image colors; restore the legacy shader/tints elsewhere.
	sprite.material = null if fire_art else _sprite_rest_material
	sprite.self_modulate = Color.WHITE if fire_art else SCHOOL_TINTS[combat.get_active_school()]
	if _legacy_body_shape != null:
		var desired_shape: Shape2D = _fire_body_shape if fire_art else _legacy_body_shape
		if body_collision.shape != desired_shape:
			body_collision.shape = desired_shape
			body_collision.position = FIRE_BODY_POSITION if fire_art else _legacy_body_position


func sync_combat_body_profile() -> void:
	if _config.is_empty():
		return
	# Animation texture follows the committed action, including a school switch.
	# Outside an action, refresh the selected school's art before physics queries.
	if _hit_visual_active:
		_update_hit_reaction_visual(0.0)
	elif might.is_dodging():
		# Native playback may finish before Might releases the dodge action this sample.
		pass
	elif not combat.is_attack_playing() and _update_fire_defence_visual():
		pass
	elif not combat.is_attack_playing():
		var walking: bool = _is_locomotion_visual_walking()
		var texture: Texture2D = _get_walk_texture(combat.get_active_school()) if walking else _get_idle_texture(combat.get_active_school())
		if sprite.texture != texture:
			_set_visual_mode(&"walk" if walking else &"idle", texture)
			_set_region(0)
	_apply_sprite_art_profile()


func _update_side_facing(direction: Vector2) -> void:
	if not is_zero_approx(direction.x):
		_facing_left = direction.x < 0.0
	sprite.flip_h = _facing_left


func _on_facing_changed(direction: Vector2) -> void:
	_visual_time = 0.0
	_update_side_facing(direction)
	_visual_attack_direction = _get_attack_direction()


func _get_attack_direction() -> Vector2:
	return Vector2.LEFT if _facing_left else Vector2.RIGHT


func get_facing_direction() -> Vector2:
	return _get_attack_direction()


func _on_attack_started(kind: StringName, school: StringName, direction: Vector2) -> void:
	_clear_fire_defence_visual()
	_visual_attack_direction = direction
	_visual_light_position = clampi(combat.get_current_chain_position(), 1, 5) if kind == &"light" else 0
	_visual_time = 0.0
	_apply_sprite_art_profile()
	if kind == &"light":
		_play_audio(attack_swing_audio, _load_audio_stream(ATTACK_SWING_STREAM_PATHS[(_visual_light_position - 1) % ATTACK_SWING_STREAM_PATHS.size()]))
		_play_audio(element_audio, _school_attack_stream(school, _visual_light_position))


func _on_dodge_started(direction: Vector2) -> void:
	_clear_fire_defence_visual()
	_clear_pending_mark_audio()
	_visual_attack_direction = direction
	_visual_light_position = 0
	_visual_time = 0.0
	movement.begin_dodge(direction)
	_reset_sprite_motion()


func _on_dodge_finished() -> void:
	movement.end_dodge()
	_dodge_visual_handoff_frame = Engine.get_physics_frames()
	sync_combat_body_profile()


func _on_empowered_cast_started(school: StringName, direction: Vector2) -> void:
	var dot := Polygon2D.new()
	dot.polygon = PackedVector2Array([
		Vector2(-6.0, -6.0),
		Vector2(6.0, -6.0),
		Vector2(6.0, 6.0),
		Vector2(-6.0, 6.0),
	])
	dot.color = SCHOOL_COLORS[school]
	dot.position = direction.normalized() * 8.0 + Vector2(0.0, -66.0)
	dot.z_index = 4
	add_child(dot)
	get_tree().create_timer(0.45).timeout.connect(dot.queue_free)
	_play_audio(empowered_cast_audio, _load_audio_stream(EMPOWERED_CAST_STREAM_PATH))


func _on_cast_launch_requested(payload: Dictionary) -> void:
	var request: Dictionary = payload.duplicate(true)
	var direction: Vector2 = request["direction"]
	request["origin"] = global_position + direction.normalized() * 42.0
	var primary_school := StringName(request["primary_school"])
	_play_audio(cast_audio, _load_audio_stream(str(CAST_STREAM_PATHS.get(primary_school, CAST_STREAM_PATHS[&"fire"]))))
	spell_projectile_requested.emit(request)


func _on_active_school_changed(school: StringName) -> void:
	_clear_fire_defence_visual()
	_update_school_outline(school)
	sync_combat_body_profile()
	active_school_changed.emit(school)


func _update_school_outline(school: StringName) -> void:
	var shader_material := _sprite_rest_material as ShaderMaterial
	if shader_material != null:
		shader_material.set_shader_parameter(&"outline_color", SCHOOL_COLORS[school])
	_apply_sprite_art_profile()


func _on_heat_changed(value: float, level: int, speed_multiplier: float) -> void:
	heat_changed.emit(value, level, speed_multiplier)


func _on_health_changed(current_value: float, maximum_value: float) -> void:
	if current_value <= 0.0:
		combat.cancel_combat_attack()
		hit_reaction.reset_for_stage()
		_finish_hit_visual()
		set_stage_input_locked(true)
		velocity = Vector2.ZERO
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
	if visible_marked_count < _last_marked_count:
		_clear_pending_mark_audio()
	if snapshot.size() > _last_orb_count:
		_play_audio(orb_audio, _load_audio_stream(ORB_CREATED_STREAM_PATH))
	if not _stage_input_locked and not health.is_zero() and visible_marked_count > _last_marked_count and not MARK_ORB_STREAM_PATH.is_empty():
		for level in range(_last_marked_count + 1, visible_marked_count + 1):
			_pending_mark_audio_levels.append(level)
		_drain_mark_audio_queue()
	_last_orb_count = snapshot.size()
	_last_marked_count = visible_marked_count
	orb_queue_changed.emit(snapshot, marked_count, marking_progress)


func _on_effect_state_changed(snapshot: Dictionary) -> void:
	movement.set_effect_multiplier(float(snapshot["movement_multiplier"]))
	combat.set_effect_actions_suppressed(bool(snapshot["actions_suppressed"]))


func _on_hit_reaction_started(level: int, direction: Vector2, distance: float, duration: float) -> void:
	_clear_fire_defence_visual()
	_clear_pending_mark_audio()
	combat.on_hit_reaction_started()
	if level > 0 and hit_reaction_audio.stream != null:
		hit_reaction_audio.play()
	if _hit_reaction_tween != null and _hit_reaction_tween.is_valid():
		_hit_reaction_tween.kill()
	_hit_visual_active = true
	_hit_visual_time = 0.0
	_hit_visual_duration = duration
	if hit_reaction.is_invincible():
		sprite.position = _sprite_rest_position
	else:
		var offset := direction.normalized() * distance
		sprite.position = _sprite_rest_position + offset
		_hit_reaction_tween = create_tween()
		_hit_reaction_tween.tween_property(sprite, "position", _sprite_rest_position, duration)
		_hit_reaction_tween.tween_callback(_finish_hit_visual)


func _on_hit_reaction_ended() -> void:
	combat.on_hit_reaction_ended()
	_finish_hit_visual()


func _finish_hit_visual() -> void:
	if _hit_reaction_tween != null and _hit_reaction_tween.is_valid():
		_hit_reaction_tween.kill()
	_hit_reaction_tween = null
	_hit_visual_active = false
	_hit_visual_time = 0.0
	_hit_visual_duration = 0.0
	sprite.position = _sprite_rest_position


func _on_defence_status_changed(label: String, current_guard: float, maximum_guard: float) -> void:
	defence_status_changed.emit(label, current_guard, maximum_guard)


func _on_guard_warning() -> void:
	if guard_warning_audio.stream != null:
		guard_warning_audio.play()


func _on_cast_failed() -> void:
	_clear_pending_mark_audio()
	_play_audio(cast_fail_audio, _load_audio_stream(CAST_FAIL_STREAM_PATH))


func _play_mark_audio(charged_orb_count: int) -> bool:
	var stream: AudioStream = _load_audio_stream(MARK_ORB_STREAM_PATH)
	if stream == null:
		return false
	var pitch_index: int = clampi(charged_orb_count - 1, 0, MARK_AUDIO_PITCH_SCALES.size() - 1)
	mark_audio.pitch_scale = MARK_AUDIO_PITCH_SCALES[pitch_index]
	mark_audio.volume_db = MARK_AUDIO_VOLUME_DB
	_set_mark_audio_foreground(true)
	_play_audio(mark_audio, stream)
	return true


func _drain_mark_audio_queue() -> void:
	if _mark_audio_draining:
		return
	if _pending_mark_audio_levels.is_empty():
		_set_mark_audio_foreground(false)
		return
	_mark_audio_draining = true
	var level: int = _pending_mark_audio_levels.pop_front()
	if not _play_mark_audio(level):
		_clear_pending_mark_audio()


func _on_mark_audio_finished() -> void:
	_mark_audio_draining = false
	_drain_mark_audio_queue()


func _clear_pending_mark_audio() -> void:
	_pending_mark_audio_levels.clear()
	_mark_audio_draining = false
	if mark_audio != null:
		mark_audio.stop()
	_set_mark_audio_foreground(false)


func _set_mark_audio_foreground(enabled: bool) -> void:
	if enabled:
		if not _mark_audio_background_volumes.is_empty():
			return
		# Keep earlier spell/pickup tails behind the count-indexed charging notes.
		for player in [cast_audio, empowered_cast_audio, orb_audio]:
			_mark_audio_background_volumes[player] = player.volume_db
			player.volume_db -= MARK_AUDIO_BACKGROUND_REDUCTION_DB
	else:
		for player in _mark_audio_background_volumes:
			if is_instance_valid(player):
				player.volume_db = float(_mark_audio_background_volumes[player])
		_mark_audio_background_volumes.clear()


func _exit_tree() -> void:
	_clear_pending_mark_audio()


func _school_attack_stream(school: StringName, position: int) -> AudioStream:
	var stream_paths: Array = SCHOOL_ATTACK_STREAM_PATHS.get(school, SCHOOL_ATTACK_STREAM_PATHS[&"fire"])
	return _load_audio_stream(str(stream_paths[clampi(position - 1, 0, stream_paths.size() - 1)]))


func _play_audio(player: AudioStreamPlayer, stream: AudioStream) -> void:
	if stream == null:
		return
	player.stream = stream
	player.play()


func _load_audio_stream(path: String) -> AudioStream:
	if path.is_empty():
		return null
	return ResourceLoader.load(path, "AudioStream") as AudioStream


func uses_combat_hit_reaction() -> bool:
	return true


func is_combat_invincible() -> bool:
	return super.is_combat_invincible() or (might != null and might.is_dodging())


func is_player_combatant() -> bool:
	return true


func get_poise() -> int:
	return int(_config["player"]["poise"])


func get_melee_snapshot() -> Dictionary:
	return combat.get_melee_snapshot()


func cancel_combat_attack() -> void:
	combat.cancel_combat_attack()


func on_clash_contact_resolved(result: HealthResult) -> void:
	combat.on_clash_contact_resolved(result)
