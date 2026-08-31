# Changelist — 2026-08-31 stage-one validation checkpoint

## Intent

Record the latest unarchived Laema task state after the user's broad Godot verification report and preserve the exact boundary between committed source, the current working-tree candidate, and the newly reopened Generating/Charging design question.

## Included in this checkpoint-record commit

- `docs/checkpoints/2026-08-31-stage-one-validation.md`
- `docs/changelists/2026-08-31-stage-one-validation.md`

## Preserved out-of-scope working-tree scope

The following existing modifications are intentionally not staged by this checkpoint save:

```text
AGENTS.md
README.md
docs/GAME_DESIGN.md
docs/IMPLEMENTATION_STATUS.md
docs/TECH_ARCHITECTURE.md
scenes/stages/final_arena.tscn
scenes/ui/prototype_hud.tscn
scripts/combat/combat_controller.gd
scripts/combat/might_component.gd
scripts/player/player.gd
scripts/prototype/five_hit_fire_evaluator.gd
scripts/prototype/prototype_arena.gd
scripts/ui/objective_widget.gd
scripts/ui/prototype_hud.gd
```

They contain the user-reported U-001/U-002 candidate corrections, tutorial/UI adjustments, and documentation synchronization. The Combat task has since reopened the vocabulary: Generating is the landed melee action, while the exact effect of Charging on a generated orb is still Open. No candidate terminology is promoted by this record.

## Evidence and gates

- User-reported Godot verification date: 2026-08-31; broad report only.
- No exact scenario matrix, tested-tree identity, or engine-version record.
- No agent-run Godot, build, compiler, or automated-test evidence.
- Fresh Ultron `mode=tech-postflight` remains required after exact terminology and document synchronization.

## Static checks

`git diff --check` passed before this record was staged. No build, runtime, editor, compiler, or automated-test command was run.
