# Dread Knight — static master proposal

Status: **awaiting human master approval**. Selected artwork: `raw-master-v02.png`.
Animation production has not begun.

The proposal retains the upgraded **CBLORD** identity: a dark armored mounted rider,
tall enclosed helm with black plume and red slit, pale metal shoulder spikes,
silver horse face/neck/chest barding, red saddle panels and hanging fringe, and one
low curved silver sword. The horse remains dark and equine, facing right in the
native idle. The nearby native **CBKNIG** was inspected to distinguish its bare
horse from this upgrade. The Pikeman reference guided modeled volume and surface
finish only. Mali's source-first review kept the original equipment and compact
mounted silhouette as the basis for the redraw.

The complete `job.json` was read. Actual DEF and metadata hashes match it, and every
native group record equals the job's embedded record: **18 groups, 125 frame
positions, 62 distinct indexed drawings**. Native idle, scale guide and the
all-group contact were inspected. Detailed guides sampled G0/1/2/3/4/5/7/11/12/13/17
at their labeled first/middle/last positions. G2 F0, `cblord62.pcx`, is the pose
authority. `visual-review.json` records the exact sampled indices; this was static
frame inspection, not animation playback.

Two built-in `image_gen.imagegen` calls were made. V01 introduced warm gold trim,
an extra spike on the horse's breast armor and blade barbs. A targeted edit
produced V02 with pale silver spikes/edging, a smooth chest plate and a clean,
continuous saber. Both raw attempts remain byte-identical to their tool outputs.
The exact prompts are `prompt-master-v01.txt` and `prompt-master-v02-edit.txt`;
`generation-record.json` contains full call arguments, input hashes, original tool
output paths and raw hashes. Selected raw SHA-256:
`59ef49e4ff40ea716c56c63092e4cbcb2770121dcef6333622b4ffd24f35b592`.

`build-master.cjs` calls the shared `tools/lib.cjs` **registerMaster** without
an anatomy override. Registration uses **180/73**, the **1024×768** transparent
cell, anchor **(512,512)** and original reference **(196,268)**. Native visible
height 99 maps to **244 px**, not 180 px for the mounted unit. Registered visible
bounds at alpha >64 are **(468,265), 207×244**, with a 259 px minimum cell margin.
The redraw's silhouette aspect ratio is 1.65% broader than native; it was scaled
uniformly, without independent width adjustment.

Inspected `source-vs-master.png`, `game-size-alpha-review.png` and both registered
facings. The main identity markers and low sword read at game size. All hooves,
plume, tail and weapon fit. Dark, pale and checker backgrounds show no visible
matte rectangle, floor shadow or added effects. The registered alpha has one
connected component at >64 and no nonzero border pixels; the mirror is exact.
Very faint raw border traces remain in the preserved raw; the helper's standard
alpha >8 crop and padded outputs provide the review framing.

Outputs: `master_rgba.png` (1142×1340 cutout),
`master_source_1024x768.png`, `master_mirror_1024x768.png`,
`master-padded-review.png`, the two comparison images, `master-manifest.json`,
`registration-checks.json`, `source-audit.json` and `visual-review.json`.
Sixty-seven source/reference files were checked unchanged. Fine rivets soften at
244 px; the redraw interprets ambiguous native pixels. Approval, all animation
work, engine import and runtime validation remain outstanding. No game, engine,
test/build/runtime, Git or peer-message operations were performed.
