# Laema Side-Scrolling Orb Casting — Technical Design

Status: READY_FOR_ULTRON_OR_DUM-E

## 1. Scope and Repository Baseline

This document defines the architecture for the user-verified design in GAME_DESIGN.md and replaces the previous top-down/Y-finisher technical design.

The current source baseline is commit 5d027b5. At that baseline, the repository contains:

- shared Player and Enemy Entity roots;
- HealthEvent, HealthResult, HealthResolver, Health, Status, and HitReaction;
- Player Movement, Combat, InputCombo, Heat, and Defence components;
- functional Fire, Water, Air, and Earth resolver scripts;
- three-position X chains and immediate Y finishers;
- top-down movement and a Player-child Camera2D;
- the non-attacking permanent Enemy;
- combat HUD, JSON tuning, and Developer Overlay; and
- the preceding prototype character and VFX assets.

The current working tree is intentionally dirty. It additionally stages the accepted 20 X-attack sheets, shared casting and locomotion sheets, Player presentation lookup for X1–X5, and a side-view arena art pass. Those edits do not yet implement five-position chain rules, side-scrolling collision and gravity, OrbCastingController, analog R2 states, marked-orb behavior, SpellProjectile, or the revised HUD/configuration. This report treats those files as concurrent user-owned work and does not mistake presentation staging for completed gameplay.

The new GDD materially replaces movement, chain progression, finisher input, casting state, projectile lifetime, HUD, configuration, and animation allocation. Existing user validation applies only to the earlier exercised slice; no side-scrolling Orb Casting runtime evidence exists yet.

In scope:

- grounded horizontal movement with gravity and one continuous floor;
- Player-child horizontal-follow camera;
- five-position X/Cast chains;
- all four schools’ X attacks and casting specialties;
- Player-owned OrbCastingController;
- analog R2 pressure classification, Heat-scaled orb marking, pause/resume, normal/empowered/failed Casting, and punishment flinch;
- marked-orb hit loss, sequential lifetime fade, and mark transfer;
- Arena-spawned SpellProjectile scene;
- current Health/effect/Heat pipelines;
- accepted 20-sheet X allocation and shared Casting Spell flipbook;
- orb/charge/chain/projectile UI plus live developer R2 pressure; and
- existing Fire parry and Water block state entry.

Excluded:

- jumping and non-flat traversal;
- Air and Earth defence;
- active Enemy attacks;
- final projectile art and final Laema art;
- final balance; and
- the deferred change from direct-hit Heat to orb-consumption Heat.

## 2. Current Codebase Map and Migration

| Current owner | Current responsibility | Required migration |
|---|---|---|
| PrototypeArena | Configuration distribution and Player/Enemy/HUD wiring | Add flat-floor composition and Arena-owned SpellProjectile spawning |
| Player | Entity composition, presentation, camera, resolver injection | Compose OrbCastingController, expose casting/projectile signals, retain Camera2D |
| MovementController | Two-axis velocity and facing | Consume horizontal input only; apply gravity independently of horizontal locks |
| CombatController | Sole action arbiter, FSM, timing, contact, current finisher orchestration | Classify raw R2 pressure, orchestrate marking state and release, five-position chain actions, casting timing, failure, and spell impact |
| InputCombo | Three-X token list, one switch, Y level resolution | Become five-position X/Cast chain bookkeeping; remove spell composition |
| HeatController | Timed Heat resource and speed multiplier | Preserve current direct-hit behavior for this slice |
| School resolvers | Fire/Water/Air/Earth direct effects | Reuse at SpellProjectile impact with primary-only empowered damage multiplier |
| DefenceController | Fire parry and Water block | Preserve; do not add Air/Earth defence |
| StatusController | DoT, Water status, Earth Slow, EffectState | Preserve; add accepted five-level Earth data |
| PrototypeHUD | Heat, Health, defence, school, and combo feedback | Split presentation into always-visible GameUI and flag-controlled DeveloperReadout; add marked/unmarked orbs, front fade, marking progress, and upper-right pressure gauge |
| DeveloperOverlay | Backtick fail-fast tuning menu plus attack-hitbox control | Add the persisted DeveloperReadout visibility checkbox and expose accepted R2 tunables |
| PrototypeConfigLoader | Fail-fast JSON validation and saving | Validate casting, trigger bands, projectile, gravity, five-level Earth, and revised input-window schema |

