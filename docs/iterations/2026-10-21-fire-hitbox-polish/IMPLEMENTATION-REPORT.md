# Frozen Fire geometry / Pikeman diagnosis handoff — October 21

Status: `AWAITING_USER_VALIDATION`. Bounded implementation and independent
combined review passed; this is not human feel acceptance or submission clearance.
Base HEAD:921fd1ae207c990070cd279587f5a05ee0fb239c. No commit/push/export/publication.

## Outcome and limits of the change

All five Fire moves now follow independently measured current physical sword
poses. Only native AttackCast position/target key data changed. Artwork, Sprite
keys, UIDs, animation length/active/pacing markers, radius3.5, actor body/floor,
AI, damage, Impact/Poise, reaction/wait rules, lunge, other schools and Cast
remain unchanged. Native registration is source origin(224,348), not feet(224,400).

The reported only-walking symptom under repeated attacks is reproduced as
interruption/reaction/post-reaction-wait suppression. Passive approach attacks
normally, and every final pressure case resumes three attack cycles once input
pressure stops. No persistent AI deadlock was found; no armour, reach/range,
collision or timing workaround was made. Existing reaction invincibility can
still reject a fast follow-up and spend its contact for0damage.

## Exact frozen product files and SHA256

| File | SHA256 |
| --- | --- |
| config/attack_animations/fire_x1.tres | 07e3c2b616b98b6dee7a8476a58f6a6e9dbefd446e0480a436db5f05d3a50ced |
| config/attack_animations/fire_x2.tres | 95fe76edb92ce6113bfa1e58860d5363145560426e2b6a3d9e1f4d3ac66580ad |
| config/attack_animations/fire_x3.tres | 4d2ecedc98d4a881078d09a2d7179cc07f5b64620ecfd4bf477385a4bccfe1ad |
| config/attack_animations/fire_x4.tres | bfc1ee308ac202b4717b472c1306c3d961a9a557359e31c11d08159fd3cecbad |
| config/attack_animations/fire_x5.tres | 83594bbbfeee85cd4f15c573050efd8a157f409dca8943501c40b6d39a73341e |

Each change is confined to tracks3/4 key blocks. Radius track and all other
Animation content are preserved. Source invariants report no other product-file
changes and all five atlases unchanged. No product/helper edit follows the freeze.

## Implementer-run evidence

Godot4.7.1 stable official a13da4feb8d8aefc283c3763d33a2f170a18d541,
private project/portable profile. Rendered checks use hidden/offscreen
Compatibility/OpenGL3.3, RTX4090 and Dummy audio, not the user's editor session.

| Move / measurements and detailed logs | Pristine negative fixture | Final headless | Final rendered |
| --- | --- | ---: | ---: |
| [X1](x1-candidate/README.md) | 336/1265 failed as expected | 1741 pass | 1592 pass |
| [X2](x2-candidate/README.md) | 192/736 failed as expected | 1236 pass | 1093 pass |
| [X3](x3-candidate/README.md) | 268/913 failed as expected | 1337 pass | 1369 pass |
| [X4](x4-candidate/README.md) | 192/737 failed as expected | 1281 pass | 1136 pass |
| [X5](x5-candidate/README.md) | 192/737 failed as expected | 1341 pass | 1192 pass |

Negative fixtures exit1 for expected assertions; listed final positive runs exit0
with no reported errors. Test totals vary with observed live physics-frame count.
An earlier X5 assertion-passing process had a native shutdown access violation;
it is explicitly not counted as clean. The test-only queued-deletion reruns
exit0; resource hashes did not change to work around that failure. Earlier failed
development probes remain retained and are superseded, not erased.

Coverage:24 active holds/23 unique cells,2688 actual ShapeCast point probes,
192 equal normal/max-Heat sample pairs, both facings, clear interiors and separate
native key-tolerance samples. Independent pixel truth is never generated from
edited collision data. Real collector/resolver fixtures preserve active bounds,
late contact, once-per-target spending including rejection/no orb, and cancellation.
40 ordinary input/physics cases are distinct from frozen/manual fixtures.
Per-move folders retain160 original viewport PNGs and60 plain/overlay paired crops.
All normal active poses were inspected in both facings except X1's additional
left coverage is explicitly divided between implementer and supervisor records.

