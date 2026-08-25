extends Node

signal queue_changed(snapshot: Array, marked_count: int, marking_progress: float)

var _config: Dictionary = {}
var _heat: Node
var _queue: Array[StringName] = []
var _front_remaining := 0.0
var _partial_mark_time := 0.0
var _marked_capacity := 0
var _marking_active := false
var _depleting_active := false


func configure(config: Dictionary, heat: Node) -> void:
	_config = config
	_heat = heat
	_clear_state()
	_emit_snapshot()


func apply_runtime_tuning(config: Dictionary) -> void:
	_config = config
	_front_remaining = minf(_front_remaining, _orb_lifetime())
	_marked_capacity = mini(_marked_capacity, _maximum_marked_capacity())
	_emit_snapshot()


func _process(delta: float) -> void:
	if _config.is_empty():
		return
	var changed := _advance_front_lifetime(delta)
	if _marking_active:
		changed = _advance_marking(delta) or changed
	elif _depleting_active:
		changed = _advance_depleting(delta) or changed
	if changed:
		_emit_snapshot()


func add_orb(school: StringName) -> void:
	if school == &"":
		return
	if _queue.is_empty():
		_front_remaining = _orb_lifetime()
	_queue.append(school)
	_trace(&"created", {"school": school, "queue_size": _queue.size(), "marked_count": get_marked_count()})
	_emit_snapshot()


func start_charging() -> void:
	var was_active := _marking_active
	_marking_active = true
	_depleting_active = false
	if not was_active:
		_trace(&"charging_started", {"marked_capacity": _marked_capacity, "partial_progress": get_marking_progress()})
	_emit_snapshot()


func start_depleting() -> void:
	var was_active := _depleting_active
	_marking_active = false
	if was_active:
		return
	_depleting_active = true
	_trace(&"depleting_started", {"marked_capacity": _marked_capacity, "partial_progress": get_marking_progress()})
	_emit_snapshot()


func has_active_marking_state() -> bool:
	return _marking_active or _depleting_active or _partial_mark_time > 0.0 or _marked_capacity > 0


func has_marked_orbs() -> bool:
	return get_marked_count() > 0


func get_marked_count() -> int:
	return mini(_marked_capacity, _queue.size())


func consume_marked_orbs() -> Dictionary:
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
	_depleting_active = false
	_front_remaining = _orb_lifetime() if not _queue.is_empty() else 0.0
	_trace(&"consumed", {"primary_school": primary_school, "primary_level": consumed_count, "secondary_school": secondary_school, "secondary_level": secondary_level, "remaining_queue": _queue.size()})
	_emit_snapshot()
	return {
		"valid": true,
		"primary_school": primary_school,
		"primary_level": consumed_count,
		"secondary_school": secondary_school,
		"secondary_level": secondary_level,
		"consumed_count": consumed_count,
	}


func remove_marked_orbs_on_owner_hit() -> void:
	var removed_count := get_marked_count()
	if removed_count <= 0:
		return
	for _index in range(removed_count):
		_queue.remove_at(0)
	_marked_capacity = 0
	_partial_mark_time = 0.0
	_depleting_active = false
	_front_remaining = _orb_lifetime() if not _queue.is_empty() else 0.0
	_trace(&"marked_orbs_removed_on_owner_hit", {"removed": removed_count, "remaining_queue": _queue.size()})
	_emit_snapshot()


func clear() -> void:
	var previous_size := _queue.size()
	var previous_marked := get_marked_count()
	_clear_state()
	if previous_size > 0 or previous_marked > 0:
		_trace(&"cleared", {"queue_size": previous_size, "marked_count": previous_marked})
	_emit_snapshot()


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
	while (
		_partial_mark_time >= _charge_step_duration()
		and _marked_capacity < _maximum_marked_capacity()
	):
		_partial_mark_time -= _charge_step_duration()
		_marked_capacity += 1
		_trace(&"mark_incremented", {"marked_capacity": _marked_capacity, "queue_size": _queue.size()})
	if _marked_capacity >= _maximum_marked_capacity():
		_partial_mark_time = 0.0
	return changed


func _advance_depleting(delta: float) -> bool:
	if _marked_capacity <= 0 and _partial_mark_time <= 0.0:
		return false
	_partial_mark_time -= delta
	var changed := true
	while _partial_mark_time < 0.0 and _marked_capacity > 0:
		_marked_capacity -= 1
		_partial_mark_time += _charge_step_duration()
		_trace(&"mark_decremented", {"marked_capacity": _marked_capacity, "queue_size": _queue.size()})
	if _marked_capacity <= 0 and _partial_mark_time < 0.0:
		_partial_mark_time = 0.0
	return changed


func _clear_state() -> void:
	_queue.clear()
	_front_remaining = 0.0
	_partial_mark_time = 0.0
	_marked_capacity = 0
	_marking_active = false
	_depleting_active = false


func _emit_snapshot() -> void:
	queue_changed.emit(get_snapshot(), _marked_capacity, get_marking_progress())


func _orb_lifetime() -> float:
	return float(_config["orb_lifetime"])


func _charge_step_duration() -> float:
	return float(_config["charge_step_duration"])


func _maximum_marked_capacity() -> int:
	return int(_config["max_marked_capacity"])


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][ORBS] %s %s" % [event_name, data])
