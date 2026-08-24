# Laema

This repository is the shared source of truth for the project across the home and office desktops.

## Current status

The repository contains the expanded 2D top-down combat prototype source. The user reported the current first draft as validated in Godot on 2026-08-24.

- Project name: Laema
- Engine version: Godot 4.7
- Design status: Current prototype GDD verified
- Technical design status: Current architecture recorded and preflight-cleared with waivers
- Implementation status: First-draft prototype user-validated
- Committed prototype baseline: `e543a43`

## Prototype controls

| Action | Controller | Keyboard / mouse |
|---|---|---|
| Move and face | Left stick | WASD |
| Light attack (X) | X | Left mouse button |
| Finisher (Y) | Y | Right mouse button |
| Select Fire | D-pad Up | 1 |
| Select Water | D-pad Down | 2 |
| Select Air placeholder | D-pad Left | 3 |
| Select Earth placeholder | D-pad Right | 4 |
| Defend | Left shoulder | Shift |

In a debug build, backtick opens the paused developer overlay. It exposes validated live tuning, explicit Save-to-JSON, and the attack-hitbox display toggle.

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
