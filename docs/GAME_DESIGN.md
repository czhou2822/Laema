# Laema Side-Scrolling Orb Casting Prototype

Status: User-verified gameplay contract for the current prototype.

## Overview

This prototype tests the existing four-school combat system in a 2D side-scrolling space. Laema builds a temporary queue of elemental orbs through successful X attacks, charges and depletes Casting with R2, and triggers normal or empowered school spells through full-pressure timing and resource composition.

The primary experience remains deliberate combat mastery. The player should learn to maintain an attack chain, build the desired elemental sequence, charge while continuing to attack, and trigger Casting at an intentional pressure moment.

## Prototype Scope

**Included:** grounded left/right movement, gravity, one continuous flat floor, horizontal camera following, functional Fire/Water/Air/Earth X attacks and casting specialties, school switching, a five-position attack-and-casting chain, temporary elemental orbs, R2 charging, normal and empowered casting, casting projectiles, Heat, Fire parrying, Water blocking, hit reactions, combat UI, and three non-attacking Enemy targets.

**Excluded:** jumping, vertical traversal controls, Air and Earth defence, active Enemy behavior and attacks, final level design, final art and UI assets, complete enemy content, and final numerical tuning.

## Controls and Movement

| Input | Action |
|---|---|
| Left stick | Move left or right and face that direction |
| X | Perform the active school’s attack |
| R2 held in the 35–65% charge band | Charge and mark orbs |
| R2 entering the 90–100% CAST band | Trigger Casting once on entry |
| R2 held in the 0–10% lower endpoint deadzone | Deplete the marking meter |
| D-pad Up | Select Fire |
| D-pad Down | Select Water |
| D-pad Left | Select Air |
| D-pad Right | Select Earth |
| L1 | Use the active school’s available defence |

Laema is affected by gravity and remains grounded on solid collision. The first test level is one continuous flat floor. The camera follows Laema horizontally while preserving fixed vertical framing.

Active X and Cast animations lock player-controlled movement. When CHARGING or DEPLETING preserves a chain between actions, Laema may move horizontally while retaining the chain and its orbs. Facing is horizontal; attacks and casting projectiles use Laema’s current facing direction.

## Schools and Character Presentation

All four schools have functional X attacks and casting specialties. Active-school selection changes the displayed prototype character:

| School | Character | Casting specialty |
|---|---|---|
| Fire | Fighter | Stack damage over time |
| Water | Prototype Saber Fighter | Wet, Slow, and Frozen control |
| Air | Shinobi | Attack-speed buff and chain lightning |
| Earth | Samurai | Area damage and Slow |

This character mapping is prototype presentation only. It does not define Laema’s final appearance.

### Prototype X-Attack Animation Allocation

The five X positions use the following accepted Craftpix prototype flipbooks:

| School | Source family | X1 | X2 | X3 | X4 | X5 |
|---|---|---|---|---|---|---|
| Fire | Free Prototype Character Pack 2 | Punch 1 | Punch 2 | Fire Kick | Explosive Strike | Power Strike |
| Water | Medieval Character Pack 6 | Attack 1 | Attack 2 | Attack 3 | Enchanted Attack 1 | Enchanted Attack 2 |
| Air | Prototype Hero Pack 3 | Aerial Strike | Double Strike | Energy Wave | Wind Power | Weapon 1 |
| Earth | Medieval Character Pack 5 | Attack 1 | Attack 2 | Attack 3 | Power Punch 1 | Power Punch 2 |

All 20 sheets use compatible 128×128 cells and the shared prototype-character baseline. Water and Earth use matching Idle and Walk sheets from their respective source families. Fire and Air use the shared Medieval Character Pack 6 locomotion shell. Their visible weapon may therefore change when transitioning between locomotion and attack animations; this discontinuity is accepted for the prototype.

All four schools share `Casting Spell.png` from Free Prototype Character Pack 2 as the prototype casting animation. It contains 10 frames using compatible 128×128 cells and the shared feet baseline. Final projectile art remains open.

The existing one-switch chain rule remains: a chain may use at most two schools, and only one school switch may occur during the chain. Switching consumes no progression position and does not clear the chain.

## Five-Position Chain

A chain contains five progression positions.

- A successful or missed X attack occupies one position.
- X creates an orb only when it physically hits an Enemy.
- A successful mid-chain Cast occupies one position and creates no orb.
- Cast may chain directly into another Cast when the next attempt succeeds.
- After position 5, the player may perform one optional endpoint Cast.
- The optional endpoint Cast after position 5 ends the chain.
- When a chain ends or fails, all remaining orbs are cleared.

