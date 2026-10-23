@tool
extends RefCounted

const GENERAL_SECTION_ORDER := [
	"movement",
	"player",
	"enemy",
	"enemy_ai",
	"ui",
]
const COMBAT_SECTION_ORDER := [
	"combat",
	"moves",
	"attack_styles",
	"casting",
	"heat",
	"fire",
	"water",
	"air",
	"earth",
	"defence",
	"elemental_endurance",
	"hit_reaction",
	"legacy_reactions",
]
const ReactionRanges = preload("res://scripts/config/combat_reaction_ranges.gd")
const Style = preload("res://scripts/combat/attack_style.gd")
const Creatures = preload("res://scripts/config/creature_catalog.gd")
const STYLE_HELP := "Scrub sprite frames and key Player X hitbox position, target and radius in Player / AnimationPlayer; native curves alone own geometry. Windup and recovery split at the pacing-only timing_split marker (active_start when absent), in seconds before Heat scaling; zero timing inherits shared timing. Lunge is attacker-body travel through collision, not victim knockback. Shared reaction levels alone own victim distance, motion time and stun. Numeric edits affect subsequent actions; Save persists the character Settings. Save native Animation edits separately and restart the scene to compare."

const AUDIO_GROUP_ORDER := ["ambient", "sfx", "bgm"]
# October 15 accepted formula: Combat Systems / Design Decision Log in Laema Space.
# Implemented receiver-side formula; October 16 zero/negative and 0/0 decisions.
const IMPACT_HELP := "Subtract the receiver's Poise and active-move Impact from incoming Impact. Outside active frames, the move contributes 0.\nOrdinary positive results interrupt; Player zero against a combat Enemy selects Level 1. Other ordinary non-positive hits deal damage without interruption.\nWhen both active melee hitboxes reach their opponents simultaneously, compare signed results: larger wins, equality favors Player. Only the winner deals damage and interrupts; a winning non-positive result selects configured Level 1."
const REACTION_LEVEL_HELP := "Each shared level owns its starting value, victim distance, motion duration and separate stun duration. Motion is uniform and capped at stun lifetime; ending motion does not end hurt, control lock or invulnerability. The range ends just before the next level starts; Level 5 covers higher values. Level 1 starts at 0. These ranges choose the level only after reaction eligibility is decided."
const IMPACT_TOOLTIP := "Impact and Poise range from 0 to 100. Poise is defensive.\n\nHit-reaction value = incoming Impact - receiver Poise - receiver active-move Impact. Outside active_start..active_end the move contribution is zero.\n\nAn ordinary connected negative hit deals damage without interruption. Player zero against a combat Enemy selects configured Level 1; Enemy zero does not interrupt.\n\nOnly when both active melee hitboxes reach their opposing characters at the same sample is there a simultaneous clash: larger signed result wins, equality favors Player. Only the winner deals damage and interrupts. Winning zero/negative explicitly selects configured Level 1; positive uses configured ranges. Weapon-to-weapon overlap is unnecessary. An unconnected attack causes no reverse damage or interruption.\n\nInvincibility/block/parry still intercept; first contact spends the target allowance even when ignored. Practice targets, defence and failed Cast retain their separate controls."
# Legacy field meanings confirmed read-only with Combat against execute() and callers.
const LEGACY_REACTION_NOTICE := "These legacy settings do not affect the new combat hit reactions."
const LEGACY_REACTION_HELP := LEGACY_REACTION_NOTICE + "\nUsed by stationary practice-target recoil and failed-Cast self-flinch. Retained blocked, non-parried defence hits use this path only when their calculated reaction level is positive. Positive levels are capped at 5. Duration controls the flinch/recovery time; distance moves the sprite out and back without moving its collision body. These reactions grant no invincibility. Failed Cast always uses Level 1, so only the two Base values affect it. The new combat reactions use their own Levels 1–5 table."
const HIDDEN_PORTAL_FIELDS := {
	"enemy_ai.windup_duration": true, # Legacy profile fields; Enemy timing is authored in its animation.
	"enemy_ai.recovery_duration": true,
	"fire.visual_motion_exponent": true, # Frame pacing is baked into native sprite tracks.
	"water.visual_motion_exponent": true,
	"air.visual_motion_exponent": true,
	"earth.visual_motion_exponent": true,
	"ui.gym_formula_visible": true, # Deprecated: unified with developer_overlay_visible.
	"movement.gravity_scale": true,
	"combat.direct_impact": true,
	"combat.hit_phase": true,
	"enemy_ai.impact": true,
}
const INTEGER_FIELDS := {
	"enemy.defensive_level": true,
	"player.poise": true,
	"enemy_ai.poise": true,
	"enemy_ai.impact": true,
	"combat.direct_impact": true,
	"casting.max_marked_capacity": true,
	"defence.water_block_defensive_level": true,
}
const FIELD_RANGES := {
	"movement.speed": Vector3(1.0, 600.0, 1.0),
	"movement.gravity_scale": Vector3(0.05, 5.0, 0.05),
	"player.poise": Vector3(0.0, 100.0, 1.0),
	"enemy_ai.poise": Vector3(0.0, 100.0, 1.0),
	"player.max_health": Vector3(1.0, 10000.0, 1.0),
	"enemy.max_health": Vector3(1.0, 10000.0, 1.0),
	"enemy.defensive_level": Vector3(0.0, 100.0, 1.0),
	"enemy_ai.aggro_range": Vector3(1.0, 2000.0, 1.0),
	"enemy_ai.attack_range": Vector3(1.0, 400.0, 1.0),
	"enemy_ai.hitbox_reach": Vector3(0.0, 400.0, 1.0),
	"enemy_ai.hitbox_radius": Vector3(0.001, 200.0, 1.0),
	"enemy_ai.movement_speed": Vector3(0.0, 600.0, 1.0),
	"enemy_ai.damage": Vector3(0.0, 1000.0, 1.0),
	"enemy_ai.impact": Vector3(0.0, 5.0, 1.0),
	"combat.attack_duration": Vector3(0.05, 5.0, 0.01),
	"combat.hit_phase": Vector3(0.0, 1.0, 0.01),
	"combat.input_window_start": Vector3(0.0, 1.0, 0.01),
	"combat.light_damage": Vector3(0.0, 1000.0, 1.0),
	"combat.casting_damage": Vector3(0.0, 1000.0, 1.0),
	"combat.direct_impact": Vector3(0.0, 5.0, 1.0),
	"casting.orb_lifetime": Vector3(0.1, 30.0, 0.1),
	"casting.charge_step_duration": Vector3(0.05, 5.0, 0.01),
	"casting.max_marked_capacity": Vector3(8.0, 8.0, 1.0),
	"casting.trigger_release_max": Vector3(0.0, 1.0, 0.01),
	"casting.trigger_charge_min": Vector3(0.0, 1.0, 0.01),
	"casting.empowered_primary_multiplier": Vector3(0.1, 5.0, 0.05),
	"casting.projectile_screen_ratio": Vector3(0.05, 1.0, 0.05),
	"casting.projectile_travel_duration": Vector3(0.1, 5.0, 0.05),
	"heat.max_heat": Vector3(100.0, 100.0, 1.0),
	"heat.gain_per_charged_orb": Vector3(0.0, 10.0, 0.1),
	"heat.loss_per_direct_hit": Vector3(0.0, 50.0, 0.1),
	"heat.reset_timer": Vector3(0.1, 60.0, 0.1),
	"heat.depletion_per_second": Vector3(0.0, 20.0, 0.1),
	"fire.dot_duration": Vector3(0.01, 60.0, 0.01),
	"fire.dot_tick_interval": Vector3(0.01, 30.0, 0.01),
	"fire.damage_per_stack": Vector3(0.0, 100.0, 0.1),
	"fire.visual_motion_exponent": Vector3(0.1, 5.0, 0.05),
	"fire.vfx_fps": Vector3(0.1, 120.0, 0.1),
	"water.base_radius": Vector3(1.0, 400.0, 1.0),
	"water.radius_per_level": Vector3(0.0, 200.0, 1.0),
	"water.visual_motion_exponent": Vector3(0.1, 5.0, 0.05),
	"water.vfx_fps": Vector3(0.1, 120.0, 0.1),
	"defence.guard_capacity": Vector3(1.0, 1000.0, 1.0),
	"defence.blocked_damage_to_guard": Vector3(0.0, 10.0, 0.1),
	"defence.guard_warning_ratio": Vector3(0.0, 1.0, 0.01),
	"defence.parry_window": Vector3(0.01, 2.0, 0.01),
	"defence.fire_tap_parry_window": Vector3(0.01, 2.0, 0.01),
	"defence.fire_control_commitment": Vector3(0.01, 5.0, 0.01),
	"defence.fire_miss_recovery": Vector3(0.0, 5.0, 0.01),
	"defence.fire_block_absorption": Vector3(0.0, 1.0, 0.01),
	"defence.guard_break_recovery": Vector3(0.0, 5.0, 0.01),
	"defence.heat_drain_per_second": Vector3(0.0, 100.0, 0.1),
	"defence.water_block_defensive_level": Vector3(0.0, 100.0, 1.0),
	"elemental_endurance.hit_6_damage_percent": Vector3(0.0, 1.0, 0.05),
	"elemental_endurance.hit_7_damage_percent": Vector3(0.0, 1.0, 0.05),
	"elemental_endurance.hit_8_damage_percent": Vector3(0.0, 1.0, 0.05),
	"elemental_endurance.hit_9_damage_percent": Vector3(0.0, 1.0, 0.05),
	"elemental_endurance.hit_10_damage_percent": Vector3(0.0, 1.0, 0.05),
	"hit_reaction.base_distance": Vector3(0.0, 100.0, 0.1),
	"hit_reaction.distance_per_level": Vector3(0.0, 100.0, 0.1),
	"hit_reaction.base_duration": Vector3(0.001, 60.0, 0.01),
	"hit_reaction.duration_per_level": Vector3(0.0, 10.0, 0.01),
	"ui.completed_combo_display_duration": Vector3(0.0, 20.0, 0.1),
	"tutorial.transition_duration": Vector3(0.1, 5.0, 0.1),
}
const HEAT_LEVEL_RANGES := {
	"fill_ratio": Vector3(0.0, 1.0, 0.01),
	"speed_multiplier": Vector3(0.1, 5.0, 0.05),
}
const WATER_LEVEL_RANGES := {
	"duration": Vector3(0.01, 60.0, 0.01),
	"slow_percent": Vector3(0.0, 1.0, 0.01),
}
const TUNABLE_TOOLTIPS := {
	"elemental_endurance.enabled": "Enable same-school resistance for the combat Enemy in every scene. Changing this resets its resistance streak; unrelated tuning preserves it.",
	"movement.speed": "Horizontal movement speed.",
	"movement.gravity_scale": "Gravity multiplier for airborne movement.",
	"player.max_health": "Player maximum Health.",
	"player.one_hp_floor_enabled": "Keep Player Health at a minimum of 1 against all damage.",
	"enemy.max_health": "Maximum Health for each training target.",
	"enemy.defensive_level": "Impact level that reduces incoming hit reactions.",
	"enemy_ai.enabled": "Enable the reversible prototype Final Enemy AI.",
	"enemy_ai.aggro_range": "Distance at which the Final Enemy begins tracking the Player.",
	"enemy_ai.attack_range": "Distance at which the Final Enemy begins its committed melee windup.",
	"enemy_ai.hitbox_reach": "Melee hitbox length at the animation active_start marker, in pixels. Save updates that animation key; approach distance is separate.",
	"enemy_ai.hitbox_radius": "Melee hitbox radius at the animation active_start marker, in pixels. Save updates that animation key.",
	"enemy_ai.movement_speed": "Final Enemy horizontal approach speed.",
	"enemy_ai.damage": "Final Enemy direct melee damage.",
	"enemy_ai.impact": "Impact level applied by Final Enemy melee damage.",
	"combat.attack_duration": "Base Casting duration and fallback for X timing phases set to zero. Heat scales playback.",
	"combat.casting_damage": "Base direct damage for school Casting effects.",
	"combat.direct_impact": "Impact level applied by direct X and Casting damage.",
	"combat.hit_phase": "Legacy phase mirror; native active_start/active_end own X contact windows and launch owns Cast emission.",
	"combat.input_window_start": "Normalized phase when the normal X/Cast chaining window opens.",
	"combat.x_buffer_width": "Normalized pre-window buffer width for X and full-press Cast requests.",
	"combat.collect_orb_without_contact": "Testing toggle: grant one orb on a missed X without applying damage.",
	"combat.light_damage": "Direct damage applied by a successful X hit.",
	"casting.charge_step_duration": "Seconds required to add one Charging-capacity step before Heat scaling.",
	"casting.empowered_primary_multiplier": "Damage multiplier for the primary school of an empowered Cast.",
	"casting.max_marked_capacity": "Maximum charged-orb capacity for one Cast. Fixed at eight in this prototype.",
	"casting.orb_lifetime": "Lifetime of the oldest orb before FIFO expiration.",
	"casting.projectile_screen_ratio": "Maximum projectile travel distance as a fraction of visible width.",
	"casting.projectile_travel_duration": "Seconds for a projectile to travel its maximum distance.",
	"casting.trigger_charge_min": "Minimum L2 pressure that charges generated orbs.",
	"casting.trigger_release_max": "Maximum L2 pressure that triggers Casting on release.",
	"heat.max_heat": "Maximum Heat units.",
	"heat.gain_per_charged_orb": "Heat units gained per consumed charged orb.",
	"heat.loss_per_direct_hit": "Heat units lost on an incoming applied direct hit.",
	"heat.reset_timer": "Seconds after a landed direct hit before Heat depletes.",
	"heat.depletion_per_second": "Heat units depleted each second after the reset timer.",
	"fire.damage_per_stack": "Damage dealt by each Fire DoT stack per tick.",
	"fire.dot_duration": "Lifetime of each Fire DoT stack.",
	"fire.dot_tick_interval": "Seconds between Fire DoT ticks.",
	"fire.visual_motion_exponent": "Exponent shaping Fire attack visual motion.",
	"fire.vfx_fps": "Playback speed of Fire status VFX.",
	"water.base_radius": "Base radius of Water area effects.",
	"water.radius_per_level": "Additional Water area radius per level.",
	"water.visual_motion_exponent": "Exponent shaping Water attack visual motion.",
	"water.vfx_fps": "Playback speed of Water status VFX.",
	"air.chain_radius": "Radius used to find additional Air chain-lightning targets.",
	"air.damage_per_level": "Additional Air direct-damage multiplier per level.",
	"air.max_chain_targets": "Maximum number of targets in an Air chain-lightning result.",
	"air.visual_motion_exponent": "Exponent shaping Air attack visual motion.",
	"earth.base_radius": "Starting radius of Earth area effects.",
	"earth.radius_per_level": "Additional Earth area radius per level.",
	"earth.visual_motion_exponent": "Exponent shaping Earth attack visual motion.",
	"defence.guard_capacity": "Maximum Water guard capacity.",
	"defence.blocked_damage_to_guard": "Guard damage multiplier applied to blocked incoming damage.",
	"defence.guard_warning_ratio": "Guard ratio at or below which the warning state activates.",
	"defence.parry_window": "Fire full-parry duration immediately on R1 press. Dead Cells reference: 0.20 seconds. Holding then gives partial block. Captured on press.",
	"defence.fire_tap_parry_window": "Fire quick-release parry endpoint measured from the original press, not release. Also the hold-charge threshold. Reference: 0.37 seconds; at least the early parry window.",
	"defence.fire_control_commitment": "Fire quick-release movement/action commitment measured from the original press. Success unlocks immediately. Reference: 0.50 seconds; at least the tap-parry endpoint.",
	"defence.fire_miss_recovery": "Shield reuse penalty starting when an unsuccessful tap parry expires. Separate from movement lock. Reference: 0.60 seconds.",
	"defence.fire_block_absorption": "Fraction of front direct damage prevented by held Fire block. Reference: 0.75 (75%). The remaining chip damage is still a defended result; no Water guard/Heat drain.",
	"defence.guard_break_recovery": "Seconds of recovery after guard break.",
	"defence.heat_drain_per_second": "Heat drained per second while Water blocking.",
	"defence.water_block_defensive_level": "Defensive Impact level supplied by Water blocking.",
	"elemental_endurance.hit_6_damage_percent": "Final Enemy same-school damage multiplier at streak hit 6.",
	"elemental_endurance.hit_7_damage_percent": "Final Enemy same-school damage multiplier at streak hit 7.",
	"elemental_endurance.hit_8_damage_percent": "Final Enemy same-school damage multiplier at streak hit 8.",
	"elemental_endurance.hit_9_damage_percent": "Final Enemy same-school damage multiplier at streak hit 9.",
	"elemental_endurance.hit_10_damage_percent": "Final Enemy same-school damage multiplier at streak hit 10 and later.",
	"hit_reaction.base_distance": "Sprite recoil distance at Level 1, in pixels. Total recoil = Base Distance + Distance Per Level × (level − 1), with level capped at 5. Failed Cast uses this Base Distance directly.\n\n" + LEGACY_REACTION_HELP,
	"hit_reaction.distance_per_level": "Extra sprite recoil, in pixels, for each level above Level 1. Level 3 adds this amount twice: Base Distance + 2 × Distance Per Level. This does not affect failed Cast, which always uses Level 1.\n\n" + LEGACY_REACTION_HELP,
	"hit_reaction.base_duration": "Reaction/recovery time at Level 1, in seconds. Total time = Base Duration + Duration Per Level × (level − 1), with level capped at 5. Failed Cast uses this Base Duration directly.\n\n" + LEGACY_REACTION_HELP,
	"hit_reaction.duration_per_level": "Extra reaction/recovery time, in seconds, for each level above Level 1. Level 3 adds this amount twice: Base Duration + 2 × Duration Per Level. This does not affect failed Cast, which always uses Level 1.\n\n" + LEGACY_REACTION_HELP,
	"ui.completed_combo_display_duration": "Seconds completed chains remain in the readout.",
	"ui.developer_overlay_visible": "Show or hide developer telemetry and the gym formula panel together. F4 toggles them together while the gym is focused. Captured hit values are retained while hidden. Gameplay HUD remains visible; the Dev Portal window has its own backtick toggle. Save this setting to remember it for future runs.",
	"tutorial.transition_duration": "Seconds used by future tutorial camera pans.",
	"heat.levels.fill_ratio": "Heat threshold for this level as a fraction of maximum Heat.",
	"heat.levels.speed_multiplier": "Attack, Casting, and marking speed multiplier at this Heat level.",
	"water.levels.duration": "Duration of this Water status level.",
	"water.levels.slow_percent": "Movement slow percentage for this Water status level.",
	"audio.ambient.enabled": "Enable or mute the Ambient audio bus.",
	"audio.ambient.volume_db": "Ambient volume as a percentage of the normal mix level.",
	"audio.sfx.enabled": "Enable or mute the SFX audio bus.",
	"audio.sfx.volume_db": "SFX volume as a percentage of the normal mix level.",
	"audio.bgm.enabled": "Enable or mute the BGM audio bus.",
	"audio.bgm.volume_db": "BGM volume as a percentage of the normal mix level.",
}

