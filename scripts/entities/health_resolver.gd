class_name HealthResolver
extends Node

signal reaction_evaluated(snapshot: Dictionary)

const ImpactProbe = preload("res://scripts/debug/impact_probe.gd")

var _owner_entity: Entity
var _health: HealthComponent
var _status_controller
var _hit_reaction: HitReaction
var _defence_component
var _hit_transaction_depth := 0
var _pending_difference := -1
var _pending_direction := Vector2.ZERO


static func calculate_reaction_value(incoming_impact: int, receiver_poise: int, receiver_move: Dictionary) -> int:
	var active_impact := int(receiver_move.get("impact", 0)) if bool(receiver_move.get("active", false)) else 0
	return incoming_impact - receiver_poise - active_impact


static func _is_reaction_eligible(value: int, instigator: Entity, receiver: Entity, direct_damage: bool) -> bool:
	if value > 0:
		return true
	return (
		value == 0
		and direct_damage
		and is_instance_valid(instigator)
		and instigator.is_player_combatant()
		and is_instance_valid(receiver)
		and receiver.uses_combat_hit_reaction()
		and not receiver.is_player_combatant()
	)


func configure(
	owner_entity: Entity,
	health_component: HealthComponent,
	status_component,
	hit_reaction_component: HitReaction,
	defence_component = null
) -> void:
	_owner_entity = owner_entity
	_health = health_component
	_status_controller = status_component
	_hit_reaction = hit_reaction_component
	_defence_component = defence_component


func resolve(event: HealthEvent) -> HealthResult:
	if not _is_valid_event(event):
		var invalid := HealthResult.create(
			event,
			HealthResult.Outcome.INVALID,
			0.0,
			0,
			false,
			false
		)
		_deliver_result(invalid)
		return invalid

	if event.operation == HealthEvent.Operation.HEAL:
		var heal_result := HealthResult.create(
			event,
			HealthResult.Outcome.INVALID,
			0.0,
			0,
			false,
			false
		)
		_deliver_result(heal_result)
		return heal_result

	if event.melee_contact and not _live_melee(event):
		return _reject(event, HealthResult.Outcome.CANCELLED, &"attack_cancelled")
	if event.is_direct_damage() and _owner_entity.uses_combat_hit_reaction() and event.reaction_debug.is_empty():
		event.reaction_debug = _capture_reaction_debug(event, _owner_entity.get_melee_snapshot())
	if _owner_entity.is_combat_invincible():
		return _reject(event, HealthResult.Outcome.INVINCIBLE, &"invincible")

	var defensive_level := _owner_entity.get_defensive_level()
	var outcome := HealthResult.Outcome.APPLIED
	if event.interception_checked:
		outcome = event.interception_outcome
	elif _defence_component != null:
		outcome = int(_defence_component.intercept(event))


	var combat_difference := -1
	var combat_reaction_eligible := false
	if outcome == HealthResult.Outcome.APPLIED and _owner_entity.uses_combat_hit_reaction():
		combat_difference = event.reaction_difference if event.clash_resolved else calculate_reaction_value(event.impact, _owner_entity.get_poise(), _owner_entity.get_melee_snapshot())
		event.reaction_difference = combat_difference
		combat_reaction_eligible = event.force_clash_level_one or _is_reaction_eligible(combat_difference, event.instigator as Entity, _owner_entity, event.is_direct_damage())
		if not event.reaction_debug.is_empty():
			event.reaction_debug.merge({"value": combat_difference, "calculated": true, "eligible": combat_reaction_eligible, "player_zero_advantage": combat_difference == 0 and _is_reaction_eligible(0, event.instigator as Entity, _owner_entity, event.is_direct_damage())}, true)

	var reaction_level := 0
	if event.is_direct_damage():
		ImpactProbe.record("reaction_decision", {"target": str(_owner_entity.get_path()), "action_id": event.source_action_id, "impact": event.impact, "target_poise": _owner_entity.get_poise(), "combat_reaction": _owner_entity.uses_combat_hit_reaction(), "hit_reaction_value": combat_difference, "eligible": combat_reaction_eligible, "player_winning_tie": event.player_winning_clash_tie, "clash_resolved": event.clash_resolved, "outcome": HealthResult.Outcome.keys()[outcome], "reaction_level": _hit_reaction.level_for_value(combat_difference) if combat_reaction_eligible else 0})
	if combat_reaction_eligible:
		reaction_level = _hit_reaction.level_for_value(combat_difference)
		_owner_entity.cancel_combat_attack()
		if _hit_transaction_depth > 0:
			if maxi(combat_difference, 0) > _pending_difference:
				_pending_difference = maxi(combat_difference, 0)
				_pending_direction = event.contact_direction
		else:
			# Keep signed diagnostics; zero explicitly selects configured Level 1.
			_owner_entity.request_combat_hit_reaction(maxi(combat_difference, 0), event.contact_direction)
	elif not event.fire_defence and outcome != HealthResult.Outcome.PARRIED and (outcome == HealthResult.Outcome.BLOCKED or not _owner_entity.uses_combat_hit_reaction()):
		reaction_level = maxi(event.impact - defensive_level, 0)

	var health_delta := 0.0
	var effect_applied := false
	var resolution_tag: StringName = &""
	if outcome == HealthResult.Outcome.APPLIED:
		var endurance: Dictionary = _status_controller.resolve_elemental_endurance(event)
		var multiplier := float(endurance["multiplier"])
		health_delta = _health.apply_damage(event.amount * multiplier)
		if bool(endurance["full_resist"]):
			resolution_tag = &"elemental_endurance_full_resist"
		if not event.effect_instruction.is_empty() and multiplier > 0.0:
			effect_applied = bool(
				_status_controller.apply_instruction(
					event.effect_instruction,
					event.instigator
				)
			)

	if outcome == HealthResult.Outcome.BLOCKED and event.fire_defence:
		# Chip damage stays a defended result: no normal-hit resources or status payload.
		health_delta = _health.apply_damage(event.amount * event.block_damage_multiplier)
		resolution_tag = &"fire_block"

	var zero_reached := _health.is_zero()
	var result := HealthResult.create(
		event,
		outcome,
		health_delta,
		reaction_level,
		effect_applied,
		zero_reached,
		resolution_tag
	)
	if not combat_reaction_eligible:
		_hit_reaction.execute(reaction_level, event.contact_direction)
	if zero_reached and _owner_entity.should_refill_health_at_zero():
		_health.reset_to_maximum()
	_deliver_result(result)
	return result


