# Laema Side-Scrolling Orb Casting Prototype

Current design, consolidated October 20, 2026. Implementation candidates and scoped evidence are recorded in [Implementation Status](IMPLEMENTATION_STATUS.md); acceptance of earlier versions does not validate the full current tree.

**Resolved decisions — October 20:** keep the current shorter reaction durations of 0.25/0.55/0.85/1.15/1.45 seconds for Levels 1–5. Cast commitment and qualifying landed direct hits each restart the five-second Heat Reset Timer. Both former documentation conflicts are resolved; these selections do not add runtime-validation evidence.

[Pre-housekeeping document](history/2026-10-20-document-housekeeping/sources/docs/GAME_DESIGN.md) preserves earlier wording, superseded rules, experiment reports and the detailed validation checklist. Historical snapshots are not current requirements.

## Selectable combat creatures — October 22

**Decision:** Add the Castle Griffin alongside Pikeman as a selectable opponent,
using the existing grounded approach, committed melee attack, shared combat
settings and hit-reaction behavior for now. Add the Castle Archer as another
choice; the user confirmed in its independent Combat chat that it shoots at
range and uses a separate melee attack up close. All three remain available
through one Dev Portal selector. These additions belong to Combat.

The Gym still contains one attacking opponent at a time. **Creature to spawn**
chooses Pikeman, Archer or Griffin; **Spawn / Restart** starts a fresh encounter
with that choice, resetting fighters, Health, orbs, Heat and actions through the
existing restart flow. Choosing a different creature does not change an attack
already in progress. Retry retains the chosen creature; Save Tuning remembers
the choice for subsequent launches. Final Arena uses the same selected opponent
in its existing final-enemy slot, preserving its completion objective and
separate practice targets. Pikeman remains the saved default.

Griffin uses the original native creature artwork and sound cues for this
prototype. Its wing movement is presentation of the current grounded actor.
The existing melee timing and hit geometry remain a temporary contract, not
final Griffin-specific tuning. Archer's melee and shooting use separate original
animation sheets. Source/static checks do not establish Godot playback,
controller acceptance, final artwork approval or balance validation; see
IMPLEMENTATION_STATUS.md for the implementation candidate and limits.

## SFX source decision — October 20

The user requires original Heroes III sources for runtime SFX. The former CC0
SFX are removed. Accepted replacements now use SWRDATTK for one common Player
X-start cue (including misses), SWRDWNCE for accepted nonzero Player hurt,
SWRDDFND for stationary-target response, SPONTCOMB/ICERAY/LIGHTBLT/METEOR for
Fire/Water/Air/Earth Cast launch, BLESS for the existing empowered event,
DISPELL for failure, PICKUP04 for generated orbs, and PROTECT for the existing
near-guard-break warning. No extra school spell layer plays on melee, and whole
spell cues are not replayed at impact. Projectile flight/impact remain unassigned.

Each newly visible charged orb plays one count-indexed note from the accepted
0.18-second PICKUP03 excerpt, using ratios 1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2
at fixed gain. Batched gains retain FIFO order; reset/cancel boundaries discard
stale queued notes. The reference eight-note preview is not a runtime cue and
sets no gameplay cadence. Earlier spell/pickup tails are temporarily quieter
while the notes drain; source checks do not establish their audible balance.

Original Pikeman attack/hurt/death/movement assignments, the SFX controls and
Ambient/BGM are preserved. Compound-Cast harmony timing remains Open. These
original/derived game recordings are copyrighted, not CC0, with no established
redistribution permission. Listening and Godot runtime validation remain pending.

See `docs/audio/2026-10-20-original-heroes-sfx-audit.md` for the inventory and
removal history. `assets/prototype/audio/ORIGINAL_HEROES_SFX.md` records the
accepted runtime mapping and Charging path. Older source-specific descriptions are
superseded by this decision where they name removed cues.

## Melee contact and simultaneous clashes — October 20

Player and Enemy melee attacks check their animated hitboxes throughout the
interval defined by `active_start` and `active_end`. An attack may connect later
in that interval after initially missing. Each attack may hit the same target
only once. Melee animations no longer require a `contact` marker; active-window
checking replaces the single contact-marker query described in older records.

Casting emits its projectile once at the authored `launch` marker. Projectile collision remains separate from melee active-window checks. The implementation candidate is recorded in IMPLEMENTATION_STATUS.md; user validation remains pending.

The first valid contact sends a hit to the target and spends the attack's one-hit
allowance for that target. Invincibility is handled by the target during resolution:
it ignores the hit's damage and reaction, but the allowance remains spent. The
same attack cannot hit that target again even if invincibility expires before
its active interval ends. Contact detection and a successfully applied result
remain separate facts; invincibility rejection does not become an applied hit.

When both melee attacks are active, weapon-to-weapon overlap is not required.
Each attack must reach the opposing character with its own hitbox to cause damage
or interruption. An opposing move's active state only contributes resistance to
the hit being resolved; a favorable calculated counter value alone creates no
reverse hit, damage or interruption. A connected hit with a negative reaction
value still deals its normal damage, subject to target-side defence and
invincibility, while the receiving attack continues without interruption.

