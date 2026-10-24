class_name CombatComponent
extends Node

signal movement_lock_changed(locked: bool)
signal active_school_changed(school: StringName)
signal attack_started(kind: StringName, school: StringName, direction: Vector2)
signal dodge_started(direction: Vector2)
signal dodge_finished
signal empowered_cast_started(school: StringName, direction: Vector2)
signal cast_launch_requested(payload: Dictionary)
signal cast_failed
signal defence_status_changed(label: String, current_guard: float, maximum_guard: float)
signal heat_changed(value: float, level: int, speed_multiplier: float)
signal combo_sequence_changed(tokens: Array)
signal combo_completed(tokens: Array)
signal combo_reset
signal orb_queue_changed(snapshot: Array, marked_count: int, marking_progress: float)
signal outcome_published(outcome)

const SCHOOL_FIRE := &"fire"
const SCHOOL_WATER := &"water"
const SCHOOL_AIR := &"air"
const SCHOOL_EARTH := &"earth"
const CombatOutcomeResource = preload("res://scripts/combat/combat_outcome.gd")

var _config: Dictionary = {}
var _owner_entity: Entity
var _might: MightComponent
var _magic: MagicComponent
var _heat: HeatComponent
var _defence: DefenceController
var _defending := false
var _guard_broken := false
var _guard_break_remaining := 0.0
var _stage_input_locked := false
var _might_movement_locked := false


func configure(
	config: Dictionary,
	owner_entity: Entity,
	animation_player: AnimationPlayer,
	attack_cast: ShapeCast2D,
	input_combo,
	might: MightComponent,
	magic: MagicComponent,
	heat: HeatComponent,
	defence: DefenceController,
	resolvers: Dictionary
) -> void:
	_config = config
	_owner_entity = owner_entity
	_might = might
	_magic = magic
	_heat = heat
	_defence = defence
	_heat.configure(_config["heat"])
	_defence.configure(_config["defence"])
	_magic.configure(_config, _heat, {}, _owner_entity, attack_cast, resolvers)
	_might.configure(_config, _owner_entity, animation_player, attack_cast, input_combo, _magic, _heat)
	_connect_public_interfaces(input_combo)
	active_school_changed.emit(_might.get_active_school())


func apply_runtime_tuning() -> void:
	if _config.is_empty():
		return
	_heat.apply_runtime_tuning()
	_defence.configure(_config["defence"])
	_magic.apply_runtime_tuning(_config, {})
	_might.apply_runtime_tuning()


func _process(delta: float) -> void:
	if _stage_input_locked:
		return
	# Released tap parries and reuse recovery continue after the button comes up.
	_defence.update(delta, _heat)
	if _guard_broken:
		_guard_break_remaining = maxf(_guard_break_remaining - delta, 0.0)
		if _guard_break_remaining <= 0.0 and not _defence.is_holding():
			_guard_broken = false
			defence_status_changed.emit("READY", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))
	_update_casting_pressure()


func handle_input_event(event: InputEvent, attack_direction: Vector2) -> void:
	if _stage_input_locked or _might.is_dodging():
		return
	if event.is_echo():
		return
	for school_action in [
		[&"select_fire", SCHOOL_FIRE],
		[&"select_water", SCHOOL_WATER],
		[&"select_air", SCHOOL_AIR],
		[&"select_earth", SCHOOL_EARTH],
	]:
		if event.is_action_pressed(school_action[0]):
			_might.try_select_school(school_action[1])
			return
	if event.is_action_pressed(&"defend"):
		_try_defend()
		return
	if event.is_action_released(&"defend"):
		_release_defend()
		return
	if event.is_action_pressed(&"light_attack"):
		if _defence.is_fire_mode() and _defence.blocks_actions():
			return
		_might.try_light_attack(attack_direction)


func try_dodge(direction: Vector2, normal_movement_speed: float) -> void:
	if _stage_input_locked or _defending or _guard_broken:
		return
	_might.try_dodge(direction, normal_movement_speed)


func is_dodging() -> bool:
	return _might.is_dodging()


func is_combo_active() -> bool:
	return _might.is_combo_active()


func is_attack_playing() -> bool:
	return _might.is_attack_playing()