The shared Entity/Health pipeline remains the architectural foundation. Orb Casting reuses it rather than introducing another damage system.

## 3. Selected Ownership and Communication

    PrototypeArena
    ├─ FlatFloor / collision
    ├─ Player : Entity
    │  ├─ MovementController
    │  ├─ CombatController
    │  ├─ InputCombo
    │  ├─ OrbCastingController
    │  ├─ HeatController
    │  ├─ DefenceController
    │  ├─ Health / HealthResolver
    │  ├─ Status / HitReaction
    │  ├─ AnimationPlayer / AttackCast
    │  └─ Camera2D
    ├─ Enemy : Entity
    ├─ PrototypeHUD
    │  ├─ GameUI
    │  └─ DeveloperReadout [PROCESS_MODE_ALWAYS]
    ├─ DeveloperOverlay [backtick tuning menu]
    └─ SpellProjectile instances

### OrbCastingController

OrbCastingController is a Player-owned sibling component following the existing HeatController pattern. It owns:

- the FIFO orb queue;
- the active front-orb lifetime;
- sequential expiration;
- retained partial marking time;
- marked capacity from 0 through 5;
- first-N marked coverage over the FIFO queue;
- transfer of that coverage when the front orb expires;
- removal of marked orbs when the accepted owner-hit seam is invoked;
- immediate FIFO consumption;
- primary/tie-break/secondary composition; and
- read-only snapshots containing school, marked state, and front lifetime ratio for UI.

It does not sample raw input, classify trigger pressure, choose action validity, advance the chain, launch projectiles, apply damage, or own animation state. Combat remains the sole input and action authority.

### InputCombo

InputCombo remains the accepted-chain record. It owns:

- progression positions 1–5;
- accepted X and mid-chain Cast tokens;
- the optional endpoint-Cast boundary;
- one school switch and at most two schools;
- completed-chain token snapshots; and
- timeout/failure clearing.

It no longer calculates spell levels. OrbCastingController resolves consumed-orb composition.

### SpellProjectile

SpellProjectile.tscn is a reusable scene with an Area2D root, collision shape, placeholder visual, and script. It owns:

- forward movement;
- maximum-distance tracking;
- first-valid-hit detection;
- miss/expiry cleanup;
- blended-color presentation; and
- resolved spell fields carried until impact.

The projectile directly stores:

- original instigator;
- facing/travel direction;
- primary school and level;
- optional secondary school and level;
- empowered state;
- primary damage multiplier; and
- primary/secondary color weights.

There is no CastPlan, ResolvedCast, global projectile manager, global event bus, or orb-queue lookup after release.

### World spawning and resolution

Player emits a typed projectile-spawn request at the casting animation’s launch phase. PrototypeArena:

1. instantiates SpellProjectile.tscn;
2. initializes its direct fields and travel values;
3. adds it to world space; and
4. connects its impact signal to Player Combat’s spell-impact boundary.

Arena owns world-object creation but no spell rules. Combat owns spell-impact orchestration and delegates each resolved school layer to the existing school resolvers.

Communication remains local and explicit:

- Godot `Input.get_action_raw_strength(&"casting")` to Player/Combat pressure classification;
- Combat to InputCombo and OrbCastingController by direct component calls;
- Player to Arena by typed spawn signal;
- SpellProjectile to Combat by an Arena-wired impact signal;
- school resolvers to target Entity by HealthEvent;
- Player and Enemy to HUD by observer signals;
- DeveloperReadout directly sampling the same un-deadzoned `casting` raw-strength API used by Combat; and
- DeveloperOverlay visibility checkbox to PrototypeArena/PrototypeHUD by a local callback while mutating the shared validated JSON-backed configuration.

No Autoload is added.

## 4. Movement, Camera, and Action State

### Side-scrolling movement

MovementController remains the movement owner.

