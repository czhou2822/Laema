# Castle Swordsman prototype assets

User-authorized Castle level 4 prototype integration, October 22, 2026.
The base creature is Swordsman (`Csword`), not Crusader. Original Heroes III
reference artwork belongs to its respective rights holders.

## Selected high-resolution presentation

The five runtime sheets in `highres_v01/` are byte-identical copies selected
through `castle-creature-assets-v01/animations/collection-index.json`.
They are existing generated animation review candidates descended from the
accepted Swordsman static master. No original low-resolution sheet, raw
generation or rejected candidate is used as a runtime character texture.
`highres_v01/source-manifest.json` records the portable selected source paths,
index and sheet hashes, original group/block mapping and static-master digest.

| Runtime sheet | Original group / block | Frames |
| --- | --- | ---: |
| Idle.png | 2 / 2 | 8 |
| Walk.png | 0 / 0 | 8 |
| Hurt.png | 3 / 3 | 6 |
| Dead.png | 5 / 5 | 6 |
| Attack.png | 12 / 11 | 7 |

Each atlas is 3072 x 1280, with four columns of 768 x 640 transparent cells in
the selected frame order. All 35 selected atlas cells were compared with the
collection's individual source-orientation PNG frames; unused padding is never
sampled. Sprite2D supplies the facing mirror. Cell anchor (384, 448), sprite
scale 1 and centered offset (0, -128) register at the inherited BodyVisual
position (-11, 31). The inherited 60 x 180 body capsule remains unchanged.

## Existing combat contract

`scenes/enemy/swordsman.tscn` inherits CombatEnemy and its shared Settings,
behavior tree, grounded approach, collision rules, reactions and feedback.
`swordsman_melee.tres` retains the external `melee_swing` alias, 1.0-second
length, active start at 0.5, timing split at 0.5, active end at 1.0, and all
temporary Pikeman-derived AttackCast geometry keys copied from Griffin's
existing prototype melee resource. Shared Pikeman geometry overrides are
disabled for this native creature clip, following Griffin and Archer.

The seven source attack poses play in order at 0, 1/7, 2/7, 3/7, 4/7, 5/7 and
6/7 seconds; the sprite returns to attack pose 0 at 1.0 seconds. Idle plays at
the existing 8 fps, movement at 9 fps, Hurt spans the captured reaction duration,
and Death plays at 8 fps with its terminal pose held. These are Laema prototype
presentation mappings. The source collection has no original timing contract;
its 10 fps GIFs are illustrative only.

All four inherited Pikeman audio streams are explicitly null for this
prototype, following the existing unassigned-audio convention. No Swordsman
cue assignment, new ability, creature-specific tuning or audio audition is
claimed.

## Validation limits

Representative idle and forward-attack source frames were visually inspected.
Checks cover source bytes, decoded frame equality, atlas bounds and static
resource references only. No Godot import, editor, runtime, build or automated
tests were run. Both facings, feet, attack/weapon alignment, reactions, death,
retry and Final Arena completion require user validation. The inherited hit
geometry is temporary and has not been aligned to this sword artwork.

The source handoff retains visual limits around blade length/foreshortening,
wrist and free-hand shape, collapse joints, face/cloth continuity and motion
seams. Complete frame coverage and successful file checks grant no final
animation, art, gameplay or balance acceptance.
