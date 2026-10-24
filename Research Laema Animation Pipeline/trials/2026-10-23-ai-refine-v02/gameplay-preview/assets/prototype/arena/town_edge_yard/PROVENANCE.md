# Town-edge practice yard — Gym framing05 / v02

The user selected framing05 and authorized its background/framing implementation
while Art produces the separate live Pikeman flipbooks. Runtime uses the matching
pair from Art's `town-edge-yard-assets-v02` package, task
`01a07f41-7159-70f1-ac7d-e6217941c130`. Its HANDOFF.md and manifest.json are the
source record; `town-edge-yard-framing-round-02/mockup-05.png` is the composition
reference, not a runtime texture. No actor, HUD or screenshot is baked into these
runtime PNGs. Generated environment art and the original Heroes III material
references retain the distinct provenance described below.

| Runtime file | Size | SHA-256 |
|---|---|---|
| town_edge_yard_v02_background.png | 1280 × 610 | 77505225af08c4dd2c9ecac8d3043fd0802864d8d4c527b33a2c968bf914324a |
| town_edge_yard_v02_ground.png | 1280 × 110 | 1adeeb408f23a82348f9216f07d6e7732296b217e78128b0e011ba19a9cfd5e7 |

Both are byte-identical source copies, top-left-origin Sprite2Ds at unit scale
with existing linear filtering. In Gym only, Backdrop is at (-640, -558), Ground
at (-640, 52), and CameraAnchor at (0, -198). The join is -558 + 610 = 52,
matching the unchanged physical floor top 68 - 32/2. At 1280 × 720, zoom 1,
the source-based projection is floor screen y610: 52 - (-198) + 360.
The 110-pixel foreground covers the remaining 15.3% of the frame.

Gym enables the existing HUD's optional compact-bottom presentation: Heat and
orb/Spell Level panels start at screen y648, targeting 64-pixel heights. All live
values, ten orb slots, charging/Heat bars, objective and developer UI are retained.
Other arenas leave the presentation flag false. Current live actors, spawns,
colliders, AI, combat geometry/timing and shared settings are unchanged. The
eventual 180-pixel fighter presentation is separate pending Art work.

No Godot/import/editor/runtime/build/test process was run for v02. Source hashes,
PNG dimensions and placement/scene-source checks are static evidence only.
Godot will generate imports on the user's next ordinary open. Live baseline
coverage, HUD minimum sizing/overflow flinch, feet alignment, movement and Retry
need user validation. The plates are not seamless; expanded aspect ratios are
not validated. The old v01 files remain intact as recoverable historical assets.

## Previous Gym preview v01 — historical, superseded above

User-selected concept: candidate 02, town-edge practice yard. Art produced the
assets and handed their bounded Gym integration to DUM-E on October 20, 2026.
This is a reversible static preview, not a final location or production-art lock.

Source package: `town-edge-yard-assets-v01`, Art task
`01a07f41-7159-70f1-ac7d-e6217941c130`. Its `HANDOFF.md`, `manifest.json`,
`PROMPTS.md`, and `placement_guide.png` retain the production record. The two
runtime PNGs below are byte-identical copies of Art's exports; annotated guides,
concept art, and offline previews are not runtime assets.

| Runtime file | Size | SHA-256 |
|---|---|---|
| town_edge_yard_background.png | 1280 × 544 | 58fa5ea207d7745485c1db4aef8a0fb675f528898f69539f3d6b2d1b44137b73 |
| town_edge_yard_ground.png | 1280 × 416 | 26022435095d8b509f4a3d69d84ecda2099575dfa67c9152b989a12c19226c20 |

The environment was generated with the built-in image tool and mechanically
split from one 1280 × 960 master. Earlier composition referenced original
Heroes III Castle/tavern materials and the retained Laema-with-hammer concept;
the runtime plates contain no baked character, hammer, HUD, or actor shadow.
Generated scenery, original Heroes III references, and licensed prototype
assets retain distinct provenance. Painted equipment is non-interactive scenery.

## Placement and import

Only `scenes/stages/gym_area.tscn` uses this pair. Both Sprite2D nodes have
top-left origins, unit scale, and node-local linear filtering:

- Backdrop: position `(-640, -492)`, z-index `-4`.
- Ground: position `(-640, 52)`, z-index `-2`.
- Shared edge: `-492 + 544 = 52`, matching collision-floor top `68 - 32/2`.
- Fixed camera `(0, 0)` at 1280 × 720 sees master rows 132–851. Ground coverage
  ends at world y468, 108 pixels below the normal viewport.

PNG import sidecars follow the existing lossless CompressedTexture2D importer
settings. Godot generates the referenced `.godot/imported` texture cache on its
next ordinary asset import; no editor/export/import process was run here.

The pair is one static composition, not parallax layers or seamless tiles. Keep
their relative placement/scale together. Other aspect ratios need a separate
coverage review. Tutorial/FinalArena art, actors, colliders, camera, settings,
combat, and HUD are outside this preview change.

Validation: file hashes, decoded dimensions, exact pair/master reconstruction,
placement math, and scene-source preservation were checked offline. Live feet,
HUD contrast, combat silhouettes, and retry appearance await user validation.
