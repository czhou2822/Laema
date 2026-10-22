# Technical Design Report — Orb Casting and Tutorial Stage Architecture

Current architecture consolidated October 20, 2026. This updates the existing
technical record; it is not an independent implementation audit or submission
clearance. The [GDD](GAME_DESIGN.md) owns gameplay intent and
[Implementation Status](IMPLEMENTATION_STATUS.md) owns revision-specific evidence.

## Fire X5 shove and Fireball anchor amendment — October 22

Source basis: `fd72f4e2a83960abb862da09ae98fb210c5c8410` plus the scoped
candidate on `codex/combat-feedback-fixes`. This is not a main-tree merge,
rendered validation or submission-clearance receipt. The user approved the
0.15-second shove for all qualifying Fire X5 bands, unchanged stun, and actual
Fire projectile emission at the raised hand. No dodge source or tuning is part
of that two-fix amendment. The brief later acceptance of immediate overlap
correction is superseded by the approved one-time extension in the Fire dodge
section below. Neither decision supplies blanket controller or visual-art
acceptance.

`MoveStyleTuning.push_motion_duration` follows the existing style capture,
Inspector and Portal/save path. Fire X5 stores 0.15; omitted/zero values retain
full-reaction motion. Validation permits a finite nonnegative override only on
`fire_x5`; other moves remain zero and expose no new Portal control. A live edit
affects the next captured action, not an active X5. No JSON file/schema migration
or room-specific override is introduced.

Might copies the captured Fire X5 value into its existing `HealthEvent`.
HealthResolver retains it with direction/push scale through immediate resolution
and strongest-reaction transactions; Entity/CombatEnemy forward it through the
existing captured reaction request. HitReaction captures the unchanged selected
duration/distance and caps positive motion time at that duration. Its body-motion
clock consumes uniform displacement over the motion time, then returns zero
while its original lifetime continues. Existing body owners still apply
collision-aware movement and finish the reaction only when that original
lifetime ends. Hurt, control lock, invincibility, bands/eligibility, AI recovery
and other attacks' motion are unchanged. Blocked displacement is consumed, not
stored for later.

Player maps source-cell hand pixel `(205,235)` from the 448-square Fire launch
pose (cell 3 at native 0.24) through centered cell coordinates, Sprite offset,
committed-facing reflection and `Sprite.to_global`. The resulting origin is
carried by the existing projectile request, moving its actual collider and
drawing together. Non-Fire primary Casts retain root plus facing times42.
No marker, projectile owner, collider size, direction, speed/range, damage,
level drawing or audio changes. The user accepted the raised horizontal shot's
short-legacy-dummy miss without a target/trajectory repair.

## Castle levels 4–7 amendment — October 22

The approved prototype extension adds four actor scenes originating on branch
`codex/castle-creatures-4-7`, based on `5fe2886f`. The user authorized its scoped
creature/shortcut commit and merge into local `main`. Each creature was handled by
its own subagent; the parent owns the shared catalog, shooter binding and
canonical records. Existing unrelated combat tuning remains separate.

| Catalog ID | Scene | Existing execution owner |
| --- | --- | --- |
| swordsman | scenes/enemy/swordsman.tscn | CombatEnemy grounded melee |
| monk | scenes/enemy/monk.tscn | Archer ranged and close melee |
| cavalier | scenes/enemy/cavalier.tscn | CombatEnemy grounded melee |
| angel | scenes/enemy/angel.tscn | CombatEnemy grounded melee |

All inherit the existing shared Settings, hit reaction, behavior tree and
collision contract. Their selected generated character sheets use 768x640
cells/four columns and anchor(384,448), registered with scale1/offset(0,-128).
The current 1.0s attack clocks and temporary melee geometry are retained;
sprite keys follow each source sequence's own frame count. Each creature's
provenance and compact source manifest record exact selected paths and hashes.

Archer exposes `ranged_projectile_scene`, defaulting to its existing ArrowScene.
Monk overrides that PackedScene with `scenes/combat/monk_bolt.tscn`; it retains
the `melee_swing` and `archer_shoot` execution aliases while binding its own
Animation resources. The bolt uses the existing enemy_arrow.gd lifecycle,
direct unschooled HealthEvent, swept collision and enemy_projectiles cleanup.
Its original CPRZEAX horizontal frame is preserved reference art because the
selected high-resolution collection supplies no detached projectile. Damage,
Impact, range, attack choice, commitment, interruption and reset remain with
the existing owners. No per-creature combat profile is introduced.

Both Portals continue reading the same catalog and ui.enemy_creature preference.
The loader's unavailable-choice message is generic so it matches this expanded
roster. All four new actors leave their inherited Pikeman audio streams null;
new SFX assignments remain open. Source/static checks establish no Godot import,
runtime, final art, mounted/airborne presentation or contact-alignment approval.

## Creature roster amendment — October 22

This scoped candidate adds Pikeman, Archer and Griffin to one selector without
changing the shared character-settings ownership described below. The source
basis is `dda30976` plus this scoped creature revision, originating on
`codex/castle-creature-roster`. The user authorized committing it and merging
into local `main`; unrelated Fire/player tuning is excluded. This is not a
tested revision, submission clearance or remote-publication receipt.

The later high-resolution presentation correction originates on
`codex/castle-creature-hires`, based on roster merge `fd72f4e2`. The user
authorized its scoped commit and merge into local `main`. It changes
character sheet bindings, atlas rectangles and sprite registration only;
other ongoing tuning is outside that slice. Its available evidence and source
digests are recorded in IMPLEMENTATION_STATUS.md and creature provenance.

`scripts/config/creature_catalog.gd` owns the stable IDs and PackedScene paths:
`pikeman` -> `scenes/enemy/combat_enemy.tscn`, `archer` -> `scenes/enemy/archer.tscn`,
and `griffin` -> `scenes/enemy/griffin.tscn`, plus the four IDs listed above.
Both Portals use the same catalog.
The preference `ui.enemy_creature` belongs to `config/prototype_combat.json`;
older configurations default to Pikeman. Validation rejects unavailable IDs.
Save Tuning and the editor's review/save retain the existing merge/conflict flow.

Before a StageArea enters the tree, PrototypeArena replaces only its existing
`FinalEnemy` slot with the selected scene. Name, transform, encounter ID and
final/refill roles are retained. Other area contents and practice targets are
unchanged. Each new scene inherits CombatEnemy and the same
`config/characters/combat_enemy.tres`; there is no new room combat profile.
The runtime Portal emits the spawn request; the editor sends the equivalent
`spawn_creature` debugger command. Both call the arena's existing restart path.
Training stages without a final-enemy slot reject that action with a message.

PrototypeArena also owns physical top-row 1–7 creature shortcuts in
`_unhandled_key_input`: Pikeman/Archer/Griffin/Swordsman/Monk/Cavalier/Angel
route through the same
`spawn_developer_creature` request and existing restart owner, with no new
selection setting or live-actor mutation. Only fresh, unmodified key presses
are accepted; echoes, releases and numpad keys are ignored. Shortcuts do not run
while the Portal or pause menu is open, before an area exists, during transitions,
or in training areas without `FinalEnemy`. Input-map setup removes the former 1–4
school-key bindings, including stale bindings from an earlier arena in the same
session. Controller D-pad bindings and school-selection logic remain unchanged.

Gym retry carries the selected ID through SceneTree metadata, independently of
the saved file. Its persisted-config comparison retains the true disk value so
Save Tuning can still save a run-only choice after retry. A new launch uses the
saved preference. Spawn/retry resets the encounter rather than mutating an
in-flight actor; root cleanup also removes `enemy_projectiles` such as arrows.

CombatEnemy exposes per-scene textures, cell layout, frame counts and optional
mirrored sprite offset while retaining Pikeman's exact defaults. Archer and
Griffin now bind existing generated review sheets under each creature's
`highres_v01/` folder: four columns of 768x640 cells, scale1 and offset(0,-128).
The source cell anchor(384,448) maps to the inherited BodyVisual(-11,31);
the 60x180 capsule is unchanged. Griffin retains Idle8/Walk4/Hurt7/Death9
and a nine-pose attack. Its native Animation resource retains
the existing 1.0s clock, active0.5..1.0 and all Pikeman AttackCast key values.
Its original-source cues use the existing playback/mix owners. Archer may leave
unassigned streams null; shared playback skips those streams.

Archer's subclass adapts the existing tree's approach-stop range to awareness,
then captures melee versus shooting at windup start using the shared
`attack_range` threshold. It retains separate native `melee_swing` and
`archer_shoot` aliases. The provisional clips both last1.0s; melee is active
0.5..1.0, and shooting releases one arrow at0.5 with active-end0.625 and the
remaining authored recovery. The arrow captures damage/Impact, direction,
awareness-distance limit and an exported1.0s travel-duration placeholder.
It is parented under the arena, joins `enemy_projectiles`, and sweeps each
travelled segment against Player/level collision. One contact consumes it through
the existing direct HealthEvent path; a shot does not enter simultaneous melee
clash arbitration. Current generated character sheets, preserved original
character/arrow sheets and source hashes are documented
in `assets/prototype/enemy/archer/PROVENANCE.md`. These are implementation
candidate details, not recovered Heroes battle timing or runtime evidence.

Animation cloning reloads the external resource's own path before duplication;
a creature's `melee_swing` alias therefore retains its own native clip. The
`use_shared_melee_geometry` flag defaults true for Pikeman and is false in the
non-Pikeman creature scenes. Their authored geometry is not overwritten by
Pikeman's mirrored reach/radius settings. Those two Portal controls are hidden
for native-creature selection, and saving that selection skips Pikeman geometry
writes. Native Animation tracks remain their geometry-editing source.

Static syntax parsing, JSON/resource/reference checks and original-byte checks
are the available evidence. Godot import, editor/type checking, running gameplay,
tests, facing/feet/contact validation and human acceptance remain unverified.
See IMPLEMENTATION_STATUS.md and each creature's asset provenance.

