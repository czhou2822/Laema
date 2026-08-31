# Laema Side-Scrolling Orb Casting Prototype

## Overview

This prototype tests the existing four-school combat system in a 2D side-scrolling space. Laema builds a temporary queue of charged elemental orbs through successful X attacks, uses full R2 pressure to mark charged orbs for the upcoming Cast, depletes that marking progress below full pressure, and triggers normal or empowered school spells by releasing R2 below the Cast threshold.

The primary experience remains deliberate combat mastery. The player should learn to maintain an attack chain, build the desired elemental sequence, mark charged orbs while continuing to attack, and trigger Casting at an intentional pressure moment.

## Prototype Scope

**Included:** grounded left/right movement, gravity, continuous flat ground through all current stage areas, horizontal camera movement, functional Fire/Water/Air/Earth X attacks, generic school-and-level Cast resolution, school switching, a five-position attack-and-casting chain, temporary elemental orbs, R2 Marking, normal and empowered casting, casting projectiles, Heat, Fire parrying, Water blocking, hit reactions, combat UI, reusable tutorial-stage progression, Stage 1 and Stage 2 objectives, and stage-owned target sets.

**Excluded:** jumping, vertical traversal controls, Air and Earth defence, active Enemy behavior and attacks, final level design, final art and UI assets, complete enemy content, and final numerical tuning.

## Controls and Movement

| Input | Action |
|---|---|
| Left stick | Move left or right and face that direction |
| X | Perform the active school’s attack |
| R2 held in the 95–100% Marking band | Mark charged orbs for the upcoming Cast |
| R2 held between 5–95% | Deplete marking progress at the fixed baseline rate |
| R2 released below 5% | Trigger Casting once on release |
| D-pad Up | Select Fire |
| D-pad Down | Select Water |
| D-pad Left | Select Air |
| D-pad Right | Select Earth |
| L1 | Use the active school’s available defence |

Laema is affected by gravity and remains grounded on solid collision. Every current stage area uses the same continuous flat ground height, and adjacent ground sections overlap at stage boundaries so transitions do not introduce a gap. The camera follows Laema horizontally while preserving fixed vertical framing.

Active X and Cast animations lock player-controlled movement. When MARKING or DEPLETING preserves a chain between actions, Laema may move horizontally while retaining the chain and its orbs. Facing is horizontal; attacks and casting projectiles use Laema’s current facing direction.

## Schools and Character Presentation

All four schools have functional X attacks and generic school-and-level Cast outputs. Active-school selection changes the displayed prototype character:

| School | Character | Prototype Cast output |
|---|---|---|
| Fire | Fighter | Generic direct damage plus `Fire Lv.N` display |
| Water | Prototype Saber Fighter | Generic direct damage plus `Water Lv.N` display |
| Air | Shinobi | Generic direct damage plus `Air Lv.N` display |
| Earth | Samurai | Generic direct damage plus `Earth Lv.N` display |

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
- Ending or failing a chain does not remove stored orbs. Failed Casting resets their marking state as defined below.

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

X presses and release-Cast requests use one shared normalized pre-window buffer. The buffer width is 20% of normalized action duration. With `combat.input_window_start = 0.48` and `combat.x_buffer_width = 0.20`, the initial buffer zone is `0.28 <= progress < 0.48`. One valid X or release-Cast request may occupy the buffer slot; later requests in that same buffer period are ignored. The buffer applies while the current chainable animation is X or Cast, and does not apply to school switching.

An X buffer stores one school-and-direction action intention without advancing the chain or UI, then promotes it through the normal X acceptance path when the chaining window opens. A buffered release requires marked orbs, consumes them immediately, resolves and freezes the Cast composition and existing Cast fields, then promotes the resolved Cast as the appropriate empowered mid-chain or endpoint Cast when the chaining window opens. Early X remains ignored; an early release before the buffer without a valid request remains a rushed Cast failure. Buffer state does not repeat from held input and clears on interruption, hit reaction, failed Cast, chain completion/reset, or return to `READY`.

## Orb Queue

Every X attack that hits an Enemy creates one charged orb matching the attack’s school:

| School | Orb |
|---|---|
| Fire | F |
| Water | W |
| Air | A |
| Earth | E |

