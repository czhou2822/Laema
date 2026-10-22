# Fire combat — October 22 daytime review

Status: **daytime run closed17:30:48 HKT; heartbeat deleted, chat kept open.** C7 product source **1404d0ab**, final evidence **2151ffa0** independently remote-verified **17:21:07 HKT October22**; see [final receipt](FINAL_PUBLICATION.md) and [short review handoff](REVIEW_HANDOFF.md). First lunch publication **05fb22b8** met the deadline at **12:03 HKT**; earlier snapshots remain in history. Seven change–play–review rounds are recorded, including rejected candidates. All retained changes remain candidates for your controller review, not final game-feel acceptance. Candidate introduction stopped17:00; no further gameplay changes were made during closeout.

## Where the five concerns stand

All five have equal priority. A narrow improvement is not the same as solving the whole concern.

| Concern | Retained candidate | Still unresolved |
| --- | --- | --- |
| SFX too loud | SFX bus gain 0 → -6 dB, with the liked magic clips and pitches preserved | Human listening comfort; rare recorded overload remains |
| Dodge-end snap | Corrected native-pose ownership and one-frame completion handoff | Physical de-penetration when a dodge ends inside the Enemy |
| Detached X4 → X5 | X4 recovery 0.51 → 0.36 seconds | Art/pose discontinuity and X5's long late hold |
| Pikeman never makes space | Diagnosis and real encounter evidence; no new AI policy installed | Whether to regain distance only after attacks or whenever too close |
| Weak Casting presentation | Fire projectile drawing enlarged 1.5× at every level, preserving level ratios | Hip-level origin, point-blank disappearance and unfinished primitive artwork |

## Iteration 1 — first candidates, followed by actual counterexamples

### Target change

Reduce the mix, shorten the held X4 tail, make Lv1 Casting readable, and isolate the dodge snap and Pikeman-spacing causes. Preserve damage, Health, Impact/Poise, Heat, normalized windows, shared Cast timing and the approved dodge contract.

### What changed

U changed only the Player presentation path, Fire projectile drawing scale and Fire X4 timing. Dum-E changed only the effective SFX JSON gain. Four independent candidate units:

- **Player C1:** retain native dodge Sprite ownership; select a locomotion handoff using raw directional input for one frame.
- **Fire projectile:** drawing baseline 1 → 1.5; Lv1 is now 36×27 world pixels and Lv3 72×54. Collider, physical origin, flight, lifetime and damage are unchanged. Other schools are unchanged.
- **Fire X4:** windup 0.33 remains; recovery 0.51 → 0.36, total 0.84 → 0.69 seconds before Heat. Native Sprite/weapon keys, active markers, lunge and push are unchanged. X5 stays 0.45/1.10.
- **Audio:** effective `audio.sfx.volume_db` 0 → -6. Exact clips, pitches, Ambient/BGM, ducking and event timing are unchanged.

The original 692-path morning source is recoverable through [BASELINE_MANIFEST.json](BASELINE_MANIFEST.json). C1's exact changed source is in [candidate-01-source](candidate-01-source/). U also added opt-in, bounded Master-mix WAV capture to the existing playtest recorder; it defaults off and captures no microphone/OS audio.

### Actual play and review

Fresh isolated rendered Windows Godot 4.7.1 processes used ordinary bound movement, X, full-pressure Charging, release, dodge and Retry inputs. No actors, Health, Heat, resources, positions, AI or clocks were forced. Inputs were scheduled rather than operated by a human controller; selected actual viewport frames were reviewed.

- **Complete mixed encounters:** morning baseline won with 70 HP; a source-identical audio repeat won with 80. C1's matched control schedule won with 80. These small, unseeded runs do not establish easier difficulty or superior survival.
- **Five-X comparison:** baseline and C1 each accepted and landed all five X attacks, generated five orbs and ended Player100/Enemy150. X5 started about **0.154 seconds earlier** with shorter X4. Real movement/Enemy re-approach can differ because the earlier action changes the encounter timing.
- **Audio:** both actual Master captures are exactly 12 seconds, stereo PCM16 at 48 kHz, with valid headers and no discarded, invalid or unwritten frames. Over-full-scale source samples fell **3500 → 2**; recorded RMS was **-12.71 → -18.36 dBFS**. This supports provisional headroom improvement, not exact speaker-output or listening-comfort acceptance. The two rare overload samples remain.
- **Open-range Casting:** naturally generated orbs produced a normal Lv1 and then Lv3. Both travelled and hit; the larger drawing is visible. The ranges and frame ages differ, so the images are not a controlled perceptual-ratio comparison. At point blank, a projectile can still disappear immediately after contact.
- **Dodge cause separated:** an open-ground dodge travelled exactly 120 units and stopped stably. An overlapping-enemy finish travelled the same 120, then collision restoration moved Laema **another 28.14 units**. That physical correction is not fixed by a Sprite handoff.
- **C1 regression:** holding Left against the wall produced Dodge → **Walk for one sampled frame** → Idle despite no root movement. Repetition reproduced the problem. C1's raw-input handoff was rejected rather than kept for a nicer open-ground result.

