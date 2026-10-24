class_name StageArea
extends Node2D

signal exit_reached

enum Lifecycle {
	PREPARED,
	ACTIVE,
	RETIRED,
}

@export var camera_left := -720.0
@export var camera_right := 720.0

@onready var entry_anchor: Marker2D = $EntryAnchor
@onready var exit_anchor: Marker2D = $ExitAnchor
@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var camera_anchor: Marker2D = $CameraAnchor
@onready var right_gate: StaticBody2D = $RightGate
@onready var exit_trigger: Area2D = $ExitTrigger

var _lifecycle := Lifecycle.PREPARED
var _exit_authorized := false


func _ready() -> void:
	exit_trigger.body_entered.connect(_on_exit_body_entered)
	set_lifecycle(Lifecycle.PREPARED)


func set_lifecycle(next_lifecycle: Lifecycle) -> void:
	_lifecycle = next_lifecycle
	var active := _lifecycle == Lifecycle.ACTIVE
	for target in get_tree().get_nodes_in_group("status_targets"):
		if is_ancestor_of(target) and target.has_method("set_stage_active"):
			target.call("set_stage_active", active)
	exit_trigger.monitoring = active and _exit_authorized
	exit_trigger.monitorable = active and _exit_authorized
	if _lifecycle == Lifecycle.RETIRED:
		exit_trigger.set_deferred("monitoring", false)
		right_gate.set_deferred("collision_layer", 0)


func authorize_exit(authorized: bool) -> void:
	_exit_authorized = authorized
	var unlocked := authorized and _lifecycle == Lifecycle.ACTIVE
	right_gate.set_deferred("collision_layer", 0 if unlocked else 4)
	exit_trigger.set_deferred("monitoring", unlocked)
	exit_trigger.set_deferred("monitorable", unlocked)


func get_entry_world_position() -> Vector2:
	return entry_anchor.global_position


func get_exit_world_position() -> Vector2:
	return exit_anchor.global_position


func get_spawn_world_position() -> Vector2:
	return player_spawn.global_position


func get_camera_world_position() -> Vector2:
	return camera_anchor.global_position


func get_camera_world_bounds() -> Vector2:
	return Vector2(global_position.x + camera_left, global_position.x + camera_right)


func get_targets() -> Array[Node]:
	var targets: Array[Node] = []
	for target in get_tree().get_nodes_in_group("status_targets"):
		if is_ancestor_of(target):
			targets.append(target)
	return targets


func _on_exit_body_entered(body: Node2D) -> void:
	if _lifecycle != Lifecycle.ACTIVE or not _exit_authorized:
		return
	if body.is_in_group("player") or body.name == "Player":
		exit_reached.emit()
