# Changelist — 2026-09-11 progress-UID checkpoint

## Intent

Publish the UID-aware checkpoint workflow and the complete current Laema working scope.

## Included scope

- `docs/checkpoints/2026-09-11-progress-uid/README.md`
- `docs/checkpoints/2026-09-11-progress-uid/manifest.json`
- One compact task note for each of the ten listed, unarchived Laema tasks.
- `AGENTS.md`, `docs/README.md`, `tools/README.md`, and `tools/checkpoint.ps1` — portable UID rules and dormant-task load filtering.
- Current presentation modifications/deletions and untracked deck, preview, image, GIF, and keyframe assets already present in the working tree.

## Evidence and preservation

- The prior checkpoint is named in `manifest.json` and remains unchanged.
- UIDs are recovery metadata, not gameplay/runtime evidence; missing or non-comparable UIDs remain conservative and are not skipped.
- `tools/checkpoint.ps1 Save` stages all current files, commits, pushes, and verifies `HEAD` equals `origin/main`.
