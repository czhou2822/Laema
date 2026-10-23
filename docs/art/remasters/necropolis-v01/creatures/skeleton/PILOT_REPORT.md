# Skeleton attack/turn pilot

Historical pilot snapshot. See `FULL_REPORT.md` for the completed full source coverage.

Status: supplied for parent review. **Pilot only; full creature incomplete.**
The dedicated Skeleton assignment is retained for the later full pass.

## Supplied scope

Exactly the ten distinct prebuilt-guide IDs are active:

- Page00 order: p033, p034, p035, p036, p043, p044, p045, p046.
- Page01 order: p047, p042.
- Complete source groups: G7/B6, G8/B7, G9/B8, G10/B9 and G12/B11.
- Front attack source order: p035, p036, p043, p044, p045, p046, p047, p042.

Coverage is 10/57 unique poses and 5/15 groups, covering 16/86 source positions
plus their 16 exact mirrored positions. The remaining 47 poses and ten groups
stay explicitly missing. No idle reuse or original-pixel substitution was used.

## Parent review paths

All asset paths below are relative to `assets/prototype/enemy/skeleton/remaster_v01/`:

- `contacts/pilot_comparison_source_1x.png`: all ten original/candidate comparisons with one shared fixed viewing window.
- `contacts/pilot_comparison_source_2x.png`: enlarged version.
- `contacts/pilot_comparison_mirror_1x.png`: all ten mirrored comparisons.
- `contacts/pilot_alpha_light_contact.png`: alpha/edge inspection on a light background.
- `contacts/group_12_block_11.png`: source-ordered eight-frame front attack, originals above candidates.
- `previews/group_12_block_11_source.gif` and `_mirror.gif`: front attack review previews.
- `contacts/group_07_block_06.png`, `group_08_block_07.png`, `group_09_block_08.png`, `group_10_block_09.png`: complete turn comparisons; corresponding GIFs are in `previews/`.
- `source_manifest.json`: partial manifest, exact source occurrence mapping, frame order, hashes and missing IDs.

`pilot-visual-review.json` records individual observations and remaining limits.
`pilot-mechanical-evidence.json` records the actual subset checks and reference hashes.

## Artwork and repairs

All new artwork came from the built-in image generator: nine calls, with exact
prompts and request JSON under `_source/prompts/`. Returned output hints are
preserved verbatim in `_source/*.tool-metadata.json`; every returned raw PNG was
copied byte-for-byte. All nine original-output/local-copy comparisons passed.
No model or seed was returned, so none is claimed.

Page00's original rectangular-grid ingestion failed because sword extents crossed
column boundaries. After the parent provided the user-approved task-local SciPy
overlay and strict component extraction, the unchanged page passed under batch
`pilot-attack-turn-00-a01-components-c01`. Seven of those figures remain active.
The p033 sword-angle failure was repaired with a separate built-in image: it now
hangs down beside the hip. The frontal p034 genuinely turns toward camera.

Page01 had visible background haze and was rejected. Its two recovery poses were
redrawn individually: p047 retains a shallow upward blade with deeply bowed torso;
p042 retains the later recovery and downward blade. All earlier attempts survive.
Four other generated single-pose alternatives remain retained but inactive.
Prepared a02 requests for p044/p045/p046 were never called.

The active ten poses are all newly generated artwork: seven page figures plus
three single-pose repairs. No original or appearance master was edited. Skeleton
master, original DEF and original metadata hashes match the generation plan.

## Actual review and limits

Reviewed all ten source/candidate poses at registered scale and enlarged, both
facings, all five group contacts, and all ten exported GIFs as decoded source-order
frame strips. Light/dark alpha contacts show no floor, text, grid or cast shadows.
The subset checks found no errors in fixed cells, alpha, safe padding, hashes,
exact mirrors, atlas cell order or encoded 100 ms review durations. This is static
worker review, not live animation playback, human animation acceptance or runtime proof.

Source limits: the native pilot silhouettes are only 38-105 pixels wide and 69-108
tall; exact finger overlaps and near-edge-on blade occlusion are not fully resolved.
The four turn groups contain two original poses in forward/reverse orders with
exact aliases, not four independently drawn turn sequences. Original timing is
unknown; every GIF uses 10 fps solely for comparison.

Candidate limits for parent review: silhouette ratios and some rib/forearm angles
vary from the source; fixed registration does not make joint landmarks identical.
The p033 blade is more exposed than the source's tiny edge-on blade. The p042
downward blade slope is somewhat steeper than the original. The original anatomical
sword hand and the distinct wind-up, strike and recovery actions remain readable.

No full-library validate/SpriteFrames export was run because 47 poses are missing.
No browser, Godot, game build or engine test was run. No Git, game code, shared tool,
generation-plan or canonical-record changes were made by this worker.

Resume: retain this pilot and its provenance for parent review. Remain the dedicated
Skeleton worker; do not generate other poses until the later full pass is released.
