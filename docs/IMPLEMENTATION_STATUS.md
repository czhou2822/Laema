# Implementation Status

## Benchmark pacing and charged-orb progress — 2026-10-19

User-approved candidate: Fire benchmark private configuration multiplies Player
Fire X windup/recovery, shared Cast animation duration and opponent windup/recovery
by 1.5 at load. Fire X1 becomes 0.21 + 0.51 s before Heat; opponent base timing
0.6/0.9 s becomes 0.9/1.35 s. Charging and its Heat multiplier retain their current
rate. Shared saved tuning is unchanged, and retry derives a fresh scaled profile.

The shared HUD derives both its charge bar and Spell Level from charged flags
in the orb snapshot. Three charged orbs fill 3/8; empty or uncharged queues fill
zero regardless of banked capacity. The bar advances in completed-orb steps;
underlying banked charging and partial progression are preserved.

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
