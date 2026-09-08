# Technical Design Report — Orb Casting and Tutorial Stage Architecture

Status: `READY_FOR_ULTRON_OR_DUM-E`

Repository basis: committed recovery baseline `6b06dc2` (`checkpoint: save cross-thread recovery state`), the current approved working-copy `docs/GAME_DESIGN.md`, and the current working-tree implementation. Commit `23fa85b` preserves the accepted U-001–U-007 corrections; `6b06dc2` remains the historical Stage 1–6 sequence-objective checkpoint.

The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01. No exact scenario matrix, tested-tree identity, or engine-version record was supplied. No agent-run Godot, build, compiler, or automated-test evidence exists.

## Scope and selected decisions

This report preserves the implemented side-scrolling Orb Casting combat baseline and records the reusable tutorial-stage framework through the combined Stage 7, ordered transitions into the existing Final Arena, the tutorial-only Elemental Endurance demonstration, and in-place free-practice completion state.

The Material Decision Ledger is closed:

1. **Direct generic Cast path.** `MagicComponent` resolves generic direct damage for the primary and optional secondary layers. Active prototype Casting does not read a spell loadout or dispatch school-specialty resolvers.
2. **Shared Entity feedback.** A reusable `FeedbackComponent` belongs to the base `Entity` contract. Target-side `HealthResult` handling displays final direct-hit damage, including `0` for a fully resisted Cast layer; it displays the school-and-level label only for a direct Cast layer whose final loss is negative. Applied DoT ticks use the same final `health_delta` with a smaller number and no Cast-level label.
3. **Stages 1–7 preserve the committed combat schema.** The current continuous Heat and generic-Cast schema remains authoritative. Legacy Fire/Water/Air/Earth effect fields and their Developer Portal controls remain dormant but intact; their previously accepted strict removal is deferred to a separate future cleanup slice.
4. **Dedicated commitment-to-Heat interface.** After successful orb consumption and immutable payload storage, Magic emits one internal commitment fact carrying `commit_id` and `consumed_count`. Combat receives it synchronously and grants Heat exactly once. Promotion, launch, interruption, discard, and impact do not emit this fact.
5. **Last-in primary and single-secondary ordering.** The final consumed orb selects the primary school, whose level equals total consumed orbs. The highest-count remaining school becomes the optional secondary; a secondary tie selects the school appearing latest in the consumed sequence. Impact and feedback resolve primary first, then secondary.
6. **Pressure state owns chain preservation.** Magic reports CHARGING and the 5–95% intermediate band as chain-preserving states independently of queue contents, charged count, and partial progress. CHARGING banks capacity while the queue is empty; the intermediate band waits 0.3 seconds before DEPLETING begins, resets that timer on return to CHARGING, and remains preserving at zero progress until R2 leaves the band. Might consumes this state for timeout and between-action movement decisions.
7. **Shared configured feedback lifetime.** Both Entity scenes configure their `FeedbackComponent` from `ui.cast_feedback_duration`, default `2.0` seconds and validated from `0.1` through `20.0`. Developer Portal live tuning affects future entries only; each visible entry retains the duration captured when it was created.
8. **Initial RELEASE is side-effect-free.** The first raw-pressure sample always establishes Magic's initial pressure state. If that state is RELEASE, initialization emits no Cast request or failure. Only a later transition from CHARGING or the 5–95% intermediate band into RELEASE dispatches one Cast attempt; initial CHARGING begins charging generated orbs and an initial intermediate-band sample begins its no-drain timer.
9. **Persistent tutorial root and reusable Stage Areas.** Player, HUD, audio, StageDirector, and an Arena-owned camera persist. Physical stage content is supplied by independently instantiated Stage Area scenes.
10. **Declarative objectives and generic rows.** StageDirector owns lifecycle, merges evaluator-owned row state with descriptor-owned presentation rows, and delegates Stage 1–6 attempt state to `SequenceObjectiveEvaluator`. Combined Stage 7 uses the Heat-gated sequence evaluator with independent Heat and chain rows. HUD never interprets combat outcomes.
11. **Scene-plus-JSON stage definitions.** Stage Area `.tscn` scenes own physical content; the validated prototype JSON owns ordered descriptors, objective type, UI content, and evaluator parameters.
12. **Player transition facade.** Arena locks input and requests one ordered combat reset through Player rather than reaching into Player components. Active school is preserved.
13. **Current-plus-next Stage Area lifetime.** Only the active and next areas coexist during a transition. Completed non-final areas unload after the next stage activates; the final arena remains indefinitely.
14. **Reusable ObjectiveWidget.** A HUD-owned UI component renders any number of descriptor rows, each with label, optional tokens, progress/highlight, and completed/default state, plus whole-widget invalidation and completion presentation.
15. **Node-based evaluator lifetime.** StageDirector creates one Node evaluator per active stage. It consumes immutable outcomes, may advance with time, and is discarded on stage change.
16. **Normalized chain termination.** Might publishes one immutable `chain_terminated` outcome exactly once whenever an active InputCombo ends, carrying its termination reason. Sequence evaluators consume this fact rather than reconstructing chain lifetime from specialized outcomes.
17. **Prepared-stage isolation.** Completion preloads only the next PackedScene resource. Arena instantiates its nodes after exit/input lock in a PREPARED state with combat and outcomes dormant, clears root-owned projectiles, and promotes the area to ACTIVE only after the pan and objective evaluator are ready.
18. **Anchor-aligned Stage Area placement.** Arena owns Stage Area world transforms and aligns the next area's local EntryAnchor to the current area's world-space ExitAnchor. Each area supplies its own spawn, camera target, and horizontal camera bounds.
19. **Configured transition duration.** Arena captures `tutorial.transition_duration` when a pan begins. The default is `1.0` second, valid from `0.1` through `5.0`; live tuning affects future transitions only.
20. **Normalized Cast-attempt evidence.** Might assigns one `attempt_id` to each Cast attempt. Accepted actions and their later launched/failed/discarded terminal facts carry that ID, so objectives advance only on the correct terminal result rather than on input acceptance or projectile impact.
21. **Shared training-area content.** Stages 1–7 instantiate independent copies of one shared training-area scene. Each instance owns its dummy, floor, anchors, gate, trigger, and lifecycle while stage-specific rules remain entirely data/evaluator-owned.
22. **Descriptor-owned selector naming.** Every stage descriptor owns a non-empty `display_name`; Developer Portal options use that field rather than a presentation-row label.
22. **Generating/Charging terminology boundary.** Player-facing design and HUD use Generating/generated orbs and Charging/charged orbs. The runtime pressure state and persisted threshold remain `CHARGING`/`trigger_charge_min`; private identifiers using `marked` remain compatibility details only.
23. **Tutorial-only Elemental Endurance.** Final Enemy `StatusController` owns the active school, capped hit count, action cache, and current multiplier. `MightComponent` supplies one `source_action_id` per X/Cast action and forwards it through committed Cast payloads. `HealthResolver` obtains the multiplier before applying Health, emits the full-resist tag when a direct action reaches zero, suppresses new effects at zero, and returns the actual `health_delta` for presentation. DoT reads the current multiplier without changing the streak.
24. **First active Final Enemy and Player Health floor.** `CombatEnemy` owns the one-pattern AI and final-Enemy-only solid collision. `HealthComponent` owns the optional minimum Health invariant; Player applies the validated, Developer-Portal-backed `player.one_hp_floor_enabled` flag. Changing the flag affects future damage only and never heals.
25. **Eight-level Charging through the existing Magic owner.** `MagicComponent` retains the ten-orb FIFO queue and config-driven charged prefix. The approved target raises `casting.max_marked_capacity` from five to eight without changing storage order, expiration, depletion, failure, or consumption ownership. The current five-position X/Cast chain remains independent.
26. **Spell Level remains derived presentation.** The existing `queue_changed(snapshot, marked_count, marking_progress)` path carries both the per-orb charged flags and private banked-capacity progress; its `marked_count` argument currently represents banked capacity and is not always the number of stored orbs actually charged. `PrototypeHUD` derives Spell Level `0..8` by counting charged flags in the snapshot, keeps all ten storage slots visible, and continues using banked capacity plus partial progress over eight for the charging-progress bar. No duplicate Spell-Level state or new event is introduced.
27. **One-octave charged-orb cue with ordered boundary delivery.** Player retains local ownership of the fixed-volume charged-orb cue. Its discrete pitch table expands to the eight-step major scale `Do–Re–Mi–Fa–Sol–La–Ti–Do`, represented by pitch ratios `1`, `9/8`, `5/4`, `4/3`, `3/2`, `5/3`, `15/8`, and `2`. On each queue snapshot, Player compares the previous and current visible charged-orb counts. Every crossed upward boundary is appended once, in ascending order, to a Player-owned presentation FIFO; the FIFO plays those cues without overwriting an earlier queued note and never blocks gameplay. Unchanged or decreasing counts enqueue nothing, charge transfer that preserves the visible count produces no cue, and Player teardown or stage combat reset clears pending presentation cues. This preserves one note per newly charged visible orb even when a single update crosses multiple Charging boundaries, without changing Magic's timing or adding gameplay state.

