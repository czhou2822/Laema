# Laema portable thread-binding checkpoint — 2026-09-04

## Purpose

This record makes the user-confirmed source-to-local task map durable for bidirectional recovery. Canonical task keys and aliases are portable; thread IDs, hosts, checkouts, statuses, and turn cursors are machine-specific bindings. The full source transcript remains preserved in `docs/checkpoints/2026-09-03-cross-thread-recovery.md`.

## Capture metadata

- **Captured:** 2026-09-04.
- **Project:** Laema, Codex project `66d70521-6484-4bf3-b170-ba142e9e0ad9`.
- **Repository before this record:** `main` and `origin/main` were aligned at `b395c5ee9b46193be694d2ef045691ab762f05c7`.
- **User confirmation:** the local name map below was explicitly confirmed as correct.
- **Conversation rule:** do not send mapping prompts or mutate tasks during load; use the saved transcript when a source ID is unavailable.

## Confirmed portable bindings

| Canonical task key | Canonical title | Confirmed aliases | Source checkpoint binding | Local binding |
|---|---|---|---|---|
| `combat` | Combat | `Combat` | `01a0150a-3101-7611-910e-4e9dc6d55728` @ `C:\Users\zhouc\OneDrive\Documents\ChatGPT\Laema` | `01a01768-b38f-7480-a74b-70e29cc50fae` @ `C:\Users\ckzhou\.codex\worktrees\5f33\Laema` |
| `marketing` | Marketing | `Marketing` | `01a03d58-c058-7f10-a30a-3185b3dfc8ce` @ `C:\Users\zhouc\.codex\worktrees\0c16\Laema` | `01a03c62-0713-7f72-9237-38ed6e1b42d1` @ `C:\Users\ckzhou\Documents\GitHub\Laema` |
| `production_manager` | Production Manager | `PM`, `Production Manager` | `01a014f7-f5ea-7e70-9474-117c6ca3728d` @ `C:\Users\zhouc\OneDrive\Documents\ChatGPT\Laema` | `01a01766-1781-7800-a3cb-fc38aca5bb1e` @ `C:\Users\ckzhou\Documents\GitHub\Laema` |
| `u` | U | `U` | `01a02d6a-8dfd-75f1-8b1f-230ababb3f22` @ `C:\Users\zhouc\OneDrive\Documents\ChatGPT\Laema` | `01a03c06-1c70-7b13-9717-249b021f1cd8` @ `C:\Users\ckzhou\Documents\GitHub\Laema` |
| `art` | Art | `Art` | `01a01e79-b350-7b81-8643-3ee1681c062f` @ `C:\Users\zhouc\.codex\worktrees\cb05\Laema` | `01a01d0a-ced6-77c0-a98a-e94ec3c5c10e` @ `C:\Users\ckzhou\Documents\GitHub\Laema` |
| `dummy` | Dummy | `Dummy` | `01a02eea-fb2f-7c32-aa95-5aed9642a14b` @ `C:\Users\zhouc\OneDrive\Documents\ChatGPT\Laema` | `01a0312b-7bf3-7c93-b16a-343f45cfcff2` @ `C:\Users\ckzhou\.codex\worktrees\b792\Laema` |
| `narrative_room` | Narrative Room | `NarrativeRoom`, `Narrative Room` | `01a014f2-6363-7c20-b67e-1d80689ff86e` @ `C:\Users\zhouc\OneDrive\Documents\ChatGPT\Laema` | `01a01768-b391-7c61-b31f-2d4be4310c73` @ `C:\Users\ckzhou\.codex\worktrees\37a6\Laema` |
| `town_design` | Town Design | `Town Design` | `01a01e79-b349-7f13-a083-4e9224cf1968` @ `C:\Users\zhouc\.codex\worktrees\425b\Laema` | `01a018cb-7c14-7fe2-af09-569b2f3faf97` @ `C:\Users\ckzhou\Documents\GitHub\Laema` |
| `audio` | Laema Audio | `Audio`, `Laema Audio` | `01a02e1a-babc-7200-991f-d48f8f4bf4f2` @ `C:\Users\zhouc\OneDrive\Documents\ChatGPT\Laema` | `01a0312b-7be4-7b81-82d9-1085237e5bb6` @ `C:\Users\ckzhou\.codex\worktrees\cdbf\Laema` |
| `design_overseer` | Design overseer | `Design Overseer`, `Design overseer` | `01a01e79-b347-74e3-ba8e-6ed09d54e2bc` @ `C:\Users\zhouc\.codex\worktrees\7584\Laema` | `01a018d6-9097-7d53-8a42-1fe65472ceb1` @ `C:\Users\ckzhou\Documents\GitHub\Laema` |

