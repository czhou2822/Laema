# Laema Side-Scrolling Orb Casting Prototype

## Overview

This prototype tests the existing four-school combat system in a 2D side-scrolling space. Laema generates temporary elemental orbs through successful X attacks, uses full L2 pressure to charge generated orbs for the upcoming Cast, depletes that charging progress below full pressure, and triggers normal or empowered school spells by releasing L2 below the Cast threshold.

The primary experience remains deliberate combat mastery. The player should learn to maintain an attack chain, generate the desired elemental sequence, charge generated orbs while continuing to attack, and trigger Casting at an intentional pressure moment.

## Prototype Scope

**Included:** grounded left/right movement, gravity, continuous flat ground through all current stage areas, horizontal camera movement, functional Fire/Water/Air/Earth X attacks, generic school-and-level Cast resolution, school switching, a five-position attack-and-casting chain, temporary elemental orbs, L2 Charging, normal and empowered casting, casting projectiles, Heat, Fire parrying, Water blocking, hit reactions, combat UI, reusable tutorial-stage progression, Stage 1 through Stage 7 objectives, stage-owned target sets, and one attacking final Enemy with one committed melee pattern.

**Excluded:** jumping, vertical traversal controls, Air and Earth defence, additional Enemy behaviors and attack patterns, final level design, final art and UI assets, complete enemy content, and final numerical tuning.

## Controls and Movement

| Input | Action |
|---|---|
| Left stick | Move left or right and face that direction |
| X | Perform the active school’s attack |
| L2 held in the 95–100% Charging band | Charge generated orbs for the upcoming Cast |
| L2 held between 5–95% for more than 0.3 seconds | Deplete charging progress at the fixed baseline rate |
| L2 released below 5% | Trigger Casting once on release |
| D-pad Up | Select Fire |
| D-pad Down | Select Water |
| D-pad Left | Select Air |
| D-pad Right | Select Earth |
| L1 | Use the active school’s available defence |
| Start / Esc | Pause or resume through the pause menu |

Laema is affected by gravity and remains grounded on solid collision. Every current stage area uses the same continuous flat ground height, and adjacent ground sections overlap at stage boundaries so transitions do not introduce a gap. The camera follows Laema horizontally while preserving fixed vertical framing.

Active X and Cast animations lock player-controlled movement and facing. Once an action begins, left/right input cannot flip Laema until that action finishes. When CHARGING or DEPLETING preserves a chain between actions, Laema may move horizontally while retaining the chain and its orbs. Facing is horizontal; attacks and casting projectiles use Laema’s current facing direction.

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

School switching is always available and changes the school used by future X attacks. It does not depend on the current chaining window, CHARGING or DEPLETING state, or any prior switch in the active chain. Switching consumes no progression position, buffered input, or other chain/input capacity, and it never clears or ends the chain. The currently selected school never directly determines Cast output.

## Six-Slot Chain

A chain contains six available slots. Slots 1–5 are progression slots that may each contain X or Cast. Slot 6 is an optional Cast-only endpoint.

- A successful or missed X attack occupies one of slots 1–5.
- X creates an orb only when it physically hits an Enemy.
- A successful Cast in slots 1–5 occupies one slot, creates no orb, and may continue chaining.
- Cast may establish the chain in slot 1; no previous X is required.
- Cast may chain directly into another Cast when the next attempt succeeds.
- Slot 6 accepts Cast only. A successful slot-6 Cast is the endpoint and ends the chain.
- A failed Cast in any slot immediately breaks the chain.
- Ending or failing a chain does not remove stored orbs. Failed Casting resets their charged state as defined below.

Examples:

```text
X → X → X → X → X
Cast → Cast
X → X → Cast → X → X
X → X → X → X → X → Cast
X → X → Cast → X → Cast
X → Cast → X → X → X → Cast
```

In `X1 → X2 → Cast → X → X`, the Cast occupies position 3; the following attacks use the X4 and X5 presentations.

Every attack and casting animation has a chaining window. Once that window opens, it remains valid through the end of the animation. Inputs before the applicable buffer zone are rushed inputs.

X attacks use independently tunable windup and post-contact recovery durations for each school's X1–X5. Casting retains the shared base animation duration. The normalized chaining-window and pre-window buffer rules remain shared; an accepted follow-up still starts when the current action finishes. Heat accelerates each timing phase once through the same current speed multiplier.

### School melee styles — approved 2026-10-16

Keep the four schools, existing prototype animations, five global X/Cast progression positions and optional sixth-slot Cast endpoint. The temporary proposal to remove the five-position limit was withdrawn. Each move works independently at its global position when schools are mixed; no school-local combo counter, same-school prerequisite, critical-hit rule or extra hit event is introduced.

| School / feel reference | X1 | X2 | X3 | X4 | X5 |
|---|---|---|---|---|---|
| Earth / slow Broadsword | Broad opener | Heavy return | Compact opener variation | Loaded return variation | Full-weight finish |
| Fire / medium Spartan Sandals | Lead hit | Advancing hit | Checking kick | Driving strike | Push-away finish |
| Water / medium War Spear | Reaching opener | Quick follow-up | Close-range check | Extended follow-up | Committed thrust |
| Air / fast Twin Daggers | Opening cut | Reverse cut | Advancing opener variation | Returning follow-up variation | Finishing slash |

The current implementation provides provisional per-move windup, post-contact duration, reach/radius, forward-body distance/phase interval and qualifying-reaction push-distance multiplier. Timing values are seconds before Heat scaling. A zero timing value inherits the corresponding shared-duration phase. The approved October 19 authoring workflow uses native AnimationPlayer sprite/hitbox tracks: scrub a move, edit its visible hitbox, and key the pose. Saved animation geometry is authoritative; Inspector/Portal reach and radius read and edit the contact-time keys. JSON remains authoritative for timing, lunge, Impact and other combat settings. Native zero reach is a point query and radius is positive; legacy custom profiles retain their existing fallback normalization.

Forward motion follows the action's committed facing through the existing collision body; walls block displacement and interruption/reset discards the remaining motion. Early Fire attacks use limited push; its X5 increases separation only when the existing hit-reaction rules qualify. Push scaling changes distance, not reaction eligibility, duration, invincibility, damage or Impact/Poise. Active actions retain the style captured at their start; tuning edits apply to subsequent actions. Native Animation markers still author the active interval and contact boundary.

