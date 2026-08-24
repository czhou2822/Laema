# Laema Combat Prototype — Technical Design

## Scope and Current Repository State

This document defines the architecture for the combat prototype in [GAME_DESIGN.md](GAME_DESIGN.md). The target scope includes player movement, complete Fire and Water combat packages, selectable Air and Earth visual placeholders, Fire–Water mixed finishers, Heat, Fire parrying, Water blocking, shared damage and hit-reaction processing, one non-attacking Enemy placeholder, combat feedback, and developer tuning tools.

The repository currently contains an unverified Fire/Water source slice: a composed Player, Combat FSM, Input-combo, Heat, AnimationPlayer timing, ShapeCast2D contact, a permanent target with a target-local flinch tween, HUD, JSON configuration, imported Craftpix assets, and a debug Developer Overlay. Direct contact currently bypasses the proposed shared HealthEvent and HealthResolver path. Godot runtime behavior remains unverified according to [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md).

Defence, Air/Earth placeholder selection, shared Entity architecture, and shared hit-reaction processing are not implemented yet. Functional Air and Earth combat packages, Active Enemy behavior, and its attack FSM are explicitly deferred. Exact health values and final art remain open gameplay or content work.

The current direct-contact path is `CombatController._perform_hit_query()` in `scripts/combat/combat_controller.gd` → `TrainingTarget.receive_direct_hit()` in `scripts/targets/training_target.gd` → a target-local flinch tween; Heat is incremented directly in Combat. Fire ticking in `scripts/status/status_controller.gd` emits only a damage number. `CombatController` and `Player._update_school_outline()` currently recognize only Fire and Water, which are the concrete seams for adding Air/Earth selection without adding their combat packages.

## Entity Hierarchy and Ownership

`Entity` is the shared parent class for health-bearing combat actors.

```text
Entity : CharacterBody2D
├─ Health
├─ HealthResolver
├─ Buff/Debuff
├─ HitReaction
└─ Hit/status presentation

Player : Entity
├─ Movement
├─ Combat
├─ Input-combo
├─ Heat
├─ Defence
├─ School switching
├─ AnimationPlayer
├─ ShapeCast2D
└─ Camera2D

Enemy : Entity
└─ Permanent placeholder behavior
```

The base Entity owns no player input, school selection, AI, or attack decisions. Player and Enemy inherit the common damage/effect foundation and add their own feature components.

| Component | Responsibility |
|---|---|
| Entity | Shared lifetime, HealthResult receiver, and references for Health, HealthResolver, Buff/Debuff, HitReaction, and hit/status presentation. |
| Health | Finite current/maximum Health and health-change signals behind one shared interface. |
| HealthResolver | Resolves HealthEvent damage or healing operations and damage-only hit reaction against target state. |
| Buff/Debuff | Owns effect source, stacks, duration, modifiers, expiry, and periodic effect execution. |
| HitReaction | Executes a resolved reaction level and owns recovery lifetime and reaction-state signals for one Entity. |
| Combat | Top-level Player action authority, input validation, attack/defence exclusion, animation, contact, and finisher orchestration. |
| Input-combo | Records only Combat-approved inputs and resolves school levels. |
| Heat | Owns Heat state and attack-speed multiplier. |
| Defence | Owns guard, parry windows, L1 rearming, and incoming-damage interception. |
| HUD / feedback | Observes resolved gameplay state without mutating it. |

GDScript remains the implementation language. Shared behavior uses class inheritance only at the Entity boundary; feature behavior remains composed.

## Shared Health and Effect Pipeline

HealthEvent is the shared contract for damage and healing. The current slice creates direct-damage and DoT-damage events; healing and HoT behavior remain deferred beyond the shared operation and attribution fields.

A HealthEvent carries the information required by approved behavior:

- original instigator;
- target Entity;
- operation: damage or heal;
- requested amount;
- Impact level for damage operations, from 0 through 5;
- delivery type, including direct, DoT tick, or future HoT tick;
- school or originating effect attribution;
- effect-application instructions carried only by events that instantiate a status; and
- contact information when physical contact exists.

Every Buff/Debuff instance records the original instigator for its complete lifetime. A Fire DoT tick therefore creates a new damage HealthEvent whose instigator remains the Entity that applied the DoT. Any future HoT tick must create a heal HealthEvent with that same original-instigator attribution.

Each Entity owns an instance of the same HealthResolver implementation. For damage operations in the current slice:

