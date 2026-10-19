extends SceneTree

var checks := 0
var failures: Array[String] = []
var gym
var enemy: Entity


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: ", description)


func active_pair(player_impact: int, player_poise: int, enemy_impact: int, enemy_poise: int) -> void:
	var cfg: Dictionary = gym.get("_config")
	cfg["player"]["poise"] = player_poise
	cfg["enemy_ai"]["poise"] = enemy_poise
	cfg["moves"]["fire_x1"]["impact"] = player_impact
	cfg["moves"]["final_enemy_attack"]["impact"] = enemy_impact
	check(gym._apply_runtime_tuning()["ok"], "Readout example tuning applies in memory")
	var might: MightComponent = gym.player.get_node("Combat/Might")
	might.reset_for_stage()
	gym.player.hit_reaction.reset_for_stage()
	gym.player.health_resolver.reset_for_stage()
	enemy.hit_reaction.reset_for_stage()
	enemy.health_resolver.reset_for_stage()
	gym.player.health.reset_to_maximum()
	enemy.health.reset_to_maximum()
	might.set_physics_process(false)
	enemy.set_physics_process(false)
	might.try_light_attack(Vector2.RIGHT)
	var animation_player: AnimationPlayer = gym.player.get_node("AnimationPlayer")
	var clock := animation_player.get_animation(animation_player.current_animation)
	animation_player.seek((clock.get_marker_time(&"active_start") + clock.get_marker_time(&"active_end")) / 2.0, true)
	enemy.ai_begin_windup(gym.player, 72.0, 0.6)
	clock = enemy.attack_animation.get_animation(&"melee_swing")
	enemy.attack_animation.seek((clock.get_marker_time(&"active_start") + clock.get_marker_time(&"active_end")) / 2.0, true)


func connected_hit(attacker: Entity, receiver: Entity) -> HealthResult:
	var move := attacker.get_melee_snapshot()
	var event := HealthEvent.damage(attacker, receiver, 10.0, int(move["impact"]), HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT, Vector2.ZERO, int(move["action_id"]))
	event.melee_contact = true
	return receiver.receive_health_event(event)


