# Fire X1–X5 sword-angle prototype v03 — October 20

The user viewed Art's all-five v03 study and requested DUM-E integration:
“right lets have dume to put them in”. This supersedes the source package's
older study-only/no-import labels for this prototype installation. It does not
establish final weapon design, final artwork acceptance, or runtime validation.

Art task: `01a15800-6824-7d03-aee8-9e7ad7ef3885`.
Selected source packet: `x1-sword-angle-study-v03/angle-proofs/`; each runtime
`fire_xN.png` is an exact copy of `fire_xN/fire_xN-sheet.png`. Source
`INTEGRATION_HANDOFF.md`, `README.md`, `metadata.json`, `prompts.json`, `qa.json`,
contact sheets and GIFs retain the generation/review ancestry outside the depot.
The runtime manifest records copied-sheet hashes, selected source-frame hashes,
visual key phases and raw-pose selections. The plain steel blade/crossguard is
the requested diagnostic artwork; it has not been regenerated or ornamented.

Only five attack sheets are imported: X1/X2/X3/X4/X5 have 8/6/5/6/7 frames,
32 total. All cells are 448×448 at fixed foot anchor (224,400), with an intended
standing body of approximately180px. There is no independent per-frame trimming
or scale change. X3's reversed raw pose index2 is absent; its remaining
chamber-to-cut gap and generated hip/foot/anatomy variation remain review limits.

## Binding and preservation

The five existing native Fire Animations point to this subfolder and use the
source metadata's frame phases for their discrete Sprite:region_rect keys.
Existing native clocks, UIDs, markers, timing splits, active windows, all three
AttackCast curves, per-move durations, Heat scaling, lunge, collision, damage,
Impact and input remain unchanged. Current markers agree with Art's reference
metadata; references were checked rather than restored into current resources.

The folder is inside Player's existing `FIRE_ART_ROOT` prefix so the existing
presentation/body profile still recognizes committed Fire artwork without a
script edit. Shared registration, facing, feet-to-floor placement, shader/filter
selection and root/Sprite scales are preserved. No Idle/Walk/Hurt/Cast, other
school, Pikeman, audio, Gym, HUD, camera or AI file is changed by this swap.
The original v01 attack sheets remain in the parent folder for recovery.

Drawings and retained physical coverage are now intentionally separate. The
older v01 alignment pass followed different sword poses. In particular, v03 X2
extends forward later in its cut while its retained active hitbox follows the
earlier backward sweep; the added X1 transitions and revised X3/X4/X5 poses can
also differ from held geometry between existing keys. No silent retuning or
new alignment claim is made. Use the F4 overlay to compare both facings before
requesting any separately scoped physical correction.

## Evidence and remaining review

Static checks cover copied-sheet/source-frame identity, frame count/dimensions,
metadata phase mapping, region bounds, retained Animation IDs/markers/geometry,
unchanged gameplay/settings/other-art source and `git diff --check`. Source
contact sheets were visually inspected. Godot/editor/runtime/build/tests were
not run for this task. Existing import descriptors that appeared in the working
tree during the interruption are preserved, including their generated UIDs.

Prior engine captures/alignment assertions apply to the earlier v01 drawings,
not this 32-position swap. The separate MINI/FULL Fireball VFX plan is pending
approval and has not been implemented here. No commit/push/publication occurred.

User review: Fire X1–X5 at baseline and high Heat, both facings, chaining,
feet/hip stability, X3's transition gap, interruption/return to existing Hurt,
Idle/Walk/Cast, school switches and retry. Compare F4 geometry visually; report
physical mismatches without treating this image replacement as their repair.
