# Overnight Fire Gym iteration — October 19–20, 2026

Status: FINAL HANDOFF / OVERNIGHT_EXECUTION_ENDED. Worker finish/stop stamp 2026-10-20 05:54:10 HKT; supervisor heartbeat PAUSED05:53 confirmed. Parent play runs stopped02:56; worker jobs ended, user editor preserved open. H637/47 paths/source identity frozen; all failures and human/controller/submission limits remain open. No autonomous next work.

## Authority, scope and timing

- Approved goal: deliberate Fire duel; reliable melee contact/rhythm, Charging during attacks, release-to-Cast and melee return; readable Enemy commitment, stable spacing and useful recovery/punish opportunities.
- Allowed components: existing Enemy actor and LimboAI tasks/tree; Fire/Enemy animation resources; Gym tuning/profile; existing feedback. Might/Magic only for demonstrated input/action-completion faults. Focused tests, iteration records, candidate documentation and Combat metadata are authorized.
- Preserve existing generation/queue/Charging/Cast/parry/clash/reaction/eligibility/buffering rules, slower Gym direction, authored Enemy speed 1 and committed nontracking once-only contact. No new attacks, mechanics or AI framework. No commit, push, PR, publication or checkpoint save/load.
- Supervisor may accept/reject provisional experiments and issue in-scope corrections without another per-file gate. Each later round snapshots only its scoped files before edits, tests one hypothesis and stops for review. No autonomous next round or messages to other chats.
- Hard deadlines, Hong Kong October 20: gameplay edits/new experiments stop 05:30; verification/documentation stop 05:50; owned sessions/all work stop by 06:00 (2026-10-19T22:00:00Z). No operation starts at/after cutoff. Baseline assignment budget: 25 minutes.

## Identity and baseline

- Worker: independent task `overnight_melee_cast_ai_2026_10_19`, Combat; thread `01a15464-d6c5-77e2-ac72-725e5c9a1b26`, host local, project `11e255e1-541c-4ba4-bd15-c0e78716c51d`, verified from current host listing. Requested model: GPT-6.1 Sol Medium.
- Supervisor: `01a1545c-4c06-7690-b81a-3822d7fc6a0e`; no desktop/keyboard/mouse control by worker.
- Starting source: clean `main` at `644587bc9e570aed5d7c78cc00f8f81a6defff67`, checked 2026-10-19 21:41 HKT. Native engine supplied: Godot 4.7.1.stable.official.a13da4feb Windows x64.
- Before-edit round-0 file scope: this new record; `docs/departments/task-departments.json`; `docs/departments/combat.md`; new `tools/tests/overnight_gym_input_test.gd`. Gameplay/config/assets remain baseline.
- Read current AGENTS, README, GDD, technical architecture, implementation status, GYM, ATTACK_STYLES, Combat record and DUM-E game-feel/AI references. Latest L2 controls supersede historical R2. Older unified-Gym technical/Combat paragraphs still mention Enemy 1.5× scaling; current authored-timing sections and actual code supersede them. No silent canonical rewrite in baseline round.

## Round ledger

| Round | Hypothesis / scope | Evidence | Disposition |
| --- | --- | --- | --- |
| 0 | Establish unchanged Gym input/physics and Enemy cadence | 11 input assertions passed; 8 observed scenarios; existing 120/121 Gym, 22/22 timing, 582/582 style checks | READY_FOR_SUPERVISOR_REVIEW; launch-setting failure and diagnostic errors retained |
| 1 | U-001: avoid native timing reads after cancelled action | 11 input checks; all eight reports/frame timings identical apart from instance IDs; errors 66→0; 588 style checks with no engine/resource errors | READY_FOR_SUPERVISOR_REVIEW; no gameplay/rule/timing change |
| 2 | Isolated Enemy length 1.0 versus 1.3, unchanged contact/active markers | Both original 11 checks pass; focused A 66/67, B 74/75, same pre-existing first-apply AI-disable failure; exact 18-tick recovery in B | READY_FOR_SUPERVISOR_REVIEW; working Enemy resource unchanged; graphical fixture prepared, captures pending supervisor |
| 3 | U-002 initial AI settings snapshot owns prior values | Before 66/67 recovery; after 67/67, 152 timing/config/lifecycle, 11 original input; full ordinary-play reports identical except IDs; zero engine/resource errors | READY_FOR_SUPERVISOR_REVIEW; one-line Enemy cache fix, stock timing retained |
| 4 | Isolated Fire Cast contact/anticipation 0.36 versus 0.24, total duration retained | A/B each 45 focused +11 original checks; matched levels launch 8 ticks earlier, same commitment/end/follow-up; spacing policy faster with lower remaining Health | READY_FOR_SUPERVISOR_REVIEW; working Fire asset unchanged; GPU capture prepared, supervisor run pending |
| 5 | Promote exact supervisor-reviewed Fire B and synchronize/regress | 45 Cast, 11 original input, 595 styles, 152 Enemy, 67 lifecycle pass; full input reports match reviewed B | READY_FOR_SUPERVISOR_REVIEW; retained overnight candidate; human/controller acceptance pending |
| 6 | Isolated Gym Poise1 versus10, unchanged formula/clocks | 50 focused A/B checks; original A11/B10 of11; default pressure Cast interrupted in B; prepared parry/retreat cycle viable; Enemy152 A/B pass | READY_FOR_SUPERVISOR_REVIEW; recommend reject promotion for now; working Poise1 unchanged |
| 7 | Fixed Poise10: contact0.8/end1.0 B versus contact1.1/end1.3 C | A66/B69/C69 choice checks, no errors; C20-tick READY margin and no-parry disengage/Cast route; exact original policies still lose in C | READY_FOR_SUPERVISOR_REVIEW; recommend provisional C after rendered review; working production unchanged |
| 8 | U-003 distinguish invalid contact fixture from real spatial misses | 14 failures reproduced; test gap64 restores198 checks,244 with negatives; native/input probe159; original11/Cast45 unchanged; overreach mutant caught | READY_FOR_SUPERVISOR_REVIEW; no production changes; C stays held |
| 9 | Isolated X2/X3 centers43/42→40, same radius/markers | A501/D505/E505 probes; close chains1→3 applied hits, explicit outer loss; A/D ordinary reports identical; E melee still loses | READY_FOR_SUPERVISOR_REVIEW; recommend provisional D after rendered review; no promotion |
| 10 | Promote exact reviewed D; retain meaningful inside/outside coverage | Clash270, contact164, close508, input11, Cast45, styles595, Enemy152, lifecycle67 pass; complete outputs match reviewed D | READY_FOR_SUPERVISOR_REVIEW; retained OVERNIGHT CANDIDATE; human/controller acceptance pending |
| 11 | Complete ordinary A/E duels, legal parry/spacing policies and sensitivity | Both parry routes win all starts; E spacing wins default/mirror HP90, wall loses; A spacing wins HP50, wall loses; ±3-tick/gap130–145 first exchanges complete | READY_FOR_SUPERVISOR_REVIEW; recommend provisional E after full renderer review; no promotion |
| 12 | Promote exact reviewed E; semantic stock/fixture regressions | Enemy153/clash287/input11/Cast45/lifecycle67/authoring74/styles595/contact164/close508 pass; Gym120/121 knownF5; complete duel/reset/sensitivity reports exactly match E | READY_FOR_SUPERVISOR_REVIEW; retained OVERNIGHT CANDIDATE; human acceptance pending |
| 13 | Isolated damage/DoT anchors F−174/−146, conservative G−198/−166 | A/F/G110 focused+45Cast each; F new Player DoT/Cast overlap; G preserves pairs but fresh Player still touches header; actual combat unchanged | READY_FOR_SUPERVISOR_REVIEW; reject F as-is, hold G pending actual-render review; working component unchanged |
| 14 | Promote exact reviewed H offsets−186/−154 | Fresh feedback110/Cast45/entity-readout23 pass; runtime equals H; only component differs vs round12; combat records equal | READY_FOR_SUPERVISOR_REVIEW; provisional candidate, human acceptance pending |
| 15 | Validation only: independent process/physics observation at30/60/120 | Headless each73; supervisor GPU30/120 each92,19PNGs, failures[]/zero diagnostics; both facings generate6/6 and release3/3; E interruption, pause and Retry pass | Bounded implementation review COMPLETE; production unchanged; controlled rates do not establish real-time jitter/controller/feel acceptance |
| 16 | Diagnose first-iteration exit vs import-complete exit on cold baseline/H |12 cold runs exit0 with same UID error,538 byte-equal artifacts/205 present remaps;4 warm retries clean; no crash/timeout | READY_FOR_SUPERVISOR_REVIEW; race hypothesis not demonstrated; runner/production unchanged; prior0xC0000005 unresolved |
| 17 | Full-duel per-action timing variation, fixed predeclared11 fights | Controls/6 small-jitter/2 wider fights all win HP100;10 runs87/0, first87/1 false assertion preserved; supervisor actual GPU95/0,4PNGs | Bounded implementation review COMPLETE; finite machine-policy tolerance only; no production change, no human acceptance |
| 18 | Isolated Gym feedback duration A2.0s/B1.2s only | Each153+110 headless; A D3D12 GPU174/24PNGs; B D3D12 startup0xC0000374/no report; separate B GL174/24PNGs | B rejected for this night's promotion; hold evidence, retain H2.0s; startup failure unexplained, no human/balance clearance |
| 19 | Integrated frozen-source review and morning handoff draft |637-file H unchanged;8 production paths;35-path historical snapshot→47 after12 generated UIDs; limited current-H native F6/defeat/Retry; no suite reruns|Supervisor-reviewed/frozen; play runs stopped02:56/editor open; scheduled05:50 worker stop/heartbeat disabling pending; human acceptance open |

## Baseline limitations

- Tests/simulation do not establish human controller/game-feel, readability or balance acceptance.
- Initial runner attempts using default Windows sandbox temporary directories failed before copy creation with PermissionError. Retried under this task's writable visualization directory.
- First isolated imports reported unrecognized saved main-scene UID. Existing combat suites: Gym 120/121, Enemy authored timing 22/22, attack styles 582/582. Runner overall failed because of import error; Gym's failed check is F5 launching Gym. The saved main-scene UID `botreihvj2l3f` belongs to `scenes/prototype_arena.tscn`; `gym.tscn` has no UID. Supervisor independently observed F5 open tutorial Stage 8. This is a real launch-setting mismatch, outside baseline edit scope; use explicit Gym scene for replay.

## Round 0 retained evidence

Source identity: all 637 runtime/project files copied by the runner match the unchanged working source byte-for-byte. The runner excludes two tracked tilde-prefixed LimboAI backup/temporary DLL files, as designed. Sorted path/SHA-256 manifest digest: `1bc3fc906fdbade7c83084dd60814c3130d7033557fb9ad125187c3fa9b8dfe8`. Final input-test SHA-256: `1a2a0635a633803e2e978a34372de9b0124e4db50ae0a7a3e9b5110946d6a255`. Baseline HEAD remains `644587b`; administrative/test additions are uncommitted.

Retained isolated folders live under this worker's task visualization directory (thread ID above):

| Folder | Purpose and logs |
| --- | --- |
| `laema-dev-portal-4i9s7r02` | Playable baseline at `project/`; Gym `check-0.log`, `check-1.log`, warm logs; final `overnight-output-final.log`, `overnight-engine-final.log`, `baseline-identity.json`, `project/overnight-input-report.json` |
| `laema-dev-portal-fnxd84bl` | Enemy authored timing import/runtime and warm logs |
| `laema-dev-portal-v2rlb_ym` | Attack-style import/runtime and warm logs |

Commands: initial copies use `python tools/test-dev-portal.py --godot <provided-engine> --script tools/tests/<suite>.gd --keep-work --work-root <task-evidence-root>` for `gym_encounter_test`, `enemy_animation_test`, `attack_style_test`. Each initial runner invoked isolated engine `--headless --path <project> --editor --quit`, then `--headless --path <project> --script res://dev_portal_test.gd --quit-after 600`, with isolated `--log-file` paths and APPDATA/LOCALAPPDATA. Warm reruns execute that runtime command again after UID import. Warm results: Gym exits 1 with the same sole launch assertion failure; timing exits 0 with 22 passes but reports six resources still in use at shutdown; attack styles exits 0, 582 passes without errors.

Final input harness: copy the new test into the retained Gym project, then run its isolated engine with `--headless --audio-driver Dummy --path <project> --script res://overnight_gym_input_test.gd --fixed-fps 60 --quit-after 12000 --log-file <work>/overnight-engine-final.log`, with APPDATA/LOCALAPPDATA pointing to that work folder's `profile/`. Python subprocess timeout: 120 seconds. Actual native engine banner confirms 4.7.1.stable.official.a13da4feb. Fixed simulation step is 60 Hz; elapsed simulated time is physics frames / 60, not wall time. No OS audio settings were changed.

The final harness reports 11/11 assertions and exits 0, but is **not error-clean**: 66 existing `AnimationPlayer has no current animation` errors occur when the spacing policy presses X during hit reaction. Backtrace: `Might.get_normalized_attack_progress` line 300 reads `current_animation_length` after animation stop; rejected-input tracing calls it from `try_light_attack`. Gameplay still returns from the reaction. This is a demonstrated diagnostic-query fault, not evidence that input eligibility should change. Initial harness reads of stopped Enemy animation position were corrected in the test only; superseded logs remain separately named. Final shutdown has no resource-leak report after allowing Dummy audio stopped playback handles 100 ms to release; earlier accelerated runs contain audio-resource leaks and are not represented as clean.

## Measured input / physics observations

Scenario setup instantiates the actual Gym; focused cases optionally move only initial Enemy X. No combat methods, damage events, animation advances, charge methods or physics methods are called directly. D/Enter use bound keyboard events, X/L1 use bound joypad buttons, and L2 uses trigger-axis events through `Input.parse_input_event`. The engine owns normal processing, collision, attacks, reactions and lifecycle. Three comparison policies start at the normal spawn positions and stop at victory/defeat or 30 simulated seconds. Policies read telemetry; they are neither optimal-player simulations nor physical-controller evidence.

- Movement: ten D-held physics ticks move Player 50 px at the existing 300 px/s speed.
- Close setup, gap 56 px: X starts frame 4; real hit generates at frame 17, held L2 charges at frame 34; release at frame 37 commits frame 38, one physics tick later. Cast starts frame 48 after the preceding melee finishes; projectile launches frame 74. This separates input acceptance from existing queued-action and Cast anticipation delays. Cast finishes frame 120 and buffered melee starts that frame, contacts frame 132, finishes frame 159. End: Player 100, Enemy 167, one generated orb; current/pending actions empty. No stale handoff reproduced.
- Close stationary Enemy: contact frame 49, IDLE frame 61, next WINDUP frame 62. No sampled sustained RECOVERY. Authored contact 0.8, active end/length 1.0; one idle tick separates attack cycles when already in range. Ten natural 10-damage hits produce defeat by frame 656 (10.93 s); observation continues to frame 2403. Enter through normal UI input reloads Player 100 / Enemy 200, empty resources and no result modal.
- Retreat after commitment: real A movement opens gap from 60 to 210 px before first contact. Player remains 100; committed origin and facing stay captured through active contact; no homing strike or duplicate damage observed.
- Timed L1: actual Enemy contact resolves PARRIED at frame 49, Player stays 100; subsequent X lands for 10 damage, creates one orb and interrupts the following windup. No parry cancel/reward was added.

| Policy, one deterministic run | Victory time | Player Health | Enemy / interactions |
| --- | ---: | ---: | --- |
| Melee-first | 1150 frames / 19.17 s | 100 | 20 landed X contacts; 4 Enemy contacts lose active clash; no Cast/parry |
| Parry then single X punish | 1639 frames / 27.32 s | 100 | 20 parries, 20 X contacts |
| One-orb Charging/Cast plus attempted spacing | 1229 frames / 20.48 s | 80 | 10 launched Casts, 11 X contact outcomes; 2 Enemy contacts applied, 2 lost clash |

No Enemy approach direction reversal was sampled in any scenario. This does not rule out oscillation under unsampled movement, crossing or wall conditions. Melee-first is strongest in these limited policies; it does not establish universal dominance. Long invincibility/reaction/collision semantics remain intact. No native desktop or keyboard/mouse control was performed by this worker; no rendered frames were captured headlessly. Supervisor separately reported native F6 Gym launch, idle defeat/Retry reset and a 10-damage X1/one-orb/Level-1 contact; controller timing and visual feel remain unaccepted.

## Prioritized next-round hypotheses (not authorized changes by this record)

1. **Diagnostic query on rejected X:** guard progress queries when no animation is assigned/playing, using existing ownership. Acceptance: the same real-input script retains all 11 assertions and combat outcomes while the 66 invalid-animation reads disappear; focused attack-style completion coverage still passes. No eligibility, buffering or reaction change. This is the smallest demonstrated fault.
2. **Absent Enemy recovery presentation:** an authored tail after active_end could make the end of a miss/hit legible. A bounded comparison could extend only Enemy clip length from 1.0 to 1.3 s while preserving markers/contact/geometry/speed. Acceptance: measured 0.3 s RECOVERY for hit and miss, no early next windup, once-only committed contact and interruption preserved; supervisor native comparison then human morning feel judgment. Risk: additional vulnerability may make already-effective melee-first still easier; absence of a tail alone is not proof of an unpunishable enemy. The current following windup already permits punishment.
3. **Melee/Cast versus simple-X effectiveness:** investigate one observed contact/clash interval before any timing adjustment. Acceptance for a later candidate must preserve existing impact/poise/reaction rules and show a measured pacing/readability improvement rather than require Casting to win. No evidence supports a new AI framework, attack or core mechanic; no handoff retune is presently justified.

The launch UID mismatch remains separately deferred. No open gameplay decisions were promoted to accepted rules. All owned engine processes completed; retained copies/logs remain available for supervisor replay. Stop here and await the next bounded assignment.

## Round 1 — U-001 narrow progress query

Supervisor independently replayed round 0 and confirmed 11 assertions, eight
matching scalar reports and 66 errors (`supervisor-baseline-output-confirmed.log`
and `supervisor-baseline-engine-confirmed.log` in the original baseline folder).
Under the user's one-night disposition authority, supervisor established U-001
as Minor, accepted it for narrow correction and returned from Ultron tech-postflight
to DUM-E. This records implementation evidence, not human feel acceptance.

Round began October 19 21:52:42 HKT. Before editing, all seven approved paths
were copied byte-for-byte into task evidence `round-1-before/`, preserving prior
round work. `manifest.json` holds each pre-edit SHA-256. Actual edits:
`scripts/combat/might_component.gd`, `tools/tests/attack_style_test.gd`, this
ledger, `docs/IMPLEMENTATION_STATUS.md`, `docs/TECH_ARCHITECTURE.md`,
`docs/departments/combat.md`. The overnight input harness was not modified;
task assignment metadata remains the retained round-0 change.

Producer/caller trace: cancelled attacks stop AnimationPlayer and clear Might's
`_current_action`; rejected X tracing calls `get_normalized_attack_progress`,
which previously queried `current_animation_length` first. The query also serves
the active input window/buffer predicates, Combat's facade and Player's debug
hitbox display. Those gameplay callers retain their existing gates. The fix
returns zero when Might has no owned current action, then reads length once and
uses the same clamped ratio. No action-start/completion/state transition is edited.

Native 4.7.1 probes showed why a blanket `!is_playing`/empty-current-animation
guard was unsuitable: active 0.6/2.0 playback reports current `query`, paused and
completed report an empty current name but retain native positions 0.6 and 2.0;
explicit stop clears native playback and timing getters emit errors. Intentional
probe errors are isolated in `progress-semantics.log` and
`progress-section-semantics.log`; these are diagnostic experiments, not clean
test runs. The retained ownership guard preserves paused owned-action progress;
when completion clears the action, attack progress is zero. Existing completion
and queued follow-ups retain their previous behavior.

Candidate evidence lives in `round-1-candidate/` under this worker's task
visualization directory. Original `laema-dev-portal-4i9s7r02` was not changed.
The candidate `project/` is an independent full copy with only the scoped Might
production change applied; `style-project/` is a separate disposable fixture copy
so the persistence suite cannot alter the playable candidate's resources.

- Unchanged real-input script command: same round-0 engine arguments, isolated
  APPDATA/LOCALAPPDATA, `--headless --audio-driver Dummy --path <candidate>/project
  --script res://overnight_gym_input_test.gd --fixed-fps 60 --quit-after 12000`,
  plus `--log-file <candidate>/round-1-input-engine.log`. Subprocess timeout 120 s.
  Output `round-1-input-output.log`: exit 0, 11 assertions, zero engine errors or
  resource-leak reports. All eight complete scenario dictionaries match baseline
  after excluding only receiver/attacker machine instance IDs, including every
  event frame, phase transition, gap, outcome and scalar. Comparison saved in
  `round-1-comparison.json`; no timing tolerance or hidden timing difference.
- Focused attack-style command: isolated engine `--headless --path
  <candidate>/style-project --script res://round-1-attack-style-test.gd
  --quit-after 600 --log-file <candidate>/round-1-style-engine.log` with isolated
  profile and 120 s subprocess timeout. `round-1-style-output.log`: exit 0,
  588 checks, zero engine/resource errors. Six new checks cover unconfigured,
  idle, active, paused, completed and cancelled/rejected-X progress. Existing
  all-school Cast/completion/queued-followup coverage remains in that suite.
- Baseline F5 UID mismatch stays deferred. No desktop controls, gameplay tuning,
  commits, pushes, publication or subsequent round started.

Pre-edit Might SHA-256: `eabcc014d589368e22ede274be85e3cfa9642b29324b67291d33ee64006ea166`.
Post-edit Might SHA-256: `ee08fe528d9aee7db42bd1a29971b8b83851f460538fed5f957ce6a140b82a9c`.
Tested 637-file runtime manifest digest: `4d18d308c3299dcda29650da117da7928cb3ab8cb9c17aa37cb82f4c57d5d72c`.
Post-edit identities and the complete tested runtime digest are stored in
`round-1-candidate/round-1-identity.json`. Test basis is `644587b` plus exactly
the one Might query diff and the focused test additions; canonical changes above
describe only that candidate. Human/controller/game-feel acceptance stays pending.

## Round 2 — isolated 0.3-second recovery A/B

Supervisor independently reran round 1: 11 checks, zero errors, all eight full
scenario/event reports exactly equal after removing only attacker/receiver IDs.
U-001 is **IMPLEMENTATION_REVIEW_COMPLETE**, retained provisionally, with no
remaining finding in that bounded diff. This is not submission/game-feel clearance.
Supervisor logs remain `round-1-candidate/supervisor-round-1-output.log` and
`supervisor-round-1-engine.log`.

Round 2 began 21:59:02 HKT October 19. Snapshot: `round-2-before/manifest.json`
and the prior ledger copy. New `tools/tests/overnight_enemy_recovery_test.gd` was
absent before this round. Those are the only two working source paths edited;
the existing overnight harness and all production/canonical design files remain
unchanged by this experiment. The working `melee_swing.tres` remains length 1.0.

Independent `round-2-A/project/` and `round-2-B/project/` under this worker's
task evidence directory retain the round-1 production query fix. Across all
637 runtime/project files their **only** difference is the literal resource
`length = 1.0` → `length = 1.3` in
`config/attack_animations/melee_swing.tres`. Active_start/contact remain 0.8,
active_end remains 1.0, and every sprite/geometry key and combat value is byte
identical. No timer or speed change. Resource SHA-256: A
`9d770a99eb783e2a4c6c2c79cf93f98aa4db4ee2ba66d71e661cb915009481eb`, B
`3d1852f7dc1acead7ba8cf5f0d5d5c044607abf142647c8f3b38386c43f78a68`.
Runtime manifest digests: A `4d18d308c3299dcda29650da117da7928cb3ab8cb9c17aa37cb82f4c57d5d72c`,
B `a7abec5605aa052f2fe4aa93569e9d7c8b346a291b22ae7441776385cd61549a`.
Fixture digest and complete comparison identity are in `round-2-identity.json`.

