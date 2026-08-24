class_name HealthResult
extends RefCounted

enum Outcome {
	APPLIED,
	BLOCKED,
	PARRIED,
	INVALID,
}

var event: HealthEvent
var outcome := Outcome.INVALID
var health_delta := 0.0
var final_reaction_level := 0
var effect_applied := false
var zero_reached := false


static func create(
	source_event: HealthEvent,
	resolution_outcome: int,
	actual_health_delta: float,
	reaction_level: int,
	did_apply_effect: bool,
	did_reach_zero: bool
) -> HealthResult:
	var result := HealthResult.new()
	result.event = source_event
	result.outcome = resolution_outcome
	result.health_delta = actual_health_delta
	result.final_reaction_level = reaction_level
	result.effect_applied = did_apply_effect
	result.zero_reached = did_reach_zero
	return result
