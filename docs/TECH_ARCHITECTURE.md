# Technical Design Report — Orb Casting Prototype Synchronization

Status: `READY_FOR_ULTRON_OR_DUM-E`

Repository basis: `f29c0c8` (`refactor: simplify magic and casting configuration`) plus the user-verified, uncommitted `docs/GAME_DESIGN.md` draft present when this report was generated. This report defines the approved target architecture; it does not claim that the current source implements that target.

No Godot runtime, build, compiler, or automated test was run while preparing this report.

## Scope and selected decisions

This synchronization covers the current side-scrolling prototype: five-position X/Cast chains, the shared normalized input buffer, a ten-orb FIFO queue with a five-orb marking limit, R2 RELEASE/DEPLETING/CHARGING behavior, immutable Cast commitments, generic per-school Cast damage, entity-local school-and-level feedback, and commitment-time Heat.

The Material Decision Ledger is closed:

1. **Direct generic Cast path.** `MagicComponent` resolves generic direct damage for the primary and optional secondary layers. Active prototype Casting does not read a spell loadout or dispatch school-specialty resolvers.
2. **Shared Entity feedback.** A reusable `FeedbackComponent` belongs to the base `Entity` contract. Enemy uses it now for Cast-level feedback; Player receives the same capability without gaining a new current feedback rule.
3. **Strict configuration replacement.** Obsolete spell-loadout, school-effect, discrete-Heat, and independent Air-speed fields are removed and rejected rather than retained as ignored compatibility data.
4. **Dedicated commitment-to-Heat interface.** After successful orb consumption and immutable payload storage, Magic emits one internal commitment fact carrying `commit_id` and `consumed_count`. Combat receives it synchronously and grants Heat exactly once. Promotion, launch, interruption, discard, and impact do not emit this fact.
5. **Last-in primary and single-secondary ordering.** The final consumed orb selects the primary school, whose level equals total consumed orbs. The highest-count remaining school becomes the optional secondary; a secondary tie selects the school appearing latest in the consumed sequence. Impact and feedback resolve primary first, then secondary.
6. **Pressure state owns chain preservation.** Magic reports CHARGING and DEPLETING as chain-preserving states independently of queue contents, marked count, and partial progress. CHARGING banks capacity while the queue is empty; DEPLETING remains preserving at zero progress until R2 leaves that band. Might consumes this state for timeout and between-action movement decisions.
7. **Shared configured feedback lifetime.** Both Entity scenes configure their `FeedbackComponent` from `ui.cast_feedback_duration`, default `2.0` seconds and validated from `0.1` through `20.0`. Developer Portal live tuning affects future entries only; each visible entry retains the duration captured when it was created.
8. **Initial RELEASE is side-effect-free.** The first raw-pressure sample always establishes Magic's initial pressure state. If that state is RELEASE, initialization emits no Cast request or failure. Only a later transition from CHARGING or DEPLETING into RELEASE dispatches one Cast attempt; initial CHARGING or DEPLETING may begin their ordinary state behavior immediately.

Excluded from this implementation slice: school-level spell behavior, configurable spell assignment, resolver/status cleanup, active Enemy attacks, a killable final tutorial Enemy, defence redesign, Air/Earth defence, final presentation, asset remapping, and final tuning. Existing deferred school resolvers may remain in the repository but must be unreferenced by active prototype Casting.

## Current codebase map and mismatch

```text
Player
└── CombatComponent                         thin public facade
    ├── MightComponent                     actions, chain, buffer, timing
    ├── MagicComponent                     pressure, queue, Cast commitments
    ├── HeatComponent                      attack-speed state and timer
    └── DefenceController                  current Fire/Water defence

PrototypeArena
├── SpellProjectile instances              movement and collision carrier
├── stationary Enemy entities
├── PrototypeHUD / Developer Portal
└── StageDirector                          consumes public outcomes only

Entity
├── HealthComponent / HealthResolver
├── StatusController
└── HitReaction
```

The current ownership split is suitable and remains in place. The source at `f29c0c8` is nevertheless behind the verified GDD in these material ways:

- `MagicComponent` classifies the middle R2 band as HOLD, has no ten-orb storage cap, clears the queue after a failed Cast, selects the primary by majority rather than the final consumed orb, reduces the secondary level by one, and does not guarantee the verified LIFO secondary tie-break.
- Projectile impact still looks up `spell_loadout` and dispatches Fire/Water/Air/Earth specialty resolvers.
- `CombatComponent` gains Heat from direct outgoing damage, while `HeatComponent` still uses hit gain, discrete levels, and an old inactivity model. `MagicComponent` also owns a separate timed Air speed multiplier.
- `PrototypeHUD` renders only five orb slots and still displays a discrete Heat level.
- `prototype_combat.json`, its fail-fast loader, and Developer Portal controls still require obsolete loadout and school-effect fields.
- `Entity` has no shared feedback component; Enemy currently owns status-specific display code directly.

