# Skeleton full animation production

Status: **worker asset production complete; parent independent QA and motion acceptance pending.**

All 57/57 unique source poses and 15/15 groups are supplied and worker reviewed,
with zero missing poses. The ten supplied pilot poses, including corrected p033,
are retained byte-for-byte. All 47 additional poses were newly drawn; no idle
master reuse, OG upscales, code-painted anatomy or warped-master fillers were used.

## Outputs

Asset base: `assets/prototype/enemy/skeleton/remaster_v01/`.

- `source_manifest.json`: full original occurrence mapping, source order/repeats, exact aliases, raw/isolated/registered hashes and fresh worker reviews.
- 15 source atlases plus 15 exact mirror atlases; 86 frame positions per facing, 172 frame PNGs in `frames/`.
- 57 source poses plus 57 exact mirrored poses in `poses/`.
- 30 GIF review previews in `previews/`.
- `original_groups.tres` and `original_groups_mirrored.tres`: all 15 groups / 86 positions each, explicitly preview-only resources.
- `contacts/full_batch_000_source_comparison.png` through `full_batch_005_source_comparison.png`: remaining-pose original/candidate comparisons; corresponding mirror/light-alpha versions are supplied.
- `contacts/full_gNN_source_comparison.png`: every original-ordered group; `full_gNN_source_gif_timeline.png` and `_mirror_gif_timeline.png` show every logical GIF position, including repeated holds.

Useful parent review examples:

- `contacts/full_g05_source_comparison.png`: all six death positions, released sword, detached bones and final low bone pile.
- `contacts/full_g11_source_comparison.png`: complete upper attack with real side/back views and repaired p037.
- `contacts/full_g13_source_comparison.png`: complete low attack and distinct bowed recoveries.
- `contacts/full_g02_source_gif_timeline.png`: idle sequence after p014 continuity correction.
- `contacts/pilot_comparison_source_1x.png`: retained pilot overview.

## Repairs and provenance

The full pass used six built-in image-generation pages (8,8,8,8,8,7 poses) and
three single-pose repair calls. Across pilot and full pass, 18 built-in calls are
retained, with exact prompts/request JSON under `_source/prompts/`, original PNGs
copied verbatim, and returned output hints in `_source/*.tool-metadata.json`.
All 18 original-output/local-copy byte checks passed. Actual reference paths and
hashes are in `full-mechanical-evidence.json`. No model or seed was returned.

Strict component extraction initially split p030's released sword across p026 and
p030. The unmodified raw page contains both complete poses in explicit disjoint
whole-cell regions; these were mechanically cropped, inspected, ingested singly,
and verified RGBA-identical to those raw regions. No fragment was deleted or
painted. Exact rectangles and hashes are in `death-region-recovery.json`.

p014 was redrawn twice to correct excessive idle straightening and knee extension;
a03 is active. p037 was redrawn once to restore the narrow side view and steeper
overhead sword angle. Prior attempts remain in raw files and pose history. All
dependent groups were rebuilt and inspected after these repairs. Other valid
page figures were reused rather than regenerated wholesale.

## Verification and review boundary

Required sequence passed: **validate -> SpriteFrames -> final validate**. Both
validation runs reported complete=true, 86 frame cells verified, no errors, all
57 worker reviews, and no missing poses. `final-validation.json` retains results.

All unique source/candidate poses were compared at registered display size and
against enlarged source/raw artwork. Every source-ordered group comparison and
all 30 GIFs were inspected as decoded frame timelines in both facings. Light/dark
alpha checks found no background haze, floor, text, grid or cast shadow. Exact
mirror/alias/atlas order, immutable-input hashes, raw copies and all 57 review-hash
freshness checks passed. No blocking anatomy, clipping or order defect remains
observed by the worker. See `full-visual-review.json` for per-pose/group evidence.

Remaining limits: source fingers/occlusion are low-resolution; redraw silhouette
proportions, some rib/forearm angles and highlights vary. The preserved pilot's
more exposed p033 blade and slightly steeper p042 recovery blade remain documented.
These are candidate-quality limits for parent motion review, not an exact joint
landmark claim. Original timing is unknown; GIFs/resources use 10 fps for review.

No live animation playback, browser, Godot, game build or human motion acceptance
is claimed. Parent owns independent validation, integration and publication.
No Git, game files, shared tools, generation plan, canonical records or peer chats
were changed by this worker. All writes stay in the two assigned Skeleton folders.
