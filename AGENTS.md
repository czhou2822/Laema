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

- `save checkpoint` means inspect the current status and diff, query every currently listed and unarchived Laema task (including idle or not-loaded tasks), and record at least its latest completed message round: the newest user message and the corresponding assistant response, with the task ID, exact title, status, and recovery cursor or timestamp when available. If a task has changed since the previous checkpoint, capture its new latest round. Store this recovery manifest and transcript material in a new dated file under `docs/checkpoints/`, with a matching reviewable file-scope record under `docs/changelists/`. Preserve older records as history.
- Every recovery manifest must assign each task a stable canonical `task_key` within the Laema project, a canonical title, and any explicitly confirmed title aliases. The `task_key` and alias set are the portable identity; a Codex thread ID, host ID, checkout path, status, and cursor/timestamp are machine-specific bindings. Preserve every binding and its transcript history rather than replacing older bindings.
- As part of `save checkpoint`, stage all current tracked modifications and untracked project files with `git add -A`; do not filter out source, scene, asset, configuration, or documentation changes. Then commit and push the complete checkpoint in the same operation. A save is not published until the push succeeds; report any partial commit/push state exactly.
- `load checkpoint` means inspect local Git state first. If staged, unstaged, or untracked work exists, stop and ask the user to resolve it; never stash, reset, revert, discard, or overwrite it automatically. When the checkout is safe to synchronize, pull committed repository state with fast-forward-only behavior, read the newest checkpoint and changelist, then query every currently listed and unarchived task named in the recovery manifest and reopen/read at least its saved latest completed message round. If a task has newer messages, read and report its newest round as well. Restore context by reading the conversations; do not send duplicate messages or mutate the tasks unless the user explicitly asks.
- During `load checkpoint`, resolve a task by the current project identity plus its canonical `task_key` and confirmed aliases before relying on a thread ID. Verify the local title/project and compare the saved transcript or latest-turn metadata. If no task matches or more than one matches, report the task as unresolved and use the embedded transcript as context; never silently substitute a same-titled task. Once a user-confirmed binding exists, record the local machine's ID as a new binding in the next save.
- When a safe `load checkpoint` creates or updates a recovery record, binding, or other explicitly authorized project file, stage, commit, and push that result in the same operation before reporting completion. A read-only load with no file changes has no commit to publish and should report that no-op. If the initial dirty-tree gate blocks the load, do not pull, commit, or push.
- If the Codex thread service is unavailable, report that only the Git files were loaded and that thread conversations were not restored. Never claim that a repository pull restored chat history.
- Outside `save checkpoint` and `load checkpoint`, commit and push remain separate explicit actions.

## Working boundaries

- Do not invent gameplay rules, project scope, or technical architecture.
- Keep Fact, Constraint, Assumption, Proposal, Decision, Rejected, and Open distinct whenever their status could be confused.
- Record durable accepted project knowledge in `docs/` only through the appropriate user-authorized workflow.
- Preserve unrelated working-tree changes and never overwrite them to make the repository look clean.
- Never claim unavailable build, test, editor, playtest, or runtime evidence.
- Use the installed personal Fanor skills for workflow. Do not copy generic Fanor workflow skills into this repository.
- Treat `docs/TECH_ARCHITECTURE.md` as synchronized with the committed source only after its repository-state and handoff sections match the implementation; retain the accepted technical waivers and route submission-readiness to Ultron `mode=tech-postflight`.
