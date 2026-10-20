# Combat Gym

Status: implemented candidate for a user playtest. Fire is the default
school; character tuning remains provisional. No gameplay-feel or
physical-controller acceptance is claimed.

The user now uses this Gym to develop the first reusable Enemy intended for the
game. That is the development target, not a claim that the Enemy is finished.

## Run and retry

Open `scenes/gym.tscn` and press **F6**, or select **Laema Dev Portal → Run gym**.
F5 runs the saved PrototypeArena main scene. Use F6 or Run gym for the Gym. A local command-line
run is `godot --path . scenes/gym.tscn`. The separate Fire benchmark scene,
script and inherited area have been retired and deleted. Tutorial play remains
available through `scenes/prototype_arena.tscn`; its saved stage is unchanged.

This is one bounded room and one attacking, killable opponent. Defeat the
opponent while surviving. There is no required Cast level, parry count, attack
sequence or time limit. Victory and defeat stop the encounter and show a focused
**Retry** button (keyboard Enter / controller confirm). Start/Esc also offers
**Retry gym** during play. Retry reloads the complete scene, restoring
both fighters, positions, the authored initial school, empty orbs, zero Heat, reactions and buffered
actions. A same-frame trade reaching zero Player Health counts as defeat.

Controls retain the current implementation:

| Action | Controller | Keyboard / mouse |
| --- | --- | --- |
| Move | Left stick | A / D |
| Active-school melee | X | Left mouse |
| Charge, then release to Cast | L2 | Hold, then release right mouse |
| Fire parry | L1 | Shift |
| Pause / retry menu | Start | Esc |

School-selection input reaches Player in this scene just as it does in the Arena.
Casting uses the shared L2 binding; Fire parry remains on L1.

## Character settings and tuning

There are no Gym root or level combat settings. Both Gym and PrototypeArena use
Player and CombatEnemy's authored Settings assets. The former Gym baseline now
applies everywhere: Player Health 100 / Poise 0; Enemy Health 200 / Poise 10 /
Impact 20; contact-required orbs, genuine death and Endurance disabled.

To tune a character in the editor:

1. Open `scenes/player/player.tscn` or `scenes/enemy/combat_enemy.tscn`.
2. Select its root node and expand **Settings** in the Inspector.
3. Change one value in its named section, then save the external Resource.
   The files are `config/characters/player.tres` and `combat_enemy.tres`.
4. For hurt duration/knockback, expand **Shared Hit Reaction → Hit Reaction →
   Combat Levels**, select a level and change **Duration** (seconds) or
   **Distance** (pixels). Both characters reference `hit_reaction.tres`.
5. Run either scene to compare. The editor and in-game Dev Portals expose the
   same data; **Review & save / Save Tuning** persists it to these same assets.
   Unsaved runtime edits last until retry/reload; saved edits survive.

For the Enemy's AI, edit the tree in LimboAI. Its qualifying-hit branch executes
**Execute hit reaction using character settings**, then waits for the component
reaction to finish before reassessing. Duration is adjusted through the reaction
Resource or **Combat → Hit reaction** in the Dev Portal. No extra post-hurt
BTWait or duplicate timing setting is present.

Enemy attack timing belongs to `AnimationPlayer / melee_swing`: `active_start`
and `contact` are 1.1 s; `active_end` and length are 1.3 s; native speed is 1.
Extend length after `active_end` to author recovery, or retime the sprite and
marker keys together. There are no windup/recovery overrides in character or
Gym settings. See `ATTACK_STYLES.md` for scrubbing and body alignment.

Player Fire X windup/recovery pairs at zero Heat are .21/.51, .24/.51,
.195/.45, .33/.51 and .45/.63 seconds. Cast total is 1.2 seconds. These contain
the old Gym 1.5× pace once; neither room multiplies them again. Charging retains
its previous speed. Native Fire X4/X5 geometry and motion are unchanged.

With Enemy Poise 10 outside its active attack, Fire Impacts 10/20/30/40/50
produce no reaction / Levels 1/2/3/4. Cast Levels 1–4 use Impacts 10/20/30/40
and produce no reaction / Levels 1/2/3. The receiver's active-move Impact can
weaken or prevent a reaction. Hurt, body knockback and invulnerability share
the selected duration; nonqualifying damage has no separate hurt animation.
Current level duration/distance pairs are .25 s/5 px, .55/10, .85/15, 1.15/20
and 1.45/25. Cast level Impact overrides live in Player Settings / Moves / Cast.

Overnight comparisons, historical policies and their human-acceptance limits are
preserved in `iterations/2026-10-19-overnight.md` and the morning handoff.

## Existing combat rules retained

- No parry cancel is added. Parry can begin only in Might's `READY` state. It
  cannot start during an attack, Cast or a chain preserved between actions by
  Charging/Depleting. Finishing an unpreserved action returns to READY; finishing
  an action does not always end a preserved chain.
