# Pikeman sprite assets v01 — first static idle master

Status: first actual transparent sprite asset, exported for inspection. The complete animated replacement has not been produced.

## Delivered

- [pikeman_idle_master_rgba.png](pikeman_idle_master_rgba.png): high-resolution, cropped RGBA sprite master with genuine alpha.
- [idle_right_frame_00.png](idle_right_frame_00.png): one right-facing idle frame.
- [idle_left_frame_00.png](idle_left_frame_00.png): its exact mirrored left-facing counterpart.
- [idle_asset_preview.png](idle_asset_preview.png): exported frame at the180px standing-body target on light and dark mattes.
- manifest.json: source paths, crop/body landmarks, frame registration, hashes and alpha checks.
- export-idle.cjs: reproducible mechanical normalization/export.
- PROMPTS.md: actual built-in generation and transparency-cleanup prompts.

## Working frame contract

Both direction exports are768×512 RGBA PNGs with feet anchor at(384,448). The manually identified helmet-crown-to-lowest-sole span is normalized to180px. Pike tip and shaft are included in the same asset; the canvas includes side margins for future action poses.

Current frame count is ONE. Do not treat this as a7-frame idle sheet or copy it over the existing imported Idle.png. The existing runtime uses450×400 cells/four columns and seven idle frames; this proposed new frame contract requires an explicit sampler/registration integration once the animation set is ready.

The180px value describes the artwork at1:1 pixel display. Existing node/camera scaling must be taken into account by DUM-E when integrating; this asset export does not change those settings or collision geometry.

Source stance faces left. A right-facing export is supplied to match the original runtime's default-facing convention; preserve the chosen direction/flip convention consistently.

## Authority and provenance

The user selected environment/framing option05, requested a clearer enlarged Pikeman, corrected the omitted metal helmet, rejected a bright-silver helmet and accepted the darker brown-bronze colour as better. This first sprite retains that corrected helmet, blue/white clothing, metal shoulder protection, boots and held pike.

This is a generated reinterpretation based on the approved mockup, which in turn uses the original Heroes III Pikeman as its visual reference. Fine detail, crest and facial construction are interpreted, not recovered original pixels or new original-game evidence. It remains subject to user visual acceptance.

The generation source is retained unchanged at:
C:\Users\zhouc\.codex\generated_images\01a07f41-7159-70f1-ac7d-e6217941c130\exec-7c92379e-0cb2-44a2-a89b-4c4e59ad96c1.png

The selected framing reference is:
C:\Users\zhouc\.codex\visualizations\2026\09\08\01a07f41-7159-70f1-ac7d-e6217941c130\town-edge-yard-framing-round-02\mockup-05.png

The actual colour-corrected reference used for extraction is:
C:\Users\zhouc\.codex\visualizations\2026\09\08\01a07f41-7159-70f1-ac7d-e6217941c130\pikeman-resolution-study-v01\07-helmet-colour-corrected-mockup.png

Original Heroes III reference images and existing game assets were not edited.

## Checks performed

- Source/export PNG decoding and real alpha-channel inspection.
- Transparent exterior, opaque interior and antialiased edge inspection on light and dark mattes.
- Zero visible pixels on the exported frame borders; pike and boots remain inside the canvas.
- Shared anchor and exact left/right mirror export.
- Pixel dimensions and SHA-256 hashes recorded.
- Full source, actual-size frame preview and dark/light mattes visually inspected.

Alpha export tidying is documented in manifest.json: near-invisible stray alpha<=2 is cleared, generated interior alpha>=240 becomes fully opaque, and normal intermediate silhouette alpha is retained. The original generated source is preserved separately.

No idle motion, walk/attack/hurt/death animation, temporal consistency, Godot/editor run, collision behavior or in-game visual acceptance is claimed. No product files, imports, scenes, code, timing or hitboxes were changed.

## Remaining animated set

Existing source coverage is7 idle,6 walk,10 front-thrust,6 hurt and5 death frames:34 frame slots. Build those using the preserved original pose order and the new master as the consistent character guide. Check identity, bronze helmet colour, pike continuity, limb volumes and feet registration in playback before calling the set ready. A single polished PNG does not establish that whole animation pipeline.

Implementation remains with DUM-E after a usable set or a specifically authorized static preview. Do not hand off this single frame as a finished combat-enemy replacement.