```text
HealthEvent
→ validate instigator, target, damage operation, amount, and Impact
→ at contact, read the target’s current defensive level
→ consult optional target interceptors against that same contact state
   └─ Player Defence: PARRIED / BLOCKED / PASS
→ resolve final hit-reaction level before the contact changes guard or action state
→ determine damage remaining after interception
→ cap actual Health reduction to the target’s current Health and discard excess
→ apply the negative Health delta
→ forward any accepted effect-application instruction to the target Buff/Debuff component
→ create HealthResult with actual Health delta, final reaction level, effect outcome, and zero-reaching state
→ target HitReaction executes the resolved reaction
→ deliver HealthResult synchronously to the HealthEvent’s original instigator Entity
→ instigator-owned consumers process the result, including eligible direct-hit Heat
→ if the Enemy placeholder reached zero, reset its Health to maximum without creating another HealthEvent
```

HealthResult records the operation, resolution outcome, actual signed `health_delta`, final reaction level, contact direction, effect outcome, zero-reaching state, and attribution needed by downstream consumers. Every Entity exposes the same synchronous result-receiver boundary. Player and Enemy use the same resolver; Player-specific defence enters only through the optional Defence interceptor.

Damage and hit reaction are separate outputs. A `BLOCKED` result has zero Health delta but retains its Impact and may still produce a hit reaction. A `PARRIED` result has zero Health delta and no hit reaction because parrying nullifies the incoming attack. DoT ticks use damage HealthEvents with Impact 0, so they grant no Heat and cause no hit reaction.

The Enemy placeholder has finite maximum and current Health. Damage is capped at its remaining Health; excess is discarded. A zero-reaching event resolves with its actual negative Health delta, delivers its HealthResult synchronously to the original instigator, then the Enemy performs an internal lifecycle reset to maximum Health. The reset is not a heal HealthEvent, has no instigator, emits no death, and leaves Buff/Debuff state untouched.

A resolved Fire Y HealthEvent carries an instruction to instantiate the approved number of Fire DoT stacks. HealthResolver forwards that instruction and the event’s original instigator to the victim’s Buff/Debuff component. Buff/Debuff stores stack lifetime and instigator, then creates a new damage HealthEvent for every tick with that same instigator. Tick events use DoT delivery, Impact 0, and no effect-application instruction, so they cannot recursively instantiate another DoT.

Combat owns direct-hit Heat triggering. For each unique target, Combat submits one accepted Fire/Water X or Y damage HealthEvent. The target HealthResolver synchronously delivers HealthResult to the Player Entity’s result receiver, which forwards eligible direct results to Combat. Combat grants one Heat increment only when that direct result has `health_delta < 0`. DoT, status, and future HoT results pass through the same receiver but do not grant Heat.

Every primary or secondary specialty owns its genuine direct-damage HealthEvent. Fire creates one contact-target HealthEvent; Water queries its level-scaled area centered on the confirmed contact point and creates one HealthEvent per unique Enemy in that area. A mixed Fire–Water finisher therefore creates separate Fire and Water HealthEvents, and the contacted Enemy may resolve both. Each direct HealthResult with `health_delta < 0` grants its own Heat increment.

Every Water HealthEvent carries 10 damage and Impact 1 plus the status instruction for its resolved level: level 1 Wet for 1 second; level 2 Wet for 2 seconds; level 3 Slow at 20% for 2 seconds; level 4 Slow at 40% for 2.5 seconds; and level 5 Frozen for 1 second. Water emits no duplicate event for the same Enemy within one area resolution. A miss produces no area or HealthEvent. Wet has no active modifier while Air remains a placeholder.

Every Entity owns one HitReaction component. It has no knowledge of schools, blocking rules, defensive levels, or attack identities. HealthResolver applies the fixed rule synchronously at contact, using the victim’s defensive level at that moment:

```text
final reaction level = max(0, Impact level - defensive level)
```

The defensive level is neither copied into nor retained by HealthEvent. Final level 0 emits no reaction. For levels 1 through 5, HitReaction applies the configured linearly increasing flinch magnitude and recovery duration, owns the recovery lifetime, and emits reaction-started and reaction-ended state; visual displacement remains presentation owned.

If HitReaction receives a new nonzero level while recovery is active, it ends the active reaction immediately, discards all remaining movement and recovery, and starts the new level at full magnitude and duration. Presentation cancels the old displacement before beginning the replacement. A level-0 result leaves any active reaction unchanged.

For Player, a nonzero reaction forces Combat into its hit-reaction state, cancels the current action and input-combo, locks movement and further actions, and returns Combat to READY when recovery ends. The Enemy placeholder has no action to cancel; its presentation consumes the same reaction state to reproduce the current light flinch.

