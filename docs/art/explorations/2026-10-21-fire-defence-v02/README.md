# Fire sword-and-shield defence studies — 2026-10-21

Status: five Fire-school parry motion proposals, created after the user corrected the active stance to sword and shield. On October 21 the user selected candidate 1, Shield Catch, for refinement; see [the versioned refinement](../2026-10-21-fire-shield-catch-refined-v03/README.md). No candidate is runtime-integrated by this Art work. This set supersedes the mistaken hammer-based defence-v01 set for the current request, not any other school's appearance.

## Candidates

1. Shield catch — compact shield-led interception.
2. Sword deflection — rising sword-led interception with the shield retained.
3. Sword over rim — coordinated sword and shield presentation.
4. High shield — raised shield deflection.
5. Low shield sweep — lower-centre shield deflection.

These are alternative presentations of the existing Fire parry, not five new abilities. No sustained block, counterattack, additional reward or new defence rule is approved here.

## Current reference and authority

The user's latest correction and `assets/prototype/player/fire_sword_shield_v01/PROVENANCE.md` establish the current prototype sword-and-shield direction. Current Idle/Walk/Hurt/Cast are v01; current X1–X5 use the v03 plain-sword angle studies under `angle_proofs_v03/`. The generation used crops from the actual current Idle and v03 X1 sheets.

Preserve Laema's white ponytail, cream rolled sleeves, blue vest, red sash, brown trousers/boots/gloves, plain steel sword and small round navy shield with steel rim and boss. Original Heroes III material/rendering remains the style reference; these are generated interpretations, not original Heroes III sprites or final Laema art. Older hammer direction in other records does not override the current Fire-specific correction.

## Deliverables

- `defence-five-motion-comparison.gif`: five motions side by side, 1440×370, common review cadence.
- `defence-five-guard-poses.png`: static pose comparison.
- Each candidate folder: original generated 1536×1024 six-pose sheet, six transparent 448×448 PNG frames, 2688×448 horizontal flipbook, transparent 448×448 looping GIF, and export metadata.
- `manifest.json`: source IDs, dimensions, root alignment and review timings.
- `prompts.json`: exact selected prompts and source provenance.

Export matches the current Fire canvas convention: 448×448 cells, foot anchor (224,400), target standing body approximately 180px. One shared scale per candidate and per-pose root translation were applied; neighbouring fragments were isolated mechanically. Five distinct source poses are used, followed by the opening pose as the sixth endpoint. The unused generated sixth pose is preserved in each raw source sheet. No interpolated or rigged animation is claimed.

Individual GIF cadence is 220/90/90/70/120/300ms. The side-by-side comparison uses a slower common review cadence. Neither is engine timing or balance authority.

## Verification and limits

All five GIFs were reopened and checked for 448×448 dimensions, six frames and infinite looping; each export has five unique poses. Static strips and pose comparison were visually inspected. No exported source-cell boundary contacts were detected. Live GIF playback and Godot runtime validation were not performed.

These are rough motion studies: face, grip, sword/shield proportions, garment and body continuity still need cleanup. Canvas compatibility does not make them production-ready. No gameplay, resource bindings, hitboxes or runtime timing were changed. The older hammer set is retained only as a superseded study. This folder is excluded from Godot import.

Created with built-in image generation; deterministic slicing/alignment/GIF export used the Art task helper `build-fire-defence-v02.py`. No API-key generation, commit or publication was performed.
