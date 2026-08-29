extends CanvasLayer

const TOGGLE_KEY := KEY_QUOTELEFT
const GENERAL_SECTION_ORDER := [
	"movement",
	"player",
	"enemy",
	"ui",
]
const COMBAT_SECTION_ORDER := [
	"combat",
	"casting",
	"heat",
	"fire",
	"water",
	"air",
	"earth",
	"defence",
	"hit_reaction",
]
const AUDIO_GROUP_ORDER := ["ambient", "sfx", "bgm"]
const HIDDEN_PORTAL_FIELDS := {
	"movement.gravity_scale": true,
}
const INTEGER_FIELDS := {
	"enemy.defensive_level": true,
	"combat.direct_impact": true,
	"casting.max_marked_capacity": true,
	"defence.water_block_defensive_level": true,
}
const FIELD_RANGES := {
	"movement.speed": Vector3(1.0, 600.0, 1.0),
	"movement.gravity_scale": Vector3(0.05, 5.0, 0.05),
	"audio.ambient.volume_db": Vector3(-80.0, 24.0, 0.5),
	"audio.sfx.volume_db": Vector3(-80.0, 24.0, 0.5),
	"audio.bgm.volume_db": Vector3(-80.0, 24.0, 0.5),
	"player.max_health": Vector3(1.0, 10000.0, 1.0),
	"enemy.max_health": Vector3(1.0, 10000.0, 1.0),
	"enemy.defensive_level": Vector3(0.0, 100.0, 1.0),
	"combat.attack_duration": Vector3(0.05, 5.0, 0.01),
	"combat.hit_phase": Vector3(0.0, 1.0, 0.01),
	"combat.input_window_start": Vector3(0.0, 1.0, 0.01),
	"combat.shape_radius": Vector3(1.0, 200.0, 1.0),
	"combat.shape_reach": Vector3(1.0, 400.0, 1.0),
	"combat.light_damage": Vector3(0.0, 1000.0, 1.0),
	"combat.casting_damage": Vector3(0.0, 1000.0, 1.0),
	"combat.direct_impact": Vector3(0.0, 5.0, 1.0),
	"casting.orb_lifetime": Vector3(0.1, 30.0, 0.1),
	"casting.charge_step_duration": Vector3(0.05, 5.0, 0.01),
	"casting.max_marked_capacity": Vector3(5.0, 5.0, 1.0),
	"casting.trigger_release_max": Vector3(0.0, 1.0, 0.01),
	"casting.trigger_charge_min": Vector3(0.0, 1.0, 0.01),
	"casting.empowered_primary_multiplier": Vector3(0.1, 5.0, 0.05),
	"casting.projectile_screen_ratio": Vector3(0.05, 1.0, 0.05),
	"casting.projectile_travel_duration": Vector3(0.1, 5.0, 0.05),
	"heat.max_attack_speed_percent": Vector3(100.0, 150.0, 1.0),
	"heat.attack_speed_gain_per_orb": Vector3(0.0, 10.0, 0.1),
	"heat.attack_speed_loss_per_hit": Vector3(0.0, 50.0, 0.1),
	"heat.heat_reset_timer": Vector3(0.1, 60.0, 0.1),
	"fire.dot_duration": Vector3(0.01, 60.0, 0.01),
	"fire.dot_tick_interval": Vector3(0.01, 30.0, 0.01),
	"fire.damage_per_stack": Vector3(0.0, 100.0, 0.1),
	"fire.visual_motion_exponent": Vector3(0.1, 5.0, 0.05),
	"fire.vfx_fps": Vector3(0.1, 120.0, 0.1),
	"water.base_radius": Vector3(1.0, 400.0, 1.0),
	"water.radius_per_level": Vector3(0.0, 200.0, 1.0),
	"water.visual_motion_exponent": Vector3(0.1, 5.0, 0.05),
	"water.vfx_fps": Vector3(0.1, 120.0, 0.1),
	"defence.guard_capacity": Vector3(1.0, 1000.0, 1.0),
	"defence.blocked_damage_to_guard": Vector3(0.0, 10.0, 0.1),
	"defence.guard_warning_ratio": Vector3(0.0, 1.0, 0.01),
	"defence.parry_window": Vector3(0.01, 2.0, 0.01),
	"defence.guard_break_recovery": Vector3(0.0, 5.0, 0.01),
	"defence.heat_drain_per_second": Vector3(0.0, 100.0, 0.1),
	"defence.water_block_defensive_level": Vector3(0.0, 100.0, 1.0),
	"hit_reaction.base_distance": Vector3(0.0, 100.0, 0.1),
	"hit_reaction.distance_per_level": Vector3(0.0, 100.0, 0.1),
	"hit_reaction.base_duration": Vector3(0.01, 10.0, 0.01),
	"hit_reaction.duration_per_level": Vector3(0.0, 10.0, 0.01),
	"ui.completed_combo_display_duration": Vector3(0.0, 20.0, 0.1),
}
const HEAT_LEVEL_RANGES := {
	"fill_ratio": Vector3(0.0, 1.0, 0.01),
	"speed_multiplier": Vector3(0.1, 5.0, 0.05),
}
const WATER_LEVEL_RANGES := {
	"duration": Vector3(0.01, 60.0, 0.01),
	"slow_percent": Vector3(0.0, 1.0, 0.01),
}
const TUNABLE_TOOLTIPS := {
	"movement.speed": "Horizontal movement speed.",
	"movement.gravity_scale": "Gravity multiplier for airborne movement.",
	"player.max_health": "Player maximum Health.",
	"enemy.max_health": "Maximum Health for each training target.",
	"enemy.defensive_level": "Impact level that reduces incoming hit reactions.",
	"combat.attack_duration": "Base duration of X and Casting animations.",
	"combat.casting_damage": "Base direct damage for school Casting effects.",
	"combat.direct_impact": "Impact level applied by direct X and Casting damage.",
	"combat.hit_phase": "Normalized animation phase when X contact or a projectile launch occurs.",
	"combat.input_window_start": "Normalized phase when the normal X/Cast chaining window opens.",
	"combat.x_buffer_width": "Normalized pre-window buffer width for X and full-press Cast requests.",
	"combat.collect_orb_without_contact": "Testing toggle: grant one orb on a missed X without applying damage.",
	"combat.light_damage": "Direct damage applied by a successful X hit.",
	"combat.shape_radius": "Radius of the X contact query.",
	"combat.shape_reach": "Forward reach of the X contact query.",
	"casting.charge_step_duration": "Seconds required to add one marking-capacity step before Heat scaling.",
	"casting.empowered_primary_multiplier": "Damage multiplier for the primary school of an empowered Cast.",
	"casting.max_marked_capacity": "Maximum number of orbs that can be marked for one Cast.",
	"casting.orb_lifetime": "Lifetime of the oldest orb before FIFO expiration.",
	"casting.projectile_screen_ratio": "Maximum projectile travel distance as a fraction of visible width.",
	"casting.projectile_travel_duration": "Seconds for a projectile to travel its maximum distance.",
	"casting.trigger_charge_min": "Minimum R2 pressure that charges and marks orbs.",
	"casting.trigger_release_max": "Maximum R2 pressure that triggers Casting on release.",
	"heat.max_attack_speed_percent": "Maximum attack speed percentage.",
	"heat.attack_speed_gain_per_orb": "Attack-speed points gained per committed orb.",
	"heat.attack_speed_loss_per_hit": "Attack-speed points lost when the Player is hit.",
	"heat.heat_reset_timer": "Seconds after a commitment before Heat resets.",
	"fire.damage_per_stack": "Damage dealt by each Fire DoT stack per tick.",
	"fire.dot_duration": "Lifetime of each Fire DoT stack.",
	"fire.dot_tick_interval": "Seconds between Fire DoT ticks.",
	"fire.visual_motion_exponent": "Exponent shaping Fire attack visual motion.",
	"fire.vfx_fps": "Playback speed of Fire status VFX.",
	"water.base_radius": "Base radius of Water area effects.",
	"water.radius_per_level": "Additional Water area radius per level.",
	"water.visual_motion_exponent": "Exponent shaping Water attack visual motion.",
	"water.vfx_fps": "Playback speed of Water status VFX.",
	"air.attack_speed_multiplier": "Attack-speed multiplier granted by Air level 1.",
	"air.buff_duration": "Duration of the Air attack-speed buff.",
	"air.chain_radius": "Radius used to find additional Air chain-lightning targets.",
	"air.damage_per_level": "Additional Air direct-damage multiplier per level.",
	"air.max_chain_targets": "Maximum number of targets in an Air chain-lightning result.",
	"air.visual_motion_exponent": "Exponent shaping Air attack visual motion.",
	"earth.base_radius": "Starting radius of Earth area effects.",
	"earth.radius_per_level": "Additional Earth area radius per level.",
	"earth.visual_motion_exponent": "Exponent shaping Earth attack visual motion.",
	"defence.guard_capacity": "Maximum Water guard capacity.",
	"defence.blocked_damage_to_guard": "Guard damage multiplier applied to blocked incoming damage.",
	"defence.guard_warning_ratio": "Guard ratio at or below which the warning state activates.",
	"defence.parry_window": "Duration of the Fire parry window.",
	"defence.guard_break_recovery": "Seconds of recovery after guard break.",
	"defence.heat_drain_per_second": "Heat drained per second while Water blocking.",
	"defence.water_block_defensive_level": "Defensive Impact level supplied by Water blocking.",
	"hit_reaction.base_distance": "Base displacement of a level-1 hit reaction.",
	"hit_reaction.distance_per_level": "Additional hit-reaction displacement per level.",
	"hit_reaction.base_duration": "Base duration of a level-1 hit reaction.",
	"hit_reaction.duration_per_level": "Additional hit-reaction duration per level.",
	"ui.completed_combo_display_duration": "Seconds completed chains remain in the readout.",
	"ui.developer_overlay_visible": "Show or hide the DeveloperReadout regions; gameplay UI remains visible.",
	"heat.levels.fill_ratio": "Heat threshold for this level as a fraction of maximum Heat.",
	"heat.levels.speed_multiplier": "Attack, Casting, and marking speed multiplier at this Heat level.",
	"water.levels.duration": "Duration of this Water status level.",
	"water.levels.slow_percent": "Movement slow percentage for this Water status level.",
	"audio.ambient.enabled": "Enable or mute the Ambient audio bus.",
	"audio.ambient.volume_db": "Volume of the Ambient audio bus in decibels.",
	"audio.sfx.enabled": "Enable or mute the SFX audio bus.",
	"audio.sfx.volume_db": "Volume of the SFX audio bus in decibels.",
	"audio.bgm.enabled": "Enable or mute the BGM audio bus.",
	"audio.bgm.volume_db": "Volume of the BGM audio bus in decibels.",
}