These are initial feel presets awaiting user playtesting, not accepted final numbers. Existing reaction invincibility still rejects otherwise valid follow-up hits during that interval. Practice-target tempo comparisons and attacking-enemy reaction checks are separate.

X presses and release-Cast requests use one shared normalized pre-window buffer. The buffer width is 20% of normalized action duration. With `combat.input_window_start = 0.48` and `combat.x_buffer_width = 0.20`, the initial buffer zone is `0.28 <= progress < 0.48`. One valid X or release-Cast request may occupy the buffer slot; later requests in that same buffer period are ignored. The buffer applies while the current chainable animation is X or Cast, and does not apply to school switching.

An X buffer stores one school-and-direction action intention without advancing the chain or UI, then promotes it through the normal X acceptance path when the chaining window opens. A buffered release requires charged orbs, consumes them immediately, resolves and freezes the Cast composition and existing Cast fields, then promotes the resolved Cast as the appropriate empowered mid-chain or endpoint Cast when the chaining window opens. Early X remains ignored; an early release before the buffer without a valid request remains a rushed Cast failure. Buffer state does not repeat from held input and clears on interruption, hit reaction, failed Cast, chain completion/reset, or return to `READY`.

## Orb Queue

Every X attack that hits an Enemy performs **Generating** and creates one generated orb matching the attack’s school:

| School | Orb |
|---|---|
| Fire | F |
| Water | W |
| Air | A |
| Earth | E |

Generated orbs form a first-in, first-out queue. A generated orb is an orb produced when a melee X hit lands on an Enemy. A charged orb is a generated orb selected by holding L2 through Charging and made ready to participate in the upcoming Cast.

- The queue stores at most 10 orbs.
- If all 10 slots are occupied, the landed hit still counts as Generating, but the additional generated orb is discarded without changing the stored queue.
- Only the oldest orb counts down toward expiration.
- Its lifetime is ten seconds.
- A newly spawned orb is a solid school-colored disc (Fire is red). As its lifetime falls, the filled region interpolates from 100% to 75%, 50%, 25%, and empty by shrinking from the right edge toward the left; the unfilled region is transparent.
- Later orbs retain their full lifetime while another orb remains ahead of them.
- When the oldest orb expires or is consumed, the next orb immediately begins its full ten-second lifetime.
- Every successful Cast consumes at most the eight charged front orbs. All unconsumed orbs remain and shift forward into the vacated slots while preserving FIFO order.
- When a chain times out after a completed action without a follow-up, the chain state ends but unconsumed orbs remain while Laema is idle or moving and continue their FIFO expiration.
- A failed Cast removes no orbs. It returns every charged orb to the generated state and resets partial charging progress to zero.

Example:

```text
Air X hit → Air X hit → switch Water → Water X hit → Water X hit
Orb queue: A A W W
```

## L2 Pressure and Charging

L2 pressure has three semantic states, and state changes are transition-based:

- Below `5%`: **RELEASE**; one Cast attempt occurs on entry.
- `5–95%`: an intermediate hold. It begins **DEPLETING** only after remaining in that band continuously for more than 0.3 seconds; before then it preserves charged orbs for a release.
- `95–100%`: **CHARGING**; available charging capacity selects generated orbs in FIFO order and charges them for the upcoming Cast.

CHARGING may begin at any time, with or without available generated orbs, and continues while Laema attacks or performs casting animations. Charging capacity selects the oldest available generated orbs in first-in, first-out order.

- Entering CHARGING starts or resumes charging progress.
- Entering the 5–95% intermediate band starts a 0.3-second no-drain hold timer. Returning to CHARGING resets that timer.
- Holding continuously in the intermediate band for more than 0.3 seconds begins DEPLETING, which drains the continuous charging meter at the baseline `charge_step_duration` rate without Heat scaling.
- Entering RELEASE triggers one normal or empowered Cast attempt; holding at full release does not repeat it.
- The prototype begins with 95–100% as CHARGING, 5–95% as the intermediate no-drain hold band, and below 5% as RELEASE; no exact 0% or 100% reading is required.
- Charging capacity increases by one charged orb every nominal 0.5 seconds while CHARGING.
- At baseline speed, the first generated orb becomes charged after 0.5 seconds.
- At baseline speed, maximum capacity is eight charged orbs after 4 seconds.
- Holding longer leaves capacity at eight.
- CHARGING uses the current Heat multiplier. At multiplier `M`, effective step duration is `0.5 / M` seconds.
- DEPLETING uses the fixed zero-Heat Charging rate: one charge-equivalent per baseline `charge_step_duration`, currently 0.5 seconds. It does not scale with Heat.
- Partial progress depletes continuously. Crossing a completed-charge boundary returns the most recently charged orb to the generated state first.
- DEPLETING never consumes or removes queue orbs.
- CHARGING and DEPLETING preserve the active chain and its orb queue beyond the normal idle timeout.
- CHARGING and DEPLETING do not keep movement locked between active X or Cast animations.
- Charging does not pause expiration. If a charged oldest orb expires, the existing charging coverage transfers forward with the shifted queue, preserving the charged count when enough orbs remain.
- When Laema receives an incoming direct-damage `HealthResult` whose outcome is `APPLIED`, every charged orb is removed. Generated but uncharged orbs remain in the queue and continue their normal expiration countdown. `BLOCKED`, `PARRIED`, and DoT results remove no orbs. Final hit-reaction strength does not affect this resource rule.
- Entering RELEASE consumes:

```text
all currently charged orbs
```

Consumption is first-in, first-out. For example, two charged orbs in `A A W W` consume `A A`.

Charged orbs are consumed immediately on RELEASE entry, including a buffered release before the promoted Cast animation begins. If Casting is interrupted before projectile launch, those orbs are not refunded.

After consumption, every unconsumed orb shifts forward into the consumed slots while preserving FIFO order. This applies to normal, mid-chain, and endpoint Casts.

## Casting Outcomes

### Normal Cast

Entering RELEASE while Laema is idle performs a normal Cast when at least one orb is charged. A successful normal Cast occupies the next available slot among slots 1–5 and may establish or continue the chain. `Normal` describes how the Cast was initiated; it does not force the chain to end.

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

- Release is triggered before any orb is charged.
- Release is triggered during an active attack or casting animation before its buffer zone opens.

A failed Cast:

