# Research AI Art Pipeline for HoMM3

Published research from 23 October 2026, based on Laema commit `16b4c3b7`.
This folder contains research evidence and experimental assets. Production creature
assets, gameplay code and timing were not replaced.

- [Research report — PDF](report.pdf): 17 pages, primary-source evidence, project diagnosis and controlled results.
- [Standalone interactive report](report.html): download and open locally to scrub frames, compare silhouettes and inspect previews.
- [Local continuation prompt](CONTINUE_LOCALLY.md): copy into your local Codex session after pulling this repository.
- [All experimental frames](comparison_all_methods.png) and [animated comparison](comparison_animated.webp).
- [Staged Gym renderer comparison](gameplay-preview/normalized/engine-comparison-animated.webp).
- [Reproduction instructions](README.txt), [executed restoration recipe](a-restoration/README.txt) and [proposed local Qwen workflows](workflows/README.txt).

## What was actually tested

One Castle Pikeman front-attack group: ten frames, six unique source drawings.

1. **Restoration:** actual CPU RealESRGAN_x4plus, with nearest/Lanczos controls and source alpha locked exactly.
2. **Per-frame editing:** six source-image/reference-guided edits through the available image tool, with soft pose instructions and deterministic reuse of repeated poses. This was not a local Qwen or ControlNet run.
3. **Whole-sheet editing:** one reference-guided strip. The raw output changed aspect ratio and crossed fixed cell boundaries, cutting pikes during atlas extraction.

The current Pikeman repaint also changes the original recovery-pose mapping.
Preserving ten frames alone did not preserve the animation.

## Limits to carry forward

- The original timing is incomplete: the documented base attack is one second, but the ten 100 ms preview dwells are provisional, not verified original executable timing.
- Complete high-resolution master packages and prior generation workflows were unavailable. The experiments explicitly used a cropped generated idle frame as an appearance proxy.
- Qwen/ControlNet, temporal propagation and rigging were researched or prepared, not executed. Proposed scripts were syntax checked only.
- Gym captures are actual staged renders from an isolated copy, not combat playtests. Godot 4.6.3 rendered a project targeting 4.7, with a documented unrelated UI compatibility error.
- No candidate has final art approval. Human cleanup time and roster production cost remain unmeasured.

## Continue on the local computer

Pull this repository's latest `main` using your existing checkout. Preserve any
uncommitted work; do not reset, overwrite or automatically stash it. Open this
folder and paste [CONTINUE_LOCALLY.md](CONTINUE_LOCALLY.md) into Codex.

Downloaded weights, the Python environment and the copied game project/cache are
excluded. Fetch official models only when needed for the chosen local experiment,
using the pinned revisions and hashes. Existing absolute `/workspace/...` paths
are provenance from the cloud run; adapt reproduction paths to this checkout.
The report and candidate images can be reviewed without installing any models.

`.gdignore` keeps these research files outside Godot's normal asset import scan.
The original `bundle_manifest.json` records the cloud review package's bytes.
This publication adds this index and the continuation prompt without altering its
original evidence files.
