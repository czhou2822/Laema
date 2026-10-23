# Lich remaster production report

Status: **Complete asset coverage; worker-reviewed animation candidate.** All **74 registered poses / 18 original groups / 120 source timeline positions** are supplied, reviewed and exported. Final validation is complete with zero errors and zero missing poses. Appearance approval is not human motion acceptance.

## Delivered

- Asset root: `assets/prototype/enemy/lich/remaster_v01/`.
- **74 newly drawn selected poses**, plus exact pose mirrors; no approved-idle reuse, original-pixel replacement or warped-master fill.
- **18 source atlases and 18 mirror atlases**, 1024×768 cells, four columns, prescribed anchor/source coordinate transform and uniform aspect-fit. Death uses its native shrinking bounds.
- **120 source frame PNGs and 120 mirror frame PNGs**, **36 review GIFs**, **18 original/candidate contacts** and both SpriteFrames libraries, each containing 18 groups and 120 positions.
- All source order, repeated positions and separate alias groups retained. G7/G9 and G8/G10 have byte-identical corresponding source/mirror atlases while remaining separate outputs. No nonexistent CLICH G6/G17–19 slots were invented.
- Source manifest: [source_manifest.json](../../../../../../assets/prototype/enemy/lich/remaster_v01/source_manifest.json). Export details and hashes: [handoff-files.json](handoff-files.json).

## Identity, generation and repairs

CLICH and the creature's own approved master govern this base Lich: pale skeleton, red eyes, plain dark gold-banded cap, chainmail coif/skirt, dark gold-trimmed plate and boots, plain capped wooden staff. No Power Lich equipment was used. Original DEF, metadata, appearance-master and generation-plan hashes were rechecked unchanged after production; exact values remain in [source-audit.json](source-audit.json) and [visual-review.json](visual-review.json).

Used **17 built-in image-generation calls**, requesting **111 figures including 37 superseded selections**. Every exact prompt was saved before its call. All returned raw pages were retained byte-for-byte and verified against their original generated files. Actual returned metadata, reference paths/hashes, prompt hashes, extraction rejections and repair reasons are in [generation-attempts.json](generation-attempts.json). No seeds, model version or offline drawing workflow are invented.

Repairs affected 37 poses: narrower idle registration (p012–016), purple defence accents (p023–026), detached death anatomy (p029), red ranged accents (p064–069), red walking accents (p001–007), yellow hurt accents (p017–022), and red ranged/ending accents (p058–063, p072–073). Good figures elsewhere were retained. Prior pose records and unsuccessful packing submissions remain under `_source/history/` and `_source/raw/`.

53 selected poses use the approved strict component path. Other selected poses use transparent gutters or inspected unchanged pixel-region crops. Row/figure crops preserved existing artwork without padding, painting or warping; their provenance is recorded. Death fragments were kept together as complete pose compositions rather than treated as additional creatures. No dependency was installed and no clipping/count check was weakened.

## Actual review and validation

Mali's evidence workflow kept source observations, candidate review and human acceptance distinct. Inspected all 74 original pose guides, every raw attempt enlarged, and every selected pose against the original at target pixels. Then inspected **every source-ordered group contact and every decoded source/mirror GIF frame position**, including entry/exit drawings, held repeats, reverse returns, turn aliases, staff directions/grips, changing views, boots and disassembled death pieces. [visual-review.json](visual-review.json) records per-pose comparisons, current reviewed hashes and per-group observations. [gif-frame-evidence.json](gif-frame-evidence.json) records actual GIF decoding and repeat expansion.

Ran `build lich`, `validate lich`, `spriteframes lich`, then final `validate lich`. Both validations passed: **74/74 reviewed poses, 18/18 groups, 120 ordered frame cells, zero errors**. Static resource checks also confirm 18 texture references, 120 AtlasTextures and 18 animations per SpriteFrames library. These checks do not establish that Godot loaded the resources.

## Limits and parent handoff

Review was static: raw drawings, source/candidate comparisons, group contacts and decoded GIF frame sheets. No continuous browser playback, Godot/editor/runtime check or human motion acceptance was performed. GIF/library timing is **10fps review only**; original timing remains unknown. Separately redrawn contour, material-detail and apparent-volume differences remain a motion-review consideration; no per-pose scaling correction or motion warping was applied.

Existing isolated artwork can be rebuilt offline with the repository helper, generation plan, original reference tree and Python/Pillow. Strict component re-ingestion additionally needs NumPy/SciPy; build itself does not. New drawing still requires the built-in image tool: no local model/weights/seed package is supplied. The parent owns the combined portable package, independent browser/Godot checks and publication. No Git, shared-tool, original/master, canonical-record, gameplay, actor, AI, encounter or timing change was performed by this worker.
