# Implementation Status

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
audio is not CC0; no commit/push/live publication is authorized. The removal
record below describes the preceding silent stage, not the current assignments.

## Original-Heroes-only SFX audit/removal — October 20

42 non-Heroes runtime SFX and 42 import sidecars have been removed with a recovery
ZIP outside the depot and a hashed inventory under `docs/audio/`. Their path
bindings are empty and tolerate unassigned sources; Player/base-target feedback
and projectile audio are silent pending selection of original-game replacements.
The charge FIFO does not enqueue while its source is empty. The four original
Pikeman runtime cues remain in place. Ambient wind and Fairy Battles BGM remain
outside this SFX pass. Audit, source mapping and identity checks are static only;
no agent-run playback, Godot, editor, build or automated test validates the removal.

See `docs/audio/2026-10-20-original-heroes-sfx-audit.md`.
Older cue-specific implementation claims below describe preceding source state.

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

Implemented in HealthResolver's common eligibility and both clash candidates.
An applied direct Player hit against a combat-reaction Enemy qualifies at exactly
zero and selects configured Level 1, including idle, windup, active and recovery.
Both contact orders use the candidate's actual instigator/receiver; Player zero
versus Enemy negative and exact 0/0 now favor Player. Enemy zero against Player
and negative results remain non-interrupting. Signed captured values, existing
winner ordering, invincibility/defence checks, damage/resource delivery, per-action
hit tracking, mixed-Cast transaction and reaction/AI lifecycle remain in place.
Gym's existing formula readout displays Player zero advantage.

This amendment has source/static evidence only. No Godot/editor/runtime/build or
automated tests were run or created for it. Earlier automated results below do
not validate the amendment. User-run checks remain for zero-valued melee/Cast
contacts in each Enemy phase, both clash contact orders, negative/non-Player-zero
controls, cancellation/reassessment, duplicate contact and mixed-layer reactions.

## Pikeman presentation and attack-speed candidate — October 20

CombatEnemy now references the local Heroes III Pikeman idle, walk, front attack,
hurt, and death sheets in both Gym and Final Arena. Multi-row sampling and one
shared feet anchor preserve the intended size/alignment. The user reported the
visual swap looks good, then requested original attack pacing. The attack now
uses the 1.0-second Pikeman base duration found in both installed `CrAnim.txt`
copies, evenly spaced ten-frame playback, contact at 0.5 seconds, and end at
1.0 second. Marker/geometry-key times are retimed; geometry values, collision,
damage/Poise/Impact, and practice targets are preserved. The speed adjustment
has source/static evidence only; Godot execution and user acceptance of the
new attack timing remain pending.
The older automated results below do not validate this presentation change.

## Current implementation — character settings and tree-triggered hurt, October 20

New user-directed work follows published `8f89498` and supersedes the overnight
freeze for this task. The frozen report below is historical, not the current
working-tree state. Character root Settings replace level/Gym combat profiles;
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

## Frozen overnight candidate / morning handoff — October20

