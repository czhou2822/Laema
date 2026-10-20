# Implementation Status

## Fire X1–X5 v03 diagnostic image swap — October 20

Status: `AWAITING_USER_VALIDATION`. The user selected Art's all-five v03 sword-
angle studies for prototype integration. The five native Fire Animations now
reference 32 positions (8/6/5/6/7) in fixed448px cells, using the exact source
metadata phases. The selected sheets live in the existing recognized Fire asset
prefix, preserving the (224,400) feet anchor and current presentation/body owner.
The plain sword/crossguard is intentional diagnostic art, not a final weapon lock.

Only attack textures and Sprite image-region keys change. Animation UIDs,
active/timing markers, all existing geometry curves, collision, move timing,
lunge, Heat/input/damage/Impact, Idle/Walk/Hurt/Cast, other schools, Pikeman,
Gym/HUD/camera, AI and audio are preserved. The prior v01 attack sheets remain.
Current markers agree with Art's reference metadata; no older geometry is restored.

Known review limits: X3's reversed pose is excluded but its chamber-to-cut gap
remains. The v03 drawings can diverge from retained v01 hitbox curves: notably
X2 extends forward while the earlier backward-sweep query remains. The earlier
337 alignment assertions/captures below do not establish v03 visual alignment.

Evidence is static/source and image inspection only: source/copy/frame identity,
dimensions/regions, phase mapping, preserved markers/geometry and whitespace.
No editor/runtime/build/tests were run for v03; source contact sheets are not
engine captures. User review remains for both facings, all five moves, high Heat,
transitions/interruptions/retry, feet stability and F4 pose/query comparison.
The MINI/FULL Fireball VFX integration remains a separate pending plan.

Current candidate records, consolidated October 20. Engine checks belong only to
their named slices, including the focused collision correction below; they do not
validate unrelated active-window/clash/audio cases, imply human/controller acceptance,
or establish Web export or submission clearance. Heat timing and shared reaction
durations are resolved in GAME_DESIGN.md; the separate post-reaction AI wait is
also user-confirmed.

## Art-aligned Fire / pikeman collision correction — October 20

Status: `AWAITING_USER_VALIDATION`. The user approved both attack and body
corrections, Fire X2's backward coverage, unchanged damage windows/pacing and
focused Godot tests/captures. This supersedes the preserved physical mismatches
in the earlier art-only integration records below; their art limits remain.

Fire X1–X5 now use held, frame-aligned guard-to-tip capsule segments (radius3.5
local/7world). Pikeman uses hand-to-tip thrust segments (radius6), including close
coverage; full extension reaches localX211 right / X-233 left about visualX-11.
The native animations retain identities, sprite keys, markers and lengths. Only
their three geometry tracks change. Damage, Impact, Poise, lunge, approach range,
AI, SFX, layers, one-contact spending and other-school attack curves are preserved.

Fire Player's stable private rectangle is30×90 at(0,-19), root scale2:60×180world
with bottomY26. Legacy art restores26×30 at(0,11). The actual committed texture
retains its body across selected-school switches, including Cast. Player owns
profile synchronization; Movement calls before movement, Might before/after
clock advancement and after the contact frame. Reset/death clear stale Hurt
presentation and its tween. Pikeman's capsule is radius30/height180 at(-11,-59),
bottomY31. Both existing sprite/foot registrations and root positions remain.

Changed runtime scope: five Fire native melee resources and melee_swing;
scripts/player/player.gd; scripts/player/movement_controller.gd;
scripts/combat/might_component.gd; scripts/enemy/combat_enemy.gd;
scenes/enemy/combat_enemy.tscn. Player scene/assets, other-school native resources,
shared settings, evaluator/resolver and AI source are unchanged by this task.
The new tools/tests/art_hitbox_alignment_test.gd and its UID own focused evidence.
GDD, TDD and ATTACK_STYLES record the approved behavior/current authoring values.

