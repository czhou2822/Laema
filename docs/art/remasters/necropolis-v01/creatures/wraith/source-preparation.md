# Wraith source preparation

Historical initial-preparation snapshot. Full production was later cleared and completed; see `report.md` and `visual-review.json` for current coverage and review status.

Status: **INITIAL_PREPARATION_COMPLETE; AWAITING_PARENT_PILOT_CLEARANCE**. Creature ID `wraith`; original `H3sprite/CWRAIT.def`. This is the existing accepted Mali operation. The user's current approval of all 14 appearance masters and the remaster approval record control; older master-package labels saying approval is pending are historical.

## Source checks and preparation

Read the full worker brief, installed Mali and imagegen Skills, Mali's art-review-and-direction reference, physical Fanor personal-art profile, current AGENTS.md, document map and project art direction. Inspected the complete Wraith plan entry through bounded header, group-sequence and pose/occurrence tables. The read-only `audit_sources.py` additionally compares every embedded group record with native metadata and checks every representative and occurrence field.

Actual coverage: **18 native groups, 102 timeline positions, 57 registered source signatures**. Native cells are 450 x 400. Independently decoded all 102 DEF frame occurrences using the existing reference verifier; each matched its metadata pixel hash and preserved indexed-sheet bytes/palette. Checked all 36 native indexed/RGBA page files, all 57 opaque body rectangles, group ordering, occurrence maps and exact aliases. No mismatch was found.

| Input | Actual SHA-256, matching the plan |
| --- | --- |
| Native metadata | `6fae0fdc8d4a67eda68e140eecdbdc7b0d69bdca7f194529cf77637c00397266` |
| Original DEF | `9148c306d115fd514964cea16d0c6d9ed6b336365ef3e7ef592797bc52c2e47e` |
| Approved high-resolution master | `b319f9536813d002cb7832c739a4ed840ac5c61968fa474335b5233d9689c33d` |
| Shared generation plan | `084dcc8ed5bdbf4ade05ec7f6bd9cf2f78bfe575884c6ebad256a3927012488f` |

The approved master also matches the selected-master, master-manifest and approval-record hashes. It is a 510 x 1445 RGBA crop with alpha range 0-254; no fully opaque alpha-255 pixel is required to identify its visible body.

Ran `python -B tools/art/necropolis_remaster.py prepare wraith` once: **57 pending poses, eight guides**, seven 4 x 2 pages of 2048 x 1024 and one 1 x 1 page of 512 x 512. Guides are labeled original-reference enlargements only. `_source/appearance-master.png` is a byte-identical reference copy. Checked the preparation manifest, every guide mapping/dimension and complete row-major pose coverage. All 57 artwork poses remain unsupplied; no new drawing, reuse ingestion, candidate acceptance or export occurred.

## Original groups and aliases

Groups/counts: G00/8 movement; G01/10 gesture; G02/8 idle; G03/6 hurt; G04/10 defence; G05/8 death; G07-G10/2 each turns; G11-G16/7 each attack-numbered slots; G20-G21/1 each movement boundaries. These role labels are interpretations of source slots, not gameplay or timing proof. G06 and G17-G19 are absent in this DEF, not missing work to invent.

Exact aliases: **7=9, 8=10, 11=14, 12=15, 13=16, 20=21**. G08 reverses G07's two poses; G10 does the same. G14-G16 are identical to the corresponding melee sequences, not evidence of distinct ranged attacks. G03 and G05 share their first two poses. G01 holds p011 for F3-F6; G04 holds p026 for F3-F6; G02 repeats its return poses. All repeated positions must remain in source order. Pose occurrence counts are 20 used once, 33 used twice and four used four times, totaling 102.

## Actual visual inspection

Viewed the approved high-resolution master, existing shared-scale source/master comparison, light-background master review, all-groups representative contact, **all eight prepared guides / all 57 unique source poses**, and existing native sequence samples G01 (F0/F5/F9), G04 (F0/F5/F9), G05 (F0/F4/F7), G07-G08 (both positions) and G12 (F0/F3/F6). The all-groups contact is representative sampling; prepared guides expose every unique pose but omit duplicate timeline occurrences.

Observed identity: very slender hooded undead, worn near-black brown/umber robe, pale skull-like face and long pale throat fringe, thin skeletal forearms/fingers, long uneven sleeve and hem tatters, no held weapon, visible legs or feet. The master retains the right-facing idle and close hands, with more explicit skull, cloth wear and finger detail than native pixels. Its appearance approval does not turn that idle arrangement into authority for other actions.

Movement trails the lower robe backward and lowers its visible height. G01 shows an enlarging red face/mouth patch during its gesture, absent from neutral idle. Defence raises both hands toward the face. Turns expose a broader near-frontal cowl/robe and different hand overlap. G11-G13 swing the arms through different upper/front/lower trajectories, expose back/side views, and contain pale yellow/white hand accents plus **embedded white curved claw streaks**. G05 collapses into cloth and bone fragments; later frames include detached pieces and end as a low heap. Preserve these original embedded features without inventing standalone effects.

## Risks and static limits

- Fine fingers, throat fringe and dark folds can merge at display size; maintain exact forearm/hand overlap, hem direction and silhouette through changes of view. Detached death fragments require intentional spatial grouping, not automatic removal as stray components.
- Prepared guide figures are enlarged independently for inspection. Their displayed sizes and centers are not registration authority. Preserve the fixed 1024 x 768 cell, anchor (512,512), native reference (196,268), scale 180/73 and alpha >160 source bounds. The union is native `(144,157)-(248,266)`, mapping to approximately `(383.78,238.30)-(640.22,507.07)` with required padding.
- The current idle p012 opaque rectangle is `(180,180,33,86)`, implying 212 px target body height. The historical static master job used alpha >64, 33 x 88 and 217 px. Preserve the current plan's threshold/placement; do not silently substitute the older registration or normalize flight/death to standing height. No packing or reuse was attempted here.
- The master is tightly cropped, with antialiased partial alpha and dark edge detail. Later generated pages need generous transparent margins and gutters; this preparation does not certify future page isolation or alpha cleanliness.

This is static source preparation and asset-data inspection only. No animation playback, mirror continuity review, human animation acceptance, original timing proof, browser or engine validation, runtime/game changes, builds, dependency installation, Git operation, peer message, published package change or offline export was performed. Writes are confined to the two assigned Wraith directories. Mali's evidence and handoff requirements determined the explicit source sampling and limits recorded here.

Resume: retain the dedicated Wraith assignment and wait for the parent's explicit pilot clearance/full-generation instruction. Use the existing prepared guides; any later image call must follow the brief's saved-prompt and raw-provenance requirements. Source evidence: shared generation plan and approval record; native CWRAIT metadata/DEF/sheets; published Wraith job, master manifest and existing comparison guides; `_source/preparation.json`; `source-preparation.json`; read-only `audit_sources.py`.
