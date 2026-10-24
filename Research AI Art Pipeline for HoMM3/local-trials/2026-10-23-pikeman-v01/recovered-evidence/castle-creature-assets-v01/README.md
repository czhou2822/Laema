# Castle creatures — approved masters and animation collection

Status: **The13 selected masters are approved; the generated animation review collection is exported.** The user accepted the cleaned selected13-creature review and instructed the animation pass to proceed. Start with the [animation library](animations/review-library.html) or [delivery notes](animations/README.md). All212 source sequences and1,244 timeline frames per orientation are present. Master approval and export QA are not animation-user, runtime or final production-art approval.

## Review images

**Use the [clean selected review](selected-review-v01/comparison-13.png): exactly13 creatures, one image per creature.** The selected-review-v01/creatures folder excludes the superseded Archangel generation. The earlier in-chat gallery displayed both Archangel revisions; these are not two different creatures. See selected-review-v01/README.md.

- [Full master comparison](comparison-masters.png): the13 new masters beside the existing approved Pikeman. Each artwork is shown at the intended calibrated review scale, not independently fit-to-card.
- [Original-versus-master roster](source-vs-master-roster.png): compact visual comparison of original sprite references and generated interpretations.
- [Selected light/dark alpha checks](selected-alpha-check.png). Full matte strip: light-dark-mattes.png.
- Each creature also has an individual source-versus-master image with no thumbnail reduction.

| Number | Creature | Transparent high-resolution | 768×640 frame | Source check |
| --- | --- | --- | --- | --- |
| 01 | Halberdier | [Master](halberdier/master_rgba.png) | [Game-scale](halberdier/master_source_768x640.png) | [Original comparison](halberdier/source-vs-master.png) |
| 02 | Archer | [Master](archer/master_rgba.png) | [Game-scale](archer/master_source_768x640.png) | [Original comparison](archer/source-vs-master.png) |
| 03 | Marksman | [Master](marksman/master_rgba.png) | [Game-scale](marksman/master_source_768x640.png) | [Original comparison](marksman/source-vs-master.png) |
| 04 | Griffin | [Master](griffin/master_rgba.png) | [Game-scale](griffin/master_source_768x640.png) | [Original comparison](griffin/source-vs-master.png) |
| 05 | Royal Griffin | [Master](royal-griffin/master_rgba.png) | [Game-scale](royal-griffin/master_source_768x640.png) | [Original comparison](royal-griffin/source-vs-master.png) |
| 06 | Swordsman | [Master](swordsman/master_rgba.png) | [Game-scale](swordsman/master_source_768x640.png) | [Original comparison](swordsman/source-vs-master.png) |
| 07 | Crusader | [Master](crusader/master_rgba.png) | [Game-scale](crusader/master_source_768x640.png) | [Original comparison](crusader/source-vs-master.png) |
| 08 | Monk | [Master](monk/master_rgba.png) | [Game-scale](monk/master_source_768x640.png) | [Original comparison](monk/source-vs-master.png) |
| 09 | Zealot | [Master](zealot/master_rgba.png) | [Game-scale](zealot/master_source_768x640.png) | [Original comparison](zealot/source-vs-master.png) |
| 10 | Cavalier | [Master](cavalier/master_rgba.png) | [Game-scale](cavalier/master_source_768x640.png) | [Original comparison](cavalier/source-vs-master.png) |
| 11 | Champion | [Master](champion/master_rgba.png) | [Game-scale](champion/master_source_768x640.png) | [Original comparison](champion/source-vs-master.png) |
| 12 | Angel | [Master](angel/master_rgba.png) | [Game-scale](angel/master_source_768x640.png) | [Original comparison](angel/source-vs-master.png) |
| 13 | Archangel | [Master](archangel/master_rgba.png) | [Game-scale](archangel/master_source_768x640.png) | [Original comparison](archangel/source-vs-master.png) |

## Files per creature

- master-generated-source.png: unchanged first built-in generation.
- master-corrected-source.png: Archangel's selected one-sword repair, where present; the first generation remains preserved.
- master_rgba.png: high-resolution cutout with transparent margins, no backdrop or ground shadow.
- master_source_768x640.png: registered original-orientation ready/idle review frame.
- master_mirror_768x640.png: exact horizontal mirror of that frame.
- native-idle.png and native-idle-6x.png: original reference crop and unmodified nearest-neighbour enlargement, NOT new Laema artwork.
- source-details.png: original movement/attack reference samples; source-scale-guide.png: original-pixel registration/scale guide.
- source-vs-master.png: review comparison, NOT a runtime atlas.

