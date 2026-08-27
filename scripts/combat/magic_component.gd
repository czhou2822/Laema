class_name MagicComponent
extends Node

const CombatOutcomeResource = preload("res://scripts/combat/combat_outcome.gd")

signal queue_changed(snapshot: Array, marked_count: int, marking_progress: float)
signal outcome_published(outcome)
signal projectile_launch_requested(payload: Dictionary)
signal action_speed_multiplier_changed(multiplier: float)

enum PressureState {
	INTERMEDIATE,
	RELEASE,
	HOLD,
	CHARGING,
}

var _config: Dictionary = {}
var _casting_config: Dictionary = {}
var _heat: HeatComponent
var _owner_entity: Entity
var _attack_cast: ShapeCast2D
var _loadout: Dictionary = {}
var _resolvers: Dictionary = {}
var _queue: Array[StringName] = []
var _front_remaining := 0.0
var _partial_mark_time := 0.0
var _marked_capacity := 0
var _marking_active := false
var _holding_charge := false
var _pressure_initialized := false
var _pressure_state := PressureState.INTERMEDIATE
var _committed_casts: Dictionary = {}
var _next_commit_id := 1
var _air_speed_multiplier := 1.0
var _air_speed_remaining := 0.0


func configure(
	config: Dictionary,
	heat: HeatComponent,
	loadout: Dictionary,
	owner_entity: Entity,
	attack_cast: ShapeCast2D,
	resolvers: Dictionary
) -> void:
	_config = config
	_casting_config = _config["casting"]
	_heat = heat
	_loadout = loadout.duplicate(true)
	_owner_entity = owner_entity
	_attack_cast = attack_cast
	_resolvers = resolvers.duplicate()
	_clear_orb_state()
	_committed_casts.clear()
	_next_commit_id = 1
	_pressure_initialized = false
	_pressure_state = PressureState.INTERMEDIATE
	_air_speed_multiplier = 1.0
	_air_speed_remaining = 0.0
	_emit_snapshot()
	action_speed_multiplier_changed.emit(_air_speed_multiplier)


func apply_runtime_tuning(config: Dictionary, loadout: Dictionary) -> void:
	_config = config
	_casting_config = _config["casting"]
	_loadout = loadout.duplicate(true)
	_front_remaining = minf(_front_remaining, _orb_lifetime())
	_marked_capacity = mini(_marked_capacity, _maximum_marked_capacity())
	_emit_snapshot()


func _process(delta: float) -> void:
	if _casting_config.is_empty():
		return
	var changed := _advance_front_lifetime(delta)
	if _marking_active:
		changed = _advance_marking(delta) or changed
	_update_air_speed_buff(delta)
	if changed:
		_emit_snapshot()


func update_pressure(raw_strength: float) -> int:
	if _casting_config.is_empty():
		return PressureState.INTERMEDIATE
	var candidate := _classify_pressure(raw_strength)
	if candidate == PressureState.INTERMEDIATE:
		return PressureState.INTERMEDIATE
	if not _pressure_initialized:
		_pressure_initialized = true
		_pressure_state = candidate
		_publish_outcome(&"pressure_state_changed", {
			"state": _pressure_state_name(candidate),
			"initial": true,
		})
		_trace(&"pressure_state_changed", {"raw_strength": raw_strength, "state": _pressure_state_name(candidate), "initial": true})
		return PressureState.INTERMEDIATE if candidate == PressureState.RELEASE else candidate
	if candidate == _pressure_state:
		return PressureState.INTERMEDIATE
	_pressure_state = candidate
	_publish_outcome(&"pressure_state_changed", {
		"state": _pressure_state_name(candidate),
		"initial": false,
	})
	_trace(&"pressure_state_changed", {"raw_strength": raw_strength, "state": _pressure_state_name(candidate), "initial": false})
	return candidate


func start_charging() -> void:
	var was_active := _marking_active
	_marking_active = true
	_holding_charge = false
	if not was_active:
		_trace(&"charging_started", {"marked_capacity": _marked_capacity, "partial_progress": get_marking_progress()})
		_publish_outcome(&"charging_started", {"marked_count": get_marked_count()})
		_emit_snapshot()


func hold_charge() -> void:
	var was_holding := _holding_charge
	_marking_active = false
	if was_holding:
		return
	_holding_charge = true
	_trace(&"charge_held", {"marked_capacity": _marked_capacity, "partial_progress": get_marking_progress()})
	_publish_outcome(&"charge_held", {"marked_count": get_marked_count()})
	_emit_snapshot()


