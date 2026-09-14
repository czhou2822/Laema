# Laema published snapshots

This folder replaces the separate `laema-live` checkout inside the working repository.

- `game/` is the exact browser bundle migrated from `czhou2822/laema-live` at commit `9202fcdba0cc05073fac10ae5874bd56ac0c6c11`.
- `pitch/` is the published copy of `docs/presentation/decks/laema-html-draft` at the time of migration.
- `index.html` is a small entry page linking to both published snapshots.

Working sources remain separate:

- Godot source: the repository root.
- Editable pitch: `docs/presentation/decks/laema-html-draft/`.

Use `tools/publish-live.ps1` to refresh `game/` in this repository. The former `laema-live` remote has not been deleted, but it is no longer the publication target.
