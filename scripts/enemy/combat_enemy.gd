extends "res://scripts/enemy/enemy.gd"

const IDLE_TEXTURE = preload("res://assets/prototype/enemy/pikeman/repaint_v02/idle_right_sheet.png")
const WALK_TEXTURE = preload("res://assets/prototype/enemy/pikeman/repaint_v02/walk_right_sheet.png")
const DEAD_TEXTURE = preload("res://assets/prototype/enemy/pikeman/repaint_v02/death_right_sheet.png")
const HURT_TEXTURE = preload("res://assets/prototype/enemy/pikeman/repaint_v02/hurt_right_sheet.png")
const ImpactProbe = preload("res://scripts/debug/impact_probe.gd")
const Geometry = preload("res://scripts/combat/attack_geometry.gd")
const Contacts = preload("res://scripts/combat/contact_evaluation.gd")
const CELL_SIZE := Vector2(768.0, 512.0)
const SHEET_COLUMNS := 4
const IDLE_FRAMES := 7
const WALK_FRAMES := 6
const DEAD_FRAMES := 5
const HURT_FRAMES := 6

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

@export var settings: EnemyCombatSettings

@onready var attack_cast: ShapeCast2D = $AttackCast
@onready var warning_marker: Polygon2D = $WarningMarker
@onready var attack_flash: Polygon2D = $AttackFlash
@onready var bt_player: BTPlayer = $BTPlayer
@onready var attack_animation: AnimationPlayer = $AnimationPlayer
@onready var pikeman_attack_audio: AudioStreamPlayer = $PikemanAttackAudio
@onready var pikeman_death_audio: AudioStreamPlayer = $PikemanDeathAudio
@onready var pikeman_movement_audio: AudioStreamPlayer = $PikemanMovementAudio
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
var _next_attack_id := 1
var _attack_id := 0
var _hit_targets: Array[int] = []
var _ticking_tree := false
var _preempt_requested := false
var _pending_hit_reaction: Dictionary = {}
var _reaction_probe_origin := Vector2.ZERO
var _reaction_probe_started_ms := 0
var _walking_audio_active := false
var _death_audio_played := false
var _geometry_clock: Animation
var _sample_action_id := 0
var _sample_time := 0.0
var _window_finished := false
var _frame_action_id := 0
var _physics_action_id := 0
var _defer_tree_tick := false


func configure(config: Dictionary) -> void:
	if settings != null:
		settings.read_from_config(config)
		settings.hit_reaction.read_from_config(config)
	super.configure(config)
	_stop_pikeman_audio()
	_death_audio_played = false
	if not pikeman_movement_audio.finished.is_connected(_on_movement_audio_finished):
		pikeman_movement_audio.finished.connect(_on_movement_audio_finished)
	Contacts.register(self)
	Geometry.make_private(attack_animation)
	Geometry.set_active_size(attack_animation.get_animation(&"melee_swing"), float(config["enemy_ai"]["hitbox_reach"]), float(config["enemy_ai"]["hitbox_radius"]))
	hit_reaction.reaction_ended.connect(_finish_hit_visual)
	_ai_config = Dictionary(config["enemy_ai"]).duplicate(true)
	warning_marker.visible = false
	attack_flash.visible = false
	body_visual.modulate = Color.WHITE
	# Capture the scene-authored rest pose for reaction and stage reset recovery.
	_body_rest_position = body_visual.position
	_sync_ai_blackboard()
	_abort_ai_tree()
	_set_state(State.DORMANT)


func apply_runtime_tuning() -> void:
	if settings != null:
		settings.read_from_config(_config)
		settings.hit_reaction.read_from_config(_config)
	super.apply_runtime_tuning()
	var next_ai: Dictionary = _config["enemy_ai"]
	var decision_tuning_changed := false
	for key in ["enabled", "aggro_range", "attack_range", "movement_speed", "damage"]:
		if _ai_config.get(key) != next_ai.get(key):
			decision_tuning_changed = true
	_ai_config = next_ai.duplicate(true)
	Geometry.set_active_size(attack_animation.get_animation(&"melee_swing"), float(_ai_config["hitbox_reach"]), float(_ai_config["hitbox_radius"]))
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
	if result == null or result.event == null:
		return
	if (
		result.event.instigator == self
		and result.event.fire_defence
		and result.outcome == HealthResult.Outcome.PARRIED
	):
		if not _defeated and not hit_reaction.is_invincible() and not has_pending_combat_hit_reaction():
			cancel_combat_attack()
			# Zero selects the existing Level 1 profile; this is not counterdamage.
			request_combat_hit_reaction(0, -result.event.contact_direction)
		return
	if result.event.target != self:
		return
	if result.zero_reached and not should_refill_health_at_zero():
		_stage_enabled = false
		_pending_hit_reaction.clear()
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
		_pending_hit_reaction.clear()
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
	# Reassess facing between actions, never during a committed attack/recovery.
	if _state in [State.IDLE, State.APPROACH] and absf(player.global_position.x - global_position.x) <= float(_ai_config["aggro_range"]):
		_facing = Vector2.RIGHT if player.global_position.x >= global_position.x else Vector2.LEFT
		_update_visual_facing()
	bt_player.blackboard.set_var(&"target", player)
	_physics_action_id = _attack_id
	_defer_tree_tick = attack_animation.is_playing()
	if not _defer_tree_tick:
		_update_ai_tree(delta)
	if _state == State.DEAD:
		return
	_apply_gravity_and_move(delta)


