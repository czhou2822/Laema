# Castle Cavalier prototype assets

User-authorized integration, October 22, 2026. This is the base Castle Cavalier,
not Champion. The selected generated animation review collection descends from
the approved Cavalier static master; animation, final artwork and Godot runtime
acceptance remain separate and unverified.

## Selected sources and registration

Source package: `castle-creature-assets-v01/animations`, selected through its
`collection-index.json` Cavalier entry. `highres_v01/source-manifest.json` records
the source index, creature manifest and QA-note digests, selected relative sheet
paths, frame counts, exact sheet hashes and this integration's file checks.
No raw, rejected or superseded generation is selected.

| Runtime sheet in highres_v01/ | Source group / block | Frames |
|---|---|---:|
| Idle.png | 2 / 2 | 4 |
| Walk.png | 0 / 0 | 8 |
| Hurt.png | 3 / 3 | 8 |
| Dead.png | 5 / 5 | 8 |
| Attack.png | 12 / 11 | 10 |

The five atlases are byte copies of the selected source-orientation sheets.
Their four-column, row-major 768x640 cells retain source order and repeats.
All 38 used cells match the selected individual source PNGs as decoded RGBA;
the Attack sheet's two unused cells are transparent and never sampled.

The source cell anchor (384,448) maps to inherited BodyVisual (-11,31), using
sprite scale 1 and centered offset (0,-128). Sprite2D supplies the facing mirror;
the pre-mirrored source sheets are not bound. Mounted proportions retain the
collection's rider/horse calibration rather than being scaled to a 180px total
silhouette. Original reference identity and pose metadata remain under
`docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CCAVLR/`.

## Preserved combat contract

`scenes/enemy/cavalier.tscn` inherits CombatEnemy, including the shared
`config/characters/combat_enemy.tres`, grounded movement, behavior tree,
reactions, collision and encounter lifecycle. No Cavalier charge bonus,
locomotion rule, AI or stat override is introduced. The inherited capsule remains
radius 30 / height 180 at (-11,-59), with bottom y31.

`config/attack_animations/cavalier_melee.tres` uses the existing `melee_swing`
alias, 1.0-second length, active-start/timing-split 0.5 and active-end 1.0.
Ten attack poses play in order at 0.0 through 0.9 seconds; pose 0 returns at 1.0.
AttackCast position, target and radius tracks are copied unchanged from the
existing Griffin/Pikeman baseline. `use_shared_melee_geometry` is false so the
native clip retains those authored temporary values. This mapping is a Laema
presentation contract, not recovered Heroes III timing or a new charge attack.

All four inherited Pikeman Attack/Hurt/Death/Movement streams are explicitly
null, following Archer's existing scene pattern. No Cavalier cue is assigned.

## Source limits and validation boundary

The source QA records G12's earlier invented galloping attack as superseded by
the repaired rear/lower/planted-lunge/recovery sequence, ready for prototype
review. G0 still records imperfect source hoof phases, stride paths and near/far
leg overlap. Idle proportions, Hurt rein/lance staging and Death anatomy retain
generated interpretation limits. Final collection/user acceptance and exact
source-motion fidelity are not established by the repair review.

The wide horse silhouette and lance are not represented by the inherited
humanoid capsule or provisional melee geometry. Both facings, feet, walk,
attack contact, interruption, death and encounter retry require user validation
in Godot. Source-cell/hash and static resource checks do not establish import,
playback, visual alignment, balance or final art approval. No Godot/editor,
runtime, build or automated tests were run for this component.

These are generated reinterpretations using original Heroes III references,
not original-game sprite recovery. Source-game references and generated artwork
retain distinct provenance; no redistribution permission is established here.