If both active melee hitboxes reach the opposing characters simultaneously,
resolve one clash winner before applying damage. Only the winner's connected hit
deals damage and interrupts; the loser's simultaneous hit is cancelled. Compare
each attack's signed result against its receiver: the larger result wins, and
equal results favor Player. The loser's reaction uses the winning attack's
result: zero or negative selects the configured Level 1 reaction; positive uses
the normal reaction-level table. Both-negative results do not automatically favor
Player; for example, Player -10 versus Enemy -5 means Enemy wins with Level 1.
Player -10 versus Enemy 0 also means Enemy wins with Level 1. Equal negatives
favor Player. This exception requires both actual contacts; it creates no counter
against an untouched character and does not undo a hit that landed earlier.

The Defence section owns Fire parry/partial-block and retained Water guard interception; target-side invincibility remains an earlier rejection. Further hit-chain and defence design remains separate.

## Current decision — character-owned combat, October 20

Pikeman's CombatEnemy uses the accepted generated Pikeman repaint v02 for idle, movement,
front thrust, hurt and death, referencing the original unupgraded Heroes III
Castle Pikeman. Fire Laema uses the accepted generated sword-and-shield sheets;
other schools retain their legacy artwork. These bindings apply to the reusable
actors in Gym and Final Arena. Practice targets retain their separate artwork,
collision and tuning. The user's subsequent
speed adjustment uses the original Pikeman's one-second base attack duration:
ten evenly spaced frames, fully extended thrust/active-start at 0.5 seconds, and
return to idle at 1.0 second. This supersedes the prior 1.1-second windup and
1.3-second total attack; damage, Impact and Poise remain unchanged. The later
approved spatial correction below supersedes the earlier preserved hitbox sizes.

The user selected the current Gym tuning as the baseline for the reusable Player
and CombatEnemy in every scene. Combat settings belong to the characters, with
no Gym or level combat profile. Rooms retain layout, spawns, objectives and result
UI. School switching, contact-required orb generation, genuine Player death,
Enemy Poise 10 / Impact 20 / Health 200 and disabled Elemental Endurance now use
the same character settings everywhere. Practice targets retain their distinct
non-attacking/refilling role.

The Enemy behavior tree triggers the qualifying hit reaction. The Dev Portal
adjusts its exact duration, distance and ranges through the characters' shared
reaction Resource. Hurt animation, control lock and invulnerability retain one
lifetime owned by HitReaction; the tree waits for that execution to finish.
Qualifying Fire X5 hits, including lower reaction bands, deliver their unchanged
knockback distance over a separate 0.15-second shove (capped by the reaction
lifetime). Other attacks keep their existing full-duration knockback. Finishing
the shove does not end hurt, control lock, invulnerability or the subsequent AI wait.
**October 20 editor-setting decision:** after the hit-reaction task finishes,
the Enemy tree uses its configured BTRandomWait of 0.3–0.8 seconds. This separate
AI wait does not extend HitReaction-owned hurt, knockback or invulnerability.
Enemy attack windup/recovery remain authored in AnimationPlayer at native speed 1.

The previous Gym's 1.5× Fire/Cast duration is baked into Player settings once;
there is no scene multiplier. Charging speed, authored hitboxes and X4/X5 motion
are preserved. This supersedes older Gym-only/run-only tuning descriptions below.
Implementation and automated checks do not establish human gameplay-feel acceptance.

### Accepted art-aligned collision correction — October 20

The user approved correcting both attack areas and body collision to fit the new
art. Fire X1–X5 follow the visible sword from guard to tip, including Fire X2's
backward sweep. Pikeman's thrust covers the forward hand-to-tip segment so both
close contact and the extended tip can connect. Geometry follows held sprite
poses within the existing active windows. Attack duration, markers, combo pacing,
damage, Impact, Poise, lunge and one-contact-per-target rules are preserved.

Fire Laema has a stable 60×180-world-pixel body; legacy school artwork restores
its existing 52×60 body. An ongoing action retains the body associated with its
committed artwork when the selected school changes. Pikeman has a stable capsule
60 pixels wide and 180 high. Bodies exclude weapon extensions and do not change
shape with individual poses. Existing feet/floor anchors and root scales remain.
Pikeman's left attack mirrors about its visual foot anchor, not the actor root.
These are accepted behavior choices; implementation evidence and remaining human
validation are recorded in IMPLEMENTATION_STATUS.md.

### Current provisional Fire timing — October 22 afternoon

Fire X5 currently uses windup0.30/recovery1.10 seconds before Heat scaling
(C7; total1.40 seconds). Fire X4 remains0.33/0.36, total0.69 seconds. These are
provisional tuning candidates for human review, not final numerical or feel acceptance.
X5's shorter pre-split preparation advances its poses, lunge and active boundaries;
real-time input/contact windows and the following Cast can occur earlier. The
normalized rules, authored geometry/lunge values, reaction/invulnerability and
shared Cast timing are unchanged. No safe Cast outcome or improved artistic
continuity is guaranteed. Scoped agent-play evidence is in
[Implementation Status](IMPLEMENTATION_STATUS.md); live high-Heat protection and
human/controller aesthetics remain unverified. No new AI retreat, dodge safe-end,
impact-feedback treatment or art direction is selected by this numerical candidate.

### Historical overnight implementation and tuning — October 22

