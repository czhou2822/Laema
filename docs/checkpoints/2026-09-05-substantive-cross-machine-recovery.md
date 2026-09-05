# Laema substantive cross-machine recovery checkpoint — 2026-09-05

## Purpose

This is the first schema-2 recovery package. It replaces an insufficient summary-only recovery envelope with a portable package for every currently listed, unarchived Laema task. Each package preserves the task's role, authority and rationale, proposals, open questions, conflicts, evidence limits, source references, resume point, latest completed round, and both historical and current-machine bindings.

## Preceding history and scope

- **Preceding manifest:** `docs/checkpoints/2026-09-04-cross-machine-retrieval.thread-sync.json` (schema 1), retained unchanged as history.
- **Current repository before this save:** `011693c` (`feat: restore substantive task context`), with `main` aligned to `origin/main` and no local changes.
- **Task sweep:** all ten currently listed, unarchived Laema tasks were read. The in-progress Production Manager save request is excluded from its latest *completed* round.
- **Changed completed rounds:** `combat` and `production_manager` only. The eight remaining packages are carried forward in full, not replaced by blank summaries.

## Portable recovery rule

Resolve on any machine by `task_key`, canonical title, and explicitly confirmed aliases. Saved thread IDs, hosts, paths, statuses, and timestamps are bindings—not portable identity. If the local task is missing or ambiguous, report it and use the preserved package and transcript fallback; do not silently pick a same-titled task.

The historical cross-machine binding map remains at `docs/checkpoints/2026-09-04-cross-machine-thread-bindings.md`. The source transcript fallback remains at `docs/checkpoints/2026-09-03-cross-thread-recovery.md`.

## Latest material deltas

| Task | Delta | Resume point |
|---|---|---|
| Combat | Elemental Endurance was consolidated as a candidate; it is not canonical gameplay. | Resolve one Open interaction, beginning with multi-event spell damage counting, before any technical handoff. |
| Production Manager | The prior portable save was published but cross-machine retrieval remains unproven. | On the other machine: clean checkout, pull `main`, request `load checkpoint`, then inspect each substantive restoration response. |

## Evidence boundary

- This checkpoint records task context and Git recovery material. It does not establish gameplay, Godot, browser, audio, build, compiler, or automated-test validation.
- The only supplied Godot runtime evidence remains the broad Stage 1–6 user report; it has no scenario matrix, tested-tree identity, or engine-version record.
- Successful push makes this package available through Git; it does not prove the other computer has restored its conversations.