Excluded from this implementation slice: distinct school-level spell behavior for Levels 6–8, additional Enemy attacks or behaviors, legacy school-effect configuration/Portal cleanup, defence redesign, Air/Earth defence, Player defeat behavior while the 1-HP Floor is disabled, final presentation, asset remapping, save/resume persistence, and final numerical tuning.

## Implemented codebase map and postflight basis

```text
PrototypeArena                              persistent root
├── Arena-owned Camera2D
├── Player / CombatComponent
│   ├── MightComponent
│   ├── MagicComponent
│   ├── HeatComponent
│   └── DefenceController
├── StageDirector / active evaluator
├── StageAreas
│   ├── active StageArea
│   └── next StageArea during transition
├── PrototypeHUD / ObjectiveWidget / Developer Portal
└── audio and projectile orchestration
```

Static inspection of the current working candidate confirms the combat baseline, Stage 1–7 tutorial descriptors, active Final Enemy candidate, and Elemental Endurance path are implemented:

- `prototype_arena.tscn` is the persistent root; Stages 1–7 instantiate independent copies of `training_area.tscn`, while `final_arena.tscn` owns the final combat area.
- Arena owns the active `Camera2D`, Stage Area placement, transition pan, current-plus-next lifetime, projectile cleanup, and activation ordering.
- `StageDirector` owns the stage lifecycle and delegates Stage 1–6 sequence logic plus the combined Stage 7 Heat-gated sequence to configured evaluators; the Final Arena retains its final-enemy evaluator.
- `prototype_combat.json` contains validated ordered descriptors for Stages 1–7 plus the Final Arena, descriptor-owned display names, generic presentation rows, and a Portal-persisted default-stage selector.
- `PrototypeHUD` instantiates the reusable `ObjectiveWidget` for progress, invalidation, completion, and free-practice presentation.
- Player exposes the stage input-lock and ordered combat-reset boundary while preserving the selected school.

The current HUD uses generated-orb and charging/charged presentation terminology. Private `marked` fields remain internal compatibility data; no terminology-only implementation delta remains.

Might publishes normalized light-contact, action, Cast-attempt, school-switch, and chain-termination facts while preserving specialized outcomes where useful. The sequence evaluator consumes only immutable outcomes and stage data; `orb_without_contact` is never a physical hit. No second tutorial event bus exists.

