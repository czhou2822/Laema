# Iteration7 — shorter X5 preparation: provisional review candidate

## Target change

Investigate the reported X4->X5 disconnect at X5's preparation/onset, rather
than repeat C3/C5's rejected recovery shortening. Keep X4's retained.33/.36,
X5 recovery1.10, damage, Health, Impact/Poise, Heat, shared Cast, normalized
windows, defence and Dodge rules fixed. No new bridge animation or artwork.

## What changed

U changed ONLY `config/attack_styles/fire_x5.tres` windup.45 ->.30; base total
1.55 ->1.40 seconds before Heat. Exact beforeD57 is preserved under
candidate-07-source-before; candidate SHA-256 is
651D9978BDBAFE9FB0E64A4053EB31E54F7CCDD0EF1A7FCFC91E509985C3A27C.

Main inspected the complete Resource, one-leaf diff and AttackStyle/Might
consumers after U's source trace. Native length1, timing_split.60, active.36..80,
Sprite/weapon keys, radius/reach, lunge12/.15..55 and push2 remain unchanged.
Pre-split native playback is1.5x faster; post-split speed is unchanged.
This is NOT merely cosmetic: contact/lunge and real-time input windows move.
The nominal earliest-contact-to-endpoint margin also shortens; unchanged
recovery1.10 does not guarantee a following spell clears target invulnerability.

## Actual rendered play and review

Fresh isolated Windows Godot4.7.1 D7/C7 processes used ordinary bound input,
the same requested Right opening and continuation, Enemy72 and recorder634.
No forced Health, Heat, orbs, positions, AI, clocks or evaluator state. Copies
were made only after normal closure. All unexpected-input counters stayed0.

| Right-facing opening | D .45/1.10 | C7 .30/1.10 |
| --- | --- | --- |
| Actual X5 start |3.523s|3.531s|
| X5's real contact |4.000s|3.877s|
| Endpoint Cast launch |5.350s|5.201s|
| Result |All5 X hit; empowered Lv5 applied13; Player100/Enemy137|Same qualifying result|
| Same-fight continuation |Won Player70/Enemy0|Won Player70/Enemy0|

The X4 finish/X5 start is effectively unchanged, not a new transition bridge.
The setup poses advance sooner into the existing attack; real contact occurred
about123ms earlier and endpoint launch149ms earlier in this small pair. Full
and smaller actual captures were reviewed around3.46..4.01s, not inferred solely
from the Resource. The remaining old poses and long tail have not been replaced.

After C7's first victory, normal Retry plus a real Circle crossing placed Laema
on the other side. A normal Left turn and five-X/Charging attempt landed all5,
launched empowered Lv5 at4.916s and applied13. Player stayed100 through the spell,
then received a genuine10-damage hit before pausing. After a normal recovery wait,
the SAME left-facing fight continued to Player70/Enemy0. No mid-fight Retry/heal.
Right opening had debug hidden; Left opening's actual captures have it visible
(the F4 toggle was not an off-state guarantee after Retry). No external inputs.

This is three full attacking encounters, not seven fights. The later requested
continuations include a real empty-charged failure after interruption; intended
inputs are not all labelled successful. The crossing still uses the existing
Dodge physical endpoint; no safe-end fix or new backoff was slipped in.

## Supplementary checks — not primary play

After rendered closure, the existing full Fire X5 geometry suite completed
**1545 checks, zero failures, explicit exit0** on this exact isolated candidate.
Its manual seeks, forced Heat/preparation and collectors are controlled fixtures,
not genuine resource-earned high-Heat play or human usability. The shorter action
produces a different count from D's1617; do not claim an identical assertion census.
Existing14ObjectDB/10resource shutdown warnings remain. Primary rendered processes
also exited0 with existing13/9 shutdown warnings. No audio audition was added.

## Judgment and disposition

**PROVISIONALLY RETAIN for controller review.** In inspected play the preparation
occupies less time before the existing thrust and the following empowered spell
still applies in the sampled Right/Left cases. This is a bounded response to the
reported late-chain hesitation, not proof that X5 feels heavier, that art blends
are solved, or that every cadence/Heat level has a safe spell margin. More natural
high-Heat practice remains to be checked separately. Human acceptance can still
reject the shorter anticipation; exact D is recoverable.

No survival superiority is inferred from70HP outcomes. All five concerns remain
equal priority. Audio comfort, physical dodge overlap, deliberate Enemy backoff,
Cast origin/impact treatment and failure-cause explanation remain distinct open
items, not supposedly solved by a timing change.

## Evidence and next step

- [D last X4 pose](timing-d7-01/cmd_2_frame_000062_full.png) /
  [C7 last X4 pose](timing-c7-01/cmd_2_frame_000062_full.png).
- [D later X5](timing-d7-01/cmd_2_frame_000070_full.png) /
  [C7 later X5](timing-c7-01/cmd_2_frame_000070_full.png).
- [C7 Left preparation](timing-c7-01/cmd_6_frame_000474_full.png) /
  [Left spell applied13](timing-c7-01/cmd_6_frame_000492_full.png).
- Both archives retain exact tested X5 Resource, complete events/state and
  engine/stdout/stderr logs. [Controlled suite](regressions-c7/fire_x5/report.json).
- [Activity census](ITERATION7_ACTIVITY.json):7 episodes/222 edges, conservative
 65.138s wall/65.133s physics alive/unpaused coverage; excludes Retry/setup,
  paused review, coding, tests, after-victory time and waiting. Cold F4 delays
  102/97/121ms are retained; other recorded edges at most13ms.

Next: synchronize only directly affected canonical current-candidate records,
review the actual diff, publish reviewed source/report/evidence, and continue
natural high-Heat practice. Do not transfer controlled-suite Heat into live-play
claims or silently strengthen this provisional disposition into human acceptance.
