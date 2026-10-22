# Fire X5 candidate — October 21

Status: bounded supervisor review passed; `AWAITING_USER_VALIDATION`.
Combat independently passed1341 headless checks at the candidate hash below and
inspected all four active poses in both facings in a separate actual renderer.
No observed detachment/mirroring defect. X3-only is the final authorized move;
human feel and combined current-five regression remain separate.

Only config/attack_animations/fire_x5.tres position/target key data changed.
Four current active cells now replace stale backward/downward geometry. Add
the missing0.5 vertical pose and0.18 preparation hold matching the first active
cell. Preserve initial0.0 and post-active0.8142505 geometry values. All Sprite
keys/art, UID/length, active0.36–0.8, pacing split0.6, radius3.5 and other settings
are unchanged. Cells5/6 return after the hit window and are not made hittable.

## Independent physical blade truth

Direct original steel/alpha and3x coordinate-grid measurements, uncertainty2
source pixels; middle independently observed, not generated from geometry.
Combat also reviewed all four annotated source cells before candidate testing.
See ../fire_x5-blade-points.json and ../fire_x5-source-measurements/.

| Cell | Native active hold | Base | Middle | Tip |
| --- | --- | --- | --- | --- |
| 1 | [.36,.37149858) | (189,224) | (212,209.5) | (239,192) |
| 2 | [.37149858,.5) | (216,214) | (190,204) | (162,193) |
| 3 | [.5,.60950685) | (232,217) | (230,194) | (227,171) |
| 4 | [.60950685,.8] | (276,285) | (313,284.5) | (352,284) |

The same engine-verified source root(224,348), actor2/Sprite0.5 scale and
7-source-pixel center inset from the [X2 method](../x2-candidate/README.md)
are used. Feet anchor(224,400) is not substituted for the geometry origin.

## Evidence and process results

Godot4.7.1 stable official a13da4feb in an isolated portable project/profile.
Rendered runs: hidden/offscreen Compatibility/OpenGL3.3, RTX4090, Dummy audio.
Base921fd1ae plus reviewed X1/X2/X4 and this X5 resource.

| Run | Result | Files |
| --- | --- | --- |
| Pristine X5 negative | Expected192/737 failed checks, exit1, no reported engine errors | baseline-negative-report.json / baseline-negative.log |
| Final candidate headless | 1341 checks pass, exit0, no reported errors | headless-report.json / headless.log |
| Final candidate rendered | 1192 checks pass, exit0, no reported errors | render-report.json / render.log |
| Non-geometry/whitespace invariants | PASS | ../fire_x5-source-measurements/static-checks.json; working diff |

64 manual samples/448 real ShapeCast probes cover the four held poses in both
directions/Heat0/100: blade base/middle/tip and outside points. All192 old blade
expectations fail; candidate checks pass. All32 normal/max-Heat sample pairs
have identical geometry and Sprite region. Interior and near-key tolerance
samples are distinct and use the actual native region. Real collector/resolver
fixtures preserve active bounds, late contact after a miss, spent targets,
invincible rejection/no orb and cancellation.

Eight ordinary input/physics cases reach X5 through actual five-X input and
live saved AI, both directions and baseline/max Heat, spacing/approach cases.
Each records one APPLIED10-damage X5 contact in these final runs. Structured
ordinary_contact_result entries distinguish actual resolver outcome from a
geometric attempt; high-Heat invincibility on other moves remains unchanged.
Max Heat is seeded through the existing API as a test precondition. Manual
fixtures are not ordinary-play evidence and are labeled separately.

captures/ has28 original1280×720 native engine PNGs:10 matched fixture pairs and
8 ordinary input frames. close-ups/ has10 native2x paired crops. All four normal
pose pairs were directly inspected in both directions; max-Heat thrust pairs
are also retained. Clean panels show the physical blade beside the actual
committed-query overlay. tested-fixture.gd and candidate-native.tres preserve
the exact used helper/resource; helper/point hashes are embedded in reports.

One earlier isolated headless process passed its assertions but exited with a
native shutdown access violation(-1073741819). That is not a clean test result.
Its original log/report remain in the isolated work directory. The fixture was
changed only to queue scene deletion after lifecycle retirement, rather than
freeing it in a frame callback. The final headless and renderer runs above both
exit0; the game resource is unchanged between those runs and the earlier one.
No game-code or AI workaround was inferred from the shutdown failure.

SHA256:

- Atlas:ef9d5a5c78ba2eaaa3b7d6227f4498d5ae3b0f3bf80218a3de495c4d676a1d94
- Pristine X5:49c8567f43a7c650a29ec099d5a17b87b1f7e7c7f950da47e1e819bf80ec183e
- Candidate X5:83594bbbfeee85cd4f15c573050efd8a157f409dca8943501c40b6d39a73341e
- Exact final helper:6ff9a62c87df14b466caace8135c99af81d73513b16b4afaac2bc34e25ca2c9d

Residual limits: finite pixel/solver probes and this engine/hardware, not human
feel acceptance or game-wide clearance. Existing reaction invincibility is a
separate feel consideration, not changed here. No build/export, commit, push,
publication or source-art rewrite occurred.