`SpellProjectile` already carries a copied payload from commitment through collision. Preserve that model and the `SpellProjectile` name; no separate Cast-plan object is introduced.

## Target ownership

### Might, Magic, Heat, and Combat

`MightComponent` continues to own action eligibility, X/Cast timing, the one-slot earliest-request buffer, chain progression, animation/contact/launch phases, and action-caused movement locks. It decides whether a release-Cast request is normal, empowered, buffered, an endpoint Cast, or a timing failure. After an action and when evaluating timeout, Might reads Magic's pressure-state preservation contract rather than deriving preservation from queue or meter values.

`MagicComponent` owns the ten-orb FIFO queue, front-orb lifetime, five-orb marking capacity, pressure state, CHARGING and DEPLETING progression, Cast composition, immediate consumption, and immutable committed payloads. Its first raw-pressure sample establishes the initial state before transition behavior is allowed. Initial RELEASE is side-effect-free; initial CHARGING or DEPLETING may begin ordinary state behavior. Its current pressure state is the sole preservation authority: CHARGING and DEPLETING preserve the chain; RELEASE does not. This state remains authoritative even when the queue, marked count, and partial progress are all zero. Only after a successful commitment has consumed its marked prefix and stored its payload does Magic emit a dedicated internal commitment fact containing `commit_id` and `consumed_count`. Failed commitment attempts emit nothing.

`HeatComponent` remains the sole owner of attack-speed bonus points, the `100%..150%` multiplier, loss, Water-block drain, and the three-second reset timer. `CombatComponent` subscribes to Magic's dedicated commitment fact during configuration and synchronously routes `consumed_count` to Heat once. Might reads the resulting multiplier for X/Cast animation timing; Magic reads it only for CHARGING speed.

`CombatComponent` remains a thin facade. It forwards Player/HUD/Arena-facing signals and orders cross-component transactions without duplicating Might, Magic, Heat, queue, or feedback state. Generic public `CombatOutcome` events remain observational and never drive the authoritative Heat mutation.

### Entity feedback

The base `Entity` script gains a required `FeedbackComponent` reference alongside Health, Status, and HitReaction. The project uses a shared base script rather than a shared inherited Entity scene, so both Player and Enemy scenes compose their own `Feedback` child satisfying that contract; no base-scene refactor is required.

`FeedbackComponent` owns transient entity-local feedback entries and their expiration. It is separate from `StatusController`: Cast-level text is presentation evidence, not a buff, debuff, or gameplay status. The base Entity configuration injects `ui.cast_feedback_duration` into each Player and Enemy component. Every entry captures that duration at creation, so a live tuning change affects only later entries and never extends or truncates feedback already visible. The current slice publishes `<School> Lv.<N>` only on a struck Entity after that school layer successfully applies direct damage. Enemy presents those entries now. Player has the same public capability for future use, but this slice introduces no new Player-facing feedback trigger.

### Arena and projectile

`PrototypeArena` continues to instantiate projectiles and route their collision back through Combat. `SpellProjectile` owns travel, maximum distance, first-valid-target collision, and blended presentation. It carries the immutable resolved Cast payload rather than reading the live orb queue later.

The payload carries an explicit primary school and level plus one optional secondary school and level. It also retains empowered state, the primary-only damage multiplier, original instigator, direction, and the information needed to derive color weights. The final consumed orb always selects the primary school; primary level equals total consumed orbs. After excluding the primary, the highest-count remaining school becomes secondary. A secondary-count tie selects the tied school appearing latest in the consumed sequence. Other represented schools create no layer, although their orbs remain consumed and still contribute to primary level and commitment-time Heat.

Impact resolution is ordered: primary first, optional secondary second. Feedback presentation uses that same order. This preserves one deterministic sequence across payload construction, HealthEvents, immediate target refill, hit reactions, and Cast-level labels.

## Core flows and contracts

### Queue and R2 pressure