Current-slice assignments are explicit: Player and Enemy maximum Health begin at 100; every accepted Fire or Water X and valid Fire or Water Y finisher deals 10 direct damage and has Impact 1; Fire DoT ticks have Impact 0; and the Enemy placeholder has defensive level 0. These Health and direct-damage values are tunable starting points rather than final balance. Air/Earth X and Y inputs produce no attack or HealthEvent. Earth’s defensive levels belong to its deferred full package and are not implemented in this slice. Other defensive levels remain unassigned gameplay data and may not be invented in implementation.

Buff/Debuff is also shared by Player and Enemy:

- Fire DoT stores stacks, duration, original instigator, and emits instruction-free, instigator-attributed HealthEvents on ticks.
- Water Wet stores source and duration but contributes no current modifier.
- Water Slow contributes `movement_multiplier = 0.8` at level 3 or `0.6` at level 4 for the approved duration.
- Water Frozen contributes `actions_suppressed = true` and `movement_multiplier = 0` for 1 second.

Buff/Debuff owns one active Water-status slot containing Water level, status identity, remaining duration, and original instigator. An incoming higher level replaces the slot and starts at full duration. An equal level refreshes the full duration without stacking. A lower level leaves the slot unchanged. HealthResolver still applies the Water HealthEvent’s direct damage and returns its HealthResult when Buff/Debuff rejects the lower-level status instruction.

Fire continues adding the approved independent DoT stacks. Reapplication policies for deferred effects remain outside this slice.

Whenever active effects change, Buff/Debuff publishes one aggregate EffectState:

```text
EffectState
├─ actions_suppressed
└─ movement_multiplier
```

Buff/Debuff alone interprets individual effects and combines their outputs. Consumers never inspect effect identities or stacks directly.

- Player Combat consumes `actions_suppressed` before accepting actions.
- Player Movement calculates final movement speed as `base speed × movement_multiplier`.
- Player Combat calculates attack playback speed from the Heat multiplier in this slice.

If only one active effect contributes to a category, its value passes through unchanged. Fire stack aggregation and the single Water-status priority slot remain internal to Buff/Debuff without changing the consumer interface.

Hit reaction is a transient combat state rather than a Buff/Debuff effect. HitReaction therefore signals Player Combat directly; it does not write into EffectState or create a second top-level input authority.

## Player Input and Action State

Godot InputMap remains the device abstraction; no custom input layer exists. Movement consumes continuous movement actions. Combat receives semantic attack, school, and defence actions and decides whether they are valid.

Input-combo receives only actions accepted by Combat. Defence never consumes input independently.

Combat accepts all four school-selection actions while READY. Fire and Water expose functional attack and defence behavior. Air and Earth update only the active-school identity and Player outline—white for Air, brown for Earth—while X, Y, and L1 are ignored. During COMBO_ACTIVE, only the Fire–Water switch is eligible; Air/Earth selection inputs are ignored without changing the combo or active school.

Combat expands its explicit FSM:

```text
READY
├─ Fire/Water: accepted X → COMBO_ACTIVE
├─ Fire/Water: accepted L1 → DEFENDING
└─ Air/Earth: X / Y / L1 → ignored

COMBO_ACTIVE
├─ accepted X → next attack
├─ accepted Fire–Water switch → update next attack school
├─ Air/Earth selection → ignored
├─ accepted Y → resolve → READY
└─ timeout → reset → READY

DEFENDING
├─ L1 release → READY
└─ guard break → GUARD_BROKEN

GUARD_BROKEN
└─ reaction ends and L1 has been released → READY

READY / COMBO_ACTIVE / DEFENDING
└─ final hit-reaction level > 0 → HIT_REACTING

HIT_REACTING
├─ new final reaction > 0 → replace reaction; remain HIT_REACTING
├─ final reaction = 0 → no state change
└─ HitReaction recovery ends → READY
```

Combat remains the sole top-level Player action arbiter. Entering HIT_REACTING stops attack playback, resets the input-combo, exits defence, rejects all input, and keeps movement locked until HitReaction signals recovery completion. This prevents simultaneous attack, defence, movement, school-switch, and reaction states.

## Defence Component

L1 invokes defence only while Fire or Water is active. Defence locks movement, disables school switching, and has no directional aiming. L1 is ignored while Air or Earth is active.

Defence owns:

