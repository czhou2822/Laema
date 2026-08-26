# Laema Side-Scrolling Orb Casting — Technical Design

Status: READY_FOR_ULTRON_OR_DUM-E

This report is synchronized to the approved gameplay authority in `docs/GAME_DESIGN.md` and the current prototype implementation.

## 1. Scope, authority, and repository state

### Authority

The technical representation follows this order:

1. the user's latest explicit decision;
2. the user-verified gameplay and player-experience decisions in `docs/GAME_DESIGN.md`;
3. this technical representation;
4. the implementation as repository evidence.

This document does not revise gameplay intent. Where implementation and the GDD differ, the mismatch remains visible for the owning workflow to resolve.

### Reviewed identity

- GDD: `docs/GAME_DESIGN.md`, status `User-verified gameplay contract for the current prototype`.
- Validated baseline: `e543a43` (`feat: add validated combat prototype slice`).
- Last committed implementation: `358684b` (`feat: add side-scrolling orb casting prototype`).
- Current source scope: the approved R2 pressure/depletion/Cast state machine, shared X/Cast buffer, orb lifetime presentation, Developer Portal controls, audio-bus integration, and three-target arena fixes are included in the current authorized changeset.
- Current uncommitted source delta: `CombatController` releases horizontal movement when CHARGING or DEPLETING preserves a chain between active actions; no other implementation file is changed in this review range.
- Human validation: the user reported, `I verified and validates now`, for the expanded implementation on 2026-08-25. No scenario-level matrix, engine/version, or individual pass/fail breakdown was supplied.
- Agent checks: the agent did not run Godot, a build, a compiler, or automated tests.

### Gameplay scope

Included by the GDD:

- grounded left/right movement, gravity, a continuous flat floor, and horizontal camera following;
- functional Fire, Water, Air, and Earth X attacks and casting specialties;
- school selection and one school switch per chain;
- five-position X/Cast chaining and optional endpoint Casting;
- FIFO elemental orbs, R2 marking, normal Casting, empowered Casting, failed Casting, and casting projectiles;
- Heat acceleration of attacks, Casting, and R2 marking;
- Fire parry, Water block, hit reactions, status effects, combat UI, and three non-attacking Enemy targets.

Excluded by the GDD:

- jumping and vertical traversal;
- Air and Earth defence;
- active Enemy behaviour and attacks;
- final level design, final art and UI assets, complete enemy content, and final numerical tuning.

## 2. Repository map and execution paths

### Startup and composition

`project.godot` selects `scenes/prototype_arena.tscn` as the main scene. `PrototypeArena._ready()` loads and validates `config/prototype_combat.json`, installs runtime InputMap bindings, configures the HUD, Enemy, and Player, connects feedback signals, starts prototype audio, and creates the debug-only DeveloperOverlay (`scripts/prototype/prototype_arena.gd:27-58`). The accepted portal/audio change adds an AudioServer bus-layout resource and applies the validated audio settings through the same Arena-owned tuning path.

The arena scene owns the continuous floor, backdrop, Player instance, three non-attacking Enemy instances, HUD, and arena-level audio (`scenes/prototype_arena.tscn`). `PrototypeArena` configures every `status_targets` group member; the center `Enemy` remains the HUD's primary health-bar source while each target owns its own Health/status presentation. The Player scene composes the movement, combat, chain, orb, Heat, health, status, hit-reaction, and defence components (`scenes/player/player.tscn`).

### Input and movement

Player `_unhandled_input()` forwards school selection, defence, and X input to `CombatController` with the current horizontal facing direction (`scripts/player/player.gd:222-225`).

`MovementController` samples the left/right axis, updates facing, applies horizontal velocity unless movement is locked, applies gravity while airborne, and calls `CharacterBody2D.move_and_slide()` (`scripts/player/movement_controller.gd:24-41`). The floor is a single `StaticBody2D` on collision layer 4, and Player collision mask 6 permits floor and Enemy interaction (`scenes/prototype_arena.tscn`, `scenes/player/player.tscn`).