The accepted U-001–U-007 postflight corrections are committed in the recovery baseline. The user reported the complete Stage 1–6 flow confirmed; a fresh postflight is still required before submission.

## Implemented ownership

### Might, Magic, Heat, and Combat

`MightComponent` continues to own action eligibility, X/Cast timing, the one-slot earliest-request buffer, chain progression, animation/contact/launch phases, and action-caused movement locks. It decides whether a release-Cast request is normal, empowered, buffered, an endpoint Cast, or a timing failure. After an action and when evaluating timeout, Might reads Magic's pressure-state preservation contract rather than deriving preservation from queue or meter values. Because Might orders every InputCombo exit, it also publishes one `chain_terminated` outcome exactly once per active-chain termination, including a reason for timeout, completion, failed Cast, or interruption.

`MagicComponent` owns the ten-orb FIFO queue, front-orb lifetime, config-driven charging capacity, pressure state, CHARGING and DEPLETING progression, Cast composition, immediate consumption, and immutable committed payloads. The approved target capacity is eight; the current working-copy configuration and exact loader guard still use five until this slice is implemented. Its first raw-pressure sample establishes the initial state before transition behavior is allowed. Initial RELEASE is side-effect-free; initial CHARGING or DEPLETING may begin ordinary state behavior. Its current pressure state is the sole preservation authority: CHARGING and DEPLETING preserve the chain; RELEASE does not. This state remains authoritative even when the queue, charged count, and partial progress are all zero. Only after a successful commitment has consumed its charged prefix and stored its payload does Magic emit a dedicated internal commitment fact containing `commit_id` and `consumed_count`. Failed commitment attempts emit nothing.

`HeatComponent` remains the sole owner of the `0..100` Heat value, the `100%..150%` multiplier, loss, Water-block drain, the five-second reset timer, and subsequent three-per-second depletion. `CombatComponent` subscribes to Magic's dedicated commitment fact during configuration and synchronously routes `consumed_count` to Heat once. Might reads the resulting multiplier for X/Cast animation timing; Magic reads it only for CHARGING speed.

`CombatComponent` remains a thin facade. It forwards Player/HUD/Arena-facing signals and orders cross-component transactions without duplicating Might, Magic, Heat, queue, or feedback state. Generic public `CombatOutcome` events remain observational and never drive the authoritative Heat mutation.

### Entity feedback

The base `Entity` script owns a required `FeedbackComponent` reference alongside Health, Status, and HitReaction. The project uses a shared base script rather than a shared inherited Entity scene, so both Player and Enemy scenes compose their own `Feedback` child satisfying that contract.

`FeedbackComponent` owns transient entity-local feedback entries and their expiration. It is separate from `StatusController`: Cast-level text is presentation evidence, not a buff, debuff, or gameplay status. The base Entity configuration injects `ui.cast_feedback_duration` into each Player and Enemy component. Every entry captures that duration at creation, so a live tuning change affects only later entries and never extends or truncates feedback already visible.

`HealthResolver` delivers each `HealthResult` first to the target and then, when distinct, to the instigator. Player and Enemy gate feedback on `result.event.target == self`, preventing duplicate target/instigator numbers. Applied direct damage displays the final negative `health_delta` as a normal-size number, including `0` after direct full resistance. Magic retains `<School> Lv.<N>` only when its direct Cast layer is applied with a negative loss; a fully resisted Cast layer therefore has a `0` number without a school/level label. Applied `DOT_TICK` events display the same final post-modifier loss through the smaller DoT-number path and never create a Cast-level label. FeedbackComponent clamps new transient labels to the viewport at creation; persistent Enemy Health and status readouts remain world-attached above their owner.

### Elemental Endurance

Elemental Endurance is enabled only when base Enemy configuration identifies the Final Enemy. `StatusController` owns the enabled flag, active school, capped hit count, cached source-action multiplier, and snapshot values used by the overhead badge. For a direct damage event, `HealthResolver` resolves defence first and calls `StatusController.resolve_elemental_endurance()` only for an `APPLIED` result. The returned multiplier is applied before `HealthComponent.apply_damage()`; the latter remains the source of the final delta, including any Player minimum-Health cap.

`MightComponent` allocates one `source_action_id` for each light action. It supplies that ID and single-school composition to each physical X contact, and writes the same ID into the committed Cast payload that `MagicComponent` forwards to both primary and optional secondary layers. StatusController uses the shared action ID to count one action at most once; a mixed Cast clears the streak instead. At zero multiplier, HealthResolver tags the direct result `elemental_endurance_full_resist`, suppresses new effect instructions, and leaves actual loss at `0`. Might reads that tag to withhold orb generation while Combat still refreshes Heat for the landed direct hit and the normal Impact/hit-reaction path remains available. DoT ticks read the current multiplier for their school but do not advance, reset, or replace the streak.

Enemy builds the active-school Endurance icon and remaining percentage from the StatusController snapshot. It hides the badge at 100%; direct and DoT feedback use the resolved final loss rather than the requested damage.

### First active Final Enemy and Player Health floor

`CombatEnemy` extends the base Enemy with one `DORMANT -> IDLE -> APPROACH -> WINDUP -> RECOVERY` loop and a terminal `DEAD` state. While the Portal-backed `enemy_ai.enabled` setting and active-stage state both permit it, it approaches within range, captures the ShapeCast origin and target vector at windup start, then resolves that frozen geometry after windup. Movement after commitment can therefore produce a complete miss. Hits and misses enter the same configured recovery; an ordinary landed Player hit updates feedback/reaction but does not interrupt the committed Enemy attack. The Final Enemy alone enables the solid collision layer while active; its death removes that layer. Training targets remain pass-through detection targets.

