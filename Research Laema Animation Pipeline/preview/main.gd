extends Node2D

const DURATION := 0.72
const WINDOW_START := 0.126
const SPLIT := 0.21
const WINDOW_END := 0.5075
const PRE_HOLD := 0.24
const POST_HOLD := 0.42
const INK := Color("d9dfda")
const MUTED := Color("94a8b7")
const ACCENTS := [Color("e6ba81"), Color("84c7c9"), Color("c5a9de")]

var proposals: Array = []
var playhead := -PRE_HOLD
var playing := true
var heat := 0
var slow := false
var facing := 1.0
var zoomed := false
var debug_joints := false
var selected := 0
var capture_dir := ""
var capture_index := 0
var capture_frames := 120
var capture_fps := 60.0
var snapshot_path := ""
var status_label: Label
var buttons: Dictionary = {}
var capture_busy := false
var headless := false

func _ready() -> void:
	headless = DisplayServer.get_name() == "headless"
	var path := "res://study-data.json"
	if not FileAccess.file_exists(path):
		path = "res://../study-data.json"
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not data is Dictionary or not data.has("proposals"):
		push_error("Missing or invalid study-data.json")
		get_tree().quit(2)
		return
	proposals = data["proposals"]
	if proposals.size() != 3:
		push_error("Expected exactly three study proposals")
		get_tree().quit(2)
		return
	for proposal in proposals:
		assert(proposal.has("keys") and proposal.keys.size() >= 2)
		assert(float(proposal.keys[0].t) == 0.0)
		assert(absf(float(proposal.keys[-1].t) - DURATION) < 0.00001)
	_build_ui()
	var args := OS.get_cmdline_user_args()
	for i in range(args.size()):
		if args[i] == "--capture-dir" and i + 1 < args.size(): capture_dir = args[i + 1]
		if args[i] == "--capture-frames" and i + 1 < args.size(): capture_frames = int(args[i + 1])
		if args[i] == "--capture-fps" and i + 1 < args.size(): capture_fps = float(args[i + 1])
		if args[i] == "--snapshot" and i + 1 < args.size(): snapshot_path = args[i + 1]
		if args[i] == "--heat100": heat = 100
		if args[i] == "--slow": slow = true
		if args[i] == "--left": facing = -1.0
		if args[i] == "--check":
			_run_data_check()
			get_tree().quit()
	if not capture_dir.is_empty():
		if headless:
			push_error("Rendering capture needs a graphical display; headless check remains available")
			get_tree().quit(3)
			return
		DirAccess.make_dir_recursive_absolute(capture_dir)
		playing = false
	if not snapshot_path.is_empty():
		playhead = 0.17
		playing = false
	_update_ui()
	queue_redraw()

func _run_data_check() -> void:
	var samples := 0
	for proposal in proposals:
		for i in range(73):
			var pose := _sample(proposal, float(i) / 100.0)
			assert(pose.has("hand") and pose.has("sword_tip"))
			assert(absf(pose.hand.distance_to(pose.sword_tip) - 88.0) < 0.01)
			samples += 1
	print("PREVIEW_DATA_CHECK_OK proposals=3 samples=%d fixed_sword_length=88 duration=0.72" % samples)

func _build_ui() -> void:
	var title := Label.new()
	title.text = "LAEMA  /  ORIGINAL MOTION STUDIES"
	title.position = Vector2(36, 24)
	title.add_theme_font_size_override("font_size", 26)
	title.modulate = INK
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Fire X1 • rough silhouettes • contact geometry not adapted • awaiting motion approval"
	subtitle.position = Vector2(36, 63)
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.modulate = MUTED
	add_child(subtitle)
	status_label = Label.new()
	status_label.position = Vector2(36, 101)
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.modulate = INK
	add_child(status_label)
	_button("play", "Pause", 36, 589, 100, func(): playing = not playing)
	_button("replay", "Replay", 144, 589, 100, func(): playhead = -PRE_HOLD; playing = true)
	_button("heat", "Heat 0", 252, 589, 108, func(): heat = 100 if heat == 0 else 0)
	_button("speed", "1× speed", 368, 589, 118, func(): slow = not slow)
	_button("facing", "Face right", 494, 589, 114, func(): facing *= -1.0)
	_button("zoom", "1× scale", 616, 589, 122, func(): zoomed = not zoomed)
	_button("debug", "Joints off", 746, 589, 120, func(): debug_joints = not debug_joints)
	for i in range(3):
		var index := i
		_button("select%d" % i, str(proposals[i].id), 918 + i * 72, 589, 64, func(): selected = index)
	var help := Label.new()
	help.text = "Space pause  •  Enter replay  •  ←/→ step 1/60 s  •  H Heat  •  F facing  •  Z scale  •  1/2/3 focus\nClick the timeline to scrub. Existing contact window shown as timing reference only. No collision or gameplay validation."
	help.position = Vector2(36, 648)
	help.add_theme_font_size_override("font_size", 15)
	help.modulate = MUTED
	add_child(help)

