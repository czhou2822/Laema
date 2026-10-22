# Fire combat — October 22 daytime review

Status: lunch publication is being prepared; no daytime commit/push has yet been made. Three change–play–review rounds are recorded below, including a rejected timing candidate. All retained changes remain candidates for the user's controller review, not final game-feel acceptance. Work continues toward 17:30 HKT after the lunch publication.

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

## Verification and publication boundary

After C2 rendered closure, all five existing geometry/input suites completed with explicit process exits0 and zero assertion failures: **1741 + 1236 + 1337 + 1185 + 1617 = 7116 checks**. X2 used its dedicated suite. Their forced setup/Heat/seeks make them supplementary controlled checks, never substitutes for the primary encounters above. Reports and stderr are in [regressions-c2](regressions-c2/). Fixture shutdown warnings were14/10,14/10,24/15,22/14,22/14 ObjectDB/resources, respectively; no warning-free exit or new cause is claimed.

The bounded [implementation review](IMPLEMENTATION_REVIEW.md) found no new contract violations in the four retained product deltas plus recorder extension; it is not whole-tree or submission clearance. [Lunch source identity](LUNCH_SOURCE_IDENTITY.json) rechecked all692 morning paths after C3 rollback: exact root/runtime agreement, four retained product changes plus the support helper, unchanged X5 D. The four affected canonical technical/status records are synchronized; the GDD was not redesigned.

Before calling the lunch package published, Main will commit/push and verify the remote ref. Actual publication outcome belongs in PROGRESS/PUBLICATION, not an anticipatory success claim here.

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
