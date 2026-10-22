# Retained-source Fire encounter — defence, dodge and Casting

Agent-run review through14:01 HKT October22. This is **continued play on retained
C4**, not Iteration6: no product change was proposed or implemented. It adds
bounded incoming-attack evidence without converting it into human acceptance.

## Source and method

Published product source remains b57d1b3f;26fa5890 adds the fifth-round report and
evidence only. X5 is restored D1.10/57aef5ab, Player9b705e0d, widgete91201b5,
Defence935c2eed and helper63409fd5. Isolated rendered Godot4.7.1 process77216,
session77216_597317, normal Gym, no connected controller. Startup and actual
viewport were checked through the real Windows window; normal bound inputs
drive all actions. No actor/Health/Heat/resources/positions/AI/clocks were forced.
The Player's one-HP floor is disabled in the saved source.

One encounter ran from100/200 through the cases below to victory at **37.5/0**.
There was no mid-encounter Retry, healing or state repair. Ordinary Pause was
used between observation and the next attempt. Inputs are scheduled keyboard
events, not physical-controller usability or human reaction-time acceptance.

## Actual cases

| Case | Observed outcome | Evidence boundary |
| --- | --- | --- |
| Hold front Fire defence | First10-damage thrust resolved BLOCKED with2.5 chip; HP100->97.5, no combat reaction. Held Shield Catch and horizontal thrust are visible. | Actual Health is fractional; HUD rounds97.5 to98 and2.5 to3. No listening judgment. |
| Two late tap requests | Both followed real hits during0.55s suppression; they did not enter defence. HP eventually67.5. | Not successful parries or unexplained input failure. |
| Fresh tap from the same67.5HP | Actual PARRIED/0damage; Enemy Level1 reaction0.25s and about5 units of push; Enemy200/Heat0/orbs0. | One successful case. The exact spark frame was not isolated. |
| Dodge across an attack and reface | Two of three requested presses executed24 ticks each; the cooldown press and X during dodge were ignored. Enemy kept its committed left thrust, then faced right after recovery. | This crossing produced no eligible HealthEvent; unchanged HP alone is not invulnerability proof. No retreat policy added. |
| Dodge against a wall under real contact | Ordinary movement reached the wall. Enemy action8 physically contacted during dodge and resolved INVINCIBLE/0. After dodge ended, the same attack was still ACTIVE in a frame without a later HP loss. | One once-per-target/invulnerability case, not all possible contact times. Wall position stayed fixed. |
| Late Circle during X4 | All four X hit, generating and charging four orbs. Circle2550ms came after actual X4 contact2507ms and did not execute. | Main's intended pre-active timing was wrong; this instead exercises the correct active/recovery rejection. No hidden retry or bug claim. |
| Early Circle during X5 with Charging held | X5 accepted as position5, then Circle interrupted before contact. The chain reset; four real orbs remained, charged4->0 and progress->0. Holding full L2 still did not restart charging. | Before/after actual UI shows full pressure but spell level0, consistent with the required release/repress rearm. Physical endpoint correction remains separate. |
| Cancel a Cast before launch | Normal release/repress rearmed charging. One orb committed to FireLv1; Circle interrupted before launch, discarded that commitment and dodged. Queue4->3 only, no double spending, no projectile. Heat2 was retained. | Heat at commitment, including interruption, is the current GDD rule. Another incoming contact during this dodge resolved INVINCIBLE/0. |
| Circle after launch | Another real Lv1 committed/launched; queue3->2. Circle after launch did not execute; Cast continued. A later genuine hit interrupted it and reduced HP67.5->57.5. | No claim of uninterrupted completion: the later hit prevents that stronger test. No queued dodge was observed. |
| Return to offence, left facing | Normal movement/refacing and a five-X chain all hit. An empowered FireLv7 launched and applied13; Enemy160->97. A later actual hit left Player47.5. | Actual seven-orb result, not an assumed level from hold duration. Debug UI was genuinely hidden with Gym F4. |
| Finish the same encounter | Continued normal melee/Charging/Casting launched another empowered Lv5 and defeated the Enemy; Player37.5/queue4. | Six full10-damage hits plus2.5 chip explain the final Health. Unseeded outcome, not a comparative difficulty claim. |

## Rendered evidence

- [Held block and horizontal thrust](c4-defence-dodge-01/cmd_2_frame_000034_full.png)
- [Successful parry and Enemy recoil](c4-defence-dodge-01/cmd_3_frame_000151_full.png)
- [Committed left thrust while Laema crosses](c4-defence-dodge-01/cmd_4_frame_000166_full.png)
- [Enemy refaces after recovery](c4-defence-dodge-01/cmd_4_frame_000169_full.png)
- [Real invincible wall contact](c4-defence-dodge-01/cmd_6_frame_000292_full.png)
- [Same attack active after dodge](c4-defence-dodge-01/cmd_6_frame_000293_full.png)
- [Charged4 before interruption](c4-defence-dodge-01/cmd_8_frame_000363_full.png)
- [Full pressure still held, charged0 afterwards](c4-defence-dodge-01/cmd_8_frame_000371_full.png)
- [Normal Lv1 in flight after the ignored Circle](c4-defence-dodge-01/cmd_10_frame_000415_full.png)
- [Left-facing empowered Lv7 applied](c4-defence-dodge-01/cmd_11_frame_000525_full.png)
- [Same encounter victory](c4-defence-dodge-01/cmd_12_frame_000819_full.png)

Raw events, state, engine/stdout/stderr and full keyframes are in
c4-defence-dodge-01. Exactly one parried, two invincible, one blocked and six
ordinary damaging incoming Health results are logged. These are not ten parries
or successful dodges merely because ten contacts were examined.

## Judgment and remaining work

The observed rules compose coherently in this encounter: real block/parry,
post-attack facing, dodge cancellation and orb accounting lead back into melee
and a complete win without repairing the state. Main's late-X4 cancellation
assumption was corrected from the actual clock/outcome instead of treating an
ignored input as a defect. Keep the protected mechanics unchanged on this evidence.

This does **not** solve the five morning presentation concerns. The Enemy still
returns to pursuit rather than deliberately making space; the physical dodge
end correction is not fixed; Casts retain the low origin/primitive appearance;
timing trims did not establish a convincing X4->X5 presentation solution; audio
comfort still needs actual human listening. Fresh AI/safe-end/art choices remain
unaccepted, and all retained tuning awaits the user's controller playtest.

No new implementation round, automated-test pass, audition, whole-scenario
clearance or human acceptance is claimed. Process closed normally with exit0;
the retained13 ObjectDB/9 resource warnings remain. No other runtime error was
recorded in this Gym session. It did not exercise the separate tutorial
transition error.

POST_C5_PLAY_ACTIVITY.json separately records11 commanded episodes/156 bound
edges and conservative alive/unpaused sample coverage **43.858s wall /43.917s
physics**. Cold Gym F4 release in command11 was95ms late before resuming; it is
not hidden in a claim that every edge was within9ms. Commands after victory are
requests, not successful game actions. Paused/source/visual review, implementation
and waiting are separate categories without invented stopwatch durations.
