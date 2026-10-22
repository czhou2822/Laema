# Iteration6 — more spear standoff, worse roll endpoint: rejected

## Target change

Test the existing Pikeman approach-stop distance, not a new retreat/backoff
policy. A farther stop might make his committed thrust read at spear range instead
of crowding Laema. Preserve body/query geometry, attack pattern, Health, damage,
Impact/Poise, native timing, Heat, defence and Dodge.

## What changed

Dum-E changed ONLY `config/characters/combat_enemy.tres`:
`enemy_ai.attack_range`72 ->96. The actor config reaches EnemyApproach through
the existing configure/blackboard sync. The tree's fallback72 is unchanged.
No new branch, movement direction, spacing trigger or retreat action was added.

- Before/resource restored: A9682BE02BB7761E2F9BEA1833A2D5FE58DEC940E9C9DD99FC29AA4D17257AAF.
- Candidate/resource archived: 2A078B2B14FE433F3CA580A470F7925010C2E28CA50963B4C1D6A2D1267973BE.

Main reviewed the complete Resource, exact one-leaf diff and live consumer.
Separate fresh rendered Windows Godot4.7.1 processes used the same isolated
profile/helper634 and requested normal-input schedules. Source copied only
after normal process closure, never hot-swapped into an encounter.

## Actual play and review

Both sessions started at authored Player100/Enemy200. No forced actor, Health,
resource, Heat, position, clock or AI writes. Ordinary Pause/Retry separated the
passive, roll-crossing and full-fight cases; there was NO Retry inside either
full fight. Unexpected-input counters stayed0. These are scheduled bound inputs,
not physical-controller usability or human feel acceptance.

| Observed case | Range72 | Range96 |
| --- | --- | --- |
| Passive windup root separation |71.50019|95.50018|
| Passive4s outcome |Two10-damage hits; Player80/Enemy200|Two10-damage hits; Player80/Enemy200|
| Same950ms Circle request after normal Retry |Player stayed100; normal120-unit roll then about0.57 extra units|Player stayed100; normal120-unit roll then about24.57 extra units|
| Five-X/empowered Lv5 opening |All5 melee contacts; Cast launched5334ms; Player100/Enemy137|All5 melee contacts; Cast launched5350ms; Player100/Enemy137|
| Full encounter after ordinary continuation |Player70/Enemy0|Player70/Enemy0|

The Retry macros did not provide identical wall-time simulation: the two actual
starting separations were148.00018 and145.00018. This3-unit difference is retained,
not called a perfect replay. Both Enemies nevertheless reached their respective
standoff before Circle. The roll's fixed120-unit commanded travel is separate
from the subsequent collision correction. Player root began-80; settled endpoints
were40.56651 and64.56925. Enemy stopped-8.49981 and15.50018 respectively.

Actual windup/thrust and pre-/post-Dodge frames were inspected. Range96 really
creates more initial room and its spear reaches a passive Player, but restoring
solidity nearer the Enemy at roll end pushes Laema visibly farther. It does not
make the Enemy back away when crowded. Both continuations contained a real
`no_marked_orbs` failure after incoming interruption; do not turn an intended
Cast request into a successful action claim. Both also launched a later genuine
empowered Lv7 Cast. Identical final HP is not statistical difficulty evidence.

## Judgment and disposition

**REJECTED / NOT_RETAINED.** More initial spear standoff is observable, but its
Dodge-end displacement regression worsens another equal-priority concern. Do not
compensate by changing hitboxes, Dodge distance, solidity policy or invulnerability.
Dum-E restored ONLY96 ->72 after both owned games closed. Main independently
verified the exact baseline hash/no product diff and refreshed the isolated
runtime to72 before the next trial. No new AI policy has been accepted.

Next hypothesis: the remaining late-combo gap may be X5's preparation/onset,
not just its already-tested late recovery. That is a separate one-leaf Fire
timing trial, not a reason to retain this range candidate.

## Recoverable evidence

- [72-range windup](c6-range72-baseline-01/cmd_2_frame_000026_full.png) /
  [96-range windup](c6-range96-candidate-01/cmd_2_frame_000020_full.png).
- [72 roll before end](c6-range72-baseline-01/cmd_4_frame_000096_full.png) /
  [72 after end](c6-range72-baseline-01/cmd_4_frame_000097_full.png).
- [96 roll before end](c6-range96-candidate-01/cmd_4_frame_000090_full.png) /
  [96 after end](c6-range96-candidate-01/cmd_4_frame_000091_full.png).
- Each directory contains its exact EnemySettings, state, complete events and
  engine/stdout/stderr logs, plus41 actual full viewport images. Both processes
  exited0 with inherited13ObjectDB/9resource shutdown warnings preserved.
- [Activity census](ITERATION6_ACTIVITY.json):8 commanded play episodes/164 bound
  edges, lower-bound54.183s alive/unpaused sample coverage. Native Retry, paused
  source/image review, implementation, archival and waiting are separate time.
  Cold F4 release was105/98ms late; non-overlay edges were at most8ms. Do not
  claim every input was within8ms or count these as8 completed encounters.
