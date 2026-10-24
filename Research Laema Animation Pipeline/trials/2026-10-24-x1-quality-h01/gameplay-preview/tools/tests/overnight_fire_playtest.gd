extends SceneTree
## Persistent rendered encounter recorder. Inputs are wall-time scripts, never a combat
## policy. Run in an isolated project/profile, not beside another owned game:
## Godot --path <project> --script res://tools/tests/overnight_fire_playtest.gd -- --out=<absolute-dir>
## Optional --scene=res://scenes/prototype_arena.tscn; only that scene and the
## default res://scenes/gym.tscn are allowed. Stage navigation stays in the UI.
## command.json: {id, actions:[{at_ms, action, pressed, value?}],
## capture_seconds?:15, capture_every_ms?:125 (50..5000), capture_scale?:0.5,
## capture_audio_seconds?:0 (0..30, opt-in Master-mix stereo PCM16 WAV),
## keyframes_ms?:[0,1000], quit?:false}. Use a new integer id for each command.
## Holds persist across commands. A new ordinary command waits until completion;
## quit:true stops immediately. Output: state.json, append-only events.jsonl,
## captures/<session>/*.png. No gameplay writes, seeded state or assertion policy.

class Observer extends Node:
	var tick: Callable
	var input_observed: Callable

	func _process(_delta: float) -> void:
		tick.call()

	func _input(event: InputEvent) -> void:
		input_observed.call(event)


class ImageEncoder extends RefCounted:
	# Worker owns this private Image until join. No scene/helper state, input,
	# rendering-server calls, callbacks or log access are allowed here.
	func encode(pixels: Image, stem: String, full: bool, scale: float) -> Dictionary:
		var started_us := Time.get_ticks_usec()
		var paths: Dictionary = {}
		var costs: Dictionary = {"full_png_save_us": null, "review_duplicate_us": null, "review_resize_us": 0, "review_prepare_us": null, "review_png_save_us": null}
		if full:
			paths["full"] = stem + "_full.png"
			var full_started_us := Time.get_ticks_usec()
			paths["full_error"] = pixels.save_png(paths["full"])
			costs["full_png_save_us"] = Time.get_ticks_usec() - full_started_us
		var prepare_started_us := Time.get_ticks_usec()
		var review: Image = pixels.duplicate() as Image
		costs["review_duplicate_us"] = Time.get_ticks_usec() - prepare_started_us
		if review == null:
			paths["error"] = "Private review Image duplication failed"
		else:
			if scale < 1.0:
				var resize_started_us := Time.get_ticks_usec()
				review.resize(maxi(1, roundi(pixels.get_width() * scale)), maxi(1, roundi(pixels.get_height() * scale)), Image.INTERPOLATE_BILINEAR)
				costs["review_resize_us"] = Time.get_ticks_usec() - resize_started_us
			costs["review_prepare_us"] = Time.get_ticks_usec() - prepare_started_us
			paths["review"] = stem + ".png"
			var png_started_us := Time.get_ticks_usec()
			paths["review_error"] = review.save_png(paths["review"])
			costs["review_png_save_us"] = Time.get_ticks_usec() - png_started_us
		var finished_us := Time.get_ticks_usec()
		costs["worker_encode_us"] = finished_us - started_us
		return {"paths": paths, "timings_us": costs, "encode_started_us": started_us, "encode_finished_us": finished_us}


const MAX_ACTIONS := 2048
const MAX_SCHEDULE_MS := 120000
const MAX_CAPTURE_SECONDS := 15.0
const MAX_KEYFRAMES := 32
const MAX_AUDIO_SECONDS := 30.0
const AUDIO_DRAIN_FRAMES := 2048
const INPUT_TAG := &"overnight_fire_playtest"
const ALLOWED_SCENES: Array[String] = ["res://scenes/gym.tscn", "res://scenes/prototype_arena.tscn"]
const ACTIONS: Array[StringName] = [
	&"move_left", &"move_right", &"light_attack", &"casting", &"defend", &"dodge",
	&"pause", &"ui_accept", &"ui_cancel", &"ui_up", &"ui_down", &"ui_left", &"ui_right",
	&"select_fire", &"select_water", &"select_air", &"select_earth", &"developer_overlay",
]
const ALIASES := {"left": "move_left", "right": "move_right", "defence": "defend", "developer-overlay": "developer_overlay"}

var _out := ""
var _scene_path := "res://scenes/gym.tscn"
var _session := ""
var _metadata: Dictionary = {}
var _log: FileAccess
var _observer: Observer
var _started_ms := 0
var _running := false
var _stopping := false
var _seen_ids: Dictionary = {}
var _held: Dictionary = {}
var _command: Dictionary = {}
var _schedule: Array[Dictionary] = []
var _schedule_index := 0
var _accepted_ms := 0
var _end_ms := 0
var _capture_until_ms := 0
var _capture_interval_ms := 125
var _capture_scale := 0.5
var _next_capture_ms := 0
var _keyframes: Array[int] = []
var _keyframe_index := 0
var _full_due: Array[int] = []
var _capture_pending := false
var _capture_worker: Thread
var _capture_encoder: ImageEncoder
var _capture_context: Dictionary = {}
var _capture_serial := 0
var _next_poll_ms := 0
var _next_state_ms := 0
var _next_observation_ms := 0
var _last_invalid_text := ""
var _pending_notice_id: Variant = null
var _unexpected_count := 0
var _axis_observations: Dictionary = {}
var _outcome_source: WeakRef
var _screen_keep_on_previous := false
var _screen_keep_on_captured := false
var _audio_capture: AudioEffectCapture
var _audio_file: FileAccess
var _audio: Dictionary = {}


