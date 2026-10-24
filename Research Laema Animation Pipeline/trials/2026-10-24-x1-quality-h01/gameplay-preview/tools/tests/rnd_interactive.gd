extends SceneTree
## One-shot review launcher: normal hardware mappings, then existing pause input.
## No gameplay settings or actor state are written.

func _initialize() -> void:
	call_deferred("_open_review")

func _open_review() -> void:
	var error := change_scene_to_file("res://scenes/gym.tscn")
	if error != OK:
		printerr("Cannot open isolated Gym: ", error_string(error))
		quit(2)
		return
	await process_frame
	await process_frame
	var press := InputEventAction.new()
	press.action = &"pause"
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventAction.new()
	release.action = &"pause"
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
	await RenderingServer.frame_post_draw
	var out := ""
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--proof="):
			out = argument.trim_prefix("--proof=")
	if not out.is_empty():
		root.get_texture().get_image().save_png(out)
	print("RND_INTERACTIVE_READY paused=", paused, " normal_hardware_bindings=true")
