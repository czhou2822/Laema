# Original Heroes III Wight

User-approved base Necropolis prototype integration, October 23, 2026.
Original third-party artwork remains attributable to its rights holders; this is
not generated Laema artwork, a license grant or final-art acceptance.

Preservation master: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CWIGHT.def`.
SHA256: `211ff3e4d786b50fdd3666b2f8b2e80ef44a455b47eb4f9560a562a305b52bdb`.
Source metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWIGHT/metadata.json`.
SHA256: `fa0de311d54c8c25140efcd37f9004cc32f795d68f9f7886cd7f1599b1a5c8c9`.

The PNGs below are byte-identical copies of the collection's RGBA preview
sheets. Original palette colors, frame order, 450x400 character canvases and
canvas offsets are retained. No cropping, repainting, resampling or alpha edit
was applied. Original DEF/indexed/palette masters remain in the reference
collection; preview shadow/transparency interpretation is unchanged.

| Runtime sheet | Source group | Frames | Source file | SHA256 |
| --- | ---: | ---: | --- | --- |
| Idle.png | 2 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWIGHT/group_02_block_02_page_00.png | 9f3800edc379b21902db70b151b03b21c22a01667d60df8c2418c0ee17e13e01 |
| Walk.png | 0 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWIGHT/group_00_block_00_page_00.png | c56aec921a7031b7478738e5cbb68258a0ae4d55ddc345635d547ec8ca3a17b7 |
| Hurt.png | 3 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWIGHT/group_03_block_03_page_00.png | a26ed435f70d740d2f6b5ff940866a9d66d3f3b05d1c0f7f05d2184463c2cd4a |
| Dead.png | 5 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWIGHT/group_05_block_05_page_00.png | c2808a15f92620cade3cc314e38bece410e28572810a10db5c29f14a8402722d |
| Attack.png | 12 | 7 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWIGHT/group_12_block_11_page_00.png | 940e81a4e4be05ac473f37897ccbbb25e4e5eaef551f16731bd0014f6b3554e0 |

## Native registration and playback

The unchanged inherited BodyVisual(-11,31) is the shared foot position. Its
scene-authored scale is 180/87 (2.068965517) and centered offset is
(29,-67), registering the original foot anchor(196,267).
The first idle frame's opaque height is 87px. This follows the
existing original-Archer/Griffin registration convention while retaining the
same 60x180 capsule and bottomY31. One anchor applies across all source groups;
the existing horizontal-facing path mirrors the offset about that anchor.
Original floating/wing/horse motion is artwork, not a new movement rule.

Idle plays at8fps, movement at9fps, Hurt spans the existing captured reaction
duration, and Death plays at8fps with its last frame held. The native melee
clip preserves the current1.0s clock, active0.5..1.0 and exact copied AttackCast
tracks from config/attack_animations/melee_swing.tres. Source frames remain in
order; frame3 is placed at active_start0.5, remaining return
frames finish at0.9, and frame0 is restored at1.0. This is prototype presentation
timing, not recovered original-game playback or final weapon/contact tuning.

Shared Settings, behavior tree, damage/Poise/Impact, reactions, grounded
collision, interruption and encounter reset retain their existing owners.
Inherited Pikeman sounds are null; no new SFX, flying, resurrection or life
drain is added. source-manifest.json records exact files, frame names and keys.

Validation is static only. Godot import/editor/runtime, both facings, feet,
attack/hitbox alignment, reactions, death, reset and saved selection require the
user's run.
