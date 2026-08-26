# Scripts

- `prototype/` — arena startup, configuration distribution, input bindings, and signal wiring.
- `config/` — fail-fast JSON configuration loading and validation.
- `entities/` — shared Entity, HealthEvent/Result, HealthResolver, Health, and hit reaction.
- `player/` — Player composition and movement.
- `enemy/` — permanent Enemy health, status, reaction, and VFX presentation.
- `combat/` — Combat facade, Might/Magic/Heat/defence components, input-combo, SpellProjectile, and four-school resolvers.
- `status/` — Buff/Debuff lifetimes, Water priority, and periodic HealthEvents.
- `ui/` — always-visible prototype HUD and paused Developer Portal presentation.

The user reported the expanded prototype as validated in Godot on 2026-08-25. Agent-run Godot, build, compiler, and automated-test evidence remains unavailable.
