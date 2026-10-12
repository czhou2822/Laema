# Laema project instructions

## Current state

Laema is an in-progress 2D side-scrolling orb-casting and tutorial-stage prototype. The working tree may contain substantial uncommitted draft code, scenes, assets, configuration, or documents. Inspect `git status` and the relevant diff before acting, preserve unrelated work, and never mistake a file's existence for user approval.

The current committed recovery baseline is `6b06dc2` (`checkpoint: save cross-thread recovery state`). It includes the Might/Magic combat composition, continuous combat feedback, the declarative Stage 1–6 sequence-objective candidate, reusable ObjectiveWidget, persistent tutorial root, reusable Stage Areas, transition into the Final Arena, and final-enemy completion into indefinite free practice.

The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01. The report was broad: no exact scenario matrix, tested-tree identity, or engine-version record was supplied. No agent-run Godot, build, compiler, or automated-test evidence exists. Keep incoming Enemy attacks, ordinary-play defence validation, final art, final tuning, complete enemy content, future stages, and other explicitly deferred seams separate from that report.

Player-facing orb terminology is authoritative: a landed melee hit performs **Generating** and creates a generated orb; holding R2 performs **Charging** and turns selected generated orbs into charged orbs ready for the next Cast. Existing private code identifiers using `marked` remain implementation details unless separately refactored; game-facing text and canonical records use generated/charged terminology.

Godot runtime behavior remains unverified unless the user explicitly reports that the relevant version was run and checked in Godot. A broad report establishes only broad validation; do not invent scenario-level coverage.

## Authority order

Apply this order when sources disagree:

1. The user's latest explicit decision.
2. User-verified gameplay in `docs/GAME_DESIGN.md`.
3. User-verified technical representation in `docs/TECH_ARCHITECTURE.md`.
4. Implementation.

Use each document's stated status and the user's verification, not its filename, to determine whether it is authoritative. If current documents and implementation disagree materially, report the mismatch rather than reconciling it silently.

## Read before acting

- `docs/README.md` — document map.
- `docs/GAME_DESIGN.md` — gameplay and player-experience state.
- `docs/TECH_ARCHITECTURE.md` — technical ownership and data-flow state.
- `docs/IMPLEMENTATION_STATUS.md` — implemented and verified state.

Read only the sources relevant to the request, but inspect the current Git state before any edit.

## Git checkpoint and thread recovery

The repository checkpoint contract is:

- `save checkpoint` means inspect the current status and diff, query every currently listed and unarchived Laema task, and create a new schema 4 checkpoint folder. It contains a small manifest plus one compact Markdown note per task. Each note records material change since the previous checkpoint, carried context, a resume point, and sources. Preserve earlier checkpoint folders as history.
- Every recovery manifest must assign each task a stable canonical `task_key` within the Laema project, a canonical title, and any explicitly confirmed title aliases. The `task_key` and alias set are the portable identity; a Codex thread ID, host ID, checkout path, status, and cursor/timestamp are machine-specific bindings. Preserve every binding and its transcript history rather than replacing older bindings.
- Save schema 4 checkpoints as a folder under `docs/checkpoints/`. Create one compact Markdown note for every currently listed, unarchived Laema task. Each note contains Since last checkpoint, Carried context, Resume point, and Sources. Keep the note short enough to read in one pass; carry prior context forward in plain language and summarize only material changes. The sibling manifest stores stable task identity, aliases, current binding metadata, the latest completed round, a portable `progress_uid` digest of that round, changed flag, compact summary, and the relative task-file path. On load, compare the checkpoint and local binding UIDs first; matching UIDs mean the task is dormant and must be skipped.
- As part of `save checkpoint`, stage all current tracked modifications and untracked project files with `git add -A`; do not filter out source, scene, asset, configuration, or documentation changes. Then commit and push the complete checkpoint in the same operation. A save is not published until the push succeeds; report any partial commit/push state exactly.
- `load checkpoint` means inspect local Git state first. If staged, unstaged, or untracked work exists, stop and ask the user to resolve it; never stash, reset, revert, discard, or overwrite it automatically. When safe, fast-forward the checkout, resolve every saved task, and send each resolved task one short instruction pointing to its own note. The task reads its note and current canonical sources, carries compatible context forward, distinguishes changes, and reports conflicts and its resume point.
- During `load checkpoint`, resolve every task by current project identity, canonical `task_key`, and confirmed aliases. Send one short restoration request pointing to the task's own Markdown note. The task reads its note and current canonical sources, carries compatible context forward, identifies what changed, and reports any material conflict and resume point. Do not put a large recovery package in the task message.
- When a safe `load checkpoint` creates or updates a recovery record, binding, or other explicitly authorized project file, stage, commit, and push that result in the same operation before reporting completion. A read-only load with no file changes has no commit to publish and should report that no-op. If the initial dirty-tree gate blocks the load, do not pull, commit, or push.
- If the Codex thread service is unavailable, report that only the Git files were loaded and that thread conversations were not restored. Never claim that a repository pull restored chat history.
- Outside `save checkpoint` and `load checkpoint`, commit and push remain separate explicit actions.

