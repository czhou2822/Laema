extends RefCounted


func apply(
	instigator: Entity,
	target: Entity,
	level: int,
	combat_config: Dictionary,
	direction: Vector2,
	contact_point: Vector2
) -> void:
	if level < 1 or target == null:
		return
	var instruction := {
		"type": &"fire_dot",
		"stacks": level,
	}
	var event := HealthEvent.damage(
		instigator,
		target,
		float(combat_config["finisher_damage"]),
		int(combat_config["direct_impact"]),
		HealthEvent.Delivery.DIRECT,
		&"fire",
		instruction,
		direction,
		contact_point
	)
	target.receive_health_event(event)
