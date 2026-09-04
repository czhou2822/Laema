# Changelist — 2026-09-04 portable thread bindings

## Intent

Make the user-confirmed cross-machine task map durable and update the repository contract so checkpoint recovery uses stable task keys, explicit aliases, machine-specific bindings, and embedded transcripts rather than source-host thread IDs alone.

## Files changed

- `AGENTS.md`
- `docs/README.md`
- `docs/checkpoints/2026-09-04-cross-machine-thread-bindings.md`
- `docs/changelists/2026-09-04-cross-machine-thread-bindings.md`

## Mapping captured

- Ten currently listed, unarchived Laema task bindings are recorded.
- The user's confirmed aliases include `PM` → `Production Manager`, `NarrativeRoom` → `Narrative Room`, `Audio` → `Laema Audio`, and capitalization-only variants.
- Source IDs and source transcripts remain linked to `docs/checkpoints/2026-09-03-cross-thread-recovery.md`.
- Local IDs and latest message-bearing turn metadata are recorded for bidirectional recovery.

## Recovery behavior

- `task_key` plus project identity is the portable identity.
- Thread ID, host, checkout, status, and cursor are per-machine bindings.
- Missing or ambiguous matches remain unresolved and fall back to the embedded transcript; same-name matching alone is not treated as proof.
- Future saves preserve older bindings and add the new machine's binding.

## Publication rule added

- `save checkpoint` now stages, commits, and pushes as one operation.
- A safe `load checkpoint` publishes any recovery-file changes it creates or updates; a read-only no-change load reports a no-op.
- Dirty-tree safety stops remain non-mutating.

## Evidence and Git boundary

- This record does not add runtime, build, compiler, editor, or automated-test evidence.
- Existing project changes are preserved. This contract edit is staged but not yet committed or pushed; it is not itself a checkpoint command.
