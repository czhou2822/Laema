extends "res://scripts/enemy/enemy.gd"

const IDLE_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Idle.png")
const WALK_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Walk.png")
const ATTACK_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Attack_1.png")
const DEAD_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Dead.png")
const HURT_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Hurt.png")
const CELL_SIZE := Vector2(128.0, 128.0)
const IDLE_FRAMES := 6
const WALK_FRAMES := 12
const ATTACK_FRAMES := 4
const DEAD_FRAMES := 5
const HURT_FRAMES := 4

enum State {
	DORMANT,
	IDLE,
	APPROACH,
	WINDUP,
	RECOVERY,
	DEAD,
}

@onready var attack_cast: ShapeCast2D = $AttackCast
@onready var warning_marker: Polygon2D = $WarningMarker
@onready var attack_flash: Polygon2D = $AttackFlash

var _ai_config: Dictionary = {}
var _stage_enabled := false
var _state := State.DORMANT
var _state_remaining := 0.0
var _facing := Vector2.RIGHT
var _animation_time := 0.0
var _attack_flash_remaining := 0.0
var _body_rest_position := Vector2.ZERO
var _hit_visual_tween: Tween
var _hit_visual_active := false
var _hit_visual_time := 0.0
var _hit_visual_duration := 0.0


func configure(config: Dictionary) -> void:
	super.configure(config)
	_ai_config = Dictionary(config["enemy_ai"])
	warning_marker.visible = false
	attack_flash.visible = false
	body_visual.scale = Vector2.ONE
	body_visual.position = Vector2(0.0, -21.0)
	body_visual.modulate = Color("a77991")
	_body_rest_position = body_visual.position
	_set_state(State.DORMANT)


func apply_runtime_tuning() -> void:
	super.apply_runtime_tuning()
	_ai_config = Dictionary(_config["enemy_ai"])
	if not bool(_ai_config["enabled"]):
		_set_state(State.DORMANT)
		set_physics_process(false)


func set_stage_active(active: bool) -> void:
	super.set_stage_active(active)
	_stage_enabled = active and not _defeated and not _ai_config.is_empty() and bool(_ai_config["enabled"])
	_set_state(State.IDLE if _stage_enabled else State.DORMANT)
	set_physics_process(_stage_enabled)


func receive_health_result(result: HealthResult) -> void:
	super.receive_health_result(result)
	if result != null and result.event != null and result.event.target == self and result.zero_reached:
		_set_state(State.DEAD)
		velocity = Vector2.ZERO
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	_update_attack_flash(delta)
	if not _stage_enabled or _state in [State.DORMANT, State.DEAD]:
		return
	var player := _get_player()
	if player == null or player.health.is_zero():
		_set_state(State.DORMANT)
		velocity = Vector2.ZERO
		set_physics_process(false)
		return
	var horizontal_distance := player.global_position.x - global_position.x
	var distance := absf(horizontal_distance)
	if _state == State.IDLE:
		if distance <= float(_ai_config["aggro_range"]):
			if distance <= float(_ai_config["attack_range"]):
				_begin_windup(horizontal_distance)
			else:
				_set_state(State.APPROACH)
	elif _state == State.APPROACH:
		if distance > float(_ai_config["aggro_range"]):
			_set_state(State.IDLE)
		elif distance <= float(_ai_config["attack_range"]):
			_begin_windup(horizontal_distance)
		else:
			_facing = Vector2.RIGHT if horizontal_distance >= 0.0 else Vector2.LEFT
			body_visual.flip_h = _facing.x < 0.0
			velocity.x = _facing.x * float(_ai_config["movement_speed"])
	elif _state == State.WINDUP:
		_state_remaining = maxf(_state_remaining - delta, 0.0)
		if _state_remaining <= 0.0:
			_resolve_melee_hit(player)
			_set_state(State.RECOVERY)
			_state_remaining = float(_ai_config["recovery_duration"])
	elif _state == State.RECOVERY:
		_state_remaining = maxf(_state_remaining - delta, 0.0)
		if _state_remaining <= 0.0:
			_set_state(State.IDLE)
	_apply_gravity_and_move(delta)


func _begin_windup(horizontal_distance: float) -> void:
	velocity.x = 0.0
	_facing = Vector2.RIGHT if horizontal_distance >= 0.0 else Vector2.LEFT
	body_visual.flip_h = _facing.x < 0.0
	_set_state(State.WINDUP)
	_state_remaining = float(_ai_config["windup_duration"])