## Fire visual amendment — October 21

X1/X4/X5 reference transparent
R05/R02/R04 derivatives in `fire_sword_shield_v01/overnight_v04/`, containing
8/3/7 fixed 448px cells. X4 maps its six existing keys to cells0/0/0/1/2/2; X5
selects R04 poses1/2/3/4/6/7/9. X2/X3 retain v03. Existing FIRE_ART_ROOT selects
the same body/registration/facing profile without a script edit. That art-only
amendment changed three texture paths and X4 region values; it preserved Animation
IDs/UIDs, key times, clocks/markers, AttackCast tracks and move settings. Anchor(224,400),
offset(0,-124), root2/Sprite0.5, all prior PNGs and Idle/Walk/Hurt/Cast remain.
Generated cutouts are derived artwork, not pixel-identical extraction. Exact
transforms/phase maps are in `art/preparation/2026-10-21-fire-v01/`. That art-only
step had no Godot validation. The subsequent October 21 Fire X1–X5 alignment pass
corrects only AttackCast position/target key data against the current visible
blades, including X2's forward poses. Artwork, Sprite keys, active timing and
radius 3.5 remain unchanged. Independent Godot 4.7.1 checks and viewport inspection
support this candidate's alignment; see the [bounded implementation review](iterations/2026-10-21-fire-hitbox-polish/supervisor-review.md).
Human feel/transition acceptance and game-wide clearance remain open.

<a id="scope-and-selected-decisions"></a>

## Scope and source basis

The prototype covers four-school side-scrolling combat, five global X/Cast
positions and an optional sixth Cast-only endpoint, ten-orb FIFO storage,
eight-level Charging, Stage 1–7 tutorial progression, Final Arena/free practice
and the shared-character Gym. Mirham, narrative and future spell-loadout proposals
remain outside this implementation scope.

Settled October 20 decisions:

- Cast commitment and qualifying APPLIED direct hits restart Heat's five-second timer.
- Shared reaction durations are 0.25/0.55/0.85/1.15/1.45 seconds; distances remain 5/10/15/20/25 pixels before move push scaling.
- Air X5 uses the approved eleven-frame Weapon Summon sheet.
- The user confirmed the editor's BTRandomWait of 0.3–0.8 seconds after the Enemy hit-reaction task. This separate AI wait does not extend HitReaction-owned hurt, knockback or invulnerability. The tree and reaction tuning were not edited by this synchronization.

Consolidation source basis: HEAD `fcddaadb460cd84b85727fe11dc02ac41919aff6` plus
the then-inspected uncommitted tree. The later collision amendment describes its
scoped working-tree changes and evidence in Implementation Status; the older
consolidation hash is not a tested identity for that amendment.
The [complete pre-consolidation TDD](history/2026-10-20-tdd-housekeeping/sources/docs/TECH_ARCHITECTURE.md)
preserves amendments, alternatives, exact older evidence and waivers. Consolidation
alone asserted neither a clean tree, remote publication nor new runtime evidence.
The later collision amendment's focused evidence is recorded separately below.

The captured October22 daytime baseline was HEAD921fd1ae plus the intentionally
dirty tree, not a tested commit identity. Retained C2 gameplay/source, reports and
evidence were first published as **05fb22b819e95919da74bcd7c0b57587b5e6f95b**.
Main verified the push and independent remote-main/local-HEAD equality at
**12:03:26 HKT October22**; see the [publication receipt](iterations/2026-10-22-fire-combat-daytime/PUBLICATION.md)
and [daytime report](iterations/2026-10-22-fire-combat-daytime/REPORT.md).
That first lunch receipt remains a historical snapshot; later candidate publication
state belongs to Main's receipts/source identities, not this numerical sync.
The current provisional human-review candidate uses Player
9b705e0d (C2), Fire projectilecc1101fc, X4 style90f963de, SFX JSONddab1126 and
opt-in recorder63409fd5, plus ObjectiveWidgete91201b5 (C4). X5 is now C7
651d9978: windup0.30/recovery1.10, base1.40s. Enemy attack_range72/A9682BE0 is
restored after the rejected range96 trial; no retreat policy was introduced.
The overnight X5 D57aef5ab is historical comparison evidence, not the current
style identity. All other retained overnight work remains inherited.
See [daytime progress](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md) and
Implementation Status for isolated run identities and limitations. All daytime
tuning/presentation remains candidate state pending user controller acceptance.

<a id="implemented-codebase-map-and-postflight-basis"></a>
<a id="implemented-ownership"></a>

## Runtime ownership

### Art-aligned collision amendment — October 20

The approved hitbox correction changes the six native melee geometry curves,
Player's body-profile handling and the reusable CombatEnemy capsule/facing path.
The position/target/radius interface, layers, common-sample evaluator and spent
target records remain. Fire X1–X5 use a 3.5-local-pixel radius (7 world pixels)
along their measured guard-to-tip segments. Pikeman uses radius6 along its forward
hand-to-tip segment. Capsule centers are inset at both ends so their outer ends
reach the measured weapon endpoints. Held geometry keys share exact sprite-key
timestamps, plus unchanged active boundaries; no interpolated ghost sweep is added.

Player owns `sync_combat_body_profile()`. It follows the actual committed texture
during an action, refreshing selected-school locomotion/Hurt outside actions.
Movement invokes it before moving the body; Might invokes it before/after clock
advancement and at the end of the contact frame. Thus all actors query the updated
body after the common advance barrier. Fire uses a private 30×90 RectangleShape2D
at(0,-19), with root scale2: 60×180 world and bottom localY26. The original26×30
shape at(0,11) is restored for legacy art. Configuration captures the original
shape and floor reference once; sprite offset(0,-124) is preserved. Reset/death
also clear the visual Hurt lifetime/tween so it cannot select stale body art.

CombatEnemy's scene capsule is radius30/height180 at(-11,-59), retaining bottomY31.
Its query mirrors around BodyVisual's X position(-11), using the same transformed
pose for contact collection and the yellow overlay. Root/sprite scales, spawns,
ground anchors and AI approach range remain. No separate hurtbox or new layer is
introduced. See Implementation Status for the focused test/capture results and
retained shutdown diagnostics. Earlier art-only integration paragraphs below
describe the preserved pre-correction geometry, not the current collision sizes.


| Owner | Responsibility and lifetime | Source |
| --- | --- | --- |
| PrototypeArena | Persistent Player/HUD/audio/projectiles, Stage Areas, camera and transitions | [prototype_arena.gd](../scripts/prototype/prototype_arena.gd) |
| Player | Input/facing, movement/combat facade, Settings, death lock and ordered reset boundary | [player.gd](../scripts/player/player.gd) |
| MightComponent / InputCombo | Action acceptance, six-slot progression, earliest-request buffer, action clocks and immutable outcomes | [might_component.gd](../scripts/combat/might_component.gd), [input_combo.gd](../scripts/combat/input_combo.gd) |
| MagicComponent | FIFO queue, banked Charging, pressure, immutable Cast commitments/composition and generic layers | [magic_component.gd](../scripts/combat/magic_component.gd) |
| HeatComponent / CombatComponent | Heat/timer state; synchronous routing of commitment and result facts | [heat_controller.gd](../scripts/combat/heat_controller.gd), [combat_controller.gd](../scripts/combat/combat_controller.gd) |
| ContactEvaluation | Scene-local common-sample ordering; actors retain clocks, curves and spent-target records | scripts/combat/contact_evaluation.gd (uncommitted candidate) |
| HealthResolver / Health / Status / HitReaction | Defence/eligibility, damage/result delivery, optional effects and captured reaction displacement/lifetime | [health_resolver.gd](../scripts/entities/health_resolver.gd), [hit_reaction.gd](../scripts/entities/hit_reaction.gd), [status_controller.gd](../scripts/status/status_controller.gd) |
| CombatEnemy / LimboAI | Actor action identity, movement/playback; tree decisions, reaction and post-reaction wait | [combat_enemy.gd](../scripts/enemy/combat_enemy.gd), [final_enemy.tres](../ai/trees/final_enemy.tres) |
| StageDirector / evaluators | Stage lifecycle and objective state, with one evaluator per active stage | [stage_director.gd](../scripts/prototype/stage_director.gd) |
| HUD / ObjectiveWidget / Feedback | Render observed state, with no combat/objective/Heat authority | [prototype_hud.gd](../scripts/ui/prototype_hud.gd), [objective_widget.gd](../scripts/ui/objective_widget.gd), [feedback_component.gd](../scripts/entities/feedback_component.gd) |

CombatComponent stays a thin facade. CombatOutcome events are observational and
cannot independently mutate Heat or recreate queue/chain state. Entity scenes
compose common Health, Status, Feedback and HitReaction contracts. Practice
targets remain stationary/non-attacking/pass-through and refill at zero Health
without clearing effects. CombatEnemy is solid/killable; death removes combat
collision. Player death locks movement/combat; reset unlocks it. The optional
1-HP floor is disabled and never heals on toggle. Broader defeat design remains
separate from Gym retry.

<a id="air-x5-weapon-summon-correction--october-20"></a>
<a id="active-window-melee-and-cast-launch-amendment--october-20"></a>
<a id="authored-enemy-animation-timing--2026-10-19"></a>
<a id="native-cast-completion-guard-correction--2026-10-19"></a>
<a id="native-attack-animation-and-hitbox-authoring--2026-10-19"></a>
<a id="fire-and-cast-reaction-progression--2026-10-19"></a>
<a id="school-attack-styles--2026-10-16"></a>
<a id="might-magic-heat-and-combat"></a>
<a id="elemental-endurance"></a>
<a id="first-active-final-enemy-and-player-health-floor"></a>
<a id="arena-and-projectile"></a>
<a id="core-flows-and-contracts"></a>
<a id="queue-and-l2-pressure"></a>
<a id="commitment-buffering-and-heat"></a>
<a id="receiver-side-clash-formula--2026-10-16"></a>