`HealthComponent` owns a configurable `_minimum` Health bound and caps damage at `current - minimum`. Player sets that bound to `1` when `player.one_hp_floor_enabled` is true and `0` otherwise, both during configure and later Portal runtime tuning. This setting is validated and persisted through the existing configuration path. Toggling it changes only future damage calculations; it never changes current Health or creates a Player defeat/restart state.

### Arena and projectile

The persistent tutorial root retains the `PrototypeArena` script's orchestration role: it owns Player, HUD, audio, projectile spawning/impact routing, StageDirector, Stage Area lifetime, and the transition camera. `SpellProjectile` continues to own travel, maximum distance, first-valid-target collision, and blended presentation. It carries the immutable resolved Cast payload rather than reading the live orb queue later.

The payload carries an explicit primary school and level plus one optional secondary school and level. It also retains empowered state, the primary-only damage multiplier, original instigator, direction, and the information needed to derive color weights. The final consumed orb always selects the primary school; primary level equals total consumed orbs and therefore extends through Level 8 under the approved capacity. After excluding the primary, the highest-count remaining school becomes secondary. A secondary-count tie selects the tied school appearing latest in the consumed sequence. Other represented schools create no layer, although their orbs remain consumed and still contribute to primary level and commitment-time Heat. Existing integer payload fields and generic direct-damage resolution require no schema or ownership change for Levels 6–8.

Impact resolution is ordered: primary first, optional secondary second. Feedback presentation uses that same order. This preserves one deterministic sequence across payload construction, HealthEvents, immediate target refill, hit reactions, and Cast-level labels.

### Tutorial root, Stage Areas, and camera

```text
Persistent TutorialRoot / PrototypeArena
├── Player                                persists across stages
├── Camera2D                              Arena-owned
├── HUD
│   └── ObjectiveWidget
├── StageDirector                         authoritative stage FSM
├── CurrentStageArea
├── NextStageArea                         present only around transition
└── audio / projectile infrastructure

StageArea
├── physical floor and backdrop
├── EntryAnchor marker
├── ExitAnchor marker
├── PlayerSpawn marker
├── CameraAnchor marker
├── CameraBounds markers / local horizontal range
├── RightGate collision
├── ExitTrigger
└── stage-owned targets/enemies
```

Stage Area scenes own physical content only. Their shared public contract exposes local EntryAnchor and ExitAnchor positions, PlayerSpawn and CameraAnchor positions, local horizontal camera bounds, gate lock state, exit event, stage-owned Entity set, and one lifecycle state: PREPARED, ACTIVE, or RETIRED. Each area’s flat ground section is authored at the shared ground height and extends far enough to overlap the adjacent area’s ground at the anchor-aligned boundary. They do not evaluate objectives, mutate Player combat state, drive HUD, select the next stage, or choose their own world transform.

Arena owns placement. The first Stage Area is positioned with its EntryAnchor at the tutorial root's initial world origin. For every later area, Arena computes the Stage Area root transform so the next local EntryAnchor coincides with the current world-space ExitAnchor. All spawn, camera, gate, trigger, floor, and Entity coordinates then follow from that single transform. No fixed global stage width or stage-spacing assumption exists.

PREPARED displays the area's environment and supplies floor collision needed for the waiting Player, but every stage-owned combat Entity has combat collision, Health-event reception, and gameplay processing disabled. Arena has not yet connected Entity outcomes to StageDirector. ACTIVE enables stage-owned combat and exit behavior only after the evaluator and outcome subscriptions exist. RETIRED disables all interaction immediately and precedes unloading.

Stage-owned Enemy bodies remain on the target-detection layer used by X and projectiles. Training dummies do not mask the Player body and remain pass-through. The active Final Enemy additionally enables its solid collision layer, so Player cannot pass through it while its AI is active; the layer is disabled when the Final Enemy dies or its AI/stage activation is disabled.

The existing `prototype_arena.tscn` is split mechanically: its final-arena geometry and four target instances move into the Final Arena Stage Area, while its Player, HUD, audio, StageDirector, projectile routing, and new Arena-owned Camera2D remain in the persistent root. Final Arena contains three permanent, refillable, pass-through practice targets and one solid, killable Final Enemy. The shared training Stage Area contains one permanent refill target plus its own gate/exit markers.

The Arena-owned camera has two modes. During an active stage it follows Player horizontally while clamped to the active Stage Area's transformed horizontal camera bounds and fixed vertical framing. During transition it stops following Player and pans to the transformed next CameraAnchor. Laema exits the old frame under ordinary movement; after exit, Arena locks Player input, repositions Laema to the transformed next PlayerSpawn during the pan, and reveals her waiting when the camera arrives.

The current-plus-next rolling window is authoritative. On completion, Arena loads only the next PackedScene resource; no next-stage nodes enter the tree while the player remains free in the completed area. After exit and input lock, Arena instantiates that resource as PREPARED and keeps both areas loaded during the pan. It unloads the completed non-final area only after next-stage activation. The Final Arena remains loaded after tutorial completion.

### StageDirector and objective evaluators

StageDirector owns one explicit lifecycle FSM:

```text
ACTIVE
  -> COMPLETED_WAITING_FOR_EXIT
  -> TRANSITIONING
  -> ACTIVE (next stage)

FINAL_ACTIVE
  -> FREE_PRACTICE
```

StageDirector owns stage order, active descriptor, completion latch, evaluator lifetime, gate authorization, and ObjectiveWidget presentation snapshots. Arena reports physical milestones—exit reached and camera pan finished—through dedicated lifecycle interfaces. Those milestones do not travel through `CombatOutcome`.