The files in the table above are one-pose masters. The separate [animation collection](animations/README.md) contains the generated flipbooks and its current review status; neither is an engine import or a separated rig.

## Scale and rendering

Original Heroes III art supplies each creature's identity, original pose/material colours and native proportions. The approved repainted Pikeman supplies the high-resolution modeled finish and upper-left light. Deliberately retain differences such as Archer's light headgear versus Marksman's mail, no-shield Swordsman versus shielded Crusader, brown Monk versus blue/gold Zealot, brown/gold Griffin versus white Royal Griffin, and plain Cavalier versus plumed/barded Champion.

The accepted calibration is180px Pikeman body from a73px native reference, factor180/73. master-export-spec.json records visually identified source crown/helmet/hood/crest and generated master landmarks. Each master receives one uniform scale, with no independent width/height stretch; body scale is not derived from weapon height. Native idle horizontal envelope centers provide the source-relative horizontal placement. Contact is aligned to image-space y448 within768×640 cells, with the common reference anchor(384,448).

Landmarks are visual calibration, not recovered original anatomy, an exact source-pixel redraw or an engine pivot. Generated poses, feather shapes, limb proportions, cloth folds, heraldry and weapons retain interpreted detail. The source comparisons expose those differences for approval. Riders/mounts and winged creatures are not normalized to the same180px total silhouette as Pikeman. These are static masters; no frame-to-frame scale or motion is established yet.

The raw generations requested genuine transparency. Export keeps intermediate edge alpha, clears alpha<=2 plus RGB, and makes alpha>=240 opaque; original generation pixels remain in source files. No new background artwork was painted by the export scripts.

## Checks and corrections

- All13 masters and their original-reference comparisons were visually inspected. Source idle crops and supporting movement/attack samples were inspected before generation.
- Archangel's first master had an extra tangled scabbard/second-hilt shape. The built-in image tool replaced that with one coherent lowered sword; see master-repairs.json.
- Every exported master has true alpha, a fully transparent canvas border and contact envelope ending at y448. All13 mirror frames decode exactly as their corresponding horizontal transforms.
- PNG dimensions, alpha and mirrors were checked by validate-masters.cjs; results are in master-qa.json.
- The initial master pass did not include animation work. Subsequent animation production and its evidence are recorded separately in animations/. No Godot imports, runtime checks, source/scene edits, gameplay/API changes, commits or pushes were performed. Existing Pikeman assets were only read.
- These static masters were accepted by the user after the clean selected-roster correction. That acceptance does not constitute animation, runtime or final production-art approval.

## Approved animation scope

13 creatures,212 source groups,1,244 timeline frames in their unmirrored source orientation, plus mirrored outputs. source-inventory.json preserves every source group ID/block, exact frame order/count, repeated frame pixel hashes, margins, page coordinates and original DEF hash. It was compiled from the readable local collection, not reconstructed from filenames.

The master-pass supporting samples did not certify every source sequence. The subsequent animation pass uses native pose guides and records stepwise creature reviews separately from collection-level export checks. Keep turning/angled sequences distinct from uniformly right-facing motion. Preview10fps is illustrative, not original game or approved Laema gameplay timing.

The master-approval gate was fulfilled before animation production began; see master-approval.json. Follow animations/README.md for current coverage, corrections, motion-review limitations and export QA. Runtime integration remains a separate operation.

## Provenance and reproducibility

Method: built-in image-generation artwork, followed by mechanical cutout export, uniform scaling, registration and comparison layouts. New generated reinterpretations are distinct from original Heroes III references and the existing approved Pikeman. These files do not grant rights to original game artwork or establish a final Laema character design.

Source collection: C:/Users/zhouc/OneDrive/Documents/ChatGPT/Laema/docs/art/references/heroes3-original-flipbooks/sprites/H3sprite.
Original paths and DEF hashes are recorded in source-inventory.json. No originals were modified.

Prompt records: master-prompts.json (common spec and initial creatures), remaining-master-prompts.json (full creature descriptions), master-repairs.json (repair and two prompt appendices), generation-files.json (initial outputs). Selected source files, crop/scale/placement data and output hashes are in masters-manifest.json.

Reproduction scripts: prepare-references.cjs, inspect-masters.cjs, export-masters.cjs, validate-masters.cjs. Inspect scripts perform read/copy/export operations only in this scratch package; they do not import or modify engine assets.

