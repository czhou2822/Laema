# Final C7 targeted replay — earlier X5 Dodge, rearm and empowered Lv8

No new product candidate. Fresh rendered session41128_645991 tests the existing
pre-active Dodge contract with C7's faster X5 preparation, rather than importing
the older C4 timing result. Frozen X5651D/Enemy72/helper634, no second owned game.

## Actual play and review

- First4 X attacks hit; X5 began3.541s. Normal Circle at3.661,120ms after that
  actual start and before its active marker, cancelled X5 and began Dodge.
  Dodge ended4.056 after24 physics ticks. Player100/Enemy160, queue4 retained,
  charged4->0, chain reset. Still-held full Charging did not restart by pause.
  Actual pre-/during-/post-roll frames were inspected; no forced actor/resources.
- Neutral Casting release rearmed normally; a fresh full press started Charging.
  A normal Left turn/five-X sequence hit all5 and committed empowered FireLv8.
  It launched4.915s, impacted4.966 and applied13. The actual target FireLv8/13
  frame was inspected. Later genuine damage left Player90/Enemy97/Heat11/queue1.
- After an ordinary recovery wait, the SAME encounter continued to Player50/
  Enemy0/Heat1/queue6. No Retry/healing or Health/Heat/orb/position/AI/clock/evaluator
  writes; unexpected-input counter0 throughout. Right setup had debug hidden;
  Left return had it visible. This is one continuous fight, not3 encounters.

The rearm release was requested100ms into cmd3 but actually dispatched184ms
(84ms late), still before unpause200ms. Cold F4 release delays were108/104ms.
These timing limits are retained, not called uniformly7ms input or a precise
100ms human reaction. No new priority, cancellation or pressure rule was added.

## Judgment and remaining limits

The tested earlier Circle still cancels C7 X5 before active, preserves generated
orbs, clears charged status, requires rearm, and permits a later real empowered
Cast/offensive return. This is finite normal-input coverage at this timing/Heat,
not all possible cancellation windows, physical-controller feel or a repaired
physical overlap endpoint. Faster preparation leaves less real pre-active time;
the normalized gameplay rule is unchanged.

Normalquit5 explicitly exited0. **This last session reported25 ObjectDB instances
and15 resources still in use at shutdown**, unlike the13/9 in the earlier rendered
sessions. Preserve the full stderr; no cause or new leak fix is established, and
no warning-free teardown is claimed. Do not silently call the counts identical.
No supplementary test/audition or fresh C7 parry acceptance was added here.

Evidence: [before Dodge, charged4](c7-x5-dodge-01/cmd_2_frame_000065_full.png),
[during Dodge, uncharged queue retained](c7-x5-dodge-01/cmd_2_frame_000066_full.png),
[after Dodge](c7-x5-dodge-01/cmd_2_frame_000068_full.png),
[empowered Lv8/13](c7-x5-dodge-01/cmd_3_frame_000158_full.png),
[same-fight victory](c7-x5-dodge-01/cmd_4_frame_000455_full.png).
The37-file/~43MB archive retains30 full viewport images, complete events/state,
engine/stdout/stderr and exact tested X5 Resource.

[Activity census](C7_X5_DODGE_ACTIVITY.json):3 episodes/94 bound edges,
conservative24.492s wall/24.517s physics alive/unpaused sample coverage. Paused
analysis, startup, after-victory time, sparse gaps and waiting are excluded.
C7 remains provisional for the user's controller review.
