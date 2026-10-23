# Zombie — full asset production handoff

Status: **COMPLETE — worker-reviewed candidate; human motion acceptance pending.**
Dedicated creature: `zombie` / `CZOMLO`. Parent cleared the pilot workflow in the
follow-up instruction. No other creature was edited.

## Delivered coverage

- **60/60 unique poses reviewed; 15/15 original groups; zero missing poses.**
- All 86 original source positions, source order, repeated holds and exact aliases
  are preserved. Source plus exact mirrors provide 172 ordered frame PNGs.
- 120 individual pose PNGs including mirrors, 30 group atlases, 15 original/candidate
  contacts, 30 GIF previews, and two complete SpriteFrames resources.
- G7/G9 and G8/G10 remain byte-identical alias atlases in both facings. Their
  opposite turn orders remain separate. Movement-start/end remain distinct.

Asset root: `assets/prototype/enemy/zombie/remaster_v01/`.
The root `source_manifest.json` contains complete mappings, relative source paths,
registered geometry, provenance and review records. `original_groups.tres` and
`original_groups_mirrored.tres` each contain all 15 groups / 86 positions. Their
10 fps timing is explicitly preview-only; original timing remains unknown.

## Production and repair

Used **nine built-in imagegen calls**: eight source-guide pages (seven with eight
figures; one with four), then one individual repair. All 60 active poses are new
artwork; **zero master/idle reuse**, no OG upscale deliverables and no warped or
code-painted bodies. There are 61 generated pose drawings including the replaced
attempt. Exact prompts, actual reference hashes, returned tool hints and verbatim
raw PNG copies are retained in `_source/` and `generation-provenance.json`.
No model or seed was returned by the tool, so none is asserted.

The first walking-page rectangular extraction rejected `zombie_p001` at a nominal
cell boundary. Its raw/prompt/submission are retained. The approved strict SciPy
component path accepted all eight pages with separate row-major figures and no
outer-edge clipping/count-check override. The individual repair used 1×1 Pillow
ingestion. No dependency installation or shared-helper edit occurred.

Repair: `zombie_p015` originally held its hammer too vertically. A newly drawn
single-pose replacement restores the original diagonal down-right shaft. The
original page and previous pose record remain under `_source/raw/` and
`_source/history/zombie_p015/`. Build regenerated every group, including affected
G2, from the retained isolated artwork.

## Actual review and validation

Inspected every raw page and the repair, all eight original guides plus the repair
guide, and all 60 registered original/candidate pose comparisons. The raw images
provide enlarged anatomy/equipment inspection; registered comparison panels retain
1:1 pixels, although the image tool can downsample their complete contact image.

Then inspected **all 15 group review boards**: every source-ordered contact position
and all decoded GIF frames for source and mirror facings. Reviewed walk return,
idle/defence holds, raised-arm hurt recovery, folded corpse/hammer positions,
frontal turns and their reverse, all three hammer attack directions, and separate
movement start/end. Review boards and separate full comparison/GIF-frame sheets
are under `_source/review/`. This is static frame/sequence inspection, not timed
playback. Per-pose and per-group observations are in `visual-review.json`.

The unmodified helper ran `build zombie`, `validate zombie`, `spriteframes zombie`,
and final `validate zombie`. Both validations returned **complete=true, errors=[]**,
86 source atlas cells verified, and 60 current pose reviews. Checks cover pose/atlas
hashes, exact mirrors, source cell order, transparent padding, geometry and GIF
preview duration totals. All final review hashes match the current pose bytes.
See `validation.json` for the actual results.

No blocking anatomy, clipping or ordering defect was observed after the repair
at the inspected scales. Independent drawings still vary in body proportions,
cloth and texture. The required source-bound aspect-fit can make a broader drawn
silhouette visibly shorter than OG; the prescribed transform was retained without
independent body/weapon/action scaling. These candidates still require the parent's
independent visual checks and the user's motion acceptance.

No browser, Godot/editor, engine import, gameplay/build/test run, human playback,
canonical record update, Git operation or publication was performed.

## Evidence pointers

- `visual-review.json`: 60 per-pose entries, 15 per-group entries, inspected files,
  observations, current hashes, exact source order and validation boundaries.
- `generation-provenance.json`: nine exact prompts sent, actual references/hashes,
  returned tool metadata and the retained rejected/superseded attempts.
- `validation.json`: before/after SpriteFrames validation plus output/alias checks.
- `source-preparation.md` and `preparation-visual-review.json`: historical initial
  preparation evidence, retained separately from this completion.

Plan SHA-256: `084dcc8ed5bdbf4ade05ec7f6bd9cf2f78bfe575884c6ebad256a3927012488f`.
Production helper SHA-256: `763bccc9052e527d13ecbbdc0502bc539fbbb68994181be9446a9ab3d5cb8e3d`.
Approved master SHA-256: `2475a0958922c1ad54875612b7a871c49c1d39480da772f2647ca8829e8d8b1e`.