- cancels the active attack or casting animation;
- produces no projectile or spell effect;
- ends the chain, leaves every stored orb in the queue, returns all charged orbs to the generated state, resets partial charging progress to zero; and
- applies the existing level-1 light flinch and recovery to Laema.

Entering RELEASE while idle is not a timing failure. It succeeds when at least one orb is charged.

## Mixed-School Resolution

The consumed charged-orb sequence alone determines the spell output. The currently selected school does not override or otherwise modify this resolution.

1. The school of the final consumed orb becomes the primary school, using last-in, first-out selection.
2. Primary casting level equals the total number of consumed orbs, from level 1 through level 8.
3. After removing the primary school from consideration, the remaining school with the greatest consumed-orb count becomes the single secondary school.
4. If secondary candidates tie, whichever tied school appears last in the consumed sequence becomes secondary, using a last-in, first-out tie-break.
5. Secondary casting level equals that school's own consumed-orb count.
6. A Cast resolves at most one secondary layer. Other represented schools produce no casting layer, although their charged orbs are still consumed and still count toward the primary casting level and commitment-time Heat.

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
- uses the Impact configured for its Spell Level, falling back to the base Cast Impact when no level override exists; and
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

The current prototype starts Player and Enemy maximum Health at 100. X attacks retain their current direct damage; Fire Impact follows the progression below. Casting projectile hits use generic direct damage for the resolved primary and optional secondary layers.

### Poise and qualifying combat reactions — formula updated 2026-10-16

Each attack has Attack Impact in 0–100, and Player/Final Enemy Poise is defensive in 0–100. Hit-reaction value = incoming Attack Impact − receiving character's Poise − receiving character's active-move Impact. The receiving move contributes only during authored active frames capable of triggering its hit event; startup/windup, recovery and idle contribute 0. Attacker Poise is never an offensive bonus.

A melee clash requires physical contact and overlapping active intervals. Both receiving-side values are captured at that contact; a positive value interrupts its receiver, cancelling that move before its damage can apply. The Final Enemy discards the cancelled attack and reassesses afterward. A counter that wins at this established contact does not need a separate reverse query.

October 16 user decision: when neither side has a positive value, connected hits deal normal damage without flinching and both attacks continue. A later reverse hit still needs physical contact; an inconclusive clash does not manufacture one. The explicit exception is an exact 0/0 active clash: Player wins, applies its connected damage once, and the enemy receives the configured Level 1 reaction. A single zero against a negative opposite value is not this exception.

| Difference after eligibility | Level | Duration | World-space displacement |
|---|---:|---:|---:|
| 0–10 | 1 | 0.6 s | 5 px |
| 11–20 | 2 | 0.9 s | 10 px |
| 21–30 | 3 | 1.2 s | 15 px |
| 31–40 | 4 | 1.5 s | 20 px |
| 41+ | 5 | 1.8 s | 25 px |

The table gives the current starting tuning values, revised by the user on 2026-10-14 to start at 0.6 seconds and increase by 0.3 seconds per level. This tuning awaits gameplay validation. Reaction durations and distances are now editable per level in the Godot Inspector and Developer Portal; the five value bands are now configurable through each level's starting value (October 15 refinement). Eligibility rules are not changed by this range configuration.

Zero qualifies only for that exact 0/0 Player-winning active-clash exception; zero outside a clash and other non-positive values cause no combat reaction. The whole character and collision body are pushed backward over the full duration and remain at the new position. Walls can stop the push. The current candidate uses uniform displacement without an additional easing treatment.

The qualifying combat-reaction duration is invincible against further damage and reactions. Failed-Cast self-reactions grant no invincibility. Existing defence interception and its reaction behavior remain unchanged pending a separate defence decision. Stationary, non-attacking, pass-through practice targets retain their existing recoil and finite-health refill behavior.

One mixed Cast resolves its primary and secondary layers in order before starting invincibility. Already active effects are retained and continue advancing; damage ticks received while invincible are rejected. Melee/spell damage rejected by invincibility or clash cancellation is not an applied hit and does not grant hit-dependent resources or change Elemental Endurance. Spell-vs-melee clash rules and further school/status interactions remain deferred.

Each move has an independent JSON data record for its animation and existing damage/duration sources. The October 16 school-style implementation adds Player X timing, geometry, forward-lunge distance/phases and qualifying-reaction push scaling. Individual Impact and character-poise tuning remain separate, exposed through the shared Inspector Resource and mirrored to JSON. Style overrides do not change Impact, Poise or reaction bands; final tuning remains open. Cast and Final Enemy do not use the Player X style overrides.

### Fire X and leveled Cast reaction progression

Fire X1–X5 produce progressively stronger combat reactions. Cast Spell Levels 1–4 use the corresponding reaction progression:

| Fire attack | Cast Spell Level | Attack Impact | Reaction against the Gym opponent outside its active swing |
|---|---|---:|---:|
| X1 | 1 | 10 | Level 1 |
| X2 | 2 | 20 | Level 2 |
| X3 | 3 | 30 | Level 3 |
| X4 | 4 | 40 | Level 4 |
| X5 | — | 50 | Level 5 |

The existing receiver-side formula still applies. The Gym opponent has 1 Poise, so these Impacts produce values 9, 19, 29, 39 and 49 when it is idle, winding up or recovering. Its active move contributes additional resistance and can reduce or prevent the reaction. These are not forced reaction levels that bypass Poise or active attacks.

The hurt animation belongs to the qualifying combat reaction: it starts with stagger and whole-body knockback, uses the selected reaction's duration, and ends with that reaction. A damaging hit that does not qualify causes no separate hurt animation. Existing reaction invincibility and collision behavior are retained.

Each Cast layer uses its own Spell Level to select Impact. Mixed Casts resolve both layers before the strongest qualifying reaction begins. Cast damage, empowerment, Charging and Heat behavior are unchanged. Cast Levels 5–8 retain the existing base Cast Impact; their reaction progression is not assigned by this change. Other schools' X Impacts are unchanged.

Active frames are authored with `active_start` and `active_end` Animation markers. A separate `contact` marker retains the once-per-action hit/launch event. Each Player X has its own animation clock; the provisional active end is the end of its swing. Final Enemy has a marked melee animation clock. The user tunes these markers in Godot.


Heat ranges from `0` to `100`. Attack speed scales linearly with Heat: `0` Heat produces the `100%` baseline attack speed, and `100` Heat produces `150%` attack speed. Intermediate Heat values produce proportionate attack speed.