- It samples only left/right actions.
- Horizontal velocity is input × movement speed × EffectState movement multiplier.
- Gravity is Godot’s configured 2D default gravity multiplied by a JSON gravity_scale starting at 1.0.
- Gravity continues while horizontal movement is combat-locked.
- Combat lock sets horizontal velocity to zero without erasing vertical velocity.
- Movement calls move_and_slide and relies on CharacterBody2D floor state.
- Slow modifies horizontal movement only; gravity remains active.
- Facing is always left or right.

PrototypeArena adds one continuous StaticBody2D floor and positions Player and Enemy directly on it. No jump or vertical movement action is consumed.

### Camera

Camera2D remains a Player child by explicit decision. The flat floor and grounded spawn keep Player Y stable, so the existing child relationship supplies horizontal following without a new camera controller.

### Combat and orthogonal charging

Combat keeps its explicit FSM for READY, chain activity, defence, guard break, and hit reaction. R2 marking is orthogonal state owned by OrbCastingController; there is no exclusive CHARGING FSM state.

Combat samples `Input.get_action_raw_strength(&"casting")` as the normalized `0.0–1.0` gameplay pressure value. DeveloperReadout independently samples that same raw-strength API while visible so its gauge remains live when the backtick menu pauses the gameplay tree. Both paths explicitly bypass the InputMap action deadzone; neither may substitute deadzone-adjusted `get_action_strength()`. Combat owns a transition-based pressure classifier:

- entering `0.90–1.00` starts or resumes marking;
- entering `0.35–0.65` pauses marking while retaining partial progress and existing marks;
- entering `0.00–0.10` attempts one Cast release;
- values between those bands retain the current semantic pressure state; and
- the release action is edge-triggered, so a resting trigger does not repeatedly attempt Casting.

X and subsequent Cast actions may occur while marking is active or paused. On a release transition, Combat classifies timing as idle-normal, valid-window empowered, or rushed failure. OrbCastingController validates marked-orb availability and consumes only on an accepted attempt.

The current finisher InputMap action is replaced by `casting`. Controller R2 uses the positive right-trigger axis. Right mouse may remain the developer keyboard/mouse alternative and therefore supplies only digital `0.0/1.0` pressure. Controller Y no longer resolves casting.

### Chain and animation clock

X and Cast use the same base action duration, normalized launch/contact phase, normalized chaining-window start, and Heat-derived speed multiplier.

The chaining window remains open from its configured start through normalized animation end. The old configurable window-end field is no longer consumed.

Combat action state distinguishes X attack, normal Cast, empowered mid-chain Cast, and empowered endpoint Cast.

Active or paused R2 marking preserves an active chain beyond normal idle timeout. A preserved chain retains movement lock and its orbs. X may begin a chain while R2 is already marking.

Successful mid-chain Cast advances one progression position. The optional Cast after position 5 does not create a sixth position and ends the chain.

### Failed casting

Combat rejects a Cast when:

- no orb is marked; or
- R2 is released before the active X/Cast chaining window opens.

Failure stops the active animation, resets InputCombo and OrbCastingController, creates no projectile, and requests the existing level-1 HitReaction directly. It does not synthesize a damage HealthEvent.

Starting or retaining marking across defence, guard break, Frozen, or externally caused hit reaction remains deferred under the accepted design waiver. Combat prevents new marking while actions are blocked, but the TDR does not decide whether pre-existing marks pause, persist, or clear when defence begins.

## 5. Orb, Projectile, and Effect Flows

### Orb generation and lifetime

One accepted X action generates at most one orb:

    X contact query
    → at least one valid Enemy contacted
    → submit normal X HealthEvents
    → add one active-school orb

Multiple targets do not generate multiple orbs from one X. A miss advances the chain but creates no orb.

OrbCastingController stores school queue order, one front lifetime, retained partial marking time, and an integer marked capacity:

- front lifetime starts at 3.0 seconds;
- only the front timer advances;
- UI alpha for the front orb is its remaining-lifetime ratio, producing a linear fade;
- waiting orbs remain fully visible because their timers have not started;
- front expiry removes that orb;
- the next orb begins a fresh 3.0 seconds;
- the first `min(marked_capacity, queue_size)` entries are marked;
- when a marked front orb expires, queue compaction transfers marking forward while preserving marked capacity when enough orbs remain;
- successful mid-chain Cast removes only consumed front orbs;
- normal Cast, endpoint Cast, timeout, and failure clear the remaining queue.