### Measurements and validation

The focused fixture inherits the unchanged real-input helper. Initial position/
one-hit-death Health setup is explicitly labeled. Movement, L1, X, contact,
reaction and death run through actual input/physics; AI apply, cancellation and
stage lifecycle probes explicitly call their existing owner APIs and are not
described as player inputs. Normal-spawn duel policies use the original script.
The helper is staged at its repository-relative `tools/tests/` path inside both
isolated projects so the fixture's inheritance path is also valid in source.

- Focused final run covers 21 cases in each variant: Gym hit/miss, both facing
  directions, both walls, actual tutorial hit/miss, seven Gym lifecycle cases
  and six tutorial lifecycle cases. A passes 66/67; B passes 74/75; both exit 1
  for the same known AI-disable assertion. No engine/resource errors in these
  focused runs. Reports: `project/recovery-captures/A-recovery-report.json` or B;
  logs: `recovery-output-final-with-tutorial.log`,
  `recovery-engine-final-with-tutorial.log` in each variant folder.
- In Gym and shared tutorial, B enters RECOVERY at commitment +60 ticks (1.0 s)
  and leaves at +78 (1.3 s): exactly 18 ticks for hits and misses. Close-range
  next windup begins +79; A begins +61. First contact remains +48 (0.8 s),
  origin/facing remain committed, a hit produces one resolver contact and a
  retreat produces none. Both wall/facing cases preserve contact and timing.
- Real X started after a protected/parried first contact interrupts B during
  RECOVERY; one-hit-death setup plus actual X reaches DEAD. Stage retirement,
  reset and explicit cancellation abandon the old clock; reset/new decision
  begins at zero. These cases also pass for shared tutorial Enemy. Direct
  cancellation without an active hit reaction immediately permits a new tree
  cycle, matching A; it is not a new stun policy.
- **Shared pre-existing failure:** the first runtime AI `enabled=false` apply
  does not stop the Enemy in either A or B. It subsequently lands another hit,
  taking Player 100→90. Source trace finds `_ai_config = Dictionary(config[...])`
  shares the initial dictionary; in-place mutation changes both sides of the
  decision-change comparison. A prior unchanged apply detaches the cached copy;
  the separate `disable_ai_after_snapshot` case then correctly cancels to DORMANT
  in both Gym and tutorial. This is measured and source-supported, not fixed or
  promoted into this experiment's scope. The failure remains visibly asserted.
- The initial tutorial retreat setup placed Player at world zero, beside that
  area's translated left wall, preventing retreat. The fixture now uses the
  actual tutorial spawn's world X. Initial failed logs/report are retained as
  `recovery-output-initial.log` / `initial-recovery-report.json`; this was a
  fixture placement error, not a new tutorial or recovery regression.
- Original unchanged input suite: 11/11 on A and B, exit 0, zero engine/resource
  errors. `original-input-output.log` / `original-input-engine.log`. All melee/
  Charging/Cast follow-up event timings remain identical. Natural idle defeat
  shifts from frame 656 / 10.93 s to frame 820 / 13.67 s. Post-miss approach starts
  18 ticks later. Other phase histories change where recovery replaces windup.

| Original policy | A | B | Interpretation |
| --- | --- | --- | --- |
| Melee-first | victory frame 1150, HP 100 | same | Full event/phase report identical except IDs; interruptions prevent reaching tail |
| Parry/punish | victory frame 1639, HP 100; 20 parries | same | Action/contact frames and outcomes unchanged; Enemy phase history differs |
| Spacing/Cast | victory frame 1229, HP 80; 10 Casts | same | Action/contact frames and outcomes unchanged; Enemy phase history differs |

Existing production suites remain unedited. Separate disposable fixture copies
prevent persistence checks from modifying the retained playable A/B projects:
`enemy_animation_test-project/`, `attack_authoring_test-project/`. A passes
22/22 timing and 74/74 authoring, exits 0 without engine errors. B passes the
other 21 timing checks but intentionally fails the one stock assertion requiring
completion at 1.0 s; exits 1. B authoring passes 74/74, exit 0. Those B runs also
report six and four resources still in use at shutdown respectively; these are
not represented as clean runs. Earlier baseline timing also reported resource
shutdown errors. No production/OS audio cleanup was attempted.

### Matched rendered-frame fixture — prepared, not worker-executed

No graphical process or desktop input was used by the worker. The fixture's
`--capture` mode uses the actual Gym viewport and existing art, captures hit and
miss at +45/+49/+66/+77/+81 physics ticks (0.75/0.8167/1.10/1.2833/1.35 s),
and writes ten full viewport PNGs plus JSON with phase/clock/frame/Health and
actual image dimensions. It verifies the post-draw capture remains on the
recorded physics tick. It refuses a headless capture request. This branch awaits
supervisor execution with the real renderer; no PNG existence or visual success
is claimed by these headless runs.

Supervisor graphical PowerShell invocation; use the task evidence directory as
`$evidenceRoot`, then run once with A and once with B:

```powershell
$variant = 'A'
$work = Join-Path $evidenceRoot "round-2-$variant"
$env:APPDATA = Join-Path $work 'profile'
$env:LOCALAPPDATA = Join-Path $work 'profile'
& (Join-Path $work 'engine/Godot_v4.7.1-stable_win64.exe') --path (Join-Path $work 'project') --rendering-method gl_compatibility --script res://overnight_enemy_recovery_test.gd --fixed-fps 60 --quit-after 600 --log-file (Join-Path $work 'capture-engine.log') -- --capture "--variant=$variant" "--output=$(Join-Path $work 'captures')"
```

Expected output naming: `captures/A_gym_hit_f045.png` through f081 and matching
gym_miss files (B prefix for B), plus `captures/A-recovery-report.json` or B.
Use a bounded process timeout (120 s); do not control the desktop from the worker.
For headless focused measurement, use the same engine with `--headless
--audio-driver Dummy`, omit `--capture`, use `--quit-after 12000` and retain
the per-variant logs above. Original policy command stays identical to round 1.
Existing suites use their original scripts and `--quit-after 600`. All actual
subprocesses used 120 s timeouts and isolated APPDATA/LOCALAPPDATA profiles.

Headless pose sampling: A is in another windup (hit) or walking (miss) by 1.10 s;
B remains on Attack_1.png region X 384 at 1.10 and 1.2833 s, the same region as
at 0.8167 s contact. At 1.35 s B has begun new windup/approach. Extending length
alone supplies a timing tail but no new recovery pose. This is native pose data,
not rendered readability evidence.

**Recommendation:** reject promotion into working source for now; retain B only
as the isolated visual comparison. Functional recovery semantics work, but no
policy gains or human readability improvement are established, the tail holds
the contact artwork, and passive cadence is slower in both Gym and tutorial.
Supervisor may reconsider after the matched graphical comparison. No architecture
or gameplay-rule conclusion is inferred. All owned processes have ended; await
the next bounded assignment. No commit, push, publication or later round started.

## Round 2 supervisor disposition

Supervisor verified the single A/B runtime difference and that working resource
equals A. Actual OpenGL 3.3 / NVIDIA GeForce RTX 4090 runs captured ten PNGs per
variant: A 29/29, B 31/31 checks, both exit 0 with zero engine errors. Matched
1.10-second viewport inspection showed A's next windup/red warning and B's held
contact pose with warning absent. Evidence in each `round-2-A`/B folder:
`supervisor-capture-output.log`, `supervisor-capture-engine.log`,
`supervisor-captures/*.png` and report JSON. This establishes the rendered
pose/timing difference, not improved feel or physical-controller acceptance.

**Rejected for working-source promotion:** this isolated 1.3-second candidate.
Keep stock clip 1.0 and preserve A/B for morning reference. No broader conclusion
about all recovery tails follows. Supervisor replay of A reproduced 66/67 with
the sole AI-disable failure and zero engine errors (`supervisor-focused-output.log`,
`supervisor-focused-engine.log`, report under `supervisor-focused/`).

## Round 3 — U-002 independent initial decision-settings snapshot

U-002 was established as Major, existing baseline, accepted for narrow correction
under the user's overnight disposition delegation. Review returned to DUM-E.
Round began 22:13:24 HKT October 19; 20-minute budget and all original cutoffs
remain in force. Prior round-1 query fix and rejected A/B copies are preserved.

Before editing, seven approved paths were copied to `round-3-before/`, with a
SHA-256 manifest. Actual changed paths in this round: `scripts/enemy/combat_enemy.gd`,
`tools/tests/enemy_animation_test.gd`, this ledger, `docs/IMPLEMENTATION_STATUS.md`,
`docs/TECH_ARCHITECTURE.md`, `docs/departments/combat.md`. The recovery fixture
and original input harness were not changed.

Reproduction in a new independent stock-length `round-3-candidate/project/`
before the fix: recovery fixture exit 1, 66/67, sole failed assertion `AI disable
cancels tail and pending contact`, zero engine errors. `before-output.log`,
`before-engine.log`, and `project/recovery-captures/before-recovery-report.json`
remain available. No prior no-op apply was performed.

The production diff is one line: `_ai_config = Dictionary(config["enemy_ai"])`
becomes `.duplicate(true)`. Initial configure had aliased `_config`'s live enemy_ai
dictionary. Mutating a setting changed the cached value before Arena's validated
parent apply reached Enemy; the difference detector then returned without reset.
Later applies already deep-copied, explaining the warmup-dependent behavior.
The fix uses that existing copy convention at initialization too. Existing
comparison keys, reset order, reaction resets, cancellation, and dead/area guards
are untouched.

Trace: Arena's shared config is mutated → `_apply_runtime_tuning` validates,
synchronizes the mirror and applies each target → Enemy compares its old snapshot,
copies the new settings, updates private geometry/blackboard → a changed decision
key invokes existing `_reset_ai_execution`. Aggro-range condition and approach
tasks consume the blackboard; movement consumes its speed; actor contact consumes
new `_ai_config.damage`. Tests distinguish old/new values at non-default distances,
speed and damage. Configuration/lifecycle probes use owner APIs and labeled
manual physics/HealthEvent setup; they do not claim real-input gameplay evidence.

### Round 3 validation and identity

- Expanded Enemy timing suite **152/152**, exit 0. Original 22 timing checks
  remain; new coverage tests first changed enabled/range/speed/damage in Gym and
  tutorial, normal parent apply, first disable without warmup, re-enable,
  already-disabled no-op preserving an existing reaction lifetime, initially
  disabled configuration, unchanged/geometry/reaction/legacy nonreset behavior,
  next-attack geometry consumption, and named active/recovery/reaction/dead/retired
  states. Private fixture-only animation length 1.3 supplies recovery coverage;
  the saved resource stays 1.0. Each named phase is asserted before applying.
  Enable cannot resurrect dead/retired actors. Decision edits retain the existing
  reaction-reset behavior. No new engine/resource errors.
- Unchanged recovery fixture **67/67**, exit 0, zero engine/resource errors.
  The previously sole failure passes, across the retained 21 cases; the separate
  already-detached disable case remains valid. Report:
  `project/recovery-captures/round3-recovery-report.json`.
- Unchanged real-input suite **11/11**, exit 0, zero engine/resource errors.
  All eight complete scenario dictionaries match round 1 after removing only
  attacker_id/receiver_id, including every action/contact frame, Enemy phase,
  gap, outcome and scalar. `input-comparison.json` records an empty difference
  list. No ordinary-play tuning or timing changed.

Engine: 4.7.1.stable.official.a13da4feb Windows. Retained playable candidate is
`round-3-candidate/project/`; logs beside it: `round-3-timing-output-final.log`,
`round-3-timing-engine-final.log`, `round-3-recovery-output.log`,
`round-3-recovery-engine.log`, `round-3-input-output.log`, `round-3-input-engine.log`.
All runs use isolated APPDATA/LOCALAPPDATA profiles and 120-second subprocess
timeouts. Command prefix: isolated engine `--headless --audio-driver Dummy
--path <candidate>/project --script res://<script> --fixed-fps 60 --quit-after
<limit> --log-file <named-engine-log>`. Scripts/limits: new copied
`round-3-enemy-animation-test.gd` / 6000; unchanged
`overnight_enemy_recovery_test.gd` / 12000 with `-- --variant=round3`;
unchanged `overnight_gym_input_test.gd` / 12000. Before-fix reproduction uses
the recovery command with variant `before` and the pre-edit Enemy source.

Tested runtime basis: `644587b` plus retained U-001 and this one Enemy line.
All 637 candidate runtime/project files match current source; compared with
retained round-2 A, only `scripts/enemy/combat_enemy.gd` differs. Runtime manifest
digest: `0219c4525213faaf48a3e7f454dc43a3d3e54d6a4cf6849b8866ef39cbb525c6`.
Enemy pre-edit SHA-256: `374b6851b6a98a44ac3aaeee8dec3639cc6cf98a9534f4174b1bb8d59823e7de`;
post-edit: `c76ac4dc7c8552cf3aaf6489f3ecf974a8e002882b6d016aac1cb7386edd041e`.
Stock animation SHA remains `9d770a99eb783e2a4c6c2c79cf93f98aa4db4ee2ba66d71e661cb915009481eb`.
Complete scoped before/after hashes and fixture identity are retained in
`round-3-candidate/round-3-identity.json`.

Status: **READY_FOR_SUPERVISOR_REVIEW**. No desktop input, commit, push,
publication, submission clearance, human-feel acceptance or subsequent round.
All owned engine subprocesses ended; await the next bounded assignment.

## Round 3 supervisor disposition

U-002 is **IMPLEMENTATION_REVIEW_COMPLETE**, retained after bounded tech-postflight
review. Supervisor independently obtained 67/67 recovery and 11/11 original
input checks, both exit 0/zero engine errors. Recursive comparison of all eight
scenario/event dictionaries exactly matches round 1 after removing only
attacker_id/receiver_id. Evidence in `round-3-candidate/`:
`supervisor-recovery-output.log`, `supervisor-recovery-engine.log`,
`supervisor-input-output.log`, `supervisor-input-engine.log`. No reset policy,
human gameplay/controller acceptance or submission clearance is inferred.

## Round 4 — isolated Fire Cast anticipation A/B

Round began October 19 22:23:14 HKT, with a 30-minute budget and unchanged
overnight cutoffs. Only working paths changed: new
`tools/tests/overnight_cast_timing_test.gd` and this ledger. Snapshot of the prior
ledger and absence record for the new fixture are in `round-4-before/`.
Original input helper, all production files and earlier evidence are preserved.

Independent `round-4-A/project/` and `round-4-B/project/` retain U-001/U-002 and
stock Enemy length 1.0. Across 637 runtime/project files, **only**
`config/attack_animations/cast_fire.tres` differs. A contact/active_start 0.36;
B 0.24; active_end/length stay 1.0. Existing sprite times are mapped piecewise:
before/equal 0.36, multiply by 0.24/0.36; afterward use
0.24+(t−0.36)×0.76/0.64. Geometry keys at 0.36 move to 0.24. Texture, ordered
sprite poses, geometry values, JSON, Fire X/Enemy clocks, other school assets,
damage/Impact, projectile speed, input window and Gym scale are byte-identical.
Non-timestamp animation text compares exactly equal. Working Fire asset remains A.

Fire resource SHA-256 A: `07025e1c2324ef3900e02bb8fc4e886e414a17704f95443afa6a9bc788f8b882`;
B: `13fbce9b6311cf69243c456ff3e6d7fba44215f0c6dddd99680493191a866f82`.
Runtime manifest digests A: `0219c4525213faaf48a3e7f454dc43a3d3e54d6a4cf6849b8866ef39cbb525c6`;
B: `e5ec3b1083d6885e1aae6254aaf44098c4ad83914ae8cba8e4bad61541e7390b`.
`round-4-identity.json` records the fixture hash, full delta and current-source
comparison. A matches current production; B differs only in that resource.

### Producer-to-consumer trace and fixture boundary

Real InputMap L2 axis release → CombatComponent samples pressure → Might
classifies/commits through Magic, retaining existing resource/Heat rules → a
pending Cast waits for predecessor completion → school-specific native clock
visits contact → Magic launches its once-only committed payload → Player's
launch subscriber starts cast audio and requests the projectile → Arena spawns
the existing projectile/visual/travel audio. Only Fire's authored timestamp/pose
mapping changes. No Cast/combat methods manufacture timing evidence.

Matched normal/queued Levels 1/4/8 use explicitly labeled **initial Fire-orb
setup** and existing owner apply to disable AI. Charging/release and all action
physics then use actual input. The queued predecessor deliberately misses at
ordinary spawn so target reactions cannot alter the timing comparison. These
high-level cases do not claim those resources were generated through play.
A separate zero-resource case generates/charges/releases three consecutive
cycles through actual close melee contacts. Real rear Enemy strikes supply
interruption cases; the forward projectile cannot cancel that attacker. AI is
disabled only after the first measured incoming hit to avoid an extra cycle.
Esc/Down/Enter drive pause/resume and Retry through the real UI.

### Results

Both variants pass **45/45** focused checks across 11 scenarios, exit 0 with
zero engine/resource errors. Logs per variant: `cast-output-retained.log`,
`cast-engine-retained.log`; complete frame/state/event data:
`project/cast-evidence/A-cast-report.json` or B. The initial fixture checked
Retry before releasing Enter; moving the check after key release and scene
reload corrected that shared fixture failure. Initial logs/reports remain
`cast-output-initial.log`, `cast-report-initial.json`; no production UI change.

All six matched cases have exactly equal commitment event dictionaries,
including frame, level, school and empowerment. They launch once. Cast start,
total action end, queued melee start and follow-up completion are identical;
first live/render-eligible projectile and cast-audio playback move with launch.
Headless node visibility is not a claim of GPU-visible pixels or audible feel.

| Matched normal/queued level | Cast-start → launch A/B | Cast duration A/B | Result |
| --- | --- | --- | --- |
| 1 | 26 / 18 ticks | 72 / 72 ticks | 8 ticks earlier; same end/follow-up |
| 4 | 25 / 17 ticks | 70 / 70 ticks | 8 ticks earlier; same end/follow-up |
| 8 | 24 / 16 ticks | 67 / 67 ticks | 8 ticks earlier; same end/follow-up |

Heat gained from commitment explains the different total durations across
levels; comparisons within a level use identical Heat and durations. Level-1
stand-alone release frame 35 commits/starts 36, launches A62/B54, ends 108 and
starts melee 108. Queued fixture release 46 commits 47, starts Cast 78, launches
A104/B96, ends/starts melee 150. Thus predecessor waiting is preserved; this
does not remove buffering or action commitment.

In the original real-generation close case, release 37 commits 38, Cast starts
48, launches **A74/B66**, ends/starts follow-up melee 120, which finishes 159.
Enemy phase/spacing changes after earlier impact are retained as real effects.

- Rear strike before both launch times: A0/B0 launches, same resource commitment.
- Strike between launch times: A0/B1. A is interrupted before its projectile;
  B has already launched and the existing projectile continues. No new cancel rule.
- Strike after both launch times: A1/B1. All cases receive the actual 10-damage
  Enemy hit, with no duplicated launch.
- Three zero-resource real-generation cycles: three generated orbs, three
  charged/committed Casts and three launches in each variant. Their action ends
  remain identical; launches are 8–9 ticks earlier depending on Heat/quantization.
- Pause holds the actual Cast clock and prevents launch; resume launches once.
  UI Retry restores Player100/Enemy200, empty queue and zero Heat in both.

Original unchanged suite: **11/11** A/B, exit 0, zero engine/resource errors;
`original-input-output.log` / `original-input-engine.log`. Duel policies:

| Policy | A | B |
| --- | --- | --- |
| Melee-first | 1150 ticks / 19.17 s, HP100 | identical |
| Parry/punish | 1639 ticks / 27.32 s, HP100 | identical |
| Spacing/Cast | 1229 ticks / 20.48 s, HP80, 10 Casts | 1164 ticks / 19.40 s, HP60, 9 Casts |

The last policy is faster but loses more Health. No universal balance or
enjoyment claim follows; event/phase differences are not normalized away.
`round-4-comparison.json` records matched commitment/end/follow-up comparisons.

Broad attack-style suite is unedited, run in separate `style-project/` copies
because its persistence checks write fixture resources. A **588/588**, exit 0.
B **585/588**, exit 1: exactly three `Native Cast scrubbing retains school frame
pacing: fire` assertions expect old sprite timestamps. These are intentional
old-pacing expectations, not unreported all-school/completion failures. Neither
run has engine/resource errors. `style-output.log` / `style-engine.log` retain
the failures; other-school and mixed-primary/queued completion checks remain.

### GPU capture fixture prepared for supervisor

Worker used headless processes only. `--capture` runs Level-1 normal and queued
cases with actual existing Gym art, explicit initial resource setup and a missed
predecessor. It writes full viewport PNGs at release and matched Cast-start
offsets 0,16,18,25,26,70,71,72,78 ticks, covering anticipation, new/old launch,
completion and melee follow-up. JSON annotates after-draw frame, action, clock,
sprite, positions, resource/Health state and projectile visibility. It checks
capture remains on the scheduled physics tick and refuses headless capture.
Actual rendering/PNG success remains pending supervisor execution.

Using `$evidenceRoot` for this worker's task evidence directory, run once with
A and once with B; bound the owned process to 120 seconds:

```powershell
$variant = 'A'
$work = Join-Path $evidenceRoot "round-4-$variant"
$env:APPDATA = Join-Path $work 'profile'
$env:LOCALAPPDATA = Join-Path $work 'profile'
& (Join-Path $work 'engine/Godot_v4.7.1-stable_win64.exe') --path (Join-Path $work 'project') --rendering-method gl_compatibility --script res://overnight_cast_timing_test.gd --fixed-fps 60 --quit-after 1500 --log-file (Join-Path $work 'capture-engine.log') -- --capture "--variant=$variant" "--output=$(Join-Path $work 'captures')"
```

Expected names include `captures/A_normal_1_release.png`,
`A_normal_1_cast_018.png`, `A_normal_1_cast_026.png`, corresponding queued files
and B prefixes, plus A/B-cast-report.json. Capture mode may include additional
assertions for actual image/frame validation; no count or PNG existence is claimed
until rendered. Headless focused command adds `--headless --audio-driver Dummy`,
omits `--capture`, uses `--quit-after 10000`, variant A/B and the retained logs.
Original input command uses its unchanged script /12000-frame limit; style uses
its unchanged copied script /600-frame limit. All subprocesses use isolated
APPDATA/LOCALAPPDATA and 120-second timeouts. Engine remains Godot 4.7.1 Windows.

**Recommendation:** retain B provisionally if supervisor's rendered comparison
confirms the compressed anticipation/contact reads coherently. The measured
response gain is 0.133 s in matched cases without changing total cadence;
the increased damage taken by the spacing policy must remain part of morning
evaluation. No working-source promotion was performed, and human/controller/
game-feel acceptance remains pending. All owned processes ended; stop for review.
No desktop input, commits, publication or autonomous next round.

## Round 4 supervisor disposition

Supervisor retained Fire B **provisionally**, pending human morning controller/
feel acceptance, after bounded tech-postflight review with no unresolved A/B
conformance findings. Actual OpenGL A/B runs each passed 46 capture-mode checks,
produced 19 actual PNGs and exited 0 with zero engine errors. Evidence in each
`round-4-A`/B: `supervisor-capture-output.log`, `supervisor-capture-engine.log`,
`supervisor-captures/*.png` and JSON. Inspected Cast+18/+26 frames show B's
earlier projectile progression with the existing pose sequence/coherent caster
presentation. Metadata establishes the eight-tick launch gain; inspected frames
do not establish an exhaustive first-visible-pixel frame or human enjoyment.

Supervisor independently verified only cast_fire differs and confirmed matched
normal A62/B54 launch, both start36/end108/melee108; queued A104/B96 launch,
both start78/end150/melee150. The spacing-policy damage tradeoff remains part
of the candidate; no new rule/architecture or final tuning is accepted.

## Round 5 — exact Fire B promotion and source regression

