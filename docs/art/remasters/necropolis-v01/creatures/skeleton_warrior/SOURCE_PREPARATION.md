# Skeleton Warrior source preparation

Historical initial-preparation snapshot. Current production status and outputs
are recorded in [CREATURE_REPORT.md](CREATURE_REPORT.md).

Initial status: **PREPARED; ARTWORK GENERATION ON HOLD** pending the parent's explicit
Skeleton/Bone Dragon pilot clearance. Dedicated creature: `skeleton_warrior`.
Preparation date: 2026-10-23. This is source preparation, not animation acceptance.

## Verified sources and counts

The complete Skeleton Warrior plan entry, native group records, all 86 occurrence
mappings, 57 signatures/body bounds, and exact aliases were inspected. The
read-only `check_sources.py` audit passed using Python `-B`: every stored indexed
frame crop matches its recorded SHA-256, every RGBA alpha>160 body bound matches
the plan, all mappings agree with native metadata, all projected bodies fit the
helper's padded cell, and all guide mappings/dimensions agree with preparation.

| Item | Count |
| --- | ---: |
| Original DEF | 1: `H3sprite/CWSKEL.def` |
| Source groups / ordered frame positions | 15 / 86 |
| Unique registered poses | 57 (`p000` through `p056`) |
| Repeat occurrences beyond unique poses | 29 |
| Original sheets | 15 RGBA + 15 indexed |
| Missing-pose reference guides | 8 (seven 4x2; one 1x1) |
| New artwork / approved-idle reuse / registered candidates | 0 / 0 / 0 |
| Still missing candidate poses / complete candidate groups | 57 / 0 |

The eventual two-facing expansion is 30 group/facing sequences and 172 ordered
positions. These outputs have not been built. Source-facing pose count is 57;
mirroring does not create additional original source signatures.

SHA-256 values verified against the plan and relevant approval record:

- Approved master: `b5c927d1906aaf32eb4d9c0df532d7094fd24afdfbb1ef453870fd45c20e20ee`.
  Source: `docs/art/production/necropolis-creature-assets-v01/skeleton-warrior/master_rgba.png`.
  Actual RGBA size: 755x1582; alpha range 0-255. Prepared
  `_source/appearance-master.png` is byte-identical.
- Metadata: `38d52108452c5c9bed2261bd44d4372ba43a745ce63e945476d62625d9142567`.
  Source: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWSKEL/metadata.json`.
- Original DEF: `d5b4ddf69f1688af80350ba98d941b4ae1fddb191b3956d45c49580e13798489`.
  Source: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CWSKEL.def`.

## Complete source order and exact aliases

`pNNN` below means `skeleton_warrior_pNNN`. Role labels are the helper's
interpretations, not additional gameplay decisions. Block indices are zero-based.

| Group / block | Role | Ordered pose IDs | Exact alias |
| --- | --- | --- | --- |
| 0 / 0 | movement | 000,001,002,003,004,005,006,007 | none |
| 1 / 1 | idle gesture | 008,009,010,011,011,011,011,011,010,009,008 | none |
| 2 / 2 | idle | 012,013,014,015,016,015,014,013 | none |
| 3 / 3 | hurt | 017,018,019,020,021,022 | none |
| 4 / 4 | defensive reaction | 023,024,025,026,026,026,026,026,025,024,023 | none |
| 5 / 5 | death | 027,028,029,030,031,032 | none |
| 7 / 6 | turn part 1 | 033,034 | G9 |
| 8 / 7 | turn part 2 | 034,033 | G10 |
| 9 / 8 | legacy turn | 033,034 | G7 |
| 10 / 9 | legacy turn | 034,033 | G8 |
| 11 / 10 | melee upper | 035,036,037,038,039,040,041,042 | none |
| 12 / 11 | melee front | 035,036,043,044,045,046,047,042 | none |
| 13 / 12 | melee lower | 035,036,048,049,050,051,052,042 | none |
| 20 / 13 | movement start | 053,054 | none |
| 21 / 14 | movement end | 055,056 | none |

## Actual visual inspection

Viewed the approved master and actual OG G2 RGBA sheet using `view_image`.
Viewed **each of the eight actual prepared PNG guides**, covering all 57 unique
source drawings as static enlarged references. This does not establish review of
all source-ordered motion, repeats, transitions, or both-facing playback.

| Guide | Pose IDs | Observed content |
| --- | --- | --- |
| batch-000 | 000-007 | Eight walk poses: alternating legs, changing sword angle and shield exposure. |
| batch-001 | 008-015 | Gesture raises sword/shield; four distinct ordinary-idle drawings follow. |
| batch-002 | 016-023 | Remaining ordinary-idle drawing, six hurt drawings with strong backward lean/recovery, defence entry. |
| batch-003 | 024-031 | Shield-led defence poses; death reaches upward then folds/collapses with sword and shield. |
| batch-004 | 032-039 | Compact final remains with upright sword; side/front turn views; upper-attack windup and arc. |
| batch-005 | 040-047 | Upper-attack recovery and distinct forward attack: extended blade, torso lean and raised shield. |
| batch-006 | 048-055 | Lower attack bends markedly with lowered sword; separate movement-start/end poses. |
| batch-007 | 056 | Final movement-end drawing, blade nearly horizontal and one leg behind. |

The master visibly supplies a spiked helmet with cheek guards, dark modeled
cuirass, pale exposed bones, armored boots, straight sword and bronze-rimmed
round shield. Preserve these appearance features while following each OG view,
grip, limb arrangement and collapse. The designated exact idle reference is
`skeleton_warrior_p012`; reuse has not been performed or registered.

## Discoverable issues and continuation constraints

No hash mismatch, missing source sheet, occurrence mismatch, wrong alias,
empty alpha>160 body, guide omission, or projected-padding failure was found.

- G1 and G4 each hold one drawing for five source positions. G2 reverses through
  its drawings. Keep these exact positions; unique-pose guides omit repeats.
- Only G7=G9 and G8=G10 are complete-sequence aliases. G8 reverses G7; it is not
  the same sequence. G11/G12/G13 share 035,036,042 but have distinct middle poses.
- Source slots G6 and G14-19 do not exist for CWSKEL; do not fabricate them.
- The guides enlarge and fit each source drawing separately for visibility.
  Their presentation scale/placement is not registration authority. Preserve
  fixed output 1024x768, anchor (512,512), source anchor (196,268), scale 180/73,
  four atlas columns and the plan's alpha>160 native body bounds.
- Ordinary-idle differences are subtle but have distinct signatures. Walking,
  turn, shield reactions, attacks and collapsed remains require their own poses.
- Original per-frame timing is unverified. No generated-art, sequence playback,
  mirrors, engine, browser, build, gameplay, human acceptance, or publication
  evidence is claimed. `build`, candidate `validate`, `spriteframes`, ingest,
  review-marking, and image generation were not run.

Prepared asset root:
`assets/prototype/enemy/skeleton_warrior/remaster_v01/`.
Exact guide requests: `_source/guides/batch-000.json` through `batch-007.json`.
Aggregate missing-pose request: `_source/preparation.json`.

Resume only after explicit parent pilot clearance, using this same dedicated
creature assignment. Follow the brief's saved-prompt, built-in-imagegen,
transparent-output, retained-attempt and per-pose-review requirements. Parent
owns shared tool changes, root reports, game integration and Git publication.
