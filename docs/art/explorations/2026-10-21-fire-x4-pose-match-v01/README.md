# Fire X4 — original-pose reskin study v01

Status: **review candidate, not exact-pose approved and not integrated**. Created for the user's request to redo Laema's attacks using the original poses and sword paths. X4 has five original key poses; no generic sixth ready/recovery pose is substituted.

## Sources and meaning

- Motion authority: revision `9f9d9bba`, `config/attack_animations/fire_x4.tres`, referencing `assets/prototype/player/animation/earth_x4.png`. The historical Fire/Earth visual swap explains the texture name.
- Avatar identity/material only: current Fire `shared_idle.png` via a mechanically enlarged appearance crop. White ponytail, cream rolled sleeves, blue vest, red sash, brown trousers/boots/gloves, plain steel sword and navy round shield.
- The original 128px sprites cut off lower legs and some tips. Completing those hidden portions is inference, not recovered pose evidence.

The five phase directions represented here are: high arm with slightly downward-to-right overhead blade; bent overhead arm with horizontal right blade; crossed-chest hand with near-vertical blade; back/side turn with shallow up-right extension; steeper up-right extension with rear-leg lift. The source's thin blade-path marks are retained near pose4. They add no gameplay effect.

## Review files

- [Original versus Laema GIF](original-vs-laema-x4.gif): synchronized five-pose inspection.
- [All five original and new poses](original-vs-laema-x4-poses.png).
- [Laema-only review GIF](fire-x4-review.gif).
- [Transparent native preview](fire-x4-preview.gif).
- [Transparent five-cell atlas](fire-x4-5x448.png): 2240×448, five 448px cells.
- `frame-01.png` through `frame-05.png`: individual transparent frames.
- `generation-01.png`, `generation-02-shield-correction.png`, and `generation-03-isolated-pose3.png`: all raw generated sources retained. The third generation replaces only pose3. `before-isolated-pose3-correction/` preserves the earlier exported atlas, frames, previews and metadata.
- `original-x4-atlas.png`, original frame PNGs and source-pose grids: preserved motion evidence.
- `prompts.json`, `metadata.json`, `prepare.py`, `export.py`: exact prompts, derivation and static checks.

Native registration uses one scale for all five drawings, a target standing body around180px, and foot anchor (224,400). Per-pose translation aligns the foot-root; no pose is independently rescaled, stretched or repainted. Pose4's sword tip/trail overhangs into the neighbouring gutter in the generated sheet. The export includes that complete overhang and excludes its detached fragment from pose5.

## Fidelity limits — important

This is closer to the original five-phase choreography than the rejected three-pose X4, but it is **not yet a precise skeleton/path match**:

- Pose3's wrong screen-right shield placement was corrected in a final isolated edit: the shield now sits on the original screen-left side behind the crossed sword forearm. Exact silhouette and occlusion still differ; it is not a pixel-locked reconstruction.
- Pose2 has a wider inferred stance than the source's compact visible knee arrangement.
- Arm reach, torso silhouette and knee/hip bends are not landmark-locked to the low-resolution mannequin.
- The original source's shield back/face rendering and generated equipment perspective differ.
- Generated face, ponytail, guard and cloth continuity are not rig-locked.

The sword-direction sequence and turn-away action are restored; that does not establish exact trajectories between the sparse keyframes. Review those differences before deciding on repair or acceptance. No additional in-betweens or synthesized movement paths are claimed.

## QA and boundaries

Five saved native RGBA frames and atlas dimensions checked. Three GIFs were decoded frame-by-frame and checked as five frames, infinite loop. Native alpha96 bounds remain clear of canvas edges. The comparison PNG was visually inspected on grey, including the corrected neighbour-gutter extraction. Continuous GIF playback, editor import, Godot runtime, builds or gameplay tests were not performed.

After the isolated pose3 correction, the exported PNGs for poses1,2,4,5 were verified byte-identical to their pre-correction versions. Pose3 alone was replaced as a complete generated cell, using uniform whole-canvas resampling to512px before the same registration/export path.

Review durations 480/300/270/240/450ms are slowed display timing plus endpoint pause, not engine timing or current balance authority. The original native normalized keys are preserved in metadata.

Only this X4 exploration folder was changed. No runtime assets, configuration, scenes, gameplay, other moves or canonical documents were edited; no staging, commit, push or publication. This folder is excluded from Godot import.
