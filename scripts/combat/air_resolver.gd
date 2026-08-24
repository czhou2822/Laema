extends RefCounted

const TARGET_COLLISION_MASK := 2


func apply(
	instigator: Entity,
	world: World2D,
	contact_target: Entity,
	contact_point: Vector2,
	direction: Vector2,
	level: int,
	combat_config: Dictionary,
	air_config: Dictionary
) -> void:
	if level < 1 or world == null or contact_target == null:
		return

	var targets: Array[Entity] = [contact_target]
	if level >= 2:
		var shape := CircleShape2D.new()
		shape.radius = float(air_config["chain_radius"])
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = shape
		query.transform = Transform2D(0.0, contact_point)
		query.collision_mask = TARGET_COLLISION_MASK
		query.collide_with_bodies = true
		query.collide_with_areas = false

		var target_limit := mini(level, int(air_config["max_chain_targets"]))
		for result in world.direct_space_state.intersect_shape(query, 32):
			var target := result.get("collider") as Entity
			if target == null or targets.has(target):
				continue
			targets.append(target)
			if targets.size() >= target_limit:
				break

	var damage_multiplier := (
		1.0 + float(air_config["damage_per_level"]) * float(level - 1)
	)
	for target in targets:
		var target_contact_point := (
			contact_point if target == contact_target else target.global_position
		)
		var event := HealthEvent.damage(
			instigator,
			target,
			float(combat_config["finisher_damage"]) * damage_multiplier,
			int(combat_config["direct_impact"]),
			HealthEvent.Delivery.DIRECT,
			&"air",
			{},
			direction,
			target_contact_point
		)
		target.receive_health_event(event)
