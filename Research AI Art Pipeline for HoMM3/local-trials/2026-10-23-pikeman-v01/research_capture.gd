extends SceneTree

var output: String
var spec_path: String
var gym
var enemy
var records: Array = []

func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			output = arg.trim_prefix("--out=")
		if arg.begins_with("--spec="):
			spec_path = arg.trim_prefix("--spec=")
	call_deferred("run")

func frames(count: int) -> void:
	for i in range(count):
		await physics_frame
		await process_frame

func shot(label: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var path := output.path_join(label + ".png")
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var image := root.get_texture().get_image()
	var error := image.save_png(path)
	records.append({"label":label,"file":path,"save_error":error,"size":str(image.get_size()),"enemy_position":str(enemy.global_position),"sprite_position":str(enemy.body_visual.position),"sprite_offset":str(enemy.body_visual.offset),"sprite_scale":str(enemy.body_visual.scale),"texture_filter":enemy.body_visual.texture_filter,"camera_position":str(gym.get_node("Camera2D").global_position),"camera_zoom":str(gym.get_node("Camera2D").zoom)})
	print("CAPTURE ",label," ",error)

func use_external(file: String) -> bool:
	if not FileAccess.file_exists(file):
		printerr("Missing candidate: ",file)
		return false
	var image := Image.load_from_file(file)
	if image == null:
		return false
	image.fix_alpha_edges()
	enemy.body_visual.texture = ImageTexture.create_from_image(image)
	enemy.body_visual.region_enabled = false
	enemy.body_visual.scale = Vector2.ONE * (180.0 / 148.0)
	enemy.body_visual.offset = Vector2(54,-88)
	return true

func run() -> void:
	if output.is_empty() or spec_path.is_empty() or DisplayServer.get_name() == "headless":
		printerr("Explicit output/spec and an actual renderer are required")
		quit(2)
		return
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_NO_FOCUS,true)
	root.size = Vector2i(1280,720)
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
	gym.get("_developer_overlay")._on_setting_changed(["ui","developer_overlay_visible"],false)
	var settled := {"player_on_floor":gym.player.is_on_floor(),"enemy_on_floor":enemy.is_on_floor(),"player_position":str(gym.player.global_position),"enemy_position":str(enemy.global_position)}
	gym.process_mode = Node.PROCESS_MODE_DISABLED
	enemy.attack_animation.play(&"melee_swing")
	enemy.attack_animation.seek(0.5,true)
	enemy.attack_animation.pause()
	enemy.body_visual.flip_h = false
	enemy.warning_marker.hide()
	enemy.attack_flash.hide()
	for index in range(10):
		enemy.attack_animation.seek(float(index)*0.1,true)
		await shot("current/frame_%02d" % index)
	var specs: Array = JSON.parse_string(FileAccess.get_file_as_string(spec_path))
	for spec in specs:
		for index in spec.get("frames",range(10)):
			var file := str(spec["pattern"]).replace("{frame}","%02d" % int(index))
			if use_external(file):
				await shot(str(spec["label"]) + "/frame_%02d" % int(index))
	var report := {"engine":Engine.get_version_info(),"display_server":DisplayServer.get_name(),"rendering_method":RenderingServer.get_current_rendering_method(),"viewport_size":str(root.size),"settled":settled,"source_anchor_native":[196,268],"crop_anchor":[92,192],"candidate_offset":[54,-88],"candidate_scale":180.0/148.0,"captures":records,"limits":"Actual local GPU staged Gym renderer, isolated project copy. Stationary frozen fixture; right facing only. Not ordinary input/combat playtest, both-facing/contact validation, original timing recovery or user art acceptance. Playback100ms remains provisional."}
	var f := FileAccess.open(output.path_join("capture-report.json"),FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"\t"))
	f.close()
	current_scene = null
	gym.queue_free()
	await process_frame
	quit(0)
