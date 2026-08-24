class_name SpellProjectile
extends Area2D

signal impact(target: Entity, contact_point: Vector2, payload: Dictionary)

const SCHOOL_COLORS := {
	&"fire": Color("ff493d"),
	&"water": Color("3a96ff"),
	&"air": Color("f4f6ff"),
	&"earth": Color("8b5a2b"),
}
const TRAVEL_STREAM_PATHS := {
	&"fire": "res://assets/prototype/audio/projectile/fire_travel.ogg",
	&"water": "res://assets/prototype/audio/projectile/water_travel.ogg",
	&"air": "res://assets/prototype/audio/projectile/air_travel.ogg",
	&"earth": "res://assets/prototype/audio/projectile/earth_travel.ogg",
}

@onready var visual: Polygon2D = $Visual
@onready var travel_audio: AudioStreamPlayer = $TravelAudio

var _payload: Dictionary = {}
var _direction := Vector2.RIGHT
var _speed := 0.0
var _maximum_distance := 0.0
var _travelled_distance := 0.0


func _ready() -> void:
	_update_visual_color()
	var primary_school := StringName(_payload.get("primary_school", &"fire"))
	var stream_path := str(TRAVEL_STREAM_PATHS.get(primary_school, TRAVEL_STREAM_PATHS[&"fire"]))
	var stream: AudioStream = _load_audio_stream(stream_path)
	if stream != null:
		travel_audio.stream = stream
		travel_audio.play()


func initialize(payload: Dictionary, maximum_distance: float, travel_duration: float) -> void:
	_payload = payload.duplicate(true)
	_direction = Vector2(_payload["direction"]).normalized()
	global_position = Vector2(_payload["origin"])
	_maximum_distance = maximum_distance
	_speed = maximum_distance / travel_duration
	_update_visual_color()
	_trace(&"spawned", {"primary_school": _payload["primary_school"], "primary_level": _payload["primary_level"], "secondary_school": _payload.get("secondary_school", &""), "secondary_level": _payload.get("secondary_level", 0), "maximum_distance": _maximum_distance, "speed": _speed})


func _physics_process(delta: float) -> void:
	if _payload.is_empty():
		return
	var step_distance := _speed * delta
	global_position += _direction * step_distance
	_travelled_distance += step_distance
	if _travelled_distance >= _maximum_distance:
		_trace(&"expired", {"travelled_distance": _travelled_distance, "maximum_distance": _maximum_distance})
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	var target: Entity = body as Entity
	if target == null or target == _payload.get("instigator"):
		return
	_trace(&"impacted", {"target": target.name, "position": global_position, "travelled_distance": _travelled_distance})
	impact.emit(target, global_position, _payload.duplicate(true))
	queue_free()


func _update_visual_color() -> void:
	if visual == null:
		return
	var primary_school := StringName(_payload["primary_school"])
	var secondary_school := StringName(_payload.get("secondary_school", &""))
	var primary_color: Color = SCHOOL_COLORS[primary_school]
	var display_color := primary_color
	if secondary_school != &"":
		var primary_level := float(_payload["primary_level"])
		var secondary_level := float(_payload["secondary_level"])
		var secondary_weight := secondary_level / (primary_level + secondary_level)
		var secondary_color: Color = SCHOOL_COLORS[secondary_school]
		display_color = primary_color.lerp(secondary_color, secondary_weight)
	visual.color = display_color


func _load_audio_stream(path: String) -> AudioStream:
	return ResourceLoader.load(path, "AudioStream") as AudioStream


func _trace(event_name: StringName, data: Dictionary) -> void:
	if OS.is_debug_build():
		print("[TRACE][PROJECTILE] %s %s" % [event_name, data])
