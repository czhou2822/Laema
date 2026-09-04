# Laema cross-machine retrieval checkpoint — 2026-09-04

## Purpose

The user reported that the other computer could not retrieve the current task context. This checkpoint republishes the portable recovery state so that recovery is based on Laema task keys, confirmed aliases, and saved task summaries rather than a machine-specific Codex thread ID.

## Recovery source

- **Repository before this checkpoint:** `1885c77` (`checkpoint: 2026-09-04-dev-portal-snapshot`), clean.
- **Portable bindings:** `docs/checkpoints/2026-09-04-cross-machine-thread-bindings.md` retains the confirmed source and local bindings for every task, without replacing historical bindings.
- **Transcript fallback:** `docs/checkpoints/2026-09-03-cross-thread-recovery.md` retains the source conversation material if a local binding is missing or ambiguous.
- **Machine independence:** resolve by `task_key`, canonical title, and confirmed aliases first; treat thread IDs, hosts, checkout paths, status, and cursors only as machine-specific hints.

## Material task updates since the prior manifest

| Task key | Update |
|---|---|
| `combat` | Enemy-AI status was summarized. Damage-number semantics after resistance, blocking, and modifiers remain Open; no design decision was made. |
| `production_manager` | The user reported failed cross-machine retrieval. This checkpoint refreshes the portable recovery record; it adds no gameplay, source, or validation decision. |

The other eight mapped tasks retain their previously saved latest rounds and remain included in the machine-readable manifest.

## Recovery procedure on the other computer

1. Make the Laema checkout clean; a load deliberately stops if it finds staged, unstaged, or untracked work.
2. Pull the published `main` branch.
3. Request `load checkpoint` in the Laema project. It should read this manifest and the binding record, then resolve local tasks by portable identity before considering a saved thread ID.
4. If a binding cannot be found uniquely, use the embedded transcript fallback rather than silently substituting a same-titled task.

This save does not prove the other machine's retrieval path has been run. It only makes the complete current recovery material available through Git.

## Evidence boundary

- No gameplay, Godot, browser, build, compiler, or automated-test validation was run for this checkpoint.
- Existing user-reported Godot validation remains limited to the broad Stage 1–6 report recorded elsewhere.
