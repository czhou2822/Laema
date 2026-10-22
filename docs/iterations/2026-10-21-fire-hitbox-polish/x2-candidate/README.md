# Fire X2 candidate — October 21

Status: bounded supervisor review passed; `AWAITING_USER_VALIDATION`.
Combat independently reran1236 headless checks at the candidate hash below and
reviewed all four active poses plus left thrust in actual captures. No observed
detached coverage was reported; this is not human feel acceptance. Combat then
authorized a separate X1-only iteration. Only X2 geometry belongs to this report.

## Result and exact scope

The old X2 position/target curves stayed behind the actor even when the current
angle_proofs_v03 artwork displayed a forward sword. The candidate follows the
actual steel: backward on active pose1, forward on poses2–4.

The only product change is config/attack_animations/fire_x2.tres,
tracks3/4 **key data** (AttackCast position and target_position). Geometry holds
at the existing Sprite poses. Add the missing0.6 forward-thrust pose and a0.2
preparation key matching the first active pose; queries remain disabled before
active_start. Keep the initial inactive0.0 key and duplicate the final pose at
active_end. No new track type, animation/config field or API was added.

Unchanged byte-for-byte outside those two key blocks: UID, length, texture path,
all Sprite keys, active_start0.36, timing_split0.46666667, active_end0.8333333,
radius track3.5 and interpolation/update modes. No other move, body/scene/camera,
AI, damage, Impact/Poise, lunge, reaction or timing setting changed.

Companion files: tools/tests/fire_x2_geometry_test.gd, x2_measure.py,
x2_capture_review.py, x2-blade-points.json, docs/ATTACK_STYLES.md and the scoped
entry in docs/IMPLEMENTATION_STATUS.md. Earlier Pikeman evidence is separate.

## Independent physical blade measurements

Measured directly from the unchanged atlas, before editing geometry, using its
3x nearest-neighbor grid, original alpha/color steel pixels and plain frames.
The middle points are separately observed, not values derived from the edited
capsules. Estimated visual uncertainty is2 source pixels. Frame indices below
are zero-based. Source inspection PNGs are in ../x2-source-measurements/;
machine-readable truth is ../x2-blade-points.json. Combat independently reviewed
these four annotated source poses without requesting a correction.

| Frame | Nominal active hold | Blade base | Observed middle | Tip |
| --- | --- | --- | --- | --- |
| 1 | [0.36,0.45624605) | (183,288) | (154,278.5) | (124,267) |
| 2 | [0.45624605,0.6) | (224,293.5) | (265,297) | (308,300) |
| 3 | [0.6,0.7485495) | (294,282.5) | (331,282.5) | (368,283) |
| 4 | [0.7485495,0.8333333] | (278,283.5) | (309,274.5) | (339,265.5) |

Engine-derived registration: Sprite rect(-224,-348,448,448), offset(0,-124),
actor scale2, Sprite scale0.5. Source feet(224,400) map to actor-local(0,26),
not its origin. Source-to-local is `(pixel - Vector2(224,348)) / 2`, mirrored
in localX for left facing. The unchanged radius3.5 is7 source/world pixels.
Inset each capsule center7 source pixels from the measured blade endpoints;
its endcaps terminate at the measured steel rather than adding reach.

## Checks and engine evidence

Base source: `921fd1ae207c990070cd279587f5a05ee0fb239c` plus this X2-only resource
candidate. Godot4.7.1 stable official `a13da4feb8d8aefc283c3763d33a2f170a18d541`.
Rendered runs use Compatibility/OpenGL3.3 on RTX4090, audio driver Dummy.
All runs use a separate project and portable profile; windows were hidden/offscreen.

| Run | Result | Retained evidence |
| --- | --- | --- |
| Pristine saved X2 with corrected fixture | Expected failure:192/736 assertions; exit1, no reported engine errors | baseline-negative-report.json / baseline-negative.log |
| Candidate headless | 1236 checks pass, exit0, no reported errors | headless-report.json / headless.log |
| Candidate rendered | 1093 checks pass, exit0, no reported errors | render-report.json / render.log |
| Scoped source/invariant comparison | PASS; only the two key blocks differ | ../x2-source-measurements/static-checks.json |
| Whitespace | git diff --check passes | Working diff |

The regression fixture samples all four poses in both directions at Heat0 and
Heat100: beginning, midpoint, unambiguous late interior, plus a distinct native
near-key tolerance sample. There are64 samples and448 real ShapeCast point
probes: base/middle/tip must hit; beyond-tip, behind-base and both side points
must miss. The pristine resource fails exactly all192 blade-point expectations.
The candidate passes them without changing radius. Actual Sprite region selects
the independent physical truth for near-key tolerance; no source retiming is
used to satisfy an ideal-time floor assumption. All32 normal/max-Heat sample
pairs have equal geometry and Sprite region.

Separate frozen-actor fixtures exercise the real Entity collector and resolver:
pre/post-window requests are empty; an initial miss allows later body contact;
each target is spent once; invincible-target rejection gives no damage/orb and
does not reopen contact; cancellation produces no contact. A0.5-world-pixel
point fixture uses a private collision layer. These are controlled fixtures,
not claims of natural play.

Eight ordinary input/physics cases use the actual saved Gym and live AI: X→X
in both facings at baseline/max Heat, from initial spacing and after movement
input approaches within95 root pixels. In-range cases land one10-damage X2
contact, never repeated. The widest left-facing max-Heat case legitimately
whiffs (recorded root gap exceeds its visible sword/body reach); moving closer
lands. Do not expand the blade, body or AI range to turn that spacing miss into
a hit. Live-frame sampled queries are checked against the displayed steel.
Assertion totals vary with the number of observed live physics frames.

## Visual review and limits

captures/ contains28 original1280x720 engine PNGs:10 matched fixture plain/overlay
pairs and8 ordinary live-input frames. close-ups/ contains10 paired2x crops
from those native PNGs, not redraws of an expected collision. All held-pose pairs
were visually inspected, including both facings and the max-Heat thrust. Native
ShapeCast debug is hidden in screenshots; the visible yellow shape is Player's
actual committed-query overlay. Plain panels keep the blade visible for judgment.

Earlier exploratory runs remain in the isolated work directory. They included
a false ideal-time near-key expectation, an unconditional-hit assumption at wide
spacing, a check of an unused interception field instead of the delivered result,
and one frozen-fixture shutdown access violation. The final helper retires the
room through its existing lifecycle before freeing it; final runs above have
clean exits. None required a product pipeline, timing or range workaround.

SHA256:

- Atlas:39b90fad4e91440d5c5567b3fa56b2b689f94306d4d2a80e36557f0569d83628
- Saved X2:d4aef7baa487998d2517dd7f63329b5b7cdf8306a4773df191d66e85440dfd58
- Candidate X2:95fe76edb92ce6113bfa1e58860d5363145560426e2b6a3d9e1f4d3ac66580ad
- Focused fixture:ebb196b9ad63c67b64539e383f633d1e452d8759aa5e044ad1ca634513c622ed
- Independent point JSON:66c75420748658524a518a9a00b4dbae7c2f688a0543fa86461f7d552284e822

Residual limits: finite source-pixel measurements, bounded solver probes and
this engine/hardware only. Human feel/readability approval and the other Fire
moves remain open. Retry/AI recovery evidence belongs to the separate AI phase.
No commit, push, export, live publication or source-art rewrite occurred.
