# Changelist — 2026-09-16 pitch release checkpoint

## Intent

Save the complete current editable pitch scope and its schema-3 task recovery records before publishing the selected snapshot into `live/pitch`.

## Included scope

- `docs/checkpoints/2026-09-16-pitch-release/README.md`
- `docs/checkpoints/2026-09-16-pitch-release/manifest.json`
- One compact note for every currently listed Laema task, including the distinct new `polish_deck_presentation` task.
- All current tracked and untracked editable-pitch markup, styles, documentation, source/reference/generated images, and video under `docs/presentation/decks/laema-html-draft/`.

## Evidence and preservation

- `build_pitch_deck` remains preserved in the prior checkpoint history; it is not silently merged into the new current task identity.
- Current pitch artifacts are working material; no user visual approval or gameplay/runtime evidence is claimed.
- The save publisher stages all current project files, commits, pushes, and verifies `HEAD` equals `origin/main`.
