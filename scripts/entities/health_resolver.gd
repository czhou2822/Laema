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
var _pending_push_scale := 1.0
var _pending_direction := Vector2.ZERO


static func calculate_reaction_value(incoming_impact: int, receiver_poise: int, receiver_move: Dictionary) -> int:
	var active_impact := int(receiver_move.get("impact", 0)) if bool(receiver_move.get("active", false)) else 0
	return incoming_impact - receiver_poise - active_impact


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

	if event.is_direct_damage() and _owner_entity.uses_combat_hit_reaction() and event.reaction_debug.is_empty():
		event.reaction_debug = _capture_reaction_debug(event, _owner_entity.get_melee_snapshot())
	if _hit_reaction.is_invincible():
		return _reject(event, HealthResult.Outcome.INVINCIBLE, &"invincible")

	var defensive_level := _owner_entity.get_defensive_level()
	var outcome := HealthResult.Outcome.APPLIED
	if _defence_component != null:
		outcome = int(_defence_component.intercept(event))


	var combat_difference := -1
	var combat_reaction_eligible := false
	if outcome == HealthResult.Outcome.APPLIED and _owner_entity.uses_combat_hit_reaction():
		if event.melee_contact and not event.clash_resolved:
			var clash_result: HealthResult = _resolve_clash(event)
			if clash_result != null:
				return clash_result
		combat_difference = event.reaction_difference if event.clash_resolved else calculate_reaction_value(event.impact, _owner_entity.get_poise(), _owner_entity.get_melee_snapshot())
		event.reaction_difference = combat_difference
		combat_reaction_eligible = combat_difference > 0 or (combat_difference == 0 and event.clash_resolved and event.player_winning_clash_tie)
		if not event.reaction_debug.is_empty():
			event.reaction_debug.merge({"value": combat_difference, "calculated": true, "eligible": combat_reaction_eligible}, true)

	var reaction_level := 0
	if event.is_direct_damage():
		ImpactProbe.record("reaction_decision", {"target": str(_owner_entity.get_path()), "action_id": event.source_action_id, "impact": event.impact, "target_poise": _owner_entity.get_poise(), "combat_reaction": _owner_entity.uses_combat_hit_reaction(), "hit_reaction_value": combat_difference, "eligible": combat_reaction_eligible, "player_winning_tie": event.player_winning_clash_tie, "clash_resolved": event.clash_resolved, "outcome": HealthResult.Outcome.keys()[outcome], "reaction_level": _hit_reaction.level_for_value(combat_difference) if combat_reaction_eligible else 0})
	if combat_reaction_eligible:
		reaction_level = _hit_reaction.level_for_value(combat_difference)
		_owner_entity.cancel_combat_attack()
		if _hit_transaction_depth > 0:
			if combat_difference > _pending_difference:
				_pending_difference = combat_difference
				_pending_direction = event.contact_direction
				_pending_push_scale = event.push_scale
		else:
			_hit_reaction.execute_combat(combat_difference, event.contact_direction, event.push_scale)
	elif outcome != HealthResult.Outcome.PARRIED and (outcome == HealthResult.Outcome.BLOCKED or not _owner_entity.uses_combat_hit_reaction()):
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
	var push_scale := _pending_push_scale
	_pending_difference = -1
	_pending_direction = Vector2.ZERO
	_pending_push_scale = 1.0
	if not _health.is_zero():
		_hit_reaction.execute_combat(difference, direction, push_scale)


func reset_for_stage() -> void:
	_hit_transaction_depth = 0
	_pending_difference = -1
	_pending_direction = Vector2.ZERO
	_pending_push_scale = 1.0


func _reject(event: HealthEvent, outcome: int, tag: StringName) -> HealthResult:
	var result := HealthResult.create(event, outcome, 0.0, 0, false, false, tag)
	_deliver_result(result)
	return result


func _resolve_clash(event: HealthEvent) -> HealthResult:
	var attacker := event.instigator as Entity
	if not is_instance_valid(attacker):
		return null
	var incoming: Dictionary = attacker.get_melee_snapshot()
	if incoming.is_empty() or int(incoming["action_id"]) != event.source_action_id:
		return _reject(event, HealthResult.Outcome.CANCELLED, &"attack_cancelled")
	var defending: Dictionary = _owner_entity.get_melee_snapshot()
	# One physical contact is enough; overlapping authored active intervals decide
	# eligibility without waiting for a reverse contact on the same update.
	if not bool(incoming["active"]) or defending.is_empty() or not bool(defending["active"]):
		return null
	# Calculate each receiving side independently. Poise never boosts an outgoing hit.
	var incoming_value := calculate_reaction_value(event.impact, _owner_entity.get_poise(), defending)
	var counter_value := calculate_reaction_value(int(defending["impact"]), attacker.get_poise(), incoming)
	var zero_tie := incoming_value == 0 and counter_value == 0
	var attacker_wins := incoming_value > 0 or (zero_tie and attacker.is_player_combatant())
	var defender_wins := counter_value > 0 or (zero_tie and _owner_entity.is_player_combatant())
	if not event.reaction_debug.is_empty():
		event.reaction_debug.merge({"value": incoming_value, "calculated": true, "eligible": false, "clash_contact": true}, true)
	ImpactProbe.record("clash_decision", {"action_id": event.source_action_id, "target": str(_owner_entity.get_path()), "attacker_poise_defensive_only": attacker.get_poise(), "incoming_impact": event.impact, "target_poise": _owner_entity.get_poise(), "defending_impact": defending["impact"], "incoming_hit_reaction_value": incoming_value, "counter_hit_reaction_value": counter_value, "zero_tie": zero_tie, "attacker_wins": attacker_wins, "defender_wins": defender_wins})
	if attacker_wins:
		event.reaction_difference = incoming_value
		event.clash_resolved = true
		event.player_winning_clash_tie = zero_tie
		return null
	if not defender_wins:
		# No interruption: apply this connected hit normally and let both attacks continue.
		# A later reverse hit still needs its own physical contact; do not synthesize one.
		event.reaction_difference = incoming_value
		event.clash_resolved = true
		return null

	# Resolve the winning move against the loser at the established contact.
	# It is a clash result, not a second range-free collision query.
	var counter := HealthEvent.damage(
		_owner_entity, attacker, float(defending["damage"]), int(defending["impact"]),
		HealthEvent.Delivery.DIRECT, StringName(defending["school"]), {},
		-event.contact_direction, event.contact_point, int(defending["action_id"]),
		Array(defending.get("composition", []))
	)
	counter.melee_contact = true
	counter.push_scale = float(defending.get("push_scale", 1.0))
	counter.clash_resolved = true
	counter.reaction_difference = counter_value
	counter.player_winning_clash_tie = zero_tie
	counter.reaction_debug = _capture_reaction_debug(counter, incoming, defending)
	if Array(defending.get("hit_targets", [])).has(attacker.get_instance_id()):
		# Report the actual reaction without inventing a second damage result.
		counter.reaction_debug.merge({"value": counter_value, "calculated": true, "eligible": true}, true)
		attacker.cancel_combat_attack()
		attacker.hit_reaction.execute_combat(counter_value, -event.contact_direction, counter.push_scale)
		attacker.health_resolver._emit_reaction_debug(counter, attacker.hit_reaction.level_for_value(counter_value), "REACTION ONLY")
		return _reject(event, HealthResult.Outcome.CLASH_LOST, &"clash_lost")
	var counter_result: HealthResult = attacker.receive_health_event(counter)
	_owner_entity.on_clash_contact_resolved(counter_result)
	return _reject(event, HealthResult.Outcome.CLASH_LOST, &"clash_lost")