func is_defending() -> bool:
	return _defending


func get_normalized_attack_progress() -> float:
	return _might.get_normalized_attack_progress()


func get_current_attack_school() -> StringName:
	return _might.get_current_attack_school()


func get_active_school() -> StringName:
	return _might.get_active_school()


func get_current_chain_position() -> int:
	return _might.get_current_chain_position()


func select_stage_school(school: StringName) -> void:
	_might.try_select_school(school)


func get_defensive_level() -> int:
	return _defence.get_defensive_level() if _defending else 0


func set_effect_actions_suppressed(suppressed: bool) -> void:
	_might.set_effect_actions_suppressed(suppressed)


func handle_health_result(result: HealthResult) -> void:
	if result == null or result.event == null or result.outcome != HealthResult.Outcome.APPLIED or not result.event.is_direct_damage():
		return
	if result.event.target == _owner_entity:
		_heat.remove_for_player_hit()
		_magic.remove_marked_orbs_on_player_hit()
	elif result.event.instigator == _owner_entity:
		_heat.refresh_from_landed_direct_hit()


func resolve_spell_projectile_impact(target: Entity, contact_point: Vector2, payload: Dictionary) -> void:
	_magic.resolve_projectile_impact(target, contact_point, payload)


func on_hit_reaction_started() -> void:
	if _might.consume_failed_cast_reaction():
		return
	if _might.is_hit_reacting():
		return
	_might.cancel_for_player_hit()
	_magic.discard_committed_casts(&"player_hit")
	_defence.force_cancel(false)
	_defending = false
	_guard_broken = false
	_guard_break_remaining = 0.0
	_might.enter_hit_reaction()
	defence_status_changed.emit(_defence.fire_status(), _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func on_hit_reaction_ended() -> void:
	_might.on_hit_reaction_ended()


func set_stage_input_locked(locked: bool) -> void:
	_stage_input_locked = locked
	if locked:
		_might.cancel_dodge()
		_defence.force_cancel()
		_defending = false
		_guard_broken = false
		_guard_break_remaining = 0.0
		movement_lock_changed.emit(true)


func reset_for_stage() -> void:
	_might.reset_for_stage()
	_magic.reset_for_stage()
	_heat.reset_for_stage()
	_defence.force_cancel()
	_defence.configure(_config["defence"])
	_defending = false
	_guard_broken = false
	_guard_break_remaining = 0.0
	defence_status_changed.emit("READY", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))
	if _stage_input_locked:
		movement_lock_changed.emit(true)


func _update_casting_pressure() -> void:
	if _might.is_dodging():
		return
	var transition := _magic.update_pressure(Input.get_action_raw_strength(&"casting"))
	if transition == MagicComponent.PressureState.INTERMEDIATE:
		return
	if transition == MagicComponent.PressureState.RELEASE:
		var block_reason := &""
		if _defending:
			block_reason = &"defence_active"
		elif _guard_broken:
			block_reason = &"guard_broken"
		_might.try_cast_trigger(block_reason)
		return
	if not _might.can_handle_pressure() or _defending or _guard_broken:
		return
	match transition:
		MagicComponent.PressureState.DEPLETING:
			_magic.start_depleting()
			_might.release_movement_for_orb_state()
		MagicComponent.PressureState.CHARGING:
			_magic.start_charging()
			_might.release_movement_for_orb_state()



