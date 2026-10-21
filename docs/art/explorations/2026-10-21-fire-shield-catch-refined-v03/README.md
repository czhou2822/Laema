# Fire Shield Catch — refinement v03

The user selected candidate 1 (Shield Catch) on 2026-10-21, requested refinement, then accepted this refined animation ("looks good") and authorized handover to U for game implementation. This is approved for prototype integration, not final Laema art or runtime validation. It preserves the sword-and-shield Fire stance and the selected shield-led catch rather than exploring five new motions. Integration remains pending at handover.

## Changes

- Eight exported frames rather than six, with seven distinct drawn poses rather than five.
- Additional intermediate shield raise and release positions.
- Quieter, consistently forward sword presentation; compact shield action rather than a forward bash.
- One sequence-wide scale and root alignment, with an exact repeated opening pose at the endpoint.
- Existing Fire canvas convention: 448×448, foot anchor (224,400), approximately 180px standing body.

The character design, plain steel sword, small round navy shield, cream shirt, blue vest, red sash and brown trousers/boots/gloves remain reference constraints. Original Heroes III material/rendering direction is carried forward through the selected source, not claimed as authentic H3 output.

## Files

- [Enlarged review GIF](shield-catch-detail.gif): fixed crop enlarged 2× with nearest-neighbour sampling, grey background and label; not a runtime atlas.
- [Transparent preview GIF](shield-catch-preview.gif): 448×448, eight frames.
- [Slow review GIF](shield-catch-slow-review.gif): same native canvases, slower review cadence.
- [Native-canvas grey review GIF](shield-catch-review.gif).
- [Transparent flipbook](shield-catch-8x448.png): 3584×448, eight 448×448 cells.
- `frame-01.png` through `frame-08.png`: individual RGBA frames.
- [Contact sheet](shield-catch-contact-sheet.png): overview plus ready/contact poses.
- `source-eight-pose-sheet.png`: unmodified generated 1774×887 source in a conceptual 4×2 layout. Source-cell boundaries are rounded to pixels.
- `metadata.json` and `prompts.json`: export details, exact prompt and provenance.

Native source order is 1/2/3/4/5/6/7/1. Generated source pose 8 is retained in the raw sheet but replaced by the opening pose for an exact loop endpoint. No synthetic morph/in-between generation or rigging is claimed. Artwork was refined with built-in image generation; isolation, shared scaling, translation and GIF/palette export are mechanical.

## Scope and verification

This is an art-only shield-catch/contact study. The current GDD already contains the October 21 Fire press-parry/hold-partial-block prototype; this art does not change those rules or validate that implementation. It does not prescribe how the held guard, unsuccessful parry or success interruption must be bound. The preview's 240/60/50/60/70/70/100/350ms cadence includes a viewing pause and is not gameplay timing.

Saved native PNGs were decoded and dimensions/alpha checked. The three native-canvas GIFs were reopened frame-by-frame and verified as eight frames, 448×448 and infinite looping. Seven unique exported poses, exact matching first/last pixels and clear exported canvas margins were checked. The contact sheet was visually inspected on grey; live continuous playback and Godot/import/runtime validation were not performed.

Fine face/hair, sword guard, shield perspective and garment continuity remain cleanup limits. Root alignment reduces translation drift but does not make generated boots/limbs pixel-identical across frames. No final-art acceptance is claimed.

Only this versioned exploration folder and the preceding exploration's selection note were edited. Existing source/configuration/scene/document work by other tasks was preserved. No runtime resources, binding, hitbox or timing edits; no commit, push or live publication.

## Runtime binding update — October 21

The user subsequently requested binding this artwork to the new defend feature.
The exact transparent atlas is now copied into
`assets/prototype/player/fire_sword_shield_v01/defence_v03/shield_catch.png`.
Player reads captured defence state; guard/contact/recovery mapping is recorded
in that folder's manifest. No defence rules/timings or source image pixels change.
Status remains `AWAITING_USER_VALIDATION`; no Godot import/editor/runtime/build/
tests, commit or push was performed for this binding. The handover limits above
remain applicable to final-art acceptance.
