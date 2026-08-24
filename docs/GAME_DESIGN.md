# Laema Side-Scrolling Orb Casting Prototype

Status: User-verified design ready for technical handoff.

## Overview

This prototype tests the existing four-school combat system in a 2D side-scrolling space. Laema builds a temporary queue of elemental orbs through successful X attacks, charges Casting independently with R2, and releases normal or empowered school spells through timing and resource composition.

The primary experience remains deliberate combat mastery. The player should learn to maintain an attack chain, build the desired elemental sequence, charge while continuing to attack, and release Casting at an intentional moment.

## Prototype Scope

**Included:** grounded left/right movement, gravity, one continuous flat floor, horizontal camera following, functional Fire/Water/Air/Earth X attacks and casting specialties, school switching, a five-position attack-and-casting chain, temporary elemental orbs, R2 charging, normal and empowered casting, casting projectiles, Heat, Fire parrying, Water blocking, hit reactions, combat UI, and one non-attacking Enemy target.

**Excluded:** jumping, vertical traversal controls, Air and Earth defence, active Enemy behavior and attacks, final level design, final art and UI assets, complete enemy content, and final numerical tuning.

## Controls and Movement

| Input | Action |
|---|---|
| Left stick | Move left or right and face that direction |
| X | Perform the active school’s attack |
| R2 pressed into the 90–100% upper endpoint deadzone | Start or resume marking orbs for Casting |
| R2 eased to approximately 50% | Pause orb-marking progress |
| R2 released into the 0–10% lower endpoint deadzone | Attempt Casting |
| D-pad Up | Select Fire |
| D-pad Down | Select Water |
| D-pad Left | Select Air |
| D-pad Right | Select Earth |
| L1 | Use the active school’s available defence |

Laema is affected by gravity and remains grounded on solid collision. The first test level is one continuous flat floor. The camera follows Laema horizontally while preserving fixed vertical framing.

Attacking continues to lock player-controlled movement for the active chain. Facing is horizontal; attacks and casting projectiles use Laema’s current facing direction.

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

Every attack and casting animation has a chaining window. Once that window opens, it remains valid through the end of the animation. Inputs before the window opens are rushed inputs.

For this prototype, X attacks and Casting use the same base animation duration and normalized chaining-window timing. Heat accelerates both through the same current speed multiplier.

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
- Its lifetime is three seconds.
- The oldest orb fades linearly from fully visible to invisible across its remaining lifetime.
- Later orbs retain their full lifetime while another orb remains ahead of them.
- When the oldest orb expires or is consumed, the next orb immediately begins its full three-second lifetime.
- Unconsumed orbs remain after a successful mid-chain Cast.
- Ending or failing the chain clears every remaining orb.

Example:

```text
Air X hit → Air X hit → switch Water → Water X hit → Water X hit
Orb queue: A A W W
```

## R2 Charging

R2 charging may begin at any time, with or without available orbs, and continues while Laema attacks or performs casting animations. Charging capacity marks the oldest available orbs in first-in, first-out order.

- Pressing R2 into the 90–100% upper endpoint deadzone starts or resumes marking progress.
- Easing R2 to approximately 50% pauses marking progress without attempting a Cast. Existing progress and marked orbs remain.
- Pressing R2 back into the 90–100% upper endpoint deadzone resumes from the paused progress.
- Releasing R2 into the 0–10% lower endpoint deadzone attempts to resolve Casting.
- The approximate 50% pause point and its positive/negative tolerance band are tunable. The prototype begins with a ±15% band, so 35–65% pressure counts as paused.
- For the prototype, 0–10% counts as fully released and 90–100% counts as fully pressed. References below to fully releasing R2 use the lower endpoint deadzone rather than requiring an exact 0% reading.
- Casting capacity increases by one marked orb every nominal 0.5 seconds.
- At baseline speed, the first orb becomes marked after 0.5 seconds.
- At baseline speed, maximum capacity is five marked orbs after 2.5 seconds.
- Holding longer leaves capacity at five.
- R2 charging speed uses the same current Heat multiplier as attack and casting animations. At multiplier `M`, effective step duration is `0.5 / M` seconds and full five-orb charge time is `2.5 / M` seconds.
- Holding or pausing R2 preserves the active chain and its orb queue beyond the normal idle timeout.
- Marking does not pause expiration. If a marked oldest orb expires, the existing marking coverage transfers forward with the shifted queue, preserving the marked count when enough orbs remain.
- When Laema is hit, every marked orb is removed. Unmarked orbs remain in the queue and continue their normal expiration countdown.
- Fully releasing R2 consumes:

```text
all currently marked orbs
```

Consumption is first-in, first-out. For example, two marked orbs in `A A W W` consume `A A`.

Marked orbs are consumed immediately when a Cast successfully begins. If casting is interrupted before projectile launch, those orbs are not refunded.

## Casting Outcomes

### Normal Cast

Fully releasing R2 while Laema is idle performs a normal Cast when at least one orb is marked. A normal Cast ends the current chain after consuming its marked orbs.

### Empowered Cast

Fully releasing R2 during an attack or casting animation’s valid chaining window performs an empowered Cast.

- A mid-chain empowered Cast occupies the next progression position and may continue chaining.
- An empowered Cast released after position 5 is the optional endpoint Cast and ends the chain.
- Empowered Casting displays a distinct VFX on Laema; a visible dot is sufficient for the prototype.
- Only the primary school’s direct damage receives the empowered multiplier.
- Empowered primary direct damage is `1.3×` the corresponding normal-cast damage.
- Secondary casting damage and other specialty behavior remain unchanged.

