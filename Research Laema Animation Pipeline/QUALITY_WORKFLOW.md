# Small animation experiments

Use one immutable baseline and one written experiment per meaningful iteration. The user gives the final artistic verdict. A successful export, changed pixels or a clean engine run never advances an artistic gate automatically.

| Stage | Required review criteria | Stop condition |
| --- | --- | --- |
| Blocking | Essential poses read at gameplay scale; anticipation/release/stop are clear; grip/limb construction and silhouette support the intended action; the action fits the existing gameplay contract. | Weak performance or unreadable poses: revise the blocking rather than add detailed drawings. |
| Refinement | Coherent arcs/spacing, planted feet and body weight, believable momentum/braking, stable hand/weapon attachment, consistent body/equipment volumes, clear legal transitions. | A new interpolation or pose creates a hitch, drift, broken grip or poor return: reject/revise that specific change. |
| Polish | Secondary motion and offsets support the already accepted performance; edges/material details and transitions stay consistent at normal speed. | A detail pass changes the performance or character: return to the affected earlier stage. |

Each experiment records: observable problem; competing explanations; selected hypothesis; intended change; protected variables; predicted result and regression checks; actual changes; evidence; improvement/regressions/unresolved issues; and accept/reject/revise/pending verdicts. The technical result and human verdict have separate fields. Do not silently promote the latest file into the accepted baseline.

References are principles and explicit targets, not animation to copy. Prefer one recoverable local reference: a user-selected game clip, permitted movement recording, or an original key-pose construction. Record its source, relevant moments, what principle is being tested and what must remain Laema-specific. Import no reference automatically. Existing game art can remain a visual quality benchmark without supplying a sequence to generation or tracing.

For H01 the reference is an original wrist/palm/hilt construction across three release poses: fingers enclose the handle, the guard sits beyond the index/thumb side, and the wrist connects the forearm to the palm without a floating grip or abrupt hinge. That anatomical/continuity target does not approve the rest of the motion or claim a final fencing style.

Review order: character-only source flipbooks at native gameplay size/normal speed; the corresponding key poses and silhouettes; slow/stepped playback for diagnosis. Use actual-game context/return/interruptions as a separate integration check, rather than recording the scene for every artistic iteration. Keep draw exposure distinct from gameplay events. Use an accepted-action/contact event only when its timestamp is observed in engine logs; a visually emphasized drawing is not a hit marker.

Use existing pause, drawing/frame counters, grip bookmark, A/B playback and linked pan. Keep observations in the experiment record initially. Add annotation/event UI only when a concrete repeated review need justifies it. Reusable setup, per-action generation/corrections, agent elapsed wall time and human artist/review labor are recorded separately; unknown effort stays unknown.

Direct review notes: use the comparison tool to pin observations to a version SHA and source drawing/range. Read active annotations before the next experiment. Preserve removed-note history, but do not treat validation/deleted records or a local improvement note as broad artistic acceptance.