func _initialize() -> void:
	call_deferred("_start")


func _start() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			_out = argument.trim_prefix("--out=").replace("\\", "/")
		elif argument.begins_with("--scene="):
			_scene_path = argument.trim_prefix("--scene=")
	if _scene_path not in ALLOWED_SCENES:
		printerr("Unsupported startup scene; only Gym and PrototypeArena are allowed: ", _scene_path)
		quit(2)
		return
	if _out.is_empty() or not _out.is_absolute_path():
		printerr("overnight_fire_playtest requires --out=<absolute-directory>")
		quit(2)
		return
	if DisplayServer.get_name() == "headless":
		printerr("This driver requires a rendered game; headless is not a substitute.")
		quit(2)
		return
	if DirAccess.make_dir_recursive_absolute(_out) != OK:
		printerr("Cannot create output directory: ", _out)
		quit(2)
		return
	_started_ms = Time.get_ticks_msec()
	_session = "%s_%s" % [OS.get_process_id(), Time.get_ticks_usec()]
	var log_path := _out.path_join("events.jsonl")
	_log = FileAccess.open(log_path, FileAccess.READ_WRITE if FileAccess.file_exists(log_path) else FileAccess.WRITE)
	if _log == null:
		printerr("Cannot open append-only event log: ", FileAccess.get_open_error())
		quit(2)
		return
	_log.seek_end()
	_metadata = {
		"engine": Engine.get_version_info(), "display_server": DisplayServer.get_name(),
		"rendering_method": RenderingServer.call("get_current_rendering_method") if RenderingServer.has_method("get_current_rendering_method") else "unavailable",
		"configured_renderer": ProjectSettings.get_setting("rendering/renderer/rendering_method", "forward_plus"),
		"physics_ticks_per_second": Engine.physics_ticks_per_second,
		"driver": "res://tools/tests/overnight_fire_playtest.gd", "scene": _scene_path,
		"driver_sha256": FileAccess.get_sha256("res://tools/tests/overnight_fire_playtest.gd"),
		"input_mode": "scheduled bound hardware events; wall-clock only; no state-oracle timing",
		"limits": "Synthetic input is not physical-controller acceptance. Captures need visual review. A single-file mailbox is not a queued command service.",
	}
	var joypads: Array[Dictionary] = []
	for device in Input.get_connected_joypads():
		joypads.append({"device": device, "name": Input.get_joy_name(device)})
	_metadata["connected_joypads_at_start"] = joypads
	_request_screen_keep_on()
	_record("session_started", {"metadata": _metadata})
	_observer = Observer.new()
	_observer.name = "OvernightFirePlaytestObserver"
	_observer.process_mode = Node.PROCESS_MODE_ALWAYS
	_observer.tick = _tick
	_observer.input_observed = _observe_input
	root.add_child(_observer)
	auto_accept_quit = false
	root.close_requested.connect(_stop)
	process_frame.connect(_sync_outcome_source)
	process_frame.connect(_collect_capture_worker)
	var error := change_scene_to_file(_scene_path)
	if error != OK:
		_record("startup_error", {"error": error_string(error)})
		_stop(2)
		return
	await process_frame
	await process_frame
	_sync_outcome_source()
	_running = true
	_record("ready", {"state": _snapshot(), "mailbox": _out.path_join("command.json")})
	_write_live_state()
	print("OVERNIGHT_PLAYTEST_READY ", _out)


func _sync_outcome_source() -> void:
	if _stopping:
		return
	var combat: Node = current_scene.get_node_or_null("Player/Combat") if is_instance_valid(current_scene) else null
	var previous: Node = _outcome_source.get_ref() if _outcome_source != null else null
	if previous == combat:
		return
	_disconnect_outcome_source()
	if combat != null and combat.has_signal(&"outcome_published"):
		_outcome_source = weakref(combat)
		combat.connect(&"outcome_published", _on_combat_outcome)
		_record("outcome_observer_bound", {"combat_instance_id": combat.get_instance_id(), "path": str(combat.get_path())})


func _disconnect_outcome_source() -> void:
	var combat: Node = _outcome_source.get_ref() if _outcome_source != null else null
	if is_instance_valid(combat) and combat.is_connected(&"outcome_published", _on_combat_outcome):
		combat.disconnect(&"outcome_published", _on_combat_outcome)
	_outcome_source = null


func _on_combat_outcome(outcome) -> void:
	var snapshot: Dictionary = outcome.snapshot()
	_record("combat_outcome", {"outcome": snapshot})


func _detach_outcome_observer() -> void:
	if process_frame.is_connected(_sync_outcome_source):
		process_frame.disconnect(_sync_outcome_source)
	_disconnect_outcome_source()


func _request_screen_keep_on() -> void:
	var available := DisplayServer.has_method("screen_is_kept_on") and DisplayServer.has_method("screen_set_keep_on")
	var screen_state: Dictionary = {"api_available": available, "requested": false}
	if available:
		_screen_keep_on_previous = bool(DisplayServer.call("screen_is_kept_on"))
		_screen_keep_on_captured = true
		DisplayServer.call("screen_set_keep_on", true)
		screen_state.merge({"previous": _screen_keep_on_previous, "requested": true, "reported_after_request": bool(DisplayServer.call("screen_is_kept_on"))}, true)
	_metadata["screen_keep_on"] = screen_state


