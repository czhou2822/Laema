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
@onready var bt_player: BTPlayer = $BTPlayer

var _ai_config: Dictionary = {}
var _stage_enabled := false
var _area_active := false
var _state := State.DORMANT
var _state_remaining := 0.0
var _windup_duration := 0.0
var _facing := Vector2.RIGHT
var _animation_time := 0.0
var _attack_flash_remaining := 0.0
var _body_rest_position := Vector2.ZERO
var _hit_visual_tween: Tween
var _hit_visual_active := false
var _hit_visual_time := 0.0
var _hit_visual_duration := 0.0
var _committed_attack_origin := Vector2.ZERO
var _committed_attack_target_position := Vector2.RIGHT


func configure(config: Dictionary) -> void:
	super.configure(config)
	_ai_config = Dictionary(config["enemy_ai"])
	warning_marker.visible = false
	attack_flash.visible = false
	body_visual.scale = Vector2.ONE
	body_visual.position = Vector2(0.0, -21.0)
	body_visual.modulate = Color("a77991")
	_body_rest_position = body_visual.position
	_sync_ai_blackboard()
	_abort_ai_tree()
	_set_state(State.DORMANT)


func apply_runtime_tuning() -> void:
	super.apply_runtime_tuning()
	_ai_config = Dictionary(_config["enemy_ai"])
	_stage_enabled = _area_active and not _defeated and bool(_ai_config["enabled"])
	_sync_ai_blackboard()
	_reset_ai_execution()
	set_collision_layer_value(4, _stage_enabled)
	set_physics_process(_stage_enabled)


func set_stage_active(active: bool) -> void:
	super.set_stage_active(active)
	_area_active = active
	_stage_enabled = _area_active and not _defeated and not _ai_config.is_empty() and bool(_ai_config["enabled"])
	_reset_ai_execution()
	set_collision_layer_value(4, _stage_enabled)
	set_physics_process(_stage_enabled)


func receive_health_result(result: HealthResult) -> void:
	super.receive_health_result(result)
	if result != null and result.event != null and result.event.target == self and result.zero_reached:
		_stage_enabled = false
		_abort_ai_tree()
		_set_state(State.DEAD)
		velocity = Vector2.ZERO
		set_collision_layer_value(4, false)
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	_update_attack_flash(delta)
	if not _stage_enabled or _state in [State.DORMANT, State.DEAD]:
		return
	var player := _get_player()
	if player == null or player.health.is_zero():
		_abort_ai_tree()
		_set_state(State.DORMANT)
		velocity = Vector2.ZERO
		set_physics_process(false)
		return
	bt_player.blackboard.set_var(&"target", player)
	# Tick once before movement; BTPlayer is configured for manual updates.
	bt_player.update(delta)
	_apply_gravity_and_move(delta)


func ai_begin_approach() -> void:
	_set_state(State.APPROACH)


func ai_move_toward(target: Entity, speed: float) -> void:
	_facing = Vector2.RIGHT if target.global_position.x >= global_position.x else Vector2.LEFT
	body_visual.flip_h = _facing.x < 0.0
	velocity.x = _facing.x * speed


func ai_stop_moving() -> void:
	velocity.x = 0.0


func ai_begin_windup(target: Entity, attack_range: float, duration: float) -> void:
	velocity.x = 0.0
	var horizontal_distance := target.global_position.x - global_position.x
	_facing = Vector2.RIGHT if horizontal_distance >= 0.0 else Vector2.LEFT
	body_visual.flip_h = _facing.x < 0.0
	_committed_attack_origin = attack_cast.global_position
	_committed_attack_target_position = _facing * attack_range
	_set_state(State.WINDUP)
	_windup_duration = duration
	_state_remaining = duration


func ai_show_windup_remaining(remaining: float) -> void:
	_state_remaining = remaining


func ai_strike(target: Entity, damage: float, impact: int) -> void:
	_resolve_melee_hit(target, damage, impact)


func ai_begin_recovery() -> void:
	velocity.x = 0.0
	_set_state(State.RECOVERY)


func ai_idle() -> void:
	velocity.x = 0.0
	if not _defeated:
		_set_state(State.IDLE)


func _sync_ai_blackboard() -> void:
	for key in _ai_config:
		if key != "enabled":
			bt_player.blackboard.set_var(StringName(key), _ai_config[key])


func _abort_ai_tree() -> void:
	var instance := bt_player.get_bt_instance()
	if instance != null:
		instance.get_root_task().abort()
	bt_player.active = false
	bt_player.blackboard.set_var(&"target", null)
	velocity.x = 0.0
	_state_remaining = 0.0


func _reset_ai_execution() -> void:
	_abort_ai_tree()
	_set_state(State.DEAD if _defeated else (State.IDLE if _stage_enabled else State.DORMANT))
	bt_player.active = _stage_enabled


func _exit_tree() -> void:
	if is_instance_valid(bt_player):
		_abort_ai_tree()


func _resolve_melee_hit(player: Entity, damage: float, impact: int) -> void:
	var live_origin := attack_cast.global_position
	var live_target_position := attack_cast.target_position
	attack_cast.global_position = _committed_attack_origin
	attack_cast.target_position = _committed_attack_target_position
	attack_cast.force_shapecast_update()
	var did_hit := false
	for index in range(attack_cast.get_collision_count()):
		if attack_cast.get_collider(index) != player:
			continue
		var event := HealthEvent.damage(
			self,
			player,
			damage,
			impact,
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
		did_hit = true
		break
	attack_cast.global_position = live_origin
	attack_cast.target_position = live_target_position
	if not did_hit:
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
		var duration := maxf(_windup_duration, 0.001)
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


func _on_reaction_started(level: int, direction: Vector2, distance: float, duration: float) -> void:
	if _state == State.DEAD:
		return
	if level > 0:
		hit_reaction_audio.play()
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
	bt_player.blackboard.set_var(&"phase", _state_name())
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
