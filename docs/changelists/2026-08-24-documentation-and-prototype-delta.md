# Laema documentation and prototype delta changelist — 2026-08-24

## Review status

This is a review artifact accompanying the save checkpoint. It inventories the complete dirty working tree without authorizing those changes for publication. Only this changelist and its companion checkpoint are in scope for the checkpoint commit.

- **Baseline:** `e543a43` — `feat: add validated combat prototype slice`
- **Branch:** `main`
- **Remote:** `origin/main`
- **Runtime evidence:** user-reported validation applies to the committed first-draft slice only. The newer dirty delta has not been run in Godot by the agent or reported as validated by the user.
- **Review boundary:** review documentation/instruction synchronization separately from the prototype source delta.

## Modified tracked files

### Documentation and AI instructions — authorized, uncommitted

- `AGENTS.md` — current baseline, authority order, validation boundary, changelist map, and technical postflight rule.
- `README.md` — committed prototype baseline.
- `docs/DECISIONS.md` — first-draft validation and technical synchronization record.
- `docs/GAME_DESIGN.md` — explicit user-verified first-draft status.
- `docs/IMPLEMENTATION_STATUS.md` — committed baseline and user-validation record.
- `docs/README.md` — changelist record map and checkpoint workflow reference.
- `docs/TECH_ARCHITECTURE.md` — current committed architecture, implementation slices, validation boundary, and postflight handoff.
- `docs/changelists/2026-08-24-prototype-review.md` — historical/superseded status correction.

These files were updated in response to the prior explicit request to update Markdown and AI instructions. They are not staged by this checkpoint save.

### Prototype source, configuration, and scenes — dirty delta, awaiting validation

- `config/prototype_combat.json` — Air/Earth configuration and reordered/normalized current tuning data.
- `scenes/enemy/enemy.tscn` — animated Swordsman idle visual.
- `scenes/player/player.tscn` — attack-cast position/debug presentation adjustment.
- `scripts/combat/combat_controller.gd` — Air/Earth resolver wiring, Air speed buff, mixed-school helper, finisher-start signal.
- `scripts/combat/input_combo.gd` — prototype combo cap reduced from five X inputs to three.
- `scripts/config/prototype_config_loader.gd` — Air/Earth sections and validation.
- `scripts/enemy/enemy.gd` — animated idle flipbook and Earth-status presentation.
- `scripts/player/player.gd` — school-specific presentation candidates, attack-position frames, direction synchronization, and finisher VFX.
- `scripts/status/status_controller.gd` — Earth Slow state and effect-state output.

## Untracked files

### Prototype audio/import metadata

- `assets/prototype/audio/guard_warning.ogg.import`

### Prototype character candidates

- `assets/prototype/player/Fighter_Idle.png` and `.import`
- `assets/prototype/player/Fighter_Walk.png` and `.import`
- `assets/prototype/player/Fighter_Attack_1.png` and `.import`
- `assets/prototype/player/Fighter_Attack_2.png` and `.import`
- `assets/prototype/player/Fighter_Attack_3.png` and `.import`
- `assets/prototype/player/Saber_Idle.png` and `.import`
- `assets/prototype/player/Saber_Walk.png` and `.import`
- `assets/prototype/player/Saber_Attack_1.png` and `.import`
- `assets/prototype/player/Saber_Attack_2.png` and `.import`
- `assets/prototype/player/Saber_Attack_3.png` and `.import`
- `assets/prototype/player/Samurai_Idle.png` and `.import`
- `assets/prototype/player/Samurai_Walk.png` and `.import`
- `assets/prototype/player/Shinobi_Attack_2.png` and `.import`
- `assets/prototype/player/Shinobi_Attack_3.png` and `.import`

### Prototype resolver scripts

- `scripts/combat/air_resolver.gd` and `.uid`
- `scripts/combat/earth_resolver.gd` and `.uid`

## Validation evidence and risks

- Static whitespace/diff/config/resource checks reported by DUM-E passed for individual iterations.
- No agent-run Godot, build, compiler, or automated-test evidence exists for the dirty delta.
- The user-validated committed baseline does not validate the new Air/Earth packages, three-X combo cap, finisher VFX timing, school-switch visual refresh, or animated Enemy.
- The new source delta makes the current canonical GDD and technical record stale until the user validates and the exact accepted behavior is synchronized.
- The existing Enemy remains non-attacking, so incoming block/parry/guard-break and ordinary guard-warning behavior remain outside practical validation.
- Asset provenance and entitlement remain as documented in `assets/README.md`; no new final-art decision is implied by the prototype candidates.

## Proposed review boundary

1. Review the eight documentation/AI-instruction edits as a documentation synchronization scope.
2. Review the nine modified source/config/scene files and 33 untracked asset/resolver files as a separate prototype delta.
3. Keep both scopes unstaged during this checkpoint save.
4. After user validation, synchronize the exact accepted gameplay and architecture scope, then route the coupled source change to Ultron `mode=tech-postflight` before submission readiness.

## Save boundary

Only this changelist and `docs/checkpoints/2026-08-24-save.md` are authorized for the checkpoint commit. No prototype source, assets, configuration, scenes, canonical documents, or AI-instruction files are staged by this save.
