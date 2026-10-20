# Technical Design Report — Orb Casting and Tutorial Stage Architecture

Current representation consolidated October 20. [Implementation Status](IMPLEMENTATION_STATUS.md) owns revision-specific evidence and pending validation. This document is not a new implementation audit or submission clearance.

**Resolved decisions — October 20:** the user retained the current shared reaction durations of 0.25/0.55/0.85/1.15/1.45 seconds for Levels 1–5 and confirmed that Cast commitment restarts Heat's timer without requiring launch or impact. Both former documentation conflicts are resolved in the GDD and this report.

The accepted reaction-duration baseline is already stored in
`config/characters/hit_reaction.tres`, referenced by both Player and CombatEnemy
Settings. CharacterReactionSettings supplies those per-level durations through
the existing effective configuration. HitReaction captures the selected duration
at reaction start and uses it for the stagger, body-displacement lifetime and
reaction invincibility. Keep the existing 5/10/15/20/25-pixel distances, range starts,
eligibility, capture lifetime and legacy reaction path. This synchronization
requires no gameplay-code or Resource change and establishes no new runtime result.

[Pre-housekeeping snapshot](history/2026-10-20-document-housekeeping/sources/docs/TECH_ARCHITECTURE.md) preserves the complete prior technical record, including superseded approaches, scoped evidence and waivers. Historical amendment links below are not current instructions.

## Gym framing05 environment candidate — October 20

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
HUD is unchanged. Panel sizing follows queued container layout, and the orb
overflow-flinch rest position is captured after the compact placement. All ten
slots, school/lifetime/charged presentation, both progress bars and objective/
developer information remain. No combat values or update semantics change.

Asset hashes and placement math are static evidence only; actual minimum sizing,
live visual alignment, overflow, retry and expanded-aspect coverage are unverified.
The current live fighters are retained. Art's eventual 180-pixel actor/flipbook
work is separate and is not implemented by this environment slice. No Godot,
editor, runtime, builds or tests were run; no commit/push occurred in this task.

## Accepted original-Heroes SFX replacement candidate — October 20

The preceding removal of 42 non-Heroes SFX is preserved. Twelve selected PCM16
runtime copies now bind Player's existing melee, school-launch, empowered,
failure, generation, and charging events plus Player hurt/guard and base Enemy
response streams. CombatEnemy still overrides its inherited hurt with PIKEWNCE;
all four Pikeman cues are preserved. Scene players remain on SFX, and the existing
AudioServer mute/volume path, Ambient and BGM are unchanged. SpellProjectile and
Arena travel/impact source maps remain empty, preventing duplicate whole-spell
playback. The active mapping/conversion hashes are in
`assets/prototype/audio/heroes3-replacements.json`; source originals and fallback
choices remain in the prepared reference package. Earlier CC0 descriptions are
historical; the selected originals and derived note are not CC0.

Magic's visible marked-prefix snapshots pass through Combat to Player. Player
counts visible charged entries rather than banked capacity, enqueues each newly
reached count (including batched increases), and plays one derived PICKUP03 note
through MarkAudio. Its existing just-intonation ratios remain unchanged, gain is
fixed at 0 dB, and one connected finished callback advances the one-voice FIFO.
Note loading is null-guarded before playback; a load failure releases/clears the
drain. Count decreases, failed Cast, hit reaction, stage lock/death, configure,
stage reset and teardown clear old note presentation. Repeated identical
snapshots enqueue nothing. No gameplay clock or fixed preview-note gap is added.
While notes drain, Player captures CastAudio/EmpoweredCastAudio/OrbAudio gains,
reduces them by 12 dB, and restores those exact gains on completion or clear.
Heat never changes note pitch; import does not loop, normalize, trim or compress.

This replacement has static evidence only and no Godot/runtime/playback validation.
The independent active-window melee candidate and its validation limits are tracked below.

## Original Pikeman audio implementation — October 20

CombatEnemy's reusable scene owns SFX-bus attack, movement and death players,
and overrides its inherited HitReactionAudio stream with PIKEWNCE. The existing
nonzero reaction handler plays that inherited player once. PIKEATTK plays once
at committed thrust animation start in `ai_begin_windup`, including misses;
cancellation stops it. PIKEKILL plays once on entering DEAD, stopping movement,
attack and hurt playback; encounter reset clears its guard. PIKEMOVE repeats
only while APPROACH actually moves horizontally, stopping on other states,
blocked movement, AI stop, reaction, reset/deactivation and teardown. Playback
has no dependency on melee contact markers; the separate active-window
candidate below now coordinates contact without changing these sound bindings. Player/practice-target sound assignments remain.

Four mono 22,050 Hz PCM16 copies preserve the original RIFF `fact` sample counts
and durations; source originals and archive provenance remain under
`docs/art/references/heroes3-original-audio/pikeman/`. Runtime conversion metadata
is in `assets/prototype/audio/enemy/pikeman/manifest.json`. PIKEDFND is reserved.
These are copyrighted game recordings with no established redistribution license,
separate from CC0 assets. This handoff includes no commit/push or live publication.
Metadata/source checks do not establish audition or Godot runtime behavior.

## Active-window melee and Cast launch amendment — October 20

Status: `IMPLEMENTED_AWAITING_USER_VALIDATION` in the uncommitted working tree.
This section supersedes the older single-contact and synthesized-counter source
descriptions below. It does not establish runtime validation or Ultron clearance.

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

## Current representation — character-owned settings, October 20

CombatEnemy presentation now uses the five local Pikeman sheets documented in
`assets/prototype/enemy/pikeman/PROVENANCE.md`. Script-driven idle/walk/hurt/death
regions wrap across four columns of 450 × 400 cells. One Sprite2D scale/offset
preserves the common source feet anchor. Native `melee_swing` sprite tracks use
the front-thrust group at ten evenly spaced frames per second. The user's speed
adjustment adopts the original `CrAnim.txt` Pikeman base duration of 1.0 second:
extended-pose/active-start at 0.5 seconds and active-end at 1.0 second.
The active-window candidate above now samples native geometry throughout the
active interval, preserving these authored timings and geometry values.
The existing AnimationPlayer and BT marker consumers own all timing; no speed
multiplier or second timer is added. Reaction ownership, prior fighter assets,
and the practice-target scene remain intact.

This change builds on published source `8f89498`; the overnight frozen package
and recovery references below describe historical baselines. Current source is
an implementation candidate awaiting the user's gameplay validation.

- Player root `settings` references `config/characters/player.tres`
  (`PlayerCombatSettings`). It owns health/Poise, initial school, movement,
  melee/Cast/Charging/Heat/defence/school data, impacts and the twenty external
  attack-style references. Existing move-style Resources own phase durations,
  lunge and push scale. Native Animations own sprite frames and contact geometry.
- CombatEnemy root `settings` references `config/characters/combat_enemy.tres`
  (`EnemyCombatSettings`). It owns health, decision parameters, attack Impact
  and Endurance. The reusable root also owns its non-refilling combat role and encounter ID;
  room instances specify only placement. It exposes no windup/recovery override. Native `melee_swing`
  markers/length retain attack timing at speed 1.
- Both reference `config/characters/hit_reaction.tres`
  (`CharacterReactionSettings`). One shared table owns reaction bands, duration
  and distance. There is no new timer owner.
- `CharacterSettingsStore` reads the resources actually assigned on those two
  reusable scene roots, refreshes external data leaves, and adapts them to the
  retained runtime Dictionary shape. Canonical JSON now contains only audio,
  tutorial flow and UI preferences. Character keys are removed on save; legacy
  full JSON snapshots at other paths remain readable for compatibility/tests.
- `DeveloperConfigStore` merges changed leaves against fresh character/native
  assets, rejects conflicting Inspector edits and saves to the same assigned
  resources. Source hashes include character scenes, Settings, reaction, styles
  and native geometry. Startup is read-only. The legacy CombatTuning Inspector
  mirror lives under Player and is a synchronized view, never a source/profile.
  Both Portals use the same save/apply path in Gym and PrototypeArena.

HealthResolver still decides eligibility/damage and cancels interrupted actions
immediately. An Enemy request captures level/direction/duration/distance, then
its behavior-tree reaction task consumes the request and invokes HitReaction.
Requests during a tree tick wait until the abandoned task unwinds; pending
requests already protect against duplicate contacts. There is no recursive tick
of an active task. An off/offensive-disabled Enemy still executes an incoming
reaction. Mixed layers defer one strongest request until transaction completion;
death/reset/area retirement clear pending state. Portal edits affect the next
request and cannot change an already captured reaction.

Player death locks combat/movement in the reusable actor and reset unlocks it.
Gym retains its result/retry/formula UI only; its private tuning, Fire lock,
pacing multiplier, Endurance override and save refusal are removed. Practice
actors retain their non-attacking/refilling semantics.

Settings saves span several native resources and preferences; failure reports
identify partial writes. This does not claim a multi-file atomic transaction.

Status: `IMPLEMENTED_AWAITING_USER_VALIDATION`

Repository basis at this contact-slice synchronization: HEAD `3d0542c49552caaacc001fc871a213964848dbc9` plus the dirty working-copy implementation and approved `docs/GAME_DESIGN.md`. This is a local source snapshot, not a clean-tree, remote-publication or runtime-validation claim. The exact contact-slice file inventory is in IMPLEMENTATION_STATUS.md; parallel changes are preserved. Commit `23fa85b` preserves the historical U-001–U-007 corrections; `6b06dc2` remains the historical Stage 1–6 sequence-objective recovery checkpoint.

