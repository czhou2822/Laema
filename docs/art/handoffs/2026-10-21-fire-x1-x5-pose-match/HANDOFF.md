# Reviewed Fire X1–X5 — integration handover to U

## User authority and status

On October21 the user completed a move-by-move review and said: “okay lets hand over to U to implement”. This authorizes integration of the reviewed Fire X1–X5 key-pose artwork below. It does not establish Godot validation, final Laema art, final polish or new gameplay rules.

The selected asset READMEs/metadata retain earlier candidate labels. This dated handover records the later user review/implementation authorization; it supersedes those earlier approval-state labels only for this exact selected prototype artwork. Other fidelity/runtime limits still stand.

| Move | Selected version | Frames | Atlas |
|---|---|---:|---|
| Fire X1 | pose-match-v02 | 4 | ../../explorations/2026-10-21-fire-x1-pose-match-v02/fire-x1-4x448.png |
| Fire X2 | pose-match-v07 | 3 | ../../explorations/2026-10-21-fire-x2-pose-match-v07/fire-x2-3x448.png |
| Fire X3 | pose-match-v01 | 4 | ../../explorations/2026-10-21-fire-x3-pose-match-v01/fire-x3-pose-match-4x448.png |
| Fire X4 | pose-match-v01 | 5 | ../../explorations/2026-10-21-fire-x4-pose-match-v01/fire-x4-5x448.png |
| Fire X5 | pose-match-v02 | 4 | ../../explorations/2026-10-21-fire-x5-pose-match-v02/fire-x5-pose-match-4x448.png |

Five moves,20 keyframes total. [manifest.json](manifest.json) pins root-relative paths, atlas hashes, dimensions and individual frame hashes. Do not substitute an older X2, the original overly leaning X5, the overnight-v04 attacks, or an earlier angle proof.

## Review chronology to preserve

- X1v02: final right-to-left follow-through corrected so blade passes behind the left thigh. User said it looked better and continued the chain review.
- X2v07: shield placement retained from the user's accepted v06 shield; blade middle now behind the body, tip emerging at the left/rear hip. User viewed the complete revised sequence and said it looked good before moving to X3.
- X3v01: four-pose original-matching pass; user said it looked good before moving to X4.
- X4v01: latest five-pose export includes the isolated pose3 shield-side correction. User said it looked good before moving to X5.
- X5v02: last two poses have shallower forward lean; ending shows right sword hand and left shield hand. Frames1/2 remain byte-identical to v01. User then authorized this handover.

The intent is the original pre-avatar Fire attack choreography, historical revision9f9d9bba whose resources referenced earth_x1..earth_x5 after the older Fire/Earth presentation swap. Those historical resources are motion evidence, not files to restore over current implementation. Current school IDs/rules remain Fire.

## Asset contract

All five selected atlases are RGBA horizontal strips of448×448 cells, foot anchor(224,400), approximately180px body convention. Pose compression, ponytail and raised weapon alter visible overall bounds. Use the existing Fire presentation registration; don't independently enlarge moves or silently change sprite/collision transforms.

Copy only the selected runtime PNG artwork through the normal implementation workflow, preserving source hashes. Exploration folders have .gdignore and must stay excluded; don't remove that exclusion or import raw generations, GIFs, comparison boards or reference mannequins as runtime textures. Individual PNG frames are supplied for authoring/verification.

The selected pose counts4/3/4/5/4 differ from the existing expanded presentation keys. Integration needs an explicit per-move texture-region/key mapping, not a blind path swap. Review GIF delays include slow-inspection holds and are NOT gameplay timing. No new in-betweens or smoothed combo transitions are authorized by this handover.

## Implementation boundaries and open synchronization

- Preserve current Fire attack identity, five-position chain, school switching, input, damage, Impact, Heat, lunge, gameplay windup/active/recovery settings, markers and current combat contact/parry behavior unless the user separately approves a change.
- Preserve Idle/Walk/Hurt/Cast, Shield Catch/defence, other schools, Enemy, arena/HUD/audio/VFX and unrelated dirty work.
- Do not copy entire old historical Animation resources or revert current code/config to get the old frame counts.
- Artwork is not hitbox proof. Any mismatch between selected sword paths and existing query geometry must be reported; do not silently retune gameplay geometry to fit pictures.
- U should establish the required presentation binding/frame mapping and follow its active specialist workflow. This handover does not override a review-only Skill or grant a different Skill's authority. Existing implementation/file-plan gates remain in force; the already-reviewed artwork need not be re-approved merely because old notes call it a candidate.
- Current source/technical/design/asset records describing earlier presentation will need exact-scope reconciliation by their proper owners. Carry that synchronization obligation and obtain any document-scope approval required by the workflow; Art has not edited canonical GDD/TDR here.
- Repository has substantial concurrent dirty source/config/docs/assets/housekeeping work. Read fresh status/diff and preserve it. No commit, push, checkpoint or live publication requested.

## Evidence and remaining art limits

Art checked selected PNG decoding, RGBA dimensions, cell counts/hashes and rendered atlas-cell agreement with the saved individual frames. Prior per-move notes carry static margin/GIF decode and visual-inspection evidence. Those are not Godot/import/build/test/runtime evidence. No additional runtime/test authority is granted here; use any existing explicit permissions only within their scope.

Original references crop lower legs and some tips; generated completions are inferred. Fine joint tracing, hilt/shield/hand/face/hair/garment continuity, exact hidden blade geometry and material consistency remain provisional despite the user's prototype selection. Final Laema art, polish, in-betweens and whole-chain flow remain open. Implementation and user validation are pending at this handover.