func has_active_marking_state() -> bool:
	return _marking_active or _holding_charge or _partial_mark_time > 0.0 or _marked_capacity > 0


func has_marked_orbs() -> bool:
	return get_marked_count() > 0


func get_marked_count() -> int:
	return mini(_marked_capacity, _queue.size())


func add_orb(school: StringName) -> void:
	if school == &"":
		return
	if _queue.is_empty():
		_front_remaining = _orb_lifetime()
	_queue.append(school)
	_trace(&"created", {"school": school, "queue_size": _queue.size(), "marked_count": get_marked_count()})
	_publish_outcome(&"orb_created", {"school": school, "queue_size": _queue.size()})
	_emit_snapshot()


func commit_cast(
	casting_school: StringName,
	empowered: bool,
	primary_damage_multiplier: float,
	direction: Vector2,
	instigator: Entity
) -> Dictionary:
	var resolution := _consume_marked_orbs()
	if not bool(resolution.get("valid", false)):
		return resolution
	var primary_school := StringName(resolution["primary_school"])
	var primary_level := int(resolution["primary_level"])
	var secondary_school := StringName(resolution["secondary_school"])
	var secondary_level := int(resolution["secondary_level"])
	var commit_id := _next_commit_id
	_next_commit_id += 1
	var payload := {
		"commit_id": commit_id,
		"casting_school": casting_school,
		"composition": resolution["composition"].duplicate(),
		"primary_school": primary_school,
		"primary_level": primary_level,
		"primary_spell": _equipped_spell(primary_school, primary_level),
		"secondary_school": secondary_school,
		"secondary_level": secondary_level,
		"secondary_spell": _equipped_spell(secondary_school, secondary_level) if secondary_level >= 1 else &"",
		"empowered": empowered,
		"primary_damage_multiplier": primary_damage_multiplier,
		"direction": direction,
		"instigator": instigator,
	}
	_committed_casts[commit_id] = payload.duplicate(true)
	_publish_outcome(&"cast_committed", {
		"commit_id": commit_id,
		"primary_school": primary_school,
		"primary_level": primary_level,
		"secondary_school": secondary_school,
		"secondary_level": secondary_level,
		"empowered": empowered,
	})
	_trace(&"cast_committed", {"commit_id": commit_id, "primary_school": primary_school, "primary_level": primary_level, "empowered": empowered})
	return {"valid": true, "commit_id": commit_id}


func get_committed_cast(commit_id: int) -> Dictionary:
	if not _committed_casts.has(commit_id):
		return {}
	return Dictionary(_committed_casts[commit_id]).duplicate(true)


func launch_committed_cast(commit_id: int) -> void:
	if not _committed_casts.has(commit_id):
		return
	var payload: Dictionary = Dictionary(_committed_casts[commit_id]).duplicate(true)
	_committed_casts.erase(commit_id)
	_publish_outcome(&"cast_launched", {
		"commit_id": commit_id,
		"primary_school": payload["primary_school"],
		"primary_level": payload["primary_level"],
		"secondary_school": payload["secondary_school"],
		"secondary_level": payload["secondary_level"],
		"empowered": payload["empowered"],
	})
	_trace(&"projectile_launch_requested", {"commit_id": commit_id, "primary_school": payload["primary_school"], "primary_level": payload["primary_level"]})
	projectile_launch_requested.emit(payload)


func discard_committed_cast(commit_id: int, reason: StringName) -> void:
	if not _committed_casts.has(commit_id):
		return
	_committed_casts.erase(commit_id)
	_publish_outcome(&"cast_commitment_discarded", {"reason": reason, "commit_id": commit_id})
	_trace(&"cast_commitment_discarded", {"reason": reason, "commit_id": commit_id})


func discard_committed_casts(reason: StringName) -> void:
	if _committed_casts.is_empty():
		return
	var discarded_count := _committed_casts.size()
	_committed_casts.clear()
	_publish_outcome(&"cast_commitments_discarded", {"reason": reason, "count": discarded_count})
	_trace(&"cast_commitments_discarded", {"reason": reason, "count": discarded_count})


func remove_marked_orbs_on_player_hit() -> void:
	var removed_count := get_marked_count()
	if removed_count <= 0:
		return
	for _index in range(removed_count):
		_queue.remove_at(0)
	_marked_capacity = 0
	_partial_mark_time = 0.0
	_holding_charge = false
	_front_remaining = _orb_lifetime() if not _queue.is_empty() else 0.0
	_publish_outcome(&"marked_orbs_removed_on_player_hit", {"removed_count": removed_count, "remaining_queue": _queue.size()})
	_trace(&"marked_orbs_removed_on_owner_hit", {"removed": removed_count, "remaining_queue": _queue.size()})
	_emit_snapshot()