var _config: Dictionary = {}
var _apply_tuning: Callable
var _save_tuning: Callable
var _get_hitbox_enabled: Callable
var _set_hitbox_enabled: Callable
var _overlay_root: Control
var _field_container: VBoxContainer
var _general_fields: VBoxContainer
var _combat_fields: Dictionary = {}
var _audio_fields: VBoxContainer
var _status_label: Label
var _hitbox_check: CheckBox
var _pause_button: Button
var _was_tree_paused := false


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_overlay_root.visible = false
	_rebuild_fields()


func configure(
	config: Dictionary,
	apply_tuning: Callable,
	save_tuning: Callable,
	get_hitbox_enabled: Callable,
	set_hitbox_enabled: Callable
) -> void:
	_config = config
	_apply_tuning = apply_tuning
	_save_tuning = save_tuning
	_get_hitbox_enabled = get_hitbox_enabled
	_set_hitbox_enabled = set_hitbox_enabled
	if _general_fields != null:
		_rebuild_fields()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if (
		key_event.pressed
		and not key_event.echo
		and (key_event.keycode == TOGGLE_KEY or key_event.physical_keycode == TOGGLE_KEY)
	):
		_set_open(not _overlay_root.visible)
		get_viewport().set_input_as_handled()


func _exit_tree() -> void:
	if _overlay_root != null and _overlay_root.visible and get_tree() != null:
		get_tree().paused = _was_tree_paused


