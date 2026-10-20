extends SceneTree

const Store = preload("res://scripts/config/developer_config_store.gd")
const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Fields = preload("res://scripts/ui/developer_settings_fields.gd")
const Dock = preload("res://addons/laema_dev_portal/focus_dock.gd")
const ReactionRanges = preload("res://scripts/config/combat_reaction_ranges.gd")
const Series = preload("res://scripts/config/developer_settings_series.gd")
const Geometry = preload("res://scripts/combat/attack_geometry.gd")

var failures: Array[String] = []
var checks := 0

class FakeDebugger:
	extends RefCounted
	signal state_received(packet: Dictionary)
	signal availability_changed(available: bool, reason: String)
	func request(_command: String, _payload: Dictionary = {}) -> bool:
		return false


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: ", description)


func send_pad(button: JoyButton, pressed: bool) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func send_key(key: Key, pressed: bool, echo: bool = false) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	event.echo = echo
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func current_field_panel(dock: Node) -> VBoxContainer:
	for child in dock.get("_fields").get_children():
		if child.has_method("update_snapshots"):
			return child
	return null


func choose_category(dock: Node, section: String, category: String) -> void:
	dock._select_section(section)
	var picker: TabBar = dock.get("_category_tabs")
	for index in range(picker.tab_count):
		if picker.get_tab_metadata(index) == category:
			picker.current_tab = index
			return