### Judgment

Keep the SFX reduction and shorter X4 **provisionally**. Keep the larger Fire drawing as a limited visibility improvement, not a complete Cast-presentation solution. Reject C1's raw-input dodge handoff. Do not add a retreat rule or change physical dodge endpoints without settling those behavior choices.

What still needs improvement: the low-body spell origin, immediate point-blank disappearance, primitive visual identity, artistic X4/X5 continuity, and physical overlap snap.

### Evidence to review

- [Original mix, SFX 0 dB](baseline-audio-01/master-0db.wav) / [candidate mix, SFX -6 dB](candidate-01/master-sfx-minus6db.wav). These are game Master recordings, not isolated SFX or a performed listening acceptance.
- [Lv1 in flight](candidate-01/cmd_9_frame_000585_full.png) / [Lv3 in flight](candidate-01/cmd_10_frame_000642_full.png).
- [C1 events and observed states](candidate-01/events.jsonl); [baseline records](baseline-01/).
- Support-only early-quit probe: a requested 30-second audio recording was stopped after a genuine 1.003-second prefix; valid header and uninterrupted prefix, **not** a complete 30-second recording. An earlier intended early-quit probe actually finished all 12 seconds and is not counted as early-stop coverage.

## Iteration 2 — correct the wall handoff, then replay under pressure

### Target change

Remove C1's stationary-wall Walk flash without changing actual movement, collision restoration, dodge duration/cooldown/invulnerability, or response to new actions and hit reactions.

### What changed

U replaced the raw-input locomotion selector with a private **completion-physics-frame pose hold**. The next physics frame resumes the original actual-motion-based Walk/Idle logic.

The hold is cleared by a new attack/dodge, school change, hurt, stage lock or reset. Callback ordering was reviewed so cancellation/reset cannot leave a stale hold. No position/velocity, collision, action-acceptance, movement-provider or timing rule changed. Current Player hash begins **9b705e0d**; the other three product candidates are unchanged.

### Actual play and review

A fresh C2 process was used; no source was hot-swapped into C1.

- **Matched held-direction wall case:** sampled final Dodge poses returned to Idle without C1's false Walk. Root stayed about -557.99; Player remained100.
- **Repeated wall case:** three new dodges each lasted **24 physics ticks / 0.4 seconds**. A post-dodge X was accepted while dodge cooldown still remained. No false Walk was observed in the non-action wall frames.
- **Continue the encounter:** ordinary escape and X/Charging/Cast pressure then won **Player60/Enemy0**. Empowered Lv5/Lv7 launched; two actual no-charged-orb failures remained. There was no mid-encounter healing or resource repair.
- **Dodge pressure:** 13 fresh presses requested; **10 executed**. Three requests followed actual hit reactions. Each executed dodge completed24 ticks; Player ended70/Enemy200. Inspected frames show the roll, genuine10-damage hurt and continued pursuit.
- **Continue again:** the same70HP state was carried into melee/Casting. Fifteen X hits reduced Enemy200→50. A corrected full-pressure hold was interrupted twice by real incoming hits; only Lv1 remained at release, which committed/launched normally. Subsequent melee won **Player50/Enemy0**. An intended level is never substituted for the observed level.
- **Operator errors preserved:** command8 was rejected before gameplay because required Boolean fields were omitted. Corrected command9 used half pressure, which the current GDD defines as depletion, not Charging; its three failed Casts are not evidence of unexplained engine failure.
- **Native UI setup limitation:** closing the Portal resumed the game, and Laema died passively while the next observation was being reviewed. That unattended setup interval is excluded from active-play/difficulty claims. Ordinary Retry was used; no Health was written.
- **Fresh follow-up:** normal defeat-Retry and the mixed schedule from a different starting position won Player20/Enemy0, with an empowered Lv6 and four actual no-charged-orb failures. Known native-setup counter8 stayed8 during that trial. Different opening context prevents a causal difficulty comparison; the poorer outcome is retained.