Each active stage has one Node-based objective evaluator created from a closed evaluator-type registry. The evaluator consumes immutable CombatOutcomes, may receive elapsed time for future timed lessons, and returns only objective-domain results: unchanged, progress changed, attempt invalidated, or objective completed. StageDirector discards the evaluator at stage change. Evaluators never load scenes, control gates/camera, reset Player, or draw UI.

### Player transition facade

Player exposes one stage-transition boundary to Arena. It provides all-gameplay-input lock/unlock and one ordered stage reset. The reset cancels active and buffered actions, clears chain, queue, marks, Heat, statuses, hit-reaction suppression, and defence state, restores full Health, and leaves the active school unchanged. Arena never calls Might, Magic, Heat, Status, Health, or Defence directly.

The reset occurs while input is locked and before the next stage becomes ACTIVE. After Stage 1, the school selected at exit is therefore the school shown when the Final Arena appears.

### ObjectiveWidget

`ObjectiveWidget` is a reusable HUD-owned Control scene. StageDirector supplies immutable presentation snapshots containing generic rows with stable id, label, optional tokens, evaluator-owned progress/highlight/completed state, attempt invalidation, whole-widget completion state, and prompt text. The widget owns only rendering and its light UI-only flinch. It never consumes CombatOutcome or stage nodes.

The widget occupies the upper-right gameplay-UI region. When the developer overlay is visible, its R2 pressure panel is laid out below the objective widget. This preserves both GDD placements without overlap.

## Core flows and contracts

### Stage 1 objective evaluation

Stage 1's evaluator is registered as the five-hit Fire-chain objective. It receives the existing immutable combat outcomes and maintains only `attempt_active` and the number of valid landed Fire X hits.

```text
Stage 1 activation
  -> Fire is selected for initial startup
  -> one refill target is configured
  -> right gate is locked
  -> ObjectiveWidget: "perform a 5 hit combo" / X-X-X-X-X

light_contact_resolved
  -> result hit + Fire:
       if no attempt: begin attempt
       advance one green X
       fifth valid hit: complete permanently
  -> result miss or orb_without_contact:
       if Fire or attempt already active: invalidate/flinch/reset
       otherwise: unchanged
  -> result hit + non-Fire while attempt active:
       invalidate/flinch/reset
  -> result hit + non-Fire before attempt:
       unchanged

action_accepted
  -> Cast while attempt active: invalidate/flinch/reset

school_selected / school_switched / unrelated outcome
  -> unchanged

chain_terminated while attempt active
  -> if objective already completed: ignore
  -> otherwise: invalidate/flinch/reset for every termination reason
```

The objective uses physical `light_contact_resolved` evidence rather than accepted input or orb creation. Completion is latched before the subsequent `chain_terminated` fact can arrive. Once complete, the evaluator ignores later combat and StageDirector unlocks the Stage 1 right gate while publishing the green widget plus `moving on ->`.

### Declarative Stage 1–7 evaluation

Stages 1–6 share one data-driven `SequenceObjectiveEvaluator`. Each descriptor supplies ordered `success_steps`, optional prestart and active invalidation flags, completion progress, a stable sequence-row id, and whether the next expected token is highlighted. The evaluator maintains only PRESTART/ACTIVE/COMPLETED phase, progress, and one pending Cast attempt ID; it exposes the dynamic state for its configured row id.

- **Stage 1:** five landed Fire X steps; a Fire miss invalidates even before progress.
- **Stage 2:** one Cast step requiring level 5. The evaluator waits for the matching Cast-attempt terminal fact; only `launched` at level 5 succeeds. Any non-launched terminal or launched lower-level Cast invalidates. Projectile impact is irrelevant.
- **Stage 3:** five landed X steps followed by a level-5 endpoint Cast launch. Its presentation instructs `Hold R2 + X -> X -> X -> X -> X -> Release R2`; compact token rendering accommodates the longer first and final labels. R2 timing remains guidance and is not evaluated.
- **Stage 4:** `X -> X -> Cast -> X`, with the Cast occupying chain position 3 and the final X occupying position 4.
- **Stage 5:** `X -> Cast -> X -> Cast`, with Casts occupying positions 2 and 4; the second launch completes the objective.
- **Stage 6:** `X -> X -> school switch -> X -> X -> X`; the accepted switch must occur at chain position 2, and rejected or mistimed switches invalidate the active attempt.
- **Stage 7:** the Heat-gated sequence evaluator exposes a Heat row and chain row. Heat at or above 80 marks only the Heat row complete. A chain attempt begins only on landed position-1 X at or above threshold; its five landed X steps advance the chain row. Miss, premature termination, or dropping below threshold during an attempt resets/flinches the chain row, while a pre-attempt Heat drop updates only the Heat row. X5 completes the stage.

Unexpected actions follow each descriptor's phase rules. Prestart `ignore_unexpected` allows the player to prepare freely where approved. Once an attempt is active, a wrong expected step, an applicable rejected switch, or `chain_terminated` invalidates and resets only the objective attempt. Completion remains latched permanently.

### Stage transition and final arena

```text
Stage 1 completion
  -> StageDirector latches completion and authorizes gate unlock
  -> Arena preloads Final Arena PackedScene resource only
  -> player exits Stage 1 to the right
  -> StageArea reports exit reached
  -> StageDirector enters TRANSITIONING
  -> Arena locks Player input and releases active combat safely
  -> Arena clears every root-owned SpellProjectile and other transient combat object
  -> Arena instantiates Final Arena as PREPARED
  -> Arena aligns Final Arena EntryAnchor to Stage 1 world ExitAnchor
  -> Camera2D pans to Final Arena anchor
  -> Player is repositioned to Final Arena spawn
  -> Player facade resets all combat state except active school
  -> Arena reports pan finished
  -> StageDirector creates Final Arena evaluator
  -> Arena connects Final Arena Entity outcomes
  -> Arena promotes Final Arena to ACTIVE
  -> StageDirector publishes Final Arena objective
  -> input unlocks and Stage 1 area unloads
```

