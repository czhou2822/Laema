# Fire X1 — original-pose reskin candidate

The user rejected the choreography drift in our generated avatar attacks and asked to redo X1–X5 with the original poses and sword paths. Work began with X1; the user then explicitly authorized move-specific subagents for the remaining moves. This is the X1 review candidate, not an accepted exact trace or runtime replacement.

## Reference authority

- Historical Fire X1 resource: Git revision `9f9d9bba`, `config/attack_animations/fire_x1.tres`.
- Its texture is `assets/prototype/player/animation/earth_x1.png` because the Fire/Earth benchmark presentation swap predates the avatar replacement.
- Four original 128px frames remain in their original order. The original atlas and a padded 2×2 mechanical reference layout are preserved here.
- `laema-appearance-only.png` derives from the current avatar Idle. It supplies appearance/materials only, not choreography.
- Laema identity: silver-white ponytail, cream sleeves, blue vest, red sash, brown trousers/boots/gloves; plain steel sword and round navy shield with steel rim/boss. Original Heroes III material direction carries through the avatar reference, not a claim of authentic H3 artwork.

## Restored phase directions

1. Sword wrist behind the torso to screen-left; blade diagonally up-left.
2. Sword wrist high in front of head; blade points steeply up-left.
3. Sword arm extends forward-right; blade cuts slightly down-right.
4. Low follow-through; blade points steeply down-left. No substituted return-to-ready pose.

The visible original shoulder/wrist/blade relationships guide the reskin. They are not proven pixel-identical: arm reach, anatomy, torso twist, shield perspective and blade foreshortening still vary. The original cells crop lower legs and some blade extent; those hidden portions were completed by inference. Comparing inferred full boots to cropped original pixels cannot prove foot fidelity.

## Files

- [Original versus candidate GIF](original-vs-laema-x1.gif)
- [Four-pose comparison](original-vs-laema-x1-poses.png)
- [Transparent native flipbook](fire-x1-4x448.png): 1792×448, four448×448 cells, root(224,400), approximately180px body excluding raised sword.
- [Transparent preview](fire-x1-preview.gif) and [enlarged review](fire-x1-detail.gif).
- `frame-01.png`–`frame-04.png`: native RGBA frames.
- `source-selected-four-pose-sheet.png`, prior generations, reference images, `prompts.json` and `metadata.json`: complete source lineage.

Built-in image generation produced the artwork and targeted edits. The first white motion accent was too thick; a stroke-thinning edit still resembled a filled effect, so a second targeted edit removed the accent entirely. The selected candidate preserves the physical blade phases but omits the original white motion strokes; that is an explicit remaining VFX difference, not a new approved effect.

Mechanical export uses complete-figure rectangles because the lower-left blade crosses the conceptual source-cell division without overlapping the next figure. No blade tip was silently cut at that division. One scale serves all four poses; translation aligns the midpoint of both boots, not a single lowest sole. No per-pose scaling, painted repair, rigging or interpolated new poses was used.

## Evidence and limits

PNG dimensions/alpha and four unique frames were checked. Three GIFs decoded as four frames and infinite loops; exported opaque bounds clear all canvas edges. The pose comparison was visually inspected. Original-reference registration is approximate upper-body alignment; missing old boots are not reconstructed as reference evidence. GIF cadence is slowed inspection timing, not engine timing or phase remapping.

No continuous playback inspection, Godot/import/build/test/runtime validation, integration, hitbox/timing/gameplay edit, commit, push or live publication. Current runtime attacks and other concurrent repository edits remain untouched. Review the reskin against the originals before authorizing any integration or further in-betweens.
