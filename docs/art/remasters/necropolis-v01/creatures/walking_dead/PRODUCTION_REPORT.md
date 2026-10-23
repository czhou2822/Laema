# Walking Dead production report

2026-10-23. `walking_dead` / original `H3sprite/CZOMBI`.
Status: **COMPLETE WORKER CANDIDATE; parent browser/Godot checks and human animation acceptance remain pending.** Supersedes the earlier preparation hold after explicit pilot clearance.

## Delivered coverage

- **60/60 unique poses**, **15/15 original groups**, **86 ordered source positions**, and **172 positions including exact mirrors**. Missing poses: zero.
- 59 newly drawn final poses from built-in imagegen; one byte-identical approved high-resolution idle master reused only for `walking_dead_p010`, its exact matching OG idle reference. All 60 registered pose images have distinct hashes.
- 30 group atlases, 172 individual frame PNGs, 30 GIF previews, 15 original/candidate contacts, and two SpriteFrames resources. All are under `assets/prototype/enemy/walking_dead/remaster_v01/`.
- Original repeats and exact aliases G7/G9 and G8/G10 are retained. No action was filled with idle, original-pixel upscale, placeholder, or code-warped master.

The helper's fixed 1024x768 cell, four-column atlas, (512,512) anchor, (196,268) source reference, 180/73 scale and original body bounds remain in use. `original_groups.tres` and `original_groups_mirrored.tres` are preview resources, each containing 15 groups/86 positions at illustrative 10 fps; they establish no original timing or actor integration.

## Generation, repairs and provenance

Twelve built-in imagegen calls produced 77 separately drawn source figures across initial and repair pages. The final library uses 59 of those figures. Eighteen superseded pose records and all raw pages/prompts remain recoverable; no attempts were overwritten with different bytes.

Repairs newly drew p038/p039 to correct the intermediate/frontal camera and central edge-on cleaver; p015-p017 to reduce avoidable idle size variation; and p000-p009 plus p058/p059 to restore the source's more upright inclination and slimmer movement silhouettes. Valid figures from other pages were retained. The generated p010 candidate was replaced only by its exact approved idle master.

Four default gutter attempts were rejected: production-002 (p020 touched a nominal row boundary), production-005 and production-006 (no clear row gutter), and repaired walk-000-007 (p002 touched a nominal boundary). The installed strict component path then accepted their separate figures with count/outer-edge checks intact. Thirty final poses use component isolation; 29 new poses use ordinary gutters, plus the approved idle reuse. No dependency installation or shared helper edit was performed.

Every one of the twelve archived generated PNGs was hash-compared with the actual returned imagegen file and is byte-identical. `transmitted-prompts.json` retains exact request strings/reference order; `_source/prompts/`, `_source/raw/` and `_source/tool-metadata/` retain prompt copies, submissions and returned metadata. `generation-reference-provenance.json` records actual master/guide hashes. No seed or model was returned, and none is fabricated.

## Actual review and validation

Inspected every generated raw page and OG guide, all 60 unique poses through enlarged source/candidate comparisons, every source-ordered helper group contact, and all 30 GIF previews as decoded static frame sheets in both facings. The GIF sheets contain 166 decoded frames; repeated identical holds are coalesced by GIF encoding while their total durations and all 86 atlas positions remain intact. Reviewed openings, exits, turn reversals, repeated holds, limb overlaps, skeletal hand, cleaver grip/angle, feet, death curls, alpha and framing. No unresolved blocking anatomy, clipping, equipment or ordering defect was found in this worker's static pass.

All 60 pose reviews were marked through the parent helper with actual individual observations, then the library was rebuilt. Validation passed before SpriteFrames export and again afterward: **complete=true, 86 frame cells verified, 60 reviewed poses, errors=[]**. `validation-results.json` preserves the final result. `visual-review.json` records each pose/group observation, file hashes, raw origin, repair history, inspected evidence and limits; `review-artifact-index.json` points to the comparison sheets.

Mali's evidence boundary kept appearance approval separate from candidate-motion acceptance. Review was static ordered-frame inspection, not real-time playback. Fine details and proportions remain generated interpretations, not pixel-identical reconstructions. No browser, Godot/editor, gameplay, engine build, human playback or original-timing proof is claimed. No Git operations, actor/AI/encounter/timing/canonical-record edits, or peer messages were performed; publication belongs to parent.
