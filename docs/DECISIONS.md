# Decisions

## 2026-08-20 — Checkpoint synchronization workflow

- **Decision:** “Save checkpoint” and close equivalents sweep all available, unarchived Laema threads, including idle threads, while excluding archived and unrelated threads.
- **Decision:** A save writes a dated Markdown checkpoint containing thread IDs, updates, and the current labeled design state, then commits and pushes it to `origin`.
- **Decision:** A save is not reported as complete unless the push succeeds. Synchronization failures leave the local state intact and are reported precisely.
- **Decision:** A save checkpoint produces two review outputs: a durable cross-thread project record and a separate changelist covering all modified and untracked project files, their scope, validation evidence, authority mismatches, and the proposed review boundary.
- **Constraint:** Checkpointing does not stage or publish prototype code, scenes, assets, configuration, or canonical-document drafts unless the user separately authorizes that scope.
- **Decision:** “Load checkpoint” and close equivalents pull the latest checkpoint fast-forward-only, reconcile the local repository, and send checkpoint-derived resume context to each listed unarchived thread available on the current host.
- **Constraint:** Git does not transfer thread history. Loading updates available threads with context; it does not rewrite or resurrect archived, missing, or inaccessible threads, which are reported as skipped.

## 2026-08-24 — First-draft prototype baseline

- **Decision:** The committed first-draft baseline is `e543a43`, covering the user-verified 2D top-down Fire/Water prototype slice with Air/Earth placeholders and a non-attacking Enemy.
- **Fact:** The user reported `validation passed` in Godot on 2026-08-24 for the exercised scene, controls, school selection, Fire/Water combat, combos, Heat, Enemy refill, statuses, hit reactions, collision, animation readability, and UI.
- **Constraint:** Incoming Enemy attacks, ordinary-play blocking/parrying/guard-break triggering, functional Air/Earth packages, final art, complete enemy content, and final tuning remain outside that validation.
- **Constraint:** The accepted instigator-lifetime waiver and the deferred Enemy/Air/Earth scope remain part of the technical record.
- **Decision:** `docs/TECH_ARCHITECTURE.md` is synchronized to the committed implementation and validation boundary by the current documentation update; future material source changes must keep it synchronized before submission readiness is declared.

## 2026-08-25 — Expanded side-scrolling prototype state

- **Decision:** The active prototype representation is the four-school side-scrolling orb-casting slice with five-position X/Cast chains, seven-second FIFO orb lifetime, R2 DEPLETING/CHARGING/CAST pressure semantics, full-press Casting, shared normalized X/Cast buffering, three non-attacking Enemy targets, and the organized Developer Portal/audio controls recorded in the canonical GDD and technical architecture.
- **Fact:** The user reported the expanded implementation as validated in Godot on 2026-08-25, but did not provide a scenario-by-scenario matrix or engine-version record.
- **Constraint:** Agent-run Godot, build, compiler, and automated-test evidence remains unavailable. Incoming Enemy attacks, ordinary-play defence validation, final art, final tuning, and complete enemy content remain outside the current validation boundary.
- **Decision:** The active summaries and implementation-status record are synchronized to the current implementation. Dated checkpoints and changelists retain their historical wording as an audit trail and do not override the canonical documents.
- **Fact:** The current committed implementation is `358684b` (`feat: add side-scrolling orb casting prototype`). The user-reported validation applies to the expanded implementation, while agent-run runtime/build/test evidence remains unavailable.
