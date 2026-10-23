# Ghost Dragon animation remaster v01

Worker candidate asset package: 61 newly drawn source poses, 15 original groups,
88 source positions per facing. No idle-master reuse, original-pixel deliverables,
code-painted anatomy or warped-master animation. All new art used built-in
imagegen. Original master, DEF, metadata and all 88 indexed source crops match
their recorded hashes.

Outputs are in `assets/prototype/enemy/ghost_dragon/remaster_v01/`: transparent
1024 x 768 registered poses, exact mirrors, four-column group atlases, 176 frame
PNGs, 30 review GIFs, 15 source/candidate contacts, two preview-only SpriteFrames
resources and `source_manifest.json`. Source order, repeats and turn aliases
7/9 and 8/10 are preserved. Parent owns publication and engine validation.

Mali review followed the actual original silhouettes and camera changes. Repairs
corrected backward recoil/hidden skull views, defensive skull direction, a clipped
turn claw, melee tail arcs, upper reach, upward front-windup skull and flying
digits. Good figures were retained when neighboring figures needed repair.
Intentional death fragments were retained as whole source clusters, including the
falling skull, ribs, wing spars and final low heap. No intact idle fills them.

Native exported phase drawings have binary alpha gaps. The selected new artwork
interprets those visibility changes as continuous partial alpha, not decorative
checker texture. Measured selected alpha is in `selected-art-alpha-evidence.json`;
native evidence is in `exported-source-alpha-evidence.json`. Prompt opacity
numbers are requests, not exact measured source opacity. Pixel-level dither,
palette/engine behavior and original timing are not established. These remain
interpretation and validation limits, not new gameplay or standalone VFX.

All 61 poses were inspected through original guides, raw artwork, native-scale
and fixed-registration comparisons. All 15 source-ordered group contacts and
both-facing GIF decode contacts were inspected, including entries, exits, repeats,
turns and death progression. This is static decoded-frame review, not real-time
playback. The parent directly resolved the displayed flying-toe concern on both
mattes; that does not establish general human animation acceptance.

`visual-review.json` supplies per-pose and per-group observations and fresh hashes.
`exact-generation-provenance.json` retains exact prompts, reference hashes, raw
hashes and actually returned tool metadata; unsuccessful attempts remain saved.
`input-verification.json`, `gif-decode-evidence.json`, `spriteframes-export.json`
and the before/after validation JSON files record mechanical evidence. No browser,
Godot, editor or runtime validation is claimed. No unresolved blocking anatomy,
clipping, missing-pose or source-order defect remains in worker review.
