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
3. For each task, assign or preserve a stable canonical `task_key`, canonical title, and explicitly confirmed aliases. Record its machine-specific thread ID, host, checkout, status, recovery cursor or timestamp when available, and at least the latest completed message round. For tasks changed since the prior checkpoint, store a concise material summary rather than a word-for-word transcript.
4. Write a new dated checkpoint in `checkpoints/` and a separate reviewable file-scope record in `changelists/`. Keep prior records unchanged as history.
5. Stage every current tracked and untracked project file with `git add -A`, then commit and push the complete checkpoint in the same operation. A save is not published until the push succeeds; report partial state if either step fails.

### Load checkpoint

1. Inspect local Git state before synchronizing. Any staged, unstaged, or untracked work must be reported to the user for resolution; never auto-stash, reset, revert, discard, or overwrite it.
2. When safe, synchronize committed repository state using fast-forward-only behavior, then read the newest checkpoint and matching changelist.
3. Query every currently listed, unarchived task named in the checkpoint recovery manifest and resolve it by project identity, stable `task_key`, and user-confirmed aliases. Reopen/read at least its saved latest completed message round and verify the saved transcript or turn metadata. If a task has newer messages, read and report its newest round too. For each changed task with one verified local binding, send exactly one concise checkpoint-update message to that dedicated task; do not message unchanged or unresolved tasks. A thread ID is only a machine-specific binding; if it is unavailable, use a verified local binding or the transcript embedded in the checkpoint.
4. If thread access is unavailable, state clearly that only the Git files were loaded and the conversations were not restored.

If a safe load writes or updates a recovery record, binding, or other explicitly authorized project file, it must stage, commit, and push that result before reporting completion. A read-only load with no file changes reports a no-op; a dirty-tree safety stop performs no pull, commit, or push.

### Portable task identity

The checkpoint's canonical task key is the portable identity across machines. Each machine contributes a binding containing its local Codex thread ID, host, checkout, status, latest completed turn/timestamp, and the latest user/assistant transcript. Only aliases explicitly confirmed by the user may resolve title differences such as `PM` → `Production Manager`, `NarrativeRoom` → `Narrative Room`, `Audio` → `Laema Audio`, or capitalization-only variants. A missing or ambiguous binding is reported as unresolved; same-name matching alone is not sufficient.

`tools/checkpoint.ps1` automates manifest validation, Git safety checks, checkpoint publication, and load-plan generation. It does not read, summarize, or message Codex tasks; the agent supplies those context-sensitive operations. The app controls how dispatched thread updates appear in the sidebar.

Outside `save checkpoint` and `load checkpoint`, Git commit and push remain separate explicit actions. Within either checkpoint command, commit and push are one publication step.