C2 started with no physical controller connected, whereas C1's startup listed XInput. These runs therefore do not establish physical-controller A/B, analog priority or human comfort. Scheduled-input trials had no unexpected gameplay input; known native Portal setup is recorded separately.

### Judgment and disposition

**Provisionally retain C2** for its observed wall-presentation correction. It is a real improvement over C1 in that case, not a cure for the independently reproduced physical collision snap. Retain the other three limited candidates pending final source/regression review and human acceptance.

The four candidate units were retained for final regression and documentation synchronization. New AI spacing and dodge safe-end behavior still need their actual design decisions. The following third round checked whether a further timing reduction would actually help.

## Iteration 3 — shorter X5, tested and rejected

### Target change

Reduce the long X5 late strike/recovery hold, rather than treating earlier X5 arrival alone as proof that the late chain feels connected.

### What changed

U changed only Fire X5 recovery **1.10 → 0.85 seconds**, leaving windup0.45 and every other field unchanged. Total duration became1.30 instead of1.55 seconds before Heat. This also advances late active playback and the following Cast; it is not merely trimming an idle wait. Exact candidate hash0a8309a5 is preserved in [candidate-03-source](candidate-03-source/).

### Actual play and review

A fresh retained-D process and fresh C3 process used the same20-edge opening: ordinary approach, five X attacks, full Charging and release at4.5 seconds. Both started100/200, had no unexpected inputs, landed all five melee hits and committed an empowered Lv5 Cast. Actual late-phase frames were inspected.

- **D / recovery1.10:** endpoint started5.070s, projectile launched5.350s and applied **13 damage**. Player100/Enemy137 after the opening.
- **C3 / recovery0.85:** endpoint started4.836s, projectile launched5.116s and resolved **INVINCIBLE / 0 damage**. Player100/Enemy150 after the opening.
- C3's late pose advances sooner, as intended. But the earlier projectile arrived before the X5-induced Enemy hit-reaction invulnerability ended. This is a concrete timing consequence in the actual encounter, not a prediction from a formula or an invalid Cast input.
- Both encounters were continued from their actual states with the same ordinary follow-up controls, without healing/repositioning/resources/AI writes. D won80HP; C3 won60HP. These small unseeded whole-fight outcomes are not statistical difficulty evidence. The opening's observed damage difference is enough to reject the candidate.

### Judgment and disposition

**Reject C3 and restore recovery1.10.** U restored the exact previous57aef5ab Resource; Main copied it back to the isolated runtime only after C3 closed. No shared reaction duration, invincibility, Cast timing or damage rule was changed to conceal the result.

What worked: the comparison made the shorter hold and its real consequence visible. What needs improvement: X4/X5 continuity still needs a treatment that does not swallow the following spell. "Faster" alone is not the acceptance criterion.

Evidence: [D late hold](timing-d-01/cmd_2_frame_000080_full.png), [C3 earlier recovery](timing-c3-01/cmd_2_frame_000080_full.png), [D engine facts](timing-d-01/timing-d-01-engine.log), [C3 engine facts](timing-c3-01/timing-c3-01-engine.log). The encounter records retain exact inputs, observations and outcome timing.

## Iteration 4 — make the objective readable, then check real progression

### Target change

Afternoon normal-input high-Heat practice exposed a concrete presentation defect:
the Stage7 sentence extended beyond the right edge, hiding "Heat or higher".
Correct this existing widget's text fit without changing the objective, input
rules, typography, strings or gameplay. This is an ancillary presentation repair;
the five morning concerns remain equal priority and their open choices remain open.

### What changed

U added exactly two Label properties in `scripts/ui/objective_widget.gd`:
word-smart wrapping and a maximum width equal to the existing widget width minus
its panel's horizontal style margins. Current allocation330 minus4 gives326px;
the vertical maximum is unbounded. The panel can grow downward. Tokens, fonts,
colors, evaluator state, prompt and UI flinch code are unchanged. Source hash
**e91201b5**; original **4c808a50** is preserved in candidate-04-source-before.
This is not a new general responsive-layout architecture: width is sampled when
rows are rebuilt, and long token HBoxes are outside the two-property change.

