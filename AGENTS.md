# Laema project instructions

## Current state

Laema is an in-progress 2D side-scrolling orb-casting and tutorial-stage prototype. The working tree may contain substantial uncommitted draft code, scenes, assets, configuration, or documents. Inspect `git status` and the relevant diff before acting, preserve unrelated work, and never mistake a file's existence for user approval.

The current committed prototype baseline is `582e141` (`feat: add stage one tutorial flow`). It includes the Might/Magic combat composition, continuous combat feedback, Stage 1 five-hit Fire-chain objective, reusable ObjectiveWidget, persistent tutorial root, reusable Stage Areas, transition into the Final Arena, and final-enemy completion into indefinite free practice.

The user reported the current feature set verified in Godot on 2026-08-31. The report was broad: no exact scenario matrix, tested-tree identity, or engine-version record was supplied. No agent-run Godot, build, compiler, or automated-test evidence exists. Keep incoming Enemy attacks, ordinary-play defence validation, final art, final tuning, complete enemy content, Stages 2–7, and other explicitly deferred seams separate from that report.

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

## Working boundaries

- Do not invent gameplay rules, project scope, or technical architecture.
- Keep Fact, Constraint, Assumption, Proposal, Decision, Rejected, and Open distinct whenever their status could be confused.
- Record durable accepted project knowledge in `docs/` only through the appropriate user-authorized workflow.
- Preserve unrelated working-tree changes and never overwrite them to make the repository look clean.
- Never claim unavailable build, test, editor, playtest, or runtime evidence.
- Use the installed personal Fanor skills for workflow. Do not copy generic Fanor workflow skills into this repository.
- Treat `docs/TECH_ARCHITECTURE.md` as synchronized with the committed source only after its repository-state and handoff sections match the implementation; retain the accepted technical waivers and route submission-readiness to Ultron `mode=tech-postflight`.
