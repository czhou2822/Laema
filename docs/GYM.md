# Combat Gym

Status: implemented candidate for a user playtest. Fire is the user-selected
school; the encounter numbers below are provisional. No gameplay-feel or
physical-controller acceptance is claimed.

The user now uses this Gym to develop the first reusable Enemy intended for the
game. That is the development target, not a claim that the Enemy is finished.

## Run and retry

Open `scenes/gym.tscn` and press **F6**, or select **Laema Dev Portal → Run gym**.
The saved F5 main-scene UID currently points to the tutorial; the intended
F5-to-Gym launch remains a known mismatch. Startup configuration is not changed
by the overnight work. A local command-line
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
| Opponent Poise | 10 |
| Opponent move Impact | 20 |
| Current authored opponent active_start / contact | 1.1 s / 1.1 s |
| Current authored opponent active_end / clip end | 1.3 s / 1.3 s |
| Starting horizontal gap | 160 px |

The Gym multiplies Player Fire X windup/recovery and shared Cast animation
duration by 1.5 when loading its private profile.
For example, Fire X1's 0.14 + 0.34 s becomes 0.21 + 0.51 s before Heat, and the
shared Cast duration becomes approximately 1.2 s. Enemy animation timing has no
Gym multiplier. The current Enemy clip has no recovery tail because active_end
coincides with its end. Retry reloads the saved baseline and authored animations.
Legacy Enemy duration keys remain readable in old JSON profiles for compatibility
but have no runtime effect.

Retained overnight Fire Cast candidate: active_start/contact move from 0.36 to
0.24 of the native one-second clock; active_end/length stay 1.0. Existing poses
are retimed around contact (ATTACK_STYLES.md), with unchanged total Gym duration,
Heat, Charging, queue/buffer policy and melee handoff. This is a supervisor-retained
candidate pending the user's morning controller/feel playtest. Matched engine
cases launch eight ticks earlier at 60 Hz without earlier action completion.
One deterministic spacing/Cast policy changes from 20.48 s/HP80 to 19.40 s/HP60;
carry both responsiveness and the damage tradeoff into the playtest. Other-school
assets were unchanged by that Fire pass. The earlier0.8-contact/1.3-length
recovery-tail comparison remains rejected; it differs from the retained
1.1-contact/1.3-end Enemy telegraph candidate below.

Retained October20 overnight close-contact candidate: Fire X2/X3 native centers
are local(40,11), radius16 and zero target, matching X1's center. This gains6/4
world pixels inward at current scale2 and loses6/4 outward. Sampled close and
body-blocked chains improve from one to three applied hits; the three original
policy outcomes are unchanged. Timing, lunge, damage/Impact, invincibility,
single queries and generation remain intact. The later retained Enemy package
uses GymPoise10/contact1.1/end1.3. Compare close and outer
spacing on controller before accepting final feel/tuning. See the iteration
ledger for supervised visual evidence, exact tradeoffs and checks.

Charging retains its current rate, including Heat acceleration. The shared HUD
bar fills and drains smoothly: three charged orbs plus half of the next available
orb show 3.5/8 while Spell Level stays at 3. Fill is capped by available orbs, up
to eight; an empty queue shows zero, and three fully charged available orbs cap
the bar at 3/8. Banked capacity beyond available orbs is not displayed.

Retained OVERNIGHT CANDIDATE: Gym scene Poise10; the shared Enemy telegraph
plays at speed1. Existing sprite keys map0/.25/.5/.75→0/.34375/.6875/1.03125 and
geometry contact keys.8→1.1; values/poses stay unchanged. Active duration stays
0.2; length equals active_end1.3, so no recovery tail/timer is added. Gym script
export default remains1; shared tutorial Poise0/JSON is unchanged, while its
native cycle grows61→79 ticks at60Hz. Human controller/feel acceptance is pending.

The existing approach, commitment, collision, reaction and death behavior is
reused. Fire X1–X5 Impacts10/20/30/40/50 produce no reaction/Levels1/2/3/4
against GymPoise10 outside active frames. Cast Levels1–4 use10/20/30/40 and
produce no reaction/Levels1/2/3. Nonqualifying hits still deal their damage;
landed melee still generates an orb. The former Poise1 Level1–5 matrix remains
historical/private test coverage, not the current default.

Complete deterministic E fights support both tested styles from default and
mirrored starts: parry finishes HP100 in about26.7s; no-parry spacing/Cast HP90
in about24.7s. The wall-pressure spacing route loses naturally at16.8s with
Enemy120; parry still wins there. First-exchange offsets±3 ticks and gap targets
130/135/145 are locally viable, not whole-fight/controller robustness proof.
Charge loss and failed-Cast release costs remain. Earlier pure-melee/fixed0.68
policy losses are preserved, not hidden or turned into mandatory strategy rules.
These are exact-clock/position robot policies; judge human readability and
enjoyment separately in the morning. Full source/render evidence is in the ledger.
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
Gym encounter, formula, visibility and Portal results are recorded in
IMPLEMENTATION_STATUS.md. Human controller and gameplay acceptance remain separate.