Examples:

```text
X → X → X → X → X
X → X → Cast → X → X
X → X → X → X → X → Cast
X → X → Cast → X → Cast
X → Cast → X → X → X → Cast
```

In `X1 → X2 → Cast → X → X`, the Cast occupies position 3; the following attacks use the X4 and X5 presentations.

Every attack and casting animation has a chaining window. Once that window opens, it remains valid through the end of the animation. Inputs before the applicable buffer zone are rushed inputs.

For this prototype, X attacks and Casting use the same base animation duration and normalized chaining-window timing. Heat accelerates both through the same current speed multiplier.

X presses and full-press Cast requests use one shared normalized pre-window buffer. The buffer width is 20% of normalized action duration. With `combat.input_window_start = 0.48` and `combat.x_buffer_width = 0.20`, the initial buffer zone is `0.28 <= progress < 0.48`. One valid X or full-press Cast request may occupy the buffer slot; later requests in that same buffer period are ignored. The buffer applies while the current chainable animation is X or Cast, and does not apply to school switching.

An X buffer stores one school-and-direction action intention without advancing the chain or UI, then promotes it through the normal X acceptance path when the chaining window opens. A buffered full press requires marked orbs, consumes them immediately, resolves and freezes the Cast composition and existing Cast fields, then promotes the resolved Cast as the appropriate empowered mid-chain or endpoint Cast when the chaining window opens. Early X remains ignored; an early full press before the buffer without a valid request remains a rushed Cast failure. Buffer state does not repeat from held input and clears on interruption, hit reaction, failed Cast, chain completion/reset, or return to `READY`.

## Orb Queue

Every X attack that hits an Enemy creates one orb matching the attack’s school:

| School | Orb |
|---|---|
| Fire | F |
| Water | W |
| Air | A |
| Earth | E |

Orbs form a first-in, first-out queue.

- Only the oldest orb counts down toward expiration.
- Its lifetime is seven seconds.
- A newly spawned orb is a solid school-colored disc (Fire is red). As its lifetime falls, the filled region interpolates from 100% to 75%, 50%, 25%, and empty by shrinking from the right edge toward the left; the unfilled region is transparent.
- Later orbs retain their full lifetime while another orb remains ahead of them.
- When the oldest orb expires or is consumed, the next orb immediately begins its full seven-second lifetime.
- Unconsumed orbs remain after a successful mid-chain Cast.
- When a chain times out after a completed action without a follow-up, the chain state ends but unconsumed orbs remain while Laema is idle or moving and continue their FIFO expiration.
- A failed Cast clears every remaining orb. Normal and endpoint Cast completion retain their existing clear-after-consumption behavior.

Example:

```text
Air X hit → Air X hit → switch Water → Water X hit → Water X hit
Orb queue: A A W W
```

## R2 Pressure and Charging

R2 pressure has three semantic states. Values between the configured bands retain the previous semantic state, and state changes are transition-based:

- `0–10%`: **DEPLETING**; marking capacity and partial progress drain.
- `35–65%`: **CHARGING**; available orb capacity charges and marks in FIFO order.
- `90–100%`: **CAST**; one Cast attempt occurs on entry.

CHARGING may begin at any time, with or without available orbs, and continues while Laema attacks or performs casting animations. Charging capacity marks the oldest available orbs in first-in, first-out order.

- Entering CHARGING starts or resumes marking progress.
- Entering DEPLETING drains the continuous marking meter at the baseline `charge_step_duration` rate, without Heat scaling or queue-orb removal.
- Entering CAST triggers one normal or empowered Cast attempt; holding at full pressure does not repeat it.
- Releasing R2 no longer triggers Casting.
- The charge band center and tolerance are tunable. The prototype begins with a ±15% band, so 35–65% pressure counts as CHARGING.
- For the prototype, 0–10% is DEPLETING and 90–100% is CAST; no exact 0% or 100% reading is required.
- Casting capacity increases by one marked orb every nominal 0.5 seconds while CHARGING.
- At baseline speed, the first orb becomes marked after 0.5 seconds.
- At baseline speed, maximum capacity is five marked orbs after 2.5 seconds.
- Holding longer leaves capacity at five.
- CHARGING uses the current Heat multiplier. At multiplier `M`, effective step duration is `0.5 / M` seconds.
- DEPLETING uses fixed real time at the baseline `0.5` second step duration. Five marked orbs deplete in 2.5 seconds, independent of Heat.
- Partial DEPLETING progress is continuous. Crossing a completed-mark boundary unmarks the most recently marked orb first.
- DEPLETING never consumes or removes queue orbs.
- CHARGING and DEPLETING preserve the active chain and its orb queue beyond the normal idle timeout.
- CHARGING and DEPLETING do not keep movement locked between active X or Cast animations.
- Marking does not pause expiration. If a marked oldest orb expires, the existing marking coverage transfers forward with the shifted queue, preserving the marked count when enough orbs remain.
- When Laema is hit, every marked orb is removed. Unmarked orbs remain in the queue and continue their normal expiration countdown.
- Entering CAST consumes:

