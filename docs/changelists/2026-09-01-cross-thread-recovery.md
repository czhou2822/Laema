# Changelist — 2026-09-01 cross-thread recovery checkpoint

## Intent

Capture the latest completed message round from every currently listed, unarchived Laema task and preserve the complete current working-tree scope for the requested save, commit, and push. This is a recovery record, not a product-code review or runtime verification.

## Recovery records added

- `docs/checkpoints/2026-09-01-cross-thread-recovery.md`
- `docs/changelists/2026-09-01-cross-thread-recovery.md`

The checkpoint manifest contains all ten task IDs, exact titles, observed statuses, checkout paths, completed-turn identifiers/timestamps, and the latest recoverable user/assistant message round. Four newest U turns exposed no user/assistant message items; that limitation is recorded explicitly, along with the latest message-bearing U context.

## Pre-existing project scope preserved

### Modified

- `config/prototype_combat.json`
- `docs/GAME_DESIGN.md`
- `scenes/stages/final_arena.tscn`
- `scripts/combat/input_combo.gd`
- `scripts/combat/might_component.gd`
- `scripts/config/prototype_config_loader.gd`
- `scripts/ui/developer_overlay.gd`

### Untracked

- `scenes/enemy/combat_enemy.tscn`
- `scripts/enemy/combat_enemy.gd`
- `scripts/enemy/combat_enemy.gd.uid`

## Static evidence

- Pre-record status: ten existing project paths were dirty.
- Pre-record tracked diff: seven files, 61 insertions and 22 deletions.
- `git diff --check` passed before the checkpoint record was created.
- No Godot, editor, build, compiler, or automated-test command was run.

## Git boundary

This save stages all current tracked, deleted, and untracked project files with `git add -A`, including the two new recovery records. The user separately authorized commit and push, so this checkpoint is followed by a commit and push to `origin/main` after staged-scope verification.
