# Skeleton Warrior production handoff

Status: **COMPLETE WORKER CANDIDATE** — 2026-10-23. Dedicated creature:
`skeleton_warrior` (`CWSKEL`). Parent explicitly cleared the pilot workflow before
production. No unresolved blocking clipping, anatomy, equipment, framing or order
defect was identified in the worker's final static inspection. This status is
not human motion acceptance or engine validation.

## Coverage and outputs

| Item | Supplied | Missing |
| --- | ---: | ---: |
| Unique source-pose artworks | 57 | 0 |
| Original groups | 15 | 0 |
| Original ordered positions | 86 | 0 |
| Positions including exact mirrors | 172 | 0 |
| Source/mirror group atlases | 30 | 0 |
| Source/mirror pose PNGs | 114 | 0 |
| Source/mirror frame PNGs | 172 | 0 |
| GIF previews / OG-candidate group contacts | 30 / 15 | 0 |
| SpriteFrames libraries | 2, each 15 groups / 86 positions | 0 |

All 57 selected artworks are newly drawn with built-in imagegen. Approved-master
idle reuse: **0**. Nineteen built-in calls produced 82 figure attempts including
repairs; every raw page is preserved. No idle substitution, original-pixel
deliverable, code-painted figure, or warped-master animation was used.

Asset root: `assets/prototype/enemy/skeleton_warrior/remaster_v01/`.

- `source_manifest.json` contains complete source/pose/group mappings and hashes.
- `original_groups.tres` and `original_groups_mirrored.tres` contain every source
  slot, including legacy turn aliases. They are preview-only resources.
- `frames/source/`, `frames/mirror/`, `previews/` and `contacts/` contain the
  exported frame PNGs, GIFs and source comparisons.
- Geometry remains fixed: 1024x768, four atlas columns, anchor (512,512), source
  anchor (196,268), scale 180/73 and alpha>160 native body bounds.

## Review and repairs

All 57 OG/candidate/exact-mirror poses were visually inspected in fixed-placement
contacts and enlarged comparisons. Every one of the 15 source-ordered group
contacts and every decoded frame from all 30 GIFs was inspected. This was static
frame/contact inspection with `view_image`, not timed browser or engine playback.
Per-pose and per-group observations and evidence hashes are in
`visual-review.json`; all 57 helper pose records carry actual review notes.

Clipped/grid-boundary p011, p017 and p018 were redrawn singly. The original
intact figures from those pages were retained through exact mechanical cell
crops, with parent-page hashes and crop regions. Strict component isolation
successfully preserved separate figures crossing nominal cells on pages 003,
005 and 006; count and global-edge checks were unchanged. Only the approved
preinstalled dependency overlay was used; nothing was installed.

Source comparisons prompted single-pose repairs of p025's hidden/edge-on weapon,
p033's turn silhouette and p032's compact remains/upright sword. Added forearm
guards were removed from p025 and 17 selected hurt/attack/movement drawings;
p054 required a final individual correction. Previous raw art, isolated sources
and pose-record history remain available. No standalone effect was added.

G1/p011 and G4/p026 retain all five held source positions. Their GIFs coalesce
identical frames to a 500ms hold at the helper's review rate. G7=G9 and G8=G10
remain exact aliases; G8 reverses G7. G11/G12/G13 retain shared p035,p036,p042
and their distinct middle actions. Original group slots and order were preserved.

## Verification and provenance

`build` completed; `validate` passed before SpriteFrames export and again after
export. Final helper result: complete=true, errors=[], 57/57 poses, 57 reviewed,
15/15 groups and 86 atlas positions checked. Additional asset checks verified
all 172 emitted frame PNGs against pose/exact-mirror bytes, both library entry
counts, alias atlas hashes, original indexed frame hashes/body bounds and all
generation reference/raw hashes. See `final-validation.json` and
`check_sources.py` / `production_assets.py` in this report directory.

Source manifest SHA-256:
`10734b3c0206319c1056acd105baa268a428e2c17b83d9ae2014530a70ccd9b7`.
Approved master hash remains
`b5c927d1906aaf32eb4d9c0df532d7094fd24afdfbb1ef453870fd45c20e20ee`;
original DEF and metadata hashes also match the unchanged plan.

Under the asset root, `_source/generation-provenance.json` records all 19 calls
with actual reference, prompt and raw-file hashes. `_source/tool-metadata/`
retains returned metadata, `_source/tool-invocations.json` retains exact invoked
prompt strings/reference order, and `_source/intake-and-repair-log.json` records
the failed extractions and repairs. Saved pre-call text prompts have the same
wording plus one final separator newline; exact invocation strings are retained
separately. No model identifier or seed was returned or invented.

Original timing, browser playback, Godot import/runtime, final subjective motion
quality and human animation acceptance remain unverified. The resources' 10 fps
is review-only. No actor, AI, encounter, gameplay timing, canonical document,
shared helper, plan, original/master asset, Git state or peer chat was changed.
Parent owns independent review, integration, packaging and publication.