const Store = preload("res://scripts/config/developer_config_store.gd")
const CATEGORIES := [
	["movement", "General / Movement"], ["player", "General / Player"],
	["enemy", "General / Practice targets"], ["enemy_ai", "General / Final Enemy"],
	["ui", "General / UI & debug"], ["audio", "Audio / Mix"],
	["combat", "Combat / Timing & testing"], ["moves", "Combat / Impact"],
	["attack_styles", "Combat / Attack styles"],
	["casting", "Combat / Casting"], ["heat", "Combat / Heat"],
	["fire", "Schools / Fire"], ["water", "Schools / Water"],
	["air", "Schools / Air"], ["earth", "Schools / Earth"],
	["defence", "Combat / Defence"], ["elemental_endurance", "Combat / Elemental Endurance"],
	["hit_reaction", "Combat / Hit-reaction levels"], ["legacy_reactions", "Combat / Legacy reactions"], ["tutorial", "Tutorial / Startup"],
]

const NAVIGATION := [
	["general", "General", ["movement", "player", "enemy", "enemy_ai", "ui"]],
	["combat", "Combat", ["combat", "moves", "attack_styles", "casting", "heat", "defence", "elemental_endurance", "hit_reaction", "legacy_reactions"]],
	["schools", "Schools", ["fire", "water", "air", "earth"]],
	["audio", "Audio", ["audio"]],
	["tutorial", "Tutorial", ["tutorial"]],
	["session", "Session", ["session"]],
]
# Confirmed by the generic Cast path and its retained school-resolver consumers.
# This describes Casting usage, not whether another system can read the value.
const UNUSED_CAST_FIELDS := [
	"fire.damage_per_stack", "fire.dot_duration", "fire.dot_tick_interval", "fire.vfx_fps",
	"water.base_radius", "water.radius_per_level", "water.vfx_fps",
	"air.chain_radius", "air.damage_per_level", "air.max_chain_targets",
	"earth.base_radius", "earth.radius_per_level",
]


