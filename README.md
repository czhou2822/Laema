# Laema

This repository is the shared source of truth for the project across the home and office desktops.

## Current status

The repository contains the expanded 2D side-scrolling orb-casting prototype plus the implemented Stage 1–6 tutorial flow and Final Arena/free-practice path. The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01; an exact scenario matrix, tested-tree identity, and engine-version record were not supplied.

- Project name: Laema
- Engine version: Godot 4.7
- Design status: Current prototype GDD verified
- Technical design status: Stage 1–6 architecture synchronized; game-facing generated/charged terminology implementation is pending before tech-postflight
- Implementation status: Complete Stage 1–6 flow user-confirmed on 2026-09-01; agent-run runtime evidence unavailable
- Last committed recovery baseline: `6b06dc2` (`checkpoint: save cross-thread recovery state`)

## Prototype controls

| Action | Controller | Keyboard / mouse |
|---|---|---|
| Move and face | Left stick | WASD |
| Light attack (X) | X | Left mouse button |
| Charge generated orbs | R2 in the 95–100% band | — |
| Deplete charging meter after the hold delay | R2 in the 5–95% band | — |
| Cast | Release R2 below 5% | — |
| Select Fire | D-pad Up | 1 |
| Select Water | D-pad Down | 2 |
| Select Air | D-pad Left | 3 |
| Select Earth | D-pad Right | 4 |
| Defend | L1 | Shift |

Backtick opens the paused Developer Portal. Its header provides Pause/Unpause, Save to JSON, status, and Close controls; it also exposes the organized General, Audio, and Combat tuning tabs.

Melee hits perform Generating and add generated orbs to the queue. Holding R2 performs Charging and makes selected generated orbs charged for the next Cast. The current tutorial runs through Stages 1–6, transitions into the Final Arena, and enters indefinite free practice when the final Enemy is defeated.

## Repository layout

- `docs/` — durable design, architecture, decision, and status records
- `scenes/` — Godot scenes
- `scripts/` — project scripts
- `tools/` — repository workflow automation
- `assets/` — project assets
- `.agents/skills/` — project-specific Codex skills, when approved
- `AGENTS.md` — repository-level working guidance

## Working cadence

1. Pull the latest repository state before starting work.
2. Read `AGENTS.md`, `docs/GAME_DESIGN.md`, and `docs/TECH_ARCHITECTURE.md`.
3. Work locally with Godot and Codex.
4. Record accepted decisions and verification state in `docs/`.
5. Commit and push only after the relevant human validation gate.
6. Use `publish live version` for the current-working-tree Web snapshot under `live/game`; the editable pitch remains under `docs/presentation/decks/laema-html-draft` and its published copy under `live/pitch`.