### Actual play and review

Main first played the published C2 source to genuine100 Heat, closed that process,
then copied only the widget into a fresh rendered4.7.1 process. No hot swap or
forced Health/Heat/orbs/positions/AI/clocks was used.

- **Current C2 practice:** three120-second normal-input batches launched48
  normal Lv1 spells without failed Casts, naturally building Heat4->36->68->100.
  An uncharged five-X attempt at100 accepted all positions and applied35 units
  of authored lunge. OnlyX3 hit the short legacy dummy at this spacing; this is
  not Stage7 completion or an incoming-Pikeman trial.
- **C4 replay:** the same three-batch approach again produced48 normal Lv1
  launches/no failures and genuine100. Maximum scheduled-edge lateness was
 17/37/16ms across the batches; the37ms outliers are retained, not discarded as
  inconvenient. All five high-Heat X positions were accepted again.
- **Text before/after:** actual100-Heat frames show the previously clipped row
  now wrapping into two complete lines inside the viewport, with five tokens
  below. The panel grows down rather than preserving the old height.
- **Hidden debug and natural reversion:** normal Portal switches disabled
  developer overlay and hitboxes for this run only; no Save Tuning. Ordinary
  idle let Heat100 fall below80. The Heat goal changed green->white while the
  complete sentence and game-facing orb/Heat UI remained visible. Player100,
  Enemy190 and position stayed unchanged; the remaining orb expired normally.
- **Completion:** normal Portal Stage2 entry, ten uncharged five-X attempts and
  ordinary retreat/refacing earned five FIFO orbs. Full Charging then released
  an actual standalone **FireLv5** Cast. Its launch completed Stage2, turning the
  whole widget green and showing **moving on ->**; its later hit applied10.
  No assumption that generation alone meant completion was used.
- **Rebuild:** normal right movement and the authored transition activated
  Stage3. The new sentence and compact instruction-token row fit in the actual
  captured frame. Normal stage reset cleared Heat/orbs and kept Player100.
  However, the transition emitted14 physics-mutation errors while instantiating
  the next area. This is preserved as an independently investigated pre-existing
  lifecycle issue, not an error-free transition or a widget regression claim.
- **Scope limits:** these are keyboard/scheduled normal-input practice and
  rendered UI checks, not human-controller feel acceptance. The earlier flinch
  keyframe did not isolate every motion phase; unchanged flinch code is not a
  substitute for such coverage. C4 exited0 with the existing13/9 shutdown warnings
  in addition to the recorded transition errors.

Evidence: [clipped C2 row at100](c2-heat-practice-01/cmd_6_frame_001267_full.png),
[wrapped C4 row at100](c4-objective-fit-01/cmd_6_frame_001267_full.png),
[hidden-debug goal green](c4-objective-fit-01/cmd_8_frame_001357_full.png),
[natural below80 reversion](c4-objective-fit-01/cmd_8_frame_001437_full.png),
[Stage2 completed](c4-objective-fit-01/cmd_10_frame_001695_full.png), and
[Stage3 rebuilt](c4-objective-fit-01/cmd_11_frame_001850_full.png).
Exact inputs, observations and warnings remain in the two session archives;
[C4 source identity](AFTERNOON_C4_SOURCE_IDENTITY.json) rechecked692 root/runtime
paths with zero mismatches, including unchanged protected combat sources.

### Judgment and disposition

Provisionally retain the two-property text-fit candidate for the demonstrated
clipping correction. U synchronized the exact TDD/status representation; Main
read the actual diff and completed a bounded Ultron implementation review with
zero new in-scope findings, not submission clearance. Human acceptance remains open.
It does not settle dodge overlap, Pikeman spacing, Cast origin/art or listening
comfort. Transition stderr requires its own source-backed diagnosis and exact
scope; it is not hidden behind a successful screenshot. No new AI/gameplay policy
or replacement artwork has been accepted. At this13:17 review's closure the
afternoon source/evidence was not yet pushed; publication must be independently
verified and recorded separately, not inferred from the lunch push.

## Iteration 5 — a smaller X5 trim, not retained without a demonstrated benefit

### Target change

Check whether an intermediate late-X5 reduction can shorten the closing hold
without repeating C3's swallowed following Cast. Do not equate a faster endpoint
or a better unseeded fight result with solving the reported X4-to-X5 detachment.

