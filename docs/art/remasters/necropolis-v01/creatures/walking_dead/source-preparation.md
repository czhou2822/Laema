# Walking Dead source preparation

2026-10-23. Creature `walking_dead`; original `H3sprite/CZOMBI.def`.
Historical preparation snapshot; the later [production report](PRODUCTION_REPORT.md) supersedes its hold and pending-artwork counts.
Status: **PREPARED; ARTWORK HELD pending explicit parent clearance of the Skeleton/Bone Dragon pilots.** This worker retains Walking Dead ownership.

## Inventory and verification

The complete Walking Dead plan entry was inspected: source metadata, all group records/sequences, 60 pose signatures/body rectangles/representatives, all 86 occurrences, and exact aliases. Static reconciliation against native metadata found zero mapping, count, signature, source-record, sheet-path, cell-region, or alias discrepancies. All 30 referenced PNGs exist: 15 RGBA preview sheets and 15 indexed preservation sheets. There are 15 stored groups, 86 ordered positions, 60 unique registered poses, and 13 distinct group sequences. These are source counts before derived mirrored exports.

Verified SHA-256 values:

- Approved appearance master, `docs/art/production/necropolis-creature-assets-v01/walking-dead/master_rgba.png`: `c7c876d8b59106f422408e72c6570fc7260e3b8bd5d95fb21e2407c0531f3cd5`.
- Native metadata, `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/metadata.json`: `8b5c7c9eaa21cbefd910b2bb91c3369f38457ddbe126b089a900e1a7576caca9`.
- Original DEF, `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CZOMBI.def`: `fee70e4ce759b793b42def1dae19e77b3ca65baca71016d88184772c35800266`.
- Plan snapshot: `084dcc8ed5bdbf4ade05ec7f6bd9cf2f78bfe575884c6ebad256a3927012488f`.
- Read-only helper snapshot: `e889a9588118cabe8a50a7b8460b2f7b1ecb1435cb684f523d27876816f098fd`.

The copied `_source/appearance-master.png` is byte-identical to the approved master. The native canvas is 450x400. Final registration remains the shared 1024x768 cell, anchor (512,512), source reference (196,268), uniform scale 180/73, alpha>160 body bounds, and four atlas columns.

## All source sequences

Below, `010` means `walking_dead_p010`; ranges expand inclusively in ascending order. Role labels are the plan's interpretations; they do not establish original gameplay semantics or timing.

| Group | Role | Positions | Exact pose order | Exact aliases |
| --- | --- | ---: | --- | --- |
| 0 | Movement | 10 | 000-009 | none |
| 1 | Idle gesture | 9 | 010,011,012,013,014,014,013,012,011 | none |
| 2 | Idle | 8 | 010,015,016,017,017,016,015,010 | none |
| 3 | Hurt | 7 | 010,018-023 | none |
| 4 | Defensive reaction | 8 | 010,024,025,026,027,027,028,029 | none |
| 5 | Death | 9 | 010,030-037 | none |
| 7 | Turn part 1 | 3 | 010,038,039 | 9 |
| 8 | Turn part 2 | 3 | 039,038,010 | 10 |
| 9 | Legacy turn | 3 | 010,038,039 | 7 |
| 10 | Legacy turn | 3 | 039,038,010 | 8 |
| 11 | Melee upper | 7 | 010,040-045 | none |
| 12 | Melee front | 7 | 010,046-051 | none |
| 13 | Melee lower | 7 | 010,052-057 | none |
| 20 | Movement start | 1 | 058 | none |
| 21 | Movement end | 1 | 059 | none |

## Prepared references and actual inspection

Ran the unmodified helper with Python `-B`: `prepare walking_dead`. It created eight PNG/JSON guide pairs and `_source/preparation.json` beneath `assets/prototype/enemy/walking_dead/remaster_v01/`. Seven guides are 2048x1024, four columns by two rows; the last is 2048x512, four columns by one row. Their 60 row-major IDs exactly match the pending pose list.

`view_image` inspection covered the approved master, native G2/G5/G7/G12 sheets, and **every** guide `batch-000.png` through `batch-007.png`:

| Guide | Poses | Static content inspected |
| --- | --- | --- |
| 000 | 000-007 | Changing walk stance, knees and cleaver angle |
| 001 | 008-015 | Walk recovery, original idle 010, idle gesture |
| 002 | 016-023 | Remaining idle drawings and hurt lean/recovery |
| 003 | 024-031 | Raised-cleaver defence, opening death poses |
| 004 | 032-039 | Falling/flattened body and more frontal turn views |
| 005 | 040-047 | Upper attack, front attack windup, changing torso view |
| 006 | 048-055 | Forward sweep/recovery and deeply bent lower strike |
| 007 | 056-059 | Low-strike recovery and distinct movement endpoints |

## Production cautions and limits

- Preserve the bald pale body, exposed ribs, damaged arm/skeletal hand, injured lower leg, torn dark trousers, bare feet and cleaver from the approved master. Actual originals control the hand/grip, limb positions, view changes and weapon angle in each pose.
- Pose 010 occurs 13 times across source groups. Idle/gesture/defence also contain deliberate repeated positions. Deduplication must preserve those exact occurrences; an arbitrary idle cannot replace their other drawings.
- G7/G9 and G8/G10 are exact aliases; G8 reverses G7. Preserve these separately named groups. The DEF has no G6 or ranged groups; this is its actual inventory, not missing artwork to invent.
- Death moves from raised limbs into a compact horizontal body; lower attack bends deeply. Guides enlarge each figure independently for inspection. Their displayed sizes/centres are not registration authority; retain native body bounds and fixed shared coordinates.
- The 721x1467 RGBA master is tightly cropped, with alpha range 0-254 and body bounds at alpha>160 of (0,1,720,1466). It is an appearance reference, not a padded sprite page. A direct idle reuse has not been ingested or cleared by this preparation; future pages need genuinely transparent gutters and complete limbs/weapon margins.
- Guide PNGs are RGB reference enlargements only. No final artwork exists: 0 newly drawn poses, 0 reused poses, 60 missing/pending poses, 0/15 completed remaster groups. Mirrors, candidate sequence contacts/GIFs and exports remain pending.

This is a static reference preparation pass, not full source-motion playback review, animation acceptance, timing proof, or game/engine validation. No imagegen, ingestion, review marking, build, engine/gameplay tests, shared edits, Git operations, or peer messages were performed.

Required context read: worker brief; installed Mali and imagegen Skills; Mali art-review-and-direction reference and physical personal-art profile; current AGENTS.md, document map and relevant GDD/TDD/Implementation Status context; project ART_DIRECTION.md. Mali informed evidence labeling and the separation of appearance approval from animation acceptance. The latest task explicitly excludes Git operations. Resume only after parent pilot clearance, using these existing guides and the approved master; do not regenerate duplicate guides without a repair reason.