The approved 2026-10-12 LimboAI conversion is a candidate introduced against `23ccc29b6436776a729d071cf4a73038af5b52e6` and captured by `docs/checkpoints/2026-10-12-game-feel-limboai/manifest.json`. It replaces only the Final Enemy decision/timer loop with a visible behavior tree. Source and dependency checks do not establish Godot execution or Web export success; prior tuning validation and waivers do not cover this conversion.

The user reported complete Stage1–6 flow in Godot on2026-09-01 without a precise
scenario/tree/engine matrix. That historical checkpoint had no agent-run engine
evidence. Later scoped overnight engine/render evidence below does not validate
every historical feature, waive submission gates or establish human acceptance.

## Retained overnight Enemy parameter package — October20

Historical comparison, superseded by character-owned settings and the Pikeman timing update. The exact E package, old Gym/tutorial differences and review limits remain in the [snapshot](history/2026-10-20-document-housekeeping/sources/docs/TECH_ARCHITECTURE.md#retained-overnight-enemy-parameter-package--october20) and overnight ledger.

## Authored Enemy animation timing — 2026-10-19

The current CombatEnemy plays a private `melee_swing` at native speed 1. Its
Pikeman clip has ten evenly spaced frames, active_start/timing_split at 0.5 and
active_end/length at 1.0 second. BT tasks wait on actor animation progress;
AnimationPlayer owns timing, with no separate windup/recovery timers or room
multipliers. Recovery is any authored tail after active_end; currently none.
Contact collection follows the active-window contract above.

The independent `_ai_config` snapshot lets first changes to decision settings
invoke the existing reset/cancel path. Geometry/reaction-only and ignored legacy
timing edits do not acquire a new reset policy. Earlier 0.8/1.0 and 1.1/1.3
packages, scalar timing and single-query algorithms are preserved in the history
snapshot and overnight ledger. Legacy profile timing fields remain readable for
compatibility but do not rescale native Enemy playback.

## Enemy scene transform and grounding — 2026-10-19

The reusable Enemy now uses the Pikeman sheets and common feet anchor described
in Current representation above and its asset provenance. Scene-authored sprite
and collision transforms remain the source for placement. Earlier fighter-body
alignment calculations are [historical](history/2026-10-20-document-housekeeping/sources/docs/TECH_ARCHITECTURE.md#enemy-scene-transform-and-grounding--2026-10-19), not dimensions to reapply to the Pikeman. See ATTACK_STYLES.md for current authoring guidance.

## Native Cast completion guard correction — 2026-10-19

Retained overnight Fire anticipation candidate: the exact reviewed
`cast_fire.tres` uses active_start/launch 0.24 and active_end/length 1.0 in the
accepted marker naming; current source still calls this launch point `contact`.
Sprite times are mapped piecewise around old/new contact: t≤0.36 becomes
t×0.24/0.36; later t becomes 0.24+(t−0.36)×0.76/0.64. Contact geometry key times
move to 0.24 with values unchanged. The renamed native launch marker drives the same
once-only Magic payload/audio/projectile path; total duration, Heat scaling,
normalized input windows, queue ownership and completion handoff are unchanged.
Other native clips and JSON/mirror data are unchanged. Supervisor-rendered A/B
review retained the data provisionally; morning human acceptance remains open.
Round-5 source validation and the spacing-policy damage tradeoff are recorded
in the overnight ledger. This scoped candidate note does not validate the whole
technical document or settle final tuning.

Overnight U-001 diagnostic candidate: `Might.get_normalized_attack_progress`
checks its existing `_current_action` ownership before querying AnimationPlayer's
native timing. With no current action, progress is zero. An owned paused action
still exposes its saved ratio, so this does not gate the query solely on
`is_playing` or `current_animation`: native 4.7.1 empties `current_animation` for
paused and completed playback as well as stopped playback. Existing action
completion/clearing and queued handoff remain unchanged. A/B input reports match
all eight baseline scenarios and frame timings; six focused lifecycle checks
cover unconfigured, idle, active, paused, completed and interrupted/rejected-X
queries. This is a scoped candidate update, not whole-document synchronization
or human gameplay acceptance; see the overnight iteration ledger.

Might validates animation_finished against AnimationPlayer.assigned_animation,
which retains the actual clip name after playback ends. The legacy
moves.cast.animation value remains `attack_clock` for compatibility but does not
identify a played `cast_<primary_school>` clip. Matching that legacy name left
completed Casts and queued melee stuck; later releases hit the pending-action
rejection without consuming charged orbs. This guard correction restores the
existing action-completion/handoff paths without changing Cast/chain rules.

## Fire / Earth flipbook exchange — 2026-10-19

User approved an artwork-only exchange between Fire and Earth X1–X5 to use the
sword set in the Fire-only benchmark. Each pair of native Animation assets swaps
its texture reference and Sprite:region_rect frame track, including key times.
Animation identities and all AttackCast tracks, contact/active markers and clock
lengths remain intact. JSON/settings assets and runtime code do not change, so
school-specific damage, Impact, timing, lunge and hitbox geometry remain attached
to their move IDs. PNG filenames are preserved; resource references express the
new assignment. Casts, other schools, locomotion and Enemy remain unchanged.

## Native attack animation and hitbox authoring — 2026-10-19

Fire X2/X3 retain the provisional local-X40 coverage adjustment. Exact comparison
reports and its earlier single-query baseline are [historical](history/2026-10-20-document-housekeeping/sources/docs/TECH_ARCHITECTURE.md#native-attack-animation-and-hitbox-authoring--2026-10-19); current contact uses active-window sampling.

Status: implemented candidate; interactive editor acceptance remains pending.
This supersedes the earlier JSON-geometry authority and marker-only animation
representation below. User decision: existing Godot animation tooling must
provide scrubbing and visual hitbox editing from the move-settings resource.

Player's embedded AnimationLibrary references native external Animation assets
under `config/attack_animations/`: 20 X clips, four school-paced Cast clips and
the retained `attack_clock` compatibility clock. Enemy references `melee_swing`.
Each clip has discrete texture/region tracks and value tracks for AttackCast
position, target_position and shape:radius. MoveStyleTuning's Animation property
references the very same X asset. The existing editor plugin adds a navigation
button that opens Player, assigns the requested clip and selects AnimationPlayer;
it implements no timeline or preview renderer. Native editor seeking drives the
sprite and query geometry without running actor scripts.

Current active-window implementation: AttackGeometry samples the three geometry
tracks throughout the active interval using native value-track interpolation;
Portal size readback is anchored at active_start. Canonical configuration loading overlays those
saved reach/radius values onto the runtime readback. Character/style Resources
own timing, lunge, Impact and other combat tuning; native tracks own full geometry and sprite frame pacing.
The previous school visual-motion exponents remain hidden compatibility data;
their original defaults are baked into sprite-frame key times, including Casts.
Enemy AI attack_range remains only the approach/windup initiation distance;
separate hitbox_reach/hitbox_radius read and edit its active_start keys.

At configuration, actors reload saved Animation data without reloading Script
dependencies and create private AnimationLibrary/Animation copies. Portal preview
resizes only active_start size keys in those copies. Might and CombatEnemy capture
private geometry curves on action start and mirror sampled local position/target
coordinates with committed facing. Each query restores the live node's canonical
animation-space values afterward. Enemy geometry now follows its current body
transform rather than retaining a frozen windup-time world origin. Debug drawing
uses the same animated samples. Later Portal tuning affects the next action's
captured curve. Shape resources remain local to each scene instance. Damage,
reaction, Heat, body motion and cancellation retain their owners; contact queries
repeat through the active window but each target allowance is spent only once.

Store loads current native geometry before merging drafts. Conflicting stale
active-start-size changes are rejected. Shared saves validate positive radii before
writing, persist the assigned character/style Resources and preferences, update
only changed native active_start size keys, then synchronize the Inspector view. Target resizing preserves its direction, origin and all other
keys. These multi-file writes are not atomic: failure messages identify partial completion. Native edits should be saved before Portal
drafting; unsaved editor changes cannot be inferred from disk. Portal/bridge
watch character/native-animation sources and preferences. Startup and reload remain read-only.
Custom JSON fixture/profile paths keep their legacy geometry normalization.

The historical Gym-only save guards/private settings graph are superseded by
the character-owned representation above. Runtime geometry edits change actor-owned
Animation copies; retry reloads saved data. The existing
editor Portal's Attack styles category is now registered in navigation. See
`docs/ATTACK_STYLES.md` for current active-window keying/saving instructions.

## External move-style assets — 2026-10-19

Move-style Resources link to the same native Animation assets used by Player.
Character Settings reference those twenty styles; native tracks own geometry.
The earlier navigation-only/JSON authority stage is preserved in the
[technical history](history/2026-10-20-document-housekeeping/sources/docs/TECH_ARCHITECTURE.md#external-move-style-assets--2026-10-19).

## Fire and Cast reaction progression — 2026-10-19

Player Settings hold Fire X1–X5 Impacts 10/20/30/40/50 and Cast Level 1–4
overrides 10/20/30/40. The optional level table accepts Levels 1–8 and values
0–100; omitted levels use the base Cast Impact. Both Portals preserve that table
when saving unrelated tuning. Earlier JSON representations remain compatible
historical profiles rather than the shared-character source of truth.

MagicComponent reads each resolved layer's Spell Level at projectile impact and
puts the selected Impact into the existing HealthEvent. HealthResolver retains
the receiver-side formula, attack cancellation, level selection and mixed-layer
transaction. No reaction level is forced by action position. Against current Gym
Poise 10 outside active frames, Fire X1–X5 give values 0/10/20/30/40; under the
October 20 Player zero advantage these select Levels 1/1/2/3/4. Cast Levels 1–4
follow the same corresponding values. Active-move resistance remains unchanged.

CombatEnemy's hurt animation again starts only through HitReaction's reaction
signal and ends through its existing completion signal. The visual-only direct
damage hook is removed. Body movement, invincibility, AI preemption, reaction
timing/distance and existing diagnostic probes keep their current owners.
Interactive visual acceptance and GDD verification remain with the user.

## School attack styles — 2026-10-16

The implemented school-style slice uses the current 20 prototype animations and the existing global five-position X/Cast chain. AttackStyle captures per-X timing/spacing data. Its MightComponent clock now splits around the optional pacing-only timing_split marker (active_start when absent) into the existing windup/recovery durations, each scaled once by Heat. All authored split times are preserved; contact queries use the entire active interval independently. Casting keeps uniform shared-duration playback and uses the renamed launch marker for emission. Input windows remain normalized, pending actions start on animation completion, and action IDs prevent leftover frame time from advancing a newly queued action.

MovementController remains the sole Player body mover. Before Might’s later-priority physics query it consumes predicted phase-overlap lunge displacement, including steps spanning the timing split/end. Lunge distance is consumed even when collision blocks it; cancellation/reset leaves no deferred burst. Per-move reach/radius feed the existing ShapeCast and debug geometry. The style is captured on action start, so Portal changes do not change an in-progress lunge.

HealthEvent.push_scale defaults to 1 and is propagated through actual direct melee contacts, the winning actual clash contact and deferred reaction transactions. It scales only the selected qualifying reaction’s distance. Formula, band selection, damage, invincibility and duration remain with their existing owners. Legacy practice/defence/failed-Cast reactions are unaffected.

MoveStyleTuning provides 20 Inspector entries beside the existing Impact entries. Character Settings and the shared Store persist the assigned style Resources; Combat / Attack styles uses the shared field catalog/renderer in both Portal surfaces. Legacy missing X style fields normalize to inherited timing/geometry and zero lunge without startup writes. Cast/Enemy lunge overrides remain invalid. Reaction Resource properties are serialized after their script attachment so stored range starts load correctly.

Validation evidence for this slice is recorded in IMPLEMENTATION_STATUS.md. Interactive editor/controller feel remains awaiting the user; prior validation and waivers do not prove these presets.

## Hit-reaction implementation candidate — 2026-10-14

The current contact/clash and character-owned reaction contracts are defined
above. HitReaction owns captured duration, invincibility and collision-body
displacement; the existing movement owners consume it, and the Enemy tree
executes/waits for captured reaction requests. Failed Cast remains vulnerable;
stationary practice targets retain legacy recoil/refill. Mixed Cast layers resolve
before one strongest reaction begins, without refunding committed resources.

The [October 14 representation and validation checklist](history/2026-10-20-document-housekeeping/sources/docs/TECH_ARCHITECTURE.md#hit-reaction-implementation-candidate--2026-10-14)
are historical. Its single-query/frozen-origin/JSON-ownership descriptions and
unimplemented-lunge labels are superseded. Reaction-duration authority remains
explicitly unresolved; no value is changed by this consolidation.

## Scope and selected decisions

This report preserves the implemented side-scrolling Orb Casting combat baseline and records the reusable tutorial-stage framework through the combined Stage 7, ordered transitions into the existing Final Arena, the tutorial-only Elemental Endurance demonstration, and in-place free-practice completion state.

The Material Decision Ledger is closed:

1. **Direct generic Cast path.** `MagicComponent` resolves generic direct damage for the primary and optional secondary layers. Active prototype Casting does not read a spell loadout or dispatch school-specialty resolvers.
2. **Shared Entity feedback.** A reusable `FeedbackComponent` belongs to the base `Entity` contract. Target-side `HealthResult` handling displays final direct-hit damage, including `0` for a fully resisted Cast layer; it displays the school-and-level label only for a direct Cast layer whose final loss is negative. Applied DoT ticks use the same final `health_delta` with a smaller number and no Cast-level label.
3. **Stages 1–7 preserve the committed combat schema.** The current continuous Heat and generic-Cast schema remains authoritative. Legacy Fire/Water/Air/Earth effect fields and their Developer Portal controls remain dormant but intact; their previously accepted strict removal is deferred to a separate future cleanup slice.
4. **Dedicated commitment-to-Heat interface.** After successful orb consumption and immutable payload storage, Magic emits one internal commitment fact carrying `commit_id` and `consumed_count`. Combat receives it synchronously and grants Heat exactly once. Promotion, launch, interruption, discard, and impact do not emit this fact.
5. **Last-in primary and single-secondary ordering.** The final consumed orb selects the primary school, whose level equals total consumed orbs. The highest-count remaining school becomes the optional secondary; a secondary tie selects the school appearing latest in the consumed sequence. Impact and feedback resolve primary first, then secondary.
6. **Pressure state owns chain preservation.** Magic reports CHARGING and the 5–95% intermediate band as chain-preserving states independently of queue contents, charged count, and partial progress. CHARGING banks capacity while the queue is empty; the intermediate band waits 0.3 seconds before DEPLETING begins, resets that timer on return to CHARGING, and remains preserving at zero progress until L2 leaves the band. Might consumes this state for timeout and between-action movement decisions.
7. **Shared configured feedback lifetime.** Both Entity scenes configure their `FeedbackComponent` from `ui.cast_feedback_duration`, default `2.0` seconds and validated from `0.1` through `20.0`. Developer Portal live tuning affects future entries only; each visible entry retains the duration captured when it was created.
8. **Initial RELEASE is side-effect-free.** The first raw-pressure sample always establishes Magic's initial pressure state. If that state is RELEASE, initialization emits no Cast request or failure. Only a later transition from CHARGING or the 5–95% intermediate band into RELEASE dispatches one Cast attempt; initial CHARGING begins charging generated orbs and an initial intermediate-band sample begins its no-drain timer.
9. **Persistent tutorial root and reusable Stage Areas.** Player, HUD, audio, StageDirector, and an Arena-owned camera persist. Physical stage content is supplied by independently instantiated Stage Area scenes.
10. **Declarative objectives and generic rows.** StageDirector owns lifecycle, merges evaluator-owned row state with descriptor-owned presentation rows, and delegates Stage 1–6 attempt state to `SequenceObjectiveEvaluator`. Combined Stage 7 uses the Heat-gated sequence evaluator with independent Heat and chain rows. HUD never interprets combat outcomes.
11. **Scene-plus-JSON stage definitions.** Stage Area `.tscn` scenes own physical content; the validated prototype JSON owns ordered descriptors, objective type, UI content, and evaluator parameters.
12. **Player transition facade.** Arena locks input and requests one ordered combat reset through Player rather than reaching into Player components. Active school is preserved.
13. **Current-plus-next Stage Area lifetime.** Only the active and next areas coexist during a transition. Completed non-final areas unload after the next stage activates; the final arena remains indefinitely.
14. **Reusable ObjectiveWidget.** A HUD-owned UI component renders any number of descriptor rows, each with label, optional tokens, progress/highlight, and completed/default state, plus whole-widget invalidation and completion presentation.
15. **Node-based evaluator lifetime.** StageDirector creates one Node evaluator per active stage. It consumes immutable outcomes, may advance with time, and is discarded on stage change.
16. **Normalized chain termination.** Might publishes one immutable `chain_terminated` outcome exactly once whenever an active InputCombo ends, carrying its termination reason. Sequence evaluators consume this fact rather than reconstructing chain lifetime from specialized outcomes.
17. **Prepared-stage isolation.** Completion preloads only the next PackedScene resource. Arena instantiates its nodes after exit/input lock in a PREPARED state with combat and outcomes dormant, clears root-owned projectiles, and promotes the area to ACTIVE only after the pan and objective evaluator are ready.
18. **Anchor-aligned Stage Area placement.** Arena owns Stage Area world transforms and aligns the next area's local EntryAnchor to the current area's world-space ExitAnchor. Each area supplies its own spawn, camera target, and horizontal camera bounds.
19. **Configured transition duration.** Arena captures `tutorial.transition_duration` when a pan begins. The default is `1.0` second, valid from `0.1` through `5.0`; live tuning affects future transitions only.
20. **Normalized Cast-attempt evidence.** Might assigns one `attempt_id` to each Cast attempt. Accepted actions and their later launched/failed/discarded terminal facts carry that ID, so objectives advance only on the correct terminal result rather than on input acceptance or projectile impact.
21. **Shared training-area content.** Stages 1–7 instantiate independent copies of one shared training-area scene. Each instance owns its dummy, floor, anchors, gate, trigger, and lifecycle while stage-specific rules remain entirely data/evaluator-owned.
22. **Descriptor-owned selector naming.** Every stage descriptor owns a non-empty `display_name`; Developer Portal options use that field rather than a presentation-row label.
23. **Generating/Charging terminology boundary.** Player-facing design and HUD use Generating/generated orbs and Charging/charged orbs. The runtime pressure state and persisted threshold remain `CHARGING`/`trigger_charge_min`; private identifiers using `marked` remain compatibility details only.
24. **Retained, disabled tutorial-only Elemental Endurance.** Current character settings disable it. When enabled, Final Enemy `StatusController` owns the active school, capped hit count, action cache, and current multiplier. `MightComponent` supplies one `source_action_id` per X/Cast action and forwards it through committed Cast payloads. `HealthResolver` obtains the multiplier before applying Health, emits the full-resist tag when a direct action reaches zero, suppresses new effects at zero, and returns the actual `health_delta` for presentation. DoT reads the current multiplier without changing the streak.
25. **First active Final Enemy and optional Player Health floor.** The shared baseline disables the floor and supports Player death locking; Gym provides retry. `CombatEnemy` owns the one-pattern AI and final-Enemy-only solid collision. `HealthComponent` owns the optional minimum Health invariant; Player applies the validated, Developer-Portal-backed `player.one_hp_floor_enabled` flag. Changing the flag affects future damage only and never heals.
26. **Eight-level Charging through the existing Magic owner.** `MagicComponent` retains the ten-orb FIFO queue and config-driven charged prefix. The implemented invariant is `casting.max_marked_capacity = 8`, replacing the historical five without changing storage order, expiration, depletion, failure, or consumption ownership. The current five-position X/Cast chain remains independent.
27. **Spell Level remains derived presentation.** The existing `queue_changed(snapshot, marked_count, marking_progress)` path carries both the per-orb charged flags and private banked-capacity progress; its `marked_count` argument represents banked capacity and is not always the number of stored orbs actually charged. `PrototypeHUD` counts charged snapshot flags for Spell Level `0..8`, keeping all ten storage slots visible. The smooth bar adds normalized partial progress to that charged count, caps the result at available orbs (maximum eight), then divides by eight. Banked capacity beyond available orbs is not displayed. No duplicate Spell-Level state or new event is introduced.
28. **One-octave charged-orb cue with ordered boundary delivery.** Player retains local ownership of the fixed-volume charged-orb cue. Its discrete pitch table expands to the eight-step major scale `Do–Re–Mi–Fa–Sol–La–Ti–Do`, represented by pitch ratios `1`, `9/8`, `5/4`, `4/3`, `3/2`, `5/3`, `15/8`, and `2`. On each queue snapshot, Player compares the previous and current visible charged-orb counts. Every crossed upward boundary is appended once, in ascending order, to a Player-owned presentation FIFO; the FIFO plays those cues without overwriting an earlier queued note and never blocks gameplay. Unchanged or decreasing counts enqueue nothing, charge transfer that preserves the visible count produces no cue, and Player teardown or stage combat reset clears pending presentation cues. This preserves one note per newly charged visible orb even when a single update crosses multiple Charging boundaries, without changing Magic's timing or adding gameplay state.

Excluded from this implementation slice: distinct school-level spell behavior for Levels 6–8, additional Enemy attacks or behaviors, legacy school-effect configuration/Portal cleanup, defence redesign, Air/Earth defence, broader defeat/restart design beyond current death locking and Gym retry, final presentation, asset remapping, save/resume persistence, and final numerical tuning.

## Implemented codebase map and postflight basis

```text
PrototypeArena                              persistent root
├── Arena-owned Camera2D
├── Player / CombatComponent
│   ├── MightComponent
│   ├── MagicComponent
│   ├── HeatComponent
│   └── DefenceController
├── StageDirector / active evaluator
├── StageAreas
│   ├── active StageArea
│   └── next StageArea during transition
├── PrototypeHUD / ObjectiveWidget / Developer Portal
└── audio and projectile orchestration
```

Static inspection of the current working candidate confirms the combat baseline, Stage 1–7 tutorial descriptors, active Final Enemy candidate, and Elemental Endurance path are implemented:

- `prototype_arena.tscn` is the persistent root; Stages 1–7 instantiate independent copies of `training_area.tscn`, while `final_arena.tscn` owns the final combat area.
- Arena owns the active `Camera2D`, Stage Area placement, transition pan, current-plus-next lifetime, projectile cleanup, and activation ordering.
- `StageDirector` owns the stage lifecycle and delegates Stage 1–6 sequence logic plus the combined Stage 7 Heat-gated sequence to configured evaluators; the Final Arena retains its final-enemy evaluator.
- `prototype_combat.json` contains validated ordered descriptors for Stages 1–7 plus the Final Arena, descriptor-owned display names, generic presentation rows, and a Portal-persisted default-stage selector.
- `PrototypeHUD` instantiates the reusable `ObjectiveWidget` for progress, invalidation, completion, and free-practice presentation.
- Player exposes the stage input-lock and ordered combat-reset boundary while preserving the selected school.

The current HUD uses generated-orb and charging/charged presentation terminology. Private `marked` fields remain internal compatibility data; no terminology-only implementation delta remains.

Might publishes normalized light-contact, action, Cast-attempt, school-switch, and chain-termination facts while preserving specialized outcomes where useful. The sequence evaluator consumes only immutable outcomes and stage data; `orb_without_contact` is never a physical hit. No second tutorial event bus exists.

The accepted U-001–U-007 postflight corrections are committed in the recovery baseline. The user reported the complete Stage 1–6 flow confirmed; a fresh postflight is still required before submission.

## Implemented ownership

### Might, Magic, Heat, and Combat

`MightComponent` continues to own action eligibility, X/Cast timing, the one-slot earliest-request buffer, chain progression, animation/contact/launch phases, and action-caused movement locks. It decides whether a release-Cast request is normal, empowered, buffered, an endpoint Cast, or a timing failure. After an action and when evaluating timeout, Might reads Magic's pressure-state preservation contract rather than deriving preservation from queue or meter values. Because Might orders every InputCombo exit, it also publishes one `chain_terminated` outcome exactly once per active-chain termination, including a reason for timeout, completion, failed Cast, or interruption.

`MagicComponent` owns the ten-orb FIFO queue, front-orb lifetime, config-driven charging capacity, pressure state, CHARGING and DEPLETING progression, Cast composition, immediate consumption, and immutable committed payloads. The approved target capacity is eight; the assigned Player Settings and exact loader guard use eight. Its first raw-pressure sample establishes the initial state before transition behavior is allowed. Initial RELEASE is side-effect-free; initial CHARGING or DEPLETING may begin ordinary state behavior. Its current pressure state is the sole preservation authority: CHARGING and DEPLETING preserve the chain; RELEASE does not. This state remains authoritative even when the queue, charged count, and partial progress are all zero. Only after a successful commitment has consumed its charged prefix and stored its payload does Magic emit a dedicated internal commitment fact containing `commit_id` and `consumed_count`. Failed commitment attempts emit nothing.

`HeatComponent` remains the sole owner of the `0..100` Heat value, the `100%..150%` multiplier, loss, Water-block drain, the five-second reset timer, and subsequent three-per-second depletion. `CombatComponent` subscribes to Magic's dedicated commitment fact during configuration and synchronously routes `consumed_count` to Heat once. Might reads the resulting multiplier for X/Cast animation timing; Magic reads it only for CHARGING speed.

`CombatComponent` remains a thin facade. It forwards Player/HUD/Arena-facing signals and orders cross-component transactions without duplicating Might, Magic, Heat, queue, or feedback state. Generic public `CombatOutcome` events remain observational and never drive the authoritative Heat mutation.

### Entity feedback

Retained overnight H changes exactly two existing FeedbackComponent offsets:
directY−238→−186 and DoTY−206→−154 (X−10/−8); Cast-level Y−118 stays fixed.
Existing owner parenting and world-intended clamp path, font/color/outline,
bound tweens/displacement/easing/duration and timer APIs remain unchanged.
Supervisor actual after-draw/image review supports sampled fresh-header and
initial glyph spacing at1280×720; inherited Player scale2, repeated-label
crowding, late drift, unsampled layouts and pause asymmetry remain limits.
Direct/DoT tweens pause with owner; the existing Cast-level timer continues
during tree pause. No stacking/filter/layout framework or gameplay rule changes.
Palette/zero/DoT API probes are labeled layout-only, not fabricated HealthResults.

The base `Entity` script owns a required `FeedbackComponent` reference alongside Health, Status, and HitReaction. The project uses a shared base script rather than a shared inherited Entity scene, so both Player and Enemy scenes compose their own `Feedback` child satisfying that contract.

`FeedbackComponent` owns transient entity-local feedback entries and their expiration. It is separate from `StatusController`: Cast-level text is presentation evidence, not a buff, debuff, or gameplay status. The base Entity configuration injects `ui.cast_feedback_duration` into each Player and Enemy component. Every entry captures that duration at creation, so a live tuning change affects only later entries and never extends or truncates feedback already visible.

`HealthResolver` delivers each `HealthResult` first to the target and then, when distinct, to the instigator. Player and Enemy gate feedback on `result.event.target == self`, preventing duplicate target/instigator numbers. Applied direct damage displays the final negative `health_delta` as a normal-size number, including `0` after direct full resistance. Magic retains `<School> Lv.<N>` only when its direct Cast layer is applied with a negative loss; a fully resisted Cast layer therefore has a `0` number without a school/level label. Applied `DOT_TICK` events display the same final post-modifier loss through the smaller DoT-number path and never create a Cast-level label. FeedbackComponent clamps new transient labels to the viewport at creation; persistent Enemy Health and status readouts remain world-attached above their owner.

### Elemental Endurance

Elemental Endurance is disabled in the current shared character baseline. Its retained optional path is restricted to the Final Enemy role when enabled. `StatusController` owns the enabled flag, active school, capped hit count, cached source-action multiplier, and snapshot values used by the overhead badge. For a direct damage event, `HealthResolver` resolves defence first and calls `StatusController.resolve_elemental_endurance()` only for an `APPLIED` result. The returned multiplier is applied before `HealthComponent.apply_damage()`; the latter remains the source of the final delta, including any Player minimum-Health cap.

`MightComponent` allocates one `source_action_id` for each light action. It supplies that ID and single-school composition to each physical X contact, and writes the same ID into the committed Cast payload that `MagicComponent` forwards to both primary and optional secondary layers. StatusController uses the shared action ID to count one action at most once; a mixed Cast clears the streak instead. At zero multiplier, HealthResolver tags the direct result `elemental_endurance_full_resist`, suppresses new effect instructions, and leaves actual loss at `0`. Might reads that tag to withhold orb generation while Combat still refreshes Heat for the landed direct hit and the normal Impact/hit-reaction path remains available. DoT ticks read the current multiplier for their school but do not advance, reset, or replace the streak.

Enemy builds the active-school Endurance icon and remaining percentage from the StatusController snapshot. It hides the badge at 100%; direct and DoT feedback use the resolved final loss rather than the requested damage.

### First active Final Enemy and Player Health floor

`CombatEnemy` extends Enemy and owns the manually updated `BTPlayer` using
`ai/trees/final_enemy.tres`. LimboAI 1.8.1 remains the vendored GDExtension. The
tree owns awareness/approach, committed windup, active swing, authored recovery
and reaction decisions; the actor owns native playback, geometry, body movement
and action identity. Blackboard data comes from character Settings, not a room
profile. Native animation progress owns phase timing; there are no BT phase timers.

The scene-local common-sample barrier and once-per-target contact rules are
specified in the active-window section above. A qualifying hit or losing clash
cancels the attack; after HitReaction, the Enemy reassesses rather than resuming.
AI disablement, stage retirement, target loss, death and teardown retain their
reset/cancellation boundaries. The active combat Enemy is solid; practice targets
remain non-attacking/refilling/pass-through. Death removes combat collision.

HealthComponent retains the optional minimum bound. The shared Player baseline
sets it to zero; enabling the optional 1-HP floor changes future damage only and
never heals. Player death locks combat/movement, reset unlocks it, and Gym owns
its result/retry UI. Broader defeat design remains separate.

The Web preset includes GDExtension support and vendored Web libraries. No Web
export success is inferred from installation or earlier isolated engine checks.

### Arena and projectile

The persistent tutorial root retains the `PrototypeArena` script's orchestration role: it owns Player, HUD, audio, projectile spawning/impact routing, StageDirector, Stage Area lifetime, and the transition camera. `SpellProjectile` continues to own travel, maximum distance, first-valid-target collision, and blended presentation. It carries the immutable resolved Cast payload rather than reading the live orb queue later.

The payload carries an explicit primary school and level plus one optional secondary school and level. It also retains empowered state, the primary-only damage multiplier, original instigator, direction, and the information needed to derive color weights. The final consumed orb always selects the primary school; primary level equals total consumed orbs and therefore extends through Level 8 under the approved capacity. After excluding the primary, the highest-count remaining school becomes secondary. A secondary-count tie selects the tied school appearing latest in the consumed sequence. Other represented schools create no layer, although their orbs remain consumed and still contribute to primary level and commitment-time Heat. Existing integer payload fields and generic direct-damage resolution require no schema or ownership change for Levels 6–8.

Impact resolution is ordered: primary first, optional secondary second. Feedback presentation uses that same order. This preserves one deterministic sequence across payload construction, HealthEvents, immediate target refill, hit reactions, and Cast-level labels.

### Tutorial root, Stage Areas, and camera

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

### StageDirector and objective evaluators

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

### Player transition facade

Player exposes one stage-transition boundary to Arena. It provides all-gameplay-input lock/unlock and one ordered stage reset. The reset cancels active and buffered actions, clears chain, queue, marks, Heat, statuses, hit-reaction suppression, and defence state, restores full Health, and leaves the active school unchanged. Arena never calls Might, Magic, Heat, Status, Health, or Defence directly.

The reset occurs while input is locked and before the next stage becomes ACTIVE. After Stage 1, the school selected at exit is therefore the school shown when the Final Arena appears.

### ObjectiveWidget

`ObjectiveWidget` is a reusable HUD-owned Control scene. StageDirector supplies immutable presentation snapshots containing generic rows with stable id, label, optional tokens, evaluator-owned progress/highlight/completed state, attempt invalidation, whole-widget completion state, and prompt text. The widget owns only rendering and its light UI-only flinch. It never consumes CombatOutcome or stage nodes.

The widget occupies the upper-right gameplay-UI region. When the developer overlay is visible, its L2 pressure panel is laid out below the objective widget. This preserves both GDD placements without overlap.

## Core flows and contracts

### Stage 1 objective evaluation

Stage 1's evaluator is registered as the five-hit Fire-chain objective. It receives the existing immutable combat outcomes and maintains only `attempt_active` and the number of valid landed Fire X hits.

```text
Stage 1 activation
  -> Fire is selected for initial startup
  -> one refill target is configured
  -> right gate is locked
  -> ObjectiveWidget: "perform a 5 hit combo" / X-X-X-X-X

light_contact_resolved
  -> result hit + Fire:
       if no attempt: begin attempt
       advance one green X
       fifth valid hit: complete permanently
  -> result miss or orb_without_contact:
       if Fire or attempt already active: invalidate/flinch/reset
       otherwise: unchanged
  -> result hit + non-Fire while attempt active:
       invalidate/flinch/reset
  -> result hit + non-Fire before attempt:
       unchanged

action_accepted
  -> Cast while attempt active: invalidate/flinch/reset

school_selected / school_switched / unrelated outcome
  -> unchanged

chain_terminated while attempt active
  -> if objective already completed: ignore
  -> otherwise: invalidate/flinch/reset for every termination reason
```

The objective uses physical `light_contact_resolved` evidence rather than accepted input or orb creation. Completion is latched before the subsequent `chain_terminated` fact can arrive. Once complete, the evaluator ignores later combat and StageDirector unlocks the Stage 1 right gate while publishing the green widget plus `moving on ->`.

### Declarative Stage 1–7 evaluation

Stages 1–6 share one data-driven `SequenceObjectiveEvaluator`. Each descriptor supplies ordered `success_steps`, optional prestart and active invalidation flags, completion progress, a stable sequence-row id, and whether the next expected token is highlighted. The evaluator maintains only PRESTART/ACTIVE/COMPLETED phase, progress, and one pending Cast attempt ID; it exposes the dynamic state for its configured row id.

- **Stage 1:** five landed Fire X steps; a Fire miss invalidates even before progress.
- **Stage 2:** one Cast step requiring level 5. The evaluator waits for the matching Cast-attempt terminal fact; only `launched` at level 5 succeeds. Any non-launched terminal or launched lower-level Cast invalidates. Projectile impact is irrelevant.
- **Stage 3:** five landed X steps followed by a level-5 endpoint Cast launch. Its presentation instructs `Hold L2 + X -> X -> X -> X -> X -> Release L2`; compact token rendering accommodates the longer first and final labels. L2 timing remains guidance and is not evaluated.
- **Stage 4:** `X -> X -> Cast -> X`, with the Cast occupying chain position 3 and the final X occupying position 4.
- **Stage 5:** `X -> Cast -> X -> Cast`, with Casts occupying positions 2 and 4; the second launch completes the objective.
- **Stage 6:** `X -> X -> school switch -> X -> X -> X`; the accepted switch must occur at chain position 2, and rejected or mistimed switches invalidate the active attempt.
- **Stage 7:** the Heat-gated sequence evaluator exposes a Heat row and chain row. Heat at or above 80 marks only the Heat row complete. A chain attempt begins only on landed position-1 X at or above threshold; its five landed X steps advance the chain row. Miss, premature termination, or dropping below threshold during an attempt resets/flinches the chain row, while a pre-attempt Heat drop updates only the Heat row. X5 completes the stage.

Unexpected actions follow each descriptor's phase rules. Prestart `ignore_unexpected` allows the player to prepare freely where approved. Once an attempt is active, a wrong expected step, an applicable rejected switch, or `chain_terminated` invalidates and resets only the objective attempt. Completion remains latched permanently.

### Stage transition and final arena

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

### Queue and L2 pressure

PrototypeArena registers the shared `casting` InputMap action on the left
controller trigger (`JOY_AXIS_TRIGGER_LEFT`, positive axis direction). The unified Gym inherits this registration. CombatComponent and the pressure HUD
read that action's raw strength, so both follow L2. The right-mouse binding,
L1 defence binding and pressure-state thresholds are preserved.

```text
X contacts an Enemy
  -> Magic attempts to append that school orb
  -> queue below 10: append and publish the new snapshot
  -> queue at 10: discard only the new orb and publish overflow feedback

L2 >= 95%
  -> CHARGING advances at the current Heat multiplier
  -> banks charging capacity up to eight even when no generated orb is available
  -> marks the oldest available orbs covered by that capacity
  -> preserves the chain and releases movement between actions

5% <= L2 < 95%
  -> enters a 0.3-second no-drain intermediate hold
  -> returning to CHARGING before the timer expires resets that timer
  -> only a continuous hold beyond 0.3 seconds starts DEPLETING
  -> DEPLETING drains at the fixed baseline charge-step rate
  -> partial progress drains first
  -> completed boundaries return newest charged orbs to generated state first
  -> remains chain-preserving even after progress reaches zero
  -> releases movement between actions

L2 < 5% on state entry
  -> stops pressure-state preservation
  -> one Cast attempt only when this is a later transition
```

Before evaluating these transitions, Magic classifies the first raw-pressure sample and stores it without dispatching RELEASE behavior. This prevents a resting trigger from producing a startup Cast failure. Initial CHARGING activates ordinary charging; an initial intermediate-band sample starts its no-drain timer. After initialization, only a change from CHARGING or the intermediate band into RELEASE dispatches one Cast attempt.

Magic exposes one pressure-preservation result to Might. Might uses it after an animation and for idle-timeout eligibility. Queue size, charged count, and partial progress are presentation/resource values and never substitute for this state result. Active X and Cast animations remain movement-locked; Combat releases movement only between actions while Magic reports CHARGING or DEPLETING.

Only the front queue orb counts down. Consumption or expiration shifts the remaining queue forward and starts the new front orb at its full lifetime. Charging coverage transfers with the shifted queue when enough generated orbs remain.

A failed Cast ends the chain, returns every charged orb to the generated state, and resets partial charging progress to zero without removing queue contents. An incoming direct-damage `HealthResult` qualifies for the resource-loss transaction only when its outcome is `APPLIED`: Magic removes currently charged orbs, preserves generated-orb order, and resets charging progress. `BLOCKED`, `PARRIED`, and DoT results do not enter this transaction. Final reaction strength is not part of the predicate. Orbs already consumed by a committed Cast are never refunded.

Magic publishes enough queue state for the HUD to render all ten slots, current contents, charged state, front lifetime, and charging progress. Overflow reaches the HUD through the existing Combat/Player presentation path and restarts the whole-widget flinch from rest. Current private payload keys may remain `marked` during this candidate; the HUD presents them as charged state.

### Commitment, buffering, and Heat

```text
Might accepts a normal/windowed/buffered release-Cast
  -> Magic consumes the charged FIFO prefix immediately
  -> Magic resolves the last-in primary and optional majority secondary
  -> immutable Cast payload is stored under one commitment
  -> Magic emits one internal commitment fact
  -> Combat grants Heat from its consumed_count immediately
  -> Might launches that payload once at the Cast launch marker
```

A buffered Cast commits before its later promotion. The dedicated fact is emitted during commitment, not promotion, launch, interruption, discard, or impact. Those later transitions therefore cannot duplicate or revoke the Heat gain. If the action is interrupted before launch, its payload is discarded without refund; the Heat already granted at commitment remains. A projectile miss likewise does not revoke Heat.

Heat is stored as an absolute `0..100` value, producing a continuous `1.00..1.50` attack-speed multiplier. Each committed consumed orb grants two Heat, so an eight-orb Cast grants 16 Heat before the existing `0..100` clamp. The same incoming `APPLIED` direct-damage result that triggers charged-orb removal also removes five Heat with a zero-point floor. `BLOCKED`, `PARRIED`, and DoT results remove none, regardless of reaction strength. The October 20 accepted timer contract matches the current HeatComponent: a non-empty `gain_from_commit()` grants Heat and restarts the full configured five-second timer immediately; `refresh_from_landed_direct_hit()` also restarts it for applied outgoing direct X/projectile hits. Buffered commitment refreshes before animation promotion, without requiring launch or impact, and subsequent interruption or miss does not revoke it. DoT and zero-consumption failed attempts do not refresh the timer. After five seconds without a qualifying commitment or landed direct hit, Heat depletes at three per second until zero. Loss and Water-block drain do not create Heat or change its authority. This documentation synchronization requires no gameplay-code or tuning change and adds no runtime-validation evidence.

Direct X hits, projectile impact, feedback, and deferred school effects grant no Heat. There is no independent Air speed buff or Air-specific Heat source in this prototype.

### Generic projectile impact and feedback

```text
SpellProjectile contacts a valid Entity
  -> Combat routes the frozen payload to Magic
  -> resolve the primary, then the optional secondary:
       create one direct-damage HealthEvent
       use combat.casting_damage
       use moves.cast.level_impacts[level], falling back to moves.cast.impact
       apply the empowered multiplier only to the primary layer
       resolve through the target's shared HealthResolver
       if HealthResult is APPLIED and health_delta is negative:
           publish <School> Lv.<N> through target FeedbackComponent
  -> projectile disappears
```

The direct path does not read `spell_loadout`, call a school resolver, or create a status instruction. A mixed Cast intentionally produces one generic damage event and one feedback entry for the primary and optional secondary layers, in that order. A blocked, parried, invalid, zero-damage, interrupted, or missed layer produces no Cast-level display. Existing HealthEvent instigator, school, Impact, contact direction, and contact point attribution remain intact.

## Configuration, persistence, and UI

Character Settings/style/reaction Resources own combat values. `config/prototype_combat.json` owns tutorial, audio and UI preferences through the existing fail-fast pipeline. Both Portals persist these same assigned sources; native Animations own frame/geometry tracks. Legacy full JSON profiles remain compatibility inputs. There is no player-profile migration.

The active Heat schema is:

```yaml
heat:
  max_heat: 100
  gain_per_charged_orb: 2
  loss_per_direct_hit: 5
  reset_timer: 5
  depletion_per_second: 3
```

The active shared feedback-lifetime field is:

```yaml
ui:
  cast_feedback_duration: 2.0
```

`ui.cast_feedback_duration` must be numeric from `0.1` through `20.0` seconds. It follows the same fail-fast save/load path as the existing UI duration. Player and Enemy receive the value during Entity configuration and forward later runtime-tuning changes to their Feedback components. A changed value applies to future entries only; active entries retain their captured expiry.

The tutorial section uses an ordered declarative sequence grammar. Its current shape is:

```yaml
tutorial:
  initial_school: fire
  transition_duration: 1.0
  stages:
    - id: stage_1
      area_scene: res://scenes/stages/training_area.tscn
      objective:
        type: sequence
        label: perform a 5 hit combo
        tokens: [X, X, X, X, X]
        success_steps: [fire X, fire X, fire X, fire X, fire X]
        completion_progress: 5
    - id: stage_2
      area_scene: res://scenes/stages/training_area.tscn
      objective:
        type: sequence
        label: perform a level 5 spell
        tokens: []
        success_steps: [level-5 Cast launch]
        completion_progress: 0
    - id: stage_3 ... stage_7
      area_scene: res://scenes/stages/training_area.tscn
      objective:
        type: sequence
        success_steps: <ordered approved light/Cast/switch steps>
    - id: final_arena
      area_scene: res://scenes/stages/final_arena.tscn
      final: true
      objective:
        type: final_enemy
        label: Defeat the final Enemy.
        encounter_id: final_enemy
      free_practice_presentation:
        rows: [{id: free_practice, label: now you are free}]
```

The loader requires a non-empty ordered stage array, unique non-empty stage IDs and display names, loadable PackedScene paths, exactly one final stage at the end, known evaluator types, generic non-empty presentation rows, and evaluator-specific required fields. Every row has a unique non-empty id, non-empty label, and optional string-token array. Sequence objectives require a non-empty `success_steps` array, valid step types (`light`, `cast`, `switch`), valid optional school/level/endpoint/chain-position fields, phase rule dictionaries, numeric completion progress, and optional highlight behavior. The approved eight-level slice expands the generic `required_level` validation range from `1..5` to `1..8`; existing Stage 2 and Stage 3 descriptors remain Level 5. `initial_school` must be functional. `transition_duration` must be numeric from `0.1` through `5.0` seconds. The obsolete flat tutorial shape and superseded evaluator types are rejected.

The fixed `100%` baseline is behavior, not configuration. The committed continuous-Heat schema remains unchanged; the superseded discrete Heat and independent Air-speed fields remain absent and rejected.

Player Settings retain the timing, pressure, projectile, and ten-orb storage fields. `casting.max_marked_capacity` is the exact invariant `8`, enforced by the loader and Portal; five-capacity legacy data is stale and rejected. `spell_loadout` remains absent. The persisted key `max_marked_capacity` remains a private compatibility detail for this prototype; game-facing terminology is charged capacity. The retained character school data for Fire DoT, Water status-level, Air chain-lightning, Earth area/Slow, and related school effects remain validated and exposed through their existing Portal controls, but generic prototype Casting does not read or dispatch them. Removing those dormant fields and dependent paths is a separate future cleanup slice.

The Developer Portal keeps its General, Audio, and Combat organization. General → UI exposes `cast_feedback_duration` and `tutorial.transition_duration` beside the existing presentation duration. Transition-duration changes persist through the existing JSON path; each pan captures the value at start, so live changes affect future transitions only. Audio presents `0–100%` linear volume controls, converts them to the existing persisted `audio.<group>.volume_db` values, and leaves Arena's AudioServer bus application unchanged; `0%` stores the validated silence floor of `-80 dB`, while `100%` stores `0 dB`. On load, any legacy saved audio value above `0 dB` is normalized to `0 dB` in memory; it is durably rewritten only when the user next saves the configuration. Player owns the fixed-volume MarkAudio playback and selects the discrete Do–Re–Mi–Fa–Sol–La–Ti–Do pitch table from visible charged-orb count. Each character owns its assigned SFX-bus response; the current original-Heroes mappings are recorded in the audio sections above. Existing Combat-tab school controls remain untouched and dormant where their effects are deferred.

The always-visible HUD renders ten generated-orb slots even when empty, a gold outline on charged orbs, the charging-progress bar, the front-orb lifetime, and a Spell Level readout derived by counting charged snapshot entries. Spell Level ranges from `0` through `8`; the smooth bar adds partial charge/depletion to that count, caps the result at the number of available orbs or eight, whichever is smaller, then divides by eight. Three charged orbs with a fourth half charged show 3.5/8 while Spell Level remains 3. An empty queue shows zero; three fully charged available orbs cap the bar at 3/8 regardless of additional banked capacity. Slots nine and ten may remain generated and uncharged. Private snapshot fields and the private `marked_count` capacity argument remain for compatibility and existing diagnostics. The overflow signal drives the whole-widget horizontal flinch. The developer telemetry rail shows live Health, Enemy Health, Heat, speed, defence, school/chain, event confirmations, and raw L2 pressure; its visibility remains Portal-controlled.

## Implementation slices and validation seams

1. **Persistent root and Stage Areas:** Player/HUD/audio/projectile orchestration persists in the root; Arena owns the Camera2D; Stages 1–7 instantiate the shared training-area contract and Final Arena uses its dedicated scene.
2. **Stage configuration and lifecycle:** the flat tutorial schema is replaced by validated ordered stages with display names, generic presentation rows, evaluator configuration, StageDirector lifecycle, and the current-plus-next loading window.
3. **Objective evidence, evaluation, and presentation:** normalized light/Cast-attempt/switch/termination facts, Stage 1–6 sequence plus combined Stage 7 Heat-gated evaluation, final-enemy evaluation, immutable row snapshots, and ObjectiveWidget are implemented.
4. **Player transition boundary:** Player exposes input lock and ordered stage reset; Arena orders PREPARED instantiation, placement, camera pan, evaluator binding, activation, unlock, and completed-area unloading.
5. **Stage 1 through free practice:** Stage 1 initializes at startup, progresses through Stages 2–7, transitions into the Final Arena, and final-enemy defeat switches that arena in place to indefinite `now you are free` practice.
6. **Eight-level Casting slice:** JSON, loader, and Portal enforce the exact capacity invariant of eight; generic tutorial Cast-level validation accepts `1..8` while existing Level-5 descriptors remain unchanged; Player uses a local ordered one-octave cue FIFO for every crossed visible-charge boundary; and the HUD derives Spell Level and bar fill from charged snapshot entries over the eight-level denominator, without adding gameplay state or components.

The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01. Because no exact scenario matrix was supplied, postflight must not infer individual results for these validation seams:

- Stage 1 starts immediately with Fire selected, one refill target, empty green-token progress, and a locked right gate;
- only physical Fire X hits advance progress, while Fire misses—including `orb_without_contact`—flinch/reset even before progress;
- unrelated actions before progress remain silent, while Cast insertion, non-Fire hit, X miss, or premature chain end after progress invalidates only the attempt;
- timeout, completion, failed Cast, and interruption each produce one normalized chain-termination fact, preventing progress from surviving a real chain reset;
- the fifth valid hit latches completion, turns the widget green, adds `moving on ->`, and unlocks the gate permanently;
- later combat in the completed Stage 1 area cannot revoke completion;
- Stage 2 completes only on a launched level-5 Cast; non-launched attempts and lower-level launches invalidate, while projectile impact is irrelevant;
- Stages 3–6 enforce their exact declarative X/Cast/switch sequences and invalidation rules;
- Combined Stage 7 Heat-row state, threshold-qualified chain start, chain invalidation, X5 completion, and direct transition to Final Arena require separate user validation;
- each completed stage locks input, pans to the next independently instantiated area, resets combat state, preserves active school, unloads the completed area, and prevents return;
- only current and next Stage Areas coexist during transition; PREPARED targets cannot collide, receive HealthEvents, process gameplay, or publish outcomes;
- shared training-area and Final Arena placement align anchors, preserve continuous ground, and respect transformed camera bounds;
- root-owned projectiles are removed before Final Arena instantiation, and Final Arena outcomes bind only after its evaluator exists;
- incoming `APPLIED` direct damage triggers charged-orb removal and five-point Heat loss exactly once even at zero final reaction, while `BLOCKED`, `PARRIED`, and DoT results trigger neither loss;
- camera pans use the default one-second duration, reject values outside `0.1–5.0`, persist Portal changes, and do not retime a transition already in progress;
- the existing final-enemy objective and practice targets remain functional after scene extraction; and
- final-enemy defeat immediately changes the widget to persistent `now you are free` with no progress row or further transition.

Existing Orb Casting, generic damage, Entity feedback, audio, Developer Portal—including its dormant legacy school controls—and Final Arena combat behavior are regression boundaries. The combined Stage 7 rows/evaluation have broad historical user-reported validation without a scenario matrix. The earlier Endurance, AI enable/disable, optional floor and defence waivers retain their original scope; dated later engine checks do not establish current human acceptance. Endurance and the floor are disabled in the present baseline. Additional Enemy attacks and legacy school-effect cleanup remain separate future slices.

The eight-level slice requires bounded validation that Charging reaches and stops at eight while the queue still stores ten, Spell Level and progress show `0..8`, Cast payloads and Enemy feedback preserve Levels 6–8, every visible charged-count boundary crossed in one or several updates produces exactly one corresponding note in ascending order without overwriting another cue, stage reset clears pending cues, Level-5 tutorial objectives remain unchanged, and an eight-orb commitment grants Heat exactly once from a consumed count of eight. The design-review waivers leave first-time comprehension of the ten-slot/eight-level distinction and discovery beyond Level 5 explicitly unverified.

Light widget-flinch values remain reversible prototype tuning. Shared training-area dimensions and internal marker placement are authored in the Stage Area scene. Historical broad user reports did not supply scenario-level coverage. Later dated isolated engine checks have their own scopes in IMPLEMENTATION_STATUS.md and do not validate the full current tree.

The user has specifically reported validating the smaller DoT floating-damage feedback. On 2026-09-05, the user also reported that the Final Enemy's solid-body collision works, the three restored practice targets remain pass-through, leaving the committed attack area during windup produces a miss without retargeting, and hitting the Enemy during windup does not interrupt its committed attack. The user then explicitly waived all remaining targeted verification passes for the current tuning phase. After the Stage 7/8 merge, the user broadly reported the combined Stage 7 implementation verified without supplying a scenario matrix. Those waivers do not establish the remaining untested combat, Portal, or defence behavior. A fresh Ultron `mode=tech-postflight` remains appropriate if broader runtime evidence is supplied later.

## Handoff

The current October 20 active-window/clash slice is implemented in the dirty working
tree and awaits user validation. Its exact source scope, static checks and manual
cases are recorded in IMPLEMENTATION_STATUS.md. No engine parsing, runtime,
compiler/build or automated tests validate this slice. This task ran no commit/push.
The following LimboAI handoff is retained historical context, not clearance of the
new contact source.

The October 14 hit-reaction candidate now supersedes blanket hurt-with-continuing-attack behavior. Validate the new candidate before submission clearance; historical LimboAI comparison checks below are the earlier baseline.


Historical LimboAI status: `IMPLEMENTED_AWAITING_LIMBOAI_USER_VALIDATION`.

The approved LimboAI conversion awaits the user's Godot comparison: reload the project to discover the native extension, open `ai/trees/final_enemy.tres`, inspect the active Final Enemy in Debugger -> LimboAI, and compare approach, windup, committed hit/miss, equal recovery, ordinary-hit non-interruption, Portal tuning/enable resets, death, and stage transitions. Web export requires a separate requested export check. No new diagnostic logs or automated tests were added. The existing trace output remains retained. A fresh Ultron `mode=tech-postflight` is appropriate for implementation review; submission clearance still requires its evidence gates.


## Inspector / Portal tuning synchronization — 2026-10-14

Both Portals and the character-root Inspector use the assigned Settings, shared
reaction/style Resources and native-animation geometry. The legacy Inspector
mirror under Player is a synchronized view, not a source or room profile. Saves
merge changed leaves against fresh sources and report partial writes. Active
reactions retain captured values; AI decision-setting edits retain their reset
behavior. The older Arena-node/JSON-mirror workflow is [historical](history/2026-10-20-document-housekeeping/sources/docs/TECH_ARCHITECTURE.md#inspector--portal-tuning-synchronization--2026-10-14).

## Focus editor integration — 2026-10-15

`addons/laema_dev_portal` registers the native editor dock and debugger plugin.
Its shared catalog/renderer supplies editor and runtime controls, validation,
series fill and audio percentage conversion. The dock reads the same assigned
character/native Resources and JSON preferences as the runtime Portal, independent
of a running scene. Startup is read-only. Draft editing, review/save and applying
to a running game remain separate. The Store merges changed leaves against fresh
sources, preserves independent edits and rejects same-field conflicts. Saving
several Resources/preferences is not a multi-file atomic transaction.

Arena owns the active dictionary and a baseline for its unsaved edits. Applying
saved settings preserves dictionary references held by components. The existing
runtime tuning callback retains gameplay ownership, reaction capture and AI
decision-reset behavior. Apply rejects stale snapshots and unsaved runtime
changes. Externally changed tutorial stage definitions require a restart.

The runtime debug-only session adapter exchanges snapshots and explicit apply,
stage-load and pause commands over Godot's debugger connection. It creates no
separate server. The editor requires exactly one connected Laema session for
commands. Editor file watching preserves a dirty draft; a clean draft follows
valid file updates. `ui.attack_hitbox_visible` persists the prior enabled debug
default; older files receive that default in memory on load.

See `addons/laema_dev_portal/README.md` for usage and the isolated validation
runner. Headless checks do not establish visual UX, an interactive debugger
round trip, gameplay feel, export success or postflight clearance.

`developer_settings_series.gd` discovers repeated numeric columns from catalogue
array paths. It offers a shared preview/fill dialog for combat reaction, Water
and Earth level tables, retaining field bounds, precision, integer metadata and
read-only cells. Each rule starts at the first editable row and advances by the
original level-index difference; fixed cells are skipped. Fill applies only the
selected changed paths to the draft. Table snapshot checks reject stale previews;
the ordinary save/apply pipeline remains separate.

The shared native renderer puts all five combat reactions beneath one Levels 1–5
foldout, with plain level headings and no individual level toggles. Legacy reaction
and move-Impact groups retain separate foldouts with draft-value summaries.
Foldouts are collapsed by default. Their expansion state is UI-only
and owned by each Portal, independent of saved gameplay configuration. The Impact
page retains all 22 existing moves; X1–X5 are ordered/grouped by school and Cast
and Enemy attack remain separate. The series adapter represents each school as
five ordered move-record paths, reusing the same numeric rules/preview and
writing only moves.<school>_xN.impact. It never adds a parallel Impact schema.

## Unified Combat Gym — 2026-10-19

`scenes/gym.tscn` is the development encounter: explicit F6 or editor Run gym.
Saved project F5 main-scene UID still points to tutorial, an intended-launch
mismatch left unchanged. Its `gym.gd` script
extends PrototypeArena and combines the bounded Fire encounter with the Gym
formula readout. The separate benchmark scene/script/area are deleted. The
canonical `gym_area.tscn` owns the 160-pixel placement and non-refilling opponent.

Gym inherits shared Player/CombatEnemy Settings and native animation ownership.
It has no private Fire filter, pacing multiplier, Endurance override or persistence
refusal. Rooms provide layout/spawns, objectives and result UI. Retry reloads the
scene and saved assets; only overlay visibility is carried through one-shot
SceneTree metadata. Both Portals save through the same shared path as Arena.

`gym.gd` creates GymCombatReadout after Arena initialization, subscribes once to
Player and the active Enemy, and follows HUD telemetry visibility. A full retry
recreates its subscriptions and clears captured contact history. F4 remains the
single developer-overlay toggle, including while paused. The result panel is
above the formula overlay. The tutorial does not gain this readout.

## Runtime pause menu — 2026-10-15

The shared Arena scene instances `scenes/ui/pause_menu.tscn`, so the tutorial and
inherited Gym share one HUD. Its CanvasLayer uses PROCESS_MODE_ALWAYS, handles
the pause action before gameplay's unhandled input, and consumes Start/Esc plus
menu cancel events. Default runtime input bindings map the action to controller
Start and physical Esc. Native focused buttons provide UI navigation and accept.

Arena connects the pause menu and runtime Portal's opening signals so only one
modal owns gameplay pause at a time. Opening either closes the other before it
captures/changes pause state. Editor debugger pause commands route through
Arena.set_game_paused and use the visible menu. Restart requests reuse the active
StageDirector option and Arena's existing reload/reset path, with transitions
guarded. Neither pause nor restart writes configuration. The pause overlay is
independent of the developer-readout visibility flag.

## Configurable hit-reaction ranges — 2026-10-15

The dedicated Hit-reaction levels page edits five combat_levels records, each with
minimum_value, duration and distance. combat_reaction_ranges.gd owns shared
validation, level selection and range display. Level 1 starts at 0, later integer
starts strictly increase, ends derive from the next start minus one, and the fifth
level is open-ended. HealthResolver and HitReaction both use the configured table;
range help and headings derive from the same data. This does not change reaction
eligibility or tie handling. The later October 16 formula implementation below
resolves the previously pending receiver-side clash alignment.

The JSON loader supplies default starts in memory only for older tables with all
starts absent; partially specified tables fail validation. The Inspector Resource
mirrors all three fields. Shared fill validates the whole proposed start sequence
before changing the draft. Legacy reactions have their own page and remain separate.

## Receiver-side clash formula — 2026-10-16

HealthResolver.calculate_reaction_value subtracts receiver Poise and only the
receiver's active melee-snapshot Impact from incoming Impact. Ordinary eligibility
is separate from level selection: positive values react, and zero additionally
qualifies for a direct Player hit against a combat Enemy in any phase. Enemy zero
and ordinary negative hits do not cause combat interruption. Cast layers retain
their existing transaction; zero remains a valid pending reaction and stronger
layers retain priority. HitReaction owns configured duration, displacement and
invincibility; CombatEnemy owns cancellation and AI reassessment.

The October 20 active-window implementation above supersedes the earlier
incoming/counter-candidate implementation. Each event requires its source's actual
character contact. Reciprocal active contacts at the same common sample capture
both signed values, compare larger-wins/equal-Player, and deliver only the winning
event. A non-positive winner selects configured Level 1 while preserving the raw
signed formula in diagnostics; no synthetic counter event or duplicate-counter
reaction-only path remains. Ordinary one-sided hits keep ordinary eligibility.
Existing invincibility, defence interception, first-contact spending, live-action
checks and mixed-Cast transaction ownership remain. The legacy tie flag is
diagnostic; eligibility does not depend on it. Gym identifies ordinary Player
zero advantage without mislabeling a forced Enemy zero-clash win.

Move Impact, Player/Final Enemy Poise, editor controls and Inspector hints now use
0–100; invalid configuration is rejected without clamping existing values. Runtime
HealthEvents reject Impact outside that range. The selected reaction still comes
from configured range starts and captures its duration/distance once.

Previously recorded focused headless engine checks covered both contact orders,
each winning side, attacker-Poise invariance, non-positive damage, the former 0/0
exception, phase snapshots from real Player/Enemy animations, duplicate counters
and input limits. Those results do not validate the October 20 amendment. Its
validation seams are Player zero-valued hits against idle/windup/recovery/active
Enemy, either clash contact order including zero-versus-negative, Enemy zero hits
against Player, negative-valued non-interrupting hits, and once-only damage and
reaction with the existing invincibility/transaction boundaries. The amendment
was inspected statically; no new engine, runtime, build or automated-test execution
is claimed for this implementation.

## Gym contact-time formula display — 2026-10-16

HealthEvent carries an optional development-only reaction_debug dictionary. The
resolver captures incoming move identity/Impact, receiver Poise and active-move
contribution before cancellation. reaction_evaluated emits copied scalar facts,
the actual selected level and result status after normal result delivery. Reciprocal
clash contexts retain both pre-cancellation signed values; the winning actual event
and rejected CLASH_LOST event are reported without a synthetic counter or a second
damage application.
Rejected invincible/defended events do not claim a new formula calculation.

Only gym.gd creates GymCombatReadout and subscribes to Player plus the currently
bound Enemy. It keeps separate last-calculation and latest-attempt records by
receiver, clears/rebinds on encounter reload, and ignores retired actor IDs. Live
move/Poise rows are observational. The click-through CanvasLayer sits below modal
UI and follows ordinary developer-readout visibility. The normal Arena
HUD and saved configuration remain unchanged.

## Unified developer overlay visibility — 2026-10-16

ui.developer_overlay_visible is the one saved developer-readout preference. Gym
mirrors HUD.DeveloperReadout's visibility_changed signal to its formula panel,
including direct HUD visibility changes; it no longer has a separate runtime-tuning
override or formula preference. F4 updates the canonical setting through the existing
runtime Portal callback and unsaved/save flow. The always-processing shortcut listener
still works while the formula panel is hidden or gameplay is paused.

Loading erases deprecated ui.gym_formula_visible in memory. The canonical developer
preference takes precedence; the deprecated value is used only if the canonical one
is absent. Explicit save writes the normalized configuration. Catalog metadata also
hides the obsolete field in stale live dictionaries so it cannot appear as a second
checkbox. Gameplay HUD, capture history and combat tuning remain separate from this
presentation toggle.
