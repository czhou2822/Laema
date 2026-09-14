# Changelist — 2026-09-14 live consolidation checkpoint

## Intent

Publish the migrated `live/` structure through the main Laema repository and record the current cross-task recovery state.

## Included scope

- Prior local commit `5d3d32d` — migrated the former `laema-live` game bundle to `live/game`, copied the published pitch to `live/pitch`, added `live/index.html`, and redirected the publication workflow to the working repository.
- `docs/GAME_DESIGN.md` — user-authored future Mirham, Cloudfire, and narrative direction, explicitly outside active prototype requirements.
- `docs/checkpoints/2026-09-14-live-consolidation/` — schema-3 manifest and 11 compact task notes.
- This changelist.

## Preservation and validation

- The former `laema-live` remote remains intact as historical rollback but is not an active publication destination.
- Local HTTP checks confirmed the live hub, game bundle assets, and pitch routes load. No new Godot runtime, gameplay, visual, or user-review evidence is claimed.
- Save stages the complete current tree, commits this checkpoint, pushes `main`, and verifies the remote revision.
