# Fire X2 v02 — starting-pose blade-depth correction

On October21 the user identified X2's starting pose as having the same front-of-thigh blade problem just corrected in X1. This revision changes only X2 pose1: the sword chambers diagonally back-left behind the left thigh, with the trouser leg covering the central blade and only a short foreshortened tip visible.

Status: review candidate, not user-accepted final art, not integrated into the game.

## Scope and files

- Pose1's forearm/wrist/sword and overlap were edited; its own crouch and stance were retained rather than copying X1's wider pose.
- Poses2 and3 are byte-for-byte identical to v01, verified with SHA-256 in metadata.
- [Enlarged review GIF](fire-x2-detail.gif), [transparent preview](fire-x2-preview.gif), [original versus revised](original-vs-laema-x2.gif).
- [Three-pose comparison](original-vs-laema-x2.png), [opening close-up](first-frame-closeup.png), [before/after](first-frame-before-after.png).
- [Transparent atlas](fire-x2-3x448.png):1344×448, three448×448 cells, foot anchor(224,400).
- Individual frame PNGs, raw generated edit, edit target and original first-pose reference preserved.
- [Exact prompt](prompts.json) and [metadata/checks](metadata.json).

Built-in image generation performed the targeted artwork edit. The corrected X1 v02 source was supplied only as a depth/occlusion example; the original X2 first pose remained the motion reference. The generated square canvas was uniformly restored to724px and exported with X2 v01's existing shared scale, plus foot-root translation. No painted/warped repair, additional in-betweens or gameplay tuning was applied.

## Verification and remaining limits

Static before/after inspection confirms removal of the silver blade stripe over the sash/trousers. Three unique native frames and clear alpha margins checked. Three GIFs were decoded as three frames and infinite loops. Pose2/3 PNG bytes match v01. Continuous GIF playback, Godot/import/build/test/runtime verification was not performed.

The original's cropped boots are still inferred. The deeper starting crouch remains unchanged by scope, fine grip/guard/shield/face continuity is provisional, and pose2's white crescent remains thicker than the original. This correction does not establish an exact pose trace or final equipment continuity.

Preview cadence680/440/380ms is slowed review timing, not engine timing. v01 is preserved. No runtime asset/binding, code, scene, hitbox, timing, other-move or canonical-record edits; no staging/commit/push/publication. This folder is excluded from Godot imports.
