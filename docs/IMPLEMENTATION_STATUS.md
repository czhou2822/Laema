# Implementation Status

Status: `IMPLEMENTED_WITH_REMAINING_RUNTIME_VALIDATION_WAIVED_FOR_TUNING`.

Last committed recovery baseline: `6b06dc2` (`checkpoint: save cross-thread recovery state`). It commits the historical Stage 1–6 sequence-objective candidate and recovery records. The current working tree contains the later combined Stage 7, Final Enemy, Elemental Endurance, minimum-Health, feedback, and presentation additions described below.

## Current working-tree implementation

The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01. The report was broad: no exact scenario matrix, tested-tree identity, or engine-version record was supplied. The user later reported validating the small DoT floating-damage feedback. On 2026-09-05, the user also followed targeted checks and reported that the Final Enemy's body blocking works while the three restored practice targets remain pass-through, that leaving the committed attack area during windup produces a miss without retargeting, and that hitting the Enemy during windup does not interrupt its committed attack. The user then explicitly waived the remaining targeted verification passes for the current tuning phase. After the Stage 7/8 merge, the user broadly reported the combined Stage 7 implementation verified; no scenario matrix was supplied. Those waivers and broad reports do not establish untested scenario details. No agent-run Godot, build, compiler, or automated-test evidence exists.

- Combat is composed as a thin `CombatComponent` facade with `MightComponent`, `MagicComponent`, the existing Heat implementation, and Defence beneath it. Might owns action timing, chains, movement locks, and the shared X/Cast buffer; Magic owns the queue, pressure charging/depletion, immediate frozen Cast commitments, generic Cast execution, and charged-only qualifying Player-hit removal.
- Successful normal and endpoint Cast completion now preserves every unconsumed FIFO queue entry.
- Incoming `APPLIED` direct damage now routes one five-point Heat loss and charged-orb removal through Combat; `BLOCKED`, `PARRIED`, and DoT results cause neither resource loss, regardless of reaction strength.
- Shared `FeedbackComponent` owns target-local Cast-level, direct-damage, and smaller DoT-damage feedback. Every displayed amount is the final `HealthResult.health_delta`; fully resisted Cast layers display `0` without a school/level label, and applied DoT ticks display a smaller final-loss number including `0`.
- Public immutable combat and encounter outcomes feed the Arena-owned StageDirector and stage-specific evaluators.
- Stage 1–6 use the declarative sequence evaluator; combined Stage 7 uses the Heat-gated sequence evaluator with independent Heat and chain presentation rows.
- Stages 1–7 use independently instantiated shared training-area content with one stationary, non-attacking, refillable dummy per stage.
- Player-facing terminology distinguishes Generating/generated orbs from Charging/charged orbs; private `marked` identifiers remain implementation details. The HUD now uses generated-orb and Charging/charged wording.
- Tutorial-only Elemental Endurance is implemented for Final Enemy: StatusController owns the streak/multiplier, Might propagates source-action identity through X and Cast, HealthResolver applies the multiplier and full-resist tag before Health, and final feedback reflects post-modifier loss. At full resistance, new effects and orb generation are suppressed while direct Impact, hit reaction, and Heat refresh remain available.
- Player-wide minimum Health is implemented in HealthComponent. The default-enabled, Portal-backed `player.one_hp_floor_enabled` option applies a minimum of `1` only to future damage and never heals on toggle.
- Final Arena contains three permanent refillable pass-through practice targets plus one solid, killable Final Enemy. The active Final Enemy uses its one approach/committed-windup/strike/recovery loop with frozen attack geometry, equal hit/miss recovery, ordinary-hit non-interruption, and live AI enable/disable behavior.
- The persistent Arena root owns Player, HUD, audio, projectiles, camera, StageDirector, and the current-plus-next Stage Area lifecycle.
- Final-enemy defeat completes the tutorial and changes the loaded Final Arena into indefinite free practice.

The current prototype source includes:

- a Godot entry scene with runtime InputMap bindings for controller, keyboard, and mouse input;
- fail-fast JSON tuning configuration with validated live-edit rollback and persisted Developer Portal changes;
- shared Entity, HealthEvent/HealthResult, HealthResolver, Health, Buff/Debuff, and HitReaction components;
- composed movement, Combat/defence FSMs, five-position InputCombo chaining, and Heat components;
- AnimationPlayer-based attack timing and ShapeCast2D contact queries;
- twenty active school/position X sheets covering X1–X5 for Fire, Water, Air, and Earth, with shared locomotion and Cast presentation;
- functional Fire, Water, Air, and Earth X/casting specialties and their current status/effect pipelines;
- a ten-slot FIFO elemental-orb queue with front lifetime, right-to-left circular lifetime presentation, eight-level Charging capacity, continuous charging progress, consumption, transfer, and fixed-rate depletion;
- R2 95–100% CHARGING, 5–95% fixed-rate DEPLETING, and below-5% RELEASE semantics with transition-based Cast-on-release behavior;
- one normalized pre-window buffer shared by X and release-Cast requests, with earliest-request arbitration and event-level debug traces;
- Stage 1–7 refill targets plus the extracted Final Arena's three permanent pass-through practice targets and distinct solid, killable Final Enemy;
- Fire parry and Water block state scaffolding with guard-warning feedback, a shared CC0 hit-reaction cue, and a fixed-volume eight-step charged-orb pitch cue delivered through Player's local presentation FIFO;
- an always-visible gameplay HUD with all ten orb slots, Spell Level `0..8` derived from visible charged entries, separate banked charging progress, reusable ObjectiveWidget, and a paused Developer Portal with General, Audio, and nested Combat tabs, visible toggles, tooltips, pause/unpause, and Save to JSON;
- Stage 3 presentation instructing `Hold R2 + X -> X -> X -> X -> X -> Release R2`, plus matching Hold/Release guidance for the Stage 4 and Stage 5 Cast steps, through compact objective tokens while retaining the existing evaluator rules;
- reusable Stage Area scenes, descriptor-owned display names and generic presentation rows, StageDirector lifecycle, Stage 1–7 evaluators plus final-enemy evaluator, transition camera flow, stage reset, and final free-practice presentation;
- Ambient, SFX, and BGM bus routing with persisted enabled and volume controls; and
- the approved prototype asset and audio subsets.

At synchronization time, the working tree contains later shared-training-area and debug-navigation consolidation. It was preserved untouched by this document synchronization. The exact tested-tree identity was not supplied.

The user explicitly waived the following remaining validation checks for the current tuning phase. They remain outside the validation boundary or intentionally open:

- eight-level Charging capacity, ten-slot storage coexistence, Spell Level/progress presentation, generic Levels 6–8 feedback, ordered charged-orb cue delivery, reset/teardown cue clearing, and eight-orb once-only Heat commitment;
- Elemental Endurance streak counting, partial/zero resistance, DoT resistance, orb suppression, Heat refresh, Endurance badge, and final direct-damage feedback;
- Final Enemy hit/miss recovery parity and live AI enable/disable;
- both states of the Player 1-HP Floor option and Player defeat behavior with the option disabled;
- ordinary-play validation of Water block, Fire parry, guard depletion, guard warning, guard break, and charged-orb loss on Player hit;
- scenario-level results for each Stage 1–7 objective and transition, because the user supplied only a broad earlier report;
- Air and Earth defence;
- school-specific idle/walk locomotion switching; the current prototype uses the shared locomotion shell;
- final character, projectile, UI, level, and audio presentation;
- final numerical tuning and experiential success criteria; and
- complete enemy content and final level geometry.