Round began October 19 22:39:17 HKT; 20-minute budget and original cutoffs apply.
Before editing, all nine approved files were copied to `round-5-before/` with
SHA-256 manifest. Promotion first verified reviewed B hash
`13fbce9b6311cf69243c456ff3e6d7fba44215f0c6dddd99680493191a866f82`, then copied
those exact bytes to working `config/attack_animations/cast_fire.tres`.
Pre-promotion A hash was
`07025e1c2324ef3900e02bb8fc4e886e414a17704f95443afa6a9bc788f8b882`.
No hand recreation or additional timing edit was made.

Actual changed paths this round:

- `config/attack_animations/cast_fire.tres`
- `tools/tests/attack_style_test.gd`
- `docs/GAME_DESIGN.md`
- `docs/TECH_ARCHITECTURE.md`
- `docs/IMPLEMENTATION_STATUS.md`
- `docs/ATTACK_STYLES.md`
- `docs/GYM.md`
- `docs/departments/combat.md`
- `docs/iterations/2026-10-19-overnight.md`

Only affected candidate/representation/status passages are synchronized. Fire
active_start/contact 0.24, end/length 1.0 and piecewise pose/key mapping are
explicit; total Gym Cast scale/duration, resource/queue rules, once-only launch
and melee handoff remain intact. Documentation retains the HP60-versus80 policy
tradeoff and pending human acceptance. Stock Enemy remains 1.0, rejected 1.3
comparison remains isolated. The two earlier bounded implementation-review
statuses are updated without claiming whole-document validation.

Broad tests retain all prior checks. Only the three old Fire sprite expectations
are changed using the normative inverse of the reviewed piecewise mapping;
Water/Air/Earth expected paths are unchanged. New checks cover 0.24 markers,
1.0 end/length, original contact pose, once-only launch at the marker, full
configured duration and queued melee at completion. Existing all-school,
mixed-primary, buffered/windowed/endpoint and persistence coverage remains.

### Fresh current-source validation

`round-5-candidate/project/` was copied fresh from current source, including all
runtime roots and test files. Engine/profile are isolated. A disposable
`style-project/` copy contains the intentionally mutating persistence tests;
the retained playable copy is not used for those writes. Godot is
4.7.1.stable.official.a13da4feb Windows x64.

| Suite | Checks | Exit / engine-resource result |
| --- | ---: | --- |
| Focused real-input Cast | 45 | 0, zero errors |
| Original real-input Gym/policies | 11 | 0, zero errors |
| Updated broad attack styles | 595 | 0, zero errors |
| Enemy timing/config/lifecycle | 152 | 0, zero errors in bounded delayed rerun |
| Shared Gym/tutorial recovery/lifecycle | 67 | 0, zero errors |

Initial fresh import reports the existing unrecognized main-scene UID before
building its UID cache; no launch configuration was edited. `import-output.log`
and `import-engine.log` preserve it. The first parallel Enemy152 run passed but
reported the intermittent six-resource audio shutdown warning already seen in
baseline runs. Both that output and the clean rerun are retained. The rerun
adds engine `--frame-delay 25` to allow mixing-thread wall time, without source,
audio settings or simulation-step changes. It exits 0/152 passes/zero errors.
This is not a source-level audio fix or a claim that every historical run was clean.

Ordinary-input comparison is against **reviewed round-4 B**, not old A. All eight
complete scenario/event dictionaries are exactly equal after removing only
attacker_id and receiver_id; `input-comparison.json` records no differences.
Thus launch timing and changed policy outcomes are carried intact: spacing/Cast
1164 ticks /19.40 s/HP60, melee-first1150/HP100, parry-punish1639/HP100. The
original close case launches66 and ends/starts melee120, matching B.

All 637 retained candidate runtime/project files match current source after
nonmutating suites. Compared with round 3, only cast_fire differs; all non-Fire
assets and Fire X/Enemy clocks remain byte-identical. Runtime manifest digest
is the reviewed B digest:
`e5ec3b1083d6885e1aae6254aaf44098c4ad83914ae8cba8e4bad61541e7390b`.
Candidate shared JSON SHA remains
`5ffa6b4edcf823a0efe677661ad0c2945ac85930d3d0324adec07816e18c283a`;
mirror remains `773f08a5bd6cee2da07fc5d1f8bec28a76fe5830190cbf31eb41802eff43c67a`.
Source/candidate comparisons confirm both remain unchanged. Exact nine-file
before/after hashes are in `round-5-candidate/round-5-identity.json`.

Logs in that folder: `cast-output.log`/`cast-engine.log`,
`input-output.log`/`input-engine.log`, `style-output.log`/`style-engine.log`,
`recovery-output.log`/`recovery-engine.log`, initial `enemy-output.log`/
`enemy-engine.log`, clean `enemy-delayed-output.log`/`enemy-delayed-engine.log`.
Fresh import uses `--headless --path <project> --editor --quit`; runtime prefix
is isolated engine `--headless --audio-driver Dummy --path <project> --script
res://tools/tests/<suite>.gd --fixed-fps 60 --quit-after <limit> --log-file
<named-engine-log>`. Suite/limits: overnight_cast_timing_test10000 with
`-- --variant=round5`; overnight_gym_input_test12000; attack_style_test6000 in
style-project; enemy_animation_test6000 (clean retry adds `--frame-delay 25`);
overnight_enemy_recovery_test12000 with round5 variant. Every subprocess had a
120-second timeout and isolated APPDATA/LOCALAPPDATA.

### Morning validation notes

Use the retained source/explicit Gym scene and a physical controller to compare
stand-alone and queued L2 release, visible anticipation/contact, melee return,
and pressure during Enemy attacks. Judge the earlier launch in the retained
slower rhythm; quicker firing does not remove full action commitment. Keep the
measured spacing-policy extra damage visible in that judgment. Supervisor
rendered evidence and engine checks are not human/controller acceptance. The
baseline F5 UID issue remains deferred; no live/export/submission validation is
claimed. All original A/B copies and snapshots remain available.

Status: **READY_FOR_SUPERVISOR_REVIEW**, retained overnight candidate. All owned
processes ended. No desktop input, commit, push, publication or next round.

## Round 5 supervisor disposition

Supervisor independently verified the promoted Fire hash equals reviewed B,
checked candidate wording/primary-school native consumer and reran fresh Cast
45/45 with zero engine errors. Evidence: `round-5-candidate/supervisor-cast-output.log`,
`supervisor-cast-engine.log`, report under `supervisor-cast/`. No new findings;
bounded **IMPLEMENTATION_REVIEW_COMPLETE**, retained candidate. Human/controller/
game-feel acceptance remains pending; prior import/audio caveats are preserved.

## Round 6 — isolated Gym Poise1/10 comparison

Round began 22:48:07 HKT October 19, with 25-minute budget and original cutoffs.
Only working paths changed: new `tools/tests/overnight_gym_poise_test.gd` and
this ledger. Prior ledger and new-file absence snapshot: `round-6-before/`.
All working production stays unchanged, including Gym Poise1, EnemyImpact20,
Health100/200, native Enemy1.0 and retained Fire Cast contact0.24.

Independent `round-6-A/project/` and `round-6-B/project/` preserve current source.
Their only difference across all 637 runtime/project files is B's Gym-root
`opponent_poise = 10` property in `scenes/gym.tscn`; A inherits the existing1.
Reusable Enemy defaults, shared tutorial, JSON/mirror, assets, geometry, damage,
Player Impacts, reactions and clocks are byte-identical. Scene SHA-256 A:
`6bfefa80da56c0dad815f37ada358ac9a03614168b92409b629e08d2b78ddcc6`;
B: `59a30b45d7281a25d2d4573d3ee10703584df98914f53c8e17c76fd5b24081e7`.
Runtime digest A remains `e5ec3b1083d6885e1aae6254aaf44098c4ad83914ae8cba8e4bad61541e7390b`;
B is `ee6825f77975380012b9d4c386df114384a98713fd8a63076fa91c88ec6e13ea`.
`round-6-identity.json` records exact source/hash delta and fixture hash.

### Input/physics evidence

The new fixture drives actual InputMap X/L1/L2 and movement through engine ticks;
no manufactured HealthEvent or reaction invocation supplies gameplay evidence.
Position/wall/facing setup is labeled. Higher-X cases build their prefixes by
real hits with AI disabled, then enable it for the tested move; held L2 preserves
the chain across existing invincibility waits. Cast-level isolation explicitly
supplies initial Fire orbs, then uses real Charging/release with AI enabled for
actual windup/impact. Those prepared cases do not claim ordinary acquisition of
high levels under uninterrupted pressure.

Final focused run: **50/50 A and B**, exit 0, zero engine/resource errors, across
18 cases each. Reports: `project/poise-evidence/A-poise-report.json` or B;
logs: `poise-output-retained.log`, `poise-engine-retained.log` per variant.
These assertions validate contact/formula/eligibility and the stated policy
attempts; they do not require every tested policy to win or complete its Cast.

- X1 in windup: A10−1−0=9→Level1; B10−10−0=0→no reaction. Both apply ten damage
  and generate one orb. B's existing Enemy windup continues, contacting once at
  its original 0.8 marker; damage recognition is not lost.
- Prepared real X2–X5 retain Impacts20/30/40/50. B yields reaction values
  10/20/30/40→Levels1/2/3/4, versus A19/29/39/49→Levels2/3/4/5. Qualifying hits
  still cancel the pending windup. Prefix damage and generation are real contacts.
- Prepared normal Cast Levels1–4 all retain ten damage and one projectile.
  B reactions are0/1/2/3, versus A1/2/3/4, using unchanged eligibility/bands.
  Level1 damage leaves B's pending windup intact; higher qualifying levels cancel
  it. Reassessment can still produce a later separate strike; interruption does
  not grant an invented cooldown.
- Mirrored/left-wall/right-wall real X1 cases preserve damage, generation,
  formula and committed Enemy contact. Position setup precedes commitment.
  Existing once-only/miss/native timing behavior remains covered by the unchanged
  Enemy suite and original committed-retreat scenario.

### Choices after an opener

Close setup, one X without Charging: actual contact frame16; Player becomes
READY47 in both. A's reaction delays the next incoming contact to82; B's original
committed strike arrives49. Thus B leaves **2 ticks /33 ms** from READY to strike.
A legal scripted L1 at47 parries B49; retreat at47 is still struck at49. This
demonstrates a very narrow timing margin, not a claim humans can react within it.
Mirrored/wall setups leave four ticks in those particular placements, not a
universal scenario-independent window. After the first measured parry, probes
remain idle and may receive a later separate hit; final HP is not represented
as the first-contact outcome.

Parry-first then single X and READY-spacing succeeds at HP100 in A/B. Parry49,
X contact62, READY/retreat93; B's next committed contact110 misses after retreat.
The 17-tick window is a viable existing prepared route. No parry cancel, input
buffer or reaction rule was added.

Zero-resource generate/charge/release/melee policy: hold L2 during X1; release
when first charge and existing window allow; queue melee only during an actual
Cast at normalized progress≥0.6. A generates, commits36, starts Cast48, launches66
and starts melee120; finishes observation HP100/Enemy167. B also generates and
commits36, starts48, but Enemy49 interrupts before launch. No follow-up input is
manufactured during the reaction; B launches zero and ends HP70/Enemy190 after
three natural incoming strikes. This is the ordinary loop tradeoff, not a stale
handoff defect or permission to add cancels.

Additional explicit parry/spacing policies retain both failure and success:

- Parry → real generate/charge → after X ends retreat14 ticks → turn one tick →
  release: A launches then is hit; B is hit before its release is classified and
  launches zero. Neither completes follow-up. The attempt remained inside the
  committed sweep/body reach after turning back. Intermediate logs/report remain
  `poise-output-intermediate.log` / `poise-report-intermediate.json`; the first
  assertion incorrectly required commitment despite a valid interrupted release.
  Final observation checks the release request and records failure separately.
- Parry → real generate/charge → after X ends retreat until gap≥135 px → turn
  one tick → release → queue melee at Cast0.6: both launch once and complete real
  follow-up, HP100/Enemy170, two generated orbs and one remaining. B release112,
  commitment/start113, launch131, melee185. A release111/start112/launch130/
  melee184. This is an explicitly telemetry-driven prepared policy, not proof of
  intuitive human spacing. Holding L2 preserves the chain and releases movement
  only after the full melee action; no impossible cancel or state reset is used.

The successful route means the loop is mechanically viable under Poise10. It
does not erase the failed default opener or establish parry as universally
mandatory; unsampled spacing/baiting strategies may differ.

### Unchanged original policies and regressions

Original script is unedited. A **11/11**, exit0; B **10/11**, exit1; zero engine/
resource errors. B's failed assertion is the actual generated-orb release/Cast
workflow being interrupted, not just an outdated numeric label. It remains
visible in `original-input-output.log` / `original-input-engine.log`.

| Original policy | A | B | Actual contact outcomes |
| --- | --- | --- | --- |
| Melee-first | victory1150 ticks/19.17s, HP100 | defeat614/10.23s, Enemy100 | A24 melee starts/20 hits, four Enemy clashes lost; B15 starts/10 hits, ten Enemy applied strikes |
| Parry/punish | victory1639/27.32s, HP100 | victory1240/20.67s, HP100 | Both20 melee starts/hits and20 parries; no Cast |
| Spacing/Cast | victory1164/19.40s, HP60 | defeat1040/17.33s, Enemy170 | A13 melee starts/9 hits/9 Casts, four applied Enemy hits/four lost clashes; B3 starts/3 hits/zero Casts, ten applied Enemy hits |

No strategy is required to use every control, and these policies are not optimal
human players. The results show a strong shift toward the existing parry-first
route in this sample, not proof that all other play is impossible.

Unchanged Enemy timing/config/lifecycle suite passes **152/152 A and B**, exit0,
zero engine/resource errors, covering shared tutorial as well as Gym, native
contact/once-only cancellation, misses/custom recovery and owner lifecycle.
The existing clash suite was also run unchanged: A14 failed assertions (real
X2/X3 contact/reaction fixture expectations), B48 failed assertions including
additional Poise-sensitive level/duration/cancellation expectations. Both exit1
with zero engine errors. A failures are present without Poise10 under this
invocation and remain outside this round; their cause is not claimed resolved.
This suite is not represented as passing, nor were production tests rewritten
to conceal it. Detailed logs: `clash_formula_test-output.log`/`-engine.log`;
Enemy logs use `enemy_animation_test-output.log`/`-engine.log`.

### Supervisor graphical command and recommendation

No worker graphical process or desktop input was used. New fixture `--capture`
mode runs X-no-defence, X-READY-parry and parry-X-READY-spacing with the actual
Gym art/viewport. Matched frame targets17,45,48,49,64,83,95,110,120 show first-hit
aftermath, full-action end, continued windup/contact and successful legal parry/
retreat where observed. JSON annotates after-draw action/progress, phase/clock,
Health, positions, resources and actual scheduled physics frame. It rejects
headless capture; actual PNG/renderer success awaits supervisor execution.

Set `$evidenceRoot` to this worker's task evidence directory and run A then B,
using a 120-second process timeout:

```powershell
$variant = 'A'
$work = Join-Path $evidenceRoot "round-6-$variant"
$env:APPDATA = Join-Path $work 'profile'
$env:LOCALAPPDATA = Join-Path $work 'profile'
& (Join-Path $work 'engine/Godot_v4.7.1-stable_win64.exe') --path (Join-Path $work 'project') --rendering-method gl_compatibility --script res://tools/tests/overnight_gym_poise_test.gd --fixed-fps 60 --quit-after 1200 --log-file (Join-Path $work 'capture-engine.log') -- --capture "--variant=$variant" "--output=$(Join-Path $work 'captures')"
```

Expected naming includes `captures/B_X_no_defence_f017.png`,
`B_X_READY_parry_f049.png`, `B_parry_then_X_READY_spacing_f110.png` and matching
A files/report JSON. Headless focused command uses `--headless --audio-driver
Dummy`, omits `--capture`, limit16000 and variant A/B. Original suite limit12000;
Enemy/clash limit6000 with `--frame-delay 25`. All runs use fixed60 simulation,
isolated APPDATA/LOCALAPPDATA and 120-second subprocess timeouts, Godot4.7.1.

**Recommendation: reject working-source promotion of Poise10 for now.** It
creates pressure and has a viable prepared parry/retreat route, but the ordinary
close opener's two-tick READY window and interrupted main melee–Casting policy
substantially constrain the primary focus. Greater difficulty alone is not an
improvement; rendered/human assessment could inform a different later choice.
No new rules, timing changes or alternative tuning are inferred. Working Poise1
and all prior retained candidates remain intact. All owned processes ended;
READY_FOR_SUPERVISOR_REVIEW. No desktop input, commits/publication or next round.

## Round 6 supervisor disposition

Poise10-only B rejected for working promotion after bounded tech-postflight
review. Its two-tick READY interval and interrupted ordinary melee–Casting loop
do not support the intended readable pressure despite a prepared viable route.
This is a scoped rejection, not a requirement for equal strategy strength.
Supervisor's actual GPU A/B runs each exited0, passed65 checks and produced27
PNGs with zero engine errors. Matched no-defence frame49 inspection shows
A Player100/Enemy190 and interrupted/restarted Enemy, versus B Player90/Enemy190
with no X1 reaction. Evidence in each round-6 folder: supervisor-capture logs,
`supervisor-captures/` images/reports. Prior failures remain preserved. Existing
clash-suite A14 FireX2/X3 fixture/contact failures remain unresolved, outside
this tuning experiment; no production or test repair is inferred.

## Round 7 — fixed-Poise timing / choice-window experiment

Round began October19 23:04:36 HKT, with25-minute budget and unchanged overnight
cutoffs. Working edits are new `tools/tests/overnight_gym_choice_window_test.gd`,
minimal parameterization of `tools/tests/overnight_gym_poise_test.gd`, and this
ledger. `round-7-before/` snapshots the helper/ledger and records new-file absence.
No working gameplay resource, actor or configuration is changed.

Independent references:

- A `round-7-A/project/`: current retained production, GymPoise1, Enemy0.8/1.0.
- B `round-7-B/project/`: fresh copy of rejected Poise10-only B, Enemy0.8/1.0.
- C `round-7-C/project/`: B plus only Enemy active_start/contact1.1,
  active_end/length1.3. Active interval stays0.2; there is no recovery tail/timer.

C remaps the four existing sprite timestamps0/.25/.5/.75 to
0/.34375/.6875/1.03125 and geometry timestamps .8→1.1. Poses/order, texture,
geometry values, native speed1, damage/health, Fire Cast0.24, all Player clips/
Impact/Poise, decision tree, JSON/mirror and other assets remain byte-identical.
C versus B has **one** runtime file difference, `config/attack_animations/melee_swing.tres`;
C versus A adds only that and `scenes/gym.tscn`'s Poise10 override. Non-timing
Enemy animation text compares exactly equal. Enemy asset hashes: A/B
`9d770a99eb783e2a4c6c2c79cf93f98aa4db4ee2ba66d71e661cb915009481eb`,
C `c974260d13e7435991651109b58e5ae0d0bbb2ab68f7116eba4c29a2136a176e`.
Runtime C digest: `07809cf9010d09bd38e91e2a83814765c3c18aea98e15bba55b6e268bb375135`.
Full637-file identities are in `round-7-identity.json`.

**Tutorial source discrepancy:** task wording assumed shared tutorial Poise1;
actual `config/prototype_combat.json` enemy_ai.poise is0. Gym A explicitly
overrides1. The experiment preserves the actual shared JSON/mirror bytes and
measures tutorial Poise0, rather than silently changing config to fit that
assumption. This was flagged during work. No tutorial Poise decision is made.

### Helper continuity and test boundary

The existing Poise fixture now exposes two pure defaults: parry trigger0.68
and its original capture-target array. The new choice fixture overrides parry
trigger to authored contact−0.12 and supplies additional capture moments. No
other helper policy/timing changes. An independent A helper replay passes50/50;
all18 full prior round-6 scenario dictionaries are exactly equal after removing
only attacker_id/receiver_id (`baseline-helper-comparison.json`). Thus old
observations remain reproducible; the original three-policy script is unedited.

All attacks, Charging, parry, direction/pivot and school switching use real
InputMap events and engine physics. No direct health/resource/action edits make
policies succeed. Higher-X prefixes use the labeled prior fixture setup, then
actual qualifying hits. Explicit stage retirement/reactivation is a separate
lifecycle control probe, not a player-action claim.

Final choice fixture: **A66/66, B69/69, C69/69**,13 scenarios each, exit0 and zero
engine/resource errors. Counts vary with observed real contacts/formula checks.
`choice-output-final.log` / `choice-engine-final.log` and
`project/choice-evidence/<variant>-choice-report.json` are retained per folder.
These tests validate legality/formula/once-only events, not human skill or feel.

### Measured choices at fixed Poise10

| Close X1 probe | A | B | C |
| --- | --- | --- | --- |
| Actual X1 contact | frame16, Level1 reaction | frame16, value0/no reaction | frame16, value0/no reaction |
| Player READY |47|47|47|
| Next incoming contact without defence |82|49|67|
| READY→contact margin |35 ticks/583ms|2 ticks/33ms|20 ticks/333ms|
| Legal READY-parry input / successful contact |75/82|47/49|60/67|
| Immediate READY retreat |evades|first hit applies|evades|

Only contact/active timing differs between B/C; C's X1 still deals ten damage
and generates an orb without interrupting the committed windup. Marker-relative
parry is reported separately from the exact old policy, whose fixed0.68 press
expires before C1.1 contact. No early defence press is buffered or promoted.
Single-parry probes later idle and may take a separate strike; final observation
HP is not the first-contact success metric.

**No-parry opener→READY disengage→Cast→melee policy:** X1 without L2; on actual
READY start Charging and move away until gap≥135; pivot one real movement tick
toward Enemy; release once charged and READY; queue melee only at actual Cast
progress≥0.6. No initial resources or action cancels. A and C finish HP100/
Enemy170 with one Cast and two real generated orbs; B completes the same route
after taking its first hit, HP90/Enemy170. A READY47/pivot64/release79; C
READY47/pivot65/release79, commitment/start80, launch98 and melee152. C's
committed strike67 misses while the player is already outside its range. This
is a concrete viable no-parry route; it is a telemetry-driven policy, not proof
of intuitive human spacing.

Prepared parry→X→READY-spacing also succeeds at HP100 in C: parry67, READY111,
retreat before next contact146. The prior parry/generate/gap135/Cast/melee cycle
also completes at HP100/Enemy170. No mandatory use of parry or Casting is inferred.

**Default held-Charging close cycle:** release35, commitment36, Cast starts48.
A launches66 and completes follow-up120, HP100/Enemy167. B is interrupted49
before launch, HP70/Enemy190. C launches66, but Enemy67 interrupts Cast recovery;
no follow-up is queued before the interruption, observation HP80/Enemy177.
Thus C allows the projectile but does not make that unguarded close cycle safe.
The original separate script later manually retries melee105 after reaction,
not an unchanged completed-Cast handoff120; that difference remains visible.

Prepared real X2/X5 hits at Poise10 retain existing higher-Impact reactions and
cancellation. In a real C active clash at146, incoming PlayerImpact40 minus
EnemyPoise10 minus activeEnemyImpact20=10 gives Enemy Level1; the reverse
20−0−40=−20 rejects the Enemy strike as CLASH_LOST. No clash/eligibility rule
changes. All observed positive action IDs have at most one Player-contact event.
Actual retreat tests keep origin/facing committed, miss once and expose no
sustained recovery: active_end equals length1.3.

### Exact original policies (unchanged inputs)

| Policy | A | rejected B reference | C |
| --- | --- | --- | --- |
| Melee-first |victory1150/19.17s, HP100|defeat614/10.23s, Enemy100|defeat997/16.62s, Enemy80|
| Fixed0.68 parry/punish |victory1639/27.32s, HP100|victory1240/20.67s, HP100|defeat794/13.23s, Enemy100|
| Spacing/Cast |victory1164/19.40s, HP60|defeat1040/17.33s, Enemy170|defeat1238/20.63s, Enemy157|