Movement locking is action-scoped rather than chain-scoped. `CombatController` locks horizontal movement while an X or Cast animation is active. If an action finishes with no pending follow-up while CHARGING or DEPLETING remains active, Combat clears the active-action fields and emits `movement_lock_changed(false)` without clearing the chain or orb state. Entering CHARGING or DEPLETING while no action is active also releases the movement lock. Defence, guard break, failed-Cast reaction, and external hit reaction retain their existing locks (`scripts/combat/combat_controller.gd:_try_start_charging`, `_try_start_depleting`, `_unlock_movement_for_orb_state`, `_on_animation_finished`).

`Camera2D` remains a Player child. Because the prototype keeps Player grounded on a flat floor, the child camera supplies horizontal following while preserving the intended fixed vertical framing.

### Combat and Casting

`CombatController` owns the action FSM, school selection, chain timing, ShapeCast contact timing, defence entry, hit-reaction interruption, R2 pressure classification, and Cast action creation (`scripts/combat/combat_controller.gd`).

The action state is explicit for `READY`, active chain actions, defence, guard break, and hit reaction. R2 pressure state is orthogonal state owned across Combat and `OrbCastingController`; there is no exclusive action-state `CHARGING` mode.

The pressure path samples `Input.get_action_raw_strength(&"casting")` and classifies transitions into:

- DEPLETING: `0.00–0.10`, fixed-rate marking-meter drain;
- CHARGING: `0.35–0.65`, Heat-scaled marking;
- CAST: `0.90–1.00`, one Cast attempt on entry; and
- intermediate values, retain the previous semantic state.

The CAST transition is edge-triggered, so holding full R2 does not repeatedly Cast. Releasing R2 does not Cast. The same raw API is sampled independently by the HUD's live diagnostic gauge.

### Shared normalized X/R2 input buffer

`CombatController` owns one buffer slot for X presses and R2 full-press Cast requests while a chainable X or Cast animation is active. The persisted `combat.x_buffer_width` is the normalized buffer width; buffer start is derived as `combat.input_window_start - combat.x_buffer_width`. The initial values produce `0.28 <= progress < 0.48`. The loader requires a numeric width in `0.0–1.0` and requires it to be no greater than `combat.input_window_start`.

The first valid X or full-press Cast request in a buffer period wins. Later requests do not replace it. X stores its school and horizontal direction without calling InputCombo or changing UI state. Full press requires marked orbs, consumes them immediately, and stores a duplicated resolved Cast payload including composition, empowered state, primary multiplier, direction, and instigator. The stored request is promoted at normal-window opening; promotion revalidates the current chain and uses the existing acceptance path. Casts and school switching do not receive any other buffering behavior.

The buffer is cleared on hit reaction, failed Cast, interruption, chain completion/reset, and return to `READY`. Holding X or R2 does not repeat a request. Buffered-Cast presentation and audio begin only when the Cast action is promoted.

### Chain and orb path

`InputCombo` owns the five-position token list and one-switch limit (`scripts/combat/input_combo.gd`). A successful or missed X occupies a position; a successful mid-chain Cast occupies a position; the optional Cast after position 5 is an endpoint and does not create a sixth position. Under default rules, an X creates an orb only after valid Enemy contact. The `combat.collect_orb_without_contact` Developer Portal test toggle may grant one orb on a miss without creating a HealthEvent or damage; the current persisted prototype config has this test toggle enabled.

`OrbCastingController` owns the school FIFO, the single front-orb lifetime, marking capacity, partial mark progress, right-to-left front-orb progress ratio, mark transfer, consumption, and school-composition resolution (`scripts/combat/orb_casting_controller.gd`). Heat supplies the current speed multiplier for marking.

### Projectile and effect path

At the shared normalized contact/launch phase, `CombatController` emits a Cast payload through Player. `PrototypeArena` instantiates and owns `SpellProjectile`, calculates maximum travel distance from visible world width and configuration, and routes the first valid Enemy impact back to Player combat (`scripts/prototype/prototype_arena.gd:154-176`).

`SpellProjectile` owns transient travel, visual color blending, travel audio, first valid Enemy collision, and maximum-distance expiry (`scripts/combat/spell_projectile.gd`). Combat passes the resolved primary and secondary school levels to the appropriate resolver. Resolvers create the shared `HealthEvent` and effect instructions consumed by `HealthResolver` and `StatusController`.