## Combat execution

### Actions and native timing

Might accepts/queues X and Cast through the shared normalized buffer, captures
school/facing/style and private geometry curves, and starts the next action on
completion. Leftover substeps cannot advance a replacement action. School changes
affect future actions without consuming chain/buffer capacity. Magic's pressure
preservation, not queue occupancy, determines between-action timeout/movement.

The October22 retained Might candidate reasserts movement_lock_changed(true) in
the common _start_action path before move lookup/playback. Thus every actual
X/Cast start reacquires the existing Movement lock even when COMBO_ACTIVE survived
an unlocked gap. Existing finish/READY paths still unlock; queued starts merely
reassert true. Movement remains the only mover and its motion consumer is unchanged.
This repairs consumed-but-unapplied lunge after preserved gaps without changing
the FSM, input windows, captured facing/style, lunge values or dodge path.

Native Animations own sprite frames, geometry and active bounds. Player X phase
durations map around optional pacing-only timing_split (fallback active_start)
and scale once with Heat. That split emits no hit. Cast uses its primary-school
clip and once-only launch marker. Completion matches the assigned clip rather
than the legacy attack_clock label; an owned paused action still exposes progress.
MovementController remains the sole Player body mover. It consumes predicted
lunge through collision, consumes blocked motion and discards cancelled remainder.
Push scale changes qualifying reaction distance only, not eligibility or duration.

The daytime Fire X4 candidate is windup0.33/recovery0.36 (base0.69s), replacing
recovery0.51 only. Player Settings/attack_styles supplies moves.fire_x4; the
existing phase-speed consumer shortens playback after timing_split0.70, including
late active frames and the real-time input window. Native keys/geometry, normalized
windows, lunge and push are unchanged. X5 can start0.15/Heat-multiplier seconds
earlier; this does not guarantee unchanged timing relative to the Enemy.

Fire X5's current provisional C7 Resource is windup0.30/recovery1.10 (base1.40s,
651d9978), captured through the same Player Settings/style path. Native length1,
timing_split0.60, active0.36..0.80, geometry/Sprite keys,12-unit lunge at0.15..0.55
and push2 remain. Pre-split native playback is1.5x its D rate; later native rate
is unchanged. Poses, lunge and active-boundary wall times advance, while real-time
input/buffer spans also change under the unchanged normalized rules. X4 completion
and actual X5 action start are not moved by this leaf; X5 finishes and a queued
Cast can start0.15/Heat-multiplier seconds earlier at constant Heat. Actual contact,
collision and live Heat remain authoritative; this guarantees no Enemy-invulnerability
margin or aesthetic improvement. Main's initial15:48 selection used scoped
Right/Left rendered comparisons plus one supplementary X5-only1545-check suite.
The final17:09 current-C7 run completed all five existing suites:7044 checks,
zero assertion failures and explicitly waited exits0, with shutdown warnings
retained; see the [final regression manifest](iterations/2026-10-22-fire-combat-daytime/FINAL_REGRESSION_MANIFEST.json).
Forced Heat/preparation/seeks/collectors remain supplementary, not primary play,
tutorial reachability, NPC safety or human acceptance. Open compatibility findings
and unanswered human choices are not cleared by this result.

Later Main-run C7 practice reached genuine100 Heat through48 normal Lv1 Casts,
then accepted all five X positions/full35 lunge at0.43s cadence; onlyX3 hit the
short dummy. An empowered Lv2 applied13 there; a separate ordinary Gym Lv8
applied10 and its same encounter later ended Player60/Enemy0. These are bounded
resource-earned cases, not all-five-hit tutorial completion, high-Heat NPC
invulnerability clearance, controller/feel or eight-note audition acceptance.
See Implementation Status and the
[daytime ledger](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md).

Historical overnight D Resource was windup0.45/recovery1.10 (base1.55s,57aef5ab),
captured through Player Settings/attack_styles into moves.fire_x5. Its native
length1, timing_split0.60 and active0.36..0.80 remain unchanged. Positive recovery
duration controls native0.60..1.00, including late active frames; phase speed is
Heat multiplier times native span divided by captured duration. Cast retains its
shared1.2s base and native launch0.24. D's low-Heat comparison and added latency
are scoped agent evidence, not accepted feel or high-Heat protection clearance.

### Fire dodge — October 21

The user verified the exact GDD synchronization and approved this bounded
implementation plan. Might owns the Fire-only dodge action, its fixed 0.4-second
native Animation clock, locked direction and post-completion 0.37-second cooldown.
The October22 approved exception adds one conditional 0.1-second end-overlap
phase without retiming that clip; the scoped source basis is `cfa537d` plus this
follow-up on `codex/combat-feedback-fixes`.
Combat remains the input/resource facade; Movement remains the only Player body
mover. There is no additional component, global owner or second movement timer.

Arena binds Circle through a fresh-press `dodge` action. Player supplies the
controller's horizontal stick direction, with neutral stick falling back to
Movement's facing, and captures current normal movement speed. Might's existing
body-motion provider normally delivers 0.4 seconds of that speed over the dodge. Movement
consumes blocked displacement, retains wall/floor collision and temporarily adds
body-pair exceptions against existing enemy entities. It restores only exceptions
owned by this dodge; query/damage layers and authored body profiles do not change.

Player wires a local overlap query from Movement to Might during existing
configuration. Movement checks current enabled collision shapes/transforms
against combat Enemies already held in this roll's body-exception list, not
sprite bounds, an approximate radius, practice targets or a new target scan.
Might defers the native-finish decision to its existing end-of-physics-frame
hook, after the final body step and common contact samples. Both native finish
routes mark the same boundary instead of independently restoring collision.
Clear rolls finish normally. Actual end-overlap extends the same captured action
and body-motion budget once, from0.4 to0.5 seconds. The existing body-motion
elapsed value advances only as Movement consumes physics time, including blocked
motion, so an animation substep cannot spend grace before any extra body step.
There is no new Timer, movement owner or global0.5-second gameplay cooldown.

During that extension Might remains DODGING: Player's existing invulnerability
query, Combat's action/pressure suppression and Movement's owned exceptions
remain in force. Player holds the final native pose without replay or stretch.
Normal completion stops playback with visual state retained, rather than
resetting the held endpoint to the clip's first cell; interruption keeps its
existing reset/higher-priority presentation path.
Only actual completion publishes the existing single finish event, restores
owned exceptions, rearms pressure and starts the same0.37-second cooldown.
The one-shot action state clears through existing completion/cancel/reset paths;
stage lock/death still cancel immediately. If overlap remains after0.1 seconds,
collision restores anyway and ordinary correction may occur. There is no
loop-until-clear, new AI response, generic extra clear-roll travel or promise of
exact Dead Cells animation/cooldown parity.

Might accepts cancellation of a committed Fire X strictly before native
active_start, or a Cast before its once-only launch. Active/recovery X and
post-launch Cast ignore Circle without buffering. Existing stage/death, reaction,
suppression and defence commitments are not new dodge-cancellation paths. Starting
dodge ends the current input-combo and clears pending/buffered actions through
their existing interruption outcomes. Cast commitments already consumed their
orbs: discard cancelled commitments, never consume or refund them again, and
preserve unconsumed FIFO entries and existing Heat accounting.

Magic clears charged coverage and partial progress without changing queue order
or the front orb's lifetime. Combat suppresses gameplay input and pressure
dispatch during dodge. Magic's pressure rearm boundary observes the input without
dispatching a Cast at dodge completion: a still-held input requires release before
a later press can charge again. No stale release, buffered input or held Circle
may restart an action. The cooldown itself rejects only new dodge attempts.

Entity exposes a shared combat-invulnerability query; Player adds active dodge to
the existing reaction/pending-reaction protection. HealthResolver uses that query
both for ordinary damage and before simultaneous-clash interception. Contacts
retain the existing spent-target rule even when rejected as INVINCIBLE; dodge
creates no melee contact, resource reward or hit reaction of its own.

The new `fire_dodge.tres` plays the approved original 12-cell idle-exit atlas at
native speed1 over 0.4 seconds, without Heat scaling. Sprite.flip_h is the sole
mirror. Other clips and the existing Fire body/feet profile remain untouched.
The optional running-exit atlas stays unused; normal locomotion resumes through
its existing path after completion. Wall contact changes neither the clock nor
invulnerability. Pause freezes the existing scene-local physics clock. Stage
lock, death and reset stop dodge, restore owned collision exceptions and clear
its transient state/cooldown; reset retains its established school policy.

Daytime C2 Player presentation retains native dodge Sprite ownership until Might
releases the action. It holds the last native pose only for the completion
physics frame, then resumes the existing actual-motion Walk/Idle path. The
rejected C1 raw-input walking inference is removed. New action/school, hurt,
stage-lock and reset clear the private handoff frame; hurt/action/defence keep
priority. No input/state lock, timer, animation length, movement or collision
restoration changed. Main's C2 held-wall replay supports removal of the false Walk
frame, not all dodge cases or human feel acceptance. The historical baseline
overlap case had120 units of travel followed by collision recovery. The later
approved one-time extension above supersedes immediate restoration in that case;
it does not clear the new candidate's rendered/human validation or settle a
deliberate AI-spacing policy.

No JSON schema, saved tuning, Portal controls, audio, enemy AI or other school is
changed. Existing instrumentation is retained; the normal observational outcome
stream carries dodge start/end and interruption facts, not a new diagnostic probe.
Initial integration used static source/resource inspection. Later Main-owned
rendered normal-input observations through October22 07:19 support current-D
windup/prelaunch cancellation and accounting, active/postlaunch ignore, held
Charging rearm, real invincible wall contact and return to the same encounter.
Earlier same-Might high-Heat practice supports fixed24-tick duration/hold behavior,
not high-Heat Pikeman contact protection. Physical analog-stick priority, human
acceptance remain open. The later five full headless suites completed as
supplementary controlled regression execution, not controller/parry/AI acceptance.
No independent audit or blanket
runtime clearance is implied; exact scope/version evidence is in
IMPLEMENTATION_STATUS.md and the overnight ledger.