func _update_ai_tree(delta: float) -> void:
	_ticking_tree = true
	bt_player.update(delta)
	_ticking_tree = false
	if _preempt_requested:
		_preempt_requested = false
		_abort_ai_tree()
		bt_player.active = _stage_enabled
		if has_pending_combat_hit_reaction() and not _defeated:
			# Finish the abandoned task before dispatching a reaction requested inside it.
			_update_ai_tree(0.0)
		elif hit_reaction.is_invincible():
			_set_state(State.HIT_REACTING)


func ai_begin_approach() -> void:
	_set_state(State.APPROACH)


func ai_move_toward(target: Entity, speed: float) -> void:
	_facing = Vector2.RIGHT if target.global_position.x >= global_position.x else Vector2.LEFT
	_update_visual_facing()
	velocity.x = _facing.x * speed


func ai_stop_moving() -> void:
	velocity.x = 0.0
	_stop_movement_audio()


func contact_evaluation_enabled() -> bool:
	return is_physics_processing() and _area_active and not _defeated


func begin_contact_frame() -> void:
	# A windup created by this frame's BT tick starts advancing next frame,
	# as it did when the actor advanced its clock before ticking the tree.
	_frame_action_id = _physics_action_id


func finish_contact_frame(delta: float) -> void:
	if _defer_tree_tick and _stage_enabled and not _defeated:
		_defer_tree_tick = false
		_update_ai_tree(delta)


func contact_step_limit(limit: float) -> float:
	if _attack_id != _frame_action_id or not attack_animation.is_playing():
		return limit
	return Geometry.step_limit(attack_animation.get_animation(&"melee_swing"), attack_animation.current_animation_position, 1.0, limit)


func advance_contact_clock(delta: float) -> void:
	_sample_action_id = 0
	if _attack_id != _frame_action_id or not attack_animation.is_playing():
		return
	var clock: Animation = attack_animation.get_animation(&"melee_swing")
	_sample_action_id = _attack_id
	_sample_time = minf(attack_animation.current_animation_position + delta, clock.length)
	attack_animation.advance(delta)
	if _attack_id != 0 and _sample_time >= clock.get_marker_time(&"active_start") and _sample_time <= clock.get_marker_time(&"active_end"):
		_set_state(State.ACTIVE)


func finish_contact_sample() -> void:
	if _attack_id == 0 or _attack_id != _sample_action_id or _window_finished:
		return
	if _sample_time >= _geometry_clock.get_marker_time(&"active_end"):
		_window_finished = true
		if _hit_targets.is_empty():
			var target := _get_player()
			_trace_ai(&"melee_miss", {"target": target.name if target != null else &""})


func ai_begin_windup(target: Entity) -> void:
	velocity.x = 0.0
	var horizontal_distance := target.global_position.x - global_position.x
	_facing = Vector2.RIGHT if horizontal_distance >= 0.0 else Vector2.LEFT
	_update_visual_facing()
	_attack_id = _next_attack_id
	_next_attack_id += 1
	_hit_targets.clear()
	_window_finished = false
	var clock: Animation = attack_animation.get_animation(&"melee_swing")
	attack_animation.speed_scale = 1.0
	attack_animation.play(&"melee_swing")
	attack_animation.advance(0.0)
	_geometry_clock = clock.duplicate()
	_sample_action_id = _attack_id
	_sample_time = 0.0
	_set_state(State.WINDUP)
	pikeman_attack_audio.play()


func ai_windup_finished() -> bool:
	return not attack_animation.is_playing() or attack_animation.current_animation_position >= attack_animation.get_animation(&"melee_swing").get_marker_time(&"active_start")


