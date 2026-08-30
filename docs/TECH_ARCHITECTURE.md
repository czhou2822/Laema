# Technical Design Report — Orb Casting and Tutorial Stage Architecture

Status: `READY_FOR_ULTRON_OR_DUM-E`

Repository basis: `04b4c6c` (`feat: add combat feedback state`) plus the user-verified, uncommitted `docs/GAME_DESIGN.md` draft with SHA-256 `1993E5842E581779A72B26B5D9474884CA6EA5F00CF71B58D7635D51EAEE67CB`. The committed source is the combat baseline; this report defines the additional tutorial-stage target architecture and does not claim that the new stage flow is implemented.

No Godot runtime, build, compiler, or automated test was run while preparing this report.

## Scope and selected decisions

This report preserves the implemented side-scrolling Orb Casting combat baseline and adds the verified reusable tutorial-stage framework, complete Stage 1 behavior, transition into the existing final arena, and in-place free-practice completion state.

The Material Decision Ledger is closed:

1. **Direct generic Cast path.** `MagicComponent` resolves generic direct damage for the primary and optional secondary layers. Active prototype Casting does not read a spell loadout or dispatch school-specialty resolvers.
2. **Shared Entity feedback.** A reusable `FeedbackComponent` belongs to the base `Entity` contract. Enemy uses it now for Cast-level feedback; Player receives the same capability without gaining a new current feedback rule.
3. **Stage 1 preserves the committed combat schema.** The current continuous Heat and generic-Cast schema remains authoritative. Legacy Fire/Water/Air/Earth effect fields and their Developer Portal controls remain dormant but intact during Stage 1 work; their previously accepted strict removal is deferred to a separate future cleanup slice.
4. **Dedicated commitment-to-Heat interface.** After successful orb consumption and immutable payload storage, Magic emits one internal commitment fact carrying `commit_id` and `consumed_count`. Combat receives it synchronously and grants Heat exactly once. Promotion, launch, interruption, discard, and impact do not emit this fact.
5. **Last-in primary and single-secondary ordering.** The final consumed orb selects the primary school, whose level equals total consumed orbs. The highest-count remaining school becomes the optional secondary; a secondary tie selects the school appearing latest in the consumed sequence. Impact and feedback resolve primary first, then secondary.
6. **Pressure state owns chain preservation.** Magic reports CHARGING and DEPLETING as chain-preserving states independently of queue contents, marked count, and partial progress. CHARGING banks capacity while the queue is empty; DEPLETING remains preserving at zero progress until R2 leaves that band. Might consumes this state for timeout and between-action movement decisions.
7. **Shared configured feedback lifetime.** Both Entity scenes configure their `FeedbackComponent` from `ui.cast_feedback_duration`, default `2.0` seconds and validated from `0.1` through `20.0`. Developer Portal live tuning affects future entries only; each visible entry retains the duration captured when it was created.
8. **Initial RELEASE is side-effect-free.** The first raw-pressure sample always establishes Magic's initial pressure state. If that state is RELEASE, initialization emits no Cast request or failure. Only a later transition from CHARGING or DEPLETING into RELEASE dispatches one Cast attempt; initial CHARGING or DEPLETING may begin their ordinary state behavior immediately.
9. **Persistent tutorial root and reusable Stage Areas.** Player, HUD, audio, StageDirector, and an Arena-owned camera persist. Physical stage content is supplied by independently instantiated Stage Area scenes.
10. **Stage-specific objective evaluators.** StageDirector owns lifecycle and delegates attempt state to one evaluator instance for the active stage. HUD never interprets combat outcomes.
11. **Scene-plus-JSON stage definitions.** Stage Area `.tscn` scenes own physical content; the validated prototype JSON owns ordered descriptors, objective type, UI content, and evaluator parameters.
12. **Player transition facade.** Arena locks input and requests one ordered combat reset through Player rather than reaching into Player components. Active school is preserved.
13. **Current-plus-next Stage Area lifetime.** Only the active and next areas coexist during a transition. Completed non-final areas unload after the next stage activates; the final arena remains indefinitely.
14. **Reusable ObjectiveWidget.** A HUD-owned UI component renders objective text, progress, invalidation flinch/reset, completion green, and `moving on ->` from Director presentation state.
15. **Node-based evaluator lifetime.** StageDirector creates one Node evaluator per active stage. It consumes immutable outcomes, may advance with time, and is discarded on stage change.
16. **Normalized chain termination.** Might publishes one immutable `chain_terminated` outcome exactly once whenever an active InputCombo ends, carrying its termination reason. Sequence evaluators consume this fact rather than reconstructing chain lifetime from specialized outcomes.
17. **Prepared-stage isolation.** Completion preloads only the next PackedScene resource. Arena instantiates its nodes after exit/input lock in a PREPARED state with combat and outcomes dormant, clears root-owned projectiles, and promotes the area to ACTIVE only after the pan and objective evaluator are ready.
18. **Anchor-aligned Stage Area placement.** Arena owns Stage Area world transforms and aligns the next area's local EntryAnchor to the current area's world-space ExitAnchor. Each area supplies its own spawn, camera target, and horizontal camera bounds.
19. **Configured transition duration.** Arena captures `tutorial.transition_duration` when a pan begins. The default is `1.0` second, valid from `0.1` through `5.0`; live tuning affects future transitions only.

