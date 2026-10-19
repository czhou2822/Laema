@tool
extends EditorPlugin
var failures := 0
var checks := 0
func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAILED: " + description)
func _enter_tree() -> void:
	call_deferred("_run")
func _run() -> void:
	for i in range(5):
		await get_tree().process_frame
	# Wait for startup scene/layout restoration before simulating a user click.
	await get_tree().create_timer(1.0).timeout
	var style = load("res://config/attack_styles/fire_x1.tres")
	EditorInterface.edit_resource(style)
	for i in range(5):
		await get_tree().process_frame
	var button: Button
	for item in EditorInterface.get_base_control().find_children("*", "Button", true, false):
		if item.text == "Edit fire_x1 animation & hitbox":
			button = item
			break
	check(button != null, "Move resource displays native animation navigation button")
	if button != null:
		button.pressed.emit()
		for i in range(10):
			await get_tree().process_frame
		var scene = EditorInterface.get_edited_scene_root()
		check(scene != null and scene.scene_file_path == "res://scenes/player/player.tscn", "Actual button opens Player authoring scene")
		if scene != null and scene.has_node("AnimationPlayer"):
			var player = scene.get_node("AnimationPlayer")
			check(player.assigned_animation == &"fire_x1", "Actual button assigns matching native timeline clip")
			check(EditorInterface.get_selection().get_selected_nodes().has(player), "Actual button selects AnimationPlayer")
			check(player.get_animation(&"fire_x1") == style.animation, "Native editor and resource Inspector use the same Animation object")
			player.seek(0.67, true)
			check(scene.get_node("Sprite").texture.resource_path.ends_with("fire_x1.png") and scene.get_node("Sprite").region_rect.position.x > 0, "Native editor seek previews the actual flipbook")
	if failures == 0:
		print("PASSED: %d native editor navigation checks" % checks)
	get_tree().quit(0 if failures == 0 else 1)
