# Castle Archer prototype

## Current high-resolution presentation — October 22

After the user identified the original low-resolution artwork in Gym, the actor
was rebound to the existing generated Castle animation review collection.
The six character sheets now live in `highres_v01/`; `source-manifest.json`
records their selected source paths, source-index digest and exact file hashes.
Source package: `castle-creature-assets-v01/animations/archer`, selected through
the collection's `collection-index.json`, not raw generation/rejected folders.

These are the existing redrawn animations descended from the approved Castle
masters, with prototype animation review still pending. They are not enlarged
original pixels or newly generated drawings from this integration. All 42
selected character frames were compared with the source collection's individual
PNGs. Sheets retain four columns and 768 x 640 cells, in the same group/frame
order as the preserved originals below. The cell anchor (384, 448) maps to the
inherited BodyVisual (-11, 31) using sprite scale 1 and centered offset (0, -128).

Only character texture references, cell rectangles and sprite registration
changed. Attack marker/key times, melee query tracks, collider, AI, stats,
muzzle/projectile and sound assignments retain the current implementation.
The arrow still uses the original `Arrow.png`; the Art collection supplies no
detached high-resolution projectile. Fresh in-game visual, foot/muzzle and
hitbox-alignment review is required. Source/resource checks are not Godot import,
runtime, user-animation or final-art approval. The earlier native registration
below is historical and no longer configures the character sprite.

## Preserved original integration

The user approved adding the unupgraded Heroes III Castle Archer alongside
Pikeman, with ranged attacks and a separate melee attack at close range, on
October 22, 2026. This task belongs to Combat and remains independent of the
Castle Griffin task. These original assets are prototype reference artwork;
they do not establish final Laema production art or a new redistribution license.

## Preserved sources

Every PNG below is a byte-identical copy from the existing verified collection
`docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/`. No frames,
palette, offsets or source resolution were repainted or resampled. The source
metadata is also copied locally; original DEFs and indexed preservation masters
remain in the reference collection.

- `CLCBOW.def` SHA-256:
  `19d0bf685e3c510eb3cee6c73164ae8f30ce97c7c30841aba4f9f4c0fda6407c`
- `PLCBOWX.def` SHA-256:
  `f2f44309eb2a58bd2ce47f8a957edcb915744244b7a4b0591cb2774fd84d2ac4`

| Local sheet | Source | Group | Frames | SHA-256 |
| --- | --- | ---: | ---: | --- |
| Idle.png | CLCBOW/group_02_block_02_page_00.png | 2 | 8 | 86d522acc62988f78982809de9974559b8e23f3f6430c7fb1f11cd78742e0ae6 |
| Walk.png | CLCBOW/group_00_block_00_page_00.png | 0 | 8 | 7ae6d1b54862573e869f0da3c3ffd19b7df9e626f58f10a651a017d9ad30cb01 |
| Hurt.png | CLCBOW/group_03_block_03_page_00.png | 3 | 6 | 26827a7f9f4053abf19cb143e0e6829dce101d8ffa07555827004b2ed5c383b8 |
| Dead.png | CLCBOW/group_05_block_05_page_00.png | 5 | 6 | 13433c8fcbdf9e2b1f46c79a60a87fe8a6b381a450bd9aeb614341d56fc5fa12 |
| Melee.png | CLCBOW/group_12_block_11_page_00.png | 12 | 6 | bf14e946d2f37e8cc44b3e476b06f1c7fdf2139deb5a54b3354981df06546578 |
| Shoot.png | CLCBOW/group_15_block_14_page_00.png | 15 | 8 | d2075d1299303e04b63a81a3392dc4aee0b702227006777954a3597661a33a12 |
| Arrow.png | PLCBOWX/group_00_block_00_page_00.png | 0 | 9 | ea0013985246846ccc8239cd122f6aa011e94cc7b057d83756e5925c598e98a9 |

## Registration and execution

Actor sheets retain 450 x 400 cells, four columns and original frame order.
Sprite scale is 180 / 76; the idle body's first-frame opaque height is 76 source
pixels. The original-cell foot anchor (196, 267) maps to the inherited
BodyVisual position (-11, 31), using centered offset (29, -67). Horizontal facing
mirrors the offset, muzzle and attack geometry about that same foot anchor.
The inherited 60 x 180 capsule and shared combat Settings are preserved.

The six-frame melee clip is aliased as `melee_swing` and has its own authored
hand-to-blade geometry. The eight-frame shooting clip is `archer_shoot`.
Both use the existing one-second prototype attack baseline at native speed 1;
this is not a recovered original-game timing claim. Melee is active from 0.5
through 1.0 seconds. Shooting launches one arrow at 0.5 seconds and recovers
after its 0.625-second active boundary until animation completion at 1.0.
Attack choice and facing are committed at windup start.

Shared `attack_range` is the melee threshold; shared `aggro_range` bounds ranged
awareness. The Archer adapts the existing approach tree's stopping range to
awareness while leaving both saved values intact. There is no added retreat,
homing or melee-clash behavior for the arrow. Arrow damage and Impact are
captured from the shared enemy settings at shooting commitment.

The arrow uses horizontal source frame 4, a 30 x 30 cell at (120, 0), and the
actor's scale. Its muzzle is (64, -108), mirrored about BodyVisual X. The
one-second exported travel-duration placeholder is independent of Player Cast
settings; maximum travel uses the captured awareness range. Per-frame ray
sweeps hit Player or level geometry without jumping over a thin obstacle.
First contact consumes the arrow even if blocked, parried or ignored by
invincibility. Direct-damage resolution uses the existing HealthEvent path.
Arrows belong to the root-owned `enemy_projectiles` group for encounter cleanup.

Pikeman-specific audio streams are cleared on this scene; Archer SFX are
unassigned. No generated art or new sound assignment is claimed.

Validation: both new scripts pass standalone GDScript grammar parsing; resource
references and attack-cell bounds were inspected, all seven runtime PNGs match
their original source bytes, and diff whitespace checks pass. These checks do
not establish Godot type checking or import success. No Godot/editor/runtime,
build, automated-test, animation-audition or gameplay validation is claimed.
Muzzle alignment, melee coverage, both facings, blocking, parry, interruption,
death, retry and shared-selector behavior require a user run.
