# Combat Gym

Current guide, consolidated October 20. [Pre-housekeeping version](history/2026-10-20-document-housekeeping/sources/docs/GYM.md) preserves earlier instructions and reports. Heat timer and shared reaction durations are settled by the October 20 decisions in [GAME_DESIGN.md](GAME_DESIGN.md).

## Shared hit-reaction camera authoring — October 24

Camera profiles belong to **Shared Hit Reaction**, not to a particular scene.
Gym and the tutorial/Final Arena use the same saved Resource and four values:

| Profile | Strength default | Duration default |
| --- | ---: | ---: |
| Precise | 1.0 viewport px | 0.08 s |
| Weight | 3.0 viewport px | 0.11 s |

Strength is the maximum before existing reaction-level scaling. Limits remain
0–3viewport px and0.001–0.120s. These four global values do not add per-level or
per-attack controls and do not change distance, motion, stun or hit eligibility.

- **Local Inspector:** open `config/characters/hit_reaction.tres` in FileSystem.
  Expand **Cosmetic impact feedback → Precise camera / Weight camera**, edit
  strength/duration and save the external Resource. Player and CombatEnemy
  Settings both reference this same asset.
- **Live Remote Inspector:** Player → **CombatTuning → Settings → Cosmetic
  impact feedback → Precise camera / Weight camera**. This is the existing
  live mirror, not an independent scene profile; use normal Save Tuning to
  persist through the bridge into Shared Hit Reaction.
- **Runtime Dev Portal:** backtick → **Combat → Hit Reaction Camera**.
- **Editor Dev Portal:** **Laema Dev Portal → Combat → Hit reaction camera**.
  Both Portals edit the same Resource via **Save Tuning / Review & save**.
  General → UI retains the independent switches and treatment selector only.

The four property names are `impact_precise_camera_strength`,
`impact_precise_camera_duration`, `impact_weight_camera_strength` and
`impact_weight_camera_duration`. The effective configuration places them under
`hit_reaction`; they are no longer saved as UI JSON preferences. Current values,
treatment and enabled switches were preserved.

Legacy full profiles can fill missing shared values from their old UI keys or
the defaults. Conflicting explicit UI/shared values fail with a migration
message; move the intended values into the shared Resource and remove the old
UI keys instead of letting a scene override them. Loading never writes files.

Values apply to the next confirmed qualifying hit-reaction camera cue; a running
cue keeps its capture. Both scene roots share them; camera rendering remains
with the active Arena. Waveform, trigger, restoration, contact cues and combat
are unchanged. Inspector/Portal agreement, actual live apply, both scenes and
save/reload still need user validation; prior overnight checks do not verify
this ownership migration.

## Optional feedback review — October 23–24 candidate

The runtime Portal's **General → UI → Cosmetic impact feedback** provides
independent **Contact accent** and **Heavy impact camera** switches and a
**Precise / Weight** treatment selector. Both switches default off; Precise is
the default. Live edits reach both fighters; **Save Tuning** remembers the
preferences. The editor Portal uses its own navigation over the same catalog.

Only confirmed APPLIED direct damage with actual Health lost receives the new
ordinary-hit cue. Misses, zero, block, parry, invincibility and DoT do not.
Mixed Casts keep both damage amounts/captions but one contact accent. Stronger
qualifying reactions can receive the optional camera offset. At1280×720,
camera stays within3px/120ms and complete contact footprint within40px/120ms.
No hit stop, zoom/rotation or actor-wide flash is added. Both-off is the useful
comparison baseline, not a loss of existing damage or status information.

Same-frame direct numbers and Cast captions now space horizontally in their
existing lanes, with8px between outlined siblings and a12px viewport margin.
Formed families retain that margin as the owner moves. Older fading numbers
can still crowd the row. The [overnight report](iterations/2026-10-23-fire-combat-overnight/REPORT.md)
separates actual agent play/native images from pending controller/feel acceptance.

Status: implemented candidate for a user playtest. Fire is the default
school; character tuning remains provisional. No gameplay-feel or
physical-controller acceptance is claimed.

The user now uses this Gym to develop the first reusable Enemy intended for the
game. That is the development target, not a claim that the Enemy is finished.

## Run and retry

