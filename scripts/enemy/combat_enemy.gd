extends "res://scripts/enemy/enemy.gd"

const IDLE_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Idle.png")
const WALK_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Walk.png")
const DEAD_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Dead.png")
const HURT_TEXTURE = preload("res://assets/prototype/enemy/medieval_fighter/Hurt.png")
const ImpactProbe = preload("res://scripts/debug/impact_probe.gd")
const Geometry = preload("res://scripts/combat/attack_geometry.gd")
const CELL_SIZE := Vector2(128.0, 128.0)
const IDLE_FRAMES := 6
const WALK_FRAMES := 12
const DEAD_FRAMES := 5
const HURT_FRAMES := 4

enum State {
	DORMANT,
	IDLE,
	APPROACH,
	WINDUP,
	ACTIVE,
	HIT_REACTING,
	RECOVERY,
	DEAD,
}

@onready var attack_cast: ShapeCast2D = $AttackCast
@onready var warning_marker: Polygon2D = $WarningMarker
@onready var attack_flash: Polygon2D = $AttackFlash
@onready var bt_player: BTPlayer = $BTPlayer
@onready var attack_animation: AnimationPlayer = $AnimationPlayer
# StageArea prepares children before configure(); its reset needs the saved pose.
@onready var _body_rest_position: Vector2 = $BodyVisual.position

var _ai_config: Dictionary = {}
var _stage_enabled := false
var _area_active := false
var _state := State.DORMANT
var _facing := Vector2.RIGHT
var _animation_time := 0.0
var _attack_flash_remaining := 0.0
var _hit_visual_tween: Tween
var _hit_visual_active := false
var _hit_visual_time := 0.0
var _hit_visual_duration := 0.0
var _committed_attack_origin := Vector2.ZERO
var _committed_attack_target_position := Vector2.RIGHT
var _committed_attack_radius := 24.0
var _next_attack_id := 1
var _attack_id := 0
var _strike_emitted := false
var _hit_targets: Array[int] = []
var _ticking_tree := false
var _preempt_requested := false
var _reaction_probe_origin := Vector2.ZERO
var _reaction_probe_started_ms := 0


func configure(config: Dictionary) -> void:
	super.configure(config)
	Geometry.make_private(attack_animation)
	Geometry.set_contact_size(attack_animation.get_animation(&"melee_swing"), float(config["enemy_ai"]["hitbox_reach"]), float(config["enemy_ai"]["hitbox_radius"]))
	hit_reaction.reaction_ended.connect(_finish_hit_visual)
	_ai_config = Dictionary(config["enemy_ai"])
	warning_marker.visible = false
	attack_flash.visible = false
	body_visual.modulate = Color("a77991")
	# Capture the scene-authored rest pose for reaction and stage reset recovery.
	_body_rest_position = body_visual.position
	_sync_ai_blackboard()
	_abort_ai_tree()
	_set_state(State.DORMANT)


func apply_runtime_tuning() -> void:
	super.apply_runtime_tuning()
	var next_ai: Dictionary = _config["enemy_ai"]
	var decision_tuning_changed := false
	for key in ["enabled", "aggro_range", "attack_range", "movement_speed", "damage"]:
		if _ai_config.get(key) != next_ai.get(key):
			decision_tuning_changed = true
	_ai_config = next_ai.duplicate(true)
	Geometry.set_contact_size(attack_animation.get_animation(&"melee_swing"), float(_ai_config["hitbox_reach"]), float(_ai_config["hitbox_radius"]))
	_sync_ai_blackboard()
	if not decision_tuning_changed:
		return
	_stage_enabled = _area_active and not _defeated and bool(_ai_config["enabled"])
	_reset_ai_execution()
	set_collision_layer_value(4, _stage_enabled)
	set_physics_process(_area_active and not _defeated)


func set_stage_active(active: bool) -> void:
	super.set_stage_active(active)
	_area_active = active
	_stage_enabled = _area_active and not _defeated and not _ai_config.is_empty() and bool(_ai_config["enabled"])
	_reset_ai_execution()
	set_collision_layer_value(4, _stage_enabled)
	set_physics_process(_area_active and not _defeated)