func _is_valid_event(event: HealthEvent) -> bool:
	if event == null or _owner_entity == null or _health == null:
		return false
	if event.target != _owner_entity or event.amount < 0.0:
		return false
	if event.operation == HealthEvent.Operation.DAMAGE:
		return event.impact >= 0 and event.impact <= 100
	return event.operation == HealthEvent.Operation.HEAL


func _deliver_result(result: HealthResult) -> void:
	if result.event == null:
		return
	if result.event.is_direct_damage():
		ImpactProbe.record("health_result", {"target": str(result.event.target.get_path()) if is_instance_valid(result.event.target) else "invalid", "action_id": result.event.source_action_id, "impact": result.event.impact, "outcome": HealthResult.Outcome.keys()[result.outcome], "reaction_level": result.final_reaction_level, "health_delta": result.health_delta, "tag": result.resolution_tag})
	var target := result.event.target
	if is_instance_valid(target) and target.has_method("receive_health_result"):
		target.call("receive_health_result", result)
	var instigator := result.event.instigator
	if instigator != target and is_instance_valid(instigator) and instigator.has_method("receive_health_result"):
		instigator.call("receive_health_result", result)
	_emit_reaction_debug(result.event, result.final_reaction_level, HealthResult.Outcome.keys()[result.outcome])


func _capture_reaction_debug(event: HealthEvent, receiver_move: Dictionary, attacker_move: Dictionary = {}) -> Dictionary:
	var receiver := event.target as Entity
	var attacker := event.instigator as Entity
	if not is_instance_valid(receiver):
		return {}
	if attacker_move.is_empty() and is_instance_valid(attacker):
		attacker_move = attacker.get_melee_snapshot()
	return {
		"receiver_id": receiver.get_instance_id(),
		"attacker_id": attacker.get_instance_id() if is_instance_valid(attacker) else 0,
		"attacker_move": str(attacker_move.get("move_id", event.school)) if event.melee_contact else "Cast",
		"incoming_impact": event.impact,
		"receiver_poise": receiver.get_poise(),
		"receiver_move_impact": int(receiver_move.get("impact", 0)),
		"receiver_active": bool(receiver_move.get("active", false)),
		"active_contribution": int(receiver_move.get("impact", 0)) if bool(receiver_move.get("active", false)) else 0,
		"calculated": false,
	}


func _emit_reaction_debug(event: HealthEvent, level: int, outcome: String) -> void:
	if not event.is_direct_damage() or event.reaction_debug.is_empty():
		return
	var snapshot := event.reaction_debug.duplicate(true)
	snapshot.merge({"level": level, "outcome": outcome, "player_tie": event.player_winning_clash_tie, "clash": snapshot.get("clash_contact", event.clash_resolved)}, true)
	reaction_evaluated.emit(snapshot)


func begin_hit_transaction() -> void:
	_hit_transaction_depth += 1


func end_hit_transaction() -> void:
	_hit_transaction_depth = maxi(_hit_transaction_depth - 1, 0)
	if _hit_transaction_depth != 0 or _pending_difference < 0:
		return
	var difference := _pending_difference
	var direction := _pending_direction
	_pending_difference = -1
	_pending_direction = Vector2.ZERO
	if not _health.is_zero():
		_owner_entity.request_combat_hit_reaction(difference, direction)