- current guard value;
- blocked-damage depletion;
- parry-window lifetime;
- L1 release/repress rearming;
- guard-break reaction timing; and
- HealthResolver interception results.

### Water blocking

- L1 hold activates block while guard remains.
- Block returns `BLOCKED`, so incoming damage does not reach Health while Impact continues to HitReaction.
- Blocked damage depletes guard.
- Holding block drains Heat.
- Guard warning feedback is emitted near the configured threshold.
- The breaking hit remains blocked.
- Guard break enters the configured input-lock reaction, currently 0.5 seconds.
- Continued L1 hold cannot rearm.
- Releasing and pressing L1 again restores full guard and begins a new block.
- Water’s blocking defensive level remains open and is not selected by this report. Earth blocking is outside the current slice.

### Fire parrying

- L1 press opens one configured parry window.
- Contact inside that window returns `PARRIED`.
- `PARRIED` ends damage and hit-reaction resolution for that attack.
- Holding L1 after the window provides no defence while movement remains locked.
- Release and repress are required for another parry.

Enemy attack generation is outside the current prototype scope. Defence and HealthResolver retain the interception seam required for the deferred Active Enemy without adding an attack FSM shell now.

## Enemy Placeholder Architecture

The separate permanent Training Target scene is replaced by one Enemy subclass of Entity while preserving its current role as a stationary contact and feedback target.

The Enemy placeholder:

- has defensive level 0;
- begins with maximum and current Health of 100;
- never moves or attacks;
- cannot die;
- has finite maximum/current Health, caps damage at remaining Health, and discards excess;
- resets Health to maximum after a zero-reaching HealthResult without emitting death or clearing active effects;
- owns the shared Health, HealthResolver, Buff/Debuff, and HitReaction components; and
- presents resolved hit reactions, statuses, and VFX without deciding combat outcomes.

There is no mode switch, attack controller, contact generation, or attack FSM in the current scope. The approved future attack lifecycle remains deferred design context and does not authorize implementation of an empty Active-mode shell.

## School Effect Architecture

Combat continues delegating functional finisher output to the existing Fire and Water resolver boundary:

- Fire constructs one contact-target direct HealthEvent containing 10 damage, Impact 1, and its instigator-attributed DoT application instruction at the resolved specialty level.
- Water resolves the level-scaled unique target set and constructs one direct HealthEvent per target containing 10 damage, Impact 1, and its level-specific Wet, Slow, or Frozen instruction.
- Primary and secondary resolvers run as distinct layers in primary-then-secondary order; each HealthEvent independently resolves Health, reaction replacement, status application, and Heat eligibility.

School resolvers retain no ongoing effect state. Buff/Debuff owns lifetimes and modifiers; HealthResolver owns Health-event resolution.

Air and Earth have no resolver, effect state, attack configuration, defence configuration, or HealthEvent generation in this slice. Their deferred full packages must not be represented by speculative component shells.

## Configuration, Communication, and Developer Tools

Prototype Arena continues loading `config/prototype_combat.json` once, validating the complete document, and distributing one Arena-owned runtime snapshot. Invalid required data fails fast with no silent defaults.

JSON remains the tuning source for movement, attacks, Heat, effects, defence, finite entity Health, and hit-reaction magnitude and recovery. The schema adds required positive `player.max_health` and `enemy.max_health` values, both initially 100, plus required non-negative `combat.light_damage` and `combat.finisher_damage` values, both initially 10. Refill-at-zero and excess-damage discard are fixed rules rather than tunables. There are no Enemy attack definitions in the current schema. Fixed gameplay rules—including the subtraction formula and approved Impact and defensive-level assignments—remain validated contracts rather than silent defaults.

Water configuration stores one entry per specialty level with its status identity, duration, and Slow percentage where applicable. Initial entries are Wet/1 second, Wet/2 seconds, Slow/20%/2 seconds, Slow/40%/2.5 seconds, and Frozen/1 second. Water level is the fixed priority key: higher replaces, equal refreshes, and lower is ignored. Water’s existing base-radius and per-level radius fields continue to define area growth; direct damage and Impact remain the shared 10 and 1 values.

Impact fields validate as integers from 0 through 5. Defensive-level fields validate as non-negative integers without inventing an upper bound absent from the GDD. Hit-reaction tuning stores the level-1 magnitude and recovery plus the per-level linear increases used through level 5. The current target’s flinch-distance and flinch-duration values migrate into this shared representation rather than remaining target-owned fields.