While pressure is in the active state, partial marking time advances using the current Heat multiplier. One mark completes every effective `0.5 / HeatMultiplier` seconds, and marked capacity caps at 5. Pausing retains partial time and marked capacity. A successful release consumes all currently marked front orbs and resets marking state.

OrbCastingController exposes a bounded owner-hit operation that removes every currently marked front orb, leaves all unmarked orbs in FIFO order, and resets marked capacity. Because the current Enemy cannot attack and R2–defence overlap is waived, this report does not choose which future blocked, parried, zero-impact, or status outcomes invoke that operation.

### Composition and launch

At successful R2 release, OrbCastingController consumes all marked orbs immediately and returns resolved values to Combat’s current casting action:

1. majority consumed school becomes primary;
2. a tie is won by the final consumed orb;
3. primary level equals total consumed count;
4. secondary level equals that school’s consumed count minus 1;
5. a secondary below level 1 is omitted.

The current action retains those direct fields only until projectile launch. Interrupted casting does not refund orbs.

At the shared normalized contact/release phase, Player asks Arena to spawn SpellProjectile.

- Arena derives visible world width from the active viewport/camera transform.
- Maximum travel distance is 50% of that width.
- Travel duration is 1.0 second.
- Projectile speed is maximum distance divided by travel duration.
- Direction is Player facing at successful release.
- Collision targets Enemy Entity bodies.
- First valid Enemy hit emits one impact and destroys the projectile.
- Maximum distance destroys it without impact.

For primary level P and secondary level S, color weights are P divided by P + S and S divided by P + S. A primary-only projectile uses the primary color.

### Spell impact

Combat resolves primary first, then secondary, using the projectile’s direct fields and existing resolver boundary.

- Fire: direct damage plus DoT stacks equal to Fire level.
- Water: direct damage plus existing Wet/Slow/Frozen instruction.
- Air: level 1 applies the timed attack-speed buff; levels 2–5 use current chain-lightning scaling.
- Earth: area damage and five-level Slow data.

Empowered 1.3× direct-damage multiplication applies only to the primary resolver. Status strength, DoT stacks, chained-target count, area, Slow, and secondary direct damage remain unchanged.

Resolver interfaces gain an explicit direct-damage multiplier or equivalent resolved amount. They do not read projectile nodes, orb state, or Combat state.

Each direct HealthEvent continues through the shared HealthResolver. Existing synchronous HealthResult delivery and direct-hit Heat behavior remain unchanged. The later orb-consumption Heat design is documented but not implemented.

## 6. Configuration, UI, and Assets

### JSON configuration

The Arena-owned fail-fast JSON model remains. Required additions:

    movement
    └─ gravity_scale = 1.0

    casting
    ├─ orb_lifetime = 3.0
    ├─ charge_step_duration = 0.5
    ├─ max_marked_capacity = 5
    ├─ trigger_release_max = 0.10
    ├─ trigger_pause_center = 0.50
    ├─ trigger_pause_half_width = 0.15
    ├─ trigger_press_min = 0.90
    ├─ empowered_primary_multiplier = 1.3
    ├─ projectile_screen_ratio = 0.5
    └─ projectile_travel_duration = 1.0

    ui
    └─ developer_overlay_visible = true

Casting reuses combat.attack_duration, combat.hit_phase, and combat.input_window_start. The normalized window end is fixed at animation end. The old combat.input_window_end and combat.finisher_damage fields are removed or migrated to revised casting naming in one coordinated config update.

Earth configuration contains:

| Level | Radius | Slow | Duration |
|---|---:|---:|---:|
| 1 | 28 | 15% | 1.5s |
| 2 | 38 | 25% | 2.0s |
| 3 | 48 | 40% | 2.5s |
| 4 | 58 | 40% | 3.0s |
| 5 | 68 | 40% | 4.0s |

PrototypeConfigLoader validates positive durations/distances, marked capacity as integer 5, trigger values in `0.0–1.0`, exactly five Earth levels, and existing school/effect contracts. Trigger validation also requires:

```text
trigger_release_max
< trigger_pause_center - trigger_pause_half_width
< trigger_pause_center + trigger_pause_half_width
< trigger_press_min
```

The starting values produce the accepted `0–10%` release band, `35–65%` pause band, and `90–100%` press/resume band. PrototypeConfigLoader also requires `ui.developer_overlay_visible` to be Boolean. DeveloperOverlay exposes the accepted R2 tunables and the DeveloperReadout visibility checkbox while retaining full-document validation before saving.

There is no save-game migration requirement. The coordinated JSON schema fails fast rather than silently defaulting.

### HUD

HUD remains presentation-only but is divided into two visibility domains.

GameUI is unaffected by the developer visibility flag:

- Orb UI displays the FIFO school-colored queue.
- Each orb snapshot identifies whether it is currently marked.
- The front orb’s alpha equals its remaining-lifetime ratio; waiting orbs remain fully visible.
- A ProgressBar beneath the queue displays partial progress toward the next mark and completed marked capacity.
- Expired, consumed, and owner-hit-lost marked orbs disappear.
- Target status and overhead Health presentation remain visible through their existing owners.

DeveloperReadout is one flag-controlled presentation group:

- upper left: Heat, Player Health, Enemy Health, and defence;
- upper center: active school, five-position chain, and completed-chain feedback; and
- upper right: live raw R2 pressure gauge.

DeveloperReadout begins visible from `ui.developer_overlay_visible = true`. Its always-processing presentation path polls `Input.get_action_raw_strength(&"casting")` directly while visible, including while DeveloperOverlay has paused the tree. This updates only the diagnostic gauge; Combat, OrbCastingController, and gameplay timing remain paused.

DeveloperOverlay remains the backtick tuning menu. Its checkbox changes the shared Boolean, immediately applies DeveloperReadout visibility through the existing Arena-owned tuning path, and persists through the existing validated Save-to-JSON action.

### Animation allocation

| School | X1 | X2 | X3 | X4 | X5 |
|---|---|---|---|---|---|
| Fire | Punch 1 | Punch 2 | Fire Kick | Explosive Strike | Power Strike |
| Water | Attack 1 | Attack 2 | Attack 3 | Enchanted Attack 1 | Enchanted Attack 2 |
| Air | Aerial Strike | Double Strike | Energy Wave | Wind Power | Weapon 1 |
| Earth | Attack 1 | Attack 2 | Attack 3 | Power Punch 1 | Power Punch 2 |

All use 128×128 cells and the shared feet baseline.

- Water and Earth use matching family Idle/Walk sheets.
- Fire and Air use the Medieval Character Pack 6 locomotion shell.
- Fire/Air prop discontinuity is accepted.
- All schools use Free Prototype Character Pack 2 Casting Spell.png.
- Final projectile art remains open; SpellProjectile uses a code-native colorable placeholder.
- Empowered Cast uses a visible Player-attached dot.

AnimationPlayer timing remains authoritative. Flipbook frame counts affect presentation sampling, not action duration, launch phase, chain window, hitbox, or damage.

## 7. Implementation Slices, Validation, and Handoff

### Implementation slices

1. Side-scrolling foundation
   - Convert MovementController to horizontal input plus gravity.
   - Add continuous floor collision and grounded spawn.
   - Preserve Player-child Camera2D.

2. Chain and Orb Casting
   - Add OrbCastingController.
   - Convert InputCombo to five X/Cast positions and one all-school switch.
   - Replace Y with analog R2 pressure classification and semantic Casting transitions.
   - Add Heat-scaled marking, pause/resume, marked-orb snapshots, sequential fade, and mark transfer.
   - Add normal, empowered, endpoint, consecutive, and failed outcomes.

3. Casting and projectile
   - Integrate Casting Spell flipbook.
   - Launch at the shared phase.
   - Add Arena-owned SpellProjectile spawning and direct fields.
   - Reuse school resolvers at impact with primary-only empowered damage.