Charged orbs form a first-in, first-out queue. A charged orb is an orb earned by a landed melee X. A marked orb is a charged orb selected by R2 Marking to participate in the upcoming Cast.

- The queue stores at most 10 orbs.
- If all 10 slots are occupied, an additional generated orb is discarded without changing the stored queue.
- Only the oldest orb counts down toward expiration.
- Its lifetime is seven seconds.
- A newly spawned orb is a solid school-colored disc (Fire is red). As its lifetime falls, the filled region interpolates from 100% to 75%, 50%, 25%, and empty by shrinking from the right edge toward the left; the unfilled region is transparent.
- Later orbs retain their full lifetime while another orb remains ahead of them.
- When the oldest orb expires or is consumed, the next orb immediately begins its full seven-second lifetime.
- Every successful Cast consumes at most the five marked front orbs. All unconsumed orbs remain and shift forward into the vacated slots while preserving FIFO order.
- When a chain times out after a completed action without a follow-up, the chain state ends but unconsumed orbs remain while Laema is idle or moving and continue their FIFO expiration.
- A failed Cast removes no orbs. It makes every stored orb unmarked and resets partial marking progress to zero.

Example:

```text
Air X hit → Air X hit → switch Water → Water X hit → Water X hit
Orb queue: A A W W
```

## R2 Pressure and Marking

R2 pressure has three semantic states, and state changes are transition-based:

- Below `5%`: **RELEASE**; one Cast attempt occurs on entry.
- `5–95%`: **DEPLETING**; marking capacity and partial progress drain at a fixed rate.
- `95–100%`: **MARKING**; available marking capacity selects charged orbs in FIFO order.

MARKING may begin at any time, with or without available charged orbs, and continues while Laema attacks or performs casting animations. Marking capacity selects the oldest available charged orbs in first-in, first-out order.

- Entering MARKING starts or resumes marking progress.
- Entering DEPLETING drains the continuous marking meter at the baseline `charge_step_duration` rate without Heat scaling.
- Entering RELEASE triggers one normal or empowered Cast attempt; holding at full release does not repeat it.
- The prototype begins with 95–100% as MARKING, 5–95% as DEPLETING, and below 5% as RELEASE; no exact 0% or 100% reading is required.
- Marking capacity increases by one marked orb every nominal 0.5 seconds while MARKING.
- At baseline speed, the first orb becomes marked after 0.5 seconds.
- At baseline speed, maximum capacity is five marked orbs after 2.5 seconds.
- Holding longer leaves capacity at five.
- MARKING uses the current Heat multiplier. At multiplier `M`, effective step duration is `0.5 / M` seconds.
- DEPLETING uses the fixed zero-Heat Marking rate: one mark-equivalent per baseline `charge_step_duration`, currently 0.5 seconds. It does not scale with Heat.
- Partial progress depletes continuously. Crossing a completed-mark boundary unmarks the most recently marked orb first.
- DEPLETING never consumes or removes queue orbs.
- MARKING and DEPLETING preserve the active chain and its orb queue beyond the normal idle timeout.
- MARKING and DEPLETING do not keep movement locked between active X or Cast animations.
- Marking does not pause expiration. If a marked oldest orb expires, the existing marking coverage transfers forward with the shifted queue, preserving the marked count when enough orbs remain.
- When Laema receives an incoming direct-damage `HealthResult` whose outcome is `APPLIED`, every marked orb is removed. Unmarked orbs remain in the queue and continue their normal expiration countdown. `BLOCKED`, `PARRIED`, and DoT results remove no orbs. Final hit-reaction strength does not affect this resource rule.
- Entering RELEASE consumes:

```text
all currently marked orbs
```

Consumption is first-in, first-out. For example, two marked orbs in `A A W W` consume `A A`.

Marked orbs are consumed immediately on RELEASE entry, including a buffered release before the promoted Cast animation begins. If Casting is interrupted before projectile launch, those orbs are not refunded.

After consumption, every unconsumed orb shifts forward into the consumed slots while preserving FIFO order. This applies to normal, mid-chain, and endpoint Casts.

## Casting Outcomes

### Normal Cast