func _build_ui() -> void:
	_overlay_root = Control.new()
	_overlay_root.name = "DeveloperOverlayRoot"
	_overlay_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay_root)

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.025, 0.04, 0.9)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay_root.add_child(dim)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.08
	panel.anchor_top = 0.06
	panel.anchor_right = 0.92
	panel.anchor_bottom = 0.94
	_overlay_root.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 8)
	margin.add_child(body)

	var header := HBoxContainer.new()
	body.add_child(header)
	var title := Label.new()
	title.text = "DEVELOPER TUNING  ·  ` TOGGLE"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	header.add_child(title)
	_status_label = Label.new()
	_status_label.text = "RUN-ONLY"
	header.add_child(_status_label)
	_pause_button = Button.new()
	_pause_button.name = "PauseButton"
	_pause_button.pressed.connect(_toggle_game_paused)
	header.add_child(_pause_button)
	var save_button := Button.new()
	save_button.text = "Save to JSON"
	save_button.pressed.connect(_on_save_pressed)
	header.add_child(save_button)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_set_open.bind(false))
	header.add_child(close_button)
	_update_pause_button()

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_child(tabs)

	var general_tab := VBoxContainer.new()
	general_tab.name = "General"
	tabs.add_child(general_tab)
	_general_fields = _add_tab_scroll(general_tab)

	var audio_tab := VBoxContainer.new()
	audio_tab.name = "Audio"
	tabs.add_child(audio_tab)
	_audio_fields = _add_tab_scroll(audio_tab)

	var combat_tab := VBoxContainer.new()
	combat_tab.name = "Combat"
	tabs.add_child(combat_tab)
	var combat_tabs := TabContainer.new()
	combat_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	combat_tab.add_child(combat_tabs)
	_combat_fields.clear()
	for section_name in COMBAT_SECTION_ORDER:
		var category_tab := VBoxContainer.new()
		category_tab.name = str(section_name).to_upper().replace("_", " ")
		combat_tabs.add_child(category_tab)
		if section_name == "combat":
			_hitbox_check = CheckBox.new()
			_hitbox_check.text = "Show attack hitbox"
			_hitbox_check.toggled.connect(_on_hitbox_toggled)
			category_tab.add_child(_hitbox_check)
		_combat_fields[section_name] = _add_tab_scroll(category_tab)


