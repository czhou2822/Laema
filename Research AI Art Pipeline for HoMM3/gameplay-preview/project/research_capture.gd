extends SceneTree

var output := "/workspace/homm3-research/gameplay-preview/normalized"
var gym
var enemy
var records: Array = []

func _initialize() -> void:
	call_deferred("run")

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func shot(label: String) -> void:
	for i in range(1):
		await process_frame
		await RenderingServer.frame_post_draw
	var file := output.path_join(label + ".png")
	DirAccess.make_dir_recursive_absolute(file.get_base_dir())
	var err := root.get_texture().get_image().save_png(file)
	records.append({"label": label, "file": file, "save_error": err, "enemy_position": str(enemy.global_position), "sprite_position": str(enemy.body_visual.position), "sprite_offset": str(enemy.body_visual.offset), "sprite_region": str(enemy.body_visual.region_rect), "sprite_scale": str(enemy.body_visual.scale), "texture_size": str(enemy.body_visual.texture.get_size()), "texture_filter": enemy.body_visual.texture_filter, "camera_position": str(gym.get_node("Camera2D").global_position), "camera_zoom": str(gym.get_node("Camera2D").zoom)})
	print("CAPTURE ", label, " ", err)

func use_external(spec: Dictionary) -> bool:
	var file := str(spec["file"])
	if not FileAccess.file_exists(file):
		print("SKIP missing candidate: ", file)
		return false
	var image := Image.load_from_file(file)
	if image == null:
		return false
	image.fix_alpha_edges()
	enemy.body_visual.texture = ImageTexture.create_from_image(image)
	enemy.body_visual.region_enabled = false
	enemy.body_visual.scale = Vector2.ONE * (180.0 / 148.0)
	enemy.body_visual.offset = Vector2(float(spec["offset"][0]), float(spec["offset"][1]))
	return true

func run() -> void:
	root.size = Vector2i(1280, 720)
	if DisplayServer.get_name() == "headless":
		printerr("A renderer is required for actual engine captures")
		quit(1)
		return
	gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await frames(2)
	enemy = gym.get("_current_area").get_targets()[0]
	gym._config["enemy_ai"]["aggro_range"] = 1.0
	gym._config["enemy_ai"]["movement_speed"] = 0.0
	gym._config["enemy_ai"]["attack_range"] = 1.0
	gym._apply_runtime_tuning()
	gym.player.global_position.x = -240
	enemy.global_position.x = 120
	await frames(24)
	gym.get("_developer_overlay")._on_setting_changed(["ui", "developer_overlay_visible"], false)
	var settled := {"player_on_floor": gym.player.is_on_floor(), "enemy_on_floor": enemy.is_on_floor(), "player_position": str(gym.player.global_position), "enemy_position": str(enemy.global_position)}
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	gym.process_mode = Node.PROCESS_MODE_DISABLED
	enemy.attack_animation.play(&"melee_swing")
	enemy.attack_animation.seek(0.5, true)
	enemy.attack_animation.pause()
	enemy.body_visual.flip_h = false
	enemy.warning_marker.hide()
	enemy.attack_flash.hide()
	await shot("current-fullthrust")
	for index in range(10):
		enemy.attack_animation.seek(float(index) * 0.1, true)
		await shot("frames/current/frame_%02d" % index)
	var specfile := "/workspace/homm3-research/gameplay-preview/candidates.json"
	if FileAccess.file_exists(specfile):
		var specs: Array = JSON.parse_string(FileAccess.get_file_as_string(specfile))
		for spec in specs:
			if use_external(spec):
				await shot(str(spec["label"]))
				for index in range(10):
					var frame_spec: Dictionary = spec.duplicate()
					frame_spec["file"] = str(spec["file"]).get_base_dir().path_join("frame_%02d.png" % index)
					if use_external(frame_spec):
						await shot("frames/%s/frame_%02d" % [str(spec["label"]).trim_suffix("-fullthrust"), index])
	var report := {"engine": Engine.get_version_info(), "display_server": DisplayServer.get_name(), "rendering_method": RenderingServer.get_current_rendering_method(), "viewport_size": str(root.size), "settled": settled, "candidate_alpha_edge_fix": true, "source_anchor": [196,268], "candidate_crop_anchor": [92,192], "candidate_offset": [54,-88], "candidate_uniform_scale": 180.0 / 148.0, "sequence_timing_ms": 100, "captures": records, "limits": "Actual Godot renderer and full Gym scene. Private stationary perception/movement fixture; selected facing right; player moved left for space. Candidate textures temporarily bound in memory at original-derived anchor, one uniform scale180/148 to match source ready body148 target pixels to current180 scene units, with Image.fix_alpha_edges matching imported alpha-border-fix setting. Current frame samples native Animation at0.0..0.9; candidates sample source frames0..9. Sequence preview dwell100ms is imposed comparison contract. Staged engine appearance preview, not ordinary combat playtest or human visual acceptance. Engine4.6.3 differs from project's4.7 setting and objective_widget.gd custom_maximum_size raises an error; the top-right objective UI is incomplete. Project copied before import; production assets untouched."}
	var file := FileAccess.open(output.path_join("capture-report.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	current_scene = null
	gym.queue_free()
	await process_frame
	await process_frame
	quit(0)
