# H01 — release grip continuity

Status: **artistic verdict pending**. The user requested a quality-driven workflow and one focused experiment, rather than a larger comparison application. This is a blocking/construction correction inside the existing X1, not a polish pass or production installation.

Open [the three-character comparison](../2026-10-23-v08-game-integration/review.html?experiment=H01): **Current game / v08 previous / H01 this iteration**. It plays the actual source sprite sheets at their saved action times, on a neutral background with a common foot anchor. No scene, enemy, HUD, camera, hit-stop or root lunge is included in this art review. Normal size is1× gameplay sprite scale. Pause/scrub, frame stepping, Heat0/100, facing, inspection zoom, shared pan, edited-region outlines and version-specific annotations are available. The [H01 integration recordings](../2026-10-23-v08-game-integration/review.html?experiment=H01&view=recording) and [original-game/v08 recordings](../2026-10-23-v08-game-integration/review.html?view=recording) remain optional technical checks. The [playable copied project](gameplay-preview/project.godot) is unchanged.

## Which frames to review

These frame numbers apply to **v08 and H01**. The current game has8 keys, while both trials have16; compare equal action times rather than equal frame numbers across all three.

| Trial frame | Heat0 interval | Focus |
| --- | --- | --- |
| 5 |0.126–0.142s| Fingers enclosing the upright hilt |
| 6 |0.142–0.158s| Grip connection while the blade rotates |
| **7** |**0.158–0.184s**| **Forearm → wrist → palm → hilt connection** |

The5/6/7 buttons pause all versions at the matching source time. At trial frame7 the current game shows frame4/8. H01 changes local arm/grip pixels in these three keys; the other13 trial cells, all key times, protected sword regions and surrounding body remain unchanged. This does not correct body weight transfer or braking.

## Annotating directly

Click a character to place a point and open a note, or choose **Note this frame**. The editor captures the version, sprite SHA and frame; it stays anchored when the timeline moves. **From frame / Through frame** supports a range. Save persists the observation in [annotations.json](annotations.json), with Heat/facing and optional native-cell point coordinates. Notes can be shown, edited, softly removed/restored and exported. Unsaved drafts have a browser-local backup; saved notes live in the research folder. Prior saved state is backed up and edit/removal history is retained. No note is automatically promoted into an accepted art/gameplay decision.

Run `python "Research Laema Animation Pipeline/review_server.py"` from the repository root; a generic static HTTP server cannot save notes. Continue from active, nondeleted notes in the main annotations file, not its backup. The clearly marked UI validation note is removed and is not artistic feedback. Eight isolated storage checks and a live save/reload/remove check were performed; user-authored feedback was not replaced.

The user's correction supersedes the earlier emphasis on gameplay captures for artistic review. Source flipbooks are the default now; scene recording is reserved for integration questions. This viewer update generates no new art and establishes no quality improvement by itself.

## Question and controls

The observed problem is the user's repeatedly rejected wrist-to-sword relationship. Competing causes are inconsistent wrist/palm/hilt construction, body/hip sequencing, and whole-character redraw drift. H01 tests the first explanation: can a consistent closed grip in release drawings5–7 make that short phase read more convincingly?

The [original construction reference](inputs/release-grip-construction.png) separates elbow, wrist, palm and fixed handle axes. It specifies closed fingers around the hilt and a continuous wrist, rather than a sword emerging from a fist endpoint. It is a minimum construction target, not a polished motion reference or an anatomical acceptance claim. No external animation was downloaded, traced or retargeted. The user's preferred current-game animation remains a visual quality benchmark, not a generation input.

Only three local arm crops were generated. One common scale normalized the three-panel output; fixed-guard registration used translations(0,0),(-1,1),(-2,1) native pixels. Explicit masks permit arm/hand alpha changes while restoring protected source pixels. The13 other cells, all16 drawing times, body/feet outside masks, protected blade/guard half-planes and pommel regions remain exact. Native attack clocks, geometry, markers, movement, damage, input and other actions remain unchanged. Raw AI output, prompt, original inputs, registered proposals, masks and final output are preserved.

## Result, without conflating correctness and quality

| Evidence | Result | Meaning |
| --- | --- | --- |
| Export/preservation | Pass; changed RGBA pixels1094/1253/1077 in the three masked drawings. Alpha silhouette changes22/1/49 pixels. | The edit is bounded. Counts do not establish anatomy or artistic quality; drawing6 barely changes its outer alpha silhouette. |
| Agent close-up impression | Finger/handle overlap appears clearer. | Subjective, limited to the close-up. It is insufficient to accept the hypothesis or the full action. |
| Regressions/open issues | Cuff/sleeve shading changes inside masks require review. Existing stiffness, braking and v08 key7 body/equipment drift remain. | H01 does not solve these independent problems. No broad quality win is claimed. |
| Normal-speed game | Both controlled runs completed; X1 contact/orb/Charging/Cast impact/Dodge/later interruption observed. Player87.5HP/Enemy180HP at command end in both. | Runtime conformance and review material, not artistic acceptance or encounter completion. |
| Final quality verdict | Pending user. | Accept/reject/revise H01 only after native-scale/normal-speed review. If the difference is not useful, record that outcome rather than promote it. |

The [experiment record](experiment.json) stores the problem, competing explanations, prediction, intended/actual changes, regressions, remaining issues, observed event timestamps and separate technical/agent/human verdicts. The [4× diagnostic board](evidence/arm-comparison-4x.png) helps explain the change; it is not the primary quality test.

## Runtime scope and effort

Both runs use a fresh copy of the preserved `d97c7280` Gym fixture. Current main was `574270f6`; its later feedback/roster changes are not validated by this older fixture. All832 inventoried fixture files remain exact except the copied X1 texture reference; a unique application name isolates test preferences. [Preservation evidence](evidence/runtime-preservation.json) records that boundary. A test-only driver initializes paused until synthetic input routing is installed, then runs the existing schedule at the normal clock. It changes no gameplay code/settings. Both runs recorded zero external input and at most6ms scheduled-input lateness.

There are401/410 measured viewport samples; both median intervals are21ms, with maxima26/27ms. Playback preserves their timestamps and aligns at first accepted X1. This is not stable60fps or identical-state deterministic evidence. Existing13 ObjectDB /9 resource shutdown diagnostics remain. The first candidate import pass attempted to load its PNG before import; the actual subsequent game run loaded the candidate successfully. No high-Heat/both-facing combat matrix or physical-controller acceptance is added here.

One built-in image request took about28s wall time measured at1s UTC resolution. No human pixel painting occurred; human review time is unknown. Reusable work is the bounded-crop/mask process, frozen runtime fixture and existing viewer. Per-action work is three original construction targets, one prompt, three guard registrations and three masks. Agent elapsed wall time includes reasoning, tools, waits, processing and review setup; it is not artist labor or a production-cost estimate. See [effort](effort.csv).

## Minimal workflow change

[The audit](../../PIPELINE_AUDIT.md) explains the actual generation path and bottlenecks. [The three-stage protocol](../../QUALITY_WORKFLOW.md) requires blocking, refinement and polish criteria, with human quality judgments separated from technical checks. This experiment adds a small hypothesis/result record and a question/reference link in the same viewer.

Frame annotations are feasible as version-hash/time/range records, but a note editor/database is deferred until repeated reviews need one. First-accepted-X1 alignment and the existing pose bookmark suffice here; additional observed contact/finish timestamps are saved without inventing an impact pose. A third reference panel is unnecessary for this test. No new rig/3D system, bulk animation replacement, gameplay change, commit, push or publication occurred.
