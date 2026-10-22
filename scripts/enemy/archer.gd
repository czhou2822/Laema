extends "res://scripts/enemy/combat_enemy.gd"
## Castle Archer: choose melee or one committed, straight shot at attack start.

const ArrowScene = preload("res://scenes/combat/enemy_arrow.tscn")

@export var ranged_projectile_scene: PackedScene = ArrowScene
@export_range(0.05, 5.0, 0.05) var arrow_travel_duration := 1.0
@export var arrow_origin := Vector2(64.0, -108.0)

var _shooting := false
var _arrow_released := false
var _shot_damage := 0.0
var _shot_impact := 0
var _shot_distance := 0.0
var _shot_duration := 1.0


func _sync_ai_blackboard() -> void:
	super._sync_ai_blackboard()
	# The saved attack_range remains the close-range melee threshold. The same
	# approach tree permits a shot anywhere inside the existing awareness range.
	bt_player.blackboard.set_var(&"attack_range", float(_ai_config["aggro_range"]))


func ai_begin_windup(target: Entity) -> void:
	_shooting = absf(target.global_position.x - global_position.x) > float(_ai_config["attack_range"])
	_arrow_released = false
	if not _shooting:
		super.ai_begin_windup(target)
		return
	velocity.x = 0.0
	_facing = Vector2.RIGHT if target.global_position.x >= global_position.x else Vector2.LEFT
	_update_visual_facing()
	_attack_id = _next_attack_id
	_next_attack_id += 1
	_hit_targets.clear()
	_window_finished = false
	_shot_damage = float(_ai_config["damage"])
	_shot_impact = int(_config["moves"]["final_enemy_attack"]["impact"])
	_shot_distance = float(_ai_config["aggro_range"])
	_shot_duration = maxf(arrow_travel_duration, 0.05)
	var clock: Animation = attack_animation.get_animation(&"archer_shoot")
	attack_animation.speed_scale = 1.0
	attack_animation.play(&"archer_shoot")
	attack_animation.advance(0.0)
	_geometry_clock = clock.duplicate()
	_sample_action_id = _attack_id
	_sample_time = 0.0
	_set_state(State.WINDUP)


func contact_step_limit(limit: float) -> float:
	if not _shooting:
		return super.contact_step_limit(limit)
	if _attack_id != _frame_action_id or not attack_animation.is_playing():
		return limit
	return Geometry.step_limit(
		attack_animation.get_animation(&"archer_shoot"),
		attack_animation.current_animation_position, 1.0, limit
	)


func advance_contact_clock(delta: float) -> void:
	if not _shooting:
		super.advance_contact_clock(delta)
		return
	_sample_action_id = 0
	if _attack_id != _frame_action_id or not attack_animation.is_playing():
		return
	var clock: Animation = attack_animation.get_animation(&"archer_shoot")
	_sample_action_id = _attack_id
	_sample_time = minf(attack_animation.current_animation_position + delta, clock.length)
	attack_animation.advance(delta)
	if _attack_id == 0 or _attack_id != _sample_action_id:
		return
	if _sample_time >= clock.get_marker_time(&"active_start"):
		_set_state(State.ACTIVE)
	if not _arrow_released and _sample_time >= clock.get_marker_time(&"launch"):
		# Set the latch before adding a projectile, including same-frame callbacks.
		_arrow_released = true
		_release_arrow()


func finish_contact_sample() -> void:
	if not _shooting:
		super.finish_contact_sample()
		return
	if _attack_id != 0 and _attack_id == _sample_action_id:
		if _sample_time >= _geometry_clock.get_marker_time(&"active_end"):
			_window_finished = true


func ai_windup_finished() -> bool:
	if not _shooting:
		return super.ai_windup_finished()
	return _shot_clock_reached(&"active_start")


func ai_strike_finished() -> bool:
	if not _shooting:
		return super.ai_strike_finished()
	return _shot_clock_reached(&"active_end")


func ai_recovery_finished() -> bool:
	if not _shooting:
		return super.ai_recovery_finished()
	return (
		not attack_animation.is_playing()
		or attack_animation.current_animation_position
		>= attack_animation.get_animation(&"archer_shoot").length
	)


func get_melee_snapshot() -> Dictionary:
	# A flying arrow never participates in simultaneous melee-clash arbitration.
	return {} if _shooting else super.get_melee_snapshot()


func _shot_clock_reached(marker: StringName) -> bool:
	return (
		not attack_animation.is_playing()
		or attack_animation.current_animation_position
		>= attack_animation.get_animation(&"archer_shoot").get_marker_time(marker)
	)


func _release_arrow() -> void:
	var scene := get_tree().current_scene
	if scene == null or _defeated or not _stage_enabled:
		return
	# Mirror the muzzle about the visual foot anchor, as the melee geometry does.
	var pivot_x := body_visual.position.x
	var muzzle := Vector2(pivot_x + (arrow_origin.x - pivot_x) * _facing.x, arrow_origin.y)
	var arrow = ranged_projectile_scene.instantiate()
	scene.add_child(arrow)
	arrow.initialize(
		self, to_global(muzzle), _facing, _shot_damage, _shot_impact,
		_attack_id, _shot_distance, _shot_duration
	)