Open `scenes/gym.tscn` and press **F6**, or select **Laema Dev Portal → Run gym**.
The current saved F5 main scene is also Gym. Use F6 on PrototypeArena for tutorial play. A local command-line
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
| Fire parry / hold to block | R1 | Shift |
| Fire dodge | Circle | No keyboard default |
| Pause / retry menu | Start | Esc |
| Cycle Castle/Necropolis base at tier 1–7; Spawn / Restart | No controller shortcut | Top-row 1–7 |
| Toggle base/upgraded within selected faction; Spawn / Restart | No controller shortcut | Shift + top-row 1–7 |

School selection uses the controller D-pad just as it does in the Arena. The
former 1–4 keyboard school-selection defaults have been removed.
Casting uses the shared L2 binding. R1 is defence; Fire uses the October 21 press-parry/hold-block prototype.

## Choose an opponent

Roster and number-row controls updated October23; runtime validation pending.

During play, each physical top-row number identifies one tier:

| Number | Castle base / upgrade | Necropolis base / upgrade |
| --- | --- | --- |
| 1 | Pikeman / Halberdier | Skeleton / Skeleton Warrior |
| 2 | Archer / Marksman | Walking Dead / Zombie |
| 3 | Griffin / Royal Griffin | Wight / Wraith |
| 4 | Swordsman / Crusader | Vampire / Vampire Lord |
| 5 | Monk / Zealot | Lich / Power Lich |
| 6 | Cavalier / Champion | Black Knight / Dread Knight |
| 7 | Angel / Archangel | Bone Dragon / Ghost Dragon |

Press a number repeatedly to alternate Castle/Necropolis **bases** at that tier.
From another tier, the first plain press selects Castle base. A plain press
from an upgrade advances to the other faction's base at that tier.
Hold Shift and press that number to toggle base ↔ upgrade **within the selected
faction**, without advancing factions. Shift+another number selects the selected
faction's upgrade at that tier. For example: Pikeman → Shift+1 → Halberdier →
Shift+1 → Pikeman → 1 → Skeleton → Shift+1 → Skeleton Warrior → 1 → Pikeman.
This replaces the earlier proposed three-step cycle.

Each fresh press, plain or with Shift, uses the same
**Spawn / Restart** action below, including full Health, empty orbs, zero Heat
and reset actions/positions. Holding the key does not repeat. Close the pause
menu and Dev Portal first; shortcuts stay inactive while either is open, even
if the Portal has unpaused play. Alt/Ctrl/Meta and numpad keys are not shortcuts.
Shift's separate keyboard-defence binding is otherwise unchanged. The choice is
run-only until Save Tuning, and no new creature behavior or tuning is added.

All 28 creatures above share the Dev Portal's **Creature to spawn** choice.
The saved default remains Pikeman; the room still
contains one opponent at a time. Griffin currently uses the existing grounded
melee behavior. Archer shoots at range and has a separate close-range melee.
The added level4 Swordsman, level6 Cavalier and level7 Angel use the current
grounded melee prototype; level5 Monk uses the existing ranged/close-melee
pattern with its own bolt visual. Their character sheets are the existing
high-resolution candidates. Castle upgrades inherit their base actor's behavior;
Marksman keeps Archer's arrow, and Zealot keeps Monk's bolt. All fourteen
Necropolis choices use the existing grounded-melee stand-in behavior, including
Liches and winged creatures. No new creature ability, flight, stat or original
game timing is added. Stop and rerun Gym to load the new scenes/resources.

1. Open the in-game Dev Portal with backtick and select **General**.
2. Under the UI fields, set **Creature to spawn**.
3. Press **Spawn / Restart** to begin a fresh encounter with that creature.
4. Use **Save Tuning** to remember the choice for later launches. Retry keeps the
   current choice even before saving. Save other tuning before a Gym restart if
   it needs to survive the existing full-scene reload.

The editor Portal exposes the same choice and **Spawn / Restart** in
**General / UI & debug**. Spawning requires a connected Gym or Final Arena;
**Review & save** remembers the draft selection for future launches. Other draft
edits retain their normal separate save/apply flow. The action resets the
fighters, Health, positions, empty orbs, zero Heat, reactions and buffered actions.
Final Arena retains its practice targets and final-enemy completion identity.