C counts: melee-first22 starts/12 hits/two reported misses, zero Casts, ten
applied incoming strikes/one lost Enemy clash; old parry policy10 starts/hits,
zero successful parries and ten applied strikes; spacing3 starts/hits, one Cast
and ten applied strikes. A counts retain round6 values. The old parry input is
now mistimed, not a valid test that correct new-timing parries are impossible.
The separate native-marker-relative parry probe succeeds as above.

Unbroken close melee also loses in the new continuation observation. Its result
includes existing contact misses (e.g. X2 before the first C strike), so loss
alone is not proof of improved AI or balanced pressure. Compact geometry/lunge
and placement remain unchanged and unmodified; no diagnosis is promoted into a
production fix. Prior clash-suite A14 failures remain unresolved/out of scope.

Original script results: A11/11 exit0; C10/11 exit1, zero engine errors. C's sole
failed assertion is the old timed parry's missing PARRIED result. Cast inputs
and subsequent outcomes remain recorded, not forced to match A. Logs per
variant `original-input-output.log`/`original-input-engine.log`; retained final
C replay uses `original-input-output-final.log`/`-engine-final.log`.

### Shared tutorial cadence and lifecycle

Actual shared tutorial Poise0/config/Endurance are unchanged in A/B/C; only C's
shared native clip differs. In the same idle observation, A/B contacts occur
49/110/171/232 (61-tick cycles), C67/146/225 (79-tick cycles). First hit delays
18 ticks/0.3s; subsequent cycle length increases18 ticks/0.3s. At263 ticks,
A/B Player60, C70. Stage retirement cancels the pending clock without further
damage; reactivation starts a fresh native action. No new recovery timer.

The first Fire-only tutorial defeat attempt stopped at Enemy36 in all variants
under existing Endurance. It was retained as `choice-output-fire-only-tutorial.log`
and `choice-report-fire-only-tutorial.json`, not turned into a fabricated death
claim. A separate actual-key policy rotates Fire/Water/Air/Earth before attacks,
preserving Endurance; all variants reach real Enemy defeat and remain DEAD after
stage retirement/reactivation. Final sample405, Player100/Enemy0, with real
school/contact events. No HP/resource/Endurance edits supply that evidence.

### Graphical replay and recommendation

Worker used only headless processes. `--capture` runs no-defence opener,
marker-relative READY-parry and no-parry disengage/charge/Cast/melee, with matched
targets17,47,49,60,67,78,96,98,110,146,150,152,164,185. Full actual gameplay viewport
PNGs and after-draw annotated JSON cover READY, continued windup/contact and
retreat/Cast. Some cases end before later targets; no image count or rendering
success is claimed until supervisor executes this branch. No synthetic frames.

Use `$evidenceRoot` for this worker's evidence directory, run A then C (optional
B uses the same new fixture on an independent B copy), bound process to120s:

```powershell
$variant = 'C'
$work = Join-Path $evidenceRoot "round-7-$variant"
$env:APPDATA = Join-Path $work 'profile'
$env:LOCALAPPDATA = Join-Path $work 'profile'
& (Join-Path $work 'engine/Godot_v4.7.1-stable_win64.exe') --path (Join-Path $work 'project') --rendering-method gl_compatibility --script res://tools/tests/overnight_gym_choice_window_test.gd --fixed-fps 60 --quit-after 1800 --log-file (Join-Path $work 'capture-engine.log') -- --capture "--variant=$variant" "--output=$(Join-Path $work 'captures')"
```

Expected names include `captures/C_X_no_defence_f067.png`,
`C_X_READY_parry_f067.png`,
`C_opener_READY_disengage_charge_cast_melee_f096.png`, plus report JSON. Headless
choice command adds `--headless --audio-driver Dummy`, omits capture, uses20000
limit and A/B/C variant. Original suite limit12000, no parameter changes. Helper
baseline replay limit16000 with variant baseline-replay. All subprocesses used
120-second timeouts, isolated APPDATA/LOCALAPPDATA and Godot4.7.1 Windows.

**Recommendation:** provisionally retain C only after supervisor-rendered review
confirms the telegraph/pivot/Cast sequence. It supplies a measured20-tick choice
window and a viable no-parry full cycle; tested continuous melee does not become
an automatic full-Health win. Existing contact misses confound broader combat
judgment, old policies are not optimal, and the global tutorial cadence change
must remain explicit. Human/controller acceptance and final tuning are open.
No working promotion or new rule/architecture is performed. All owned processes
ended; READY_FOR_SUPERVISOR_REVIEW. No desktop control, commits/publication or
autonomous next round.

## Round7 supervisor disposition / U-003

C is **held**, promising but not promoted pending contact clarity. Supervisor
actual GPU A/C runs each passed87 checks, produced38 PNGs, exited0 with zero
engine errors. Evidence: per-variant supervisor-capture logs and
`supervisor-captures/` reports/images. Inspected C no-defence60 and spaced-Cast96
support the visible telegraph/sequence and20-tick opportunity, not human feel.
Actual shared tutorial Poise0 was confirmed and remains unchanged.

U-003: Major, NEEDS_EVIDENCE, implementation-versus-fixture gap. Supervisor
independently reproduced exactly14 FireX2/X3 actual-contact/reaction assertions
on retained ordinary A, exit1/zero engine errors, in
`round-7-A/supervisor-clash-output.log` and `supervisor-clash-engine.log`.
No contact redesign or production fix was authorized; DUM-E owns diagnosis.

## Round8 — contact geometry diagnosis and fixture correction

Round began23:23:54 HKT October19,20-minute budget, original cutoffs unchanged.
Before edits, approved test/status/Combat/ledger files were copied with hashes
to `round-8-before/`; new-probe absence recorded. Actual changed paths:

- `tools/tests/clash_formula_test.gd`
- `tools/tests/overnight_contact_probe_test.gd` (new)
- `docs/IMPLEMENTATION_STATUS.md`
- `docs/departments/combat.md`
- `docs/iterations/2026-10-19-overnight.md`

No Might, resolver, Geometry, animation, scene, tuning or other production edit.
New `round-8-candidate/project/` is an ordinary-source copy matching round5;
all earlier failure logs, C and rejected branches remain intact.

### Causal evidence

Existing suite reproduced **14 failures**, exit1/zero engine errors, before
repair (`before-output.log`, `before-engine.log`). Isolated diagnostic-only
`clash_instrumented.gd` logs selected move/chain/action ID, native clock/marker,
captured/live geometry, actual transforms/masks/layers, collision count, Health
and reaction events; retained `instrumented-output.log`/`-engine.log`.

Fixture selects FireX1–X5 correctly, uses each move's configured windup and
Might's phase-speed mapping, and reaches its native contact marker. Native
contacts are .6/.46666667/.6/.7/.6 respectively; no shared-marker assumption is
used. `_hit_emitted` becomes true for all moves, and clocks are just beyond
their respective markers. X2/X3 have zero ShapeCast collisions and zero reaction
evaluations, HP200; the other moves produce one contact/evaluation and HP190.

At the old fixture's right-facing gap48, frozen Player origin is(−80,0), global
scale(2,2). Enemy origin(−32,16), capsule center(−43,12.65), radius12.4/height68.7,
world bounds(−55.4,−21.7,size24.8×68.7). Attack mask2 intersects Enemy layer10;
this is not a mask/filter exclusion. Player local circle radius16 becomes world
radius32. Query Y22 lies along the capsule's straight segment. Thus horizontal
distance compares directly with radii sum **44.4** (ShapeCast margin0):

| Move | Captured contact world X | Capsule-axis distance | Native contact |
| --- | ---: | ---: | --- |
| X1 |0|43|hit|
| X2 |6|49|miss|
| X3 |4|47|miss|
| X4 |−20|23|hit|
| X5 |−10|33|hit|

These come from current native offsets, including X4's contact-time30 and X5's35,
not stale JSON reach labels. X2/X3's zero-length target vectors make point-circle
queries; the authored circle is ahead of the too-close collider. Changing only
target placement to gap64 makes all five hit and passes all original198
assertions (`inside64-output.log`), without changing geometry or timing.

The new probe runs **42 fixture cases** across gaps16/48/64/180 and both facings,
plus repeat old X2/X3 placement with three physics waits rather than one.
Independent `direct_space_state.intersect_shape` at the captured world transform
agrees with actual ShapeCast/damage in every case; extra waits preserve the
misses. Entity filtering, invincibility, stale action ID or cancellation cannot
cause these two failures: no contact event reaches those consumers. Inside hits
do reach them and preserve damage/reaction/cancellation/invincibility behavior.
The existing generic clash/transaction/ID checks remain intact.

### Real InputMap chains, separately labeled

The manual cases explicitly seed fixture chain position and advance the native
action clock with movement frozen. They are not ordinary-player evidence.
Five additional chains use real InputMap L2/X, actual engine physics and queued
X1→X2→X3 requests. Only initial placement/optional AI disable is scenario setup;
there are no synthetic hit/reaction/resource events.

| Real chain | X1 | X2 | X3 |
| --- | --- | --- | --- |
| Ordinary close gap56, right, AI active |hit at17|miss at63|miss at105|
| Inside gap64, right, AI disabled |hit17|hit63|hit105|
| Inside gap64, left, AI disabled |hit18|hit64|hit106|
| Outside gap180, right, AI disabled |miss17|miss63|miss105|
| Outside gap180, left, AI disabled |miss18|miss64|miss106|

Ordinary close X2/X3 axis distances at query are47.574/45.525, both above44.4;
the independent spatial query agrees. The actor lunge and target displacement
change separation before the captured point-circle query. Inside right distances
are29.99998/40.04225/36.49977; inside left12.99997/23.04170/19.49907, all within.
Facing asymmetry follows the unchanged Enemy collider's X−11 offset, not a new
mirror rule. Detailed actor/live/captured transforms, actual collider IDs,
contacts, clocks and outcomes are in `project/contact-probe-report.json`.

**Classification:** the14 regression failures are an invalid positive-test
placement assumption. Ordinary close misses are also real spatial outcomes of
the authored data and motion. No clock/query-delivery/resolver implementation
fault is demonstrated. Whether the current compact geometry/lunge should hit
those close positions is an authoring/game-feel question, not settled by fixing
the fixture. No production repair or new contact rule is inferred; C stays held.

### Small test-only correction / checks

Positive fixture gap48→64, with an explicit units/setup comment. All198 original
reaction, damage, cancellation, duration, hurt/knockback and invincibility
assertions remain. New mirrored inside64 and negative48/right plus180/both-facing
X2/X3 cases check query occurrence, no damage/reaction/cancellation/generation on
miss, and no delayed/repeated hit. Coupled-reaction helper accepts a signed
direction for mirrored displacement; default right-facing behavior is unchanged.

- Corrected full suite **244/244**, exit0/zero engine/resource errors:
  `corrected-output.log`, `corrected-engine.log`.
- Independent geometry/real-input probe **159/159**, exit0/zero errors:
  `contact-probe-output.log`, `contact-probe-engine.log`, full JSON above.
- Meaningful negative-coverage proof: isolated `clash_overreach_mutant.gd`
  changes only a test-owned action's private query radius to500 in negative
  cases. No production file is mutated. It intentionally fails24 assertions,
  exit1/zero engine errors, `mutant-output.log`/`mutant-engine.log`. Inflating
  reach cannot silently make this correction pass.
- Original input **11/11** and Cast **45/45**, exit0/zero engine/resource errors:
  `input-output.log`/`input-engine.log`, `cast-output.log`/`cast-engine.log`.
  All eight full ordinary reports exactly match round5 after removing only
  attacker_id/receiver_id; `input-comparison.json` confirms equality.

The intermediate instrumented64-placement run passed198 but reported13
resources still in use at shutdown. That output is preserved as a caveat, not
represented as clean. Final corrected244 run is clean. The original14 and
intentional-mutant24 failures remain separately labeled and retained.

All637 runtime/project files hash-match retained round5, digest
`e5ec3b1083d6885e1aae6254aaf44098c4ad83914ae8cba8e4bad61541e7390b`.
Current source/candidate runtime deltas are empty; only test/record files change.
Exact before/after test/record hashes: `round-8-candidate/round-8-identity.json`.

Commands use isolated Godot4.7.1 engine/profile,120-second subprocess timeouts,
`--headless --audio-driver Dummy --path <candidate>/project --fixed-fps60
--quit-after <limit> --log-file <named-engine-log> --script <script>` (flags are
separate arguments: `--fixed-fps 60`). Corrected suite uses
`res://tools/tests/clash_formula_test.gd`, limit6000 and `--frame-delay25`
(separate arguments `--frame-delay 25`); probe limit10000; original input12000;
Cast10000 with `-- --variant=round8`. Isolated instrumentation/inside/mutant
scripts use their names above. Logs contain actual invocations' outputs.

U-003 causal evidence is ready for supervisor review; no self-issued submission
or gameplay clearance. All owned processes ended; READY_FOR_SUPERVISOR_REVIEW.
No desktop input, commits/push/publication, C promotion or autonomous next round.

## Round8 supervisor disposition

U-003 resolved as invalid positive-fixture placement, not a demonstrated gameplay
implementation defect. Retain test-only correction/all original198 assertions
plus negative/mirrored cases; bounded **IMPLEMENTATION_REVIEW_COMPLETE**, no
game/submission clearance. Supervisor independent244/244 replay exits0 but emits
shutdown-only46 ObjectDB/16-resource warnings; no runtime assertion/logic errors.
Evidence: `round-8-candidate/supervisor-corrected-output.log` and
`supervisor-corrected-engine.log`. These coexist with the worker's clean run;
not every run is represented as resource-clean. Ordinary close spatial misses
remain an authoring concern; no unrelated audio/OS or production repair.

## Round9 — isolated FireX2/X3 close coverage

Round began October19 23:44:31 HKT,25-minute budget and original cutoffs unchanged.
Approved before snapshots: `round-9-before/` contains current contact helper,
prior ledger, hashes and new-file absence. Actual working edits: new
`tools/tests/overnight_close_contact_test.gd` and this ledger only. Existing
contact helper is unchanged, SHA
`012b37efd41816152cc31680596cda55d06b950db9584cf129d314f074b4d77e`.
No working gameplay resource or production test expectation is changed.

Independent retained copies:

- `round-9-A/project/`: ordinary retained production, FireX2 localX43/X3X42.
- `round-9-D/project/`: only those two clips' existing position keys use X40.
- `round-9-C/project/`: held C, unchanged Poise10/Enemy contact1.1/end1.3.
- `round-9-E/project/`: C plus exactly the same two inward offsets as D.

Actual source values were confirmed before constructing D/E. Each clip has two
existing AttackCast:position keys; only their X component changes. Y11, timestamps,
zero target vectors, radius16, markers, sprite poses, length, lunge, Impacts,
damage, actor/collider scale, all other clips and JSON/mirror remain byte-identical.
Across637 runtime/project files, A→D and C→E each differ in **only** fire_x2.tres
and fire_x3.tres. Exact byte-replacement verification confirms no other fields.
Working resources still equal A; C/D/E remain unpromoted.

| Resource | A/C SHA-256 | D/E SHA-256 |
| --- | --- | --- |
| fire_x2.tres |882dccfbadf937c41eb4217f0583294f5052337454417c6fbbcfcc8848aeed43|39be9aaf1d05d85269b22093419de39864de93a0b09481f877f60baf83431545|
| fire_x3.tres |581e926f9f2fe65c75f01c19aad1d8c679f78b33327db3946d0c05fb7d1b5555|92717c53fc2e30915c393c426a96fe21537476ef7ac0a6cbd8112f87ce49857b|

D runtime digest `72125bff19cb507e48884b709e0929b200a7442c6caaeaf04168a495fd33d584`;
E `a58538980c0aff922ca7f328f1583f450dc0e55af5f6c7b9ef49371ecf108995`.
`round-9-identity.json` records full source/delta/fixture hashes for all variants.

### Coverage measurement and real contacts

New probe inherits current geometry/input helpers without editing them. It
separates156 frozen, labeled fixture selections/manual clocks from ten actual
InputMap chains per variant. All independent overlap/actual query comparisons
agree; far misses and once-only application are checked. A501/501, D505/505,
E505/505 checks pass, exit0/zero engine/resource errors; counts vary with actual
applied/formula events. Reports: `project/close-evidence/<variant>-close-report.json`;
logs `close-output-final.log`, `close-engine-final.log` per folder (earlier
same-count runs without extra body-motion metadata remain separately retained).

Player scale2 turns X2's3-local-pixel inward shift into6 world pixels, and X3's
2-local shift into4. Radius stays32 world pixels; capsule radius12.4/offset−11
and query margin0 remain. For the frozen vertically overlapping capsule setup,
calculated horizontal root-separation intervals, supported by sampled edges:

| Move/facing | A interval | D interval | Effect |
| --- | --- | --- | --- |
| X2 right |52.6–141.4|46.6–135.4|gains6 px near, loses6 px far|
| X3 right |50.6–139.4|46.6–135.4|gains4 px near, loses4 px far|
| X2 left |30.6–119.4|24.6–113.4|gains6 px near, loses6 px far|
| X3 left |28.6–117.4|24.6–113.4|gains4 px near, loses4 px far|

Intervals are world pixels for this placement, not a universal range independent
of vertical position. Sampled integer right edges move141/139→135, left119/117→113;
near edges53/51→47 right and31/29→25 left. There is no radius/reach inflation.

Actual InputMap X1→X2→X3, original inputs/lunge/body collision preserved:

| Scenario | A applied hits / EnemyHP | D applied hits / EnemyHP |
| --- | --- | --- |
| Ordinary close right, initial gap56, AI active |1/190|3/170|
| Inside64 right or left, AI disabled |3/170|3/170|
| Too-close/body-blocked right30 or left16, AI active |1/190|3/170|
| Outer right146, AI disabled |2/180|1/190|
| Outer left132, AI disabled |1/190|0/200|
| Far180 both facings, AI disabled |0/200|0/200|

Initial too-close placements recover through the real bodies: at right X2,
root separation is approximately49.40, left27.40, rather than remaining at
the setup30/16. A misses X2/X3 there; D hits. Ordinary close A/D X2 has the same
actual separation49.426; A circle excludes it, D includes it. D's additional
qualifying hits then change Enemy reaction displacement; later actual body
positions can diverge although authored lunge/body-motion code is unchanged.
CharacterBody slide collisions directly identify FinalEnemy as the X2 blocker;
A/D consume the same0.81781045 lunge fraction there. Captured X1/X2/X3 motion
profiles compare equal; the extra target reaction explains later displacement.

Outer tradeoff is also a real input outcome: right X2 at actual gap136.458
hits A and misses D; left X2 at117.458 hits A and misses D. Later X3 separation
can differ because A's preceding hit causes recoil, so chain totals are not
treated as fixed-pose geometry equivalence. No phantom damage/generation occurs
outside shifted circles. Far chains have zero applied hits/orbs in all variants.

Contact markers/action clocks and sprite sequences remain identical. Receiver
events, raw Health deltas, query presence and generation are recorded separately.
In five-input inside64 A/D, X4 overlaps at152 but returns INVINCIBLE: observed
Health delta0, no extra generation; four of five contacts apply. E's existing
Poise10 shortens its qualifying reaction levels/durations, so that same later
X4 is eligible after the reaction ends and all five apply. No invincibility or
clash acceptance rule is changed/forced. Each chain's generated count matches
actual APPLIED outcomes, not all spatial overlaps. Query records distinguish
native once-only query from an already-consumed active clash contact.

### Policies, existing checks and held-C implication

The exact original script is unedited. A/D each11/11, exit0/zero engine errors;
all eight full scenario/event dictionaries are exactly equal after removing only
attacker_id/receiver_id (`round-9-comparison.json`). Melee-first remains
1150 ticks/19.17s/HP100; parry-punish1639/27.32s/HP100; spacing-Cast1164/19.40s/
HP60 with9 Casts. The actual default generate/charge/release/melee loop keeps
the same events and results. This adjustment fixes the sampled close coverage
without claiming a global score improvement.

C/E exact original policies retain the old timed-parry assertion failure
(10/11, exit1), with zero engine errors. Fixed0.68 input expires before their
1.1 contact; it is not an assertion that well-timed parry is impossible. Results:

| Policy | C | E |
| --- | --- | --- |
| Melee-first |defeat997/16.62s, Enemy80|defeat1076/17.93s, Enemy50|
| Old fixed parry |defeat794/13.23s, Enemy100|same|
| Spacing/Cast |defeat1238/20.63s, Enemy157,1 Cast|same|

Current choice fixture also passes C69/E72, exit0/zero errors. Close continuation
observation changes defeat982/Enemy80→1061/Enemy50; corrected coverage improves
damage but does not restore an automatic full-Health melee win in this policy.
The legal no-parry opener/READY-disengage/charge/Cast/melee route remains HP100/
Enemy170 with one Cast in both; the default stationary Charging cycle remains
HP80/Enemy177 and interrupted recovery in both. Inputs are unchanged; none was
optimized to force a desired winner. Earlier C pressure evidence was partly
confounded by misses, but its sampled pressure does not disappear in E. Human
balance/readability remains unverified; C's held disposition is not lifted.

Unchanged baseline suites: A corrected clash244/244 clean; D fails exactly8
old gap48/right negative assertions because those points are now deliberately
inside X2/X3. The other behavioral assertions remain; no production test
expectations were rewritten for an unretained candidate. A/D Cast45 each pass
clean. A/D broad style595 each pass; D run clean. Initial A style run has a
five-resource shutdown warning; a fresh disposable style copy with frame-delay25
passes595/zero errors. Both logs retained. Persistence tests run in separate
style-project copies so retained playable source/config stays untouched.

Logs per variant: `original-input-output.log`/`-engine.log`, `choice-output.log`/
`-engine.log` for C/E, `clash-output.log`/`-engine.log`, `cast-output.log`/
`-engine.log`, `style-output.log`/`-engine.log`; A clean retry uses
`style-clean-output.log`/`style-clean-engine.log`. Reports remain in each
project's close/choice/Cast evidence folders and original input JSON.

### Matched renderer fixture, prepared for supervisor

Worker uses headless only. `--capture` runs ordinary close/right and inside64/
right real chains, capturing first actual X2/X3 contact-state frames, including
misses. It uses actual existing art and the **existing private-run player hitbox
overlay**; that debug setup is explicit in JSON and does not save config/assets.
Full viewport PNG metadata includes native clock, captured/live geometry, world
circle/capsule bounds/separation, collider IDs, independent overlap and emission
type. APPLIED/INVINCIBLE/CLASH_LOST/reaction/generation are separate report events.
It waits for real frame-post-draw and verifies the physics frame, not a synthetic
diagram. Actual GPU/PNG success awaits supervisor execution.

Set `$evidenceRoot` to this worker's task evidence directory; run A then D,
optionally C/E on their independent copies, with120-second process timeout:

```powershell
$variant = 'D'
$work = Join-Path $evidenceRoot "round-9-$variant"
$env:APPDATA = Join-Path $work 'profile'
$env:LOCALAPPDATA = Join-Path $work 'profile'
& (Join-Path $work 'engine/Godot_v4.7.1-stable_win64.exe') --path (Join-Path $work 'project') --rendering-method gl_compatibility --script res://tools/tests/overnight_close_contact_test.gd --fixed-fps 60 --quit-after 1400 --log-file (Join-Path $work 'capture-engine.log') -- --capture "--variant=$variant" "--output=$(Join-Path $work 'captures')"
```

Expected matching names include `D_ordinary_close_right_fire_x2_f063.png` and
`D_ordinary_close_right_fire_x3_f105.png`, corresponding A files and inside64
cases, plus report JSON. No image count or visible alignment success is claimed
before rendering. Headless close command adds `--headless --audio-driver Dummy`,
omits capture, limit16000. Original input limit12000; choice20000; clash6000 with
frame-delay25; Cast10000; style6000 (clean A retry adds frame-delay25). All use
fixed60 simulation, isolated APPDATA/LOCALAPPDATA, Godot4.7.1 and120-second limits.