Entering RELEASE while Laema is idle performs a normal Cast when at least one orb is marked. A normal Cast ends the current chain after consuming its marked orbs.

### Empowered Cast

Entering RELEASE during an attack or casting animation’s valid buffer/window performs an empowered Cast.

- A mid-chain empowered Cast occupies the next progression position and may continue chaining.
- An empowered Cast triggered after position 5 is the optional endpoint Cast and ends the chain.
- Empowered Casting displays a distinct VFX on Laema; a visible dot is sufficient for the prototype.
- Only the primary school’s direct damage receives the empowered multiplier.
- Empowered primary direct damage is `1.3×` the corresponding normal-cast damage.
- Secondary generic direct damage remains unchanged. No school-specific Cast behavior resolves in this prototype.

### Failed Cast

Casting fails when any of the following is true:

- Release is triggered before any orb is marked.
- Release is triggered during an active attack or casting animation before its buffer zone opens.

A failed Cast:

- cancels the active attack or casting animation;
- produces no projectile or spell effect;
- ends the chain, leaves every stored orb in the queue, makes all of them unmarked, resets partial marking progress to zero; and
- applies the existing level-1 light flinch and recovery to Laema.

Entering RELEASE while idle is not a timing failure. It succeeds when at least one orb is marked.

## Mixed-School Resolution

The consumed orb composition determines the spell output.

1. The school of the final consumed orb becomes the primary school, using last-in, first-out selection.
2. Primary casting level equals the total number of consumed orbs.
3. After removing the primary school from consideration, the remaining school with the greatest consumed-orb count becomes the single secondary school.
4. If secondary candidates tie, whichever tied school appears last in the consumed sequence becomes secondary, using a last-in, first-out tie-break.
5. Secondary casting level equals that school's own consumed-orb count.
6. A Cast resolves at most one secondary layer. Other represented schools produce no casting layer, although their marked orbs are still consumed and still count toward the primary casting level and commitment-time Heat.

Example:

```text
Consumed queue: A A W W
Primary: Water level 4
Secondary: Air level 2

Consumed queue: F F E E E
Primary: Earth level 5
Secondary: Fire level 2

Consumed queue: E E E F W
Primary: Water level 5, because Water is the final consumed orb
Secondary: Earth level 3, because Earth has the highest remaining count
Fire: no casting layer

Consumed queue: E E W W F
Primary: Fire level 5, because Fire is the final consumed orb
Secondary: Water level 2, because Earth and Water tie and Water appears last in the consumed sequence
Earth: no casting layer
```

The primary and optional secondary results each deal the existing generic direct Cast damage and display their school and resolved level on the struck Enemy.

### Future Configurable Spell Mapping

For the final product, the player configures outside combat which spell is assigned to each school and casting level, choosing from the spells available for that slot. Casting invocation remains unchanged during combat; when a school and casting level resolve, the configured spell determines the resulting behavior.

The prototype uses generic direct Cast damage plus school-and-level display instead of fixed school-specific behavior. Available spell lists and every individual school-level spell behavior remain open for a separate design session.

## Prototype School-and-Level Cast Feedback

Every resolved school layer—the primary and optional secondary—in a successful projectile hit:

- deals the existing generic direct Cast damage;
- uses the existing generic Cast Impact contract; and
- displays `<School> Lv.<N>` on the struck Enemy.

A mixed Cast displays its resolved primary and optional secondary results, such as `Water Lv.4` and `Air Lv.2`. The exact display duration and presentation remain prototype feedback tuning. Fire DoT, Water Wet/Slow/Frozen, Air Heat/chain lightning, Earth area/Slow, and every other school-level spell behavior are deferred to a separate design session.

## Casting Projectile

Every successful Cast begins a casting animation. The projectile launches later at the same normalized phase used by X attacks for contact.

- One combined projectile carries the primary and at most one secondary school layer.
- It travels in Laema’s facing direction.
- It travels approximately 50% of the visible screen width in one second.
- It disappears on the first valid Enemy hit or after reaching maximum distance.
- On hit, it resolves each included generic direct-damage layer and displays every resolved school and level on the Enemy.
- A miss produces no impact damage or school-and-level display. It does not revoke Heat already granted at Cast commitment.

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