static func fields(config: Dictionary, section: String) -> Array:
	config = config.duplicate(true)
	Style.strip_retired_fields(config)
	var result: Array = []
	if section == "attack_styles":
		for school in ["fire", "water", "air", "earth"]:
			for position in range(1, 6):
				var id := "%s_x%d" % [school, position]
				_collect(Style.read_move(config["moves"][id]), ["moves", id], result, config, true)
		return result
	if section == "moves":
		var ordered: Array = []
		for school in ["fire", "water", "air", "earth"]:
			for position in range(1, 6):
				ordered.append("%s_x%d" % [school, position])
		ordered.append_array(["cast", "final_enemy_attack"])
		for id in config["moves"]:
			if not ordered.has(id):
				ordered.append(id)
		for id in ordered:
			if config["moves"].has(id):
				_collect(config["moves"][id], ["moves", id], result, config)
		return result
	if section == "hit_reaction":
		_collect(config[section]["combat_levels"], [section, "combat_levels"], result, config)
		return result
	if section == "legacy_reactions":
		for key in ["base_duration", "duration_per_level", "base_distance", "distance_per_level"]:
			_collect(config["hit_reaction"][key], ["hit_reaction", key], result, config)
		return result
	_collect(config.get(section, {}), [section], result, config)
	if section in ["fire", "water", "air", "earth"]:
		# Keep the active animation setting visible before status/effect controls.
		var ordered: Array = []
		for field in result:
			if field["casting_usage_note"].is_empty():
				ordered.append(field)
		for field in result:
			if not field["casting_usage_note"].is_empty():
				ordered.append(field)
		return ordered
	return result