## Transcript and turn bindings

The source task IDs and latest completed message rounds are preserved verbatim in `docs/checkpoints/2026-09-03-cross-thread-recovery.md`. The local task rounds were read during the 2026-09-04 mapped sync; the most recent message-bearing local turns were:

| Canonical task key | Source latest turn / timestamp | Local latest message-bearing turn / timestamp | Local recovery note |
|---|---|---|---|
| `combat` | `01a05ca2-3e3c-7a92-bee8-4ea1f8a0abc6` / `1788260645` | `01a05b8d-5453-72a3-b33b-4114a019c3fa` / `1788242443` | Local handoff to U; source has the later reversible Final Enemy experiment. |
| `marketing` | `01a04b2c-19b8-7c02-bce9-e497e38bb9a5` / `1787967601` | `01a0552b-edf5-71c1-89d8-eb755f5e0c97` / `1788135383` | Local 582e141 presentation-state load; source locked the later pitch flow. |
| `production_manager` | `01a05c76-93eb-7f70-b93c-11f2311ee883` / `1788257720` | `01a069ac-c333-7e81-9b15-a90af2d00dc9` / `1788479393` | Local mapping conversation is newer than the source checkpoint round. |
| `u` | `01a05cf3-c232-7762-9064-c6c95fd84ac9` / `1788265889` | `01a05ba5-4c5e-7060-bc6f-02447d3308c2` / `1788244016` | Source's four newest turns exposed no message items; local has the latest export/cache result. |
| `art` | `01a05c9b-1a0b-7b91-b91c-7ad24d0d518f` / `1788260282` | `01a0557f-375c-7e50-a8dc-5b80637be8a1` / `1788140889` | Source asked about VFX; local produced the neutral UI layout wireframe. |
| `dummy` | `01a05185-bf98-7853-bd5d-f195c669127e` / `1788074282` | `01a05a55-a76a-7fd0-96ce-c347a530989d` / `1788222031` | Local parser fix is newer; source round recorded floor continuity. |
| `narrative_room` | `01a03d56-0260-72e2-b4fb-faaca31bda2d` / `1787735502` | `01a0552c-67b0-7c02-a926-7d1e461e5501` / `1788135458` | Both preserve dormant narrative context. |
| `town_design` | `01a03d56-00e8-7261-8130-8d294b5d60d3` / `1787735494` | `01a0552c-54b6-7063-8f79-9f9c35f2b3fa` / `1788135467` | Both preserve dormant Mirham context. |
| `audio` | `01a03d55-fb69-7383-a581-f1317189fb5e` / `1787735559` | `01a0552c-2516-7361-bef6-7eed0b901c16` / `1788135416` | Both preserve audio provenance and the audition boundary. |
| `design_overseer` | `01a03d55-fcf1-72b0-bd97-f1fa1b5d9701` / `1787735530` | `01a0552c-46b3-7811-bb30-7cd38d9ec6cb` / `1788135489` | Both preserve the design/validation boundary. |

The source and local latest rounds are not assumed to be identical merely because the names map. On a future load, the local binding is used for that machine, newer local messages are reported, and the source transcript remains the portable fallback.

## Checkpoint publication rule

- `save checkpoint` stages all current project files, then commits and pushes them in the same operation. The save is incomplete if the push fails.
- A safe `load checkpoint` commits and pushes any recovery record, binding, or other explicitly authorized file it creates or updates. A read-only no-change load is a reported no-op.
- A dirty-tree safety stop performs no pull, commit, or push.

## Bidirectional recovery algorithm

1. On either machine, inspect Git and require a clean tree before loading.
2. Pull fast-forward-only, read the newest checkpoint/changelist, and query the local project task list.
3. Resolve each `task_key` through the confirmed alias set and project identity. Use the machine-specific binding only as a lookup hint.
4. Verify the local title/project and compare the saved latest-turn metadata or transcript. If there is one match, continue with that local ID; if missing or ambiguous, report it and restore only the embedded transcript context.
5. After work, `save checkpoint` records the new machine binding and latest transcript without deleting older bindings. This makes the same process work from home to office and office to home.

## Evidence boundary

- The user reported broad Godot verification of the complete Stage 1–6 flow on 2026-09-01; no exact scenario matrix, tested-tree identity, or engine-version record was supplied.
- The user separately verified always-available school switching; no broader scenario coverage is inferred.
- No agent-run Godot, build, compiler, editor, or automated-test evidence is claimed.
