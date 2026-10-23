# Laema attack feel guidelines

Status: adopted reference and authoring guideline at the user's request on
2026-10-23. Applies to Laema's X attacks, Casts and selectable reusable Enemies across
all scenes. This document guides future authoring and evaluation; it does not
change gameplay. The separately approved October23–24 optional contact/camera
prototype is recorded in the GDD and overnight report; it is a candidate, not
final artwork, motion comfort or controller acceptance.

Source: user-supplied `游戏打击感是怎么来的_逐字稿.pdf`, six pages, prepared
2026-10-23 from the 14:46 recording `我做了个游戏，告诉你游戏打击感是怎么来的？.mp4`.
Page/time references below refer to that transcript. Its examples illustrate
principles; its Unreal nodes, promotional material and numerical examples are
not Laema requirements. The transcript identifies uncertain automatic recognition
and approximate timestamps. The source video/audio was not independently checked.

## The standard

An attack should let the player understand the action, recognize contact and
feel its consequence. Animation, sound, target response and effects should agree
about the same event. The source's central distinction is that the game knowing
it registered a hit does not guarantee that the player perceived it (pp. 1–2,
01:37–03:41).

For Laema, evaluate four things together:

1. **Intention:** Can the player read the weapon's motion and the attack's commitment?
2. **Contact:** Does the visible strike agree with where and when the game connects?
3. **Consequence:** Can the player distinguish damage, a qualifying reaction,
   defence and a miss?
4. **Rhythm:** Can the player follow up while still paying attention to L2
   Charging, Cast release and the Enemy?

Perceived weight comes from coordinated cues and changes in rhythm. Maximum
speed, displacement, volume or effect density is not an acceptance criterion.

## Author the whole attack

| Phase | What the player should read | Laema application |
| --- | --- | --- |
| Anticipation / windup | What is about to happen and how the body prepares to deliver force | Readable weapon pose, body movement and Enemy telegraph. Attack anticipation is distinct from L2 orb Charging. |
| Strike and contact | Where the weapon travels and whether it connects | Align sprite poses, active_start/active_end, animated AttackCast geometry and actual contact feedback throughout the hit-capable frames. |
| Follow-through / recovery | The result of the strike and its commitment | Keep the weapon's follow-through readable; qualifying target hurt and displacement follow the resolved reaction. |
| Handoff | When the next action can begin | Evaluate X→X, X→Cast and Cast→X with the existing input/chain rules and consistent Heat. |

Authoring note: Player's optional `timing_split` controls phase pacing;
`active_start`/`active_end` control detection. A phase named recovery can still
contain hit-capable frames. Judge the authored poses and window together.

The source's weight cues include preparation, a shift of body weight, torso and
shoulder participation, and follow-through (p. 3, 05:06–06:44). In the current 2D
flipbooks, use readable poses and frame spacing to express these cues. A sprite
sheet's frame count alone does not determine its timing or perceived weight.

Keep the benchmark weapon and its motion consistent. Fire currently uses
sword-and-shield artwork; the source's warning about putting a much larger weapon
onto an unchanged light-weapon motion is a reference for future artwork changes.
It does not authorize another weapon or flipbook swap.

## Coordinate the feedback layers