Godot InputMap adds `select_air` and `select_earth`. The current JSON schema adds no Air or Earth attack, effect, or defence sections. White and brown outline mappings are fixed placeholder presentation rules and are not exposed as functional school tuning.

In debug builds, the Arena-owned Developer Overlay may edit approved tunables on the live snapshot. **Save to JSON** remains the only persistence path and must validate the complete snapshot before replacing the source file. Invalid data leaves the source unchanged.

Communication follows three explicit boundaries:

- Each Entity composition root wires its own internal components through direct references and local signals. Player owns Combat, Movement, Input-combo, Heat, Defence, and HitReaction wiring; Enemy owns HealthResolver, Health, Buff/Debuff, HitReaction, and presentation wiring.
- Cross-Entity Health resolution uses the synchronous public Entity boundary: the instigator submits HealthEvent to the target Entity, and the target HealthResolver delivers HealthResult directly to the original instigator Entity’s result receiver before finalizing target lifecycle work. Arena does not relay this transaction.
- Prototype Arena distributes configuration, holds scene-level Player/Enemy/HUD references, and wires presentation observers such as Player state to HUD. HUD and feedback listeners do not mutate gameplay.

There is no global event bus or gameplay Autoload.

AnimationPlayer remains the attack clock, normalized JSON values remain the timing source, and ShapeCast2D remains the physical contact query. The existing attack-hitbox diagnostic display remains debug-only and may not alter collision or resolution.

## Art and Content Evidence

The imported Shinobi, retained legacy Swordsman, Grassland, Fire, Water, and Ice subset is user-approved under user-confirmed Craftpix entitlement. Shinobi is the active generic side-view stand-in rather than final Laema art. Left-facing presentation mirrors the right-facing sheets, while vertical movement and attacks retain the most recent horizontal facing; the user explicitly accepted this directional compromise for the prototype.

Air/Earth placeholder presentation reuses the existing outline shader with white and brown colors and requires no new school animation or VFX assets. Distinct full-package Air/Earth movement, blocking, parrying, an active Enemy, persistent status overlays, and final UI remain deferred asset needs.

## Architecture-Level Implementation Slices

1. **Entity foundation**
   - Establish Entity, Health, shared HealthResolver, Buff/Debuff, HitReaction, HealthEvent, and HealthResult.
   - Add finite Enemy Health, capped Health reduction, discarded excess, zero-reaching result state, and lifecycle reset to maximum.
   - Replace an active hit reaction atomically when a new nonzero level arrives; preserve it when a level-0 result arrives.
   - Route direct hits and DoT ticks through the common event path while preserving existing Fire/Water outcomes.
   - Replace Water’s effect-only area callback with one HealthEvent per unique area target and suppress duplicate Water events from overlapping colliders.
   - Execute genuine Fire and Water primary/secondary resolver layers independently, preserving primary-then-secondary order and separate Heat-eligible HealthResults.
   - Add one Water-status priority slot to Buff/Debuff with higher-level replacement, same-level duration refresh, and lower-level rejection.

2. **Player defence and reaction state**
   - Add L1 InputMap action, Water block, Fire parry, Combat FSM defence states, movement/switch lock, guard, rearm, and guard-break output.
   - Add Player HIT_REACTING integration so a shared HitReaction cancels the current action, locks the Player, and returns Combat to READY.

3. **Enemy placeholder migration**
   - Replace Training Target with the non-attacking Enemy subclass while preserving permanent-target collision, status, VFX, and light-flinch presentation.
   - Do not add an Active mode, attack controller, or attack FSM.

4. **Air/Earth selection placeholders**
   - Add Air and Earth InputMap actions and active-school identities.
   - Apply white and brown outlines, ignore X/Y/L1 while either placeholder is active, and reject Air/Earth selections during an active Fire–Water combo.
   - Add no Air/Earth resolver, attack, defence, effect, Buff/Debuff, or HealthEvent behavior.

5. **Configuration and feedback**
   - Extend fail-fast JSON validation and Developer Overlay for Player/Enemy maximum Health, Fire/Water direct damage, Water’s five status-level entries, approved Impact, defensive-level, hit-reaction, defence, and Entity values.
   - Add diagnostic feedback for damage outcomes, reaction level, guard, parry, and Enemy status.

## Validation Seams and Open Evidence

Validate that:

