# Wraith remaster v01 delivery

Status: **COMPLETE — worker asset review; awaiting parent independent checks and human motion acceptance**. The parent explicitly cleared full production after the earlier preparation snapshot. This report supersedes its waiting status. Original source is `H3sprite/CWRAIT.def`; appearance remains the approved Wraith master, SHA-256 `b319f9536813d002cb7832c739a4ed840ac5c61968fa474335b5233d9689c33d`.

## Coverage and usable outputs

**57/57 source poses; 18/18 groups; 102/102 timeline positions; zero missing poses.** All 57 selected poses are newly drawn through built-in imagegen; zero approved-master reuses, original-pixel upscales, idle fillers or code-warped masters. Eleven artwork calls produced 71 figure drawings, including 14 replacement drawings across 13 source IDs. All raw pages, exact submitted prompts, actual reference hashes, returned output-path metadata and previous selection records are retained.

Outputs are under `assets/prototype/enemy/wraith/remaster_v01/`: 57 registered source poses plus 57 exact mirrors, 18 source and 18 mirror atlases, 204 source/mirror timeline-frame PNGs, 36 review GIFs, 18 original/candidate group contacts, complete `source_manifest.json`, and `original_groups.tres` / `original_groups_mirrored.tres`. Both libraries contain 18 groups and 102 positions. Fixed geometry remains 1024 x 768, four columns, anchor (512,512), source reference (196,268), scale 180/73 and native alpha >160 bounds; no independent action normalization or stretching was introduced.

All source ordering, repeats, shared hurt/death entry drawings and six exact alias pairs are retained: **7=9, 8=10, 11=14, 12=15, 13=16, 20=21**. Turn exits preserve the reversed two-pose order. G01/G04 retain their four-position holds. G14-G16 are original attack aliases, not invented ranged behavior. Slots 6 and 17-19 are absent in this original.

## Actual review and repairs

Inspected every raw page, all 57 original/source-pose comparisons at 1.5x registered size, all 18 helper group contacts, every source-ordered frame in both facings at registered size, and every stored frame decoded from all 36 GIFs. GIF frame montages retain stored durations, including the 400ms merged holds. This was static frame and transition inspection, **not animated playback**. Reviewed entries, exits, turn order, repeat holds, skull view, two-arm anatomy, fingers, robe direction, collapse/fragments, white claw strokes, alpha and framing.

Mali's source-comparison review drove targeted redraws instead of accepting extraction alone. Repair A corrected p008-p011 gesture height, p017 recoil length, p020 raised-arm layout, p026 defence height and p033 near-frontal turn. Repair B corrected early death p027's stray speck, p035 shoulder-level windup, p036 hidden-face rear turn, p037 long rear silhouette and p054's crouched camera. Repair C replaced p020 again after the intermediate page introduced a red mouth absent from that recoil original. Valid figures from other pages were retained; every dependent group was rebuilt. Initial comparison sheets and prior pose-selection metadata remain recoverable. No blocking anatomy, clipping or order defect remained in this worker review; the redraw is an interpretation, not pixel-identical source motion.

## Transparency and native features

Native references use the agreed alpha >160 body interpretation, excluding exported palette shadows; it is not proof of original-engine alpha/compositing. Wraith's observed death is cloth collapse plus progressively detached fingers/bones/skull, ending in a low heap. Those forms remain distinct drawings with transparent gaps; they were not replaced by an intact idle or an invented uniform fade. No additional engine dissolve, dither shader, fog, particle system or projectile was inferred. Original white curved claw streaks and pale hand-motion patches remain embedded in their corresponding attack poses; the red face patch belongs to G01 only.

Generated pages retain actual alpha, including antialiasing. Some near-transparent RGB values can look brightly colored in a raw diagnostic display: on the initial death page, 5,596 strongly red RGB pixels had alpha only 1-4 and none exceeded alpha 16. Raw bytes were preserved; properly composited registered reviews do not show a new red death effect. This is a generated-alpha observation, not a claim about source-engine effects.

Default rectangular ingestion rejected three pages for missing full-page gutters. Their unmodified raw submissions were preserved and strict component isolation then passed. Seven artwork pages used the approved installed component path; the others used Pillow gutters/single-pose ingestion. No dependency was installed, count/clipping check weakened, source anatomy repaired by code or component grouping invented manually.

## Verification and handoff

Ran **build → validate → spriteframes → final validate** after recording all 57 worker reviews. Both validations returned complete coverage, 102 atlas positions verified, no missing pose IDs and no errors. An additional asset readback verified all 204 frame PNGs against their selected pose/exact mirror, 57 distinct registered pose hashes, current review hashes, all raw copies against actual tool output bytes, reference/prompt hashes and library references. Details: `validation-results.json`, `visual-review.json`, `pose-review-notes.json`, `generation-attempts.json`.

Existing isolated artwork can be repacked locally with the shared helper and Pillow; build was run without the optional dependency overlay. The complete checkout's plan and native reference files remain required. No local drawing model, offline cloud-generation reproduction or separately assembled portable ZIP is claimed; the parent owns package assembly/publication. Preview speed is 10fps for review only; original timing remains unknown. No browser, Godot/import/runtime, human motion acceptance, gameplay change, Git operation or peer message was performed. Writes remained in the assigned Wraith asset/report folders.