The current prototype starts Player and Enemy maximum Health at 100. X attacks retain their current direct-damage and Impact values across all four schools. Casting projectile hits use the existing generic Cast damage and Impact contracts for the resolved primary and optional secondary layers.

The struck Entity’s defensive level reduces Impact:

```text
final hit-reaction level = max(0, Impact level − defensive level)
```

Attack speed begins at the `100%` baseline and cannot exceed `150%`. Each orb consumed by Casting increases attack speed by one percentage point: five total consumed orbs produce `105%` attack speed, and ten total consumed orbs across multiple Casts produce `110%` attack speed.

Orb consumption is the only current source of this attack-speed increase. Heat is granted immediately when a Cast commits and consumes marked orbs, including a buffered Cast committed before its animation begins. Interruption before launch and projectile miss do not revoke that Heat. Direct X hits, projectile impacts, and any deferred spell behavior add none. Three seconds after the last qualifying Cast commitment, the Heat Reset Timer resets Heat and attack speed fully to the `100%` baseline.

When Laema receives an incoming direct-damage `HealthResult` whose outcome is `APPLIED`, attack speed decreases by five percentage points and cannot fall below the `100%` baseline. For example, a qualifying hit at `110%` attack speed reduces it to `105%` attack speed. `BLOCKED`, `PARRIED`, and DoT results cause no Heat loss. Final hit-reaction strength does not affect this resource rule.

**Deferred direction:** Future school-level spells may add Heat directly. Every such rule and value remains open.

## Enemy and Feedback

Each tutorial stage owns its area contents and entity instances independently; later stages may deliberately duplicate earlier targets or enemies. Stage 1 and Stage 2 each contain exactly one stationary, non-attacking, permanent target with identical behavior. Damage is capped at its remaining Health; reaching zero resolves normally and then immediately refills it to full Health without clearing active effects. The existing prototype arena is the final tutorial area and retains its three permanent practice targets plus its killable final Enemy.

All current prototype targets—including training dummies and the final Enemy—are pass-through: they never physically block Laema's movement. They remain valid X and projectile targets. Body-blocking behavior is outside the current prototype rule.

Each target displays the school and level of every successful Cast layer applied to it. School-specific status displays are deferred with the spell behaviors they would represent.

The always-visible game UI includes:

- a school-colored FIFO orb queue with all 10 storage slots always visible, including empty slots; and
- an R2 marking-progress bar beneath the orb queue.

Consumed, expired, and hit-lost marked orbs disappear. Each marked orb uses a 2 px gold outline while retaining its school-colored fill. The actively expiring oldest orb displays its remaining lifetime through a left-filled reverse progress indicator whose empty portion grows right to left.

When a generated orb is discarded because all 10 slots are occupied, the entire orb widget performs a UI-only horizontal flinch: 4 px left, 4 px right, then back to rest over approximately 0.12 seconds. Each discarded orb restarts the flinch from the widget's resting position. This feedback never interrupts Laema, movement, actions, or chain state.

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

The prototype is a one-way sequence of side-scrolling tutorial areas governed by a stage Director. Each stage owns its objective rules, objective presentation, area contents, completion state, exit gate, and transition into the next area.

### Reusable Stage Progression

Every non-final tutorial stage uses the same progression shell:

1. A stage begins when its area is revealed and Laema is waiting there.
2. Its objective widget initializes in the upper-right game UI.
3. The player may move, attack, Cast, defend, switch schools, and perform unrelated actions freely. These actions do not fail the stage or prevent later success.
4. Each stage separately defines what begins an attempt, advances it, invalidates and resets it, completes the objective, and counts as unrelated behavior.
5. Invalidating an active attempt resets only that attempt. The stage remains available indefinitely until its objective succeeds.
6. Objective success is permanent. Later actions cannot undo a completed stage.
7. On success, the objective widget turns green, displays `moving on ->`, and the solid right-side boundary unlocks.
8. The player chooses when to move right and exit the visible frame.
9. Once Laema leaves the frame, player input locks and the camera pans horizontally to the next area.
10. During the pan, Laema is repositioned into the next area. She is already visible there in an idle waiting state when the pan finishes.
11. The next stage begins when the pan finishes. Its objective widget initializes, player input returns, and backward travel into the completed area is blocked.

