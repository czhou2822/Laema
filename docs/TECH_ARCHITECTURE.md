# Technical Design Report — Might/Magic Combat Restructure and Tutorial Director

Status: `IMPLEMENTED_AWAITING_USER_VALIDATION`

Revision: U-001 through U-004 incorporated; final Ultron `mode=tech-preflight`: `TECH_PREFLIGHT_CLEAR`.

## Scope

Preserve verified GDD behavior while adding outside-combat school-level spell assignments, shared X/Cast buffering, immediate no-refund Cast commitment, marked-only orb loss on Player hit, authoritative Heat under Combat, a success-gated tutorial, and final completion on Enemy death.

Excluded: fractional/multiple orb contributions, new spells/balance/unlocks/profile persistence, defence redesign, final intermediate objectives, final presentation, and final enemy behavior.

## Implemented source surface

The uncommitted implementation candidate uses `scripts/combat/combat_controller.gd` as the stable `CombatComponent` facade, with `Might`, `Magic`, `Heat`, and Defence composed below its Player-scene node. The former standalone orb controller is superseded by `MagicComponent`; retained orb and combat trace points remain with their new owners.

`config/prototype_combat.json` carries the default `(school, level)` mappings and the current final-only tutorial objective. The configuration loader validates the fixed defaults and requires the final objective to match the final Enemy's public defeated fact. No profile persistence or extra spell content is represented.

`PrototypeArena` connects public Combat and Enemy outcomes to its `StageDirector`; the Director owns no combat state. The three existing practice targets still refill, while the distinct `FinalEnemy` does not refill and publishes `final_enemy_defeated` exactly once.

## Ownership

```text
Player
├── CombatComponent
│   ├── MightComponent
│   ├── MagicComponent
│   └── HeatComponent
└── outside-combat loadout data

PrototypeArena
├── practice targets / final enemy
└── StageDirector
```

CombatComponent is a thin facade: it owns/configures the three children, connects their public interfaces, orders cross-domain transactions, aggregates immutable outcomes, and preserves Player/HUD/Arena-facing signals. It stores no duplicate Might, Magic, or Heat state.

Might owns input eligibility, melee/casting action state, the one shared X/Cast first-request buffer, chain position/switching, animation/contact/launch/window timing, pending/current actions, and action-caused movement locks.

Magic owns orb queue lifetime/marking/depletion, Cast commitment/consumption, marked-only owner-hit removal, composition, configured spell lookup, committed payloads, and spell/projectile execution.

Heat owns the sole mutable Heat value, inactivity/expiration, levels/multiplier, gain/drain, and publication. Might reads its multiplier for action speed; Magic reads it for marking; DEPLETING remains fixed-time; Defence drains only through Heat.

Outside-combat loadout data maps `(school, casting level) -> equipped spell`. Current fixed effects are defaults; persistence is excluded.

## Contracts

### Cast commitment

```text
R2 enters CAST
  -> Might performs timing and shared-buffer arbitration
  -> Magic immediately consumes marked orbs
  -> Magic freezes composition, levels, equipped spell, multiplier,
     direction, and instigator
  -> Might later launches that committed payload exactly once
```

Buffered Casts commit before promotion. Interruption discards payloads without refund or execution. Failed Casts remain separate full-queue clear transactions.

### Player hit

An authoritative Player-hit outcome orders: Might cancels actions/buffer/animation/chain; committed payload is discarded without refund; Magic removes marked orbs only and preserves unmarked order/expiration; Defence cancels; hit reaction and movement lock continue. Failed Cast clearing never reuses this marked-only path.

### Outcomes and tutorial

After authoritative transitions, owners publish immutable tutorial-agnostic facts. Might publishes action, chain, buffer, and launch facts; Magic publishes pressure, commitment, launch/failure/interruption, impact, and orb facts; Arena/Entity publish encounter activation, practice refill, zero Health, and final Enemy defeat facts.

StageDirector is Arena-owned. It consumes only public facts, owns ordered objective data and one-time advancement, ignores unrelated actions, emits configured `No` feedback only for defined failed attempts, and completes only on final Enemy defeat. It never reads raw input, private state, animation internals, orb queues, or debug traces.

Practice targets retain refill. The final Enemy has a distinct authoritative defeated outcome.

## Validation

Human validation must confirm unchanged X/Cast buffering and Heat behavior; immediate frozen no-refund Casts with no double consumption; marked-only Player-hit loss; immutable one-per-transition outcomes; Director freedom/No/single advancement; practice refill; and final Enemy completion.

No Godot, build, compiler, or automated test was run by the agent. Runtime validation remains required.
