# Lich — static master proposal

Status: awaiting human master approval. Full-collection scope is retained in `job.json`; this delivery covers the static idle master only.

## Source and identity

Read the worker brief, complete job, current project instructions, Mali and imagegen Skills and relevant references, project art direction, and physical Mali personal profile. Inspected the actual CLICH native idle, full-group contact, and guides G02, G04, G07, G12 and G15 before generation, plus the Pikeman rendering benchmark. CLICH metadata and original DEF hashes match the job; all 18 native group records match. The 120 timeline frames / 74 distinct indexed drawings remain inventoried in `job.json`, without duplication here.

The proposal keeps the right-facing skeleton, dark cap and plain gold band, chain coif/skirt, exposed bony limbs, dark metal armor/greaves, gold fittings and upright straight staff. No Power Lich crescent/crown, elaborate staff head, extra weapon or VFX is present. Bone, gunmetal, mail and wood are separately readable; the Pikeman supplied rendering finish only.

## Deliverables and provenance

- `master_rgba.png`: high-resolution cropped RGBA artwork.
- `master_source_1024x768.png` and `master_mirror_1024x768.png`: registered transparent cells.
- `source-vs-master.png` and `game-size-review.png`: inspected comparison sheets.
- `master-manifest.json`, `artifact-checks.json`, `provenance.json` and `visual-review.json`: measurements and review boundary.

One built-in `image_gen.imagegen` call produced chosen `raw/master-01.png`, preserved byte-for-byte from the returned file. Exact prompt and arguments are in `prompts/master-01.txt` and `requests/master-01.json`; `generation-result-01.json` records the returned path. Provenance includes SHA-256 hashes for prompt, request, raw, inputs and shared helper; output hashes are in the manifest/check record.

## Review and limitations

Inspected the raw render, registered cell, source comparison, exact mirror, light/dark backgrounds, 224px shared-scale view and 91px native-density comparison. The cell uses anchor (512,512), reference (196,268), scale 180/73, default uniform registration and no anatomy override. Full body and staff are visible, with generous cell margins, genuine alpha and no floor shadow.

The generated silhouette measures 82×224 versus the source target 94×224: about 13% narrower. It was not stretched. Fine chain links, facial construction and the bone-like belt clasp are generated interpretations; gold trim is more emphatic than in the tiny source. At 91px, face and mail detail merge, while the staff and dark/bone separation remain legible.

No corrective generation was needed for clipping, transparency or upgrade identity. Human acceptance remains open. Animation production has not begun; no game import, engine run, tests, build, Git operation or peer message occurred. Runtime is unverified.
