# Wight source preparation — 2026-10-23

Historical initial preparation record. Full production later cleared and completed; see [current production report](report.md).

Status: **PREPARED; ARTWORK ON HOLD** pending the parent's explicit Skeleton/Bone Dragon pilot clearance. Dedicated creature: `wight` / `CWIGHT` only.

## Verified source

The complete Wight plan entry was inspected: source metadata, all group records and sequences, 57 unique signatures, representatives, all 102 occurrence mappings, geometry and exact aliases. The read-only [audit](audit_source.py) rechecked every original group/frame record, indexed frame pixels and opaque body rectangle against actual files; it exited 0 with no errors. This is asset-source evidence only.

| Item | Count / result |
| --- | --- |
| Original groups / timeline positions | 18 / 102 |
| Unique registered source poses | 57 (`wight_p000`–`wight_p056`) |
| Distinct ordered group sequences | 12 |
| Repeated positions beyond first pose occurrence | 45 |
| Source sheets checked present | 36: 18 RGBA and 18 indexed |
| Actual indexed occurrence hashes checked | 102 / 102 |
| Prepared reference pages | 8: seven 4×2 pages, one 1×1 page |
| Supplied / missing remaster poses | 0 / 57 |
| Complete remaster groups | 0 / 18 |
| New imagegen calls / approved idle reuse | 0 / 0 |

Paths below are relative to the repository root.

- Approved appearance: `docs/art/production/necropolis-creature-assets-v01/wight/master_rgba.png`; SHA-256 `3a4e7927611d40175af4f308291329420f987d79f61f863247e571cf96e62cc2`; actual RGBA dimensions 545×1546, alpha range 0–255. Prepared `_source/appearance-master.png` is byte-identical. Approval also matches `master-approval.json`.
- Original metadata: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CWIGHT/metadata.json`; SHA-256 `d618cc973a1880a703a6a2302964d8a5a64c483b7310f7a709e2031185a2d5ab`.
- Original DEF: `docs/art/references/heroes3-original-flipbooks/originals/H3sprite/CWIGHT.def`; SHA-256 `211ff3e4d786b50fdd3666b2f8b2e80ef44a455b47eb4f9560a562a305b52bdb`.

## Source order and aliases

Numbers below abbreviate `wight_pNNN`. Role names are the helper's format interpretations, not gameplay decisions. No G6, G17, G18 or G19 exists in this source inventory.

| Group (block) | Role | Exact source pose order | Exact alias |
| --- | --- | --- | --- |
| 0 (0) | movement | 000,001,002,003,004,005,006,007 | — |
| 1 (1) | idle gesture | 008,009,010,011,011,011,011,010,009,008 | — |
| 2 (2) | idle | 012,013,014,015,016,015,014,013 | — |
| 3 (3) | hurt | 017,018,019,020,021,022 | — |
| 4 (4) | defensive reaction | 023,024,025,026,026,026,026,025,024,023 | — |
| 5 (5) | death | 017,018,027,028,029,030,031,032 | — |
| 7 (6) | turn part 1 | 033,034 | G9 |
| 8 (7) | turn part 2 | 034,033 | G10 |
| 9 (8) | legacy turn | 033,034 | G7 |
| 10 (9) | legacy turn | 034,033 | G8 |
| 11 (10) | melee upper | 035,036,037,038,039,040,041 | G14 |
| 12 (11) | melee front | 042,043,044,045,046,047,048 | G15 |
| 13 (12) | melee lower | 049,050,051,052,053,054,055 | G16 |
| 14 (13) | ranged-numbered upper slot | 035,036,037,038,039,040,041 | G11 |
| 15 (14) | ranged-numbered front slot | 042,043,044,045,046,047,048 | G12 |
| 16 (15) | ranged-numbered lower slot | 049,050,051,052,053,054,055 | G13 |
| 20 (16) | movement start | 056 | G21 |
| 21 (17) | movement end | 056 | G20 |

Hurt/death share exactly p017 and p018. G7/G8 are reverse order, not aliases of one another. Alias slots and deliberate repeated frame positions must remain present.

## Actual visual inspection

Viewed with `view_image`: the approved high-resolution master, actual OG G2 idle and G0 movement RGBA sheets, and **all eight** prepared pages under `assets/prototype/enemy/wight/remaster_v01/_source/guides/`. This is a still inspection of all 57 unique poses across eight images; it is not source-ordered playback of all 102 occurrences or a review of both animation facings.

| Guide | Inspected source poses and content |
| --- | --- |
| batch-000 | p000–p007: movement, changing hand/robe positions and floating hem |
| batch-001 | p008–p015: idle gesture, red eye accent, most idle poses |
| batch-002 | p016–p023: remaining idle, hurt, first defence pose |
| batch-003 | p024–p031: defence hands rising toward face; death recline and separation |
| batch-004 | p032–p039: terminal death heap, both turn poses, upper attack windup/sweep |
| batch-005 | p040–p047: upper recovery; front attack and embedded white hand trails |
| batch-006 | p048–p055: front recovery, lower attack, low extended torso and trails |
| batch-007 | p056: shared movement start/end pose |

## Findings and production cautions

- No hash, occurrence, alias, indexed-pixel, guide-order or body-bound mismatch was found. Every native opaque body fits the fixed cell with 40-pixel padding. Projected opaque union LTRB is approximately (378.849,253.096,637.753,504.603).
- Appearance authority remains the approved brown hood, modeled torn cloth and bone master. Source poses control torso lean, hand visibility, facing and hem movement. Idle has no weapon or visible feet; do not introduce either.
- G1 has a red eye accent absent from the idle master. Attack p037–p040, p044–p047 and p051–p054 visibly include white hand/trail forms; preserve the embedded source state, without inventing a separate projectile or effect. G14–16 are exact melee sequence aliases, not evidence for ranged gameplay.
- Death includes detached hands/arm sections in p030–p031 and a flattened terminal robe/body heap p032. Multi-part silhouettes must survive later generation and ingestion; do not replace death with idle or force the fragments into a standing figure.
- Guides independently enlarge cropped poses for readability. Their displayed size and centering are not registration authority. Keep the common scale 180/73, source anchor (196,268), target anchor (512,512), 1024×768 cells, alpha>160 body threshold and four-column atlas geometry.
- The historical master report/review still says awaiting approval. The newer user instruction, worker brief, generation plan and `master-approval.json` establish appearance approval; no shared historical file was edited or approval reopened.

## Resume point and limits

Read `_source/preparation.json` for exact page mappings; resume with batch-000 only after explicit parent clearance, applying any pilot lessons within Wight's exclusive folders. p012 is the plan's exact idle reuse candidate, but it has not been ingested, marked reviewed or reused. All 57 remaster poses remain missing.

Mali's evidence workflow kept appearance, source motion authority and actual still sampling separate. The installed Mali/imagegen skills, Mali art-review reference and physical personal profile, current AGENTS, ART_DIRECTION and relevant project-document context were read. No artwork, placeholder, runtime frame, atlas, SpriteFrames resource, engine/build/gameplay test, Git operation or peer message was produced. Original timing, continuous motion, mirrored sequences, native UI and human animation acceptance remain unverified. Parent owns publication.