func _run() -> void:
	root.size = Vector2i(1280, 720)
	var saved_hash := FileAccess.get_sha256("res://config/prototype_combat.json")
	gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	for frame in range(3):
		await process_frame
	enemy = gym.get("_current_area").get_targets()[0]
	var readout = gym.combat_readout
	check(readout != null and readout.get("_last_evaluations").is_empty(), "Gym creates a readout without inventing a hit calculation")
	active_pair(60, 10, 15, 20)
	var result := connected_hit(gym.player, enemy)
	var facts: Dictionary = readout.get("_last_evaluations")["Enemy"]
	check(result.final_reaction_level == 3 and facts["incoming_impact"] == 60 and facts["receiver_poise"] == 20 and facts["active_contribution"] == 15 and facts["value"] == 25 and facts["level"] == result.final_reaction_level, "Enemy card displays actual resolver terms and selected level")
	check(enemy.get_melee_snapshot().is_empty() and facts["receiver_active"] and readout.get("_formulas")["Enemy"].text.contains("60 − 20 − 15 = 25"), "Contact snapshot survives the defender's attack cancellation")
	active_pair(15, 20, 60, 10)
	result = connected_hit(gym.player, enemy)
	var player_facts: Dictionary = readout.get("_last_evaluations")["Player"]
	var enemy_facts: Dictionary = readout.get("_last_evaluations")["Enemy"]
	check(result.outcome == HealthResult.Outcome.CLASH_LOST and player_facts["value"] == 25 and player_facts["active_contribution"] == 15 and player_facts["level"] == 3 and enemy_facts["value"] == -55 and enemy_facts["level"] == 0 and enemy_facts["clash"], "Counter and rejected incoming hit update separate receiving-character cards")
	check(str(player_facts["attacker_move"]) == "final_enemy_attack" and str(enemy_facts["attacker_move"]) == "fire_x1", "Move identities are captured before cancellation")
	var previous_formula: String = readout.get("_formulas")["Player"].text
	result = connected_hit(enemy, gym.player)
	check(result.outcome == HealthResult.Outcome.INVINCIBLE and not readout.get("_last_attempts")["Player"]["calculated"] and readout.get("_formulas")["Player"].text == previous_formula and readout.get("_statuses")["Player"].text.contains("invincible"), "Invincibility rejection shows a status without fabricating new reaction math")
	gym.get("_config")["player"]["poise"] = 50
	readout._process(0.2)
	check(readout.get("_live")["Player"].text.contains("Poise 50") and readout.get("_last_evaluations")["Player"]["receiver_poise"] == 20 and readout.get("_formulas")["Player"].text == previous_formula, "Live stats update while the last-hit snapshot stays frozen")
	active_pair(30, 10, 30, 10)
	connected_hit(gym.player, enemy)
	facts = readout.get("_last_evaluations")["Enemy"]
	check(facts["value"] == -10 and facts["level"] == 0 and readout.get("_formulas")["Enemy"].text.contains("No reaction"), "Non-positive values show no reaction rather than incorrectly mapping to Level 1")
	active_pair(30, 0, 30, 0)
	connected_hit(enemy, gym.player)
	facts = readout.get("_last_evaluations")["Enemy"]
	check(facts["value"] == 0 and facts["level"] == 1 and facts["player_tie"] and readout.get("_statuses")["Enemy"].text.contains("0/0 tie"), "Player-winning zero tie is explicitly explained on the affected card")
	active_pair(60, 10, 15, 20)
	var clock: Animation = enemy.attack_animation.get_animation(&"melee_swing")
	enemy.attack_animation.seek(clock.get_marker_time(&"active_start") - 0.001, true)
	connected_hit(gym.player, enemy)
	facts = readout.get("_last_evaluations")["Enemy"]
	check(facts["receiver_move_impact"] == 15 and not facts["receiver_active"] and facts["active_contribution"] == 0 and facts["value"] == 40, "Windup reports a zero active contribution despite the move's configured Impact")
	gym.hud.set_developer_readout_visible(false)
	check(not readout.get("_panel").is_visible_in_tree(), "Gym formula visibility follows the general developer telemetry group")
	gym.hud.set_developer_readout_visible(true)
	check(readout.get("_panel").is_visible_in_tree(), "Showing the developer telemetry group also restores the gym formula panel")
	gym.pause_menu.set_open(true)
	var paused_formula: String = readout.get("_formulas")["Enemy"].text
	await process_frame
	check(paused and readout.get("_formulas")["Enemy"].text == paused_formula and readout.layer < gym.pause_menu.layer, "Pause keeps captured numbers visible underneath the menu")
	gym.pause_menu.close()
	for frame in range(3):
		await process_frame
	var rect: Rect2 = readout.get("_panel").get_global_rect()
	var clear_of_hud := true
	for path in ["GameUI/HeatPanel", "GameUI/OrbPanel", "GameUI/ObjectiveWidget", "DeveloperReadout/TelemetryPanel", "DeveloperReadout/ComboPanel", "DeveloperReadout/EventPanel", "DeveloperReadout/PressurePanel"]:
		clear_of_hud = clear_of_hud and not rect.intersects(gym.hud.get_node(path).get_global_rect())
	check(clear_of_hud and rect.end.x <= root.size.x and rect.end.y < 560, "Readout layout stays inside the viewport and clear of existing HUD panels")
	var click_through := true
	for control in readout.find_children("*", "Control", true, false):
		click_through = click_through and control.mouse_filter == Control.MOUSE_FILTER_IGNORE
	check(click_through, "Formula display cannot intercept gameplay mouse input")
	var old_enemy_id := enemy.get_instance_id()
	gym._load_stage_from_developer(0)
	for frame in range(3):
		await process_frame
	gym = current_scene
	readout = gym.combat_readout
	enemy = gym.get("_current_area").get_targets()[0]
	check(enemy.get_instance_id() != old_enemy_id and readout.get("_last_evaluations").is_empty() and readout.get("_enemy") == enemy and gym.player.health_resolver.reaction_evaluated.get_connections().size() == 1, "Reset gym clears history and reconnects the new enemy without duplicate Player subscriptions")
	var normal_arena = load("res://scenes/prototype_arena.tscn").instantiate()
	check(normal_arena.get_node_or_null("GymCombatReadout") == null, "Normal arena scene does not gain the gym-specific overlay")
	normal_arena.free()
	check(FileAccess.get_sha256("res://config/prototype_combat.json") == saved_hash, "Readout and example checks never write shared tuning")
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	await create_timer(0.3).timeout
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d gym combat readout checks" % checks)
	quit(0 if failures.is_empty() else 1)
