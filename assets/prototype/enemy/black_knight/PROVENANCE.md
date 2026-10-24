# Original Heroes III Black Knight

User-approved base Necropolis prototype integration, October 23, 2026.
Original third-party artwork remains attributable to its rights holders; this is
not generated Laema artwork, a license grant or final-art acceptance.

Preservation master: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CBKNIG.def`.
SHA256: `68758791ac3be0ae5426797775cb7c564e6220d0e54154adac6d6094f68742c4`.
Source metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CBKNIG/metadata.json`.
SHA256: `67611be7e7362719deb39fed774afd14638ac023b525d8f7399d2b4efafc4f99`.

The PNGs below are byte-identical copies of the collection's RGBA preview
sheets. Original palette colors, frame order, 450x400 character canvases and
canvas offsets are retained. No cropping, repainting, resampling or alpha edit
was applied. Original DEF/indexed/palette masters remain in the reference
collection; preview shadow/transparency interpretation is unchanged.

| Runtime sheet | Source group | Frames | Source file | SHA256 |
| --- | ---: | ---: | --- | --- |
| Idle.png | 2 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CBKNIG/group_02_block_02_page_00.png | 735db9187e9d3b9a44b156a74eb771f93eeb25572944e8b81b315e5d7e35e8ba |
| Walk.png | 0 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CBKNIG/group_00_block_00_page_00.png | 97ea9b842c0952d76f24a506d82ecf39b3e4d2811afdfe25efab6015a64cf754 |
| Hurt.png | 3 | 6 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CBKNIG/group_03_block_03_page_00.png | 177d444607e277d230392d4b37e27419f0e80d8acafb97119d3d254c5eb4f388 |
| Dead.png | 5 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CBKNIG/group_05_block_05_page_00.png | e3fc18dedf807681ed4bd7bfba5fa03d4a0105f75ac4578be17e32b25f5563cc |
| Attack.png | 12 | 8 | docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CBKNIG/group_12_block_11_page_00.png | d963beee2e1a7fb89d1b835ffb0e9ea2024742b22aab37e9b78f050d49f25ecd |

## Native registration and playback

The unchanged inherited BodyVisual(-11,31) is the shared foot position. Its
scene-authored scale is 180/98 (1.836734694) and centered offset is
(7,-67), registering the original foot anchor(218,267).
The first idle frame's opaque height is 98px. This follows the
existing original-Archer/Griffin registration convention while retaining the
same 60x180 capsule and bottomY31. One anchor applies across all source groups;
the existing horizontal-facing path mirrors the offset about that anchor.
Original floating/wing/horse motion is artwork, not a new movement rule.

Idle plays at8fps, movement at9fps, Hurt spans the existing captured reaction
duration, and Death plays at8fps with its last frame held. The native melee
clip preserves the current1.0s clock, active0.5..1.0 and exact copied AttackCast
tracks from config/attack_animations/melee_swing.tres. Source frames remain in
order; frame4 is placed at active_start0.5, remaining return
frames finish at0.9, and frame0 is restored at1.0. This is prototype presentation
timing, not recovered original-game playback or final weapon/contact tuning.

Shared Settings, behavior tree, damage/Poise/Impact, reactions, grounded
collision, interruption and encounter reset retain their existing owners.
Inherited Pikeman sounds are null; no new SFX, flying, resurrection or life
drain is added. source-manifest.json records exact files, frame names and keys.

Validation is static only. Godot import/editor/runtime, both facings, feet,
attack/hitbox alignment, reactions, death, reset and saved selection require the
user's run.
