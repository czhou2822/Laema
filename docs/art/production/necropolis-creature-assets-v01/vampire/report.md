# Vampire base — static master proposal

Status: **Awaiting human master approval.** This is the Vampire contribution to the complete Necropolis collection. Animation production has not begun.

The selected result is `raw/master-attempt-02.png`: one built-in imagegen master followed by one targeted repair. The first result had oversized glossy red talons; the repair shortened them to restrained dark-red nail tips. Both untouched raw outputs and both exact requests are retained.

## Source and treatment

Inspected the enlarged native idle, all-groups contact sheet, all 15 group guides (their labelled first/middle/last samples), native scale guide and approved Pikeman rendering master. Full inventory remains in `job.json`; sampling and source hashes are in `source-evidence.json`. The original CVAMP DEF and actual metadata hashes match the job, and every native metadata group matches its job entry. These were static samples, not motion playback.

The master preserves the pale bald pointed-eared identity, hooked elongated face, compact bent-wrist right-facing three-quarter idle, lean legs, fitted dark ragged attire and low black footwear. Pale hands and small red nail tips remain readable. The Pikeman reference supplied modeled shading and material finish only. Fine grain and softened volumes replace block pixels; no red noble cape, armor, weapon, wings or transformation effects were added.

## Selected files and registration

- `master_rgba.png` — 660×1481 tightly cropped high-resolution RGBA master.
- `master_source_1024x768.png` / `master_mirror_1024x768.png` — transparent native-facing registration and exact horizontal mirror.
- `source-vs-master.png` / `alpha-review.png` — shared-scale comparison and dark/light inspection previews.
- `provenance.json` — exact prompts, tool path, input/output hashes, reference roles/paths and original generated-output locations; `generation-01.request.json` and `generation-02.request.json` retain exact tool arguments.
- `master-manifest.json`, `visual-review.json`, `source-evidence.json` — registration and review evidence.

Used the shared read-only `../tools/lib.cjs` `registerMaster` through `build-master.cjs`, without overrides: cell 1024×768, anchor (512,512), original reference (196,268), scale 180/73. Registered alpha bounds are (467,302), 92×207; bottom 509. Original target bounds were 96×207. Genuine alpha and pixel-exact mirroring passed the helper's mechanical checks.

## Visual review and limitations

Inspected the selected enlarged master, registered source and mirror, shared-scale comparison and both inspection backgrounds. Full figure and claws are visible, edges are clean at display scale, and no floor shadow or baked backdrop is visible. This is an assistant-reviewed proposal, not human acceptance.

The reconstruction is approximate: its silhouette is about 4% narrower than the source target; tiny face/finger details, cloth seams and leather-like grain interpret low-resolution evidence. Surface wear is more explicit than the native pixels. The claw edit also subtly resynthesized texture outside the hands despite the requested invariants. Runtime semantics/timing and motion continuity are unverified. No animation, engine import, gameplay/code change, runtime, tests, builds, Git operation or peer message occurred. Collection QA belongs to the parent.