- Fire parry lasts the existing 0.2 s, negates one incoming event, and adds no
  counterattack, stun or resource reward. Release/repress rearms it. Holding
  after the window closes remains movement-locked and vulnerable.
- Existing attack-while-defence-held input behavior is not redesigned here.
- Cast remains the generic projectile: normal base damage is 10 at every level,
  empowered primary damage is 13 with the current shared multiplier. No Fire
  DoT or level-based damage increase is added.
- Consuming more charged orbs grants more of the existing commitment-time Heat;
  it does not make the single-school projectile's base damage larger. Existing
  Heat timer, buffering, resource loss, interruption and invincibility rules
  remain unchanged.

## Combat formula readout

A gym-only panel below the ordinary telemetry shows each fighter's current melee
move Impact and Poise. The two **Last hit received by** cards display the actual
resolver values captured at contact:

Incoming Impact − receiver Poise − receiver active-move Impact = hit-reaction value → level.

For example, **60 − 20 − 15 = 25 → Level 3** with the initial configured ranges.
The active-move contribution is 0 during windup/recovery. Captured math remains
visible after the attack is cancelled or its reaction ends. Live stats can change
without rewriting that last-hit snapshot. Non-positive contacts show **No reaction**;
the exact Player-winning 0/0 exception is explicitly labeled. Invincible/blocked/
parried/cancelled attempts show their status and preserve the last evaluated math.

The formula panel is part of **Developer Overlay Visible**, alongside the normal
telemetry panels. **F4** hides/shows them together while the gym is focused,
including while paused. The same single switch is in **General → UI & debug**
in both the editor and in-game Portal. Gameplay Health/Heat/orb/objective UI remains
visible. The Dev Portal window still uses its separate backtick open/close shortcut.

Captured values keep updating while the overlay is hidden. Retry gym clears the
cards and reconnects the Enemy while retaining your shared visibility choice.
The shortcut changes the current run, and retry retains that visibility choice.
Use **Review & save** in the editor to set the default for future launches;
the runtime Portal saves the same shared preference. The obsolete
formula-only preference is ignored when an existing Developer Overlay Visible preference is present. No combat values or
rules are changed by toggling the overlay.

## Playtest observations

Retained feedback candidate H lowers direct/DoT anchors by52 pixels (−186/−154),
Cast-level stays−118. Supervisor actual viewport review supports fresh numbers
closer to the affected fighter and clear of EventPanel, with initial Player
DoT/Cast glyphs separated. Old fading numbers can drift back into the header,
and repeated NPC numbers still overlap. No scale/clamp/stacking solution or
uniform-resolution readability is claimed. Headless110 includes layout-only
DoT/zero/palette probes; current Gym has no Fire DoT gameplay. Capture-mode68
and inspected real combat images are separate evidence; human acceptance pending.

Keep three consistent uncertainties for this encounter:

1. Does the enemy create understandable choices between continuing, defending
   and disengaging?
2. Does Casting earn its attention cost through damage, spacing or Heat?
3. Can the player deliberately manage melee, defence and Charging together?

Observe first, then ask neutral follow-ups. Let the user interpret before
critique. Melee-first, close parry-and-punish, and spacing/Casting approaches
are permitted; they are not separate encounters or required checklists.
If a simpler approach consistently dominates, record that rather than requiring
extra buttons to pass. Readability, timing, balance and subjective success
remain for the user's playtest.

## Automated verification

Run the existing isolated runner with
`python3 tools/test-dev-portal.py --godot <executable> --script tools/tests/gym_encounter_test.gd`.
Use temporary `XDG_DATA_HOME`, `XDG_CONFIG_HOME` and `XDG_CACHE_HOME` on Linux to
keep Godot user data outside the developer profile. The runner validates a copy,
not the working project. Existing Portal, attack-style and clash suites remain
separate regression checks. Engine checks do not establish interactive playtest
or export success.

Historical pre-consolidation verification: 106 focused benchmark checks, 179 Portal/config/layout/
Gym checks, 199 attack-style checks and 59 receiver-side clash checks passed in
isolated copies (543 checks total). This executor used Godot 4.6.3 official Linux
x64; this is distinct from the historical Godot 4.7.2 Windows evidence. The
focused suite checks genuine enemy hit geometry, Fire restriction, the retained
parry eligibility, completion/defeat/retry, resource reset and unchanged shared
configuration/mirror bytes. It intentionally exercises the disabled Inspector
save warning. No visual, physical-controller, gameplay-feel or export acceptance
is inferred.

The historical totals above do not validate the consolidation. Current isolated
Gym encounter, formula, visibility, character parity and Portal results are recorded in
IMPLEMENTATION_STATUS.md. Human controller and gameplay acceptance remain separate.