Excluded from this implementation slice: defining or implementing Stages 2–7, changing the existing final-arena combat objective or contents, school-level spell behavior, legacy school-effect configuration/Portal cleanup, active Enemy attacks, defence redesign, Air/Earth defence, final presentation, asset remapping, save/resume persistence, and final numerical tuning.

## Current codebase map and mismatch

```text
PrototypeArena                              current monolithic root
├── Player
│   ├── Camera2D                           currently Player-owned
│   └── CombatComponent
│       ├── MightComponent
│       ├── MagicComponent
│       ├── HeatComponent
│       └── DefenceController
├── three permanent practice targets
├── one killable FinalEnemy
├── StageDirector                          flat outcome matcher
├── PrototypeHUD / Developer Portal
└── arena geometry, backdrop, and audio
```

Static inspection at `04b4c6c` shows that the accepted combat component, queue, Heat, generic Cast, and Entity feedback structures are present and are the baseline for this slice. The tutorial-stage target is not present:

- `prototype_arena.tscn` hardcodes geometry, three practice targets, the FinalEnemy, Player, HUD, and StageDirector into one scene.
- Player owns the active `Camera2D`, so the camera cannot pan independently after Laema exits the frame.
- `StageDirector` stores one flat objective list and matches one immutable outcome at a time. It owns no stage FSM, attempt evaluator, exit gate, transition, or free-practice state.
- `prototype_combat.json` contains only the current final-enemy objective and no ordered Stage Area descriptors.
- `PrototypeHUD` has a text-only tutorial panel rather than the reusable token/progress widget.
- Player has no public stage-transition boundary for all-input lock and ordered combat reset.

The current combat outcomes provide Stage 1's action and contact evidence, but current chain termination is fragmented across `chain_reset`, `chain_completed`, `cast_failed`, and `action_interrupted`. The target adds one normalized `chain_terminated` CombatOutcome while preserving specialized outcomes where they remain useful. `orb_without_contact` is not a physical hit and therefore follows Stage 1's miss path. No second tutorial event bus is introduced.

## Target ownership

### Might, Magic, Heat, and Combat

`MightComponent` continues to own action eligibility, X/Cast timing, the one-slot earliest-request buffer, chain progression, animation/contact/launch phases, and action-caused movement locks. It decides whether a release-Cast request is normal, empowered, buffered, an endpoint Cast, or a timing failure. After an action and when evaluating timeout, Might reads Magic's pressure-state preservation contract rather than deriving preservation from queue or meter values. Because Might orders every InputCombo exit, it also publishes one `chain_terminated` outcome exactly once per active-chain termination, including a reason for timeout, completion, failed Cast, or interruption.

`MagicComponent` owns the ten-orb FIFO queue, front-orb lifetime, five-orb marking capacity, pressure state, CHARGING and DEPLETING progression, Cast composition, immediate consumption, and immutable committed payloads. Its first raw-pressure sample establishes the initial state before transition behavior is allowed. Initial RELEASE is side-effect-free; initial CHARGING or DEPLETING may begin ordinary state behavior. Its current pressure state is the sole preservation authority: CHARGING and DEPLETING preserve the chain; RELEASE does not. This state remains authoritative even when the queue, marked count, and partial progress are all zero. Only after a successful commitment has consumed its marked prefix and stored its payload does Magic emit a dedicated internal commitment fact containing `commit_id` and `consumed_count`. Failed commitment attempts emit nothing.

