# Production Manager checkpoint — 2026-09-14

Task key: production_manager

## Since last checkpoint

- The working repository now owns `live/game`, `live/pitch`, and a `live/` entry page; the separate `laema-live` remote is no longer the publication target.
- `tools/publish-live.ps1` now refreshes only `live/game` and publishes that folder through the main repository.

## Carried context

- Decision: editable game source stays at the repository root; editable pitch stays under `docs/presentation/decks/laema-html-draft`; `live/` holds snapshots.
- Validation: migrated game files matched the former live bundle byte-for-byte; local hub, game, and pitch routes loaded. This is not a new Godot runtime or user-review result.

## Resume point

Use the working repository as the only publication path. Archive or delete the old remote only if the user explicitly chooses that external action.

## Sources

- live/README.md
- tools/publish-live.ps1
- PM turn 01a0a05a-8513-7663-8795-5096b8731e77