The Final Arena evaluator retains the existing `final_enemy_defeated` success fact. On success, StageDirector enters `FREE_PRACTICE`, keeps the Final Arena loaded, leaves its permanent practice targets available, and immediately publishes `now you are free` with no progress row. No gate unlock, scene transition, delay, or intermediate completion presentation occurs.

### Queue and R2 pressure

```text
X contacts an Enemy
  -> Magic attempts to append that school orb
  -> queue below 10: append and publish the new snapshot
  -> queue at 10: discard only the new orb and publish overflow feedback

R2 >= 95%
  -> CHARGING advances at the current Heat multiplier
  -> banks charging capacity up to eight even when no generated orb is available
  -> marks the oldest available orbs covered by that capacity
  -> preserves the chain and releases movement between actions

5% <= R2 < 95%
  -> enters a 0.3-second no-drain intermediate hold
  -> returning to CHARGING before the timer expires resets that timer
  -> only a continuous hold beyond 0.3 seconds starts DEPLETING
  -> DEPLETING drains at the fixed baseline charge-step rate
  -> partial progress drains first
  -> completed boundaries return newest charged orbs to generated state first
  -> remains chain-preserving even after progress reaches zero
  -> releases movement between actions

R2 < 5% on state entry
  -> stops pressure-state preservation
  -> one Cast attempt only when this is a later transition
```

Before evaluating these transitions, Magic classifies the first raw-pressure sample and stores it without dispatching RELEASE behavior. This prevents a resting trigger from producing a startup Cast failure. Initial CHARGING activates ordinary charging; an initial intermediate-band sample starts its no-drain timer. After initialization, only a change from CHARGING or the intermediate band into RELEASE dispatches one Cast attempt.

Magic exposes one pressure-preservation result to Might. Might uses it after an animation and for idle-timeout eligibility. Queue size, charged count, and partial progress are presentation/resource values and never substitute for this state result. Active X and Cast animations remain movement-locked; Combat releases movement only between actions while Magic reports CHARGING or DEPLETING.

Only the front queue orb counts down. Consumption or expiration shifts the remaining queue forward and starts the new front orb at its full lifetime. Charging coverage transfers with the shifted queue when enough generated orbs remain.

A failed Cast ends the chain, returns every charged orb to the generated state, and resets partial charging progress to zero without removing queue contents. An incoming direct-damage `HealthResult` qualifies for the resource-loss transaction only when its outcome is `APPLIED`: Magic removes currently charged orbs, preserves generated-orb order, and resets charging progress. `BLOCKED`, `PARRIED`, and DoT results do not enter this transaction. Final reaction strength is not part of the predicate. Orbs already consumed by a committed Cast are never refunded.

Magic publishes enough queue state for the HUD to render all ten slots, current contents, charged state, front lifetime, and charging progress. Overflow reaches the HUD through the existing Combat/Player presentation path and restarts the whole-widget flinch from rest. Current private payload keys may remain `marked` during this candidate; the HUD presents them as charged state.

### Commitment, buffering, and Heat

```text
Might accepts a normal/windowed/buffered release-Cast
  -> Magic consumes the charged FIFO prefix immediately
  -> Magic resolves the last-in primary and optional majority secondary
  -> immutable Cast payload is stored under one commitment
  -> Magic emits one internal commitment fact
  -> Combat grants Heat from its consumed_count immediately
  -> Might launches that payload at the Cast contact phase
```

A buffered Cast commits before its later promotion. The dedicated fact is emitted during commitment, not promotion, launch, interruption, discard, or impact. Those later transitions therefore cannot duplicate or revoke the Heat gain. If the action is interrupted before launch, its payload is discarded without refund; the Heat already granted at commitment remains. A projectile miss likewise does not revoke Heat.

Heat is stored as an absolute `0..100` value, producing a continuous `1.00..1.50` attack-speed multiplier. Each committed consumed orb grants two Heat, so an eight-orb Cast grants 16 Heat before the existing `0..100` clamp. The same incoming `APPLIED` direct-damage result that triggers charged-orb removal also removes five Heat with a zero-point floor. `BLOCKED`, `PARRIED`, and DoT results remove none, regardless of reaction strength. Five seconds after the latest qualifying direct hit or Cast commitment, Heat depletes at three per second until zero. Loss and Water-block drain do not create Heat or change its authority.

Direct X hits, projectile impact, feedback, and deferred school effects grant no Heat. There is no independent Air speed buff or Air-specific Heat source in this prototype.

### Generic projectile impact and feedback

```text
SpellProjectile contacts a valid Entity
  -> Combat routes the frozen payload to Magic
  -> resolve the primary, then the optional secondary:
       create one direct-damage HealthEvent
       use combat.casting_damage and combat.direct_impact
       apply the empowered multiplier only to the primary layer
       resolve through the target's shared HealthResolver
       if HealthResult is APPLIED and health_delta is negative:
           publish <School> Lv.<N> through target FeedbackComponent
  -> projectile disappears
```

The direct path does not read `spell_loadout`, call a school resolver, or create a status instruction. A mixed Cast intentionally produces one generic damage event and one feedback entry for the primary and optional secondary layers, in that order. A blocked, parried, invalid, zero-damage, interrupted, or missed layer produces no Cast-level display. Existing HealthEvent instigator, school, Impact, contact direction, and contact point attribution remain intact.

## Configuration, persistence, and UI