`HeatComponent` remains the sole owner of attack-speed bonus points, the `100%..150%` multiplier, loss, Water-block drain, and the three-second reset timer. `CombatComponent` subscribes to Magic's dedicated commitment fact during configuration and synchronously routes `consumed_count` to Heat once. Might reads the resulting multiplier for X/Cast animation timing; Magic reads it only for CHARGING speed.

`CombatComponent` remains a thin facade. It forwards Player/HUD/Arena-facing signals and orders cross-component transactions without duplicating Might, Magic, Heat, queue, or feedback state. Generic public `CombatOutcome` events remain observational and never drive the authoritative Heat mutation.

### Entity feedback

The base `Entity` script owns a required `FeedbackComponent` reference alongside Health, Status, and HitReaction. The project uses a shared base script rather than a shared inherited Entity scene, so both Player and Enemy scenes compose their own `Feedback` child satisfying that contract.

`FeedbackComponent` owns transient entity-local feedback entries and their expiration. It is separate from `StatusController`: Cast-level text is presentation evidence, not a buff, debuff, or gameplay status. The base Entity configuration injects `ui.cast_feedback_duration` into each Player and Enemy component. Every entry captures that duration at creation, so a live tuning change affects only later entries and never extends or truncates feedback already visible. The current slice publishes `<School> Lv.<N>` only on a struck Entity after that school layer successfully applies direct damage. Enemy presents those entries now. Player has the same public capability for future use, but this slice introduces no new Player-facing feedback trigger.

### Arena and projectile

The persistent tutorial root retains the `PrototypeArena` script's orchestration role: it owns Player, HUD, audio, projectile spawning/impact routing, StageDirector, Stage Area lifetime, and the transition camera. `SpellProjectile` continues to own travel, maximum distance, first-valid-target collision, and blended presentation. It carries the immutable resolved Cast payload rather than reading the live orb queue later.

The payload carries an explicit primary school and level plus one optional secondary school and level. It also retains empowered state, the primary-only damage multiplier, original instigator, direction, and the information needed to derive color weights. The final consumed orb always selects the primary school; primary level equals total consumed orbs. After excluding the primary, the highest-count remaining school becomes secondary. A secondary-count tie selects the tied school appearing latest in the consumed sequence. Other represented schools create no layer, although their orbs remain consumed and still contribute to primary level and commitment-time Heat.

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

Stage-owned Enemy bodies remain on the target-detection layer used by X and projectiles, but do not mask the Player body. Training dummies and the final Enemy are therefore pass-through while still receiving combat contact.

The existing `prototype_arena.tscn` is split mechanically: its final-arena geometry and four Enemy instances move into the Final Arena Stage Area, while its Player, HUD, audio, StageDirector, projectile routing, and new Arena-owned Camera2D remain in the persistent root. A new Stage 1 Stage Area contains one permanent refill target and its own gate/exit markers.

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

`ObjectiveWidget` is a reusable HUD-owned Control scene. StageDirector supplies immutable presentation snapshots containing objective text, progress-token definitions/state, attempt invalidation, completion state, and prompt text. The widget owns only rendering and its light UI-only flinch. It never consumes CombatOutcome or stage nodes.

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
  -> banks marking capacity up to five even when no orb is available
  -> marks the oldest available orbs covered by that capacity
  -> preserves the chain and releases movement between actions

5% <= R2 < 95%
  -> DEPLETING drains at the fixed baseline charge-step rate
  -> partial progress drains first
  -> completed boundaries unmark newest marked orbs first
  -> remains chain-preserving even after progress reaches zero
  -> releases movement between actions

R2 < 5% on state entry
  -> stops pressure-state preservation
  -> one Cast attempt only when this is a later transition