Evidence: the existing runner imported and checked a fresh isolated project with
Godot4.7.1.stable.official.a13da4feb; all324 focused assertions passed. Cases cover
both facings, all Fire moves/pikeman active sprite poses, measured tip/near-hand
contact, outside-tip misses, actor collectors, per-target spending, artwork/query
frame agreement, head/torso/leg body reception, school switches during melee/Cast,
Hurt, failed Cast/reset, death, actual Retry, Final Arena capsule reuse, ordinary
solid movement/floor anchors and input-driven X1 damage/one generated orb.
Fixtures that place actors/seek clocks are distinct from ordinary input/physics.
The final Compatibility-renderer run passed337 assertions, including13 capture
saves. All13 rendered Gym images were inspected: five Fire attack poses in both
facings, both pikeman thrust facings and ordinary body contact. The yellow overlay
follows the sampled weapon; cyan engine debug shows the stable body. Native
ShapeCast authoring debug was hidden in captures to avoid confusing its restored
pose with the committed query overlay. Fixture seeks restart the clip first,
preventing a retained discrete sprite value after backward seeking.

Static comparison confirms geometry-only edits to the six native resources,
byte-identical scoped runtime files in the final isolated copy, and319 unchanged
paths out of330 protected pre-edit source/resource/asset hashes. The scoped runtime
plus test fingerprint is SHA-256
`a0814087ecacfea8d92567da273b1bf97b7ca0fac4f24dce65c40b21e1f21c88`.
Local task evidence retains both isolated runs, reports, all13 captures, their
overview, pre-edit copies and the before/after shutdown control. This fingerprint
covers the listed correction/test scope, not unrelated work or the entire tree.

Validation limitation: the runner reports overall FAILED because Godot logs
shutdown resource errors, despite zero assertion failures. A before/after boot/free
control reproduced the same23 ObjectDB /14 resource shutdown counts in both trees;
the fresh final focused run also reports those counts. Earlier warm runs showed
13/9. These existing lifecycle diagnostics are retained, not silently fixed or
reported as a clean engine run. No human/controller feel, full clash matrix,
submission review, export/build or publication was performed. Nothing was committed
or pushed by this task. Human acceptance of reach/spacing and remaining art limits
remains separate.

## Fire player sword-and-shield presentation — October 20

Status: `AWAITING_USER_VALIDATION`. The user's latest Art handoff authorizes
prototype integration of nine selected sheets/52 frames; the package's earlier
review-candidate labels and fine continuity/handling limits remain, not production
or runtime acceptance. Only Fire art changes. Pikeman v02, Gym framing05, other
schools, gameplay, hitboxes/colliders, lunge/movement, input, AI and SFX are preserved.

Fire X1–X5 and cast_fire native Animations use448px regions/new textures at their
exact existing frame times and markers. Old swapped earth_x1..earth_x5 textures
remain intact. Player selects Fire Idle/Walk/Hurt without overwriting the shared
128px sheets used by Water/Air/Earth. Actual displayed texture chooses the visual
profile, including a committed Fire action after a selected-school switch. Legacy
textures restore their saved material/filter/offset and original school styling.
Fire displays the accepted colors without the old outline/tint shader. Root2,
Sprite0.5, physical rectangle and all timing remain unchanged; a Fire-only offset
(0,-124) maps foot(224,400) to collider floor26local/52world/y610in Gym. Runtime
profile registration is not a new native-editor preview controller.

Exact changed files: scripts/player/player.gd; config/attack_animations/fire_x1.tres,
fire_x2.tres, fire_x3.tres, fire_x4.tres, fire_x5.tres and cast_fire.tres;
assets/prototype/player/fire_sword_shield_v01/PROVENANCE.md and its nine PNGs
(fire_x1.png..fire_x5.png, shared_idle.png, shared_walk.png, hurt.png, cast_fire.png);
docs/TECH_ARCHITECTURE.md; this file. Player's scene, the other20 native Animations,
shared originals, protected Pikeman/Gym/settings/resolver/AI source are not edited.

Static evidence: all nine runtime hashes/dimensions match selected metadata; six
native-resource comparisons differ only in texture references and region payloads,
preserving every current key time/marker and gameplay track. Source tracing covers
Fire/legacy restoration, Hurt and committed-action/mixed-Cast texture selection.
Protected-file hashes and whitespace checks are retained. No Godot/editor/import,
continuous playback, compiler/build, automated game tests or test creation was
performed. Nothing was committed, pushed or published by this task.

