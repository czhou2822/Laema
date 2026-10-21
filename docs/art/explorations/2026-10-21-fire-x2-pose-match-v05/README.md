# Fire X2 v05 — blade-axis adjustment

The user accepted v04's shield-depth direction and asked for a small blade adjustment because the sword appeared to bend behind the thigh. This candidate makes the exposed lower blade steeper down-left, aiming for a straighter continuation from the grip through the occluded section.

Only opening pose1 is a new image edit. Poses2/3 PNG bytes match v04 and v01, verified by hashes. The partial far-side shield and behind-thigh blade depth are retained. This remains a review candidate, not final acceptance or runtime integration.

## Review files

- [Opening close-up](first-frame-closeup.png), [before/after](first-frame-before-after.png)
- [Updated animation](fire-x2-detail.gif), [original comparison](original-vs-laema-x2.gif), [transparent preview](fire-x2-preview.gif)
- [Three-pose comparison](original-vs-laema-x2.png), [transparent atlas](fire-x2-3x448.png):1344×448 with three448px cells, anchor(224,400)
- [Exact prompts](prompts.json), [metadata and checks](metadata.json)
- Raw selected generation, earlier straightness attempt, previous edit target, original pose reference and registered source retained.

Built-in image generation performed two targeted straightness passes. The first left the tip drifting outward; the follow-up moved the exposed tip inward to steepen the visible blade. Straight continuation is assessed visually, not established by an exact skeleton/3D projection. Fine grip/guard geometry and generative body/face continuity remain review limits.

The generation enlarged its framing. Mechanical export therefore applies one uniform whole-figure scale and translation to restore the previous180px body height before the unchanged X2 native export scale. No blade-only geometric warp, articulated pose fitting or painted repair was used. This source-registration transform is recorded explicitly; preserving canvas dimensions alone would not have preserved the character scale.

Native alpha margins, three distinct frames and three-frame looping GIF decode checked. Opening close-up and before/after were statically inspected. No continuous playback, Godot/import/editor/build/test/runtime verification.

The original source's cropped boots remain inferred, exact joints remain approximate, and the unchanged pose2 crescent is still thicker than source. Slowed680/440/380ms GIF cadence is review timing, not gameplay timing.

v01–v04 preserved. No runtime assets/bindings, gameplay, other moves or canonical records changed; no staging/commit/push/publication. This folder is excluded from Godot import.
