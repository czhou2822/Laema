# Laema Player Combat Prototype — First Draft

Status: User-verified first draft; Godot validation reported on 2026-08-24.

## Overview

This 2D top-down sandbox tests whether switching between the complete Fire and Water combat packages creates meaningful depth and whether Heat-driven acceleration produces a flow state the player wants to maintain. Air and Earth remain selectable visual placeholders for their deferred combat packages. One non-attacking Enemy placeholder serves as the permanent training target.

Combat should reward deliberate mastery: increasing fluency lets the player perform demanding sequences faster and more confidently. Action timing comes from attack animations and input windows.

## Scope

**Included:** movement, centered camera, complete Fire and Water combat packages, selectable Air and Earth visual placeholders, Fire–Water input-combos and layered finishers, one Fire–Water mid-combo school switch, Heat acceleration, Fire parrying, Water blocking, hit reactions, combat UI, and one non-attacking Enemy placeholder.

**Excluded:** functional Air and Earth attacks and defence, mid-combo switches involving Air or Earth, active Enemy behavior and its attack FSM, final art and UI assets, complete enemy content, and final numerical tuning.

## Controls and Movement

| Input | Action |
|---|---|
| Left stick | Move and face |
| X | Light attack |
| Y | Resolve finisher |
| D-pad Up | Select Fire |
| D-pad Down | Select Water |
| D-pad Left | Select Air |
| D-pad Right | Select Earth |
| L1 | Use the active school’s defence |

Laema snaps to new movement and facing directions while the camera keeps her centered. An attack uses the current directional input or, when none is supplied, her last facing direction.

Attacking locks Laema’s position until the input-combo finishes or resets. Each chained attack may face a new direction without moving her. The Enemy has a solid body and blocks movement.

## Input-Combos and Switching

Valid combos range from `XY` to `XXXY`. Specialty level equals accumulated X inputs; Y resolves the finisher but adds no level. Y without X does nothing. A fourth X is ignored, leaving `XXX` available for Y.

Each attack animation has a window for the next input. Early inputs are ignored and never buffered. A valid input continues the combo; an expired window resets it. When attacks accelerate, their timeline-based windows shorten proportionally.

Outside an active combo, D-pad selection may activate any of the four schools. While Air or Earth is active, X, Y, and L1 inputs are ignored.

During an active combo, only a Fire-to-Water or Water-to-Fire D-pad selection can change the next attack’s school. It does not consume an attack, add a level, or reset the combo. Only one such school change is allowed per combo; further switches do nothing. Air and Earth selections are ignored during an active combo. The selected Fire or Water school remains active afterward. A valid Y immediately spawns its finisher VFX and always ends the combo, hit or miss.

### Prototype Attack Animation Scope

The three X positions use three different attack animations: X1 through X3. Animation position follows the total input-combo count and does not restart after a school switch. For example, `Fire X1 → X2 → switch to Water → X3` uses Water's character presentation on X3. The switch may snap directly into the next animation; transition animation and pose blending are not required for this prototype.

Fire and Water retain identical prototype hitbox shape, reach, timing, damage, and Impact across all three positions. Fire and Water share one Y animation across both schools and all finisher levels. School color treatment, effects, and the active character communicate the selected school. Final animation assets, transition quality, and school-specific motion remain outside this prototype scope.

## Layered Finishers

Within the current Fire–Water slice, the school performing Y resolves at the full specialty level. The earlier school resolves two levels lower; if that result is below level 1, it produces no secondary finisher.

| Combo | Result |
|---|---|
| `Fire XXXY` | Fire level 3 |
| `Fire X → Water Y` | Water level 1; no Fire |
| `Fire XX → Water XY` | Water level 3 and Fire level 1 |

Switch position does not alter the result. Combos with the same X count, schools, and finishing school resolve identically; therefore `Fire XX → Water XY` and `Fire X → Water XXY` produce the same finisher.

Every primary or secondary specialty performs its genuine behavior at its resolved level. Separate specialties may therefore create separate direct-damage HealthEvents on the same Enemy. Each such event independently grants Heat when it reduces Health.

## Schools

Fire and Water are the current functional schools. At equal Heat, they share underlying combat timing; presentation makes Fire medium-paced and Water faster and swifter. Air and Earth expose selection feedback only; their complete combat timing, motion, attacks, specialties, and defence remain deferred.

### Prototype Character Presentation

Active-school selection changes the displayed character for this prototype only:

