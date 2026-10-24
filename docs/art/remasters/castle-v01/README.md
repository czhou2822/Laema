# Castle original-group remasters — October 23, 2026

## Main merge amendment — October 24

The user authorized integration into main. Main already has 28 selectable
creatures, including seven Castle upgrades and fourteen Necropolis actors. This
merge rebinds only the seven Castle base actors described below; the other
actors retain their existing behavior, controls and artwork. Statements below
about a seven-enemy catalog describe the source-branch validation baseline, not
the merged main catalog. All fourteen remaster preview libraries remain present.

Current camera-authoring controls, Fire Player registration/tuning, shared
reactions, Castle/Necropolis cycling and upgrades are preserved. Existing engine
evidence belongs to the original branch/version; no new Godot run, matching-
version gameplay clearance or human visual acceptance is added by this merge.

All **225 original groups / 1,324 frame positions across 14 creatures** now have a high-resolution counterpart in the working depot. The 847 registered source poses use **633 newly generated drawings and 214 existing high-resolution drawings**. No original pixel-art frame was enlarged as a deliverable. Each group has its own PNG even when its source is an exact alias.

The user authorized generation from the original flipbooks after reviewing the inventory. These are new source-guided remasters, not recovered high-resolution masters. The original audit remains a historical pre-generation snapshot.

## Coverage

| Creature | Original DEF | Groups | Frame positions | New poses | Reused hi-res poses |
| --- | --- | ---: | ---: | ---: | ---: |
| Pikeman | CPKMAN | 13 | 80 | 25 | 25 |
| Halberdier | chalbd | 13 | 67 | 50 | 0 |
| Archer | CLCBOW | 18 | 100 | 40 | 37 |
| Marksman | CHCBOW | 18 | 101 | 75 | 0 |
| Griffin | CGRIFF | 15 | 91 | 27 | 26 |
| Royal Griffin | Crgrif | 15 | 91 | 53 | 0 |
| Swordsman | Csword | 15 | 80 | 22 | 32 |
| Crusader | Ccrusd | 15 | 80 | 54 | 0 |
| Monk | Cmonkk | 17 | 113 | 25 | 27 |
| Zealot | Czealt | 20 | 154 | 69 | 0 |
| Cavalier | CCAVLR | 15 | 87 | 36 | 37 |
| Champion | CCHAMP | 15 | 87 | 73 | 0 |
| Angel | cangel | 18 | 98 | 27 | 30 |
| Archangel | CRANGL | 18 | 95 | 57 | 0 |
| **Total** | | **225** | **1,324** | **633** | **214** |

[Complete inventory](inventory.csv) · [Machine-readable inventory](inventory.json) · [Original-versus-remaster viewer](preview.html) · [Pre-generation audit](../../reviews/2026-10-23-castle-animation-parity-audit/README.md)

## Depot assets and sources

Each creature has `assets/prototype/enemy/<creature_id>/remaster_v01/` containing:

- `group_XX_block_YY.png`: source-ordered, four-column RGBA group sheets with all original frame positions.
- `original_groups.tres`: native Godot SpriteFrames resource with every original group; adjustable **10 fps preview timing is provisional**, not recovered original timing.
- `source_manifest.json`: source identities, original opaque-body coordinates, frame ordering, aliases, hashes, registration and art provenance.
- `poses/`: registered individual drawings and provenance. `_source/`: retained raw generated artwork, prompts/guides where recorded, and technical isolation sources. Both folders are excluded from duplicate Godot image imports.

Original source artwork remains under `docs/art/references/heroes3-original-flipbooks/`: fourteen Castle DEF files in `originals/H3sprite/`, indexed masters and RGBA reference sheets in `sprites/H3sprite/<DEF>/`. Existing high-resolution reuse comes from Pikeman `repaint_v02/` and the six base creatures' `highres_v01/` folders. The seven upgraded identities were newly painted from their own OG designs.

Packing uses the established 768×512 Pikeman / 768×640 other-creature cells, four columns and target anchor (384,448). A single original-coordinate transform per creature preserves source frame displacement. Registration version 2 measures opaque OG artwork (alpha >160), excluding decoded ground shadows; airborne poses therefore keep their original elevation. Generated drawings aspect-fit their source body rectangle without stretching. Raw artwork is preserved so registration can be rebuilt without resizing previous outputs.

