# Default Fire tutorial target — source-grounded reachability finding

Status: **OPEN, repair scope awaiting human choice.** Not caused by C7's X5
timing and not repaired by changing protected sword geometry. Dum-E investigated
read-only; Main independently inspected the exact source/transform/evaluator chain.

## What was actually observed

Retained C4 and current C7 normal-input tutorial practice repeatedly accepted all
five Fire X actions but only X3 hit the small stationary dummy at those positions.
Current C7 naturally reached100 Heat through48 normal practice Casts, and all5
X inputs at.43s cadence were accepted. This is NOT a five-hit objective pass.
The first Heat goal turned green; the sequence goal did not. A single-position
miss alone would not prove a global reachability problem.

## Source facts and inference

- `scenes/enemy/enemy.tscn` defines an unscaled/unshifted50x58 collision rectangle.
  TrainingArea places its root atY16: area-relative collider Y=[-13,45]. Its
  32x96 Sprite is not the collider.
- `scenes/player/player.tscn` scales Player root2x. The Fire body profile is
  30x90 local centeredY-19, so grounded feet reach worldY52, the floor top;
  grounded Player root is approximately0. No jump exists in this slice.
- `config/attack_animations/fire_x1.tres` limits contact to native.36..8333333.
  Across its active stepped circle/sweep poses, local radius3.5 and root2x give
  an overall vertical envelope approximately[-180.200919,-34.613020]. The lowest
  reach occurs at.711878675:
  `2 * (-24.1934898 + 3.3869797 + 3.5) = -34.6130202`.
- The dummy's top is-13, leaving at least21.613 pixels of vertical separation.
  `Might.collect_melee_contacts` assigns the sampled query position; it does not
  add the old scene AttackCastY11 or Sprite offset. AttackGeometry.facing_pose
  mirrorsX only. Horizontal spacing cannot close this vertical gap; Heat changes
  time, not the authored geometry.
- SequenceObjectiveEvaluator requires actual `result=hit`; Stage7's
  HeatGuardSequenceEvaluator specifically needs a position1 hit to begin.

**Source inference:** default grounded Fire X1 cannot hit this legacy dummy at
any ordinary horizontal spacing in either facing. Thus the default Fire-only
five-melee tutorial route has a reachability conflict. This is not proof that
other schools or the entire tutorial are impossible, nor that X1 cannot hit the
separate tall Pikeman (actual Gym encounters do hit him).

## Scope boundary

Do not enlarge an invisible hit area, distort the sword query, silently change
the objective to count misses, or substitute new target artwork/collision as an
accepted design. The user has been asked whether to authorize a separate
full-height training target with matching visible art and collision, or leave
that decision for17:30. Existing GDD intent remains unchanged. No repair is
implemented; current C7 remains a provisional Gym review candidate, not a claim
that its default Fire tutorial flow is clear.

Evidence: actual current100-Heat objective
[frame](c7-heat-practice-01/cmd_6_frame_001261_full.png), X5/charged-orb
[frame](c7-heat-practice-01/cmd_8_frame_001397_full.png), and complete session
[events](c7-heat-practice-01/events.jsonl). Native setup/idle and controlled tests
are not substituted for observed successful tutorial completion.
