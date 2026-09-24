# Complete depot checkpoint — 2026-09-24

## Scope

The user authorized a complete Laema depot save. Stage all current tracked modifications and non-ignored untracked project files with the checkpoint workflow; do not filter out project source, scene, asset, configuration, or documentation changes. Preserve every existing candidate, including the earlier uncommitted 2026-09-16 pitch-release record.

## Included candidate groups

- Editable HTML pitch draft: markup, styles, deck/status documentation, provenance records, generated concept art, Heroes III source images/frames, and source video files.
- Schema 3 cross-thread checkpoint: current listed Laema tasks plus task identities/bindings carried from the latest checkpoint where they were outside the app’s 50-task listing window.
- Existing local 2026-09-16 pitch-release changelist and checkpoint folder.

## Already published before this save

Commit 738020d repaired the live/pitch copy by restoring missing layout CSS and adding content-versioned stylesheet/script URLs. It was pushed to origin/main before this full depot checkpoint. The live rendering has not been independently browser-verified.

## Validation and publication boundary

Checkpoint note headings and manifest schema are validated by tools/checkpoint.ps1. Save publication is complete only after commit/push and exact local/origin ref verification. This operation does not change the server-side privacy boundary: GitHub Pages remains public static hosting, and no server-side access control was added.
