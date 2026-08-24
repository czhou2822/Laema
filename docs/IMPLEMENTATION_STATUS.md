# Implementation Status

Status: First-draft prototype user-validated in Godot on 2026-08-24.

Committed baseline: `e543a43` (`feat: add validated combat prototype slice`).

The current prototype source now includes:

- a Godot entry scene and runtime InputMap bindings;
- controller, keyboard, and mouse bindings that coexist on the same InputMap actions;
- fail-fast JSON tuning configuration with validated live-edit rollback;
- shared Entity, HealthEvent/HealthResult, HealthResolver, Health, Buff/Debuff, and HitReaction components;
- composed movement, Combat/defence FSMs, input-combo, and Heat components;
- AnimationPlayer-based attack timing and ShapeCast2D contact queries;
- shared Pack 6 Idle/Walk, Pack 2 shared cast, and twenty school/position X sheets; the current three-X cap presents X1–X3 while X4/X5 are staged for a separate combat change;
- genuine primary/secondary Fire and Water resolvers with separate HealthEvents;
- Wet/Slow/Frozen Water priority, Fire DoT ticks, original-instigator attribution, and WoW-style target status badges;
- a finite-Health permanent Enemy with excess-damage discard and automatic full refill;
- Air/Earth outline-only placeholders with blocked combat inputs;
- Fire parry and Water block state scaffolding with provisional tunables, persistent amber guard-warning feedback, and a CC0 warning sound;
- Heat, Health, defence, school, and input-combo UI; and
- the approved first-draft Craftpix asset subset.

No Godot runtime, build, compiler, or automated test was run by the agent. The user reported `validation passed` for the current first-draft prototype on 2026-08-24, covering the requested scene, controls, school selection, Fire/Water combat, combo, Heat, Enemy, status, animation, collision, and UI validation pass. The user also validated the strictly animation-only shared locomotion/cast/X1–X3 presentation slice that day; this does not validate a future X4/X5 combat expansion. Incoming-hit behavior for blocking, parrying, guard warning, and guard break remains intentionally unverified because the approved Enemy placeholder does not attack.