```text
all currently marked orbs
```

Consumption is first-in, first-out. For example, two marked orbs in `A A W W` consume `A A`.

Marked orbs are consumed immediately on CAST entry, including a buffered full press before the promoted Cast animation begins. If Casting is interrupted before projectile launch, those orbs are not refunded.

## Casting Outcomes

### Normal Cast

Entering CAST while Laema is idle performs a normal Cast when at least one orb is marked. A normal Cast ends the current chain after consuming its marked orbs.

### Empowered Cast

Entering CAST during an attack or casting animation’s valid buffer/window performs an empowered Cast.

- A mid-chain empowered Cast occupies the next progression position and may continue chaining.
- An empowered Cast triggered after position 5 is the optional endpoint Cast and ends the chain.
- Empowered Casting displays a distinct VFX on Laema; a visible dot is sufficient for the prototype.
- Only the primary school’s direct damage receives the empowered multiplier.
- Empowered primary direct damage is `1.3×` the corresponding normal-cast damage.
- Secondary casting damage and other specialty behavior remain unchanged.

### Failed Cast

Casting fails when any of the following is true:

- Full press is triggered before any orb is marked.
- Full press is triggered during an active attack or casting animation before its buffer zone opens.

A failed Cast:

- cancels the active attack or casting animation;
- produces no projectile or spell effect;
- ends the chain and clears its orbs; and
- applies the existing level-1 light flinch and recovery to Laema.

Entering CAST while idle is not a timing failure. It succeeds when at least one orb is marked.

## Mixed-School Resolution

The consumed orb composition determines the spell output.

1. The school with the greatest consumed-orb count becomes the primary school.
2. If two schools tie, the school of the final consumed orb wins the tie.
3. Primary casting level equals the total number of consumed orbs.
4. Every secondary school resolves at its own consumed-orb count.
5. A school with zero consumed orbs produces no casting.

Example:

```text
Consumed queue: A A W W
Primary: Water level 4
Secondary: Air level 2

Consumed queue: F F E E E
Primary: Earth level 5
Secondary: Fire level 2
```

The primary and secondary results reuse their school’s current specialty behavior.

### Future Configurable Spell Mapping

For the final product, the player configures outside combat which spell is assigned to each school and casting level, choosing from the spells available for that slot. Casting invocation remains unchanged during combat; when a school and casting level resolve, the configured spell determines the resulting behavior.

The prototype's fixed school-level casting outcomes remain the current behavior. The available spell lists and individual spell behaviors remain open.

## School Casting

### Fire

Fire casting deals direct damage and applies one independent DoT stack per resolved Fire level. DoT ticks use Impact 0, cause no flinch, and add no Heat.

### Water

Water casting deals direct damage and applies the resolved Water control effect:

| Water level | Effect |
|---|---|
| 1 | Wet for 1 second |
| 2 | Wet for 2 seconds |
| 3 | 20% Slow for 2 seconds |
| 4 | 40% Slow for 2.5 seconds |
| 5 | Frozen for 1 second |

Wet remains a future Air-lightning interaction and has no current modifier. Frozen prevents movement and actions. Water statuses remain mutually exclusive: higher level replaces lower, equal level refreshes duration, and lower level is ignored while direct damage still resolves.

### Air

Air level 1 adds ten attack-speed percentage points directly to Heat when its spell effect resolves. It has no separate timed attack-speed multiplier; the added Heat follows the ordinary Heat cap, loss, drain, and reset rules. Air levels 2 through 5 release chain lightning whose direct damage and chained-target count scale with level. Exact final values remain tunable.

### Earth

