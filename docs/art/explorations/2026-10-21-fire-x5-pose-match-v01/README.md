# Fire X5 original-pose reskin — review candidate

The user requested the avatar attacks be redone to follow the original poses and sword paths, using parallel move-specific agents. This folder covers X5 only. It is NOT approved or integrated.

## Source and interpretation

Motion authority: `9f9d9bba:config/attack_animations/fire_x5.tres`, pointing at `assets/prototype/player/animation/earth_x5.png` because of the historical Fire/Earth benchmark swap. The four original 128px cells and key order are retained:

1. High overhead up-left sword chamber.
2. High forward wrist with short foreshortened up-right blade.
3. Low back-left/down-left slash follow-through, shield behind left shoulder, thin original low-front white arcs.
4. Low back-left/down-left blade follow-through behind hip.

Appearance only came from the actual Laema shared Idle: silver-white ponytail, cream sleeves, blue vest, red sash, brown trousers/boots/gloves, round navy/steel shield, plain steel sword. The current generated X5 was not a pose reference.

Built-in image generation created the four-pose sheet, followed by one targeted lower-row torso-lean correction. Exact prompts and generated source IDs are in `prompts.json`. No API-key/CLI generation was used.

## Deliverables

- [Original versus Laema GIF](original-vs-laema.gif)
- [Four-pose comparison PNG](original-vs-laema-poses.png)
- [Transparent 4×448 atlas](fire-x5-pose-match-4x448.png)
- [Native transparent GIF](preview.gif) and [enlarged detail GIF](detail-review.gif)
- `frame-01.png` through `frame-04.png`
- Original atlas/padded reference, initial and selected generated source, metadata and prompt ancestry

PNG atlas is 1792×448, each cell448×448, approximate foot root (224,400). One sequence scale targets approximately180px first-pose body; no independent pose resizing. Per-frame root translation and ordinary GIF palette conversion are mechanical exports, not painting or new interpolation.

Review cadence 560/360/300/280ms is slowed inspection timing and not engine timing. The loop goes directly from original fourth follow-through to first chamber; no invented ready/return pose was added.

## Important review limits

This preserves the broad four sword-direction sequence and shield moving behind/left. It is still an AI-derived reinterpretation, not a traced or exact joint match.

The first generation exaggerated the lower-row forward lean. A targeted correction reduced it only partly; poses3/4 still lean farther forward than the original mannequin and should be treated as needing further posture refinement before any exact-pose approval. White slash accents are generated approximations rather than exact source strokes. Blade foreshortening/length, wrist spacing, shield perspective and face/hair/garment continuity also remain provisional.

Original lower legs and some cell-edge content are cropped: completed boots/unseen anatomy are inferred, not source proof. Comparison enlarges the original cells without redrawing or completing them.

Static PNG decode, 448px cell/1792px atlas dimensions, alpha, four unique poses, clear output margins and four-frame infinite-loop GIF decode were checked. The pose-comparison sheet was visually inspected. No continuous GIF playback, Godot/editor/import/runtime/build/test validation was performed.

Only this X5 exploration and its local visualization helpers were written. The tree was already heavily dirty. No runtime asset, script, resource, canonical document, staging, commit, push or publication was changed. This folder is excluded from Godot with .gdignore. Existing auto-created .import files were preserved.
