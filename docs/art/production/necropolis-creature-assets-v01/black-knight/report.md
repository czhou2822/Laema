# Black Knight — static master proposal

Status: **Awaiting human master approval. Animation has not begun.** Selected
`raw-master-06.png`; this remains a proposal for the full collection's static
approval gate.

The original **CBKNIG** mounted figure governs identity. The complete `job.json`
and actual metadata agree: **15 groups, 92 timeline positions, 58 distinct indexed
drawings**. DEF, metadata and idle PNG hashes match the job. I inspected
`native-idle-6x.png`, the all-group contact, all 15 guides (43 labeled sample
positions), and the Pikeman rendering master. Group labels remain format mappings;
static inspection establishes no playback timing.

Mali's source-first review kept the dark navy-black rider, red slits, slim helmet
prongs, flesh-covered charcoal horse, small red fringed saddle cloth and one low
curved silver sword. Pikeman supplied modeled volume and material finish only.
There is no Dread Knight horse barding, exposed skeleton, added weapon, effect,
floor or cast shadow. Successive built-in edits corrected overly silver armor,
an ornate hilt, a kinked blade, metallic hoof treatment and a muzzle edge contact.
Earlier raws and exact prompts remain available.

`build-master.cjs` calls the unchanged `../tools/lib.cjs` `registerMaster`.
Registration uses the **180/73** shared source scale, **1024 × 768** cell,
**(512,512)** anchor and **(196,268)** original reference. No anatomy override or
stretching was used. The final alpha64 silhouette is **208 × 242 px**, at
**(465,268)**, bottom **510**. The native target is 200 × 242: the repaint is
**4% wider**, which is disclosed for review rather than hidden with distortion.
General native idle stance and horse/rider relationship are retained; fine
rein-hand placement remains somewhat higher, and tack/limb modeling is an
interpretation of the small original.

Inspected `source-vs-master.png`, `game-size-alpha.png` at 1:1 shared pixel size
in both facings, and `alpha-inspection-06.png` on dark/pale mattes. Props and all
four hooves are visible; the muzzle is complete. Genuine zero-alpha space exists,
no raw edge is touched, registered padding exceeds 40 px, and the mirror matches
pixel-for-pixel. Source-only extraction shadow remains in the native comparison.

Outputs: `master_rgba.png` (high-resolution cutout),
`master_source_1024x768.png`, `master_mirror_1024x768.png`, comparison and alpha
review PNGs, `master-manifest.json`, `mechanical-checks.json`,
`attempt-history.json` and `visual-review.json`. Exact tool requests/prompts are
`request-master-01..06.json` / `prompt-master-01..06.txt`; all raw attempts and
hash provenance are retained. Final tool: **image_gen.imagegen**, via
`functions.exec → tools.image_gen__imagegen`.
Selected raw SHA-256:
`fe3b59cdb48b9bd1216a13751fe3bddc8692a2b06c16bd090e4ba824a313e985`.

Only this creature folder was written. No animation, imports, implementation,
engine/tests/build/runtime, Git operations or peer messages occurred. Static
visual and image-file checks do not establish runtime compatibility. Human
approval of this master is the next gate.