### Cory checkpoint reconciliation

The user authorized development-only chat summaries in this public depot. On save checkpoint, create the normal complete schema 4 task notes; tools/checkpoint.ps1 also validates and writes cory-context.json beside the manifest and docs/checkpoints/latest.json pointing to that checkpoint. Include both in the same complete save/commit/push. Exclude personal material, raw transcripts, reasoning, credentials and private command/tool output.

On load checkpoint, the normal dirty-tree gate and fast-forward run first. Omitting ManifestPath resolves the depot latest pointer, with committed-manifest history as a legacy fallback. After reading local unarchived task context, pass the returned cory_snapshot.packet.threadContext as carriedThreadContext to Cory's open_reconciliation_dashboard, along with fresh local threadContext. Stable task keys, confirmed aliases, binding history and progress UIDs determine continuity; do not copy a saved UID onto different local history. Matching UIDs retain the existing dormant-task skip. Similar titles alone are review candidates. Preserve both summaries, distinguish carried/changed/conflicting context and show the best proposed resume point. A missing local binding is unresolved, not deleted. Only an actual load checkpoint command authorizes the existing restoration dispatch; dashboard comparison buttons remain read-only.


### Persistent departments and independent tasks

Combat, Narrative, Town Design, Marketing, Art, Design Overseer, Audio and Other each have one persistent Markdown record in docs/departments/. These records carry development context across task creation, closure and machine changes. They do not supersede user decisions, the GDD or accepted technical records. Keep facts, decisions, proposals, Open items, conflicts, validation limits and sources distinct.

Tasks retain independent task_key, title, bindings, history, progress UID and task note. A department is not a task identity: several tasks may belong to one department, and a new task must not masquerade as an older same-department chat. Ask which department a new task belongs to unless the user already specifies it. Other is an explicit choice; do not silently classify new work by title or Skill. Persist choices in docs/departments/task-departments.json. On save/load, ask about unassigned tasks and preserve existing confirmed choices.

The user explicitly keeps Production Manager as its own standalone coordination position. Its independent task note and binding history carry its context; record position_key production_manager with no department assignment. This is a confirmed exception for that task key, not an implicit Other classification or a general exemption for unassigned tasks. Keep all eight specialist department records.

New saves use schema 4. Reconcile material task developments into the appropriate department record while keeping independent task notes. Never blindly overwrite department memory with one task's latest response. Include all eight department records, task assignments and ordinary candidate scope. The checkpoint adapter freezes department copies under the new checkpoint's departments/ folder, computes their content UIDs, writes cory-context.json and latest.json, and publishes through the existing complete checkpoint save. Historical schemas 1–3 remain readable.

Load the latest saved department records first, then read the selected current task context. Restore matched independent tasks with both their task note and department record. A genuinely new task loads its chosen department without stealing another task's identity or transcript. Missing saved tasks remain reference context, not a requirement to recreate them. Equal task UIDs permit a dormant skip only when the department UID is also verified unchanged; unknown or changed department context must be reconciled. Update confirmed bindings and department-read UIDs only from actual reads. Preserve dormant domains and report unresolved conflicts; do not infer approval or restore unread history.

Department records and checkpoint snapshots contain development summaries only. Preserve the existing dirty-tree Load gate and complete Save publication rules. Do not publish this integration outside an explicitly authorized checkpoint or commit/push request.

## Live publication

- `publish live version` is separate from checkpointing. Use `tools/publish-live.ps1` to export the Godot `Web` preset to a temporary directory, compare only generated `index.*` artifacts, then publish them into `live/game` in this working repository.
- `publish live version` publishes a shareable snapshot of the current working source, including permitted uncommitted source changes. It records the source commit and whether the tree was dirty in its result and live commit message. The script stages and publishes only the generated `live/game` artifacts; the editable game and pitch sources remain separate. Resolve Godot from PATH or `LAEMA_GODOT_PATH`. The former `laema-live` remote is historical and is no longer a publication target. Never store a user-specific absolute path in the repository.
- If Godot, matching Web export templates, or the live repository is unavailable, the publication workflow must return the missing prerequisite and ask the user for the installation or location. Do not continue into artifact replacement or Git publication.
- A byte-identical export is a no-op, not an empty live commit. Do not claim an exported build ran successfully unless the user reports it.

## Working boundaries

- Do not invent gameplay rules, project scope, or technical architecture.
- Keep Fact, Constraint, Assumption, Proposal, Decision, Rejected, and Open distinct whenever their status could be confused.
- Record durable accepted project knowledge in `docs/` only through the appropriate user-authorized workflow.
- Preserve unrelated working-tree changes and never overwrite them to make the repository look clean.
- Never claim unavailable build, test, editor, playtest, or runtime evidence.
- Use the installed personal Fanor skills for workflow. Do not copy generic Fanor workflow skills into this repository.
- Treat `docs/TECH_ARCHITECTURE.md` as synchronized with the committed source only after its repository-state and handoff sections match the implementation; retain the accepted technical waivers and route submission-readiness to Ultron `mode=tech-postflight`.
