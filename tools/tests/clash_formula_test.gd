extends SceneTree

const Loader = preload("res://scripts/config/prototype_config_loader.gd")
const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
var config: Dictionary
var checks := 0
var failures: Array[String] = []

class StatusStub:
	extends Node
	func resolve_elemental_endurance(_event: HealthEvent) -> Dictionary:
		return {"multiplier": 1.0, "full_resist": false}

class Fighter:
	extends Entity
	var poise := 0
	var player := false
	var snapshot: Dictionary = {}
	var cancellations := 0
	var winning_contacts := 0
	func uses_combat_hit_reaction() -> bool:
		return true
	func get_poise() -> int:
		return poise
	func is_player_combatant() -> bool:
		return player
	func get_melee_snapshot() -> Dictionary:
		return snapshot.duplicate(true)
	func cancel_combat_attack() -> void:
		cancellations += 1
		snapshot.clear()
	func on_clash_contact_resolved(result: HealthResult) -> void:
		if result.outcome == HealthResult.Outcome.APPLIED:
			winning_contacts += 1
			snapshot["hit_targets"].append(result.event.target.get_instance_id())


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: ", description)


func fighter(impact: int, poise: int, player: bool) -> Fighter:
	var actor := Fighter.new()
	actor.name = "PlayerProbe" if player else "EnemyProbe"
	actor.poise = poise
	actor.player = player
	actor.snapshot = {"active": true, "impact": impact, "damage": 10.0, "school": &"fire", "action_id": 1, "composition": [&"fire"], "hit_targets": []}
	for component in [HealthComponent.new(), HealthResolver.new(), StatusStub.new(), HitReaction.new(), FeedbackComponent.new()]:
		component.name = ["Health", "HealthResolver", "Status", "HitReaction", "Feedback"][actor.get_child_count()]
		actor.add_child(component)
	root.add_child(actor)
	actor.health.configure(100.0)
	actor.hit_reaction.configure(config["hit_reaction"])
	actor.health_resolver.configure(actor, actor.health, actor.status_controller, actor.hit_reaction)
	return actor


func hit(attacker: Fighter, receiver: Fighter, melee: bool = true) -> HealthResult:
	var event := HealthEvent.damage(attacker, receiver, 10.0, int(attacker.snapshot["impact"]), HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT, Vector2.ZERO, 1)
	event.melee_contact = melee
	return receiver.receive_health_event(event)


