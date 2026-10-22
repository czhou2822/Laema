# Daytime C2 — bounded implementation review

Mode: Ultron `tech-postflight`, implementation review only. Result:
`IMPLEMENTATION_REVIEW_COMPLETE`. New finding inventory: **0 Blocking / 0 Major /
0 Minor contract violations identified in the bounded deltas**. This is not
submission clearance, whole-tree correctness or human game-feel acceptance.

## Identified baseline and authority

Review compares the frozen October22 morning692-path source in
BASELINE_MANIFEST.json against the current four daytime product deltas and one
support-recorder extension. HEAD/origin main were921fd1ae and intentionally dirty;
that commit alone is not the tested source. All692 listed root/runtime hashes
were rechecked at11:26 HKT: no mismatch, exactly these five differences from the
morning baseline. Earlier dirty work, inherited overnight changes and waivers are
outside this new-delta review and remain preserved.

The human approved bounded timing/existing-presentation iteration, normal-input
rendered replay, U/Dum-E implementation and repository publication after review.
GDD gameplay remains immutable: damage/Health/Impact/Poise/Heat, normalized
windows, shared Cast timing, defence and the approved dodge contract stay fixed.
The current TDD and companion records describe the daytime candidate; the GDD
needed no result-only amendment. The exact local tuning/presentation plan was
approved in the authorized handoff; no separate new architecture TDR is required.

| Reviewed file | Current SHA-256 prefix | Execution path checked |
| --- | --- | --- |
| scripts/player/player.gd | 9b705e0d | Native dodge Sprite ownership; completion-physics-frame hold; actual-motion locomotion; new action/school/hurt/stage/reset precedence |
| scripts/combat/spell_projectile.gd | cc1101fc | Fire-only child drawing scale; primary level clamp1..8; unchanged root/collider/payload/flight/impact/free |
| config/attack_styles/fire_x4.tres | 90f963de | Resource -> Player Settings -> move capture -> AttackStyle phase speed; only recovery0.51->0.36 |
| config/prototype_combat.json | ddab1126 | JSON audio.sfx.volume_db -> existing Arena bus consumer; only0->-6dB |
| tools/tests/overnight_fire_playtest.gd | 63409fd5 | Optional default-off Master tap; bounded stereo PCM16 drain; WAV size/header; owned effect cleanup and explicit loss/completion flags |

## Source conclusions

- C2 removes C1's raw-input Walk inference. Its private handoff frame does not
  extend Might's dodge state or movement/invulnerability/collision exception
  lifetime. Guards and clearing order prevent retaining it over a new action,
  hurt, school change, stage lock, reset or death. Movement remains the sole mover.
- The stopped native clip may expose cell0 rather than cell11 at completion.
  The approved dodge asset's PROVENANCE records both as the same existing idle
  pose. The claim is end-equivalent appearance, not retention of the last index.
- Fire size changes only Polygon2D.scale. School/color composition, radius12
  collision, Player-root-plus42 origin, launch, travel and disappearance remain.
- X4's shorter recovery also shortens late-active/input wall time and brings X5
  forward by0.15/Heat-multiplier seconds. Native keys/windows/geometry/lunge/push
  remain, but Enemy-relative timing is not invariant. This consequence is explicit.
- SFX's effective saved gain is changed at its actual consumer, not only the bus
  layout overridden during startup. Other buses, exact clips/pitches and ducking
  are untouched.
- Recorder capture copies the existing Master mix without modifying gain,
  devices, source clips, input binding/sending, gameplay or the PNG worker. Rate/
  driver/effect changes and discarded/invalid/unwritten samples are not hidden.
  Captured overrange/clamped PCM does not prove hardware output or comfort.

## Evidence boundary

Main reviewed complete changed functions, immediate callers/consumers, exact
morning-to-C2 diffs, protected source hashes and four synchronized documents.
Static whitespace checks passed. Existing primary rendered trials, selected
viewport images and WAV/lifecycle observations are separately recorded in
REPORT.md and PROGRESS.md. Their normal bound events are not physical-controller
acceptance; headless regression results are recorded separately after completion.
No new game/test/build run was initiated by this read-only review.

The physical Enemy-overlap snap, unanswered safe-end/AI-spacing decisions,
hip-level emission, zero-flight visibility, remaining pose/art quality,
Charging-during-hurt seam, human audio/controller comfort and inherited shutdown
warnings remain open. None is concealed by this narrow implementation result.
No code, cleanup, gameplay decision, commit/push or submission clearance was made
under Ultron's review authority.