| School | Character |
|---|---|
| Fire | Fighter |
| Water | Prototype Saber Fighter |
| Air | Shinobi |
| Earth | Samurai |

This presentation mapping changes neither the Fire/Water combat contracts nor Air/Earth's deferred placeholder status.

**Fire:** A red outline identifies Fire. Fire Y applies one DoT stack per resolved Fire level; X never applies DoT directly. DoT ticks add no Heat and cause no flinch.

**Water:** A blue outline identifies Water. Whenever Water resolves as a primary or secondary specialty, it creates an area centered on the weapon–target contact point. Every unique Enemy in that area receives one HealthEvent with 10 direct damage and Impact 1, plus the crowd-control effect for Water’s resolved level:

| Water level | Effect |
|---|---|
| 1 | Wet for 1 second |
| 2 | Wet for 2 seconds |
| 3 | 20% Slow for 2 seconds |
| 4 | 40% Slow for 2.5 seconds |
| 5 | Frozen for 1 second |

Wet is a status that will increase Air-school lightning damage when Air’s full package is implemented; it has no active modifier in this slice. Frozen prevents movement and attacks. Water’s area grows with resolved level, while damage and Impact remain unchanged. Each affected Enemy resolves the Water hit once. A miss creates no area, damage, status, or Heat but still ends the combo. The Enemy communicates active Water statuses through its status display; Frozen also applies the blue tint.

Water statuses are mutually exclusive and use Water level as priority. A higher-level Water status replaces an active lower-level status and begins at full duration. A lower-level status is ignored while a higher level remains active. Reapplying the same level resets its duration without stacking. Water’s direct damage still resolves when its status instruction is ignored.

**Air:** Selecting Air gives Laema a white outline. X, Y, and L1 do nothing while Air is active. Its intended full package remains the fastest school and uses lightning: a level-1 Air finisher grants a timed multiplicative attack-speed buff based on Laema’s current speed, while level-2 through level-5 finishers use chain lightning whose damage and chained-target count scale with level. That package is not implemented in this slice.

**Earth:** Selecting Earth gives Laema a brown outline. X, Y, and L1 do nothing while Earth is active. Its intended full package remains stable, slow, powerful, defensive, and deliberately cumbersome, with greater damage per hit. In that deferred package, idle Earth grants defensive level 1, sustained Earth blocking grants defensive level 3, and Earth Y applies Slow whose area, slowing percentage, and duration scale with level.

## Defence

L1 activates Fire or Water’s defence when that functional school is active. Entering defence locks movement, disables school switching, and provides no aiming or directional control. L1 is ignored while Air or Earth is active.

### Sustained Blocking

Water uses sustained blocking in the current slice. Earth’s sustained block remains part of its deferred full package.

- Blocking remains active while L1 is held and guard remains intact.
- Blocking nullifies incoming damage.
- Blocked damage depletes guard.
- Holding block drains Heat.
- VFX and SFX warn when guard is close to breaking.
- The hit that breaks guard remains fully blocked.
- Guard break causes a currently tunable 0.5-second reaction that blocks every player input.
- Continuing to hold L1 after guard break does not restore defence.
- Releasing and pressing L1 again restores guard to full immediately.

### Parrying

Fire uses parrying in the current slice. Air’s parry remains part of its deferred full package.

- Pressing L1 activates one parry window.
- A successful parry nullifies the incoming attack and currently grants no additional reward.
- Continuing to hold L1 after the window closes provides no defence while movement remains locked.
- Another parry requires releasing and pressing L1 again.

When active Enemy attacks are introduced, every attack may be either blocked or parried. The player chooses a defensive school according to confidence and the offensive package they are willing to give up.

## Health Events and Hit Reactions

HealthEvent is the shared event contract for damage and healing. The event identifies its operation as damage or heal and retains its original instigator. Every buff or debuff also records its original instigator, and any periodic DoT or future HoT tick carries that attribution into its HealthEvent. Every damaging HealthEvent carries an Impact level. Levels 1 through 5 are the five active Impact levels. Impact 0 explicitly produces no hit reaction and is used by Fire DoT ticks.

For the current slice, every accepted Fire or Water X attack and every valid Fire or Water Y finisher carries Impact 1 and deals 10 direct damage, regardless of specialty level. Player and Enemy maximum Health both begin at 100. These are tunable prototype starting values rather than final balance decisions. Ignored Air and Earth inputs create no attack or HealthEvent.