The following records the overnight baseline. Its X5 D timing is superseded by
C7 above; the other retained repairs remain inherited. These are
agent-tested implementation/presentation/tuning candidates, not user-verified
gameplay-feel, final art or final numerical acceptance:

- Fire X5 uses windup0.45/recovery1.10 seconds before Heat scaling (candidate D;
  total1.55 seconds). Recovery still includes playback after native timing_split,
  not a new wait or protection rule. Shared Cast timing and native geometry stay
  unchanged. D is not a guarantee that high-Heat Casts clear Enemy invincibility.
- The implementation reacquires the existing movement/facing lock at every actual
  X/Cast start, including starts after a pressure-preserved gap. The gaps remain
  unlocked; authored lunge values, windows and Heat scaling are unchanged.
- A normal RELEASE transition stops further Charging/depletion progression even
  when first-request-wins ignores the Cast request. That ignored request does not
  consume or reset the retained queue, charged/banked coverage or partial progress.
- All ten orb slots now have a faint neutral empty-circle indicator. Occupied
  lifetime fill and the2px charged outline are unchanged. The overflow widget keeps
  its stable dimensions through the existing4px-left/4px-right/rest flinch.
- The existing school-colored empowered square has half-size6 local units,
  horizontal facing offset8, vertical offset-66 and0.45-second lifetime. Its
  triggering event and audio are unchanged; it adds no new feedback meaning.

Evidence covers rendered observations through October22 07:19 HKT and the later
five existing supplementary controlled regression suites; see
[Implementation Status](IMPLEMENTATION_STATUS.md). Physical-controller priority,
audio and human latency/feel acceptance remain unverified; current-source parry
attempts did not establish a pass. The completed headless suites do not replace
primary play or human acceptance. A new full Charging press during hurt can
currently be classified without starting Charging,
and an unchanged hold does not retry after recovery. This is an implementation
seam, not an approved new incoming-hit rearm rule.

## Overview

This prototype tests the existing four-school combat system in a 2D side-scrolling space. Laema generates temporary elemental orbs through successful X attacks, uses full L2 pressure to charge generated orbs for the upcoming Cast, depletes that charging progress below full pressure, and triggers normal or empowered school spells by releasing L2 below the Cast threshold.

The primary experience remains deliberate combat mastery. The player should learn to maintain an attack chain, generate the desired elemental sequence, charge generated orbs while continuing to attack, and trigger Casting at an intentional pressure moment.

## Prototype Scope

**Included:** grounded left/right movement, gravity, continuous flat ground through all current stage areas, horizontal camera movement, functional Fire/Water/Air/Earth X attacks, generic school-and-level Cast resolution, school switching, a five-position attack-and-casting chain, temporary elemental orbs, L2 Charging, normal and empowered casting, casting projectiles, Heat, Fire parrying/partial blocking, Fire dodge, Water blocking, hit reactions, combat UI, reusable tutorial-stage progression, Stage 1 through Stage 7 objectives, stage-owned target sets, and one attacking final Enemy with one committed melee pattern.

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
| R1 | Use the active school’s available defence |
| Circle | Dodge while using Fire |
| Start / Esc | Pause or resume through the pause menu |

Laema is affected by gravity and remains grounded on solid collision. Every current stage area uses the same continuous flat ground height, and adjacent ground sections overlap at stage boundaries so transitions do not introduce a gap. The camera follows Laema horizontally while preserving fixed vertical framing.

Active X and Cast animations lock player-controlled movement and facing unless interrupted by the Fire dodge rules below. Once an action begins, left/right input cannot flip Laema until that action finishes. When CHARGING or DEPLETING preserves a chain between actions, Laema may move horizontally while retaining the chain and its orbs. Facing is horizontal; attacks and casting projectiles use Laema’s current facing direction.

### Fire Dodge

Only Fire has dodge in this slice. A fresh Circle press starts an available
dodge; holding Circle does not repeat it.

- The native dodge animation lasts **0.4 seconds**, with invincibility throughout.
- Travel distance equals **0.4 seconds of normal movement**, including when
  starting from idle. At activation, stick direction takes priority; neutral
  stick uses Laema’s facing. Direction remains locked throughout the dodge.
- Laema passes through enemy bodies. Walls stop movement, but animation and
  invincibility continue until the original 0.4-second duration ends.
- At that normal endpoint, after the final movement step, actual overlap with
  a combat Enemy whose body collision was excepted by this roll grants **one
  0.1-second extension**. Clear rolls still finish at 0.4 seconds. During the
  extension Laema continues at the same captured speed and locked direction,
  remains invincible and ignores gameplay actions. The final native dodge pose
  is held without stretching or replaying the animation. At speed 300 this adds
  up to 30 units of travel; walls still block it and consume blocked movement.
- The extension cannot repeat or wait indefinitely for clearance. Collision
  restores at its end even if a wide Enemy or wall leaves Laema overlapping;
  normal collision correction can then occur. Practice targets, artwork bounds
  and a clear roll do not independently grant extra time or travel.
- Starting dodge resets the input-combo. During dodge, all other gameplay action
  inputs are ignored, not buffered.
