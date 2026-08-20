# Decisions

## 2026-08-20 — Checkpoint synchronization workflow

- **Decision:** “Save checkpoint” and close equivalents sweep all available, unarchived Laema threads, including idle threads, while excluding archived and unrelated threads.
- **Decision:** A save writes a dated Markdown checkpoint containing thread IDs, updates, and the current labeled design state, then commits and pushes it to `origin`.
- **Decision:** A save is not reported as complete unless the push succeeds. Synchronization failures leave the local state intact and are reported precisely.
- **Decision:** “Load checkpoint” and close equivalents pull the latest checkpoint fast-forward-only, reconcile the local repository, and send checkpoint-derived resume context to each listed unarchived thread available on the current host.
- **Constraint:** Git does not transfer thread history. Loading updates available threads with context; it does not rewrite or resurrect archived, missing, or inaccessible threads, which are reported as skipped.
