# Original Heroes III Bone Dragon

User-approved base Necropolis prototype integration, October 23, 2026.
Original third-party artwork remains attributable to its rights holders; this is
not generated Laema artwork, a license grant or final-art acceptance.

Preservation master: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CNDRGN.def`.
SHA256: `58135b0772daff477ca118434052631255fd6e8de89d405529fa7b068f23bf3a`.
Source metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CNDRGN/metadata.json`.
SHA256: `4e8cb7cf16f847f1fe862601d8af6aa28a74b0df13911409ae57fea0186b93bd`.

The PNGs below are byte-identical copies of the collection's RGBA preview
sheets. Original palette colors, frame order, 450x400 character canvases and
canvas offsets are retained. No cropping, repainting, resampling or alpha edit
was applied. Original DEF/indexed/palette masters remain in the reference
collection; preview shadow/transparency interpretation is unchanged.

| Runtime sheet | Source group | Frames | Source file | SHA256 |
| --- | ---: | ---: | --- | --- |
| Idle.png | 2 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CNDRGN/group_02_block_02_page_00.png | d95939bedfc8b3bb5da2e795fc8b825b8637888e6b114ccdb6ca8415523aefa8 |
| Walk.png | 0 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CNDRGN/group_00_block_00_page_00.png | 89ba7ddbea98041766fd36b90f04ec962e76d82bc5a8e823bca2a2f8c29e05f2 |
| Hurt.png | 3 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CNDRGN/group_03_block_03_page_00.png | 3a1947c17320f94177a48bad6b9cc7eba81e5653415657dcf4fc2ee0dac008d5 |
| Dead.png | 5 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CNDRGN/group_05_block_05_page_00.png | fe2c5fcaf43f06ac58fc00d8d81df5db88703ddccc0fa12313c0fec1dd7b0c65 |
| Attack.png | 12 | 7 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CNDRGN/group_12_block_11_page_00.png | cb1b19843729c7261daae0ebda9d63a8950689ea265c311b8061490a4c1d4b91 |

## Native registration and playback

The unchanged inherited BodyVisual(-11,31) is the shared foot position. Its
scene-authored scale is 180/114 (1.578947368) and centered offset is
(7,-67), registering the original foot anchor(218,267).
The first idle frame's opaque height is 114px. This follows the
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
