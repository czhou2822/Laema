# Overnight Fire combat review — October 23–24

Status: FINAL CANDIDATE HANDOFF, prepared07:40HKT October24 for08:00 delivery.
Candidates froze before07:30. Product source is local main3200279f, including
the restart-camera repair and provisional X5 timing; the accompanying records
commit changes no further gameplay. No push or Web export. All tuning and
presentation remains a candidate for the user's controller playtest.

Evidence index: [local integration](LOCAL_INTEGRATION.md),
[activity accounting](TIMING.md), [chronological ledger](PROGRESS.md),
[original-media hashes](ARTIFACT_HASHES.json).

## Current result

- Shared reaction Level 4 now delivers its existing 20px shove promptly, while its 1.15s stun remains unchanged.
- X5's provisional pre-split duration is now0.55s instead of0.30s, with1.10s recovery unchanged. It cleared an observed low-Heat protection overlap; this is not a high-Heat safety guarantee.
- Optional contact/camera treatments distinguish confirmed damage. The refined Weight accent is clearer than its first version, but is not final artwork.
- Simultaneous mixed-Cast captions and damage values are now separate, including during observed right-edge movement. No amounts are aggregated.

## Baseline and evidence boundary

Baseline f6ccfbe03143b5bf591ee83f5725ddb3919644b3 was preserved as an archive. Actual Windows Godot4.7.1 rendered at1280×720/60physicsHz. Complete encounters use ordinary bound input events, with zero unexpected inputs in the clean trials. These are agent-scripted encounters, not physical-controller usability acceptance. Paused review time is not active play.

The first preflight mistakenly used normal game userdata:2log/69shader-cache paths changed; no other file types were found in that interval. No tuning/preferences were saved there. An explicit unique userdata override corrected later runs. Do not claim the normal profile was entirely untouched.

Selected original captures are preserved beside this report. The baseline7.7s master WAV is valid captured game output, but has NOT been auditioned. No audio-comfort improvement or audio change is claimed.

There were six numbered change/replay comparisons and23combat Enemy defeats
across31rendered trials, including separately labelled preflight, UI and partial
diagnostics. Sampled scheduled unpaused operation was about13m26s, not eight
hours of continuous play. See TIMING.md/TIME_ACCOUNTING.json for the honest
activity boundary;62selected original media outputs have hashes in
ARTIFACT_HASHES.json. Not every recorded frame was individually inspected.

## Iteration 1 — prompt shared shove

**Target:** separate a heavy hit's quick displacement from its longer hurt/stun.

**Changed:** commit4b715460 modifies only Level4 motion1.15→0.15s in the shared character Resource and its existing mirror. Distance20px, stun1.15s, bands, damage and every other level stay unchanged. No per-attack override returns.

**Actual review:** baseline X5 produced a qualifying Level4. M1 measurements deliver the same20px in9physics steps/about0.15s while the target remains hurt for about1.15s. Original frames were inspected. A fresh complete M1 fight endedP100/E0/Heat26/unexpected0. Later presentation replays retain the same Resource values.

**Judgment/disposition:** provisionally retain. The shove no longer drifts through the full hurt period. Morning acceptance is still human-owned.

**Remaining weakness:** some later X5 contacts resolve INVINCIBLE and cause0Health loss. They are not failed inputs; fixed protection remains intact. Feedback must not fabricate a damaging hit.

Evidence: M1-02/ and baseline-01/. One earlier M1 trial ended atEnemy4HP and is explicitly incomplete.

## Iteration 2 — truthful contact and optional camera response

**Target:** make actual contact more recognizable without hiding the blade, opponent or Charging HUD.

**Changed:** U's a1d7d1c3 adds opt-in Precise/Weight treatments in existing Feedback/Arena owners. Only APPLIED direct damage with Health lost qualifies. Mixed layers coalesce per action/target; camera emphasizes stronger qualifying reactions and composes with existing framing. Independent switches default off. No simulation clock, actor, hitbox, audio or input change.

