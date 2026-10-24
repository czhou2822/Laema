# Findings — original Laema animation pipeline

Latest integration: the user requested "put it into the game and lets see". [v08 actual-game trial](trials/2026-10-23-v08-game-integration/README.md) is a fresh isolated Gym copy. [The current replay](trials/2026-10-23-v08-game-integration/review.html) compares real current-art/v08 viewports; a separate normal-controls playable window was opened. Only copied X1 artwork/drawing keys changed. Both sequences observed X1 contact/orb/Charging/Cast impact/Dodge/incoming interruption. Source gameplay is unchanged. Variable sample intervals, pre-command controller events, scheduling limits and retained shutdown warnings are recorded in its evidence. Human visual acceptance remains pending; this test request does not approve artwork or propagation. Current game remains the last stated overall preference. This newer run supersedes older "last integration v02" statements only within its stated scope.

Latest wrist test: the user found v05's wrist/sword relationship wrong. v06 changed757 RGB pixels under the original alpha; its close-up detail read better, but the user reported no visible pose/motion difference. That is an unsuccessful structural correction. Unrun v07 cosmetic propagation stopped. [v08](trials/2026-10-23-x1-structural-grip-v08/README.md) changes the whole one-pose render using explicit wrist/palm/hilt targets;486 inspected arm-region alpha pixels differ, with a visibly different forearm direction. It also changes body/equipment details. The demonstrated tradeoff is detail preservation without structural repair in v06 versus structural change with detail drift in v08. Neither establishes a production workflow or anatomical acceptance. Static native snapshots are separate from motion quality; the current game remains the last overall preference.

Latest human result: the user still prefers the current game. v04 drawings2–7 are awkward; v03 drawing2 is relatively better and drawing3 has a bad arm/sword position. Thus the R&D has not established a visual-quality improvement over the installed game. [v05](trials/2026-10-23-x1-opening-v05/README.md) tests an exact preferred-pose hold and three new release drawings; later v04 poses remain unapproved. The first export had a scale-calibration code error, caught in its board and corrected with component-isolated calibration; failed output is retained. Standalone rendering and image preservation checks do not establish naturalness or production readiness.

Prior v04 slice: the user requested weight transfer, improved stopping and a steeper downward blade, with unchanged gameplay. [v04](trials/2026-10-23-x1-weight-transfer-v04/README.md) used14 new working drawings and original full-body targets. The source sheet needed four row origins and14 explicit front-sole translations (up to23px sideways); before/corrected exports remain inspectable. Output generation alone was not a clean anchored flipbook. Existing timing and gameplay/query data remain unchanged.

Prior visual feedback: refined AI improved the first study but remained below expectation; the user rejected the near-ground sword drop and positively received the synchronized review tool. The original pose plan itself pointed the sword85° down at .340s, so adding inbetweens did not fix the underlying motion. [v03](trials/2026-10-23-x1-followthrough-v03/README.md) revised seven follow-through/recovery drawings toward a shallow diagonal while retaining nine cells and gameplay timing.

Earlier local slice: AI was chosen for continued refinement. A16-key X1 candidate and original8-key Cast trial were produced, exported with reused processing, graphically compared at both Heat settings/facings, and exercised in a copied real-game project. See [the v02 results](trials/2026-10-23-ai-refine-v02/README.md). Original gameplay/source files and copied gameplay code/settings remain unchanged; only copied sprite texture/frame keys differ. Visual quality and complete production repeatability are not accepted yet.

Local continuation, October23: the user selected A and assigned this R&D to Combat. Actual method trials, local Godot4.7.1 rendering evidence, rejected corrections and a pending motion/contact decision are recorded in [local reconciliation](LOCAL_RECONCILIATION.md) and [the trial report](trials/2026-10-23-A-v01/README.md). The original cloud diagnosis/approval labels below remain a historical snapshot, not the latest selection state.

Inspected revision: `16b4c3b7199589439a276881eca7516cc0f7401c`. Inspection covered current Fire five-hit textures/resources, all four Cast resources, Fire Idle/Walk, AI studies, the later reviewed handoff, animation clocks, registration, input queues and contact geometry. Native Laema dashboard/chat-history tools were unavailable. Source/image findings are separate from engine or human acceptance.

## Diagnosis

