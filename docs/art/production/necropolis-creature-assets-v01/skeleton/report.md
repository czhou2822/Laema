# Skeleton — static master review

Status: **static master awaiting human approval; animation not begun; runtime unverified.** This is the basic Necropolis Skeleton (`CSKELE`), one creature within the full-collection operation. The complete native inventory is recorded for continuity; no replacement animation frames were generated.

## Reviewable files

- [Source versus master](source-vs-master.png): original and generated artwork at the shared display scale, plus enlarged inspection.
- [Light/dark alpha review](alpha-review.png): enlarged and actual 192 px visible-height crops, mechanically composited over two review colors. These backgrounds are not in the master.
- [High-resolution RGBA master](master_rgba.png): 830 × 1594 px alpha-bound crop of newly generated artwork.
- [Registered source](master_source_1024x768.png) and [exact horizontal mirror](master_mirror_1024x768.png): transparent 1024 × 768 cells.
- [Visual review](visual-review.json), [master manifest](master-manifest.json), and [generation provenance](generation-provenance.json).

## Native evidence and artistic observations

Read the complete `job.json`; examined the original `CSKELE/metadata.json`, group/frame names and page layout, and verified its SHA-256 and the original DEF SHA-256 against the job. The source has **15 groups, 86 timeline frames, 57 distinct indexed drawings**. The selected identity/pose authority is G2 F0, `cskele57.pcx`, within a 450 × 400 native cell. Its trimmed frame metadata is 44 × 80 at (175,188); actual alpha64 bounds are 42 × 78 at (176,189).

Visually inspected `native-idle-6x.png`, the complete `native-all-groups-contact.png`, and G1, G2, G4 and G12 guides. The guides show first/middle/last samples: G1 F0/F5/F10, G2 F0/F4/F7, G4 F0/F5/F10 and G12 F0/F4/F7. The contact sheet supplies one representative view for each of all 15 groups. This is static sampling, not a full frame-by-frame or moving-animation audit.

Observed identity: bare adult human bones; small right-facing skull with dark empty sockets; narrow, forward-leaning ribcage; exposed pelvis and long slender leg bones; bent near arm holding one sword low behind the hip; opposite empty hand forward; slightly bent knees and spread bony feet. The native blade descends diagonally toward screen right. Bone is muted ivory/yellow-gray with olive-gray recesses. The sword has pale metal edges, a modest warm gold/brass hilt and a tiny blue-violet grip accent. There is no shield, helmet, armor, clothing, second weapon or native magical glow in the inspected samples. My preliminary progress message mentioning a shield was an error and did not enter the artwork.

Inspected `../references/pikeman-rendering-master.png` for rendering only. Mali's project/source precedence kept the Necropolis identity and palette; the rendering reference guided fine modeled volume, worn surface texture, concentrated highlights and readable materials. No Castle costume, colors, helmet or weapon were transferred.

## Source inventory

Role names below are source-format mappings, not engine/timing verification.

| Group | Format mapping | Timeline frames | Distinct within group |
| --- | --- | ---: | ---: |
| 0 | movement | 8 | 8 |
| 1 | gesture / mouse-over | 11 | 4 |
| 2 | idle | 8 | 5 |
| 3 | hit reaction | 6 | 6 |
| 4 | defence | 11 | 4 |
| 5 | death | 6 | 6 |
| 7 | turn | 2 | 2 |
| 8 | turn | 2 | 2 |
| 9 | turn | 2 | 2 |
| 10 | turn | 2 | 2 |
| 11 | melee upper | 8 | 8 |
| 12 | melee front | 8 | 8 |
| 13 | melee lower | 8 | 8 |
| 20 | movement start | 2 | 2 |
| 21 | movement end | 2 | 2 |

Drawings repeat between groups, so the last column is not additive to the global distinct count.

## Generation and registration

One built-in Imagegen call; selected attempt 1, no corrective edits, no rejected outputs. [Exact submitted prompt](generation-01.prompt.txt); its complete text and exact input/tool-output paths and hashes are also in `generation-provenance.json`. The prompt SHA-256 applies to submitted UTF-8 text without the file's trailing newline.

Tool output: `C:/Users/zhouc/.codex/generated_images/01a16383-53e2-7d13-961e-482bcd4abce7/exec-4a2e4e3f-16a6-4033-ac1b-44f29fe9f6d7.png`. Preserved byte-for-byte as [generated-01-raw.png](generated-01-raw.png), 920 × 1708 px. Generated raw SHA-256: `37ce8e09c3fdab4f4bbf1150f9547d044d09f820bb89dfc336d6aba2a9a55efe`.

Used the provided `registerMaster` helper with default uniform height scaling; no stretch, anatomy override, painted edits, source-pixel substitution or background removal. The common source scale is **180/73 = 2.4657534246575343**, anchor (512,512), native reference (196,268). Skeleton's native-derived target is (463,317), 104 × 192. The generated aspect ratio registers at **(465,317), 100 × 192**, bottom 509: 4 px narrower than the native target, centered on the same silhouette center. Its height is not forced to 180 px. The mirror is verified byte-for-byte as a horizontal RGBA reversal by the helper.

## Actual review and limits

Inspected the generated result, `source-vs-master.png`, the complete registered source cell, and `alpha-review.png` on light/dark backgrounds. Skull facing, lean, arm placement, spread feet, down-right sword, complete extremities, palette and the empty hand remain readable at 192 px visible height. Fine bone modeling replaces enlarged source pixels. Open bone spaces and genuine alpha remain visible, without a floor, cast shadow, text, VFX or clipped props.

Remaining differences for human review: the generated skull/joints and rib spacing are more anatomically explicit than the tiny native pixels; the sword guard is regularized; the hand articulation and bone texture are interpretations, not exact recovery. The silhouette is 4 px narrower and the bone highlights somewhat creamier than the olive-gray source. No claim of perfect anatomical accuracy or pixel-identical pose is made.

No animation timing, transitions, attack alignment, future-frame consistency, game-background coexistence, engine import or runtime behavior was checked. No tests, builds, editor/engine runs, Git writes, commits or pushes were performed. Only Skeleton's directory was written. Human approval of this static master is the next gate before animation work.