func receive_health_result(result: HealthResult) -> void:
	super.receive_health_result(result)
	if result == null or result.event == null or result.event.target != self:
		return
	if result.zero_reached and not should_refill_health_at_zero():
		_stage_enabled = false
		hit_reaction.reset_for_stage()
		health_resolver.reset_for_stage()
		attack_animation.stop()
		_attack_id = 0
		if _ticking_tree:
			_preempt_requested = true
		else:
			_abort_ai_tree()
		_set_state(State.DEAD)
		velocity = Vector2.ZERO
		set_collision_layer_value(4, false)
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	_update_attack_flash(delta)
	if _state == State.DEAD:
		return
	if not _stage_enabled:
		# Disabling decisions does not freeze a later combat reaction's lifetime.
		if hit_reaction.is_invincible():
			_apply_gravity_and_move(delta)
		else:
			_set_state(State.DORMANT)
		return
	if _state == State.DORMANT:
		return
	var player := _get_player()
	if player == null or player.health.is_zero():
		hit_reaction.reset_for_stage()
		health_resolver.reset_for_stage()
		attack_animation.stop()
		_attack_id = 0
		_finish_hit_visual()
		_abort_ai_tree()
		_set_state(State.DORMANT)
		_stage_enabled = false
		velocity = Vector2.ZERO
		set_physics_process(_area_active and not _defeated)
		return
	bt_player.blackboard.set_var(&"target", player)
	if attack_animation.is_playing():
		_advance_attack(delta, player)
	_ticking_tree = true
	bt_player.update(delta)
	_ticking_tree = false
	if _preempt_requested:
		_preempt_requested = false
		_abort_ai_tree()
		bt_player.active = _stage_enabled
		if hit_reaction.is_invincible():
			_set_state(State.HIT_REACTING)
	if _state == State.DEAD:
		return
	_apply_gravity_and_move(delta)


func ai_begin_approach() -> void:
	_set_state(State.APPROACH)


func ai_move_toward(target: Entity, speed: float) -> void:
	_facing = Vector2.RIGHT if target.global_position.x >= global_position.x else Vector2.LEFT
	body_visual.flip_h = _facing.x < 0.0
	velocity.x = _facing.x * speed


func ai_stop_moving() -> void:
	velocity.x = 0.0


func _advance_attack(delta: float, player: Entity) -> void:
	var clock: Animation = attack_animation.get_animation(&"melee_swing")
	var contact_time := clock.get_marker_time(&"contact")
	var time := attack_animation.current_animation_position
	var action_id := _attack_id
	var advanced := 0.0
	# Visit contact before advancing past the active interval or animation end.
	if action_id != 0 and not _strike_emitted and (time >= contact_time or time + delta >= contact_time):
		advanced = clampf(contact_time - time, 0.0, delta)
		attack_animation.advance(advanced)
		if not ai_strike(player, float(_ai_config["damage"]), int(_config["moves"]["final_enemy_attack"]["impact"])):
			return
	if _attack_id != action_id:
		return
	attack_animation.advance(maxf(delta - advanced, 0.0))


func ai_begin_windup(target: Entity) -> void:
	velocity.x = 0.0
	var horizontal_distance := target.global_position.x - global_position.x
	_facing = Vector2.RIGHT if horizontal_distance >= 0.0 else Vector2.LEFT
	body_visual.flip_h = _facing.x < 0.0
	_attack_id = _next_attack_id
	_next_attack_id += 1
	_hit_targets.clear()
	_strike_emitted = false
	var clock: Animation = attack_animation.get_animation(&"melee_swing")
	attack_animation.speed_scale = 1.0
	attack_animation.play(&"melee_swing")
	attack_animation.advance(0.0)
	var pose := Geometry.facing_pose(Geometry.contact(clock), _facing)
	_committed_attack_origin = to_global(pose["position"])
	_committed_attack_target_position = pose["target"]
	_committed_attack_radius = float(pose["radius"])
	_set_state(State.WINDUP)


func ai_windup_finished() -> bool:
	return not attack_animation.is_playing() or attack_animation.current_animation_position >= attack_animation.get_animation(&"melee_swing").get_marker_time(&"active_start")


