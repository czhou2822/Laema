# Laema

This repository is the shared source of truth for the project across the home and office desktops.

## Current status

The repository contains the 2D side-scrolling orb-casting prototype, Stage 1–7
tutorial progression and Final Arena/free-practice path, plus the development Gym.
Current Player/CombatEnemy Settings are shared across rooms. Native Animations
own sprites, hitbox curves, melee active bounds and Cast launch timing.

- Project name: Laema
- Engine target: Godot 4.7; scoped checks recorded elsewhere used their stated engine versions.
- Design and implementation: see [GAME_DESIGN.md](docs/GAME_DESIGN.md), [TECH_ARCHITECTURE.md](docs/TECH_ARCHITECTURE.md) and [IMPLEMENTATION_STATUS.md](docs/IMPLEMENTATION_STATUS.md).
- Validation: the September 1 Stage 1–6 user report was broad, without a scenario matrix, tested-tree identity or engine-version record. Later reports/checks retain their own scope; current candidates do not have blanket human acceptance or Web-export clearance.
- Historical Stage 1–6 recovery checkpoint: `6b06dc2`; [checkpoint history](docs/checkpoints/) preserves later saves and bindings.
- Open documentation conflicts: Heat timer refresh triggers and reaction-duration values remain reserved for discussion in the GDD/TDR.

## Prototype controls

| Action | Controller | Keyboard / mouse |
|---|---|---|
| Move and face | Left stick | A / D |
| Light attack (X) | X | Left mouse button |
| Charge generated orbs | L2 in the 95–100% band | Hold right mouse button |
| Deplete charging meter after the hold delay | L2 in the 5–95% band | — |
| Cast | Release L2 below 5% | Release right mouse button |
| Select Fire | D-pad Up | 1 |
| Select Water | D-pad Down | 2 |
| Select Air | D-pad Left | 3 |
| Select Earth | D-pad Right | 4 |
| Defend | L1 | Shift |

Backtick opens the paused Developer Portal. Its header provides Pause/Unpause, Save Tuning, status, and Close controls; it also exposes the organized General, Audio, and Combat tuning tabs.

Melee hits perform Generating and add generated orbs to the queue. Holding L2 performs Charging and makes selected generated orbs charged for the next Cast. The current tutorial runs through Stages 1–7, transitions into the Final Arena, and enters indefinite free practice when the final Enemy is defeated.

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