func _restore_screen_keep_on() -> void:
	if not _screen_keep_on_captured:
		return
	DisplayServer.call("screen_set_keep_on", _screen_keep_on_previous)
	_screen_keep_on_captured = false
	var reported := bool(DisplayServer.call("screen_is_kept_on"))
	_metadata["screen_keep_on"]["restored_to"] = _screen_keep_on_previous
	_metadata["screen_keep_on"]["reported_after_restore"] = reported
	_record("screen_keep_on_restored", {"restored_to": _screen_keep_on_previous, "reported": reported})


func _tick() -> void:
	if not _running or _stopping:
		return
	var now := Time.get_ticks_msec()
	if now >= _next_poll_ms:
		_next_poll_ms = now + 100
		_poll_command()
	if _stopping:
		return
	_tick_audio_capture()
	if not _command.is_empty():
		var elapsed := Time.get_ticks_msec() - _accepted_ms
		while _schedule_index < _schedule.size() and int(_schedule[_schedule_index]["at_ms"]) <= elapsed:
			var scheduled: Dictionary = _schedule[_schedule_index]
			_send_control(scheduled, elapsed - int(scheduled["at_ms"]))
			_schedule_index += 1
		while _keyframe_index < _keyframes.size() and _keyframes[_keyframe_index] <= elapsed:
			_full_due.append(_keyframes[_keyframe_index])
			_keyframe_index += 1
		var periodic_due := _capture_until_ms > 0 and elapsed <= _capture_until_ms and elapsed >= _next_capture_ms
		if not _capture_pending and (periodic_due or not _full_due.is_empty()):
			var skipped := 0
			if periodic_due:
				skipped = maxi(0, int((elapsed - _next_capture_ms) / _capture_interval_ms))
				_next_capture_ms += (skipped + 1) * _capture_interval_ms
			var full_times: Array[int] = _full_due.duplicate()
			_full_due.clear()
			_capture(int(_command["id"]), elapsed, full_times, skipped)
		if elapsed >= _end_ms and _schedule_index >= _schedule.size() and _keyframe_index >= _keyframes.size() and _full_due.is_empty() and not _capture_pending and _audio_capture == null:
			_record("command_finished", {"id": _command["id"], "state": _snapshot(), "holds_persist": true})
			_command = {}
			_schedule.clear()
	if now >= _next_state_ms:
		_next_state_ms = now + 250
		_write_live_state()
	if now >= _next_observation_ms:
		_next_observation_ms = now + 500
		_record("observation", {"state": _snapshot()})


func _poll_command() -> void:
	var path := _out.path_join("command.json")
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	if file.get_length() > 1024 * 1024:
		file.close()
		return
	var text := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		if text != _last_invalid_text:
			_last_invalid_text = text
			_record("command_parse_pending", {"reason": "Incomplete or invalid JSON; waiting for a complete file."})
		return
	var raw: Dictionary = parser.data
	if not _integer(raw.get("id"), -9007199254740991.0, 9007199254740991.0):
		if text != _last_invalid_text:
			_last_invalid_text = text
			_record("command_rejected", {"error": "id must be an exactly representable integer"})
		return
	var id := int(raw["id"])
	if _seen_ids.has(id):
		return
	if raw.get("quit", false) is bool and bool(raw.get("quit", false)):
		_seen_ids[id] = true
		_record("quit_command", {"id": id})
		_stop()
		return
	if not _command.is_empty():
		if _pending_notice_id != id:
			_pending_notice_id = id
			_record("command_waiting", {"id": id, "active_id": _command["id"], "note": "Only the latest mailbox contents will be read when idle."})
		return
	_seen_ids[id] = true
	var parsed := _validate_command(raw)
	if parsed.has("error"):
		_record("command_rejected", {"id": id, "error": parsed["error"]})
		return
	_command = {"id": id}
	_schedule.assign(parsed["actions"])
	_schedule_index = 0
	_accepted_ms = Time.get_ticks_msec()
	_capture_until_ms = int(parsed["capture_ms"])
	_capture_interval_ms = int(parsed["interval_ms"])
	_capture_scale = float(parsed["scale"])
	_next_capture_ms = 0
	_keyframes.assign(parsed["keyframes"])
	_keyframe_index = 0
	_full_due.clear()
	_end_ms = int(parsed["end_ms"])
	_pending_notice_id = null
	_record("command_accepted", {"id": id, "requested": raw, "end_ms": _end_ms, "capture_ms": _capture_until_ms, "capture_every_ms": _capture_interval_ms, "capture_scale": _capture_scale})
	if float(parsed["audio_seconds"]) > 0.0:
		_start_audio_capture(id, float(parsed["audio_seconds"]))