The struck character’s defensive level reduces the incoming Impact:

```text
final hit-reaction level = max(0, Impact level - defensive level)
```

Final level 0 causes no hit reaction. Final level 1 reproduces the prototype’s existing light flinch. From levels 1 through 5, flinch magnitude and recovery duration increase linearly.

Blocking can nullify damage while still producing a reduced hit reaction. In the deferred full Earth package, for example, an Impact-4 hit produces final reaction level 3 against idle Earth Laema and final reaction level 1 against sustained-blocking Earth Laema.

Any nonzero hit reaction cancels the struck character’s current action, prevents action and movement throughout recovery, then returns the character to idle. “Defensive level” is a provisional name.

If another hit produces a nonzero reaction during recovery, the active reaction ends immediately and all remaining movement and recovery are discarded. The new reaction begins at its full magnitude and recovery duration. A final reaction level of 0 neither starts a reaction nor replaces one already in progress.

## Enemy Placeholder and Deferred Active Mode

The current prototype uses one permanent Enemy placeholder with defensive level 0 and an initial maximum Health of 100. Its Health is finite and depleting, but it remains stationary, does not attack, and cannot die. When a HealthEvent deals at least the Enemy’s remaining Health, only that remaining Health is removed and all excess damage is discarded. The event resolves normally, including any Heat granted by the actual Health reduction, then the Enemy immediately refills to full. The refill does not clear active buffs or debuffs.

Active Enemy behavior and its attack FSM are deferred. When Active mode is implemented later, its attacks will follow this lifecycle:

```text
Begin → recognizable warning → active hit → resolution → recovery → ready
```

Exact attacks, timing, health, damage, and encounter-completion rules remain open.

## Heat

Every successful direct X or Y HealthEvent that actually reduces the target’s Health adds the same amount of Heat, regardless of school, attack, or finisher level. Separate direct HealthEvents from one layered finisher grant Heat independently. For example, when Fire performs Y and Water resolves as a secondary specialty, the contacted Enemy may grant one Heat increment for Fire’s direct damage and another for Water’s area damage. A zero-reaching hit grants Heat from its Health reduction before the Enemy refills. DoT, status effects, and any future HoT ticks add none.

Heat advances through distinct levels that increase attack speed. Level count, thresholds, and speed increases are tunable. During the inactivity grace period, Heat remains unchanged; when it expires, Heat resets immediately and attack speed returns to baseline. A progress bar displays Heat.

## Enemy and Combat Feedback

The Enemy placeholder never moves, attacks, or dies. Its Health refills immediately after reaching zero, while active buffs and debuffs continue normally. Direct hits use the shared hit-reaction rules; final reaction level 1 is the existing light flinch. DoT ticks use damage HealthEvents with Impact 0 and cause no reaction.

A WoW-style display above the target shows all buffs and debuffs. Fire DoT appears only after Y resolves; Frozen also applies the blue tint.

The input-combo UI shows Fire inputs in red and Water inputs in blue. Completed combos remain briefly, then disappear; new combos queue while a completed sequence remains visible. Timed-out incomplete combos disappear immediately. Final UI placement, animation assets, VFX, and visual polish remain open.

## Tunables and Validation

Tunables include movement and attack speed, direct damage, input windows, Heat gain, Heat levels and thresholds, acceleration, guard capacity, blocked-damage conversion, parry timing, guard-break reaction, hit-reaction magnitude and recovery, status values, Player and Enemy maximum Health, enemy values, and feedback duration. The supplied Health and direct-damage values are prototype starting points, not final balance decisions.

The prototype must make movement, directional attacks, Fire–Water combo timing, mixed finishers, Fire and Water school packages, Air and Earth placeholder selection, defensive-state entry, hit-reaction resolution, status feedback, direct-hit Heat gain, and Heat acceleration observable. Because the Enemy placeholder does not attack, incoming-hit validation of blocking, parrying, and guard break remains deferred. The primary empirical question is whether functional Fire–Water switching feels deeper than ordinary weapon switching because it changes offensive specialty, moveset, defensive response, and mixed-finisher composition.

Still open: the final name for defensive level, defensive levels for other schools and states, complete Air and Earth implementation, Wet’s future lightning-damage multiplier, Air-buff reapplication, exact chain-lightning and Earth-damage scaling, complete active Enemy behavior, Player death and encounter-ending rules, final Health and damage tuning, and final school-specific motion and feedback assets.
