@tool
class_name CombatTuningBridge
extends Node

signal inspector_tuning_applied

const CONFIG_PATH := "res://config/prototype_combat.json"
const TUNING_PATH := "res://config/combat_tuning.tres"
const ConfigLoader = preload("res://scripts/config/prototype_config_loader.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")

## Standalone encounters can opt out of the shared character-Settings save path.
@export var persistence_enabled := true

@export var settings: CombatTuningSettings:
	set(value):
		settings = value
		if is_inside_tree():
			_reconnect_resources()
			_on_settings_changed()

var _config: Dictionary = {}
var _editor_config: Dictionary = {}
var _apply_tuning: Callable
var _last_valid: Dictionary = {}
var _connected: Array[Resource] = []
var _syncing := false
var _editor_pending := false
var _json_hash := ""
var _watch_elapsed := 0.0


func _ready() -> void:
	_reconnect_resources()
	if settings != null:
		_last_valid = settings.get_data().duplicate(true)
	_json_hash = Store.source_hash()
	if Engine.is_editor_hint():
		var loaded := ConfigLoader.load_and_validate(CONFIG_PATH)
		if loaded["ok"]:
			_editor_config = loaded["data"].duplicate(true)
			sync_from_config(_editor_config)
	set_process(Engine.is_editor_hint())


func initialize(config: Dictionary, apply_tuning: Callable) -> Dictionary:
	_config = config
	_apply_tuning = apply_tuning
	if settings == null:
		return {"ok": false, "error": "CombatTuning requires its shared Settings resource."}
	# Character Settings are authoritative; this legacy Resource is an Inspector view.
	sync_from_config(_config)
	return ConfigLoader.validate(_config)


func sync_from_config(config: Dictionary) -> void:
	if _syncing or settings == null:
		return
	_syncing = true
	settings.read_from_config(config)
	_reconnect_resources()
	_last_valid = settings.get_data().duplicate(true)
	_syncing = false


func save_resource() -> Dictionary:
	if not persistence_enabled:
		return {"ok": false, "error": "This encounter uses run-only tuning."}
	if settings == null:
		return {"ok": false, "error": "Combat tuning resource is missing."}
	var path := settings.resource_path
	if path.is_empty() or path.contains("::"):
		path = TUNING_PATH
	return settings.save_resources(path)


func _reconnect_resources() -> void:
	for resource in _connected:
		if is_instance_valid(resource) and resource.changed.is_connected(_on_settings_changed):
			resource.changed.disconnect(_on_settings_changed)
	_connected.clear()
	if settings == null:
		return
	for resource in settings.get_nested_resources():
		if not _connected.has(resource):
			resource.changed.connect(_on_settings_changed)
			_connected.append(resource)


func _on_settings_changed() -> void:
	if _syncing or settings == null:
		return
	if Engine.is_editor_hint():
		if not _editor_pending:
			_editor_pending = true
			call_deferred("_apply_editor_change")
	elif not _config.is_empty() and _apply_tuning.is_valid():
		_apply_runtime_inspector_change()


func _apply_runtime_inspector_change() -> void:
	if settings.get_data() == _last_valid:
		return
	_syncing = true
	var result := settings.apply_to_config(_config)
	if bool(result["ok"]):
		result = _apply_tuning.call()
	if bool(result["ok"]):
		_last_valid = settings.get_data().duplicate(true)
		_reconnect_resources()
	else:
		_restore_last_valid()
		push_warning(str(result["error"]))
	_syncing = false
	inspector_tuning_applied.emit()


func _apply_editor_change() -> void:
	_editor_pending = false
	if settings == null or settings.get_data() == _last_valid:
		return
	if not persistence_enabled:
		_syncing = true
		_restore_last_valid()
		_syncing = false
		push_warning("This encounter uses run-only combat tuning. Edit its root Inspector settings instead.")
		return
	if _editor_config.is_empty():
		push_warning("Reload valid character Settings before editing Inspector tuning.")
		return
	var candidate := _editor_config.duplicate(true)
	var result := settings.apply_to_config(candidate)
	if result["ok"]:
		result = Store.save_changes(_editor_config, candidate)
	if not result["ok"]:
		_syncing = true
		_restore_last_valid()
		_syncing = false
		push_warning(str(result["error"]))
		return
	_editor_config = result["data"].duplicate(true)
	_json_hash = Store.source_hash()
	sync_from_config(_editor_config)
	result = save_resource()
	if not result["ok"]:
		push_warning("Settings saved; Inspector mirror save failed: %s" % result["error"])


func _restore_last_valid() -> void:
	if _last_valid.is_empty():
		return
	if not _config.is_empty():
		CombatTuningSettings.apply_data_to_config(_last_valid, _config)
	settings.read_data(_last_valid)
	_reconnect_resources()


func _process(delta: float) -> void:
	# Keep an open scene's Inspector current after Portal saves or text edits.
	_watch_elapsed += delta
	if _watch_elapsed < 1.0 or _editor_pending or _syncing:
		return
	_watch_elapsed = 0.0
	var hash := Store.source_hash()
	if hash == _json_hash:
		return
	var result := ConfigLoader.load_and_validate(CONFIG_PATH)
	if not bool(result["ok"]):
		return
	_json_hash = hash
	_editor_config = result["data"].duplicate(true)
	sync_from_config(_editor_config)
