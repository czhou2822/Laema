# Fire combat — review handoff for17:30

Source candidate: **C7**, first published as1404d0ab. Later evidence/document
commits do not change the product. All tuning remains provisional for your
controller review; this is editable Godot source, not a Web/standalone export.
The [final publication receipt](FINAL_PUBLICATION.md) records the independently
verified evidence snapshot once the push has completed.

## What changed and what still needs work

| Equal-priority concern | Retained change | Not solved |
| --- | --- | --- |
| Loud SFX | SFX bus-6dB; liked clips/pitches preserved | Your listening comfort; rare recorded overload remains |
| Dodge snapping | Native-pose ownership/completion handoff corrected | Physical correction when the roll ends inside the Enemy |
| X4->X5 separation | X4 recovery.51->.36; X5 preparation.45->.30, keeping recovery1.10 | Existing pose/art discontinuity, heavy-impact feel and long tail |
| Pikeman crowding | Investigated/tested; no new policy installed | Deliberately stepping back requires your behavior choice |
| Weak Cast presentation | Fire drawing1.5x larger, existing level ratios preserved | Hip-level emission, primitive artwork, point-blank disappearance and failure-cause explanation |

Seven actual change–play–review rounds are in [REPORT.md](REPORT.md), with targets,
changes, evidence, judgments and retain/revise/revert decisions. Range96 was
rejected because it increased crossing-roll correction to about24.57 extra units
from0.57. Two earlier X5 recovery trials were rejected; C7 instead shortens setup.
Its matched Right case hit with X5 about123ms earlier and launched the following
empowered Lv5 about149ms earlier, still applying13. Left-facing play also applied13.
Small unseeded survival results are not a difficulty or human-feel proof.

## Additional actual play, not extra implementation rounds

- [Naturally earned100 Heat](C7_HIGH_HEAT_REVIEW.md):48 ordinary practice Casts,
  then all5 input positions accepted at150% speed and a real empowered Lv2 applied13.
- [Normal Lv8](C7_LEVEL8_REVIEW.md):genuinely generated orbs, normal retreat while
  Charging, actual8/8 UI, visible flight and target level/damage feedback; same
  fight won without Retry/healing/state repair.
- [Earlier X5 Dodge/rearm](C7_X5_DODGE_REVIEW.md):Circle120ms after actual X5 start
  cancelled before active; charged status cleared but four generated orbs stayed.
  Later empowered Lv8 applied13 and the same fight finished normally.

All primary evidence uses rendered Windows Godot4.7.1 and normal bound inputs,
not forced Health/Heat/orbs/positions/AI/clocks. Inputs were scheduled by the agent,
not a human controller. Selected actual frames are not a60fps animation recording.
Controlled tests, source review, implementation, paused review and waiting are
separate in [TIME_LEDGER.md](TIME_LEDGER.md). No audio audition is invented.

Final verification on the frozen candidate: all five existing controlled suites
explicitly exited0, **7044 checks, zero assertion failures**. Exact warning counts
remain in [the manifest](FINAL_REGRESSION_MANIFEST.json). These fixture passes
do not clear the short-dummy conflict or replace your own playtest.

## Important new finding before reviewing the tutorial

The old tutorial dummy is below Fire X1's entire active sword sweep. Source
transforms leave a21.61px vertical gap, so the default Fire-only five-hit route
cannot complete by horizontal spacing alone. This is NOT a failure against the
tall Pikeman or proof that every school/tutorial route is impossible. See
[TUTORIAL_TARGET_FINDING.md](TUTORIAL_TARGET_FINDING.md).

No invisible collider enlargement, sword distortion or objective-counting change
was slipped in. A separate visible full-height target/collision update awaits
your scope decision. Use the Gym for this Fire feel review; do not mistake the
known short-dummy conflict for a new combo-input failure.

## Short controller review

1. Listen: are the preserved melee/magic sounds comfortable at the new mix?
2. Perform X1–X5 and a following Cast: is the preparation less detached without
   making X5 feel too light? Exact previous D timing remains recoverable.
3. Dodge in open space, against a wall and across Pikeman. Distinguish the pose
   handoff from the still-open body-overlap correction.
4. Compare Lv1/Lv3 at some range, then charge8. Judge origin/impact satisfaction,
   not just whether the primitive became bigger. Current damage remains generic.
5. Decide when Pikeman should regain space, the desired physical Dodge endpoint,
   and whether to authorize the tutorial-target update/visual-direction work.

Remaining technical limits include inherited tutorial-transition physics errors
and shutdown resource warnings. The last extra rendered session reported25/15,
not the13/9 from earlier ones; it still exited0. No cause/fix or warning-free
teardown, whole-tree/submission clearance, all-Heat Enemy protection or human
acceptance is asserted. Candidate introduction stopped at17:00; only final
review/regression/report/publication remains before the17:30 cutoff.