Each charged orb consumed by Casting adds `2` Heat. Orb consumption is the only current source of Heat gain. Heat is granted immediately when a Cast commits and consumes charged orbs, including a buffered Cast committed before its animation begins. Interruption before launch and projectile miss do not revoke that Heat. Direct X hits, projectile impacts, and any deferred spell behavior add no Heat.

The Heat Reset Timer is refreshed by either a landed direct X hit or a landed direct spell projectile hit. DoT ticks do not refresh it. After five seconds without either qualifying landed hit, Heat begins depleting smoothly and linearly at `3` Heat per second until it reaches `0`.

When Laema receives an incoming direct-damage `HealthResult` from an opponent whose outcome is `APPLIED`, Heat decreases by `5` and cannot fall below `0`. For example, a qualifying hit at `20` Heat reduces it to `15` Heat, changing attack speed from `110%` to `107.5%` under the linear mapping. `BLOCKED`, `PARRIED`, and DoT results cause no Heat loss. Final hit-reaction strength does not affect this resource rule.

**Deferred direction:** Future school-level spells may add Heat directly. Every such rule and value remains open.

## Enemy and Feedback

Each tutorial stage owns its area contents and entity instances independently; later stages may deliberately duplicate earlier targets or enemies. Stage 1 and Stage 2 each contain exactly one stationary, non-attacking, permanent target with identical behavior. Damage is capped at its remaining Health; reaching zero resolves normally and then immediately refills it to full Health without clearing active effects. The existing prototype arena is the final tutorial area and retains its three permanent practice targets plus its killable final Enemy.

Training targets are pass-through and never physically block Laema's movement. The final Enemy is solid: Laema cannot move through or pass it. All current targets remain valid X and projectile targets.

Each target displays the school and level of every successful Cast layer that deals Health damage. A fully resisted Cast layer displays `0` damage without its school-and-level label. School-specific status displays other than the tutorial-only Elemental Endurance buff below are deferred with the spell behaviors they would represent.

### Elemental Endurance — Tutorial-Only Buff

Elemental Endurance is currently a tutorial-only protective buff for the tutorial's final Enemy. It showcases Laema's school-changing and Casting systems without becoming the later boss-like skill test. This buff is not yet a general rule for other enemies or the final game.

The Enemy tests whether the player recognizes Elemental Endurance and changes schools. If it survives through hit 9 of one school's streak, hit 10 and later become fully resisted and a school change is required to resume direct damage. Single-school melee is therefore not guaranteed to defeat this Enemy.

Only physically landed attacks whose defence resolution is `APPLIED` participate in Elemental Endurance. A fully resisted same-school attack remains an `APPLIED` contact, but it does not advance the streak beyond the hit-10 cap. One player action advances its school streak at most once, regardless of how many direct-damage `HealthEvent`s the action produces. Blocked and parried actions neither advance nor reset the streak.

Consecutive landed actions from the same school use the following damage percentages:

| Same-school hit | Damage dealt |
|---|---:|
| 1–5 | 100% |
| 6 | 50% |
| 7 | 40% |
| 8 | 30% |
| 9 | 20% |
| 10 and later | 0% |

Hit 6 activates the protective buff. The 0% state persists until an action from another school successfully lands.

A landed action from another school:

- deals full damage;
- clears the previous school streak;
- removes the existing protective buff; and
- becomes hit 1 of the new school's streak.

A mixed-school Cast is an exception to ordinary streak replacement. It clears Elemental Endurance, removes the protective buff, deals full damage with both school-damage layers, and leaves no active school streak. The next landed single-school action becomes hit 1. Its primary and secondary layers display separate floating damage numbers, each showing that layer's final Health loss after modifiers.

DoT ticks use the Enemy's current damage percentage for their school, but they never advance, reset, or replace the streak. A landed same-school action at hit 10 or later remains capped at 0% damage until a different school successfully lands.

At `50%`, `40%`, `30%`, or `20%` damage, the action's non-damage effects still apply normally. At `0%` damage, newly applied same-school status effects and orb generation are suppressed. Existing effects are not removed; for example, an already active same-school DoT continues ticking at the current 0% damage percentage without changing the streak. Impact, Enemy hit reaction, and Heat Reset Timer refresh remain explicit exceptions to this suppression.

A same-school direct hit that lands at `0%` damage still refreshes the Heat Reset Timer and resolves its normal Impact and Enemy hit reaction. A same-school X hit at `0%` does not generate an orb. A fully resisted Cast layer displays its final damage feedback as `0` without displaying its school-and-level label.

When active, the protective buff displays an icon above the Enemy's head. The icon color identifies the resisted school. A number in the icon's lower-right corner displays the percentage of incoming same-school damage that remains: `50`, `40`, `30`, `20`, or `0`.

Floating damage numbers always display the final Health actually lost after Elemental Endurance, blocking, and every other damage modifier. A final Health loss of zero still displays `0`. Every DoT tick displays its final damage number using a much smaller font than direct-hit damage.

### First Enemy Attack Pattern

The final Enemy attacks while the player works through the school-switching test. Its first-pass behavior uses one repeating pattern:

```text
approach → commit to Laema's current position → wind up → active swing → recover → repeat
qualifying hit / losing clash → abandon attack → hit reaction → reassess
```

- The attack commits to its position and direction when windup begins.
- A hit with incoming Impact above character poise interrupts windup. A losing active-frame clash also cancels the attack. After reaction, the Enemy reassesses instead of resuming the cancelled attack.
- The attack does not track Laema after committing.
- If Laema leaves the committed attack area before contact, the attack misses completely.
- Hits and misses use the same recovery period.
- No separate miss indicator is required; unchanged Player Health communicates the miss.
- The Developer Portal includes a Player 1-HP Floor option, enabled by default for this prototype. While enabled, no damage source can reduce Laema below `1` Health. Disabling it removes the floor. No Player death or restart state is introduced.

The current first-pass values remain tunable placeholders: `600 px` awareness range, `72 px` attack range, `90 px/s` approach speed, `0.6 s` windup, `10` damage at Impact `1`, and `0.9 s` recovery.

The always-visible game UI includes:

- a school-colored FIFO orb queue with all 10 storage slots always visible, including empty slots; and
- a smooth L2 charging-progress bar beneath the orb queue, showing completed charges plus progress toward the next available orb, divided by eight; and
- a Spell Level readout equal to the current number of charged orbs, from level 0 through level 8.

