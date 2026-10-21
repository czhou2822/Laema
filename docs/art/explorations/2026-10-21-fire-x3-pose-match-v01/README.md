# Fire X3 original-pose reskin candidate — 2026-10-21

Status: review candidate from the user-authorized parallel art pass, not accepted final art or integrated gameplay.

## Authority and intent

The user rejected the current avatar attacks as unlike the originals and requested the same poses and sword paths. Original choreography comes from git revision `9f9d9bba`, native `config/attack_animations/fire_x3.tres`, then pointing to `assets/prototype/player/animation/earth_x3.png` after the historical Fire/Earth visual swap. There are exactly four source poses.

The original is not a generic forward-ready sequence. Its first two frames place the sword behind/left at low chest level, first almost horizontal and then angled slightly up-left. The torso then rotates right, placing the shield behind/left and carrying the sword low forward-right through slash and follow-through. The white tip arcs appear in the third frame only. Those gestures govern this candidate; the current generated attacks were not used as pose references.

Avatar appearance alone comes from current Fire shared Idle: white ponytail, cream sleeves, blue vest, red sash, brown clothes/gloves/boots, plain steel sword and small round navy shield. Decorative hilt details in that appearance reference were not adopted.

## Files

- [Original-versus-Laema GIF](original-vs-laema.gif): synchronized four-pose review.
- [Four-pose comparison PNG](original-vs-laema-poses.png).
- [Native transparent GIF](preview.gif), 448×448.
- [Enlarged review GIF](detail-review.gif), fixed crop with grey background.
- [RGBA atlas](fire-x3-pose-match-4x448.png), 1792×448; four 448×448 cells.
- `frame-01.png` through `frame-04.png`.
- `source-four-poses-selected.png`: selected built-in imagegen elbow-repair result.
- `source-four-poses-initial.png`: preserved first generation.
- `original-x3-128-atlas.png` and `original-pose-reference.png`: exact original atlas and mechanically enlarged/padded input guide.
- `prompts.json` and `metadata.json`: exact prompt lineage, crops, original key times and export verification.

One shared scale per generated sequence targets approximately180px body height, foot anchor(224,400). Per-pose root translation, full-pose crops and GIF conversion are mechanical; artwork was not repainted with Python. The generated third pose crosses the conceptual grid boundary, so its full blade/trail is preserved using an expanded crop rather than clipped to the nominal cell. No extra in-between or idle-return poses were inserted.

Review durations560/360/300/280ms reflect slowed original pose cadence, not authoritative gameplay timing. No native animation/resource/hitbox/duration change is made.

## Fidelity and evidence limits

The pose sequence and broad blade directions now follow the original, rather than a substitute overhead/thrust attack. A targeted second imagegen pass bends the first two sword-arm elbows downward toward the original reference. This is nevertheless an AI-derived reinterpretation, not pixel-exact tracing: limb/torso proportions, shoulder rotation, foreshortening, shield/hand/face/garment continuity and blade-tip placement remain review limits. The original's lower legs and some tips are cropped; newly completed boots and hidden details are inferred.

All saved GIFs were reopened and decoded as four frames with infinite looping. PNG/atlas dimensions, alpha-bearing source, unique native poses and clear final canvas margins were checked. The four-pose comparison was visually inspected. No live continuous playback, Godot import/editor/runtime/build/test evidence exists. No runtime assets, source/configuration, canonical records, staging, commits or publication were changed.
