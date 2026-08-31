# Project records

This directory is intended to hold the durable project state that should travel with the repository.

- `GAME_DESIGN.md` — accepted gameplay and player-experience decisions
- `TECH_ARCHITECTURE.md` — accepted technical representation and ownership decisions
- `DECISIONS.md` — decision history and rationale
- `IMPLEMENTATION_STATUS.md` — current implementation state and verification notes
- `checkpoints/` — dated project snapshots that preserve cross-thread working state
- `changelists/` — reviewable file-scope records for coordinated changes
- `presentation/` — tournament-guideline references and generated internal pitch decks

## Checkpoint and thread recovery contract

`save checkpoint` and `load checkpoint` are repository workflow commands with a cross-thread recovery requirement.

### Save checkpoint

1. Inspect the current Git status and diff.
2. Query every currently listed, unarchived Laema task, including idle or not-loaded tasks.
3. For each task, record its task ID, exact title, status, recovery cursor or timestamp when available, and at least the latest completed message round: the newest user message and corresponding assistant response. Capture the new latest round for any task updated since the previous checkpoint.
4. Write a new dated checkpoint in `checkpoints/` and a separate reviewable file-scope record in `changelists/`. Keep prior records unchanged as history.
5. Stage every current tracked and untracked project file with `git add -A`. Do not commit or push unless separately requested.

### Load checkpoint

1. Inspect local Git state before synchronizing. Any staged, unstaged, or untracked work must be reported to the user for resolution; never auto-stash, reset, revert, discard, or overwrite it.
2. When safe, synchronize committed repository state using fast-forward-only behavior, then read the newest checkpoint and matching changelist.
3. Query every currently listed, unarchived task named in the checkpoint recovery manifest and reopen/read at least its saved latest completed message round. If a task has newer messages, read and report its newest round too. This restores conversation context by reading it; it must not post duplicate messages or otherwise mutate the task.
4. If thread access is unavailable, state clearly that only the Git files were loaded and the conversations were not restored.

Git commit and push are separate explicit actions.