Consumed, expired, and hit-lost charged orbs disappear. Each charged orb uses a 2 px gold outline while retaining its school-colored fill. The actively expiring oldest orb displays its remaining lifetime through a left-filled reverse progress indicator whose empty portion grows right to left.

The charging-progress bar fills and drains smoothly between completed charges.
Three charged orbs with the next available orb half charged show 3.5/8 on the bar;
Spell Level remains 3 until the fourth orb becomes charged. The bar is capped by
the number of available orbs, up to eight: an empty queue shows zero, and three
available, fully charged orbs cap the bar at 3/8. Banked capacity beyond available
orbs does not fill the bar. Charging and its banked capacity retain their existing
gameplay behavior.

When a generated orb is discarded because all 10 slots are occupied, the entire orb widget performs a UI-only horizontal flinch: 4 px left, 4 px right, then back to rest over approximately 0.12 seconds. Each discarded orb restarts the flinch from the widget's resting position. This feedback never interrupts Laema, movement, actions, or chain state.

The prototype developer overlay contains:

- the upper-left Heat, Player Health, Enemy Health, and defence readouts;
- the upper-center active-school, five-position-chain, and completed-chain readouts; and
- an upper-right gauge showing L2’s live raw pressure percentage.

The backtick Developer Portal has a shared header with Save to JSON, status, and Close controls, followed by three top-level tabs:

- **General:** Movement, Player, Enemy, UI, and the saved developer-overlay visibility flag. Gravity Scale is intentionally omitted from the Portal control surface.
- **Audio:** Ambient, SFX, and BGM groups. Each group has an Enabled control and a `0–100%` Volume control.
- **Combat:** nested sub-tabs for Combat, Casting, Heat, Fire, Water, Air, Earth, Defence, and Hit Reaction. The Combat sub-tab contains attack-hitbox visibility, the `collect_orb_without_contact` testing toggle, and the Combat controls. When enabled, a missed X can collect an orb without applying damage; the persisted prototype config currently has this test toggle enabled.

Audio controls apply immediately and persist through the same fail-fast JSON save/load flow. Ambient controls the wind loop; SFX controls attack, cast, orb, projectile, cast-failure, guard-warning, and hit-reaction feedback; BGM controls the Fairy Battles music loop. Each newly charged orb uses the fixed-volume charged-orb cue at eight ascending pitches: Do, Re, Mi, Fa, Sol, La, Ti, Do. Charging all eight orbs completes the scale. The Portal expresses normal mix volume as `100%` and silence as `0%`; its internal mixer representation is not player-facing. These controls do not affect the orb queue, L2 charging-progress bar, target status display, target overhead Health display, or gameplay rules.

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

Stage 1 begins with Fire selected and `0` Heat. At the beginning of every stage after Stage 1, Laema receives a full combat reset: full Health, `0` Heat, an empty orb queue, no charging progress, no active chain, no buffs or debuffs, and a ready defence state. The currently selected school carries forward instead of resetting.

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

Stage 2 teaches that orbs generated through melee attacks can be charged and spent through Casting. The player may accumulate generated orbs through any attacks, chains, or schools.

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
- Movement, melee attacks, defence, school switching, Charging, DEPLETING, and other unrelated actions do not fail the stage.
- The persistent ten-slot combat orb queue remains unchanged and provides all generated-orb and charged-orb feedback; the Stage 2 objective widget does not duplicate that progress.

Completion is permanent, turns the whole objective widget green, displays `moving on ->`, and unlocks the right boundary through the reusable stage-progression shell.

### Stage 3 — Charge While Attacking, then Cast

Stage 3 teaches the player to begin Charging while starting a five-position attack chain, continue Charging while attacking, and release L2 for an endpoint Cast. It contains one stationary, non-attacking, permanent refill target matching the targets in Stages 1 and 2.

The objective widget displays:

```text
Charge while attacking, then Cast
Hold L2 + X → X → X → X → X → Release L2
```

Stage 3 succeeds when the player lands five X attacks in one uninterrupted chain, then enters a level-5 Cast in the endpoint chaining window after X5.

- The L2 timing is instructional guidance only. The evaluator does not require L2 and the first X to begin simultaneously, and it does not fail when Charging begins later.
- All five X attacks must physically hit the target.
- The five X attacks may use any school composition permitted by the existing chain rules.
- The Cast's school composition does not affect success.
- The Cast must launch at level 5; projectile impact is unnecessary.
- Each valid X hit turns the corresponding attack step green; the first step advances on the first valid X regardless of when L2 Charging began.
- After X5 lands, `Release L2` receives a bright white highlight to show that it is the required next input.
- A valid level-5 endpoint Cast turns `Release L2` green and permanently completes the stage.
- An X miss, a broken chain, a failed Cast, or a launched Cast below level 5 lightly flinches the whole widget and resets the attempt.

Completion turns the whole objective widget green, displays `moving on ->`, and unlocks the right boundary through the reusable stage-progression shell.

### Stage 4 — Mid-Chain Cast Continuation

Stage 4 teaches that Cast can occupy a position inside an active chain and that the player may continue the chain afterward. It contains one stationary, non-attacking, permanent refill target.

The objective widget displays:

```text
perform X, X, Cast, X
Hold L2 + X → X → Release L2 → X
```

Stage 4 succeeds through one uninterrupted `X -> X -> Cast -> X` chain.

- All three X attacks must physically hit the target.
- The Cast must be accepted as position 3 of the active chain; an isolated Cast does not count.
- The Cast may use any available level or school composition.
- The Cast counts when it launches; projectile impact is unnecessary.
- The final X uses position 4 and must physically hit. Stage completion occurs on that X4 hit, not on Cast launch.
- The objective tokens use the established green progress and bright-white next-step highlight behavior.
- An X miss, broken chain, failed or isolated Cast, or wrong action order lightly flinches the whole widget and resets the attempt.

Completion turns the whole objective widget green, displays `moving on ->`, and unlocks the right boundary through the reusable stage-progression shell.

### Stage 5 — Multiple Casts in One Chain

Stage 5 teaches that Cast is an alternative chain input to X and that a chain may contain more than one Cast. It contains one stationary, non-attacking, permanent refill target.

The objective widget displays:

```text
perform X, Cast, X, Cast
Hold L2 + X → Release L2 → Hold L2 + X → Release L2
```