**Recommendation:** provisional D retention after supervisor-rendered pose/body/
circle alignment review, with the measured6/4-pixel outer loss explicit. This is
a small close-coverage trade, not an implementation/formula repair or universal
improvement. Held C should be judged against E if D is retained; E removes the
sampled close misses without removing tested pressure, but does not justify
automatic C/E promotion or human acceptance. Working resources remain A. All
prior logs/copies remain; all owned processes ended. READY_FOR_SUPERVISOR_REVIEW.
No desktop input, commits/push/publication or autonomous next round.

## Round9 supervisor disposition

D retained **provisionally** for close melee contact feel after bounded
tech-postflight review; no shape/radius/query-rule change authorized. Actual
GPU A14/D16 capture checks, four PNGs each, exit0/zero engine errors. Evidence:
per-round9 A/D supervisor-capture logs and `supervisor-captures/` images/JSON.
Matched ordinary X2 frame63 inspection shows A's forward circle leaves Enemy190/
one orb, while D's6-world-pixel inward shift yields Enemy180/two orbs at the same
attack pose/clock. This supports the close swing/contact alignment, not final
human/controller acceptance. Outer losses6/4 remain explicit; original policies
are unchanged. Independent runtime comparison confirmed only the two clips
differed. Held C/E have not been promoted or given full encounter clearance.

## Round10 — exact reviewed D promotion and regression

Round began October20 00:04:14 HKT,20-minute budget and original cutoffs apply.
All12 approved paths were snapshotted with hashes under `round-10-before/`
before editing. Exact D resource hashes were verified before copying bytes:

- X2 `39be9aaf1d05d85269b22093419de39864de93a0b09481f877f60baf83431545`
- X3 `92717c53fc2e30915c393c426a96fe21537476ef7ac0a6cbd8112f87ce49857b`

Both existing AttackCast:position keys use localX40/Y11. No other component/key
timestamp, radius16, target0, marker, sprite, lunge, Impact or source behavior
changes. Fire Cast candidate and U-001/U-002 remain retained. Gym Enemy stays
Poise1/native contact0.8/end1.0, with no recovery tail. C/E remain held. Actual
current X4 contact(30,11), later key(−11,11), and X5 contact(35,11) are unchanged;
old prose endpoint46/50 values are not copied into current data/documentation.

Actual changed paths this round:

- `config/attack_animations/fire_x2.tres`, `fire_x3.tres`
- `tools/tests/clash_formula_test.gd`
- `tools/tests/overnight_contact_probe_test.gd`
- `tools/tests/overnight_close_contact_test.gd`
- `docs/GAME_DESIGN.md`, `docs/TECH_ARCHITECTURE.md`
- `docs/IMPLEMENTATION_STATUS.md`, `docs/ATTACK_STYLES.md`, `docs/GYM.md`
- `docs/departments/combat.md`
- `docs/iterations/2026-10-19-overnight.md`

Docs label retained OVERNIGHT CANDIDATE, pending human/controller acceptance,
and preserve the close-gain/outer-loss tradeoff6/4 world pixels under scale2.
Only affected passages are synchronized; no whole-document validation claim.
Historical U-003/pre-retention offsets remain clearly historical. Current native
contact table is authoritative over old initial scalar reach presets.

### Normative tests without weakening reaction coverage

All original198 assertions remain. Gap48/right is now intentionally inside for
X2/X3 and runs the same full damage/reaction/cancellation/lifetime/knockback
assertions. Verified frozen inner16/right and left, plus far180/right and left,
remain negative cases. Negative checks still prohibit damage, reaction,
cancellation, generation and delayed repeat contact. Main all-move positive64
is retained; mirrored signed-displacement checks remain. Full suite now270.

Contact probe updates its old48-miss label to retained positive coverage, adds
verified inner16 negatives and an actual ordinary close three-hit expectation.
It now164 checks. Close probe retains independent spatial/collider data,
APPLIED/INVINCIBLE/CLASH_LOST/Health/generation separation and adds the three
reviewed close/body-blocked chain expectations; now508. No redundant cloned
implementation or radius inflation is used. Actual overlap during invincibility
still has measured Health delta0 and no additional orb.

Private-action overreach mutation proof remains meaningful: the isolated mutant
radius500 intentionally fails32 negative assertions, exit1/zero engine errors.
Only the test-owned action is changed; production files are untouched by the
mutation. `mutant-output.log`/`mutant-engine.log` are retained separately.

### Fresh source / evidence

New `round-10-candidate/project/` is copied fresh from current runtime roots and
tests, with isolated engine/profile. Persistence suite uses a disposable
`style-project/` copy. Godot4.7.1.stable.official.a13da4feb Windows, fixed60 Hz.

| Suite | Checks | Result |
| --- | ---: | --- |
| Corrected clash/formula/coupling |270|exit0, zero engine/resource errors|
| Native geometry and InputMap contact |164|exit0, zero errors|
| Close/outer/body-blocked/invincibility |508|exit0, zero errors|
| Original input/policies |11|exit0, zero errors|
| Focused Cast |45|exit0, zero errors|
| Broad styles/completion/persistence |595|exit0, zero errors|
| Enemy configuration/native timing |152|exit0, clean serial rerun|
| Shared Gym/tutorial lifecycle |67|exit0, zero errors|

All eight ordinary reports and all ten full contact-chain dictionaries exactly
match reviewed round9 D after removing only attacker_id/receiver_id. Evidence:
`reviewed-D-comparison.json`. This preserves the reviewed outcomes, not a score
improvement claim: melee-first1150/HP100, parry1639/HP100, spacing1164/HP60.
All637 current candidate runtime files equal source and reviewed D. Relative
to round5 only the two native resources differ; JSON/mirror, all non-X2/X3
assets/code and authored motion/timing are byte-identical. Runtime digest:
`72125bff19cb507e48884b709e0929b200a7442c6caaeaf04168a495fd33d584`.

Fresh first import repeats the known unresolved saved main-scene UID error
before building its cache; config is not changed. Initial parallel Enemy152
passes but emits a six-resource shutdown warning. A serial rerun with engine
frame-delay50 passes152 and exits0 with zero engine/resource errors. All these
logs are retained; no claim that every historical run is resource-clean or that
audio/OS code was repaired. No other runtime assertion/logic error observed.

Logs in `round-10-candidate/`: `clash-output.log`/`-engine.log`,
`contact-output.log`/`-engine.log`, `close-output.log`/`-engine.log`,
`input-output.log`/`-engine.log`, `cast-output.log`/`-engine.log`,
`style-output.log`/`-engine.log`, `lifecycle-output.log`/`-engine.log`, initial
`enemy-output.log`/`-engine.log`, clean `enemy-serial-output.log`/
`enemy-serial-engine.log`, `import-output.log`/`-engine.log` and mutation logs.
Full before/after hashes and source identity: `round-10-identity.json`.

Runtime command prefix: isolated engine `--headless --audio-driver Dummy --path
<project> --script res://tools/tests/<suite>.gd --fixed-fps 60 --quit-after
<limit> --log-file <named-engine-log>`, isolated APPDATA/LOCALAPPDATA and120s
subprocess timeouts. Limits: clash6000 (frame-delay25); contact10000;
close16000 with `-- --variant=round10`; original12000; Cast10000 with round10
variant; style6000 in style-project; Enemy6000 (initial delay25, clean retry50);
lifecycle12000 with round10 variant. Mutation uses root isolated mutant script,
limit6000/delay25. No graphical worker process was run.

### Morning comparison / status

Use the current explicit Gym scene/controller to compare close and body-blocked
X1→X2→X3, then outer spacing. Judge whether the small inward centers fit the
existing sword poses, including the real6/4-pixel outer loss. Check Charging,
queued/released Cast and return to melee under pressure; invincibility/clashes
can legitimately reject an overlap and must not be treated as lost input.
Original A/D render evidence remains available. Current source is baselineEnemy,
not held C/E; no new Enemy or final tuning approval is implied. F5 UID remains
deferred; no export/live/submission or whole-project validation is claimed.

READY_FOR_SUPERVISOR_REVIEW. All owned processes ended; exact reviewed data
retained provisionally, human/controller acceptance pending. No desktop input,
commits/push/publication or autonomous next round.

## Round10 supervisor disposition

Exact working D hashes independently equal reviewed resources. Supervisor
reviewed source/negative coverage/candidate docs and replayed fresh close508/508,
exit0/zero engine errors: `round-10-candidate/supervisor-close-output.log`,
`supervisor-close-engine.log`, report under `supervisor-close/`. Close data/test
updates retained provisionally, bounded **IMPLEMENTATION_REVIEW_COMPLETE**.
Human/controller acceptance and import/shutdown caveats remain; Enemy baseline
is unchanged. No whole-game/submission clearance.

## Round11 — full ordinary encounters A/E

Round began October20 00:18:56 HKT,30-minute budget and original overnight
cutoffs unchanged. Only working changes: new
`tools/tests/overnight_duel_policy_test.gd` and this ledger. Prior ledger/new
file absence snapshot: `round-11-before/`. No helper or production edit.

Fresh independent `round-11-A/project/` equals retained round10. E copies only
the exact held `scenes/gym.tscn` Poise10 override and `melee_swing.tres` authored
contact1.1/end1.3 from reviewed round9 E. No tail/timer, new tuning or policy
framework. Across637 runtime/project files these are the only A/E differences.
A digest `72125bff19cb507e48884b709e0929b200a7442c6caaeaf04168a495fd33d584`;
E `a58538980c0aff922ca7f328f1583f450dc0e55af5f6c7b9ef49371ecf108995`.
E byte-for-byte matches the earlier E runtime; A equals current working source.
Shared tutorial JSON remains actual Poise0; JSON/mirror/noncandidate assets
are unchanged. `round-11-identity.json` records exact deltas/hashes.

### Explicit deterministic policies / setup

All attempts start actual Gym Player100/Enemy200, empty queue, Heat0, normal
candidate rules. Default leaves authored positions; mirrored starts Player80/
Enemy−80; wall-pressure starts Player−530/Enemy−370. Position changes occur
before commitment; no stats/resources/health/action/time/geometry methods
manufacture success. All controls use real InputMap events/physics.

Policies are public-telemetry deterministic examples, not human/optimal play:

1. **Parry/punish:** approach to about55px, press L1 only when actual READY and
   not already defending at native contact−0.12s; upon actual PARRIED outcome
   release L1 then pulse one X. Wait through the full action/reaction before
   returning to guard; no parry cancel or held-window exploit. Failed incoming
   events recover normally. Native marker is0.8 in A,1.1 in E. Old fixed0.68
   losses remain historical evidence, not silently rewritten.
2. **No-parry spacing/Cast:** if no existing generated resource, approach and
   send one X from READY without L2. At actual READY with resources, start L2
   and retreat until gap≥135; pivot one real movement tick toward Enemy, wait
   for charged resource/READY, release; queue one X only during actual Cast at
   progress≥0.6. After melee ends, adapt to actual remaining queue; reuse its
   generated orb rather than seed another. On an actual reaction, wait. A lost
   charge is released via input after READY, accepting existing failed-Cast
   cost when no marked orb remains; no private marking/action reset is used.
   If the wall prevents135, do not invent a dodge/cancel or force an unsafe
   release to win. Record the resulting recovery/defeat.

Action kind is tracked from public action outcomes. Private pending/buffer/
movement-lock fields are read only for diagnostics, not policy control. Inputs,
decision transitions, positions, public action/reaction results and periodic
state snapshots are saved. Own policy labels are not engine states. Terminal
movement/action freezes are expected UI behavior and not classified as stale.

Each full attempt is bounded5400 action-loop ticks (90 simulated seconds),
with small setup/result-verification ticks separately present in total frame
count. Four policy/variant processes each run three starts and have120s wall
timeouts; no single unbounded process. All12 attempts ended naturally, none
timed out. Times below are the report's total physics-tick count/60, including
initial observation and two result-settle ticks.

### Full outcomes

| Policy/start | A outcome / seconds / HP / EnemyHP | E outcome / seconds / HP / EnemyHP |
| --- | --- | --- |
| Parry default |win26.35/100/0|win26.65/100/0|
| Parry mirrored |win26.43/100/0|win26.73/100/0|
| Parry wall |win26.37/100/0|win26.67/100/0|
| Spacing default |win29.02/50/0|win24.70/90/0|
| Spacing mirrored |win28.90/50/0|win24.78/90/0|
| Spacing wall |defeat23.73/0/80|defeat16.80/0/120|

Each parry fight:20 actual parries,20 melee APPLIED hits, no Casts or applied
incoming damage. A X1 hits qualify for20 reactions; E X1 hits qualify for0,
using the unchanged formula. There are12 orb-created events and the remaining
storage-overflow attempts in each20-hit fight; no Cast resources are used.

Spacing default/mirror: A13 actual melee hits+7 Casts, five applied incoming
strikes; E11 melee hits+9 Casts, one applied strike. Both deliver20 actual
damage contacts. E has9 qualifying Enemy reactions from higher melee, while
its Level1 Cast/X1 hits retain nonqualifying damage. No phantom/invincible
overlap is counted as damage; full receiver outcomes remain in report.

Wall spacing loss is retained: A11 melee hits+1 Cast, ten incoming applied
strikes; E7 melee hits+1 Cast, ten strikes. Samples show retreat near the room
boundary with gap below135, not a stale engine queue. Recovery after charge
loss also incurs real failed-Cast releases: default/mirror A5 each/E1 each;
wall A9/E5 (`failed:no_marked_orbs`). Those costs are part of this policy's
outcome, not hidden or fixed. The wall needs a different legal plan; this
does not prove every no-parry route impossible or that parry is a required rule.

No sampled idle pending/buffer queue, or unexplained locked READY state, was
found in any full fight. No-health/action-progress intervals max66–123 ticks
for A and79–84 for E, not unbounded deadlocks. Terminal locks are intentional.
Every natural win/defeat set the actual result layer visible in scene state;
headless checks do not prove rendered pixels. Real Enter UI input
reloaded each of12 attempts: HP100/200, empty orbs/Heat0, no reactions, pending
or buffer, empty result state. E retry restores Poise10/contact1.1/length1.3;
A restores1/0.8/1.0. No direct scene restart/reset method supplies that evidence.

`round-11-policy-audit.json` records exact counts, failure reasons, reset fields
and sampled stale/lock audit. Reports have per-input frame logs as well as raw
event/phase/state history, rather than just summary victory claims.

### First-exchange sensitivity / limits

Separate fresh ordinary default attempts, not an exhaustive strategy search:

- Native-marker-relative parry offsets−3/0/+3 physics ticks all produce one
  actual parry, one melee hit, HP100/Enemy190 in A/E. E first-exchange report129
  ticks, A111. This demonstrates local±50ms tolerance around this chosen legal
  press, not full-fight jitter robustness or human reaction acceptance.
- No-parry spacing thresholds130/135/145 all complete real generation/Charging/
  release/Cast/melee, HP100/Enemy170, one Cast/two melee hits in A/E. First
  exchange215 total ticks in these cases; charging dominates the wait after
  the spatial target is reached. These are policy thresholds, not new game rules.

Original pure-melee/old policies are not replaced: earlier exact E pure melee
loses1076 ticks with Enemy50; old fixed0.68 parry loses794/Enemy100; old spacing
loses1238/Enemy157. The new legal policies demonstrate complete alternatives,
not optimality or equal strategy strength. Robot access to exact native time,
fixed60Hz binary trigger samples and position telemetry differs from physical
controller use. Wall pressure remains a real limitation. No human readability,
reaction/enjoyment or whole-fight sensitivity clearance is claimed.

### Runs / errors / exact source

Four final full-run processes each exit0/zero engine/resource errors with9
initial/UI/Retry checks; the assertions do not require every route to win.
Two sensitivity processes each exit0/zero errors with6 ordinary-state checks,
and all six observed exchanges complete per variant. Initial corrected-policy
runs give the same full outcomes and are retained separately. Very first
fixture parsing failed on a built-in name collision/type inference before any
gameplay; those logs remain labeled `*-initial-parse-output.log`. The new test
was corrected before measured runs. No production fix is inferred from that.

Per A/E folder: `parry-output-final.log`/`parry-engine-final.log`,
`spacing-output-final.log`/`spacing-engine-final.log`, `sensitivity-output.log`/
`sensitivity-engine.log`; initial-run outputs/reports are preserved. Full JSON:
`project/duel-evidence/<variant>_full_parry-duel-report.json`, spacing equivalent
and `<variant>_sensitivity_parry-duel-report.json` (that file contains all six
parry and spacing probes). Final fixture syntax check after adding capture
layout selection exits0/zero errors, `round-11-E/final-script-check.log`.

Runtime source identity is unchanged in the working tree: A equals current
round10. E differs only in exact held scene/Enemy resource and matches round9 E.
No JSON/mirror/noncandidate asset writes, new tuning or production promotion.
All per-process commands use isolated APPDATA/LOCALAPPDATA and120-second wall
timeouts, Godot4.7.1.stable.official.a13da4feb Windows, fixed60 simulation.
Headless prefix: `--headless --audio-driver Dummy --path <project> --script
res://tools/tests/overnight_duel_policy_test.gd --fixed-fps 60 --quit-after
22000 --log-file <log> -- --variant=<A/E> --policy=<parry/spacing>`. Full processes
run three layouts. Sensitivity uses limit6000 and `--suite=sensitivity`.

### Full renderer replay prepared

Worker used headless only. Capture mode runs one requested layout to natural
win/defeat/timeout and records actual viewport/art, initial state, first generated
orb, first parry when present, retreat, Cast, melee return and final result UI.
After-draw JSON includes physics frame, positions, actual action/state/resources,
result UI and input policy. No synthetic frames, seeded resource or forced win.
The graphical branch remains unexecuted by worker; actual PNG/UI success awaits
supervisor. Use separate output folder per policy/layout to preserve reports.

With `$evidenceRoot` pointing to this task evidence directory:

```powershell
$variant = 'E'
$policy = 'spacing'
$layout = 'default'
$work = Join-Path $evidenceRoot "round-11-$variant"
$env:APPDATA = Join-Path $work 'profile'
$env:LOCALAPPDATA = Join-Path $work 'profile'
& (Join-Path $work 'engine/Godot_v4.7.1-stable_win64.exe') --path (Join-Path $work 'project') --rendering-method gl_compatibility --script res://tools/tests/overnight_duel_policy_test.gd --fixed-fps 60 --quit-after 6000 --log-file (Join-Path $work "capture-$policy-$layout-engine.log") -- --capture "--variant=$variant" "--policy=$policy" "--layout=$layout" "--output=$(Join-Path $work "captures-$policy-$layout")"
```

Run E spacing/default for complete Cast/melee victory sequence, E parry/default
for complete parry route, and spacing/wall for the retained defeat UI. A uses
the same command/variables. Each owned graphical process must remain bounded
to120s. Initial position/debug policy is labeled in report; no source overlay
or asset change. Expected filenames contain policy/layout/event/frame, including
final_victory or final_defeat. No PNG count/success is claimed before rendering.

**Recommendation:** provisional E retention only after full renderer review,
with wall-route failure and charge-loss/fumble costs explicit. There are now
complete legal default/mirrored encounters for both styles, a full parry route
under wall pressure, and local first-exchange tolerance; one-cycle success is
not being substituted for a fight. Human controller/feel acceptance is pending.
E remains unpromoted in working source until supervisor disposition. All owned
processes ended; READY_FOR_SUPERVISOR_REVIEW. No desktop input, commits/push/
publication or autonomous next round.

## Round11 supervisor disposition

Exact E retained provisionally after bounded tech-postflight full-encounter
review; no new rule/architecture/final balance acceptance. Independent actual
OpenGL E spacing/default wins1482/HP90/9Casts/11melee,15 checks/sixPNG;
parry/default wins1599/HP100/20parries/20melee,11 checks/fourPNG; spacing/wall
natural defeat1008/Enemy120/oneCast/sevenmelee/ten incoming hits,15 checks/sixPNG.
All exit0/zero engine errors. Terminal victory/defeat viewport images and actual
input-driven Retry states inspected. Evidence in `round-11-E/` supervisor logs
and `supervisor-captures-{spacing-default,parry-default,spacing-wall}/`.
Policies use actual InputMap/physics without manufactured resources/damage.
Independent two-file delta confirmed. Robot exact-clock/position access, wall
failure, charge-loss fumbles, tutorial cadence and human acceptance remain limits.

## Round12 — exact reviewed E promotion / current contract synchronization

Round began October20 00:47:51 HKT,30-minute budget and original cutoffs apply.
All production/doc paths and relevant test sources were copied with hashes to
`round-12-before/` before editing. Exact reviewed E bytes verified and copied:

- `scenes/gym.tscn` SHA `59a30b45d7281a25d2d4573d3ee10703584df98914f53c8e17c76fd5b24081e7`
- `config/attack_animations/melee_swing.tres` SHA `c974260d13e7435991651109b58e5ae0d0bbb2ab68f7116eba4c29a2136a176e`

Only these two production paths change relative to round10. Scene Poise10;
native active_start/contact1.1, active_end/length1.3, approved four-pose/geometry
timestamp retiming, speed1/no tail/timer. Script export default1, shared tutorial
Poise0/JSON, stats/geometry values/AI tree and input/formula/queue/cancel rules
remain. FireCast0.24/X2-X3X40 and prior fixes remain. All A/B/C/D/E snapshots and
old policy results are preserved; E is now retained data, not final human tuning.

### Exact test paths / reasons and preserved contracts

Test reasons were stated before edits in worker commentary; each source has a
before snapshot. Changes are semantic setup/current-value updates, not loosened
production rules:

- `enemy_animation_test.gd`: explicit stock1.1/1.3/no-tail assertion; phase/damage
  observation uses actual markers. Recovery lifecycle privately extends only its
  clip beyond active_end by0.3. All arbitrary .31/.37/.48/.81 custom-clock tests,
  large-frame once-only contact, cancellation, configuration and lifetime checks
  remain.153 checks versus152 previously adds the explicit stock contract.
- `clash_formula_test.gd`: separately tests defaultGymPoise10 values0/10/20/30/40,
  Levels0–4, damage/generation and qualifying cancellation. Then sets **private
  runtime fixture** Poise1 for all original198 assertions plus the prior negative/
  mirrored coverage. It does not assert default10 yields old levels.287 checks.
- `overnight_contact_probe_test.gd`: current default inside expected Levels0–4;
  native overlap/damage/negative/world-space checks remain.164 checks.
- `overnight_gym_input_test.gd`: current timed parry derives native contact−0.12;
  strategy identity is explicitly `parry_marker_relative`. Fixed0.68 archived
  reports remain losing/history, not a retained contract. Other naive policies
  remain observations, not required winners.11 checks.
- `overnight_gym_poise_test.gd`: current default trigger is marker-relative;
  helper's prior archived copies are untouched. Direct current helper50 checks pass.
- `overnight_enemy_recovery_test.gd`: tail derives **length−active_end**, not
  length>1.0; stock1.3 therefore has no tail. Observation/parry phase offsets
  derive markers. Private recovery clips extend to1.6; qualifying X1 reaction/
  death probes privately use Poise1 and label it.67 lifecycle checks retained.
- `overnight_cast_timing_test.gd`: only rear-strike fixture scheduling changes
  with native contact1.1, preserving intended before/between/after Fire launch.
  All commitment/once-only/interruption expectations remain,45 checks.
- `attack_authoring_test.gd`: scrub at actual Enemy contact marker, retaining
  same expected contact pose/geometry/grounding;74 checks. Writer suite isolated.
- `gym_encounter_test.gd`: candidate value expectation Poise10/Impact20; original
  F5-to-Gym intended assertion remains visibly failed.120/121, sole known F5
  mismatch. Persistence/shared-mirror guards remain; no startup config change.

Existing duel/choice/close algorithms and production code are not changed.
Private overreach mutation still fails32 negative assertions, exit1/zero engine
errors; mutation evidence is separate from passing corrected tests.