| Area | Finding | Production implication |
| --- | --- | --- |
| Motion design | Most live attacks change arms/blade more than hips and body mass. Wide planted stances repeat. X4 has three actual drawings held across six keys. Fire Cast raises the blade early and remains overhead. | Author load, acceleration, braking, recovery and distinct silhouettes before adding detail. More generated frames alone will not solve the motion. |
| Character consistency | Pale ponytail, blue vest, white shirt and red sash remain broadly consistent. Hilt, shield size/perspective, gloves, face/hair, boot material and sword treatment drift. Idle/Cast have a narrower stance and more ornate glowing steel. | Lock one reference pack per experiment and inspect equipment, proportions, materials and occlusion frame by frame. |
| Timing | Native normalized time is remapped through phase timing and Heat. X1's late pose exposure is much longer than its release drawings. | Uniform-FPS GIFs and editor speed 1 are insufficient evidence. Review actual gameplay exposure at fixed Heat 0 and 100. |
| Transitions | Independently authored sheets switch without blending. Cast ends overhead; Idle starts low-ready. | Review entry/exit poses and actual action boundaries, including queued X2/Cast, rather than judging isolated loops. |
| Integration | Current implementation already separates Sprite2D region tracks, native registration, contact curves and once-only Cast launch. Earlier geometry repairs are recorded. | No new engine bug was established. New blade paths still require contact-curve review; old misalignment descriptions must not be reported as a fresh defect. |

Static examples: [live-frame contact sheet](evidence/live-contact.png), [equipment details](evidence/equipment-details.png), [character-reference context](evidence/reference-context.png).

## Live versus reviewed artwork

The live resources use `overnight_v04` for X1/X4/X5 and `angle_proofs_v03` for X2/X3. A later [reviewed handoff](../docs/art/handoffs/2026-10-21-fire-x1-x5-pose-match/HANDOFF.md) selects a different 4/3/4/5/4-pose set and explicitly excludes substituting the older sheets. Its recorded prototype integration approval is not a claim that these are currently bound or runtime-accepted.

This research does not install either set. Keep current live state, later reviewed artwork and new original-motion proposals distinct.

## Actual timing at the inspected revision

| Move | Distinct live drawings | Heat 0 action | Heat 0 contact / launch | Fixed Heat 100 action |
| --- | ---: | ---: | --- | ---: |
| Fire X1 | 8 | 0.720s | 0.126–0.5075s | 0.480s |
| Fire X2 | 6 | 0.750s | 0.1851–0.5906s | 0.500s |
| Fire X3 | 5 | 0.645s | 0.117–0.4575s | 0.430s |
| Fire X4 | 3 over 6 keys | 0.690s | 0.1697–0.530s | 0.460s |
| Fire X5 | 7 | 1.400s | 0.180–0.850s | 0.9333s |
| Fire Cast | 10 | 1.200s | Launch 0.288s | 0.800s |

Heat multiplier is `1 + 0.5 * Heat/100`. Actual Heat can change during an action; preview comparisons hold it fixed. Fire X5's older 1.55-second total is historical, not the inspected current value.

X1 has normalized `active_start=0.36`, pacing-only `timing_split=0.60`, `active_end=0.8333333`, windup 0.21s and recovery 0.51s. Thus contact begins before the nominal windup ends, and nominal recovery includes active frames. The split is not a hit marker. Approximate Heat 0 frame holds are **65 / 65 / 27.5 / 28 / 36.6 / 130.5 / 130.5 / 236.8ms**. Divide by 1.5 for fixed Heat 100. This is a timing characteristic for visual review, not an automatically diagnosed defect.

The [baseline video](evidence/live-baseline.mp4) reconstructs unchanged current atlas cells with source-derived timing. It is not a Godot gameplay recording. [live-contract.json](evidence/live-contract.json) preserves current texture paths, hashes and frame exposures.

## X1 integration contract to preserve

- Gameplay viewport 1280×720, default camera zoom 1; standing body convention approximately 180 source/world pixels.
- Root scale 2 × Sprite scale 0.5 gives net 1×. Fire cells are 448×448, Sprite offset `(0,-124)`, foot registration `(224,400)`. Actor origin maps to `(224,348)`: feet are 52 world pixels below it. Query conversion is actor-local, not foot-local.
- Current X1 has a 3-world-pixel root lunge over normalized phase 0.15–0.55. The studies keep feet fixed and do not simulate this body motion.
- Current input buffer opens around 0.098s and ordinary queue around 0.168s at Heat 0. A queued X2/Cast starts at completion, not at buffer opening. Buffer is first-request-wins.
- Fire dodge can interrupt X1 strictly before active_start. Active/recovery dodge is rejected. Preserve existing incoming-reaction and cancellation paths.
- Current contact geometry is held/sampled through the full active window, with once-per-target allowance. New proposals do not match the old curves merely by sharing its timing.
- Cast launch is once-only and distinct from projectile contact. Replacing Cast artwork also requires checking the authored CastOrigin against the hand. Other schools retain legacy shared casting art and normalized launch 0.36, versus Fire 0.24.

