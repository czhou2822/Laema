# Necropolis animation worker contract

The user explicitly approved all 14 existing Necropolis masters as appearance
references and requested all 228 original groups / 1,378 positions, including
mirrors and a portable offline package. Original pose, facing, grip and placement
remain authoritative. This is **asset production only**, not actor integration.

Read the installed Mali and imagegen Skills completely before art work, plus
Mali's art-review-and-direction reference, physical personal-art profile, current
AGENTS.md and docs/art/ART_DIRECTION.md. Mali is already the accepted Art operation;
do not ask for entry or repeat master approval. The user authorized relevant
asset-image checks; no gameplay builds, tests, editor changes or live game work.

## Ownership

Each dedicated worker owns only its assigned creature's
`assets/prototype/enemy/<id>/remaster_v01/` and its own creature report under
`docs/art/remasters/necropolis-v01/creatures/<id>/`. Shared tool, generation plan,
root indexes, original sources, published master package, game files and Git are
read-only. Other workers run concurrently; never overwrite another worker's work.
No Git operations or messages to peer threads. Parent owns all publication.

## Actual inputs and tooling

- Read your complete creature entry in `generation-plan.json`, all group sequences,
  source metadata, approved appearance path/hash and source occurrence mappings.
- Inspect actual source-pose guides and the approved master with view_image before
  generation. Follow the original's costume, weapons, anatomy and upgrade identity.
- Tool: `tools/art/necropolis_remaster.py`; Python with Pillow is available. The
  parent's read-only helper handles reference preparation and mechanical exports.
  Use its `--help`, `guide`, `prepare`, `ingest`, `review`, `build`, `validate` and
  `spriteframes` commands. Python executable on this host is
  `C:/Users/zhouc/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe`.
- Fixed cell 1024×768, four-column final atlas, target anchor (512,512), source
  reference (196,268), scale180/73. Native body bounds use alpha>160, excluding
  shadow palette. No independent pose/weapon/crouch/flight scaling.
- `guide <id> --pose-ids id_p000,id_p001 --name chosen-name` writes labeled OG
  reference guides and exact mapping JSON in your `_source/guides` folder.
- `prepare <id>` generates all still-pending guides in batches of up to eight.
  Its batch guide JSON lists exact row-major pose IDs and dimensions. Do not
  create another guide for the same already supplied pose without a repair reason.

## Artwork and ingestion

Generate all invented/redrawn artwork with **built-in image_gen**, genuinely
transparent. No API/CLI/local-model fallback. No code-painted body parts and no
upscaled original-pixel deliverables. Original-reference enlargements are guides
only. Request one separately drawn complete source pose per occupied guide cell,
in exact row-major order, with clear gutters/margins, no labels/grid/floor/shadow.
Use the master for appearance only: never force the original action into idle.
The original controls changes of view, turns, flight, death fragments and effects
already embedded in creature frames. Do not add standalone projectiles or VFX.

Save the exact prompt with apply_patch before the built-in call. Copy the returned
raw PNG verbatim into your `_source` folder; retain returned tool metadata, actual
reference paths/hashes and all unsuccessful attempts. Never fabricate seeds,
models, offline workflows or missing prompts. Use one built-in call per requested
page/variant, and inspect the result before accepting it.

Ingest a page with:

```
python tools/art/necropolis_remaster.py ingest <id> <raw-png> --pose-ids <comma-separated-IDs> --cols <N> --rows <N> --batch <unique-attempt-name> --prompt-file <prompt-path> --adaptive-grid
```

The default Pillow-only helper requires transparent gutters and rejects clipping. Do not
weaken its checks to force in a broken image. Regenerate uncertain/clipped poses
individually with `--cols 1 --rows 1`. Optional strict component isolation is now
available after the user's explicit scratch-only SciPy installation approval.
It must reject ambiguous figure counts and true outer-edge clipping. On this host,
place `--dependency-path C:/Users/zhouc/.codex/visualizations/2026/09/08/01a07f41-7159-70f1-ac7d-e6217941c130/necropolis-validation-v01/python-deps`
**before** the `ingest` command and add `--components`. This is an optional host
dependency overlay, not an operational dependency of the default packing path.
Do not install anything yourself or silently invent grouping. Never overwrite raw
attempt names with different bytes. Replacements preserve previous provenance.

Approved idle reuse is permitted only for the exact original idle reference pose,
after visually comparing the master with that source. Use the byte-identical
cropped high-resolution master, `--reuse-approved-idle`, one pose and 1×1 layout;
do not reuse it for merely similar movement, hurt, attacks or other idle drawings.

After actually inspecting each ingested pose against OG at game size and enlarged,
mark only those IDs with `review <id> --pose-ids <IDs> --note <actual observations>`.
This is worker review of candidates, not human animation acceptance.

## Completion

Run `build <id>`, repair issues, then `validate <id>` and `spriteframes <id>` only
when complete. Missing poses must stay explicitly missing: no duplicate idle,
placeholder art, motion warping or silent OG replacement to fill coverage.

Review every source-ordered sequence, entries/exits, turns, repeats and both facings.
Inspect individual source/candidate poses, generated per-group contacts and GIFs.
Check anatomy, limbs, skeletal fragments, grips, weapon length/angle, wing/robe
continuity, feet, silhouette, alpha, scale and framing. Rebuild every dependent
group after any shared-pose repair. Correct concrete failures before completion.

Write a concise creature report and machine-readable visual review under your
exclusive report folder: supplied/missing poses and groups, actual sampling,
repairs, exact provenance, reused/new artwork counts and remaining limitations.
Do not claim browser, engine, human playback or original timing proof. Parent
handles independent checks, viewer, isolated Godot validation and publication.
If the tool/model fails, report the exact blocker and preserve partial work; never
invent success. Do not mark full coverage complete while anything is missing.