| Layer | Principle from the transcript | Guideline for Laema |
| --- | --- | --- |
| Target reaction | Force should produce a visible consequence; identical reactions can flatten different strikes (pp. 2–3, 02:16–03:41) | Respect the resolved reaction level and direction. Use the selected shared reaction level: distance and motion time govern knockback; stun time governs hurt, control lock and invulnerability. |
| Sound | Weapon movement and impact are separate, complementary sounds; variants reduce repetition (pp. 2–3, 03:41–05:06) | A swing sound can occur on a miss. Contact sounds must represent the actual result. Judge the accepted original Heroes III cues together. Source examples do not authorize extra melee spell layers, impact replay or altered pitch. |
| Animation | Preparation, body participation and recovery communicate weight (p. 3, 05:06–06:44) | Match frame timing, weapon motion, lunge and contact. Use the user's earlier positive Fire X4→X5 report as a comparison reference while preserving newer authored candidates. |
| Camera | A small response can reinforce force; excessive movement destroys readability (p. 4, 06:44–08:14) | Treat shake as an optional enhancement. Any trial must keep the Enemy, weapon contact and Charging/Cast information readable in the 2D view. |
| Effects | Trails, flashes and particles primarily convey information (p. 4, 08:14–09:20) | Trails describe motion; contact effects identify the actual impact. Preserve readable school identity, silhouettes, spacing and the Enemy's next action. |
| Hit stop / 卡肉 | A brief pause at impact can suggest resistance and distinguish attack texture (pp. 4–5, 09:20–10:35) | Optional experiment, not a new default. Establish its scope and input/timer behavior before implementation; judge both perceived contact and follow-up responsiveness. |
| Rhythm / 节奏 | Bursts and pauses create contrast and breathing room (p. 5, 10:35–11:23) | Preserve deliberate combat pacing and room to attend to Casting. Examine anticipation, contact, recovery and handoff separately. |
| Defeat and haptics | Defeat presentation confirms victory; controller feedback adds another channel (pp. 5–6, 11:23–13:38) | Keep death and victory readable. Cinematic finishers and vibration remain optional future work; existing kill/death rules are unchanged. |

### Feedback must tell the truth

Use the confirmed combat result as the meaning of contact feedback. The attack
animation starting, a debug shape being visible, and a successful damaging hit
are different events.

- A miss may have weapon motion, a trail and a swing sound; it should not claim
  a successful impact on an Enemy.
- A connected damaging hit can fail to qualify for a combat reaction. Laema's
  Impact/Poise/active-move calculation still decides that outcome; this guide
  does not force a hurt animation or interruption on every contact.
- A qualifying reaction uses the shared level's distance, motion duration and
  stun duration. Motion can finish before stun; hurt, control lock and invulnerability
  remain tied to stun. Do not add per-move shove or cosmetic hurt overrides.
- Blocked, parried and invincible outcomes must not masquerade as an ordinary
  damaging hit. New result-specific assets remain future authoring work.
- A Cast's launch and its projectile impact are different moments. Launch cues
  communicate release; target-contact cues must agree with the resolved impact.
- Mixed Cast layers must preserve their existing damage/effect ordering and one
  strongest deferred reaction; feedback must not imply extra damage or interrupts.

### Leave room for Charging and Casting

Laema asks the player to manage attack timing and L2 pressure together. Apply the
source's rhythm and information principles to that existing attention demand:

- Preserve readable moments to notice generated orbs, continuous Charging
  progress, Cast release and Enemy commitment.
- Keep school/charge/Cast information distinguishable from impact decoration.
  More particles or louder attack layers should not bury a meaningful cue.
- Compare normal play as well as isolated attacks. A strong-looking single hit
  can become tiring or obscure decisions across a full chain.
- Use the currently authored character-owned pacing as the baseline. This guideline
  does not change Charging speed, Heat scaling, combo windows or recovery values.

## Apply it through the existing authoring workflow

See [attack authoring](ATTACK_STYLES.md) for exact editor controls and
[the Gym guide](GYM.md) for launch and tuning steps.

1. Choose one attack or transition and record the symptom in player terms:
   unclear contact, unreadable weight, repetitive sound or a difficult handoff.
   Save its current values before changing anything.
2. Open `player.tscn` or `combat_enemy.tscn` and scrub its **AnimationPlayer**.
   Inspect anticipation, each hit-capable pose and follow-through against the artwork.
3. Inspect the actual **AttackCast** curves across **active_start → active_end**.
   Keep them aligned with intended weapon reach throughout the window. A shape
   visible while scrubbing does not mean detection is active at that time.