### Fresh current-source regressions and exact reviewed equality

New `round-12-candidate/project/` copies current source; `style-project/` and
`authoring-project/` are disposable copies for intentional writer checks. Godot
4.7.1.stable.official.a13da4feb Windows. Results:

| Suite | Checks / exit |
| --- | --- |
| Enemy native/config/lifecycle |153/0, clean serial run|
| Formula/default10/private1/clash |287/0, zero errors|
| Current real-input regression |11/0, zero errors; revised parry identity|
| Cast/pre-between-post interruption |45/0, zero errors|
| Recovery/stage lifecycle |67/0, zero errors|
| Native authoring/grounding |74/0, zero errors|
| Broad styles/queue/persistence |595/0, zero errors|
| Contact geometry/real-input |164/0, zero errors|
| Close/outer/invincibility |508/0, zero errors|
| Gym encounter/persistence |120 of121/exit1, only known F5 assertion|
| Direct current Poise helper |50/0, zero errors|

Two complete current-source duel processes each pass9 fresh-state/UI/Retry
checks and exit0/zero errors across default/mirrored/wall starts. Sensitivity
passes6/exit0/zero errors. After removing **only attacker_id/receiver_id**, all
complete attempt/event/input/state dictionaries for full parry, full spacing
and six sensitivity cases exactly match reviewed round11 E, including Retry
Poise10/contact1.1/end1.3 fields. `reviewed-E-comparison.json` confirms all true.
No equality is claimed to the earlier intentionally revised fixed0.68 policy.

The retained outcomes remain: parry wins all three atHP100; no-parry default/
mirror winsHP90 with9Casts/11melee, wall loses16.8s/Enemy120. Local parry±3 ticks
and gap130/135/145 first exchanges remain viable, not whole-fight jitter/human
proof. Naive pure melee/old fixed policy losses, charge-loss fumbles and corner
space costs remain in history/current docs; no mandatory strategy or equal-power
rule is inferred. Shared tutorial native cadence61→79 ticks while Poise0/config
stays unchanged, with prior actual lifecycle/Endurance evidence retained.

Source identity: all637 current candidate runtime files equal working source and
exact reviewed E, digest `a58538980c0aff922ca7f328f1583f450dc0e55af5f6c7b9ef49371ecf108995`.
Relative to round10 only the scene and Enemy animation differ. JSON/mirror and
all noncandidate assets/code remain byte-identical. Test/record changes are
listed with before/after hashes in `round-12-identity.json`.

### Import, shutdown and launch caveats

First fresh editor import logs the known unrecognized saved main-scene UID,
finishes asset import/layout, then exits native0xC0000005. Its cause is not
diagnosed as a gameplay fault or dismissed as a harmless warning. Log retained
`import-output.log`/`import-engine.log`. A warm editor import exits0/zero errors
(`warm-import-output.log`/`warm-import-engine.log`). All listed runtime suites
run successfully from the fresh imported copy, aside from the known F5 assertion.

Initial parallel Enemy153 passes but reports six resources at shutdown. Clean
serial retry with frame-delay50 exits0/153/zero engine-resource errors. Both
outputs retained; no audio/OS fix or claim that all history is resource-clean.
No other runtime assertion/logic error is observed in this round.

CURRENT launch prose in GDD/technical/Gym records is corrected: open explicit
`scenes/gym.tscn` for F6 or Portal Run gym. Saved project.godot F5 still points
to the tutorial and remains a known intended-launch mismatch. No project.godot
edit or silent startup retarget. Docs explicitly distinguish current package
from historical Poise1/.8/1.0 and the rejected .8/1.3 recovery-tail comparison.
Scope-limited synchronization does not claim whole-document/project validation.

### Paths / commands / morning handoff

Actual changed files: production `scenes/gym.tscn` and Enemy Animation;
the nine tests above; docs GAME_DESIGN,TECH_ARCHITECTURE,IMPLEMENTATION_STATUS,
ATTACK_STYLES,GYM,departments/combat and this ledger. All have before snapshots.
No other production or workflow/Skill file change.

Logs in `round-12-candidate/`: enemy/clash/input/cast/lifecycle/gym/authoring/
style/contact/close `*-output.log` and `*-engine.log`; clean
`enemy-serial-output.log`/`enemy-serial-engine.log`; `poise-helper-*`, `mutant-*`;
full `duel-parry-*`, `duel-spacing-*`, `duel-sensitivity-*`; import logs above.
Full reports under project duel/recovery/Cast/close evidence folders and native
contact/input JSON. Writer suites affect only disposable copies, not playable.

Commands use isolated engine/profile and120-second wall timeouts. Prefix
`--headless --audio-driver Dummy --path <project> --script
res://tools/tests/<suite>.gd --fixed-fps 60 --quit-after <limit> --log-file <log>`.
Enemy/clash6000 with initial frame-delay25; clean Enemy retry50. Input12000;
Cast10000; lifecycle12000; Gym6000; authoring/style6000 in their separate copies;
contact10000; close16000; Poise helper16000. Full duels22000 with
`-- --variant=round12 --policy=parry` or spacing; sensitivity6000 with
`--suite=sensitivity`. Appropriate focused variant labels are round12. Mutation
uses the isolated root script,6000/delay25. No worker graphical process/desktop
control was used; supervisor's actual complete terminal images remain round11.

Morning: launch explicit Gym/F6, verify controller L2 release/Cast/melee return,
read the longer commitment and choose continue/parry/disengage under pressure,
compare close and outer sword coverage, and try the corner case. Human judgement
must assess the full slower rhythm, room limitations and fumble costs; robot
exact-marker/position success does not establish enjoyment or controller skill.
All original snapshots/failures remain. No live/export/submission validation.

READY_FOR_SUPERVISOR_REVIEW. Exact reviewed E is retained provisionally; no
final gameplay/balance acceptance claimed. All owned processes ended. No desktop
input, commit/push/publication or autonomous next round; hard overnight cutoffs
remain unchanged.

## Round12 supervisor disposition

Promoted E exact hashes/data/docs reviewed, bounded IMPLEMENTATION_REVIEW_COMPLETE.
Independent fresh Enemy153/153 exits0/zero errors with frame-delay50:
`round-12-candidate/supervisor-enemy-output.log`, `supervisor-enemy-engine.log`.
Human/submission clearance remains open. Cold native import0xC0000005, F5
mismatch and intermittent shutdown warnings remain evidence limits; warm
success does not erase them.

## Round13 — isolated feedback anchors A/F/G

Round began October20 01:16:22 HKT,25-minute budget and overnight cutoffs apply.
Only working edits: new `tools/tests/overnight_feedback_layout_test.gd` and this
ledger. Prior ledger/new-file absence snapshot: `round-13-before/`. No helper,
production component, font/color/outline/clamp/tween/event/rule/asset changes.

Independent copies under this task evidence directory:

- A `round-13-A/project/`: retained E source, directY−238/DoTY−206.
- F `round-13-F/project/`: only two component literals directY−174/DoTY−146.
- G `round-13-G/project/`: added by same-round supervisor steering; directY−198/
  DoTY−166, shifting both old anchors down40 pixels and preserving32px separation.

All keep X−10/−8, Cast-level−118, parenting, fonts/colors/outlines, clamp function,
tween displacement/duration/easing and timers byte-identical. Across637 runtime/
project files each candidate differs from A only in
`scripts/entities/feedback_component.gd`; exact literal-replacement proof passes.
Component SHA A `82046f203625566c61297f6cae8cd51e6894992fdb766a0a4c740ed6aae41554`,
F `34e49c87ff4b1c75f5f986e45bcf4d3e0bd57e87280d12ef8191d44953cf20ac`,
G `d43c27f7bba027e292774aa9bd22cbc5884c88510dcda39b2ff736e4322d0278`.
Working component still equals A. Full identities: `round-13-identity.json`.

### Probe boundary / real combat

Layout-only direct presentation APIs are explicitly labeled and do not alter
Health: damage0/10, DoT0/3, FireLv1/WaterLv4/AirLv8/EarthLv1, plus rejection
of Lv0. No status or DoT gameplay is injected; ordinary Gym Fire DoT is disabled.
Actual NPC scale1 and Player scale2 are used. Tree pause is layout-only temporal
setup without a modal obscuring labels. Existing overlay visibility is changed
privately, not saved. Actor/HP/header bounds, font/color/outline, label counts,
Control-rectangle overlaps, opacity and lifetime are recorded.

Separate actual InputMap X/held L2/release from ordinary gap56 generates a real
orb, commits/launches once and produces NPC damage10, empowered projectile13,
FireLv1 and incoming Player10 through actual HealthResults. No initial resource,
synthetic health event or direct combat method supplies those frames. Real
samples18/68/148 are collected with overlay on/off, preserving repeated labels.

All A/F/G pass **110/110 focused content/count/layout/pause/lifetime/actual-input/
UI-Retry checks**, exit0/zero engine-resource errors. Cast45 passes each variant
with zero errors. `round-13-comparison.json`: complete combat event/phase/Health/
resource/Heat cases equal A after removing only machine attacker/receiver IDs;
all Cast key metrics, release/action/launch/end/follow-up frames equal A.
No gameplay outcome or timing change is inferred from presentation relocation.

First measurement attempt incorrectly accessed Control.global_scale, producing
script errors despite an exit0/status print; those runs are not evidence of a
clean check. They remain `feedback-initial-probe-errors.log`. Getter corrected
to the actual global-transform scale before clean measured runs. No component
or production behavior was repaired as part of that fixture correction.

### Measured current1280×720 layout

Headless measurements are laid-out Control geometry, **not inspected GPU pixels**.
Renderer mode recollects actual after-draw rectangles and full viewport images;
visual outline/glyph clearance still awaits supervisor. Bounds exclude glyph
outline extents, whose existing local thickness is also recorded.

NPC actor screen origin(715.5,378.72), HP rectangleY290.72…316.72. Triplet top Y:

| Channel | A | F | G | NPC Control height |
| --- | ---: | ---: | ---: | ---: |
| Damage |140.72|204.72|180.72|26|
| DoT |172.72|232.72|212.72|17|
| Cast |260.72|260.72|260.72|23|

F moves damage64px/DoT60px closer; G moves both40px. No NPC triplet/HP
rectangle overlap at spawn. NPC damage-bottom-to-origin distance A212→F148/
G172 pixels; DoT189→F129/G149. Cast remains95. No claim all target layouts
or resolutions are covered. NPC status row spans202.72…250.72 but has zero
visible children in current Gym; populated-status layouts are not solved or
manufactured by these probes.

Player scale2 at screen origin(560,360), no actor HealthLabel; HP is in HUD
telemetry, whose actual canvas rectangle/visibility is recorded. Triplet:

| Channel | A top/height | F top/height | G top/height |
| --- | --- | --- | --- |
| Damage |122/52|186/52|162/52|
| DoT |154/34|214/34|194/34|
| Cast |242/46|242/46|242/46|

A already has direct/DoT rectangle overlap. F narrows their separation and adds
new DoT/Cast overlap6px; per supervisor steering F is **not recommended as-is**.
G preserves A's overlap pairs and leaves14px Control clearance DoT→Cast, but
fresh Player damage162…214 still intersects EventPanel124…172 by10px. Outline
sizes are unchanged and inherited scale matters; no arithmetic-only claim of
visual clearance is made.

Actual real-combat overlay-on sample label/panel intersections: A8, F1, G5
across the three matched samples, counting label-panel pairs rather than unique
occluded glyphs. F clears fresh actual NPC and Player numbers at18/68, but an
older Player number drifts back into the header by148. G clears fresh NPC,
but fresh incoming Player number still intersects the header around10.5px in
Control bounds. Overlay-off has no visible-header intersections. Rectangles,
alpha and panel visibility remain available to distinguish potential from
actual glyph occlusion.

Repeated NPC10/13 and Player10/10 numbers overlap in actual combat in all
variants; there is no stacking/aggregation fix. Direct/DoT float at different
rates; even A/G's initial NPC separation can overlap later in the tween. These
are preserved limits, not silently repaired. F's shared component must not be
promoted as if all Actor scales/channels became readable.

### Lifetime / pause / reset

Text0 remains0, DoT font12 stays smaller than direct18 and Cast16, colors and
outline2/3 remain. No Lv0 label is created. Duration remains2s. Actual pause
observations: owner-bound direct/DoT tweens keep positions/labels while tree is
paused; the existing SceneTree Cast-level timer continues and expires during
pause. Unpausing advances direct/DoT to alpha0.5 at midway and frees them at
their original duration. This asymmetry is baseline behavior, not modified.
Actual InputMap Esc/Down/Enter Retry clears old owner labels and restores
ordinary HP100/200; no direct health/reset method supplies that evidence.

Final focused logs: A/F `feedback-output-ui-reset.log`/`feedback-engine-ui-reset.log`,
G `feedback-output.log`/`feedback-engine.log`; earlier clean probes remain
separately named. Reports per variant:
`project/feedback-evidence/<variant>-feedback-report.json`. Cast logs
`cast-output.log`/`cast-engine.log`. Source/metrics comparisons in the two
round-level JSON files above. All use isolated APPDATA/LOCALAPPDATA,
Godot4.7.1 Windows, fixed60 simulation and120-second process timeouts.

### Actual-renderer command / disposition

Worker remains headless. Graph mode captures actual direct-hit/Cast/incoming
frames18/68/148 with overlay on/off, plus labeled layout-only NPC/Player
triplets. All are full original gameplay viewports, not manufactured diagrams.
Player and NPC actual after-draw Label/HP/header rectangles, transforms, fonts/
outline/alpha and source classification are recorded with the image metadata.
No DoT gameplay/status/art is created; layout-only filenames distinguish the
three-channel API examples. Actual GPU visual overlap/outline review is pending.

Use `$evidenceRoot` for this task evidence directory; run A then F then G with
separate variant folders and120s process bounds:

```powershell
$variant = 'G'
$work = Join-Path $evidenceRoot "round-13-$variant"
$env:APPDATA = Join-Path $work 'profile'
$env:LOCALAPPDATA = Join-Path $work 'profile'
& (Join-Path $work 'engine/Godot_v4.7.1-stable_win64.exe') --path (Join-Path $work 'project') --rendering-method gl_compatibility --script res://tools/tests/overnight_feedback_layout_test.gd --fixed-fps 60 --quit-after 6000 --log-file (Join-Path $work 'capture-engine.log') -- --capture "--variant=$variant" "--output=$(Join-Path $work 'captures')"
```

Expected names include `G_actual_overlay_on_npc_68_*.png` (full viewport also
contains the real Player number), `G_layout_only_player_overlay_on_triplet_*.png`
and matching A/F files/report JSON. Actual image count/visual success is not
claimed until rendered. Headless uses `--headless --audio-driver Dummy`, no
capture flag, limit6000; focused Cast uses its unchanged script/limit10000.

**Recommendation:** reject F as-is for the new Player cross-channel overlap;
hold G as a conservative partial comparison, not a full goal-complete promotion.
G improves target proximity/NPC header clearance without new measured triplet
pairs, but fresh Player header clearance remains incomplete. After-draw glyph/
outline review may inform supervisor's tradeoff choice; no scale/clamp/stacking
framework or further anchors are invented. Working component stays A. All
owned processes ended; READY_FOR_SUPERVISOR_REVIEW. No desktop control,
production promotion, commits/push/publication or autonomous next round.

### Round13 final constrained H comparison / superseding recommendation

Supervisor's same-round steering derived one final equal52px shift from actual
bounds: new isolated `round-13-H/project/`, directY−186/DoTY−154, Cast−118. No
open-ended search, scale/clamp/fonts/tween/timer/stacking change. A/F/G remain
preserved. Working component still A. Exact two-literal proof and hash recorded
in `round-13-identity.json`; same fixture/Graph command accepts variant H.

H110/110 focused and Cast45/45 pass, exit0/zero engine-resource errors. Real
combat event/phase/Health/resource cases and Cast action metrics exactly equal A
after removing only attacker_id/receiver_id. Normal lifetime/pause/UI Retry and
content/color/outline checks remain. No gameplay/DoT outcome is manufactured.

H NPC triplet Y192.72/224.72/260.72; no initial pair/HP/header Control overlap.
Player triplet Y174/206/242 with heights52/34/46: the old direct/DoT pair remains,
no new pair. DoT bottom240 leaves **2px** to Cast top242. EventPanel bottom172
leaves2px to static direct top174; real first incoming frame68 top173.476 leaves
**1.476px**, later fresh frame148 top172.953 leaves **0.953px**. Actual older
Player number at148 remains in the header. Across sampled overlay-on real
frames, H has one label-panel intersection, versus A8/F1/G5. This is Control
geometry only, not automatic rendered glyph/outline clearance. Existing outline
thickness3/2/3 is inherited/scaled; tiny nominal margins may still look crowded.
No fix or conclusion is made without the actual GPU images.

H logs `feedback-output.log`/`feedback-engine.log`, `cast-output.log`/
`cast-engine.log`; report `project/feedback-evidence/H-feedback-report.json`.
The prepared actual-render command above works with `$variant='H'` and writes
actual after-draw rectangles/PNGs, including layout-only Player triplet and real
incoming numbers. Worker remains headless; outline/glyph inspection is explicitly
**unverified for supervisor**, not supplied by the successful bounds arithmetic.

Superseding recommendation: H is the strongest numeric candidate for supervisor
GPU review; keep promotion on hold until its tight outline/header spacing is
actually inspected. F remains rejected as-is; G remains a partial compromise,
neither is relabeled goal-complete. No further parameter search/framework work,
production promotion or new round. All owned processes ended before handoff.

## Round13 supervisor disposition

Bounded two-offset H candidate is **IMPLEMENTATION_REVIEW_COMPLETE**, selected
provisionally under the user's overnight disposition authority. F rejected
as-is; G remains a partial comparison. No final gameplay/human/submission clearance.

Supervisor independent actual OpenGL A/H each exits0/errors0, passes68
capture-mode checks and writes10 full viewport PNGs. The palette is skipped
by capture-mode design; these68 are separate from headless110, not a contradictory
count or a single summed total. Evidence: `round-13-{A,H}/supervisor-capture-output.log`,
`supervisor-capture-engine.log`, `supervisor-captures/` PNGs/report JSON.
Inspected actual overlay-on68, H148, H overlay-off68 and layout-only NPC/Player
triplets. H fresh glyphs visually clear EventPanel; initial Player DoT/Cast
glyphs remain visibly separate and direct/DoT pair remains baseline. At148,
older fading Player10 still drifts into header; repeated NPC10/13 overlap.
No scale/clamp/stacking or resolution-independent layout fix is inferred.

## Round14 — exact H feedback promotion and final source verification

Round began October20 01:41:07 HKT; deadline02:10 and original overnight cutoffs
remain. Before editing, component and corresponding GDD/technical/status/Gym/
Combat/ledger files were copied with hashes to `round-14-before/`. Exact H hash
and exact two-literal delta were verified before copying into working source:

`scripts/entities/feedback_component.gd` SHA
`834925ff5544c13a31ad5891bfce559e257584e7032ff02d228dd41049cffe17`.

Only `show_damage` Y−238→−186 and `show_dot_damage` Y−206→−154 differ from
retained round12. X−10/−8, Cast-level−118, fonts/colors/outlines, owner parenting,
clamp/scale, tween movement/easing/duration/timers, labels/APIs and all combat
events/damage/resources/animation/AI/tuning remain unchanged. No new feedback
channel/meaning, accepted design Decision or layout framework is created.

Actual changed paths:

- `scripts/entities/feedback_component.gd`
- `docs/GAME_DESIGN.md`
- `docs/TECH_ARCHITECTURE.md`
- `docs/IMPLEMENTATION_STATUS.md`
- `docs/GYM.md`
- `docs/departments/combat.md`
- `docs/iterations/2026-10-19-overnight.md`

No test/helper, project.godot, engine, attack/tuning resource or other production
file is edited in round14. Docs label retained OVERNIGHT CANDIDATE, pending
human readability/controller/feel acceptance, and separate actual68-check render
evidence from110-check headless palette/lifetime evidence. Baseline direct/DoT
crowding, repeated numbers, late drift, inherited-scale/clamp/pause limitations
and unsampled layouts remain explicit. No globally clean/whole-document or
whole-project validation claim.

### Fresh final source / checks

New `round-14-final/project/` copies current runtime roots and tests from working
source. It reuses only the reviewed H imported-asset cache for initialization;
no cold/warm editor process is rerun for this two-value verification. Engine and
APPDATA/LOCALAPPDATA profile are isolated. This does not erase the earlier cold
native import0xC0000005 or warm-success caveat. Source scripts/resources are
verified independently of that cache.

- Focused feedback **110/110**, exit0/zero engine-resource errors: strings0/10,
  smaller DoT0/3, school-level1/4/8/colors, no Lv0, counts, representative NPC1/
  Player2 bounds, layout-only API Health unchanged, real InputMap melee/Charging/
  Cast/incoming HealthResult frames, lifetime/pause and actual UI Retry.
- Focused Cast **45/45**, exit0/zero errors, unchanged script/expectations.
- Existing shared entity/formula readout **23/23**, exit0/zero errors, unchanged
  suite. No other dedicated feedback/entity suite was found; no broad unrelated
  regressions are rerun for these two presentation literals.