- A **0.37-second cooldown** begins after actual dodge completion: after 0.4
  seconds for a clear roll, or 0.5 seconds for an extended roll. Circle presses during
  dodge or cooldown are ignored; another dodge requires a fresh press once ready.

Dodge interacts with current actions as follows:

- **Fire X:** Circle can cancel the attack strictly before its active frames
  begin. From active-frame start until the attack animation finishes, Circle is
  ignored; no dodge is queued.
- **Charging:** starting dodge interrupts charging, clears charged statuses and
  resets partial charging progress to zero. The orbs remain in the queue.
  Keeping the Charging input held does not restart charging.
- **Cast before projectile launch:** Circle interrupts the Cast, spends that
  Cast’s charged orbs and starts dodge. Orbs already spent at Cast commitment
  are not spent a second time; unconsumed queue entries remain.
- **Cast after projectile launch:** Circle is ignored until Cast recovery
  finishes; no dodge is queued.

## Schools and Character Presentation

All four schools have functional X attacks and generic school-and-level Cast outputs. Active-school selection changes the displayed prototype character:

| School | Character | Prototype Cast output |
|---|---|---|
| Fire | Generated Laema sword and shield | Generic direct damage plus `Fire Lv.N` display |
| Water | Prototype Saber Fighter | Generic direct damage plus `Water Lv.N` display |
| Air | Shinobi | Generic direct damage plus `Air Lv.N` display |
| Earth | Samurai | Generic direct damage plus `Earth Lv.N` display |

This character mapping is prototype presentation only. It does not define Laema’s final appearance.

### Prototype X-Attack Animation Allocation

Following the October 21 implementation request, Fire X1/X4/X5 use transparent
derivatives of the overnight R05/R02/R04 studies in
`assets/prototype/player/fire_sword_shield_v01/overnight_v04/`. X1 uses eight
poses; X4 holds three poses across six existing keys; X5 uses seven R04 poses.
X2/X3 retain v03. Existing 448×448 cells and foot anchor(224,400) remain. This
is prototype presentation, not final artwork or weapon acceptance. Hitboxes,
directions and gameplay clocks are unchanged; X2's forward v03 drawing still
differs from the retained backward query. X3 remains unresolved and its reversed
candidate stays excluded. The parent v01 Idle/Walk/Hurt/Cast remains active. The table below retains the
earlier Craftpix allocation as pose/source history; it is not Fire's current
texture binding. The approved Air X5 replacement uses Weapon Summon: eleven
full-body 128×128 frames. Its retired effect and original records remain in
[Air X5 history](history/2026-10-20-air-x5-weapon-summon/README.md).

| School | Source family | X1 | X2 | X3 | X4 | X5 |
|---|---|---|---|---|---|---|
| Fire | Free Prototype Character Pack 2 | Punch 1 | Punch 2 | Fire Kick | Explosive Strike | Power Strike |
| Water | Medieval Character Pack 6 | Attack 1 | Attack 2 | Attack 3 | Enchanted Attack 1 | Enchanted Attack 2 |
| Air | Prototype Hero Pack 3 | Aerial Strike | Double Strike | Energy Wave | Wind Power | Weapon Summon |
| Earth | Medieval Character Pack 5 | Attack 1 | Attack 2 | Attack 3 | Power Punch 1 | Power Punch 2 |

The original 20 sheets used 128×128 cells. The October 19 Fire/Earth visual swap
and later Fire repaint retained move identities, frame times and combat pacing.
Fire's later approved spatial correction is described above. Water/Air/Earth keep
their 128×128 bindings; Earth still references the original `fire_xN.png` sheets.
The replaced source textures remain available as history.

Fire Cast uses the generated ten-frame 448×448 sheet. Water/Air/Earth retain the
original ten-frame 128×128 casting presentation. Fire also has dedicated Idle,
Walk and Hurt sheets; legacy schools keep the shared originals. Cast's sword
gesture adds no melee strike. Final projectile art remains open.

Outside dodge, school switching is always available and changes the school used by future X attacks. During dodge it is ignored with the other gameplay action inputs. It does not otherwise depend on the current chaining window, CHARGING or DEPLETING state, or any prior switch in the active chain. Switching consumes no progression position, buffered input, or other chain/input capacity, and it never clears or ends the chain. The currently selected school never directly determines Cast output.

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

X attacks use independently tunable durations before and after the pacing split for each school's X1–X5. Casting retains the shared base animation duration. The normalized chaining-window and pre-window buffer rules remain shared; an accepted follow-up still starts when the current action finishes. Heat accelerates each timing phase once through the same current speed multiplier.

### School melee styles — approved 2026-10-16

Keep the four schools, existing prototype animations, five global X/Cast progression positions and optional sixth-slot Cast endpoint. The temporary proposal to remove the five-position limit was withdrawn. Each move works independently at its global position when schools are mixed; no school-local combo counter, same-school prerequisite, critical-hit rule or extra hit event is introduced.

| School / feel reference | X1 | X2 | X3 | X4 | X5 |
|---|---|---|---|---|---|
| Earth / slow Broadsword | Broad opener | Heavy return | Compact opener variation | Loaded return variation | Full-weight finish |
| Fire / medium Spartan Sandals | Lead hit | Advancing hit | Checking kick | Driving strike | Push-away finish |
| Water / medium War Spear | Reaching opener | Quick follow-up | Close-range check | Extended follow-up | Committed thrust |
| Air / fast Twin Daggers | Opening cut | Reverse cut | Advancing opener variation | Returning follow-up variation | Finishing slash |

