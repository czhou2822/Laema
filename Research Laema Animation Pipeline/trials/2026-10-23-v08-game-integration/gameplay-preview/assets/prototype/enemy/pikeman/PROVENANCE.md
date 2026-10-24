# Heroes III Pikeman — CombatEnemy prototype presentation

Current runtime presentation is the user-approved corrected generated repaint
under [repaint_v02/](repaint_v02/PROVENANCE.md). The native originals below are
preserved unchanged as reference/history; they no longer supply CombatEnemy's
live textures. The new provenance records registration, source hashes, unchanged
gameplay timing and the known drawing-versus-hitbox mismatch.

## Preserved original presentation — historical

User-approved visual replacement, October 20, 2026. Only CombatEnemy uses these
assets; permanent practice targets retain their existing artwork.

Source: the user's installed Heroes of Might and Magic III Complete Edition,
extracted into `docs/art/references/heroes3-original-flipbooks/`. These five RGBA
preview sheets are byte-identical copies from `sprites/H3sprite/CPKMAN/`.
Original artwork belongs to its respective rights holders; this is prototype
reference artwork, not original Laema production art or a new asset license.

The preserved source DEF is `originals/H3sprite/CPKMAN.def`, SHA-256
`f6fa622a5452b561beeb285bc234c14d728a301576357b9b41c6d0ae8b01b94c`.
The original frame order, palette colors, 450 × 400 canvas, and frame offsets
remain intact. RGBA transparency/shadows retain the extraction's documented
preview interpretation; the DEF and indexed sheets remain preservation masters.

| Local sheet | Source sheet | Group | Frames | SHA-256 |
|---|---|---:|---:|---|
| Idle.png | group_02_block_02_page_00.png | 2 | 7 | c36da403c8616d20ea80ebe3a432527fd9767dc9f34ab01d9bc07a44d96f8753 |
| Walk.png | group_00_block_00_page_00.png | 0 | 6 | aec4831ebd715de4a1955846723ba26567c5cadba520545949607075096ff240 |
| Hurt.png | group_03_block_03_page_00.png | 3 | 6 | 7ace3e997ad69c6a5605c1e646495129d008b7257fd4aa1585f5dd3b4fda16a0 |
| Dead.png | group_05_block_05_page_00.png | 5 | 5 | 88e4f546bdf3eea10605c1ed519977611f02795e5f00eef59bd3e5d716f9fe1f |
| Attack.png | group_12_block_11_page_00.png | 12 | 10 | 2611a2a0cfa719510271860324f012f8d1abd887987b609c22487daecbdb3676 |

Group meanings follow <https://vcmi.eu/modders/Animation_Format/>: movement,
idle, hit, death, and front melee attack. Every sheet has four columns; frame
coordinates must wrap to subsequent rows. No blank padding cell is a frame.

## Integration

- CombatEnemy's Sprite2D uses uniform scale `68 / 95` to match the preceding
  fighter's 68-pixel opaque idle height to the Pikeman's 95-pixel opaque height.
- The shared canvas foot anchor `(196, 268)` maps to `(-6, 64)` relative to the
  sprite's unchanged `(0, -21)` position. Centered Sprite2D offset is therefore
  `(20.617647059, 21.411764706)`. The same scale/offset applies to every group;
  horizontal mirroring also negates the sprite's horizontal offset, preserving
  the mirrored anchor instead of moving the fighter across its padded canvas.
  No collider is resized.
- Idle remains 8 fps; walk remains 9 fps; death remains 8 fps and holds its last
  frame. Hurt uses all six frames over the existing captured reaction duration.
- Following the user's speed adjustment, the front attack uses the original
  Pikeman base attack duration: `1.00` second, read directly from the `Pikeman`
  row of `CrAnim.txt` in both installed `en/Data/H3ab_bmp.lod` and
  `en/Data/H3bitmap.lod` (the `Attack Animation Time` column). Both rows agree.
  This is the data-file base duration, not a claim to reproduce every original
  game's battle-speed setting. The DEF itself stores no per-frame timing.
- Ten frames are evenly keyed at 10 fps. Frame 5 (zero-based, fully extended
  thrust) and the contact/active-start markers now occur at `0.5` seconds;
  frame 0 returns and the active interval ends at `1.0` second. Geometry key
  times follow contact; geometry values are unchanged. The previous Laema
  `1.1`-second windup / `1.3`-second total is superseded.
- Damage, Poise, Impact, AI logic, reaction lifetime, knockback, and actor
  collision stay intact.

Validation: source/sheet/static checks only. No Godot/editor/runtime/build/test
run is claimed for this replacement; visual alignment and feel await user review.