### Active-window contact and reaction ordering

Status: `IMPLEMENTED_AWAITING_USER_VALIDATION` in the uncommitted working tree.
This replaces historical single-contact and synthesized-counter algorithms.
It does not establish runtime validation or Ultron clearance.

Might and CombatEnemy keep their existing action IDs, native AnimationPlayers,
per-action target records, collision queries, and cancellation/reset ownership.
A scene-local `ContactEvaluation` node coordinates their callbacks at physics
priority 2 after ordinary actor/movement processing. It holds weak actor references,
inherits the scene's pause lifetime, and removes expired registrations; it is not
an Autoload or global event bus. Each physics update evaluates the current pose,
then advances all eligible clocks to common sample times before collecting any
contacts. Substeps are bounded at 1/120 second and split at authored marker/key
boundaries, so a large update also visits a short active interval. This is discrete
animated-geometry sampling, not an analytical continuous swept-volume solver.

At each sample, both actors query their own facing-transformed animated geometry
throughout inclusive `active_start..active_end`. Geometry curves are captured from
the actor's private Animation when its action starts, preserving next-action
runtime-tuning lifetime. A first miss does not close the window. Each target ID
is recorded as spent during collection, before target-side resolution, including
invincibility, block and parry rejection. These contact records are distinct from
APPLIED outcomes and remain until the action is discarded or replaced. Ignored
contacts grant no APPLIED-hit resources or objective progress.

U-001 boundary correction (user accepted): after the active_end sample's contacts
resolve, each actor's existing window-closure flag also makes its melee snapshot
inactive. That snapshot gates collection and live-event validation, so a later
physics tick cannot re-query the same endpoint after bodies move, apply late
damage after a terminal miss, or reuse the retired move's active resistance.
The final endpoint sample itself still resolves before closure. Might records
the testing-only no-contact orb grant before publishing its queue update, keeping
the per-action grant ledger consistent. This is a source/static correction;
Ultron recheck and user runtime validation remain pending.

HealthResolver consumes the collected events. A nonreciprocal contact evaluates
only its actual receiver: incoming Impact minus receiver Poise minus receiver
active-move Impact (zero outside active frames). Negative ordinary connected hits
deal their normal accepted damage without combat interruption. Ordinary Player
zero against a combat Enemy selects configured Level 1; ordinary Enemy zero does
not interrupt. No reverse HealthEvent or reaction is synthesized merely because
the opposing move is active.

If reciprocal active melee contacts are present in the same sample, both
receiver-side signed values are captured before either damage applies. Existing
defence/invincibility interception runs before clash arbitration and is not
applied twice. The larger signed result wins; equality favors Player. Only the
winning actual contact applies damage and interrupts; the losing simultaneous
contact is reported CLASH_LOST without damage. A winning value <= 0 explicitly
selects configured Level 1 through the existing reaction owner, while its signed
raw value remains intact in HealthEvent/debug/result diagnostics. Positive wins
use the existing configured reaction ranges. Thus Player -10 / Enemy 0 and
Player -10 / Enemy -5 favor Enemy, Player -5 / Enemy -10 favors Player, and equal
negatives or 0/0 favor Player. Earlier sequential damage is never revoked.
Weapon-to-weapon overlap is not required; reciprocal character contact is.

Before delivery, events must still belong to the source's live active action.
All clocks advance before collection/resolution, and finished actions are retired
after that sample's contacts resolve. Cancellation stops subsequent queries.
Per-frame action-ID guards prevent leftover substeps from advancing a replacement
action. Enemy BT decisions retain their owner: a newly created windup starts its
clock on the next physics frame; an already-playing attack ticks its BT after the
common clock pass. Body movement, push, reaction execution and AI reassessment
remain in their existing owners rather than acquiring a second gameplay timer.

Might grants at most one generated orb per X action, only after an eligible APPLIED
result; existing full-resist exclusions remain. Its hit/objective outcome is
published once on the first APPLIED contact using the action's captured chain
position. Miss or testing-only no-contact orb outcomes wait until active_end,
and rejected contacts are not recategorized as successful hits or geometric
misses. Existing HealthResult delivery still owns landed-hit Heat eligibility,
Endurance and hit losses. Magic commitment, mixed-Cast transactions, projectile
payloads and projectile impact resolution are unchanged.

Authoring migration:

- Twenty school melee clips and `melee_swing.tres` replace `contact` with the
  optional pacing-only `timing_split` at the identical authored timestamp.
  AttackStyle uses that split for the existing windup/recovery duration mapping
  and lunge prediction; without it, pacing falls back to active_start. The split
  neither emits a hit nor gates contact detection. Active markers, clip lengths,
  sprite/geometry tracks and tuning values were preserved by this migration.
- Four school Cast clips and the generic `attack_clock.tres` rename `contact`
  to `launch` at the same authored timestamp. Might retains its per-action launch
  latch and samples launch before retiring a finished clip, preserving one
  projectile emission even when a large update crosses launch and animation end.
- AttackGeometry reads Portal size mirrors at active_start. Save changes the
  active_start reach/radius keys only, retaining other geometry keys, offset and
  direction; the existing concurrent-edit guard remains. Player and Enemy private
  animations use the same bridge. Editor scrubbing owns the rest of the curve.
- Native validation rejects retired contact markers, checks ordered active bounds,
  required enabled geometry tracks/valid active poses and Cast launch markers.
  Inspector navigation and Portal help describe these contracts. Player/Enemy
  debug hitbox overlays use the same animated poses and active-window visibility
  as their queries rather than a contact-time flash/frozen pose.

Static evidence: whitespace/diff checks; retired-consumer and once-only-delivery
source tracing; native-resource inspection of all 26 marker migrations against
the pre-slice working-copy snapshot, confirming marker-name-only edits with no
timestamp, length, sprite or geometry-track drift. No Godot/editor, engine parser,
compiler/build, playback or automated tests were run or created for this slice.
Existing contact-marker-based test fixtures remain historical and need separately
authorized maintenance/execution. Earlier test totals do not validate this code.

User verification remains for late-window contact and misses, ignored/defended
contact spending, all signed clash cases in either facing/actor arrangement,
ordinary zero/negative controls, multi-target resources/objectives, Cast launch
and mixed layers, cancellation/replacement, pause/reset/retirement, Portal
save/reload and animated debug geometry. Residual risks are Godot parsing/API and
integration behavior, common-sample physics/BT ordering, and sampling cost or very
fast geometry between samples. No tuning, asset/audio replacement, commit or push
is included in this contact slice.

### Enemy execution

CombatEnemy uses native melee_swing speed 1. The current Pikeman clip has ten
evenly spaced frames, active_start/timing_split 0.5 and active_end/length 1.0
seconds. Recovery is any authored tail after active_end; currently none. Tasks
wait on actor progress, not a second windup/recovery timer. Approach range is
separate from hitbox geometry.

The manually ticked LimboAI 1.8.1 tree owns awareness/approach, committed attack,
recovery and reaction decisions. A qualifying hit/losing clash cancels the move;
the tree executes its captured HitReaction request and waits for that component.
The user-confirmed branch then has BTRandomWait 0.3–0.8 seconds before its sequence
completes. This later AI wait adds no reaction invincibility and does not replace
or extend hurt/knockback duration. Live scheduling/feel remains user validation.

An independent prior decision-settings snapshot detects first AI edits through
the existing reset/cancel path; reaction/geometry-only edits do not acquire that
policy. Pending reaction requests protect against duplicates and execute after a
running task unwinds, without recursive ticking. Mixed hits retain one strongest
request. Death/reset/retirement clear pending state. Disabled offensive AI still
permits a received reaction to finish.

### Queue, Casting and Heat

Magic owns ten FIFO slots and eight charged front-orb capacity. Only the front
orb expires; shifting to a new front starts its full lifetime. Capacity banks
while the queue is empty, but HUD progress shows available charged orbs plus
bounded partial progress. Spell Level is derived from visible charged flags,
not duplicated state or the private banked-capacity argument.

| L2 pressure | State and preservation |
| --- | --- |
| 95–100% | CHARGING uses Heat scaling, selects FIFO front orbs and preserves the chain |
| Intermediate 5–95% | Preserves the chain immediately; after 0.3 seconds held continuously, DEPLETING drains newest charged coverage first at baseline speed without Heat scaling |
| Below 5% | RELEASE dispatches one attempt on a later transition; the first pressure sample creates no startup Cast/failure |

Arena registers left-trigger/right-mouse Casting; R1 is defence (Shift on keyboard). Active
actions lock movement/facing separately from between-action pressure preservation.
Charging/Depleting never pause expiry. Failure ends the chain, resets charging
coverage/progress and preserves stored orbs. APPLIED incoming direct damage
removes charged orbs and five Heat; blocked/parried/DoT outcomes cause neither
loss. Reaction strength is not the resource-loss predicate.

The October22 retained Magic repair clears only the Charging/depleting updater
flags at the normal initialized transition into RELEASE, before publishing the
transition/dispatching Cast arbitration. First-request-wins can still ignore a
later Cast with no consumption or self-flinch; queue, banked/charged coverage,
partial progress and front lifetime remain untouched by this flag change. Startup
initialization and the separate dodge-rearm path retain their existing behavior.

Known current seam: Magic records a new CHARGING transition before Combat checks
Might.can_handle_pressure(). A press during HIT_REACTING may therefore publish
CHARGING without starting the updater; the unchanged hold is not retried after
reaction. Incoming-hit resource removal itself leaves an already-running Charging
updater unchanged and establishes no hit-rearm flag. GDD/TDR do not explicitly
settle the press-during-hurt/retry consequence; this paragraph records existing
behavior, not a new selected rule. The overnight repair did not change it.

