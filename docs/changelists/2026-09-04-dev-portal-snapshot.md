# Changelist — 2026-09-04 Developer Portal sharing snapshot

## Intent

Persist the current working source after enabling the Developer Portal in Web sharing snapshots and changing live publication from a clean-release policy to a working-tree snapshot policy.

## Included scope

- `scripts/prototype/prototype_arena.gd` — creates the Developer Portal in Web/release snapshots.
- `README.md` — removes the obsolete debug-only Portal wording.
- `tools/publish-live.ps1` — waits for GUI Godot export, reports prerequisites, and publishes working snapshots without requiring clean source.
- `tools/README.md` and `AGENTS.md` — document portable snapshot publication behavior.
- `docs/art/ART_DIRECTION.md` — approved prototype developer-overlay visual direction.
- `docs/checkpoints/2026-09-04-dev-portal-snapshot.*` and this changelist.

## Evidence

- `git diff --check` passed before save publication.
- The prior live snapshot changed `index.html` and `index.pck` at live commit `dd3b1de`.
- No agent-run browser or Godot playtest is claimed.