static func _collect(value: Variant, keys: Array, result: Array, config: Dictionary, styles_only := false) -> void:
	var id := Store.path_label(keys)
	if id in ["enemy_ai.hitbox_reach", "enemy_ai.hitbox_radius"] and config.get("ui", {}).get("enemy_creature", "pikeman") != "pikeman":
		return # Creature-specific Animation tracks own these values.
	if HIDDEN_PORTAL_FIELDS.has(id) or id == "tutorial.stages":
		return
	if typeof(value) == TYPE_DICTIONARY:
		var names: Array = value.keys()
		names.sort()
		if keys.size() == 3 and keys[1] == "combat_levels":
			names = ["minimum_value", "duration", "motion_duration", "distance"]
		for key in names:
			_collect(value[key], keys + [key], result, config, styles_only)
		return
	if typeof(value) == TYPE_ARRAY:
		for index in range(value.size()):
			_collect(value[index], keys + [index], result, config, styles_only)
		return
	# Move records retain their authored animation/source links and reserved lunge.
	if keys[0] == "moves" and not styles_only and keys.back() != "impact":
		return
	var field := {
		"path": keys, "id": id, "label": _label(keys), "group": _group(keys, config),
		"kind": "bool" if typeof(value) == TYPE_BOOL else "number",
		"description": TUNABLE_TOOLTIPS.get(id, "Adjust %s." % _label(keys)),
		"minimum": 0.0, "maximum": 10000.0, "step": 0.01,
		"integer": INTEGER_FIELDS.has(id), "allow_greater": true, "readonly": false,
		"unit": "", "options": [], "casting_usage_note": "",
	}
	if FIELD_RANGES.has(id):
		var limits: Vector3 = FIELD_RANGES[id]
		field["minimum"] = limits.x
		field["maximum"] = limits.y
		field["step"] = limits.z
		field["allow_greater"] = false
		field["readonly"] = is_equal_approx(limits.x, limits.y)
	if id in ["player.poise", "enemy_ai.poise"] or (keys[0] == "moves" and not styles_only):
		field.merge({"minimum": 0.0, "maximum": 100.0, "step": 1.0, "integer": true, "allow_greater": false}, true)
		field["description"] = impact_tooltip(config)
	if id.begins_with("hit_reaction."):
		field["allow_greater"] = true
	if id.contains(".combat_levels."):
		var is_duration: bool = keys.back() in ["duration", "motion_duration"]
		field.merge({"minimum": 0.001 if is_duration else 0.0,
			"maximum": 60.0 if is_duration else 1000.0,
			"step": 0.001 if is_duration else 0.1,
			"description": reaction_field_tooltip(config, str(keys.back()))}, true)
		if keys.back() == "duration":
			field["label"] = "Stun duration"
	if id.contains(".combat_levels.") and keys.back() == "minimum_value":
		field.merge({"label": "Starting value", "minimum": 0, "maximum": 2147483647, "step": 1, "integer": true, "allow_greater": false, "readonly": keys[2] == 0,
			"description": "First hit-reaction value assigned to this level. The previous level ends one below it. Starts must increase; Level 1 stays at 0. This does not make an otherwise ineligible hit react."}, true)
	if keys[0] in ["water", "earth"] and keys.size() == 4:
		field["minimum"] = 0.001 if keys.back() == "duration" else 0.0
		field["maximum"] = 60.0 if keys.back() == "duration" else 1.0
		field["step"] = 0.01
		field["allow_greater"] = keys.back() == "duration"
		field["readonly"] = keys.back() == "status"
		field["description"] = "School-effect tuning; generic prototype Casting does not dispatch these effects."
		if keys[0] == "water" and keys.back() == "slow_percent":
			field["readonly"] = config["water"]["levels"][keys[2]]["status"] != "slow"
	if id == "casting.max_storage_capacity":
		field.merge({"minimum": 10.0, "maximum": 10.0, "integer": true, "step": 1.0, "readonly": true}, true)
	if id == "combat.x_buffer_width":
		field.merge({"minimum": 0.0, "maximum": 1.0, "step": 0.01, "allow_greater": false}, true)
	if id == "air.max_chain_targets":
		field.merge({"minimum": 1.0, "maximum": 32.0, "integer": true, "step": 1.0, "allow_greater": false}, true)
	if id == "ui.cast_feedback_duration":
		field.merge({"minimum": 0.1, "maximum": 20.0, "step": 0.1, "allow_greater": false}, true)
	if id in ["ui.impact_contact_enabled", "ui.impact_camera_enabled"]:
		field["label"] = "Contact accent" if id == "ui.impact_contact_enabled" else "Heavy impact camera"
		field["group"] = "Cosmetic impact feedback"
		field["description"] = "Optional confirmed direct-Health-loss feedback. Off by default; never changes combat. Contact is <=40px/120ms; camera only Level 3+ combat reactions, <=3 viewport pixels/120ms. Existing damage/status information stays visible."
	if id == "ui.impact_treatment":
		field["kind"] = "choice"
		field["label"] = "Impact treatment"
		field["group"] = "Cosmetic impact feedback"
		field["options"] = [["precise", "Precise contact"], ["weight", "Weight accent"]]
		field["description"] = "Precise: two tapered ticks (20/24px complete footprint, 90/100ms); strong camera <=1px/80ms. Weight: wedge and two flecks (28/38px complete footprint, expansion/fade <=110ms); strong camera <=3px/110ms. Enable contact/camera separately; damage cues do not imply stun."
	if id == "ui.attack_hitbox_visible":
		field["label"] = "Show attack hitboxes"
		field["description"] = "Saved debug visibility shared by the editor and in-game Portal."
	if id.begins_with("audio.") and keys.back() == "volume_db":
		field.merge({"label": "Volume", "kind": "volume", "minimum": 0.0, "maximum": 100.0, "step": 1.0, "unit": "%", "allow_greater": false}, true)
	if id == "tutorial.default_stage_id":
		field["kind"] = "choice"
		field["label"] = "Default startup stage"
		field["description"] = "Loads on the next game startup. Use Session actions to change the current stage."
		for stage in config["tutorial"]["stages"]:
			field["options"].append([stage["id"], stage["display_name"]])
	if id == "ui.enemy_creature":
		field["kind"] = "choice"
		field["label"] = "Creature to spawn"
		field["description"] = "Choose the next opponent. Spawn / Restart starts a new encounter. Save Tuning remembers this choice."
		field["options"] = Creatures.options()
	if id == "tutorial.initial_school":
		field["kind"] = "choice"
		field["description"] = "Initial school for the next startup."
		for school in ["fire", "water", "air", "earth"]:
			field["options"].append([school, school.capitalize()])
	if typeof(value) == TYPE_STRING and field["kind"] != "choice":
		field["kind"] = "text"
		field["readonly"] = true
	if field["integer"]:
		field["step"] = 1.0
	if field["kind"] == "number":
		if id.contains("duration") or id.ends_with("timer") or id.ends_with("lifetime") or id.ends_with("window"):
			field["unit"] = "s"
		elif keys.back() in ["distance", "base_distance", "distance_per_level", "hitbox_radius", "hitbox_reach", "base_radius", "radius_per_level", "chain_radius", "aggro_range", "attack_range"]:
			field["unit"] = "px"
		elif keys.back() in ["speed", "movement_speed"]:
			field["unit"] = "px/s"
	if id in UNUSED_CAST_FIELDS or id.begins_with("water.levels.") or id.begins_with("earth.levels."):
		field["casting_usage_note"] = "Not used by current Casting"
		field["description"] += " Current Casting resolves generic damage without dispatching school-specific effects."
	if keys[0] in ["fire", "water", "air", "earth"]:
		if keys.back() == "visual_motion_exponent":
			field["group"] = "Attack presentation"
		elif keys.back() == "vfx_fps":
			field["group"] = "Status presentation"
		elif str(field["group"]).is_empty():
			field["group"] = "School effects"
	if styles_only:
		field["group"] = str(keys[1]).get_slice("_", 0).capitalize() + " / " + str(keys[1]).get_slice("_", 1).to_upper()
		field["label"] = str(keys.back()).replace("_", " ").capitalize()
		field["description"] = STYLE_HELP
		if keys.has("forward_lunge"):
			field["label"] = "Lunge " + field["label"].to_lower()
		if keys.back() in ["start_phase", "end_phase"]:
			field.merge({"maximum": 1.0, "allow_greater": false, "unit": "", "step": 0.01}, true)
		if keys.back() in ["windup_duration", "recovery_duration"]:
			field["unit"] = "s"
	result.append(field)


