# Combat checkpoint — 2026-10-12

Task key: combat

## Since last checkpoint

- User found the five-hit combo okay but identified a short Enemy hurt reaction and immediate return to attacking as the encounter mismatch. Existing task analysis reports hurt presentation running alongside uninterrupted Enemy logic.
- User approved a behavior-preserving LimboAI 1.8.1 Final Enemy conversion. The source candidate includes the extension, visible tree, six tasks, Portal-fed blackboard and Web extension settings.
- Reported grammar and resource/dependency checks passed; no user-reported Godot comparison or Web export result exists for this conversion.
- Latest question is impact/reaction definition and pixel displacement: visual recoil that returns versus actual collision-body displacement remains unresolved.

## Carried context

- Decision: investigate the cause first, then guide the user's own editor tuning; target December 31, 2026.
- Preserve the L2 Casting/R1 defence expression discussed in this task; implementation and canonical R2 wording require reconciliation before a control change is claimed.
- Task report: reaction level is max(0, Impact minus defensive level); current sprite-only levels 1–5 shift 7, 10.5, 14, 17.5 and 21 pixels then return. This does not establish approval of new body knockback or AI interruption.
- Open: behavior choice, LimboAI runtime validation, and historical Heat-timer wording mismatch. Earlier tuning waivers do not cover the new conversion.

## Resume point

Ask whether the proposed translation should visually recoil and return or move the target's collision body to a new position. Then define the intended rule before parameter tuning. User runs the Godot comparison; no further implementation is authorized by this note.

## Sources

- Combat latest completed round 01a12f1d-0d8a-79a1-a2a0-0420efee312b; preceding LimboAI approval/result and hurt-feedback rounds (12 recent turns read).
- ai/trees/final_enemy.tres; scripts/enemy/combat_enemy.gd; docs/GAME_DESIGN.md; docs/TECH_ARCHITECTURE.md; docs/IMPLEMENTATION_STATUS.md.
