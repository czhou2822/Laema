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

The schema 4 manifest contains task identity, routing data and confirmed department assignments. This abbreviated example shows one task; actual saves include every current unarchived task and preserve current and historical bindings. The adapter freezes all eight department records and writes their content UIDs. Replace the illustrative identifiers and progress UID with actual discovered values.

    {
      "schema_version": 4,
      "checkpoint_id": "2026-09-05-example",
      "previous_manifest": "docs/checkpoints/2026-09-04-example/manifest.json",
      "project_id": "portable-checkpoint-project-id",
      "tasks": [
        {
          "task_key": "design_overseer",
          "department_key": "design_overseer",
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

The script validates schema 4, verifies each note has the required headings and a `progress_uid`, compares progress UIDs when checking changed-task summaries, stages all project files, commits, pushes, and verifies HEAD equals origin/main.

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

## Cory depot snapshot

Save creates a bounded development-only cory-context.json next to the manifest and updates docs/checkpoints/latest.json before the existing complete commit/push. Load/Plan emits cory_snapshot for comparison with fresh home-PC context in Cory. Load can omit ManifestPath to resolve the latest committed pointer. Read-only inspection: node tools/cory-checkpoint.mjs --read <project-root>. It never writes or publishes; legacy notes remain labelled partial. No cloud snapshot store or chat transcript synchronization is installed.

### Persistent departments and independent tasks

Combat, Narrative, Town Design, Marketing, Art, Design Overseer, Audio and Other each have one persistent Markdown record in docs/departments/. These records carry development context across task creation, closure and machine changes. They do not supersede user decisions, the GDD or accepted technical records. Keep facts, decisions, proposals, Open items, conflicts, validation limits and sources distinct.

Tasks retain independent task_key, title, bindings, history, progress UID and task note. A department is not a task identity: several tasks may belong to one department, and a new task must not masquerade as an older same-department chat. Ask which department a new task belongs to unless the user already specifies it. Other is an explicit choice; do not silently classify new work by title or Skill. Persist choices in docs/departments/task-departments.json. On save/load, ask about unassigned tasks and preserve existing confirmed choices.

Production Manager is the user-confirmed standalone coordination position. Its task key and position_key are both production_manager; department_key stays null. It carries its own task note and bindings and uses the ordinary verified task-UID dormant check. This exception does not exempt any other task from explicit department assignment. Cory's existing nullable departmentKey transports its task context while all eight specialist department records remain intact.

New saves use schema 4. Reconcile material task developments into the appropriate department record while keeping independent task notes. Never blindly overwrite department memory with one task's latest response. Include all eight department records, task assignments and ordinary candidate scope. The checkpoint adapter freezes department copies under the new checkpoint's departments/ folder, computes their content UIDs, writes cory-context.json and latest.json, and publishes through the existing complete checkpoint save. Historical schemas 1–3 remain readable.

Load the latest saved department records first, then read the selected current task context. Restore matched independent tasks with both their task note and department record. A genuinely new task loads its chosen department without stealing another task's identity or transcript. Missing saved tasks remain reference context, not a requirement to recreate them. Equal task UIDs permit a dormant skip only when the department UID is also verified unchanged; unknown or changed department context must be reconciled. Update confirmed bindings and department-read UIDs only from actual reads. Preserve dormant domains and report unresolved conflicts; do not infer approval or restore unread history.

Department records and checkpoint snapshots contain development summaries only. Preserve the existing dirty-tree Load gate and complete Save publication rules. Do not publish this integration outside an explicitly authorized checkpoint or commit/push request.