Art limits: fine sword/guard/shield/strap/face/hair continuity, separate X3 low
sweep, X5 shield grip and loop rhythm remain provisional. Cast's raised sword is
not an attack-rule change. X2's rearward blade remains rearward; its physical
coverage stays forward. X1's drawn forward edge likewise exceeds its query, and
the180px drawing is taller than the unchanged physical body. These mismatches
are reported, not retuned. Walk5376px/Cast4480px atlas import/Web/GPU compatibility
is unverified. Old art-source GDD descriptions need the owning result-only sync.

User validation: normal project import, then Fire Idle/Walk/X1–X5/Hurt/Cast in both
facings; compare feet and debug geometry, school changes during/after Fire moves,
failed Cast, interruption/reset/death/Retry and mixed-primary Cast presentation.
Return to Water/Air/Earth and confirm their original Idle/Walk/Hurt/attacks/Cast,
colors, filters and registration. Check Gym HUD/Pikeman remain unchanged. Inspect
X3/X5 handling, source-backed X2 sweep, actual walk motion and loop/transition feel.

## Corrected Pikeman v02 presentation — October 20

Status: `AWAITING_USER_VALIDATION`. Art's superseding v02 right atlases now supply
Idle/Walk/Attack/Hurt/Death, using four-column 768×512 cells and unchanged frame
counts 7/6/10/6/5. Runtime flips once for left facing. The approximately180px body
uses unit sprite scale; its (384,448) foot anchor maps through centered offset
(0,-192) and BodyVisual position(-11,31) to the unchanged capsule bottom. No actor
root/collider/spawn is scaled or moved. Gym framing05 camera/background/HUD and
current Player art are preserved. The user separately approved moving only the
HP label and windup warning above the taller body and floating-damage lane.

Native melee_swing changes only texture and region rectangles. Its key times,
0.5s active-start/full-thrust index5, 1.0s end, all AttackCast tracks and events
are unchanged. Scripted idle/walk/death pace, captured Hurt timing, existing death
hold/result freeze, AI, reactions, damage, progression and SFX remain unchanged.

Known mismatch, intentionally not retuned: the painted right thrust edge is about
115px beyond the unchanged query's x96 outer edge; the pike's visual height also
differs from its legacy hitbox lane. Left-facing geometry must be compared too.
Minor generated material variation and coarse five-frame death remain Art limits.

Exact changed files: scripts/enemy/combat_enemy.gd; scenes/enemy/combat_enemy.tscn;
config/attack_animations/melee_swing.tres; assets/prototype/enemy/pikeman/PROVENANCE.md;
assets/prototype/enemy/pikeman/repaint_v02/PROVENANCE.md and its five new PNGs
(idle_right_sheet.png, walk_right_sheet.png, attack_right_sheet.png,
hurt_right_sheet.png, death_right_sheet.png); docs/TECH_ARCHITECTURE.md; this file.
Existing native PNGs/provenance and unrelated dirty work are retained.

Checks: Art-source/runtime copy hashes and PNG dimensions; frame-region bounds;
source-based anchor/facing arithmetic; old/new native Animation comparison with
only texture/region payloads excluded; collider/query/AI/audio source-block
preservation; protected Gym/Player/settings/AI/resolver hashes; whitespace checks.
Art's 34-frame/68-cell/mirror/boundary review is reported source evidence, not an
agent-run game test. No Godot/editor/import/build, continuous playback or automated
tests ran or were created. This task did not commit or push.

User validation: open Gym after normal import; walk/fight in both directions,
compare feet to the floor, and inspect full thrust against the debug hitbox.
Check ready/loop/recovery, interruption/reset, Hurt, Death's existing terminal
behavior and Gym result freeze/Retry. Confirm HP/warning/damage readability,
unchanged Player and framing05 HUD. Also compare the reusable Enemy in Final Arena.
The GDD's earlier native-Pikeman source wording predates this accepted Art change;
its owning result-only documentation synchronization remains outstanding. No new
gameplay decision is implied by this presentation integration.

## TDD consolidation and editor wait alignment — October 20

Documentation-only source check: TECH_ARCHITECTURE.md consolidates ownership,
combat/contact, Settings/persistence, tutorial lifecycle, presentation/tools and
validation. All dated amendments and earlier records are preserved in
[TDD history](history/2026-10-20-tdd-housekeeping/README.md); old deep-link anchors
remain beside their current topic. Companion stale conflict labels are aligned.