**First review:** complete Precise and Weight encounters proved live cues, but neither original treatment gave a decisive readability gain. Red Weight shapes could resemble a glove/cuff; Precise ticks blended with blade highlights.

**Refinement:** C2a12a3109 adds a tiny white center/black edge inside Weight's existing footprint. Native captures and Mali's review support better local contrast without hiding the hand/blade/HUD. It still looks like a prototype marker rather than final spark artwork.

**Correctness follow-up:** actual Final Arena shutdown exposed a new detached-area query error. C31908008f repairs only that lifecycle path. Ordinary menu Retry, fresh damaging contact and normal quit were replayed; the null-tree/script error no longer reproduced. Generic ObjectDB/resource-exit diagnostics remain separate.

**Control checks:** native Portal toggles update both fighters live; Save visibly succeeded and a fresh process loaded the saved off preferences. All92isolated configuration files were restored byte-identically afterward. Clean camera-only play produced0contact-accent frames and a sampled1.836px camera peak; contact-only play produced accents with0camera offset. Both encounters completed.

**Disposition:** retain C2 as an OPT-IN morning candidate, with both alternatives preserved. C4/C5 only shorten selector labels and wrap the new tooltips; native fit was checked. Source code plus focused fixtures do not establish motion comfort.

Evidence: contact-C1/, contact-C2/, controls/. UI01's mistaken post-Portal pause sequence is EXCLUDED as a combat comparison.

## Iteration 3 — readable mixed-Cast information

**Target:** preserve the separate13/10damage results and WaterLv4/FireLv2captions without overprinting.

**Changed:** C6d34ca57c separates same-actor, same-frame siblings horizontally in their existing lanes, preserving text, colors, fonts, outlines, timers, vertical tweens and DoT. No23aggregation or global manager. C78593348e keeps formed families within the viewport when the victim subsequently moves.

**Actual center replay:** the same ordinary FFWW case endedP100/E74/Heat18/unexpected0. Actual node measurements and native images show an8px outlined gap in each family. Both captions and both amounts are independently readable. The complete mixed encounter endedP100/E0/Heat28.

**Found and repaired:** a controlled moving-edge test initially failed8checks: creation-only clamp allowed8px clipping after a20px owner move. C7's edge-only UI correction passed1,991focused checks. It changes no victim motion or label lifetime.

**Ordinary edge replay:** walking, guard, dodge and melee brought a live Pikeman rightward; no positions/resources/AI were forced. The mixed Cast launched at level4Water/2Fire. Across22visible caption samples, the target movedX535.736→547.502and back; right outlined bound stayed≤1268 in a1280viewport, gap8px. Original native frames and Mali's review support the narrow right-edge correction. The encounter completedP50/E0/Heat23/unexpected0.

**Disposition:** provisionally retain the simultaneous-label correction and C7 edge repair. Older fading melee numbers can still clutter the amount row; that persistence policy was deliberately left unchanged. Rendered left-edge coverage and human feel remain separate gaps.

Evidence: mixed-labels/. Right-edge originals and measurement summary are preserved.

## Iteration 4 — longer X5 preparation, fixed protection

**Target:** test whether a modestly longer existing X5 preparation gives a
qualifying heavy contact without changing the target's protection rules.

**Changed:** U's5cc98e8e changes one Resource value: X5 pre-split duration0.30→
0.55s. Recovery1.10, native poses/geometry/markers, lunge values, all other X
styles and normalized input rules remain fixed. Base X5 duration is1.65s;
completion/queued Cast is0.25/Heat-multiplier seconds later at constant Heat.

**Actual review:** the earlier0.30 replay's X4→X5 contacts were815ms apart:
the target's0.85s protection rejected X5 for0damage. A closely comparable T1
prelude also ended Player90/Enemy150/Heat8. Its next X4→X5 interval was1067ms;
X5 applied10damage/Level4 and the subsequent Cast launched. Incoming/AI timing
was not seeded, so final Health differences are not a controlled treatment effect.

