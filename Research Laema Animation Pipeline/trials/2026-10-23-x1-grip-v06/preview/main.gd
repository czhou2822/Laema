extends Node2D

const LABELS := ["Current game / user preferred", "v05 / wrist still rejected", "v06 / ONE-key grip proof"]
const FILES := ["current-game-x1.png", "x1-opening-v05.png", "x1-grip-proof-v06.png"]
const DURATIONS := [0.72,0.72,0.72]
const COLUMNS := [8,8,8]
const COLORS := [Color("e6ba81"), Color("84c7c9"), Color("c5a9de")]
var textures: Array[Texture2D] = []
var clocks: Array = []
var metrics: Dictionary = {}
var t := -0.24
var playing := true
var heat := 0
var facing := 1.0
var slow := false
var zoom := false
var selected := 0
var snapshot := ""
var capture_dir := ""
var capture_frames := 90
var capture_index := 0
var busy := false

func _ready() -> void:
	var output := ProjectSettings.globalize_path("res://").path_join("../outputs").simplify_path()
	metrics = JSON.parse_string(FileAccess.get_file_as_string(output.path_join("clips.json")))
	for file in FILES:
		var img := Image.load_from_file(output.path_join(file))
		if img == null or img.is_empty():
			push_error("Missing trial texture " + file)
			get_tree().quit(2)
			return
		textures.append(ImageTexture.create_from_image(img))
	clocks = [metrics.clips[0].times,metrics.clips[1].times,metrics.clips[2].times]
	var args := OS.get_cmdline_user_args()
	for i in range(args.size()):
		if args[i] == "--heat100": heat = 100
		if args[i] == "--left": facing = -1.0
		if args[i] == "--snapshot" and i+1 < args.size(): snapshot = args[i+1]; playing = false; t = 0.1
		if args[i] == "--at" and i+1 < args.size(): t = float(args[i+1])
		if args[i] == "--capture-dir" and i+1 < args.size(): capture_dir = args[i+1]; playing = false
		if args[i] == "--capture-frames" and i+1 < args.size(): capture_frames = int(args[i+1])
	if not capture_dir.is_empty(): DirAccess.make_dir_recursive_absolute(capture_dir)
	print("TRIAL_ASSETS_LOADED GAME_X1=%d PREVIOUS=%d GRIP_PROOF_V06=%d; rendering only, no combat simulation" % [clocks[0].size(),clocks[1].size(),clocks[2].size()])
	queue_redraw()

func _process(delta: float) -> void:
	if not capture_dir.is_empty():
		if capture_index < capture_frames and not busy: _capture()
		return
	if playing:
		t += delta * (1.5 if heat == 100 else 1.0) * (0.25 if slow else 1.0)
		if t > 1.14: t = -0.24
	queue_redraw()
	if not snapshot.is_empty() and not busy:
		busy = true
		await RenderingServer.frame_post_draw
		var result := get_viewport().get_texture().get_image().save_png(snapshot)
		print("TRIAL_SNAPSHOT result=%d" % result)
		get_tree().quit(0 if result == OK else 4)

func _capture() -> void:
	busy = true
	t = fmod(float(capture_index)/60.0*(1.5 if heat == 100 else 1.0),1.38)-0.24
	queue_redraw()
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(capture_dir.path_join("frame_%05d.png" % capture_index))
	if result != OK:
		get_tree().quit(4)
		return
	capture_index += 1
	if capture_index == capture_frames:
		print("TRIAL_CAPTURE_OK frames=%d heat=%d facing=%s" % [capture_index,heat,str(facing)])
		get_tree().quit()
	else: busy = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Rect2(36,541,1208,30).has_point(event.position):
			t = clampf((event.position.x-36)/1208*0.72,0,.72); playing = false
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_SPACE: playing = not playing
			KEY_ENTER: t = -0.24; playing = true
			KEY_H: heat = 100 if heat == 0 else 0
			KEY_F: facing *= -1
			KEY_S: slow = not slow
			KEY_Z: zoom = not zoom
			KEY_1: selected = 0
			KEY_2: selected = 1
			KEY_3: selected = 2
			KEY_LEFT: t = maxf(0,t-(1.5 if heat == 100 else 1.0)/60); playing = false
			KEY_RIGHT: t = minf(0.72,t+(1.5 if heat == 100 else 1.0)/60); playing = false
	queue_redraw()

func _draw() -> void:
	if textures.size() != 3: return
	var font := ThemeDB.fallback_font
	var ink := Color("e2e9ed")
	var muted := Color("9baebd")
	draw_string(font,Vector2(36,46),"LAEMA / ONE-KEY WRIST + GRIP PROOF",HORIZONTAL_ALIGNMENT_LEFT,-1,24,ink)
	draw_string(font,Vector2(36,80),"Only key7 locally repaired; source blade angle and other keys unchanged | .720s action",HORIZONTAL_ALIGNMENT_LEFT,-1,16,muted)
	draw_string(font,Vector2(36,114),"Heat %d | X1 %.3fs | t %.3fs | %s | unchanged gameplay contract" % [heat,.72/(1.5 if heat == 100 else 1.0),clampf(t,0,0.72)/(1.5 if heat == 100 else 1.0),"quarter speed" if slow else "normal speed"],HORIZONTAL_ALIGNMENT_LEFT,-1,17,ink)
	if zoom: _lane(selected,640,2.0)
	else:
		for i in range(3): _lane(i,212+426*i,1.0)
	var progress := clampf(t,0,0.72)/0.72
	draw_rect(Rect2(36,547,1208,12),Color("293b49"))
	draw_rect(Rect2(36+.126/0.72*1208,547,(.5075-.126)/0.72*1208,12),Color("7d6844"))
	draw_line(Vector2(36+progress*1208,539),Vector2(36+progress*1208,566),ink,2)
	draw_string(font,Vector2(36,596),"Space play/pause | Enter replay | arrows step | H Heat | F mirror | S slow | Z 2x | 1/2/3 focus",HORIZONTAL_ALIGNMENT_LEFT,-1,16,muted)
	draw_string(font,Vector2(36,628),"Gold=X1 active time only. No contact curves changed. Review holds outside the action.",HORIZONTAL_ALIGNMENT_LEFT,-1,15,muted)
	draw_string(font,Vector2(36,666),"One local RGB grip test only. No whole-strip correction, visual acceptance or integrated combat claim.",HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("d9b881"))

func _lane(i: int, x: float, scale_factor: float) -> void:
	var font := ThemeDB.fallback_font
	var phase := clampf(t,0,float(DURATIONS[i]))
	var idx := 0
	for j in range(clocks[i].size()):
		if float(clocks[i][j]) <= phase+.00000001: idx = j
	var cols: int = COLUMNS[i]
	var left := 36.0 if zoom else 36.0+426*i
	draw_string(font,Vector2(left,170),LABELS[i],HORIZONTAL_ALIGNMENT_LEFT,-1,17,COLORS[i])
	draw_string(font,Vector2(left,199),"frame %d / %d" % [idx+1,clocks[i].size()],HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("99aebe"))
	draw_line(Vector2(x-165*scale_factor,480),Vector2(x+165*scale_factor,480),Color("647b8d"),1)
	draw_set_transform(Vector2(x,480),0,Vector2(facing*scale_factor,scale_factor))
	draw_texture_rect_region(textures[i],Rect2(-224,-400,448,448),Rect2((idx%cols)*448,(idx/cols)*448,448,448))
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
