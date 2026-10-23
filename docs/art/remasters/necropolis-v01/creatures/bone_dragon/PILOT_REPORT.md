# Bone Dragon pilot handoff

Historical pilot baseline: the measurements below describe earlier candidates, not the current full-production selection. The final selected p002 is `full-p002-a06-far-wing.png`, registered SHA-256 `6ce2514eb8e4a25997ada878085dcdbe3efd781f6c5d81494745e0fb99a4f0f3`; parent directly closed its original wing concern. See `selected-p002-repair.json`, its labeled `bone_dragon_p002-SELECTED-A06.png` comparison, and `production-progress.json` for current full-production status. Full reviewed handoff is being finalized separately.

Status: three requested candidates supplied and inspected. P002 retains a source-fidelity limitation. Full creature is **not complete**.

Scope: `bone_dragon_p000` (CNDRGN G0 F0 flight), `bone_dragon_p002` (G0 F2 flight), `bone_dragon_p042` (G11 F5 low-reaching melee, not death). The supplied pilot guide controls pose; the approved master controls warm aged ivory bone and dry dark membranes. Mali informed the native-scale, silhouette and material checks.

All following paths are relative to the repository root.

| Pose | Verbatim raw builtin PNG | Registered 1024x768 candidate | Source/candidate comparison | Padding L/T/R/B px |
| --- | --- | --- | --- | --- |
| bone_dragon_p000 | assets/prototype/enemy/bone_dragon/remaster_v01/_source/raw/pilot-p000-a02.png | assets/prototype/enemy/bone_dragon/remaster_v01/poses/bone_dragon_p000.png | assets/prototype/enemy/bone_dragon/remaster_v01/contacts/pilot/bone_dragon_p000-registered-comparison.png | 344/72/246/330 |
| bone_dragon_p002 | assets/prototype/enemy/bone_dragon/remaster_v01/_source/raw/pilot-p002-a03.png | assets/prototype/enemy/bone_dragon/remaster_v01/poses/bone_dragon_p002.png | assets/prototype/enemy/bone_dragon/remaster_v01/contacts/pilot/bone_dragon_p002-registered-comparison.png | 335/210/243/345 |
| bone_dragon_p042 | assets/prototype/enemy/bone_dragon/remaster_v01/_source/raw/pilot-p042-a03.png | assets/prototype/enemy/bone_dragon/remaster_v01/poses/bone_dragon_p042.png | assets/prototype/enemy/bone_dragon/remaster_v01/contacts/pilot/bone_dragon_p042-registered-comparison.png | 390/214/299/236 |

Every registered nonzero-alpha pixel clears 40 px padding. Minimum margins are 72 px (p000), 210 px (p002), 214 px (p042). Three exact RGBA mirror candidates are also saved beside the source-facing poses. Wing fingers, claws, toes and tail tips visibly fit.

## Actual review and repairs

The initial 3x1 page was rejected by the unchanged shared helper: `ValueError: Figure touches raw/grid boundary: bone_dragon_p002; preserve attempt and regenerate`. The raw page, exact request and prompt remain retained. All final candidates use individual 1x1 ingestion; no clipping or component-isolation bypass.

P042 a03 lowers the skull and foreclaws and replaces the previous horizontally spreading tail with a compact low vertical hook closer to G11 F5. Arched wing and bent, splayed hind legs are retained. No death fragments were added.

P002 a03 increases lower membrane overlap over the ribs, but retains a flatter silhouette: registered 446x213 px versus the original opaque projected envelope of about 446x237 px. Jaw opening and tail/body proportions remain interpretation. This remains open before a full animation lock.

P000 retains the high upstroke; p002 has the distinct lower backward wing sweep. These three original source poses face right. Later turns must follow their own sources rather than inherit a universal facing.

Inspected the source guide and approved master, all registered/source comparisons, all 2x detail comparisons, native 1:1/backprojected contact, and light/dark mattes. Re-inspected p002 after its final repair at native, registered and 2x scales, and p042 at those scales plus its light matte. No floor, text, grid or cast shadow is visible. Some raw files contain alpha 1-8 noise away from the visible figure; the unchanged shared helper crops at alpha>8 before registration. Reported registered padding includes every nonzero alpha pixel.

## Recoverable evidence

- Native-size contact: `assets/prototype/enemy/bone_dragon/remaster_v01/contacts/pilot/pilot-native-size.png`.
- Enlarged comparisons and mattes: `assets/prototype/enemy/bone_dragon/remaster_v01/contacts/pilot/`.
- Exact prompts, request objects and returned output hints: `assets/prototype/enemy/bone_dragon/remaster_v01/_source/prompts/`.
- Six raw attempts, submission hashes and prompt copies: `assets/prototype/enemy/bone_dragon/remaster_v01/_source/raw/`.
- Previous p002/p042 registration records: `assets/prototype/enemy/bone_dragon/remaster_v01/_source/history/`.
- Measurements and SHA-256 readback: `docs/art/remasters/necropolis-v01/creatures/bone_dragon/pilot-mechanical-checks.json`.
- Machine-readable visual review and complete missing list: `docs/art/remasters/necropolis-v01/creatures/bone_dragon/visual-review.json`.
- Mechanical-only comparison script: `docs/art/remasters/necropolis-v01/creatures/bone_dragon/pilot_checks.py`.

All six raw archives match the builtin-produced PNGs byte for byte. Master hash remains `bcc402249960e2febabf8482b952de84763c65c88a3202b37c3d7a3ff65955a4`; original CNDRGN DEF and metadata match their plan hashes. No model identifier or seed was returned or invented.

Counts: 3 new final source-pose candidates, 0 reused masters, 3 exact mirrors, 6 builtin calls/raw attempts. Coverage remains 3/61 unique poses and 0/15 complete groups; 58 poses intentionally absent. No other pose generated. Full sequences, joins, turns, death fragments, both-facing motion continuity, original timing and human acceptance remain unverified. Build/validate/spriteframes were not run for this incomplete pilot. No Git, game-code, canonical-record or shared-tool changes.

Resume: remain the dedicated Bone Dragon worker. Await later full-pass instruction and carry the p002 fidelity issue into parent review. Do not continue past the three pilot IDs or mark the creature complete.

