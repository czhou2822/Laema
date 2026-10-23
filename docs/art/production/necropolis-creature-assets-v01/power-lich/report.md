# Power Lich — static master proposal

Status: **awaiting human approval**. Selected full-body input: `master-input-eye-repair.png`; generated eye source: `raw/attempt-05.png`. Animation production has not begun.

## Source and correction

Original CPLICH DEF, metadata and idle hashes match `job.json`; its complete inventory remains there (18 groups, 120 positions, 74 distinct drawings). Pose authority: G2 F0 / cplich74.pcx. Inspected native idle, all-group contact and guides G0 0/4/7, G2 0/4/7, G4 0/5/10, G7 0/1, G12 0/4/7 and G15 0/5/10. Pikeman supplied rendering polish only.

The parent's `../references/native-power-lich-head-audit.png` confirms **two red facial/socket accents below the crown**, separate from its red stones. The earlier claim that red eye detail was unsolicited, and its removal in attempt 02, were incorrect. This report and current provenance supersede that diagnosis; exact historical prompts/raw outputs remain unchanged.

Two full-frame repair attempts restored only the near accent and introduced incidental repainting; neither was applied. A targeted built-in head edit produced both accents. `repair-eye.cjs` mechanically extracts only its red pixels and places them inside the existing sockets on attempt 02. **92 RGB pixels changed; every non-eye pixel and the complete alpha channel remain identical.** No glow, aura, halo or bone light spill is visible.

## Outputs and verification

- `master_rgba.png`: transparent 575 × 1481 master.
- `master_source_1024x768.png`, `master_mirror_1024x768.png`: registered cells, exact pixel mirror verified.
- `source-vs-master.png`, `eye-repair-review.png`, `cutout-background-review.png`: display-scale, head-detail and matte comparisons.
- `master-manifest.json`, `artifact-audit.json`, `eye-repair-provenance.json`, `eye-repair-verification.json`, `visual-review.json`, `final-hashes.json`: current evidence and full hashes.

Shared read-only `tools/lib.cjs` registration is unchanged: cell 1024 × 768, anchor (512,512), reference (196,268), scale 180/73; alpha64 bounds (461,251), 101 × 259. In the registered cell, only 35 RGB pixels around the eyes differ; alpha is identical. Crown, staff, armor, skull geometry and pose retain the preceding master pixels.

Exact tool arguments and all five byte-preserved attempts remain in `prompts/`, `raw/` and `generation-attempt-*.json`. Master SHA-256: `0953e37e537356a924f8e820ff6d4513a1d679eb70150d6a68185fe83bdba1e5`. Full raw/input/master/source/mirror hashes: `final-hashes.json`.

## Actual limits

Both red accents are distinct in the head close-up; the far accent is very small at 259px display height. Prior limits remain: silhouette about 5% narrower than the native target, brighter/more regular mail, interpreted fine details, still-image sampling only. Parent owns collection QA. No animation, engine import, game code, gameplay, tests/builds/runtime, Git operations or peer messages. Runtime unverified; await human approval.
