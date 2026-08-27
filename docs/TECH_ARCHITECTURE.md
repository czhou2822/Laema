# Technical Design Report — Might/Magic Combat Restructure and Tutorial Director

Status: `READY_FOR_ULTRON_OR_DUM-E`

Revision: U-001 through U-004 incorporated; the accepted Heat configuration/UI finding and accepted attack-speed-composition finding from later Ultron `mode=tech-preflight` reviews are incorporated. A fresh preflight is required before implementation.

## Scope

Preserve verified GDD behavior while adding outside-combat school-level spell assignments, shared X/Cast buffering, immediate no-refund Cast commitment, marked-only orb loss on Player hit, authoritative Heat under Combat, simplified mixed-school levels, an orb-consumption- and Air-spell-driven attack-speed measure, a success-gated tutorial, and final completion on Enemy death.

Excluded: fractional/multiple orb contributions, new spells/balance/unlocks/profile persistence, defence redesign, final intermediate objectives, final presentation, and final enemy behavior.

## Current source surface and mismatch

The committed source at `e26b00f` uses `scripts/combat/combat_controller.gd` as the stable `CombatComponent` facade, with `Might`, `Magic`, `Heat`, and Defence composed below its Player-scene node. The former standalone orb controller is superseded by `MagicComponent`; retained orb and combat trace points remain with their new owners.

The committed source does not yet implement the newly verified rules. `MagicComponent` still reduces secondary casting level by one. `CombatComponent` still adds Heat from direct outgoing Health results, while `HeatComponent` still uses `gain_per_hit` plus configured level thresholds. Air level 1 still stores and applies a separate timed multiplier through `MagicComponent`, `MightComponent`, `air.attack_speed_multiplier`, and `air.buff_duration`. These paths are now stale and require DUM-E synchronization.

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

Heat owns the sole mutable attack-speed bonus, reset timing, multiplier, gain/loss operations, and publication. Its bonus ranges from zero to fifty percentage points, producing `100%` through `150%` attack speed. Might reads its multiplier for action speed; Magic reads it for marking; DEPLETING remains fixed-time; Defence drains only through Heat.

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

### Mixed-school resolution

Magic retains the existing primary selection: the school with the greatest consumed count is primary, with the final consumed orb breaking ties. Primary casting level equals total consumed orbs. Every represented non-primary school resolves at its own consumed-orb count, without subtracting one. Thus `FFEEE` resolves Earth level 5 and Fire level 2.

### Attack speed and Heat

Heat represents attack-speed bonus percentage points above the fixed `100%` baseline. Its authoritative range is `0..50`, mapped continuously to a `1.00..1.50` attack-speed multiplier.

When Magic commits a Cast and consumes `N` marked orbs, it reports that committed consumed count to Combat. Combat routes exactly one gain of `N` attack-speed percentage points to Heat. The gain occurs at commitment, so an interrupted no-refund Cast retains the attack speed already earned from its consumed orbs.

When an Air level-1 spell effect resolves on a valid projectile impact, Magic reports the configured ten-point Air Heat gain to Combat, and Combat routes it once to Heat. This is not a separate multiplier or timed Magic state. It uses Heat's ordinary cap, loss, Water-block drain, and Heat Reset Timer, and it restarts that timer as a qualifying gain. A miss or interrupted pre-launch Cast receives only the earlier orb-consumption gain and no Air-effect gain. The gains stack: at `105%`, a one-orb Air level-1 Cast reaches `106%` at commitment and `116%` on impact.

Orb consumption and Air level 1 are the only current gain sources. Melee hits, other spell impacts, DoT, status, and HoT results do not mutate Heat.

An authoritative Player-hit outcome routes a loss of five attack-speed percentage points to Heat in the same cross-domain transaction, floored at zero bonus / `100%` attack speed. The Heat Reset Timer restarts on each qualifying orb-consumption gain; when its configured duration expires without another qualifying gain, Heat resets fully to zero bonus / `100%` attack speed. Loss operations do not restart the timer. Existing Water-block drain continues through Heat's bounded loss operation. Future spells that add Heat directly remain deferred and have no current implementation contract.

Heat publishes the resulting attack-speed multiplier once per authoritative mutation. Combat forwards it to Might for X/Cast animation speed, Magic for CHARGING speed, and Player/HUD/debug presentation. DEPLETING remains fixed-time and ignores the multiplier.

#### Configuration replacement