func _rebuild_fields() -> void:
	if _general_fields == null or _combat_fields.is_empty() or _audio_fields == null:
		return
	if _config.is_empty():
		return
	if _get_hitbox_enabled.is_valid():
		_hitbox_check.set_pressed_no_signal(bool(_get_hitbox_enabled.call()))
	_rebuild_section_group(_general_fields, GENERAL_SECTION_ORDER)
	for section_name in COMBAT_SECTION_ORDER:
		var fields: VBoxContainer = _combat_fields[section_name]
		_rebuild_section_group(fields, [section_name])
	_rebuild_audio_group()


func _add_tab_scroll(tab: VBoxContainer) -> VBoxContainer:
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab.add_child(scroll)
	var fields := VBoxContainer.new()
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fields.add_theme_constant_override("separation", 10)
	scroll.add_child(fields)
	return fields


func _rebuild_section_group(container: VBoxContainer, section_order: Array) -> void:
	_clear_field_container(container)
	_field_container = container
	for section_name in section_order:
		if _config.has(section_name):
			_add_section(section_name, _config[section_name])


func _rebuild_audio_group() -> void:
	_clear_field_container(_audio_fields)
	_field_container = _audio_fields
	var audio: Dictionary = _config["audio"]
	for group_name in AUDIO_GROUP_ORDER:
		_add_audio_group(group_name, audio[group_name])