The current shared Health/Poise/Impact and AI values still come from
CombatEnemy Settings. Non-Pikeman melee hitboxes are edited in their own
native Animation resources; the Pikeman reach/radius shortcuts are hidden while
one of those creatures is selected. New creature playback, both facings,
grounding, hit alignment, restart and saved-selection behavior await a user run.

The current presentation candidate binds the existing high-resolution Archer
and Griffin character sheets (768 x 640 per frame). Stop and rerun Gym to load
the new scene/texture bindings, then use the same creature selector. The source
animation collection remains a review candidate; this rebind preserves current
attack timing, combat settings and hitboxes. Review both facings, grounding and
weapon/muzzle alignment in-game. Original character sheets remain preserved.

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
4. For victim reactions, expand **Shared Hit Reaction → Hit Reaction →
   Combat Levels**. **Duration** is stun/hurt/control-lock/invulnerability time;
   **Motion Duration** is independent shove time, capped at that lifetime;
   **Distance** is body displacement. Both characters reference
   `hit_reaction.tres`; no Player-X move multiplies or overrides these values.
5. Run either scene to compare. The editor and in-game Dev Portals expose the
   same data; **Review & save / Save Tuning** persists it to these same assets.
   Unsaved runtime edits last until retry/reload; saved edits survive.

For the Enemy's AI, edit the tree in LimboAI. Its qualifying-hit branch executes
**Execute hit reaction using character settings**, then waits for the component
reaction to finish before reassessing. Duration is adjusted through the reaction
Resource or **Combat → Hit reaction** in the Dev Portal. The user confirmed the
editor setting: after the reaction task, a separate BTRandomWait is configured
for 0.3–0.8 seconds. It does not extend the component's hurt/knockback/invulnerability
lifetime. This alignment changes no tree or tuning value.

Enemy attack timing belongs to `AnimationPlayer / melee_swing`: `active_start`
is 0.5 s and `active_end`/length are 1.0 s, at native speed 1, using the original
Pikeman's ten evenly spaced frames. Melee checks the animated hitbox throughout
that interval, once per target. There is no melee contact marker. The optional
`timing_split` is a pacing boundary, not a hit event. Extend length after
`active_end` to author recovery. There are no character/Gym timing overrides.
See [ATTACK_STYLES.md](ATTACK_STYLES.md) for scrubbing and keying.

Player-X hitboxes are authored only in each linked native Animation's
`AttackCast:position`, `target_position` and `shape:radius` curves.
MoveStyle and **Combat → Attack styles** now expose only timing and attacker
lunge; no reach/radius, push scale or per-move motion-time controls remain.
Save native edits separately and restart the scene. Portal Save does not patch
Player-X curves; Enemy/Pikeman shortcuts keep their existing behavior.

Player Fire X windup/recovery pairs at zero Heat are .21/.51, .24/.51,
.195/.45, .33/.36 and .55/1.10 seconds. X4's daytime candidate totals0.69s,
replacing only its0.51s recovery; native normalized windows/geometry stay fixed,
but their real-time duration shortens. X5's current T1 (5cc98e8e/local3200279f) is
a provisional human-review candidate, base1.65s, not accepted final latency/feel. Cast total is
1.2 seconds. The unchanged shared baselines already contain the old Gym1.5× pace
once; T1 changes only X5's pre-split duration from C7's0.30 to0.55, retaining1.10
recovery and no room multiplier. Later lunge/contact and changed real input/buffer
timing accompany that slower preparation; normalized rules/values do not change,
and following Cast safety is not guaranteed. Charging retains
its previous speed. Native Fire X4/X5 geometry and authored lunge values are
unchanged; actual timed displacement can differ through pacing and collision.

