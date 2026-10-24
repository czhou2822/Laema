# H02 — preparation loading from saved feedback

Status: **blocking candidate, awaiting human artistic review**. Open [the character-only comparison](../2026-10-23-v08-game-integration/review.html?experiment=H02): **Current game / H01 previous / H02 preparation test**. The [previous H01/v08 comparison and annotations](../2026-10-23-v08-game-integration/review.html?experiment=H01) remain intact.

## Feedback used, with its original version scope

The immutable [feedback snapshot](inputs/feedback-snapshot.json) preserves the five active notes read from H01 annotation revision9.

| User observation | Source | Treatment in this experiment |
| --- | --- | --- |
| Game preparation feels more powerful | Game frame2 | Quality/principle reference only; no game pose/sequence supplied to generation. |
| Elbow handoff into5 is awkward | Game frames3–4 | Retained as a separate release concern. These are not H01 preparation-frame numbers. |
| Follow-through reads as thrust | Game frame6 | Retained separately; not silently applied to H01 or to gameplay. |
| Preparation weak; static frames add little | v08 frames2–4 | Direct target. H01 inherits these exact pixels, so the criticism applies to its unchanged hold. |
| Release comparison looks the same/too similar | v08 frames5–7 | No positive H01 quality verdict inferred. The note does not unambiguously distinguish comparison between drawings from comparison between versions. |

H01 preparation2/3/4 was one identical drawing held from0.050 to0.126s, represented by three saved keys. Those keys did not add three new poses. A strong hold can be appropriate; H02 tests a deliberate body-load progression rather than assuming that more frames alone improve quality.

## One targeted phase correction

| H02 frame | Heat0 time | Proposed performance |
| --- | --- | --- |
| 2 |0.050s| Initial rear-leg load |
| **3** |**0.075s**| **Peak loaded coil — main inspection point** |
| 4 |0.100s| Begin uncoiling toward the retained release at5 |

Only frames2–4 change. Frames1 and5–16 remain exact H01 RGBA pixels, including the existing grip trial. Every key time remains exact. Total duration remains0.720s at Heat0 /0.480s at fixedHeat100. No Player code, native attack Resource, query, active window, collision body, lunge, damage, input or other action is changed. The primary game retains its installed artwork. H02 has not been installed or newly run in Godot; these are source-timed character previews.

This tests a **coordinated preparation treatment**, including body/arm/shield/chamber placement. It is not a pure hip-only causal test. The [corrected original guide](inputs/corrected-preparation-guide.png) and H01's own static artwork were the only generation references. No existing game animation was downloaded, traced or retargeted.

## Actual output, corrections and limits

Attempt1 is [rejected](evidence/rejected-attempt01.json). The agent placed hip/knee targets too low relative to source anatomy, and the generator enlarged figures inside the full448px cells. Both are recorded; the planning error is not blamed on the generator. The retry corrected the source-landmark mapping and used a tighter, fixed-framing crop. Both raw outputs and prompts remain preserved.

Attempt2 produced three distinct body silhouettes. One common strip transform normalizes the crop; translations(-1,2),(-6,2),(-4,2) register the front sole. Before sole cleanup, the rear contact landmark differed by about5/7.5/5px horizontally. Source pixels in rows393–447 were then restored with a narrow388–392 transition. Pre-cleanup frames remain available. This is explicit correction work, not proof that the generator delivered stable feet or correct biomechanics. Boot/ankle seams, material/head/hair drift and the4→5 handoff remain review risks.

Core-body silhouette differences between the three exported poses are957/1179 pixels for2→3 and3→4. These establish visible pose changes, not power, naturalness or a quality win. [The experiment record](experiment.json) keeps the hypothesis, actual modifications, remaining feedback and **pending** human verdict separate. [Comparison board](evidence/preparation-comparison.png), [sprite strip](outputs/x1-h02-preparation.png), [attempt1 prompt](prompts/attempt01.txt), [attempt2 prompt](prompts/attempt02.txt).

Two built-in image-generation requests took about30s and27s of observed wall time at1s UTC resolution. Human pixel painting was not performed. Active art direction, export correction, overlay implementation and user review are not interchangeable with that service wait. Reusable overlay/tool setup and per-action generation/registration operations are recorded separately in [effort](effort.csv). No production workflow winner or quality approval is inferred.

## Drag-and-drop comparison

Drag a character or its **Drag** handle onto another panel. It creates a50% transparent mix aligned at the shared foot anchor and the same action time. Use the opacity slider;0% shows the base and100% the overlaid version. **Clear overlay** restores the single version. Clicking the handle also provides a destination selector. Overlay controls sit below the images so all three panel baselines remain aligned.

Use **Note base** or **Note overlay** to choose which version the annotation addresses. Notes retain the version SHA/frame/range and the comparison pair, both image hashes, corresponding frames, opacity and action time. Showing a saved overlay note restores that comparison. H02 notes save in [annotations.json](annotations.json), separately from the preserved H01 notes. Unsaved drafts are backed up per experiment. An annotation is an observation, not an automatic acceptance decision.

Actual browser checks covered native handle dragging and dragging the character itself, opacity changes, matched panel origins, and overlay-note target identity. An unchanged source frame7 rendered identically at0% and50% mix: screenshot maximum RGB difference0. This prevents false double-edge differences from the blending method. The annotation backend passed version/time/comparison persistence checks without modifying user H01 notes. These checks do not establish artistic quality or game readiness.

## Next review

Watch the full action at1×, then inspect2 →3 →4 →5. Judge whether the preparation reads more forcefully and connects cleanly into release, and whether appearance/boot changes outweigh any gain. Annotate H02 directly. No new gameplay recording is required for this art verdict; integration remains a later separate check if the visual change is worth retaining.
