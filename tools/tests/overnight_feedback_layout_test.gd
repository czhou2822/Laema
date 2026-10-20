extends "res://tools/tests/overnight_gym_input_test.gd"
## API layout probes are labeled, never gameplay/DoT evidence. Separate real
## InputMap melee/Charging/Cast/incoming HealthResult frames supply combat proof.
var variant := "unspecified"
var output_dir := ""
var capture_enabled := false
var tracked: Array = []
var captures: Array = []
var combat_samples: Array = []

func rect_dict(rect: Rect2) -> Dictionary:
	return {"x": rect.position.x, "y": rect.position.y, "w": rect.size.x, "h": rect.size.y}

func canvas_rect(control: Control) -> Rect2:
	return control.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, control.size)

func label_data(entry: Dictionary) -> Dictionary:
	var label = entry.label
	var data := {"channel": entry.channel, "school": entry.school, "expected_text": entry.text, "created_frame": entry.created_frame, "alive": is_instance_valid(label)}
	if not is_instance_valid(label): return data
	var rect := canvas_rect(label)
	data.merge({"text": label.text, "font_size": label.get_theme_font_size("font_size"), "outline": label.get_theme_constant("outline_size"), "color": label.get_theme_color("font_color").to_html(false), "local_position": str(label.position), "global_position": str(label.global_position), "canvas_rect": rect_dict(rect), "global_scale": str(label.get_global_transform().get_scale()), "alpha": label.modulate.a, "visible": label.is_visible_in_tree()})
	return data

func owner_labels(owner: Node) -> Array:
	return owner.get_children().filter(func(child): return child is Label and child.name != "HealthLabel")

func headers() -> Array:
	var result: Array = []
	for name in ["TelemetryPanel", "ComboPanel", "EventPanel", "PressurePanel"]:
		var panel: Control = gym.hud.developer_readout.get_node(name)
		result.append({"name": name, "visible": panel.is_visible_in_tree(), "rect": rect_dict(canvas_rect(panel))})
	var formula: Control = gym.combat_readout.get("_panel")
	result.append({"name": "FormulaPanel", "visible": formula.is_visible_in_tree(), "rect": rect_dict(canvas_rect(formula))})
	return result

func measure(owner: Entity, entries: Array, label: String, after_draw := false) -> Dictionary:
	var actor_screen := root.get_canvas_transform() * owner.global_position
	var labels: Array = entries.map(func(entry): return label_data(entry))
	var hp_label: Control = owner.get_node_or_null("HealthLabel")
	var status: Control = owner.get_node_or_null("StatusDisplay")
	var bounds: Array = []
	for entry in entries:
		if is_instance_valid(entry.label): bounds.append(canvas_rect(entry.label))
	var overlaps: Array = []
	for i in range(bounds.size()):
		for j in range(i + 1, bounds.size()):
			if bounds[i].intersects(bounds[j]): overlaps.append([i, j])
	var header_hits: Array = []
	var panels := headers()
	for i in range(bounds.size()):
		for panel in panels:
			var r: Dictionary = panel.rect
			if panel.visible and bounds[i].intersects(Rect2(r.x, r.y, r.w, r.h)):
				header_hits.append({"label_index": i, "panel": panel.name})
	var distances: Array = []
	for rect in bounds: distances.append(actor_screen.y - rect.end.y)
	var hp_overlaps: Array = []
	for index in range(bounds.size()):
		if hp_label != null and bounds[index].intersects(canvas_rect(hp_label)): hp_overlaps.append(index)
	return {"label": label, "frame": Engine.get_physics_frames() - start_frame, "measurement": "after actual frame draw" if after_draw else "headless laid-out Control geometry", "owner": owner.name, "actor_world": str(owner.global_position), "actor_screen": str(actor_screen), "actor_scale": str(owner.global_scale), "owner_hp": owner.health.get_current(), "npc_hp_label_rect": rect_dict(canvas_rect(hp_label)) if hp_label != null else null, "npc_hp_rect_overlaps": hp_overlaps, "npc_status_rect": rect_dict(canvas_rect(status)) if status != null else null, "npc_status_visible_children": status.get_children().filter(func(child): return child is CanvasItem and child.is_visible_in_tree()).size() if status != null else 0, "player_hp_location": "HUD telemetry; no actor HealthLabel" if owner == gym.player else "actor HealthLabel", "player_hp_hud_rect": rect_dict(canvas_rect(gym.hud.telemetry_primary)), "player_hp_hud_visible": gym.hud.telemetry_primary.is_visible_in_tree(), "labels": labels, "label_pair_rect_overlaps": overlaps, "header_rect_overlaps": header_hits, "label_bottom_to_actor_origin_y": distances, "headers": panels, "bounds_limit": "Control rectangles exclude glyph outline extents; unchanged scale/clamp behavior"}