The tutorial subsection of `config/prototype_combat.json`, `PrototypeConfigLoader`, and the new transition-duration control change through the existing fail-fast save/load pipeline. Existing combat, school, audio, and UI configuration outside the exact tutorial additions remains unchanged. There is no player-profile migration.

The active Heat schema is:

```yaml
heat:
  max_heat: 100
  gain_per_charged_orb: 2
  loss_per_direct_hit: 5
  reset_timer: 5
  depletion_per_second: 3
```

The active shared feedback-lifetime field is:

```yaml
ui:
  cast_feedback_duration: 2.0
```

`ui.cast_feedback_duration` must be numeric from `0.1` through `20.0` seconds. It follows the same fail-fast save/load path as the existing UI duration. Player and Enemy receive the value during Entity configuration and forward later runtime-tuning changes to their Feedback components. A changed value applies to future entries only; active entries retain their captured expiry.

The tutorial section uses an ordered declarative sequence grammar. Its current shape is:

```yaml
tutorial:
  initial_school: fire
  transition_duration: 1.0
  stages:
    - id: stage_1
      area_scene: res://scenes/stages/training_area.tscn
      objective:
        type: sequence
        label: perform a 5 hit combo
        tokens: [X, X, X, X, X]
        success_steps: [fire X, fire X, fire X, fire X, fire X]
        completion_progress: 5
    - id: stage_2
      area_scene: res://scenes/stages/training_area.tscn
      objective:
        type: sequence
        label: perform a level 5 spell
        tokens: []
        success_steps: [level-5 Cast launch]
        completion_progress: 0
    - id: stage_3 ... stage_7
      area_scene: res://scenes/stages/training_area.tscn
      objective:
        type: sequence
        success_steps: <ordered approved light/Cast/switch steps>
    - id: final_arena
      area_scene: res://scenes/stages/final_arena.tscn
      final: true
      objective:
        type: final_enemy
        label: Defeat the final Enemy.
        encounter_id: final_enemy
      free_practice_presentation:
        rows: [{id: free_practice, label: now you are free}]
```

The loader requires a non-empty ordered stage array, unique non-empty stage IDs and display names, loadable PackedScene paths, exactly one final stage at the end, known evaluator types, generic non-empty presentation rows, and evaluator-specific required fields. Every row has a unique non-empty id, non-empty label, and optional string-token array. Sequence objectives require a non-empty `success_steps` array, valid step types (`light`, `cast`, `switch`), valid optional school/level/endpoint/chain-position fields, phase rule dictionaries, numeric completion progress, and optional highlight behavior. The approved eight-level slice expands the generic `required_level` validation range from `1..5` to `1..8`; existing Stage 2 and Stage 3 descriptors remain Level 5. `initial_school` must be functional. `transition_duration` must be numeric from `0.1` through `5.0` seconds. The obsolete flat tutorial shape and superseded evaluator types are rejected.

The fixed `100%` baseline is behavior, not configuration. The committed continuous-Heat schema remains unchanged; the superseded discrete Heat and independent Air-speed fields remain absent and rejected.

Casting configuration retains the committed timing, pressure, projectile, and ten-orb storage fields. The approved slice changes `casting.max_marked_capacity` to the exact invariant `8`; `PrototypeConfigLoader` and the Developer Portal's fixed range must accept that invariant instead of five. Existing saved project configuration using five is intentionally stale and must fail fast until synchronized to eight; no migration path is introduced. `spell_loadout` remains absent. The persisted key `max_marked_capacity` remains a private compatibility detail for this prototype; game-facing terminology is charged capacity. The currently persisted Fire DoT, Water status-level, Air chain-lightning, Earth area/Slow, and related school-effect fields remain validated and exposed through their existing Portal controls, but generic prototype Casting does not read or dispatch them. Removing those dormant fields and dependent paths is a separate future cleanup slice.

The Developer Portal keeps its General, Audio, and Combat organization. General → UI exposes `cast_feedback_duration` and `tutorial.transition_duration` beside the existing presentation duration. Transition-duration changes persist through the existing JSON path; each pan captures the value at start, so live changes affect future transitions only. Audio presents `0–100%` linear volume controls, converts them to the existing persisted `audio.<group>.volume_db` values, and leaves Arena's AudioServer bus application unchanged; `0%` stores the validated silence floor of `-80 dB`, while `100%` stores `0 dB`. On load, any legacy saved audio value above `0 dB` is normalized to `0 dB` in memory; it is durably rewritten only when the user next saves the configuration. Player owns the fixed-volume MarkAudio playback and selects the discrete Do–Re–Mi–Fa–Sol–La–Ti–Do pitch table from visible charged-orb count; Player and base Enemy own the shared SFX-bus hit-reaction cue. Existing Combat-tab school controls remain untouched and dormant where their effects are deferred.

The always-visible HUD renders ten generated-orb slots even when empty, a gold outline on charged orbs, the charging-progress bar, the front-orb lifetime, and a Spell Level readout derived by counting charged snapshot entries. Spell Level ranges from `0` through `8`; the charging-progress bar separately uses banked capacity plus partial progress over the same eight-level denominator, including when Charging was banked before enough generated orbs existed. Slots nine and ten may remain generated and uncharged. Private snapshot fields and the private `marked_count` capacity argument may remain for compatibility. The overflow signal drives the whole-widget horizontal flinch. The developer telemetry rail shows live Health, Enemy Health, Heat, speed, defence, school/chain, event confirmations, and raw R2 pressure; its visibility remains Portal-controlled.

## Implementation slices and validation seams

