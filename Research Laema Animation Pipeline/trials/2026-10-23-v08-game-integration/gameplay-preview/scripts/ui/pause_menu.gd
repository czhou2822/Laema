extends CanvasLayer

signal opening_requested
signal restart_requested

@onready var overlay: Control = $Overlay
@onready var resume_button: Button = $Overlay/Center/Panel/Margin/Content/Resume
@onready var restart_button: Button = $Overlay/Center/Panel/Margin/Content/Restart

var _can_restart: Callable


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 110
	overlay.hide()
	resume_button.pressed.connect(close)
	restart_button.pressed.connect(_request_restart)


func configure(can_restart: Callable, restart_text: String = "Restart encounter") -> void:
	_can_restart = can_restart
	restart_button.text = restart_text
	_update_restart()


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed(&"pause"):
		set_open(not is_open())
		get_viewport().set_input_as_handled()
	elif is_open() and event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func is_open() -> bool:
	return is_instance_valid(overlay) and overlay.visible


func set_open(open: bool) -> void:
	if open == is_open():
		return
	if open:
		# Let the owner close another modal before taking over pause state.
		opening_requested.emit()
		overlay.show()
		get_tree().paused = true
		_update_restart()
		resume_button.grab_focus()
	else:
		overlay.hide()
		get_tree().paused = false


func close() -> void:
	set_open(false)


func _request_restart() -> void:
	if _can_restart.is_valid() and bool(_can_restart.call()):
		restart_requested.emit()


func _process(_delta: float) -> void:
	if is_open():
		_update_restart()


func _update_restart() -> void:
	restart_button.disabled = not _can_restart.is_valid() or not bool(_can_restart.call())


func _exit_tree() -> void:
	if is_open() and get_tree() != null:
		get_tree().paused = false
