# Laema changelist — 2026-08-25 side-scrolling orb-casting delta

## Scope and authorization

This changelist accompanies [2026-08-25-save.md](../checkpoints/2026-08-25-save.md). The user explicitly authorized the full current scope to be staged, committed on `main`, and pushed to `origin/main` after the checkpoint and changelist were prepared.

- Base commit: `2178fbb feat: expand elemental combat and prototype presentation`
- Target branch: `main`
- Remote: `origin/main`
- Validation: user-reported expanded implementation validation exists; no agent-run Godot/build/compiler/test evidence.

## Modified tracked files

| File | Review scope |
|---|---|
| `README.md` | Side-scrolling/orb-casting project description and controls |
| `assets/README.md` | Current asset/audio provenance and scope |
| `config/prototype_combat.json` | R2 bands, orb/casting, school, audio, and tuning data |
| `docs/DECISIONS.md` | Current design and workflow decisions |
| `docs/GAME_DESIGN.md` | Side-scrolling orb-casting prototype contract |
| `docs/IMPLEMENTATION_STATUS.md` | Expanded implementation and user-reported validation status |
| `docs/TECH_ARCHITECTURE.md` | Updated data flow, orb/casting, projectile, audio, portal, and validation seams |
| `project.godot` | Current project/input/audio configuration |
| `scenes/README.md` | Scene inventory |
| `scenes/combat/spell_projectile.tscn` | Projectile scene wiring |
| `scenes/player/player.tscn` | Player casting/audio/presentation wiring |
| `scenes/prototype_arena.tscn` | Side-scrolling arena, targets, HUD, audio, and camera layout |
| `scripts/README.md` | Script inventory |
| `scripts/combat/combat_controller.gd` | X/Cast chain, pressure, buffer, school, projectile, and defence coordination |
| `scripts/combat/orb_casting_controller.gd` | Orb queue, marking, depletion, consumption, and Cast composition |
| `scripts/config/prototype_config_loader.gd` | R2/orb/Cast/audio configuration validation |
| `scripts/prototype/prototype_arena.gd` | Arena-owned setup, audio buses, projectile impact, and UI composition |
| `scripts/ui/developer_overlay.gd` | Developer Portal controls, tabs, toggles, audio, and save behavior |
| `scripts/ui/prototype_hud.gd` | Pressure, orb, Cast, school, and validation feedback |

Git reports **19 modified tracked files**: 998 insertions and 593 deletions before this record was added.

## Untracked file

- `config/prototype_audio_bus_layout.tres` — Ambient, SFX, and BGM bus layout used by the prototype audio pass.

## Functional groups

- **Movement/arena:** grounded side-scrolling movement, gravity, flat floor, horizontal camera, three stationary targets.
- **Combat:** five-position X/Cast chain, R2 pressure state machine, shared input buffer, orb FIFO, mixed-school Cast, and projectile launch/impact.
- **Schools:** Fire, Water, Air, and Earth X/casting packages with current prototype status/effect behavior.
- **Presentation:** 20 X flipbooks, shared Cast/idle/walk sheets, school mapping, projectile color blend, HUD, orb progress, and Developer Portal.
- **Audio:** 42 curated audio files from the external CC0 library, bus routing, school attack/cast cues, orb/casting cues, projectile travel/impact, ambience, music, failure, and guard warning.
- **Documentation:** current GDD, technical architecture, implementation status, README records, and decisions.

## Review concerns

- The side-scrolling orb-casting design supersedes the earlier top-down presentation for this current prototype, while the older dated checkpoints remain historical records.
- The broader Decomposition/Reintegration foundation has not yet been explicitly reconciled with the orb-casting design.
- Incoming Enemy attacks and all ordinary-play incoming-defence scenarios remain deferred.
- Final art, final UI, final tuning, complete enemy content, and exact scenario-by-scenario validation remain open.
- External asset/audio entitlement and audition records remain documented; this changelist does not claim final art or audio approval.
- The source and docs are being committed under explicit user authorization; no agent-run runtime/test evidence is added.
