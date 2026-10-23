# Vampire Lord source preparation

Historical preparation snapshot. See `PRODUCTION_REPORT.md` for the later full-production result.

Status: preparation complete; awaiting the parent's explicit Skeleton/Bone pilot clearance and full-generation instruction. Dedicated creature ID: `vampire_lord`. No animation artwork has been produced or accepted in this pass.

## Verified source inventory

The complete Vampire Lord entry in `../../generation-plan.json` was inspected in bounded group, pose and frame slices. Its native source is `H3sprite/CNOSFE.def`, with 450x400 source cells: **18 original groups, 111 timeline positions, 62 registered pose signatures, 36 source sheets** (18 RGBA and 18 indexed), and 14 distinct group sequences. Every original group record, frame record, sheet-cell occurrence, signature and representative matches the current native metadata; all 62 alpha>160 body rectangles were recomputed from the referenced RGBA sheets and match. All 111 positions remain mapped, including repeated frames.

| Group | Plan interpretation | Positions | Exact sequence aliases |
|---|---|---:|---|
| 0 | Movement | 6 | None |
| 1 | Idle gesture | 9 | None |
| 2 | Idle | 8 | None |
| 3 | Hurt | 7 | None |
| 4 | Defensive reaction | 9 | None |
| 5 | Death | 8 | None |
| 7 / 9 | Turn part 1 / legacy turn | 3 each | 7 = 9 |
| 8 / 10 | Turn part 2 / legacy turn | 3 each | 8 = 10 |
| 11 / 12 / 13 | Melee upper / front / lower | 7 each | None |
| 17 / 18 / 19 | Special upper / front / lower slots | 7 each | 17 = 18 = 19 |
| 20 / 21 | Movement start / end | 5 each | None |

There is no group 6 or 14-16 in this source. Slot labels are interpretations, not new gameplay or original-timing evidence. `vampire_lord_p004` is the exact registered idle reference and occurs at 16 source positions across multiple groups; other similar idle drawings remain distinct poses.

Actual SHA-256 values match the generation plan; the master also matches its applicable master-approval entry:

- Metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CNOSFE/metadata.json` — `4ac5906db377f31902170fdd68224eaf2c92d379b4f7b74317023dacc9f6bd8d`.
- Native DEF: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CNOSFE.def` — `7f3fe9079b255ad09ded551a82017580087905f0e6f4484aad90b357b84a0cfa`.
- Approved 732x1448 RGBA master: `docs/art/production/necropolis-creature-assets-v01/vampire-lord/master_rgba.png` — `ce85d841852af7fedf5ebdad8b0451bc7f85dcd7c8494f1de35e0a7e85713d64`. Its `_source/appearance-master.png` preparation copy is byte-identical.

## Preparation and actual visual inspection

Ran `python -B tools/art/necropolis_remaster.py prepare vampire_lord`: **62 pending poses, eight guide pages**. The eight existing guide PNG/JSON pairs under `assets/prototype/enemy/vampire_lord/remaster_v01/_source/guides/` cover p000-p061 exactly once in row-major order: batches 000-006 each contain eight poses; batch 007 contains six. All pages are 2048x1024, four columns by two rows; the last two cells are empty. Their mappings, dimensions and master hash were checked after preparation. No duplicate custom guides were made.

Viewed the approved high-resolution master and all eight guide PNGs at original image resolution, covering **all 62 unique source drawings**:

- p000-p003: right-facing bat flight, with distinct raised/folded membrane silhouettes; movement is not a walking robed humanoid.
- p004-p011: narrow hunched humanoid idle and gesture variations. Observed identity: bald pale wrinkled head, pointed ears, red eyes and fangs, long clawlike bare fingers, charcoal/brown ragged floor-length robe, orange-gold collar/cuffs/edging and dark red inner cloth. No held weapon or added armor.
- p012-p021: recoil and defence change arm height, shoulder lean and sleeve spread; the defensive hand comes across the face.
- p022-p028: raised arms progress into embedded pale disintegration flecks and a low collapsed remnant. Preserve those source fragments and the shrinking silhouette.
- p029-p030: frontal/intermediate turn views differ from the default right-facing three-quarter pose; retain their source view.
- p031-p048: upper, forward and low clawing actions have different reaches and crouches. Hands, long nails, ragged sleeves and robe folds require independent pose attention.
- p049-p054: the special-slot sequence contains an embedded pale pink/white bloom and specks around the raised hand/head region, then settles back. Its gameplay meaning is not inferred.
- p055-p061: white/gray transformation clouds partly obscure the humanoid and bat forms. These are embedded creature-frame content, not permission to add separate effects.

## Risks and validation limits

Preserve the fixed 1024x768 cell, (512,512) anchor, source reference (196,268), scale 180/73 and alpha>160 native body bounds. Guides enlarge each source crop for reference readability and do not establish delivered pose scale. Flight bodies range down to 22 native pixels high versus 87 for p004; the death remnant is 26 high and a deep low attack is 54. Standing-height normalization would erase this source geometry.

Thin fingers, ear tips, wing membranes, tattered cloth and embedded particles/clouds risk being cropped, merged, discarded as noise or assigned to another cell by generation/isolation. Smoke-heavy figures need particular review before component-based isolation. Aliased groups must remain independently represented later, and repairs to any shared pose must propagate to every occurrence.

The approved master's measured alpha range is 0-254: 379,263 fully transparent pixels and 680,673 partial-alpha pixels, with alpha>8 bounds spanning the full 732x1448 crop. The displayed reference has a warm dark fringe/background appearance. This is an observed source characteristic to inspect against contrasting backgrounds during future asset review; appearance approval does not prove clean new sprite transparency. The published master was not modified.

This pass is **static source preparation only**. Enlarged guides were reviewed, but no new candidate exists for game-size comparison, mirrored animation, temporal continuity, transparent-gutter isolation or human animation acceptance. No native DEF re-decoding, original-timing proof, browser playback, engine import or runtime check was performed. The local `source_preflight.py` is a read-only asset-data check, not a gameplay test. Mali's workflow kept observed source content separate from action/slot interpretation.

No image-generation, ingestion, pose-acceptance, animation build, validate or SpriteFrames command was run. All 62 artwork poses remain pending. No dependencies were installed, no Git operation or peer message was issued, and writes were confined to this creature's two assigned directories.

Resume: retain dedicated ownership of `vampire_lord`; wait for the parent's explicit pilot clearance/full-generation instruction before any artwork operation. Start from `_source/preparation.json` and the inspected guide/master references; do not treat this preparation report as animation clearance.
