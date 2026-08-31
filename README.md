# Laema

This repository is the shared source of truth for the project across the home and office desktops.

## Current status

The repository contains the expanded 2D side-scrolling orb-casting prototype plus the implemented Stage 1 tutorial flow and Final Arena/free-practice path. The user reported the current feature set verified in Godot on 2026-08-31; an exact scenario matrix, tested-tree identity, and engine-version record were not supplied.

- Project name: Laema
- Engine version: Godot 4.7
- Design status: Current prototype GDD verified
- Technical design status: Implemented architecture synchronized to `582e141`; tech-postflight is the current gate
- Implementation status: Broad user-reported validation on 2026-08-31; agent-run runtime evidence unavailable
- Last committed implementation: `582e141` (`feat: add stage one tutorial flow`)

## Prototype controls

| Action | Controller | Keyboard / mouse |
|---|---|---|
| Move and face | Left stick | WASD |
| Light attack (X) | X | Left mouse button |
| Charge and mark | R2 in the 95–100% band | — |
| Deplete marking meter | R2 in the 5–95% band | — |
| Cast | Release R2 below 5% | — |
| Select Fire | D-pad Up | 1 |
| Select Water | D-pad Down | 2 |
| Select Air | D-pad Left | 3 |
| Select Earth | D-pad Right | 4 |
| Defend | L1 | Shift |

In a debug build, backtick opens the paused Developer Portal. Its header provides Pause/Unpause, Save to JSON, status, and Close controls; it also exposes the organized General, Audio, and Combat tuning tabs.

The current tutorial begins in Stage 1 with a five-hit Fire-chain objective, transitions through the reusable stage structure into the Final Arena, and enters indefinite free practice when the final Enemy is defeated.

## Repository layout

- `docs/` — durable design, architecture, decision, and status records
- `scenes/` — Godot scenes
- `scripts/` — project scripts
- `assets/` — project assets
- `.agents/skills/` — project-specific Codex skills, when approved
- `AGENTS.md` — repository-level working guidance

## Working cadence

1. Pull the latest repository state before starting work.
2. Read `AGENTS.md`, `docs/GAME_DESIGN.md`, and `docs/TECH_ARCHITECTURE.md`.
3. Work locally with Godot and Codex.
4. Record accepted decisions and verification state in `docs/`.
5. Commit and push only after the relevant human validation gate.