1. **Persistent root and Stage Areas:** Player/HUD/audio/projectile orchestration persists in the root; Arena owns the Camera2D; Stages 1–7 instantiate the shared training-area contract and Final Arena uses its dedicated scene.
2. **Stage configuration and lifecycle:** the flat tutorial schema is replaced by validated ordered stages with display names, generic presentation rows, evaluator configuration, StageDirector lifecycle, and the current-plus-next loading window.
3. **Objective evidence, evaluation, and presentation:** normalized light/Cast-attempt/switch/termination facts, Stage 1–6 sequence plus combined Stage 7 Heat-gated evaluation, final-enemy evaluation, immutable row snapshots, and ObjectiveWidget are implemented.
4. **Player transition boundary:** Player exposes input lock and ordered stage reset; Arena orders PREPARED instantiation, placement, camera pan, evaluator binding, activation, unlock, and completed-area unloading.
5. **Stage 1 through free practice:** Stage 1 initializes at startup, progresses through Stages 2–7, transitions into the Final Arena, and final-enemy defeat switches that arena in place to indefinite `now you are free` practice.
6. **Eight-level Casting slice:** JSON, loader, and Portal enforce the exact capacity invariant of eight; generic tutorial Cast-level validation accepts `1..8` while existing Level-5 descriptors remain unchanged; Player uses a local ordered one-octave cue FIFO for every crossed visible-charge boundary; and the HUD derives Spell Level from charged snapshot entries while retaining banked-capacity progress over the eight-level denominator, without adding gameplay state or components.

The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01. Because no exact scenario matrix was supplied, postflight must not infer individual results for these validation seams:

- Stage 1 starts immediately with Fire selected, one refill target, empty green-token progress, and a locked right gate;
- only physical Fire X hits advance progress, while Fire misses—including `orb_without_contact`—flinch/reset even before progress;
- unrelated actions before progress remain silent, while Cast insertion, non-Fire hit, X miss, or premature chain end after progress invalidates only the attempt;
- timeout, completion, failed Cast, and interruption each produce one normalized chain-termination fact, preventing progress from surviving a real chain reset;
- the fifth valid hit latches completion, turns the widget green, adds `moving on ->`, and unlocks the gate permanently;
- later combat in the completed Stage 1 area cannot revoke completion;
- Stage 2 completes only on a launched level-5 Cast; non-launched attempts and lower-level launches invalidate, while projectile impact is irrelevant;
- Stages 3–6 enforce their exact declarative X/Cast/switch sequences and invalidation rules;
- Combined Stage 7 Heat-row state, threshold-qualified chain start, chain invalidation, X5 completion, and direct transition to Final Arena require separate user validation;
- each completed stage locks input, pans to the next independently instantiated area, resets combat state, preserves active school, unloads the completed area, and prevents return;
- only current and next Stage Areas coexist during transition; PREPARED targets cannot collide, receive HealthEvents, process gameplay, or publish outcomes;
- shared training-area and Final Arena placement align anchors, preserve continuous ground, and respect transformed camera bounds;
- root-owned projectiles are removed before Final Arena instantiation, and Final Arena outcomes bind only after its evaluator exists;
- incoming `APPLIED` direct damage triggers charged-orb removal and five-point Heat loss exactly once even at zero final reaction, while `BLOCKED`, `PARRIED`, and DoT results trigger neither loss;
- camera pans use the default one-second duration, reject values outside `0.1–5.0`, persist Portal changes, and do not retime a transition already in progress;
- the existing final-enemy objective and practice targets remain functional after scene extraction; and
- final-enemy defeat immediately changes the widget to persistent `now you are free` with no progress row or further transition.

Existing Orb Casting, generic damage, Entity feedback, audio, Developer Portal—including its dormant legacy school controls—and Final Arena combat behavior are regression boundaries. The combined Stage 7 rows/evaluation have broad user-reported validation without a scenario matrix. Elemental Endurance, live AI enable/disable, Player 1-HP Floor behavior, and ordinary-play defence remain outside the reported runtime-validation boundary. Additional Enemy attacks and legacy school-effect cleanup remain separate future slices.

The eight-level slice requires bounded validation that Charging reaches and stops at eight while the queue still stores ten, Spell Level and progress show `0..8`, Cast payloads and Enemy feedback preserve Levels 6–8, every visible charged-count boundary crossed in one or several updates produces exactly one corresponding note in ascending order without overwriting another cue, stage reset clears pending cues, Level-5 tutorial objectives remain unchanged, and an eight-orb commitment grants Heat exactly once from a consumed count of eight. The design-review waivers leave first-time comprehension of the ten-slot/eight-level distinction and discovery beyond Level 5 explicitly unverified.

Light widget-flinch values remain reversible prototype tuning. Shared training-area dimensions and internal marker placement are authored in the Stage Area scene. The user reported broad current-feature validation; no agent-run Godot, build, compiler, or automated-test evidence exists.

The user has specifically reported validating the smaller DoT floating-damage feedback. On 2026-09-05, the user also reported that the Final Enemy's solid-body collision works, the three restored practice targets remain pass-through, leaving the committed attack area during windup produces a miss without retargeting, and hitting the Enemy during windup does not interrupt its committed attack. The user then explicitly waived all remaining targeted verification passes for the current tuning phase. After the Stage 7/8 merge, the user broadly reported the combined Stage 7 implementation verified without supplying a scenario matrix. Those waivers do not establish the remaining untested combat, Portal, or defence behavior. A fresh Ultron `mode=tech-postflight` remains appropriate if broader runtime evidence is supplied later.

## Handoff

Status: `READY_FOR_ULTRON_OR_DUM-E`.

Friday recommends an optional Ultron `mode=tech-preflight` audit because the bounded behavior crosses four existing fixed assumptions—configuration validation, tutorial level validation, HUD presentation, and Player audio—while leaving the core Magic/Cast ownership unchanged. No instrumentation is proposed or retained for this slice.
