extends CanvasLayer
## Gym-only display of resolver facts; never recalculates combat results.

signal visibility_toggle_requested
const TOGGLE_KEY := KEY_F4

var _player: Entity
var _enemy: Entity
var _panel: PanelContainer
var _live: Dictionary = {}
var _formulas: Dictionary = {}
var _statuses: Dictionary = {}
var _last_evaluations: Dictionary = {}
var _last_attempts: Dictionary = {}
var _elapsed := 0.0


func _ready() -> void:
	layer = 90 # Under the Dev Portal and pause menu.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_panel = PanelContainer.new()
	_panel.name = "FormulaPanel"
	_panel.position = Vector2(20, 124)
	_panel.custom_minimum_size.x = 380
	_panel.size.x = 380
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.075, 0.10, 0.94)
	style.border_color = Color(0.3, 0.38, 0.48)
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 5)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(body)
	body.add_child(_label("GYM / HIT REACTION  [F4]", 16))
	for role in ["Player", "Enemy"]:
		_live[role] = _label(role + ": waiting…", 13)
		body.add_child(_live[role])
	var separator := HSeparator.new()
	separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	body.add_child(separator)
	var legend := _label("Incoming Impact − Poise − active-move Impact", 12)
	legend.modulate.a = 0.8
	body.add_child(legend)
	for role in ["Player", "Enemy"]:
		body.add_child(_label("LAST HIT RECEIVED BY " + role.to_upper(), 12))
		_formulas[role] = _label("Waiting for a connected hit", 14)
		body.add_child(_formulas[role])
		_statuses[role] = _label("", 12)
		body.add_child(_statuses[role])
	var footer := _label("Live stats above. Last contact math stays visible; Reset gym clears it.", 11)
	footer.modulate.a = 0.65
	body.add_child(footer)
	reset_encounter()


func _label(text: String, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func set_readout_visible(shown: bool) -> void:
	_panel.visible = shown
	if shown:
		_refresh_live()


func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo or event.ctrl_pressed or event.alt_pressed or event.meta_pressed or event.shift_pressed:
		return
	if event.keycode != TOGGLE_KEY and event.physical_keycode != TOGGLE_KEY:
		return
	var focus := get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit:
		return
	visibility_toggle_requested.emit()
	get_viewport().set_input_as_handled()


func bind_combatants(player: Entity, enemy: Entity) -> void:
	_player = player
	_enemy = enemy
	reset_encounter()
	_refresh_live()


func reset_encounter() -> void:
	_last_evaluations.clear()
	_last_attempts.clear()
	for role in _formulas:
		_formulas[role].text = "Waiting for a connected hit"
		_formulas[role].modulate = Color(0.75, 0.78, 0.82)
		_statuses[role].text = ""


func consume_reaction(snapshot: Dictionary) -> void:
	var role := ""
	if is_instance_valid(_player) and snapshot.get("receiver_id") == _player.get_instance_id():
		role = "Player"
	elif is_instance_valid(_enemy) and snapshot.get("receiver_id") == _enemy.get_instance_id():
		role = "Enemy"
	if role.is_empty():
		return # Ignore retired encounter actors.
	_last_attempts[role] = snapshot.duplicate(true)
	var outcome: String = snapshot["outcome"]
	if not snapshot.get("calculated", false):
		_statuses[role].text = "Latest: %s. No new formula calculated." % _outcome_text(outcome)
		return
	_last_evaluations[role] = snapshot.duplicate(true)
	var level: int = snapshot["level"]
	_formulas[role].text = "%d − %d − %d = %d → %s" % [snapshot["incoming_impact"], snapshot["receiver_poise"], snapshot["active_contribution"], snapshot["value"], "Level %d" % level if level > 0 else "No reaction"]
	_formulas[role].modulate = Color("ffd581") if level > 0 else Color(0.8, 0.83, 0.88)
	var attacker := "Player" if is_instance_valid(_player) and snapshot["attacker_id"] == _player.get_instance_id() else "Enemy"
	_statuses[role].text = "%s %s · %s" % [attacker, _move_name(snapshot["attacker_move"]), _outcome_text(outcome)]
	if snapshot.get("player_tie", false):
		_statuses[role].text += " · Player wins 0/0 tie"
	elif not snapshot.get("receiver_active", false):
		_statuses[role].text += " · active contribution 0"


func _process(delta: float) -> void:
	if not _panel.visible:
		return
	_elapsed += delta
	if _elapsed >= 0.1:
		_elapsed = 0.0
		_refresh_live()


func _refresh_live() -> void:
	for role in ["Player", "Enemy"]:
		var actor: Entity = _player if role == "Player" else _enemy
		if not is_instance_valid(actor):
			_live[role].text = role + ": waiting…"
			continue
		var move := actor.get_melee_snapshot()
		_live[role].text = "%s: %s · Impact %s · Poise %d" % [role, _move_name(str(move.get("move_id", "No melee move"))), str(move["impact"]) if move.has("impact") else "—", actor.get_poise()]
		if not move.is_empty():
			_live[role].text += " [" + ("active" if move.get("active", false) else "inactive") + "]"


func _move_name(id: String) -> String:
	return "Strike" if id == "final_enemy_attack" else id.replace("_", " ").capitalize()


func _outcome_text(outcome: String) -> String:
	match outcome:
		"APPLIED": return "hit applied"
		"CLASH_LOST": return "incoming attack lost clash"
		"INVINCIBLE": return "ignored (invincible)"
		"BLOCKED": return "blocked (legacy reaction)"
		"PARRIED": return "parried"
		"CANCELLED": return "cancelled attack"
		"REACTION ONLY": return "reaction; damage already counted"
	return outcome.to_lower()