func clear_after_failed_cast() -> void:
	discard_committed_casts(&"failed_cast")
	clear_orbs(&"failed_cast")


func clear_orbs(reason: StringName) -> void:
	var previous_size := _queue.size()
	var previous_marked := get_marked_count()
	_clear_orb_state()
	if previous_size <= 0 and previous_marked <= 0:
		return
	_publish_outcome(&"orb_queue_cleared", {"reason": reason, "queue_size": previous_size, "marked_count": previous_marked})
	_trace(&"cleared", {"reason": reason, "queue_size": previous_size, "marked_count": previous_marked})
	_emit_snapshot()


func resolve_projectile_impact(target: Entity, contact_point: Vector2, payload: Dictionary) -> void:
	if target == null or payload.is_empty():
		return
	var direction: Vector2 = payload["direction"]
	_apply_equipped_spell(
		StringName(payload["primary_spell"]),
		StringName(payload["primary_school"]),
		int(payload["primary_level"]),
		float(payload["primary_damage_multiplier"]),
		target,
		contact_point,
		direction
	)
	var secondary_level := int(payload.get("secondary_level", 0))
	if secondary_level >= 1:
		_apply_equipped_spell(
			StringName(payload["secondary_spell"]),
			StringName(payload["secondary_school"]),
			secondary_level,
			1.0,
			target,
			contact_point,
			direction
		)
	_publish_outcome(&"spell_projectile_impacted", {
		"primary_school": payload["primary_school"],
		"primary_level": payload["primary_level"],
		"target": target.name,
	})


func get_action_speed_multiplier() -> float:
	return _air_speed_multiplier


func _consume_marked_orbs() -> Dictionary:
	var consumed_count := get_marked_count()
	if consumed_count <= 0:
		return {"valid": false}
	var consumed: Array[StringName] = []
	for index in range(consumed_count):
		consumed.append(_queue[index])
	var counts: Dictionary = {}
	for school in consumed:
		counts[school] = int(counts.get(school, 0)) + 1
	var primary_school: StringName = &""
	var primary_count := -1
	for school in consumed:
		var count := int(counts[school])
		if count >= primary_count:
			primary_school = school
			primary_count = count
	var secondary_school: StringName = &""
	var secondary_level := 0
	for school_variant in counts:
		var school := StringName(school_variant)
		if school == primary_school:
			continue
		var level := int(counts[school]) - 1
		if level >= secondary_level and level >= 1:
			secondary_school = school
			secondary_level = level
	for _index in range(consumed_count):
		_queue.remove_at(0)
	_marked_capacity = 0
	_partial_mark_time = 0.0
	_marking_active = false
	_holding_charge = false
	_front_remaining = _orb_lifetime() if not _queue.is_empty() else 0.0
	_emit_snapshot()
	return {
		"valid": true,
		"composition": consumed,
		"primary_school": primary_school,
		"primary_level": consumed_count,
		"secondary_school": secondary_school,
		"secondary_level": secondary_level,
	}


func _apply_equipped_spell(
	spell: StringName,
	school: StringName,
	level: int,
	damage_multiplier: float,
	target: Entity,
	contact_point: Vector2,
	direction: Vector2
) -> void:
	_trace(&"spell_effect_resolved", {"target": target.name, "spell": spell, "school": school, "level": level, "damage_multiplier": damage_multiplier, "contact_point": contact_point})
	match spell:
		&"fire_default":
			_resolvers[&"fire"].call("apply", _owner_entity, target, level, _config["combat"], direction, contact_point, damage_multiplier)
		&"water_default":
			_resolvers[&"water"].call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_point, direction, level, _config["combat"], _config["water"], damage_multiplier)
		&"air_default":
			_resolvers[&"air"].call("apply", _owner_entity, _attack_cast.get_world_2d(), target, contact_point, direction, level, _config["combat"], _config["air"], damage_multiplier)
			if level == 1:
				_apply_air_speed_buff()
		&"earth_default":
			_resolvers[&"earth"].call("apply", _owner_entity, _attack_cast.get_world_2d(), contact_point, direction, level, _config["combat"], _config["earth"], damage_multiplier)
		_:
			push_error("Unknown equipped prototype spell: %s" % spell)


