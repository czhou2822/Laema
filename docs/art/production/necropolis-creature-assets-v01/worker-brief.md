# Dedicated creature worker contract

The user requested the **complete** Necropolis collection, correcting a
defence-only interpretation. Each worker owns exactly one creature folder.

This phase is the **static master approval gate**. Do not generate animation
frames until the human approves the masters. No engine imports, implementation,
gameplay changes, tests/builds/editor/runtime runs, Git operations or peer messages.

Read the installed Mali and imagegen Skills fully and their relevant references;
Mali is already the accepted active Art operation. Read current AGENTS.md,
docs/art/ART_DIRECTION.md, and the physical Mali personal profile before artistic
judgment. Preserve source originals and approved Castle packages unchanged.

Read your job.json completely. Inspect native-idle-6x.png, native-all-groups-contact.png
and relevant native-gNN-guide.png files with view_image, plus actual native source
metadata. Inspect ../references/pikeman-rendering-master.png before generation.
It supplies fine modeled-volume rendering ONLY, not Necropolis costume or color.

Preserve the original creature identity, silhouette, costume, anatomy, weapons,
materials, upgrade distinctions, native idle pose and original facing. Prefer
source evidence over generic fantasy tropes. Genuine transparent full-body cutout,
all props visible, generous margins. No text, floor shadow, extra props, VFX,
cartoon block pixels, chibi proportions, inflated armor or invented redesign.

Use the **built-in image workflow** for all invented/redrawn art, one requested
master per call. No API/CLI fallback. Inspect generated output and correct concrete
identity, pose, anatomy or material failures with targeted imagegen edits; preserve
raw attempts and exact prompts. Never pass upscaled original pixels off as new art.

Registration: 1024×768 transparent cell; anchor (512,512), original reference
(196,268); shared 180/73 source-relative scale. Do not force all creatures to 180px
height. Do not independently normalize horns/weapons/flight/crouches. Use uniform
aspect-preserving registration. Mechanical crop/scale/export with Node/sharp is
allowed; apply_patch for local scripts/docs edits.

The parent-owned read-only tools/lib.cjs exports root, sharp, fs, path, job, json,
sha, alphaBounds, cropRect, label, and async registerMaster(slug,input,provenance,options).
Default registration uses native silhouette height/center/bottom. If an anatomy
measurement requires a justified override, document it; never stretch the artwork.
Call this helper from a small build-master.cjs in your own creature folder.
It creates master_rgba.png, master_source_1024x768.png, master_mirror_1024x768.png,
source-vs-master.png, and master-manifest.json. Inspect those comparisons too.

Deliver report.md and visual-review.json with actual identity/material observations,
source groups/frames, sampled groups, exact prompt/tool path/hash provenance,
chosen raw result, visual checks and limitations. Generated masters remain proposals
awaiting human approval; animation production has not begun; runtime is unverified.

Write only your assigned creature folder. Shared helpers, indexes, other creatures,
original references, canonical docs and game files are read-only to you. Other
agents work concurrently; never revert their changes.