October 19 presentation update: the table above records the original feel references. Fire and Earth have exchanged their X flipbook sets for the sword benchmark; the timing/spacing presets and combat tuning remain attached to their original schools.

Player X moves have tunable phase durations, forward-body motion and qualifying-reaction push scaling. Player/CombatEnemy Settings own numerical combat tuning; native Animations own sprite frames and hitbox curves. Melee checks sample those curves throughout the active interval. The [attack-authoring guide](ATTACK_STYLES.md) owns editor instructions and current geometry readbacks.

The art-aligned Fire curves supersede the earlier provisional X40 point queries.
Their earlier comparison results and limits remain in the
[overnight ledger](iterations/2026-10-19-overnight.md); human feel acceptance and
final tuning remain pending.

Forward motion follows the action's committed facing through the existing collision body; walls block displacement and interruption/reset discards the remaining motion. Early Fire attacks use limited push; its X5 increases separation only when the existing hit-reaction rules qualify. Push scaling changes distance, not reaction eligibility, duration, invincibility, damage or Impact/Poise. Active actions retain the style captured at their start; tuning edits apply to subsequent actions. Native Animation markers author the melee active interval; Casting uses its separate launch marker.

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

Except for the Fire dodge interruption above, CHARGING may begin at any time, with or without available generated orbs, and continues while Laema attacks or performs casting animations. Charging capacity selects the oldest available generated orbs in first-in, first-out order.

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

Every successful Cast begins its primary school's native casting animation. The projectile launches once at that clip's authored `launch` marker, renamed from `contact` under the October 20 update without changing its time.

Fire's retained launch anticipation is 0.24 on its normalized one-second native clock; completion remains at 1.0. Configured duration and Heat map that clock into gameplay time. The comparison history remains in the [overnight ledger](iterations/2026-10-19-overnight.md); it is provisional tuning awaiting human acceptance.

**October 22 decision:** Fire's projectile and its collision originate at the
raised hand in the launch pose, mirrored with the committed facing. Other
schools retain their current emission. Launch timing, horizontal direction,
travel/range, damage, level-dependent drawing and sound remain unchanged. The
raised horizontal shot can miss the short legacy practice dummy; the user
accepted that limitation without changing the dummy or projectile trajectory.

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

Only Fire and Water defence are functional in this prototype. The October 21
Fire candidate uses **R1** for press-to-parry / hold-to-block. Shift is its
keyboard equivalent. Shield Catch is its accepted prototype presentation.
This is an implemented prototype
awaiting user validation; the timings are reference defaults, not accepted feel.

### Fire Parry and Block — October 21 prototype

- Press R1 for immediate front parry protection, default **0.20 seconds**.
- A quick release before **0.37 seconds** continues a tap parry until that
  endpoint measured from the original press. It does not start a fresh full
  window at release. Holding through the early parry window gives partial block.
- Held front block prevents **75%** of direct incoming damage by default; the
  remaining 25% is chip damage. Fire uses no Water guard depletion or block Heat
  drain. Hits from behind and damage-over-time ticks are not intercepted by Fire.
- A successful parry prevents the incoming hit completely and returns control
  immediately. Holding the button after success requires release/repress before
  another defence attempt. It interrupts the attacking combat Enemy with the
  existing configured **Level 1 combat hit reaction**, pushing it away from
  Laema. This explicit parry response does not use an Impact/Poise comparison;
  the standard reaction invincibility and Enemy AI recovery still apply. There
  is no counterdamage, reflection, orb grant, Heat or other resource reward.
- A quick-release attempt commits movement/actions until **0.50 seconds from
  press**, unless it succeeds. An unsuccessful tap parry starts a separate
  **0.60-second** defence-reuse penalty at parry expiry. Movement may become
  available before another parry. Releasing after the hold threshold simply
  ends the held block; it does not perform another tap parry.
- Fire defence can cancel an ordinary melee windup strictly before its native
  active_start marker. This ends that chain using the existing reset and
  preserves current orbs. Active/recovery melee and committed/buffered Casts
  cannot be cancelled through this path. The five-position X/Cast progression,
  optional sixth Cast endpoint and existing casting/resource rules are retained.
- Fire blocks attack/Cast input during its defence commitment. Success releases
  that commitment; the shield reuse timer does not itself lock movement/attacks.
- Parry/block/recovery retain the existing defence readout and guard sound; chip
  damage retains its damage display. The accepted Shield Catch v03 artwork now
  raises into a guard pose held while blocking. Only a successful Fire parry
  shows the spark; ordinary blocks and misses skip that frame. Cosmetic recovery
  yields to movement and new actions as soon as existing rules permit them.
  This presentation does not change defence timing, rewards, input or control
  locks. No dodge or enemy-pattern change is included.
- All five reference controls are tunable in Player Settings / Defence and the
  existing Dev Portal. Each press captures its values; edits affect the next
  attempt. Tap endpoint must cover the early parry window, and control commitment
  must cover the tap endpoint. Retry/stage reset clears the defence state.