func _try_defend() -> void:
	var active_school := _might.get_active_school()
	if _defending or _guard_broken or not _defence.can_begin(active_school):
		return
	if not _might.can_begin_defence(active_school == SCHOOL_FIRE):
		return
	if _defence.begin(active_school):
		if active_school == SCHOOL_FIRE:
			_might.cancel_melee_for_defence()
			_sync_fire_defence()
		else:
			_defending = true
			movement_lock_changed.emit(true)
			defence_status_changed.emit("BLOCK", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _release_defend() -> void:
	if _defence.is_fire_mode():
		_defence.end_hold()
		return
	if not _defending and not _guard_broken:
		return
	_defence.end_hold()
	if _defending or _guard_break_remaining <= 0.0:
		_defending = false
		_guard_broken = false
		_guard_break_remaining = 0.0
		movement_lock_changed.emit(false)
		defence_status_changed.emit("READY", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _sync_fire_defence() -> void:
	var blocking_actions := _defence.blocks_actions()
	if _defending != blocking_actions:
		_defending = blocking_actions
		movement_lock_changed.emit(_defending or _might_movement_locked or _stage_input_locked)
	defence_status_changed.emit(_defence.fire_status(), _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _on_might_movement_lock_changed(locked: bool) -> void:
	_might_movement_locked = locked
	movement_lock_changed.emit(locked or (_defence.is_fire_mode() and _defence.blocks_actions()) or _stage_input_locked)


func _connect_public_interfaces(input_combo) -> void:
	_might.movement_lock_changed.connect(_on_might_movement_lock_changed)
	_might.active_school_changed.connect(active_school_changed.emit)
	_might.attack_started.connect(attack_started.emit)
	_might.dodge_started.connect(dodge_started.emit)
	_might.dodge_finished.connect(_on_dodge_finished)
	_might.empowered_cast_started.connect(empowered_cast_started.emit)
	_might.cast_failed.connect(cast_failed.emit)
	_might.cast_attempt_resolved.connect(_on_cast_attempt_resolved)
	_might.outcome_published.connect(_forward_outcome)
	_magic.queue_changed.connect(orb_queue_changed.emit)
	_magic.cast_committed.connect(_on_cast_committed)
	_magic.projectile_launch_requested.connect(cast_launch_requested.emit)
	_magic.outcome_published.connect(_forward_outcome)
	_heat.heat_changed.connect(heat_changed.emit)
	input_combo.sequence_changed.connect(combo_sequence_changed.emit)
	input_combo.combo_completed.connect(combo_completed.emit)
	input_combo.combo_reset.connect(combo_reset.emit)
	_defence.guard_changed.connect(_on_guard_changed)
	_defence.guard_warning.connect(_on_guard_warning)
	_defence.guard_broken.connect(_on_guard_broken)
	_defence.fire_state_changed.connect(_sync_fire_defence)


func _on_dodge_finished() -> void:
	_magic.rearm_pressure_after_dodge(Input.get_action_raw_strength(&"casting"))
	# A prior successful parry may still own a held-button latch. Reconcile a
	# release ignored during dodge without replaying an ignored defence press.
	if _defence.is_holding() and not Input.is_action_pressed(&"defend"):
		_release_defend()
	dodge_finished.emit()


func _forward_outcome(outcome) -> void:
	outcome_published.emit(outcome)


func _on_cast_attempt_resolved(result: Dictionary) -> void:
	outcome_published.emit(CombatOutcomeResource.create(&"cast_attempt_resolved", result))


func _on_cast_committed(_commit_id: int, consumed_count: int) -> void:
	_heat.gain_from_commit(consumed_count)


func _on_guard_changed(current_value: float, maximum_value: float) -> void:
	if _defence.is_fire_mode():
		return
	if not _defending:
		defence_status_changed.emit("READY", current_value, maximum_value)
		return
	var warning_threshold := float(_config["defence"]["guard_warning_ratio"])
	var warning_active := maximum_value > 0.0 and current_value / maximum_value <= warning_threshold
	defence_status_changed.emit("GUARD WARNING" if warning_active else "BLOCK", current_value, maximum_value)


func _on_guard_warning() -> void:
	defence_status_changed.emit("GUARD WARNING", _defence.get_guard(), float(_config["defence"]["guard_capacity"]))


func _on_guard_broken() -> void:
	_defending = false
	_guard_broken = true
	_guard_break_remaining = _defence.get_guard_break_recovery()
	movement_lock_changed.emit(true)
	defence_status_changed.emit("GUARD BROKEN", 0.0, float(_config["defence"]["guard_capacity"]))


func get_melee_snapshot() -> Dictionary:
	return _might.get_melee_snapshot()


func cancel_combat_attack() -> void:
	if _might.is_hit_reacting():
		return
	on_hit_reaction_started()


func on_clash_contact_resolved(result: HealthResult) -> void:
	_might.on_clash_contact_resolved(result)


func get_active_start_phase() -> float:
	return _might.get_active_start_phase()