## 3. Ownership, lifecycle, and interfaces

| Owner | Responsibility and lifetime |
|---|---|
| `PrototypeArena` | Scene-level configuration, runtime input binding, feedback wiring, audio-bus application, DeveloperOverlay, and transient `SpellProjectile` instances. |
| `Player` | Entity root and lifetime owner of movement, Combat, InputCombo, OrbCastingController, Heat, Health, Status, HitReaction, and Defence children. Emits HUD and projectile-request signals. |
| `MovementController` | Reads horizontal input each physics frame and controls Player velocity, facing, grounding, and movement locks. |
| `CombatController` | Owns action state, action timing, chain progression calls, pressure transitions, Cast resolution, defence transitions, and resolver dispatch. |
| `InputCombo` | Owns chain tokens, active state, maximum five positions, and one school switch. |
| `OrbCastingController` | Owns orb queue state, front expiry, marking state, consumption, and mixed-school composition. |
| `HeatController` | Owns Heat value, inactivity expiry, and speed multiplier consumed by Combat, animations, and orb marking. |
| `DefenceController` | Owns Fire parry and Water block state, guard, warning, guard break, and rearm requirement. |
| `SpellProjectile` | Arena-owned transient Area2D. Emits one impact or expires after its configured travel distance. |
| School resolvers | RefCounted effect calculators. They do not own entities or persistent combat state. |
| `HealthResolver` | Entity-owned shared damage/effect resolution, defensive interception, hit reaction request, and instigator result delivery. |
| `StatusController` | Entity-owned DoT, Water status, Earth Slow, movement multiplier, action suppression, and status snapshots. |
| `PrototypeHUD` | Presentation-only consumer of Player and Enemy signals. Its GameUI remains visible independently of the developer readout. |
| `DeveloperOverlay` | Debug-only, always-processing Developer Portal. It pauses the gameplay tree while leaving its own UI responsive, owns the General/Audio/Combat tab presentation, and edits the shared validated configuration. |

### Material decision ledger

The following are existing technical representations evidenced by the current implementation, not newly invented proposals:

- Player owns `OrbCastingController` as a sibling to Combat and Heat.
- Combat remains the action arbiter; OrbCastingController remains the resource/queue owner.
- PrototypeArena owns SpellProjectile spawning and impact routing.
- School resolvers reuse the shared HealthEvent pipeline.
- HUD presentation consumes signals rather than owning gameplay state.
- Configuration remains fail-fast JSON with validated runtime editing.

No new material technical choice is selected by this report. The remaining open items are implementation gaps or human validation obligations.

## 4. State, data, and effect contracts

### Chain and failure transitions

Combat starts an X action from `READY`, enters chain activity, and accepts subsequent X or Cast input only under the configured chaining-window and marking conditions. A normal Cast ends the chain. An empowered mid-chain Cast occupies the next position; an endpoint Cast after position 5 ends the chain.

Failed Casting stops the active animation, clears InputCombo and OrbCastingController, emits the Cast-failed feedback signal, and directly requests a level-1 Player hit reaction. It does not synthesize a damage HealthEvent.

### Orb composition

At a successful CAST trigger, the consumed FIFO prefix is resolved as follows:

1. the majority school is primary;
2. a primary tie is won by the final consumed orb;
3. primary level equals total consumed-orb count;
4. secondary level equals that school's consumed count minus one; and
5. a secondary result below level 1 is omitted.

Consumed orbs are removed immediately on CAST entry, including a buffered full press before the promoted Cast animation begins. They are not refunded if the Cast is later interrupted.

### Orb lifetime and normal chain timeout

The front orb lifetime is configured by `casting.orb_lifetime`, currently 7.0 seconds. Only the oldest orb advances its timer; when it expires or is consumed, the next orb receives a fresh full lifetime. The front snapshot exposes a remaining-lifetime ratio rendered as a school-colored circular fill held on the left. The filled region interpolates from full to empty by shrinking from the right edge toward the left, leaving transparent UI space.

