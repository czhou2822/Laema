# Local continuation prompt

Paste the prompt below into a local Codex task opened at the Laema repository. The research folder and its media must already be present in the checkout. The source inspected for this round was `16b4c3b7199589439a276881eca7516cc0f7401c`; compare the local state before treating old findings as current.

```text
Continue Laema — Original Character Animation Pipeline R&D from the published folder:
Research Laema Animation Pipeline

Goal: establish a repeatable, high-quality workflow for original Laema sprite-flipbook animation, without importing, tracing or retargeting pre-existing animation sequences. Recommend a workflow from actual comparable outputs and total effort, including manual correction.

First read AGENTS.md and the current canonical records relevant to animation. Inspect local Git status and preserve unrelated work. Read Research Laema Animation Pipeline/README.md, FINDINGS.md, report.html, evidence/round-record.json, preview/README.md and CONTINUE_LOCAL.md. Compare the local source against the inspected revision 16b4c3b7199589439a276881eca7516cc0f7401c; reconcile material differences without resetting or overwriting local work. Treat prior evidence as revision-scoped.

Current state:
- Phase 1 source/image diagnosis is complete. Main issues: weak body weight transfer/braking, character/equipment/material drift, uneven real-time frame exposure, and hard pose handoffs. No new engine defect was established.
- Live X1/X4/X5 use overnight_v04 and X2/X3 use angle_proofs_v03. A later reviewed 4/3/4/5/4-pose handoff is distinct and not installed by this R&D. Do not silently replace either set.
- Phase 2 has three original Fire X1 blocking proposals: A diagonal cut, B level backhand, C rising cut. There are 32 original joint keys. No proposal has user approval yet. Laema Open/current sword-and-shield context is provisional, not a final outfit or weapon lock.
- Browser motion media exists. Godot 4.6.3 headless checks passed for the standalone preview; graphical Godot and integrated combat review remain pending. The main game declares 4.7. The baseline video is a source-timed reconstruction, not recorded gameplay.
- No production AI/rig/3D comparison or workflow winner exists. Department assignment is unconfirmed; do not reuse another task's identity.

Resume at the motion-review gate. Open review.html and run the standalone preview/project.godot locally. Present A/B/C at native gameplay size and normal speed, fixed Heat 0 and 100, both facings, plus frame stepping as needed. Get my explicit selection or motion corrections before polished artwork. Do not choose a default for me. Keep corrections in this isolated research folder; it has .gdignore to exclude it from the main project.

Preserve the inspected X1 contract unless I separately approve changes: total0.720s at Heat0 /0.480s at fixedHeat100; contact window0.126–0.5075s atHeat0; pacing split0.210s is not a hit marker. Contact is checked throughout the active window, not at a single impact pose. Preserve current input, queue, dodge, movement, damage, lunge and Cast rules. The new sword arcs are not aligned to the old native contact curves; make any adaptation explicit and reviewable. The foot anchor and actor/query origin differ; use FINDINGS.md's registration details.

After motion approval, use the approved motion and one consistent character/equipment reference to produce actual reference-guided AI sprite-strip and 2D rig plus frame-by-frame hybrid results. Test 3D-assisted motion/rendering if depth, volume or reuse justifies its setup; otherwise record it as not tested. Preserve raw outputs, rejected attempts, prompts/source provenance, corrected outputs and measured effort. Separate reusable setup from per-action labor; do not invent retrospective hours or claim the blocking rig is a successful polished rig trial.

Produce comparable playable Godot previews and synchronized comparisons. Review motion quality, responsiveness, silhouette readability, character consistency, alignment, contact geometry, actual Idle/Walk/X2/Cast/Dodge/reaction transitions, correction effort and reuse across another materially different action. Distinguish what was actually run from planned checks and preserve human visual approval as separate evidence.

Recommend the production workflow only after demonstrated comparable results and total correction effort. Do not bulk-replace existing animations, change gameplay to hide animation problems, publish a live build, or claim production readiness without my visual review. Do not treat this continuation as motion approval. Continue authorized independent work without repeating settled approvals or adding unnecessary gates.
```
