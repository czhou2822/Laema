# Wight — static master proposal

**Static master awaiting human approval. Animation not begun; runtime unverified.**

- [Source comparison](source-vs-master.png): native reference, registered candidate and enlarged inspection.
- [Registered master](master_source_1024x768.png), [high-resolution master](master_rgba.png), and [exact mirror](master_mirror_1024x768.png).
- [Visual review](visual-review.json), [registration manifest](master-manifest.json), [exact prompts and generation provenance](generation-provenance.json).

## Source review

CWIGHT contains **18 groups, 102 timeline frames and 57 distinct indexed drawings**; the complete inventory remains in job.json. Source metadata and DEF hashes match the job. The native idle enlargement, all-groups contact, all 18 group guides and Pikeman rendering reference were inspected. The guides show 46 selected frame positions, not every timeline frame or playback.

Observed identity: dark brown hood and robe, pale skull-like face and hands, narrow pale throat detail, hands close to the torso, hanging sleeves and a tapered ragged hem without visible feet. The source idle carries no weapon. Gesture eye accents and attack sweep forms were excluded from idle. Pikeman supplied rendering guidance only. No upgrade comparison is claimed.

## Selected result

One built-in imagegen generation and two targeted edits produced the selected [raw 03](generated-03.png). Both rejected raw images remain preserved. Corrections repaired the needle-like proportions and removed the extra pale waist/sleeve form. The final proposal has two clear hands, right facing, modeled brown cloth and bone, genuine alpha, and no floor, shadow or VFX.

The shared helper used default uniform height scaling and native silhouette center/bottom registration. Cell: **1024 × 768**; anchor: **(512, 512)**; native reference: **(196, 268)**; common scale: **180/73**. Actual visible bounds are **76 × 217 at (475, 290)** versus target 72 × 217. The four extra width pixels preserve aspect ratio; no stretching or registration override was used. Bottom y=507 retains the native floating placement.

Both registered facings and the final comparison were visually inspected. Alpha and exact mirroring were mechanically checked.

## Actual limitations

Fine cloth grain still looks etched or ornamental when enlarged; plain native cloth fidelity is partial. The articulated skeletal throat, explicit skull and additional torn robe layers are interpretations of low-resolution source detail. The candidate is slightly wider and brighter than the native reference.

Exact prompts are preserved in prompt-01.txt through prompt-03.txt. Generation provenance retains every raw hash and original tool output path; selected raw SHA-256 is `49c788c3b32664ef949d6d3c6003734b52b986e80e460a4ddb6ded409d177eca`.

No animation, engine import, build, tests, runtime validation or human approval occurred.