The defaults come from the local Dead Cells StartShield/BaseShield crashlink
trace: early state f@36205, release f@36207/startParry f@4885, missed-parry reuse
f@4887, successful control return f@4896, and absorption f@536. This prototype
adapts those timers to Laema's existing owners; static evidence does not establish
frame-perfect equivalence or controller responsiveness.

### Water Blocking

- Blocking remains active while R1 is held and guard remains intact.
- Blocking nullifies incoming damage.
- Blocked damage depletes guard.
- Holding block drains Heat.
- VFX and SFX warn near guard break.
- The guard-breaking hit remains fully blocked.
- Guard break applies its configured recovery and blocks player input.
- Guard requires R1 release and a new press to restore.

R1 does nothing while Air or Earth is selected. Air and Earth defence remain deferred.

## Health, Impact, and Heat

HealthEvent remains the shared damage and healing contract. Damage carries Impact, original-instigator attribution, delivery type, school, contact information, and any effect instruction.

The current shared baseline starts Player at 100 maximum Health and CombatEnemy at 200. X attacks retain their current direct damage; Fire Impact follows the progression below. Casting projectile hits use generic direct damage for the resolved primary and optional secondary layers.

### Poise and qualifying combat reactions

Each attack has Attack Impact in 0–100, and Player/Final Enemy Poise is defensive in 0–100. Hit-reaction value = incoming Attack Impact − receiving character's Poise − receiving character's active-move Impact. The receiving move contributes only during authored active frames capable of triggering its hit event; startup/windup, recovery and idle contribute 0. Attacker Poise is never an offensive bonus.

Ordinary positive results qualify for combat reaction. A direct Player melee or Cast hit at exactly zero qualifies against a combat Enemy and selects Level 1; ordinary Enemy zero and ordinary negative results deal damage without combat interruption. These rules still respect valid contact, defence and invincibility. The Melee contact and simultaneous clashes section defines the separate reciprocal-contact winner rule; there is no spell-versus-melee clash rule.

| Difference after eligibility | Level | Duration | World-space displacement |
|---|---:|---:|---:|
| 0–10 | 1 | 0.25 s | 5 px |
| 11–20 | 2 | 0.55 s | 10 px |
| 21–30 | 3 | 0.85 s | 15 px |
| 31–40 | 4 | 1.15 s | 20 px |
| 41+ | 5 | 1.45 s | 25 px |

**Reaction-duration decision — October 20:** retain the current shared character settings: Levels 1–5 use 0.25/0.55/0.85/1.15/1.45 seconds. This supersedes the October 14 duration sequence and resolves the former discrepancy with the character Resource and GYM.md. Player and combat Enemy use these durations for stagger and reaction invincibility. Knockback normally spans the same duration; the October 22 Fire X5 exception below changes motion time only. Distances, value bands and reaction eligibility are unchanged. Reaction durations and distances remain editable per level in the Godot Inspector and Developer Portal; the five value bands remain configurable through each level's starting value. This tuning selection supplies no new gameplay-validation report.

The whole character and collision body are pushed backward and remain displaced.
Normally motion spans the selected reaction duration. **October 22 Fire X5
exception:** every qualifying Fire X5 hit delivers the same selected/scaled
distance over 0.15 seconds, capped by that reaction's lifetime. This includes
lower bands after active-move resistance and a qualifying winning-clash Level 1;
it does not make a nonqualifying hit interrupt. Hurt, control lock,
invulnerability and the separate Enemy AI wait are not shortened. Walls can
stop the push. Motion remains uniform without additional easing. Other moves
keep their existing timing; stationary practice targets retain legacy recoil.

The qualifying combat-reaction duration is invincible against further damage and reactions. Failed-Cast self-reactions grant no invincibility. Water retains its defence reaction path; the October 21 Fire prototype uses its own parry/partial-block interception without the legacy blocked-hit flinch. Stationary, non-attacking, pass-through practice targets retain their existing recoil and finite-health refill behavior.

One mixed Cast resolves its primary and secondary layers in order before starting invincibility. Already active effects are retained and continue advancing; damage ticks received while invincible are rejected. Melee/spell damage rejected by invincibility or clash cancellation is not an applied hit and does not grant hit-dependent resources or change Elemental Endurance. Spell-vs-melee clash rules and further school/status interactions remain deferred.

Each move has an independent character/style Resource record for its animation and damage/duration sources. Player X styles provide timing, forward-lunge distance/phases and qualifying-reaction push scaling; native Animations own geometry. Impact and character Poise remain character-owned tunables exposed through the Inspector and both Portals. Style overrides do not change Impact, Poise or reaction bands; final tuning remains open. Cast and Final Enemy do not use the Player X style overrides.

### Fire X and leveled Cast reaction progression

Fire X1–X5 produce progressively stronger combat reactions. Cast Spell Levels 1–4 use the corresponding reaction progression:

| Fire attack | Cast Spell Level | Attack Impact | Reaction against the Gym opponent outside its active swing |
|---|---|---:|---:|
| X1 | 1 | 10 | Level 1 (Player zero advantage) |
| X2 | 2 | 20 | Level 1 |
| X3 | 3 | 30 | Level 2 |
| X4 | 4 | 40 | Level 3 |
| X5 | — | 50 | Level 4 |

