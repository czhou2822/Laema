# Changelist — 2026-09-04 cross-machine retrieval checkpoint

## Intent

Publish a complete portable recovery manifest after the user reported that the other computer could not retrieve Laema task context.

## Included scope

- `docs/checkpoints/2026-09-04-cross-machine-retrieval.thread-sync.json` — machine-readable task identities, aliases, latest completed-round IDs, statuses, and concise changed-task summaries.
- `docs/checkpoints/2026-09-04-cross-machine-retrieval.md` — human-readable recovery steps and evidence boundary.
- This changelist.

## Preservation and boundary

- The pre-existing binding record preserves both source and local machine bindings; this checkpoint does not delete or overwrite them.
- Only `combat` and `production_manager` changed since the preceding manifest. No task messages are sent by this save.
- The checkpoint tool stages all project changes, commits, pushes, and verifies that `HEAD` equals `origin/main`; publication is incomplete if the push fails.
