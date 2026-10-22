# Fire X1 candidate — October 21

Status: bounded supervisor review passed; `AWAITING_USER_VALIDATION`.
Combat independently passed1741 headless checks at the hash below and inspected
all seven right-facing active poses plus left-facing samples in a separate
renderer run. No observed blade detachment or mirroring defect was reported.
Human feel remains open. Combat authorized the separate X4-only iteration.

## Exact change and independent measurements

Only config/attack_animations/fire_x1.tres position/target **key data** changed.
Current overnight_v04 artwork has seven active held poses, not the older four
blade anchors. Add matching geometry at0.45,0.53 and0.711878675 and replace all
active pose coordinates. A0.18574929 preparation key holds the first active
pose before active_start; the0.0 inactive key is retained. Sprite keys, atlas,
UID, length, all markers (active0.36–0.8333333, pacing split0.6), interpolation,
radius3.5, body/floor, AI, lunge, damage, Impact/Poise and reactions are unchanged.

The independent source inspection is in ../fire_x1-source-measurements/;
../fire_x1-blade-points.json stores the truth and source hash. Coordinates below
are source pixels within448×448 cells, with estimated2-pixel visual uncertainty.
The separately observed middle points are not reverse-generated from geometry.
Combat reviewed all seven annotated source poses before the candidate.

| Cell | Nominal active hold | Base | Middle | Tip |
| --- | --- | --- | --- | --- |
| 1 | [.36,.37149858) | (183,218) | (210,199) | (239,180) |
| 2 | [.37149858,.45) | (229,224) | (195,211) | (162,197) |
| 3 | [.45,.53) | (234,217) | (228,191) | (222,168) |
| 4 | [.53,.60950685) | (238,260) | (276,237) | (314,212) |
| 5 | [.60950685,.711878675) | (269,286) | (313,291.5) | (358,297) |
| 6 | [.711878675,.8142505) | (211,299) | (255,302.5) | (302,307) |
| 7 | [.8142505,.8333333] | (219,287) | (251,263) | (284,238) |

Use the same engine-verified source origin(224,348), actor scale2/Sprite0.5
and7-source-pixel center inset as the [X2 method](../x2-candidate/README.md).
Feet anchor(224,400) is not the geometry origin. Radius remains3.5 local.

## Saved evidence

Engine: Godot4.7.1 stable official a13da4feb, isolated portable project/profile,
hidden/offscreen window. Rendered evidence uses Compatibility/OpenGL3.3,
RTX4090 and Dummy audio. Base921fd1ae plus reviewed X2 and this X1 candidate.

| Run | Result | Files |
| --- | --- | --- |
| Pristine X1 negative fixture | Expected336/1265 failed assertions; exit1; no reported engine errors | baseline-negative-report.json / baseline-negative.log |
| Candidate headless | 1741 checks pass, exit0, no reported errors | headless-report.json / headless.log |
| Candidate rendered | 1592 checks pass, exit0, no reported errors | render-report.json / render.log |
| Non-geometry/source invariants | PASS; only X1/X2 position/target blocks differ from base, all five atlases unchanged | ../supervisor_invariants.py; ../fire_x1-source-measurements/static-checks.json |

112 manual-fixture samples cover all seven poses, both facings and Heat0/100:
start/middle/late interior and separate native boundary-tolerance samples.
784 real ShapeCast point probes cover blade base/middle/tip and outside points.
All336 old blade-point expectations fail; the candidate passes them. All56
comparable normal/max-Heat samples have identical geometry and Sprite region.
The real collector/resolver also preserves late contact after a miss,
once-per-target spending including invincible rejection/no orb, pre/post-active
exclusion and cancellation. Frozen/manual fixtures are labeled separately.

Eight ordinary input/physics cases attempt X1 in both directions at normal/max
Heat, from initial spacing and after actual movement approaches within95 root
pixels. Approached cases land one10-damage contact. The initial left-side wider
spacing legitimately whiffs in these runs; it was not hidden with more reach.
Live query samples are checked against the actually displayed blade. Assertion
totals differ between runs because live-frame observation counts differ.

captures/ contains40 original1280×720 engine PNGs:16 matched plain/overlay
fixture pairs and8 live-input frames. close-ups/ contains16 paired native2x
crops. All seven right poses and left poses1/5/7 were directly inspected here;
Combat's independent renderer review provides additional left coverage. These
are actual query overlays, with clean panels beside them, not expected-shape
redraws. Native ShapeCast debug is hidden to avoid its restored authoring pose.
tested-fixture.gd preserves the exact generic helper version used for this move;
future repeated-cell fixture changes must not rewrite this evidence. Its input
is ../fire_x1-blade-points.json copied as res://probe_points.json in isolation.

SHA256:

- Atlas:7bf37e3393201daeae2ad6fc58a0f87f16a79ea37b971983c765a40a4d2fef9d
- Pristine X1:916b22fb83f32a79a80bbdd40ce657b5fb38e1b4c6a87e3cf24731b1a069d90d
- Candidate X1:07e3c2b616b98b6dee7a8476a58f6a6e9dbefd446e0480a436db5f05d3a50ced
- Exact fixture/point hashes are also embedded in the final headless/render reports.

Residual limits: finite pixel measurements/point probes and this engine/hardware;
no human feel acceptance or whole-game clearance. Other Fire moves and final
post-pass regression remain separate. No art rewrite, build/export, commit,
push or live publication occurred.
