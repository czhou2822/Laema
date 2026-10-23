# Lich source preparation

Status: **Preparation complete; waiting for explicit parent pilot clearance and full-generation instructions.** This remains the accepted Mali operation for `creature_id=lich` only. No new artwork call, idle reuse, candidate ingestion, export or animation-acceptance claim.

## Verified source and preparation

- Native identity: `H3sprite/CLICH.def`, type 66, 450×400 source canvas.
- Actual scope: **18 groups, 120 timeline positions, 74 registered source poses**; 46 positions repeat registered drawings. All 120 occurrence records, representative bindings, source-order entries, indexed crop hashes and alpha>160 body rectangles agree with native metadata. All 36 indexed/RGBA source sheets were checked.
- DEF SHA-256: `409506a7915b25cb0a3fd7c722e378dd0735e26757c1896aba8d2bcd45ef9d54`.
- Metadata SHA-256: `bf5ad1f839e18bcedded40a857bd91bb05af4f7a315ee3ab65313800ae789873`.
- Approved high-resolution master: `docs/art/production/necropolis-creature-assets-v01/lich/master_rgba.png`, 529×1443 RGBA; SHA-256 `02f1b9e198236f6d0089076f7551f4671d651afb53b3eb23a0e87f6887cb316c`. Actual bytes match the generation plan, selected master and appearance approval. Alpha range is 0–254; no master changes were made.
- Ran `python -B tools/art/necropolis_remaster.py prepare lich`: **74 pending poses, 10 guides** (nine pages of eight poses and one of two). Prepared master copy is byte-identical. All guide JSON mappings, dimensions and row-major orders were checked. DEF, metadata, master and shared plan hashes were unchanged across preparation.
- Fixed geometry: 1024×768 cells, four atlas columns, anchor (512,512), source anchor (196,268), scale 180/73. All opaque source rectangles fit the required padding; their mapped union is approximately (356.66,218.58)–(706.79,519.40). Guide enlargement is reference presentation only.

| Native groups | Timeline positions | Source interpretation |
|---|---:|---|
| 0 / 20 / 21 | 8 / 2 / 2 | Movement / start / end |
| 1 / 2 | 11 / 8 | Idle gesture / idle |
| 3 / 4 | 6 / 11 | Hurt / defensive reaction |
| 5 | 7 | Death |
| 7 / 8 / 9 / 10 | 2 each | Turn and legacy-turn slots |
| 11 / 12 / 13 | 8 each | Upper / front / lower melee slots |
| 14 / 15 / 16 | 11 each | Ranged-numbered upper / front / lower slots |

Exact aliases: **G7=G9** (`p034,p035`) and **G8=G10** (`p035,p034`). G11/G12 share `p036,p037` at entry but are not aliases. Repeated holds and reverse returns remain in the recorded sequences. G6 and G17–19 are absent in actual CLICH metadata; no extra animation slots are invented. The original idle-reference pose is `lich_p012` (G2 F0); it has not been reused.

## Visual observations and risks

Inspected the approved high-resolution master, **every pose p000–p073 in prepared guides batch-000–009**, and the existing native-scale, G5 death and G15 source guides. The source and master show a skeletal base Lich with pale bone, red eyes, a low dark cap with gold band, chainmail coif/skirt, dark gold-trimmed breastplate, tall boots and a long plain brown staff with capped ends. Preserve this identity without introducing upgrade ornaments or a new robe.

Movement alternates booted steps with a mostly upright staff. Melee changes staff angle, two-hand grip and torso view, including rear views; the master supplies appearance only. Death disassembles skull, hands/limbs, armor and staff into a low pile. These fragments must retain their internal spacing and source-relative collapse rather than being restored to standing height or rejected as extra creatures by component isolation.

Decoded source drawings visibly carry green accents in the idle gesture, yellow in hurt, purple in defence and red in ranged-numbered slots. Their engine meaning is unknown here; do not turn them into invented standalone effects. Staff length, finger contact, boots, chainmail continuity, rear views and death-piece retention need particular attention after pilot clearance. The tightly cropped approved master and future generated pages still need the prescribed candidate alpha/gutter/padding checks.

## Evidence boundary and resume point

This is static source inspection, not motion review. Mali's evidence workflow kept observations separate from slot interpretations and later validation. No candidate artwork exists: **0 generated, 0 reused, 0 ingested, 0 candidate-reviewed; all 74 remaster poses and all 18 groups remain pending**. No mirror, atlas, SpriteFrames or offline package was produced; no browser, Godot, engine, runtime, original-timing or human animation-validation claim is made.

Prepared inputs are under `assets/prototype/enemy/lich/remaster_v01/_source/`. Detailed source sequences, occurrence maps, hashes and checks are in [source-audit.json](source-audit.json); actual visual sampling and limits are in [preparation-review.json](preparation-review.json). [check_sources.py](check_sources.py) is a read-only audit, run with Python `-B`; it does not change shared tools or inputs.

Continue as the dedicated Lich worker only after the parent explicitly clears the Skeleton/Bone pilots and issues full-generation instructions. All writes in this preparation stayed inside the two assigned Lich folders; no Git operation, dependency installation, peer message or gameplay/engine change was performed.
