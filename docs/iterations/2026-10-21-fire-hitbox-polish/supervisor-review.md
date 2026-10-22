# Fire hitbox and Pikeman AI supervision — October 21

Status: IMPLEMENTATION_REVIEW_COMPLETE / AWAITING_USER_VALIDATION.
User authorized the three-hour implementation/review loop,
Fire X1–X5 first, Pikeman AI diagnosis, and local Godot checks/overlay captures.

Starting source: main at 921fd1ae207c990070cd279587f5a05ee0fb239c; the initial
working tree was clean. Execution window: 17:45–20:45 Hong Kong (09:45–12:45 UTC).
Dum-E is the implementation writer; Combat independently reviews returned source
and visual/engine evidence. RAE deadcell is a bounded reference consultation.

Scope preserves source artwork, timings/active markers, damage/Impact/Poise,
body collision, other schools and current rules. No commit, push or publication.

## Baseline observations

- Current Fire artwork includes the October 21 X1/X4/X5 overnight_v04 binding.
- The earlier alignment fixture uses obsolete FIRE_POINTS. Registration trace
  distinguishes artwork feet anchor (224,400) from the source-pixel actor origin
  (224,348): the local floor offset (0,26) at Sprite scale .5 shifts that origin.
  The fixture's 348 transform is therefore consistent; its old blade points
  still do not establish alignment for these newer textures.
- Enemy approach uses actor-root horizontal distance and the saved 72-pixel
  attack-range threshold. A reachability or tree-transition cause is suspected,
  not established; reproduce before repair.
- Model/effort overrides were sent for Dum-E and RAE as gpt-6.1-sol/high.
  The task tool exposes no Fast-tier switch or active-self model control.

## Iterations

### Baseline review

- Independent offline source overlays are under `baseline/`, with original
  animation/texture copies and hashes in `baseline/saved-inputs/` and the JSON
  report. Yellow shapes expose saved collision coverage; they are not engine
  captures. All five moves have visibly detached geometry in some active poses.
- Supervisor corrected an initial 52-source-pixel vertical origin error before
  reviewing implementation: offline overlays were regenerated using actor-root
  origin (224,348), not artwork feet anchor (224,400). Only regenerated baseline
  images/report are retained. Dum-E was notified before its Fire measurements.
- Shared-combat baseline: 87 assertions printed PASSED, but the wrapper returned
  failure on its first import/run; no clean full-wrapper pass is claimed. A later
  warm headless editor import returned exit 0. Persistence tests mutate their
  isolated Resources, so that project was not reused as pristine gameplay data.
- A separate warm shared-combat rerun returned engine exit 0 and all 87 checks
  passed. The initial wrapper failure remains recorded rather than erased.
- Config/scenes/AI were restored in the isolated project from committed 921fd1ae
  before the independent passive-Gym probe. Three applied 10-damage strikes were
  observed from each facing (Player Health 100 to 70), followed by fourth windup.
  Saved range 72 was reached at root distances around 71. The reported only-walk
  symptom is not reproduced in that passive saved-source case; this does not
  prove the user's running scene or visible animation was correct.
- The discarded initial passive probe ran after persistence-test fixture edits
  and is not evidence for saved tuning. Only `pristine-baseline-ai-2.log` counts
  for the passive saved-source observation above.

- Independent execution of Dum-E's focused AI check in restored pristine data
  returned rendered engine exit 0 and 27 assertions passed. The test uses natural
  AI/animation/physics, side reversal, ordinary movement input, actual Retry and
  one explicitly identified direct-HealthEvent interruption fixture.
- Supervisor viewed `supervisor-ai/saved_gym_player_left_windup.png`,
  `saved_gym_player_left_active.png` and `saved_gym_player_left_return.png`:
  raised/thrust/return art changes visibly, and the active frame displays 10
  damage with Player Health 90. This supports the passive rendered case only.
- User clarified that the symptom occurred while attacking during approach.
  Dum-E received that evidence and is testing repeated Fire inputs plus recovery
  after pressure stops. No speculative range/armour/timing fix is authorized.

### AI phase review result

Supervisor read the retained 50-check pressure report with zero failures, the
input-driven probe source, and actual approach/hit-reaction/resumed-thrust
captures. The symptom is `PRESSURE_SUPPRESSION_REPRODUCED` under the existing
interruption/post-reaction-wait rules. `NO_PERSISTENT_DEADLOCK` was found in these
bounded cases; no AI, attack range, timing or collision edit was justified.
See `pikeman-ai/README.md` for Dum-E's full engine/source identity and fixture
limits. Supervisor authorized an X2-only geometry iteration after this review.

The supervisor's separate baseline Fire renderer captured 96 clean/overlay
images across all five moves and both facings in a frozen sought-frame fixture.
Its actual Sprite offset was (0,-124), Sprite scale .5 and actor scale 2,
independently confirming actor-origin image mapping (224,348). X2's fully
extended blade and the old backward query are visibly detached in both facings.
Raw baseline renderer evidence is retained in the isolated supervisor folder;
it is not ordinary-play or high-Heat validation.