func ai_strike(target: Entity, damage: float, _impact: int) -> bool:
	if _state == State.HIT_REACTING or hit_reaction.is_invincible():
		return false
	_set_state(State.ACTIVE)
	var clock: Animation = attack_animation.get_animation(&"melee_swing")
	var time := attack_animation.current_animation_position
	if not _strike_emitted and time >= clock.get_marker_time(&"contact"):
		_strike_emitted = true
		_resolve_melee_hit(target, damage, int(_config["moves"]["final_enemy_attack"]["impact"]))
	return _state != State.HIT_REACTING


func ai_strike_finished() -> bool:
	return not attack_animation.is_playing() or attack_animation.current_animation_position >= attack_animation.get_animation(&"melee_swing").get_marker_time(&"active_end")


func ai_begin_recovery() -> void:
	_attack_id = 0
	velocity.x = 0.0
	_set_state(State.RECOVERY)


func ai_recovery_finished() -> bool:
	return not attack_animation.is_playing() or attack_animation.current_animation_position >= attack_animation.get_animation(&"melee_swing").length


func ai_idle() -> void:
	velocity.x = 0.0
	if not _defeated:
		_set_state(State.IDLE)


func _sync_ai_blackboard() -> void:
	for key in _ai_config:
		if key not in ["enabled", "windup_duration", "recovery_duration"]:
			bt_player.blackboard.set_var(StringName(key), _ai_config[key])


func _abort_ai_tree() -> void:
	var instance := bt_player.get_bt_instance()
	if instance != null:
		instance.get_root_task().abort()
	bt_player.active = false
	bt_player.blackboard.set_var(&"target", null)
	velocity.x = 0.0


func _reset_ai_execution() -> void:
	hit_reaction.reset_for_stage()
	health_resolver.reset_for_stage()
	_finish_hit_visual()
	attack_animation.stop()
	_attack_id = 0
	_strike_emitted = false
	_preempt_requested = false
	_abort_ai_tree()
	_set_state(State.DEAD if _defeated else (State.IDLE if _stage_enabled else State.DORMANT))
	bt_player.active = _stage_enabled


func _exit_tree() -> void:
	if is_instance_valid(bt_player):
		hit_reaction.reset_for_stage()
		health_resolver.reset_for_stage()
		_abort_ai_tree()


func _resolve_melee_hit(player: Entity, damage: float, impact: int) -> void:
	var live_origin := attack_cast.global_position
	var live_target_position := attack_cast.target_position
	var live_radius := (attack_cast.shape as CircleShape2D).radius
	attack_cast.global_position = _committed_attack_origin
	attack_cast.target_position = _committed_attack_target_position
	(attack_cast.shape as CircleShape2D).radius = _committed_attack_radius
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
		event.source_action_id = _attack_id
		event.melee_contact = true
		var result: HealthResult = player.receive_health_event(event)
		if result.outcome != HealthResult.Outcome.APPLIED:
			break
		_hit_targets.append(player.get_instance_id())
		attack_flash.visible = true
		attack_flash.scale.x = _facing.x
		_attack_flash_remaining = 0.14
		_trace_ai(&"melee_hit", {"target": player.name, "damage": event.amount})
		did_hit = true
		break
	attack_cast.global_position = live_origin
	attack_cast.target_position = live_target_position
	(attack_cast.shape as CircleShape2D).radius = live_radius
	if not did_hit:
		_trace_ai(&"melee_miss", {"target": player.name})


func _apply_gravity_and_move(delta: float) -> void:
	var reacting := hit_reaction.is_invincible()
	var push := hit_reaction.consume_body_motion(delta) if reacting else Vector2.ZERO
	if reacting:
		velocity.x = push.x / delta if delta > 0.0 else 0.0
	elif _state != State.APPROACH:
		velocity.x = 0.0
	if not is_on_floor():
		velocity.y += float(ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)) * float(_config["movement"]["gravity_scale"]) * delta
	elif velocity.y > 0.0:
		velocity.y = 0.0
	move_and_slide()
	if reacting:
		hit_reaction.finish_body_motion()


