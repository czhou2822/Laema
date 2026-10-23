# Vampire remaster v01 handoff

Status: **worker complete; parent review and human motion acceptance pending**. Base identity remains the approved Vampire / CVAMP. No upgrade substitution or gameplay integration.

## Delivered

- **56/56 poses**, **15/15 original groups**, **90/90 original timeline positions**, zero missing poses/groups.
- **55 newly drawn selected poses**, plus byte-identical approved high-resolution master reuse solely for the visually matched exact original idle `vampire_p004`.
- **30 atlases**, **180 frame PNGs**, **30 GIF previews**, **15 original/candidate contacts**, and **two SpriteFrames libraries** with 15 animations / 90 positions each.
- Source order, holds/repeats and exact aliases **G7=G9 / G8=G10** retained as separate group files. Native Vampire has no one-frame groups; absent G6/G14–19 were not invented.
- Fixed 1024×768 cell geometry, four-column atlases, anchor (512,512), native reference (196,268), scale 180/73. Bat flight, smoke transformations, changing camera views, mantle drape, low attacks and death fragments remain source-driven.

Asset payload: `assets/prototype/enemy/vampire/remaster_v01/`. The entry point is its `source_manifest.json`; editor-preview libraries are `original_groups.tres` and `original_groups_mirrored.tres`. Parent owns portable package assembly and publication.

## Review and repairs

Inspected all original source poses and the approved master, every generated raw attempt enlarged, all 56 selected poses against OG in both facings at output scale, every source-ordered group contact, and first/middle/last decoded GIF frames for both orientations of all 15 groups. This was **static frame inspection**, not real-time animation playback.

Repaired overly broad/short standing silhouettes and recoil reach; restored the small idle-gesture progression; separately redrew the narrow melee-preparation profile with two separated hand heights; replaced the final death remnant with a low horizontal heap; corrected transformation bat views and removed invented miniature bats from smoke. Valid drawings were retained. Every group was rebuilt together after shared-pose repairs. See [REPAIR_LOG.md](REPAIR_LOG.md) for selections and superseded attempts.

All new art used the built-in image tool: **15 calls**, with exact prompts, actual reference paths/hashes, returned metadata, raw PNGs and selection history retained. No seeds/model identifiers were supplied by the tool, and none are invented. Original guides are references only, not deliverable upscales. No code-warped body art or idle fill was used.

## Verification and limits

`validate` passed before and after `spriteframes`: complete true, errors empty, all 90 atlas cells verified. Additional asset checks verified **180 frame PNGs**, all selected raw/isolated/registered/mirror hashes, current review hashes, unique pose outputs, exact alias atlas/GIF bytes, all 15 call provenance records, and both libraries' 15 animations / 90 frame subresources and existing texture paths. Native metadata, DEF and approved-master hashes still match the plan.

No unresolved blocking anatomy, clipping or order defect was observed after repairs. Fine joint geometry, surfaces and fragment shapes are drawn interpretations, not a pixel-identical reconstruction. Smoothness, flicker and original timing are not established by static contacts. GIF and SpriteFrames speed is **10 fps for review only**; original timing remains unknown. Browser, Godot, human playback and human animation acceptance were not performed or claimed.

Existing selected artwork can be rebuilt from the retained isolated sources with the shared Pillow packing helper. This does not promise offline generation of new artwork or reproducible cloud outputs. No dependency installation, Git operation, peer message, shared tool/plan/master edit, game/actor/AI/encounter/timing change or canonical-record edit was made.

Evidence: [visual-review.json](visual-review.json) contains per-pose/group observations, paths, hashes and sampling; [validation-results.json](validation-results.json) contains helper results; [gif-sampling-index.json](gif-sampling-index.json) identifies actual decoded samples. [audit_outputs.py](audit_outputs.py) verifies the handoff with Python `-B`. Initial preparation records are retained as history and superseded by this report.