Real-combat event/resource/phase dictionaries exactly equal reviewed H after
removing only machine attacker_id/receiver_id. `round-14-identity.json` records
that comparison, complete file hashes and before/after identities. All637
current runtime/project files match reviewed H and fresh final copy; outside
FeedbackComponent the diff versus round12 is empty. Final runtime digest:
`063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
Shared JSON/mirror and all nonfeedback assets/code remain unchanged.

Logs: `round-14-final/feedback-output.log`/`feedback-engine.log`,
`cast-output.log`/`cast-engine.log`, `readout-output.log`/`readout-engine.log`.
Report `project/feedback-evidence/finalH-feedback-report.json`; Cast equivalent
under cast-evidence. Headless110 remains labeled as Control/layout/semantic
evidence; supervisor actual images provide the narrow visual finding separately.
Palette/zero/DoT probes do not manufacture gameplay DoT or fully-resisted hits.

Commands use isolated Godot4.7.1, `--headless --audio-driver Dummy --path
<project> --script res://tools/tests/<suite>.gd --fixed-fps 60 --quit-after
<limit> --log-file <named-log>`,120-second process timeouts and isolated profile.
Feedback limit6000 with `-- --variant=finalH`; Cast10000/finalH; readout6000.
All owned processes completed and ended. No worker actual-render/desktop process.

### Retained limits / morning point

Fresh inspected H glyphs improve target linkage and header clearance at sampled
1280×720; old fading numbers and repeated-label clutter remain. Do not infer
all resolutions, status combinations, scale inheritance or clamp semantics are
solved. The existing owner-tween versus process-always Cast timer pause difference
is unchanged. No font/lifetime/event-filter change was made to conceal limits.

Known F5 UID still opens tutorial; use explicit Gym F6/Portal. Source Enemy E,
Fire candidates, shared tutorial Poise0/cadence effects, wall-route loss/fumbles,
cold native import failure and historical cleanup warnings remain as documented.
Current gameplay/feedback candidates are provisional and uncommitted. Human
morning controller/feel assessment is still required; no final accepted Decision,
export/live/checkpoint/submission/publication clearance is claimed.

READY_FOR_SUPERVISOR_REVIEW. All owned processes ended; no extra tuning,
next experiment, desktop/OS action, commit/push/checkpoint/publication or
autonomous next round. Overnight hard stops remain in force.

## Round15 — validation-only process/physics pacing

### Review handoff and bounded scope

Supervisor completed Round14 bounded implementation review: all637 runtime files
byte-equal reviewed H, exact FeedbackComponent SHA and110/failures[] confirmed;
H/final real-combat dictionaries equal after removing only attacker_id/receiver_id.
The isolated icon.svg.import difference is line endings with identical text,
not a gameplay delta. This is bounded implementation review, not human gameplay
acceptance, final design acceptance or submission clearance.

Round15 changes only this ledger and new
`tools/tests/overnight_frame_pacing_test.gd`. No production tuning/fix was needed
or made. Before snapshot: `round-15-before/` (ledger copy and absence of fixture).
Fresh30/60/120 isolated projects, engines and profiles copy the reviewed final H
source/imported cache. This does not establish a fresh cold-editor import or
erase the earlier native import/cleanup caveats.

### Native callback semantics and measured rates

Godot4.7.1 local `--help` states `--fixed-fps` disables real-time synchronization.
`round-15-60/engine-help.txt` preserves that engine evidence. These are controlled
simulation rates, not wall-clock GPU performance, variable frame jitter or
human controller tests. Physics stays at the existing60 ticks/second throughout.

The independent always-processing observer records every actual process and
physics callback, deltas and steps-per-process. It does not inherit `frames()`:
awaiting physics_frame then process_frame can miss/coalesce physics observations
at30FPS. Every event/input records native process/physics frame counters, wall
microseconds and observer accumulated times. Observer sums at an event describe
callbacks already completed, not an interpolated exact event timestamp.
Hardware-bound X/L2/keyboard events hold for at least two process callbacks.

The first12 process samples are retained separately as startup evidence; the
engine accumulator corrects early deltas (30FPS is initially nonuniform;120FPS
starts with1/60). Calibration uses a separate settled window:

| Requested process FPS | Process callbacks / accumulated seconds | Physics callbacks / seconds | Physics steps per process |
| --- | --- | --- | --- |
|30|60 /2.000000|120 /2.000000|2 on all60 callbacks|
|60|121 /2.016667|121 /2.016667|1 on all121 callbacks|
|120|241 /2.008333|121 /2.016667|121 callbacks with1;120 with0|

Settled process deltas are1/requested rate; physics deltas are1/60. The one-tick
endpoint difference at120 is measured scheduling, not an assumed equal-frame
contract. Raw startup/calibration deltas and event counters are in each report.

### Results and fixture corrections

Final headless runs: **73/73 each at30,60,120**, exit0, failures[] and no engine,
script or shutdown diagnostic lines. Every rate covers:

- Controlled no-pressure setup explicitly disables AI through validated private
  live config; initial placement56 and bound facing input only. No initial orbs,
  HP/timer/animation edits, direct action calls or fabricated contact results.
  Three complete Generate→held Charging→release Cast→queued melee loops in each
  direction produce6 APPLIED melee/6 generated orbs,3 distinct commits and3
  distinct launches. Each next melee finishes READY with movement unlocked,
  reaction inactive, and current/pending/buffer empty.
- Default E pressure remains enabled in its separate case. Its first real native
  strike interrupts the active committed Cast before launch (1 commit/0 launches).
  Actual reaction recovery reaches READY and accepts the next legal melee.
  Continued ordinary pressure observes native action IDs1–4 exactly once each;
  no duplicate contact. Melee APPLIED→generation equality remains exact.
- Real Esc pauses while a generated orb is charged. L2 release during pause
  neither commits nor launches, changes resources nor advances the action clock.
  Resume samples that release exactly once, producing1 commit/1 launch. The
  empowered Cast intentionally leaves an open combo, empty action occupancy and
  unlocked movement; the next legal melee is accepted and then returns READY.
- Actual Esc/Down/Enter menu Retry after pressure and after paused release
  replaces the encounter, restores100/200 Health and clears orbs/Heat, reactions,
  locks and queues. A subsequent0.25 logical-second observation has no stale
  old-player outcomes. No synthetic refill, retry call or resource reset.

Matched Health happened to agree in these runs (controlled Enemy101, pressure
Player60/Enemy180, paused-release Enemy167); exact Health/win/frame equality is
not the acceptance criterion and does not imply timing is identical.

Initial fixture diagnostics are preserved, not promoted to production faults:
an unnecessary right movement tap changed the point-contact setup and missed;
the public light_contact_resolved signal reports hit/miss, not APPLIED (corrected
to the existing HealthResult debug signal); a premature READY assertion after
empowered Cast ignored its authored open-chain behavior; and calibration initially
included the engine's startup accumulator correction. No production edit followed
those failures. Initial60 logs/reports and per-rate startup-calibration archives
remain separately named in the evidence folders.

Initial accelerated shutdowns reported8 ObjectDB instances/4 resources. The final
fixture gives stopped Dummy audio100ms wall-time cleanup after measurements and
again after scene teardown. Final three runs are clean; pre-cleanup logs/reports
remain preserved. This narrow fixture cleanup does not classify earlier native
editor crashes or all historical resource warnings as harmless.

### Evidence, identity and supervisor renderer replay

Evidence root is this worker's existing visualization directory. Each
`round-15-<30|60|120>/` contains `pacing-output.log`, `pacing-engine.log` and
`project/pacing-evidence/pacing-<rate>.json`. Final identity and compact comparison:
`round-15-identity.json`. All637 current runtime files equal Round14 and all three
isolated copies; unchanged digest
`063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
Fixture hash and final check/diagnostic summaries are stored in that identity file.

Native commands use each isolated engine/profile,120-second process timeout:
`--headless --audio-driver Dummy --path <round>/project --script
res://tools/tests/overnight_frame_pacing_test.gd --fixed-fps <30|60|120>
--quit-after 15000 --log-file <round>/pacing-engine.log -- --rate-label=<rate>`.

Supervisor-only actual-render replay is prepared as `round-15-gpu-replay.ps1`
beside the evidence folders. Run once with `-Rate 30` and once with `-Rate 120`.
It uses the same fixture/source, omits headless and adds `--capture`, writing to
separate `gpu-pacing/` output and GPU logs without overwriting headless reports.
Captures await actual frame_post_draw, save the full1280×720 viewport and record
scheduled/rendered counters for charged orb, Cast, incoming hit, pause/release,
resumed melee and Retry. These commands are prepared, **not worker-executed or
visually verified**. Actual graphics callbacks may change observation rounding;
review their own reports rather than assuming identical counters/check totals.

READY_FOR_SUPERVISOR_REVIEW. All owned headless jobs ended before the02:30 HKT
round deadline. No concrete rate-dependent production fault was found in this
bounded matrix. No extra experiment, desktop/OS action, commit/push/checkpoint,
publication, accepted gameplay Decision or human controller/feel clearance.

### Round15 supervisor actual-render supplement

Supervisor Ultron `mode=tech-postflight` bounded implementation review COMPLETE;
no new conformance finding. Supervisor independently ran the prepared30 then120
GPU commands with actual default D3D12 Forward+ / RTX4090. Each exits0 with
**92 checks/failures[],19 full-viewport PNGs**, zero ERROR/WARNING/SCRIPT ERROR
in `gpu-pacing-engine.log`. This is separate from each73-check headless result.
Worker read back both JSON reports/log diagnostics; actual image inspection is
the supervisor's reported evidence, not worker desktop access.

Supervisor inspected30 facing+ Cast, facing− charged, actual incoming and paused
release;120 facing− Cast3, resumed melee and Retry. Measured callback ratios and
bounded combat/reset results match the headless findings: both directions3
unique commits/launches and6 APPLIED/6 orbs; E1commit/0launches and4 unique native
contacts, Player60/Enemy180; pause1commit/1launch Enemy167; both retries100/200
and empty resources. Reports: `round-15-{30,120}/gpu-pacing/pacing-<rate>.json`;
logs `gpu-pacing-output.log`/`gpu-pacing-engine.log` in the corresponding rounds.
637-file runtime digest remains unchanged. Controlled fixed-fps validation is
not real-time performance, frame jitter, physical controller or human feel
acceptance. No production change or gameplay acceptance follows this review.

## Round16 — cold-import lifecycle reliability diagnosis

### Scope and hypothesis

The unchanged `tools/test-dev-portal.py` first launches
`--headless --path <isolated-project> --editor --quit`, then the runtime test.
Local4.7.1 `--help` defines `--quit` as first-iteration exit and `--import` as
starting the editor, waiting for resource import, then quitting. Hypothesis:
first-iteration exit might race cold import and explain the earlier native crash.
This is a hypothesis to test, not a diagnosis inferred from flag names.

Only this ledger and new focused helper
`tools/tests/overnight_import_lifecycle_probe.py` change. Before snapshot:
`round-16-before/` ledger and main-runner SHA. The helper creates one fresh,
uniquely named project/portable engine/profile per invocation, refuses to reuse
the folder, and records the absence of `.godot` before every cold run.
Same roots and exclusions as the main runner: scripts/scenes/config/ai/assets/
addons, project.godot and icon.svg; excludes tilde backups, .git and .godot;
copies the matching dev_portal_test.gd to the same root location. No runtime
suite is run this round. No plugin disable, recovery mode or source mutation.

Baseline is retrieved via read-only `git archive` of full
`644587bc9e570aed5d7c78cc00f8f81a6defff67`, not checkout/reset/stash. Retained
source is copied from the working tree. Each has637 runtime inputs; their exact
pre-import manifests match:

- Baseline: `1bc3fc906fdbade7c83084dd60814c3130d7033557fb9ad125187c3fa9b8dfe8`.
- Retained H: `063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.

Their only runtime differences are the retained eight files: Fire Cast/X2/X3,
Enemy melee clip, Gym scene, Might, Enemy and FeedbackComponent. Exact
project.godot is identical across sources and remains unchanged by all runs:
SHA `950c51f26406600652e47f49dcbab157cd065eaec3352b7ae583ebe18043efaa`.
Same supplied native4.7.1.stable.official.a13da4feb, binary SHA
`323f9c4cc5db674e98815cdd8e69da007d5efc779abedc8c0e42883b7fdea12a`.
Portable editor data and APPDATA/LOCALAPPDATA are fresh for each cold condition.

### Matched evidence

Started with one cold run per condition, then used the permitted maximum three
cold repeats each because the initial four did not reproduce the crash or
distinguish exit paths. Repeat2 includes one same-source/same-mode warm retry
per condition to test the observed cold UID error. Later condition order reverses
and interleaves modes/sources. Each native import has a60-second timeout; no
process timed out. Full native stdout, engine logs and reports are retained.

| Source | Exit path | Cold repeats | Native exit | Cold diagnostic | Warm retry |
| --- | --- | --- | --- | --- | --- |
|Baseline|--editor --quit|3|all0 /0x00000000|same UID error each|0, no diagnostics|
|Baseline|--import|3|all0 /0x00000000|same UID error each|0, no diagnostics|
|Retained H|--editor --quit|3|all0 /0x00000000|same UID error each|0, no diagnostics|
|Retained H|--import|3|all0 /0x00000000|same UID error each|0, no diagnostics|

Every cold run emits exactly the same diagnostic:
`ERROR: Unrecognized UID: "uid://botreihvj2l3f".` at ResourceUID.get_id_path.
It occurs during cold initialization before asset import completes. Both modes
then log completed filesystem scan, both reimport phases and editor layout.
All12 cold runs produce538 imported cache files, a UID cache and filesystem cache;
all205 declared sidecar remap targets exist, with zero missing targets.
The538 imported files are byte-identical across all twelve cold runs, both
sources/modes and all four warm retries. Warm runs import no additional assets
and emit no errors/warnings. This is concrete artifact/phase evidence, not proof
that every resource has been exercised in gameplay.

These are **not twelve error-clean validations**. Native exit0 coexists with the
cold UID error, and the helper returns failure when diagnostics remain. The
main runner's existing ERROR gate would still fail its import stage under either
command. Changing flags does not make that error disappear. Warm success supports
a cold-cache association; it does not settle the saved-UID initialization cause
or the separate known F5 tutorial-versus-Gym launch issue.

No native0xC0000005 was reproduced. Earlier round12 recorded completed asset
import/layout followed by that native exit; its cause remains unresolved.
No observed incomplete import, crash-rate difference or retained-only regression
supports the proposed first-iteration race in this bounded matrix. Three repeats
per condition cannot exclude an intermittent failure or establish engine-wide
reliability. No crash dumps, OS settings or unrelated engine/plugin architecture
were pursued.

The initial helper's broad Error-substring filter also listed the asset filename
LimboVarError.svg. Corrected to severity markers and reparsed the first four JSON
reports; the parser correction is recorded there. Full original native and driver
logs are preserved. The UID ERROR remains a failure; it is not filtered away.

### Proposed disposition and exact optional lifecycle diff

No evidence-supported crash fix is proposed. Leave the main runner unchanged.
If the supervisor separately wants its command to state the documented
wait-for-import contract explicitly, the complete optional diff is:

```diff
--- a/tools/test-dev-portal.py
+++ b/tools/test-dev-portal.py
@@
-        ["--headless", "--path", str(project), "--editor", "--quit"],
+        ["--headless", "--path", str(project), "--import"],
```

This is a contract-aligned command alternative with no demonstrated reliability
benefit here; **not applied or approved**. Criteria for a later authorized change:
keep all log/error/exit gates and isolated-copy rules; require completed imported
artifacts before the same runtime/editor-test consumers; preserve/report the
cold UID error and any native crash; verify the affected runner path without
silently treating a warm retry as a clean cold result. No automatic warm retry,
error suppression, project.godot repair or broader runner refactor is proposed.

### Reproduction, preserved evidence and stop

Evidence root: existing worker visualization directory. `round-16-imports/`
contains `<baseline|retained>-<first-iteration|import-complete>-<1|2|3>/` folders.
Each has pre-import hashes, local engine help, command/exit/native hex/timeout,
complete `cold-output.log`/`cold-engine.log`, imported-file hashes and remap
inventory in `report.json`. Repeat2 also has warm logs and before/after inventory.
Sibling driver logs preserve invocation output. Compact aggregate and identity:
`round-16-summary.json`. Initial native failures remain in their original earlier
round folders and ledger entries; no historical evidence is deleted.

Reproduce one condition with:
`python tools/tests/overnight_import_lifecycle_probe.py --godot <supplied-engine>
--work-root <new-evidence-root> --source baseline --mode first-iteration --repeat 1`.
Use retained/import-complete for the other conditions; optional `--warm` performs
one same-mode retry in that copy. Existing condition folders are never overwritten.

Main runner SHA remains
`b8647e546b6f13859de9acdc50ba9436a9a7166d97867f45e95068c208f484ac`.
Current retained runtime still matches all637 inputs/digest above. Helper SHA:
`596ad13fd8dc1f81fa9d81fc5a5e2be14394fab9ba4adb86d7d9084b258ad427`.
No production, project.godot, engine, main runner or gameplay behavior change.

READY_FOR_SUPERVISOR_REVIEW. All16 owned headless editor import/retry processes
ended before the02:40 HKT round deadline. No further experiments, desktop/OS
actions, commits, push, checkpoints or publication. Human acceptance and the
historical native crash remain open; successful imports do not grant clearance.

### Round16 supervisor disposition

Ultron `mode=tech-postflight` bounded implementation review COMPLETE, no new
conformance finding. Supervisor reviewed helper/source/ledger, summary, path-safe
Git archive/fresh profiles and preserved error gates. **Optional runner edit
rejected for this night:** no reliability difference was demonstrated. Keep the
main runner and project.godot unchanged; do not pursue engine diagnosis further.
Historical0xC0000005 and cold UID error remain unresolved, unwaived and visible.
No human/submission clearance follows this bounded review.

## Round17 — predeclared full-duel timing variation

Before play, fixed matrix (maximum11 complete attempts, no adaptive seeds):

- Controls: offset0 in default, mirrored and wall starts (3).
- Uniform independent integer offsets−3..+3, seeds1701 and9419, each in all
  three starts (6).
- Exploratory uniform offsets−6..+6, seeds1701 and9419, default only (2).

Only new `tools/tests/overnight_duel_timing_variation_test.gd` and this ledger
may change. Snapshot `round-17-before/`; isolated retained-H source/imported
cache, fresh engine/profile under `round-17-variation/`. The new fixture reuses
existing bound-input/full-duel/parry-policy helpers unchanged. Each native Enemy
action ID gets exactly one RNG draw, held throughout that action; trigger stays
native authored contact1.1 minus0.12 seconds plus offset/60. Eligibility,
approach, release and one legal melee punish stay in the existing parent policy.
Ordinary HP100/200, orbs0/Heat0, no resources/contacts/actions injected. Initial
layout placement only; actual UI Retry. Fixed60; fight bound90 logical seconds,
each owned engine process bounded90 wall seconds. Full outcomes are evidence,
not forced wins. Native telemetry/RNG policy is not human reaction or readability.

### Round17 completed outcomes

Exactly11 complete worker fights ran, each once. No extra seed, offset expansion,
control replay or production adjustment followed an outcome. Each uses native
Godot4.7.1 fixed60, authored Enemy contact1.1/length1.3, ordinary live E config.
Each natural victory is followed by actual bound Enter Retry and recorded reset.

| Condition | Starts / attempts | Victory ticks | Player HP | Incoming outcomes |
| --- | --- | --- | --- | --- |
|offset0 control|default / mirrored / wall (3)|1599 /1604 /1600|100 each|20 PARRIED each|
|±3 seed1701|default / mirrored / wall (3)|1599 /1604 /1600|100 each|20 PARRIED each|
|±3 seed9419|default / mirrored / wall (3)|1599 /1604 /1600|100 each|20 PARRIED each|
|±6 seed1701|default (1)|1599|100|20 PARRIED|
|±6 seed9419|default (1)|1599|100|20 PARRIED|

Every fight reaches Enemy0 via20 genuine APPLIED melee hits. No incoming APPLIED
or BLOCKED event, Player interruption, defeat or timeout occurs in this matrix.
Each has20 native action IDs,20 one-time draws,20 legal L1 presses and20 distinct
incoming contact results. No action rerolls or duplicate native contacts. The
six small-jitter fights support limited full-fight tolerance in this telemetry
policy. Wider sampled fights also win; no failure threshold was found or pursued.

Offsets actually vary: both ±3 seeds cover all seven integer offsets. Raw
contact-frame minus L1-input-frame leads span4–10 ticks. Wider seed1701 spans
offset−5..+6, input leads1–12; seed9419 spans−6..+6, leads1–13. Each exact sequence,
single draw frame, intended native-clock trigger, actual raw input frame and
contact frame is saved. Uniform randi_range draws are not forced coverage.
Raw frame-counter gaps cross input/process/physics phases; they do not define a
new effective parry-window length or change the existing0.2 config value.

No operational READY movement-lock/current-action/pending/buffer fault was
observed. Samples preserve attack progress, positions, reactions, locks, queues,
phase and Health; maximum no-Health/action-progress interval is84 ticks.
Final victory intentionally disables Player/current-area processing in Gym and
locks input, so the terminal snapshot may retain the killing attack mid-play.
It is not presented as a completed/unlocked action. Actual UI Retry replaces
that scene and restores100/200 HP, orbs0, Heat0, inactive reactions, empty pending/
buffer, unlocked movement and unpaused state in all11 cases. The timeout-menu
Retry branch is provided but unexercised because no fight times out.

The three no-jitter controls match the previous round12 retained-E full-parry
reports exactly in duration and bound input log. Event and Enemy HealthResult
dictionaries also match after removing **only** attacker_id/receiver_id. This
preserves policy comparability rather than substituting a new successful policy.

### Initial fixture failure and preserved evidence

The first default control naturally wins1599 ticks/HP100, but exits1 with87
checks and one invalid new assertion: it required one orb_created per APPLIED hit
throughout a full no-Cast fight. Existing Magic.add_orb correctly emits
orb_overflow at max_storage_capacity10. Its20 APPLIED hits produce12 created +8
overflow, with2 expired freeing slots; no generation or resource fault occurred.
Source inspection and the saved event list establish that existing rule.

Only the new assertion was corrected to created+overflow=APPLIED, and overflow
count was added to the report. No policy/offset/eligibility changes. The original
default fight/report/log and `fixture-first-control.gd` remain unchanged; the
fight is counted among the11 and **was not replayed**. Its original failed check
is not relabeled as passed. `round-17-summary.json` records the explicit
adjudication and verifies the corrected capacity rule from those saved events.

The remaining ten processes each exit0 with87 checks/failures[]. Across all11
original reports there are957 raw checks and that one false fixture assertion;
no engine ERROR/WARNING/SCRIPT ERROR appears. There are no other validity
failures, and zero recorded state faults. Syntax-only engine check also exited0;
no additional fight was used as a compile probe or to replace a disappointing
outcome. All outcomes and the original diagnostic remain visible.

### Identity, reproduction and supervisor replay

Only this ledger and new focused fixture change in the repository. Existing
duel/input helpers, main runner and every637 production file remain byte-equal
before/after and to the isolated candidate. Runtime digest unchanged:
`063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
Final new fixture SHA:
`8f5cea3b6e68168b717d0cb37bbbbfa28757accacd7d7b2f3555df4cedb9922c`.
This round reused the reviewed imported cache; it makes no new cold-import claim.
Round16 UID/native-crash limits and all earlier gameplay/feedback waivers persist.

Evidence under the worker visualization root:
`round-17-variation/<case>-output.log` and `<case>-engine.log`,
`project/variation-evidence/<case>-variation.json`, initial parse logs and original
fixture copy. `round-17-summary.json` stores identities, every offset sequence,
outcomes/checks/diagnostics, preserved failure adjudication and exact control
comparisons. Raw contact outcomes, input/decision/phase/sample logs and real Retry
input events/reset dictionaries remain in each report.

Per-case native command (each owned process timeout90s):
`--headless --audio-driver Dummy --path <isolated-project> --script
res://tools/tests/overnight_duel_timing_variation_test.gd --fixed-fps 60
--quit-after 6000 --log-file <case>-engine.log -- --case=j3_s1701_default`.
All11 names are in the fixture's predeclared matrix and report metadata.

Supervisor-only actual-render command prepared as `round-17-gpu-replay.ps1`
beside the evidence folders: run `-Case j3_s1701_default` (or another listed named
seed/layout, e.g. j6_s9419_default). Same exact source, no headless flag,
`--capture`; actual full-viewport initial/parry/generated/final-result frames
write beneath `round-17-variation/gpu-<case>/` with separate engine/output logs
and report. Worker did not execute GPU replay or inspect its images. Capture
checks/results must be reviewed separately from these headless counts.

READY_FOR_SUPERVISOR_REVIEW. All11 owned fight processes ended before02:50 HKT.
No concrete action-handoff/AI-state fault was demonstrated, so no production fix
is proposed. These finite scripted machine-policy results do not establish human
reaction/readability/fun, physical controller feel, real-time frame jitter,
optimal play, general timing tolerance or accepted balance. No autonomous next
round, desktop/OS action, commit/push/checkpoint or publication.

### Round17 supervisor actual-render supplement

Ultron `mode=tech-postflight` bounded implementation review COMPLETE; no new
conformance finding. Supervisor reviewed once-per-action draws, raw/derived
reports, legal input/state/reset and preserved capacity false assertion. Original
failed first-control record remains; do not claim957 checks all passed.

Supervisor independently replayed j6_s9419_default using actual default D3D12
Forward+ / RTX4090: exit0,95 checks/failures[],4 PNGs,20 PARRIED, Player100/
Enemy0,1599 ticks,20 draws/no state faults. Real Enter Retry restores100/200,
orbs0/Heat0, unlocked movement/no queues/reactions; no ERROR/WARNING. Evidence:
`round-17-variation/gpu-j6_s9419_default/`; supervisor inspected first_parry and
final_victory viewports. Worker read back the JSON metadata; image inspection
remains supervisor evidence. Limited machine-policy tolerance only; no human
window, balance or gameplay acceptance follows.

## Round18 — isolated feedback duration parameter comparison

Predeclared two variants only: A reviewed H with existing2.0s duration; B identical
except isolated Gym._load_configuration inserts
`config["ui"]["cast_feedback_duration"] = 1.2` adjacent to the existing hitbox
visibility override, before existing validation. Working Gym remains unchanged.
No export/control, shared JSON/mirror/global/default, FeedbackComponent geometry/
style/tween implementation or combat/AI/input change. Tutorial default stays2.0s.
Snapshot `round-18-before/`; isolated A/B copies/engines/profiles under matching
round folders. Repository scope: one new focused test if needed plus this ledger.

