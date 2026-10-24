# Castle Griffin prototype assets

## Current high-resolution presentation — October 22

After the user identified the original low-resolution artwork in Gym, the actor
was rebound to the existing generated Castle animation review collection.
Five character sheets now live in `highres_v01/`; `source-manifest.json` records
their selected source paths, source-index digest and exact file hashes. Source
package: `castle-creature-assets-v01/animations/griffin`, selected through the
collection's `collection-index.json`, not raw generation/rejected folders.

The existing drawings descend from approved Castle masters; prototype animation
review remains pending. All 37 selected character frames were compared with the
source collection's individual PNGs. Four-column sheets retain native group/frame
order using 768 x 640 cells. The cell anchor (384, 448) maps to the inherited
BodyVisual (-11, 31) using sprite scale 1 and centered offset (0, -128).

Only character texture references, cell rectangles and sprite registration
changed. Existing attack timing, marker/key times, AttackCast tracks, collider,
shared settings, AI, sounds and grounded behavior are preserved. No new art was
generated for this rebind. Fresh in-game visual, foot and hitbox-alignment review
is required; source/resource checks establish no Godot/import/runtime or final
art approval. Earlier native registration below is retained as history.

## Preserved original integration

User-authorized integration, October 22, 2026. These are original Heroes III
Castle Griffin reference assets used for this prototype, not generated Laema art.
Original artwork and audio belong to their respective rights holders.

Source sheets: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CGRIFF/`.
Preservation master: `originals/H3sprite/CGRIFF.def`, SHA-256
`6b2caaff58ead63f9ec2c737379c1f09ebaa231e662cf26395d876bb3e3e3c4c`. The original DEF, indexed sheets,
palette, canvas offsets and extraction records remain unchanged in the collection.
Copied runtime RGBA sheets are byte-identical to its preview sheets; preview
transparency/shadows retain the extraction's interpretation.

| Runtime sheet | Original sheet | Group | Frames | SHA-256 |
|---|---|---:|---:|---|
| Idle.png | group_02_block_02_page_00.png | 2 | 8 | 157f68a66463df98e3914d541ab7620dcb9cc605015d8a0075215a0d878d687a |
| Walk.png | group_00_block_00_page_00.png | 0 | 4 | b8117406d0e5ed8abc820f7359ffc42374850a01773cf320a967480c5113236c |
| Hurt.png | group_03_block_03_page_00.png | 3 | 7 | bf61c7f5613d4efea5bb57d319440a7dac2bdbdb61a48985c7e0b9af6cfea43d |
| Dead.png | group_05_block_05_page_00.png | 5 | 9 | 0a7fb7bec38c5d64476320432ad40eca96a09e80ebd40178a054eb65cd0b4d3d |
| Attack.png | group_12_block_11_page_00.png | 12 | 9 | 0184eef35ecfd5fd506d75a81e487b34e4bf7368f86c0f59aa4d2c3988333951 |

All cells are 450x400 with four columns. Padding cells are never sampled.
Idle uses eight frames at 8 fps, movement four at 9 fps, Hurt seven over the
captured reaction duration, and Death nine at 8 fps with the terminal pose held.
The native nine-pose front attack uses the existing ten-key 0.0-0.9-second clock
with pose sequence 0/1/2/3/4/4/5/6/7/8, then returns to pose0 at 1.0s.
This is a Laema presentation mapping, not a claim of original-game timing.

`scenes/enemy/griffin.tscn` inherits CombatEnemy with the same shared Settings,
body, behavior tree, collision rules and feedback lifetimes. Its native melee
Animation retains the existing 1.0s length, 0.5s active start, 1.0s active end,
all AttackCast geometry keys and per-target contact rules. The alias remains
`melee_swing`; cloning reloads this clip's actual resource path.

Sprite scale2 maps the idle pose's approximately89px height to178 local pixels,
matching the current180px body. The original idle foot anchor(218,267), centered
offset(7,-67), and BodyVisual(-11,31) register to the unchanged capsule bottom.
Facing mirrors the horizontal offset once. Native wing motion is artwork; the
actor retains the existing grounded movement and melee behavior.

The four SFX below copy the existing original-Heroes decoded PCM previews from
`docs/audio/references/heroes3-original-sfx/preview-pcm/Heroes3/` byte-for-byte.
Original bank bytes and decoding provenance remain in that collection. Existing
attack/Hurt/death/movement playback owners and SFX mix settings are retained.
No new audio edit, replacement audition or runtime audio result is claimed.

| Runtime cue in audio/ | SHA-256 |
|---|---|
| GRIFATTK.wav | 10dbaaa8782a873163375f01e671935255fec1bc28afda0360019e305ed469a9 |
| GRIFWNCE.wav | b661303d76fc57cbfaca039ba8fa1fd939bc71ab06df93d690b828d3c842b5e0 |
| GRIFKILL.wav | 33aeb72db1b0c90050de9a05f2eb780e0caa9c6c160979093f10e50265264527 |
| GRIFMOVE.wav | c9e414a435723f3668f8c87da6718cb0536e838f6355864d0dc06c59acd01685 |

Validation: byte hashes, source data and static resource inspection only.
No Godot import/editor/runtime/build/tests were run for this integration.
Both facings, feet, attack alignment, reactions, death and retry require user
validation. Existing Pikeman geometry is a temporary melee contract; the native
Griffin silhouette does not establish final hitbox tuning or artwork acceptance.