func _clear_field_container(container: VBoxContainer) -> void:
	for child in container.get_children():
		child.queue_free()


func _add_section(section_name: String, section: Dictionary) -> void:
	var title := Label.new()
	title.text = section_name.to_upper().replace("_", " ")
	title.add_theme_font_size_override("font_size", 16)
	_field_container.add_child(title)

	var fields := GridContainer.new()
	fields.columns = 2
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_field_container.add_child(fields)
	var keys: Array[String] = []
	for key in section:
		if key == "levels":
			continue
		keys.append(str(key))
	keys.sort()
	for key in keys:
		if HIDDEN_PORTAL_FIELDS.has("%s.%s" % [section_name, key]):
			continue
		var label := Label.new()
		label.text = key.replace("_", " ")
		var path := "%s.%s" % [section_name, key]
		_set_tuning_tooltip(label, path)
		fields.add_child(label)
		if typeof(section[key]) == TYPE_BOOL:
			var toggle := CheckButton.new()
			toggle.custom_minimum_size = Vector2(48.0, 24.0)
			var enabled := bool(section[key])
			toggle.set_pressed_no_signal(enabled)
			toggle.text = "ON" if enabled else "OFF"
			_set_tuning_tooltip(toggle, path)
			toggle.toggled.connect(_on_boolean_changed.bind(section_name, key, toggle))
			fields.add_child(toggle)
			continue
		var spin := _create_spinbox(path, float(section[key]))
		spin.value_changed.connect(_on_scalar_changed.bind(section_name, key))
		fields.add_child(spin)

	if section_name == "heat" and section.has("levels"):
		_add_heat_levels(section["levels"])
	elif section_name == "water" and section.has("levels"):
		_add_water_levels(section["levels"])


func _add_audio_group(group_name: String, group: Dictionary) -> void:
	var title := Label.new()
	title.text = group_name.to_upper()
	title.add_theme_font_size_override("font_size", 16)
	_field_container.add_child(title)
	var fields := GridContainer.new()
	fields.columns = 2
	fields.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_field_container.add_child(fields)
	for key in ["enabled", "volume_db"]:
		var label := Label.new()
		label.text = key.replace("_", " ")
		var path := "audio.%s.%s" % [group_name, key]
		_set_tuning_tooltip(label, path)
		fields.add_child(label)
		if key == "enabled":
			var toggle := CheckButton.new()
			toggle.custom_minimum_size = Vector2(48.0, 24.0)
			var enabled := bool(group[key])
			toggle.set_pressed_no_signal(enabled)
			toggle.text = "ON" if enabled else "OFF"
			_set_tuning_tooltip(toggle, path)
			toggle.toggled.connect(_on_audio_boolean_changed.bind(group_name, key, toggle))
			fields.add_child(toggle)
			continue
		var spin := _create_spinbox("audio.%s.%s" % [group_name, key], float(group[key]))
		spin.value_changed.connect(_on_audio_scalar_changed.bind(group_name, key))
		fields.add_child(spin)


