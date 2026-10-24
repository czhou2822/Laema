# Pikeman v02 — corrected prototype animation handoff

User direction: check and fix motion consistency before handing the assets to U. This package supersedes sibling `pikeman-flipbook-assets-v01` for integration; v01 remains preserved history.

## Output contract

All ten `*_right_sheet.png` / `*_left_sheet.png` files in this directory are usable transparent RGBA atlases. Four columns, 768×512 cells, row-major. Frame counts: Idle7, Walk6, Attack10, Hurt6, Death5. Unused cells are transparent; do not play them. Individual frames are under matching clip subfolders. `manifest.json` is the complete file/frame manifest, and `motion-review.json` records validation and residual limits.

| Existing clip | New right-facing atlas | New left-facing atlas | Count |
| --- | --- | --- | ---: |
| Idle | idle_right_sheet.png | idle_left_sheet.png | 7 |
| Walk | walk_right_sheet.png | walk_left_sheet.png | 6 |
| Attack / front thrust | attack_right_sheet.png | attack_left_sheet.png | 10 |
| Hurt | hurt_right_sheet.png | hurt_left_sheet.png | 6 |
| Dead | death_right_sheet.png | death_left_sheet.png | 5 |

Right-facing images are the originals; left-facing images are exact cell-local mirrors in the same timeline order. Using right sheets plus a correctly anchored runtime mirror is also equivalent; do not apply both a left texture and another flip. No second character or effect is baked in.

Image-space feet/root registration is (384,448), i.e. the visual ground/contact reference is 192px below the cell center. Derive the scene placement from its real actor ground reference; do not blindly retain the old sprite offset or assume the actor origin is its feet. Approximately180px standing BODY at 1:1 (helmet crown to soles, excluding pike) is the accepted framing target. Keep body scale constant through crouch/thrust/death. Preserve the approved thin-ground framing and floor contact at screen y610 in the 1280×720 reference. Do not scale the physics root to enlarge the art.

## Corrections completed

- Attack0/9, Hurt0/5, and Death0 now use the exact Idle0 ready image. Idle6 also exactly equals Idle0, giving a closed idle loop and exact boundary poses.
- Removed up to12px sideways registration drift in walking while retaining leg animation and small vertical bob. All frames now have opaque contact envelope ending at y448 (exclusive).
- Removed40px of excess full-thrust forward registration, preserving the full-thrust position at timeline index5 (sixth frame). Corrected other attack offsets and returned the last recovery drawing to ready. The penultimate recovery pose is redistributed visually; gameplay duration and event timing were not edited.
- Regenerated the two recoil frames' short rear pike shafts with the built-in image tool, preserving the accepted dark brown-bronze helmet and uniform. Source and prompt are in `repair-record.json` / `hurt-shaft-repaired-source.png`.
- Expanded GIF viewport to640×384 so the full thrust spearhead is no longer cropped. The old GIF lost22 opaque pixels at its right edge; the exported v01 PNG had not been clipped.
- Atlases use lossless raw-cell packing, avoiding extra edge-color rounding from repeated compositing. All68 occupied left/right sheet cells decode identically to their individual PNGs; all34 mirrors are exact; all20 padding cells are transparent.

## Implementation scope for U

Replace Pikeman visual textures and adapt only the necessary sprite-frame geometry, foot registration, facing and visual sizing. Current live bindings inspected in `scripts/enemy/combat_enemy.gd` and `scenes/enemy/combat_enemy.tscn` use450×400 cells and4columns; the new cells are768×512. Preserve unrelated edits. Keep existing timing, active markers, animation-event ownership, ShapeCast geometry, collision bodies, attack reach, damage, movement speed, AI, hit reactions, SFX and progression unchanged. Do not copy any proposed art offsets into gameplay movement.

Do not replace Laema/player art from this package. Player flipbooks and magic VFX are separate Art tasks. The current player can remain a temporary smaller stand-in while its own assets are prepared; do not enlarge or redesign it implicitly as part of this handoff. Retain the approved town-edge background work. This package is Pikeman stand-in presentation, not final Laema art.

The existing attack frame index5 remains the most extended visual pose. Counts are unchanged; keep accepted event times/durations. Do not use the preview GIF fps, final holds or repetition as runtime timing instructions. Death must retain its existing terminal/hold behavior rather than following the repeating review GIF.

## Visual QA and remaining boundary

Inspected all timeline frames in registered sequences, including the idle/walk wrap and attack/recoil entry, middle and exit poses. Inspected repaired recoil frames and the thrust pair at full canvas scale, plus light/dark matte samples. Static/stepwise review establishes these corrections, not continuous browser or Godot playback. The previous browser playback attempt timed out; it is not represented as successful evidence.

`validate-exports.cjs` completed:34 timeline frames,68 exact atlas cells,34 exact mirrors,20 transparent padding cells,6 exact ready-boundary comparisons, all opaque bottoms at448, no nonzero canvas-border or preview-outside alpha, and correct decoded GIF page counts. No engine import, build, editor/playtest or runtime run was performed here.

Integration still needs the usual runtime checks: facing without double flips, floor contact, idle/walk looping against actual translation speed, attack full extension/recovery, interruption and stage reset, Hurt recovery and Death terminal hold. Do not claim those passed from this art handoff. If visual reach and accepted physical reach differ, report the mismatch; do not silently retune collision or gameplay to the illustration.

Minor generated cloth/crest/highlight variation remains. The5-frame death is intentionally coarse and ends side-lying, an interpretation rather than the native H3 final silhouette. These are known prototype-fidelity limits, not promises of production-quality animation or perfect hand-authored temporal consistency.

## Preview and provenance

`pikeman-all-clips-preview.gif` cycles through all five; individual `*-preview.gif` files are available. `motion-contact.png` shows every timeline frame and `alpha-mattes.png` shows samples against two mattes.

Generated reinterpretation based on the user-approved Pikeman repaint and original H3 pose references. Not an authentic recovered original sprite; no redistribution rights to original game art are granted by this package. Earlier references, prompts and source paths remain in v01 (`generation-spec.json`, `source-pose-guides.json`, `generated-source-report.json`, `repair-prompts.json`, `README.md`). Current correction script and exact frame changes are retained here. Original source files and game files were not edited by Art.
