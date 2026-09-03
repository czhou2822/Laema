# Changelist — 2026-09-03 cross-thread recovery checkpoint

## Intent

Capture the latest completed message round from every currently listed, unarchived Laema task and preserve the complete current working-tree scope for the requested save checkpoint. This is a recovery record, not a product-code review or runtime verification.

## Recovery records added

- docs/checkpoints/2026-09-03-cross-thread-recovery.md
- docs/changelists/2026-09-03-cross-thread-recovery.md

The checkpoint manifest contains all ten task IDs, exact titles, observed statuses, checkout paths, completed-turn identifiers/timestamps, and the latest recoverable user/assistant message round. Four newest U turns exposed no user/assistant message items; that limitation is recorded explicitly, along with the latest message-bearing U context.

## Pre-existing project scope preserved

### Modified

- config/prototype_combat.json
- scripts/config/prototype_config_loader.gd
- scripts/enemy/combat_enemy.gd
- scripts/player/player.gd
- scripts/prototype/stage_director.gd
- scripts/ui/developer_overlay.gd

### Untracked enemy assets

- assets/prototype/enemy/medieval_fighter/Attack_1.png
- assets/prototype/enemy/medieval_fighter/Attack_1.png.import
- assets/prototype/enemy/medieval_fighter/Dead.png
- assets/prototype/enemy/medieval_fighter/Dead.png.import
- assets/prototype/enemy/medieval_fighter/Hurt.png
- assets/prototype/enemy/medieval_fighter/Hurt.png.import
- assets/prototype/enemy/medieval_fighter/Idle.png
- assets/prototype/enemy/medieval_fighter/Idle.png.import
- assets/prototype/enemy/medieval_fighter/Walk.png
- assets/prototype/enemy/medieval_fighter/Walk.png.import

### Untracked player assets

- assets/prototype/player/animation/hurt.png
- assets/prototype/player/animation/hurt.png.import

## Static evidence

- Pre-record status: 18 existing project paths were dirty.
- Pre-record tracked diff: six files, 137 insertions and 17 deletions.
- git diff --check passed before the checkpoint record was created.
- No Godot, editor, build, compiler, or automated-test command was run.

## Git boundary

This save stages all current tracked, deleted, and untracked project files with git add -A, including the two new recovery records. No commit or push is performed by save checkpoint alone.