### What changed

U preserved exact D57aef5ab, then changed only X5 recovery1.10->1.00. Windup0.45,
native keys/geometry, normalized windows and every shared combat rule remained.
Candidate19e95e92 has base1.45 instead1.55 seconds. This accelerates late active
and input wall time, not merely a cosmetic tail. The exact candidate is archived
in candidate-05-source; it was not added to the published gameplay source.

### Actual play and review

Fresh rendered D5 and C5 processes started100/200, empty orbs/Heat and no
connected controller. D5 used the unchanged runtime before U's single Resource
was copied; C5 launched only after D5 closed. Both used the identical20-edge
opening and52-edge continuation with normal input, no state/AI/resource writes.

- Both openings accepted and landed all five X, charged five orbs, launched an
  empowered FireLv5 and applied13 damage, ending Player100/Enemy137.
- D5 launched5.352s; C5 launched5.263s. C5 therefore avoided C3's zero-damage
  invulnerability result in this observed opening. This is bounded evidence,
  not immunity to every future timing/Heat/spacing interaction.
- Cold F4 release was106ms late in D5 and97ms in C5, before gameplay resumed.
  The other18 opening edges were within7ms/5ms respectively. Continuation edges
  were within7ms/6ms. No unexpected input occurred. Preserve the cold UI delays
  instead of reporting a uniformly low-latency run.
- Continued actual encounters won D5 at70HP and C5 at80HP. The older D round
  won80HP; these unseeded outcomes are not a causal difficulty comparison.
- Inspected matched late-X5 frames at about4.8s show the same existing pose in
  both. Only the later tail/endpoint advances. The X4->X5 onset handoff is not
  changed by this recovery-only adjustment, and no convincing correction of
  that reported disconnect has been established.
- Both processes closed normally with exit0 and the existing13 ObjectDB/9
  resource shutdown warnings. No new regression suite or human feel pass is
  claimed for this subsequently unretained candidate.

Evidence: [D5 late pose](timing-d5-01/cmd_2_frame_000083_full.png),
[C5 late pose](timing-c5-01/cmd_2_frame_000083_full.png),
[D5 following spell applied](timing-d5-01/cmd_2_frame_000089_full.png),
[C5 following spell applied](timing-c5-01/cmd_2_frame_000089_full.png).
The two session archives retain actual inputs, captures, states and logs.

### Judgment and disposition

**Inconclusive as an experience improvement; do not retain C5.** Avoiding the
previous zero-damage case is useful information, but is not enough to accept a
timing change that has not demonstrated the intended presentation benefit.
U restored exact D1.10/57aef5ab; Main copied it back to the isolated runtime only
after C5 exited. The candidate stays recoverable for human review. No shared rule
is changed to manufacture a favorable result.
Next hypothesis: distinguish the actual X4->X5 onset/pose presentation from a
late-X5 tail issue before another timing change. Fresh visual-direction work
still awaits its entry decision; no new art or AI/dodge policy is invented.

## Further retained-source play — no new implementation iteration

The [post-C5 encounter review](POST_C5_PLAY_REVIEW.md) records actual Fire block,
parry, post-attack refacing, real invincible dodge contacts, charged-orb retention,
pre/post-launch cancellation and a return to offence. The same Player survived
the whole encounter at37.5HP, with no mid-encounter Retry/healing/state repair.
Source remained C4; these bounded agent observations do not settle the open
presentation/design choices or replace the user's controller playtest.

The later [Casting presentation review](CAST_PRESENTATION_REVIEW.md) separates
two full failed Casts from two ignored/rejected-request cases using actual
generated/charged orbs. It also records in-flight Lv1/Lv3 drawings, target-owned
impact labels and a continuous Player90/Enemy0 encounter. The different full
failure causes are not explained in visible reason text; no new UI treatment
has been accepted or implemented.

## Iteration6 — test more spear standoff, reject the roll regression

The [complete Iteration6 report](ITERATION6_REVIEW.md) records target, one-leaf
72->96 range trial, actual normal-input replay and rollback. At96, Pikeman
stopped farther away and still reached Laema. But the same crossing Dodge
finished with about24.57 extra collision-correction units instead of0.57.
Both full fights ended Player70/Enemy0; this does not establish difficulty
equivalence. **Reject96 and restore exact72.** No new backoff policy or Dodge
safe-end behavior was invented to compensate. Actual before/after images and
both full event logs are linked in that report.

