# Scripts

- `prototype/` — arena startup, configuration distribution, input bindings, and signal wiring.
- `config/` — fail-fast JSON configuration loading and validation.
- `entities/` — shared Entity, HealthEvent/Result, HealthResolver, Health, and hit reaction.
- `player/` — Player composition and movement.
- `enemy/` — permanent Enemy health, status, reaction, and VFX presentation.
- `combat/` — Combat facade, Might/Magic/Heat/defence components, input-combo, and SpellProjectile. Magic resolves current Casts as generic direct damage with school-and-level feedback. The retained four-school resolver modules are dormant; Player does not construct or inject them.
- `status/` — Buff/Debuff lifetimes, Water priority, and periodic HealthEvents.
- `ui/` — always-visible prototype HUD and paused Developer Portal presentation.

The user's 2026-08-25 prototype validation report is historical. Current candidate scope and revision-specific validation limits are recorded in [Implementation Status](../docs/IMPLEMENTATION_STATUS.md); that report does not validate later changes.
