# Project records

This directory is intended to hold the durable project state that should travel with the repository.

- `GAME_DESIGN.md` — accepted gameplay and player-experience decisions
- `TECH_ARCHITECTURE.md` — accepted technical representation and ownership decisions
- `DECISIONS.md` — decision history and rationale
- `IMPLEMENTATION_STATUS.md` — current implementation state and verification notes
- `checkpoints/` — dated cross-thread working snapshots; these preserve design state without automatically promoting proposals into canonical documents

## Checkpoint convention

When the user says “checkpoint,” sweep all current project threads and durable project records, reconcile every update since the previous checkpoint, and write a dated snapshot preserving decisions, proposals, rejected directions, constraints, and open questions. Keep checkpoint records separate from the approved GDD, technical architecture, and implementation verification records.