static func _label(keys: Array) -> String:
	if keys[0] == "moves":
		var id: String = keys[1]
		if id == "cast":
			return "Cast"
		if id == "final_enemy_attack":
			return "Enemy attack"
		return id.get_slice("_", 1).to_upper() if id.get_slice("_", 0) in ["fire", "water", "air", "earth"] else id.capitalize()
	if Store.path_label(keys) == "casting.max_marked_capacity":
		return "Charged-orb capacity"
	return str(keys.back()).replace("_", " ").capitalize()


static func _group(keys: Array, config: Dictionary) -> String:
	if keys[0] == "moves":
		if keys[1] == "cast":
			return "Casting"
		if keys[1] == "final_enemy_attack":
			return "Final Enemy"
		var school: String = str(keys[1]).get_slice("_", 0)
		return school.capitalize() + " / X1–X5" if school in ["fire", "water", "air", "earth"] else "Other moves"
	if keys[0] == "audio":
		return str(keys[1]).to_upper()
	if keys.size() == 4 and typeof(keys[2]) == TYPE_INT:
		var label := "Level %d" % (int(keys[2]) + 1)
		if keys[1] == "combat_levels":
			label += " / hit-reaction value " + ReactionRanges.range_text(config["hit_reaction"]["combat_levels"], keys[2])
		elif keys[0] == "water":
			label += " / " + str(config["water"]["levels"][keys[2]]["status"]).capitalize()
		return label
	if keys[0] == "hit_reaction":
		return "Legacy practice / defence / failed Cast"
	return ""



