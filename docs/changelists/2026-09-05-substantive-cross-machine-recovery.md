# Changelist — 2026-09-05 substantive cross-machine recovery

## Intent

Upgrade Laema checkpointing to the required schema-2 substantive recovery package after the user reported that another computer could not retrieve the earlier summary-only checkpoint reliably.

## Included scope

- `docs/checkpoints/2026-09-05-substantive-cross-machine-recovery.thread-sync.json` — schema-2 packages for all ten unarchived Laema tasks, including portable identity, concise deltas, full recovery context, latest completed-round record, and historical/current bindings.
- `docs/checkpoints/2026-09-05-substantive-cross-machine-recovery.md` — human-readable recovery contract, task sweep, and validation boundary.
- This changelist.

## Preservation and boundary

- `docs/checkpoints/2026-09-04-cross-machine-retrieval.thread-sync.json` is explicitly named as the preceding manifest and remains unchanged.
- Only Combat and Production Manager have newer completed rounds. The other eight task packages are preserved in full.
- No thread was messaged, no gameplay decision was promoted, and no runtime validation was run.
- The checkpoint publisher stages all project files, commits, pushes, and verifies `HEAD` against `origin/main`; successful publication is reported only after that verification.
