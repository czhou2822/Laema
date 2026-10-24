# Research Laema Animation Pipeline

Original-character animation R&D, 23 October 2026 (Hong Kong).

**Local status: v08 now has an actual isolated game trial; human visual approval is pending.** Latest integration: the user requested "put it into the game and lets see". [v08 actual-game trial](trials/2026-10-23-v08-game-integration/README.md) is a fresh isolated Gym copy. [The current replay](trials/2026-10-23-v08-game-integration/review.html) compares real current-art/v08 viewports; a separate normal-controls playable window was opened. Only copied X1 artwork/drawing keys changed. Both sequences observed X1 contact/orb/Charging/Cast impact/Dodge/incoming interruption. Source gameplay is unchanged. Variable sample intervals, pre-command controller events, scheduling limits and retained shutdown warnings are recorded in its evidence. Human visual acceptance remains pending; this test request does not approve artwork or propagation. Current game remains the last stated overall preference. This newer run supersedes older "last integration v02" statements only within its stated scope.

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
