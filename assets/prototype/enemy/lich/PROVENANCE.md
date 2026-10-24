# Original Heroes III Lich

User-approved base Necropolis prototype integration, October 23, 2026.
Original third-party artwork remains attributable to its rights holders; this is
not generated Laema artwork, a license grant or final-art acceptance.

Preservation master: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CLICH.def`.
SHA256: `409506a7915b25cb0a3fd7c722e378dd0735e26757c1896aba8d2bcd45ef9d54`.
Source metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CLICH/metadata.json`.
SHA256: `907408609ca99ae1efe24d3a388021a4cb779a37e8eef280552350dbe8943e70`.

The PNGs below are byte-identical copies of the collection's RGBA preview
sheets. Original palette colors, frame order, 450x400 character canvases and
canvas offsets are retained. No cropping, repainting, resampling or alpha edit
was applied. Original DEF/indexed/palette masters remain in the reference
collection; preview shadow/transparency interpretation is unchanged.

| Runtime sheet | Source group | Frames | Source file | SHA256 |
| --- | ---: | ---: | --- | --- |
| Idle.png | 2 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CLICH/group_02_block_02_page_00.png | fb51f0c4741da8b6d38d8ddd0e3d336c49bda4ce0ef695853289b70fb27edc7e |
| Walk.png | 0 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CLICH/group_00_block_00_page_00.png | ebfff91a309d4e70c6e0fec6411334f10085e071c2f61d37e3dd1f48e70e90af |
| Hurt.png | 3 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CLICH/group_03_block_03_page_00.png | f71f978168f118d01aa8e793cd71ab3f0560b0719976f72e58e6e919d030e7db |
| Dead.png | 5 | 7 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CLICH/group_05_block_05_page_00.png | ebddd95040246342b3a19728764d3c24ee1c1b05c0ca529b6c02abbb7b6bd257 |
| Attack.png | 12 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CLICH/group_12_block_11_page_00.png | cce2d5e6200ce6c6d6f5f7d4e71694773c1256da25faf0cf993738b8cdcf5367 |
| Shoot.png | 15 | 11 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CLICH/group_15_block_14_page_00.png | 2a082076cb647dcce5141fee07ab999dffb8072c152910ebd4d339bad78bd94a |
| Projectile.png | 0 | 9 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/PLICH/group_00_block_00_page_00.png | fa9eb3d38a5ebf3fd4df9ce76f1c6f6627577d40d299b2c724a04eb4b4f22502 |

## Native registration and playback

The unchanged inherited BodyVisual(-11,31) is the shared foot position. Its
scene-authored scale is 180/91 (1.978021978) and centered offset is
(29,-67), registering the original foot anchor(196,267).
The first idle frame's opaque height is 91px. This follows the
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

Lich uses the existing Archer ranged/close-melee owner and a separate native
shooting clip. Source shooting frame3 reaches launch0.5, active_end remains
0.625 and the full clock remains1.0s. The source staff-tip reference(260,184)
maps through the same scene registration to the exported arrow_origin.
Projectile.png is the original PLICH directional sheet. Its preservation master
is `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/PLICH.def`, SHA256
`7f727a9cbf1351e065c89dc3ea8095136efe9a7329da5396f9e28c15d0e4bc15`; metadata source and digest are
recorded in source-manifest.json. Horizontal frame4 is
Rect2(140,0,35,35), rendered at the character's scale through the existing
enemy_arrow.gd direct-hit/wall-sweep/cleanup path. No death-cloud area damage
or new projectile behavior is introduced.

Shared Settings, behavior tree, damage/Poise/Impact, reactions, grounded
collision, interruption and encounter reset retain their existing owners.
Inherited Pikeman sounds are null; no new SFX, flying, resurrection or life
drain is added. source-manifest.json records exact files, frame names and keys.

Validation is static only. Godot import/editor/runtime, both facings, feet,
attack/hitbox alignment, reactions, death, reset and saved selection require the
user's run; also check muzzle, ranged/melee choice and projectile cleanup.