func take_sample(owner: Entity, entries: Array, key: String) -> Dictionary:
	if capture_enabled:
		await RenderingServer.frame_post_draw
	var data := measure(owner, entries, key, capture_enabled)
	if capture_enabled:
		var image := root.get_texture().get_image()
		var path := output_dir.path_join("%s_%s_f%04d.png" % [variant, key, int(data.frame)])
		check(image.save_png(path) == OK and not image.is_empty(), "Full real viewport capture: " + key)
		data["png"] = path
		captures.append(data)
	return data

func add_example(owner: Entity, channel: String, school: StringName, value: int) -> Dictionary:
	var previous := owner_labels(owner)
	if channel == "damage": owner.feedback.show_damage(school, value)
	elif channel == "dot": owner.feedback.show_dot_damage(school, value)
	else: owner.feedback.show_cast_level(school, value)
	var added := owner_labels(owner).filter(func(node): return not previous.has(node))
	check(added.size() == 1, "One presentation call creates one label")
	var text := "%s Lv.%d" % [String(school).capitalize(), value] if channel == "cast" else str(value)
	return {"label": added[0], "channel": channel, "school": str(school), "text": text, "created_frame": Engine.get_physics_frames() - start_frame}

func set_private_overlay(visible: bool) -> void:
	# Existing visibility signal synchronizes linked formula panel; no config write.
	gym.hud.developer_readout.visible = visible

func layout_case(role: String, overlay: bool, palette := false) -> void:
	paused = false
	await fresh("layout_only_" + role)
	paused = true # Layout-only temporal setup, without modal covering the labels.
	set_private_overlay(overlay)
	var owner: Entity = gym.player if role == "player" else enemy
	var hp: float = owner.health.get_current()
	tracked = []
	if palette:
		for value in [0, 10]: tracked.append(add_example(owner, "damage", &"fire", value))
		for value in [0, 3]: tracked.append(add_example(owner, "dot", &"water", value))
		for pair in [[&"fire", 1], [&"water", 4], [&"air", 8], [&"earth", 1]]:
			tracked.append(add_example(owner, "cast", pair[0], pair[1]))
	else:
		tracked.append(add_example(owner, "damage", &"fire", 10))
		tracked.append(add_example(owner, "dot", &"fire", 3))
		tracked.append(add_example(owner, "cast", &"fire", 1))
	var before := owner_labels(owner).size()
	owner.feedback.show_cast_level(&"fire", 0)
	check(owner_labels(owner).size() == before, "No spurious Lv0 label")
	await frames(2)
	for entry in tracked:
		var data := label_data(entry)
		check(data.text == entry.text and int(data.font_size) == (18 if entry.channel == "damage" else (12 if entry.channel == "dot" else 16)), "Text and relative prominence unchanged")
		check(data.color == {"fire": "ff493d", "water": "3a96ff", "air": "f4f6ff", "earth": "8b5a2b"}[entry.school] and int(data.outline) == (2 if entry.channel == "dot" else 3), "Existing school colors/outlines remain unchanged")
	check(owner.health.get_current() == hp, "Layout-only API calls do not manufacture health results")
	var key := "layout_only_%s_%s_%s" % [role, "overlay_on" if overlay else "overlay_off", "palette" if palette else "triplet"]
	report["layout_cases"].append(await take_sample(owner, tracked, key))

func lifetime_pause_reset() -> void:
	paused = false
	await fresh("layout_only_lifetime_pause")
	paused = true
	tracked = [add_example(enemy, "damage", &"fire", 10), add_example(enemy, "dot", &"water", 3), add_example(enemy, "cast", &"fire", 4)]
	await frames(2)
	var first := measure(enemy, tracked, "paused_start")
	var local_positions := tracked.map(func(entry): return entry.label.position)
	var duration: float = enemy.feedback.get("_duration")
	await frames(int(ceil(duration * 60.0)) + 3)
	var paused_end := measure(enemy, tracked, "paused_after_duration")
	check(is_instance_valid(tracked[0].label) and is_instance_valid(tracked[1].label), "Owner tweens retain direct/DoT labels during pause")
	check(tracked[0].label.position == local_positions[0] and tracked[1].label.position == local_positions[1], "Pause holds tween positions")
	# Existing SceneTree timer semantics are observed, not changed by this experiment.
	check(not is_instance_valid(tracked[2].label), "Existing Cast-level timer continues during pause")
	paused = false
	await frames(int(ceil(duration * 30.0)))
	var midway := measure(enemy, tracked, "unpaused_mid_lifetime")
	await frames(int(ceil(duration * 30.0)) + 4)
	check(not is_instance_valid(tracked[0].label) and not is_instance_valid(tracked[1].label), "Unpaused tweens expire at existing duration")
	report["lifetime"] = {"duration": duration, "start": first, "paused_end": paused_end, "midway": midway, "note": "layout-only probes; unchanged tween versus process-always timer semantics; no DoT gameplay"}
	var old := add_example(enemy, "damage", &"fire", 10)
	for code in [KEY_ESCAPE, KEY_DOWN, KEY_ENTER]:
		var press := InputEventKey.new()
		press.keycode = code
		press.physical_keycode = code
		press.pressed = true
		Input.parse_input_event(press)
		await frames(1)
		var release := press.duplicate() as InputEventKey
		release.pressed = false
		Input.parse_input_event(release)
	await frames(6)
	gym = current_scene
	enemy = gym.get("_current_area").get_targets()[0]
	check(not paused and not is_instance_valid(old.label) and owner_labels(enemy).is_empty() and owner_labels(gym.player).is_empty(), "Actual Esc/Down/Enter Retry clears owner-linked feedback")
	check(gym.player.health.get_current() == 100.0 and enemy.health.get_current() == 200.0, "Real Retry restores ordinary health; no synthetic health result")
	report["lifetime"]["reset"] = "actual InputMap Esc/Down/Enter pause-menu Retry"

