# Vampire Lord remaster v01

Status: **complete asset candidate; parent/browser/Godot/human motion acceptance pending**.

Full dedicated coverage is supplied: **62/62 newly drawn registered poses, 18/18 original groups, 111/111 original timeline positions, zero missing poses**. All 62 selected poses carry hash-bound helper worker-review notes. No blocking anatomy, clipping, figure-count or source-order defect remained in the actual static review. Appearance approval is not animation acceptance.

## Deliverables

Root: `assets/prototype/enemy/vampire_lord/remaster_v01/`.

- `source_manifest.json`: source identity, every original occurrence/order/repeat/alias, geometry, selected provenance and coverage.
- 36 group atlas PNGs: every original group plus its exact per-frame horizontal mirror. Aliases 7=9, 8=10 and 17=18=19 keep separate exports.
- 124 registered pose PNGs: 62 selected drawings and 62 exact mirrors, in fixed 1024x768 cells.
- 222 frame PNGs: 111 source-facing positions and 111 mirror-facing positions.
- 36 review GIFs and 18 original-above-candidate contacts. GIF preview speed is 10fps only; original timing remains unknown. Repeated GIF frames may coalesce into longer holds; atlas/frame positions retain every source repeat.
- `original_groups.tres` and `original_groups_mirrored.tres`: 18 source-named animations / 111 positions per library. Preview resources only; no actor/state/gameplay assignment.
- `_source/`: original guide maps, exact prompts, returned built-in-tool metadata, all raw attempts, isolated figures, previous selection history and review presentations.

## Artwork and repairs

All new art used the built-in image tool: **14 actual calls, 91 requested pose variants, 62 selected newly drawn poses, zero approved-master sprite reuse**. The approved 732x1448 master was used only as appearance reference. Neither OG pixel enlargements nor warped masters fill any delivery pose.

Preserved the observed CNOSFE identity: bald pale wrinkled head, pointed ears/red eyes/fangs, long bare claws, dark ragged robe with orange-gold trim and red lining. Preserved bat flight/wing states, frontal turn, high/front/low attacks, defensive face protection, disintegrating death remnants, source-embedded special particles and smoke-obscured humanoid/bat transformations. No held weapon, armor, standalone projectile or new gameplay was introduced.

Twenty-five distinct source poses were repaired. Narrow idle/gesture and recovery robes were redrawn after broad first variants packed noticeably too short. p057 was redrawn individually because the first sheet incorrectly exposed an intact winged humanoid; the selected version hides the head/hands in the native transformation cloud. p051 received an additional single-pose particle repair after a broad oval glow diverged from the source.

The eight-figure `repair-special-b` page failed unchanged strict component isolation with `ValueError: Missing figure or ambiguous primary component`. The complete failed page/prompt/submission remain. Five visibly separate complete cells were recovered using conservative clear-margin rectangular crops and ordinary 1x1 helper ingestion; the three unsafe cells were redrawn. Exact original/derived hashes and crop coordinates are in `repair-history.json`. No count/clipping check was weakened. There are 19 retained submissions including five derived crops.

## Review and validation evidence

Viewed all initial and repair raw images and original guides enlarged. Viewed all 62 selected poses beside their original fixed projection and exact mirror at native registered pixel scale. Viewed every exported group contact and **all decoded frames of all 36 GIFs**, in source order and both facings, using the mechanical `group-review-*` collages. Checked entry/exit states, central repeated holds, turn aliases, source action heights, arms/fingers, hidden feet, wing membranes, robe continuity, embedded fragments/effects, alpha and framing. All dependent groups were rebuilt after repairs.

`visual-review.json` records an observation and selected source/mirror hashes for each pose, plus order, contact/GIF paths, alias information and actual review scope for every group. The final rebuild left every reviewed pose byte hash unchanged.

Ran the existing helper functions in the required order: review selected poses, build, validate, SpriteFrames export, final validate. **Both validations passed: complete=true, errors=[], 111 frame cells checked; reviewed_poses=62.** The helper verifies per-cell source order, exact frame mirrors, hashes, transparent padding and total GIF review durations. Exact results/counts are in `validation.json`.

Final source manifest SHA-256: `600c74f85493de9964add5215214aa4864c1fba81f7f2bc9bad8349ddbccb056`.

Source hashes remain the verified preparation values: CNOSFE DEF `7f3fe9079b255ad09ded551a82017580087905f0e6f4484aad90b357b84a0cfa`; native metadata `4ac5906db377f31902170fdd68224eaf2c92d379b4f7b74317023dacc9f6bd8d`; approved master `ce85d841852af7fedf5ebdad8b0451bc7f85dcd7c8494f1de35e0a7e85713d64`. Actual guide reference hashes and tool-return output hints are retained in each `.tool.json`. No model name or seed was supplied by the built-in tool; none was invented.

## Handoff limits

This is worker visual/static asset acceptance only. No browser playback, Godot import/run, human animation acceptance, original-timing proof, actor integration or publication was performed. Decoded GIF-frame inspection is not real-time playback. Painted detail, cloth folds and fine effect interpretation differ from original indexed pixels; independent parent/human review remains meaningful.

Existing isolated artwork repacks locally with the shared helper and Pillow; the final rebuild/validation used that local path. SciPy was used only through the already approved installed overlay for component ingestion. No dependency was installed. This does not promise an offline generative model, missing seed or deterministic cloud-art regeneration. Parent owns the combined offline package/publication and independent checks.

Writes stayed within the two dedicated Vampire Lord directories. Shared tools/plan, native originals, published master, game files and Git were not edited; no peer messages were sent.
