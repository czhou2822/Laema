# Fire X2 v07 — blade tip behind the left side

Latest explicit user correction: the v06 shield is correct; the blade is not, and its tip must be behind the left side of the body.

User-confirmed scope: retain v06 shield placement. Open: review this v07 sword-depth candidate. No final pose/art or integration approval is inferred.

This edit removes the diagonal metal stripe from the front of the torso/belt/sash. The middle blade is occluded by the body; the point emerges behind the left/rear hip edge. The raised grip and shield placement are visually retained. Complete pose1 was generated, so unchanged shield pixels are not certified; poses2/3 PNGs are byte-identical to v06 and v01.

## Review

- [Opening close-up](first-frame-closeup.png), [before/after](first-frame-before-after.png)
- [Original versus candidate opening](opening-pose-original-vs-laema.png)
- [Updated animation](fire-x2-detail.gif), [original comparison GIF](original-vs-laema-x2.gif), [transparent preview](fire-x2-preview.gif)
- [Three-pose comparison](original-vs-laema-x2.png), [transparent atlas](fire-x2-3x448.png):1344×448, three448px cells, root(224,400)
- [Exact prompt](prompts.json), [metadata](metadata.json), original source/reference and raw edit target retained

Built-in image generation performed the sword-depth edit using v06 as the sole target. Mechanical assembly uses one uniform full-source scale and translation to180px native body height, then the established native canvas export. No blade painting, articulated warp, new in-betweens or gameplay timing change.

Three native unique frames, alpha margins and three-frame looping GIF decode checked. Opening close-up inspected. Pose2/3 bytes verified. No continuous playback, Godot/import/editor/build/test/runtime validation. Exact original joint/path matching, projected hidden blade length and material consistency remain review limits; missing original boots are inferred and pose2's white crescent remains thicker than source.

Prior studies preserved. Only this Art exploration was written; no runtime assets/bindings, gameplay, other moves or canonical records changed. No staging/commit/push/publication. Folder excluded from Godot imports.