With Enemy Poise 10 outside its active attack, Fire Impacts 10/20/30/40/50
produce Levels 1/1/2/3/4. Cast Levels 1–4 use Impacts 10/20/30/40
and produce Levels 1/1/2/3. Player's ordinary zero result qualifies for Level 1. The receiver's active-move Impact can
weaken or prevent a reaction. Hurt, control lock and invulnerability share
the selected duration; nonqualifying damage has no separate hurt animation.
All qualifying hits, including Fire X5 and lower-band winning clashes, now use
the selected shared level's distance and motion time. The former per-X5 0.15s
override and all per-X push multipliers are retired. In **Combat → Hit-reaction
levels**, adjust **Motion duration** to change shove speed without shortening
**Stun duration**; values above stun are capped during execution. Initial motion
times originally matched stun. The October23–24 candidate now stores
.25/.55/.85/.15/1.45 seconds; only Level4 motion changed. Its20px shove finishes
promptly while its1.15s stun, control lock and invulnerability continue.
Active reactions retain their captured values; the separate Enemy AI wait is
unchanged. Practice-target legacy recoil is separate.
Current stored duration/distance pairs are .25 s/5 px, .55/10, .85/15, 1.15/20
and 1.45/25. The user retained this shorter sequence on October 20; the earlier
October 14 durations remain historical rather than an open conflict. Cast level Impact overrides live in Player Settings / Moves / Cast.

Cast levels5–8 currently use base Impact1 because their overrides are absent.
Against non-active Enemy Poise10 that gives-9/no qualifying reaction, while Fire
X5 Impact50 gives40/Level4. Empowerment changes damage, not Impact. These locked
limitations and fixed reaction protection were not retuned by the overnight work.

The separately approved October22 Fireball origin is the raised hand, mirrored
with committed facing. Actual projectile collision moves with the drawing;
launch time, travel/damage, level-dependent size and audio are retained.
Non-Fire emission is unchanged. The user accepted that the raised horizontal
shot can miss the short legacy dummy; no dummy or trajectory repair is included.
The raised-hand mapping is preserved by this reconciliation. Rendered checks
of the current Level4 candidate include an actual20px/approximately0.15s shove
and unchanged1.15s hurt in the overnight report. Human spacing/feel acceptance
and full level/creature coverage remain pending.
The approved dodge follow-up keeps clear rolls at0.4s, but actual end-overlap
with an already excepted combat Enemy grants one0.1s extension at captured
speed/direction. Protection, ignored actions and pass-through last until actual
completion; the final native pose is held, not replayed/stretched. The existing
0.37s cooldown starts at that actual end. Collision restores after the one
extension even if a wall/wide Enemy still overlaps; further correction remains
possible. This supersedes the brief acceptance of immediate end-overlap snapping.
Practice targets grant no extension. Human feel validation remains pending.

For the new candidate, compare a clear Circle roll with one whose normal end
still overlaps the opponent. Expect0.4s versus one0.5s action, a held final pose
in the extra phase and0.37s cooldown only after actual completion. Check both
facings and a wall; a still-blocked/wide overlap must restore collision after
the single grace rather than remain pass-through. Combat owns rendered review;
the focused headless fixture is not a controller/feel pass.

The current Might repair reacquires movement/facing lock at actual X/Cast start
after a Charging-preserved gap; the gaps themselves remain movable. Normal RELEASE
also stops Charging/depleting progression even when first-wins ignores that Cast,
without consuming/resetting retained resources. A new full press during hurt can
still be classified without starting Charging and is not retried by the unchanged
hold; this remains an implementation/decision seam, not a new hit-rearm rule.

Overnight comparisons, historical policies and their human-acceptance limits are
preserved in `iterations/2026-10-19-overnight.md` and the morning handoff.

## Existing combat rules retained

- R1/Shift starts Fire's 0.20s early front parry. Releasing before 0.37s
  continues a tap parry to that endpoint from press. Holding gives 75% front
  direct-damage absorption after the early window. Fire uses no Water guard/Heat
  drain; rear hits and DoT bypass it.
- Successful parry unlocks movement/actions immediately; release/repress rearms.
  It also interrupts the attacking Enemy into its configured Level1 combat
  reaction, away from the Player. Existing reaction invincibility and AI recovery
  apply; no extra damage or resource reward is granted. Blocks and misses do not
  trigger it.
  An unsuccessful quick release commits controls to 0.50s from press and starts
  a separate 0.60s reuse penalty at parry expiry. Holding beyond 0.37s and releasing
  ends block directly. These are captured reference defaults, not feel acceptance.
- Fire can cancel melee windup before native active_start, ending that chain and
  preserving orbs. Active/recovery melee, buffered/queued Cast commitments and
  casting rules are retained. Fire's commitment gates attack/Cast input.