func ai_strike(_target: Entity, _damage: float, _impact: int) -> bool:
	if _state == State.HIT_REACTING or hit_reaction.is_invincible():
		return false
	_set_state(State.ACTIVE)
	# The shared sample barrier performs geometry detection and resolution.
	return true


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
	pikeman_attack_audio.stop()
	_stop_movement_audio()
	var instance := bt_player.get_bt_instance()
	if instance != null:
		instance.get_root_task().abort()
	bt_player.active = false
	bt_player.blackboard.set_var(&"target", null)
	velocity.x = 0.0


func _reset_ai_execution() -> void:
	_stop_pikeman_audio()
	if not _defeated:
		_death_audio_played = false
	_pending_hit_reaction.clear()
	hit_reaction.reset_for_stage()
	health_resolver.reset_for_stage()
	_finish_hit_visual()
	attack_animation.stop()
	_attack_id = 0
	_preempt_requested = false
	_abort_ai_tree()
	_set_state(State.DEAD if _defeated else (State.IDLE if _stage_enabled else State.DORMANT))
	bt_player.active = _stage_enabled


func _exit_tree() -> void:
	_stop_pikeman_audio()
	_pending_hit_reaction.clear()
	if is_instance_valid(bt_player):
		hit_reaction.reset_for_stage()
		health_resolver.reset_for_stage()
		_abort_ai_tree()


func get_attack_geometry() -> Dictionary:
	var time := _sample_time if _sample_action_id == _attack_id else attack_animation.current_animation_position
	var pose := Geometry.sample(_geometry_clock, time)
	# The atlas mirrors around BodyVisual's foot anchor, not the actor root.
	var pivot := Vector2(body_visual.position.x, 0.0)
	pose["position"] = Vector2(pose["position"]) - pivot
	pose = Geometry.facing_pose(pose, _facing)
	pose["position"] = Vector2(pose["position"]) + pivot
	return pose


func collect_melee_contacts() -> Array[HealthEvent]:
	var events: Array[HealthEvent] = []
	if _attack_id != _frame_action_id or not bool(get_melee_snapshot().get("active", false)):
		return events
	var player := _get_player()
	if player == null or _hit_targets.has(player.get_instance_id()):
		return events
	var pose := get_attack_geometry()
	var live_origin := attack_cast.position
	var live_target_position := attack_cast.target_position
	var live_radius := (attack_cast.shape as CircleShape2D).radius
	attack_cast.position = pose["position"]
	attack_cast.target_position = pose["target"]
	(attack_cast.shape as CircleShape2D).radius = float(pose["radius"])
	attack_cast.force_shapecast_update()
	for index in range(attack_cast.get_collision_count()):
		if attack_cast.get_collider(index) != player:
			continue
		_hit_targets.append(player.get_instance_id())
		var event := HealthEvent.damage(self, player, float(_ai_config["damage"]), int(_config["moves"]["final_enemy_attack"]["impact"]), HealthEvent.Delivery.DIRECT, &"", {}, _facing, attack_cast.get_collision_point(index), _attack_id)
		event.melee_contact = true
		events.append(event)
		break
	attack_cast.position = live_origin
	attack_cast.target_position = live_target_position
	(attack_cast.shape as CircleShape2D).radius = live_radius
	return events


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
	var movement_start_x := global_position.x
	move_and_slide()
	_sync_movement_audio(absf(global_position.x - movement_start_x) > 0.001)
	if reacting:
		hit_reaction.finish_body_motion()


func _process(delta: float) -> void:
	queue_redraw()
	if _state in [State.WINDUP, State.ACTIVE, State.RECOVERY] and not _hit_visual_active:
		# AnimationPlayer owns attack artwork and geometry, including editor preview.
		_update_visual_facing()
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
	var cell := Vector2(frame % SHEET_COLUMNS, floori(float(frame) / float(SHEET_COLUMNS)))
	body_visual.region_rect = Rect2(cell * CELL_SIZE, CELL_SIZE)
	_update_visual_facing()


func _update_visual_facing() -> void:
	body_visual.flip_h = _facing.x < 0.0
	# Right atlases mirror once around the cell-centered X feet anchor (384).
	# The scene's zero horizontal offset therefore needs no facing correction.


