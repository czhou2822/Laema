# Fire X2 — original-pose reskin study

Status: review candidate, not approved or integrated. X2 only; no game files or other moves were changed.

## Authority and interpretation

The original Fire X2 at revision `9f9d9bba` uses `assets/prototype/player/animation/earth_x2.png` after the historical Fire/Earth presentation swap. Its native sequence has three 128×128 cells at times 0, 0.456246036 and 0.748549508 on a one-second native timeline.

This is intentionally a **backward-left sword sweep while facing a target to the right**. The reskin does not substitute the generated forward thrust previously shown:

1. Compact chamber: sword hand in front of waist; short foreshortened visible blade points diagonally down-left.
2. Shoulder opens; sword arm extends left/rear and blade points down-left. The original forward-right white motion-arc cluster is retained as a presentation mark, not a new projectile or shield mechanic.
3. Extended-left finish: blade points left, slightly downward; shield remains at front-right chest.

Laema's appearance comes from the current shared Idle: silver-white ponytail, cream sleeves, blue vest, red sash, brown trousers/boots/gloves. Simple steel sword and small round navy shield with steel rim/boss. The decorative hilt from the appearance image was not carried into the plain sword.

## Deliverables

- `original-vs-laema-x2.gif`: synchronized original/new comparison, original left and reskin right.
- `original-vs-laema-x2.png`: three original poses above three reskin poses.
- `fire-x2-preview.gif`: transparent 448×448 preview.
- `fire-x2-3x448.png`: transparent 1344×448 horizontal atlas.
- `frame-01.png` through `frame-03.png`: transparent 448×448 cells.
- `source-three-pose-sheet.png`: unmodified selected generated 2172×724 three-cell sheet.
- `original-x2-128-atlas.png`: original texture recovered from the historical revision.
- `original-x2-pose-authority.png` and individual `original-pose-N.png`: nearest-neighbour enlarged reference cells with added empty canvas, no redraw.
- `appearance-reference.png`: current-avatar appearance-only reference.
- `prompts.json`, `metadata.json`, `build.py`: generation ancestry, exact prompts, mechanical export and QA details.

Built-in image generation created and repaired the artwork. Two targeted repair passes reduced the white streak and shortened/steepened the first-cell blade projection. Mechanical export uses one shared sequence-wide scale, full generated alpha (including detached strokes), and translation to the stance-foot anchor (224,400). Both boots are used for stance centering; the lowest single boot is not treated as the entire root. No independent pose scaling, warping, rigging, morph interpolation or Python repainting was applied.

## Review limits

- The original lower legs/feet are cropped. Their completion is inferred, not an exact recovery.
- Backward sweep direction and three distinct source phases are restored, but the new drawings are **not a pixel-exact pose trace**.
- The first pose still crouches somewhat more; fine shoulder/wrist/shield angles and body-height consistency need review.
- The white crescent remains thicker than the original thin pixel strokes.
- Native canvas scale/alignment is an export convention, not runtime integration proof.

The comparison uses historical pose order and proportional slow-review durations 680/440/380ms, not current game phase remapping or Heat-adjusted timing. Original appearance is shown without runtime school tint. The old cropped source has no recoverable foot root; its comparison placement aligns visible upper-body regions and does not claim full-body root equivalence.

PNG dimensions/alpha/margins and GIF decode, three frames/infinite loop were checked. The static comparison was inspected visually. No continuous live playback, Godot import/editor/runtime, build/test, commit/push or publication was performed.

Only this versioned Art exploration folder was written. Other dirty/concurrent work was preserved. The folder has `.gdignore`; do not remove it to import review materials.