The current Enemy tree contains BTRandomWait min_duration 0.3 / max_duration 0.8
after its hit-reaction task. The user confirmed: “the editor is correct, align
to the editor setting.” GDD, TDD, Gym and Combat continuity now record that
separate post-reaction AI wait. It does not extend HitReaction-owned hurt,
knockback or invincibility. No tree, script, asset or tuning was changed. Live
BT scheduling/feel remains user validation; this documentation alignment adds
no engine, automated-test, build or export evidence.

## Air X5 Weapon Summon correction — October 20

Status: `AWAITING_USER_VALIDATION`. The approved eleven-frame full-body
Weapon_Summon replaces the byte-verified eight-frame Weapon_1 effect at the same
`air_x5.png` path. The native Animation's sprite rectangles and presentation key
spacing now cover all eleven frames using the existing quadratic convention.
Clip length, active_start/timing_split/active_end, all hitbox tracks, character
settings and Air X1–X4 remain unchanged. Player and the move Resource continue
referencing that same Animation asset; no script change is required.

Changed: assets/prototype/player/animation/air_x5.png,
config/attack_animations/air_x5.tres, assets/README.md, GAME_DESIGN.md,
TECH_ARCHITECTURE.md, this status record and departments/art.md. Exact pre-change
files and provenance are in [Air X5 history](history/2026-10-20-air-x5-weapon-summon/README.md).
The existing texture import descriptor is preserved unchanged, including UID.

Checks: source hash and PNG dimensions; all eleven sprite rectangles in bounds;
only sprite-key changes in the native Animation; marker/length/geometry and
surrounding source preservation; source binding trace and whitespace. No Godot,
editor, engine import/parser, playback, build or automated tests ran or were
created. No commit/push occurred.

User validation: allow the normal Godot texture reimport, scrub/play air_x5 and
check eleven full-body poses without the detached-star replacement. In ordinary
play, reach Air X5, test both facings and the transition to the next allowed
Cast/idle state. Confirm existing duration, hit window, reach and input behavior
remain unchanged. Visual continuity with shared locomotion/other Air moves is
still provisional; source checks do not establish feel or runtime correctness.

## Gym framing05 background and HUD clearance — October 20

Status: `AWAITING_USER_VALIDATION`. Gym uses Art's v02 split plates with the
existing camera anchor moved to y-198. The physical floor remains y52; the
1280 × 720 source projection places it at screen y610 with 110 pixels of
foreground. Gym-only compact HUD panels start at y648 and target height 64,
preserving all values, ten orb slots, both bars, objective and developer UI.
Normal tutorial HUD/camera behavior and all physical/gameplay data are unchanged.
The pending 180-pixel fighter art/flipbooks are not substituted for live actors.

Changed: scenes/stages/gym_area.tscn (textures/origin/camera anchor), scenes/gym.tscn
(HUD presentation opt-in), scripts/ui/prototype_hud.gd (optional compact layout),
assets/prototype/arena/town_edge_yard/town_edge_yard_v02_background.png and
town_edge_yard_v02_ground.png (byte-identical Art copies), that folder's
PROVENANCE.md, docs/TECH_ARCHITECTURE.md and this document. Existing v01 assets and
unrelated source changes are retained. No Godot/editor/runtime/build/tests or
commit/push were run by this task. Static checks cover PNG dimensions/hashes,
scene placement and preservation, data-path inspection and whitespace.

User validation: open Gym at 1280 × 720, confirm the floor sits near y610 and the
bottom HUD clears the fighting line. Fill/charge the queue and trigger overflow;
expect ten-slot/Spell Level/bar updates and the flinch to stay in the lower panel.
Check objective/developer UI readability, movement/attacks, victory/defeat Retry,
and compare a tutorial scene to confirm its normal layout remains unchanged.
Risks: live container minimum sizing and visual coverage are not engine-verified;
the static plates are not seamless and expanded aspects remain unvalidated.

## Active-window contact and signed simultaneous clashes — October 20

Status: `AWAITING_USER_VALIDATION`. Implemented in the uncommitted working tree;
the TDR's active-window amendment now describes the candidate source. This
supersedes older contact-marker/synthesized-counter and clash ordering claims,
including the intermediate zero-result amendment below. It is not Ultron
clearance, runtime acceptance or a claim that older test totals cover this slice.