At the beginning of every stage after Stage 1, Laema receives a full combat reset: full Health, baseline Heat, an empty orb queue, no marking progress, no active chain, no buffs or debuffs, and a ready defence state. The currently selected school carries forward instead of resetting. Stage 1 begins with Fire selected.

### Reusable Objective Widget

Every stage reuses the upper-right objective-widget shell while supplying its own instruction and progress display.

- Valid progress turns the corresponding display elements green.
- An invalid attempt lightly flinches the whole widget and resets that attempt's progress colors.
- Invalid-attempt feedback never interrupts Laema, movement, or combat state.
- Completing an objective turns the whole widget green and adds `moving on ->`.
- The completed widget remains visible until the next stage begins.

### Stage 1 — Five-Hit Fire Chain

Stage 1 begins immediately when the game starts. Fire is selected, the upper-right objective widget is visible with no progress, the solid right boundary is locked, and one stationary non-attacking permanent target is available.

The objective widget displays:

```text
perform a 5 hit combo
X-X-X-X-X
```

Stage 1 succeeds only when all five positions of one uninterrupted chain are landed Fire X attacks against the target.

- The first landed Fire X begins an attempt and turns the first `X` green.
- Each subsequent valid Fire X hit in that chain turns the next `X` green.
- Any Fire X miss lightly flinches and resets the widget, including a miss before the first valid hit.
- Before the first green `X`, non-Fire attacks, Casts, defence, movement, school switching, and other unrelated actions leave the widget unchanged.
- After progress begins, inserting a Cast, landing a non-Fire X, missing an X, or ending the chain before five valid hits invalidates the attempt. The widget flinches and all progress colors reset.
- School-switch inputs alone do not invalidate the attempt, provided every landed attack in the successful chain is a Fire X.
- The fifth valid hit permanently completes Stage 1. The whole widget turns green, `moving on ->` appears, and the right boundary unlocks immediately.

The player may remain in the completed Stage 1 area and act freely without losing completion. Moving right eventually carries Laema out of frame and begins the standard transition into Stage 2.

### Stage 2 — Level-5 Cast

Stage 2 teaches that charged orbs earned through melee attacks can be marked and spent through Casting. The player may accumulate charged orbs through any attacks, chains, or schools.

Stage 2 contains one stationary, non-attacking, permanent target matching the Stage 1 target. Its objective widget is text-only and displays:

```text
perform a level 5 spell
```

Stage 2 succeeds when the player releases any level-5 Cast.

- The five consumed orbs may contain any school composition.
- The Cast's primary and optional secondary schools do not affect success.
- Projectile impact is unnecessary; a released level-5 Cast succeeds even if its projectile misses.
- Once the player attempts Casting, failure means that no spell projectile is released. Empty Casts, early timing failures, and commitment interrupted before release are failed attempts.
- A released Cast below level 5 is also a failed attempt.
- A failed attempt uses the same light whole-widget flinch as Stage 1 and leaves the stage available for another attempt.
- Movement, melee attacks, defence, school switching, Marking, DEPLETING, and other unrelated actions do not fail the stage.
- The persistent ten-slot combat orb queue remains unchanged and provides all charged-orb and marked-orb feedback; the Stage 2 objective widget does not duplicate that progress.

Completion is permanent, turns the whole objective widget green, displays `moving on ->`, and unlocks the right boundary through the reusable stage-progression shell.

### Later Tutorial Stages

Stage 1 and Stage 2 are locked. The remaining intermediate lesson list is provisional:

3. perform two X attacks, then cast a level-2 spell;
4. perform a five-X combo, then cast a level-5 spell;
5. perform X, X, Cast, X;
6. perform X, Cast, X, Cast; and
7. sustain Marking by holding R2 at full pressure.

Each later stage defines its own area contents and attempt rules through the reusable progression and widget shells.

### Tutorial Completion and Free Practice

Until Stage 3 is defined, Stage 1 transitions into Stage 2, and Stage 2 transitions directly into the existing prototype arena, which serves as the legitimate final tutorial stage. Future tutorial stages are inserted between Stage 2 and this final arena.

