# Project records

This directory holds durable project state that travels with the repository.

- GAME_DESIGN.md — accepted gameplay and player-experience decisions
- TECH_ARCHITECTURE.md — accepted technical representation and ownership decisions
- DECISIONS.md — decision history and rationale
- IMPLEMENTATION_STATUS.md — current implementation state and verification notes
- GYM.md — combat Gym, shared character settings, retry, formula readout and launch controls
- ATTACK_STYLES.md — four school melee presets and per-move timing/movement tuning
- [feedback/2026-10-19-judge-panel.md](feedback/2026-10-19-judge-panel.md) — formal panel feedback received October 19, with the user's separate caveat
- checkpoints/ — dated project snapshots and per-task recovery notes
- departments/ — eight persistent development-context records and confirmed task assignments
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
4. The schema 4 manifest records each independent task key, canonical title, confirmed aliases, current and historical bindings, latest completed turn, portable `progress_uid`, changed flag, compact summary, task-note path, and confirmed department assignment. `progress_uid` is a deterministic digest of the latest completed user/assistant round. It points to the preceding manifest.
5. Reconcile material developments into the eight persistent department records. Ask about unassigned tasks; persist explicit choices in departments/task-departments.json. A department is not a task identity, and older records must not be blindly overwritten by one response.
   - Production Manager is the user-confirmed standalone coordination position. Record its position_key separately and keep its own task note; it does not belong to Other or a specialist department.
6. Write a matching changelist, then run checkpoint.ps1 Save. The adapter freezes all eight department copies and their content UIDs, writes cory-context.json and latest.json, then Save stages the full project tree, commits, pushes, and verifies origin/main. Publish development summaries only; exclude personal material, transcripts, reasoning, credentials and private tool output from recovery records.

### Load checkpoint

1. Inspect local Git state. If local work exists, stop for the user to resolve it.
2. Fast-forward the checkout and read the latest pointer, manifest, changelist and saved department records. Omitting ManifestPath resolves latest.json; committed-manifest history is the legacy fallback.
3. Resolve every saved task by project identity, stable task key, and confirmed aliases.
4. Read current unarchived task context and compare it with the carried Cory snapshot. Matching task UIDs permit a dormant skip only when the department UID is also verified unchanged. Otherwise send one short restoration request pointing to that independent task's note and department record. The task reads both and its current canonical sources, carries compatible context forward, distinguishes changes, and reports material conflicts and its resume point. Never copy a saved UID onto unread or different local history.
5. Read the response before reporting completion. A task with a missing binding, missing response, or unresolved conflict remains explicitly incomplete.

If the thread service is unavailable, report that Git was synchronized but task conversations were not restored.

### Portable task identity

The canonical task key is portable across machines. Thread IDs, hosts, checkout paths, statuses, and cursors are bindings for one machine. Confirmed aliases may resolve title differences such as PM and Production Manager, NarrativeRoom and Narrative Room, or Audio and Laema Audio. Never substitute a same-titled task without the key and alias checks.

New saves use schema 4. Historical schemas 1–3 remain readable; missing context must be reported rather than invented. Missing saved tasks remain reference context and are not automatically recreated.

tools/checkpoint.ps1 validates the manifest and task-note structure, uses tools/cory-checkpoint.mjs for department snapshots and Cory context, publishes complete saves, and emits the load plan. The agent reads tasks, reconciles department records, writes compact notes, and checks restoration responses. Cory comparison buttons are read-only; an actual load checkpoint command authorizes restoration dispatch.
