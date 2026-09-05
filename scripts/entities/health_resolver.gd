class_name HealthResolver
extends Node

var _owner_entity: Entity
var _health: HealthComponent
var _status_controller
var _hit_reaction: HitReaction
var _defence_component


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

	var defensive_level := _owner_entity.get_defensive_level()
	var outcome := HealthResult.Outcome.APPLIED
	if _defence_component != null:
		outcome = int(_defence_component.intercept(event))

	var reaction_level := 0
	if outcome != HealthResult.Outcome.PARRIED:
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
		return event.impact >= 0 and event.impact <= 5
	return event.operation == HealthEvent.Operation.HEAL


func _deliver_result(result: HealthResult) -> void:
	if result.event == null:
		return
	var target := result.event.target
	if is_instance_valid(target) and target.has_method("receive_health_result"):
		target.call("receive_health_result", result)
	var instigator := result.event.instigator
	if instigator != target and is_instance_valid(instigator) and instigator.has_method("receive_health_result"):
		instigator.call("receive_health_result", result)