## Supervisor-run combined final-tree evidence

These are Combat's separate restored-project runs, not additional implementer
runs. The manifest, source invariants and relevant logs were read for this handoff:
[run-manifest.json](supervisor-final/run-manifest.json),
[source-invariants.json](supervisor-final/source-invariants.json).

- Current-five matrix: X1=1741, X2-specific=1236, X3=1337, X4=1281, X5=1341;
  all same hashes as above, zero failures, exit0/no reported engine errors.
- Shared-combat87 checks pass/exit0: [log](supervisor-final/shared-combat.log).
- Final AI baseline14 and rendered ordinary pressure44 pass/exit0:
  [baseline report](supervisor-final/ai-baseline-report.json),
  [pressure report](supervisor-final/ai-pressure-report.json).
- Native Gym rendered300 process frames with no testscript, exit0, three applied
  Enemy contacts at10damage: [log](supervisor-final/gym-smoke.log).
- Independent renderer review covers all24 active holds in both facings;
  sought-frame evidence is not ordinary play or human feel acceptance.

The initial implementer AI diagnosis, single-X1/natural-windup interruption,
Retry and pressure evidence remain in [Pikeman AI](pikeman-ai/README.md).
No AI source change was made. The final repeat establishes the same no-persistent-
deadlock boundary with the current five geometry resources, not only the old tree.

## Supporting files / document synchronization

Implementer-authored files beyond the five product resources:

- docs/ATTACK_STYLES.md and docs/IMPLEMENTATION_STATUS.md: current readbacks,
  exact bounded evidence and human-validation boundary; earlier unrelated status
  entries and detailed per-move evidence preserved.
- tools/tests/fire_x2_geometry_test.gd, fire_geometry_test.gd,
  pikeman_approach_test.gd: focused fixtures, not runtime game systems.
- This iteration folder's x2_measure.py, fire_measure.py,
  x2_capture_review.py; x2-blade-points.json and fire_x1/3/4/5-blade-points.json;
  source inspection, five candidate folders and Pikeman reports/captures.
- Generic frozen helper SHA256:
  6ff9a62c87df14b466caace8135c99af81d73513b16b4afaac2bc34e25ca2c9d.
  X2-specific frozen helper:
  ebb196b9ad63c67b64539e383f633d1e452d8759aa5e044ad1ca634513c622ed.

Combat owns the supervisor journal/helpers/evidence and made the user-approved
narrow docs/TECH_ARCHITECTURE.md opening Fire-paragraph sync; it was read and
preserved, not edited concurrently here. The GDD/gameplay rules did not change.
No blanket claim of full TDD/implementation audit or submission clearance is made.

The older art_hitbox_alignment_test.gd FIRE_POINTS/backward-only X2 assertions
are obsolete physical truth for current textures. Do not use them in place of
the independently measured manifests/fixtures above; that older test was not
silently rewritten or presented as passing this pass.

## Remaining human validation / risk

1. Start a fresh current Gym attempt, show F4 hitboxes, approach the opponent
   and perform Fire X1–X5. Inspect the visible blade/query in each pose and keep
   feet grounded. Repeat facing left and right; do not change attack tuning.
2. Repeat at high Heat with successful and failed contacts. Distinguish a real
   spacing miss or INVINCIBLE rejection from a queued-input failure. Geometry
   should still follow the blade; one target must not be hit repeatedly per action.
3. Apply repeated X pressure while the Pikeman approaches, then stop. Expect
   reaction/wait suppression while interrupted, then resumed windup/thrust/wait.
   Retry and repeat to confirm fresh actors/health/resources in the user's session.

Residual limits:2-pixel measurement uncertainty, bounded solver points, this
engine/hardware and no exhaustive gameplay coverage. Existing active windows
include brief preparation/return poses and existing invincibility may suppress
fast follow-up damage; neither rule was redesigned. Human feel/transition
acceptance, broader content and submission readiness remain open.