### U-001 correction — terminal-window re-query

User disposition: accepted; DUM-E correction implemented, awaiting Ultron recheck
and user validation. Might's window_resolved and CombatEnemy's window_finished
now make their snapshots inactive after the final active_end sample resolves.
Collection and HealthResolver's live-action guard consume that same snapshot,
preventing a new physics tick from re-querying an endpoint already reported as
missed, damaging a late entrant, or contributing retired active-move resistance.
The endpoint's original contacts still resolve before closure. The testing-only
no-contact orb path now records orb_granted before emitting its queue update.

Changed for this correction: scripts/combat/might_component.gd,
scripts/enemy/combat_enemy.gd, docs/TECH_ARCHITECTURE.md and this status document.
Read-only caller/source tracing and diff/whitespace checks only; no Godot, engine
parser, builds or tests ran or were created. Remaining focused validation: with
active_end exactly on a physics boundary and recovery remaining, miss the final
sample, then move a target into range on the next tick. Expect no damage, hit
outcome or additional orb from the retired window; repeat with the no-contact
orb option enabled and expect exactly its one grant. Also check a contact at
the final sample still applies once and that the same closure holds for Enemy.

Player and CombatEnemy query animated hitbox geometry across active_start through
active_end, including later contact after an initial miss. A scene-local physics
barrier advances both actors to common bounded sample times before collecting
contacts and resolving damage. Actors retain action IDs, private animation curves,
once-per-target spending, cancellation, tuning and reset ownership. First contact
is spent before invincibility/block/parry resolution; ignored contacts grant no
APPLIED-hit resources/objectives and cannot retry when invincibility expires.

One-sided contacts resolve only against the actually reached receiver. There are
no range-free reverse hits. Reciprocal active contacts at the same sample compare
both pre-damage signed values: larger wins, equality favors Player. Only the
winner's damage applies and the loser is interrupted; a non-positive winning value
selects configured Level 1 without rewriting the signed diagnostic value.
Ordinary negative hits remain damaging/non-interrupting, ordinary Player zero
against a combat Enemy selects Level 1, and ordinary Enemy zero does not interrupt.
Already-applied sequential damage is retained.

Might emits hit/objective success once per action on APPLIED contact, grants at
most one eligible orb per action, and delays miss/testing-only no-contact outcomes
until active_end. Existing Heat, Endurance and mixed-Cast transaction owners remain.
Cancellation/replacement guards prevent old samples or callbacks from mutating a
replacement action. Cast emission remains once-only at its renamed launch marker.

All 26 native animations retain their pre-slice authored times, lengths and
sprite/geometry tracks: 21 melee contact markers become pacing-only timing_split,
and four school Casts plus attack_clock use launch. AttackStyle retains the
existing duration split/lunge prediction; active_start is the fallback if the
optional pacing split is absent. Portal/Inspector geometry mirrors now read/write
active_start; private action curves and animated debug overlays follow the same
active-window contract. Native marker/geometry validation is migrated.

Checks actually performed: read-only source/caller/diff inspection, retired
marker/consumer scans, pre-slice-to-current native resource comparison across all
26 animations (marker names only), and `git diff --check`. No Godot/editor,
engine parser/compiler/build, playback or automated tests were run or created.
Old single-contact test fixtures were not modified or executed; updating/running
them needs separate authorization. Parallel audio/Pikeman/art/settings changes
were preserved, not included as new work in this slice. Nothing was committed
or pushed.

### Exact contact-slice files

The following inventory is this slice's edit scope, not the entire dirty tree.
Some listed files also contain preserved changes from parallel work.

