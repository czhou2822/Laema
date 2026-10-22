# Casting presentation — observed failures, ignored releases and flight visibility

Agent-run normal-input evidence, October22, session16272_625784. No product
change/new implementation round. The frozen tested runtime is retained C4,
including Enemy attack_range72; the separate root C6 range96 candidate was not
hot-swapped into this encounter. It is not human-controller or audio acceptance.

## The four release cases are not the same

| Case actually exercised | Result | What was visible with debug hidden |
| --- | --- | --- |
| Empty queue, short full-pressure hold then release | `no_marked_orbs`; full failed Cast, self-flinch and progress reset. Player100/Enemy200. | Brief pose change and Spell Level0; no displayed reason. |
| Five real generated orbs, one genuinely charged, X then release before its buffer | `before_cast_window` at native progress0.095; full failure, no projectile, charged1->0 but queue5 retained. Player100/Enemy150. | Same basic self-flinch/reset presentation, no displayed reason distinguishing it from the empty case. |
| X buffered first, then release in that same pre-window period | X buffered900ms, release920ms, X promoted958ms. Cast release ignored before an attempt was created; charged1/partial retained, X continued. | No Cast and no failure flinch; charged ring remained. No explanatory reason label. |
| X already pending in the open window, then release | Attempt3 resolved `failed / pending_action_occupied`, but **not** the full failure penalty: no `cast_failed`, charge reset, consumption or self-flinch. Pending X3 continued. | Charged1 remained and melee continued; no displayed reason. |

The last row is rejected-request bookkeeping, not evidence that a full failed
Cast penalty occurred. Main read `SequenceObjectiveEvaluator._consume_cast_attempt`:
it ignores unmatched attempt IDs. Do not assert that this terminal alone breaks
a tutorial objective or requires a priority redesign. No such bug/fix is accepted.

Source and observed pictures agree that the two full failures do not explain
their different causes in visible reason text. The ignored/rejected requests
are mechanically different again. This supports the user's informational-feedback
concern, not a conclusion that every non-launch is an unreliable input bug.

Evidence: [empty failure](c4-cast-feedback-01/cmd_2_frame_000016_full.png),
[genuinely charged early failure](c4-cast-feedback-01/cmd_4_frame_000121_full.png),
[buffered-X release](c4-cast-feedback-01/cmd_5_frame_000136_full.png),
[melee continues with charge retained](c4-cast-feedback-01/cmd_5_frame_000137_full.png),
[pending-X request](c4-cast-feedback-01/cmd_6_frame_000148_full.png).

## Existing source paths, not a selected new treatment

- `Might._fail_cast` resets Magic coverage and emits argument-free `cast_failed`;
  Combat forwards it to `Player._on_cast_failed` for the existing DISPELL sound.
  HitReaction separately drives the vulnerable self-flinch. The reason-bearing
  `cast_attempt_resolved` CombatOutcome goes through Arena/StageDirector/evaluator,
  not a direct failure-reason HUD consumer.
- `HUD.update_orb_queue` updates generated/charged rings, progress and spell
  level. No failure-reason label exists there to be overwritten. Hiding
  DeveloperReadout leaves GameUI visible; its EventPanel is combo history,
  not an explanatory error field.
- Successful impact follows SpellProjectile -> Arena -> Combat -> Magic ->
  target Health resolver/Feedback. `FeedbackComponent.show_damage` and
  `show_cast_level` attach Labels to the target Entity, not the projectile.
  They already survive projectile disposal; the shared saved duration is2s.
  Increasing it also prolongs other direct/DoT feedback and can increase overlap.
- There is no existing generic impact-burst size/intensity/linger leaf. Dormant
  school-effect hooks and empty projectile audio paths are not permission to
  invent a new impact treatment or change the accepted sound identities.

Main read the actual complete Feedback component, Might arbitration/failure
branches, Player audio handler, HUD consumers and evaluator ID guard after U and
Dum-E's bounded read-only discoveries. No new HUD/art/architecture was selected.

## Flight duration and size are separate observations

Normal movement and genuinely earned orbs produced these successful casts:

| Trial | Actual Cast | Flight distance | Observation |
| --- | --- | --- | --- |
| Cmd7, retreat then stand to charge | FireLv3, applied10 | 32 units, launch1885ms/impact1959ms | Full-keyframe cadence straddled its short flight. This is not proof it never rendered. |
| Cmd8, charge while retreating | FireLv1, applied10 | 181.333 units | Actual1.653s frame contains the36x27 drawing in flight. |
| Cmd9, ordinary approach/dodge/run/charge and left refacing | FireLv3, applied10 | 277.333 units | Actual3.138s frame contains the72x54 drawing in flight. |

The latter two use different ranges/facings and are **not matched human-readability
A/B**. They do show the current size difference at1280x720. Ordinary pursuit and
stopping to charge can leave only a short projectile interval; bigger drawing
alone does not extend that interval. Actual movement while charging increased
the separation in the observed cases, without changing AI or flight rules.

[Lv1 in flight](c4-cast-feedback-01/cmd_8_frame_000217_full.png) /
[Lv3 in flight](c4-cast-feedback-01/cmd_9_frame_000270_full.png).
No audition or satisfying-impact/human-perception pass is inferred from stills.

Normal damage remained10. The current protected PlayerSettings has Cast
level_impacts1..4=10/20/30/40 with base Impact1 fallback for unspecified5..8.
The sampled Lv1/Lv3 therefore produced different configured reactions; do not
claim all levels share one reaction or that every higher level scales linearly.
This existing data was not retuned under today's fixed Impact/Poise guard.

## Complete encounter and disposition

The same Player carried all cases forward, returned to left-facing melee plus
an empowered Lv5/APPLIED13, and won at **90HP/Enemy0**, without Retry/healing or
actor/resource/position/AI/clock writes. The two full failures were intentional
normal-input probes, not malformed/half-pressure operator mistakes. One real
incoming10-damage hit accounts for the final90HP. Stored orbs were genuinely
generated; an authored FIFO expiry also occurred. Known native/menu/source work
is not counted as active play.

**No change selected:** keep current mechanics and do not increase shared text
duration merely because a numerical control exists. Missing reason explanation,
short-flight impact registration and low origin remain presentation work to
resolve under the user's authority. No new AI/art policy, sound replacement,
buffer/window change or impact effect was accepted. C6 existing approach-range
tuning is a separate experiment, not part of these tested sources.

Normal quit12 exited0, with the existing13 ObjectDB/9 resource shutdown warnings.
Actual full keyframes, inputs, states, logs and tested EnemySettings72 are in
c4-cast-feedback-01. No automated suite or new human acceptance is claimed.