No human feel acceptance is implied by agent inspection or engine tests.

### X2 bounded implementation review

Reviewed native resource SHA256
`95fe76edb92ce6113bfa1e58860d5363145560426e2b6a3d9e1f4d3ac66580ad`.
Only position/target key tracks changed; Sprite keys, active markers and radius3.5
remain unchanged. Four current-art blade measurements are retained in
`x2-blade-points.json`. The supervisor independently restored baseline data,
copied this candidate and the focused check, and ran Godot4.7.1 headless:
exit0, 1236 assertions passed. The test distinguishes sought-frame geometry,
ordinary-input in-range hits and valid wider-spacing whiffs at max Heat.

A separate rendered capture run returned exit0 and96 images. Supervisor viewed
the actual four right-facing active blade poses and the left full thrust:
collision coverage follows the visible blade, including the backward chamber.
No detached geometry was observed in these reviewed poses. Review result:
`IMPLEMENTATION_REVIEW_COMPLETE` for X2 only, pending human feel acceptance.
X1 is the next authorized implementation increment; no gameplay changes inferred.

### X1 bounded implementation review

Reviewed candidate SHA256
`07e3c2b616b98b6dee7a8476a58f6a6e9dbefd446e0480a436db5f05d3a50ced`.
All seven active source cells1–7 were independently inspected with measured
base/middle/tip annotations. The former sparse geometry missed intermediate
poses at0.45,0.53 and0.711878675. New keys follow those existing Sprite times;
radius, artwork and clocks are unchanged. The read-only invariant helper also
confirms no tracked product change outside Fire position/target key blocks.

Separate restored project with reviewed X1/X2 candidates: Godot4.7.1 headless
exit0,1741 generic geometry assertions passed. Actual renderer exit0,96 images;
all seven right-facing active shapes and four mirrored left poses were viewed.
No detached shape or mirroring error observed. Retained independent evidence:
`supervisor-x1/`. Result:`IMPLEMENTATION_REVIEW_COMPLETE` for X1 only, pending
human feel acceptance. X4 is the next authorized increment, then X5 and X3.

The user additionally authorized a narrow synchronization of the opening Fire
visual status paragraph in TECH_ARCHITECTURE.md when the pass finishes. Combat
owns that edit; Dum-E continues the scoped guide/status/evidence files.

### X4 bounded implementation review

Reviewed candidate SHA256
`bfc1ee308ac202b4717b472c1306c3d961a9a557359e31c11d08159fd3cecbad`.
Independently checked the three measured source cells. Four active key holds
reuse those cells; source-cell identity is now distinct from key index in the
generic fixture. In particular the final cell2 holds unchanged across0.85266525.
The old geometry incorrectly changed pose there. Native artwork/key times,
radius and other settings remain unchanged; invariant comparison passes.

Separate restored project with reviewed X1/X2 plus X4: headless Godot4.7.1
exit0,1281 checks passed. Actual renderer exit0,96 images. All four active holds
were viewed in both facings and the shape follows the visible blade. Independent
evidence:`supervisor-x4/`. Result:`IMPLEMENTATION_REVIEW_COMPLETE` for X4 only,
pending human feel acceptance. X5 is the next increment, followed by X3.

X4 evidence-identity correction: the first independent run invoked a differently
named copy of the generic helper, while its new fixture hash field named
`dev_portal_test.gd`. Its assertions ran, but that metadata field described the
older file at that alias. A fresh run using the actual expected filename returned
exit0 and the same1281 passing checks; `supervisor-x4/headless-final-report.json`
records the correct fixture SHA256
`c1d357abeb453eb0071bc7b238c82f5ffcf49b480c44e70985090fcfe97127d8`.
Use that final report for fixture identity. No product change was involved.

Separate existing-rule observation: Dum-E's X4 rendered ordinary-input report
shows all four seeded max-Heat cases spending one target contact with zero
Health change. The later ordinary-phase health-result log entries (physics
frames1614/1756/1896/2045) explicitly report Impact40 `INVINCIBLE`, not a geometry
miss. Supervisor checked those entries and the grouped ordinary records. This
is a retained gameplay/tuning consideration, not an authorized rule change or
a reason to enlarge the shape. Human experience of that interaction remains open.

### X5 bounded implementation review

Reviewed candidate SHA256
`83594bbbfeee85cd4f15c573050efd8a157f409dca8943501c40b6d39a73341e`.
Four independently measured active source cells1–4 cover the overhead poses and
forward thrust. Old geometry instead became a downward/backward cut. Added the
missing0.5 pose and kept the thrust through inclusive active_end0.8; later return
art/geometry remains inactive. Artwork, Sprite keys, radius and timings are unchanged.