- `addons/laema_dev_portal/move_style_inspector.gd`
- `scripts/combat/attack_geometry.gd`
- `scripts/combat/attack_style.gd`
- `scripts/combat/combat_controller.gd`
- `scripts/combat/contact_evaluation.gd`
- `scripts/combat/might_component.gd`
- `scripts/config/developer_settings_catalog.gd`
- `scripts/config/move_style_tuning.gd`
- `scripts/enemy/combat_enemy.gd`
- `scripts/entities/health_event.gd`
- `scripts/entities/health_resolver.gd`
- `scripts/player/player.gd`
- `config/attack_animations/air_x1.tres`
- `config/attack_animations/air_x2.tres`
- `config/attack_animations/air_x3.tres`
- `config/attack_animations/air_x4.tres`
- `config/attack_animations/air_x5.tres`
- `config/attack_animations/earth_x1.tres`
- `config/attack_animations/earth_x2.tres`
- `config/attack_animations/earth_x3.tres`
- `config/attack_animations/earth_x4.tres`
- `config/attack_animations/earth_x5.tres`
- `config/attack_animations/fire_x1.tres`
- `config/attack_animations/fire_x2.tres`
- `config/attack_animations/fire_x3.tres`
- `config/attack_animations/fire_x4.tres`
- `config/attack_animations/fire_x5.tres`
- `config/attack_animations/water_x1.tres`
- `config/attack_animations/water_x2.tres`
- `config/attack_animations/water_x3.tres`
- `config/attack_animations/water_x4.tres`
- `config/attack_animations/water_x5.tres`
- `config/attack_animations/attack_clock.tres`
- `config/attack_animations/cast_air.tres`
- `config/attack_animations/cast_earth.tres`
- `config/attack_animations/cast_fire.tres`
- `config/attack_animations/cast_water.tres`
- `config/attack_animations/melee_swing.tres`
- `docs/TECH_ARCHITECTURE.md`
- `docs/IMPLEMENTATION_STATUS.md`

### Remaining user validation

1. In Gym, enable Combat > Show attack hitbox. Check both facings: the overlay
   follows authored geometry for the whole active window; start out of range and
   connect later, or miss the entire window. Expect one hit per target/action,
   with no premature miss or duplicate orb/objective completion.
2. Make first contact while the receiver is invincible; let invincibility end
   before that attack's active_end. Expect no retry from that action. Check block
   and parry likewise consume the contact without APPLIED-hit resources.
3. Arrange reciprocal active character contacts and inspect the formula readout:
   Player -10 / Enemy 0 -> Enemy; Player -5 / Enemy -10 -> Player;
   Player -10 / Enemy -5 -> Enemy; equal negatives and 0/0 -> Player.
   Only the winner deals damage; non-positive winners give configured Level 1.
   Also check positive wins use configured ranges, and ordinary one-sided
   negative/Enemy-zero hits do not interrupt or manufacture a reverse hit.
4. Check Cast launches once at the unchanged launch time, including fast playback;
   exercise mixed layers, multi-target X, buffered chains, interruption and
   replacement, pause, retry/reset and tutorial transitions. Check Portal
   reach/radius edits, Save/reload and native active-window authoring agree.

Residual risk: Godot parse/API compatibility and integration are unverified.
Common-sample physics/BT ordering, fast-update boundaries and sample cost need
runtime observation. Detection samples the animated geometry; it is not an
analytical continuous swept-volume solver. Earlier user reports and automated
results do not establish acceptance of this new source.


## Accepted original-Heroes replacements — October 20

Twelve prepared PCM16/derived WAVs now cover common Player X, hurt, four school
Cast-launch cues, empowered feedback, failure, generated orbs, the guard warning,
the stationary target's response, and the eight pitched charged-orb notes.
Player/Enemy scene bindings use the existing SFX players; CombatEnemy retains
PIKEWNCE and its other three original cues. Projectile flight/impact stay silent.
Magic/Combat state, action timing, bus controls, Ambient and BGM are preserved.

Charging uses the single 0.18-second PICKUP03 excerpt, not the reference melody.
Visible-count deltas enqueue every newly reached level once; finished callbacks
drain the FIFO with unchanged eight pitch ratios and fixed note gain. Stream
load failure, decreases and lifecycle cancellation cannot strand old notes.
Cast/empowered/pickup tails duck by 12 dB during notes and restore captured gains.
Runtime mappings, hashes, source derivation and manual listening cases are in
`assets/prototype/audio/ORIGINAL_HEROES_SFX.md` and `heroes3-replacements.json`.

Only static/source, metadata/hash, import/path and whitespace checks support this
candidate. No playback, Godot/editor/runtime, build or automated tests were run
or created. Audition of all eight notes, overlap/gain, rapid/batched charging,
cancellation, cue placement and SFX controls remains required. Copyrighted game
audio is not CC0; no commit/push/live publication is authorized. The historical removal record describes the preceding silent stage, not the current assignments.

## Original-Heroes-only SFX audit/removal — October 20