When a completed X or Cast action has no pending follow-up and no active CHARGING or DEPLETING pressure state, Combat ends the chain and enters `READY` without clearing `OrbCastingController`. Unconsumed orbs therefore remain visible and continue expiring while Laema is idle or moving. Failed Casting and the existing normal/endpoint Cast completion path retain their clearing behavior.

### Health and status pipeline

X contact and SpellProjectile impact create `HealthEvent` values with instigator, target, amount, Impact, delivery type, school, effect instructions, direction, and contact point. `HealthResolver` applies defence, Health, status instructions, and hit reaction, then delivers the result to a still-valid instigator (`scripts/entities/health_resolver.gd:25-105`).

Fire applies direct damage and independent DoT stacks. Water applies the configured Wet, Slow, or Frozen status with level priority. Air applies its level-1 speed buff or higher-level chain lightning. Earth applies area damage and level-scaled Slow. Status movement and action effects flow back through `StatusController.effect_state_changed` to Player movement and Combat.

### Defence

Only Fire parry and Water block are functional. Defence owns guard and rearm state. Combat owns the external action state and movement lock. Air/Earth defence remains excluded. Incoming Enemy attacks are absent from the current scene, so ordinary-play block, parry, guard warning, and guard-break behaviour cannot yet be validated.

### Known implementation boundaries

- `OrbCastingController.remove_marked_orbs_on_owner_hit()` exists, but no current Player hit path calls it. The GDD requires marked-orb loss on Player hit while retaining unmarked orbs. The current non-attacking Enemy makes this unexercisable; the dispatch remains an open DUM-E implementation item.
- School-specific idle/walk asset candidates exist in `assets/prototype/player/`, but `Player._get_idle_texture()` and `_get_walk_texture()` currently return the shared locomotion sheets. Per-school X attack sheets are wired; the school-specific locomotion presentation is not yet wired.

## 5. Configuration, persistence, compatibility, and performance

`config/prototype_combat.json` contains an `audio` section with three functional groups—Ambient, SFX, and BGM—each with an `enabled` Boolean and `volume_db` numeric value. The current persisted config has Ambient and SFX enabled and BGM disabled; the portal can change each setting. The `combat.collect_orb_without_contact` Boolean is currently enabled as a developer test setting, and `combat.x_buffer_width` is `0.20`. The pressure fields use `trigger_deplete_max`, `trigger_charge_center`, `trigger_charge_half_width`, and `trigger_cast_min`; the loader validates ordered non-overlapping bands, the buffer-width relation to `input_window_start`, five-level Water/Earth arrays, integer marked capacity, developer-readout Boolean, no-contact orb toggle, and all six audio fields.

`DeveloperOverlay` edits the in-memory configuration, applies validated live tuning, and persists the same JSON document through the Arena-owned save callback. Its fixed shared header is followed by top-level General, Audio, and Combat tabs; Combat contains nested tabs for Combat, Casting, Heat, Fire, Water, Air, Earth, Defence, and Hit Reaction. Boolean controls use visible ON/OFF toggles and volume controls remain bounded numeric controls. Gravity Scale is omitted from the Portal control surface while remaining part of movement configuration.

The accepted bus-layout resource adds `Ambient`, `SFX`, and `BGM` buses, each routed to untouched `Master`. `enabled` maps to the corresponding AudioServer bus mute state; `volume_db` maps to that bus volume, so a live re-enable resumes the current player stream rather than restarting it. `AmbientAudio` uses `Ambient`; `MusicAudio` uses `BGM`; Player's attack, cast, orb, cast-failure, and guard-warning players plus SpellProjectile travel and Arena projectile-impact players use `SFX`. No audio asset paths are added or replaced.

SpellProjectiles are transient scene instances and carry a duplicated launch payload only for their lifetime. Air chain queries are bounded by the configured target limit and engine query cap; Earth area queries are bounded by the engine query cap. No worker threads, shared global event bus, Autoload gameplay state, or network synchronization is introduced.