Earth casting deals area damage and applies Slow. The prototype starts with:

| Earth level | Area radius | Slow | Duration |
|---|---:|---:|---:|
| 1 | 28 | 15% | 1.5 seconds |
| 2 | 38 | 25% | 2.0 seconds |
| 3 | 48 | 40% | 2.5 seconds |
| 4 | 58 | 40% | 3.0 seconds |
| 5 | 68 | 40% | 4.0 seconds |

Area continues increasing by 10 per level. Slow strength reaches 40% at level 3 and remains 40% for levels 4 and 5 while duration continues increasing. These remain prototype tuning values rather than final balance.

## Casting Projectile

Every successful Cast begins a casting animation. The projectile launches later at the same normalized phase used by X attacks for contact.

- One combined projectile carries the primary and any secondary school effects.
- It travels in Laema’s facing direction.
- It travels approximately 50% of the visible screen width in one second.
- It disappears on the first valid Enemy hit or after reaching maximum distance.
- On hit, it resolves all included direct damage and specialty effects.
- A miss produces no damage, status, or Heat.

The projectile blends its school colors according to resolved casting levels.

Example:

```text
Air level 5 + Fire level 2
= 5/7 Air color + 2/7 Fire color
```

## Defence

Only Fire and Water defence are functional in this prototype.

### Water Blocking

- Blocking remains active while L1 is held and guard remains intact.
- Blocking nullifies incoming damage.
- Blocked damage depletes guard.
- Holding block drains Heat.
- VFX and SFX warn near guard break.
- The guard-breaking hit remains fully blocked.
- Guard break applies its configured recovery and blocks player input.
- Guard requires L1 release and a new press to restore.

### Fire Parrying

- Pressing L1 activates one parry window.
- A successful parry nullifies the incoming attack and grants no additional reward.
- Holding L1 after the window closes provides no defence while movement remains locked.
- Another parry requires releasing and pressing L1 again.

L1 does nothing while Air or Earth is selected. Air and Earth defence remain deferred.

## Health, Impact, and Heat

HealthEvent remains the shared damage and healing contract. Damage carries Impact, original-instigator attribution, delivery type, school, contact information, and any effect instruction.

The current prototype starts Player and Enemy maximum Health at 100. X attacks retain their current direct-damage and Impact values across all four schools. Casting projectile hits use each school specialty’s existing direct-damage and Impact contracts.

The struck Entity’s defensive level reduces Impact:

```text
final hit-reaction level = max(0, Impact level − defensive level)
```

Attack speed begins at the `100%` baseline and cannot exceed `150%`. Each orb consumed by Casting increases attack speed by one percentage point: five total consumed orbs produce `105%` attack speed, and ten total consumed orbs produce `110%` attack speed.

Orb consumption and the Air level-1 spell effect are the current sources of this attack-speed increase. Their gains stack: casting Air level 1 with one consumed orb at `105%` attack speed first produces `106%` at Cast commitment, then `116%` when the Air effect resolves. Direct X hits, other casting impacts, DoT, status, and future HoT events add none. Three seconds after the last qualifying Heat gain, the Heat Reset Timer resets Heat and attack speed fully to the `100%` baseline.

When Laema is hit, attack speed decreases by five percentage points and cannot fall below the `100%` baseline. For example, a hit at `110%` attack speed reduces it to `105%` attack speed.

**Deferred direction:** Additional future spells may add Heat directly. Air level 1 is the only current spell with that behavior; rules and values for any additional spell remain open.

## Enemy and Feedback

The prototype contains three stationary, non-attacking, permanent Enemy targets that cannot die. Damage is capped at each target's remaining Health; reaching zero resolves normally and then immediately refills that target's Health without clearing active effects.

Each target’s status display communicates active DoT, Wet, Slow, Frozen, and Earth Slow effects. Frozen also applies its blue tint.

The always-visible game UI includes:

- a school-colored FIFO orb queue; and
- an R2 marking-progress bar beneath the orb queue.

Consumed, expired, and hit-lost marked orbs disappear. The queue distinguishes marked orbs from unmarked orbs, and the actively expiring oldest orb displays its remaining lifetime through a left-filled reverse progress indicator whose empty portion grows right to left.

The prototype developer overlay contains:

- the upper-left Heat, Player Health, Enemy Health, and defence readouts;
- the upper-center active-school, five-position-chain, and completed-chain readouts; and
- an upper-right gauge showing R2’s live raw pressure percentage.

