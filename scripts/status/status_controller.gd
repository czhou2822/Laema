extends Node

signal status_changed(snapshot: Dictionary)
signal effect_state_changed(snapshot: Dictionary)
signal effect_applied(effect_type: StringName, payload: Dictionary)

var _owner_entity: Entity
var _config: Dictionary = {}
var _dot_instances: Array[Dictionary] = []
var _water_status: Dictionary = {}
var _earth_slow: Dictionary = {}
var _endurance_enabled := false
var _endurance_school: StringName = &""
var _endurance_hits := 0
var _last_action_key := ""
var _last_action_multiplier := 1.0
var _last_action_full_resist := false


func configure(owner_entity: Entity, config: Dictionary) -> void:
	_owner_entity = owner_entity
	_config = config
	_emit_state()


func set_elemental_endurance_enabled(enabled: bool) -> void:
	_endurance_enabled = enabled
	_endurance_school = &""
	_endurance_hits = 0
	_last_action_key = ""
	_emit_state()


func resolve_elemental_endurance(event: HealthEvent) -> Dictionary:
	if not _endurance_enabled or event.operation != HealthEvent.Operation.DAMAGE:
		return {"multiplier": 1.0, "full_resist": false}
	if event.delivery == HealthEvent.Delivery.DOT_TICK:
		return {"multiplier": _endurance_multiplier() if event.school == _endurance_school else 1.0, "full_resist": false}
	if not event.is_direct_damage() or event.school == &"":
		return {"multiplier": 1.0, "full_resist": false}
	var action_key := "%s:%d" % [event.instigator.get_instance_id() if is_instance_valid(event.instigator) else 0, event.source_action_id]
	if action_key == _last_action_key:
		return {"multiplier": _last_action_multiplier, "full_resist": _last_action_full_resist}
	_last_action_key = action_key
	var represented_schools: Dictionary = {}
	for school_variant in event.action_composition:
		represented_schools[StringName(school_variant)] = true
	if represented_schools.size() > 1:
		_endurance_school = &""
		_endurance_hits = 0
		_last_action_multiplier = 1.0
		_last_action_full_resist = false
		_emit_state()
		return {"multiplier": 1.0, "full_resist": false}
	if event.school != _endurance_school:
		_endurance_school = event.school
		_endurance_hits = 1
	else:
		_endurance_hits = mini(_endurance_hits + 1, 10)
	_last_action_multiplier = _endurance_multiplier()
	_last_action_full_resist = is_zero_approx(_last_action_multiplier)
	_emit_state()
	return {"multiplier": _last_action_multiplier, "full_resist": _last_action_full_resist}


func _endurance_multiplier() -> float:
	if _endurance_hits <= 5:
		return 1.0
	var key := "hit_%d_damage_percent" % mini(_endurance_hits, 10)
	return float(_config["elemental_endurance"][key])


func _process(delta: float) -> void:
	var changed := false
	for index in range(_dot_instances.size() - 1, -1, -1):
		var dot: Dictionary = _dot_instances[index]
		dot["remaining"] = float(dot["remaining"]) - delta
		dot["until_tick"] = float(dot["until_tick"]) - delta
		while (
			float(dot["until_tick"]) <= 0.0
			and float(dot["remaining"]) - float(dot["until_tick"]) >= -0.00001
		):
			var tick := HealthEvent.damage(
				dot["instigator"],
				_owner_entity,
				float(dot["damage"]),
				0,
				HealthEvent.Delivery.DOT_TICK,
				&"fire"
			)
			_owner_entity.receive_health_event(tick)
			dot["until_tick"] = float(dot["until_tick"]) + float(dot["tick_interval"])
		if float(dot["remaining"]) <= 0.0:
			_dot_instances.remove_at(index)
			changed = true
		else:
			_dot_instances[index] = dot

	if not _water_status.is_empty():
		_water_status["remaining"] = float(_water_status["remaining"]) - delta
		changed = true
		if float(_water_status["remaining"]) <= 0.0:
			_water_status = {}

	if not _earth_slow.is_empty():
		_earth_slow["remaining"] = float(_earth_slow["remaining"]) - delta
		changed = true
		if float(_earth_slow["remaining"]) <= 0.0:
			_earth_slow = {}

	if changed:
		_emit_state()


