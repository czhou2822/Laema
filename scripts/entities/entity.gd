class_name Entity
extends CharacterBody2D

@onready var health: HealthComponent = $Health
@onready var health_resolver: HealthResolver = $HealthResolver
@onready var status_controller = $Status
@onready var hit_reaction: HitReaction = $HitReaction
@onready var feedback: FeedbackComponent = $Feedback

var _base_defensive_level := 0
var _refill_at_zero := false


func configure_entity(
	maximum_health: float,
	defensive_level: int,
	refill_at_zero: bool,
	hit_reaction_config: Dictionary,
	status_config: Dictionary,
	defence_component = null
) -> void:
	_base_defensive_level = maxi(defensive_level, 0)
	_refill_at_zero = refill_at_zero
	feedback.configure(self, float(status_config["ui"]["cast_feedback_duration"]))
	health.configure(maximum_health)
	hit_reaction.configure(hit_reaction_config)
	status_controller.configure(self, status_config)
	health_resolver.configure(
		self,
		health,
		status_controller,
		hit_reaction,
		defence_component
	)


func apply_feedback_runtime_tuning(duration: float) -> void:
	feedback.apply_runtime_tuning(duration)


func receive_health_event(event: HealthEvent) -> HealthResult:
	return health_resolver.resolve(event)


func receive_health_result(_result: HealthResult) -> void:
	pass


func get_defensive_level() -> int:
	return _base_defensive_level


func should_refill_health_at_zero() -> bool:
	return _refill_at_zero