Sources: [attack authoring](../docs/ATTACK_STYLES.md), [technical record](../docs/TECH_ARCHITECTURE.md), [native X1](../config/attack_animations/fire_x1.tres), [X1 style](../config/attack_styles/fire_x1.tres), [player scene](../scenes/player/player.tscn), [Might](../scripts/combat/might_component.gd), [geometry](../scripts/combat/attack_geometry.gd), [Heat](../scripts/combat/heat_controller.gd).

## Original studies and approval state

Fire X1 was chosen as a representative chain opener. A/B/C use original authored joint targets, not pre-existing motion. All share the current 0.720/0.480-second envelope and a provisional guard endpoint.

| Study | Anticipation | Release / emphasis | Follow-through | Recovery |
| --- | --- | --- | --- | --- |
| A — Diagonal cut | Rear-foot load and shoulder chamber, 0–0.126s | Descending release; emphasis around 0.158–0.210s | Low braking arc to about 0.340s | Return to common guard by 0.720s |
| B — Level backhand | Closed shoulder coil and hip counter-shift, 0–0.126s | Level sweep; emphasis around 0.151–0.210s | Compact elbow brake to about 0.340s | Return to common guard by 0.720s |
| C — Rising cut | Compression and low chamber, 0–0.126s | Upward release; emphasis around 0.162–0.210s | High catch to about 0.440s | Lower into common guard by 0.720s |

These artistic emphasis times are not contact events. Divide by 1.5 at fixed Heat 100. Visual recovery overlaps the existing hit-capable interval.

Entry/exit guard continuity is shown; real Idle/Walk, X2, Cast, Dodge, hit reaction and retry transitions are not integrated or tested. Preserve their existing rules and review those boundaries after selection. A shared guard does not prove all handoffs work.

Laema Open is the provisional identity reference; current Fire Idle supplies provisional side-view sword/shield context. The preserved [art direction](../docs/art/ART_DIRECTION.md) retains multiple character/weapon alternatives. This experiment makes no final outfit or weapon choice. The latest user request for three motion proposals controls this round.

**Open: the user has not selected A/B/C. Stop before polished artwork until that selection or requested motion revision is supplied.**

## Production-method evaluation remaining

Run a controlled comparison of actual reference-guided AI and 2D rig/frame-by-frame hybrid outputs after motion approval. Keep character reference, pose/phase contract, camera, scale, anchor, timing and permitted gameplay unchanged. Try 3D assistance if blade depth, volume consistency or reusable setup justifies its cost; otherwise record it as not tested.

Preserve raw and corrected results, failed attempts and provenance. Compare playable Godot previews, synchronized videos, native silhouettes, enlarged stepping, foot/anchor behavior, full-window query alignment and real action transitions. Evaluate motion quality, responsiveness, silhouette clarity, identity, alignment, transitions, correction effort and reuse.

Use [effort-log.csv](effort-log.csv) for actual setup, authoring, wait, correction, integration and review labor. Separate one-time setup from per-action work. Existing X2 revisions through v07 and X5 posture/shield repairs demonstrate repeated corrections; no retrospective hours were available or invented. No production-rig output has been tested yet; the procedural blocking player is not evidence that a polished rig pipeline won.

## Verified scope

- Browser: three proposals, embedded source-data match, 32 keys, controls and rigid blade interpolation checked; exported video 12s/60fps/720 frames. [Evidence](evidence/browser-verification.json).
- Standalone Godot: 4.6.3 headless import, 219 pose samples, 120 execution frames. [Evidence](preview/verification.json). The main game declares 4.7. No graphical Godot or integrated combat validation is claimed.
- No motion approval, final-art approval, method winner, bulk replacement or production-readiness claim.
- Publication adds only this isolated research folder. Product sources, gameplay resources, canonical documents and department routing are unchanged.