func _run() -> void:
	config = Loader.load_and_validate("res://config/prototype_combat.json")["data"]
	var saved_hash := FileAccess.get_sha256("res://config/prototype_combat.json")
	for already_hit in [false, true]:
		var scaled_player := fighter(15, 20, true)
		var scaled_enemy := fighter(60, 0, false)
		scaled_enemy.snapshot["push_scale"] = 2.0
		if already_hit:
			scaled_enemy.snapshot["hit_targets"].append(scaled_player.get_instance_id())
		var scaled_result := hit(scaled_player, scaled_enemy)
		var scaled_level := scaled_player.hit_reaction.level_for_value(25)
		var scaled_tuning: Dictionary = config["hit_reaction"]["combat_levels"][scaled_level - 1]
		var motion := scaled_player.hit_reaction.consume_body_motion(float(scaled_tuning["duration"]))
		check(scaled_result.outcome == HealthResult.Outcome.CLASH_LOST and is_equal_approx(absf(motion.x), 2.0 * float(scaled_tuning["distance"])), "Winning counter retains its push scale, including reaction-only resolution: %s" % already_hit)
		check(scaled_player.health.get_current() == (100.0 if already_hit else 90.0), "Scaled counter preserves damage deduplication: %s" % already_hit)
		scaled_player.free()
		scaled_enemy.free()
	var transaction_source := fighter(20, 0, true)
	var transaction_receiver := fighter(0, 0, false)
	transaction_receiver.begin_hit_transaction()
	var first_push := HealthEvent.damage(transaction_source, transaction_receiver, 1.0, 1, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT)
	first_push.push_scale = 2.0
	transaction_receiver.receive_health_event(first_push)
	var strongest_push := HealthEvent.damage(transaction_source, transaction_receiver, 1.0, 20, HealthEvent.Delivery.DIRECT, &"water", {}, Vector2.RIGHT)
	strongest_push.push_scale = 3.0
	transaction_receiver.receive_health_event(strongest_push)
	check(not transaction_receiver.hit_reaction.is_invincible(), "Mixed transaction defers reaction until all layers resolve")
	transaction_receiver.end_hit_transaction()
	var transaction_tuning: Dictionary = config["hit_reaction"]["combat_levels"][transaction_receiver.hit_reaction.level_for_value(20) - 1]
	check(is_equal_approx(transaction_receiver.hit_reaction.consume_body_motion(float(transaction_tuning["duration"])).x, 3.0 * float(transaction_tuning["distance"])), "Deferred reaction retains the selected strongest layer's push scale")
	transaction_source.free()
	transaction_receiver.free()
	for attacker_poise in [0, 50, 100]:
		var player := fighter(60, attacker_poise, true)
		var enemy := fighter(15, 20, false)
		var result := hit(player, enemy)
		check(result.outcome == HealthResult.Outcome.APPLIED and result.event.reaction_difference == 25 and result.final_reaction_level == enemy.hit_reaction.level_for_value(25), "Attacker Poise %d never adds to outgoing Impact" % attacker_poise)
		check(enemy.cancellations > 0 and enemy.health.get_current() == 90 and player.health.get_current() == 100 and not player.hit_reaction.is_active(), "Positive incoming value interrupts only its receiver")
		var repeated := hit(player, enemy)
		check(repeated.outcome == HealthResult.Outcome.INVINCIBLE and enemy.health.get_current() == 90, "Reaction invincibility rejects repeated damage")
		player.free()
		enemy.free()
	for counter_attacker_poise in [0, 100]:
		var player := fighter(15, 20, true)
		var enemy := fighter(60, counter_attacker_poise, false)
		var result := hit(player, enemy)
		check(result.outcome == HealthResult.Outcome.CLASH_LOST and player.health.get_current() == 90 and enemy.health.get_current() == 100, "Counter wins using its receiver's defence, not counterattacker Poise")
		check(player.cancellations > 0 and enemy.winning_contacts == 1 and is_equal_approx(player.hit_reaction.get("_remaining"), float(config["hit_reaction"]["combat_levels"][player.hit_reaction.level_for_value(25) - 1]["duration"])), "Counter reaction uses 60 − 20 − 15 = 25")
		player.free()
		enemy.free()
	for player_first in [true, false]:
		var player := fighter(30, 10, true)
		var enemy := fighter(30, 10, false)
		var first := hit(player, enemy) if player_first else hit(enemy, player)
		check(first.outcome == HealthResult.Outcome.APPLIED and first.event.reaction_difference == -10 and first.final_reaction_level == 0 and player.cancellations == 0 and enemy.cancellations == 0, "−10/−10 clash applies first connected damage without cancelling either move")
		check((player.health.get_current() == 100 and enemy.health.get_current() == 90) if player_first else (player.health.get_current() == 90 and enemy.health.get_current() == 100), "Inconclusive clash does not invent a reverse hit without contact")
		var second := hit(enemy, player) if player_first else hit(player, enemy)
		check(second.outcome == HealthResult.Outcome.APPLIED and player.health.get_current() == 90 and enemy.health.get_current() == 90 and not player.hit_reaction.is_active() and not enemy.hit_reaction.is_active(), "Both physically connected hits damage without flinching")
		player.free()
		enemy.free()
	for player_first in [true, false]:
		var player := fighter(30, 0, true)
		var enemy := fighter(30, 0, false)
		var result := hit(player, enemy) if player_first else hit(enemy, player)
		check(result.outcome == (HealthResult.Outcome.APPLIED if player_first else HealthResult.Outcome.CLASH_LOST) and enemy.health.get_current() == 90 and player.health.get_current() == 100 and enemy.hit_reaction.is_invincible() and not player.hit_reaction.is_active(), "Exact 0/0 clash favors Player regardless of which contact resolves first")
		check(enemy.hit_reaction.level_for_value(0) == 1 and is_equal_approx(enemy.hit_reaction.get("_remaining"), float(config["hit_reaction"]["combat_levels"][0]["duration"])), "0/0 tie produces configured Level 1 reaction")
		player.free()
		enemy.free()
	# A single zero is not the selected 0/0 exception.
	var player := fighter(60, 10, true)
	var enemy := fighter(40, 20, false)
	var zero_result := hit(player, enemy)
	check(zero_result.event.reaction_difference == 0 and zero_result.final_reaction_level == 0 and not enemy.hit_reaction.is_active() and enemy.health.get_current() == 90, "0/negative clash causes damage without granting the 0/0 tie exception")
	player.free()
	enemy.free()
	for phase in ["windup", "recovery", "idle"]:
		player = fighter(60, 100, true)
		enemy = fighter(15, 20, false)
		enemy.snapshot["active"] = false
		if phase == "idle":
			enemy.snapshot.clear()
		var result := hit(player, enemy)
		check(result.event.reaction_difference == 40 and result.final_reaction_level == enemy.hit_reaction.level_for_value(40), "Receiver's %s adds no move Impact: 60 − 20 = 40" % phase)
		player.free()
		enemy.free()
	player = fighter(20, 0, true)
	enemy = fighter(30, 20, false)
	enemy.snapshot["active"] = false
	var no_clash_tie := hit(player, enemy)
	check(no_clash_tie.event.reaction_difference == 0 and no_clash_tie.final_reaction_level == 0 and enemy.health.get_current() == 90, "Zero outside active clashes never grants the Player tie exception")
	player.free()
	enemy.free()
	# Already-hit winning move can interrupt but must not apply duplicate damage.
	player = fighter(15, 20, true)
	enemy = fighter(60, 100, false)
	enemy.snapshot["hit_targets"] = [player.get_instance_id()]
	var duplicate := hit(player, enemy)
	check(duplicate.outcome == HealthResult.Outcome.CLASH_LOST and player.health.get_current() == 100 and enemy.winning_contacts == 0 and player.hit_reaction.is_invincible(), "Previously resolved counter never deals duplicate damage")
	player.free()
	enemy.free()
	player = fighter(60, 0, true)
	enemy = fighter(15, 20, false)
	var stale := HealthEvent.damage(player, enemy, 10, 60, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT, Vector2.ZERO, 999)
	stale.melee_contact = true
	check(enemy.receive_health_event(stale).outcome == HealthResult.Outcome.CANCELLED and enemy.health.get_current() == 100, "Stale cancelled action cannot deal damage")
	var invalid := HealthEvent.damage(player, enemy, 10, 101, HealthEvent.Delivery.DIRECT, &"fire")
	check(enemy.receive_health_event(invalid).outcome == HealthResult.Outcome.INVALID and enemy.health.get_current() == 100, "Runtime rejects Attack Impact above the agreed range")
	player.free()
	enemy.free()
	for path in [["player", "poise"], ["enemy_ai", "poise"], ["moves", "fire_x5", "impact"]]:
		for value in [-1, 101, 1.5]:
			var candidate := config.duplicate(true)
			var current: Dictionary = candidate
			for key in path.slice(0, -1):
				current = current[key]
			current[path[-1]] = value
			check(not Loader.validate(candidate)["ok"], "Config rejects %s = %s" % [str(path), value])
		for value in [0, 100]:
			var candidate := config.duplicate(true)
			var current: Dictionary = candidate
			for key in path.slice(0, -1):
				current = current[key]
			current[path[-1]] = value
			check(Loader.validate(candidate)["ok"], "Agreed range boundary %s = %s remains editable" % [str(path), value])
	# Inspect the real Final Enemy animation clock, not just synthetic phase flags.
	root.size = Vector2i(1280, 720)
	var gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	await process_frame
	await process_frame
	var real_enemy = gym.get("_current_area").get_targets()[0]
	real_enemy.set_physics_process(false)
	gym.get("_config")["enemy_ai"]["poise"] = 20
	gym.get("_config")["moves"]["final_enemy_attack"]["impact"] = 15
	check(gym._apply_runtime_tuning()["ok"], "Real scene accepts in-memory example tuning")
	real_enemy.ai_begin_windup(gym.player, 72.0, 0.6)
	var clock: Animation = real_enemy.attack_animation.get_animation(&"melee_swing")
	real_enemy.attack_animation.seek(clock.get_marker_time(&"active_start") - 0.001, true)
	check(HealthResolver.calculate_reaction_value(60, real_enemy.get_poise(), real_enemy.get_melee_snapshot()) == 40, "Real Enemy windup contributes no move Impact")
	real_enemy.attack_animation.seek((clock.get_marker_time(&"active_start") + clock.get_marker_time(&"active_end")) / 2.0, true)
	check(HealthResolver.calculate_reaction_value(60, real_enemy.get_poise(), real_enemy.get_melee_snapshot()) == 25, "Real Enemy active interval contributes exactly its move Impact")
	real_enemy.ai_begin_recovery()
	check(HealthResolver.calculate_reaction_value(60, real_enemy.get_poise(), real_enemy.get_melee_snapshot()) == 40, "Real Enemy recovery contributes no move Impact")
	var real_might: MightComponent = gym.player.get_node("Combat/Might")
	real_might.set_physics_process(false)
	gym.get("_config")["player"]["poise"] = 20
	gym.get("_config")["moves"]["fire_x1"]["impact"] = 15
	real_might.try_light_attack(Vector2.RIGHT)
	var player_clock: AnimationPlayer = gym.player.get_node("AnimationPlayer")
	var player_animation := player_clock.get_animation(player_clock.current_animation)
	player_clock.seek(player_animation.get_marker_time(&"active_start") - 0.001, true)
	check(HealthResolver.calculate_reaction_value(60, gym.player.get_poise(), gym.player.get_melee_snapshot()) == 40, "Real Player startup contributes no move Impact")
	player_clock.seek((player_animation.get_marker_time(&"active_start") + player_animation.get_marker_time(&"active_end")) / 2.0, true)
	check(HealthResolver.calculate_reaction_value(60, gym.player.get_poise(), gym.player.get_melee_snapshot()) == 25, "Real Player active interval uses the same receiver-side formula")
	real_might.reset_for_stage()
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	# Release Dummy-driver attack playbacks before freeing their streams.
	await create_timer(0.3).timeout
	gym.free()
	await process_frame
	check(FileAccess.get_sha256("res://config/prototype_combat.json") == saved_hash, "Clash checks preserve saved tuning")
	if failures.is_empty():
		print("PASSED: %d receiver-side clash checks" % checks)
	quit(0 if failures.is_empty() else 1)