Working source remains the eight-file retained package at HEAD644587b plus
uncommitted candidates,637 runtime-file digest
`063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
No publication or final human acceptance. See
`iterations/2026-10-20-morning-handoff.md` for the FINAL HANDOFF, exact paths,
source/evidence provenance and focused morning sequence; earlier scoped reports
below retain their own source identities and dates.

Supervisor bounded source/report review is IMPLEMENTATION_REVIEW_COMPLETE, no
new conformance finding; report content is final and candidate frozen before
05:30. Current phase is documentation/verification only, with no new source/
experiment/test/engine work. At05:33 supervisor independently verified HEAD,
all637 H hashes,47 paths/appendix, no staged files and all11 absolute links.
Process inventory showed only user Godot editor PID37568; no owned game/headless
runs. Editor remains open. Human/controller/submission acceptance is pending.

FINAL HANDOFF: worker finish/stop stamp 2026-10-20 05:54:10 HKT. Supervisor confirmed
heartbeat PAUSED05:53, preserving its prompt/cadence/thread. Parent native play
runs stopped02:56; worker-owned jobs already ended. No owned game/headless runs
remain; preserve user Godot editor PID37568 open, per the recent supervisor
inventory. No new check/run/source edit for shutdown. Overnight execution ended;
remain stopped until direct human request. At/after06:00 cleanup/stop only,
no project work or edits. Human/controller/submission acceptance remains pending.
Limited native baseline
keyboard/mouse evidence is explicit F6 launch, idle defeat/Retry and left-mouse
X1 ten damage/one generated orb; it predates H and does not validate native
Charging/release Cast/parry/full fight or current-H physical-controller feel.
Later full-route results remain scripted InputMap/GPU evidence.

Separate current-H native evidence: supervisor reloaded reviewed disk, inspected
Poise10, explicitly launched F6, observed ordinary Enemy hits/natural defeat and
native Return Retry100/200 HP,0 Heat/orbs and cleared readout/labels. F8 then
stopped that run; only editor window5245890 remained, no LaemaDEBUG. Escape did
not show Pause before further damage/defeat; focus/input delivery was unsettled,
so neither native pause validation nor a production fault is claimed. No native
held Charging/Cast/parry/active full-duel or physical-controller acceptance.

Native reload/scan generated12 preserved test .gd.uid metadata sidecars. Current
inventory is20 M+27 U=47 paths; the earlier35-path inventory remains historical.
No saved code/property edit, runtime-value or637-file runtime identity change.

Later unchanged-H evidence includes fixed process30/60/120 with physics60
(73 headless checks each; supervisor GPU30/120 each92), and11 complete timing-
variation parry fights, all HP100 victories. Ten headless variation runs pass87
checks each; the first87-check report retains one invalid capacity assertion
(20 APPLIED=12 created+8 overflow), corrected without replay. Supervisor wider-
seed GPU95/4PNGs is separate evidence. These finite machine policies do not
establish physical-controller, human timing/feel or general balance acceptance.

Isolated Gym1.2s feedback duration is rejected for this night's promotion;
working H retains2.0s. A/B each153 focused+110 existing headless checks, A D3D12
GPU174/24PNGs and separate B GL174/24PNGs do not erase B's failed initial D3D12
startup0xC0000374 (no gameplay/report/captures). Cause remains unknown, alongside
earlier native0xC0000005 and cold UID errors. No renderer-default/main-runner
change or blanket all-checks-passed claim. Full dispositions are in the ledger.

## Retained OVERNIGHT CANDIDATE feedback anchors H — October20

Exact reviewed component SHA
`834925ff5544c13a31ad5891bfce559e257584e7032ff02d228dd41049cffe17`
is promoted: only damageY−238→−186 and DoTY−206→−154. Cast−118, style,
parenting/clamp/scale, motion/lifetime and event/damage semantics stay unchanged.
Supervisor actual OpenGL A/H each passes68 capture-mode checks and produces10
full viewport PNGs, exit0/zero errors. Palette is intentionally skipped in
capture mode; separate headless110 checks include it. Inspected fresh glyphs
clear EventPanel and initial Player DoT/Cast glyphs stay separate. Human
readability/feel acceptance and resolution-independent clearance are not claimed.

Fresh final source: feedback110, Cast45 and shared entity/readout23 pass with
zero engine/resource errors. All637 runtime files equal reviewed H; only this
component differs from round12, with exactly two literal changes. Real combat
event/resource/phase dictionaries match H after removing only machine IDs.
Repeated NPC numbers and old Player-number upward drift remain baseline limits;
F is rejected as-is, G retained only as comparison. Pause asymmetry/clamp/scale
are not repaired. Earlier F5/cold-import/cleanup caveats stay in the ledger.

## Retained OVERNIGHT CANDIDATE Enemy package — October20

Exact reviewed E scene/animation data is promoted: GymPoise10, native Enemy
active_start/contact1.1, active_end/length1.3, same poses/geometry values at
retimed keys, speed1 and no tail/timer. Base script default/shared JSON remain
unchanged, including actual tutorial Poise0. Shared tutorial native cadence
changes61→79 ticks. FireCast0.24, X2/X3X40, both code fixes and core combat rules
remain. Final human controller/feel/balance acceptance is pending.

Supervisor actual-renderer complete E routes: no-parry default wins1482 ticks,
HP90,9 Casts/11 melee; parry wins1599,HP100,20 parries/20 melee; wall spacing
defeat1008,Enemy120. Terminal viewport images/Retry states were inspected. This
supports mechanical encounter viability, not universal balance. Local±3-tick
parry and130/135/145 spacing probes remain first-exchange evidence only; failed
wall route/charge-loss fumbles and earlier naive-policy losses are preserved.

Fresh source regressions explicitly assert stock1.1/1.3/no-tail and default
Poise10 Levels0–4 while retaining the original Poise1 formula matrix privately.
Current input parry is marker-relative; old fixed0.68 loss reports are archived.
Rear-Cast interruption scheduling alone moves with Enemy contact to retain
before/between/after launch semantics. Exact counts/source comparisons and cold
editor import/shutdown caveats are in the ledger. Gym's sole F5 assertion stays
a known mismatch: use explicit Gym F6/Portal; project.godot was not retargeted.
No whole-project, live/export or human validation claim.

## Retained overnight FireX2/X3 close-contact candidate — October20

Exact reviewed D resources are promoted: existing position keys X43/42→40,
Y11/radius16/target0 unchanged. Key times, markers, sprites, lunge, damage,
Impact, actor/collider scale, once-only queries and invincibility/clash/generation
rules are unchanged. At Player scale2 the shift gains6/4 world pixels inward
and loses6/4 outward. Supervisor actual GPU A14/D16 checks and four PNGs each
support close swing/contact alignment at the same pose/clock. This is a retained
OVERNIGHT CANDIDATE; final human controller/feel acceptance remains pending.

Fresh source passes clash270 (all original198 assertions retained), contact164,
close508, original input11, Cast45, styles595, Enemy152 and shared lifecycle67.
Gap48/right now tests positive contact; inner16 and far180 both-facing negatives
remain. Overreach mutation is separately checked. All eight ordinary-input and
ten detailed contact-chain reports match reviewed D after removing only machine
instance IDs. Initial import/shutdown caveats and final run results remain
separate in the ledger. Shared JSON/mirror and every non-X2/X3 runtime file
matched that round's prior source. At round10 Gym Enemy remained1/0.8/1.0;
the later retained package above supersedes that baseline. Current native
X4(30,11) and X5(35,11) are untouched; see ATTACK_STYLES.md.

## U-003 contact diagnostic / test-only correction — 2026-10-19

Round8 reproduced the retained-source clash suite's 14 FireX2/X3 failures.
Their positive fixture placed the Enemy48 world pixels ahead, outside those
then-authored compact contact circles after Player scale2 and Enemy collider X−11
are applied. Correct move IDs/contact clocks and once-only query ran; native
ShapeCast and independent overlap queries both returned no target. No health/
reaction event was emitted, so no resolver/cancellation fault is demonstrated.
Additional physics waits did not change the result. Test-only positive placement
is now64; all198 prior behavioral assertions remain, with mirrored/negative
coverage bringing the suite to244 passing checks. Private overreach fault
injection makes24 negative assertions fail, preserving meaningful miss coverage.

The round8 native geometry/real-input probe passes159 checks. At those pre-retention
offsets a real close X1→X2→X3 chain misses X2/X3; inside chains
hit all three in both directions, and outside chains miss. This is spatial
contact evidence, not human approval of that coverage or an authorized tuning
change. U-003 evidence is ready for supervisor review; C remains held/isolated.
Original input11 and Cast45 pass, with all eight ordinary reports exactly equal
to round5 after removing machine instance IDs. All637 runtime/project files
at that diagnostic hash-match round5; no production gameplay/asset changes in
round8. The later retained candidate above changes that coverage. Final clean runs and
intermediate shutdown caveats are recorded in the overnight ledger.

## Retained overnight Fire Cast anticipation candidate — 2026-10-19

Exact reviewed round-4 B data is promoted: cast_fire active_start/contact 0.24,
active_end/length 1.0, piecewise sprite retiming and unchanged geometry values.
No JSON, other-school, Fire X, Enemy, input/queue, damage or total-duration change.
Supervisor's actual OpenGL A/B capture passed 46 checks and produced 19 PNGs per
variant, exit 0/zero errors. Inspected frames support coherent earlier projectile
progression; eight ticks earlier launch comes from event/node metadata, not an
exhaustive first-visible-pixel claim. Human morning feel/controller acceptance
and final tuning remain pending.

Fresh isolated Godot 4.7.1 Windows source passes 45 focused Cast, 11 original
input, 595 attack-style, 152 Enemy timing and 67 Gym/tutorial lifecycle checks.
All eight ordinary-input reports exactly match reviewed B after removing only
machine instance IDs, preserving its spacing/Cast tradeoff: 19.40 s/HP60 versus
old A20.48 s/HP80. Current-source clean runs and the earlier known import/audio
shutdown caveats are recorded separately in the overnight ledger. Shared JSON/
mirror bytes/non-Fire assets were unchanged by that Fire pass. The rejected
0.8-contact/1.3-length recovery-tail comparison remains isolated; the later
retained1.1-contact/1.3-end package has no tail.

## Overnight U-002 initial AI snapshot candidate — 2026-10-19

The first runtime Enemy decision-setting edit could fail to cancel the pending
attack: configure cached the live enemy_ai dictionary by reference, erasing the
old values used for change detection. Configure now deep-copies that initial
snapshot, matching the existing later-apply path. The existing reset/cancel and
lifecycle guards are unchanged; no Enemy tuning or timing change is included.

Isolated Godot 4.7.1 Windows: pre-fix recovery fixture reproduced its sole
AI-disable failure (66/67); candidate passes 67/67. Expanded native timing suite
passes 152 checks, including first changes to all existing decision keys,
nonreset edits, and Gym/tutorial lifecycle cases. Original real-input suite
passes 11/11, with all eight full reports matching the retained ordinary-play
baseline after removing only machine instance IDs. All three candidate runs
exit 0 with no engine/resource errors. Snapshots, source digests and exact
commands are in the overnight iteration ledger. Supervisor's bounded U-002
implementation review is complete; human gameplay acceptance remains pending.

The isolated 1.3-second recovery-tail experiment was rejected for working-source
promotion after supervisor-rendered comparison. At that point stock was1.0;
the later retained1.1/1.3 telegraph package above is a distinct candidate.
That disposition applies to this candidate only. It is not a general decision
against recovery tails or human controller/game-feel acceptance.

## Overnight U-001 progress-query candidate — 2026-10-19

Supervisor accepted the demonstrated U-001 diagnostic fault for a narrow fix:
rejected X during hit reaction queried AnimationPlayer after cancellation had
stopped its native playback. Might now returns zero when no action owns progress
before reading native timing properties. Active and paused owned actions retain
their ratio; completion/cancellation retain their existing action-clearing and
queued-action paths. No combat eligibility, buffering, timing or damage changes.

On isolated Godot 4.7.1.stable.official.a13da4feb Windows x64, the unchanged
real-input harness passes 11 checks with zero engine errors; baseline emitted 66
invalid-animation errors. All eight scenario reports match baseline, including
action/contact frames and Enemy phases, excluding only machine instance IDs.
The focused attack-style suite passes 588 checks (six additional lifecycle checks)
with no engine/resource errors. The original baseline copy is preserved. Exact
source identity, snapshots and evidence paths are in
`iterations/2026-10-19-overnight.md`, round 1. Supervisor's bounded U-001
implementation review is complete;
human game-feel/controller acceptance and the baseline F5 UID issue remain open.

## Authored Enemy attack timing — 2026-10-19

User chose native animation timing after requesting removal of windup/recovery
settings. Gym Inspector exports and both Portal controls are removed. Enemy
plays melee_swing at authored speed 1, without Gym duration scaling or separate
windup/recovery timers. Windup ends at active_start, contact queries once, active
ends at active_end, and recovery plays any remaining clip length. The current
asset ends at active_end, so no extra recovery delay is introduced. Frame keys,
markers and hitboxes are unchanged; Player X/Cast pacing remains as before.

Behavior-tree phase tasks follow animation progress; the actor visits contact
before advancing beyond it so a large physics frame cannot skip or repeat the
connected hit. Existing qualifying hurt/cancellation stops playback and clears
the pending strike. Legacy JSON timing keys remain compatible but ignored and
cannot reset an attack. The user's earlier 1/1 override baseline is superseded
by their explicit choice of authored timing. The reusable Enemy is a candidate
for game use, with the Gym as its development space, not a completed ship target.

Validation: isolated Godot 4.6.3 stable official Linux x64 passed 22 authored
Enemy-timing, 74 native-authoring/grounding, 198 clash/reaction, 180 Portal/config
and 23 Gym-readout checks (497 total), with no engine errors or resource leaks.
Timing checks cover the actual Gym and its tree, stock and custom markers,
authored recovery playback, ignored legacy fields, once-only contact across a
large frame, interruption and stage deactivation. The same 22 timing checks also
pass with old 1/1 Gym overrides present in the isolated saved scene; they load
without restoring the removed controls or affecting playback. Native resources
remain unchanged by the checks. Interactive animation/gameplay acceptance
remains `AWAITING_USER_VALIDATION`.

## Enemy sprite transform / idle-foot grounding — 2026-10-19

The user reported sinking after the initial adjustment and requested comparison
with Player. Actual Gym runtime sampling reproduced the visual mismatch: Enemy
remained on_floor with its capsule bottom at Y 51.94, but feet at Y 72.94 below
the artwork surface Y 64. StageArea prepared Enemy before configure captured its
rest position, replacing authored Sprite Y -21 with zero. The previous synthetic-
floor test bypassed that initialization sequence and the actual floor artwork.

Enemy now captures its authored rest position with @onready, before StageArea
preparation. The capsule keeps radius 12.4, height 68.7 and X -11, with center Y
-3.35. Its bottom is local Y 31 and idle feet Y 43: the same 12-world-pixel
difference as Player. This accounts for the existing floor collision at Y 52 and
ground artwork at Y 64, superseding the initial Y 8.65/direct-foot alignment.
Player, floor scenes, sprite transforms, attack tracks and combat rules retain
their existing values. No runtime auto-alignment is added.

Validation: isolated Godot 4.6.3 stable official Linux x64 passed 74 native-
authoring/grounding and 198 receiver-side clash/reaction checks (272 total), with
no engine errors or resource leaks. The new checks use the actual Gym lifecycle,
floor collision and ground artwork, comparing both actors during walking,
windup, attack, hurt recovery and Retry within a 0.2 px collision margin. They
also preserve non-default sprite transforms. The same suite reports 17 failures
against the pre-fix source, including the reproduced sinking and pre-configure
reset. Interactive visual/gameplay acceptance remains `AWAITING_USER_VALIDATION`.

## Cast completion / melee follow-up correction — 2026-10-19

The native-animation migration changed Cast playback from `attack_clock` to
school-specific `cast_<primary_school>` clips, but Might's completion guard still
compared against the legacy JSON animation name. A completed Cast could leave
its current action and queued melee occupied. A later L2 release was rejected
as `pending_action_occupied` before consuming charged orbs, matching the user's
reported retained-orb/no-Cast symptom.

The completion guard now compares the signal with AnimationPlayer's assigned
animation, which retains the played clip name after completion. Existing pending
handoff, control release, empowered continuation and sixth-slot completion paths
then run normally. Cast eligibility, charge thresholds, damage, timing and
consumption rules are unchanged. The Fire/Earth artwork swap is preserved.

Validation: isolated Godot 4.6.3 stable official Linux x64 passed 582 attack-style
checks without engine errors or resource leaks. New cases drive real animation
completion, L2 action-strength transitions, normal/windowed/buffered Casts in all
four schools with a different primary-orb school, queued melee, sixth-slot Cast
completion, and repeated actual melee-contact/orb-generation/charging/release
cycles. The exact stale-queued-melee case retained charged orbs and logged
`pending_action_occupied` on the pre-fix source; the corrected source consumes
and launches the next Cast and releases control. Interactive controller/Gym
acceptance remains `AWAITING_USER_VALIDATION`.

## Fire / Earth benchmark flipbook swap — 2026-10-19

Fire X1–X5 now reference the former Earth sword sheets; Earth X1–X5 reference
the former Fire sheets. Matching sprite-region keys and their visual timing
swap with each sheet. All ten Animation identities, clock lengths, contact/
active markers and AttackCast tracks remain byte-for-byte unchanged. No runtime
code, JSON combat tuning or move-settings assets change. The Fire-only Gym now
shows the sword set while retaining its existing combat pace and geometry.
Water, Air, Cast, locomotion and Enemy assignments are preserved. The original
PNG filenames remain unchanged; native Animation references select the new art.
GDD, technical architecture and authoring instructions reflect the decision.

Validation: isolated Godot 4.6.3 stable official Linux x64 passed 458 attack-style
checks plus 6 native-editor checks (464 total), without engine errors or resource
leaks. The same checks passed after preserving the incoming `29e52ea` Godot
scene/resource save, including the user's collider edits. These verify the sprite source/frame counts/pacing for all school moves,
unchanged contact geometry, Cast pacing and existing style physics, then press
the actual Inspector button and seek Fire's assigned sword artwork. Static
comparison confirms unchanged marker/geometry blocks for all ten exchanged
clips and intact matching source frame tracks. Interactive weapon alignment,
contact-pose tuning and gameplay acceptance remain `AWAITING_USER_VALIDATION`.

## Native attack scrubbing and visual hitbox authoring — 2026-10-19

Implemented the approved native AnimationPlayer workflow. Each of the 20 move
settings assets links to its actual Animation resource, with an Inspector button
to open Player's matching timeline. Player X/Cast and Enemy melee sprite frames
are native tracks alongside keyed AttackCast position, target vector and radius.
The previous artwork and default frame pacing are preserved, including each
school's Cast pacing. The editor Portal's Attack styles category is reachable.

Saved animations own geometry; startup, the Inspector bridge and Portal read the
contact pose over legacy JSON mirrors. Portal saves update only changed contact-
size keys and preserve origin, angle, sprite tracks and other frames. Enemy AI
approach distance is now separate from contact reach/radius. Runtime actors own
private Animation copies, capture their attack pose before later tuning and
mirror horizontal coordinates with facing. The existing one-query contact rule,
damage, timing, reactions, Heat and Gym run-only persistence remain intact.
Native shape tracks are isolated per actor. JSON/animation hash watching refreshes
saved geometry; positive-radius validation and stale contact-draft checks precede
writes. Multi-file saves still report partial failures rather than being atomic.

Validation: isolated Godot 4.6.3 stable official Linux x64 passed 438 attack-style,
39 native-authoring persistence, 198 receiver-side clash/reaction, 180 Portal/
config/layout and 121 Gym checks (976 total), plus 6 headless native-editor checks
(982 total). These exercise native scene seeking and shared asset identity,
original sprite pacing, actual offset contacts facing both ways, committed poses,
Portal key preservation/conflicts, zero reach, saved-data reload despite caches,
Enemy range separation and unchanged saved assets after Gym previews/retries.
The editor checks edit the actual move resource, press its Inspector button,
verify the opened scene/selected clip/node and seek the flipbook using native
editor controls. No engine errors or resource leaks occurred in the final runs;
the expected Gym run-only warning remains intentional.

The reproducible isolated runner accepts `--script tools/tests/attack_authoring_test.gd`
and `--editor-test tools/tests/attack_authoring_editor_test.gd`. No source project
editor, interactive viewport handle/key/save session, controller playtest or Web
export was run. User validation of visual editing and gameplay remains pending:
`AWAITING_USER_VALIDATION`. Workflow: `docs/ATTACK_STYLES.md`.

## Move-resource FileSystem navigation — 2026-10-19

All 20 MoveStyleTuning entries now reference individual
`config/attack_styles/<move_id>.tres` files instead of embedded resources.
Their names, IDs, order and tuning values are preserved. In the Local Inspector,
right-click a move's resource name and choose **Show in FileSystem** to reveal
its settings file. Godot's native resource-picker source confirms this action
is available for external file paths; no custom context-menu UI was introduced.

Inspector saves persist external children and the parent mirror. Portal saves
continue committing validated JSON and now synchronize those external assets
without mutating the cached Inspector graph or implicitly applying to a game.
A mirror-save failure reports that JSON was already saved. Gym uses fully deep
private copies of external resources and keeps its run-only persistence guard.
Remote Gym copies do not have file paths; asset navigation uses Local resources.

Validation: isolated Godot 4.6.3 stable official Linux x64 passed 249 attack-style,
183 Portal/config/layout and 118 Gym encounter checks (550 total). These cover
all 20 paths and existing values, Inspector child-file persistence, independent
reloads, Portal JSON/file synchronization, unchanged cached views, private-copy
isolation and unchanged external-asset bytes after Gym use/retry. Final runners
completed without engine errors or resource leaks; the intentional run-only
Inspector warning remains covered. Interactive right-click navigation still
needs the user's editor check: `AWAITING_USER_VALIDATION`.

This earlier slice provided move-settings navigation only. Follow-up `ee49bcd`
connected Arena Settings to the external mirror; the user then confirmed locating
the asset. Native scrubbing/geometry authoring is the newer candidate above.

## Fire X and leveled Cast reactions — 2026-10-19

Implemented the approved progression: Fire X1–X5 have Impacts 10/20/30/40/50;
Cast Levels 1–4 have Impacts 10/20/30/40. Against the Gym opponent's 1 Poise
outside its active swing, these select reaction Levels 1–5 and 1–4 respectively.
Existing Poise and active-move resistance still apply. The visual-only damage
hook is removed: hurt animation, stagger and body knockback use the same
qualifying reaction and its captured lifetime. Damage, Charging, Heat, reaction
bands/duration/distance and other schools' X tuning are unchanged.

The optional `moves.cast.level_impacts` JSON table is validated and consumed
per resolved layer through the existing Magic/HealthEvent path. Older profiles
without it remain valid; levels without an override retain the base Cast Impact.
The table is authored in JSON, while the existing Inspector/Portal Cast Impact
control remains the fallback. Cast Levels 5–8 have no new progression assigned.
Mixed Cast layers still resolve before the strongest qualifying reaction begins.

Validation: isolated Godot 4.6.3 stable official Linux x64 checks passed: 198
receiver-side clash/reaction, 116 Gym encounter and 179 Portal/config/layout/Gym
checks (493 total). The reaction cases exercise real Fire X1–X5 native contacts
and ShapeCasts, committed normal/empowered Cast payloads at Levels 1–4, hurt
sprite/lifetime, cancellation, body displacement, invincibility, mixed layers,
non-qualifying damage, fallback levels and invalid configuration. Gym fixtures
reset reaction state between independent Cast damage cases. Final runners
completed without engine errors or resource leaks; the expected run-only
Inspector warning remains covered. Saved source configuration hashes were
preserved by the isolated runs. The incoming `3d7b0d2` art-only merge changes
no runtime files. Gameplay/visual acceptance and GDD verification remain pending:
`AWAITING_USER_VALIDATION` / `AWAITING_GDD_VERIFICATION`.

## Unified Combat Gym — 2026-10-19

The two development encounters are consolidated into `scenes/gym.tscn`, already
the project main scene and Run gym target. The separate benchmark scene, script,
area and guide are deleted; their behavior is folded into Gym and its guide.
Gym now has the slower Fire-only, killable-opponent encounter with genuine
victory/defeat and full-scene retry, plus the contact-time formula readout and F4
visibility controls. Charging and the smooth partial-progress bar are preserved.
This supersedes the earlier infinite-refill Gym behavior below. Tutorial behavior
and saved shared tuning remain separate. Retry preserves run visibility through
a one-shot transient value, while restoring combat state and the local profile.

Validation: isolated Godot 4.6.3 stable official Linux x64 checks passed: 116 Gym
encounter, 23 formula readout, 21 visibility and 179 Portal/config/layout/Gym
checks (339 total). Coverage includes native slower Player contact timing, Enemy
blackboard timing, unchanged Charging/Heat, smooth partial bar fill/depletion,
L2 binding, deleted entry point, victory/defeat/retry, readout rebind, F4 visibility
and unchanged shared configuration bytes. The run-only Inspector warning is
intentionally exercised. All final runners completed without engine errors or
resource-leak reports. Historical results below do not validate this consolidation.
Controller, visual and gameplay acceptance remain pending. The user confirmed
the earlier smooth charge-bar correction without an exact runtime revision or
engine-version record.

## Benchmark pacing and charged-orb progress — 2026-10-19

User-approved candidate, now used by the unified Gym: private configuration multiplies Player
Fire X windup/recovery and shared Cast animation duration by 1.5 at load. Fire X1
becomes 0.21 + 0.51 s before Heat. The earlier opponent scaling is superseded by
the authored-animation decision above. Charging and its Heat multiplier retain their current
rate. Shared saved tuning is unchanged, and retry derives a fresh scaled profile.

User correction: the shared HUD restores smooth partial charge/depletion between
completed-orb boundaries. It adds normalized partial progress to the charged
snapshot count, caps the result at available orbs (maximum eight), then divides
by eight. Three charged plus half of an available fourth orb show 3.5/8; Spell
Level stays at 3. Empty queues show zero, and banked capacity beyond available
orbs does not inflate the bar. Underlying charging mechanics are preserved.

Validation is limited to source/configuration/diff inspection. No new engine,
automated-test, controller or visual run is claimed. User comparison of the slower
encounter and bar after charge, depletion, Cast, expiration and hits remains pending.

## L2 Charging and Casting — 2026-10-19

User-approved control change: the shared Casting action binds the left controller
trigger (L2) in the tutorial, Gym and Fire benchmark. Holding L2 charges generated
orbs; release below the existing threshold attempts a Cast. Defence remains L1,
and the right-mouse Casting input and pressure thresholds are preserved. Tutorial
prompts, pressure telemetry, Portal tooltips and current control records use L2.

Source/diff inspection only; no engine or controller checks were run for this
remap. Earlier engine results do not validate the new physical binding. Restart
the scene and verify L2 charge/release Casting and the matching HUD in Godot.

## Four school melee styles — 2026-10-16

User-authorized candidate implements slow Earth/Broadsword, medium Fire/Spartan
Sandals, medium Water/War Spear and fast Air/Twin Daggers across X1–X5, using the
current animation mappings. The five global progression positions, optional
sixth Cast endpoint, school switching, Cast commitment and orb rules are retained.

Each X has tunable windup/post-contact duration, reach/radius, forward-body
distance/start/end phases and qualifying-reaction push-distance scale. Existing
Impact, Poise, reaction duration/bands, damage and Casting settings are preserved.
Inspector and both Dev Portal surfaces use the same JSON-backed settings.
The movement owner performs collision-aware body motion; cancellation clears it.
Initial numbers are provisional and require user playtesting.

Validation: 199 focused style/physics checks, 179 Portal/config/layout/Gym checks
and 59 clash checks passed in isolated Godot 4.7.2 copies (437 checks total).
The clash suite includes scaled winning counters, damage deduplication and deferred
mixed-hit reactions. Runtime-source hashes and the dirty HEAD basis are recorded
in output/diagnostics/attack-styles-2026-10-16.json. All listed runtime files match
the final isolated clash copy byte for byte. No interactive gameplay acceptance
or export validation is claimed.

## Unified developer overlay visibility — 2026-10-16

User correction: Developer Overlay Visible controls ordinary telemetry and the
Gym formula panel together. The duplicate formula switch/preference is removed.
F4 changes this same master preference in the Gym, including while paused/hidden.
The formula panel follows the HUD's visibility signal; gameplay HUD and combat
values are unaffected. Reset retains visibility and explicit saving persists it.
Legacy files normalize to one preference without startup writes; canonical values
win conflicts. Keyboard, capture retention, save/reopen and migration checks are
separate from interactive user validation.

## Gym combat formula display — 2026-10-16

Gym-only HUD shows live Player/Enemy melee Impact and Poise plus each receiver's
last contact-time subtraction, signed value, actual reaction level and result.
Snapshots survive attack cancellation; ignored invincible/defended events retain
the last calculated math and show a separate status. Exact 0/0 Player wins are
explicitly labeled. Reset clears/rebinds the panel, which remains click-through,
under modal UI and part of the normal developer-readout visibility group.
No combat rule or saved tuning change is selected by this display.

23 isolated engine checks cover captured terms, counter direction, move identity,
negative/zero outcomes, rejected-hit retention, live-versus-captured values, reset
subscriptions, pause layering, mouse filtering and layout bounds. The existing
Portal and clash suites are separate regression evidence; visual readability and
gameplay feel still require user review.

## Receiver-side clash formula — 2026-10-16

Implemented the accepted receiver-side calculation: incoming Attack Impact minus
receiver Poise minus receiver move Impact only during hit-capable active frames.
Attacker Poise supplies no outgoing bonus. The user selected connected-hit damage
without flinching when neither value is positive, with Player winning exactly
0/0 active clashes at configured Level 1. Other zero/negative values do not react.
Shared configuration, Portal controls, Inspector hints and runtime Attack Impact
validation now align with 0–100. Existing saved tuning and reaction ranges were
preserved. Focused isolated engine checks and the Portal regression suite are
separate from user-verified gameplay feel or visual/controller validation.
Validation: 53 focused clash checks and 178 existing Portal/config/gym checks passed
in isolated Godot 4.7.2 copies. No interactive user playtest is claimed.

## Configurable hit-reaction levels — 2026-10-15

User-approved configuration change: a dedicated Hit-reaction levels page exposes
starting value, duration and distance per level. Upper bounds follow the next
start; starts must increase, Level 1 stays at 0 and Level 5 is open-ended. Shared
JSON, runtime selection, Inspector view, tooltips and series fill use these ranges.
The previous default bands and existing duration/distance tuning are preserved.
Legacy reactions move to their own page. That configuration change preserved
reaction eligibility; the later October 16 implementation above completes the
receiver-side formula and records its explicit non-positive/tie decision.

## Collapsible reactions and Impact configuration — 2026-10-15

User-requested UI refinement: one Levels 1–5 foldout opens all five reaction
Duration/Distance pairs under plain headings; individual level collapsing is removed.
Legacy controls and Impact school groups retain foldouts with compact summaries.
These groups are collapsed by default, with Expand/Collapse all and
retained expansion state across page refreshes. Combat → Impact exposes each
school’s X1–X5, with Cast and Enemy attack separate. The shared series dialog can
fill one school’s X sequence using existing move-record paths. Editor and runtime
Portal controls share the same metadata; no saved values or combat rules are
changed by this refinement. Isolated Godot checks cover foldouts, navigation,
individual X edits, scoped integer series fill and JSON save round trips.
Visual usability remains for the user to confirm.

## Start-button pause HUD — 2026-10-15

Candidate: shared runtime pause-menu scene with controller Start / keyboard Esc,
Resume and Restart encounter. The HUD processes input while the gameplay tree
is paused, focuses Resume on opening and supports native controller navigation.
Restart uses the existing active-stage reload and is unavailable during a
transition. Runtime Dev Portal and pause menu replace each other; editor pause
commands use the same visible HUD. Configuration/tuning is not written by these
actions. Synthetic engine input, frozen-body, focus/navigation, modal handoff and
restart checks are separate from physical-controller and visual user validation.

## Development gym — 2026-10-15

Candidate: standalone `scenes/gym.tscn`, a one-enemy Gym StageArea, and a small
runtime-only encounter override that reuses the existing Arena stack. The Player
and current Final Enemy start 160 pixels apart, with no practice targets. Saved
tutorial selection, the main scene and shared tuning are preserved. Laema Dev
Portal's bottom action area provides Run gym from every page; its in-game stage selector reloads the
single encounter. The user subsequently requested unlimited gym-enemy health:
the gym enables refill-at-zero, and CombatEnemy only enters its death path for
non-refilling actors. Gym hits still produce normal damage/reactions; zero Health
refills the same actor without defeat or AI shutdown. Normal Final Enemy death
is preserved. The gym objective text describes combat practice instead of defeat.

Required user validation: launch, visual framing, preferred starting gap and
ordinary combat interaction. Isolated engine checks cover actor composition,
spawn placement, startup without config writes, enabled Enemy approach and gym
reload. These do not establish user-verified game feel or broader combat coverage.

## Focus editor Godot plugin — 2026-10-15

User-approved implementation candidate: a native Dev Portal dock, enabled in
project.godot, with all existing Portal controls backed by the shared JSON,
catalogue and native field renderer. Draft/review/save/revert/reload work without
running the game. Explicit live apply and session actions use Godot's debugger.
JSON is authoritative; the combat Inspector Resource is a view. Saves validate
and merge independent file edits, reject conflicts and replace the file through
a temporary sibling. Hitbox visibility is saved with its prior enabled default.

Godot 4.7.2 isolated editor import and headless checks cover shared field
construction, offline dock persistence, concurrent-edit protection, invalid-save
preservation, runtime application and in-game Portal save/pause behavior. These
agent-run checks do not establish user-reported gameplay validation. Final
visual inspection, interactive editor-to-game debugger commands and ordinary
play remain awaiting user validation. No Web export, commit or publication is
part of this implementation request.

The subsequent user-requested navigation refinement separates the dock into six
sections with a second-level category tab row directly below the main sections.
The category row scrolls horizontally in narrow docks, remembers each section's last page and
preserves drafts across navigation. School categories no longer carry legacy
labels. The shared field renderer marks individual school-effect controls unused
by current Casting while leaving active attack-presentation controls unmarked.

The dock is renamed Laema Dev Portal. Hit reactions includes a previewed
start-plus-increment fill for Duration and/or Distance across Levels 1–5. It
infers initial rules from the first two levels, rejects invalid generated values
and stale previews, and only changes the editor draft until explicitly saved.
The shared series tool also discovers Water/Earth numeric level columns from the
catalogue. It preserves fixed Water slow amounts and status names, enforces slow
ratios within 0–1 and keeps unrelated columns/settings unchanged.

Series dialog layout correction: table labels no longer use paragraph wrapping;
columns retain readable widths inside a bounded scrolling form, with Fill/Cancel
outside the scroll area. Headless layout checks measure single-line cells and
compact table height at normal and narrow editor-window sizes. This does not
replace visual confirmation in the user's editor theme and display scale.

Status: `IMPLEMENTED_AWAITING_USER_VALIDATION`.

Historical gameplay recovery baseline: `6b06dc2` (`checkpoint: save cross-thread recovery state`). It commits the Stage 1–6 sequence-objective candidate and recovery records. Later combined Stage 7, Final Enemy, Elemental Endurance, minimum-Health, feedback, and presentation candidates are preserved by subsequent checkpoint history. The current LimboAI candidate is captured separately below; recovery publication does not establish runtime validation.

## Current implementation candidate

### Inspector / Portal combat tuning — 2026-10-14

The candidate adds config/combat_tuning.tres, typed per-move Impact and per-level combat-reaction Resources, and an Arena-owned tool bridge. Inspector and Portal edit Player/Final Enemy poise, all 22 move Impacts, five combat reaction duration/distance pairs and separate legacy reaction values. Inspector edits persist JSON and its Resource view; runtime edits persist through Save Tuning. The 2026-10-15 Focus editor integration supersedes timestamp selection: JSON supplies startup values and the Resource is an Inspector view.

The actual combat-reaction consumer now reads the validated five-level JSON mirror instead of hardcoded durations/distances. Reaction-only tuning preserves an active reaction's captured lifetime; AI decision-tuning changes retain their reset path. Native Resource registration, editor synchronization and runtime round trips remain awaiting user validation.

### Qualifying hit reactions — 2026-10-14

The candidate adds animation active_start/contact/active_end markers, individual move Impact records and poise tuning; ordinary-hit and active-overlap clash judgment; full losing-attack cancellation; a preempted LimboAI reaction branch; collision-aware whole-body knockback; and combat-only invincibility. Mixed Cast layers resolve before their single reaction starts. Failed-Cast self-reactions remain vulnerable.

Player and Final Enemy use the new reaction contract. Practice targets retain stationary visual recoil, finite Health/refill, non-attacking and pass-through behavior. Existing dirty imports, task UID files, decisions and output artifacts are preserved.

The user authorized provisional active_end markers at swing completion and will tune them in Godot. Poise/Impact carry over as provisional 0/1. Forward-lunge fields remain null and untuned; no lunge implementation is claimed. Spell-vs-melee clash and additional school/status interactions remain deferred.

Static grammar, data/resource and whitespace checks are recorded in the execution handoff. No new Godot runtime, editor, build, automated test or export has been run. Runtime correctness and engine type/resource loading remain awaiting user validation.


### LimboAI conversion — 2026-10-12

The user approved a behavior-preserving conversion of the active Final Enemy to LimboAI after exploring the separate official demo. The conversion candidate was introduced against `23ccc29b6436776a729d071cf4a73038af5b52e6` and is recorded by `docs/checkpoints/2026-10-12-game-feel-limboai/manifest.json`. It includes the pinned official LimboAI 1.8.1 GDExtension, one manually ticked BTPlayer, `ai/trees/final_enemy.tres`, six Enemy tasks, task discovery settings, and Web extension support. The tree owns awareness/approach/windup/strike/recovery decisions and timers; Enemy retains collision, movement, committed strike geometry, damage, and visual presentation. Existing Portal configuration supplies blackboard timing/range/damage values.

Only source/dependency/static checks have been performed. This conversion has no user-reported Godot comparison or agent-run editor/runtime/build/test evidence. The existing historical tuning waivers do not cover it. User validation must confirm extension loading, tree editor/debugger access, normal attack cadence, committed hit/miss geometry, hurt non-interruption, AI enable/disable, tuning resets, death, and stage unload/reload. Web export remains unverified.

### Earlier feature and validation record

The user reported the complete Stage 1–6 flow run and confirmed in Godot on 2026-09-01. The report was broad: no exact scenario matrix, tested-tree identity, or engine-version record was supplied. The user later reported validating the small DoT floating-damage feedback. On 2026-09-05, the user also followed targeted checks and reported that the Final Enemy's body blocking works while the three restored practice targets remain pass-through, that leaving the committed attack area during windup produces a miss without retargeting, and that hitting the Enemy during windup does not interrupt its committed attack. The user then explicitly waived the remaining targeted verification passes for the current tuning phase. After the Stage 7/8 merge, the user broadly reported the combined Stage 7 implementation verified; no scenario matrix was supplied. Those waivers and broad reports do not establish untested scenario details. No agent-run Godot, build, compiler, or automated-test evidence exists.

- Combat is composed as a thin `CombatComponent` facade with `MightComponent`, `MagicComponent`, the existing Heat implementation, and Defence beneath it. Might owns action timing, chains, movement locks, and the shared X/Cast buffer; Magic owns the queue, pressure charging/depletion, immediate frozen Cast commitments, generic Cast execution, and charged-only qualifying Player-hit removal.
- Successful normal and endpoint Cast completion now preserves every unconsumed FIFO queue entry.
- Incoming `APPLIED` direct damage now routes one five-point Heat loss and charged-orb removal through Combat; `BLOCKED`, `PARRIED`, and DoT results cause neither resource loss, regardless of reaction strength.
- Shared `FeedbackComponent` owns target-local Cast-level, direct-damage, and smaller DoT-damage feedback. Every displayed amount is the final `HealthResult.health_delta`; fully resisted Cast layers display `0` without a school/level label, and applied DoT ticks display a smaller final-loss number including `0`.
- Public immutable combat and encounter outcomes feed the Arena-owned StageDirector and stage-specific evaluators.
- Stage 1–6 use the declarative sequence evaluator; combined Stage 7 uses the Heat-gated sequence evaluator with independent Heat and chain presentation rows.
- Stages 1–7 use independently instantiated shared training-area content with one stationary, non-attacking, refillable dummy per stage.
- Player-facing terminology distinguishes Generating/generated orbs from Charging/charged orbs; private `marked` identifiers remain implementation details. The HUD now uses generated-orb and Charging/charged wording.
- Tutorial-only Elemental Endurance is implemented for Final Enemy: StatusController owns the streak/multiplier, Might propagates source-action identity through X and Cast, HealthResolver applies the multiplier and full-resist tag before Health, and final feedback reflects post-modifier loss. At full resistance, new effects and orb generation are suppressed while direct Impact, hit reaction, and Heat refresh remain available.
- Player-wide minimum Health is implemented in HealthComponent. The default-enabled, Portal-backed `player.one_hp_floor_enabled` option applies a minimum of `1` only to future damage and never heals on toggle.
- Final Arena contains three permanent refillable pass-through practice targets plus one solid, killable Final Enemy. Its current candidate uses LimboAI's visible approach/committed-windup/strike/recovery sequence with frozen attack geometry, equal hit/miss recovery, ordinary-hit non-interruption, and live AI enable/disable behavior; the new representation awaits comparison in Godot.
- The persistent Arena root owns Player, HUD, audio, projectiles, camera, StageDirector, and the current-plus-next Stage Area lifecycle.
- Final-enemy defeat completes the tutorial and changes the loaded Final Arena into indefinite free practice.

The current prototype source includes:

- a Godot entry scene with runtime InputMap bindings for controller, keyboard, and mouse input;
- fail-fast JSON tuning configuration with validated live-edit rollback and persisted Developer Portal changes;
- shared Entity, HealthEvent/HealthResult, HealthResolver, Health, Buff/Debuff, and HitReaction components;
- composed movement, Combat/defence FSMs, five-position InputCombo chaining, and Heat components;
- AnimationPlayer-based attack timing and ShapeCast2D contact queries;
- twenty active school/position X sheets covering X1–X5 for Fire, Water, Air, and Earth, with shared locomotion and Cast presentation;
- functional Fire, Water, Air, and Earth X/casting specialties and their current status/effect pipelines;
- a ten-slot FIFO elemental-orb queue with front lifetime, right-to-left circular lifetime presentation, eight-level Charging capacity, continuous charging progress, consumption, transfer, and fixed-rate depletion;
- L2 95–100% CHARGING, 5–95% fixed-rate DEPLETING, and below-5% RELEASE semantics with transition-based Cast-on-release behavior;
- one normalized pre-window buffer shared by X and release-Cast requests, with earliest-request arbitration and event-level debug traces;
- Stage 1–7 refill targets plus the extracted Final Arena's three permanent pass-through practice targets and distinct solid, killable Final Enemy;
- Fire parry and Water block state scaffolding with guard-warning feedback, a shared CC0 hit-reaction cue, and a fixed-volume eight-step charged-orb pitch cue delivered through Player's local presentation FIFO;
- an always-visible gameplay HUD with all ten orb slots, Spell Level `0..8` derived from visible charged entries, separate banked charging progress, reusable ObjectiveWidget, and a paused Developer Portal with General, Audio, and nested Combat tabs, visible toggles, tooltips, pause/unpause, and Save to JSON;
- Stage 3 presentation instructing `Hold L2 + X -> X -> X -> X -> X -> Release L2`, plus matching Hold/Release guidance for the Stage 4 and Stage 5 Cast steps, through compact objective tokens while retaining the existing evaluator rules;
- reusable Stage Area scenes, descriptor-owned display names and generic presentation rows, StageDirector lifecycle, Stage 1–7 evaluators plus final-enemy evaluator, transition camera flow, stage reset, and final free-practice presentation;
- Ambient, SFX, and BGM bus routing with persisted enabled and volume controls; and
- the approved prototype asset and audio subsets.

At synchronization time, the working tree contains later shared-training-area and debug-navigation consolidation. It was preserved untouched by this document synchronization. The exact tested-tree identity was not supplied.

The user explicitly waived the following remaining validation checks for the current tuning phase. They remain outside the validation boundary or intentionally open:

- eight-level Charging capacity, ten-slot storage coexistence, Spell Level/progress presentation, generic Levels 6–8 feedback, ordered charged-orb cue delivery, reset/teardown cue clearing, and eight-orb once-only Heat commitment;
- Elemental Endurance streak counting, partial/zero resistance, DoT resistance, orb suppression, Heat refresh, Endurance badge, and final direct-damage feedback;
- Final Enemy hit/miss recovery parity and live AI enable/disable;
- both states of the Player 1-HP Floor option and Player defeat behavior with the option disabled;
- ordinary-play validation of Water block, Fire parry, guard depletion, guard warning, guard break, and charged-orb loss on Player hit;
- scenario-level results for each Stage 1–7 objective and transition, because the user supplied only a broad earlier report;
- Air and Earth defence;
- school-specific idle/walk locomotion switching; the current prototype uses the shared locomotion shell;
- final character, projectile, UI, level, and audio presentation;
- final numerical tuning and experiential success criteria; and
- complete enemy content and final level geometry.
