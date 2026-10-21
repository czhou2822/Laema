# Fire X2 v06 — fresh OG-reference opening

The user rejected v05 and explicitly directed us back to the original flipbook. This pass rebuilds the opening pose from the original first frame rather than continuing edits around the avatar's low waist grip.

## Reference and change

Motion authority is the original Fire X2 at Git9f9d9bba, which references the historical swapped `assets/prototype/player/animation/earth_x2.png`. The original first pose has a higher cross-torso sword arm and a forward wrist, with a short projected blade angling down-left toward the upper thigh. The prior avatar's low grip forced misleading blade geometry.

The original first frame was the image edit target. The current shared Idle crop supplied appearance/material only; the complete original three-frame sheet supplied movement context. A follow-up shortened the first generated blade and tucked the shield farther behind the torso/arm. Only opening pose1 is replaced; pose2/3 PNG bytes match v05 and v01.

This is a fresh review candidate, NOT an accepted exact pose trace. Shoulder/wrist reach, torso rotation, shield overlap and blade projection still require comparison. Its generated rendering is coarser than the retained second/third poses; style and material continuity remain open. Missing original lower legs/boots are inferred.

## Review files

- [OG and fresh opening side by side](opening-pose-original-vs-laema.png)
- [Opening close-up](first-frame-closeup.png)
- [OG versus new animation](original-vs-laema-x2.gif), [enlarged animation](fire-x2-detail.gif), [transparent preview](fire-x2-preview.gif)
- [All original/new poses](original-vs-laema-x2.png)
- [Native transparent atlas](fire-x2-3x448.png):1344×448, three448px cells, root(224,400)
- [Exact prompts](prompts.json), [metadata/checks](metadata.json), original reference and appearance crop, selected/raw first generation, uniformly registered source

Built-in image generation produced the new artwork and targeted follow-up. Mechanical export applies one uniform full-source scale and translation to180px body height before the existing native canvas export; no articulated warps, blade painting or new in-betweens. The original reference comparison is approximate upper-body registration, not a claim about missing original feet.

Three unique frames, native alpha margins and three-frame looping GIF decode checked. Opening comparison and close-up inspected. Frames2/3 verified byte-identical. No continuous playback, Godot/editor/import/build/test/runtime evidence. Review cadence680/440/380ms remains slowed inspection timing, not gameplay timing.

v01–v05 preserved as prior studies; v06 is not automatically approved. No runtime resources/assets, bindings, gameplay, other moves or canonical records changed. No commit/push/publication. Folder excluded from Godot import.
