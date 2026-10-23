# Bone Dragon — static master proposal

**Awaiting user approval. Animation has not begun.** Selected artwork: `raw-04.png`, generated with built-in imagegen and registered through the parent's read-only `tools/lib.cjs`. All project writes are confined to this creature folder.

## Master and registration

- `master_rgba.png`: newly redrawn high-resolution RGBA master, tightly cropped to 1109×1382.
- `master_source_1024x768.png`: right-facing, transparent common cell; `master_mirror_1024x768.png`: verified exact horizontal mirror.
- Anchor **(512,512)**; original reference **(196,268)**; shared source scale **180/73**. Default uniform registration, no anatomy override or stretching.
- Actual alpha bounds **225×281 at (447,228)** versus native target **229×281 at (445,228)**. Center and bottom match; width remains four pixels narrower (1.75%). This is an approximate source silhouette, not pixel-identical reconstruction. It was not normalized to 180px height.

## Visual review

Warm aged yellow/ivory bones, back-angled horns, open skeletal jaw, exposed ribs and vertebrae, raised foreclaws, bent hind legs and the low articulated tail remain present. Folded overlapping wings retain dark charcoal/slate desiccated membranes and long pale bony fingers. Fine modeled shading follows the Pikeman rendering benchmark; no Castle costume or colors were borrowed. There is no living scaled body, spectral cyan treatment, luminous eye effect, floor, cast shadow or added VFX.

Inspected `source-vs-master.png`, `game-size-review.png`, `alpha-review.png` and the registered cell. Wing tips, horns, tail and claws are complete; silhouette and rib/limb gaps remain readable at registered size. Transparent cell corners and borders are clear. The initial display's colored fringe is absent in actual light/dark composites and the sampled pixels. Fine bone contours, spine spikes and membrane tears are generated interpretations and remain subject to human review.

## Source and provenance

CNDRGN is verified against the actual original DEF, native metadata and idle frame hashes. CBDRGN and CHDRGN are excluded. Complete `job.json` was read; all **15 groups / 84 timeline frames / 61 distinct indexed drawings** were reconciled against native metadata. All groups were inspected in the contact image. Detailed guide samples: G0 F0/3/5, G2 F0/4/7, G4 F0/5/10, G7 F0/1/2, G12 F0/3/6, G20 F0/1/2. This is static reference inspection, not playback or a complete 84-frame visual audit.

Four raw attempts, exact prompts and tool arguments are retained as `raw-01..04.png`, `prompt-01..04.txt` and `tool-call-01..04.json`. Attempt 04 corrects the first redraw's narrow wing silhouette; attempts 02 and 03 were not selected. Earlier registered reviews remain in their attempt folders. `source-evidence.json`, `master-manifest.json`, `master-image-metrics.json` and `visual-review.json` carry source paths, hashes, selection and measurements. Original source/reference hashes remain unchanged.

Mali, its physical personal profile, project art direction, the worker brief and imagegen guidance were read before artistic work. User approval is required before animation. No animation, imports, gameplay/game code, runtime/editor, tests/builds, Git operations or peer messages were performed; runtime remains unverified.