func _validate_command(raw: Dictionary) -> Dictionary:
	if not raw.get("actions", []) is Array or raw.get("actions", []).size() > MAX_ACTIONS:
		return {"error": "actions must be an array of at most 2048 entries"}
	for option in ["capture_seconds", "capture_every_ms", "capture_scale", "capture_audio_seconds"]:
		if raw.has(option) and not _number(raw[option]):
			return {"error": option + " must be a finite number"}
	var capture_ms := int(clampf(float(raw.get("capture_seconds", 15.0)), 0.0, MAX_CAPTURE_SECONDS) * 1000.0)
	var interval_ms := int(clampf(float(raw.get("capture_every_ms", 125.0)), 50.0, 5000.0))
	var scale := clampf(float(raw.get("capture_scale", 0.5)), 0.1, 1.0)
	var audio_seconds := float(raw.get("capture_audio_seconds", 0.0))
	if audio_seconds < 0.0 or audio_seconds > MAX_AUDIO_SECONDS:
		return {"error": "capture_audio_seconds must be in 0..30"}
	var actions: Array[Dictionary] = []
	var end_ms := maxi(capture_ms, ceili(audio_seconds * 1000.0))
	for index in range(raw.get("actions", []).size()):
		var entry: Variant = raw["actions"][index]
		if not entry is Dictionary or not _integer(entry.get("at_ms"), 0.0, float(MAX_SCHEDULE_MS)) or not entry.get("pressed") is bool:
			return {"error": "Each action needs integer at_ms (0..120000) and Boolean pressed"}
		var name := str(entry.get("action", ""))
		var action := StringName(ALIASES.get(name, name))
		if action not in ACTIONS:
			return {"error": "Unsupported action: " + name}
		if entry.has("value") and (not _number(entry["value"]) or float(entry["value"]) < 0.0 or float(entry["value"]) > 1.0):
			return {"error": "value must be in 0..1"}
		var binding: InputEvent = _binding(action, entry.has("value"))
		if binding == null:
			return {"error": "No supported existing binding for " + str(action)}
		var strength := float(entry.get("value", 1.0)) if bool(entry["pressed"]) else 0.0
		actions.append({"at_ms": int(entry["at_ms"]), "ordinal": index, "action": action, "pressed": entry["pressed"], "value": strength, "binding": binding})
		end_ms = maxi(end_ms, int(entry["at_ms"]))
	actions.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["ordinal"]) < int(b["ordinal"]) if a["at_ms"] == b["at_ms"] else int(a["at_ms"]) < int(b["at_ms"]))
	if not raw.get("keyframes_ms", []) is Array or raw.get("keyframes_ms", []).size() > MAX_KEYFRAMES:
		return {"error": "keyframes_ms must contain at most 32 integer times"}
	var keyframes: Array[int] = []
	for time in raw.get("keyframes_ms", []):
		if not _integer(time, 0.0, float(MAX_SCHEDULE_MS)):
			return {"error": "Invalid full-resolution keyframe time"}
		keyframes.append(int(time))
		end_ms = maxi(end_ms, int(time))
	keyframes.sort()
	return {"actions": actions, "keyframes": keyframes, "capture_ms": capture_ms, "interval_ms": interval_ms, "scale": scale, "end_ms": end_ms, "audio_seconds": audio_seconds}