func apply_instruction(instruction: Dictionary, instigator: Node) -> bool:
	var effect_type := StringName(instruction.get("type", &""))
	match effect_type:
		&"fire_dot":
			_apply_fire_dot(instruction, instigator)
			_trace(&"fire_dot_applied", {"stacks_added": int(instruction["stacks"]), "active_stacks": _dot_instances.size()})
			effect_applied.emit(effect_type, instruction.duplicate(true))
			_emit_state()
			return true
		&"water_status":
			var applied := _apply_water_status(instruction, instigator)
			if applied:
				_trace(&"water_status_applied", {"level": instruction["level"], "status": instruction["status"], "duration": instruction["duration"], "slow_percent": instruction.get("slow_percent", 0.0)})
				effect_applied.emit(effect_type, instruction.duplicate(true))
				_emit_state()
			return applied
		&"earth_slow":
			var applied := _apply_earth_slow(instruction, instigator)
			if applied:
				_trace(&"earth_slow_applied", {"level": instruction["level"], "duration": instruction["duration"], "slow_percent": instruction["slow_percent"]})
				effect_applied.emit(effect_type, instruction.duplicate(true))
				_emit_state()
			return applied
	return false


func _apply_fire_dot(instruction: Dictionary, instigator: Node) -> void:
	var stacks := int(instruction["stacks"])
	for _index in range(stacks):
		_dot_instances.append({
			"remaining": float(_config["fire"]["dot_duration"]),
			"until_tick": float(_config["fire"]["dot_tick_interval"]),
			"tick_interval": float(_config["fire"]["dot_tick_interval"]),
			"damage": float(_config["fire"]["damage_per_stack"]),
			"instigator": instigator,
		})


func _apply_water_status(instruction: Dictionary, instigator: Node) -> bool:
	var incoming_level := int(instruction["level"])
	if not _water_status.is_empty():
		var active_level := int(_water_status["level"])
		if incoming_level < active_level:
			return false
	_water_status = {
		"level": incoming_level,
		"status": StringName(instruction["status"]),
		"remaining": float(instruction["duration"]),
		"duration": float(instruction["duration"]),
		"slow_percent": float(instruction.get("slow_percent", 0.0)),
		"instigator": instigator,
	}
	return true


func _apply_earth_slow(instruction: Dictionary, instigator: Node) -> bool:
	var incoming_level := int(instruction["level"])
	if not _earth_slow.is_empty() and incoming_level < int(_earth_slow["level"]):
		return false
	_earth_slow = {
		"level": incoming_level,
		"remaining": float(instruction["duration"]),
		"duration": float(instruction["duration"]),
		"slow_percent": float(instruction["slow_percent"]),
		"instigator": instigator,
	}
	return true


func get_snapshot() -> Dictionary:
	return {
		"dot_stacks": _dot_instances.size(),
		"water_level": int(_water_status.get("level", 0)),
		"water_status": StringName(_water_status.get("status", &"")),
		"water_remaining": float(_water_status.get("remaining", 0.0)),
		"slow_percent": float(_water_status.get("slow_percent", 0.0)),
		"frozen": StringName(_water_status.get("status", &"")) == &"frozen",
		"earth_level": int(_earth_slow.get("level", 0)),
		"earth_remaining": float(_earth_slow.get("remaining", 0.0)),
		"earth_slow_percent": float(_earth_slow.get("slow_percent", 0.0)),
		"endurance_school": _endurance_school,
		"endurance_percent": int(round(_endurance_multiplier() * 100.0)) if _endurance_school != &"" else 100,
	}


func get_effect_state() -> Dictionary:
	var status := StringName(_water_status.get("status", &""))
	var movement_multiplier := 1.0
	var actions_suppressed := false
	if status == &"slow":
		movement_multiplier = 1.0 - float(_water_status.get("slow_percent", 0.0))
	elif status == &"frozen":
		movement_multiplier = 0.0
		actions_suppressed = true
	if not _earth_slow.is_empty():
		movement_multiplier = minf(
			movement_multiplier,
			1.0 - float(_earth_slow.get("slow_percent", 0.0))
		)
	return {
		"actions_suppressed": actions_suppressed,
		"movement_multiplier": movement_multiplier,
	}


func clear_for_stage() -> void:
	_dot_instances.clear()
	_water_status.clear()
	_earth_slow.clear()
	_endurance_school = &""
	_endurance_hits = 0
	_last_action_key = ""
	_last_action_multiplier = 1.0
	_last_action_full_resist = false
	_emit_state()


func _emit_state() -> void:
	status_changed.emit(get_snapshot())
	effect_state_changed.emit(get_effect_state())


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][STATUS] %s %s" % [event_name, data])
