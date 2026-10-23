# Skeleton Warrior — static master proposal

Status: **static master awaiting human approval**. Animation not begun; engine import and runtime unverified. This is the Skeleton Warrior contribution to the full Necropolis collection, with only its master delivered at this gate.

Review [source-vs-master.png](source-vs-master.png) for the native/shared-scale comparison and [alpha-review.png](alpha-review.png) for light, middle and dark background inspection. The selected artwork is [master_rgba.png](master_rgba.png); registered right-facing output is [master_source_1024x768.png](master_source_1024x768.png), with an exact [mirror](master_mirror_1024x768.png).

## Source and visual review

The original `H3sprite/CWSKEL.def` contains 15 groups, 86 timeline frames and 57 distinct indexed drawings; the complete inventory remains in [job.json](job.json). Source DEF and metadata hashes match the job, and the metadata groups exactly match its embedded native records. The master follows idle G2 F0, `cwskel57.pcx`.

Inspected the enlarged native idle, shared-scale guide, all-groups contact sheet, and detailed guides G1 (F0/5/10), G2 (F0/4/7), G4 (F0/5/10), G7 (F0/1), G12 (F0/4/7). These are static samples, not playback of all 86 frames. Group role names remain format mappings rather than verified game behavior.

Observed identity: lean pale skeletal limbs, empty sockets, single pointed dark helmet, muted violet-gray torso armor, dark flared boots, straight sword lowered across the legs, and a small bronze-rimmed shield held obliquely. The native right-facing idle governs the pose and equipment. Pikeman informed fine modeled shading and textured material finish only.

Mali review corrected the first render's invented forearm bracer and impossible hand through the shield boss, then narrowed the shield perspective. Attempt 3 is the selected proposal. Pale bone, violet steel, bronze rim and dark boots remain distinguishable at shared scale; no background, floor, cast shadow, labels or invented VFX are visible in the selected asset. Light/middle/dark previews show open alpha gaps without an obvious opaque fringe.

## Registration and provenance

The shared 180/73 calibration maps native idle alpha height 86 to **212 px**, not 180 px. Standard uniform registration was used without override or stretching: actual alpha bounds `(462,297,101,212)` in the 1024×768 cell; native-derived target `(460,297,104,212)`. The narrower width preserves the generated aspect ratio. Ground-contact bottom is 509, following the native offset from common anchor `(512,512)`.

Selected raw: [raw/generated-attempt-03.png](raw/generated-attempt-03.png), SHA-256 `eac2644fb7cb167134a727075de8cd62f58ff58e09cbf822eda7f7403891dbdf`. All three raw outputs and superseded comparison previews are preserved. [tool-submissions.json](tool-submissions.json) retains exact built-in Imagegen arguments, prompts and output paths/hashes; [generation-provenance.json](generation-provenance.json) includes reference hashes and selection history. Human-readable prompts are `prompt-attempt-01.txt` through `03.txt`.

## Actual limits

The 86-pixel original cannot resolve every seam, rivet or boot construction: these are generated interpretations. The master has denser armor wear and slightly different local contours than the native; it is not a pixel-exact reconstruction. Native gameplay motion, timing, animation continuity, collisions and runtime appearance were not reviewed. Mechanical alpha/registration/mirror evidence establishes file properties only. Human approval remains required before animation work.
