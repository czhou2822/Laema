# Original Heroes III Skeleton

User-approved base Necropolis prototype integration, October 23, 2026.
Original third-party artwork remains attributable to its rights holders; this is
not generated Laema artwork, a license grant or final-art acceptance.

Preservation master: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CSKELE.def`.
SHA256: `3cb2a3ad4a4faaec0cc38c0cb38a71a7c2e67e93ac88ba9d389f5157e302df78`.
Source metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CSKELE/metadata.json`.
SHA256: `9b158834ed1e305a81a7516ed3e74ea0e9b598ad322fdc30b459b739fc7147af`.

The PNGs below are byte-identical copies of the collection's RGBA preview
sheets. Original palette colors, frame order, 450x400 character canvases and
canvas offsets are retained. No cropping, repainting, resampling or alpha edit
was applied. Original DEF/indexed/palette masters remain in the reference
collection; preview shadow/transparency interpretation is unchanged.

| Runtime sheet | Source group | Frames | Source file | SHA256 |
| --- | ---: | ---: | --- | --- |
| Idle.png | 2 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CSKELE/group_02_block_02_page_00.png | cb30b93537107792e35a537f8fb1b9fad9721cdf56caa4dba9065fa7bdc2583a |
| Walk.png | 0 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CSKELE/group_00_block_00_page_00.png | d5a94bb8f15786b02837c1f0de3cf4139942c09202025cf919b103dc6439e39a |
| Hurt.png | 3 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CSKELE/group_03_block_03_page_00.png | d1885bfbfdbfc3bd214565cc519e6ae5cfaed213c38c5d1fe6b10efe090de0f4 |
| Dead.png | 5 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CSKELE/group_05_block_05_page_00.png | d4fc5649e74d69a5e02bd3c9852d3d497a46082bc1ff9a9ed9171bd3876c2bf8 |
| Attack.png | 12 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CSKELE/group_12_block_11_page_00.png | 60898f9b6fc9e90e466743576e823d12d0720081584ea3e9df1cfa78323e5f9a |

## Native registration and playback

The unchanged inherited BodyVisual(-11,31) is the shared foot position. Its
scene-authored scale is 180/78 (2.307692308) and centered offset is
(29,-67), registering the original foot anchor(196,267).
The first idle frame's opaque height is 78px. This follows the
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