func _process(delta: float) -> void:
	if _state in [State.WINDUP, State.ACTIVE, State.RECOVERY] and not _hit_visual_active:
		# AnimationPlayer owns attack artwork and geometry, including editor preview.
		body_visual.flip_h = _facing.x < 0.0
		return
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
	_reaction_probe_origin = global_position
	_reaction_probe_started_ms = Time.get_ticks_msec()
	ImpactProbe.record("enemy_reaction_visual", {"target": str(get_path()), "reaction_level": level, "duration": duration, "distance": distance, "combat_reaction": hit_reaction.is_invincible()})
	if level > 0:
		hit_reaction_audio.play()
	if _hit_visual_tween != null and _hit_visual_tween.is_valid():
		_hit_visual_tween.kill()
	_hit_visual_active = true
	_hit_visual_time = 0.0
	_hit_visual_duration = duration
	body_visual.position = _body_rest_position
	if hit_reaction.is_invincible():
		cancel_combat_attack()
	else:
		var offset := direction.normalized() * distance
		_hit_visual_tween = create_tween()
		_hit_visual_tween.tween_property(body_visual, "position", _body_rest_position + offset, duration * 0.4)
		_hit_visual_tween.tween_property(body_visual, "position", _body_rest_position, duration * 0.6)
		_hit_visual_tween.tween_callback(_finish_hit_visual)


func _finish_hit_visual() -> void:
	if _hit_visual_active:
		ImpactProbe.record("enemy_reaction_finished", {"target": str(get_path()), "body_displacement_x": global_position.x - _reaction_probe_origin.x, "elapsed_ms": Time.get_ticks_msec() - _reaction_probe_started_ms, "remaining": hit_reaction.get("_remaining")})
	if _hit_visual_tween != null and _hit_visual_tween.is_valid():
		_hit_visual_tween.kill()
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
	return StringName(["DORMANT", "IDLE", "APPROACH", "WINDUP", "ACTIVE", "HIT_REACTING", "RECOVERY", "DEAD"][_state])


func _distance_to_player() -> float:
	var player := _get_player()
	return absf(player.global_position.x - global_position.x) if player != null else -1.0


func _trace_ai(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][COMBAT_ENEMY] %s %s" % [event_name, data])


func uses_combat_hit_reaction() -> bool:
	return true


func get_poise() -> int:
	return int(_config["enemy_ai"]["poise"])


func get_melee_snapshot() -> Dictionary:
	if _attack_id == 0 or _state not in [State.WINDUP, State.ACTIVE]:
		return {}
	var clock: Animation = attack_animation.get_animation(&"melee_swing")
	var time := attack_animation.current_animation_position
	return {
		"active": attack_animation.is_playing() and time >= clock.get_marker_time(&"active_start") and time <= clock.get_marker_time(&"active_end"),
		"move_id": &"final_enemy_attack",
		"impact": int(_config["moves"]["final_enemy_attack"]["impact"]),
		"damage": float(_ai_config["damage"]),
		"school": &"",
		"action_id": _attack_id,
		"composition": [],
		"hit_targets": _hit_targets.duplicate(),
	}


func cancel_combat_attack() -> void:
	if _state == State.DEAD:
		return
	attack_animation.stop()
	_attack_id = 0
	_strike_emitted = true
	_committed_attack_origin = Vector2.ZERO
	_committed_attack_target_position = Vector2.ZERO
	attack_flash.visible = false
	_attack_flash_remaining = 0.0
	_set_state(State.HIT_REACTING)
	if _ticking_tree:
		_preempt_requested = true
	else:
		_abort_ai_tree()
		bt_player.active = _stage_enabled


func ai_is_reacting() -> bool:
	return hit_reaction.is_invincible()


func ai_hold_hit_reaction() -> void:
	_set_state(State.HIT_REACTING)
	velocity.x = 0.0


func on_clash_contact_resolved(result: HealthResult) -> void:
	if result.outcome == HealthResult.Outcome.APPLIED:
		_hit_targets.append(result.event.target.get_instance_id())
		_strike_emitted = true