func _run() -> void:
	var loaded := Store.load_config()
	check(loaded["ok"], "Current fixture configuration validates")
	if not loaded["ok"]:
		quit(1)
		return
	var original: Dictionary = loaded["data"].duplicate(true)
	var levels: Array = original["hit_reaction"]["combat_levels"].duplicate(true)
	var boundary_values := [0, 1, 10, 11, 20, 21, 30, 31, 40, 41, 100]
	var boundary_levels := [1, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
	var boundaries_match := true
	for index in range(boundary_values.size()):
		boundaries_match = boundaries_match and ReactionRanges.level_for_value(boundary_values[index], levels) == boundary_levels[index]
	check(boundaries_match, "Initial configured ranges preserve every existing band boundary")
	var custom_ranges: Dictionary = original.duplicate(true)
	for index in range(5):
		custom_ranges["hit_reaction"]["combat_levels"][index]["minimum_value"] = [0, 2, 3, 4, 5][index]
	check(Loader.validate(custom_ranges)["ok"] and ReactionRanges.level_for_value(5, custom_ranges["hit_reaction"]["combat_levels"]) == 5 and ReactionRanges.range_text(custom_ranges["hit_reaction"]["combat_levels"], 3) == "4–4", "Custom starts define contiguous ranges and cap at Level 5")
	check(Catalog.impact_tooltip(custom_ranges).contains("5+ → Level 5") and not Catalog.impact_tooltip(custom_ranges).contains("41 or more → Level 5"), "Impact help follows configured ranges rather than fixed bands")
	var bad_ranges: Dictionary = custom_ranges.duplicate(true)
	bad_ranges["hit_reaction"]["combat_levels"][2]["minimum_value"] = 2
	check(not Loader.validate(bad_ranges)["ok"], "Overlapping or repeated range starts cannot be saved")
	bad_ranges = custom_ranges.duplicate(true)
	bad_ranges["hit_reaction"]["combat_levels"][1]["minimum_value"] = 1.5
	check(not Loader.validate(bad_ranges)["ok"], "Fractional range starts are rejected")
	bad_ranges = custom_ranges.duplicate(true)
	bad_ranges["hit_reaction"]["combat_levels"][0]["minimum_value"] = 1
	check(not Loader.validate(bad_ranges)["ok"], "First range remains anchored at zero without changing eligibility")
	var legacy_config: Dictionary = original.duplicate(true)
	for level in legacy_config["hit_reaction"]["combat_levels"]:
		level.erase("minimum_value")
	var legacy_file := FileAccess.open("res://legacy-ranges-test.json", FileAccess.WRITE)
	legacy_file.store_string(JSON.stringify(legacy_config))
	legacy_file.close()
	var legacy_hash := FileAccess.get_sha256("res://legacy-ranges-test.json")
	var legacy_load := Store.load_config("res://legacy-ranges-test.json")
	check(legacy_load["ok"] and Store.changes(legacy_load["data"]["hit_reaction"]["combat_levels"], levels).is_empty() and FileAccess.get_sha256("res://legacy-ranges-test.json") == legacy_hash, "Older configs receive compatible range starts in memory without startup file writes")
	var settings_view := CombatTuningSettings.new()
	settings_view.read_from_config(custom_ranges)
	check(settings_view.get_data()["hit_reaction"]["combat_levels"] == custom_ranges["hit_reaction"]["combat_levels"], "Inspector view round trips custom starts alongside duration and distance")
	var reaction_table: Dictionary = Series.tables(original, "hit_reaction")[0]
	var ranges_fill := Series.fill(original, reaction_table, {"minimum_value": {"start": 5, "increment": 5}})
	check(ranges_fill["ok"] and ranges_fill["levels"][0]["minimum_value"] == 0 and ranges_fill["levels"][4]["minimum_value"] == 20, "Range-start series fills editable levels while preserving fixed Level 1")
	check(not Series.fill(original, reaction_table, {"minimum_value": {"start": 5, "increment": 0}})["ok"], "Range series rejects repeated starts before filling the draft")
	var filled := Series.fill(original, reaction_table, {"duration": {"start": 0.4, "increment": 0.2}})
	check(filled["ok"] and is_equal_approx(filled["levels"][4]["duration"], 1.2), "Duration series uses start plus increment per level")
	check(filled["levels"][2]["distance"] == levels[2]["distance"] and levels == original["hit_reaction"]["combat_levels"], "Series preserves unselected column and original input")
	filled = Series.fill(original, reaction_table, {"duration": {"start": 1.0, "increment": -0.1}, "distance": {"start": 2.0, "increment": 3.0}})
	check(filled["ok"] and is_equal_approx(filled["levels"][4]["duration"], 0.6) and filled["levels"][4]["distance"] == 14.0, "Independent rules support decreasing and increasing series")
	check(not Series.fill(original, reaction_table, {"duration": {"start": 0.2, "increment": -0.1}})["ok"], "Series rejects non-positive generated duration")
	check(not Series.fill(original, reaction_table, {"distance": {"start": 0.0, "increment": -1.0}})["ok"], "Series rejects negative generated distance")
	check(not Series.fill(original, reaction_table, {"duration": {"start": NAN, "increment": 0.1}})["ok"], "Series rejects non-finite values")
	check(not Series.fill(original, reaction_table, {})["ok"], "Series requires at least one selected column")
	check(not Series.fill(original, reaction_table, {"difference": {"start": 0.0, "increment": 10.0}})["ok"], "Series rejects unrecognized range keys")
	check(Series.tables(original, "fire").is_empty() and Series.tables(original, "heat").is_empty(), "Fill is not offered for sections without numeric level tables")
	var water_table: Dictionary = Series.tables(original, "water")[0]
	var earth_table: Dictionary = Series.tables(original, "earth")[0]
	var water_fill := Series.fill(original, water_table, {"duration": {"start": 1.0, "increment": 0.5}, "slow_percent": {"start": 0.15, "increment": 0.1}})
	check(water_fill["ok"] and water_fill["levels"][4]["duration"] == 3.0, "Water duration fills across its levels")
	check(is_equal_approx(water_fill["levels"][2]["slow_percent"], 0.15) and is_equal_approx(water_fill["levels"][3]["slow_percent"], 0.25), "Water slow series begins at first editable level")
	var fixed_preserved := true
	for index in range(5):
		fixed_preserved = fixed_preserved and water_fill["levels"][index]["status"] == original["water"]["levels"][index]["status"]
		if index in [0, 1, 4]:
			fixed_preserved = fixed_preserved and water_fill["levels"][index]["slow_percent"] == original["water"]["levels"][index]["slow_percent"]
	check(fixed_preserved, "Water fixed Wet/Frozen amounts and status names survive series fill")
	check(not Series.fill(original, water_table, {"slow_percent": {"start": 0.9, "increment": 0.2}})["ok"], "Water series respects slow ratio maximum")
	check(not Series.fill(original, water_table, {"status": {"start": 0.0, "increment": 1.0}})["ok"], "Non-numeric status names are never fill columns")
	var earth_fill := Series.fill(original, earth_table, {"duration": {"start": 1.0, "increment": 0.25}, "slow_percent": {"start": 0.1, "increment": 0.15}})
	check(earth_fill["ok"] and earth_fill["levels"][4]["duration"] == 2.0 and is_equal_approx(earth_fill["levels"][4]["slow_percent"], 0.7), "Earth supports both numeric level columns")
	check(not Series.fill(original, earth_table, {"slow_percent": {"start": 0.5, "increment": 0.3}})["ok"], "Earth series rejects values exceeding per-field bounds")
	var impact_tables := Series.tables(original, "moves")
	check(impact_tables.size() == 4 and impact_tables[0]["row_labels"] == ["X1", "X2", "X3", "X4", "X5"], "Each school exposes an ordered X1–X5 Impact series")
	var impact_fill := Series.fill(original, impact_tables[0], {"impact": {"start": 2, "increment": 3}})
	check(impact_fill["ok"] and impact_fill["levels"][0]["impact"] == 2 and impact_fill["levels"][4]["impact"] == 14, "Impact series fills integer move strengths")
	var only_fire := true
	for change in impact_fill["changes"]:
		only_fire = only_fire and change["path"][0] == "moves" and str(change["path"][1]).begins_with("fire_x") and change["path"].back() == "impact" and change["after"] is int
	check(only_fire and original["moves"]["cast"]["impact"] == loaded["data"]["moves"]["cast"]["impact"], "Impact series targets only selected school X moves")
	check(not Series.fill(original, impact_tables[0], {"impact": {"start": 0, "increment": -1}})["ok"], "Impact series rejects negative move strength")
	var base := original.duplicate(true)
	var draft := base.duplicate(true)
	draft["movement"]["speed"] = 321.0
	var external := base.duplicate(true)
	external["player"]["poise"] = 7
	var merged := Store.merge(base, draft, external)
	check(merged["ok"] and merged["data"]["movement"]["speed"] == 321.0 and merged["data"]["player"]["poise"] == 7, "Independent edits merge without lost values")
	external["movement"]["speed"] = 333.0
	check(not Store.merge(base, draft, external)["ok"], "Same-field conflict is rejected")
	external["movement"]["speed"] = 321.0
	check(Store.merge(base, draft, external)["ok"], "Identical concurrent edits are accepted")
	var nested := base.duplicate(true)
	var retained: Dictionary = nested["movement"]
	Store.copy_into(nested, draft)
	check(retained["speed"] == 321.0, "Apply preserves retained nested dictionaries")
	check(Catalog.fields(base, "moves").size() == 22, "All move Impact controls are shared")
	check(Catalog.fields(base, "hit_reaction").size() == 15 and Catalog.fields(base, "legacy_reactions").size() == 4, "Five range/duration/distance entries are separate from four legacy controls")
	check(Catalog.fields(base, "earth").size() == 12, "Earth nested levels remain exposed; sprite pacing is authored in animation tracks")
	for entry in Catalog.CATEGORIES:
		var controls := Fields.new()
		root.add_child(controls)
		controls.configure(base, entry[0], original)
		check(controls.get_child_count() > 0, "Controls construct for " + str(entry[0]))
		controls.free()
	var path := "res://portal-test.json" # This script runs only in the isolated fixture.
	check(Loader.validate_and_save(path, base)["ok"], "Atomic first save succeeds")
	check(Store.save_changes(base, draft, path)["ok"], "Atomic replacement save succeeds")
	check(Store.load_config(path)["data"]["movement"]["speed"] == 321.0, "Save/reload round trip preserves edits")
	var invalid := draft.duplicate(true)
	invalid["casting"]["trigger_release_max"] = 0.99
	var hash := FileAccess.get_sha256(path)
	check(not Store.save_changes(draft, invalid, path)["ok"] and hash == FileAccess.get_sha256(path), "Invalid cross-field edit leaves file intact")
	check(not Loader.validate_and_save(path, base, "stale-hash")["ok"] and hash == FileAccess.get_sha256(path), "Stale file identity leaves file intact")
	var dock := Dock.new()
	# The headless display starts at 64x64; use realistic editor dimensions for layout checks.
	root.size = Vector2i(1280, 720)
	dock.setup(FakeDebugger.new())
	root.add_child(dock)
	await process_frame
	check(not dock.get("_base").is_empty(), "Dock loads without a running game")
	var category_tabs: TabBar = dock.get("_category_tabs")
	var section_row: Control = dock.get("_section_buttons")["combat"].get_parent()
	check(category_tabs.get_parent() == section_row.get_parent() and category_tabs.get_index() == section_row.get_index() + 1, "Second-level category tabs sit directly below the main section tabs")
	check(category_tabs.clip_tabs and category_tabs.scrolling_enabled and category_tabs.get_combined_minimum_size().x <= 280, "Category tabs scroll without widening a narrow editor dock")
	var navigation_before: Dictionary = dock.get("_draft").duplicate(true)
	var navigation_categories: Dictionary = dock.get("_section_categories").duplicate(true)
	var categories_reachable := true
	for section in Catalog.NAVIGATION:
		dock._select_section(section[0])
		for index in range(category_tabs.tab_count):
			category_tabs.current_tab = index
			categories_reachable = categories_reachable and dock.get("_category_key") == section[2][index]
	check(categories_reachable and dock.get("_draft") == navigation_before, "Every category tab opens its page without changing the draft")
	dock.set("_section_categories", navigation_categories)
	choose_category(dock, "combat", "hit_reaction")
	var original_section_order: Array = dock.get("_section_order").duplicate()
	var original_category_order: Dictionary = dock.get("_category_order").duplicate(true)
	dock._on_value_changed(["movement", "speed"], float(original["movement"]["speed"]) + 1.0)
	var layout_draft: Dictionary = dock.get("_draft").duplicate(true)
	var layout_source_hash := FileAccess.get_sha256(Store.CONFIG_PATH)
	var section_drag := {"kind": "laema_section", "dock": dock.get_instance_id(), "key": "schools"}
	check(dock._can_drop_section(Vector2.ZERO, section_drag, "general") and not dock._can_drop_section(Vector2.ZERO, {"kind": "laema_section", "dock": -1, "key": "schools"}, "general"), "Section drag accepts only this dock's navigation buttons")
	dock._drop_section(Vector2.ZERO, section_drag, "general")
	check(section_row.get_child(0).get_meta("section_key") == "schools" and dock.get("_section_key") == "combat", "Dragging main sections reorders the grid without selecting another page")
	var selected_category: String = dock.get("_category_key")
	category_tabs.move_tab(category_tabs.current_tab, 0)
	category_tabs.active_tab_rearranged.emit(0)
	check(category_tabs.drag_to_rearrange_enabled and dock.get("_category_order")["combat"][0] == selected_category and dock.get("_category_key") == selected_category, "Native category rearrangement preserves the selected page identity")
	check(dock.get("_draft") == layout_draft and FileAccess.get_sha256(Store.CONFIG_PATH) == layout_source_hash, "Rearranging both navigation levels preserves unsaved edits and saved gameplay tuning")
	var reopened_dock := Dock.new()
	reopened_dock.setup(FakeDebugger.new())
	root.add_child(reopened_dock)
	await process_frame
	check(reopened_dock.get("_section_order")[0] == "schools" and reopened_dock.get("_category_tabs").get_tab_metadata(0) == selected_category, "Both tab orders survive reopening the dock from local editor preferences")
	reopened_dock._select_section("schools")
	reopened_dock.get("_category_tabs").current_tab = 3
	check(reopened_dock.get("_category_order")["schools"] == original_category_order["schools"], "Each section retains its own independent category order")
	reopened_dock.free()
	var selection_dock := Dock.new()
	selection_dock.setup(FakeDebugger.new())
	root.add_child(selection_dock)
	await process_frame
	check(selection_dock.get("_section_key") == "schools" and selection_dock.get("_category_key") == "earth", "Reopening restores both the last main section and its selected category")
	selection_dock._select_section("combat")
	check(selection_dock.get("_category_key") == selected_category, "Each section's selected category survives reopening independently")
	var selected_draft: Dictionary = selection_dock.get("_draft").duplicate(true)
	selection_dock._reload_file()
	check(selection_dock.get("_category_key") == selected_category and selection_dock.get("_draft") == selected_draft and FileAccess.get_sha256(Store.CONFIG_PATH) == layout_source_hash, "Reloading configuration retains the selected page without changing saved tuning")
	selection_dock.free()
	check(dock._ordered_navigation_keys(["removed", "moves", "moves"], ["combat", "moves", "heat"]) == ["moves", "combat", "heat"], "Layout loading removes stale or duplicate tabs and appends new categories")
	dock.set("_section_order", original_section_order)
	dock.set("_category_order", original_category_order)
	dock._save_navigation_layout()
	dock._select_section("combat")
	dock._reload_file()
	var reaction_controls = current_field_panel(dock)
	check(reaction_controls.get("_foldout_bodies").is_empty(), "Reaction-level page contains no legacy foldout")
	var levels_body: VBoxContainer = reaction_controls.get("_reaction_levels_body")
	var level_inputs := levels_body.find_children("*", "SpinBox", true, false)
	check(not levels_body.visible and level_inputs.size() == 15 and not level_inputs[0].is_visible_in_tree(), "Levels 1–5 parent hides five sets of range/duration/distance controls")
	choose_category(dock, "combat", "legacy_reactions")
	var legacy_controls = current_field_panel(dock)
	check(legacy_controls.get("_entries").size() == 4 and legacy_controls.get("_reaction_levels_body") == null, "Legacy reactions have a separate four-control page")
	choose_category(dock, "combat", "hit_reaction")
	reaction_controls = current_field_panel(dock)
	levels_body = reaction_controls.get("_reaction_levels_body")
	level_inputs = levels_body.find_children("*", "SpinBox", true, false)
	reaction_controls.get("_reaction_levels_toggle").button_pressed = true
	var all_levels_visible := true
	for input in level_inputs:
		all_levels_visible = all_levels_visible and input.is_visible_in_tree()
	check(all_levels_visible and levels_body.find_children("*", "Button", true, false).is_empty(), "Opening the parent reveals every level without individual toggles")
	var start_control: SpinBox = reaction_controls.get("_inputs")["hit_reaction.combat_levels.1.minimum_value"]
	start_control.value = 5
	check(str(reaction_controls.get("_reaction_headings")[0].text).contains("0–4") and str(reaction_controls.get("_reaction_headings")[1].text).contains("5–20"), "Changing a starting value updates both adjoining range headings")
	check(dock.get("_draft")["hit_reaction"]["combat_levels"][1]["minimum_value"] == 5 and FileAccess.get_sha256(Store.CONFIG_PATH) == layout_source_hash, "Range edits use the shared draft without auto-saving")
	dock._save_changes()
	check(Store.load_config()["data"]["hit_reaction"]["combat_levels"][1]["minimum_value"] == 5, "Review/save path persists custom range starts in shared JSON")
	Store.save_changes(Store.load_config()["data"], original)
	dock._reload_file()
	dock._select_section("general")
	dock._select_section("combat")
	reaction_controls = current_field_panel(dock)
	check(reaction_controls.get("_reaction_levels_body").visible, "Expanded Levels 1–5 parent is remembered across page navigation")
	reaction_controls.get_child(0).get_child(1).pressed.emit()
	check(not reaction_controls.get("_reaction_levels_body").visible and dock.get("_draft") == original, "Collapse all changes only presentation, not tuning")
	choose_category(dock, "combat", "moves")
	check(dock.get("_page_title").text == "Impact", "Combat exposes a discoverable Impact page")
	var move_controls = current_field_panel(dock)
	var fire_group := "Fire / X1–X5"
	move_controls.get("_foldout_buttons")[fire_group].button_pressed = true
	var fire_body: VBoxContainer = move_controls.get("_foldout_bodies")[fire_group]
	var impact_spins: Array[Node] = fire_body.find_children("*", "SpinBox", true, false)
	check(impact_spins.size() == 5 and move_controls.get("_foldout_bodies").has("Casting") and move_controls.get("_foldout_bodies").has("Final Enemy"), "Impact page exposes five X controls per school plus separate Cast and Enemy controls")
	impact_spins[2].value = int(original["moves"]["fire_x3"]["impact"]) + 7
	var edited_paths := Store.changes(original, dock.get("_draft"))
	check(edited_paths.size() == 1 and edited_paths[0]["path"] == ["moves", "fire_x3", "impact"], "Editing Fire X3 changes its actual combat move entry only")
	check(str(move_controls.get("_summary_labels")[fire_group].text).contains("X3:"), "Collapsed Impact summary tracks individual X values")
	fire_body.get_child(0).pressed.emit()
	check(dock.get("_series_table")["title"] == "Fire X1–X5 Impact", "Fire's fill action targets its own move sequence")
	var impact_rule: Dictionary = dock.get("_series_controls")["impact"]
	impact_rule["start"].set_value_no_signal(2)
	impact_rule["increment"].set_value_no_signal(2)
	dock._update_series_preview()
	dock.get("_series_dialog").hide()
	dock._fill_level_series()
	var x_values_correct := true
	for position in range(1, 6):
		x_values_correct = x_values_correct and dock.get("_draft")["moves"]["fire_x%d" % position]["impact"] == position * 2
	check(x_values_correct and dock.get("_draft")["moves"]["water_x1"]["impact"] == original["moves"]["water_x1"]["impact"] and dock.get("_draft")["moves"]["cast"]["impact"] == original["moves"]["cast"]["impact"], "School Impact fill preserves other schools and Cast")
	check(current_field_panel(dock).get("_foldout_bodies")[fire_group].visible, "Impact foldout stays open after filling the draft")
	dock._save_changes()
	check(Store.load_config()["data"]["moves"]["fire_x5"]["impact"] == 10, "X1–X5 Impact saves to the shared combat configuration")
	var style_path := "res://config/attack_styles/fire_x1.tres"
	var cached_style = load(style_path)
	var cached_reach: float = cached_style.shape_reach
	dock._on_value_changed(["moves", "fire_x1", "shape_reach"], 73.25)
	dock._save_changes()
	var saved_style = ResourceLoader.load(style_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	var saved_reach: float = Store.load_config()["data"]["moves"]["fire_x1"]["shape_reach"]
	check(is_equal_approx(saved_reach, 73.25) and is_equal_approx(saved_style.shape_reach, 73.25), "Portal saves synchronize native animation and the external move asset (native=%s, mirror=%s)" % [saved_reach, saved_style.shape_reach])
	check(saved_style.resource_path == style_path and cached_style.shape_reach == cached_reach, "Portal saving retains asset paths without applying changes to cached Inspector Resources")
	var saved_mirror = ResourceLoader.load(Store.TUNING_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	check(saved_mirror.attack_styles[0].resource_path == style_path, "Portal saves preserve the parent's move-file references")
	check(is_equal_approx(Vector2(Geometry.contact(Geometry.load_clock("fire_x1"))["target"]).length(), 73.25), "Portal reach saves into the native animation contact key")
	check(Store.save_changes(Store.load_config()["data"], original)["ok"], "Portal save fixture restores character Settings and external assets together")
	cached_style = null
	saved_style = null
	saved_mirror = null
	dock._reload_file()
	choose_category(dock, "combat", "hit_reaction")
	var source_before_series := FileAccess.get_sha256(Store.CONFIG_PATH)
	var draft_before_series: Dictionary = dock.get("_draft").duplicate(true)
	dock._show_level_series(Series.tables(dock.get("_draft"), "hit_reaction")[0])
	await process_frame
	await process_frame
	var preview_grid: GridContainer = dock.get("_series_preview")
	var preview_single_lines := true
	for cell in preview_grid.get_children():
		preview_single_lines = preview_single_lines and cell.get_line_count() == 1 and cell.size.x >= 48
	check(preview_single_lines and preview_grid.size.y < 300, "Reaction preview stays in compact single-line table rows")
	var dialog: ConfirmationDialog = dock.get("_series_dialog")
	check(dialog.size.y <= root.size.y * 0.85 + 2, "Series dialog height is bounded by parent window (%s, parent %s)" % [dialog.size, root.size])
	var saved_window_size := root.size
	dialog.hide()
	root.size = Vector2i(420, 500)
	dock._show_level_series(Series.tables(dock.get("_draft"), "hit_reaction")[0])
	await process_frame
	await process_frame
	preview_grid = dock.get("_series_preview")
	preview_single_lines = true
	for cell in preview_grid.get_children():
		preview_single_lines = preview_single_lines and cell.get_line_count() == 1
	check(preview_single_lines and preview_grid.size.y < 300, "Narrow-window preview scrolls instead of stacking letters")
	dialog = dock.get("_series_dialog")
	check(dialog.size.y <= root.size.y * 0.85 + 2 and dialog.get_ok_button().get_global_rect().end.y <= dialog.size.y, "Narrow-window Fill draft button remains inside the bounded dialog")
	dialog.hide()
	root.size = saved_window_size
	var rules: Dictionary = dock._series_rules()
	check(is_equal_approx(rules["duration"]["start"], levels[0]["duration"]) and is_equal_approx(rules["duration"]["increment"], levels[1]["duration"] - levels[0]["duration"]), "Series dialog infers initial duration rule from first two levels")
	check(dock.get("_draft") == draft_before_series and FileAccess.get_sha256(Store.CONFIG_PATH) == source_before_series, "Opening series preview does not change draft or saved config")
	var series_controls: Dictionary = dock.get("_series_controls")
	series_controls["distance"]["enabled"].set_pressed_no_signal(false)
	series_controls["duration"]["start"].set_value_no_signal(0.45)
	series_controls["duration"]["increment"].set_value_no_signal(0.25)
	dock._update_series_preview()
	dock.get("_series_dialog").hide()
	dock._fill_level_series()
	check(is_equal_approx(dock.get("_draft")["hit_reaction"]["combat_levels"][4]["duration"], 1.45), "Fill series updates the editor draft")
	var series_only_changes := Store.changes(draft_before_series, dock.get("_draft"))
	var only_durations := not series_only_changes.is_empty()
	for change in series_only_changes:
		only_durations = only_durations and change["path"].size() == 4 and change["path"][1] == "combat_levels" and change["path"].back() == "duration"
	check(only_durations and FileAccess.get_sha256(Store.CONFIG_PATH) == source_before_series, "Series only changes selected draft values and never saves or applies")
	dock._reload_file()
	dock._show_level_series(Series.tables(dock.get("_draft"), "hit_reaction")[0])
	dock.get("_series_dialog").hide()
	dock.get("_draft")["hit_reaction"]["combat_levels"][0]["duration"] = 0.777
	dock._fill_level_series()
	check(dock.get("_draft")["hit_reaction"]["combat_levels"][0]["duration"] == 0.777, "Stale series preview cannot overwrite newer reaction edits")
	dock._reload_file()
	dock._select_section("schools")
	dock.get("_category_tabs").current_tab = 3
	var earth_fill_button: Button = dock.get("_fields").get_child(0)
	check(earth_fill_button.text == "Fill series…", "Earth page automatically exposes shared series action")
	earth_fill_button.pressed.emit()
	await process_frame
	await process_frame
	preview_grid = dock.get("_series_preview")
	preview_single_lines = true
	for cell in preview_grid.get_children():
		preview_single_lines = preview_single_lines and cell.get_line_count() == 1
	check(preview_single_lines and preview_grid.size.y < 300, "Earth series preview also remains a compact table")
	check(dock.get("_series_table")["path"] == ["earth", "levels"], "Earth action opens the correct level table")
	series_controls = dock.get("_series_controls")
	series_controls["duration"]["enabled"].set_pressed_no_signal(false)
	series_controls["slow_percent"]["start"].set_value_no_signal(0.2)
	series_controls["slow_percent"]["increment"].set_value_no_signal(0.3)
	dock._update_series_preview()
	check(dock.get("_series_dialog").get_ok_button().disabled, "Invalid Earth preview disables Fill draft")
	series_controls["slow_percent"]["increment"].set_value_no_signal(0.1)
	dock._update_series_preview()
	check(not dock.get("_series_dialog").get_ok_button().disabled, "Valid Earth preview enables Fill draft")
	dock.get("_series_dialog").hide()
	dock._fill_level_series()
	check(is_equal_approx(dock.get("_draft")["earth"]["levels"][4]["slow_percent"], 0.6) and dock.get("_draft")["earth"]["levels"][4]["duration"] == original["earth"]["levels"][4]["duration"], "Generic dock fill changes only selected Earth column")
	check(FileAccess.get_sha256(Store.CONFIG_PATH) == source_before_series, "Generic fill remains draft-only")
	dock._save_changes()
	check(is_equal_approx(Store.load_config()["data"]["earth"]["levels"][4]["slow_percent"], 0.6), "Generated Earth values persist through the shared save path")
	Store.save_changes(Store.load_config()["data"], original)
	dock._reload_file()
	dock.get("_section_buttons")["schools"].pressed.emit()
	check(dock.get("_category_tabs").tab_count == 4 and dock.get("_category_tabs").get_tab_title(0) == "Fire", "Schools section has four category tabs with clean names")
	dock.get("_category_tabs").current_tab = 1
	dock.get("_section_buttons")["general"].pressed.emit()
	check(dock.get("_category_tabs").tab_count == 5 and dock.get("_category_key") == "movement", "General section lists only its own settings")
	dock._on_value_changed(["movement", "speed"], 345.0)
	dock.get("_section_buttons")["schools"].pressed.emit()
	check(dock.get("_category_key") == "water" and dock.get("_draft")["movement"]["speed"] == 345.0, "Section navigation remembers category and preserves unsaved draft")
	var presentation_fields := 0
	var unused_effects := 0
	for school in ["fire", "water", "air", "earth"]:
		for field in Catalog.fields(original, school):
			if str(field["id"]).ends_with(".visual_motion_exponent"):
				presentation_fields += 1
			elif not str(field["casting_usage_note"]).is_empty():
				unused_effects += 1
	check(presentation_fields == 0 and unused_effects > 0, "Native sprite tracks replace legacy exponent controls; unused Cast effects stay identified")
	var labels: Array[Node] = dock.get("_fields").find_children("*", "Label", true, false)
	var shows_usage_note := false
	for label in labels:
		if label.text == "Not used by current Casting":
			shows_usage_note = true
	check(shows_usage_note, "Unused-Casting marks are visible on individual fields")
	dock.get("_section_buttons")["audio"].pressed.emit()
	check(not dock.get("_category_tabs").visible and dock.get("_category_key") == "audio", "Single-page section omits an unnecessary category row")
	check(Store.load_config()["data"]["movement"]["speed"] == original["movement"]["speed"], "Dock draft does not write config")
	dock._save_changes()
	check(Store.load_config()["data"]["movement"]["speed"] == 345.0, "Offline dock save persists")
	check(dock.get("_apply").disabled, "Live apply unavailable while stopped")
	dock._on_value_changed(["player", "poise"], 9)
	var latest: Dictionary = Store.load_config()["data"]
	latest["movement"]["speed"] = 350.0
	Store.save_changes(Store.load_config()["data"], latest)
	dock._process(1.1)
	check(dock.get("_draft")["player"]["poise"] == 9, "External file change preserves editor draft")
	check(dock.get("_saved_file")["movement"]["speed"] == 350.0, "Saved readback follows the actual file while preserving draft baseline")
	dock._save_changes()
	latest = Store.load_config()["data"]
	check(latest["movement"]["speed"] == 350.0 and latest["player"]["poise"] == 9, "Dock save merges external unrelated edit")
	var gym_requests: Array = []
	dock.run_gym_requested.connect(func(): gym_requests.append(true))
	var run_gym_button: Button = dock.get("_body").get_node("RunGym")
	check(not run_gym_button.disabled and run_gym_button.visible, "Gym launcher is available from a settings page without a running game")
	run_gym_button.pressed.emit()
	check(gym_requests.size() == 1, "Gym button sends an editor launch request")
	dock._select_section("session")
	dock._on_availability_changed(true, "Game connected")
	dock._on_state_received({"config": original, "stages": [{"id": "stage_1", "label": "Stage 1", "index": 0}], "paused": false, "unsaved": false})
	check(dock.get("_fields").get_node("StageSelector").item_count == 1, "Session selector populates after first game packet")
	dock.free()
	Store.save_changes(Store.load_config()["data"], original)
	var arena_scene: PackedScene = load("res://scenes/prototype_arena.tscn")
	var arena := arena_scene.instantiate()
	arena.get_node("Player/CombatTuning").settings.player_poise = 987
	var startup_hash := FileAccess.get_sha256(Store.CONFIG_PATH)
	root.add_child(arena)
	current_scene = arena
	await process_frame
	await process_frame
	await process_frame
	var packet: Dictionary = arena.get_developer_config_state()
	check(packet["config"]["player"]["poise"] == original["player"]["poise"], "Character Settings override the stale legacy Inspector view on startup")
	check(FileAccess.get_sha256(Store.CONFIG_PATH) == startup_hash, "Startup never rewrites authoritative config")
	check(not packet["unsaved"], "Arena starts from saved character Settings without unsaved changes")
	check(arena.player.is_attack_hitbox_debug_enabled() == original["ui"]["attack_hitbox_visible"], "Saved hitbox preference applied at startup")
	check(not arena.apply_saved_developer_config({})["ok"], "Stale live snapshot rejected")
	var changed_config := original.duplicate(true)
	changed_config["movement"]["speed"] = 360.0
	Store.save_changes(Store.load_config()["data"], changed_config)
	check(arena.apply_saved_developer_config(packet["config"])["ok"], "Saved editor config applies to an idle runtime")
	check(arena.get("_config")["movement"]["speed"] == 360.0, "Runtime reads applied saved value")
	arena.get("_developer_overlay")._on_setting_changed(["player", "poise"], 4)
	packet = arena.get_developer_config_state()
	check(packet["unsaved"], "In-game portal edit remains unsaved")
	check(not arena.apply_saved_developer_config(packet["config"])["ok"], "Apply protects unsaved in-game tuning")
	check(arena._save_runtime_tuning()["ok"], "In-game save uses shared config")
	check(Store.load_config()["data"]["player"]["poise"] == 4, "In-game edit persists in the same character Settings asset")
	arena.get("_developer_overlay")._set_open(true)
	check(paused, "In-game portal retains pause behavior")
	arena.get("_developer_overlay")._set_open(false)
	check(not paused, "Closing portal restores playback")
	# Let the Dummy audio driver release loop playbacks before SceneTree teardown.
	arena.ambient_audio.stop()
	arena.music_audio.stop()
	await create_timer(0.15).timeout
	arena.free()
	await process_frame
	Store.save_changes(Store.load_config()["data"], original)
	var gym_hash := FileAccess.get_sha256(Store.CONFIG_PATH)
	var gym_area_scene: PackedScene = load("res://scenes/stages/gym_area.tscn")
	var authored_gym := gym_area_scene.instantiate()
	check(is_equal_approx(authored_gym.get_node("FinalEnemy").position.x - authored_gym.get_node("PlayerSpawn").position.x, 160.0), "Gym authors a 160-pixel starting gap")
	authored_gym.free()
	var gym_scene: PackedScene = load("res://scenes/gym.tscn")
	var gym := gym_scene.instantiate()
	root.add_child(gym)
	current_scene = gym
	await process_frame
	await process_frame
	await process_frame
	var gym_area: StageArea = gym.get("_current_area")
	var gym_targets := gym_area.get_targets()
	check(gym_targets.size() == 1 and gym_targets[0].name == "FinalEnemy", "Gym spawns only the existing Final Enemy with no practice targets")
	check(gym.has_node("Player") and gym.find_children("*", "CharacterBody2D", true, false).size() == 2, "Gym contains exactly the Player and Enemy character bodies")
	var gym_options: Array = gym.get_developer_stage_options()
	check(gym_options.size() == 1 and gym_options[0]["id"] == "gym", "Gym session selector reports its scene-specific encounter ID")
	check(gym.get("_config")["tutorial"] == original["tutorial"] and FileAccess.get_sha256(Store.CONFIG_PATH) == gym_hash, "Gym leaves saved tutorial selection and configuration unchanged")
	var gym_enemy: Node2D = gym_targets[0]
	var starting_distance: float = absf(gym_enemy.global_position.x - gym.player.global_position.x)
	check(starting_distance <= 160.1 and starting_distance < float(original["enemy_ai"]["aggro_range"]), "Gym starts the enemy inside awareness range")
	for frame in range(30):
		await physics_frame
	if bool(original["enemy_ai"]["enabled"]) and float(original["enemy_ai"]["movement_speed"]) > 0.0:
		check(absf(gym_enemy.global_position.x - gym.player.global_position.x) < starting_distance, "Enabled gym enemy approaches without requiring Player travel")
	gym._load_stage_from_developer(0)
	await process_frame
	await process_frame
	gym = current_scene
	check(gym.get("_current_descriptor")["id"] == "gym" and gym.get("_current_area").get_targets().size() == 1, "Reloading the gym resets the same one-enemy encounter")
	var pause_ui = gym.pause_menu
	check(not pause_ui.is_open() and not paused, "Pause HUD starts hidden without pausing gameplay")
	send_pad(JOY_BUTTON_START, true)
	await process_frame
	send_pad(JOY_BUTTON_START, false)
	check(paused and pause_ui.is_open(), "Controller Start opens the pause HUD and pauses the tree")
	check(pause_ui.resume_button.has_focus(), "Pause HUD gives controller focus to Resume")
	var paused_enemy: Node2D = gym.get("_current_area").get_targets()[0]
	var paused_enemy_position := paused_enemy.global_position
	var paused_player_position: Vector2 = gym.player.global_position
	await create_timer(0.1, true).timeout
	check(paused_enemy.global_position == paused_enemy_position and gym.player.global_position == paused_player_position, "Player and Enemy stay frozen while pause menu is open")
	send_pad(JOY_BUTTON_DPAD_DOWN, true)
	await process_frame
	send_pad(JOY_BUTTON_DPAD_DOWN, false)
	check(pause_ui.restart_button.has_focus(), "Controller can navigate to Restart while paused")
	send_pad(JOY_BUTTON_DPAD_UP, true)
	await process_frame
	send_pad(JOY_BUTTON_DPAD_UP, false)
	send_pad(JOY_BUTTON_A, true)
	await process_frame
	send_pad(JOY_BUTTON_A, false)
	await process_frame
	check(not paused and not pause_ui.is_open(), "Controller accept activates Resume (focus %s; accept bindings %s)" % [str(root.gui_get_focus_owner()), str(InputMap.action_get_events(&"ui_accept"))])
	send_key(KEY_ESCAPE, true)
	await process_frame
	check(paused and pause_ui.is_open(), "Esc opens the same pause menu")
	send_key(KEY_ESCAPE, true, true)
	await process_frame
	check(paused and pause_ui.is_open(), "Keyboard repeat does not toggle pause repeatedly")
	send_key(KEY_ESCAPE, false)
	send_key(KEY_ESCAPE, true)
	await process_frame
	send_key(KEY_ESCAPE, false)
	check(not paused and not pause_ui.is_open(), "Esc resumes gameplay without leaving a hidden pause")
	send_pad(JOY_BUTTON_START, true)
	await process_frame
	send_pad(JOY_BUTTON_START, false)
	send_pad(JOY_BUTTON_START, true)
	await process_frame
	send_pad(JOY_BUTTON_START, false)
	check(not paused and not pause_ui.is_open(), "Start toggles the menu closed as well as open")
	send_pad(JOY_BUTTON_START, true)
	await process_frame
	send_pad(JOY_BUTTON_START, false)
	send_pad(JOY_BUTTON_B, true)
	await process_frame
	send_pad(JOY_BUTTON_B, false)
	check(not paused and not pause_ui.is_open(), "Controller cancel resumes from the pause menu")
	pause_ui.set_open(true)
	gym.get("_developer_overlay")._set_open(true)
	check(paused and not pause_ui.is_open() and gym.get("_developer_overlay").get("_overlay_root").visible, "Opening Dev Portal replaces the pause menu")
	gym.get("_developer_overlay")._set_open(false)
	check(not paused, "Closing Dev Portal after pause-menu handoff restores gameplay")
	gym.get("_developer_overlay")._set_open(true)
	send_pad(JOY_BUTTON_START, true)
	await process_frame
	send_pad(JOY_BUTTON_START, false)
	check(paused and pause_ui.is_open() and not gym.get("_developer_overlay").get("_overlay_root").visible, "Start replaces an open Dev Portal with the pause menu")
	pause_ui.resume_button.pressed.emit()
	check(not paused, "Resume after portal handoff clears the pause")
	gym.set_game_paused(true)
	check(paused and pause_ui.is_open(), "Editor pause uses the visible game pause HUD")
	gym.set_game_paused(false)
	check(not paused and not pause_ui.is_open(), "Editor resume closes the game pause HUD")
	gym.set("_transitioning", true)
	pause_ui.set_open(true)
	check(pause_ui.restart_button.disabled, "Restart is unavailable during a stage transition")
	gym.set("_transitioning", false)
	pause_ui.close()
	var old_gym_area_id: int = gym.get("_current_area").get_instance_id()
	pause_ui.set_open(true)
	pause_ui.restart_button.pressed.emit()
	await process_frame
	await process_frame
	gym = current_scene
	pause_ui = gym.pause_menu
	check(not paused and not pause_ui.is_open() and gym.get("_current_area").get_instance_id() != old_gym_area_id and gym.get("_current_descriptor")["id"] == "gym", "Pause Restart resumes and reloads the current gym encounter")
	check(FileAccess.get_sha256(Store.CONFIG_PATH) == gym_hash, "Pause/resume/restart do not save or change tuning")
	var refill_enemy: Entity = load("res://scenes/enemy/combat_enemy.tscn").instantiate()
	refill_enemy.refills_at_zero = true
	gym.add_child(refill_enemy)
	refill_enemy.configure(gym.get("_config"))
	refill_enemy.set_stage_active(true)
	refill_enemy.set_physics_process(false)
	var refill_outcomes: Array = []
	refill_enemy.outcome_published.connect(func(outcome): refill_outcomes.append(outcome.get_kind()))
	var refill_keeps_fighting := true
	for depletion in range(3):
		var hit := HealthEvent.damage(gym.player, refill_enemy, refill_enemy.health.get_maximum() * 2.0, 0, HealthEvent.Delivery.DIRECT if depletion % 2 == 0 else HealthEvent.Delivery.DOT_TICK, &"")
		var result: HealthResult = refill_enemy.receive_health_event(hit)
		refill_keeps_fighting = refill_keeps_fighting and result.zero_reached and result.health_delta < 0.0 and refill_enemy.health.get_current() == refill_enemy.health.get_maximum() and not refill_enemy.get("_defeated") and refill_enemy.get("_state") != refill_enemy.State.DEAD
	check(refill_keeps_fighting, "Independent practice enemy repeatedly refills on direct/tick depletion without dying")
	check(refill_outcomes.count(&"practice_target_refilled") == 3 and not refill_outcomes.has(&"final_enemy_defeated"), "Practice refill never publishes final-enemy defeat")
	check(gym.stage_director.get("_lifecycle") == StageDirector.Lifecycle.FINAL_ACTIVE, "Independent practice refills never complete the Gym objective")
	var reacting_hit := HealthEvent.damage(gym.player, refill_enemy, refill_enemy.health.get_maximum() * 2.0, refill_enemy.get_poise() + 1, HealthEvent.Delivery.DIRECT, &"", {}, Vector2.RIGHT)
	var reacting_result: HealthResult = refill_enemy.receive_health_event(reacting_hit)
	check(reacting_result.zero_reached and reacting_result.final_reaction_level > 0 and refill_enemy.hit_reaction.is_invincible() and refill_enemy.health.get_current() == refill_enemy.health.get_maximum() and refill_enemy.get("_state") != refill_enemy.State.DEAD, "Refilling practice enemy retains qualifying hit reactions")
	refill_enemy.hit_reaction.reset_for_stage()
	for index in range(5):
		gym.get("_config")["hit_reaction"]["combat_levels"][index]["minimum_value"] = [0, 2, 3, 4, 5][index]
	check(gym._apply_runtime_tuning()["ok"], "Live apply accepts ordered custom reaction ranges")
	var custom_hit := HealthEvent.damage(gym.player, refill_enemy, 1.0, refill_enemy.get_poise() + 5, HealthEvent.Delivery.DIRECT, &"", {}, Vector2.RIGHT)
	var custom_result: HealthResult = refill_enemy.receive_health_event(custom_hit)
	check(custom_result.final_reaction_level == 5 and is_equal_approx(refill_enemy.hit_reaction.get("_remaining"), float(original["hit_reaction"]["combat_levels"][4]["duration"])), "Real enemy health resolution uses the configured level and its duration")
	var captured_duration: float = refill_enemy.hit_reaction.get("_remaining")
	refill_enemy.hit_reaction.configure(original["hit_reaction"])
	check(is_equal_approx(refill_enemy.hit_reaction.get("_remaining"), captured_duration), "Changing range configuration does not shorten a reaction already in progress")
	var normal_enemy_scene: PackedScene = load("res://scenes/enemy/combat_enemy.tscn")
	var normal_enemy = normal_enemy_scene.instantiate()
	normal_enemy.refills_at_zero = false
	normal_enemy.is_final_enemy = true
	gym.add_child(normal_enemy)
	normal_enemy.configure(original)
	normal_enemy.set_stage_active(true)
	var lethal_hit := HealthEvent.damage(gym.player, normal_enemy, normal_enemy.health.get_maximum() * 2.0, 0, HealthEvent.Delivery.DIRECT, &"")
	normal_enemy.receive_health_event(lethal_hit)
	check(normal_enemy.health.is_zero() and normal_enemy.get("_defeated") and normal_enemy.get("_state") == normal_enemy.State.DEAD, "Ordinary non-refilling Final Enemy still dies at zero health")
	normal_enemy.free()
	refill_enemy.get_node("HitReactionAudio").stop()
	refill_enemy.free()
	gym.ambient_audio.stop()
	gym.music_audio.stop()
	await create_timer(0.15).timeout
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: ", checks, " portal, config, layout and gym headless checks")
	quit(0 if failures.is_empty() else 1)