Stage 5 succeeds through the exact uninterrupted `X -> Cast -> X -> Cast` sequence.

- Both X attacks must physically hit the target.
- The two Casts occupy positions 2 and 4.
- Each Cast may use any available level or school composition.
- Each Cast counts when it launches; projectile impact is unnecessary.
- Stage completion occurs when the second chained Cast launches.
- The objective tokens use the established green progress and bright-white next-step highlight behavior.
- An X miss, broken chain, failed or isolated Cast, or wrong action order lightly flinches the whole widget and resets the attempt.

Completion turns the whole objective widget green, displays `moving on ->`, and unlocks the right boundary through the reusable stage-progression shell.

### Stage 6 — School Switch During a Chain

Stage 6 teaches that the player may change schools without ending an active chain. It contains one stationary, non-attacking, permanent refill target.

The objective widget displays:

```text
change school during a 5-hit combo
X - X - SWITCH - X - X - X
```

Stage 6 succeeds through one uninterrupted five-X chain with a school switch specifically between X2 and X3.

- All five X attacks must physically hit the target.
- The school selected after X2 must differ from the starting school; any two distinct schools qualify.
- The switch input does not consume a chain position.
- The objective tokens use the established green progress and bright-white next-step highlight behavior.
- An X miss, broken chain, missing or mistimed switch, or attempted switch back to the original school lightly flinches the whole widget and resets the attempt.
- Stage completion occurs when the final X5 physically hits the target.

Completion turns the whole objective widget green, displays `moving on ->`, and unlocks the right boundary through the reusable stage-progression shell.

### Stage 7 — Build Heat and Complete a High-Heat Chain

Stage 7 combines observing Heat acceleration with demonstrating a complete five-X chain at high Heat. It begins at `0` Heat and contains one stationary, non-attacking, permanent refill target.

Both objectives remain visible throughout the stage:

```text
Build Heat to 80
Perform an XXXXX combo at 80 Heat or higher
```

The first objective is live rather than permanently completed. It turns green while Heat is `80` or higher and returns to its default color whenever Heat falls below `80`.

The second objective begins only when X1 of a fresh chain lands while Heat is `80` or higher. Reaching `80` Heat during X2–X5 of an existing chain does not begin an attempt; the player must begin a new chain. The stage succeeds when X1 through X5 all land in that uninterrupted chain while Heat remains at least `80` throughout.

- The second objective displays five `X` markers, and each valid landed X turns its corresponding marker green.
- Each landed X refreshes the Heat Reset Timer.
- Any school composition is valid, and school switching is allowed.
- A missed X, premature chain termination, or Heat falling below `80` invalidates the active attempt.
- Invalidation lightly flinches the whole objective widget and resets all five `X` markers. The first objective's color continues to reflect current Heat.
- Unrelated actions taken before an attempt begins do not fail the stage.
- Reaching `80` Heat alone does not complete the stage or trigger a transition.

Completing the five-X objective turns the whole widget green, displays `moving on ->`, and unlocks the right boundary through the reusable stage-progression shell.

### Later Tutorial Stages

Stages 1 through 7 are locked. No Stage 8 objective is currently locked. Any later stage must define its own area contents and attempt rules through the reusable progression and widget shells.

### Tutorial Completion and Free Practice

Stage 1 transitions through Stages 2, 3, 4, 5, 6, and 7 in order. Stage 7 transitions directly into the existing prototype arena, which serves as the legitimate final tutorial stage. Any future tutorial stages are inserted between Stage 7 and this final arena.

The final tutorial objective remains `Defeat the final Enemy`. When that Enemy dies, the tutorial completes permanently and the objective widget immediately changes to the free-form text below. There is no separate completion screen, delay, animation, or intermediate message. The final arena remains loaded and becomes the indefinite free-form practice area; there is no additional right exit or camera-pan transition. Its permanent practice targets remain available.

The objective widget switches to the free-form state, remains visible indefinitely, has no progress row, and displays:

```text
now you are free
```

## Tunables and Validation

Prototype tunables include movement speed, gravity, attack and casting duration, contact/trigger phase, chaining-window start, projectile speed and distance, direct damage, orb lifetime, L2 Charging interval and capacity, L2 pressure thresholds, empowered multiplier, Heat gain, Heat Reset Timer duration, Heat depletion rate, Elemental Endurance percentages, the Player 1-HP Floor option, defence, Impact, hit reactions, statuses, Health, and feedback duration.

The prototype must make the following observable:

