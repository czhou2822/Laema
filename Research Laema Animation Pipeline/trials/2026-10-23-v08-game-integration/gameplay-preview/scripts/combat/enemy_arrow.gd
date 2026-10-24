extends Node2D
## Root-owned projectile. Sweep each travelled segment against Player and walls.

@onready var visual: Sprite2D = $Visual

var _instigator: WeakRef
var _direction := Vector2.RIGHT
var _damage := 0.0
var _impact := 0
var _action_id := 0
var _maximum_distance := 0.0
var _travelled_distance := 0.0
var _speed := 0.0
var _initialized := false


func initialize(
	instigator: Entity, origin: Vector2, direction: Vector2,
	damage: float, impact: int, action_id: int,
	maximum_distance: float, travel_duration: float
) -> void:
	_instigator = weakref(instigator)
	global_position = origin
	_direction = direction.normalized()
	_damage = damage
	_impact = impact
	_action_id = action_id
	_maximum_distance = maxf(maximum_distance, 0.0)
	_speed = _maximum_distance / maxf(travel_duration, 0.05)
	visual.flip_h = _direction.x < 0.0
	_initialized = true


func _physics_process(delta: float) -> void:
	if not _initialized:
		return
	var instigator := _instigator.get_ref() as Entity
	if not is_instance_valid(instigator):
		queue_free()
		return
	var distance := minf(_speed * delta, _maximum_distance - _travelled_distance)
	if distance <= 0.0:
		queue_free()
		return
	var endpoint := global_position + _direction * distance
	# Player occupies layer 1 and level walls/floor layer 3. Other enemies are
	# excluded; hit_from_inside also resolves a target touching the muzzle.
	var query := PhysicsRayQueryParameters2D.create(global_position, endpoint, 5)
	query.exclude = [instigator.get_rid()]
	query.hit_from_inside = true
	var collision := get_world_2d().direct_space_state.intersect_ray(query)
	if not collision.is_empty():
		global_position = collision["position"]
		var target := collision["collider"] as Entity
		if is_instance_valid(target) and target.is_player_combatant():
			var event := HealthEvent.damage(
				instigator, target, _damage, _impact, HealthEvent.Delivery.DIRECT,
				&"", {}, _direction, global_position, _action_id
			)
			target.receive_health_event(event)
		# First contact consumes the arrow, including block/parry/invincibility.
		queue_free()
		return
	global_position = endpoint
	_travelled_distance += distance
	if _travelled_distance >= _maximum_distance:
		queue_free()