- Existing readout/guard audio communicate defence; chip damage uses the existing
  damage display. The parried Enemy uses the existing Level1 reaction rather than
  a new stun timer. No counterdamage, projectile reflection or dodge is part of
  this candidate. Water retains its existing guard behavior on R1.
- Cast remains the generic projectile: normal base damage is 10 at every level,
  empowered primary damage is 13 with the current shared multiplier. No Fire
  DoT or level-based damage increase is added.
- Consuming more charged orbs grants more of the existing commitment-time Heat;
  it does not make the single-school projectile's base damage larger. Existing
  Heat timer, buffering, resource loss, interruption and invincibility rules
  remain unchanged.

## Fire defence prototype comparison — October 21

Tune **Player root → Settings → Defence**, or **Dev Portal → Combat / Defence**:
parry_window (0.20), fire_tap_parry_window (0.37), fire_control_commitment (0.50),
fire_miss_recovery (0.60), fire_block_absorption (0.75). The tap endpoint must
cover the early window; commitment must cover the endpoint. Each R1 press
captures the values. Save persists to config/characters/player.tres; edits apply
to the next press. The old full JSON format gains missing values on load in
memory; it is not written automatically.

For the user's comparison, keep one enemy attack case and change one setting:

1. Face the enemy and tap R1 just before contact: expect zero damage, PARRIED and
   immediate control return. Release/repress for another attempt.
2. Hold R1 beyond the early window into contact: expect BLOCK 75% and 25% chip
   damage, with no Water guard/Heat drain. Turn away to compare a normal hit.
3. Tap too early: expect parry expiry, remaining control commitment, then free
   movement while PARRY RECOVERY still prevents another defence attempt.
4. Press R1 during Fire melee windup, then during active/recovery and a committed
   Cast: only eligible windup cancels. Check an ordinary five-position chain and
   normal/empowered/endpoint Cast afterwards.
5. Change one defence value, save, retry/reload and compare. Retry, death/stage
   lock and interruption must not leave a stuck input/movement lock. Taking a
   hit does not erase an already-running missed-parry reuse penalty.

Historical overnight defence evidence: the initial slice used source/whitespace
checks only. Later current-D rendered normal-input observations through October22
07:19 support held block/control return and the scoped dodge cancellation,
accounting, wall protection and return-to-fight cases in Implementation Status.
At that cutoff R1 tap attempts produced no parry pass; earlier-source parry evidence
did not clear that version. Later retained-C4 defence/dodge evidence is recorded
in Implementation Status, not a fresh C7 parry pass. Status remains AWAITING_USER_VALIDATION.
Physical analog/controller priority, audio, human
latency/feel remain unverified. The five later existing full headless geometry
suites completed as supplementary controlled regressions, not primary play or
controller/parry/AI acceptance. No blanket clearance follows.

## Combat formula readout

A gym-only panel below the ordinary telemetry shows each fighter's current melee
move Impact and Poise. The two **Last hit received by** cards display the actual
resolver values captured at contact:

Incoming Impact − receiver Poise − receiver active-move Impact = hit-reaction value → level.

For example, **60 − 20 − 15 = 25 → Level 3** with the initial configured ranges.
The active-move contribution is 0 during windup/recovery. Captured math remains
visible after the attack is cancelled or its reaction ends. Live stats can change
without rewriting that last-hit snapshot. Ordinary Player zero is labeled as
its Level-1 advantage; ordinary Enemy zero and negative hits do not interrupt.
Reciprocal simultaneous melee contacts compare signed values, with equality
favoring Player and Level 1 for a non-positive winner. Only the winning contact
deals damage. Invincible/blocked/parried/cancelled attempts show their status
and preserve the last evaluated math. See the GDD for the complete contact rules.

The formula panel is part of **Developer Overlay Visible**, alongside the normal
telemetry panels. **F4** hides/shows them together while the gym is focused,
including while paused. The same single switch is in **General → UI & debug**
in both the editor and in-game Portal. Gameplay Heat/orb/objective UI and the
target-owned overhead Health label remain visible. Player Health currently exists
in the hidden developer telemetry, not a separate always-on gameplay control; no
new Player-health UI was authorized. The Dev Portal window still uses its separate
backtick open/close shortcut.