Separate restored project with reviewed X1/X2/X4 plus X5: headless Godot4.7.1
exit0,1341 checks passed; helper ran at its expected filename so embedded fixture
identity matches the executed script. Actual renderer exit0,96 images. All four
active holds were viewed in both facings, with no observed blade detachment.
Independent evidence:`supervisor-x5/`. Invariant comparison passes. Result:
`IMPLEMENTATION_REVIEW_COMPLETE` for X5 only, pending human feel acceptance.
X3 is the last authorized increment; a combined final-tree rerun follows.

### X3 bounded implementation review

Reviewed candidate SHA256
`4d2ecedc98d4a881078d09a2d7179cc07f5b64620ecfd4bf477385a4bccfe1ad`.
Five measured active source cells0–4 cover the short opening, backswing, forward
downstroke, lower follow-through and short return. Added the missing0.711878675
geometry hold; active timing, source art and radius remain unchanged.

Separate restored project with all five candidates: Godot4.7.1 headless exit0,
1337 checks passed. Actual renderer exit0,96 images; all five X3 active holds
were viewed in both directions with no observed detachment. Independent evidence:
`supervisor-x3/`. Result:`IMPLEMENTATION_REVIEW_COMPLETE` for X3, pending human
feel acceptance. All five product resources are now frozen for the combined
regression; Dum-E finishes its X3 evidence and scoped guide/status updates.

### Combined final-tree regression

All five resource hashes above were tested together, not just in their earlier
partial states. The independent isolated project was restored after the shared
settings test before replaying geometry/AI cases. The exact used helper copies,
source invariants, logs and reports are retained in `supervisor-final/`.

| Final-tree run | Result |
| --- | --- |
| Fire X1 | 1741 checks, exit0 |
| Fire X2, retained X2-specific helper | 1236 checks, exit0 |
| Fire X3 | 1337 checks, exit0 |
| Fire X4 | 1281 checks, exit0 |
| Fire X5 | 1341 checks, exit0 |
| Shared combat/settings/reaction | 87 checks, exit0 |
| Passive/Retry/interruption AI baseline | 14 checks, exit0 |
| Rendered repeated-X/five-X AI pressure | 44 checks, exit0 |
| Native Gym without a test script, rendered300 process frames | exit0; three applied10-damage Enemy contacts |

No failures or reported engine errors/warnings were found in these retained
final logs. Generic helper SHA256 is
`6ff9a62c87df14b466caace8135c99af81d73513b16b4afaac2bc34e25ca2c9d`;
X2 uses its separately retained earlier helper. See `run-manifest.json` for
per-run identity and limits. This is bounded implementation review, not submission
clearance or a human playtest.

The final all-five native renderer produced96 plain/overlay captures. Across
the per-move and final review, all24 active holds were inspected in both
directions. The remaining X1/X2 mirrored poses were checked against the final
all-five copy. Source art and all data outside the two allowed key blocks remain
unchanged; no additional tracked or untracked runtime files were introduced.

Final pressure cases all kept Player Health100 during sustained attacks, then
resumed three natural attack/recovery/wait cycles after input stopped, ending
at70 Health. Supervisor also inspected final interruption/resumed-thrust images.
No persistent AI stall was found; pressure suppression remains, with no AI-rule
workaround. Earlier baseline-only interruption observations remain tied to their
original source identity, not silently promoted to every final-tree scenario.

The user-approved opening TDD paragraph is synchronized: its old art-only
no-validation statement is historical, and the X2 gap is no longer described as
unresolved. Human feel/transition acceptance remains open. No commit, push,
export or publication was performed.

### Final handoff review

Dum-E returned the frozen implementation handoff and stopped editing. Supervisor
read the complete IMPLEMENTATION-REPORT.md, the compact current status rollup,
all five authoring readbacks and the narrow TDD diff. They agree with the tested
resource hashes and keep human acceptance separate. Final source invariants and
whitespace checks pass; no unresolved local implementation finding remains in
this bounded scope. Existing invincibility/pressure-suppression observations are
retained as unchanged behaviour, not silently repaired or waived design issues.

Execution loop closed at 2026-10-21 11:38:28 UTC, within the authorized window.
The remaining step is the user's fresh Gym/controller/feel check. No submission
readiness, human validation, commit or publication is implied.

## Dead Cells consultation

RAE deadcell completed a read-only pass against installed Steam build 23762174.
StartSword data binds strike animation IDs, hitFrame values and explicit area
parameters. Beheaded bone tracks exist, but their collision connection is not
established. Lancer/Zombie data distinguishes manual triggers and area fields;
actual approach logic, continuous windows and hit-once bookkeeping remain
unverified. These are reference observations, not a Laema fix or copied tuning.

Recoverable reference sources are outside the project, under the user's
`Documents/Game References/Dead Cells/`: `source-identity.json`,
`tables/weapon/000---StartSword.json`, `tables/mob/Melee/017---Lancer.json`,
`tables/mob/Melee/000---Zombie.json`, and
`extracted-2026-10-21/atlas/beheaded_tracks.json`. No game assets were imported.
