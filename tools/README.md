# Workflow tools

`checkpoint.ps1` handles the repeatable repository part of checkpoint recovery. It is intentionally not a Codex-thread client: the agent reads threads, writes concise summaries, and dispatches the resulting update plan to the mapped tasks.

## Save

The agent creates a JSON sidecar under `docs/checkpoints/` and then runs:

```powershell
pwsh -NoProfile -File tools/checkpoint.ps1 -Mode Save -ManifestPath docs/checkpoints/<checkpoint>.thread-sync.json
```

The script requires one entry per task, compares `latest_turn_id` against the previous `*.thread-sync.json` manifest, and requires a concise summary for every changed or newly added task. It then runs `git diff --check`, stages the complete repository with `git add -A`, commits, pushes, and verifies that `HEAD` matches `origin/main`.

## Load

The agent produces a transient local-binding JSON from the current Codex task list, then runs:

```powershell
pwsh -NoProfile -File tools/checkpoint.ps1 -Mode Load -ManifestPath docs/checkpoints/<checkpoint>.thread-sync.json -BindingsPath <local-bindings>.json
```

The script refuses a dirty tree, pulls fast-forward-only, and prints a JSON update plan. The agent sends one `delivery_message` to every plan entry, and sends nothing to unchanged or unresolved tasks. If two tasks changed, the plan contains two messages; the Codex app decides whether those messages render as two blue update indicators.

## Manifest shape

```json
{
  "schema_version": 1,
  "checkpoint_id": "2026-09-04-example",
  "project_id": "66d70521-6484-4bf3-b170-ba142e9e0ad9",
  "tasks": [
    {
      "task_key": "combat",
      "canonical_title": "Combat",
      "aliases": ["Combat"],
      "changed": true,
      "latest_turn_id": "turn-id",
      "summary": "Final Enemy experiment added; runtime evidence remains user-reported only."
    }
  ]
}
```

The companion bindings file uses the same project ID and contains `tasks` with `task_key`, `title`, `thread_id`, and `host_id` fields. The script does not create summaries, infer aliases, or call the Codex thread service.

## Publish live version

```powershell
pwsh -NoProfile -File tools/publish-live.ps1
```

The script resolves the source repository relative to its own location and defaults the live repository to a sibling `laema-live` checkout. Override that location per machine with `LAEMA_LIVE_REPO_PATH` or `-LiveRepoPath`. It uses `godot` from PATH, then `LAEMA_GODOT_PATH`, then `-GodotPath`; no user-specific path is stored in the repository. When a prerequisite is missing, normal agent use returns structured JSON so the agent can ask the user what to install or where to find it. Manual terminal use can pass `-Interactive` to prompt for `godot.exe`. Missing Web export templates are reported separately with the matching installation action. The script requires a clean, already-pushed source checkout and a clean live repository, exports the `Web` preset into a temporary directory, compares generated `index.*` files by SHA-256, and only replaces those artifacts when bytes changed. It then commits, pushes, and verifies the live repository. Use `-WhatIf` to see planned artifact changes without replacing or publishing them.