- Player and Enemy inherit the same Entity foundation;
- Entity roots own internal component wiring, cross-Entity Health transactions use the synchronous Entity interface, and Arena wiring is limited to scene composition, configuration, and presentation observers;
- every direct and DoT damage instance produces an original-instigator-attributed damage HealthEvent with an explicit Impact;
- Fire Y’s direct event carries the DoT application instruction, while generated tick events carry no application instruction;
- Buff/Debuff preserves the original instigator across every periodic tick; any future HoT must obey the same attribution rule;
- Player and Enemy use the same HealthResolver implementation;
- Player and Enemy maximum Health initialize to 100, while functional Fire/Water X and Y direct damage initialize to 10;
- HealthResult records the actual signed Health delta and zero-reaching state;
- HealthResolver synchronously delivers HealthResult to the original instigator Entity before any zero-Health lifecycle reset;
- Enemy damage is capped at remaining Health, excess is discarded, and zero triggers a full lifecycle reset after synchronous result delivery;
- the refill creates no heal HealthEvent, emits no death, and preserves active Buff/Debuff state;
- Combat grants one Heat increment per unique direct Fire/Water X/Y result only when `health_delta < 0`;
- a zero-reaching direct result grants Heat from its negative delta before the lifecycle reset, while zero-delta, DoT, status, and future HoT results grant none;
- every primary or secondary Fire/Water specialty emits its genuine direct HealthEvent at the resolved level, in primary-then-secondary order;
- Water emits exactly one 10-damage, Impact-1 HealthEvent per unique area target with Wet at levels 1–2, Slow at levels 3–4, or Frozen at level 5;
- each target owns at most one Water status: higher replaces, equal refreshes without stacking, and lower is ignored while direct damage still resolves;
- each separate Fire or Water direct HealthResult grants Heat independently when `health_delta < 0`;
- Player Defence intercepts damage before Health without adding Player branches to HealthResolver;
- blocked and parried damage never reaches Health, while blocked Impact reaches HitReaction and parried Impact does not;
- accepted Fire/Water X and valid Fire/Water Y events use Impact 1, Fire DoT ticks use Impact 0, and the Enemy placeholder uses defensive level 0;
- HealthResolver calculates `max(0, Impact - defensive level)` for damage at contact identically for Player and Enemy, before resulting guard or action-state changes;
- final reaction level 0 does nothing, while levels 1 through 5 scale magnitude and recovery linearly;
- a new nonzero reaction ends and replaces the active reaction at full magnitude and duration, while level 0 leaves it unchanged;
- a nonzero Player reaction cancels the current action, locks actions and movement, then returns Combat to READY;
- DoT damage reaches Health but builds no Heat and causes no hit reaction;
- EffectState action suppression gates Player Combat without owning hit-reaction state;
- Movement consumes the final EffectState movement multiplier;
- AnimationPlayer speed follows the Heat multiplier in the current slice;
- guard break, L1 rearming, movement lock, and school-switch lock match the GDD;
- the Enemy placeholder preserves permanent-target behavior without a mode switch or attack FSM;
- Air/Earth selection applies white/brown outlines, ignores X/Y/L1, and cannot enter an active Fire–Water combo;
- no Air/Earth functional component or configuration silently selects deferred behavior;
- Developer Overlay edits remain debug-only and validated; and
- existing Fire/Water combo behavior remains unchanged.

Open evidence and risks:

- current source has not been reported as runtime-verified in Godot;
- current direct contact and DoT paths bypass HealthEvent and require migration into the shared resolver;
- migrating StaticBody2D target behavior into CharacterBody2D Enemy may affect collision and ShapeCast contact;
- the interaction between guard-break recovery and a simultaneous nonzero hit reaction remains deferred with incoming Enemy attacks;
- original-instigator attribution after the instigator Entity is freed remains an accepted preflight waiver;
- Player Health/death, healing semantics beyond the shared operation contract, and all active Enemy behavior remain deferred or open;
- all functional Air/Earth behavior remains deferred;
- high playback speed may cross narrow normalized phases within one update; and
- final defence, Enemy, and full-package Air/Earth assets are unavailable.

Diagnostic inventory: debug attack-hitbox sweep display owned by the Developer Overlay. It is toggleable and diagnostic-only.

## Handoff Recommendation

A fresh Ultron `mode=tech-preflight` audit is recommended before implementation. The verified GDD now defines Air/Earth as placeholders and defers the Active Enemy, while the report adds shared HealthEvent, HealthResolver, HealthResult, synchronous instigator delivery, HitReaction, periodic-effect attribution, finite dummy Health, zero refill, Health-based Heat ownership, and explicit reaction replacement. The audit should carry forward the accepted instigator-lifetime waiver. Air/Earth and Active Enemy omissions are now explicit scope, not unresolved technical claims.
