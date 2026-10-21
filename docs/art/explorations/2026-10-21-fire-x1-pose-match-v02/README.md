# Fire X1 v02 — final-pose follow-through correction

User correction on October21: the final pose should finish a right-to-left swing with the blade passing behind the left thigh. The v01 candidate incorrectly presented a hanging blade in front of the trousers. This revision changes only frame4. It is a review candidate, not user-accepted final art or an integrated game asset.

## Result and scope

- Sword/wrist follow-through revised to carry the blade diagonally back-left behind the left thigh; the trousers occlude the crossing blade section.
- Frames1–3 copied byte-for-byte from v01, verified with SHA-256. All four cells retain448×448 format and anchor(224,400).
- Frame4 alone is a complete newly generated edit. v01 remains preserved. Other moves, runtime assets, source, timings and hitboxes are unchanged by this Art revision.
- Native atlas: [fire-x1-4x448.png](fire-x1-4x448.png),1792×448.
- [Enlarged animation review](fire-x1-detail.gif), [transparent preview](fire-x1-preview.gif), [original comparison](original-vs-laema-x1.gif).
- [Final-pose close-up](last-frame-closeup.png) and [before/after](last-frame-before-after.png).
- [Exact prompt](prompts.json), [export metadata and unchanged-frame hashes](metadata.json).
- Raw generated final pose and edit/reference inputs are preserved in this folder.

## Method and evidence

Built-in image generation performed the artwork edit. The edit target was a padded crop of v01's high-resolution fourth pose; the original fourth sprite was a supporting reference. The generated square canvas was uniformly mapped to the768px reference canvas, then exported using v01's sequence scale and boot-root translation. No painted pixel repair, body warping, or new interpolation was used.

Static inspection confirms the thigh now covers the blade rather than a metal stripe being drawn over its front. Native alpha bounds clear the cell border. Three output GIFs were reopened and decoded as four frames with infinite looping. Frames1–3 PNG bytes match v01. This is not continuous playback, Godot/import/build/test/runtime evidence.

Prior v01 limits carry forward: source-cropped boots/tips were completed by inference; fine anatomy, equipment continuity, exact sword angles and joint positions remain approximate. This revision addresses the user's specified final-pose layering/follow-through, not a claim of a complete exact reconstruction. Preview cadence remains slowed review timing560/360/310/580ms, not gameplay authority.

No integration, other-move edit, canonical-document change, commit, push or publication was performed. This study folder is excluded from Godot imports.