func _draw() -> void:
	if _config.is_empty() or not bool(_config["ui"]["attack_hitbox_visible"]):
		return
	var snapshot := get_melee_snapshot()
	if snapshot.is_empty() or not bool(snapshot["active"]):
		return
	var pose := get_attack_geometry()
	var start: Vector2 = pose["position"]
	var end := start + Vector2(pose["target"])
	var radius := float(pose["radius"])
	if radius <= 0.0:
		return
	# Match the current animated query pose, including facing.
	var steps := maxi(2, int(start.distance_to(end) / (Vector2.ONE * radius * 2.0).length() * 4.0))
	for index in range(steps + 1):
		var center := start.lerp(end, float(index) / steps)
		draw_circle(center, radius, Color(1.0, 0.78, 0.12, 0.24))
		draw_arc(center, radius, 0.0, TAU, 32, Color(1.0, 0.9, 0.35, 0.95), 1.0, true)


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
		pikeman_attack_audio.stop()
		_stop_movement_audio()
		hit_reaction_audio.play()
	if _hit_visual_tween != null and _hit_visual_tween.is_valid():
		_hit_visual_tween.kill()
	_hit_visual_active = true
	_hit_visual_time = 0.0
	_hit_visual_duration = duration
	body_visual.position = _body_rest_position
	if hit_reaction.is_invincible():
		# Resolver cancellation precedes the tree's reaction action. Direct component
		# calls still cancel an outstanding attack, without aborting the reaction task.
		if _attack_id != 0 or attack_animation.is_playing():
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
	if _state != State.APPROACH:
		_stop_movement_audio()
	if _state == State.DEAD:
		_stop_pikeman_audio()
		if not _death_audio_played:
			_death_audio_played = true
			pikeman_death_audio.play()
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
	var time := _sample_time if _sample_action_id == _attack_id else attack_animation.current_animation_position
	return {
		"active": not _window_finished and _attack_id != 0 and time >= clock.get_marker_time(&"active_start") and time <= clock.get_marker_time(&"active_end"),
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
	pikeman_attack_audio.stop()
	attack_animation.stop()
	_attack_id = 0
	attack_flash.visible = false
	_attack_flash_remaining = 0.0
	_set_state(State.HIT_REACTING)
	if _ticking_tree:
		_preempt_requested = true
	else:
		_abort_ai_tree()
		bt_player.active = _stage_enabled


func ai_is_reacting() -> bool:
	return has_pending_combat_hit_reaction() or hit_reaction.is_invincible()


func has_pending_combat_hit_reaction() -> bool:
	return not _pending_hit_reaction.is_empty()


func request_combat_hit_reaction(difference: int, direction: Vector2, push_scale: float = 1.0) -> void:
	if _defeated or hit_reaction.is_invincible() or has_pending_combat_hit_reaction():
		return
	_pending_hit_reaction = hit_reaction.capture_combat(difference, direction, push_scale)
	if not _ticking_tree:
		# Dispatch at contact, including while offensive AI is disabled. No extra
		# frame or separate timer is added to the captured combat reaction.
		bt_player.active = true
		_update_ai_tree(0.0)
		bt_player.active = _stage_enabled


func ai_execute_hit_reaction() -> void:
	if not has_pending_combat_hit_reaction():
		return
	var reaction := _pending_hit_reaction
	_pending_hit_reaction = {}
	hit_reaction.execute_captured_combat(reaction)


func ai_hold_hit_reaction() -> void:
	_set_state(State.HIT_REACTING)
	velocity.x = 0.0


func on_clash_contact_resolved(result: HealthResult) -> void:
	if result.outcome != HealthResult.Outcome.APPLIED or result.event.source_action_id != _attack_id:
		return
	attack_flash.visible = true
	attack_flash.scale.x = _facing.x
	_attack_flash_remaining = 0.14
	_trace_ai(&"melee_hit", {"target": result.event.target.name, "damage": result.event.amount})


func _sync_movement_audio(moved_horizontally: bool) -> void:
	_walking_audio_active = moved_horizontally and _area_active and _stage_enabled and _state == State.APPROACH and not hit_reaction.is_active()
	if not _walking_audio_active:
		pikeman_movement_audio.stop()
	elif not pikeman_movement_audio.playing:
		pikeman_movement_audio.play()


func _on_movement_audio_finished() -> void:
	_sync_movement_audio(_walking_audio_active)


func _stop_movement_audio() -> void:
	_walking_audio_active = false
	if is_instance_valid(pikeman_movement_audio):
		pikeman_movement_audio.stop()


func _stop_pikeman_audio() -> void:
	_stop_movement_audio()
	for audio in [pikeman_attack_audio, pikeman_death_audio, hit_reaction_audio]:
		if is_instance_valid(audio):
			audio.stop()
