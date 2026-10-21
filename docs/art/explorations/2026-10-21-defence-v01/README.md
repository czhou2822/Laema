# Defence art and flipbook candidates — 2026-10-21

Superseded for the current request: this set used the older hammer reference. The user corrected the active stance to Fire sword-and-shield. Use [the corrected Fire studies](../2026-10-21-fire-defence-v02/README.md). This folder is preserved only as an obsolete study.

Status: five new visual motion proposals created at the user's request, using the current accepted-for-preservation Laema-with-hammer concept set. No candidate is user-selected yet. These files do not change gameplay, attack/defence timing, engine assets or canonical design decisions.

## Candidates

| Number | Candidate | Intended existing defence |
|---|---|---|
| 1 | Fire high-shaft parry | Brief intercept and outward deflection |
| 2 | Fire diagonal hammer-head deflection | Compact diagonal intercept |
| 3 | Water low braced guard | Hold, contact compression, regain guard |
| 4 | Water upright shaft guard | Hold close to body, contact compression |
| 5 | Water hammer-head cover | Protect with hammer mass, absorb, settle |

The gameplay reference is `docs/GAME_DESIGN.md`, Defence: Fire has a one-press parry window, Water blocks while held and guard remains intact. Air/Earth defence remains deferred. The gestures and small colored contact effects are presentation proposals, not new parry rewards, shield mechanics, retaliation or invincibility rules. Water seam colors are proposed blue; some generated source accents remain warm and need continuity cleanup.

## Deliverables

- `defence-five-motion-comparison.gif`: five previews side by side, 1440×370, synchronized review cadence.
- `defence-five-guard-poses.png`: static comparison of the main guard poses.
- Each numbered subfolder contains:
  - `source-six-pose-sheet.png`: original transparent generated 3×2 pose sheet, retained without repainting.
  - `frame-01.png` through `frame-06.png`: mechanically isolated and aligned 192×192 RGBA frames.
  - `flipbook-6x192.png`: six-cell horizontal PNG strip, 1152×192.
  - `preview.gif`: transparent 384×384 looping preview.
  - `metadata.json`: source identity, bounds, source pose order, scale, root alignment and review-only frame durations.
- `manifest.json`: complete candidate export specs.
- `prompts.json`: exact generation prompts and selected sources.

The export uses five distinct generated poses and repeats the opening pose for its sixth endpoint. The original generated sixth pose remains preserved in the source sheet. Connected-component isolation removes fragments from neighbouring cells; foot-root translation and a shared scale per sequence reduce layout jitter. No generated in-between frames or rigged animation are claimed. All five individual GIFs were reopened and verified as six frames, 384×384, infinite loop. PNG strips and static main poses were visually inspected. Live GIF playback, Godot integration and runtime acceptance were not performed or inferred.

## Source direction and provenance

- Character and hammer: `docs/art/references/2026-10-19-laema-hammer-accepted/01-laema-hammer-hero.png` and `02-laema-hammer-gameplay-scale.png`.
- Character ancestry: Laema Open in the October 18 reference set; preserve white ponytail, cream rolled-sleeve shirt, short blue vest, red waist sash, brown trousers/boots/gloves and alert expression.
- Heroes III original sprites remain the rendering-style authority; these generated large source sheets are proposals and do not demonstrate full native-style animation fidelity.
- Built-in image generation created the six-pose artworks. No API-key/CLI generation was used.
- Candidate 2's first generation returned a scene strip; a corrected transparent 3×2 generation was used in this deliverable. The scene-strip draft was not copied into this set.
- Export helper is retained at the Art task's visualization path as `build-defence-v01.py`.

## Review limits

The source drawings still vary in hand position, hammer proportions, pose weight, body facing and effect intensity. Some extremities approach source-cell edges; boundary contacts are recorded in metadata. Fire 1/2 have an outward push that can read as an attack and need particular motion review. The Water contact ripple is optional presentation, not an approved new shield. Native body scale is a review target, not an integration contract. The comparison GIF uses a common cadence; individual previews have longer Water holds. Neither replaces engine-authored timing.

Choose a pose/motion direction before spending effort on consistent in-betweens, character/weapon cleanup, native game-scale validation and engine integration. Source references and existing gameplay files remain unchanged. This review folder is excluded from Godot imports.