4. Configuration, UI, and assets
   - Update JSON, trigger-band validation, Developer Overlay, and Earth levels.
   - Split PrototypeHUD into always-visible GameUI and flag-controlled DeveloperReadout presentation groups.
   - Add marked-orb queue, front-orb fade, marking-progress bar, upper-right live raw pressure gauge, and persisted visibility checkbox.
   - Import and wire accepted attack/locomotion flipbooks.
   - Add placeholder projectile and empowered dot.

5. Validation and synchronization
   - Preserve Health attribution and accepted instigator-lifetime waiver.
   - Run static source/config/resource checks only unless the user authorizes more.
   - Hand the complete source to the user for Godot validation.
   - Synchronize implementation status only from returned evidence.

### Required human validation

- Player lands on the flat floor, moves horizontally, and retains fixed vertical framing.
- Every school plays X1–X5 and creates one orb only on an Enemy hit.
- School switching preserves chain position and FIFO composition.
- Only the front orb expires and fades linearly; the next starts fully visible at full duration.
- R2 enters release at `0–10%`, pause at `35–65%`, and press/resume at `90–100%`; intermediate pressure preserves the prior semantic state.
- Combat and DeveloperReadout independently sample the same un-deadzoned raw R2 API, independent of the InputMap action deadzone.
- The upper-right pressure gauge remains live while the backtick menu pauses Combat and OrbCastingController.
- DeveloperReadout defaults visible; its checkbox hides or shows the upper-left, upper-center, and upper-right diagnostic regions together.
- Saving then reloading the JSON restores DeveloperReadout visibility.
- The orb queue, marking-progress bar, target statuses, and target overhead Health remain visible regardless of the developer flag.
- Marking advances every effective `0.5 / HeatMultiplier` seconds, caps at 5, pauses without losing partial progress, and coexists with X/Cast actions.
- A marked front-orb expiry transfers marking forward when enough orbs remain.
- Normal, empowered, mid-chain, consecutive, endpoint, rushed, no-orb, and undercharged outcomes match the GDD.
- Failed Cast flinches and clears the chain.
- Consumed orbs are not refunded after interruption.
- SpellProjectile launches, travels, blends color, resolves first hit, and expires correctly.
- Primary/tie-break/secondary levels and primary-only empowered damage are correct.
- Fire, Water, Air, and Earth effects use the shared Health pipeline.
- GameUI, DeveloperReadout, DeveloperOverlay, Heat, status, and accepted animations remain readable.

### Open evidence and boundaries

- The redesign has not been run in Godot.
- Existing validation applies only to the preceding prototype.
- The current Enemy cannot exercise marked-orb hit loss; an owner-hit seam is defined, but its runtime behavior remains unverified until an attacking Enemy exists.
- Active-mark interaction with defence, guard break, Frozen, and external hit reaction is deferred under the accepted design waiver.
- The prototype has no predefined experiential success/failure criteria under the accepted design waiver.
- Empowered-window timing relies on animation alone under the accepted design waiver.
- Active Enemy attacks and ordinary defensive validation remain absent.
- Original-instigator behavior after the instigator Entity is freed remains the accepted waiver.
- High Heat speed may cross narrow normalized phases and requires human timing validation.
- Final projectile and final Laema art remain open.
- Orb-consumption Heat has no conversion rate and is not implemented.

Instrumentation inventory:

- Existing toggleable attack-hitbox sweep remains.
- Retained debug-build, event-only traces cover grounded/facing and movement-lock changes; combat action, pressure, contact, cast, launch, and effect resolution; orb creation, marking, expiry, transfer, consumption, and clearing; projectile spawn, impact, and expiry; Heat gain and expiry; status application; and defence entry, block/parry, release, and guard break.
- Trace ownership remains local to `MovementController`, `CombatController`, `OrbCastingController`, `SpellProjectile`, `PrototypeArena`, `HeatController`, `StatusController`, and `DefenceController`; no Autoload, global event bus, runtime overlay, or gameplay state is added.

Friday recommends optional Ultron mode=tech-preflight because the change replaces movement and chain semantics, adds analog trigger-state classification and a timed Player resource, introduces cross-scene projectile lifetime, changes configuration, touches existing damage/defence seams, and preserves multiple accepted waivers.

After user verification, this report is ready for Ultron or DUM-E. The user chooses the next handoff.
