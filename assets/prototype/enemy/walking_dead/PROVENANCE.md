# Original Heroes III Walking Dead

User-approved base Necropolis prototype integration, October 23, 2026.
Original third-party artwork remains attributable to its rights holders; this is
not generated Laema artwork, a license grant or final-art acceptance.

Preservation master: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CZOMBI.def`.
SHA256: `fee70e4ce759b793b42def1dae19e77b3ca65baca71016d88184772c35800266`.
Source metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/metadata.json`.
SHA256: `56b566e921ea5377202a42bfe0103aa91629dd24c2093b83e9a328803a061923`.

The PNGs below are byte-identical copies of the collection's RGBA preview
sheets. Original palette colors, frame order, 450x400 character canvases and
canvas offsets are retained. No cropping, repainting, resampling or alpha edit
was applied. Original DEF/indexed/palette masters remain in the reference
collection; preview shadow/transparency interpretation is unchanged.

| Runtime sheet | Source group | Frames | Source file | SHA256 |
| --- | ---: | ---: | --- | --- |
| Idle.png | 2 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/group_02_block_02_page_00.png | 147e7617f3aa0ab3ae4f2bebfe39c754973d2fd27a999afd75ce4608c5f94a6c |
| Walk.png | 0 | 10 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/group_00_block_00_page_00.png | e16ea5fd27ea6fedae2703b053c7b253cb25450042bdf57b7218a9326cc9680e |
| Hurt.png | 3 | 7 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/group_03_block_03_page_00.png | 0c1378fa5da30e3c5fcd86b7380268849d8f27e4788aca309149760da324812d |
| Dead.png | 5 | 9 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/group_05_block_05_page_00.png | ebf7087b2262180ce90c3d23d4809af1cf50f79d064a5b3948f5090a6ae3a286 |
| Attack.png | 12 | 7 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/group_12_block_11_page_00.png | d84829d8e2e688c78d62da0c83814809e0dc11a102b4d035d13ab28f8457970f |

## Native registration and playback

The unchanged inherited BodyVisual(-11,31) is the shared foot position. Its
scene-authored scale is 180/82 (2.195121951) and centered offset is
(29,-67), registering the original foot anchor(196,267).
The first idle frame's opaque height is 82px. This follows the
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