Hypothesis: duration shorter than1.3s Enemy cadence reduces old-number coexistence
and drift, with shorter reading time and faster fade/drift as explicit tradeoffs.
No arbitrary rule requires B to win; no parameter search or source promotion.
Actual combat and presentation-only palette/DoT/level examples stay distinct.

### Round18 source isolation and checks

Only the new `tools/tests/overnight_feedback_duration_test.gd` and this ledger
change in the working repository. New fixture extends the existing feedback
layout/input fixture without changing it. It adds real melee→held Charging→Cast
launch→legal next melee in both directions and overlays on/off, records label
birth/exit signals and samples0.2/0.8/1.2/1.4s after actual incoming contact,
absolute frame148 and fresh next contact, and performs actual pause-menu Retry.
Ordinary E stays enabled; no HealthEvent, DoT, orb, action or AI setup is injected.
Initial gap56 and bound facing input are explicit setup only.

Both A and B: syntax-only engine check exit0; new focused **153/153** plus
unchanged existing feedback fixture **110/110**, all runtime processes exit0,
failures[] and zero engine/script/resource warnings/errors. The unchanged fixture
preserves the exact archived real-combat frame148 scenario; the new flow's later
next-melee input and initial placement timing have their own labeled event frames.
These independent contexts are not silently equated.

All four new actual-combat cases have identical event/resource/action/phase
dictionaries A/B after removing **only** attacker_id/receiver_id. Each ends
Player60/Enemy167,2 generated orbs/1 commit/1 launched Cast and2 real melee
contacts. New right incoming frames70/149/228/310; left70/149/228/307. Those
ordinary facing/spacing differences are the same in A/B. Existing fixture's
actual combat also matches A/B after only those IDs are removed; A exactly
matches reviewed final H. Paused initial layout/style cases are byte-for-byte
equal dictionaries, including numeric/callout positions and sizes, actor scales,
18/12/16 font hierarchy, outlines, school colors, zero values and no spurious Lv0.

Working source and isolated A remain all637 runtime files byte-equal H, digest
`063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
B differs in **only** the one inserted Gym line before existing validation:

```diff
 config["ui"]["attack_hitbox_visible"] = false
+config["ui"]["cast_feedback_duration"] = 1.2
```

B runtime digest `bb53e9b371449bac7f6850edbf707d095273952f62c0c317e56ced96353e43ef`;
isolated Gym SHA `f6464f291a5d477459312662315c03514ac51caa013c4e3bce0a5ff7ec45a4e2`.
Working/A Gym SHA remains
`f7ccbd49c7f6d377f869fcd3c0acb82a500b10a3f983eba79b60f1bf976aed18`.
FeedbackComponent, shared JSON/mirror, all other runtime files and the existing
fixture remain unchanged. Shared/tutorial default2.0 is read back unchanged;
no tutorial runtime was launched or claimed verified. This round reused reviewed
imported caches and does not erase the earlier cold-import limits.

### Headless presentation findings and costs

Measured rectangles below are laid-out Control bounds, **not glyph/outline pixel
proof**. Actual renderer inspection is pending. The unchanged initial layout
case dictionaries establish unchanged starting geometry/style; changing duration
compresses the same fade/drift into less time.

The unchanged archived scenario at frame148, overlays on:

| Measurement | A2.0s | B1.2s |
| --- | --- | --- |
|Player labels|old10 alpha0.325, fresh10 alpha0.983|fresh10 alpha0.972 only|
|Old label in EventPanel|1 Control intersection|0|
|Player same-owner label pair overlaps|1|0|
|Fresh Player label top Y|172.953|172.255|
|Fresh Control clearance above EventPanel bottom172|0.953px|0.255px|
|NPC feedback remaining|13 alpha0.325 and Fire Lv.1 alpha1|none|

Thus B removes the stale Player number and same-owner overlap at that observed
next hit. The fresh number has **less** rectangle clearance because its upward
drift has advanced further. No anchor/clamp/scale change created a new margin.

The new right/on sequence, indexed from first actual Player contact at frame70:

| Contact age / native frame | A Player labels | B Player labels | Header evidence |
| --- | --- | --- | --- |
|0.2s /82|1, alpha0.900, top167.743|1, alpha0.833, top163.647|both intersect EventPanel|
|0.8s /118|1, alpha0.600, top150.489|1, alpha0.333, top139.359|both intersect; B is higher/fainter|
|1.2s /142|1, alpha0.400|none|old B label gone|
|1.4s /154|old0.300 + fresh0.958|fresh0.931 only|A2 header intersections/1 pair; B1 header intersection/no pair|

At next contact+2, frame151 in this new case, A has2 Player labels/one pair
overlap, B1/no pair. Absolute148 in this case is just before native second hit149:
A still has old10 alpha0.350 in the header; B none. It is distinct from archived
frame148 above, which already contains the fresh next number.

NPC repeated-number evidence from the same actual melee/Cast/melee sequence:
at frame118 A has4 labels/3 pair intersections; B3 labels/1 pair intersection.
At148 A retains13/callout/next10 with one numeric pair intersection; B only next10
with no pair intersection. Earlier fresh frame69 still has a numeric pair overlap
in both. Overlay-off cases preserve the same label timing/geometry while those
debug panels are hidden. This is a reduction in sampled old-label coexistence,
not a stacking solution or proof all repeated-hit layouts are clear.

Costs remain explicit:40% shorter nominal reading time; faster alpha loss and
upward travel; near-header fresh feedback can enter the header earlier; level
callouts disappear sooner. B still has header intersections and initial/simultaneous
number overlap. No headless test can establish whether values feel fleeting or
are easier to read, and there is no automatic B acceptance rule.

### Absolute lifetimes, zero/DoT/levels, pause and Retry

Tree birth/exit signals record actual native frame counters. In new right/on
combat, representative absolute local frames are:

| Real feedback | Onset | A exit | B exit |
| --- | --- | --- | --- |
|NPC melee10|17|137|88|
|NPC Cast13 and Fire Lv.1|67|187|138|
|Player incoming10|70|190|141|
|NPC next melee10|116|236|187|

Observed natural frame gaps are120 ticks for A and71 for B. These stamps include
creation-frame/callback ordering and frame quantization; the configured values
remain exactly2.0/1.2. No timer seeking or artificial time advancement is used.
Late labels still alive at UI Retry are explicitly marked as owner teardown,
not falsely counted as natural lifetime expiry.

Separate **layout-only NPC API examples**, with no manufactured HealthEvent or
gameplay DoT/level8 Cast, cover direct0/10, smaller DoT0/3 and school-level1/4/8.
All seven are born at3 and naturally exit A123/B74 in their probe scene. Their
fonts, zero strings, school colors/outlines and initial positions stay unchanged;
Cast labels remain opaque until their existing timer removes them, while numeric
alpha fades. NPC Health stays200. Ordinary E may independently hit Player during
that unpaused probe; this is not attributed to the presentation calls.

Existing paused probe confirms owner-bound direct/DoT tweens remain alive,
stationary and opaque during pause; Cast-level SceneTree timers continue and
expire after each variant's own duration. Resume completes numeric lifetimes.
This pre-existing pause difference remains unchanged. Actual Esc/Down/Enter Retry
clears both owners' labels and restores100/200 HP, orbs0/Heat0 and the correct
configured duration in both cases: A2.0, B1.2, including after the pause probe.
No direct reset or resource edit substitutes for menu input.

### Evidence and prepared actual-render comparison

Evidence folders `round-18-A/` and `round-18-B/` retain new duration-output/engine
logs, syntax logs, `project/duration-evidence/<A|B>-duration.json`, unchanged-suite
standard-output/engine logs and `standard-evidence/<A|B>standard-feedback-report.json`.
`round-18-identity.json` contains exact source/delta hashes and equality checks;
`round-18-summary.json` contains compact lifecycle/opacity/rectangle/overlap/reset
evidence. Working new fixture SHA:
`e6c86c2c1ffd030aac827fbca03e7933f6c6ab7f269cc3bcb6a765e32cb27447`.

Native commands use isolated engine/profile, fixed60, Dummy audio and process
timeout90s: `--headless --path <project> --script
res://tools/tests/overnight_feedback_duration_test.gd --fixed-fps 60
--quit-after 10000 --log-file <named-log> -- --variant=<A|B>
--expected-duration=<2.0|1.2>`. Existing standard suite uses its unchanged script
and separate output path. Each job checks the remaining deadline before launch.

Supervisor-only `round-18-gpu-replay.ps1` beside the evidence folders prepares:

- `-Variant A -Mode Extended -Case right_on -IncludeProbes`, then identical B:
  actual contact+0.2/0.8/1.2/1.4s, fresh/old frame148/next contact, post-Retry,
  layout-only zero/DoT/level palettes and lifetime samples. Optional left_off
  selects the other facing/hidden overlay. Omit IncludeProbes for combat only.
- `-Variant A -Mode Standard`, then B: unchanged original actual frame18/68/148
  replay plus existing layout/pause/reset probes, directly comparable with H.

These omit headless and use actual frame_post_draw/full1280×720 viewport saves,
with separately named GPU folders/logs/reports and90s timeout. Existing output
folders are refused to preserve prior captures. Worker did not run GPU comparison
or inspect any Round18 images. Actual-render checks/capture counts and glyph
findings must be reviewed separately, without equating them to headless counts.

### Disposition

READY_FOR_SUPERVISOR_REVIEW. Hold B isolated for renderer/readability review;
working production stays H2.0s. Data support fewer old labels in sampled E cadence
but show the faster-drift/fade costs. No promotion, accepted Decision or parameter
search. All owned processes ended before03:05 HKT. Human reading time/feel and
all earlier validation limits remain pending. No engine investigation, OS action,
commit/push/checkpoint/publication or autonomous next round.

### Round18 supervisor review and final disposition

Ultron `mode=tech-postflight` reviewed the exact isolated one-line Gym override,
fixture/events/lifetimes/reset and headless evidence; no core-behavior delta was
demonstrated. Supervisor **rejects B for this night's production promotion** and
retains H2.0s. This is an experiment disposition, not a proven gameplay fault or
a claim1.2 feels bad to a human. B evidence remains intact for reference.

Separate native graphical outcomes:

- A Extended/right_on/IncludeProbes, default D3D12 Forward+ / RTX4090: exit0,
  **174 checks/failures[],24 PNGs**, contacts70/149/228/310, HP60/167. Evidence
  `round-18-A/gpu-right_on-probes/`.
- B's first matching default-renderer launch **FAILED** at startup, native exit
  **3221226356 /0xC0000374**, before gameplay traces or captures. Preserved
  `round-18-B/gpu-right_on-probes/` engine/output logs contain only engine version
  and D3D12 device line; no JSON/PNG exists. Do not count this as a pass or infer
  the cause from the1.2 parameter. No native dump/engine/OS investigation followed.
- One bounded supervisor B retry with CLI `--rendering-method gl_compatibility`:
  exit0, **174 checks/failures[],24 PNGs**, same contacts/Health. Evidence
  `round-18-B/supervisor-gl-right_on-probes/`. This is a separate renderer/run,
  not erasure of the failed default launch or a renderer-default change.

Supervisor inspected A/B actual frames118 and151. B151 removes the older white10
and NPC13/callout; B118's white10 is fainter/higher in the header. Initial overlap
remains.40% shorter reading time/faster drift is insufficient for autonomous
promotion. These A D3D12 / B GL views are mixed-renderer observations, not a
controlled renderer/performance comparison. Worker read back reports/file
inventories; image judgments are explicitly supervisor evidence.

Counts174 GPU are separate from153 focused+110 existing headless checks. Carry
the new unresolved native startup0xC0000374 alongside earlier0xC0000005, cold UID
error and historical shutdown warnings. No failure is waived, attributed to
gameplay, or promoted to an engine-wide cause. Working637-file H identity is
unchanged; no human/controller/balance/submission acceptance follows.

## Round19 — integrated candidate review / morning handoff DRAFT

Requested frozen package review is complete at the source/record scope. New
`docs/iterations/2026-10-20-morning-handoff.md` is about1500 words plus the compact
file appendix, intended for roughly3–4 pages depending on Markdown rendering.
It links9 supervisor-produced actual PNGs with fixture/source/renderer qualifiers;
no image, plot or comic was fabricated, and no new viewport/controller play ran.

### What was checked and changed

- Inspected current Git state and the night's tracked diff against644587b;
  inventory/hashed all changed/untracked files and reviewed the focused fixtures/
  candidate records. Before:20 tracked modifications+14 untracked files. After
  adding this report:20 M+15 U,35 Git-visible paths; every path appears in the
  report appendix. No unexpected new user path or unrelated byte change appeared.
- All637 current runtime files still match H digest
  `063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
  Exactly8 runtime files differ from644587b: four native clips, Gym scene,
  Might, Enemy and FeedbackComponent. Two tilde DLL backups remain preserved
  outside the established runner manifest. Main runner/project.godot unchanged.
- Reconciled current candidate claims against code: Gym scene Poise10 vs script
  default1/tutorial0; shared contact1.1/end1.3/speed1/no-tail cadence effect;
  Cast0.36→0.24 piecewise pose mapping/full completion; X2/X3X40 and equal outer
  reach loss; action-owned progress guard; initial deep-copy snapshot; H offsets
  with unchanged2s lifetime/scale/clamp limits. No material new mismatch found.
- Added only the morning draft, this ledger and an exact current-evidence/status
  note in IMPLEMENTATION_STATUS. GDD/TDD candidate statements agree at that
  scope; unrelated historical sections and accepted waivers were not rewritten.
  No whole-document/architecture/submission synchronization claim.
- The report distinguishes source/API probes, scripted headless/native GPU
  evidence and unvalidated physical-controller/human acceptance. It carries
  wall losses/fumbles, timing-variation limits, invalid capacity/geometry/
  callback fixture assumptions, F5/UID mismatch, both unexplained native crashes,
  historical shutdown warnings, and separate source versions/counts. It never
  aggregates overlapping checks or recasts the failed first-control/B startup
  records as passed. No suite was rerun solely for reporting; earlier tests
  retain their source/dependency provenance and the H feedback-only delta is
  explicit.

### Review evidence / actual work cursor

`round-19-review/before-inventory.json` records the initial state/hashes;
`tracked-night.diff` preserves that tracked diff. `final-identity.json` records
the verified branch/HEAD, all637 runtime hashes,8 production SHA identities,
full final changed/untracked inventory, no staged changes and no unexpected
source changes. `final-tracked-night.diff` retains the final tracked view.
Local PNG targets and appendix coverage were verified. Evidence identity was
read back rather than inferred from file existence or a test exit alone.

Worker remains independent Combat task `overnight_melee_cast_ai_2026_10_19`,
same existing thread/binding. Work cursor: **Round19 bounded supervisor review
complete; report/candidate frozen, exact documentation clarifications applied**.
Next step is standby for the supervisor's explicit final-stop/cutoff-documentation
dispatch; scheduled owned-session stop and heartbeat disabling remain pending.
The user's focused8-minute explicit-Gym morning sequence and retain/adjust/defer
decisions remain future human work. No service cursor,
progress UID, checkpoint, task restoration or message to another chat is invented.

READY_FOR_SUPERVISOR_REVIEW. Round19 used source/doc/file inspection only;
all owned commands ended and no engine sessions were launched. Draft is ready
before03:20 HKT. No source/tuning/accepted Decision, suite rerun, engine/OS/
renderer-default change, commit/push/checkpoint/publication or autonomous next
round. Absolute overnight05:30/05:50/06:00 hard stops remain in force.

### Round19 bounded review completion / exact final clarifications

Supervisor Ultron `mode=tech-postflight` independently inspected the8-file
production diff, report/ledger/status/candidate values and raw637 identity/
inventory. Bounded implementation/report review COMPLETE; no new gameplay/source
conformance finding. No human acceptance or submission clearance follows.

Only the report, this ledger and the corresponding status note were clarified:

- Limited **native keyboard/mouse baseline** is separated from later scripted
  InputMap/GPU evidence and unvalidated physical-controller feel. Per baseline
  observations at ledger line86 and supervisor clarification: explicit Gym F6
  launch, natural idle defeat/actual Retry reset, native left-mouse X1 causes10
  damage and1 generated orb. This predates retained H. Native held Charging,
  release Cast, parry, full-fight/current-H controller feel were not established
  by that limited interaction; later full routes remain scripted evidence.
- Report PNG/file links now use real angle-wrapped Windows absolute targets
  `C:/Users/...`, removing the synthetic leading slash. Target files exist;
  source classifications, counts, failures, rejections and35-path inventory stay.
- Report marked **supervisor-reviewed/frozen**. Scheduled final owned-session
  stop and heartbeat disabling remain **pending**; only an actual completed stop
  can support a later cutoff/cleanup completion record. Supervisor handles the
  independent final review/native cleanup and any later cutoff documentation.

Prior Round19 identity/diff files retain their dated source/inventory snapshot;
these doc-only clarifications do not rewrite historical evidence. The retained
runtime identity remains `063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
No other file, suite, game/source, main runner, project.godot, renderer/OS setting,
chat, commit/push/checkpoint or publication operation. Worker commands end before
03:10 HKT and return READY_FOR_SUPERVISOR_REVIEW, then **STANDBY**. No autonomous
next work and no claim that the scheduled final stop/heartbeat disabling is done.

Final clarification verification at02:55 HKT:10 real Windows link targets exist;
all637 runtime hashes and all pre-existing non-record dirty-file bytes remain
unchanged. Git inventory now includes12 additional untracked test `.gd.uid`
sidecars (20 M+27 U), which appeared after the35-path draft snapshot. The first
inventory assertion therefore failed; it was not treated as a pass. No sidecar
was modified/deleted or its cause investigated. The35-path report appendix is
explicitly retained as the reviewed snapshot; later additions await supervisor
disposition. This does not alter the frozen runtime or authorize cleanup.
Worker stops here after the exact record clarifications, with final owned-session
stop and heartbeat disabling still pending, and returns to STANDBY.

### Round19 confirmed native reload / metadata provenance and current inventory

Supervisor identified the12 `.gd.uid` additions: native Godot Reload from disk/
scan generated them. They are preserved metadata for the twelve new GDScript
tests, not unexpected user code and not a deletion/cleanup target. Current
inventory is **20 M+27 U=47 Git-visible paths**; the report appendix now lists
all47, including every UID sidecar. The02:49 35-path identity/diff remains a
clearly historical snapshot. `round-19-review/metadata-inventory-update.json`
records the current inventory/provenance without replacing earlier evidence.

Separate limited **current retained-H native** observations, supervisor-reported:

1. ComputerUse F8 stopped the old Poise1 baseline run. The editor's external-newer
   gym.tscn prompt was handled with Reload from disk; reviewed Poise10 inspected.
2. Selected Gym F6 launched the retained source. Native viewport showed Poise10,
   ordinary Enemy hits and natural idle defeat. Native Return Retry visibly
   restored100/200 HP,0 Heat,0 orbs and cleared readout/labels.
3. Escape did not produce a visible Pause before more damage/defeat. Focus/input
   delivery in the embedded Game host was unsettled. This is neither native
   pause validation nor a demonstrated production fault. Native held Charging/
   release Cast/parry/active full-duel and physical-controller feel remain open.
4. F8 stopped the fresh owned play run. Supervisor `sky.list_windows` verified
   only editor window5245890 remained, with no LaemaDEBUG. The editor stays open.
   **All supervisor-owned parent play runs stopped02:56 HKT**; worker-owned runs
   already ended. The worker did not perform desktop control or stop these runs.

Supervisor independently confirmed all637 runtime hashes unchanged at02:56:28
HKT. No saved code/editor-property edits, runtime-value changes or OS settings.
This current-H evidence is distinct from the initial baseline native left-mouse
X1 ten damage/one generated orb and from later full scripted InputMap/GPU routes.
It does not expand those observations into human/gameplay/submission acceptance.

Scheduled **05:50 final worker/session stop and heartbeat disabling are still
pending**. Stopped native play runs do not establish that later scheduled stop.
Only report/ledger/status/current inventory documentation changes were made;
no tests, new run, tuning, deletion, commit/push/checkpoint or publication.
Return READY_FOR_SUPERVISOR_REVIEW before03:10 HKT, then STANDBY for an explicit
supervisor dispatch. No autonomous next action or premature cutoff-completion claim.

### 05:33 HKT final independent verification / content-final record

Supervisor bounded Ultron `mode=tech-postflight` review of the Round19
clarifications/47-path report is **IMPLEMENTATION_REVIEW_COMPLETE**, no new
conformance finding. Human feel/controller/submission acceptance remains pending.
Source was frozen before05:30; this final phase is records/verification only.
No new experiment, code/test/helper/asset/tuning edit or engine run is authorized.

Supervisor independently read/verified at this check:

- HEAD `644587bc9e570aed5d7c78cc00f8f81a6defff67` and every637 runtime hash match
  frozen H `063923eddfda510fb5ffd3cf30426f99ddf07c7b8b170be837db75f04d60b4c2`.
- 47 Git-visible paths, no staged files, every path in the current appendix and
  all11 absolute local PNG/file links resolve. Historical35→current47 UID
  metadata provenance remains intact.
- Report SHA **at the supervisor check**:
  `dd3b5d52ccc1957781ba90b53313eab8ea4e3eeb38740f0ec89f84a1e96ecd28`.
  This identifies the version before this final documentation stamp; no new
  post-edit hash or suite rerun is claimed.
- Process inventory contains only user Godot editor PID37568 (`--path Laema -e`,
  player.tscn editor context); no native/isolated game or owned headless run.
  Preserve the editor open. Native parent play runs were already verified
  stopped02:56; worker-owned runs ended earlier.
- Heartbeat confirmed **ACTIVE** via supervisor automation tool/config.
  Scheduled05:50 final worker/session stop and heartbeat disabling are **pending**;
  no completion is claimed before actual execution.

Only ledger, morning report and implementation-status records were amended to
mark report **CONTENT FINAL / frozen candidate, awaiting final shutdown stamp**.
All known failures, native Pause uncertainty and evidence-source distinctions
remain. No new accepted Decision or source/runtime/OS/renderer/main-runner edit.
No recheck/hash/suite/engine operation was run merely to repeat the supervisor's
counts. Record clarifications complete before05:45, owned commands end, then
READY_FOR_SUPERVISOR_REVIEW / STANDBY. Supervisor will dispatch the final shutdown
record after pausing heartbeat during05:50–06:00. At06:00 begin no project work
under any circumstances; cleanup/stop only. No autonomous next task, commit,
push, publication or checkpoint.

### Final shutdown record — 2026-10-20 05:54:10 HKT

OVERNIGHT_EXECUTION_ENDED. This is final documentation/stop within the05:50–06:00
window, not another round. Actual worker finish/stop stamp from clock: **2026-10-20 05:54:10 HKT**.
All worker-owned jobs had already ended; no new game, test, check or hash run
started for shutdown. This record operation completes the worker's owned work.

Supervisor just confirmed automation_update status **PAUSED05:53 HKT** for
`supervise-laema-overnight-until-06-00`, with existing prompt/cadence/thread
preserved. No further supervision run is expected. Parent native play runs were
closed02:56; recent supervisor inventory contains only user Godot editor PID37568,
no owned native/isolated/headless run. Preserve the editor open. No OS or renderer
setting was changed and no new process check is claimed here.

Morning report and implementation status now say FINAL HANDOFF, with the same
637-file H identity,47-path appendix, all known errors/tradeoffs, native Pause
uncertainty and morning sequence preserved. Source was frozen before05:30.
Human feel/controller/submission acceptance remains pending. No source/config/
UID edits, suite rerun, commit/push/checkpoint/publication or message to another
chat. No autonomous next step; remain stopped until a direct human request.
At/after06:00 begin no project work or edits under any circumstances; cleanup/
stop only. Earlier ACTIVE/pending entries are historical, superseded by this
actual PAUSED/final-stop record.
