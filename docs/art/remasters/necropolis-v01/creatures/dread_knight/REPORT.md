# Dread Knight remaster v01

Status: **Complete worker asset candidate; parent validation pending.**

All **62/62 distinct poses**, **18/18 original groups** and **125/125 source
positions** are supplied and worker reviewed. There are zero missing poses or
unresolved blocking anatomy, clipping or order defects in the completed static
review. Source repeats, original group/block order, turn aliases 7=9 and 8=10,
special aliases 17=18=19, and exact per-frame mirrors are preserved.

## Deliverables

Asset root: `assets/prototype/enemy/dread_knight/remaster_v01/`.

- `source_manifest.json`: exact source mappings, geometry, coverage and per-pose provenance.
- `group_*.png`: 18 source-facing atlases and 18 exact mirrored atlases, four columns, 1024x768 cells, anchor (512,512).
- `frames/`: 125 ordered individual frame PNGs per facing.
- `poses/`: 62 selected pose PNGs, their mirrors and helper review records.
- `previews/`: 36 GIFs, **10 fps review timing only**.
- `contacts/`: all 18 source-ordered original/candidate group contacts.
- `original_groups.tres` and `original_groups_mirrored.tres`: 18 animations and 125 positions each; preview resources only.
- `_source/`: untouched raw outputs, exact prompts, returned tool metadata, guides, isolated figures and six superseded pose records.

## Artwork and repairs

Nine built-in image-generation calls supplied 68 figure attempts. The final set
uses **62 new drawings and zero approved-master reuses**. The approved master
was an appearance reference; original guides controlled poses. There are no
original-pixel upscale deliverables, code-warped poses or idle fillers.

The initial walk page failed the Pillow gutter extractor with
`Figure touches raw/grid boundary: dread_knight_p000`. The identical raw image
passed the user-approved strict component isolation. All selected pages used
that unmodified component path with the preinstalled dependency overlay; no
dependency was installed and no count/clipping check was weakened.

One targeted six-pose page repaired p008's saber plane, p017's obscured blade,
p030/p031 reaching the fallen state too early, p041's away-facing rider and
p055's free arm. The corrected death intermediates retain airborne flank
rotation and downward legs before the final low horse/rider heap. Every group
was rebuilt after repair; original raw attempts and prior pose metadata remain.
Native red saber effects in the special groups remain attached to the weapon
and its reflected light.

## Evidence and limits

`input-verification.json` verifies the DEF, metadata and approved-master hashes,
all 125 indexed source occurrences, and metadata group equality with the plan.
`generation-provenance.json` records exact prompts, actual reference paths and
SHA-256 hashes, retained raw submissions and returned output hints. No seed or
model identifier was reported by the tool.

Direct image inspection covered every original guide, all nine raw pages, all
62 source/candidate pose comparisons at native and enlarged scales, all 18
source-ordered group contacts, and all 36 GIFs through decoded frame contacts
showing both facings. Repeated holds were expanded from encoded GIF durations
for inspection. `visual-review-observations.json` contains actual observations;
`visual-review-evidence.json` binds them to the final pose and atlas hashes.
`gif-decode-evidence.json` records the decoding boundary and durations.

The required validate -> spriteframes -> validate sequence passed. Both
`validation-before-spriteframes.json` and `validation-final.json` report complete
coverage and zero errors. All 125 atlas cells were checked for source order and
exact mirrors. Exported resource text has 18 animations/125 frame subresources
per resource.

Small strap, rivet, plume and steel-highlight differences remain between drawings.
This is static worker review, **not continuous animation playback, browser/Godot
validation, human motion acceptance or proof of original timing**. Parent owns
those checks and publication. No game actor, AI, encounter, timing, canonical
record, original source, approved-master package or Git publication was changed.
