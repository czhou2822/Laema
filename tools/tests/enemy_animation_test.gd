extends SceneTree

const Catalog = preload("res://scripts/config/developer_settings_catalog.gd")
const Store = preload("res://scripts/config/developer_config_store.gd")

var checks := 0
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures.append(description)
		printerr("FAILED: " + description)


func start_attack(gym: Node, enemy: Entity) -> void:
	gym.player.reset_for_stage()
	enemy._reset_ai_execution()
	enemy.health.reset_to_maximum()
	enemy.global_position = gym.player.global_position + Vector2(60, 16)
	enemy._physics_process(0.0)


func _run() -> void:
	var source_hash := Store.source_hash()
	var gym = load("res://scenes/gym.tscn").instantiate()
	root.add_child(gym)
	current_scene = gym
	for frame in range(5):
		await process_frame
	var enemy = gym.get("_current_area").get_node("FinalEnemy")
	enemy.set_physics_process(false)
	enemy.set_process(false)
	gym.player.movement.set_physics_process(false)
	gym.player.might.set_physics_process(false)
	await physics_frame
	var config: Dictionary = gym.get("_config")
	check(not gym.get_property_list().any(func(property): return property["name"] in ["opponent_windup", "opponent_recovery"]), "Gym has no windup/recovery override property")
	var fields := Catalog.fields(config, "enemy_ai")
	check(not fields.any(func(field): return field["id"] in ["enemy_ai.windup_duration", "enemy_ai.recovery_duration"]), "Both Portal surfaces omit the obsolete Enemy timing controls")
	check(not enemy.bt_player.blackboard.has_var(&"windup_duration") and not enemy.bt_player.blackboard.has_var(&"recovery_duration"), "Behavior tree has no independent windup/recovery timers")
	# Old profiles remain readable, but their timing values never rescale playback.
	config["enemy_ai"]["windup_duration"] = 90.0
	config["enemy_ai"]["recovery_duration"] = 90.0
	enemy.apply_runtime_tuning()
	start_attack(gym, enemy)
	await physics_frame
	check(enemy.attack_animation.speed_scale == 1.0, "Enemy plays the saved animation at authored speed despite legacy profile values")
	enemy._physics_process(0.79)
	check(enemy.get("_state") == enemy.State.WINDUP and gym.player.health.get_current() == 100.0, "Stock animation remains in windup before its 0.8-second marker")
	enemy._physics_process(0.02)
	check(enemy.get("_state") == enemy.State.ACTIVE and gym.player.health.get_current() == 90.0, "Stock animation contacts at its authored marker without the Gym multiplier")
	enemy._physics_process(0.2)
	check(enemy.get("_state") == enemy.State.IDLE and not enemy.attack_animation.is_playing(), "Stock animation ends at one second with no added recovery wait")
	# Different authored boundaries expose code that still relies on old timers.
	var source_clock: Animation = enemy.attack_animation.get_animation(&"melee_swing")
	var clock := Animation.new()
	for track in range(source_clock.get_track_count()):
		source_clock.copy_track(track, clock)
	clock.add_marker(&"active_start", 0.31)
	clock.add_marker(&"contact", 0.37)
	clock.add_marker(&"active_end", 0.48)
	clock.length = 0.81
	var library: AnimationLibrary = enemy.attack_animation.get_animation_library(&"")
	library.remove_animation(&"melee_swing")
	library.add_animation(&"melee_swing", clock)
	start_attack(gym, enemy)
	await physics_frame
	enemy._physics_process(0.15)
	var action_id: int = enemy.get("_attack_id")
	config["enemy_ai"]["windup_duration"] = 13.0
	config["enemy_ai"]["recovery_duration"] = 17.0
	enemy.apply_runtime_tuning()
	check(enemy.get("_attack_id") == action_id and is_equal_approx(enemy.attack_animation.current_animation_position, 0.15), "Changing obsolete profile timings does not reset an attack")
	enemy._physics_process(0.15)
	check(enemy.get("_state") == enemy.State.WINDUP, "Custom windup waits for the native active_start marker")
	enemy._physics_process(0.02)
	check(enemy.get("_state") == enemy.State.ACTIVE and gym.player.health.get_current() == 100.0 and enemy.get_melee_snapshot()["active"], "Active frames can begin before contact without an early hit")
	enemy._physics_process(0.06)
	check(gym.player.health.get_current() == 90.0 and enemy.get("_strike_emitted"), "Custom contact marker applies one hit")
	enemy._physics_process(0.11)
	check(enemy.get("_state") == enemy.State.RECOVERY and enemy.attack_animation.is_playing() and enemy.get_melee_snapshot().is_empty(), "After active_end, authored recovery keeps playing and contributes no active move Impact")
	enemy._process(0.0)
	check(enemy.body_visual.texture.resource_path.ends_with("Attack_1.png"), "Recovery preserves the native animation artwork")
	enemy._physics_process(0.2)
	check(enemy.get("_state") == enemy.State.RECOVERY and gym.player.health.get_current() == 90.0, "Recovery lasts to the authored clip end without repeating contact")
	enemy._physics_process(0.13)
	check(enemy.get("_state") == enemy.State.IDLE and not enemy.attack_animation.is_playing(), "Custom recovery completes at animation length")
	enemy._physics_process(0.0)
	check(enemy.get("_state") == enemy.State.WINDUP and enemy.get("_attack_id") > action_id and is_zero_approx(enemy.attack_animation.current_animation_position), "Next behavior-tree cycle starts a fresh animation")
	start_attack(gym, enemy)
	await physics_frame
	enemy._physics_process(2.0)
	check(gym.player.health.get_current() == 90.0 and enemy.get("_hit_targets").size() == 1, "A frame crossing contact and animation end still applies exactly one connected hit")
	check(enemy.get("_state") == enemy.State.IDLE and not enemy.attack_animation.is_playing(), "A large frame finishes authored recovery without starting a second attack")
	# Cancellation must prevent the future native contact from firing.
	start_attack(gym, enemy)
	await physics_frame
	enemy._physics_process(0.2)
	var result: HealthResult = enemy.receive_health_event(HealthEvent.damage(gym.player, enemy, 1.0, 60, HealthEvent.Delivery.DIRECT, &"fire", {}, Vector2.RIGHT))
	check(result.outcome == HealthResult.Outcome.APPLIED and enemy.hit_reaction.is_invincible() and not enemy.attack_animation.is_playing(), "Qualifying hurt interrupts the native animation")
	enemy._physics_process(0.5)
	check(gym.player.health.get_current() == 100.0 and enemy.get("_attack_id") == 0, "Interrupted attack cannot emit its later contact")
	start_attack(gym, enemy)
	enemy.set_stage_active(false)
	enemy._physics_process(2.0)
	check(gym.player.health.get_current() == 100.0 and not enemy.attack_animation.is_playing() and enemy.get("_state") == enemy.State.DORMANT, "Stage deactivation cancels native playback and pending damage")
	check(Store.source_hash() == source_hash, "Timing checks and private animation edits never save shared data")
	for audio in gym.find_children("*", "AudioStreamPlayer", true, false):
		audio.stop()
	current_scene = null
	gym.free()
	await process_frame
	if failures.is_empty():
		print("PASSED: %d authored Enemy timing checks" % checks)
	quit(0 if failures.is_empty() else 1)