With the shared Enemy Poise 10, Fire values outside active frames are 0/10/20/30/40, producing Levels 1/1/2/3/4 under Player's zero advantage. Receiver active-move resistance still applies. Earlier private Poise-1 comparisons remain historical; final feel acceptance is pending.

The hurt animation belongs to the qualifying combat reaction: it starts with stagger and whole-body knockback, uses the selected reaction's duration, and ends with that reaction. Fire X5's shorter shove can finish while hurt, control lock and invulnerability continue. A damaging hit that does not qualify causes no separate hurt animation. Existing reaction invincibility and collision behavior are retained.

Each Cast layer uses its own Spell Level to select Impact. Mixed Casts resolve both layers before the strongest qualifying reaction begins. Cast damage, empowerment, Charging and Heat behavior are unchanged. Cast Levels 5–8 retain the existing base Cast Impact; their reaction progression is not assigned by this change. Other schools' X Impacts are unchanged.

Active markers and once-per-target contact are defined in Melee contact and simultaneous clashes; authoring steps are in [ATTACK_STYLES.md](ATTACK_STYLES.md).

Heat ranges from `0` to `100`. Attack speed scales linearly with Heat: `0` Heat produces the `100%` baseline attack speed, and `100` Heat produces `150%` attack speed. Intermediate Heat values produce proportionate attack speed.

Each charged orb consumed by Casting adds `2` Heat. Orb consumption is the only current source of Heat gain. Heat is granted immediately when a Cast commits and consumes charged orbs, including a buffered Cast committed before its animation begins. Interruption before launch and projectile miss do not revoke that Heat. Direct X hits, projectile impacts, and any deferred spell behavior add no Heat.

The Heat Reset Timer restarts for a full five seconds whenever a Cast commits and consumes at least one charged orb, a direct X hit lands, or a direct spell projectile hit lands. Cast commitment refreshes the timer immediately, including a buffered commitment before its animation begins; no projectile launch or Enemy hit is required, and a later interruption or miss does not undo that refresh. DoT ticks and failed Cast attempts that consume no orbs do not refresh it. After five seconds without any qualifying commitment or landed direct hit, Heat begins depleting smoothly and linearly at `3` Heat per second until it reaches `0`.

**Heat timer decision — October 20:** Casting alone restarts the timer at commitment and need not hit an Enemy. This resolves the former landed-hit-only wording in favor of the existing implementation. Heat gain remains `2` per consumed orb, separate from the timer refresh.

When Laema receives an incoming direct-damage `HealthResult` from an opponent whose outcome is `APPLIED`, Heat decreases by `5` and cannot fall below `0`. For example, a qualifying hit at `20` Heat reduces it to `15` Heat, changing attack speed from `110%` to `107.5%` under the linear mapping. `BLOCKED`, `PARRIED`, and DoT results cause no Heat loss. Final hit-reaction strength does not affect this resource rule.

**Deferred direction:** Future school-level spells may add Heat directly. Every such rule and value remains open.

## Enemy and Feedback

The current reusable CombatEnemy has Elemental Endurance disabled in both Gym and Final Arena. The retained specification below documents the earlier tutorial design; it is not an active default or a requirement to re-enable the buff.

Each tutorial stage owns its area contents and entity instances independently; later stages may deliberately duplicate earlier targets or enemies. Stage 1 and Stage 2 each contain exactly one stationary, non-attacking, permanent target with identical behavior. Damage is capped at its remaining Health; reaching zero resolves normally and then immediately refills it to full Health without clearing active effects. The existing prototype arena is the final tutorial area and retains its three permanent practice targets plus its killable final Enemy.

Training targets are pass-through and never physically block Laema's movement. The final Enemy is solid: Laema cannot move through or pass it. All current targets remain valid X and projectile targets.

Each target displays the school and level of every successful Cast layer that deals Health damage. A fully resisted Cast layer displays `0` damage without its school-and-level label. School-specific status displays other than the tutorial-only Elemental Endurance buff below are deferred with the spell behaviors they would represent.

### Elemental Endurance — retained disabled tutorial specification

In the retained design, Elemental Endurance is a tutorial-only protective buff for the tutorial's final Enemy. It showcases Laema's school-changing and Casting systems without becoming the later boss-like skill test. This buff is not yet a general rule for other enemies or the final game.

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

The provisional direct/DoT feedback-anchor adjustment and its remaining overlap/readability limits are recorded in [GYM.md](GYM.md) and the overnight ledger. It establishes no final visual acceptance.

### First Enemy Attack Pattern

The final Enemy uses one repeating committed melee pattern. Endurance is disabled under the current shared baseline:

```text
approach → commit to Laema's current position → wind up → active swing → recover → repeat
qualifying hit / losing clash → abandon attack → hit reaction → reassess
```

