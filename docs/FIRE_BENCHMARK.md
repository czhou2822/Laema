# Fire combat benchmark

Status: implemented candidate for a user playtest. Fire is the user-selected
school; the encounter numbers below are provisional. No gameplay-feel or
physical-controller acceptance is claimed.

## Run and retry

Open `scenes/fire_benchmark.tscn` and use **Run Current Scene (F6)**. The project's
default scene, ordinary Gym and saved tutorial startup are unchanged. A local
command-line run is `godot --path . scenes/fire_benchmark.tscn`.

This is one bounded room and one attacking, killable opponent. Defeat the
opponent while surviving. There is no required Cast level, parry count, attack
sequence or time limit. Victory and defeat stop the encounter and show a focused
**Retry** button (keyboard Enter / controller confirm). Start/Esc also offers
**Retry Fire benchmark** during play. Retry reloads the complete scene, restoring
both fighters, positions, Fire, empty orbs, zero Heat, reactions and buffered
actions. A same-frame trade reaching zero Player Health counts as defeat.

Controls retain the current implementation:

| Action | Controller | Keyboard / mouse |
| --- | --- | --- |
| Move | Left stick | A / D |
| Fire melee | X | Left mouse |
| Charge, then release to Cast | R2 | Hold, then release right mouse |
| Fire parry | L1 | Shift |
| Pause / retry menu | Start | Esc |

School-selection input is consumed by this scene; the player remains Fire.
No controller remapping is part of this candidate.

## Local profile and tuning

Select the **FireBenchmark root** in the Inspector to edit its provisional
Player/Opponent Health, opponent Poise/Impact, windup and recovery. Save this
scene to retain those encounter values. Starting positions remain authored in
`scenes/stages/fire_benchmark_area.tscn`, inheriting the existing Gym room.

| Setting | Starting value |
| --- | ---: |
| Player Health | 100 |
| Opponent Health | 200 |
| Opponent Poise | 1 |
| Opponent move Impact | 20 |
| Opponent windup / recovery | 0.6 s / 0.9 s |
| Starting horizontal gap | 160 px |

The existing approach, committed melee, collision, reaction and death behavior
is reused. Local Poise prevents Impact-1 Fire openers from automatically
interrupting windup; the existing Fire finisher can still produce a qualifying
interruption. This is a starting hypothesis, not a verified balance result.

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
still edits the shared prototype file; use the benchmark root's Inspector for
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
`python3 tools/test-dev-portal.py --godot <executable> --script tools/tests/fire_benchmark_test.gd`.
Use temporary `XDG_DATA_HOME`, `XDG_CONFIG_HOME` and `XDG_CACHE_HOME` on Linux to
keep Godot user data outside the developer profile. The runner validates a copy,
not the working project. Existing Portal, attack-style and clash suites remain
separate regression checks. Engine checks do not establish interactive playtest
or export success.

October 19 verification: 106 focused benchmark checks, 179 Portal/config/layout/
Gym checks, 199 attack-style checks and 59 receiver-side clash checks passed in
isolated copies (543 checks total). This executor used Godot 4.6.3 official Linux
x64; this is distinct from the historical Godot 4.7.2 Windows evidence. The
focused suite checks genuine enemy hit geometry, Fire restriction, the retained
parry eligibility, completion/defeat/retry, resource reset and unchanged shared
configuration/mirror bytes. It intentionally exercises the disabled Inspector
save warning. No visual, physical-controller, gameplay-feel or export acceptance
is inferred.
