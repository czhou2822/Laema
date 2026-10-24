# Alternatives after the local editing tests

**Proposals and feasibility assessment only. No propagation or rig was executed.** The tested high-strength mask can leave an incomplete figure inside the permitted region. Restricting edit locations is not equivalent to conditioning the model on the correct anatomy.

## Approved keyframes plus propagation

The recovered master establishes the previously approved prototype appearance. It is not a high-resolution painting registered to each exact original pose. The missing prerequisite is a user-reviewed style keyframe aligned to its corresponding source guide, with compatible body, hands, pike and camera.

EbSynth's documented interface accepts a style image and source/target guide pairs. Its examples also use segmentation and positional guidance; it does not automatically solve this project's master-to-source pose mismatch. [Primary implementation and examples](https://github.com/jamriska/ebsynth).

**Proposed bounded test:** approve source-matched ready and thrust paintings first; add a transition painting where visibility or grip changes require it. Use the original six drawings as target guides, keep the shared canvas/pivot, and cache the four repeated poses. Judge disoccluded hands, face, cloth, weapon and shadow separately. The standing master alone should not be advertised as an already aligned propagation keyframe. This prerequisite assessment is an inference from the recovered files and documented guide-pair interface, not an executed EbSynth result.

No EbSynth command was found on PATH in the local probe. Its official repository provides Windows build scripts and a linked binary, so absence from PATH is not a claim that the computer cannot run it. Installation and a valid aligned-keyframe trial remain future work.

## Deterministic 2D pose-matched rendering

**Proposed test:** split an approved source-matched character into stable torso/head/limb artwork and a rigid pike layer; explicitly author the six source poses, including hand placement and draw order. Export the original ten positions using the exact repeat map. Do not replace original poses with interpolated motion or independently center each export.

The feasibility advantage is explicit control of placement, weapon geometry and reused material. Occlusions, forearm turns and foreshortening still require alternate drawings or paint corrections. The recovered flat PNG master is not proof that a usable layered rig already exists.

Spine documents transparent PNG sequences, FPS and an include-last-frame option. A future export must retain all original frame positions and repeats instead of dropping an ending pose automatically. Its FPS setting would remain a comparison schedule until original dwell is recovered. [Primary export documentation](https://esotericsoftware.com/spine-export).

## Deterministic 3D pose-matched rendering

**Proposed test:** build or select an approved character and rigid pike, calibrate camera/lighting against the original source, then match one authored render to each of the six original drawings. Keep source offsets, anchor, frame mapping and timing metadata outside the renderer. Original exaggerations and projected appearance should drive the match rather than generic motion capture.

A stable mesh/material can reduce repeated reinvention, but source-faithful camera matching, hands, proportions and costume are substantial authoring work. No approved mesh, calibrated camera or layered source-pose rig was found in the recovered packages. This is a feasibility proposal, not evidence that a rig will look better or cost less.

The scoped local probe found no Blender, Spine, EbSynth, ImageMagick, FFmpeg, Inkscape or Aseprite command on PATH, and no matching DCC directory in the inspected standard Program Files/Local Programs roots. This is not an exhaustive application registry audit. No rigging software was installed as part of these tests.

## Next quality gate

Keep restoration as the fixed source control. Ask the user to review the completed editing comparisons before selecting a faithful pose-matched high-resolution keyframe treatment. Then test propagation or a rig on this same group if needed. Measure artist work to an accepted frame/group; the current bounded repair attempt does not establish that cost. Do not expand the roster from a successful still.
