# Zombie source preparation — 2026-10-23

Historical initial preparation pass. Current production completion is recorded in
`COMPLETION.md` and `visual-review.json`; the original preparation review is
preserved in `preparation-visual-review.json`. The initial hold below was cleared
by the parent's later explicit full-production instruction.

Status: **PREPARED; HOLD FOR PARENT PILOT CLEARANCE.** Dedicated creature:
`zombie` / Zombie / `CZOMLO`. This is the initial preparation pass only.
No imagegen calls, new artwork, idle reuse, ingestion, candidate review marks,
atlases, SpriteFrames, Git operations, game edits or engine/build/gameplay tests.
Resume with this same worker after explicit parent clearance of the Skeleton and
Bone Dragon pilots.

## Source identity and checks

Read the complete Zombie entry of `../../generation-plan.json`, including all
source records, representative/occurrence mappings, group orders and aliases.
The approved master is appearance authority; original frames remain pose,
facing, grip, placement and ordering authority.

| Input | Project-relative path | Verified SHA-256 |
| --- | --- | --- |
| Approved master | `docs/art/production/necropolis-creature-assets-v01/zombie/master_rgba.png` | `2475a0958922c1ad54875612b7a871c49c1d39480da772f2647ca8829e8d8b1e` |
| Original DEF | `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CZOMLO.def` | `3ae05f80407ef6d79615186805df8e4c17fd49ea9c1d489494ea6e6c63eaa3f8` |
| Source metadata | `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMLO/metadata.json` | `bc9f2c681db210b383b1bfbe1ee6c828ac8d6bd6cc6bfc44dba1028bda9ad0f3` |

All three match the plan. Original metadata identifies H3sprite, creature DEF
type 66 and a 450×400 source canvas. Plan SHA-256:
`084dcc8ed5bdbf4ade05ec7f6bd9cf2f78bfe575884c6ebad256a3927012488f`.
Read-only helper SHA-256:
`e889a9588118cabe8a50a7b8460b2f7b1ecb1435cb684f523d27876816f098fd`.

Counts: **15 group slots, 86 ordered source positions, 60 unique registered
poses (`zombie_p000`–`zombie_p059`), 26 repeated positions beyond those unique
poses, and 13 distinct full group sequences.** There are 15 RGBA sheets and 15
indexed sheets. All 30 exist with metadata-matching dimensions. All 15 original
group records match metadata; all 86 occurrence records, cell mappings and
registered signatures agree with it. All 86 RGBA occurrence crops match their
respective representative crops. All 60 native alpha>160 body rectangles match
the plan. These are asset consistency checks, not a new DEF decoder audit.

## Exact source order

Below, `010` means `zombie_p010`. Labels are the plan's slot interpretations.

| Group / block | Interpretation | Positions | Ordered pose suffixes | Exact alias |
| --- | --- | ---: | --- | --- |
| 0 / 0 | movement | 10 | 000 001 002 003 004 005 006 007 008 009 | none |
| 1 / 1 | idle gesture | 9 | 010 011 012 013 014 014 013 012 011 | none |
| 2 / 2 | idle | 8 | 010 015 016 017 017 016 015 010 | none |
| 3 / 3 | hurt | 7 | 010 018 019 020 021 022 023 | none |
| 4 / 4 | defensive reaction | 8 | 010 024 025 026 027 027 028 029 | none |
| 5 / 5 | death | 9 | 010 030 031 032 033 034 035 036 037 | none |
| 7 / 6 | turn part 1 | 3 | 010 038 039 | G9 |
| 8 / 7 | turn part 2 | 3 | 039 038 010 | G10 |
| 9 / 8 | legacy turn | 3 | 010 038 039 | G7 |
| 10 / 9 | legacy turn | 3 | 039 038 010 | G8 |
| 11 / 10 | melee upper | 7 | 010 040 041 042 043 044 045 | none |
| 12 / 11 | melee front | 7 | 010 046 047 048 049 050 051 | none |
| 13 / 12 | melee lower | 7 | 010 052 053 054 055 056 057 | none |
| 20 / 13 | movement start | 1 | 058 | none |
| 21 / 14 | movement end | 1 | 059 | none |

