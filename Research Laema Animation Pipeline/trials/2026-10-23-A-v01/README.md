# A diagonal cut — actual production-method trial

User selected A and assigned this independent R&D to Combat on 23 October 2026. This is the first controlled artwork trial, not production acceptance.

**User visual feedback:** the left AI strip is clearly better than the other two; the rig and hybrid sword grips fail. All three use motion A. This is relative quality feedback, not a final workflow or production-art approval. The current rig is a simple scripted cutout assembly that has not reached a competent finished baseline; its failure does not establish that rigging generally loses to AI generation. The provisional recommendation is to develop and test the AI result further.

Open [the synchronized comparison](comparison.html), or run [the standalone Godot project](preview/project.godot). Both display actual raster outputs at the same action clock. Godot controls: Space pause, Enter replay, H Heat, F facing, arrows step, S slow, Z enlarged focus, 1/2/3 select. The pre/post loop holds are review aids outside the action.

## Demonstrated results

| Method | Actual output | Correction work performed | Remaining limits |
| --- | --- | --- | --- |
| Reference-guided AI strip | Ten original A key drawings, matched to original authored times | Two generation/edit requests; failed equal-grid extraction preserved; connected-component decoder with one group scale/row-column pitch; one explicit endpoint reuse | Pose/equipment contours still drift. The cleanup edit changed 229,587 RGBA pixels by more than 8 levels; alpha overlap with the first attempt is 0.909. It was not a strictly local edit. |
| Textured 2D cutout rig | Sixteen generated raster parts, 51 motion samples, two-bone sword arm, fixed 88px target blade | Two artwork requests; armless-torso preparation; sixteen extracted/bound parts and calibration constants | Visible joint/clothing seams, proportions and part perspective need art preparation. This is an executed cutout trial, not a successful polished rig. |
| Rig plus replacement drawings | Same rig with generated upper-body repairs at .100s and .210s | One repair request, two explicit asset registrations, two compositor corrections; rejected v01/v02 preserved | Only 2/51 frames repaired. Registration/contour discontinuity remains. This limited attempt is rejected as a production candidate; it does not establish the quality or cost of a finished hybrid action. |

All requests used built-in imagegen. The service's model revision, seed, generation hardware and internal workflow were not exposed. The local RTX4090 rendered Godot; it did not generate these images. The character/equipment pack is provisional Laema Open plus one static Fire Idle cell; no existing motion sequence supplied the new movement.

The AI decoder reports 0px variation in the extracted figures' lowest opaque row after one group transform. This limited registration statistic does not prove stable anatomical feet, correct scale, blade correspondence or in-game placement. The AI method has ten drawings while the rig has 51 exported samples: this difference is explicit, not an equal-frame-count comparison.

## Measured effort and provenance

- Five image-tool requests: two initial requests ran concurrently (94s observed wall each), two corrections concurrently (90s each), then a 54s hybrid repair. Overlapping waits sum to 238s of generation-phase wall time, not 422s of sequential work.
- Human artist cleanup was not performed or timed. Human review time and the labor needed to reach acceptance are unknown. No retrospective hours or finished-production cost ratio is claimed.
- Reusable work: guide/registration contract, layout decoder, sixteen cutout bindings, renderer and exporters. Per-action work: A targets, generated strip, two repair drawings and their registrations. No second-action reuse measurement exists yet.
- [Prompts](prompts/), [raw attempts](raw/), [measurements](outputs/metrics.json), [contract](contract.json), [effort log](../../effort-log.csv), [file hashes](artifact-manifest.json).
- `build_trial.py`, `review_geometry.py`, then `export_review.py` reproduce the local outputs. Generated input images remain necessary; they are not reproduced deterministically by prompts.

## Contact alignment is an unresolved gameplay decision

[The overlay](contact-correspondence.png) compares the original A blade with the unchanged native X1 query. Across 201 source samples in the existing active window, the maximum tip gap beyond the query radius is about145px and no sample contains the full A blade. These are source-space correspondence measurements, not collision or playtest outcomes, and not a new engine defect.

[A concrete spatial-curve proposal](outputs/contact-adaptation-PROPOSAL.json) follows A's hand-to-tip with the same radius, markers and pacing. It is **unapproved and not installed**. It changes where contacts can occur; unchanged timing/damage does not make that spatial change gameplay-neutral. Alternatively, A can be revised to fit the current query path. The user owns that choice.

## Recommendation supported by this pass

Keep the original authored motion data, registration contract and normal-speed engine comparison as mandatory stages. Do not adopt unattended whole-sheet generation or the current generated-parts rig as production workflows. The targeted edit and cutout-preparation failures demonstrate additional correction work; they do not prove that AI or rigging generally wins.

No production workflow winner is recommended yet. Resolve the motion/contact contract, obtain visual correction feedback, finish a comparable corrected action, then measure actual Idle/Walk/X2/Cast/Dodge/reaction transitions and reuse on another approved original action. 3D was not tested: the demonstrated problems here are layout, matte, part preparation and registration; depth/volume has not yet justified its setup cost.

## Validation boundary

Godot4.7.1 graphically loaded all three atlases and rendered synchronized comparisons. Captures cover fixed Heat0/100, both facings and native1280x720. Browser controls provide the same phase clock and frame stepping. The original A/B/C data also passed the local219-sample blade check.

These are isolated renderer runs. There is no product combat integration, actual target/contact-result test, legal transition validation, controller/feel acceptance, second-action trial, production-art approval, commit, push or live publication.