func _button(id: String, caption: String, x: float, y: float, width: float, action: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.position = Vector2(x, y)
	button.size = Vector2(width, 39)
	button.add_theme_font_size_override("font_size", 16)
	button.pressed.connect(func(): action.call(); _update_ui(); queue_redraw())
	add_child(button)
	buttons[id] = button

func _update_ui() -> void:
	var speed := 1.5 if heat == 100 else 1.0
	var phase := "GUARD / ENTRY"
	if playhead >= 0.0:
		phase = "ANTICIPATION"
	if playhead >= WINDOW_START: phase = "EXISTING CONTACT WINDOW"
	if playhead >= SPLIT: phase = "FOLLOW-THROUGH / CONTACT WINDOW"
	if playhead >= WINDOW_END: phase = "RECOVERY"
	if playhead >= DURATION: phase = "GUARD / EXIT"
	status_label.text = "Heat %d  |  %.2f s attack  |  %s  |  t %.3f s" % [heat, DURATION / speed, phase, clampf(playhead, 0.0, DURATION) / speed]
	buttons.play.text = "Pause" if playing else "Play"
	buttons.heat.text = "Heat %d" % heat
	buttons.speed.text = "¼× review" if slow else "1× speed"
	buttons.facing.text = "Face right" if facing > 0 else "Face left"
	buttons.zoom.text = "2× focus" if zoomed else "1× scale"
	buttons.debug.text = "Joints on" if debug_joints else "Joints off"
	for i in range(3): buttons["select%d" % i].modulate = ACCENTS[i] if selected == i else Color.WHITE

func _process(delta: float) -> void:
	if not capture_dir.is_empty():
		if not capture_busy:
			_capture_next()
		return
	if playing:
		playhead += delta * (1.5 if heat == 100 else 1.0) * (0.25 if slow else 1.0)
		if playhead > DURATION + POST_HOLD: playhead = -PRE_HOLD
	_update_ui()
	queue_redraw()
	if not snapshot_path.is_empty() and not capture_busy:
		capture_busy = true
		await RenderingServer.frame_post_draw
		var result := get_viewport().get_texture().get_image().save_png(snapshot_path)
		print("PREVIEW_SNAPSHOT result=%d path=%s" % [result, snapshot_path])
		get_tree().quit(0 if result == OK else 4)

func _capture_next() -> void:
	capture_busy = true
	var speed := (1.5 if heat == 100 else 1.0) * (0.25 if slow else 1.0)
	var cycle := DURATION + PRE_HOLD + POST_HOLD
	playhead = fmod(float(capture_index) / capture_fps * speed, cycle) - PRE_HOLD
	_update_ui()
	queue_redraw()
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(capture_dir.path_join("frame_%05d.png" % capture_index))
	if result != OK:
		push_error("Capture failed")
		get_tree().quit(4)
		return
	capture_index += 1
	capture_busy = false
	if capture_index >= capture_frames:
		print("PREVIEW_CAPTURE_OK frames=%d fps=%.1f heat=%d slow=%s" % [capture_index, capture_fps, heat, str(slow)])
		get_tree().quit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(36, 529, 1208, 38).has_point(event.position):
			playhead = clampf((event.position.x - 36) / 1208.0 * DURATION, 0.0, DURATION)
			playing = false
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE: playing = not playing
			KEY_ENTER: playhead = -PRE_HOLD; playing = true
			KEY_LEFT: playhead = maxf(0.0, playhead - (1.5 if heat == 100 else 1.0) / 60.0); playing = false
			KEY_RIGHT: playhead = minf(DURATION, playhead + (1.5 if heat == 100 else 1.0) / 60.0); playing = false
			KEY_H: heat = 100 if heat == 0 else 0
			KEY_F: facing *= -1.0
			KEY_Z: zoomed = not zoomed
			KEY_J: debug_joints = not debug_joints
			KEY_1: selected = 0
			KEY_2: selected = 1
			KEY_3: selected = 2
	_update_ui()
	queue_redraw()

func _sample(proposal: Dictionary, t: float) -> Dictionary:
	var keys: Array = proposal["keys"]
	var a: Dictionary = keys[0]
	var b: Dictionary = keys[-1]
	for i in range(keys.size() - 1):
		if t >= float(keys[i].t):
			a = keys[i]
			b = keys[i + 1]
		if t <= float(keys[i + 1].t): break
	var fraction := clampf((t - float(a.t)) / maxf(0.000001, float(b.t) - float(a.t)), 0.0, 1.0)
	var mode: String = a.get("mode", "smooth")
	if mode == "hold": fraction = 0.0 if fraction < 1.0 else 1.0
	elif mode == "smooth": fraction = fraction * fraction * (3.0 - 2.0 * fraction)
	var pose := {}
	for point_name in a.points:
		var av := Vector2(float(a.points[point_name][0]), float(a.points[point_name][1]))
		var bv := Vector2(float(b.points.get(point_name, a.points[point_name])[0]), float(b.points.get(point_name, a.points[point_name])[1]))
		pose[point_name] = av.lerp(bv, fraction)
	var hand_a := Vector2(float(a.points.hand[0]), float(a.points.hand[1]))
	var tip_a := Vector2(float(a.points.sword_tip[0]), float(a.points.sword_tip[1]))
	var hand_b := Vector2(float(b.points.hand[0]), float(b.points.hand[1]))
	var tip_b := Vector2(float(b.points.sword_tip[0]), float(b.points.sword_tip[1]))
	var blade_angle := lerp_angle((tip_a - hand_a).angle(), (tip_b - hand_b).angle(), fraction)
	pose.sword_tip = pose.hand + Vector2.from_angle(blade_angle) * 88.0
	return pose

func _draw() -> void:
	if proposals.is_empty(): return
	draw_line(Vector2(36, 139), Vector2(1244, 139), Color("2b3c4b"), 1)
	if zoomed:
		_draw_lane(proposals[selected], Vector2(640, 510), 2.0, selected, true)
	else:
		for i in range(3):
			if i > 0: draw_line(Vector2(426.0 * i, 156), Vector2(426.0 * i, 508), Color("263845"), 1)
			_draw_lane(proposals[i], Vector2(212 + 426 * i, 478), 1.0, i, false)
	_draw_timeline()

func _draw_lane(proposal: Dictionary, origin: Vector2, scale_factor: float, index: int, focus: bool) -> void:
	var font := ThemeDB.fallback_font
	var label_x := 36.0 if focus else 36.0 + 426.0 * index
	draw_string(font, Vector2(label_x, 174), str(proposal.id) + "  " + str(proposal.title), HORIZONTAL_ALIGNMENT_LEFT, -1, 21, ACCENTS[index])
	var text: String = proposal.get("description", "")
	if text.length() > 47: text = text.substr(0, 46) + "…"
	draw_string(font, Vector2(label_x, 200), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MUTED)
	draw_line(origin + Vector2(-165 if not focus else -450, 1), origin + Vector2(165 if not focus else 450, 1), Color("607485"), 1)
	draw_line(origin + Vector2(0, -5), origin + Vector2(0, 5), ACCENTS[index], 1)
	var pose := _sample(proposal, clampf(playhead, 0.0, DURATION))
	var screen := {}
	for key in pose: screen[key] = origin + Vector2(pose[key].x * facing, pose[key].y) * scale_factor
	var width := 13.0 * scale_factor
	# Far limbs and cloak are deliberately low fidelity; no final costume is implied.
	draw_line(screen.hip, screen.knee_b, Color("657888"), width)
	draw_line(screen.knee_b, screen.ankle_b, Color("657888"), width * 0.84)
	draw_line(screen.ankle_b, screen.ankle_b + Vector2(15 * facing, 0) * scale_factor, Color("657888"), width * 0.85)
	var cloak := PackedVector2Array([screen.neck + Vector2(-10 * facing, 6) * scale_factor, screen.hip + Vector2(-26 * facing, 16) * scale_factor, screen.hip + Vector2(10 * facing, 15) * scale_factor])
	draw_colored_polygon(cloak, Color("5d727f"))
	draw_line(screen.hip, screen.knee_a, INK, width)
	draw_line(screen.knee_a, screen.ankle_a, INK, width * 0.84)
	draw_line(screen.ankle_a, screen.ankle_a + Vector2(15 * facing, 0) * scale_factor, INK, width * 0.85)
	var axis: Vector2 = (screen.neck - screen.hip).normalized()
	var normal := axis.orthogonal()
	var torso := PackedVector2Array([screen.neck + normal * 14 * scale_factor, screen.neck - normal * 14 * scale_factor, screen.hip - normal * 13 * scale_factor, screen.hip + normal * 13 * scale_factor])
	draw_colored_polygon(torso, INK)
	draw_line(screen.neck, screen.head, INK, 13 * scale_factor)
	draw_circle(screen.head, 12 * scale_factor, INK)
	draw_colored_polygon(PackedVector2Array([screen.head + Vector2(-8 * facing, -7) * scale_factor, screen.head + Vector2(-24 * facing, 23) * scale_factor, screen.head + Vector2(-8 * facing, 12) * scale_factor]), Color("94a8af"))
	# Shield arm and shield stay visible so the free-side silhouette can be judged.
	draw_line(screen.shoulder, screen.shield, Color("a4b4b8"), 10 * scale_factor)
	var shield_points := PackedVector2Array()
	for i in range(20):
		var angle := TAU * float(i) / 20.0
		shield_points.append(screen.shield + Vector2(cos(angle) * 15, sin(angle) * 23) * scale_factor)
	draw_colored_polygon(shield_points, Color("718b9a"))
	draw_polyline(shield_points, Color("a5b6bc"), 2 * scale_factor)
	# Two-bone IK keeps the sword arm lengths stable between authored key poses.
	var elbow := _arm_elbow(screen.shoulder, screen.hand, screen.elbow, 33.0 * scale_factor)
	draw_line(screen.shoulder, elbow, INK, 10 * scale_factor)
	draw_line(elbow, screen.hand, INK, 9 * scale_factor)
	draw_circle(screen.hand, 5 * scale_factor, ACCENTS[index])
	var direction: Vector2 = (screen.sword_tip - screen.hand).normalized()
	var side := direction.orthogonal()
	var blade := PackedVector2Array([screen.hand + direction * 6 * scale_factor + side * 3 * scale_factor, screen.sword_tip, screen.hand + direction * 6 * scale_factor - side * 3 * scale_factor])
	draw_colored_polygon(blade, ACCENTS[index])
	draw_line(screen.hand + side * 9 * scale_factor, screen.hand - side * 9 * scale_factor, ACCENTS[index], 3 * scale_factor)
	if debug_joints:
		for point in screen.values(): draw_circle(point, 2.5, Color("f67f79"))
		draw_circle(elbow, 3, Color("72f2cb"))
		draw_line(screen.hand, screen.sword_tip, Color("72f2cb"), 1)
	draw_string(font, Vector2(label_x, 505), "FOOT ANCHOR  •  " + ("2× focused view" if focus else "1× ≈ 180 px body"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, MUTED)

func _arm_elbow(shoulder: Vector2, hand: Vector2, hint: Vector2, segment: float) -> Vector2:
	var delta := hand - shoulder
	var distance := minf(delta.length(), segment * 2.0 - 0.001)
	if distance < 0.001: return hint
	var middle := (shoulder + hand) / 2.0
	var height := sqrt(maxf(0.0, segment * segment - distance * distance / 4.0))
	var perpendicular := delta.normalized().orthogonal()
	var candidate_a := middle + perpendicular * height
	var candidate_b := middle - perpendicular * height
	return candidate_a if candidate_a.distance_squared_to(hint) < candidate_b.distance_squared_to(hint) else candidate_b

func _draw_timeline() -> void:
	var y := 543.0
	var x := 36.0
	var w := 1208.0
	var font := ThemeDB.fallback_font
	draw_rect(Rect2(x, y, w, 13), Color("243644"))
	draw_rect(Rect2(x + WINDOW_START / DURATION * w, y, (WINDOW_END - WINDOW_START) / DURATION * w, 13), Color("846f45"))
	for marker in [[0.0,"0"], [WINDOW_START,"contact opens"], [SPLIT,"timing split"], [WINDOW_END,"contact closes"], [DURATION,"return"]]:
		var mx: float = x + float(marker[0]) / DURATION * w
		draw_line(Vector2(mx, y - 6), Vector2(mx, y + 17), MUTED, 1)
		var tx := clampf(mx - 20, 36, 1185)
		draw_string(font, Vector2(tx, y + 34), str(marker[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, MUTED)
	var current := x + clampf(playhead, 0, DURATION) / DURATION * w
	draw_line(Vector2(current, y - 8), Vector2(current, y + 19), Color.WHITE, 2)
