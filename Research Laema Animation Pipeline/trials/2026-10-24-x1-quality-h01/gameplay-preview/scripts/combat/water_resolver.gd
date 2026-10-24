extends RefCounted

const TARGET_COLLISION_MASK := 2


func apply(
	instigator: Entity,
	world: World2D,
	contact_point: Vector2,
	direction: Vector2,
	level: int,
	combat_config: Dictionary,
	water_config: Dictionary,
	direct_damage_multiplier: float = 1.0
) -> void:
	if level < 1 or world == null:
		return
	var level_data: Dictionary = water_config["levels"][level - 1]
	var radius := (
		float(water_config["base_radius"])
		+ float(water_config["radius_per_level"]) * float(level - 1)
	)
	var shape := CircleShape2D.new()
	shape.radius = radius
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, contact_point)
	query.collision_mask = TARGET_COLLISION_MASK
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var results := world.direct_space_state.intersect_shape(query, 32)
	var seen: Dictionary = {}
	for result in results:
		var target := result.get("collider") as Entity
		if target == null:
			continue
		var target_id := target.get_instance_id()
		if seen.has(target_id):
			continue
		seen[target_id] = true
		var instruction := {
			"type": &"water_status",
			"level": level,
			"status": StringName(level_data["status"]),
			"duration": float(level_data["duration"]),
			"slow_percent": float(level_data["slow_percent"]),
			"radius": radius,
		}
		var event := HealthEvent.damage(
			instigator,
			target,
			float(combat_config["casting_damage"]) * direct_damage_multiplier,
			int(combat_config["direct_impact"]),
			HealthEvent.Delivery.DIRECT,
			&"water",
			instruction,
			direction,
			contact_point
		)
		target.receive_health_event(event)