The final tutorial objective remains `Defeat the final Enemy`. When that Enemy dies, the tutorial completes permanently and the objective widget immediately changes to the free-form text below. There is no separate completion screen, delay, animation, or intermediate message. The final arena remains loaded and becomes the indefinite free-form practice area; there is no additional right exit or camera-pan transition. Its permanent practice targets remain available.

The objective widget switches to the free-form state, remains visible indefinitely, has no progress row, and displays:

```text
now you are free
```

## Tunables and Validation

Prototype tunables include movement speed, gravity, attack and casting duration, contact/trigger phase, chaining-window start, projectile speed and distance, direct damage, orb lifetime, R2 Marking interval and capacity, R2 pressure thresholds, empowered multiplier, Heat, defence, Impact, hit reactions, statuses, Health, and feedback duration.

The prototype must make the following observable:

- grounded left/right movement and horizontal camera following;
- five-position chaining with X and mid-chain Casts;
- all four school X attacks and hit-generated orbs;
- 10-orb FIFO storage with all slots permanently visible, a five-orb marking/Cast limit, and preserved queue order after every successful Cast;
- failed Casts preserving stored orbs while resetting all marks and partial marking progress;
- gold marked-orb outlines plus full-queue discard and whole-widget flinch feedback;
- normalized X/R2 pre-window buffering at baseline and high Heat, including first-request arbitration, promotion, and clear/invalidation behavior;
- the default contact requirement and the Developer Portal's optional no-contact orb-collection test toggle;
- the Stage 1 area contains one stationary, non-attacking, permanent target that accepts X and projectile contact, displays its own Health and Cast-level feedback, and refills at zero Health;
- FIFO orb expiration, right-to-left reverse orb progress, mark transfer, and consumption;
- simultaneous R2 Marking and attacking;
- R2 MARKING, DEPLETING, and RELEASE bands, transition behavior, fixed-rate newest-mark-first depletion, and release-Cast behavior;
- default-visible developer readouts, upper-right live raw R2 pressure, shared visibility toggling, and saved visibility restoration;
- Developer Portal tab organization plus live, saved Ambient/SFX/BGM enabled and volume controls;
- an always-visible orb queue and R2 marking-progress bar independent of the developer-overlay flag;
- marked-orb and five-point Heat loss only on incoming `APPLIED` direct damage, including zero-reaction results, while `BLOCKED`, `PARRIED`, and DoT results cause neither resource loss;
- proportional Heat acceleration of attacks, casting animations, and R2 Marking, with orb consumption as the only current Heat-gain source;
- movement locked during active X/Cast animations and restored between actions while MARKING or DEPLETING preserves the chain;
- normal, empowered, endpoint, consecutive, and failed Casts;
- failure cancellation and punishment flinch;
- last-consumed-orb primary selection, single-secondary majority selection, and LIFO secondary tie-break;
- combined projectile travel, collision, color blending, generic direct damage, and school-and-level Enemy display;
- empowered player VFX and primary-only `1.3×` damage;
- commitment-time Heat and Cast-level feedback;
- Fire parry and Water defence-state entry;
- the reusable one-way lifecycle for non-final tutorial stages, including independent area contents, completion latch, right-exit gate, input-locked camera pan, waiting-state arrival, and no-backtracking rule;
- stage-start combat reset with active-school carryover;
- the reusable upper-right objective widget with green progress, invalid-attempt flinch/reset, whole-widget completion, and `moving on ->` prompt;
- the complete Stage 1 five-hit Fire-chain success, invalidation, target, UI, and transition behavior;
- the complete Stage 2 level-5 Cast success, lower-level and empty-Cast failure feedback, target, text-only UI, and transition behavior; and
- the existing prototype arena as the final tutorial area, followed in place by its indefinite `now you are free` free-practice state.

Incoming Enemy attacks and ordinary-play validation of blocking, parrying, guard depletion, guard warning, and guard break remain deferred because the Enemy does not attack.

Still open or deferred: jumping, non-flat level geometry, Air and Earth defence, active Enemy behavior, all school-level spell behaviors, final balance, final casting and projectile assets, final Laema presentation, and complete enemy content.
