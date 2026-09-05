# Project records

This directory holds durable project state that travels with the repository.

- GAME_DESIGN.md — accepted gameplay and player-experience decisions
- TECH_ARCHITECTURE.md — accepted technical representation and ownership decisions
- DECISIONS.md — decision history and rationale
- IMPLEMENTATION_STATUS.md — current implementation state and verification notes
- checkpoints/ — dated project snapshots and per-task recovery notes
- changelists/ — reviewable file-scope records for coordinated changes
- presentation/ — tournament-guideline references and internal pitch decks

## Checkpoint and thread recovery

### Save checkpoint

1. Inspect Git status and the relevant diff.
2. Query every listed, unarchived Laema task, including idle and not-loaded tasks.
3. Create docs/checkpoints/<checkpoint-id>/ with manifest.json and one compact Markdown note per task. Each note records:
   - Since last checkpoint — material changes only.
   - Carried context — decisions, proposals, open questions, conflicts, and validation limits that still matter.
   - Resume point — the exact next question, task, or dormant condition.
   - Sources — current canonical records and relevant task history.
4. The manifest records each task key, canonical title, confirmed aliases, current binding, latest completed turn, changed flag, compact summary, and relative task-note path. It points to the preceding manifest.
5. Write a matching changelist, then run checkpoint.ps1 Save. Save stages the full project tree, commits, pushes, and verifies origin/main.

### Load checkpoint

1. Inspect local Git state. If local work exists, stop for the user to resolve it.
2. Fast-forward the checkout and read the newest manifest and changelist.
3. Resolve every saved task by project identity, stable task key, and confirmed aliases.
4. Send each resolved task one short restore request pointing to its own Markdown note. The task reads that note and its current canonical sources, carries compatible context forward, distinguishes changes, and reports any material conflict and resume point.
5. Read the response before reporting completion. A task with a missing binding, missing response, or unresolved conflict remains explicitly incomplete.

If the thread service is unavailable, report that Git was synchronized but task conversations were not restored.

### Portable task identity

The canonical task key is portable across machines. Thread IDs, hosts, checkout paths, statuses, and cursors are bindings for one machine. Confirmed aliases may resolve title differences such as PM and Production Manager, NarrativeRoom and Narrative Room, or Audio and Laema Audio. Never substitute a same-titled task without the key and alias checks.

New saves use schema 3. Older schema 1 and 2 checkpoints remain readable as historical summaries; their missing task-note context must be reported rather than invented.

tools/checkpoint.ps1 validates the manifest and task-note structure, checks Git safety, publishes saves, and emits the load plan. The agent reads tasks, writes compact notes, and checks restoration responses.