Two full T1 encounters completed Player77.5/Enemy0/Heat21 and Player70/Enemy0/
Heat13, unexpected inputs0. Full five-hit chains were observed in both facings.
The agent adapted with a normal dodge-through when earlier inputs were lost to
actual hurt. Those four-hit/interrupted attempts are not reported as five-hit
successes. Native preparation/strike samples retain connected hand/blade/body;
Mali found no obvious new separation or obstruction, not a motion-comfort pass.

**Judgment/disposition:** provisionally retain as a morning timing candidate.
The observed low-Heat contact margin is better, with a more readable existing
preparation. Whether that feels deliberate or sluggish still belongs to the
controller playtest. Local integration is3200279f; the original0.30 comparison
remains recoverable in history. No new animation or invulnerability rule.

**Remaining weakness:** fixed protection can still reject otherwise valid fast
follow-ups, particularly as Heat increases. T1 does not solve that general
design/timing interaction or guarantee a safe Cast. Levels5–8 still retain base
Cast Impact1; larger level/visuals do not promise a stronger reaction.

## Iteration 5 — intermediate X5 preparation, not retained

**Target/change:** recover0.10s of T1's extra preparation without losing its
observed contact benefit. U's isolatedT2b84b3181 changes only X5pre-split0.55→
0.45s, retaining1.10s recovery; all other source is the same. X1 was unchanged.

**Actual review:** normal-input146136_815402 prelude endedP90/E150/H8; the next
guard/chain segment endedP87.5/E87/H18, matching T1's corresponding outcomes.
X4→X5 contact interval was968ms/APPLIED10/Level4, versus T1's1067ms. Native
frames showed no obvious new silhouette break. The complete encounter ended
P67.5/E0/H8/unexpected0; final HP differences are not a controlled treatment
effect. No gameplay stderr; normalquit6.

**Judgment/disposition:** leave T2 unmerged and retain the better-supported T1.
T2 clears the same low-Heat protection interval with about99ms less margin;
the sampled poses do not establish a compensating improvement in flow/comfort.
This is an inconclusive feel refinement, not proof that0.45 is bad. Its commit
remains a recoverable comparison for the user's controller judgment.

## Iteration 6 — newly authorized X1 phase comparison, not retained

**Target/change:** make X1's preparation less rushed without increasing its
0.72s total. After the user's explicit late authorization, Dum-E's isolated
P1cfa94d2d changed only preparation/follow-through0.21/0.51→0.28/0.44. X5 was
restored to main's0.55 before this comparison; T2 and P1 were not combined.

**Actual review:** two full normal-input fights completedP77.5/E0/H23 and
P70/E0/H5, unexpected0, including full five-hit chains in both facings. In the
closely comparable opening, X1 contact came243ms after acceptance instead of
192ms, while X2 began at essentially the same time. Native images show the
longer preparation and unchanged connected blade/body; this is not human feel.

**Tradeoff found:** the same very early second-X request had native progress
0.333 with the original timing, inside the unchanged0.28–0.48buffer. It queued
and produced X2/two hits. P1 reached only0.250 at that request, before the same
buffer; it was ignored and only X1 hit. No game state was forced. This is a
partial normal-input timing diagnostic, not a usability study or broken buffer.

**Judgment/disposition:** leave P1 unmerged. It buys more visible preparation
but reduces tolerance for that early press; normal cadence still worked. A net
feel/connection improvement was not established. Preserve the exact branch for
the user's controller comparison. Main keeps X1 at0.21/0.51; no input/buffer,
damage, native geometry or dodge rule was changed to conceal the tradeoff.

## Final-replay correction — detached camera callback

The first merged-default-off fight completed Player77.5/Enemy0/Heat27, but its
normal Gym Retry emitted a new null-tree camera-callback error. This was a
different path from C3's detached Stage Area fix. R1ab284aa7 guards detached
updates and disconnects only the owned callback; Main integrated it asd6a74074.
The exact focused fixture passed1,998checks/0failures/no stderr in Main's isolated
copy. Fresh normal Gym Retry and complete T0/T1 fights no longer reproduced the
error. Generic ObjectDB/resource-exit diagnostics remain uninvestigated.

