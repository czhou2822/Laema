# Combat Gym

Status: implemented candidate for a user playtest. Fire is the user-selected
school; the encounter numbers below are provisional. No gameplay-feel or
physical-controller acceptance is claimed.

The user now uses this Gym to develop the first reusable Enemy intended for the
game. That is the development target, not a claim that the Enemy is finished.

## Run and retry

Use **F5**, open `scenes/gym.tscn` and press **F6**, or select **Laema Dev
Portal → Run gym**. All three launch this one canonical Gym. A local command-line
run is `godot --path . scenes/gym.tscn`. The separate Fire benchmark scene,
script and inherited area have been retired and deleted. Tutorial play remains
available through `scenes/prototype_arena.tscn`; its saved stage is unchanged.

This is one bounded room and one attacking, killable opponent. Defeat the
opponent while surviving. There is no required Cast level, parry count, attack
sequence or time limit. Victory and defeat stop the encounter and show a focused
**Retry** button (keyboard Enter / controller confirm). Start/Esc also offers
**Retry gym** during play. Retry reloads the complete scene, restoring
both fighters, positions, Fire, empty orbs, zero Heat, reactions and buffered
actions. A same-frame trade reaching zero Player Health counts as defeat.

Controls retain the current implementation:

| Action | Controller | Keyboard / mouse |
| --- | --- | --- |
| Move | Left stick | A / D |
| Fire melee | X | Left mouse |
| Charge, then release to Cast | L2 | Hold, then release right mouse |
| Fire parry | L1 | Shift |
| Pause / retry menu | Start | Esc |

School-selection input is consumed by this scene; the player remains Fire.
Casting uses the shared L2 binding; Fire parry remains on L1.

## Local profile and tuning

Select the **Gym root** in the Inspector to edit its provisional
Player/Opponent Health and opponent Poise/Impact. Save this
scene to retain those encounter values. Starting positions remain authored in
`scenes/stages/gym_area.tscn`, which owns the shared room geometry.

Enemy attack timing comes from **combat_enemy → AnimationPlayer → melee_swing**.
The Gym Inspector and both Dev Portals no longer expose Enemy windup/recovery
overrides. Playback uses authored timeline seconds at speed 1, shared by the Gym
and tutorial Enemy. `active_start` ends windup, `contact` queries the committed
hitbox once, `active_end` ends the active interval, and the animation's remaining
length supplies recovery. Extend the clip after `active_end` to author recovery;
there is no additional timer after the clip finishes.

| Setting | Starting value |
| --- | ---: |
| Player Health | 100 |
| Opponent Health | 200 |
| Opponent Poise | 1 |
| Opponent move Impact | 20 |
| Current authored opponent active_start / contact | 0.8 s / 0.8 s |
| Current authored opponent active_end / clip end | 1.0 s / 1.0 s |
| Starting horizontal gap | 160 px |

The Gym multiplies Player Fire X windup/recovery and shared Cast animation
duration by 1.5 when loading its private profile.
For example, Fire X1's 0.14 + 0.34 s becomes 0.21 + 0.51 s before Heat, and the
shared Cast duration becomes approximately 1.2 s. Enemy animation timing has no
Gym multiplier. The current Enemy clip has no recovery tail because active_end
coincides with its end. Retry reloads the saved baseline and authored animations.
Legacy Enemy duration keys remain readable in old JSON profiles for compatibility
but have no runtime effect.

Charging retains its current rate, including Heat acceleration. The shared HUD
bar fills and drains smoothly: three charged orbs plus half of the next available
orb show 3.5/8 while Spell Level stays at 3. Fill is capped by available orbs, up
to eight; an empty queue shows zero, and three fully charged available orbs cap
the bar at 3/8. Banked capacity beyond available orbs is not displayed.

The existing approach, committed melee, collision, reaction and death behavior
is reused. Fire X1–X5 have Impacts 10/20/30/40/50, producing reaction Levels
1/2/3/4/5 against this opponent during idle, windup and recovery. Cast Levels
1–4 have Impacts 10/20/30/40 and produce reaction Levels 1–4 in those phases.
Poise and active-move Impact still apply; the opponent's active swing can weaken
or prevent the reaction. Hurt animation, stagger and whole-body knockback share
the selected reaction's lifetime. Non-qualifying damage has no separate hurt
animation. This replaces the earlier Impact-1 opener tuning.

Cast level overrides are stored in `moves.cast.level_impacts` in the shared
JSON configuration. The existing Cast Impact Inspector/Portal control remains
the fallback for levels without overrides, currently Levels 5–8. Mixed Cast
layers use their own levels and retain one strongest deferred reaction.

Only this scene disables contact-free orb generation, the Player 1-HP floor,
opponent Health refill and Elemental Endurance. It retains `is_final_enemy`
and the existing completion event; only the school-switching resistance is
disabled after configuring the opponent.

The baseline otherwise reads the shared validated prototype configuration into
a private in-memory copy. In-game Portal and Remote Inspector edits preview
changes for the current attempt. **Save Tuning**, Inspector mirror saving, and
**Apply saved to game** refuse shared-file writes/apply for this encounter.
Contact-free orbs, the HP floor and non-Fire startup cannot be enabled through
the runtime Portal. Retry discards run-only edits. The ordinary editor Dev Portal
still edits the shared prototype file; use the Gym root's Inspector for
the encounter values listed above.

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
the Gym refuses shared-file saves from its runtime Portal. The obsolete
formula-only preference is ignored when an existing Developer Overlay Visible preference is present. No combat values or
rules are changed by toggling the overlay.

## Playtest observations

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
Gym encounter, formula, visibility and Portal results are recorded in
IMPLEMENTATION_STATUS.md. Human controller and gameplay acceptance remain separate.
