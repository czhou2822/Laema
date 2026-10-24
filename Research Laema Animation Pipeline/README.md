# Research Laema Animation Pipeline

Original-character animation R&D, 23 October 2026 (Hong Kong).

**Local status: H02 preparation candidate and aligned drag overlays are ready for artistic review.** H02 preparation correction from saved annotations: [current character review](trials/2026-10-23-v08-game-integration/review.html?experiment=H02) shows Current game / H01 / H02. Five H01/v08 notes were read with version/frame scope preserved. H02 replaces only preparation2–4 with proposed load/coil/drive drawings;1 and5–16 plus all times are source-exact. The first generation was rejected after an agent guide-landmark error and reframing; the retry uses corrected source landmarks/tight crop. Sole cleanup and remaining boot/appearance/4→5 risks are explicit. Drag a character/handle onto another for a foot-aligned transparent overlay; notes can target base or overlay and retain both version hashes, frames, time and opacity. Read active [H02 notes](trials/2026-10-24-x1-quality-h02/annotations.json) and the preserved [H01 notes](trials/2026-10-24-x1-quality-h01/annotations.json) before another art change. The game-reference elbow3–4→5 and thrust6 concerns remain separate. H01 grip benefit is unestablished, not a blanket approval/rejection inferred from the ambiguous release note. No H02 Godot/gameplay run, main install, gameplay change, artistic acceptance, workflow winner or publication exists. Start review_server.py for both annotation stores. See [H02 report](trials/2026-10-24-x1-quality-h02/README.md).

The original cloud bundle has now been restored by merge. Its exact published snapshot, including media, original viewer, verification and manifest, is preserved in [history/cloud-publication-3fd153b6](history/cloud-publication-3fd153b6/README.md). The later local A-selected/Combat-assigned work and v08 records remain current. [Merge reconciliation](MERGE_RECONCILIATION.md) explains the scope; [local Godot captures](local-review/) remain separate evidence, not the restored cloud bytes.

## Start here

- [Findings and technical contract](FINDINGS.md)
- [Local continuation prompt](CONTINUE_LOCAL.md)
- [Detailed illustrated report](report.html) — open locally in a browser.
- [Interactive A/B/C motion comparison](review.html) — offline HTML with embedded data.
- [Local original-study motion capture](local-review/heat0-right.webp), [fixed Heat100](local-review/heat100-right.webp) and mirrored captures in local-review/ remain the later local evidence. [Restored cloud motion video](motion-studies.mp4) and [key-pose board](motion-keyposes.png) are the original published studies.
- [Restored cloud live-sheet video](evidence/live-baseline.mp4) is a source-timed reconstruction, not recorded gameplay. Restoring it adds no new runtime evidence.
- [Standalone Godot preview](preview/project.godot) and [controls/verification](preview/README.md).
- [Effort worksheet](effort-log.csv), [round state](evidence/round-record.json) and [file hashes](artifact-manifest.json).

GitHub displays the Markdown and images. Download/open the HTML locally to use its controls; open `preview/project.godot` directly in Godot to run the separate player. The root `.gdignore` keeps this research and its nested Godot project out of the main game's import scan. There is no automatic import into production.

## Objective and sequence

Establish a repeatable, high-quality process for original Laema flipbook animations without reusing pre-existing animation sequences. Existing animation may be inspected as diagnostic evidence; it must not be traced, retargeted or imported as the new motion.

1. Diagnose current assets, five-hit attacks, Casting and implementation. Separate motion, artwork, timing and integration issues.
2. Review three original low-fidelity motions at gameplay speed/scale. Obtain a user-selected motion before polished artwork.
3. Produce actual reference-guided AI and 2D rig/hybrid outputs using the same approved motion and consistent character reference. Add a 3D-assisted trial if its setup is justified by demonstrated depth/volume or reuse problems.
4. Compare playable Godot results, synchronized visuals and total effort, including rejected attempts and manual corrections. Recommend a workflow only from demonstrated results. No bulk replacement or production-readiness claim without visual review.

## Current review choice

| Study | Movement |
| --- | --- |
| A — Diagonal cut | Rear-foot load, descending release, low braking arc |
| B — Level backhand | Shoulder coil, level sweep, compact elbow brake |
| C — Rising cut | Compression, upward diagonal release, high catch |

These were three unranked, provisional Fire X1 studies: 32 original joint keys, shared guard endpoints, approximately 180px body height, fixed 88px blocking blade. The user subsequently selected A for the controlled trial. This establishes neither final character proportions nor weapon/outfit choices.

![Three original motion studies](motion-keyposes.png)

## Historical cloud evidence boundaries

The inspected game revision is `16b4c3b7199589439a276881eca7516cc0f7401c`. Findings are historical to that revision until checked against a newer local tree.

The browser renderer was checked in Chromium; its exported motion video is 12 seconds at 1280×720/60fps. The standalone preview passed Godot 4.6.3 headless import, 219 pose samples and 120 execution frames. The main game declares a 4.7 feature target. No graphical Godot capture, current-product playtest, contact adaptation, human motion approval or production-readiness evidence was established in this round.

Existing gameplay, production art, canonical GDD/TDR and department records are unchanged by this publication. Department assignment for this new task remains unconfirmed. No chat transcripts, restoration dispatch or full checkpoint save is included.