func _resolve_melee_hit(player: Entity) -> void:
	attack_cast.target_position = _facing * float(_ai_config["attack_range"])
	attack_cast.force_shapecast_update()
	for index in range(attack_cast.get_collision_count()):
		if attack_cast.get_collider(index) != player:
			continue
		var event := HealthEvent.damage(
			self,
			player,
			float(_ai_config["damage"]),
			int(_ai_config["impact"]),
			HealthEvent.Delivery.DIRECT,
			&"",
			{},
			_facing,
			attack_cast.get_collision_point(index)
		)
		player.receive_health_event(event)
		attack_flash.visible = true
		attack_flash.scale.x = _facing.x
		_attack_flash_remaining = 0.14
		_trace_ai(&"melee_hit", {"target": player.name, "damage": event.amount})
		return
	_trace_ai(&"melee_miss", {"target": player.name})


func _apply_gravity_and_move(delta: float) -> void:
	if _state != State.APPROACH:
		velocity.x = 0.0
	if not is_on_floor():
		velocity.y += float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)) * float(_config["movement"]["gravity_scale"]) * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0
	move_and_slide()


func _process(delta: float) -> void:
	var texture: Texture2D = IDLE_TEXTURE
	var frame := 0
	if _state == State.DEAD:
		_animation_time += delta
		texture = DEAD_TEXTURE
		frame = clampi(int(floor(_animation_time * 8.0)), 0, DEAD_FRAMES - 1)
	elif _hit_visual_active:
		_hit_visual_time += delta
		texture = HURT_TEXTURE
		var duration := maxf(_hit_visual_duration, 0.001)
		frame = clampi(int(floor(_hit_visual_time / duration * float(HURT_FRAMES))), 0, HURT_FRAMES - 1)
	else:
		_animation_time += delta
		frame = int(floor(_animation_time * 8.0)) % IDLE_FRAMES
	if _state == State.APPROACH and not _hit_visual_active:
		texture = WALK_TEXTURE
		frame = int(floor(_animation_time * 9.0)) % WALK_FRAMES
	elif _state == State.WINDUP and not _hit_visual_active:
		texture = ATTACK_TEXTURE
		var duration := maxf(float(_ai_config.get("windup_duration", 0.6)), 0.001)
		frame = clampi(int(floor((1.0 - _state_remaining / duration) * float(ATTACK_FRAMES))), 0, ATTACK_FRAMES - 1)
	body_visual.texture = texture
	body_visual.region_enabled = true
	body_visual.region_rect = Rect2(Vector2(frame, 0.0) * CELL_SIZE, CELL_SIZE)
	body_visual.flip_h = _facing.x < 0.0


func _update_attack_flash(delta: float) -> void:
	if _attack_flash_remaining <= 0.0:
		return
	_attack_flash_remaining = maxf(_attack_flash_remaining - delta, 0.0)
	if _attack_flash_remaining <= 0.0:
		attack_flash.visible = false


func _on_reaction_started(_level: int, direction: Vector2, distance: float, duration: float) -> void:
	if _state == State.DEAD:
		return
	if _hit_visual_tween != null and _hit_visual_tween.is_valid():
		_hit_visual_tween.kill()
	_hit_visual_active = true
	_hit_visual_time = 0.0
	_hit_visual_duration = duration
	body_visual.position = _body_rest_position
	var offset := direction.normalized() * distance
	_hit_visual_tween = create_tween()
	_hit_visual_tween.tween_property(body_visual, "position", _body_rest_position + offset, duration * 0.4)
	_hit_visual_tween.tween_property(body_visual, "position", _body_rest_position, duration * 0.6)
	_hit_visual_tween.tween_callback(_finish_hit_visual)


func _finish_hit_visual() -> void:
	_hit_visual_active = false
	_hit_visual_time = 0.0
	_hit_visual_duration = 0.0
	body_visual.position = _body_rest_position


func _get_player() -> Entity:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	return scene.get_node_or_null("Player") as Entity


func _set_state(next_state: State) -> void:
	if _state == next_state:
		return
	_state = next_state
	_animation_time = 0.0
	warning_marker.visible = _state == State.WINDUP
	if _state in [State.DORMANT, State.DEAD]:
		attack_flash.visible = false
		_attack_flash_remaining = 0.0
	_trace_ai(&"state", {"state": _state_name(), "target_distance": _distance_to_player()})


func _state_name() -> StringName:
	return StringName(["DORMANT", "IDLE", "APPROACH", "WINDUP", "RECOVERY", "DEAD"][_state])


func _distance_to_player() -> float:
	var player := _get_player()
	return absf(player.global_position.x - global_position.x) if player != null else -1.0


func _trace_ai(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][COMBAT_ENEMY] %s %s" % [event_name, data])