Historical intermediate state, superseded by the current replacement/contact records above. Its original scope, source checks and pending cases are preserved in the [pre-housekeeping status snapshot](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md). It supplies no additional current validation.

## Original Pikeman audio candidate — October 20

CombatEnemy in Gym and Final Arena now uses PCM16 copies of PIKEATTK at committed
thrust start, PIKEWNCE for its accepted nonzero hurt reaction, PIKEKILL once on
death, and repeating PIKEMOVE during actual approach movement. Existing SFX-bus
controls apply. State changes, cancellation, deactivation/reset and teardown stop
the corresponding playback; Player and practice-target audio remain unchanged.
PIKEDFND stays reserved. All four copies preserve mono 22,050 Hz and original
RIFF `fact` sample counts/durations; originals and conversion hashes are retained.

Source/asset checks only: no playback, Godot/editor/runtime, build or tests were
run for this slice. User audition remains for hits/misses, hurt interruption,
once-only death, blocked/ended movement, reset/teardown and SFX volume/mute.
These copyrighted original-game recordings have no established redistribution
license; this handoff does not publish, commit or push them. The active-window
melee slice is tracked separately above; this audio work did not implement it.

## Player zero-result advantage — October 20

Historical intermediate state, superseded by the current replacement/contact records above. Its original scope, source checks and pending cases are preserved in the [pre-housekeeping status snapshot](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md). It supplies no additional current validation.

## Pikeman presentation and attack-speed candidate — October 20

Historical native-sheet presentation, superseded by corrected v02 above. Its
accepted attack pacing remains unchanged by that visual replacement.
CombatEnemy previously referenced the local Heroes III Pikeman idle, walk, front attack,
hurt, and death sheets in both Gym and Final Arena. Multi-row sampling and one
shared feet anchor preserve the intended size/alignment. The user reported the
visual swap looks good, then requested original attack pacing. The attack now
uses the 1.0-second Pikeman base duration found in both installed `CrAnim.txt`
copies, evenly spaced ten-frame playback, active_start at 0.5 seconds, and active_end/length at
1.0 second. Marker/geometry-key times are retimed; geometry values, collision,
damage/Poise/Impact, and practice targets are preserved. The speed adjustment
has source/static evidence only; Godot execution and user acceptance of the
new attack timing remain pending.
The archived older automated results do not validate this presentation change.

## Current implementation — character settings and tree-triggered hurt, October 20

New user-directed work follows published `8f89498` and supersedes the overnight
freeze for this task. The archived frozen report is historical, not the current working-tree state. Character root Settings replace level/Gym combat profiles;
Portal/Inspector read and save the same assets. The Enemy tree executes captured
reaction requests through the shared HitReaction component. Both scenes now use
the former Gym baseline, including Fire/Cast pacing, health, Poise/Impact, orb
contact and Player death. Native animation/collider edits remain intact.

Validation: 1,497 assertions across seven suites passed in isolated copies using
Godot 4.6.3 stable official Linux x64: 87 character ownership/parity/tree-reaction,
180 Portal/config/layout, 287 clash, 153 Enemy timing/lifecycle, 121 Gym encounter,
595 attack-style and 74 native authoring checks. Fixture cleanup drains audio
playback before destruction; clash fixtures preload canonical actor scripts
before their lightweight subclass to avoid Godot 4.6 script cleanup retention.
Final successful logs contain no script/resource errors. Source editor/profile
was not run or modified. Native attack Animation files and actor body/sprite
transforms are unchanged. No human/controller acceptance or Web export is claimed.

The new ownership checks cover Inspector-to-runtime reads, Portal-to-actor saves,
conflicting edits, alternate root-assigned assets, shared reaction edits, pending
protection, disabled AI, mixed-hit capture and Player death/reset in both scenes.
Scene instances provide Enemy placement only; its killable combat role lives on
the reusable CombatEnemy root.

## Historical implementation and validation index

The complete pre-housekeeping status document preserves every preceding slice,
source identity, check count, caveat, user report and waiver. These records are
revision-specific history rather than descriptions of today's full tree.
No historical checks were rerun during housekeeping.

## Frozen overnight candidate / morning handoff — October20

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#frozen-overnight-candidate--morning-handoff--october20). Later candidate records above take precedence where they supersede this revision.