```text
accepted normal/windowed/buffered Cast
  -> Magic consumes charged prefix and freezes composition/commitment
  -> one synchronous commitment fact -> Combat -> Heat gain + timer restart
  -> Might promotes buffered action if needed -> native launch -> projectile
  -> impact -> primary then optional secondary -> shared HealthResolver
```

The final consumed orb selects primary school; primary level is total consumed
count. Highest-count remaining school is the single secondary, with latest-in
selection on ties. Other schools create no layer but their consumed orbs still
count toward primary level and Heat. Only primary damage gets the empowered
multiplier. Current Casting uses generic direct damage and per-level Impact,
with base Cast Impact fallback; it does not dispatch school/loadout effects.

Commitment grants two Heat per consumed orb once and restarts the five-second
timer. APPLIED outgoing direct melee/projectile hits also restart it. Buffered
commitment occurs before promotion; interruption/miss neither refunds resources
nor revokes Heat/timer refresh. DoT and zero-consumption failures do not refresh
it. After five seconds without qualifying commitment/hit, Heat depletes at three
per second. Heat 0–100 maps linearly to 1.00–1.50 action/Charging speed; Water
block retains its Heat drain. No independent Air-speed or effect Heat owner exists.

One projectile owns travel/range/first-valid-target collision and carries frozen
attribution, direction, schools/levels and empowerment. Mixed layers resolve in
primary-first order before one strongest reaction begins. Ordinary positive
reactions and Player direct-zero advantage remain separate from reciprocal melee
signed-clash arbitration. Failed-Cast self-reactions remain vulnerable.

The retained daytime Fire projectile drawing uses scale
1.5*(1+0.5*(clamped level1..8 minus1)), giving36x27 at Lv1 and72x54 at Lv3.
Other schools retain1x. The October22 amendment above moves Fire's actual
origin/collider to its raised-hand anchor; non-Fire keeps Player root plus42
horizontal units. The radius12 collider, travel, impact and destruction remain
unchanged. Historical size-only captures did not validate this new anchor or
point-blank readability. No persistent impact visual is added.

### Retained disabled Endurance

Current shared Enemy Settings disable Endurance. In its retained tutorial role,
StatusController owns school/streak, capped count, action cache and multiplier.
Might propagates one source_action_id per X/Cast, including both Cast layers;
one action counts at most once. HealthResolver intercepts defence before asking
Endurance for APPLIED damage, applies the multiplier before Health and suppresses
new effects at zero. DoT reads current resistance without changing streaks. A
full-resist tag suppresses orb generation but preserves explicit direct Impact,
reaction and Heat-refresh exceptions. This retained path is not a requirement
to re-enable the buff or a current default acceptance criterion.

<a id="current-representation--character-owned-settings-october-20"></a>
<a id="external-move-style-assets--2026-10-19"></a>
<a id="configuration-persistence-and-ui"></a>
<a id="inspector--portal-tuning-synchronization--2026-10-14"></a>
<a id="focus-editor-integration--2026-10-15"></a>
<a id="configurable-hit-reaction-ranges--2026-10-15"></a>

## Fire defence prototype — October 21

Status: implemented candidate; no engine/runtime/controller validation is claimed.
The user approved R1 press-parry/hold-block, reference defaults and tunability,
with implementation first and this exact record synchronization afterward.

PrototypeArena registers R1/Shift and removes the former default L1 joypad event
when re-entering an arena. CombatComponent receives the existing defend action;
DefenceController owns held input, early/tap windows, success/rearm, control
commitment and shield-reuse time. Its Fire state notification drives the existing
readout and movement-lock composition. Released tap/recovery timers update even
when the physical button is up; stage input lock/reset cancels them. Water keeps
its guard/Heat/reaction implementation, using the shared R1 binding.

Player Settings / Defence owns parry_window=0.20, fire_tap_parry_window=0.37,
fire_control_commitment=0.50, fire_miss_recovery=0.60 and
fire_block_absorption=0.75. Native Inspector and both Portals use the same
character Resource. The loader validates finite values and timing ordering;
older full JSON profiles receive missing fields in memory only. Fire captures
its profile at press, so runtime edits do not shorten an active attempt.

Might permits Fire to cancel a light action strictly before native active_start,
provided no buffered/queued Cast commitment exists. Cancellation clears melee
follow-ups, ends the chain using the existing reset and preserves orbs. It does
not undo accepted Cast commitments or change five-position progression, launch,
Charging, Heat or projectile rules. Action and defence locks are composed at
CombatComponent, preserving the existing movement owner.

Defence interception remains before melee clash arbitration. Fire checks front
facing/direct delivery, returns PARRIED for success, or BLOCKED with captured
fire_defence/block_damage_multiplier on HealthEvent for partial block.
HealthResolver applies chip damage once for that BLOCKED event, skips the legacy
Fire blocked-hit flinch and does not route it through APPLIED resource/status or
Endurance logic. Cached melee interception retains those event fields for final
delivery. Water's full-block behavior is unaffected. Player retains the existing
guard audio/damage display and now selects the accepted Shield Catch v03 atlas
under `fire_sword_shield_v01/shield_catch/`; no scene change is needed.

The read-only `DefenceController.get_fire_visual_snapshot()` exposes captured
elapsed/early/parry/control state. Player presentation maps zero-based frames0..3
to raise/held guard using its existing WALK_FPS=10 sprite cadence. Frame3 is held
while holding or tap-parrying; ordinary BLOCKED results do not restart it.
Only a delivered Fire PARRIED HealthResult starts spark frame4 and success
recovery4..7. Miss/release recovery uses5..7 and never enters frame4. Cosmetic
contact/release clocks use the same sprite cadence, independently of the captured
defence windows. Neither visual timer writes gameplay state or locks movement/
actions; the reuse penalty does not prolong the animation. Movement after control
returns and attack/hurt take priority, while new attempts, school changes, stage lock,
death and retry clear old presentation. Both normal drawing and the existing
pre-physics profile sync preserve the Fire atlas. Source pixels are unchanged;
448px cells, anchor(224,400), offset(0,-124), scale and facing remain. No Godot
import/editor/runtime/build/tests were run for this binding.

The later approved parry response reuses HealthResolver's existing delivery to
both target and instigator. CombatEnemy.receive_health_result recognizes an
outgoing attack whose confirmed outcome is Fire PARRIED. Unless defeated,
already combat-reacting or holding a pending reaction, it cancels its attack and
requests combat reaction value0 with the negated incoming contact direction.
Value0 selects the existing shared Level1 settings without an Impact/Poise
comparison. The ordinary captured request, LimboAI reaction branch and safe
in-tick preemption own execution, body displacement, invincibility and recovery.
The separate post-reaction wait remains unchanged. No new HealthEvent, damage,
resource grant or dedicated stun timer is created. Blocks and misses do not
request this reaction; Player defence timing/control and art remain unchanged.

Representative value flow: saved absorption 0.75 -> character config -> captured
Fire profile -> event multiplier 0.25 -> HealthResolver chip damage -> existing
Health/damage feedback. Parry success clears its action lock immediately but
requires physical release/repress; a missed committed tap starts the separate
0.60s reuse gate. Retry clears timers, held state and rearm. These source paths
are inspected, not runtime proof. The bounded scope excludes dodge, an additional
custom stun beyond the configured Level1 reaction, counterdamage and projectile
reflection.

## Character assets and persistence