The Heat configuration is a strict replacement of the prototype's discrete-level schema:

```yaml
heat:
  max_attack_speed_percent: 150
  attack_speed_gain_per_orb: 1
  attack_speed_loss_per_hit: 5
  heat_reset_timer: 3

air:
  heat_gain: 10
```

`max_attack_speed_percent` must be numeric and greater than `100`; its default is `150`. `attack_speed_gain_per_orb` must be numeric and greater than `0`; its default is `1`. `attack_speed_loss_per_hit` must be numeric and at least `0`; its default is `5`. `heat_reset_timer` must be numeric and at least `0`; its default is `3` seconds. The `100%` baseline is fixed behavior and is not stored as configuration.

`air.heat_gain` must be numeric and at least `0`; its default is `10`. It replaces `air.attack_speed_multiplier` and `air.buff_duration`, which are removed and rejected with the obsolete Heat fields. No independent Air attack-speed state, timer, multiplier, or publication remains.

The repository configuration and fail-fast loader change together. The obsolete Heat `max_value`, `gain_per_hit`, `inactivity_grace`, and `levels` fields and obsolete Air `attack_speed_multiplier` and `buff_duration` fields are removed and rejected rather than migrated. No shipped player-profile format depends on this prototype configuration, so legacy compatibility and profile migration are excluded.

The Developer Portal replaces its old Heat-value and discrete-level controls with the four Heat fields above, replaces the two obsolete Air controls with `air.heat_gain`, and applies the same validation ranges. The HUD removes `Level N`; its Heat bar represents zero through `max_attack_speed_percent - 100` attack-speed bonus points, and its label displays the actual attack speed, for example `105% attack speed`. Heat's public change signal carries attack-speed bonus points and the attack-speed multiplier, with no discrete level.

### Implementation slices

- Establish Heat as the only attack-speed state and multiplier across `HeatComponent`, `CombatComponent`, `MightComponent`, and `MagicComponent`; remove Magic's independent Air multiplier, timer, and action-speed publication.
- Route committed orb count and resolved Air level-1 effect gain through Combat to Heat exactly once at their distinct authoritative transitions.
- Replace the persisted schema and fail-fast validation in `config/prototype_combat.json` and `PrototypeConfigLoader`, including rejection of the obsolete Heat and Air fields.
- Synchronize Developer Portal controls and the Heat signal relay through Player/Arena to the continuous HUD bar and actual attack-speed label.

### Player hit

An authoritative Player-hit outcome orders: Might cancels actions/buffer/animation/chain; committed payload is discarded without refund; Magic removes marked orbs only and preserves unmarked order/expiration; Defence cancels; hit reaction and movement lock continue. Failed Cast clearing never reuses this marked-only path.

### Outcomes and tutorial

After authoritative transitions, owners publish immutable tutorial-agnostic facts. Might publishes action, chain, buffer, and launch facts; Magic publishes pressure, commitment, launch/failure/interruption, impact, and orb facts; Arena/Entity publish encounter activation, practice refill, zero Health, and final Enemy defeat facts.

StageDirector is Arena-owned. It consumes only public facts, owns ordered objective data and one-time advancement, ignores unrelated actions, emits configured `No` feedback only for defined failed attempts, and completes only on final Enemy defeat. It never reads raw input, private state, animation internals, orb queues, or debug traces.

Practice targets retain refill. The final Enemy has a distinct authoritative defeated outcome.

## Validation

Human validation must confirm unchanged X/Cast buffering; immediate frozen no-refund Casts with no double consumption; simplified primary/secondary levels; `+1` attack-speed point per committed consumed orb; `+10` on resolved Air level-1 impact with no separate timed multiplier; stacked `105% -> 106% -> 116%` sequencing; no attack-speed gain from melee, other spell impacts, DoT, status, or HoT; no Air gain on miss or pre-launch interruption; `-5` points on Player hit with a `100%` floor; `150%` cap; timer restart from either qualifying gain and full reset after the three-second Heat Reset Timer; unchanged Water-block drain; proportional X/Cast/CHARGING acceleration with fixed-time DEPLETING; updated configuration rejection and Developer Portal controls; continuous HUD bar and actual attack-speed label; marked-only Player-hit orb loss; immutable one-per-transition outcomes; Director freedom/No/single advancement; practice refill; and final Enemy completion.

No Godot, build, compiler, or automated test was run by the agent. Runtime validation remains required.