func _add_heat_levels(levels: Array) -> void:
	var title := Label.new()
	title.text = "HEAT LEVELS"
	title.add_theme_font_size_override("font_size", 14)
	_field_container.add_child(title)
	var rows := GridContainer.new()
	rows.columns = 5
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_field_container.add_child(rows)
	for index in range(levels.size()):
		var level: Dictionary = levels[index]
		var level_label := Label.new()
		level_label.text = "Level %d" % index
		rows.add_child(level_label)
		var ratio_label := Label.new()
		ratio_label.text = "threshold"
		_set_tuning_tooltip(ratio_label, "heat.levels.fill_ratio")
		rows.add_child(ratio_label)
		var ratio_spin := _create_spinbox("heat.levels.fill_ratio", float(level["fill_ratio"]))
		ratio_spin.editable = index > 0
		ratio_spin.value_changed.connect(_on_heat_level_changed.bind(index, "fill_ratio"))
		rows.add_child(ratio_spin)
		var speed_label := Label.new()
		speed_label.text = "speed"
		_set_tuning_tooltip(speed_label, "heat.levels.speed_multiplier")
		rows.add_child(speed_label)
		var speed_spin := _create_spinbox("heat.levels.speed_multiplier", float(level["speed_multiplier"]))
		speed_spin.value_changed.connect(_on_heat_level_changed.bind(index, "speed_multiplier"))
		rows.add_child(speed_spin)


func _add_water_levels(levels: Array) -> void:
	var title := Label.new()
	title.text = "WATER LEVELS"
	title.add_theme_font_size_override("font_size", 14)
	_field_container.add_child(title)
	var rows := GridContainer.new()
	rows.columns = 6
	rows.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_field_container.add_child(rows)
	for index in range(levels.size()):
		var level: Dictionary = levels[index]
		var level_label := Label.new()
		level_label.text = "Level %d %s" % [index + 1, str(level["status"]).to_upper()]
		rows.add_child(level_label)
		var duration_label := Label.new()
		duration_label.text = "duration"
		_set_tuning_tooltip(duration_label, "water.levels.duration")
		rows.add_child(duration_label)
		var duration_spin := _create_spinbox("water.levels.duration", float(level["duration"]))
		duration_spin.value_changed.connect(_on_water_level_changed.bind(index, "duration"))
		rows.add_child(duration_spin)
		var slow_label := Label.new()
		slow_label.text = "slow"
		_set_tuning_tooltip(slow_label, "water.levels.slow_percent")
		rows.add_child(slow_label)
		var slow_spin := _create_spinbox("water.levels.slow_percent", float(level["slow_percent"]))
		slow_spin.editable = str(level["status"]) == "slow"
		slow_spin.value_changed.connect(_on_water_level_changed.bind(index, "slow_percent"))
		rows.add_child(slow_spin)
		var spacer := Label.new()
		spacer.text = ""
		rows.add_child(spacer)


func _create_spinbox(path: String, value: float) -> SpinBox:
	var heat_key := path.get_slice(".", 2)
	var range = FIELD_RANGES.get(
		path,
		HEAT_LEVEL_RANGES.get(
			heat_key,
			WATER_LEVEL_RANGES.get(heat_key, Vector3(-10000.0, 10000.0, 0.01))
		)
	)
	var spin := SpinBox.new()
	spin.min_value = range.x
	spin.max_value = range.y
	spin.step = range.z
	spin.value = value
	spin.allow_greater = false
	spin.allow_lesser = false
	spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_set_tuning_tooltip(spin, path)
	return spin


func _set_tuning_tooltip(control: Control, path: String) -> void:
	control.tooltip_text = _tuning_tooltip(path)
	control.mouse_filter = Control.MOUSE_FILTER_STOP
	control.mouse_default_cursor_shape = Control.CURSOR_HELP


func _tuning_tooltip(path: String) -> String:
	if TUNABLE_TOOLTIPS.has(path):
		return str(TUNABLE_TOOLTIPS[path])
	return "Adjust %s." % path.replace(".", " / ").replace("_", " ")