func reset_for_stage() -> void:
	_hit_transaction_depth = 0
	_pending_difference = -1
	_pending_direction = Vector2.ZERO


func _reject(event: HealthEvent, outcome: int, tag: StringName) -> HealthResult:
	var result := HealthResult.create(event, outcome, 0.0, 0, false, false, tag)
	_deliver_result(result)
	return result


static func _live_melee(event: HealthEvent) -> bool:
	var attacker := event.instigator as Entity
	if not is_instance_valid(attacker) or not is_instance_valid(event.target):
		return false
	var move := attacker.get_melee_snapshot()
	return bool(move.get("active", false)) and int(move.get("action_id", 0)) == event.source_action_id


func _prepare_melee_interception(event: HealthEvent) -> void:
	if event.interception_checked:
		return
	event.reaction_debug = _capture_reaction_debug(event, _owner_entity.get_melee_snapshot())
	event.interception_checked = true
	if _owner_entity.is_combat_invincible():
		event.interception_outcome = HealthResult.Outcome.INVINCIBLE
	else:
		event.interception_outcome = int(_defence_component.intercept(event)) if _defence_component != null else HealthResult.Outcome.APPLIED


static func _deliver_melee(event: HealthEvent) -> HealthResult:
	var target := event.target as Entity
	var attacker := event.instigator as Entity
	if not is_instance_valid(target):
		return null
	var result: HealthResult
	if _live_melee(event):
		result = target.receive_health_event(event)
	else:
		result = target.health_resolver._reject(event, HealthResult.Outcome.CANCELLED, &"attack_cancelled")
	if is_instance_valid(attacker):
		attacker.on_clash_contact_resolved(result)
	return result


static func resolve_melee_contacts(events: Array[HealthEvent]) -> void:
	var handled: Dictionary = {}
	for index in range(events.size()):
		if handled.has(index):
			continue
		var event := events[index]
		if not _live_melee(event):
			_deliver_melee(event)
			continue
		var reverse_index := -1
		for other_index in range(index + 1, events.size()):
			var other := events[other_index]
			if not handled.has(other_index) and other.instigator == event.target and other.target == event.instigator and _live_melee(other):
				reverse_index = other_index
				break
		if reverse_index < 0:
			_deliver_melee(event)
			continue
		var reverse := events[reverse_index]
		var attacker := event.instigator as Entity
		var receiver := event.target as Entity
		# Both events came from actual geometry at this same common sample.
		# Defence/invincibility intercept once, before considering a clash.
		receiver.health_resolver._prepare_melee_interception(event)
		attacker.health_resolver._prepare_melee_interception(reverse)
		if event.interception_outcome != HealthResult.Outcome.APPLIED or reverse.interception_outcome != HealthResult.Outcome.APPLIED or not _live_melee(event) or not _live_melee(reverse):
			_deliver_melee(event)
			continue
		handled[reverse_index] = true
		var incoming_value := calculate_reaction_value(event.impact, receiver.get_poise(), receiver.get_melee_snapshot())
		var reverse_value := calculate_reaction_value(reverse.impact, attacker.get_poise(), attacker.get_melee_snapshot())
		var tied := incoming_value == reverse_value
		var incoming_wins := incoming_value > reverse_value or (tied and attacker.is_player_combatant())
		var winner: HealthEvent = event if incoming_wins else reverse
		var loser: HealthEvent = reverse if incoming_wins else event
		winner.clash_resolved = true
		winner.reaction_difference = incoming_value if incoming_wins else reverse_value
		winner.force_clash_level_one = winner.reaction_difference <= 0
		winner.player_winning_clash_tie = tied
		for contact in [event, reverse]:
			contact.reaction_debug.merge({"clash_contact": true, "incoming_hit_reaction_value": incoming_value, "counter_hit_reaction_value": reverse_value}, true)
		loser.reaction_debug.merge({"value": reverse_value if incoming_wins else incoming_value, "calculated": true, "eligible": false}, true)
		ImpactProbe.record("clash_decision", {"action_id": event.source_action_id, "target": str(event.target.get_path()), "incoming_hit_reaction_value": incoming_value, "counter_hit_reaction_value": reverse_value, "zero_tie": tied and incoming_value == 0, "attacker_wins": incoming_wins, "defender_wins": not incoming_wins})
		var winning_result := _deliver_melee(winner)
		if winning_result == null or winning_result.outcome != HealthResult.Outcome.APPLIED:
			_deliver_melee(loser)
			continue
		# Winner's accepted reaction cancels the loser. Never re-deliver its damage.
		var losing_receiver := loser.target as Entity
		var losing_attacker := loser.instigator as Entity
		if is_instance_valid(losing_receiver):
			var result := losing_receiver.health_resolver._reject(loser, HealthResult.Outcome.CLASH_LOST, &"clash_lost")
			if is_instance_valid(losing_attacker):
				losing_attacker.on_clash_contact_resolved(result)
