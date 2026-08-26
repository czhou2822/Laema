# Implementation Status

Status: Expanded prototype implementation with user-reported validation on 2026-08-25. An exact scenario matrix was not supplied.

Last committed implementation: `358684b` (`feat: add side-scrolling orb casting prototype`). This commit contains the finalized R2 pressure state machine, shared X/Cast input buffer, fixed-rate depletion, orb presentation, Developer Portal controls, audio-bus integration, and the side-scrolling orb-casting source/configuration/docs.

## Current uncommitted implementation candidate

Status: `AWAITING_USER_VALIDATION`.

- Combat is composed as a thin `CombatComponent` facade with `MightComponent`, `MagicComponent`, the existing Heat implementation, and Defence beneath it. Might owns action timing, chains, movement locks, and the shared X/Cast buffer; Magic owns the queue, pressure marking/depletion, immediate frozen Cast commitments, configured-spell execution, and marked-only Player-hit removal.
- The prototype configuration supplies fixed default school/level spell assignments and a final-only, data-driven tutorial objective. There is no persistence, unlock, new-spell, or balance implementation.
- Public immutable combat and encounter outcomes feed the Arena-owned StageDirector. The three existing practice targets retain their permanent refill; one distinct final Enemy emits the authoritative completion fact when it reaches zero Health without refilling.
- This candidate has not been run in Godot, built, compiled, or exercised by automated tests. The prior user-reported validation applies only to the earlier expanded prototype, not this restructure.

The current prototype source includes:

- a Godot entry scene with runtime InputMap bindings for controller, keyboard, and mouse input;
- fail-fast JSON tuning configuration with validated live-edit rollback and persisted Developer Portal changes;
- shared Entity, HealthEvent/HealthResult, HealthResolver, Health, Buff/Debuff, and HitReaction components;
- composed movement, Combat/defence FSMs, five-position InputCombo chaining, and Heat components;
- AnimationPlayer-based attack timing and ShapeCast2D contact queries;
- twenty active school/position X sheets covering X1–X5 for Fire, Water, Air, and Earth, with shared locomotion and Cast presentation;
- functional Fire, Water, Air, and Earth X/casting specialties and their current status/effect pipelines;
- a FIFO elemental-orb queue with seven-second front lifetime, right-to-left circular lifetime presentation, continuous marking progress, consumption, transfer, and fixed-rate depletion;
- R2 DEPLETING, CHARGING, and CAST pressure bands, transition-based Cast entry, and no Cast-on-release behavior;
- one normalized pre-window buffer shared by X and full-press Cast requests, with earliest-request arbitration and event-level debug traces;
- a finite-Health, non-attacking Enemy target implementation instantiated as three permanent practice targets plus one distinct killable final target in the prototype arena;
- Fire parry and Water block state scaffolding with guard-warning feedback and a CC0 warning sound;
- an always-visible gameplay HUD plus a paused Developer Portal with General, Audio, and nested Combat tabs, visible toggles, tooltips, pause/unpause, and Save to JSON;
- Ambient, SFX, and BGM bus routing with persisted enabled and volume controls; and
- the approved prototype asset and audio subsets.

No Godot runtime, build, compiler, or automated test was run by the agent. The user reported the expanded implementation as validated in Godot on 2026-08-25, but did not provide a scenario-by-scenario result or engine-version record.

The following remain outside the current validation boundary or intentionally open:

- incoming Enemy attacks and ordinary-play validation of Water block, Fire parry, guard depletion, guard warning, guard break, and marked-orb loss on Player hit;
- Air and Earth defence;
- school-specific idle/walk locomotion switching; the current prototype uses the shared locomotion shell;
- final character, projectile, UI, level, and audio presentation;
- final numerical tuning and experiential success criteria; and
- complete enemy content and final level geometry.