```text
X contacts an Enemy
  -> Magic attempts to append that school orb
  -> queue below 10: append and publish the new snapshot
  -> queue at 10: discard only the new orb and publish overflow feedback

R2 >= 95%
  -> CHARGING advances at the current Heat multiplier
  -> banks marking capacity up to five even when no orb is available
  -> marks the oldest available orbs covered by that capacity
  -> preserves the chain and releases movement between actions

5% <= R2 < 95%
  -> DEPLETING drains at the fixed baseline charge-step rate
  -> partial progress drains first
  -> completed boundaries unmark newest marked orbs first
  -> remains chain-preserving even after progress reaches zero
  -> releases movement between actions

R2 < 5% on state entry
  -> stops pressure-state preservation
  -> one Cast attempt only when this is a later transition
```

Before evaluating these transitions, Magic classifies the first raw-pressure sample and stores it without dispatching RELEASE behavior. This prevents a resting trigger from producing a startup Cast failure. Initial CHARGING or DEPLETING still activates its ordinary state behavior. After initialization, only a change from CHARGING or DEPLETING into RELEASE dispatches one Cast attempt.

Magic exposes one pressure-preservation result to Might. Might uses it after an animation and for idle-timeout eligibility. Queue size, marked count, and partial progress are presentation/resource values and never substitute for this state result. Active X and Cast animations remain movement-locked; Combat releases movement only between actions while Magic reports CHARGING or DEPLETING.

Only the front queue orb counts down. Consumption or expiration shifts the remaining queue forward and starts the new front orb at its full lifetime. Marking coverage transfers with the shifted queue when enough orbs remain.

A failed Cast ends the chain, unmarks all stored orbs, and resets partial marking progress to zero without removing queue contents. A Player hit removes currently marked orbs, preserves unmarked order, and resets marking progress. Orbs already consumed by a committed Cast are never refunded.

Magic publishes enough queue state for the HUD to render all ten slots, current contents, marked state, front lifetime, and marking progress. Overflow reaches the HUD through the existing Combat/Player presentation path and restarts the whole-widget flinch from rest.

### Commitment, buffering, and Heat

```text
Might accepts a normal/windowed/buffered release-Cast
  -> Magic consumes the marked FIFO prefix immediately
  -> Magic resolves the last-in primary and optional majority secondary
  -> immutable Cast payload is stored under one commitment
  -> Magic emits one internal commitment fact
  -> Combat grants Heat from its consumed_count immediately
  -> Might launches that payload at the Cast contact phase
```

A buffered Cast commits before its later promotion. The dedicated fact is emitted during commitment, not promotion, launch, interruption, discard, or impact. Those later transitions therefore cannot duplicate or revoke the Heat gain. If the action is interrupted before launch, its payload is discarded without refund; the Heat already granted at commitment remains. A projectile miss likewise does not revoke Heat.

Heat is stored as bonus percentage points above the fixed `100%` baseline. Its range is `0..50`, producing a continuous `1.00..1.50` multiplier. Each committed consumed orb grants one point. A Player hit removes five points with a zero-point floor. Three seconds after the latest qualifying Cast commitment, Heat resets fully to zero bonus points. Loss and Water-block drain do not create Heat or change its authority.

Direct X hits, projectile impact, feedback, and deferred school effects grant no Heat. There is no independent Air speed buff or Air-specific Heat source in this prototype.

### Generic projectile impact and feedback

```text
SpellProjectile contacts a valid Entity
  -> Combat routes the frozen payload to Magic
  -> resolve the primary, then the optional secondary:
       create one direct-damage HealthEvent
       use combat.casting_damage and combat.direct_impact
       apply the empowered multiplier only to the primary layer
       resolve through the target's shared HealthResolver
       if HealthResult is APPLIED and health_delta is negative:
           publish <School> Lv.<N> through target FeedbackComponent
  -> projectile disappears
```

The direct path does not read `spell_loadout`, call a school resolver, or create a status instruction. A mixed Cast intentionally produces one generic damage event and one feedback entry for the primary and optional secondary layers, in that order. A blocked, parried, invalid, zero-damage, interrupted, or missed layer produces no Cast-level display. Existing HealthEvent instigator, school, Impact, contact direction, and contact point attribution remain intact.

## Configuration, persistence, and UI

`config/prototype_combat.json`, `PrototypeConfigLoader`, and Developer Portal controls change as one fail-fast schema migration. There is no player-profile migration.

The active Heat schema is:

```yaml
heat:
  max_attack_speed_percent: 150
  attack_speed_gain_per_orb: 1
  attack_speed_loss_per_hit: 5
  heat_reset_timer: 3
```

The active shared feedback-lifetime field is:

