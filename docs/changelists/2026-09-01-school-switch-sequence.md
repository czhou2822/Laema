# Changelist — 2026-09-01 school-switch and sequence checkpoint

## Intent

Capture the latest completed message round from every currently listed, unarchived Laema task and preserve the complete current candidate scope after the user's narrow Godot verification of always-available school switching.

## Recovery records added

- `docs/checkpoints/2026-09-01-school-switch-sequence.md`
- `docs/changelists/2026-09-01-school-switch-sequence.md`

The checkpoint contains ten task IDs, exact titles, observed statuses, checkout paths, completed-turn identifiers/timestamps, and the latest visible user/assistant round. U's newest completed turns and Dummy's newest completed turn exposed no message items; those limitations are recorded rather than filled by inference.

## Complete candidate scope captured

The pre-record working tree contained 23 modified/deleted tracked paths and 6 untracked project paths. This save stages all of them with `git add -A`, including source, scenes, configuration, documentation, generated UID files, and deletions. No path is filtered merely because it is a source or candidate file.

## Evidence boundary

- The user reported the complete Stage 1–6 flow run and confirmation in Godot on 2026-09-01; this is broad evidence without a scenario matrix, tested-tree identity, or engine-version record.
- The user separately verified the current always-available school-switch implementation in Godot; no broader scenario coverage is inferred.
- No agent-run Godot, editor, build, compiler, or automated-test command was run.
- Fresh Friday technical revision and Ultron `mode=tech-preflight` remain required for the global school-switch contract; later postflight remains a separate gate.

## Git boundary

`git diff --check` passed before the record was written. This save stages but does not commit or push; commit and push remain separate explicit actions.
