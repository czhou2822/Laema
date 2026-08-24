class_name HealthEvent
extends RefCounted

enum Operation {
	DAMAGE,
	HEAL,
}

enum Delivery {
	DIRECT,
	DOT_TICK,
	HOT_TICK,
}

var instigator: Node
var target: Node
var operation := Operation.DAMAGE
var amount := 0.0
var impact := 0
var delivery := Delivery.DIRECT
var school: StringName = &""
var effect_instruction: Dictionary = {}
var contact_direction := Vector2.ZERO
var contact_point := Vector2.ZERO


static func damage(
	instigator_node: Node,
	target_node: Node,
	requested_amount: float,
	impact_level: int,
	delivery_type: int,
	source_school: StringName,
	instruction: Dictionary = {},
	direction: Vector2 = Vector2.ZERO,
	point: Vector2 = Vector2.ZERO
) -> HealthEvent:
	var event := HealthEvent.new()
	event.instigator = instigator_node
	event.target = target_node
	event.operation = Operation.DAMAGE
	event.amount = requested_amount
	event.impact = impact_level
	event.delivery = delivery_type
	event.school = source_school
	event.effect_instruction = instruction.duplicate(true)
	event.contact_direction = direction
	event.contact_point = point
	return event


func is_direct_damage() -> bool:
	return operation == Operation.DAMAGE and delivery == Delivery.DIRECT