## Iteration7 — shorter X5 preparation, provisional review candidate

The [complete Iteration7 report](ITERATION7_REVIEW.md) records a different timing
hypothesis: X5 preparation.45->.30 seconds, with recovery1.10 unchanged. The
matched Right opening hit with X5 about123ms earlier and launched its following
empowered Lv5 about149ms earlier; all5 melee hits and the13-damage spell applied
in both. Both whole fights won at70HP. An additional C7 Left-facing five-X/spell
and continuous encounter also completed, with genuine incoming hits preserved.
**Provisionally retain C7 for the user's controller review**, not a claim that
its artwork is stronger or the physical overlap snap is fixed. The existing
full X5 controlled suite also exited0/1545 checks/zero failures; forced setup
is separate from actual play. Natural maximum-Heat coverage remains separate.

Later unchanged-C7 checks are recorded separately rather than counted as new
iterations: [genuinely earned100 Heat](C7_HIGH_HEAT_REVIEW.md),
[natural eight-orb Cast and same-fight victory](C7_LEVEL8_REVIEW.md), and
[earlier X5 Dodge/rearm/empowered Lv8](C7_X5_DODGE_REVIEW.md).
These add bounded agent observations, not all-case protection or human acceptance.
The [default Fire tutorial-target reachability finding](TUTORIAL_TARGET_FINDING.md)
is OPEN: the old short dummy lies below X1's active sweep. No target/art/collision
or objective change has been silently installed. The final extra session exited0
with25/15 shutdown warnings; earlier13/9 counts must not be reused for it.

## Lunch verification and publication boundary

After C2 rendered closure, all five existing geometry/input suites completed with explicit process exits0 and zero assertion failures: **1741 + 1236 + 1337 + 1185 + 1617 = 7116 checks**. X2 used its dedicated suite. Their forced setup/Heat/seeks make them supplementary controlled checks, never substitutes for the primary encounters above. Reports and stderr are in [regressions-c2](regressions-c2/). Fixture shutdown warnings were14/10,14/10,24/15,22/14,22/14 ObjectDB/resources, respectively; no warning-free exit or new cause is claimed.

The bounded [implementation review](IMPLEMENTATION_REVIEW.md) found no new contract violations in the four retained product deltas plus recorder extension; it is not whole-tree or submission clearance. [Lunch source identity](LUNCH_SOURCE_IDENTITY.json) rechecked all692 morning paths after C3 rollback: exact root/runtime agreement, four retained product changes plus the support helper, unchanged X5 D. The four affected canonical technical/status records are synchronized; the GDD was not redesigned.

The lunch source commit was pushed and independently remote-verified. [PUBLICATION.md](PUBLICATION.md) records the exact identity and boundary; a small metadata follow-up updates this receipt/status without changing the gameplay source.

The [time ledger](TIME_LEDGER.md) separates gameplay from review, implementation,
tests, support probes and waiting. Recorded live-opponent samples cover at least
4m19s across27 valid commanded gameplay episodes; this is not several hours of
continuous play or a human-controller test. The known operator-error trial is
separate. Later afternoon evidence will not be retroactively added to this count.

## Your short lunch review

Open the pulled Godot project and run the Gym on the tested4.7.1 version where
available. This publication contains editable source/evidence, not a new Web or
standalone export.

1. Listen to ordinary melee and Casting: is the -6dB mix comfortable while retaining the sound character you liked?
2. Dodge into open ground and against a wall: judge the return to movement/idle. The separate Enemy-overlap correction is still expected, not secretly fixed.
3. Perform X1–X5 and a following Cast: judge the shorter X4 handoff. X5 retains its longer D timing because C3 swallowed the following spell.
4. Compare Lv1 and Lv3 Casts at some distance: judge visibility, not damage scaling. The hip-level origin/point-blank visual problem remains.
5. Pikeman spacing is intentionally unchanged pending its actual behavior choice. The outstanding choice is when to create distance; it is not being mistaken for a missing retreat implementation.

Earlier processes exited0 with the existing13 ObjectDB /9 resources-in-use warnings; no warning-free teardown is claimed. New game audio is copyrighted original/derived material under the existing provenance record, not newly CC0. The report contains game-development evidence only.

The requested afternoon continuation remains active until17:30 HKT, with no new candidate after17:00. Lunch publication is not final game acceptance and is not a Web export.