```

Before evaluating these transitions, Magic classifies the first raw-pressure sample and stores it without dispatching RELEASE behavior. This prevents a resting trigger from producing a startup Cast failure. Initial CHARGING or DEPLETING still activates its ordinary state behavior. After initialization, only a change from CHARGING or DEPLETING into RELEASE dispatches one Cast attempt.

Magic exposes one pressure-preservation result to Might. Might uses it after an animation and for idle-timeout eligibility. Queue size, marked count, and partial progress are presentation/resource values and never substitute for this state result. Active X and Cast animations remain movement-locked; Combat releases movement only between actions while Magic reports CHARGING or DEPLETING.

Only the front queue orb counts down. Consumption or expiration shifts the remaining queue forward and starts the new front orb at its full lifetime. Marking coverage transfers with the shifted queue when enough orbs remain.

A failed Cast ends the chain, unmarks all stored orbs, and resets partial marking progress to zero without removing queue contents. A Player hit removes currently marked orbs, preserves unmarked order, and resets marking progress. Orbs already consumed by a committed Cast are never refunded.

Magic publishes enough queue state for the HUD to render all ten slots, current contents, marked state, front lifetime, and marking progress. Overflow reaches the HUD through the existing Combat/Player presentation path and restarts the whole-widget flinch from rest.

### Commitment, buffering, and Heat

```text
Might accepts a normal/windowed/buffered release-Cast
  -> Magic consumes the marked FIFO prefix immediately
  -> Magic resolves the last-in primary and optional majority secondary
  -> immutable Cast payload is stored under one commitment
  -> Magic emits one internal commitment fact
  -> Combat grants Heat from its consumed_count immediately
  -> Might launches that payload at the Cast contact phase
```

A buffered Cast commits before its later promotion. The dedicated fact is emitted during commitment, not promotion, launch, interruption, discard, or impact. Those later transitions therefore cannot duplicate or revoke the Heat gain. If the action is interrupted before launch, its payload is discarded without refund; the Heat already granted at commitment remains. A projectile miss likewise does not revoke Heat.

Heat is stored as bonus percentage points above the fixed `100%` baseline. Its range is `0..50`, producing a continuous `1.00..1.50` multiplier. Each committed consumed orb grants one point. A Player hit removes five points with a zero-point floor. Three seconds after the latest qualifying Cast commitment, Heat resets fully to zero bonus points. Loss and Water-block drain do not create Heat or change its authority.

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
  max_attack_speed_percent: 150
  attack_speed_gain_per_orb: 1
  attack_speed_loss_per_hit: 5
  heat_reset_timer: 3
```

The active shared feedback-lifetime field is:

```yaml
ui:
  cast_feedback_duration: 2.0
```

`ui.cast_feedback_duration` must be numeric from `0.1` through `20.0` seconds. It follows the same fail-fast save/load path as the existing UI duration. Player and Enemy receive the value during Entity configuration and forward later runtime-tuning changes to their Feedback components. A changed value applies to future entries only; active entries retain their captured expiry.

The tutorial section is a strict replacement of the current flat objective list. Its target shape is:

```yaml
tutorial:
  initial_school: fire
  transition_duration: 1.0
  stages:
    - id: stage_1
      area_scene: res://scenes/stages/stage_1.tscn
      objective:
        type: five_hit_fire_chain
        label: perform a 5 hit combo
        tokens: [X, X, X, X, X]
        school: fire
        required_hits: 5
    - id: final_arena
      area_scene: res://scenes/stages/final_arena.tscn
      final: true
      objective:
        type: final_enemy
        label: Defeat the final Enemy.
        encounter_id: final_enemy
      free_practice_text: now you are free
```

The loader requires a non-empty ordered stage array, unique non-empty stage IDs, loadable PackedScene paths, exactly one final stage at the end, known evaluator types, and evaluator-specific required fields. `initial_school` must be a functional school. `transition_duration` must be numeric from `0.1` through `5.0` seconds and defaults to `1.0`. The obsolete flat `tutorial.objectives` and `tutorial.failure_feedback` shape is rejected.

The fixed `100%` baseline is behavior, not configuration. The committed continuous-Heat schema remains unchanged; the superseded discrete Heat and independent Air-speed fields remain absent and rejected.

Casting configuration retains the committed timing, pressure, projectile, five-orb marking, and ten-orb storage fields unchanged. `spell_loadout` remains absent. The currently persisted Fire DoT, Water status-level, Air chain-lightning, Earth area/Slow, and related school-effect fields remain validated and exposed through their existing Portal controls, but generic prototype Casting does not read or dispatch them. Removing those dormant fields and dependent paths is a separate future cleanup slice.

The Developer Portal keeps its General, Audio, and Combat organization. General → UI exposes `cast_feedback_duration` and `tutorial.transition_duration` beside the existing presentation duration. Transition-duration changes persist through the existing JSON path; each pan captures the value at start, so live changes affect future transitions only. Existing Combat-tab school controls remain untouched and dormant where their effects are deferred.

