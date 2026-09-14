# Workflow tools

checkpoint.ps1 handles the repeatable Git work for Laema checkpoints. The agent reads task conversations, writes compact recovery notes, and checks the restoration responses.

## Compact checkpoint structure

A new checkpoint uses this shape:

    docs/checkpoints/<checkpoint-id>/
      manifest.json
      combat.md
      marketing.md
      production-manager.md
      ...
    docs/changelists/<checkpoint-id>.md

Each task note follows [checkpoint-task-template.md](checkpoint-task-template.md). Keep it short: the last material delta, the context worth carrying, a resume point, and sources. The note should read like the restoration benchmark, not a raw transcript.

The schema 3 manifest contains task identity and routing data:

    {
      "schema_version": 3,
      "checkpoint_id": "2026-09-05-example",
      "previous_manifest": "docs/checkpoints/2026-09-04-example/manifest.json",
      "project_id": "portable-checkpoint-project-id",
      "tasks": [
        {
          "task_key": "design_overseer",
          "canonical_title": "Design Overseer",
          "aliases": ["Design Overseer", "Design overseer"],
          "changed": true,
          "summary": "Compact material delta.",
          "latest_turn_id": "turn-id",
          "progress_uid": "sha256:portable-latest-completed-round-digest",
          "task_file": "design-overseer.md"
        }
      ]
    }

The agent creates one note for every current unarchived Laema task, including tasks with no material change. `progress_uid` is a portable digest of the latest completed user/assistant round (including the project and task key), not a thread ID, host ID, timestamp, or checkout path. The transient local-binding JSON carries the corresponding digest for the local task. Historical bindings remain in earlier checkpoint records.

## Save

After the agent has written the manifest, task notes, and changelist:

    pwsh -NoProfile -File tools/checkpoint.ps1 -Mode Save -ManifestPath docs/checkpoints/<checkpoint-id>/manifest.json

The script validates schema 3, verifies each note has the required headings and a `progress_uid`, compares progress UIDs when checking changed-task summaries, stages all project files, commits, pushes, and verifies HEAD equals origin/main.

## Load

The agent creates a transient local-binding JSON from the current Codex task list, then runs:

    pwsh -NoProfile -File tools/checkpoint.ps1 -Mode Load -ManifestPath docs/checkpoints/<checkpoint-id>/manifest.json -BindingsPath <local-bindings>.json

The script checks that Git is clean, fast-forwards the checkout, resolves task bindings, and compares each checkpoint `progress_uid` with the local binding `progress_uid`. If both match, it emits the task in `skipped_dormant` and sends no request. Otherwise it emits one short request per resolved task; that request points only to the task note. The agent sends it, reads the response, and reports:

- Carried context
- Changed since checkpoint
- Conflict, if any
- Resume point

The output also includes `dormant_count` and `skipped_dormant`. A missing UID is handled conservatively and is not treated as a match; legacy schema 1/2 and older schema-3 manifests remain loadable without dormant skipping.

If authority does not resolve a material conflict, the task asks the user to decide. It does not edit files as part of restoration.

Use Mode Plan with the same arguments to inspect the requests without Git writes, pulls, commits, pushes, or task messages.

## Legacy checkpoints

Schema 1 and 2 checkpoints remain loadable. They route each task to the older manifest or checkpoint record and state that full per-task notes were not available. Do not manufacture missing context.

## Publish live version

    pwsh -NoProfile -File tools/publish-live.ps1

The script exports the Web preset into a temporary directory, compares generated `index.*` files by SHA-256, replaces only `live/game`, commits that published folder to the working repository, pushes `main`, and verifies the repository remote. The source checkout may be dirty because this publishes a shareable working snapshot. Godot is resolved from PATH or `LAEMA_GODOT_PATH`; the former `laema-live` checkout is no longer used.
