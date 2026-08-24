# Laema project instructions

## Current state

Laema is an in-progress 2D top-down combat prototype. The working tree may contain substantial uncommitted draft code, scenes, assets, configuration, or documents. Inspect `git status` and the relevant diff before acting, preserve unrelated work, and never mistake a file's existence for user approval.

Godot runtime behavior remains unverified unless the user explicitly reports that the relevant version was run and checked in Godot.

## Authority order

Apply this order when sources disagree:

1. The user's latest explicit decision.
2. User-verified gameplay in `docs/GAME_DESIGN.md`.
3. User-verified technical representation in `docs/TECH_ARCHITECTURE.md`.
4. Implementation.

Use each document's stated status and the user's verification, not its filename, to determine whether it is authoritative. Dated files under `docs/checkpoints/` are working snapshots; they do not override canonical documents or silently promote proposals into decisions. If current documents, checkpoints, and implementation disagree materially, report the mismatch rather than reconciling it silently.

## Read before acting

- `docs/README.md` — document map and checkpoint rules.
- `docs/GAME_DESIGN.md` — gameplay and player-experience state.
- `docs/TECH_ARCHITECTURE.md` — technical ownership and data-flow state.
- `docs/IMPLEMENTATION_STATUS.md` — implemented and verified state.
- The latest relevant file under `docs/checkpoints/` when continuing prior work.

Read only the sources relevant to the request, but inspect the current Git state before any edit.

## Working boundaries

- Do not invent gameplay rules, project scope, or technical architecture.
- Keep Fact, Constraint, Assumption, Proposal, Decision, Rejected, and Open distinct whenever their status could be confused.
- Record durable accepted project knowledge in `docs/` only through the appropriate user-authorized workflow.
- Preserve unrelated working-tree changes and never overwrite them to make the repository look clean.
- Never claim unavailable build, test, editor, playtest, or runtime evidence.
- Use the installed personal Fanor skills for workflow. Do not copy generic Fanor workflow skills into this repository.
