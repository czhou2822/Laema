# Project records

This directory is intended to hold the durable project state that should travel with the repository.

- `GAME_DESIGN.md` — accepted gameplay and player-experience decisions
- `TECH_ARCHITECTURE.md` — accepted technical representation and ownership decisions
- `DECISIONS.md` — decision history and rationale
- `IMPLEMENTATION_STATUS.md` — current implementation state and verification notes
- `checkpoints/` — dated cross-thread working snapshots; these preserve design state without automatically promoting proposals into canonical documents

## Checkpoint convention

When the user says “save checkpoint,” “checkpoint this,” or a close equivalent:

1. Sweep all available, unarchived Laema threads, including idle threads; ignore archived and unrelated threads.
2. Reconcile every update since the previous checkpoint and write a dated Markdown snapshot with the thread IDs and current design state.
3. Commit the checkpoint on the current branch and push it to `origin`.
4. Report success only after the push succeeds. If credentials, conflicts, pull/push, or another synchronization step fails, preserve the local state and report the exact incomplete step.

When the user says “load checkpoint,” “resume from checkpoint,” or a close equivalent:

1. Pull the latest checkpoint from `origin` using a fast-forward-only update by default.
2. Reconcile the local repository with the latest checkpoint without silently promoting proposals into canonical documents.
3. Send checkpoint-derived resume context to each listed unarchived thread that is available on the current host.
4. Treat archived, missing, or inaccessible threads as skipped and report them.

Git synchronizes the repository, not thread history. Loading a checkpoint updates available threads with context; it does not rewrite or resurrect thread histories.

Keep checkpoint records separate from the approved GDD, technical architecture, and implementation verification records.