## Final verification and remaining limits

Observed ordinary-input cases include empty-Cast failure, early release with an orb actually charged, held Fire block/chip, successful parry, normal FireLv1Cast followed by melee, empowered mixed Cast, FireLv8launch, both-facing Fire chains, and an overlap-extended dodge. Failed self-reaction and blocked/parried results produced no new ordinary-hit cue.

Natural practice raised Heat27→43→59→75→91. Fire then chained all five actions at91Heat, but all five missed the short dummies; the retained Water orbs cast normally. This is high-Heat Fire playback, NOT high-Heat contact against a live enemy.

Read-only native Editor samples atX2clock0.2798/0.64/0.80 show the saved capsule tracking the visible blade. Player scene and all91non-JSONconfiguration Resources stayed byte-identical. Unused older test scripts calling retired AttackGeometry.contact still produce editor parse errors; no clean whole-editor/full-suite claim.

The controlled dodge regression passed512of513checks. Its only failure expects the retired per-X5 editor-control count; it was not repaired under this presentation scope.

Archer/legacy-off completedP5/E0/H9 and Archangel completedP42.5/E0/H10, both
unexpected0. Body-debug frames/Mali reveal a pre-existing Archangel humanoid/
capsule registration separation, not a new contact/label regression; it was
left unchanged. Normal training exercised all five Air and Earth hits plus
genuine AirLv3/EarthLv5 Casts. See regressions/SUMMARY.md for exact limits.

The initial X1 handoff was blocked by the older writer restriction. The user
explicitly authorized Dum-E for that exact comparison at about06:43; P1 was
implemented and actually compared as Iteration6. There is no remaining writer
clarification. P1 and T2 remain unmerged; T1 is retained only as the candidate
described above. No native hitbox geometry was silently retuned.

Current Cast levels5–8 retain base Impact1 by the existing GDD. Bigger displayed level does not guarantee a stronger reaction; this fixed rule was NOT changed. Final Arena's tile top64 versus collision top52 is a native room-registration issue, also left unchanged.

The final exact-source/default-JSON PrototypeArena fight endedPlayer80/
FinalEnemy0/Heat28/unexpected0, with the visible green 'now you are free'
objective. Optional effects stayed off/camera0. No gameplay script error;
normal quit retained the generic exit diagnostics. Final Arena telemetry can
still show a practice target's Health after the final Enemy dies; no focus
policy was invented. The final native frame is in regressions/.

Directly affected canonical records are synchronized as candidates. Guarded local
integration preserved all6,293 unrelated draft/department entries byte-for-byte;
the index was empty and no incoming/dirty path overlapped. The final101candidate/
configuration files matched the replayed isolated source byte-for-byte. Bounded
source review is IMPLEMENTATION_REVIEW_COMPLETE, not submission clearance.
LOCAL_INTEGRATION.md records scope and the local receipt. No final gameplay,
artwork, audio or submission acceptance is claimed.

## Morning controller review

1. Does X5's0.55 preparation feel deliberate rather than sluggish? Check a
   full chain and its following Cast at low and naturally higher Heat.
2. Does the prompt shared Level4 shove communicate the impact while the
   unchanged stun remains readable?
3. Compare optional contact/camera in General → UI → Cosmetic impact feedback:
   Precise and Weight, independently on/off. Defaults remain off. Check comfort
   and mixed-caption readability, including older fading-number clutter.
4. Try physical stick/trigger input, overlap/wall dodge and charge/Cast cancel.
   Synthetic input is not your controller acceptance.

X1 P1 and X5 T2 are unmerged comparisons. If you want to audition them, change
only their stated Resource values on current main; do not switch whole worker
branches, whose ancestry is not the complete retained baseline. Audio balance,
X3 artwork, point-blank Cast visibility/origin presentation, deliberate AI
spacing, wider creature alignment and high-Heat protection remain open. Their
absence from this pass is not a silent claim that they were fixed.