Captured values keep updating while the overlay is hidden. Retry gym clears the
cards and reconnects the Enemy while retaining your shared visibility choice.
The shortcut changes the current run, and retry retains that visibility choice.
Use **Review & save** in the editor to set the default for future launches;
the runtime Portal saves the same shared preference. The obsolete
formula-only preference is ignored when an existing Developer Overlay Visible preference is present. No combat values or
rules are changed by toggling the overlay.

## Playtest observations

### Daytime candidates — October 22

At daytime closure X5 was provisionally retained as C7 .30/1.10; October24 T1
is now the0.55/1.10 human-review candidate described above. Main's earlier Right D/C7
openings both landed five X and empowered Lv5/APPLIED13; C7 contact/launch were
earlier, with both continuous fights ending70HP. A separate Left opening and
continuation also succeeded. This supports reduced setup delay into existing
poses, not a new artistic treatment, all-cadence/high-Heat protection or human feel
acceptance. The [range96 comparison](iterations/2026-10-22-fire-combat-daytime/ITERATION6_REVIEW.md)
was rejected; Enemy attack_range is restored72/A9682BE0. No retreat policy or
physical dodge safe-end correction was added. The
[Cast presentation review](iterations/2026-10-22-fire-combat-daytime/CAST_PRESENTATION_REVIEW.md)
retains the unsolved origin/brief-impact and failed/ignored reason-display limits.

Current Player C2 (9b705e0d) replaces the rejected input-based dodge handoff with
a completion-frame final-pose hold, then actual-motion Walk/Idle. Main observed
no false Walk at a blocked wall, three24-tick/0.4s repeats and immediate permitted
X afterward. New action/hurt/reset priority and physical dodge rules are unchanged.
That historical C2 did not fix the separately reproduced Enemy-overlap correction.
The later one-time extension above is now approved as its bounded follow-up;
deliberate AI-spacing policy remains open. C2 footage is not evidence for the new
extension.

Fire projectile child size is now36x27 at Lv1 and72x54 at Lv3. Selected in-flight
images support larger drawings, not a matched-distance readability or hip-origin/
point-blank visibility cure. That daytime SFX candidate was-6dB; the later
authored f6ccfbe0 baseline stores-20dB, preserved by the October23–24 run.
Original clips/pitches remain retained. The daytime12s Master WAVs show lower recorded RMS and
fewer encoder-overrange samples; no comfortable-loudness/audition pass is claimed.
The recorder's optional capture_audio_seconds defaults off and changes no game
mix. Main also verified an early-quit WAV prefix, not a full requested duration.
See [daytime progress](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md) and
[Implementation Status](IMPLEMENTATION_STATUS.md) for exact source/evidence limits.
All daytime tuning remains candidate state pending user controller acceptance.

### Retained earlier feedback and HUD observations

Retained feedback candidate H lowers direct/DoT anchors by52 pixels (−186/−154),
Cast-level stays−118. Supervisor actual viewport review supports fresh numbers
closer to the affected fighter and clear of EventPanel, with initial Player
DoT/Cast glyphs separated. Old fading numbers can drift back into the header,
and repeated NPC numbers still overlap. No scale/clamp/stacking solution or
uniform-resolution readability is claimed. Headless110 includes layout-only
DoT/zero/palette probes; current Gym has no Fire DoT gameplay. Capture-mode68
and inspected real combat images are separate evidence; human acceptance pending.

The October22 retained cue2 is the existing empowered school-colored square at
half-size6 local, facingX8/Y-66, lifetime0.45s with the same event/audio/z4. Main's
both-facing1280x720 images support above-Player ownership, not final art acceptance.
The Cast-label-over-face/shared-anchor issue remains a morning proposal: the
suggested-254 offset collided with the current HP row and was cancelled before
editing FeedbackComponent. No alternative shared anchor or class coupling exists.

The retained HUD candidate adds faint neutral empty-slot rings without altering
occupied fill/charged outlines. Orb rebuilding detaches old slots before queued
deletion so the existing overflow flinch no longer measures old/new slot sets
together. Fresh normal-generation replays support500px native Gym width through
overflow, full10/eightcharged and consumption/empty states; the4px flinch itself
is unchanged. Scope/version limits and outstanding checks are in
[Implementation Status](IMPLEMENTATION_STATUS.md). Supplementary regression
execution is complete; human acceptance and the listed coverage limits remain.

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