```yaml
ui:
  cast_feedback_duration: 2.0
```

`ui.cast_feedback_duration` must be numeric from `0.1` through `20.0` seconds. It follows the same fail-fast save/load path as the existing UI duration. Player and Enemy receive the value during Entity configuration and forward later runtime-tuning changes to their Feedback components. A changed value applies to future entries only; active entries retain their captured expiry.

The fixed `100%` baseline is behavior, not configuration. Remove and reject the old Heat `max_value`, `gain_per_hit`, `inactivity_grace`, and `levels` fields. Remove and reject Air's independent `attack_speed_multiplier` and `buff_duration`.

Casting configuration retains the existing timing, pressure, projectile, and five-orb marking fields and adds a distinct ten-orb storage capacity. `max_marked_capacity` remains five; storage capacity is ten. School sections retain only fields still consumed by current X/presentation behavior. Remove and reject `spell_loadout` plus Fire DoT, Water status-level, Air chain-lightning, Earth area/Slow, and other school-effect-only fields and controls.

The Developer Portal keeps its General, Audio, and Combat organization. General → UI exposes `cast_feedback_duration` beside the existing presentation duration. Its Heat controls use the continuous fields above; school tabs may retain current presentation/motion tuning but expose no deferred spell-effect knobs.

The always-visible HUD renders ten queue slots even when empty, a gold outline on marked orbs, the marking-progress bar, and the front-orb lifetime. The overflow signal drives the whole-widget horizontal flinch. The developer Heat readout removes `Level N` and shows actual attack speed with a continuous bar. The upper-right raw R2 pressure gauge and existing developer-overlay visibility behavior remain unchanged.

## Implementation slices and validation seams

1. **Strict schema and portal:** replace configuration validation and controls first so stale school/loadout/Heat paths fail immediately instead of remaining half-active.
2. **Magic state synchronization:** implement ten-slot storage, overflow publication, side-effect-free initial RELEASE classification, DEPLETING, state-owned chain preservation, empty-queue capacity banking, failed-Cast preservation, last-in primary selection, single-secondary majority/LIFO selection, and exact secondary levels while preserving commitment and buffer timing.
3. **Generic impact and shared feedback:** add `FeedbackComponent` to the Entity contract and both concrete scenes, configure its shared future-entry lifetime through the strict UI schema, replace resolver dispatch with per-layer generic HealthEvents, and present feedback only from successful applied damage.
4. **Heat synchronization:** establish the one-shot Magic-to-Combat commitment interface, then replace discrete/hit-driven and Air-specific speed state with commitment-count gain, hit loss, reset timing, and one continuous multiplier.
5. **HUD synchronization:** render ten slots, marked outlines, overflow flinch, depletion progress, and continuous attack-speed feedback through the existing public facade path.

Human runtime validation should establish:

- all ten storage slots, overflow discard, and UI-only flinch;
- FIFO expiration, empty-queue capacity banking, five-orb marking, fixed-rate newest-first depletion, CHARGING/DEPLETING preservation at zero resources, between-action movement release, transfer, consumption, failed-Cast preservation, and marked-only Player-hit loss;
- side-effect-free initial RELEASE, active initial CHARGING/DEPLETING behavior, and exactly one Cast attempt on each later transition into RELEASE;
- unchanged X/Cast first-request buffering at baseline and high Heat;
- last-in primary selection, single-secondary majority/LIFO selection, primary-then-secondary ordering, and one generic damage result plus one feedback entry per resolved layer;
- no active school specialty, status instruction, loadout lookup, or independent Air multiplier;
- commitment-time Heat on normal and buffered Casts, retention after interruption or miss, hit loss, cap, reset, Water-block drain, and proportional X/Cast/CHARGING speed;
- Enemy Cast-level feedback and absence of feedback on misses or rejected damage;
- shared two-second feedback lifetime, `0.1–20.0` fail-fast tuning, identical Player/Enemy configuration, and future-entry-only live updates; and
- fail-fast JSON save/load plus synchronized Developer Portal and HUD presentation.

Incoming Enemy attacks and ordinary-play defence remain unverified. The fixed final tutorial Enemy objective is still not achievable with the current permanent targets and is intentionally outside this slice. The accepted Air X5 presentation-mapping waiver is likewise untouched.

Because this change crosses shared Entity composition, combat transactions, projectile payloads, configuration persistence, and HUD interfaces, Friday recommends optional Ultron `mode=tech-preflight` before implementation. The report is also sufficiently bounded for the user to hand directly to DUM-E.
