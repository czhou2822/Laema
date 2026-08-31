# Implementation Status

Status: `IMPLEMENTED_USER_VALIDATED_AWAITING_POSTFLIGHT`.

Last committed implementation: `582e141` (`feat: add stage one tutorial flow`). Commit `04b4c6c` added the current combat-feedback state; `582e141` added Stage 1, reusable objective presentation and evaluation, Stage Area transitions, the Final Arena path, and indefinite free practice. The current working tree additionally contains the user-verified U-001/U-002 corrections in three combat files.

## Current working-tree implementation

The user reported the current feature set and U-001/U-002 corrections verified in Godot on 2026-08-31. The report was broad: no exact scenario matrix, tested-tree identity, or engine-version record was supplied. No agent-run Godot, build, compiler, or automated-test evidence exists.

- Combat is composed as a thin `CombatComponent` facade with `MightComponent`, `MagicComponent`, the existing Heat implementation, and Defence beneath it. Might owns action timing, chains, movement locks, and the shared X/Cast buffer; Magic owns the queue, pressure marking/depletion, immediate frozen Cast commitments, generic Cast execution, and marked-only qualifying Player-hit removal.
- Successful normal and endpoint Cast completion now preserves every unconsumed FIFO queue entry.
- Incoming `APPLIED` direct damage now routes one five-point Heat loss and marked-orb removal through Combat; `BLOCKED`, `PARRIED`, and DoT results cause neither resource loss, regardless of reaction strength.
- Shared `FeedbackComponent` state provides current generic Cast-level feedback.
- Public immutable combat and encounter outcomes feed the Arena-owned StageDirector and stage-specific evaluators.
- Stage 1 contains one refillable target and requires five uninterrupted landed Fire X attacks. Completion unlocks its right gate and transition into the Final Arena.
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
- a FIFO elemental-orb queue with seven-second front lifetime, right-to-left circular lifetime presentation, continuous marking progress, consumption, transfer, and fixed-rate depletion;
- R2 95–100% CHARGING, 5–95% fixed-rate DEPLETING, and below-5% RELEASE semantics with transition-based Cast-on-release behavior;
- one normalized pre-window buffer shared by X and release-Cast requests, with earliest-request arbitration and event-level debug traces;
- a Stage 1 refill target plus the extracted Final Arena's three permanent practice targets and distinct killable final target;
- Fire parry and Water block state scaffolding with guard-warning feedback and a CC0 warning sound;
- an always-visible gameplay HUD with reusable ObjectiveWidget plus a paused Developer Portal with General, Audio, and nested Combat tabs, visible toggles, tooltips, pause/unpause, and Save to JSON;
- reusable Stage Area scenes, StageDirector lifecycle, five-hit Fire and final-enemy evaluators, transition camera flow, stage reset, and final free-practice presentation;
- Ambient, SFX, and BGM bus routing with persisted enabled and volume controls; and
- the approved prototype asset and audio subsets.

At synchronization time, `scenes/ui/prototype_hud.tscn` contains an unrelated uncommitted ObjectiveWidget layout adjustment. It is not part of `582e141` or this document-only synchronization scope and was preserved untouched. The exact tested-tree identity was not supplied.

The following remain outside the current validation boundary or intentionally open:

- incoming Enemy attacks and ordinary-play validation of Water block, Fire parry, guard depletion, guard warning, guard break, and marked-orb loss on Player hit;
- scenario-level results for Stage 1 progress/invalidation/completion, transition ordering, Final Arena activation, and free-practice entry, because the user supplied only a broad validation report;
- Stages 2–7;
- Air and Earth defence;
- school-specific idle/walk locomotion switching; the current prototype uses the shared locomotion shell;
- final character, projectile, UI, level, and audio presentation;
- final numerical tuning and experiential success criteria; and
- complete enemy content and final level geometry.