func combat_entries(owner: Entity) -> Array:
	return owner_labels(owner).map(func(label): return {"label": label, "channel": "actual combat feedback", "school": "from real HealthResult/Cast", "text": label.text, "created_frame": -1})

func real_combat(overlay: bool) -> void:
	paused = false
	await fresh("actual_combat_" + ("overlay_on" if overlay else "overlay_off"), 56.0)
	set_private_overlay(overlay)
	input(&"casting", true)
	await frames(1)
	await tap(&"light_attack")
	for frame in range(165):
		if frame == 31: input(&"casting", false)
		await frames(1)
		var now := Engine.get_physics_frames() - start_frame
		if now in [18, 68, 148]:
			var key := "actual_%s" % ("overlay_on" if overlay else "overlay_off")
			combat_samples.append({"sample": await take_sample(enemy, combat_entries(enemy), key + "_npc_" + str(now)), "player_sample": measure(gym.player, combat_entries(gym.player), key + "_player_" + str(now), capture_enabled), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "events": events.duplicate(true), "setup": "ordinary gap56; actual held L2/X/release; no initial resources or synthetic damage"})
	check(count_event("orb_created") == 1 and count_event("cast_committed") == 1 and count_event("cast_launched") == 1, "Actual melee generation and release Cast launch once")
	check(gym.player.health.get_current() < 100.0 and enemy.health.get_current() == 177.0, "Actual incoming strike and empowered projectile produce real feedback")
	report["combat_cases"].append({"overlay": overlay, "events": events.duplicate(true), "phases": phases.duplicate(true), "player_hp": gym.player.health.get_current(), "enemy_hp": enemy.health.get_current(), "orbs": gym.player.magic.get_snapshot().size(), "heat": gym.player.heat.get_value()})

func _run() -> void:
	root.size = Vector2i(1280, 720)
	for argument in OS.get_cmdline_user_args():
		if argument == "--capture": capture_enabled = true
		elif argument.begins_with("--variant="): variant = argument.trim_prefix("--variant=")
		elif argument.begins_with("--output="): output_dir = argument.trim_prefix("--output=")
	if output_dir.is_empty(): output_dir = ProjectSettings.globalize_path("res://feedback-evidence")
	DirAccess.make_dir_recursive_absolute(output_dir)
	if capture_enabled and DisplayServer.get_name() == "headless":
		printerr("FAILED: actual renderer required")
		quit(1)
		return
	report = {"variant": variant, "engine": Engine.get_version_info(), "capture_enabled": capture_enabled, "layout_cases": [], "combat_cases": [], "limitations": "DoT/zero/palette are labeled presentation-only API examples; ordinary Gym has no Fire DoT; no styling/clamp/scale fix"}
	await real_combat(true)
	await real_combat(false)
	for role in ["npc", "player"]:
		await layout_case(role, true)
		await layout_case(role, false)
		if not capture_enabled: await layout_case(role, true, true)
	await lifetime_pause_reset()
	paused = false
	report["combat_samples"] = combat_samples
	report["captures"] = captures
	report["checks"] = checks
	report["failures"] = failures
	var file := FileAccess.open(output_dir.path_join(variant + "-feedback-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "  "))
	file.close()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false): audio.stop()
	OS.delay_msec(100)
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty(): print("PASSED: %d feedback layout/content/lifetime/combat checks (%s)" % [checks, variant])
	else: printerr("FAILED: %d / %d feedback checks" % [failures.size(), checks])
	quit(0 if failures.is_empty() else 1)