- grounded left/right movement and horizontal camera following;
- five-position chaining with X and mid-chain Casts;
- all four school X attacks and hit-generated orbs;
- 10-orb FIFO storage with all slots permanently visible, an eight-orb Charging/Cast limit, Spell Level presentation from 0 through 8, and preserved queue order after every successful Cast;
- failed Casts preserving stored orbs while returning charged orbs to the generated state and resetting partial charging progress;
- gold charged-orb outlines plus full-queue discard and whole-widget flinch feedback;
- normalized X/L2 pre-window buffering at baseline and high Heat, including first-request arbitration, promotion, and clear/invalidation behavior;
- school switching remaining available regardless of chaining-window timing, CHARGING or DEPLETING state, and prior switches, without consuming a chain position, buffered input, or other chain/input capacity;
- the default contact requirement and the Developer Portal's optional no-contact orb-collection test toggle;
- the Stage 1 area contains one stationary, non-attacking, permanent target that accepts X and projectile contact, displays its own Health and Cast-level feedback, and refills at zero Health;
- FIFO orb expiration, right-to-left reverse orb progress, charge transfer, and consumption;
- simultaneous L2 Charging and attacking;
- L2 CHARGING, DEPLETING, and RELEASE bands, transition behavior, fixed-rate newest-charged-first depletion, and release-Cast behavior;
- default-visible developer readouts, upper-right live raw L2 pressure, shared visibility toggling, and saved visibility restoration;
- Developer Portal tab organization plus live, saved Ambient/SFX/BGM enabled and volume controls;
- an always-visible orb queue and L2 charging-progress bar independent of the developer-overlay flag;
- charged-orb and five-point Heat loss only on incoming `APPLIED` direct damage, including zero-reaction results, while `BLOCKED`, `PARRIED`, and DoT results cause neither resource loss;
- every stage beginning at `0` Heat;
- linear Heat-to-attack-speed mapping from `0` Heat at `100%` attack speed to `100` Heat at `150%` attack speed, including intermediate values;
- two Heat gained per consumed charged orb, with orb consumption as the only current Heat-gain source;
- direct landed X and spell-projectile hits refreshing the five-second Heat Reset Timer while DoT ticks do not, followed by smooth linear depletion at `3` Heat per second;
- proportional Heat acceleration of attacks, casting animations, and L2 Charging;
- movement locked during active X/Cast animations and restored between actions while CHARGING or DEPLETING preserves the chain;
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
- the complete Stage 2 level-5 Cast success, lower-level and empty-Cast failure feedback, target, text-only UI, and transition behavior;
- the complete Stage 3 five-hit chain into a level-5 endpoint Cast, including launch-based success, invalidation, target, six-step UI, and transition behavior;
- the complete Stage 4 mid-chain Cast continuation sequence, including X4-hit completion, invalidation, target, four-step UI, and transition behavior;
- the complete Stage 5 multiple-Cast sequence, including second-Cast launch completion, invalidation, target, four-step UI, and transition behavior;
- the complete Stage 6 school-switch sequence, including switch timing, five-hit completion, invalidation, target, six-step UI, and transition behavior;
- Stage 7 beginning at `0` Heat with both objectives visible, showing its first objective green only while Heat is at least `80`, ignoring threshold crossings during X2–X5, beginning its second objective only when X1 of a fresh chain lands at `80` Heat or higher, advancing five green `X` markers through landed attacks, allowing school switching, invalidating on an X miss, premature chain termination, or Heat falling below `80`, completing only after five uninterrupted landed X attacks while Heat remains at least `80`, and transitioning directly into the Final Arena;
- tutorial-only Elemental Endurance counting each landed applied action at most once, excluding blocked/parried actions and DoT ticks from streak changes, applying current resistance to DoT damage, allowing non-damage effects at partial resistance while suppressing new same-school effects at 0%, withholding orb generation while preserving Heat Reset Timer refresh and normal Impact/hit reaction on a 0%-damage same-school X hit, clearing on a different-school hit or mixed-school Cast as defined, displaying its school and remaining damage percentage, showing smaller final-damage numbers for DoT ticks including `0`, and showing `0` without a school-and-level label for a fully resisted Cast layer; and
- the final Enemy physically blocking Laema, approaching, committing one non-interruptible attack to Laema's position at windup start, missing when she leaves that area, using the same recovery after hits and misses, and all incoming damage respecting the default-enabled Player 1-HP Floor option; and
- the existing prototype arena as the final tutorial area, followed in place by its indefinite `now you are free` free-practice state.

Incoming Enemy attacks, body blocking, committed-position misses, both states of the Player 1-HP Floor option, and ordinary-play blocking, parrying, guard depletion, guard warning, and guard break require user validation in Godot.

Still open or deferred: jumping, non-flat level geometry, Air and Earth defence, additional Enemy behavior and attack patterns, Player defeat behavior when the Player 1-HP Floor option is disabled, all school-level spell behaviors, final balance, final casting and projectile assets, final Laema presentation, and complete enemy content.

## Future Game Direction — Mirham

**Implementation boundary:** This section is outside the active prototype scope. It creates no prototype requirement, acceptance criterion, or implementation task. Code work must skip it unless the user explicitly assigns a Town Design slice.

**Decision:** Mirham is Laema's recurring buildable hub. Laema helps develop it across the campaign. Mirham is distinct from Cloudfire and Steadwick.

**Decision:** Cloudfire is a nearby recurring location, not the buildable hub. Its people, routines, and places become familiar before its destruction.

**Narrative context:** Mirham is near and readily accessible from Cloudfire. After Cloudfire falls, survivors retreat toward Mirham; the eventual final defence occurs at Mirham before Catherine reaches Cloudfire. The exact outcome and wider narrative consequences remain open.

### Narrative Context

**Decision:** Laema is a local original protagonist with no personal connection to the royal court. She helps develop Mirham across the campaign.

**Decision:** Laema recognizes the symptoms of a poison previously encountered near her town. The same poison is later used against King Nicolas Gryphonheart.

**Decision:** The established late sequence is: Cloudfire falls; its defenders and survivors retreat toward Mirham; Mirham faces its final defence; Catherine later reaches ruined Cloudfire; and the opening of *Heroes of Might and Magic III: The Restoration of Erathia* begins.

**Proposal:** The Laema story is a local tragedy immediately before *Restoration of Erathia*, following people trying to preserve a home while the wider historical catastrophe reaches them.

**Narrative source material — not decisions:** Earlier Miro notes explored a message-delivery and hold-the-line premise, a possible bridge into the Heroes III opening, alternate-history outcomes, settlement growth, and Sandro-era reinterpretations. These remain reference material only; they create no current story requirement.

**Historical reference — not canon:** The relevant Heroes III setting chronology places *The Shadow of Death* before *Restoration of Erathia*, with *Armageddon's Blade* following later. Laema's exact placement, scope, and relationship to those events remain unresolved.

**Open:** The antagonist; Laema's precise investigation and poison connection; causal transitions into the invasions; what causes Cloudfire's fall to lead to Mirham; the outcome and cost of Mirham's final defence; what Laema wants before the war intrudes; and the emotional heart of the story.

**Validation:** No narrative gameplay implementation, runtime validation, or narrative playtest evidence exists.

**Proposal:** Mirham becomes a lived-in action-RPG hub inspired by Whiterun, Novigrad, and Vernworth. It has services, merchants, residents, quests, visible cumulative growth, and meaningful resource contribution.

**Proposal:** Laema suggests construction to the town owner rather than directly ruling Mirham. A parked candidate links creature-related quests to new inhabitants settling in the town.

**Open:** What makes Mirham worth building from the beginning; the construction and resource loop; town ownership; player agency; investment tradeoffs; the effects of growth; player attachment; failure consequences; Mirham's geographic and political relationship to Cloudfire; the qualities to carry forward from its reference cities; whether the creature-settlement candidate survives; and how earlier development changes the final defence.

**Validation:** No Town Design implementation or runtime evidence exists.


## Inspector and Developer Portal Combat Tuning

Select PrototypeArena's CombatTuning node and expand Settings in Godot's Inspector. Its shared resource exposes Player and Final Enemy poise, every move's Impact, and the duration/distance of combat reaction Levels 1–5. A separate legacy group exposes the existing practice-target, defence and failed-Cast visual-reaction settings.

