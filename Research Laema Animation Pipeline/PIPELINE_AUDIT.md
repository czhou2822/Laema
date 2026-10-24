# Pipeline investigation — 24 October 2026

Inspected source: `574270f66bcbeed72db07778ef612ee37ea8d932`, plus the preserved local viewer edits. Earlier tests retain their recorded revisions. Current X1 art, timing and geometry match the prior trial; other combat/feedback/roster source has changed. The existing integrated Gym fixture is a preserved older source copy, not a test of every current-main change.

## What actually makes the animation

1. GPT authors original joint positions, pose times, guides and image prompts. [author_studies.py](author_studies.py) creates32 A/B/C keys using joint coordinates, trigonometry and an elbow construction. These are original blocking proposals, not captured or retargeted movement.
2. Built-in image generation paints reference-guided raster drawings. It does not expose a persistent skeleton, shared anatomy model, model revision or seed. GPT controls the request and supplied references; it does not directly control the resulting pixels. [v05's prompt](trials/2026-10-23-x1-opening-v05/prompts/attempt01.txt) and [v08's prompt](trials/2026-10-23-x1-structural-grip-v08/prompts/attempt01.txt) show the instructions actually used.
3. Python extracts alpha components, normalizes scale, registers feet, reuses selected drawings and packs448px cells. This is asset processing, not anatomical correction. [v05](trials/2026-10-23-x1-opening-v05/README.md) records a rejected scale export; [v04](trials/2026-10-23-x1-weight-transfer-v04/README.md) required14 foot translations.
4. Godot's native Animation resource switches Sprite textures/rectangles using discrete keys. It does not interpolate the anatomy between these painted drawings. v08 has16 saved keys but13 distinct raster cells. The earlier [cutout experiment](trials/2026-10-23-A-v01/build_trial.py) really transformed generated parts with joint targets/two-bone arm construction, then exported raster samples; it was not a successful polished skeletal/hybrid trial.3D remains untested.
5. [prepare_game.py](trials/2026-10-23-v08-game-integration/prepare_game.py) patches only an isolated copy's X1 texture/drawing keys. [build_review.py](trials/2026-10-23-v08-game-integration/build_review.py) indexes actual Gym captures. The browser aligns first accepted X1, replays measured timestamps and supports scrubbing, frame/drawing counters and linked pan. Standalone sprite playback and actual-game captures are distinct evidence.

## Where quality is being lost

| Category | Evidence | Implication |
| --- | --- | --- |
| Generation method | Whole-character regeneration changes unrelated anatomy, equipment and proportions. v08 changed15,137 whole-pose RGBA pixels for an arm correction. | Use bounded edits and verify protected pixels; additional prompts alone do not establish consistent animation. |
| Creative direction | The original A guide explicitly specified the near-ground85° blade drop later rejected by the user. | The pose plan can be the problem even when generated output follows it. More inbetweens cannot repair the chosen performance. |
| Implementation accuracy | v06 forcibly restored the original alpha, making a changed wrist silhouette impossible. v05 also had a caught scale-calibration error. | Check that the requested kind of change is actually allowed by export/compositing. |
| Evaluation | Large iterations mixed body poses, blade arcs, exposure and registration changes. Most reviews had no predeclared prediction or verdict. | Isolate one cause and preserve an explicit baseline. Pixel changes and clean Godot playback are not quality verdicts. |

The most actionable current issue is the user's repeatedly identified wrist/hilt relationship through release. Body stiffness, braking and appearance drift remain separate open issues. No new animation-engine defect was established. Gameplay feedback can alter perceived impact, but a malformed grip visible in a paused frame cannot be explained by camera shake or hit feedback.

## Smallest useful next experiment

[H01](trials/2026-10-24-x1-quality-h01/experiment.json): change only the sword-arm construction in v08 release drawings5–7. Keep all body/foot pixels outside explicit masks, blade/guard pixels, other13 keys and every key time fixed. Use an original wrist/palm/hilt construction guide rather than downloading another animation. Compare the entire action at native scale/normal speed as well as the three edited poses. Technical conformance and the user's artistic verdict remain separate.

The existing viewer is sufficient for this experiment. A small hypothesis/result record and a review link are useful now. A reference library, third viewport, annotation database and generalized event-alignment architecture are deferred; they would add work before resolving this concrete quality question.
