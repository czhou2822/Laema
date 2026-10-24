# Castle Monk prototype

The user approved adding the base Castle Monk with the existing Archer ranged
and close-melee behavior on October 22, 2026. Monk uses the shared CombatEnemy
settings and AI baseline. No Zealot behavior, damage school, healing, reflection,
status effect or new audio cue is added.

## Selected character animation

The six byte-identical character atlases in `highres_v01/` come from the selected
`castle-creature-assets-v01/animations/collection-index.json`, creature `monk`.
`highres_v01/source-manifest.json` records that index's digest, selected sheet
paths, counts and file hashes. Source `frames` entries define the original
timeline order; no raw generation or rejected candidate was substituted.

| Local sheet | Selected source sheet | Group / block | Frames |
| --- | --- | --- | ---: |
| Walk.png | monk/group_00_block_00/atlas_source.png | 0 / 0 | 6 |
| Idle.png | monk/group_02_block_02/atlas_source.png | 2 / 2 | 6 |
| Hurt.png | monk/group_03_block_03/atlas_source.png | 3 / 3 | 8 |
| Dead.png | monk/group_05_block_05/atlas_source.png | 5 / 5 | 11 |
| Melee.png | monk/group_12_block_11/atlas_source.png | 12 / 11 | 8 |
| Shoot.png | monk/group_15_block_14/atlas_source.png | 15 / 14 | 10 |

All cells are 768 x 640, four columns, with cell-space anchor (384, 448).
Sprite scale 1 and centered offset (0, -128) map that anchor to the inherited
BodyVisual position (-11, 31). The inherited 60 x 180 collision capsule and
sprite-facing owner are preserved. Source orientation retains the original
gestures and attack angles; Sprite2D supplies the facing mirror.

The source manifest identifies original `Cmonkk.def` SHA-256
`d11b9cce2da77a8df59e1a274a678cc653031311974f0ba0165f7f89d790fe9f`
and the accepted Monk static master. Its animation status is
`exported_candidate_requires_art_review`: these generated animations remain
prototype review candidates. The source production report retains robe, hood,
cord, hand-detail and burst-style review limits. Its 10fps previews are
illustrative and supply no recovered Heroes timing contract.

## Preserved original bolt

The selected high-resolution collection supplies no detached Monk projectile.
`Bolt.png` is a byte-identical copy of
`docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CPRZEAX/group_00_block_00_page_00.png`.
`source-bolt-metadata.json` preserves its original metadata. The original
`CPRZEAX.def` digest is
`361a503c9016647a4e062044dbbbffe9580a0e409525faf27fae5ef4726c4c9f`.

[VCMI's Castle source configuration](https://raw.githubusercontent.com/vcmi/vcmi/develop/config/creatures/castle.json)
explicitly maps base `monk` / `CMONKK.DEF` to `CPRZEAX.DEF`; the bolt is shared
with Zealot in that reference. This association is source evidence for the art,
not authority to import another game's gameplay rules. Horizontal frame 4 is
the 60 x 60 region at (240, 0), displayed at scale 1. No projectile pixels were
repainted, resampled or extracted from a character frame. The original artwork
is prototype reference art and establishes no new redistribution license.

## Existing execution contract

`monk.tscn` inherits `archer.tscn`, overrides the character presentation and
native clips, and sets its exported projectile scene to `monk_bolt.tscn`.
The animation aliases remain `melee_swing` and `archer_shoot`, as required by
the existing action owner. Both clips use the approved temporary 1.0-second
baseline. Melee remains active 0.5 through 1.0 seconds; shooting launches once
at 0.5, ends its active phase at 0.625 and recovers through 1.0.

All Archer melee query tracks and key times are preserved as temporary geometry.
The inherited muzzle (64, -108), committed facing, shared melee threshold,
awareness limit, captured damage/Impact, travel duration, interruption and reset
semantics are unchanged. The bolt reuses `enemy_arrow.gd`: root-owned straight
flight, Player/level ray sweep, existing unschooled direct HealthEvent,
first-contact consumption and `enemy_projectiles` encounter cleanup. It does
not participate in simultaneous melee clashes. All inherited Pikeman audio
streams are null.

## Validation boundary

Source hashes, frame/cell comparisons, references, animation data and whitespace
are inspected statically. These checks establish no Godot type/import/editor,
runtime, gameplay, animation-smoothness or final-art approval. Both facings,
feet, hand/muzzle/bolt alignment, temporary melee coverage, block/parry,
interruption, death, retry and selector behavior require a user run.

Status: `AWAITING_USER_VALIDATION`.
