# Fire X2 v04 — far-side starting shield

The user's October21 correction identified that the opening shield, not just the blade, starts behind the body and is not fully visible. Earlier blade-only revisions left a full front-facing shield face, so they did not address the upper-body depth relationship.

This review revision redraws pose1's upper-body turn, shield placement and arm overlap. The shield remains its physical round shape but is tucked on the far side, with a partial navy rim/face visible and the center boss occluded by torso/arm. The lower sword blade remains visibly down-left behind the thigh. This is a new review candidate, not final visual acceptance or runtime integration.

## Review and files

- [Opening close-up](first-frame-closeup.png)
- [Original versus revised opening](opening-pose-original-vs-laema.png)
- [Previous versus revised](first-frame-before-after.png)
- [Enlarged X2 animation](fire-x2-detail.gif), [original comparison GIF](original-vs-laema-x2.gif), [transparent preview](fire-x2-preview.gif)
- [All three original/new poses](original-vs-laema-x2.png)
- [Transparent atlas](fire-x2-3x448.png):1344×448 with three448px cells, root(224,400)
- [Exact prompt](prompts.json), [metadata/checks](metadata.json), raw generated source and edit/reference inputs

## Method and limits

Built-in image generation performed the pose1 artwork edit using v03 as the edit target and the original X2 first pose as motion/depth authority. This is an occlusion/foreshortening correction, not merely a smaller shield. Mechanical export retains the established fixed724px reference-canvas scale and boot-root translation. No painted repair, warped anatomy or added in-betweens.

Poses2/3 are byte-identical to v03 and v01, verified with SHA-256. Native PNG margins/three unique poses and three-frame looping GIF decode checked. Opening comparison and close-up inspected on grey. No continuous playback, Godot/editor/import/build/test/runtime verification.

Pose1 anatomy, exact stance dimensions, shield silhouette, grip/guard and face continuity remain approximate; retaining the same canvas scale does not make generated geometry pixel-locked. Original lower legs were cropped, so completed boots are inferred. The unchanged pose2 crescent is still thicker than source. Slowed680/440/380ms preview timing is not gameplay timing.

v01–v03 remain preserved. Only this exploration was written: no runtime source/assets/bindings, other moves, gameplay/hitboxes/tuning or canonical records were changed. No staging/commit/push/publication. Folder excluded from Godot import.