## Actual enemy integration

The existing Pikeman, Archer, Griffin, Swordsman, Monk, Cavalier and Angel now load remaster_v01 groups 0 (movement), 2 (idle), 3 (hurt), 5 (death), 12 (front melee), and Archer/Monk group15 (front shooting). The existing manual Sprite2D playback and nine native attack Animation resources own execution; no replacement animation system was added.

The seven scenes, four Pikeman texture defaults and nine attack resources were updated. Pikeman's recovery keys address physical cells8/9 in its rebuilt group12 sheet; those contain the established original repeats of poses2/1. A source diff verifies every other animation key, combat marker, duration, collision setting, hitbox curve and behavior byte is preserved. Existing Gym and Final Arena use these reusable actors. Practice-target visuals remain separate.

All other original groups and the seven upgraded variants have native preview resources and depot assets. The current seven-enemy catalog has no gameplay states/actors for those upgrades or for all original special/turn/angle slots. No new abilities, shooters, flying movement, encounter placements or upgrade balance have been invented. Angel ranged-numbered groups remain their actual original melee aliases.

## Validation and limits

| Check | Result | Evidence |
| --- | --- | --- |
| Independent source and asset audit | All 14 original DEFs and 1,324 indexed source crops rehashed; 225 group sheets, 847 poses, 38 exact-alias pairs and 332 transparent padding cells checked; zero errors | [Independent QA](validation/independent-asset-qa.json) |
| Gameplay integration preservation | 37 actual visual bindings and all 17 presentation integration files checked; other clocks/geometry/behavior preserved | Independent QA and [preservation record](validation/engine/presentation-preservation-check.json) |
| Godot imports and native libraries | 225 lossless/no-mipmap import descriptors; all 14 SpriteFrames resources / 225 groups / 1,324 frame cells loaded; zero final art import, parse or load failures | [Engine summary](validation/engine/validation-summary.json) |
| Actual reusable Gym enemies | Seven actual selected/configured actors; 392 state-frame and 168 private native attack-key samples across both facings; zero presentation-check errors; nine attack durations/markers/key times preserved | [Actual-actor samples](validation/engine/real-actor-samples.json) |
| Comparison viewer | Chromium loaded all 225 group comparisons across 14 creatures with nonempty original/remaster canvases and no page errors | [Viewer checks](validation/viewer/results.json) |

Artist checks covered every generated page; independent visual comparisons covered all 14 idle designs, 28 death poses and 14 turn poses. A Griffin turn found facing too far sideways was repainted to the original frontal view and its four alias sheets rebuilt before the final checks. Comparison images are retained beside the independent QA record.

Engine evidence uses installed **Godot 4.6.3**; the project declares **4.7**, which is unavailable here. The pre-existing 4.6 `ObjectiveWidget.custom_maximum_size` UI API error, editor socket/export warnings and exit resource-leak warnings remain recorded separately from successful art import and sampling. These checks do not establish a clean matching-version gameplay run or human acceptance.

Coverage is distinct from original-game parity certification: DEF extraction supplies source order/registration but no durations, and the original CrAnim rows/executable timing were not recovered. Existing Laema timing and native hitbox curves are retained; visual contact alignment still needs gameplay review. Generated hand grips, cloth/armor details and feather shapes can vary between drawings despite source-guided review; human visual acceptance and a matching-version gameplay review remain open. This work does not claim original timing, final creature balance, or user playtest acceptance.

[Portable packing tool](../../../../tools/art/README.md) documents rebuilding the data assets.

## Offline continuation and publication

The user subsequently requested committing and publishing the Castle work.
The source publication branch is `codex/castle-remasters-2026-10-23` in
`czhou2822/Laema`. [Offline handoff](OFFLINE_HANDOFF.md) records the complete
state, paths, validation, limits and local setup; [continuation prompt](CONTINUE_OFFLINE.md)
can be pasted into a local coding assistant. This publishes the source candidate;
it does not establish visual acceptance or export the hosted Godot game.
