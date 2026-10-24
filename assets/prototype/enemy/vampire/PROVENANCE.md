# Original Heroes III Vampire

User-approved base Necropolis prototype integration, October 23, 2026.
Original third-party artwork remains attributable to its rights holders; this is
not generated Laema artwork, a license grant or final-art acceptance.

Preservation master: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CVAMP.def`.
SHA256: `5d0d2c832aa0e9d6cf1757d281d242b300cbfb89120e9462dc1726452a9ef476`.
Source metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CVAMP/metadata.json`.
SHA256: `50d5d6559011629ce4d6a3fcbb8dc37a41b353318b59dc09231f05df758a81b0`.

The PNGs below are byte-identical copies of the collection's RGBA preview
sheets. Original palette colors, frame order, 450x400 character canvases and
canvas offsets are retained. No cropping, repainting, resampling or alpha edit
was applied. Original DEF/indexed/palette masters remain in the reference
collection; preview shadow/transparency interpretation is unchanged.

| Runtime sheet | Source group | Frames | Source file | SHA256 |
| --- | ---: | ---: | --- | --- |
| Idle.png | 2 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CVAMP/group_02_block_02_page_00.png | ddb773cbb91d797d250bce2411ea9b7ccdc0aab1074ca24ebb9104ae956c03e8 |
| Walk.png | 0 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CVAMP/group_00_block_00_page_00.png | 9e9f8fdd1411146973e3771d95cf5e7d5212a2ed15bc363b5f7b76f438fd48c9 |
| Hurt.png | 3 | 7 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CVAMP/group_03_block_03_page_00.png | 75bee3b91831302894db29175430c1182777354c3b119daa7313fb44d031386c |
| Dead.png | 5 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CVAMP/group_05_block_05_page_00.png | 7e5a1ad105fbbd3edaaced9ac3188f5f2977ac63b1ed3a330c29b8f485542d75 |
| Attack.png | 12 | 7 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CVAMP/group_12_block_11_page_00.png | cc43bf87508a05869cbcdcf42e868befef7b6f7adce93920893bfc877b1c39e8 |

## Native registration and playback

The unchanged inherited BodyVisual(-11,31) is the shared foot position. Its
scene-authored scale is 180/84 (2.142857143) and centered offset is
(29,-67), registering the original foot anchor(196,267).
The first idle frame's opaque height is 84px. This follows the
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