G7=G9 and G8=G10 are exact sequence aliases, including byte-identical corresponding
source sheets. Their opposite orders remain distinct. `zombie_p010`, the exact
idle reference, has 13 occurrences across these groups. G20/G21 are distinct
poses, not substitutes for idle. No additional absent slot is inferred missing.
Future mirrored coverage would be 30 group/facing sequences and 172 positions;
no mirrored candidate output exists yet.

## Preparation and actual visual inspection

Ran the unmodified helper with Python `-B`:
`tools/art/necropolis_remaster.py prepare zombie`.
It reported **60 pending poses / 8 batches**. All 60 pending IDs occur once in
row-major guide order. The copied `_source/appearance-master.png` is byte-identical
to the approved master. Generated files are restricted to Zombie's assigned
asset folder. Preparation metadata is
`assets/prototype/enemy/zombie/remaster_v01/_source/preparation.json`.

Used `view_image` on the actual approved master, actual original G2 RGBA sheet,
and **each of the eight distinct helper guides**, not a single roster contact.
Guides are under `assets/prototype/enemy/zombie/remaster_v01/_source/guides/`.

| Inspected guide | Pose IDs | Observed source content |
| --- | --- | --- |
| `batch-000.png` | 000–007 | Walking stance, staggered feet, free arm and carried hammer angle change. |
| `batch-001.png` | 008–015 | Walk recovery, exact idle reference and idle gesture; hammer lowers as the torso/arm gesture changes. |
| `batch-002.png` | 016–023 | Remaining idle poses and hurt: crouch, raised arms/hammer, backward lean, recovery. |
| `batch-003.png` | 024–031 | Two-hand defensive hammer lift/brace and initial death recoil with lifted leg. |
| `batch-004.png` | 032–039 | Death collapse to a low curled body, hammer across/above it; turn changes through near-frontal views and a vertical hammer. |
| `batch-005.png` | 040–047 | Upper attack arc/recovery and front-attack preparation; two-hand grips and overhead/behind-head hammer placement. |
| `batch-006.png` | 048–055 | Front strike extension/recovery and lower attack; pronounced low follow-through, forward bend and lowered hammer head. |
| `batch-007.png` | 056–059 | Low-attack recovery and distinct movement start/end poses. |

Guides 000–006 are 2048×1024 (4×2); guide 007 is 2048×512 (4×1).
This inspects 60 unique static source poses. It does **not** establish review of
all ordered motions, transitions, repeated holds, mirrored playback or timing.
No generated candidates were available for comparison at game scale.

## Discoverable issues and production constraints

- No source record, count, alias, missing-file or guide-coverage mismatch found.
- The approved 665×1330 master preserves pallid skin, brown hair, olive torn
  clothing with red lining, brass/gold fasteners and cuffs, one bare foot, one
  boot, and a wooden-shaft cross-head hammer. Do not flatten the original turns,
  crouches, two-hand grips or corpse positions into this standing reference.
- Its RGBA alpha spans 0–254: 449,822 fully transparent pixels, 434,628 partially
  transparent pixels, no alpha-255 pixels. This is the verified approved file,
  preserved unchanged. Any future exact-idle reuse needs an alpha/edge check;
  no matte removal, alpha normalization or reuse was performed in this pass.
- Each guide independently enlarges its cropped reference to aid inspection.
  Guide size/centering is not registration authority. In particular, the low
  corpse must not be scaled up to standing height. Preserve source geometry:
  cell 1024×768, anchor (512,512), source anchor (196,268), scale 180/73,
  alpha>160 native body bounds, four final atlas columns.
- Original per-frame timing is unverified. Do not invent durations or mistake
  static guide order for playback validation.

## Handoff

Prepared references: 60/60. Supplied candidate poses: **0/60**; all 15 candidate
groups remain missing. Newly drawn poses: 0; reused idle poses: 0; repairs: 0.
Machine-readable observations: `visual-review.json` beside this report.
Resume only after explicit parent pilot clearance, then save exact prompts before
built-in generation and retain raw attempts/provenance. Shared helper, plan,
originals, master package, game files and all other creatures remain read-only.

Required context read: worker brief; installed Mali and imagegen Skills;
Mali's art-review-and-direction reference and physical Fanor personal-art profile;
current AGENTS.md, document map and ART_DIRECTION.md; relevant current GDD,
technical architecture and implementation-status sections. The current task's
explicit no-Git boundary governs this preparation pass.