func _on_scalar_changed(value: float, section_name: String, key: String) -> void:
	var path := "%s.%s" % [section_name, key]
	var previous_value: Variant = _config[section_name][key]
	_config[section_name][key] = int(round(value)) if INTEGER_FIELDS.has(path) else value
	if not _apply_live_tuning():
		_config[section_name][key] = previous_value
		call_deferred("_rebuild_fields")


func _on_boolean_changed(value: bool, section_name: String, key: String, toggle: CheckButton) -> void:
	toggle.text = "ON" if value else "OFF"
	var previous_value := bool(_config[section_name][key])
	_config[section_name][key] = value
	if not _apply_live_tuning():
		_config[section_name][key] = previous_value
		toggle.set_pressed_no_signal(previous_value)
		toggle.text = "ON" if previous_value else "OFF"
		call_deferred("_rebuild_fields")


func _on_audio_scalar_changed(value: float, group_name: String, key: String) -> void:
	var previous_value: Variant = _config["audio"][group_name][key]
	_config["audio"][group_name][key] = value
	if not _apply_live_tuning():
		_config["audio"][group_name][key] = previous_value
		call_deferred("_rebuild_fields")


func _on_audio_boolean_changed(value: bool, group_name: String, key: String, toggle: CheckButton) -> void:
	toggle.text = "ON" if value else "OFF"
	var previous_value := bool(_config["audio"][group_name][key])
	_config["audio"][group_name][key] = value
	if not _apply_live_tuning():
		_config["audio"][group_name][key] = previous_value
		toggle.set_pressed_no_signal(previous_value)
		toggle.text = "ON" if previous_value else "OFF"
		call_deferred("_rebuild_fields")


func _on_heat_level_changed(value: float, index: int, key: String) -> void:
	var levels: Array = _config["heat"]["levels"]
	var previous_value: Variant = levels[index][key]
	levels[index][key] = value
	if not _apply_live_tuning():
		levels[index][key] = previous_value
		call_deferred("_rebuild_fields")


func _on_water_level_changed(value: float, index: int, key: String) -> void:
	var levels: Array = _config["water"]["levels"]
	var previous_value: Variant = levels[index][key]
	levels[index][key] = value
	if not _apply_live_tuning():
		levels[index][key] = previous_value
		call_deferred("_rebuild_fields")


func _on_hitbox_toggled(enabled: bool) -> void:
	if _set_hitbox_enabled.is_valid():
		_set_hitbox_enabled.call(enabled)
	_status_label.text = "RUN-ONLY"


func _apply_live_tuning() -> bool:
	if not _apply_tuning.is_valid():
		_status_label.text = "TUNING UNAVAILABLE"
		return false
	var result: Variant = _apply_tuning.call()
	if typeof(result) == TYPE_DICTIONARY:
		var result_data: Dictionary = result
		if not bool(result_data.get("ok", false)):
			_status_label.text = str(result_data.get("error", "INVALID VALUE"))
			return false
	_status_label.text = "UNSAVED"
	return true


func _on_save_pressed() -> void:
	if not _save_tuning.is_valid():
		_status_label.text = "SAVE UNAVAILABLE"
		return
	var result: Dictionary = _save_tuning.call()
	if bool(result.get("ok", false)):
		_status_label.text = "SAVED"
	else:
		_status_label.text = str(result.get("error", "SAVE FAILED"))


func _set_open(open: bool) -> void:
	if _overlay_root == null or _overlay_root.visible == open:
		return
	_overlay_root.visible = open
	if get_tree() == null:
		return
	if open:
		_was_tree_paused = get_tree().paused
		get_tree().paused = true
		_rebuild_fields()
	else:
		get_tree().paused = _was_tree_paused
	_update_pause_button()


func _toggle_game_paused() -> void:
	if get_tree() == null:
		return
	get_tree().paused = not get_tree().paused
	_update_pause_button()


func _update_pause_button() -> void:
	if _pause_button == null or get_tree() == null:
		return
	_pause_button.text = "Resume Game" if get_tree().paused else "Pause Game"