func _start_audio_capture(id: int, seconds: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	var rate := AudioServer.get_mix_rate()
	var driver := AudioServer.get_driver_name()
	if bus < 0 or driver == "Dummy" or AudioServer.get_speaker_mode() != AudioServer.SPEAKER_MODE_STEREO or not _integer(rate, 1.0, 67108863.0) or seconds * rate * 4.0 > 4294967259.0:
		_record("audio_capture_unsupported", {"id": id, "monotonic_us": Time.get_ticks_usec(), "driver": driver, "mix_rate": rate, "speaker_mode": AudioServer.get_speaker_mode(), "master_bus": bus})
		return
	if AudioServer.is_bus_bypassing_effects(bus):
		_record("audio_capture_unsupported", {"id": id, "monotonic_us": Time.get_ticks_usec(), "reason": "Master effects are bypassed; recorder will not change them"})
		return
	var directory := _out.path_join("audio").path_join(_session)
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK:
		_record("audio_capture_error", {"id": id, "monotonic_us": Time.get_ticks_usec(), "reason": "Cannot create audio directory", "error": error_string(error)})
		return
	var path := directory.path_join("cmd_%s.wav" % id)
	_audio_file = FileAccess.open(path, FileAccess.WRITE)
	if _audio_file == null:
		_record("audio_capture_error", {"id": id, "monotonic_us": Time.get_ticks_usec(), "path": path, "reason": "Cannot open WAV", "error": error_string(FileAccess.get_open_error())})
		return
	_audio_file.big_endian = false
	_audio = {"id": id, "path": path, "requested_seconds": seconds, "rate": int(rate), "frame_limit": maxi(1, floori(seconds * rate)), "frames_written": 0, "clipped_samples": 0, "invalid_samples": 0, "io_error": false, "capture_error": "", "discontinuous": false, "detached_us": 0, "last_drain_us": 0, "max_drain_us": 0, "drains": 0, "reason": "", "unwritten_frames": 0}
	_write_audio_header()
	if _audio_file.get_error() != OK:
		_record("audio_capture_error", {"id": id, "monotonic_us": Time.get_ticks_usec(), "path": path, "reason": "Cannot write WAV header", "error": error_string(_audio_file.get_error())})
		_audio_file.close()
		_audio_file = null
		_audio.clear()
		return
	_audio_capture = AudioEffectCapture.new()
	_audio_capture.buffer_length = 2.0 # Must be set before the effect is initialized.
	AudioServer.add_bus_effect(bus, _audio_capture, AudioServer.get_bus_effect_count(bus))
	var started_us := Time.get_ticks_usec()
	_audio["started_us"] = started_us
	_audio["deadline_us"] = started_us + maxi(1, roundi(seconds * 1000000.0))
	_record("audio_capture_started", {"id": id, "path": path, "monotonic_us": started_us, "requested_seconds": seconds, "mix_rate": rate, "channels": 2, "pcm_bits": 16, "driver": driver, "ring_seconds": 2.0, "drain_frames_per_tick": AUDIO_DRAIN_FRAMES, "frame_limit": _audio["frame_limit"], "master_volume_db": AudioServer.get_bus_volume_db(bus), "master_muted": AudioServer.is_bus_mute(bus), "output_latency_seconds": AudioServer.get_output_latency(), "timing_limit": "End-of-effects Master tap, not exact speaker-output or rendered-frame synchronization"})


func _audio_effect_index() -> int:
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0 and _audio_capture != null:
		for index in range(AudioServer.get_bus_effect_count(bus)):
			if AudioServer.get_bus_effect(bus, index) == _audio_capture:
				return index
	return -1


func _detach_audio_capture(reason: String) -> void:
	if _audio_capture == null or int(_audio["detached_us"]) != 0:
		return
	var index := _audio_effect_index()
	if index >= 0:
		AudioServer.remove_bus_effect(AudioServer.get_bus_index("Master"), index)
	else:
		_audio["discontinuous"] = true
	_audio["detached_us"] = Time.get_ticks_usec()
	_audio["reason"] = reason
	_record("audio_capture_detached", {"id": _audio["id"], "monotonic_us": _audio["detached_us"], "reason": reason, "owned_effect_found": index >= 0, "overrun_us": maxi(0, int(_audio["detached_us"]) - int(_audio["deadline_us"]))})


func _tick_audio_capture() -> void:
	if _audio_capture == null:
		return
	if int(_audio["detached_us"]) == 0:
		var rate := AudioServer.get_mix_rate()
		var index := _audio_effect_index()
		var bus := AudioServer.get_bus_index("Master")
		if rate != float(_audio["rate"]):
			_audio["discontinuous"] = true
			_record("audio_capture_mix_rate_changed", {"id": _audio["id"], "monotonic_us": Time.get_ticks_usec(), "old_rate": _audio["rate"], "new_rate": rate, "resampled": false})
			_detach_audio_capture("mix_rate_changed")
		elif index < 0 or bus < 0:
			_audio["discontinuous"] = true
			_detach_audio_capture("owned_effect_missing")
		elif AudioServer.is_bus_bypassing_effects(bus) or not AudioServer.is_bus_effect_enabled(bus, index):
			_audio["discontinuous"] = true
			_detach_audio_capture("capture_bypassed_or_disabled")
		elif AudioServer.get_driver_name() == "Dummy" or AudioServer.get_speaker_mode() != AudioServer.SPEAKER_MODE_STEREO:
			_audio["discontinuous"] = true
			_detach_audio_capture("audio_output_unsupported")
		elif Time.get_ticks_usec() >= int(_audio["deadline_us"]):
			_detach_audio_capture("deadline")
	_drain_audio_capture()
	if bool(_audio["io_error"]) or not str(_audio["capture_error"]).is_empty():
		_finish_audio_capture("capture_error", false)
	elif int(_audio["frames_written"]) >= int(_audio["frame_limit"]) or (int(_audio["detached_us"]) != 0 and _audio_capture.get_frames_available() == 0):
		_finish_audio_capture("sample_limit" if int(_audio["frames_written"]) >= int(_audio["frame_limit"]) else "drained", false)


func _drain_audio_capture() -> void:
	var started_us := Time.get_ticks_usec()
	var count := mini(AUDIO_DRAIN_FRAMES, mini(_audio_capture.get_frames_available(), int(_audio["frame_limit"]) - int(_audio["frames_written"])))
	if count <= 0 or bool(_audio["io_error"]) or not str(_audio["capture_error"]).is_empty():
		return
	var frames: PackedVector2Array = _audio_capture.get_buffer(count)
	if frames.size() != count:
		_audio["discontinuous"] = true
		_audio["capture_error"] = "buffer_read_failed"
		_record("audio_capture_error", {"id": _audio["id"], "monotonic_us": Time.get_ticks_usec(), "reason": "Unexpected capture buffer size", "requested_frames": count, "received_frames": frames.size()})
		return
	var bytes := PackedByteArray()
	bytes.resize(count * 4)
	for frame in range(count):
		for channel in range(2):
			var sample: float = frames[frame].x if channel == 0 else frames[frame].y
			if not is_finite(sample):
				_audio["invalid_samples"] += 1
				_audio["discontinuous"] = true
				sample = 0.0
			if absf(sample) > 1.0:
				_audio["clipped_samples"] += 1
			var pcm := roundi(clampf(sample, -1.0, 1.0) * 32767.0)
			var offset := frame * 4 + channel * 2
			# Explicit little-endian PCM bytes; one buffered file write per drain.
			bytes[offset] = pcm & 255
			bytes[offset + 1] = (pcm >> 8) & 255
	_audio_file.store_buffer(bytes)
	if _audio_file.get_error() != OK:
		_audio["io_error"] = true
		_audio["discontinuous"] = true
		_record("audio_capture_error", {"id": _audio["id"], "monotonic_us": Time.get_ticks_usec(), "reason": "PCM write failed", "error": error_string(_audio_file.get_error())})
	else:
		_audio["frames_written"] += count
	_audio["last_drain_us"] = Time.get_ticks_usec()
	_audio["max_drain_us"] = maxi(int(_audio["max_drain_us"]), int(_audio["last_drain_us"]) - started_us)
	_audio["drains"] += 1


func _write_audio_header() -> void:
	var data_size := int(_audio["frames_written"]) * 4
	_audio_file.seek(0)
	_audio_file.store_buffer("RIFF".to_ascii_buffer())
	_audio_file.store_32(36 + data_size)
	_audio_file.store_buffer("WAVEfmt ".to_ascii_buffer())
	_audio_file.store_32(16)
	_audio_file.store_16(1) # PCM, not IEEE float.
	_audio_file.store_16(2)
	_audio_file.store_32(int(_audio["rate"]))
	_audio_file.store_32(int(_audio["rate"]) * 4)
	_audio_file.store_16(4)
	_audio_file.store_16(16)
	_audio_file.store_buffer("data".to_ascii_buffer())
	_audio_file.store_32(data_size)


func _finish_audio_capture(reason: String, drain := true) -> void:
	if _audio_capture == null:
		return
	_detach_audio_capture(reason)
	if drain:
		_drain_audio_capture() # Shutdown is bounded too; never block to empty the ring.
	var remaining := _audio_capture.get_frames_available()
	var discarded := _audio_capture.get_discarded_frames()
	_audio["unwritten_frames"] = remaining
	if discarded > 0 or (remaining > 0 and int(_audio["frames_written"]) < int(_audio["frame_limit"])):
		_audio["discontinuous"] = true
	_write_audio_header()
	_audio_file.flush()
	var header_ok := _audio_file.get_error() == OK
	_audio_file.close()
	_audio_file = null
	var ended_us := Time.get_ticks_usec()
	var result: Dictionary = _audio.duplicate()
	result.merge({"monotonic_us": ended_us, "finalized_us": ended_us, "sample_duration_seconds": float(_audio["frames_written"]) / float(_audio["rate"]), "wall_duration_us": int(_audio["detached_us"]) - int(_audio["started_us"]), "overrun_us": maxi(0, int(_audio["detached_us"]) - int(_audio["deadline_us"])), "pushed_frames": _audio_capture.get_pushed_frames(), "discarded_frames": discarded, "uninterrupted": not bool(_audio["discontinuous"]), "duration_complete": int(_audio["frames_written"]) >= int(_audio["frame_limit"]), "wav_header_ok": header_ok, "valid_audio_evidence": header_ok and not bool(_audio["io_error"]) and not bool(_audio["discontinuous"]) and int(_audio["frames_written"]) > 0}, true)
	_record("audio_capture_finished", result)
	_audio_capture = null
	_audio.clear()


func _binding(action: StringName, analog: bool) -> InputEvent:
	if action == &"developer_overlay":
		# Existing gameplay readout toggle; this does not open the backtick Portal.
		var key := InputEventKey.new()
		key.keycode = KEY_F4
		key.physical_keycode = KEY_F4
		return key
	if not InputMap.has_action(action):
		return null
	var bindings := InputMap.action_get_events(action)
	if action == &"casting":
		for candidate in bindings:
			if candidate is InputEventJoypadMotion and candidate.axis == JOY_AXIS_TRIGGER_LEFT:
				return candidate.duplicate() as InputEvent
		return null
	if analog:
		for candidate in bindings:
			if candidate is InputEventJoypadMotion:
				return candidate.duplicate() as InputEvent
		return null
	for kind in ["key", "button", "mouse", "axis"]:
		for candidate in bindings:
			if (kind == "key" and candidate is InputEventKey) or (kind == "button" and candidate is InputEventJoypadButton) or (kind == "mouse" and candidate is InputEventMouseButton) or (kind == "axis" and candidate is InputEventJoypadMotion):
				return candidate.duplicate() as InputEvent
	return null


func _send_control(scheduled: Dictionary, late_ms := 0) -> void:
	var action: StringName = scheduled["action"]
	var pressed: bool = scheduled["pressed"]
	var value := float(scheduled["value"])
	var previous: Dictionary = _held.get(action, {})
	if not previous.is_empty() and bool(previous["pressed"]) == pressed and is_equal_approx(float(previous["value"]), value):
		_record("input_unchanged", {"action": action, "pressed": pressed, "value": value, "lateness_ms": late_ms})
		return
	var event: InputEvent = scheduled["binding"].duplicate() as InputEvent
	if event.device < 0:
		event.device = 0
	if event is InputEventJoypadMotion:
		event.axis_value = signf(event.axis_value) * value if pressed else 0.0
	elif event is InputEventJoypadButton:
		event.pressed = pressed
		event.pressure = value
	elif event is InputEventKey:
		event.pressed = pressed
		event.echo = false
	elif event is InputEventMouseButton:
		event.pressed = pressed
		event.position = root.get_mouse_position() if is_instance_valid(root) else Vector2.ZERO
		event.global_position = event.position
	_held[action] = {"pressed": pressed, "value": value, "binding": scheduled["binding"]}
	event.set_meta(INPUT_TAG, _session)
	_record("scheduled_input", {"action": action, "pressed": pressed, "value": value, "at_ms": scheduled.get("at_ms", -1), "lateness_ms": late_ms, "event": event.as_text()})
	Input.parse_input_event(event)


func _observe_input(event: InputEvent) -> void:
	if _log == null or event.is_echo():
		return
	var controlled := str(event.get_meta(INPUT_TAG, "")) == _session
	var matches: Array[String] = []
	for action in ACTIONS:
		if action != &"developer_overlay" and InputMap.has_action(action) and event.is_action(action):
			matches.append(str(action))
	if event is InputEventKey and (event.keycode == KEY_F4 or event.physical_keycode == KEY_F4):
		matches.append("developer_overlay")
	if matches.is_empty():
		return
	if event is InputEventJoypadMotion and not controlled:
		var axis_key := "%s:%s" % [event.device, event.axis]
		var prior: Dictionary = _axis_observations.get(axis_key, {})
		if not prior.is_empty() and Time.get_ticks_msec() - int(prior["ms"]) < 100 and absf(event.axis_value - float(prior["value"])) < 0.02:
			return
		_axis_observations[axis_key] = {"ms": Time.get_ticks_msec(), "value": event.axis_value}
	if not controlled:
		_unexpected_count += 1
	var record := {"source": "driver" if controlled else "unexpected_external", "actions": matches, "event": event.as_text(), "device": event.device}
	if event is InputEventJoypadMotion:
		record["axis_value"] = event.axis_value
	else:
		record["pressed"] = event.is_pressed()
	_record("input_observed", record)


func _capture(id: int, scheduled_ms: int, full_times: Array[int], skipped: int) -> void:
	_capture_pending = true
	var capture_started_us := Time.get_ticks_usec()
	await RenderingServer.frame_post_draw
	if _stopping:
		_capture_pending = false
		return
	var readback_started_us := Time.get_ticks_usec()
	var pixels: Image = root.get_texture().get_image()
	var readback_finished_us := Time.get_ticks_usec()
	var timings: Dictionary = {
		"frame_wait_us": readback_started_us - capture_started_us,
		"get_image_us": readback_finished_us - readback_started_us,
		"full_png_save_us": null, "review_duplicate_us": null,
		"review_resize_us": null, "review_prepare_us": null, "review_png_save_us": null,
	}
	# Stamp/state belong to the rendered readback, never the later encoder frame.
	_capture_context = {
		"id": id, "scheduled_ms": scheduled_ms, "keyframes_ms": full_times,
		"skipped_periods": skipped, "capture_stamp": _stamp(), "state": _snapshot(),
		"request_started_us": capture_started_us, "readback_started_us": readback_started_us,
		"readback_finished_us": readback_finished_us, "timings_us": timings,
	}
	var directory := _out.path_join("captures").path_join(_session)
	var paths: Dictionary = {}
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error == OK and pixels != null and not pixels.is_empty():
		_capture_serial += 1
		var stem := directory.path_join("cmd_%s_frame_%06d" % [id, _capture_serial])
		_capture_worker = Thread.new()
		_capture_encoder = ImageEncoder.new()
		var start_error := _capture_worker.start(_capture_encoder.encode.bind(pixels, stem, not full_times.is_empty(), _capture_scale))
		timings["main_thread_capture_us"] = Time.get_ticks_usec() - readback_started_us
		if start_error == OK:
			# Only the worker may touch pixels/review after this ownership handoff.
			return
		_capture_worker = null
		_capture_encoder = null
		paths["error"] = "Cannot start capture encoder: " + error_string(start_error)
	else:
		paths["error"] = "Output directory error %s or empty rendered image" % error
	timings["main_thread_capture_us"] = Time.get_ticks_usec() - readback_started_us
	_complete_capture({"paths": paths, "encode_finished_us": Time.get_ticks_usec()})


func _collect_capture_worker(wait := false) -> void:
	if _capture_worker == null or (not wait and _capture_worker.is_alive()):
		return
	# Joining is the ownership/memory barrier; no worker data is read before it.
	var result: Variant = _capture_worker.wait_to_finish()
	_capture_worker = null
	_capture_encoder = null
	if not result is Dictionary:
		result = {"paths": {"error": "Capture encoder returned no result"}, "encode_finished_us": Time.get_ticks_usec()}
	_complete_capture(result)


func _complete_capture(result: Dictionary) -> void:
	var context: Dictionary = _capture_context
	var costs: Dictionary = context["timings_us"]
	costs.merge(result.get("timings_us", {}), true)
	var finished_us := int(result["encode_finished_us"])
	costs["capture_total_us"] = finished_us - int(context["request_started_us"])
	costs["capture_work_us"] = finished_us - int(context["readback_started_us"])
	costs["completion_collection_us"] = Time.get_ticks_usec() - finished_us
	_record("capture", {
		"id": context["id"], "scheduled_ms": context["scheduled_ms"],
		"keyframes_ms": context["keyframes_ms"], "skipped_periods": context["skipped_periods"],
		"paths": result["paths"], "state": context["state"], "capture_stamp": context["capture_stamp"],
		"readback_finished_us": context["readback_finished_us"],
		"encode_started_us": result.get("encode_started_us"), "encode_finished_us": finished_us,
		"collection_stamp": _stamp(), "timings_us": costs,
	}, context["capture_stamp"])
	_capture_context = {}
	_capture_pending = false


func _snapshot() -> Dictionary:
	var state := {"paused": paused, "unexpected_input_count": _unexpected_count, "viewport_size": [root.size.x, root.size.y]}
	var scene: Node = current_scene
	if not is_instance_valid(scene):
		state["scene"] = "loading"
		return state
	state["scene"] = scene.scene_file_path
	state["scene_instance_id"] = scene.get_instance_id()
	var player := scene.get_node_or_null("Player")
	if player != null:
		state["player"] = _actor_snapshot(player)
		var heat := player.get_node_or_null("Combat/Heat")
		var magic := player.get_node_or_null("Combat/Magic")
		var might := player.get_node_or_null("Combat/Might")
		if heat != null:
			state["heat"] = heat.get("_value")
		if magic != null:
			var orbs: Array = magic.call("get_snapshot")
			state["orb_count"] = orbs.size()
			state["charged_count"] = magic.call("get_marked_count")
			state["charging_progress"] = magic.call("get_marking_progress")
		if might != null:
			var action: Dictionary = might.get("_current_action")
			state["action"] = {"kind": str(action.get("kind", "")), "school": str(action.get("school", "")), "move": str(action.get("move_id", "")), "source_action_id": action.get("source_action_id", 0), "state": might.get("_state")}
	var area: Variant = scene.get("_current_area")
	if is_instance_valid(area) and area is Node:
		var enemy: Node = area.get_node_or_null("FinalEnemy")
		if enemy == null and area.has_method("get_targets"):
			var targets: Array = area.call("get_targets")
			if not targets.is_empty():
				enemy = targets[0] as Node
		if is_instance_valid(enemy):
			state["enemy"] = _actor_snapshot(enemy, "BodyVisual")
			if enemy.has_method("_state_name"):
				state["enemy"]["phase"] = str(enemy.call("_state_name"))
	return state


func _actor_snapshot(actor: Node, sprite_path := "Sprite") -> Dictionary:
	var state: Dictionary = {"instance_id": actor.get_instance_id()}
	if actor is Node2D:
		state["position"] = [actor.global_position.x, actor.global_position.y]
	var health := actor.get_node_or_null("Health")
	if health != null:
		state["hp"] = health.call("get_current")
	var sprite := actor.get_node_or_null(sprite_path) as Sprite2D
	if sprite != null:
		state["sprite"] = {"texture": sprite.texture.resource_path if sprite.texture != null else "", "region": [sprite.region_rect.position.x, sprite.region_rect.position.y, sprite.region_rect.size.x, sprite.region_rect.size.y], "flip_h": sprite.flip_h}
	var animation := actor.get_node_or_null("AnimationPlayer") as AnimationPlayer
	if animation != null:
		var name: StringName = animation.assigned_animation
		var clock: Animation = animation.get_animation(name) if animation.has_animation(name) else null
		var phase: Dictionary = {"animation": str(name), "playing": animation.is_playing(), "seconds": animation.current_animation_position if animation.current_animation != &"" else 0.0, "length": clock.length if clock != null else 0.0, "speed_scale": animation.speed_scale}
		if clock != null:
			for marker in [&"active_start", &"active_end", &"launch"]:
				if clock.has_marker(marker):
					phase[str(marker)] = clock.get_marker_time(marker)
		state["clock"] = phase
	return state


func _stamp() -> Dictionary:
	return {"session": _session, "frame": Engine.get_process_frames(), "physics_frame": Engine.get_physics_frames(), "elapsed_ms": Time.get_ticks_msec() - _started_ms, "command_id": _command.get("id"), "command_elapsed_ms": Time.get_ticks_msec() - _accepted_ms if not _command.is_empty() else null}


func _record(kind: String, data: Dictionary, capture_stamp: Dictionary = {}) -> void:
	if _log == null:
		return
	var record := _stamp() if capture_stamp.is_empty() else capture_stamp.duplicate(true)
	record["kind"] = kind
	record.merge(data)
	_log.store_line(JSON.stringify(record))
	_log.flush()


func _write_live_state() -> void:
	var state := _stamp()
	var controls: Dictionary = {}
	for action in _held.keys():
		var held: Dictionary = _held[action]
		if bool(held["pressed"]) or float(held["value"]) > 0.0:
			controls[str(action)] = {"pressed": held["pressed"], "value": held["value"]}
	state.merge({"status": "stopped" if _stopping else ("busy" if not _command.is_empty() else "ready"), "metadata": _metadata, "state": _snapshot(), "controlled_holds": controls, "next_action_index": _schedule_index})
	var file := FileAccess.open(_out.path_join("state.json"), FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(state))
		file.close()


func _release_inputs() -> void:
	for action in _held.keys():
		var held: Dictionary = _held[action]
		if bool(held["pressed"]) or float(held["value"]) > 0.0:
			_send_control({"action": action, "pressed": false, "value": 0.0, "binding": held["binding"]})


func _stop(code := 0) -> void:
	if _stopping:
		return
	_stopping = true
	_running = false
	_finish_audio_capture("quit")
	_release_inputs()
	_detach_outcome_observer()
	if process_frame.is_connected(_collect_capture_worker):
		process_frame.disconnect(_collect_capture_worker)
	_collect_capture_worker(true)
	_restore_screen_keep_on()
	_record("session_stopped", {"exit_code": code, "state": _snapshot()})
	_write_live_state()
	if _log != null:
		_log.close()
		_log = null
	quit(code)


func _finalize() -> void:
	_finish_audio_capture("finalize")
	if not _stopping and _log != null:
		_release_inputs()
	_detach_outcome_observer()
	if process_frame.is_connected(_collect_capture_worker):
		process_frame.disconnect(_collect_capture_worker)
	_collect_capture_worker(true)
	_restore_screen_keep_on()
	if not _stopping and _log != null:
		_record("session_finalized", {})
		_log.close()
		_log = null


func _number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value))


func _integer(value: Variant, minimum: float, maximum: float) -> bool:
	return _number(value) and float(value) >= minimum and float(value) <= maximum and float(value) == floor(float(value))
