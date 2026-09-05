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

Resolve every saved task using verified portable identity. The load plan includes every task lacking a verified acknowledgement of this snapshot, even if unchanged since the previous save. Send its restoration request once, then wait for and inspect a substantive response in that task covering sources, governing decisions, proposals, open questions/conflicts, validation limits, and the resume point. Record the recovery token and response turn only after inspection. Delivery alone does not complete restoration; report missing responses, source conflicts, and unresolved bindings.

## Manifest shape

New saves use schema_version 2 and explicitly set previous_manifest to the repository-relative path of the preceding sidecar. Existing schema 1 checkpoints remain loadable; their missing context is reported, never invented. The agent writes complete packages before calling Save; the script validates them and rejects changes to packages marked unchanged or removal of historical bindings. Save still stages all project files, commits, and pushes.

Each schema 2 task retains the existing fields and adds:

```json
"recovery": {
  "role": "Design oversight",
  "decisions_and_rationale": ["Accepted decisions with their reasons and sources"],
  "proposals": [],
  "open_questions": ["Unresolved foundation relationship"],
  "conflicts": [],
  "validation_limits": ["Broad user report only; exact tested tree unknown"],
  "sources": ["docs/GAME_DESIGN.md", "docs/TECH_ARCHITECTURE.md"],
  "resume_point": "Await user direction on the unresolved foundation relationship",
  "latest_round": "Faithful recap of latest completed user request and assistant response",
  "bindings": [{"thread_id": "verified-id", "host_id": "local", "checkout": "recorded path", "turn_id": "saved-turn"}]
}
```

These values illustrate the shape, not approved project facts. Use empty arrays only when there is nothing in that category; explicitly record unavailable evidence. Never omit unchanged task context from a new save.

Load emits recovery_token and requires_response for each request. In the transient bindings, restored_token plus response_turn_id may suppress a repeat only after the agent has read that exact task response, verified the token and substantive restoration, and checked for material newer local context. Preserve response receipts in the next authorized recovery record; reconstruct them from task history when needed. An interrupted send must be checked in task history before resending. A token alone or a successful send is not proof of restoration. For PM's own task, incorporate the package and provide its substantive restoration here; avoid waiting for the active task to finish itself.

The helper outputs awaiting_agent_verification until the agent performs these checks. Only then may PM report restoration complete. Missing bindings or responses remain explicitly incomplete. Source conflicts must be reported without silently changing decisions. Current main-checkout documents take precedence over stale worktree documents under the project's authority order.

Use Mode Plan with the same arguments to inspect the generated requests without Git writes, pulls, commits, pushes, or task dispatch. It permits a dirty tree for local development and must never be reported as a completed Load. The example below is the legacy schema, retained for reference.

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

The script resolves the source repository relative to its own location and defaults the live repository to a sibling `laema-live` checkout. Override that location per machine with `LAEMA_LIVE_REPO_PATH` or `-LiveRepoPath`. It uses `godot` from PATH, then `LAEMA_GODOT_PATH`, then `-GodotPath`; no user-specific path is stored in the repository. When a prerequisite is missing, normal agent use returns structured JSON so the agent can ask the user what to install or where to find it. Manual terminal use can pass `-Interactive` to prompt for `godot.exe`. Missing Web export templates are reported separately with the matching installation action. The source checkout may be dirty or ahead of its remote: this command publishes a shareable working snapshot and records that source state in its result and live commit message. The live repository itself must be clean. The script exports the `Web` preset into a temporary directory, compares generated `index.*` files by SHA-256, and only replaces those artifacts when bytes changed. It then commits, pushes, and verifies the live repository. Use `-WhatIf` to see planned artifact changes without replacing or publishing them.
