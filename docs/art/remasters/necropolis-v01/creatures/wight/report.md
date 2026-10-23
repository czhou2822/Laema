# Wight full-production candidate

Status: **COMPLETE WORKER CANDIDATE — parent and human motion review pending.**

All **57/57 unique poses**, **18/18 original groups** and **102/102 source positions** are supplied. Both facings provide **204 frame PNGs**. Final helper validation returned `complete: true`, zero missing poses and zero errors. All 57 current pose reviews remain bound to their actual output hashes.

## Deliverables

Asset folder: `assets/prototype/enemy/wight/remaster_v01/`.

| Output | Count |
| --- | ---: |
| Newly drawn final source poses | 57 |
| Approved master/idle reuse | 0 |
| Registered pose PNGs, including exact mirrors | 114 |
| Four-column group atlases, including mirrors | 36 |
| Ordered frame PNGs, including mirrors | 204 |
| GIF previews, including mirrors | 36 |
| Original/candidate group contacts | 18 |
| Preview SpriteFrames libraries | 2, each 18 animations / 102 positions |
| Actual built-in imagegen calls | 14 |
| Generated pages supplying current poses | 12 |
| Missing poses / groups | 0 / 0 |

The asset root contains `source_manifest.json`, `original_groups.tres` and `original_groups_mirrored.tres`. The libraries use the helper's **10 fps review timing only**. Original timing is unknown. Source order, explicit repeats, original block IDs and exact alias pairs **7↔9, 8↔10, 11↔14, 12↔15, 13↔16, 20↔21** are preserved. Hurt/death share exactly their original p017/p018 drawings. G14–16 labels add no ranged gameplay.

Geometry stays at 1024×768 cells, four atlas columns, target anchor (512,512), native reference (196,268), scale 180/73 and alpha>160 source body bounds. The helper uses uniform aspect-fit into those bounds; no stretching, per-action registration override, code-warped master or original-pixel deliverable was used.

## Provenance and repairs

Exact prompts, byte-identical copied raw PNGs, returned tool output hints, actual ordered reference-image paths/hashes and unsuccessful/unused attempts are retained under `_source/`. All 14 copied raw files were hash-verified against their returned original tool files. The approved appearance master SHA-256 remains `3a4e7927611d40175af4f308291329420f987d79f61f863247e571cf96e62cc2`.

- [Generation provenance](../../../../../../assets/prototype/enemy/wight/remaster_v01/_source/generation-provenance.json) records every actual call and maps each final pose to its generation attempt. It invents no model, seed or timing metadata. One saved alpha-cleanup prompt was never called; one generated p056 alternate edit is retained but unused.
- The first idle page had an extra chest hand; a built-in edit corrected all eight figures. p016 was later newly redrawn to reduce a conspicuous proportion change against adjacent idle drawings.
- p033 was redrawn as a three-quarter-front turn; p037–p039 were redrawn with source back-hood views and narrower native swipe forms. Valid figures from the original page were retained.
- p043, p047, p048, p054 and p055 were newly drawn with clear source-visible articulated hands. This repaired open-palm/hand visibility and pale robe-smear substitutions. Initial outer-edge clipping suspicions were not confirmed by actual alpha bounds.
- Whole-page nearest-component ownership put a small death-bone fragment into p026. Splitting the unchanged raw page at a verified transparent band y477–479 before strict row ingestion returned it to death and removed the foreign speck. [Exact crop and repair evidence](death-fragment-membership-repair.json) is retained. p030/p031 were then newly redrawn to remove extra intermediate joint chips: each has exactly its two detached source skeletal sections, followed by the terminal heap p032.
- Default gutter rejection remains recorded. Strict component ingestion used the user-approved installed dependency overlay. Recovery of explicitly selected valid figures kept the same count, assignment and global-edge checks. No dependency was installed and the shared helper was not edited.

Mali's source-comparison workflow drove those anatomy, view, fragment-membership and continuity corrections. New native hand trails/death sections stay within creature poses; no standalone VFX or projectile was added.

## Actual review and verification

Viewed the approved master, actual original sheets and guides, every raw generation, every final pose against OG at registered scale in both facings, and all 57 final source/candidate poses in unresized 2× detail panels. Inspected **all 18 generated source-ordered contacts**, including first/last drawings and repeated positions, and decoded frame contacts from **all 36 source/mirror GIFs**. The GIF encoder combines the consecutive four-position holds in G1 and G4 into 400 ms frames; atlas/manifest positions remain separate.

[Machine-readable visual review](visual-review.json) records every pose/group, inspected evidence paths and hashes, final art identities, exact sequences, repairs, resource checks and limits. [Final helper validation](final-validate.json) records complete coverage, 102 verified source atlas cells with their mirrored counterparts, and zero errors. Validation passed before and after SpriteFrames export. Static checks additionally confirmed 18 existing local atlas paths and 102 AtlasTexture entries per library, and byte-identical atlases for all exact aliases.

The source manifest SHA-256 at handoff is `0c78125ae6afa6c5e77cb5c1bef92216c8d7fb019c0a27010fa81f572b7c56c3`.

## Review limits and handoff

No unresolved blocking anatomy, clipping, fragment-membership or order defect remained in the worker's inspected candidates. This is **still and decoded-frame review**, not continuous timed playback or human motion acceptance. Fine cloth folds, skull/finger interpretations and silhouette/proportion variation remain visible differences from OG. Uniform aspect-fit can leave the drawing smaller inside native target bounds; it does not establish pixel-identical silhouettes or smooth animation. Parent/human review must judge those qualities.

No browser, Godot import/editor/runtime, gameplay build/test, actor/AI/encounter/timing change, Git operation, canonical record edit or peer message occurred. Every write stayed in Wight's two exclusive folders. Parent owns independent checks, offline package/viewer and publication. Appearance approval remains distinct from animation acceptance.
