# Implementation Status

Status: `IMPLEMENTED_USER_VALIDATED_WITH_TERMINOLOGY_SYNC_PENDING`.

Last committed recovery baseline: `6b06dc2` (`checkpoint: save cross-thread recovery state`). It commits the declarative Stage 1–6 sequence-objective candidate and recovery records. The current working tree contains later shared-training-area and debug-stage-selection consolidation while preserving the same approved Stage 1–6 behavior.

## Current working-tree implementation

The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01. The report was broad: no exact scenario matrix, tested-tree identity, or engine-version record was supplied. No agent-run Godot, build, compiler, or automated-test evidence exists.

- Combat is composed as a thin `CombatComponent` facade with `MightComponent`, `MagicComponent`, the existing Heat implementation, and Defence beneath it. Might owns action timing, chains, movement locks, and the shared X/Cast buffer; Magic owns the queue, pressure charging/depletion, immediate frozen Cast commitments, generic Cast execution, and charged-only qualifying Player-hit removal.
- Successful normal and endpoint Cast completion now preserves every unconsumed FIFO queue entry.
- Incoming `APPLIED` direct damage now routes one five-point Heat loss and charged-orb removal through Combat; `BLOCKED`, `PARRIED`, and DoT results cause neither resource loss, regardless of reaction strength.
- Shared `FeedbackComponent` state provides current generic Cast-level feedback.
- Public immutable combat and encounter outcomes feed the Arena-owned StageDirector and stage-specific evaluators.
- One declarative sequence evaluator consumes normalized light, Cast-attempt, school-switch, and chain-termination facts for Stages 1–6.
- Stages 1–6 use independently instantiated shared training-area content with one stationary, non-attacking, refillable dummy per stage.
- Player-facing terminology distinguishes Generating/generated orbs from Charging/charged orbs; current private `marked` identifiers remain implementation details.
- The current HUD label and some public presentation field names still use the superseded `MARK`/`marked` wording. Synchronizing those game-facing surfaces is the remaining terminology-only implementation delta before postflight.
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
- a FIFO elemental-orb queue with front lifetime, right-to-left circular lifetime presentation, continuous charging progress, consumption, transfer, and fixed-rate depletion;
- R2 95–100% CHARGING, 5–95% fixed-rate DEPLETING, and below-5% RELEASE semantics with transition-based Cast-on-release behavior;
- one normalized pre-window buffer shared by X and release-Cast requests, with earliest-request arbitration and event-level debug traces;
- a Stage 1 refill target plus the extracted Final Arena's three permanent practice targets and distinct killable final target;
- Fire parry and Water block state scaffolding with guard-warning feedback and a CC0 warning sound;
- an always-visible gameplay HUD with reusable ObjectiveWidget plus a paused Developer Portal with General, Audio, and nested Combat tabs, visible toggles, tooltips, pause/unpause, and Save to JSON;
- reusable Stage Area scenes, StageDirector lifecycle, declarative sequence and final-enemy evaluators, transition camera flow, stage reset, and final free-practice presentation;
- Ambient, SFX, and BGM bus routing with persisted enabled and volume controls; and
- the approved prototype asset and audio subsets.

At synchronization time, the working tree contains later shared-training-area and debug-navigation consolidation. It was preserved untouched by this document synchronization. The exact tested-tree identity was not supplied.

The following remain outside the current validation boundary or intentionally open:

- incoming Enemy attacks and ordinary-play validation of Water block, Fire parry, guard depletion, guard warning, guard break, and charged-orb loss on Player hit;
- scenario-level results for each Stage 1–6 objective and transition, because the user supplied only a broad validation report;
- future tutorial stages after Stage 6;
- Air and Earth defence;
- school-specific idle/walk locomotion switching; the current prototype uses the shared locomotion shell;
- final character, projectile, UI, level, and audio presentation;
- final numerical tuning and experiential success criteria; and
- complete enemy content and final level geometry.