The always-visible HUD renders ten queue slots even when empty, a gold outline on marked orbs, the marking-progress bar, and the front-orb lifetime. The overflow signal drives the whole-widget horizontal flinch. The developer Heat readout removes `Level N` and shows actual attack speed with a continuous bar. The upper-right raw R2 pressure gauge and existing developer-overlay visibility behavior remain unchanged.

## Implementation slices and validation seams

1. **Persistent root and Stage Areas:** retain Player/HUD/audio/projectile orchestration in the root, move the Camera2D to Arena ownership, extract the existing final-arena content into a Final Arena Stage Area, and create the Stage 1 Stage Area plus shared entry/exit/spawn/camera/bounds/gate/trigger and PREPARED/ACTIVE/RETIRED contracts.
2. **Stage configuration and lifecycle:** replace the flat tutorial schema, add strict stage/evaluator/resource validation, establish the StageDirector FSM and dedicated Arena milestone handshake, and enforce the current-plus-next loading window.
3. **Objective evidence, evaluation, and presentation:** add the normalized one-per-exit `chain_terminated` outcome, Node evaluator registry, Stage 1 five-hit Fire evaluator, existing final-enemy evaluator, immutable presentation snapshots, and reusable upper-right ObjectiveWidget.
4. **Player transition boundary:** add all-input transition lock and one ordered stage reset through Player/Combat facades while preserving active school; clear root-owned transient combat objects and wire PREPARED instantiation, reposition, camera pan, evaluator/outcome binding, activation, unlock, and completed-area unloading.
5. **Stage 1 through free practice:** initialize Stage 1 at startup, enforce its gate/progress/invalidation/completion rules, transition to the existing Final Arena, and switch that arena in place to indefinite `now you are free` practice after final-enemy defeat.

Human runtime validation should establish:

- Stage 1 starts immediately with Fire selected, one refill target, empty green-token progress, and a locked right gate;
- only physical Fire X hits advance progress, while Fire misses—including `orb_without_contact`—flinch/reset even before progress;
- unrelated actions before progress remain silent, while Cast insertion, non-Fire hit, X miss, or premature chain end after progress invalidates only the attempt;
- timeout, completion, failed Cast, and interruption each produce one normalized chain-termination fact, preventing progress from surviving a real chain reset;
- the fifth valid hit latches completion, turns the widget green, adds `moving on ->`, and unlocks the gate permanently;
- later combat in the completed Stage 1 area cannot revoke completion;
- leaving right locks all gameplay input, pans the Arena camera, reveals Laema waiting in the Final Arena, and prevents return;
- Final Arena activation restores full Health and baseline combat state, clears transient combat resources/effects, and preserves the school selected at Stage 1 exit;
- only Stage 1 and Final Arena coexist during transition, and Stage 1 unloads after Final Arena activation;
- Final Arena placement aligns its EntryAnchor to Stage 1's world ExitAnchor, all transformed markers land on valid floor geometry, and active camera following respects each area's transformed horizontal bounds;
- no Final Arena combat node exists while the player remains in completed Stage 1; PREPARED targets cannot collide, receive HealthEvents, process gameplay, or publish outcomes;
- root-owned projectiles are removed before Final Arena instantiation, and Final Arena outcomes bind only after its evaluator exists;
- camera pans use the default one-second duration, reject values outside `0.1–5.0`, persist Portal changes, and do not retime a transition already in progress;
- the existing final-enemy objective and practice targets remain functional after scene extraction; and
- final-enemy defeat immediately changes the widget to persistent `now you are free` with no progress row or further transition.

Existing Orb Casting, generic damage, Entity feedback, audio, Developer Portal—including its dormant legacy school controls—and final-arena combat behavior are regression boundaries. Incoming Enemy attacks and ordinary-play defence remain outside the existing validation boundary. Stages 2–7 and legacy school-effect cleanup remain separate future slices.

Light widget-flinch values remain reversible prototype tuning. Individual area dimensions and internal marker placement are authored in their Stage Area scenes rather than inferred from one global spacing value. No Godot runtime, build, compiler, or automated test was run while preparing this report; human runtime validation is required.

Because this slice restructures scene ownership, camera ownership, stage configuration, Player reset ordering, and HUD interfaces, Friday recommends optional Ultron `mode=tech-preflight` before implementation. The report is also sufficiently bounded for direct DUM-E implementation if the user waives that optional audit.