The backtick Developer Portal has a shared header with Save to JSON, status, and Close controls, followed by three top-level tabs:

- **General:** Movement, Player, Enemy, UI, and the saved developer-overlay visibility flag. Gravity Scale is intentionally omitted from the Portal control surface.
- **Audio:** Ambient, SFX, and BGM groups. Each group has an Enabled control and a Volume control.
- **Combat:** nested sub-tabs for Combat, Casting, Heat, Fire, Water, Air, Earth, Defence, and Hit Reaction. The Combat sub-tab contains attack-hitbox visibility, the `collect_orb_without_contact` testing toggle, and the Combat controls. When enabled, a missed X can collect an orb without applying damage; the persisted prototype config currently has this test toggle enabled.

Audio controls apply immediately and persist through the same fail-fast JSON save/load flow. Ambient controls the wind loop; SFX controls attack, cast, orb, projectile, cast-failure, and guard-warning feedback; BGM controls the Fairy Battles music loop. These controls do not affect the orb queue, R2 marking-progress bar, target status display, target overhead Health display, or gameplay rules.

## Tutorial Stage Director

The end product of this prototype is a tutorial-like combat level governed by a stage Director. The Director presents one current task and advances only after detecting that task's successful objective.

The player remains free to perform other actions while attempting the current task. Unrelated or unsuccessful actions do not reset progress or prevent later success. A simple `No` UI message is sufficient failure feedback. The player cannot proceed to the next task until the current objective succeeds.

The current intermediate lesson list is provisional:

1. perform a five-X combo;
2. perform X, then Cast;
3. perform two X attacks, then cast a level-2 spell;
4. perform a five-X combo, then cast a level-5 spell;
5. perform X, X, Cast, X;
6. perform X, Cast, X, Cast; and
7. sustain charging by holding R2 at half pressure.

The final lesson is fixed: fight an Enemy. The lesson and tutorial complete when that Enemy dies. The current three permanent practice targets remain the current prototype behavior and do not yet satisfy this final-stage requirement.

## Tunables and Validation

Prototype tunables include movement speed, gravity, attack and casting duration, contact/trigger phase, chaining-window start, projectile speed and distance, direct damage, orb lifetime, R2 charge interval and capacity, R2 charge band center and tolerance, empowered multiplier, Heat, defence, Impact, hit reactions, statuses, Health, and feedback duration.

The prototype must make the following observable:

- grounded left/right movement and horizontal camera following;
- five-position chaining with X and mid-chain Casts;
- all four school X attacks and hit-generated orbs;
- normalized X/R2 pre-window buffering at baseline and high Heat, including first-request arbitration, promotion, and clear/invalidation behavior;
- the default contact requirement and the Developer Portal's optional no-contact orb-collection test toggle;
- all three Enemy targets accept X and projectile contact and display their own Health/status feedback;
- FIFO orb expiration, right-to-left reverse orb progress, mark transfer, and consumption;
- simultaneous R2 charging and attacking;
- R2 CHARGING, DEPLETING, and CAST bands, transition behavior, fixed-rate depletion, and full-press Cast behavior;
- default-visible developer readouts, upper-right live raw R2 pressure, shared visibility toggling, and saved visibility restoration;
- Developer Portal tab organization plus live, saved Ambient/SFX/BGM enabled and volume controls;
- an always-visible orb queue and R2 marking-progress bar independent of the developer-overlay flag;
- marked-orb loss on hit while unmarked orbs remain and expire normally;
- proportional Heat acceleration of attacks, casting animations, and R2 charging, including Air level 1's ten-point Heat gain without a separate timed multiplier;
- movement locked during active X/Cast animations and restored between actions while CHARGING or DEPLETING preserves the chain;
- normal, empowered, endpoint, consecutive, and failed Casts;
- failure cancellation and punishment flinch;
- primary, tie-break, and secondary mixed-school resolution;
- combined projectile travel, collision, color blending, and school effects;
- empowered player VFX and primary-only `1.3×` damage;
- Heat and status feedback; and
- Fire parry and Water defence-state entry.

Incoming Enemy attacks and ordinary-play validation of blocking, parrying, guard depletion, guard warning, and guard break remain deferred because the Enemy does not attack.

Still open or deferred: jumping, non-flat level geometry, Air and Earth defence, active Enemy behavior, final balance, final casting and projectile assets, final Laema presentation, complete enemy content, and detailed charge-to-orb highlighting.
