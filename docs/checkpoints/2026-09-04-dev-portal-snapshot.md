# Laema Developer Portal sharing snapshot — 2026-09-04

## Purpose

This checkpoint captures the current working source after the public sharing build omitted the Developer Portal. The Portal is now created in Web/release snapshots, and `publish live version` is defined as a shareable working-tree snapshot rather than a polished production release.

## Repository and live snapshot state

- **Source base commit:** `071c85f`.
- **Published live snapshot:** `dd3b1de` (`Publish Laema working snapshot (071c85f+working)`).
- **Updated live artifacts:** `index.html`, `index.pck`.
- **Working source included:** the Portal gate removal, portable publisher changes, README/documentation updates, and `docs/art/ART_DIRECTION.md`.
- **Validation boundary:** export and live upload succeeded. Browser/runtime validation of the Portal remains user-owned; no agent-run playtest is claimed.

## Material task summaries

| Task key | Summary |
|---|---|
| `combat` | Playtest notes: R2-to-L2 is Open; ascending charged-orb pitch feedback is a Proposal. No rule changed. |
| `production_manager` | Public sharing snapshots now include the Developer Portal and may export dirty source; the live repo remains protected as a clean artifact destination. |
| `art` | Approved live developer-overlay telemetry and event-confirmation direction was recorded in `docs/art/ART_DIRECTION.md`. |
| `narrative_room` | Chinese recap only; no new canon. |
| `town_design` | Chinese recap only; no new town decision. |

The remaining mapped tasks have no material update in this manifest.

## User validation

Hard-refresh the browser build, press backtick, and confirm that the paused Developer Portal opens. This is the remaining validation for the live snapshot change.

## Publication boundary

`tools/checkpoint.ps1` stages, commits, pushes, and verifies the complete current source scope for this save. The checkpoint is incomplete until the push succeeds.