4. For existing numerical tuning, select the character root's **Settings**, or
   use the Dev Portal. Player move styles own phase durations and attacker lunge;
   native Animation curves alone own Player-X hitbox geometry. Enemy timing comes
   from its authored animation. Victim distance, motion duration and separate
   stun duration live in the shared **Hit Reaction** Resource. Save the same assets
   both scenes use; introduce no Gym or level combat override.
5. Compare the transition at consistent Heat, target state and distance. For
   Fire X1→X2, use the earlier user-reported good X4→X5 link as a reference for
   contact, follow-through and handoff. Preserve newer authored candidates and
   record the exact comparison revision; the older report does not validate them.
6. Listen to the currently assigned original Heroes III action and target cues.
   Judge their agreement with visible motion and resolved outcomes. Projectile
   flight/impact are currently unassigned; do not replay a whole launch spell at
   impact or add the retired extra school layer to melee. New cues, variants or
   pitch treatment require their own decision within the accepted source policy.
7. Change one authored value or presentation layer, then compare with the saved
   baseline. Describe what became clearer and what became harder to read.

Current melee checks animated hitboxes throughout `active_start` to `active_end`,
with one contact allowance per target per attack. A target can enter later in
the window. An invincibility-rejected contact still spends that allowance;
detection and applied damage remain separate facts. Author the entire window,
not a single contact key. Cast emission is once-only at `launch`, with projectile
collision on its existing path. See the GDD for current clash/defence rules.

The behavior tree triggers and holds the Enemy's shared reaction execution.
Exact reaction tuning remains in character settings/Dev Portal. Its existing
post-reaction BTRandomWait stays separate from hurt and invulnerability; this
guide changes neither the wait nor reaction ownership. Sound-variation logic,
hit stop and haptics remain separate future work. The October23–24 candidate
adds independently disabled contact/camera controls through existing owners;
it does not add time manipulation or change reaction ownership. This guideline
itself does not introduce those controls or establish their subjective success.

## Review an attack in context

These are review prompts for future playtests, not a report that testing occurred.
Use gameplay presentation first, then the existing hitbox/readout tools to explain
any mismatch.

| Situation | What to observe |
| --- | --- |
| Swing into empty space | Can the player recognize a miss without a false impact cue? |
| Strike at close and outer reach, including entry after the first active frame | Does contact agree with the animated weapon throughout the active window, with one contact allowance per target? |
| Damage with and without a qualifying reaction | Can the result be understood while the existing interruption rule stays consistent? |
| X1→X2 and the reference X4→X5 | Does the next animation begin as expected? If it begins, does its contact connect? Keep input acceptance separate from damage rejection. |
| Attack while Charging, release Cast, then return to melee | Can the player track L2 progress, Cast release and the Enemy without losing the chain's rhythm? |
| Enemy approaching, committing, getting hit and recovering | Are its intentions and reaction end readable? Is the same actor behavior present in Gym and Arena? |
| Repeated attacks and a full encounter | Do audio/effects remain readable and tolerable beyond the first impressive hit? Is defeat unmistakable? |

Compare optional effects enabled/disabled if they are later prototyped. Record
the source revision, changed asset/value, Heat, distance and the player's report.
Human perception determines whether the guideline is being met; automated
assertions alone do not establish attack feel.

## Current foundation and open work

As documented at source `a41c900d`, native animation/hitbox curves, per-move
attacker lunge/timing, shared level reaction parameters and original Heroes III
action/reaction cues provide an
existing foundation. Their presence is not proof that every cue is synchronized
or that every attack feels good.

Camera shake, hit stop, direction/body-part reaction libraries, cinematic
finishers and controller vibration are reference techniques to evaluate
separately. Audio variation/pitch ideas remain subject to the existing original
Heroes III SFX decision. No implementation, timing preset, new reaction
rule, weapon change or acceptance of a specific treatment follows from adopting
this guideline.

Technical note on the source: at 60 FPS, 0.15 seconds is **9 frames**. The
transcript's "six frames or so" example is inconsistent with that calculation.
Its deliberately exaggerated demonstration is not a Laema hit-stop preset.
