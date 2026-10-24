# Focused opening correction

The user still prefers the current game. They judged v04 drawings2–7 awkward, v03 drawing2 relatively better, and v03 drawing3 bad specifically because of its arm/sword position. The version reference was presented explicitly in the clarification. No R&D candidate has demonstrated a user-preferred improvement over the installed game, and no other pose is approved by omission.

Open [the review tool](review.html): **current game / v03 reference / v05 opening trial**. Exact drawing selectors and buttons pin v03#2, v03#3 and the new release. The time-step buttons are now labeled1/60s: they advance time, whereas a drawing jump selects a saved key. Labels show when a pose is intentionally reused.

## What changed

v05 keys2–4 reuse the exact RGBA pixels of relatively preferred v03 drawing2, holding its compact chamber from .050 to .126s. This removes the rejected high/swept-back arm chamber from these keys. Three new release drawings replace keys5–7 at .126/.142/.158s. The original guide keeps the fist beside the temple/cheek, elbow below the wrist, then moves the hand forward through release. These are corrective targets, not an acceptance claim.

Keys1 and8–16 retain v04 artwork exactly for context; their body/braking/other issues remain unapproved. All16 saved key times, .720s/.480s action duration, .126–.5075s active window and .210s pacing split remain unchanged. Current-game animation, gameplay source, input/queue/dodge rules, damage, body, lunge, Cast and query curves are untouched. New visual paths are not automatically aligned to those queries.

The generation guide included five new middle targets plus three context/calibration cells. One built-in image-generation request returned eight figures. Its chamber cells were near repetitions, so export deliberately reuses the preferred existing drawing rather than inserting tiny appearance changes. Three generated release cells are actually used. [Exact prompt](prompts/attempt01.txt), [raw output](raw/attempt01.png), [contract](contract.json), [feedback board](inputs/opening-feedback-board.png), [provenance](generation-provenance.json), before/corrected exports and scripts remain preserved. Only original R&D poses/static artwork were supplied for generation; the current-game sequence is a review baseline, not a tracing/retargeting input.

## Export corrections and effort

One common group scale is calibrated from the final raw guard against the retained static guard. The decoder uses two row origins and the existing connected-alpha/component extraction. The initial export incorrectly picked up the upper row's boots while locating the lower guard's head, yielding scale0.43645 and visibly undersized release drawings. It is preserved as [rejected export](outputs/x1-opening-rejected-scale.png) and [rejected board](evidence/opening-board-rejected-scale.png). The corrected decoder isolates the guard component first; the resulting common scale is0.56. This was an export-code error, not a second image-generation request.

The three release cells then receive recorded front-sole integer translations of−14 /0 /+3px horizontally and0px vertically, using the same explicit sole-landmark method as v04. No per-frame scaling, anatomy warping or pixel repaint is applied. The preferred chamber and retained v04 cells are not translated or rescaled. [Measurements](outputs/clips.json) and [before alignment](outputs/x1-opening-before-foot-registration.png) remain inspectable. A stable sole landmark does not prove grip, body volume, rear-foot contact or natural motion.

The single image request took34.882s observed service wall time. There were two export-calibration passes, one rejected. No human pixel painting occurred; active pose authoring, export correction, review-tool work and user review were not separately timed. Reused setup and per-action operations are separated in [effort.csv](effort.csv). No complete production-cost or workflow-winner claim is made.

## Verification boundary

[Verification](evidence/verification.json) records exact preferred-pose reuse, retained v04 cells, unchanged timings/source, native capture conditions and browser drawing jumps. Native playback is isolated rendering; it does not simulate the3px lunge or combat. Previous v02 integration evidence does not validate v05's new release/contact correspondence. Human visual acceptance, complete transition/alignment quality and integrated v05 combat remain open. No production asset installation, commit, push or live publication occurs.

Rebuild with `python process_outputs.py` and `python build_review.py`; open `preview/project.godot` for the native version. The root .gdignore excludes this research from the main game project.
