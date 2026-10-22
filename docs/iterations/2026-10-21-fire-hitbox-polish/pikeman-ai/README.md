# Pikeman AI phase — October 21

Result: `PRESSURE_SUPPRESSION_REPRODUCED`; `NO_PERSISTENT_DEADLOCK` in the
tested cases. No product AI, range, timing, collision, artwork or geometry edit.
Combat reviewed the pressure evidence before authorizing the separate X2 phase.

## Diagnosis

Passive approach works. The saved 72-pixel root-distance threshold is reachable;
attacks normally start around 71 pixels. Native melee_swing advances from windup
to active at 0.5 seconds and finishes at 1.0 seconds. Its zero-tail recovery
enters and exits inside one BT update; the existing trace records RECOVERY then
IDLE even though a post-frame observer sees only IDLE. The separate random wait
is retained.

Repeated ordinary Fire inputs reproduce attack suppression: accepted contacts
cancel approach/windup into HIT_REACTING, followed by the existing reaction and
post-reaction wait. Fire X1's Impact10 minus Enemy Poise10 produces value0 and
the approved player-zero-advantage Level1 reaction. Higher chain moves produce
stronger reactions. Enemy attack IDs are cancelled, not left running invisibly.
After pressure stops, every tested case resumes at least three full autonomous
windup/active/recovery/wait cycles and actual damaging contacts. Some pressured
cases still allow thrusts; suppression is not an unconditional AI lock.

Dedicated ordinary X1 presses during an already committed natural Enemy windup
cancel it before its thrust damages Player, in both directions. This is separate
from the baseline's explicitly labeled injected HealthEvent interruption.

## Retained engine evidence

Saved source: `921fd1ae207c990070cd279587f5a05ee0fb239c`.
Engine: Godot 4.7.1 stable official `a13da4feb8d8aefc283c3763d33a2f170a18d541`.
Rendered checks: Compatibility/OpenGL 3.3, NVIDIA RTX4090. Audio driver Dummy
during rendered runs. Hidden/off-screen isolated executable, project and profile;
the user's checkout/editor/profile were not run or rewritten.

| Evidence | Assertions | Scope |
| --- | ---: | --- |
| baseline-headless-report.json / baseline-headless.log | 14 | Both sides, three cycles and waits, Retry, normal movement input, labeled injected interruption |
| render-report.json / render.log | 31 | Same baseline with 17 rendered captures, including thrust/return in both directions |
| pressure-report.json / pressure.log | 50 | Fast repeated X and buffered five-position attempts on both sides; real contacts and three full cycles after stopping |
| single-x-report.json / single-x.log | 22 | Repeated standalone X1 on both sides; three full cycles after stopping |
| x1-windup-report.json / x1-windup.log | 20 | Ordinary X1 cancels a naturally committed windup, both sides; three recovery cycles |

All listed runs exited0 with no reported script/engine errors or failed
assertions. Reports retain positions, native clocks, facing, Sprite region,
Player move/action ID, Enemy committed action ID, chain position, input timing,
health and reaction outcomes. Pressure uses rising-edge InputEventAction through
the real input route; no direct try_light_attack call, manual clock advancement,
AI disable or tuning override is used. The right-side fixture swaps starting
positions and uses normal left movement to establish attack facing.

Before the pressure extension, the isolated project was compared byte-for-byte
with current saved project settings, actor/config/scene resources, contact
evaluation, the Enemy tree and all eight Enemy BT scripts: all 19 matched.
No shared persistence test was run in this baseline copy. Source-integrity
anchors (SHA256):

- combat_enemy.gd: B50B584FEB5E1F486A6EA1E860EEEF5F6D54D2402365727A58060F6912291CEC
- final_enemy.tres: BBABD27F45BE7001CBAA0C40F3936E34AD2933C88D2C20B83859BBD5D3E86AD3
- melee_swing.tres: 999AEDA7C0930FC488B30FB49FB6648D24199C4E72E637E5A1E3D42951769A97
- prototype_combat.json: 1F3134D982565A32DE3038CDC0242F598288E620F28838E7909512D3FD1EB8D4

Captures beside this note include both-facing native thrust/return, pressure
approach/windup/hit reaction, resumed active thrusts and the explicit X1 windup
interruptions. They were visually inspected; numeric checks alone do not certify
animation readability. Collision-debug overlays can obscure artwork and are not
an independent weapon measurement.

## Reproduction and limits

Use tools/test-dev-portal.py with an installed Godot executable, an isolated
work-root, --keep-work, --script tools/tests/pikeman_approach_test.gd and
--frame-limit 1000000 for the headless baseline. The runner copies source/assets
and supplies a private portable profile. On that isolated project, the same
script accepts --capture plus --output=<evidence directory> with a renderer;
add --pressure-only, --single-only or --windup-only for the three input probes.
Launch any helper window hidden. Do not run these fixtures in the user's editor
or use a project mutated by persistence tests as a pristine baseline.

Earlier failed development assertions remain in the retained isolated work
directory, rather than being erased. The initial probe erroneously expected
RECOVERY to persist across frames and queried an unassigned animation clock;
a later pressure assertion counted an already-active attack as a fresh cycle.
The retained successful reports supersede those helper defects; none required
a product fix. Wait lengths are randomly sampled and physics-frame quantized,
not a deterministic timing guarantee.

This does not establish the user's active-session source/configuration or
human acceptance, exhaustive stress coverage, changed Fire geometry correctness,
or overall game readiness. No commit, push, export or live publication occurred.
