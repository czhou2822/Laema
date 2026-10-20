# Air X5 — Weapon Summon correction, October 20

The user explicitly authorized replacing Air X5 with Weapon Summon, synchronizing matching records, preserving old files and leaving combat timing/tuning unchanged. This reaffirms the earlier Art approval; it is not a new attack or school-chain design. The old sheet was hash-identical to Weapon_1.png, the detached star/weapon effect.

The replacement is copied byte-for-byte from the existing licensed Craftpix Prototype Hero Pack 3 source, `Animations/Weapon_Summon.png`: 1408×128, eleven 128×128 full-body frames. Runtime SHA-256: `1781ed435045772d3ef7722e4149225785cf10f659754808995d8ae87d40a26a`.

The old 1024×128 eight-frame effect is preserved below (SHA-256 `2155082dafde357e27d6b999be5ad4ea5f9638603058c6c90c1f82b33c18d54f`). Copies of the native Animation, import descriptor and matching records preserve the actual pre-change working tree, including uncommitted active-window edits. Earlier housekeeping/checkpoint history is untouched.

Only the native Sprite:region_rect frame keys change to cover eleven frames with the existing quadratic spacing convention. Combat duration mapping, clip length 1.0, active_start/timing_split 0.36, active_end 1.0, AttackCast curves, tuning, move identity, texture UID/path and Air X1–X4 remain unchanged. Frame-count adaptation is presentation spacing; it does not retune the combat clock.

The old records are historical. Follow the current GDD/TDR/status and native assets for this candidate. Relative links inside exact record snapshots retain their original source context.

| Pre-change file | Exact snapshot |
| --- | --- |
| assets/prototype/player/animation/air_x5.png | [Preserved file](sources/assets/prototype/player/animation/air_x5.png) |
| config/attack_animations/air_x5.tres | [Preserved file](sources/config/attack_animations/air_x5.tres) |
| assets/prototype/player/animation/air_x5.png.import | [Preserved file](sources/assets/prototype/player/animation/air_x5.png.import) |
| assets/README.md | [Preserved file](sources/assets/README.md) |
| docs/GAME_DESIGN.md | [Preserved file](sources/docs/GAME_DESIGN.md) |
| docs/TECH_ARCHITECTURE.md | [Preserved file](sources/docs/TECH_ARCHITECTURE.md) |
| docs/IMPLEMENTATION_STATUS.md | [Preserved file](sources/docs/IMPLEMENTATION_STATUS.md) |
| docs/departments/art.md | [Preserved file](sources/docs/departments/art.md) |

The manifest records source/replacement identities and snapshot hashes. The user's existing Craftpix project entitlement applies; source redistribution remains prohibited. No new licensing permission or public publication is inferred.

Static checks cover file identity, frame bounds and source preservation. No Godot/editor/import/parser, playback, build, tests or export was run. Human validation remains pending; no commit or push was performed.
