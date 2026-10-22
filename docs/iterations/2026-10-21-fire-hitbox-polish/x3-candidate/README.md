# Fire X3 candidate — October 21

Status: bounded supervisor review passed; `AWAITING_USER_VALIDATION`.
Combat independently passed1337 headless checks and inspected all five active
holds in both directions in a separate renderer. No observed blade detachment
or mirroring defect. Product/helper are frozen for the combined handoff.

Only config/attack_animations/fire_x3.tres position/target key data changed.
Five measured current source cells replace stale positions, with the missing
lower follow-through added at0.711878675. The0.0 inactive geometry now matches
the same cell0 visible at active_start. Sprite keys/art, UID/length, markers
(active0.36–0.8333333; split0.6), radius3.5, body/floor, AI and all settings remain
unchanged. The short opening cell0 and closing cell4 remain inside the authored
window; this pass does not redesign hit-capable frames.

## Independent physical blade truth

Measured from original alpha/color steel and3x pixel grids, with separately
observed middle points and2-source-pixel visual uncertainty. No points were
derived from old/edited geometry. Combat reviewed all five annotated cells.
See ../fire_x3-blade-points.json and ../fire_x3-source-measurements/.

| Cell | Active hold | Base | Middle | Tip |
| --- | --- | --- | --- | --- |
| 0 | [.36,.37149858) | (218,290) | (250,264) | (282,237) |
| 1 | [.37149858,.60950685) | (187,298) | (152,303) | (118,308) |
| 2 | [.60950685,.711878675) | (282,299) | (317,306.5) | (355,314.5) |
| 3 | [.711878675,.8142505) | (277,310) | (311,322.5) | (347,334) |
| 4 | [.8142505,.8333333] | (218,290) | (250,262.5) | (281,234) |

Engine source root(224,348), not feet(224,400); actor2/Sprite0.5 scale. The
unchanged3.5-local radius is7 world/source pixels. Inset centers7 pixels from
physical blade ends, using the same [X2 method](../x2-candidate/README.md).

## Evidence

Godot4.7.1 stable official a13da4feb, isolated portable project/profile; hidden
Compatibility/OpenGL3.3 renderer, RTX4090, Dummy audio. Base921fd1ae plus the
five reviewed geometry-resource candidates.

| Run | Result | Files |
| --- | --- | --- |
| Pristine X3 negative | Expected268/913 failures; exit1; no reported engine errors | baseline-negative-report.json / baseline-negative.log |
| Candidate headless | 1337 pass; exit0; no reported errors | headless-report.json / headless.log |
| Candidate rendered | 1369 pass; exit0; no reported errors | render-report.json / render.log |
| Non-geometry/whitespace invariants | PASS | ../fire_x3-source-measurements/static-checks.json; working diff |

The negative result comprises208 missing physical blade-point contacts and60
false contacts at points outside the measured blade. The candidate corrects
both:80 manual samples/560 actual ShapeCast probes across five poses, both
directions and Heat0/100. All40 comparable Heat pairs have equal geometry and
native Sprite region. Interior samples are separated from engine key-tolerance
samples; actual displayed cells select the independent physical truth.

Collector/resolver fixtures preserve active bounds, late contact after a miss,
spent targets including invincible rejection/no orb, and cancellation. Eight
ordinary live-input/physics cases reach X3 through actual X inputs, with saved
AI, both directions, baseline/max Heat and spacing/approach cases. These final
cases each record one APPLIED10-damage X3 contact. Test-seeded max Heat is a
precondition, not player-earned progression. Frozen fixtures are not ordinary
play and are explicitly labeled.

captures/ contains32 original1280×720 engine PNGs:12 matched fixture pairs plus
8 ordinary live-input frames. close-ups/ contains12 native2x paired crops.
All five normal held poses were directly inspected in both directions; max-Heat
return pairs are also retained. Clean panels show the blade beside the actual
committed-query overlay, not an expected-shape redraw. tested-fixture.gd and
candidate-native.tres preserve exact tested snapshots; helper/point hashes are
embedded in reports. No helper change followed the final freeze.

SHA256:

- Atlas:ba3a1f48162a199530e5ef3d7b3b4f4b16f48d8a8125947b4f4bf233b15ae8c1
- Pristine X3:04d9e7ed3d602ccef8760bf6feb739352423585380d6beffd6364ff10bad5371
- Candidate X3:4d2ecedc98d4a881078d09a2d7179cc07f5b64620ecfd4bf477385a4bccfe1ad
- Frozen helper:6ff9a62c87df14b466caace8135c99af81d73513b16b4afaac2bc34e25ca2c9d

Residual limits: finite pixels/probes, this engine/hardware and no human feel
acceptance. Existing timing/windows and reaction invincibility are retained,
including physical backswing/return coverage where the authored window permits
it. Combined final-tree evidence is supervisor-run in ../supervisor-final/,
not another run by this implementation task. No build/export, commit, push,
publication or source-art rewrite occurred.