static func reaction_bands(config: Dictionary) -> String:
	var levels: Array = config["hit_reaction"]["combat_levels"]
	var error := ReactionRanges.validation_error(levels)
	if not error.is_empty():
		return "Invalid reaction ranges: " + error
	var lines: PackedStringArray = ["Configured hit-reaction value → level (after eligibility):"]
	for index in range(levels.size()):
		lines.append("%s → Level %d" % [ReactionRanges.range_text(levels, index), index + 1])
	return "\n".join(lines)


static func reaction_field_tooltip(config: Dictionary, key: String) -> String:
	var meanings := {
		"duration": "Stun lifetime in seconds: hurt animation, control lock and reaction invulnerability. Independent of shove time and the later Enemy AI wait.",
		"motion_duration": "Seconds used to deliver the selected level's distance uniformly. Capped at stun duration; a shorter shove does not end hurt, control lock or invulnerability.",
		"distance": "Total victim-body displacement in pixels, with no per-attack multiplier. Walls consume blocked motion. Attacker lunge is separate.",
	}
	return str(meanings.get(key, REACTION_LEVEL_HELP)) + "\nAffects subsequent reactions; active reactions retain all captured values.\n\n" + impact_tooltip(config)


static func impact_tooltip(config: Dictionary) -> String:
	return IMPACT_TOOLTIP + "\n\n" + reaction_bands(config)
