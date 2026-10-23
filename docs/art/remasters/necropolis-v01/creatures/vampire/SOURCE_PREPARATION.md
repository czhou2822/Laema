# Vampire source preparation

Historical preparation record, before pilot clearance. Current production status and deliverables are in [REPORT.md](REPORT.md). At this preparation stage no new artwork call, idle reuse, ingestion, atlas/mirror export or animation acceptance had occurred.

## Verified inputs

The complete `vampire` entry in `generation-plan.json` was inspected in bounded creature/sequence/pose views and checked against actual `H3sprite/CVAMP` metadata and image pixels: **15 groups, 90 timeline positions, 56 distinct registered source poses**. All 90 indexed-frame crop hashes and RGBA occurrences, all 56 opaque body rectangles, representatives, occurrence maps and repeated positions agree. The native canvas is 450×400; type 66, category creatures. Exact sequence aliases are **G7=G9** and **G8=G10**; each remains a separate required group. G6 and G14–19 are absent in the actual source, not missing work.

| Input | Actual SHA-256, matching plan |
| --- | --- |
| Native metadata | `99faef81225d3ef789f496f65874d8a71bda1542cdcbc1d91e4b37c78f7a98b7` |
| Original CVAMP.def | `5d0d2c832aa0e9d6cf1757d281d242b300cbfb89120e9462dc1726452a9ef476` |
| Approved master / prepared copy | `d069d66f2eb95de77cbaf5e2b518ffa45571cab49384c8f4227a3e3ff82742bd` |

The approved master is a tightly cropped 660×1481 RGBA image with alpha extrema 0–255. It was inspected at high resolution and compared with the original idle `Cvamp01.pcx` / `vampire_p004`. This comparison does not register or authorize reuse for any other drawing.

`prepare vampire` completed with **56 pending poses in seven 4×2 guides**, each 2048×1024, under `assets/prototype/enemy/vampire/remaster_v01/_source/guides/batch-000` through `batch-006`. The preparation manifest and each guide's JSON preserve exact row-major IDs. The appearance copy is byte-identical to the approved master. Packing remains 1024×768 cells, four atlas columns, anchor (512,512), native anchor (196,268), scale 180/73, body alpha >160.

## Observed identity and source actions

The humanoid source and master share a bald pale head, pointed ears, red eyes, long fingers with reddish nails, hunched posture, ragged dark brown/charcoal shoulder mantle and tunic, torn brown trousers and dark shoes. He is unarmed; preserve the base Vampire identity rather than adding noble regalia, hair, a weapon or Vampire Lord costume. The master provides textured modeled volume and clothing detail; it is an appearance reference for the original actions.

All 56 distinct poses were visually inspected in the seven enlarged preparation guides. All 15 existing native group guides were inspected; these supply first/middle/last samples, not full playback. The original all-group overview, native idle canvas and projected idle scale guide were also inspected.

| Source groups | Observed action / preservation risk |
| --- | --- |
| G0, 6 positions / 4 poses | A small brown bat flies right with changing wing spread. Do not retain the humanoid body or normalize it to standing height. Sequence repeats p000 and p002. |
| G1, 9 / 5; G2, 8 / 4 | Subtle hand/chest gesture and idle shifts. Distinct near-idles and repeated hold cells must survive; p004 alone is the exact original idle reference. |
| G3, 7 / 7 | Recoil with a backward lean and raised hand, followed by lowered/crouched recovery. Preserve asymmetric arms and changing height. |
| G4, 9 / 5 | Hands rise across the chest/face in a defensive gesture, then return through repeated drawings. No shield or weapon is present. |
| G5, 8 / 8 | Raised arms, progressive dissolution into detached pale fragments, then a low dark remnant. Preserve scattered source fragments and the lowered final bounds. |
| G7–10, 3 each | Three-quarter to frontal body/head turn and its reverse; aliases 7/9 and 8/10. Frontal views must be drawn, not replaced by mirrored idle. |
| G11–13, 7 each / 19 shared poses total | Unarmed reaches/slashes at upper, front and low angles. G13 includes a deep forward/downward crouch. Keep two hands, finger direction, bent elbows, mantle and feet consistent. |
| G20–21, 5 each / 7 shared poses total | Humanoid-to-bat and return through white/grey smoke already embedded in the creature frames. Some poses obscure most of the body; preserve occlusion and bat anatomy. |

## Risks, evidence and resume point

The difficult cases are bat anatomy, transformation smoke, disconnected death fragments, frontal turns and deep crouches. Later ingestion must retain intended fragment/smoke islands while rejecting neighboring-figure contamination; ambiguous segmentation needs repair, not weakened checks. Large empty margins in native cells and enlarged per-pose guides do not establish final character size; the native coordinates and alpha >160 rectangles do. The tightly cropped master has no guide gutters and must not be treated as a newly generated multi-pose page.

This is static source preparation under the accepted Mali operation. It establishes source identity, counts, mapping and inspected appearance only. Original timing, actual playback continuity, candidate drawing quality, mirrors, final packing, offline package, browser and Godot behavior remain unverified. No generated pose is supplied; all 56 remain pending. No game files, shared tools, plan, original sources, published masters or peer work were edited; no Git, dependency installation or peer message was used.

Resume only after explicit parent pilot clearance/full-generation instructions. Then use the existing guides and approved master; preserve exact prompts, raw outputs and reference hashes, and inspect actual results before ingestion/review. Source-specific risks above remain constraints, not new design choices.

Evidence: [source-preparation-audit.json](source-preparation-audit.json), [source-visual-review.json](source-visual-review.json), and [audit_source_preparation.py](audit_source_preparation.py). Re-run the audit with the worker brief's Python executable and `-B`. The audit writes only this creature's report JSON.