### Failed Cast

Casting fails when any of the following is true:

- R2 is fully released before any orb is marked.
- R2 is fully released during an active attack or casting animation before its chaining window opens.

A failed Cast:

- cancels the active attack or casting animation;
- produces no projectile or spell effect;
- ends the chain and clears its orbs; and
- applies the existing level-1 light flinch and recovery to Laema.

Fully releasing R2 while idle is not a timing failure. It succeeds when at least one orb is marked.

## Mixed-School Resolution

The consumed orb composition determines the spell output.

1. The school with the greatest consumed-orb count becomes the primary school.
2. If two schools tie, the school of the final consumed orb wins the tie.
3. Primary casting level equals the total number of consumed orbs.
4. The secondary school resolves at:

```text
consumed orbs of that school − 1
```

5. A secondary result below level 1 produces no secondary casting.

Example:

```text
Consumed queue: A A W W
Primary: Water level 4
Secondary: Air level 1
```

The primary and secondary results reuse their school’s current specialty behavior.

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

Air level 1 grants the current timed multiplicative attack-speed buff. Air levels 2 through 5 release chain lightning whose direct damage and chained-target count scale with level. Exact final values remain tunable.

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

L1 does nothing while Air or Earth is selected. Air parry and Earth blocking remain deferred.

## Health, Impact, and Heat

HealthEvent remains the shared damage and healing contract. Damage carries Impact, original-instigator attribution, delivery type, school, contact information, and any effect instruction.

The current prototype starts Player and Enemy maximum Health at 100. X attacks retain their current direct-damage and Impact values across all four schools. Casting projectile hits use each school specialty’s existing direct-damage and Impact contracts.

The struck Entity’s defensive level reduces Impact:

```text
final hit-reaction level = max(0, Impact level − defensive level)
```

Direct X and casting HealthEvents that reduce Health add Heat. Separate primary and secondary direct events may add Heat independently. DoT, status, and future HoT events add none.

Heat levels continue increasing attack and casting animation speed. Inactivity resets Heat according to the current tunable grace period.

**Deferred direction:** A later iteration will replace direct-hit Heat gain with Heat gain based on the number of orbs consumed by Casting. This change is not part of the current side-scrolling prototype implementation; its conversion rate and tuning remain open.

## Enemy and Feedback

The prototype Enemy remains stationary, non-attacking, permanent, and unable to die. Damage is capped at remaining Health; reaching zero resolves normally and then immediately refills Health without clearing active effects.

The target’s status display communicates active DoT, Wet, Slow, Frozen, and Earth Slow effects. Frozen also applies its blue tint.

The always-visible game UI includes:

- a school-colored FIFO orb queue; and
- an R2 marking-progress bar beneath the orb queue.

Consumed, expired, and hit-lost marked orbs disappear. The queue distinguishes marked orbs from unmarked orbs, and the actively expiring oldest orb displays its remaining lifetime through its linear fade.

The prototype developer overlay contains:

- the upper-left Heat, Player Health, Enemy Health, and defence readouts;
- the upper-center active-school, five-position-chain, and completed-chain readouts; and
- an upper-right gauge showing R2’s live raw pressure percentage.

The backtick tuning menu contains one flag that shows or hides all three developer-overlay regions together. The flag defaults to visible for this prototype and is saved in the fail-fast JSON configuration. It does not affect the orb queue, R2 marking-progress bar, target status display, or target overhead Health display.

## Tunables and Validation

Prototype tunables include movement speed, gravity, attack and casting duration, contact/release phase, chaining-window start, projectile speed and distance, direct damage, orb lifetime, R2 charge interval and capacity, R2 pause threshold and tolerance band, empowered multiplier, Heat, defence, Impact, hit reactions, statuses, Health, and feedback duration.

The prototype must make the following observable:

- grounded left/right movement and horizontal camera following;
- five-position chaining with X and mid-chain Casts;
- all four school X attacks and hit-generated orbs;
- FIFO orb expiration, linear lifetime fade, mark transfer, and consumption;
- simultaneous R2 charging and attacking;
- R2 upper-deadzone press, approximate-half-pause, upper-deadzone resume, and lower-deadzone release behavior;
- default-visible developer readouts, upper-right live raw R2 pressure, shared visibility toggling, and saved visibility restoration;
- an always-visible orb queue and R2 marking-progress bar independent of the developer-overlay flag;
- marked-orb loss on hit while unmarked orbs remain and expire normally;
- proportional Heat acceleration of attacks, casting animations, and R2 charging;
- normal, empowered, endpoint, consecutive, and failed Casts;
- failure cancellation and punishment flinch;
- primary, tie-break, and secondary mixed-school resolution;
- combined projectile travel, collision, color blending, and school effects;
- empowered player VFX and primary-only `1.3×` damage;
- Heat and status feedback; and
- Fire parry and Water defence-state entry.

Incoming Enemy attacks and ordinary-play validation of blocking, parrying, guard depletion, guard warning, and guard break remain deferred because the Enemy does not attack.

Still open or deferred: jumping, non-flat level geometry, Air and Earth defence, active Enemy behavior, final balance, final casting and projectile assets, final Laema presentation, complete enemy content, and detailed charge-to-orb highlighting.