Debug traces are event-oriented and guarded by `OS.is_debug_build()`. Existing trace ownership remains local to MovementController, CombatController, OrbCastingController, SpellProjectile, PrototypeArena, HeatController, StatusController, and DefenceController. The attack-hitbox sweep remains toggleable through the DeveloperOverlay.

## 6. Presentation and asset representation

The current implementation wires:

- five X attack sheets for each school;
- shared casting, idle, and walk sheets;
- a visible Player-attached empowered-Cast dot;
- code-native color blending for SpellProjectile;
- school-specific attack and Cast audio;
- arena backdrop and floor prototype assets;
- Enemy status badges, health, flinch, and status VFX; and
- the always-visible orb queue and marking-progress bar.

The accepted prototype mapping is Fire/Fighter, Water/Prototype Saber Fighter, Air/Shinobi, and Earth/Samurai. This mapping is prototype presentation only and does not define final Laema art. Fire/Air locomotion-shell discontinuity remains accepted. Final projectile, final character, final UI, and final tuning remain open.

AnimationPlayer timing remains authoritative. Flipbook frame counts affect presentation sampling only; they do not independently change action duration, contact phase, launch phase, chaining window, hitbox, or damage.

## 7. Validation, waivers, and instrumentation

### Human validation report and remaining seams

The user report is now present for the expanded implementation. The following remain the required validation seams for any later detailed evidence record:

- grounding, horizontal movement, gravity, and camera framing;
- all four schools' X1–X5 attacks and hit-generated orbs;
- baseline and high-Heat X→X→X→X→X runs with the normalized X/R2 buffer, including first-request wins, promotion, and clear/invalidation traces;
- default contact-required orb collection and no-contact orb collection when the Developer Portal test toggle is enabled, with no damage on a no-contact grant;
- five-position X/Cast chains, school switching, endpoint Casting, and failed Casting;
- FIFO expiry, right-to-left reverse orb progress, mark transfer, consumption, and simultaneous R2/X activity;
- seven-second FIFO expiry and unconsumed-orb persistence while idle or moving after normal chain timeout;
- movement locked during active X/Cast animations and restored between actions when CHARGING or DEPLETING preserves the chain;
- R2 DEPLETING, CHARGING, and CAST transitions, fixed-rate depletion, and full-press Cast behavior;
- live DeveloperReadout pressure, developer visibility persistence, and always-visible GameUI;
- projectile launch, travel, first-hit collision, color blend, expiry, and all four school effects;
- Air speed buff and chain lightning; Earth area damage and Slow;
- Heat scaling, status feedback, hit reactions, and empowered primary-only `1.3×` damage; and
- school presentation switching, attack readability, HUD readability, and audio feedback.

The three current Enemy targets do not attack. Therefore incoming-hit marked-orb loss, Water block, Fire parry, guard depletion, guard warning, and guard break remain outside ordinary-play validation.

### Accepted waivers and deferred boundaries

The following remain retained and must not be silently converted into implementation claims:

- active-mark interaction with defence, guard break, Frozen, and externally caused hit reaction;
- no predefined experiential success/failure criteria for this prototype;
- empowered-window timing relies on the animation clock;
- original-instigator behaviour after the instigator Entity is freed;
- high-Heat timing crossing narrow normalized phases;
- direct-hit Heat remains current; orb-consumption Heat conversion is deferred;
- Air/Earth defence and active Enemy behaviour remain excluded; and
- final art, final tuning, complete enemy content, and final projectile art remain open.

### Instrumentation inventory

Retained debug-only traces cover grounded/facing transitions, movement locks, Combat actions and pressure-state transitions, contact and launch, orb creation/charging/depletion/expiry/transfer/consumption/clearing, projectile spawn/impact/expiry, the HUD's displayed marking-bar value at five-percent increments or marked-count changes, Heat, status application, and defence entry/block/parry/release/guard break.

## 8. Handoff and submission boundary

This technical report describes the current expanded prototype implementation and records the user's expanded validation report.

The report is ready for a fresh Ultron `mode=tech-postflight` audit. Local implementation gaps remain assigned to DUM-E; any missing scenario-level human evidence remains assigned to Human. A postflight result does not submit, commit, or approve gameplay.