## Retained OVERNIGHT CANDIDATE feedback anchors H — October20

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#retained-overnight-candidate-feedback-anchors-h--october20). Later candidate records above take precedence where they supersede this revision.

## Retained OVERNIGHT CANDIDATE Enemy package — October20

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#retained-overnight-candidate-enemy-package--october20). Later candidate records above take precedence where they supersede this revision.

## Retained overnight FireX2/X3 close-contact candidate — October20

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#retained-overnight-firex2x3-close-contact-candidate--october20). Later candidate records above take precedence where they supersede this revision.

## U-003 contact diagnostic / test-only correction — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#u-003-contact-diagnostic--test-only-correction--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Retained overnight Fire Cast anticipation candidate — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#retained-overnight-fire-cast-anticipation-candidate--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Overnight U-002 initial AI snapshot candidate — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#overnight-u-002-initial-ai-snapshot-candidate--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Overnight U-001 progress-query candidate — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#overnight-u-001-progress-query-candidate--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Authored Enemy attack timing — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#authored-enemy-attack-timing--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Enemy sprite transform / idle-foot grounding — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#enemy-sprite-transform--idle-foot-grounding--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Cast completion / melee follow-up correction — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#cast-completion--melee-follow-up-correction--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Fire / Earth benchmark flipbook swap — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#fire--earth-benchmark-flipbook-swap--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Native attack scrubbing and visual hitbox authoring — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#native-attack-scrubbing-and-visual-hitbox-authoring--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Move-resource FileSystem navigation — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#move-resource-filesystem-navigation--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Fire X and leveled Cast reactions — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#fire-x-and-leveled-cast-reactions--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Unified Combat Gym — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#unified-combat-gym--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Benchmark pacing and charged-orb progress — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#benchmark-pacing-and-charged-orb-progress--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## L2 Charging and Casting — 2026-10-19

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#l2-charging-and-casting--2026-10-19). Later candidate records above take precedence where they supersede this revision.

## Four school melee styles — 2026-10-16

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#four-school-melee-styles--2026-10-16). Later candidate records above take precedence where they supersede this revision.

## Unified developer overlay visibility — 2026-10-16

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#unified-developer-overlay-visibility--2026-10-16). Later candidate records above take precedence where they supersede this revision.

## Gym combat formula display — 2026-10-16

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#gym-combat-formula-display--2026-10-16). Later candidate records above take precedence where they supersede this revision.

## Receiver-side clash formula — 2026-10-16

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#receiver-side-clash-formula--2026-10-16). Later candidate records above take precedence where they supersede this revision.

## Configurable hit-reaction levels — 2026-10-15

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#configurable-hit-reaction-levels--2026-10-15). Later candidate records above take precedence where they supersede this revision.

## Collapsible reactions and Impact configuration — 2026-10-15

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#collapsible-reactions-and-impact-configuration--2026-10-15). Later candidate records above take precedence where they supersede this revision.

## Start-button pause HUD — 2026-10-15

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#start-button-pause-hud--2026-10-15). Later candidate records above take precedence where they supersede this revision.

## Development gym — 2026-10-15

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#development-gym--2026-10-15). Later candidate records above take precedence where they supersede this revision.

## Focus editor Godot plugin — 2026-10-15

Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#focus-editor-godot-plugin--2026-10-15). Later candidate records above take precedence where they supersede this revision.

## Current implementation candidate

This heading is retained for historical link compatibility; the current source is described at the top of this document. Historical record: [original scope, evidence and limits](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#current-implementation-candidate). Later candidate records above take precedence where they supersede this revision.

The earlier-feature record includes the September 1 Stage 1–6 user report,
September 5 targeted collision/miss checks, broad combined Stage 7 report and
tuning-phase waivers. Those reports do not establish scenario-level coverage,
current-tree correctness or acceptance of later interruptions/contact changes.
Air/Earth defence, final presentation/content/balance and broader defeat design
remain open. Earlier waived cases remain unverified unless a later scoped report
actually supplies evidence; the archive preserves the full original list.

### Earlier feature and validation record

Historical [feature reports and complete waiver list](history/2026-10-20-document-housekeeping/sources/docs/IMPLEMENTATION_STATUS.md#earlier-feature-and-validation-record), retained with their original revision and evidence limits.