The Developer Portal edits the same effective values through General/Player and Enemy AI, Combat/Moves, and Combat/Hit Reaction. JSON owns numerical combat tuning, while the October 19 native-animation authoring workflow owns melee geometry and sprite frames; the combat Resource remains an Inspector view. Local Inspector edits merge into validated JSON. During play, Remote Inspector and Portal changes apply live; Save Tuning persists JSON and the Inspector mirror. Direct JSON edits refresh the local Inspector while the Arena scene is open.

Reaction duration, displacement and invincibility are captured when the reaction starts. Changing reaction tuning affects subsequent reactions and does not shorten one already running. AI decision timing/enable changes retain their existing reset behavior.

### Native attack authoring — approved 2026-10-19

A move-settings resource must lead to its underlying flipbook animation. Use
Godot's existing AnimationPlayer timeline to scrub sprite frames and visually
edit/key the Player and Enemy hitbox. Gameplay and Portal geometry use that saved
authoring source. Geometry at the existing contact marker performs one melee
query per action; extra keyed poses do not introduce extra hits. Author right-
facing poses; left-facing attacks mirror horizontal coordinates. Active attacks
retain their committed pose when tuning changes. Enemy approach distance is
separate from hitbox geometry. Existing animation frames, starting frame pacing,
combat timing, damage, Impact/Poise, reactions and Casting rules are preserved.
See `docs/ATTACK_STYLES.md` for the native editor workflow. Implementation is a
candidate awaiting the user's interactive editor/gameplay validation.

## Focus editor development dock — 2026-10-15

User decision: implement the approved Focus editor as a Godot editor plugin. It
edits the same saved configuration as the in-game Developer Portal without
requiring the game to run or the Arena scene to be open. This is development
tooling; no combat rules or tuning values are selected by this change.

The dock provides categories, draft editing, saved/active value readbacks,
review/save, revert and reload. Saving and applying to the running game are
separate actions. Current-session stage loading and pause/resume require a
connected debug game. Startup stage/school apply on the next run. Attack-hitbox
visibility is now a saved UI/debug setting, retaining its prior enabled default.

All existing Portal settings share field definitions and validation with the
dock. Nested Earth levels are also exposed. Fixed invariants and intentional
hidden compatibility fields stay constrained; animation markers and stage
definition authoring retain their existing workflows. Legacy school controls
remain present and dormant where documented.

Implementation validation is recorded separately in IMPLEMENTATION_STATUS.md.
The user's mockup acceptance does not establish actual editor or gameplay
validation.

Navigation refinement: the user requested separate sections rather than one
flat root category list. The dock separates General, Combat, Schools, Audio,
Tutorial and Session, retaining the draft across navigation. Fire/Water/Air/Earth
categories have no blanket legacy label. Individual effect settings not consumed
by current Casting are marked as such; active attack-presentation settings are
unmarked. This distinction does not activate or remove any school behavior.

The dock is named Laema Dev Portal. Its Hit reactions page includes a user-driven
series-fill operation: infer a starting value and per-level increment from the
first two levels, edit those rules, preview the five results, then fill Duration,
Distance or both in the draft. Save/apply remain separate. This does not change
gameplay tuning automatically. The subsequent range-configuration refinement
also allows starting-value series fill, while preserving Level 1 at 0.

Series fill also supports the exposed Water and Earth level tables. It fills
only selected editable numeric fields, using each field's existing bounds and
level spacing. Water's fixed Wet/Frozen slow amounts and status names stay fixed.
Unused-by-current-Casting labels still apply to the school-effect values; this
editing tool does not activate their effects.

Reaction settings use one collapsible Levels 1–5 section; opening it shows all
five Starting value/Duration/Distance entries under plain level headings. The
Hit-reaction levels page derives each upper bound from the next level's start,
rejecting duplicate or reversed starts. Legacy reactions have a separate page. Combat →
Impact groups X1–X5 by school, plus separate Cast and Enemy attack controls.
Each school can edit or fill its existing per-move Impact values independently.
These UI changes select no new tuning and do not alter Poise/clash/reaction rules.

## Combat Gym

`scenes/gym.tscn` is the single development encounter, launched by F5, F6 or
Laema Dev Portal → Run gym. The previous separate Fire benchmark is retired.
It contains Fire-only Player and one killable opponent, starting 160 pixels
apart in the bounded Gym room. Player starts at 100 Health and the opponent at
200, with provisional opponent Poise 1 and move Impact 20. The Gym disables
contact-free orbs, the Player 1-HP floor, opponent refill and Elemental Endurance.
Defeat the opponent while surviving; there are no required parry/Cast quotas.
Victory or defeat stops the encounter and offers Retry. Start/Esc offers the
same Retry gym action. Retry restores both actors, starting positions, Fire,
empty orbs, zero Heat, buffered actions and the saved encounter profile.

Player Fire X windup/recovery and Cast animation durations take 1.5 times their
normal time, as do the opponent's windup and recovery. Charging retains its
existing rate and Heat acceleration. The tutorial retains its shared timing,
Endurance and killable final Enemy; the Gym's private tuning does not rewrite
shared configuration. Runtime Portal/Remote Inspector edits are run-only.

The Gym retains its contact-time Impact/Poise formula readout. Developer Overlay
Visible and F4 show/hide the formula panel and telemetry together. Retry clears
contact history, rebinds both fighters and retains the current overlay visibility.
Editor Review & save sets the default visibility for future launches; in-game
Gym saving and shared editor apply remain disabled. The smooth charged-orb bar
above applies throughout the prototype.

## Pause menu — 2026-10-15

User request: controller Start pauses the game and displays a pause-menu HUD.
Start and keyboard Esc toggle the same menu. Resume also accepts controller
confirm, and controller directional input navigates the buttons. The menu offers
Resume and Restart encounter; the tutorial uses its existing stage-reset path,
and the Gym reloads the complete encounter. Restart is disabled during transitions.
In the Gym, this action is labelled Retry gym and restores the Player and Enemy
at their starting positions before resuming.

The menu pauses the gameplay tree and stays responsive while paused. It remains
available when developer readouts are hidden. Opening the in-game Dev Portal
closes the pause menu; opening the pause menu closes the Portal. The editor's
pause/resume command uses the same visible menu. Pause, resume and manual restart
do not save configuration or change tuning. Physical controller operation and
visual presentation still require user validation.
