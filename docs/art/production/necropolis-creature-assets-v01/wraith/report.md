# Wraith static master review

Status: **static master awaiting human approval**. One built-in imagegen generation was made and selected. Animation has not begun. Runtime is unverified.

## Deliverables

- `master_rgba.png`: newly generated, tightly cropped 510 x 1445 RGBA master.
- `master_source_1024x768.png`: right-facing master in the common transparent cell.
- `master_mirror_1024x768.png`: exact horizontal mirror, mechanically checked by the shared registration helper.
- `source-vs-master.png`: original and generated figures at the shared display scale, plus enlarged inspection. Its background and labels are review presentation only.
- `master-light-review.png`: the registered figure on a light review background; not a transparent production asset.
- `master-manifest.json`, `generation-provenance.json`, `visual-review.json`: registration, source identity, generation and review evidence.
- `generated-raw-01.png`: unmodified tool output, retained verbatim. No rejected attempts exist.

## Original evidence and actual sampling

Read the complete `job.json` and examined native metadata for `H3sprite/CWRAIT.def`: 18 original groups, 102 timeline entries, 57 distinct indexed drawings. The native metadata, DEF and idle PNG hashes match the job. Group IDs and counts are listed in `visual-review.json`; format-based action names do not establish gameplay behavior or timing.

Viewed `native-idle-6x.png` and the all-groups contact sheet. The latter shows one representative static pose from each of the 18 groups, not every frame. Also viewed these group guides:

| Group | Positions inspected | Visible evidence |
| --- | --- | --- |
| G02 | F0, F4, F7 | Narrow upright idle, hands close to the abdomen, long hanging hem. F0 is the controlling master pose. |
| G00 | F0, F4, F7 | Robe trails backward during the sampled movement poses; pale hands remain distinct. |
| G04 | F0, F5, F9 | Arms shift from the abdomen toward the face; no held weapon in these samples. |
| G07 | F0, F1 | More frontal turn poses expose the sloping shoulders, long sleeves and uneven robe strips. |
| G12 | F0, F3, F6 | Skeletal reach/swipe, trailing cloth and a transient white streak in the middle sample. That streak is excluded from this idle master. |

The original has near-black brown/umber cloth, a close dark cowl, a pale elongated skull-like face with dark sockets, light strands below the chin, and long pale skeletal hands. The robe tapers into hanging tatters without visible feet. The exact material of the pale throat strands is ambiguous at native resolution; the generated treatment interprets them as a ragged pale fringe. No standalone weapon is present in the controlling idle reference.

Viewed `../references/pikeman-rendering-master.png` before generation. Its fine modeled volumes, surface detail and concentrated highlights informed rendering only. CWRAIT supplied the identity, costume, palette, hands, pose and facing. Project art direction and the personal art profile were read; the project source authority controls this proposal.

## Static visual review

Inspected the generated raw, high-resolution crop, registered cell, shared-scale source comparison and light-background review. The pale head and hands remain readable against the dark robe; cloth folds have modeled volume and a restrained brown-black base. The figure faces right, keeps the close idle hand arrangement, and retains its long narrow body and pointed hem. No weapon, armor, Castle colors, label, floor, shadow or added VFX appears in the usable master. Transparent gaps remain around fingers and cloth tatters. The navy and light previews show no obvious rectangular background or ground residue.

The new rendering is an interpretation, not a pixel-identical redraw. Its skull structure is more explicit, its cloth wear is finer and more numerous, and its pale throat fringe is more articulated than the native pixels. These are the main artistic approval risks. Fine finger and fringe details necessarily merge at the registered display size. No separate upgrade-pair comparison, animated continuity review or full per-frame visual audit was performed.

## Registration

The common source-relative scale is 180/73 = 2.4657534246575343, with cell 1024 x 768, anchor (512, 512), native reference (196, 268). Native idle alpha-64 bounds are (180, 180), 33 x 88; the requested mapped bounds are (473, 295), 81 x 217. Wraith therefore uses a 217 px registration height, not 180 px.

The shared helper uniformly scales the generated 510 x 1445 crop to 77 x 217 and places it at (475, 295), retaining the native silhouette center and bottom. Actual alpha >64 bounds are (475, 295), 77 x 216, ending at exclusive bottom 511; the 217 px registration rectangle ends at 512. The lowest antialiased tip accounts for the one-pixel threshold difference. The generated figure is 4 px narrower than the mapped native bounds. No nonuniform stretching or registration override was used. All body parts remain inside generous cell margins.

## Generation provenance

Method: built-in `image_gen`, `transparent_background=true`; one call, no CLI/API fallback and no artwork painted or invented by processing scripts. Mechanical work only copied the raw, cropped, uniformly resized, registered, mirrored and made review presentations.

Exact prompt: `generation-prompt-01.txt`, also preserved verbatim as `attempts[0].exact_prompt` in `generation-provenance.json`. The three reference images, their roles and hashes are recorded there.

Original tool output: `C:/Users/zhouc/.codex/generated_images/01a16383-5861-7752-accc-11b93ac0ea7a/exec-b132a464-0e79-43ed-9667-2f003ca52b5e.png`.

Selected raw: `generated-raw-01.png`.

Generated SHA-256: `ecbbcc08e4ecd2336698645a103aa6f9317885cf06008458b3573478b67853eb`.

High-resolution master SHA-256: `b319f9536813d002cb7832c739a4ed840ac5c61968fa474335b5233d9689c33d`.

Registered source SHA-256: `2824bb8aec497d120e3421f661b51c439e49f355eb0a29d19edd7aba310168ec`.

## Gate and limits

Human approval is required before animation. This delivery contains one static pose and its exact mirror, with visual and mechanical asset inspection only. No tests, build, engine run, import, runtime validation, Git mutation or peer messaging was performed. Original references, shared tools, other creature directories, canonical documents and game files were not edited.