func _equipped_spell(school: StringName, level: int) -> StringName:
	if school == &"" or level < 1:
		return &""
	var school_loadout: Dictionary = _loadout.get(String(school), {})
	return StringName(school_loadout.get(str(level), &""))


func _classify_pressure(raw_strength: float) -> int:
	if raw_strength < float(_casting_config["trigger_release_max"]):
		return PressureState.RELEASE
	if raw_strength >= float(_casting_config["trigger_charge_min"]):
		return PressureState.CHARGING
	return PressureState.HOLD


func _pressure_state_name(state: int) -> StringName:
	match state:
		PressureState.RELEASE:
			return &"RELEASE"
		PressureState.HOLD:
			return &"HOLD"
		PressureState.CHARGING:
			return &"CHARGING"
	return &"INTERMEDIATE"


func _advance_front_lifetime(delta: float) -> bool:
	if _queue.is_empty():
		return false
	_front_remaining -= delta
	if _front_remaining > 0.0:
		return true
	var expired_school := _queue[0]
	var previous_marked := get_marked_count()
	_queue.remove_at(0)
	_front_remaining = _orb_lifetime() if not _queue.is_empty() else 0.0
	_trace(&"front_expired", {"school": expired_school, "marked_before": previous_marked, "marked_after": get_marked_count(), "remaining_queue": _queue.size()})
	_publish_outcome(&"orb_expired", {"school": expired_school, "remaining_queue": _queue.size()})
	return true


func _advance_marking(delta: float) -> bool:
	if _marked_capacity >= _maximum_marked_capacity():
		_partial_mark_time = 0.0
		return false
	var speed_multiplier := 1.0
	if _heat != null and _heat.has_method("get_speed_multiplier"):
		speed_multiplier = float(_heat.call("get_speed_multiplier"))
	_partial_mark_time += delta * speed_multiplier
	var changed := true
	while _partial_mark_time >= _charge_step_duration() and _marked_capacity < _maximum_marked_capacity():
		_partial_mark_time -= _charge_step_duration()
		_marked_capacity += 1
		_trace(&"mark_incremented", {"marked_capacity": _marked_capacity, "queue_size": _queue.size()})
		_publish_outcome(&"orb_marked", {"marked_count": get_marked_count()})
	if _marked_capacity >= _maximum_marked_capacity():
		_partial_mark_time = 0.0
	return changed


func _apply_air_speed_buff() -> void:
	_air_speed_multiplier = float(_config["air"]["attack_speed_multiplier"])
	_air_speed_remaining = float(_config["air"]["buff_duration"])
	action_speed_multiplier_changed.emit(_air_speed_multiplier)
	_publish_outcome(&"air_action_speed_buff_started", {"multiplier": _air_speed_multiplier})


func _update_air_speed_buff(delta: float) -> void:
	if _air_speed_remaining <= 0.0:
		return
	_air_speed_remaining = maxf(_air_speed_remaining - delta, 0.0)
	if _air_speed_remaining > 0.0:
		return
	_air_speed_multiplier = 1.0
	action_speed_multiplier_changed.emit(_air_speed_multiplier)
	_publish_outcome(&"air_action_speed_buff_expired")


func _clear_orb_state() -> void:
	_queue.clear()
	_front_remaining = 0.0
	_partial_mark_time = 0.0
	_marked_capacity = 0
	_marking_active = false
	_holding_charge = false


func _emit_snapshot() -> void:
	queue_changed.emit(get_snapshot(), _marked_capacity, get_marking_progress())


func get_snapshot() -> Array:
	var snapshot: Array = []
	var marked_count := get_marked_count()
	var front_ratio := _front_remaining / _orb_lifetime() if not _queue.is_empty() else 0.0
	for index in range(_queue.size()):
		snapshot.append({
			"school": _queue[index],
			"marked": index < marked_count,
			"remaining_ratio": front_ratio if index == 0 else 1.0,
		})
	return snapshot


func get_marking_progress() -> float:
	return clampf(_partial_mark_time / _charge_step_duration(), 0.0, 1.0)


func _orb_lifetime() -> float:
	return float(_casting_config["orb_lifetime"])


func _charge_step_duration() -> float:
	return float(_casting_config["charge_step_duration"])


func _maximum_marked_capacity() -> int:
	return int(_casting_config["max_marked_capacity"])


func _publish_outcome(kind: StringName, facts: Dictionary = {}) -> void:
	outcome_published.emit(CombatOutcomeResource.create(kind, facts))


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][ORBS] %s %s" % [event_name, data])
