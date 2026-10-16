# Heroes III source-style sprite study — 2026-10-16

Status: first static review sample under the user's instruction to make the original HMM3 export the art-style source of truth. Generated artwork and mechanical size-normalization only; no gameplay-file edits, animation or runtime validation.

## Review outputs

- `laema-fire-ready-generated-source.png`: cleaned, enlarged transparent generation, 1024×1536. Original generated output ID: `exec-5fe725d2-5ed3-419d-be07-63c3398ec876.png`.
- `laema-fire-ready-proposal-128.png`: transparent 128×128 RGBA review sprite. The substantial visible source silhouette is normalized to 54×96 pixels including the sword, centered with foot baseline at y=116. Body height is smaller than that full sword-inclusive height. Export uses Lanczos reduction, not a claim of hand-authored native pixels.
- `export-spec.json`: measured bounds, dimensions and alpha verification.
- `laema-h3-native-comparison.png`: the displayed comparison preview, copied byte-for-byte into the depot during the complete checkpoint audit so it travels with the review sprite. It displays the proposal beside unmodified native crops from `Csword.def` group 1/frame 0 and `Ccrusd.def` group 11/frame 2, first at native size and then at nearest-neighbour 4×. Original reference pixels were not repainted or recolored. This is a review reference, not a production game asset; the full original collection remains external.

## Source authority and observations

Original HMM3 source reference: task `01a142bd-e72a-7f03-b3fb-1b28d222492b`, collection `Heroes3-original-sprites`. Current source artwork remains outside the depot. The Art task used its existing extracted frame metadata for exact crop locations, not invented animation groups or timings.

Static observations: fine steel highlights and shaded cloth/leather are closer to the inspected original sprites than the earlier chunky-pixel courtyard studies. The one-handed Fire sword reads as a restrained red line at native size. The proposal is slimmer and more directly side-on than the two reference figures. Its enlarged painting is not proof of a complete original-style animation pipeline.

Open: user acceptance, whether the seam needs more contrast during motion, exact final camera size, front/back and movement poses, split/join/extension continuity, two-handed heavy pose, the other three schools, and game integration. This pose is not a final character identity or an approved production set. Previously accepted sword and art-direction choices remain in `docs/art/ART_DIRECTION.md`.

## Generation and export

Built-in image generation was used for the new character and a targeted transparency cleanup. The initial draft was `exec-92c25776-fde7-4ea2-9a79-b4a4e51a9e47.png`; the cleaned second output is the saved source. Cleanup requested preservation of all character/weapon details while removing background haze and retaining only the seam light on the sword. Actual transparency was checked on a neutral matte.

The export script and reference comparison script are retained in the Art task's visualization directory (`export-laema-h3-study.py` and `h3-reference-contact.py`). Cropping and size-normalization do not alter the retained full generated source.

## Initial generation prompt

Generate ONE isolated original female battlemage character sprite for Laema, TRANSPARENT background, no text, no labels or sheet, no scenery, no enemy. Image 1 is the AUTHORITATIVE STYLE REFERENCE: unmodified native Heroes of Might and Magic III battle frames and their nearest-neighbour enlargements. Image 2 is ONLY the selected sword design reference, NOT the required rendering style. Match image 1's subtle low-resolution rendered-volume look: natural human proportions about 7 heads tall, fine shaded steel, soft midtone ramps inside crisp silhouettes, subdued blue cloth and worn brown leather, tiny sharp specular highlights, no heavy black cartoon contours, no anime face, no deliberate giant square pixel clusters or cel shading, no painterly promotional illustration. Character: adult human female, silver-white shoulder-length hair, functional slate-blue split travelling tunic over dark trousers, brown boots, leather belt, restrained small red scarf, small steel forearm/shoulder protection; modest practical clothing, no long cape. Full-body ready stance facing screen RIGHT with a very slight three-quarter turn sufficient to model volumes, legs planted, not jumping; view near eye-height adapted to side-scrolling combat, no top-down or isometric ground plane. She holds one plain straight one-handed steel sword in her forward hand, blade angled diagonally up-right, about half her body height. Simple crossguard and leather grip; subtle thin RED-ORANGE central lit seam, steel edges dominate, no flame cloud, no runes, no staff, no shield. Other hand free and visible. Blade point is only at the far end; handle at her hand, never a handle at a blade tip. Lighting upper-left and coherent with original Heroes III reference, no strong outline glow or rim lighting. Aim for a sprite which will retain the fine modeled shading of the original examples when reduced to roughly 90 pixels BODY HEIGHT. Render it as a clean enlarged sprite on transparent canvas with generous margin around sword tip and boots so it can be cropped and size-normalized for direct comparison. Do not recreate or repaint the original reference sprites; create only Laema's new sprite. One pose only. No ground shadow baked into the feet.