- The attack commits to its position and direction when windup begins.
- A Player hit with incoming Impact equal to or above the Enemy's poise interrupts windup; equality causes Level 1 reaction. During active frames, the Enemy's active-move Impact also contributes to the receiver-side calculation, with a zero Player result still qualifying. A losing active-frame clash cancels the attack. After reaction, the Enemy reassesses instead of resuming the cancelled attack.
- The attack does not track Laema after committing.
- The committed melee attack checks throughout its active interval; it misses Laema only if no eligible hit lands before that interval ends. Moving into or out of its hitbox during active frames can therefore affect whether it connects.
- Hits and misses use the same recovery period.
- No separate miss indicator is required; unchanged Player Health communicates the miss.
- The Player 1-HP Floor option is disabled in the current baseline. Genuine Player death locks movement/combat; Gym defeat offers Retry. The optional floor still prevents Health dropping below 1 when enabled, without healing on toggle.

Enemy attack timing is authored directly in `melee_swing`. It plays at speed 1:
windup lasts to `active_start`, hit detection checks throughout the active interval
with at most one hit per target, active frames end at `active_end`, and recovery uses any remaining animation
length. The Enemy resumes decisions when that animation finishes. Separate Enemy
windup/recovery controls and the Gym's Enemy duration multiplier are removed.
The current Pikeman clip has ten evenly spaced frames, active_start at 0.5 seconds and active_end/length at 1.0 second, at native speed 1. There is no recovery tail unless one is authored after active_end. Older 1.1/1.3-second and scalar-timer comparisons remain historical. Attack range, awareness, movement, damage, Impact and Poise are character-owned tunables; rooms provide placement and objectives.

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

The backtick Developer Portal has a shared header with Save Tuning, status, and Close controls, followed by three top-level tabs:

- **General:** Movement, Player, Enemy, UI, and the saved developer-overlay visibility flag. Gravity Scale is intentionally omitted from the Portal control surface.
- **Audio:** Ambient, SFX, and BGM groups. Each group has an Enabled control and a `0–100%` Volume control.
- **Combat:** nested sub-tabs for Combat, Casting, Heat, Fire, Water, Air, Earth, Defence, and Hit Reaction. The Combat sub-tab contains attack-hitbox visibility, the `collect_orb_without_contact` testing toggle, and the Combat controls. When enabled, a missed X can collect an orb without applying damage; the current character baseline has this test toggle disabled.

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

Movement, action pacing, authored hitbox curves, lunge, push, damage/Impact/Poise, reaction levels, Health, Charging, orb expiry, Heat, defence and feedback remain prototype tunables within their stated constraints. Final numerical and experiential acceptance remains open. The Heat timer trigger and current shorter reaction-duration baseline are settled by the October 20 decisions; neither remains an unresolved documentation conflict.

Validation must distinguish input acceptance, physical contact, APPLIED results, resource changes and presentation. Cover the six-slot chain and shared buffer; ten-orb FIFO/eight-charge behavior; Cast composition, commitment and launch; active-window contact, once-per-target spending, ordinary reactions and simultaneous clashes; defence and interruption; and the exact Stage 1–7 objective/transition rules above. Disabled Endurance is retained specification, not a current default acceptance requirement.

[IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) owns scoped reports, pending cases and waivers. The [pre-housekeeping GDD](history/2026-10-20-document-housekeeping/sources/docs/GAME_DESIGN.md#tunables-and-validation) preserves the detailed earlier checklist and its historical defaults. Broad earlier reports do not establish scenario-level acceptance of later changes. Air/Earth defence, additional Enemy behavior, school-level spell behavior, final assets/content, final balance and broader Player defeat design remain open or deferred; current Player death locking and Gym retry do not settle every future defeat/restart rule.

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


## Combat authoring and development tools

Player and CombatEnemy root Settings own numerical combat tuning and share the reaction Resource. Native AnimationPlayer tracks own sprites, geometry, melee active bounds and Cast launch. Both Dev Portals read/save the same assigned assets; rooms have no private combat profile. Active actions and reactions retain captured data; edits affect later actions. See [GYM.md](GYM.md) for character tuning and [ATTACK_STYLES.md](ATTACK_STYLES.md) for native animation/hitbox authoring.

Laema Dev Portal's editor dock edits a draft without running the game. Review/save and applying to a running game are separate operations. It groups General, Combat, Schools, Audio, Tutorial and Session; supports validated series fill for exposed level tables; and leaves dormant school effects labeled. Stage loading/pause requires a connected debug game. Mockup acceptance does not establish interactive editor acceptance. Technical ownership and persistence are recorded in [TECH_ARCHITECTURE.md](TECH_ARCHITECTURE.md).

## Combat Gym

`scenes/gym.tscn` is the bounded development encounter for the first reusable Enemy. Open it with F6 or Laema Dev Portal → Run gym; the current saved F5 main scene is also Gym. Open `scenes/prototype_arena.tscn` with F6 for the tutorial. The separate Fire benchmark is retired. Fire is the initial school, with school switching available. Both fighters use the shared character baseline; Player and Enemy start 160 pixels apart. Defeat the opponent while surviving, with no parry/Cast quotas. Victory or defeat stops the encounter and offers Retry; Start/Esc also offers Retry gym. Retry restores both actors, authored starting school/positions, empty orbs, zero Heat and saved settings.

The Gym adds result/retry and formula presentation. It has no private pacing multiplier, Fire lock, Endurance override or save refusal. F4 and Developer Overlay Visible toggle telemetry and formula readouts together. See [GYM.md](GYM.md) for controls, tuning, observations and evidence boundaries.

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
