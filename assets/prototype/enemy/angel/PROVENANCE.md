# Castle Angel prototype assets

User-approved implementation slice, October 22, 2026. This is the base Castle
Angel, using existing generated review artwork selected through
`castle-creature-assets-v01/animations/collection-index.json`.
The accepted static master and this animation candidate have separate status:
binding the sheets does not establish final animation or artwork acceptance.

Five byte-identical source-orientation atlases are copied into `highres_v01/`.
Its `source-manifest.json` records portable collection paths, the source-index
digest, sheet hashes and ordered individual-frame hashes. No raw generation,
rejected candidate, low-resolution original or mirrored sheet is bound.

| Runtime sheet | Selected group / block | Frames |
| --- | --- | ---: |
| Idle.png | 2 / 2 | 8 |
| Walk.png | 0 / 0 | 7 |
| Hurt.png | 3 / 3 | 6 |
| Dead.png | 5 / 5 | 8 |
| Attack.png | 12 / 11 | 6 |

All 35 populated atlas cells were compared with their selected individual PNGs
using exact decoded RGBA equality. Atlases retain four-column row-major order
with 768 x 640 cells. The nominal source anchor (384, 448) maps to the inherited
BodyVisual position (-11, 31) at sprite scale 1 and centered offset (0, -128).
Sprite2D supplies the single facing mirror; padding cells are never sampled.
The source's airborne and collapsed artwork offsets are retained. Wing motion
and airborne drawings do not add flying behavior.

`scenes/enemy/angel.tscn` inherits CombatEnemy's shared Settings, behavior tree,
grounded movement, collider and reactions. Idle and Death use the existing
8 fps playback, movement uses 9 fps, and Hurt spans the captured reaction
duration. Death holds the terminal pose.

The creature's own `angel_melee.tres` retains the `melee_swing` alias, existing
1.0-second length, active_start/timing_split at 0.5, active_end at 1.0 and all
existing melee AttackCast geometry keys. Six Angel poses occupy equal sixths
of the action, returning to pose 0 at 1.0 seconds. This is a provisional Laema
presentation mapping, not recovered original-game timing or Angel-specific
hitbox tuning. Attack, Hurt, Death and Movement audio streams are unassigned.
No healing, resurrection, new stats, combat rules or AI were introduced.

Validation is source-byte, raster and static resource inspection only.
Representative Idle, Walk, Hurt, terminal Death and Attack frames were viewed
before binding. No Godot import, editor, runtime, build or automated tests were
run. Motion, both facings, grounding, weapon/hitbox alignment, reactions, death
and restart remain for human Gym review.