| Saved source | Owns |
| --- | --- |
| Player root Settings, normally config/characters/player.tres | Movement, Health/Poise, combat, Charging, Heat, defence, school data and twenty styles |
| CombatEnemy root Settings, normally config/characters/combat_enemy.tres | Health/Poise/Impact, decisions and optional Endurance; reusable root retains killable role/encounter ID |
| Shared config/characters/hit_reaction.tres | Ordered range starts, per-level duration/distance and separate legacy reactions |
| config/attack_styles/*.tres | X phase durations, lunge/push and native Animation references |
| config/attack_animations/*.tres | Twenty X, four Cast, compatibility attack_clock and Enemy melee_swing; sprites/geometry/markers |
| config/prototype_combat.json | Audio, tutorial descriptors/default-stage/transition preferences and UI |

CharacterSettingsStore reads the Settings actually assigned to reusable scene
roots, refreshes external leaves and adapts them to the runtime Dictionary. Both
actors reference one shared reaction Resource; all twenty unique known styles
are required. Scene preference saves strip character sections and
tutorial.initial_school; that school comes from Player Settings. Legacy full JSON
profiles at other paths are compatible inputs, not room-owned combat defaults.
The loader validates eight charged capacity exactly, ten storage and Cast levels
1–8. Dormant school-effect tables remain validated/labeled without activating
their effects; removing them is a separate cleanup scope.

Both Portals and Local/Remote Inspector edit the same effective sources. The
Store merges changed leaves against fresh files, preserves independent edits and
rejects same-field conflicts. Hashes cover character scenes, Settings, styles,
reaction, native Animations and preferences. Startup/reload are read-only.
Explicit save writes preferences, character/style Resources, changed native
active-start size keys and Inspector mirror. Partial failures report stages;
these writes are not a multi-file atomic transaction. The old Player-side
CombatTuning mirror is a view, not a source/profile.

Native scrubbing owns the whole sprite/hitbox curve. Portal reach/radius edit
only active_start size keys, retaining origin, direction and other keys. Private
animations and per-action captures keep an active action unchanged while edits
affect later actions. Unsaved runtime edits last until reload; Save persists
assigned assets. See [ATTACK_STYLES.md](ATTACK_STYLES.md) and [GYM.md](GYM.md).

Reaction starts currently use 0/11/21/31/41, with upper bounds derived from the
next start minus one and an open-ended Level 5. Duration/distance/range tuning
is separate from eligibility. Current accepted durations are
0.25/0.55/0.85/1.15/1.45 seconds. A reaction captures these once; later edits cannot
shorten it. The separate tree wait does not change those component lifetimes.
Fire X5 alone captures a separate 0.15-second motion time through its style and
HealthEvent; positive overrides are capped at the selected lifetime. The full
duration still owns hurt, control lock and invincibility after shove motion ends.
Zero/omitted motion time retains the original full-duration displacement.

<a id="tutorial-root-stage-areas-and-camera"></a>
<a id="stagedirector-and-objective-evaluators"></a>
<a id="player-transition-facade"></a>
<a id="objectivewidget"></a>
<a id="stage-1-objective-evaluation"></a>
<a id="declarative-stage-17-evaluation"></a>
<a id="stage-transition-and-final-arena"></a>

## Tutorial lifecycle

```text
Persistent TutorialRoot / PrototypeArena
├── Player                                persists across stages
├── Camera2D                              Arena-owned
├── HUD
│   └── ObjectiveWidget
├── StageDirector                         authoritative stage FSM
├── CurrentStageArea
├── NextStageArea                         present only around transition
└── audio / projectile infrastructure

StageArea
├── physical floor and backdrop
├── EntryAnchor marker
├── ExitAnchor marker
├── PlayerSpawn marker
├── CameraAnchor marker
├── CameraBounds markers / local horizontal range
├── RightGate collision
├── ExitTrigger
└── stage-owned targets/enemies
```

Stage Area scenes own physical content only. Their shared public contract exposes local EntryAnchor and ExitAnchor positions, PlayerSpawn and CameraAnchor positions, local horizontal camera bounds, gate lock state, exit event, stage-owned Entity set, and one lifecycle state: PREPARED, ACTIVE, or RETIRED. Each area’s flat ground section is authored at the shared ground height and extends far enough to overlap the adjacent area’s ground at the anchor-aligned boundary. They do not evaluate objectives, mutate Player combat state, drive HUD, select the next stage, or choose their own world transform.

Arena owns placement. The first Stage Area is positioned with its EntryAnchor at the tutorial root's initial world origin. For every later area, Arena computes the Stage Area root transform so the next local EntryAnchor coincides with the current world-space ExitAnchor. All spawn, camera, gate, trigger, floor, and Entity coordinates then follow from that single transform. No fixed global stage width or stage-spacing assumption exists.

PREPARED displays the area's environment and supplies floor collision needed for the waiting Player, but every stage-owned combat Entity has combat collision, Health-event reception, and gameplay processing disabled. Arena has not yet connected Entity outcomes to StageDirector. ACTIVE enables stage-owned combat and exit behavior only after the evaluator and outcome subscriptions exist. RETIRED disables all interaction immediately and precedes unloading.

Stage-owned Enemy bodies remain on the target-detection layer used by X and projectiles. Training dummies do not mask the Player body and remain pass-through. The active Final Enemy additionally enables its solid collision layer, so Player cannot pass through it while its AI is active; the layer is disabled when the Final Enemy dies or its AI/stage activation is disabled.

The existing `prototype_arena.tscn` is split mechanically: its final-arena geometry and four target instances move into the Final Arena Stage Area, while its Player, HUD, audio, StageDirector, projectile routing, and new Arena-owned Camera2D remain in the persistent root. Final Arena contains three permanent, refillable, pass-through practice targets and one solid, killable Final Enemy. The shared training Stage Area contains one permanent refill target plus its own gate/exit markers.

The Arena-owned camera has two modes. During an active stage it follows Player horizontally while clamped to the active Stage Area's transformed horizontal camera bounds and fixed vertical framing. During transition it stops following Player and pans to the transformed next CameraAnchor. Laema exits the old frame under ordinary movement; after exit, Arena locks Player input, repositions Laema to the transformed next PlayerSpawn during the pan, and reveals her waiting when the camera arrives.

The current-plus-next rolling window is authoritative. On completion, Arena loads only the next PackedScene resource; no next-stage nodes enter the tree while the player remains free in the completed area. After exit and input lock, Arena instantiates that resource as PREPARED and keeps both areas loaded during the pan. It unloads the completed non-final area only after next-stage activation. The Final Arena remains loaded after tutorial completion.

StageDirector owns one explicit lifecycle FSM:

```text
ACTIVE
  -> COMPLETED_WAITING_FOR_EXIT
  -> TRANSITIONING
  -> ACTIVE (next stage)

FINAL_ACTIVE
  -> FREE_PRACTICE
```

StageDirector owns stage order, active descriptor, completion latch, evaluator lifetime, gate authorization, and ObjectiveWidget presentation snapshots. Arena reports physical milestones—exit reached and camera pan finished—through dedicated lifecycle interfaces. Those milestones do not travel through `CombatOutcome`.

Each active stage has one Node-based objective evaluator created from a closed evaluator-type registry. The evaluator consumes immutable CombatOutcomes, may receive elapsed time for future timed lessons, and returns only objective-domain results: unchanged, progress changed, attempt invalidated, or objective completed. StageDirector discards the evaluator at stage change. Evaluators never load scenes, control gates/camera, reset Player, or draw UI.

Player exposes one stage-transition boundary to Arena. It provides all-gameplay-input lock/unlock and one ordered stage reset. The reset cancels active and buffered actions, clears chain, queue, marks, Heat, statuses, hit-reaction suppression, and defence state, restores full Health, and leaves the active school unchanged. Arena never calls Might, Magic, Heat, Status, Health, or Defence directly.

The reset occurs while input is locked and before the next stage becomes ACTIVE. The school selected at each exit is retained in the next area, including Final Arena after Stage 7.

`ObjectiveWidget` is a reusable HUD-owned Control scene. StageDirector supplies immutable presentation snapshots containing generic rows with stable id, label, optional tokens, evaluator-owned progress/highlight/completed state, attempt invalidation, whole-widget completion state, and prompt text. The widget owns only rendering and its light UI-only flinch. It never consumes CombatOutcome or stage nodes.

Afternoon C4 (objective_widget.gd E91201B5, after the lunch snapshot) adds only two
natural-language row Label properties: AUTOWRAP_WORD_SMART and custom_maximum_size
(max(1, widget width minus actual StyleBox horizontal margins), -1). The current
330px allocation yields326px text width; maximum Y=-1 leaves height unbounded, allowing
the panel to grow down. Width is sampled when rows rebuild, not a generic dynamic
resize guarantee. Strings, fonts, colors, token HBoxes/order, evaluator/progress,
prompt, hierarchy and flinch are unchanged. Scoped rendered fit evidence and the
separate transition-error limit are in Implementation Status and the
[daytime ledger](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md); human
acceptance and other-stage/token-fit clearance remain open.

The HUD scene owns diagnostic/objective layout; source placement is not proof of
rendered readability. StageDirector never interprets layout and HUD never infers
objective success from accepted input or orb creation.

### Objective grammar and progression

Ordered descriptors own stable id/display_name, area scene, objective grammar and
presentation rows, ending with final_arena. The loader requires unique stage/row
IDs, known evaluator types, valid sequence fields/ranges and one final stage at
the end. This is the existing JSON grammar, not a second schematic schema.

Stages 1–6 share one data-driven `SequenceObjectiveEvaluator`. Each descriptor supplies ordered `success_steps`, optional prestart and active invalidation flags, completion progress, a stable sequence-row id, and whether the next expected token is highlighted. The evaluator maintains only PRESTART/ACTIVE/COMPLETED phase, progress, and one pending Cast attempt ID; it exposes the dynamic state for its configured row id.

- **Stage 1:** five landed Fire X steps; a Fire miss invalidates even before progress.
- **Stage 2:** one Cast step requiring level 5. The evaluator waits for the matching Cast-attempt terminal fact; only `launched` at level 5 succeeds. Any non-launched terminal or launched lower-level Cast invalidates. Projectile impact is irrelevant.
- **Stage 3:** five landed X steps followed by a level-5 endpoint Cast launch. Its presentation instructs `Hold L2 + X -> X -> X -> X -> X -> Release L2`; compact token rendering accommodates the longer first and final labels. L2 timing remains guidance and is not evaluated.
- **Stage 4:** `X -> X -> Cast -> X`, with the Cast occupying chain position 3 and the final X occupying position 4.
- **Stage 5:** `X -> Cast -> X -> Cast`, with Casts occupying positions 2 and 4; the second launch completes the objective.
- **Stage 6:** `X -> X -> school switch -> X -> X -> X`; the accepted switch must occur at chain position 2, and rejected or mistimed switches invalidate the active attempt.
- **Stage 7:** the Heat-gated sequence evaluator exposes a Heat row and chain row. Heat at or above 80 marks only the Heat row complete. A chain attempt begins only on landed position-1 X at or above threshold; its five landed X steps advance the chain row. Miss, premature termination, or dropping below threshold during an attempt resets/flinches the chain row, while a pre-attempt Heat drop updates only the Heat row. X5 completes the stage.

**OPEN validation limit — default grounded Fire tutorial route:** the legacy
dummy's50x58 collider at rootY16 occupiesY[-13,45]. Fire X1's complete active
circle/sweep envelope at root2 isY[-180.200919,-34.613020], leaving at least21.61px
of vertical separation. The source inference is that horizontal spacing cannot
make grounded Fire X1 hit this target, conflicting with the default Fire-only
Stage1/7 five-hit route. This is not an other-school/global-tutorial or tall-NPC
impossibility, and not a C7 timing regression. The
[target finding](iterations/2026-10-22-fire-combat-daytime/TUTORIAL_TARGET_FINDING.md)
retains source/observation limits. Target art/collision repair awaits an explicit
human scope decision; no invisible hit-area, evaluator, geometry or GDD rule was changed.

Unexpected actions follow each descriptor's phase rules. Prestart `ignore_unexpected` allows the player to prepare freely where approved. Once an attempt is active, a wrong expected step, an applicable rejected switch, or `chain_terminated` invalidates and resets only the objective attempt. Completion remains latched permanently.

```text
Current non-final stage completion
  -> StageDirector latches completion and authorizes gate unlock
  -> Arena preloads the next configured Stage Area PackedScene resource only
  -> player exits the current area to the right
  -> StageArea reports exit reached
  -> StageDirector enters TRANSITIONING
  -> Arena locks Player input and releases active combat safely
  -> Arena clears every root-owned SpellProjectile and other transient combat object
  -> Arena instantiates the next area as PREPARED
  -> Arena aligns the next EntryAnchor to the current world ExitAnchor
  -> Camera2D pans to the next area anchor
  -> Player is repositioned to the next area spawn
  -> Player facade resets all combat state except active school
  -> Arena reports pan finished
  -> StageDirector creates the next configured evaluator
  -> Arena connects the next area Entity outcomes
  -> Arena promotes the next area to ACTIVE
  -> StageDirector publishes the next objective
  -> input unlocks and the completed area unloads
```

The Final Arena evaluator retains the existing `final_enemy_defeated` success fact. On success, StageDirector enters `FREE_PRACTICE`, keeps the Final Arena loaded, leaves its permanent practice targets available, and immediately publishes `now you are free` with no progress row. No gate unlock, scene transition, delay, or intermediate completion presentation occurs.

<a id="gym-framing05-environment-candidate--october-20"></a>
<a id="accepted-original-heroes-sfx-replacement-candidate--october-20"></a>
<a id="original-pikeman-audio-implementation--october-20"></a>
<a id="enemy-scene-transform-and-grounding--2026-10-19"></a>
<a id="fire--earth-flipbook-exchange--2026-10-19"></a>
<a id="entity-feedback"></a>
<a id="generic-projectile-impact-and-feedback"></a>
<a id="unified-combat-gym--2026-10-19"></a>
<a id="runtime-pause-menu--2026-10-15"></a>
<a id="gym-contact-time-formula-display--2026-10-16"></a>
<a id="unified-developer-overlay-visibility--2026-10-16"></a>

## Presentation and development tools

### Current asset bindings

Approved Fire dodge art lives under
assets/prototype/player/fire_sword_shield_v01/dodge_v01. The Fire dodge slice above
binds the original12-frame idle-exit sheet through a new native Animation, using
four-column448px cells and nominal foot(224,400). The10-frame running exit and
pre-mirrors remain unused alternatives; padding cells are not frames. Native
region keys, not the legacy horizontal frame helper, select the grid cells. GIF
review delays supply no runtime timing. The manifest/provenance preserve the
initial asset-preparation evidence; later scoped Main-owned rendered observations
and remaining human/controller limits are recorded in Implementation Status.

The existing `air_x5` move/style and Player AnimationLibrary still resolve
`config/attack_animations/air_x5.tres` and the stable `air_x5.png` texture path.
The texture now copies the approved Pack 3 Weapon_Summon sheet byte-for-byte:
1408×128, eleven 128×128 full-body frames. Only Sprite:region_rect frame keys
change in the native Animation. They retain the existing normalized quadratic
spacing convention, t=(frame_index/frame_count)^2, over eleven frames instead of
eight. This is sprite presentation spacing, not a new gameplay timing owner.

Animation length remains 1.0; active_start and pacing-only timing_split remain
0.36; active_end remains 1.0. Every AttackCast geometry key, per-move duration,
Heat scaling, lunge, Impact and all other tuning are unchanged. The import UID,
settings references and Air X1–X4 are retained. No runtime script changes or
engine reimport/run were performed. Static source/hash/frame-bound checks do not
establish playback or visual/gameplay acceptance. The user must check the full
body, all eleven poses and preserved handoff in Godot after normal reimport.

[Air X5 history](history/2026-10-20-air-x5-weapon-summon/README.md) preserves the
retired effect, original native Animation/import descriptor and matching records.

The preceding art-only integration, before the approved collision amendment,
uses the selected generated sword-and-shield sheets under
assets/prototype/player/fire_sword_shield_v01. Only fire_x1..fire_x5 and cast_fire
texture references/region rectangles change; all current native frame-key times,
Animation UIDs, markers, attack geometry and gameplay timing remain. The previous
earth_x1..earth_x5 Fire source textures and the other schools' original bindings
are retained. Earth/Water/Air and attack_clock native resources are unchanged.

Player's existing presentation helpers select Fire-specific Idle6/Walk12/Hurt4
sheets with the existing8fps/10fps/captured-Hurt timing. Legacy shared sheets are
not overwritten. The currently displayed texture selects448px versus128px cells,
offset, filter and material, so switching selected schools during a committed
Fire animation does not reformat its atlas. Legacy textures restore the saved
original offset/material/filter and their school tint. Fire uses its accepted
image colors without the old outline/tint shader. The shader reference remains
cached independently for later school changes. Existing facing/input, movement,
reaction and audio paths retain their owners.

The existing root2/Sprite0.5 scales are retained. Reading the unchanged collision
rectangle's floor at local y26 yields the Fire-only centered offset(0,-124) for
448px cells and foot(224,400), giving world foot y52 and the Gym's screen y610.
No physical dimensions or root motion are changed. Registration belongs to the
runtime presentation profile; standalone editor scrubbing must account for that
offset and must not move hitboxes to fit an unconfigured preview.

All nine selected sheets/52 frames are byte-identical to Art's metadata pointers.
Art's earlier review-candidate flags and X3/X5 continuity/handling limits remain;
the later user handoff authorizes prototype integration, not final art acceptance.
Cast's held-sword gesture adds no mechanic. X2's backward sweep and X1's drawn
extent beyond the unchanged forward query are explicitly retained/reported.
The larger body is not a larger collision body. Wide Walk/Cast atlases, live
grounding, switching, playback and regression behavior require user validation;
no Godot/editor/import/build/tests were run. Exact hashes, limits and manual
checks are in the new asset PROVENANCE.md and Implementation Status.

CombatEnemy separately uses Art's
corrected generated Pikeman v02 atlases under assets/prototype/enemy/pikeman/repaint_v02,
with the native originals preserved in the parent folder. Five right atlases use
four-column 768×512 cells and existing counts Idle7/Walk6/Attack10/Hurt6/Death5.
Sprite2D.flip_h provides one cell-local left mirror; no double-flip texture path
is added. The approximately180px standing body uses unit sprite scale, not root
or physics scaling. Centered offset(0,-192) and BodyVisual position(-11,31) map
the source foot(384,448) to the unchanged capsule bottom(-11,31). Grounding comes
from the actual collider, not the old native-art offset. Only the HP label and
windup-warning visual positions also move, with explicit user approval, above the
helmet/floating-damage lane; their triggers and other feedback data are unchanged.

The melee_swing texture and region rectangles alone change: all authored times,
active markers, ShapeCast geometry and events are retained, with full thrust at
index5 / 0.5s and end1.0s. Existing scripted Idle8fps, Walk9fps, captured-duration
Hurt and Death8fps/terminal hold remain. Existing result-screen freezing is not
changed to force death playback. Player art, AI, movement, SFX, reactions, shared
settings, progression and Gym framing05 are preserved.

The new illustration does not define collision reach. Its right full-thrust
alpha edge projects to local x211 versus the unchanged query edge x96; the
vertical pike lane also differs. No gameplay geometry is retuned. Source/asset
checks are static only, not continuous playback or Godot validation. User checks
remain for both facings, grounding, movement pace, thrust/recovery, interruption,
Hurt/Death/reset, overlays and Retry. Source hashes and limits are in the new
asset provenance. Laema/player and additional art/VFX work remain separate.

### Feedback and audio

FeedbackComponent owns transient owner-local numbers/labels; StatusController
owns persistent effects. Resolver delivery goes to target before instigator;
recipients gate target-only feedback to avoid duplication. Numbers use final
Health loss including zero; DoT has the smaller path. A Cast layer shows its
school/level only for APPLIED negative health_delta. Entry lifetime is captured
from validated UI duration; later edits affect future entries. Labels use the
existing viewport clamp. Current direct/DoT offsets, crowding/drift and pause
asymmetry remain provisional: owner tweens pause, while the Cast-label timer's
pause behavior differs. Layout probes are not gameplay HealthResults.

The retained October22 empowered-cue candidate remains Player-owned on the same
empowered_cast_started event: square half-size6 local, facing-normalized X8 plus
Y-66, lifetime0.45s, original school color/z4/audio call. It is not a new launch,
damage or gameplay cue and does not alter projectile origin. Main's actual
1280x720 both-facing images support on-Player placement; human presentation
acceptance and audio remain unverified. FeedbackComponent's Cast-label offset
stays(-48,-118); the proposed shared-offset move was cancelled before editing.

Player owns the visible charged-count note FIFO, not a gameplay clock. Each
crossed upward visible-count boundary enqueues one ordered note; unchanged or
falling counts enqueue none. Cancel/death/reset/teardown clear stale notes. The
accepted PICKUP03 excerpt uses eight fixed ratios; Cast/empowered/pickup tails
duck during notes and restore captured gains. Actor event-bound SFX players
retain cue/cancellation ownership. Original-Heroes runtime sources/hashes and
unassigned projectile flight/impact are in assets/prototype/audio/ORIGINAL_HEROES_SFX.md (local candidate provenance)
and the docs/audio/2026-10-20-original-heroes-sfx-audit.md (local candidate audit). Pikeman attack,
movement, hurt and death retain their actor lifecycle. Ambient/SFX/BGM controls
use existing buses. Game recordings are not CC0; preservation establishes no
redistribution permission. The daytime saved SFX candidate is audio.sfx.volume_db
-6.0 in config/prototype_combat.json; Arena's existing runtime consumer applies
that value to SFX, overriding the bus-layout default. Clips, pitches, event
ownership, ducking and Ambient/BGM settings are unchanged. Main has captured
current full-Master playback; audition/comfort and exact hardware output remain
unverified, not silently accepted from recorded RMS or encoder clipping counts.

The support-only overnight_fire_playtest.gd recorder63409fd5 accepts optional
capture_audio_seconds in0..30, default0. Requested capture appends its own
pass-through AudioEffectCapture to Master with a2s ring, writes at most2048 stereo
PCM16 frames per tick at actual mix rate, then removes only its own effect by
identity. Deadline/sample caps are independent of gameplay; old commands/input
and PNG-worker separation are retained. WAV/header, timestamps, discard/clipping
and continuity/duration flags are observational evidence, not SFX isolation or
human acceptance. Rate changes/failures/lost samples are reported, not resampled
or hidden. Main's12s recordings and separate early-quit prefix are scoped support
evidence in Implementation Status; no new game-audio architecture was introduced.

### Gym and framing05 candidate

Gym inherits reusable characters, native Animations and persistence. It adds room,
result/retry and formula presentation, with no private pacing multiplier, school
lock, Endurance override or save refusal. F6/editor Run gym opens it; saved F5
currently targets Gym, while PrototypeArena remains available via F6. Retry reloads saved actors/data/positions; one-shot
metadata preserves overlay visibility only. Victory or Player death stops the
encounter. Formula cards retain actual receiver values and signed reciprocal
clash diagnostics, observing rather than driving the resolver.

GymArea alone now references Art's matching v02 background/ground pair. Its floor
shape/position, boundaries, actor spawns and camera X bounds remain unchanged.
The background origin is (-640, -558), ground origin (-640, 52), and the existing
CameraAnchor is (0, -198). Arena's existing camera owner consumes that anchor on
startup and every follow update; no camera controller or tutorial-wide change is
introduced. At the configured 1280 × 720 baseline and zoom 1, floor world y52
projects to screen y610 and the plate covers the viewport exactly.

Only gym.tscn opts into PrototypeHUD.compact_bottom_panels (default false).
PrototypeHUD retains its data bindings and onready control references, groups
the orb title and Spell Level label into one header, and places compact Heat/orb
panels below the fighting line at y648 with target height 64. The normal tutorial
HUD is unchanged. The orb overflow-flinch rest position is captured after compact
placement. The October22 HUD candidate draws a faint neutral1px radius13 circle
on each existing empty CenterContainer without changing its minimum size. Occupied
LifetimeOrb drawing, gold2px outline, capacities and bars are unchanged.

update_orb_queue now removes each old slot from orb_queue immediately, then queues
its deletion before adding replacements. The shared _clear_children helper stays
unchanged. This prevents position-tween minimum-size enforcement from measuring
old and new parented slots together; it changes no authored dimensions/anchors or
the4px/4px/rest0.12s flinch. Main's fresh1280x720 normal-generation replays support
500px Gym width through overflow, full10/eight-charged, consumption and empty states.
The transient20-child count was source-derived, not a live layout probe.

The original environment integration was static-only. Later actor art/body work
and the bounded rendered HUD evidence have their own records; these do not grant
expanded-aspect, complete regression or human acceptance. No commit/push is implied.

### Editor, overlay and pause

The editor dock shares catalog/renderer, validation, series fill and persistence
with the runtime Portal. Draft edit, review/save and apply are separate. The
session adapter requires one debug game for apply/stage-load/pause and adds no
server. Dirty drafts survive external changes; clean drafts follow valid sources.
Changed stage definitions require restart. Apply preserves Dictionary references,
captured reactions and existing AI reset policy.

Series fill changes selected editable numeric draft paths, respecting bounds/fixed
cells and rejecting stale previews. Reactions have one foldout; legacy reactions
and school-grouped Impact remain separate. Foldout state is presentation-only;
dormant controls do not activate school effects.

Developer Overlay Visible is the one saved preference for HUD telemetry/Gym
formula. F4 changes it through the existing live-save flow, including pause;
retry retains it. Deprecated gym_formula_visible is used only if the canonical
setting is absent and normalized away on save. Gameplay HUD/objectives and
captured calculations keep their own state.

The shared pause CanvasLayer stays responsive while gameplay pauses. Start/Esc,
controller navigation/confirm and restart use Arena's existing path; transitions
guard restart. Pause menu and runtime Portal close one another so one modal owns
pause. Editor pause uses that visible menu. Pause/resume/retry do not save tuning.

<a id="implementation-slices-and-validation-seams"></a>

## Evidence and retained instrumentation

The consolidation pass checked document/source ownership, Settings, native markers/frame
bindings, save paths, stage grammar, result/commitment routes and the Enemy tree.
It performed source/data/diff/link checks only. No Godot/editor, parser, build,
automated tests, playtest, audition or export was run or created. It is technical
document housekeeping, not independent Ultron clearance.

The October22 daytime synchronization itself likewise uses static source/data,
diff and link checks only. Main's actual rendered bound-input comparisons and WAV
captures are separate agent evidence in the daytime ledger, not new runs by this
document task or user-controller acceptance.

[IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) retains candidate scopes and
pending cases. Earlier 1,497-assertion character-settings results and overnight
engine/render reports keep their original source/engine identities; they do not
validate later contact, audio, Air X5, framing05 or editor-tree changes. September
1 Stage 1–6, September 5 targeted collision/miss/feedback, and combined Stage 7
user reports retain their actual limits. Waivers are unverified work, not passes,
and never erase later evidence requirements.

Validation seams remain for contact ordering/terminal closure, spent ignored
contacts, signed clashes/ordinary zero results, interruption/replacement/reset,
mixed Casts, save/reload/native authoring, the post-reaction wait, audio queues,
Air X5 playback and Gym/HUD readability. Physical controller/feel and Web export
remain separate. Vendored Windows/Web GDExtension libraries and an export preset
do not establish a successful export.

| Retained diagnostic | Purpose and boundary |
| --- | --- |
| [impact_probe.gd](../scripts/debug/impact_probe.gd) and existing actor/resolver/reaction callers | Debug-build IMPACT facts in the ordinary engine log; unchanged |
| Existing TRACE paths in Might/Magic/Enemy | Input, action, chain and resource facts under existing gates; no new logging |
| reaction_debug / reaction_evaluated and GymCombatReadout | Captured scalar evaluation by receiver/action, no manufactured formula for rejected attempts and no gameplay authority |
| [overnight_fire_playtest.gd](../tools/tests/overnight_fire_playtest.gd), helper63409fd5 | Existing rendered recorder plus opt-in bounded Master-mix WAV capture; default off, identity-owned cleanup, explicit loss/duration metrics; support only |

No production diagnostic was removed/expanded; the approved support-recorder
extension is listed separately above. Submission readiness or independent
implementation review remains a separately requested Ultron task; this record
selects no new implementation or verification scope.

<a id="retained-overnight-enemy-parameter-package--october20"></a>
<a id="hit-reaction-implementation-candidate--2026-10-14"></a>
<a id="handoff"></a>

## History and handoff

The [pre-consolidation TDD](history/2026-10-20-tdd-housekeeping/README.md) preserves
all earlier wording, alternatives, source IDs, check totals, matrices and waivers.
The [first housekeeping snapshot](history/2026-10-20-document-housekeeping/README.md),
[Air X5 history](history/2026-10-20-air-x5-weapon-summon/README.md), checkpoints,
iteration ledger and dated decisions remain intact. Earlier technical heading IDs
are retained as aliases by current topic, preserving links without duplicate
chronological chapters.

Heat timing, shorter shared reactions, Air X5, the editor's post-reaction wait
and the later art-aligned collision choices are settled as above.
Current source remains a candidate awaiting relevant user validation.
Historical prepublication documentation/collision-task scope:

A documentation-only
commit does not publish the other uncommitted gameplay/audio/environment changes
or their local candidate provenance; source-only references above retain that scope. Document
alignment grants no runtime acceptance, new engine result, clean-tree or submission
claim. The collision amendment includes focused isolated engine/test/capture
evidence documented in Implementation Status; it does not clear other candidates.
Nothing was committed or pushed by the collision task.

The earlier October22 synchronization covered only the five retained overnight deltas and
directly stale current-state text. Rendered evidence stops at07:19 HKT; the five
post-closure existing headless suites completed7212 checks with zero assertion
failures/all exit0, with shutdown warnings retained. Their forced positions/Heat/
seeks and input-path branches are supplementary, not primary play. Human
acceptance remains pending. This update does not clear current-source parry,
physical analog input, audio, high-Heat Enemy protection or the retained waivers,
and is not blanket canonical/source synchronization or submission clearance.

The prepublication daytime update synchronized the bounded C2 source representation above,
not new gameplay decisions. C1's input-based wall handoff was rejected; C2 has
scoped rendered support. X4 timing, projectile size and SFX mix remain provisional.
Physical overlap recovery, deliberate AI spacing, Cast emission/point-blank
visibility, human/controller feel and audio comfort remain unresolved. No product,
helper, asset, runtime/test or Git action was performed by this document update.

Historical first C2 source/report/evidence publication is verified at
05fb22b8/12:03 HKT as recorded above. The receipt/status follow-up is metadata
only, not another gameplay change or Web export. User validation remains pending;
publication establishes no whole-tree/submission, art, numerical or feel clearance.

Current handoff is the C7 X5 timing candidate over retained C4, with Enemy72
restored. Main verified C7 source publication1404d0ab and metadata receipt632efc44;
the [C7 receipt](iterations/2026-10-22-fire-combat-daytime/C7_PUBLICATION.md) records
that publication, not a new product change from these later observations.
Publication status remains Main-owned receipts/source identities; this
sync changes no published-receipt ID or product source. The
[Iteration7 review](iterations/2026-10-22-fire-combat-daytime/ITERATION7_REVIEW.md),
[daytime ledger](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md),
[rejected range trial](iterations/2026-10-22-fire-combat-daytime/ITERATION6_REVIEW.md)
and [Cast presentation review](iterations/2026-10-22-fire-combat-daytime/CAST_PRESENTATION_REVIEW.md)
retain unresolved spacing/safe-end, low-origin/brief-impact/feedback and art issues.
C7 is not new gameplay/architecture, a reason widget, a high-Heat safety pass or
human acceptance; no further rule or visual treatment is selected here.
