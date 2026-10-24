# Implementation Status

## Five shared hit-reaction shake levels — October 24

Status: `AWAITING_USER_VALIDATION`. Approved 13-file follow-up to preserved main
`98676e1e4aefcb9453040ae24bd1c30a9dcc4bfd`, on the isolated
`codex/five-level-hit-reaction-shake` branch. Local integration is authorized;
the final handoff records its actual commit/merge result. No push/export or
closed overnight iteration is authorized. User-owned dirty tuning, research,
AI and department work are excluded from this slice's commits.

Changed scope:
- `scripts/config/combat_reaction_level_tuning.gd`: two editable camera fields,
  indexed provisional defaults and level dictionary transport.
- `scripts/config/character_reaction_settings.gd`: shared-level transport and
  hidden, retained old profile data.
- `scripts/config/combat_tuning_settings.gd`: existing live Inspector mirror
  carries the new pairs without changing ownership or other tuning.
- `scripts/config/prototype_config_loader.gd`: missing-only full-profile
  initialization, finite/range validation and lossless inactive old-domain data.
- `scripts/prototype/prototype_arena.gd`: resolved Levels1–5 select their
  captured pair; old Level3 cutoff and second strength multiplier are removed.
- `scripts/config/developer_settings_catalog.gd` and
  `scripts/ui/developer_settings_fields.gd`: camera row inside each existing
  hit-reaction level in both Portals, with units/tooltips; no separate camera
  category or treatment selector.
- `config/characters/hit_reaction.tres` and `config/combat_tuning.tres`:
  initialize only the new camera properties in the two existing level arrays.
- `docs/GAME_DESIGN.md`, `docs/TECH_ARCHITECTURE.md`, `docs/GYM.md` and this file:
  exact accepted decision, current data flow, authoring and evidence boundaries.

Starting pairs L1–5 are0.5px/0.04s,1px/0.06s,1.5px/0.08s,2px/0.10s,3px/0.12s.
They are provisional, not feel acceptance. Explicit authored new fields win
over missing-only initialization. Old Precise/Weight numeric fields still
round-trip as inactive storage; old UI numeric keys are retained too. No
profile is chosen as the new source and startup does not save files. Contact
accents keep their retained preference and renderer. No actor, eligibility,
Impact/Poise, damage, AI, reaction stun/motion/distance or X1–X5 mapping changes.

Checks performed: standalone gdtoolkit4.5 grammar parsing of all seven changed
scripts; JSON parsing; exact 13-path scope and stale-reference review;
`git diff --check`; static inspection of Resource → configuration → bridge /
Portal save → selected cue → camera consumption, including a non-default
L2 pair and explicit zero strength. Removing only the ten added property lines
from each Resource reproduces its baseline text after newline normalization;
both arrays match the five accepted pairs. All existing reaction/tuning values
and Resource identities are retained. Static inspection confirms no Level3
camera gate, old profile lookup or second level multiplier in the consumer.
The local integration commit/result is reported in the final handoff.
No Godot/editor/runtime/build/test execution or test creation/modification is
authorized. Existing old-profile fixtures are not updated or claimed passing.

User validation:
1. Preserve unsaved Portal drafts, then refresh the editor plugin. Compare all
   five camera pairs in the shared Resource Inspector and both Portals under
   Combat → Hit-reaction levels → Levels1–5. No camera tab/selector should remain.
2. Set L2 to a distinctive pair, e.g.0.75px/0.09s, Save Tuning / Review & save,
   reload and compare the shared Resource, live mirror and both Portals. Other
   levels, reaction values, switches and unrelated tuning must stay unchanged.
3. With camera enabled, exercise eligible resolved Levels1–5 in Gym and tutorial/
   Final Arena; Levels1–2 now shake. Camera off and per-level strength0 suppress
   their motion. Contact cues remain independently unchanged.
4. Check stronger/weaker overlapping cues, pause/retry, stage transitions and
   teardown for offset restoration. Confirm native serialization and legacy
   full-profile save/reload preserve explicit new values and old inactive data.

Remaining risk: native Resource/Inspector/Portal serialization and visible
behavior are unrun. Static evidence does not establish comfort or runtime
correctness. The separate Pikeman reaction-mapping proposal remains open.

## Historical shared camera-profile ownership — October 24 (superseded)

The following preserves the earlier ten-file scope/evidence; its four global
profiles, category and Level3+ threshold are superseded by the current entry.

Status: `AWAITING_USER_VALIDATION`. The human amended camera authoring to use
the shared hit-reaction domain rather than scene/UI numeric settings. This
follow-up starts from main `574270f66bcbeed72db07778ef612ee37ea8d932`; the first
pass `e1355179` is already integrated. Existing unrelated research/department
drafts remain user-owned and are excluded. No overnight iteration or unretained
P1/T2 branch is resumed, and no push/export/automation is authorized.

Exact ten-file scope:
- `scripts/config/character_reaction_settings.gd`: authoritative defaults,
  four global Resource exports, get/read mapping.
- `config/characters/hit_reaction.tres`: move the four current numeric values
  into the shared Resource without editing existing levels/properties.
- `scripts/config/combat_tuning_settings.gd`: preserve the existing four live
  Inspector mirror controls, now mapped through the hit-reaction domain.
- `scripts/config/prototype_config_loader.gd`: shared-default alias,
  hit-reaction validation and conflict-preserving legacy migration.
- `scripts/config/developer_settings_catalog.gd`: both Portals' Hit Reaction
  Camera category binds the same four shared values, not UI overrides.
- `scripts/prototype/prototype_arena.gd`: capture from shared reaction data;
  existing confirmed-result/level trigger and renderer remain unchanged.
- `config/prototype_combat.json`: remove only the four retired numeric UI
  keys; preserve all switches, treatment and other preferences.
- `docs/TECH_ARCHITECTURE.md`, `docs/GYM.md` and this status: current shared
  ownership, navigation, migration and validation limits.

Saved values/defaults remain Precise1px/0.08s, Weight3px/0.11s; ranges remain
0–3px and0.001–0.120s. Exactly four profile settings exist, not four per level.
CharacterSettingsStore's already-shared reaction Resource and existing
save/hash/conflict path carry the fields; no new manager or scene export is
needed. An explicit legacy UI/shared mismatch fails rather than silently
selecting scene data or losing a draft.

Source-covered ordinary scenes are Gym and PrototypeArena, including its
tutorial areas/Final Arena. Both use the canonical loader, same shared reaction
Resource and existing Arena renderer. No runtime or custom independent-camera
coverage is claimed. The original direct Health-loss gating, resolved reaction
level, Level3+ threshold, deduplication, scaling/waveform, switches, cue capture,
pause/retry/detached teardown and all gameplay remain outside the change.

Checks performed: five standalone gdtoolkit4.5 grammar parses, whitespace/diff
checks and complete Resource/Inspector/Portal/legacy/save/cue-source tracing.
All four numeric values moved unchanged. Removing just those four new Resource
lines reproduces the original Resource text exactly, including all existing
levels; removing just the four old UI lines reproduces the new JSON exactly.
The renderer changed only its profile source read; seven camera/lifecycle/
apply/save methods compare unchanged. No scenes, actor/gameplay/Feedback code,
other tuning Resources or tests changed. Bounded source review found no
established source blockers; it is not submission/runtime clearance.

No engine/editor, automated test, test creation/modification, rendered run or
save simulation was performed. The old overnight results remain historical.
Actual new Resource serialization, Inspector/live Portal behavior, cross-scene
persistence and legacy migration remain unverified.

Manual validation:
1. Open the shared `hit_reaction.tres`; edit one profile and save. Confirm
   Player/Enemy both reference it and all existing level values remain intact.
2. Compare **Combat → Hit Reaction Camera** in both Portals and the assigned
   live Inspector mirror. Change one of the four values, Save Tuning / Review
   & save, restart and inspect the shared Resource. UI JSON must not regain
   numeric camera overrides or reset enable/treatment preferences.
3. Compare Gym and tutorial/Final Arena using the same shared values, both
   treatments and the existing trigger/cleanup boundaries. Active cues keep
   captures; no scene-specific authoring is required.
4. Check a retained legacy profile separately: missing shared values migrate
   without startup writes; explicit differing UI/shared data reports the
   conflict and leaves files untouched.

## Historical initial camera Inspector / Portal pass — October 24

Its JSON numeric ownership is superseded by the shared-reaction follow-up above;
this retained entry describes the original e1355179 scope/evidence only.

Status: `AWAITING_USER_VALIDATION`. This is a new human-approved task after
the overnight run closed: expose Precise and Weight camera strength/duration
through the existing Inspector and both Dev Portals, then integrate locally.
Base is current local main `162ff3f4ce057cdd6bd8fe5b47d4e539ca9c8686`; the
dispatch's `e693b4a4` was followed by a user tuning save. The initially inspected
main tree is clean. Existing overnight/P1/T2 branches remain preserved; no
unretained experiment, automation, remote publication or export is resumed.

Exact eight-file scope:
- `scripts/config/prototype_config_loader.gd`: shared four-field defaults,
  in-memory legacy normalization and finite/range validation.
- `scripts/config/combat_tuning_settings.gd`: four exported Inspector controls,
  mapped through the existing Resource/bridge get/read/apply/save flow to JSON.
- `scripts/config/developer_settings_catalog.gd`: four clearly labeled controls
  in Cosmetic impact feedback, matching units, limits and wrapped help.
- `scripts/prototype/prototype_arena.gd`: consume authored values captured per
  qualifying cue in the existing camera calculation, not per-frame literals.
- `config/prototype_combat.json`: add the four exact defaults only; preserve
  saved enabled switches, Weight treatment and every other value.
- `docs/TECH_ARCHITECTURE.md`, `docs/GYM.md` and this status: directly affected
  technical ownership, navigation, authoring and evidence limits.

Defaults are Precise1.0viewport px/0.08s and Weight3.0viewport px/0.11s.
Both profiles accept0–3px and0.001–0.120s, retaining the GDD caps. JSON remains
authoritative. The assigned CombatTuningSettings is an Inspector mirror, not a
competing stored profile. No `combat_tuning.tres` or character/style Resource
edit, scene change, new manager, bridge refactor or caller change is needed.

Preserved: confirmed APPLIED direct Health-loss gating, Level3+ threshold,
level scaling, treatment/enable choices, direction, waveform/fade, additive
camera-offset composition and pause/retry/teardown behavior. Contact accent,
labels, combat/timing/AI, native geometry/assets, damage/protection, Heat/orbs,
input, defence/dodge and all user tuning remain outside the change.

Checks performed: four standalone gdtoolkit4.5 grammar parses, whitespace/diff
checks, exact four-default/JSON preservation review, and complete source tracing
through Inspector get/read/apply, bridge rollback/sync, guarded Store/Portal save,
legacy load, per-cue capture and camera consumption. The existing waveform and
nine unrelated bridge/Arena/mirror methods compare unchanged. Protected
character/style Resources, native geometry, gameplay, Feedback and tests have no
diff. A bounded Ultron mode=tech-postflight source review found no established
source blockers; IMPLEMENTATION_REVIEW_COMPLETE is not submission clearance.

No engine, editor, rendered run, automated test or test creation/modification
was performed. The closed overnight permissions and old1,998-check/rendered
receipts do not validate these fields. Godot type/import validation, Inspector
layout and actual live apply/save/reload remain unverified. Local integration
is authorized only for this exact source/docs change, preserving the current
tuning; final implementation/main commit identities accompany the handoff.

Manual validation after local integration:
1. In Player → CombatTuning → Settings → Cosmetic impact feedback, check both
   camera groups, units and default values. Compare both Portals' same fields.
2. Set a non-default Precise value, for example2px/0.10s, using the assigned
   Inspector bridge; verify JSON/Portal agreement. Change Weight independently
   and confirm no treatment/switch/contact or character tuning is overwritten.
3. Use the normal Save Tuning / Review & save flows, restart and compare all
   four saved values in Inspector and both Portals. Legacy missing keys must
   restore only the four defaults, without a startup file write.
4. Exercise qualifying Level3–5 cues in both treatments, camera off/contact on,
   camera on/contact off, pause/retry and detached teardown. New values affect
   subsequent cues; active cues keep their captured values. Restore preferred
   tuning afterward. Human comfort/readability remains unverified.

## Overnight Fire game-feel candidates — October 23–24

Status: `AWAITING_USER_VALIDATION`. User-authorized bounded implementation,
rendered comparison, canonical synchronization and local merge; no push or Web
export. Source basis is f6ccfbe03143b5bf591ee83f5725ddb3919644b3 plus shared
Resource commit4b715460 and U's feedback/support sequence through1660dd04.
R1ab284aa7 was integrated locally asd6a74074; T1's one-Resource5cc98e8e was
integrated as3200279f. Current product head is3200279f4f69f0f9e6fdb5bac0f0674befda5890.
The [numbered report](iterations/2026-10-23-fire-combat-overnight/REPORT.md) and
[ledger](iterations/2026-10-23-fire-combat-overnight/PROGRESS.md) own exact local
integration/replay receipts, selected original evidence and trial limitations.

Retained scope:

- Shared Level4 motion1.15→0.15s in the authoritative Resource and existing
  mirror only. Same20px distance and1.15s stun; every other level unchanged.
- Fire X5 T1 pre-split duration0.30→0.55, recovery1.10 retained, base1.65s.
  Other style values, native poses/geometry/markers and normalized rules fixed.
- Optional confirmed-damage Precise/Weight contact and additive heavy-camera
  response in existing Feedback/Resolver/Arena/config owners. Independent
  switches default off. Mixed layers keep separate results and one cue.
- Same-frame amount/caption sibling spacing and lifetime moving-edge clamp in
  existing Feedback, preserving separate numbers, fonts, timing and DoT.
- New-control label/tooltip fit, exact detached-Area cleanup guard and the
  actually used read-only recorder observations; no new gameplay owner.
  R1 additionally guards/disconnects the detached Arena camera callback.

Actual agent evidence: Windows Godot4.7.1/1280×720/60physicsHz, normal bound input,
no forced Health/Heat/orbs/hits/positions/AI/clocks. Baseline and retained variants
completed encounters with zero unexpected inputs in the clean trials. Level4
delivered20px in9physics steps while hurt persisted approximately1.15s. Native
mixed-Cast before/after showed separate13/10 and Water4/Fire2;22right-edge samples
kept8px gaps and outlined bounds within12px margins during target movement.
Native controls, live independent off switches, Save and fresh-process reload
were checked. Configuration serialization was then restored byte-identically
before subsequent comparisons. Actual Retry/quit no longer reproduced the new
detached-Area error. A separate normal Gym Retry camera-callback error was then
found in final play and repaired by R1; fresh ordinary Retry/complete fights
did not reproduce it. Generic ObjectDB/resource exit diagnostics remain.

T1's longer X5 pre-split playback moved observed low-Heat X4→X5 contact from
815ms/INVINCIBLE0 to1067ms/APPLIED10/Level4 under the same fixed0.85s protection.
The compared preludes endedP90/E150/H8; natural AI/input variation remains, so
final Health differences are not a controlled treatment effect. Two complete
T1 fights endedP77.5/E0/H21 andP70/E0/H13, with full right/left five-hit chains
observed. Native/Mali review found no obvious new blade/body separation in the
samples; smoothness/sluggishness and higher-Heat safety remain unverified.

Late isolated comparisons were actually played and left unmerged: U's X5 T2
0.45/1.10 cleared the sampled low-Heat interval but had less margin than T1 and
no established compensating feel win. After explicit human writer authorization,
Dum-E's X1 P1 0.28/0.44 retained total0.72s and ordinary chains, but an early
second press moved from native progress0.333/buffered to0.250/before-buffer.
Main retains X1 0.21/0.51; these experiments are not accepted defaults.

Final exact-product3200279f/default-JSON PrototypeArena replay completed
Player80/FinalEnemy0/Heat28/unexpected0 and visibly entered 'now you are free'.
Optional contact/camera remained off and camera offset0. No gameplay script
error; generic16ObjectDB/9resource exit diagnostics remain. The telemetry Enemy
Health field can still follow a practice target after final Enemy defeat; that
existing focus policy was not changed. Ordinary Dodge cancellation/resource,
post-launch ignored input and wall/overlap cases are bounded in the report,
not a blanket controller/immunity-matrix pass.

Limited regression completed Archer and Archangel encounters using their
existing policies/stats. Archangel body-debug frames expose a pre-existing
humanoid/capsule registration separation; no collider/art/AI correction or wider
roster clearance. Air/Earth five-X hits and real-orb Casts were exercised on a
normal training target, not an attacking-enemy or full tutorial-flow pass.
Natural practice reached Heat91, but Fire's five high-Heat actions missed the
short dummies; this is not high-Heat contact against a live Enemy.

Supplementary focused feedback fixture after R1:1,998checks/0failures. Separate dodge
fixture:512/513passes; its sole failing retired-control-count assertion remains
stale. Native X2 editor scrubs at0.2798/0.64/0.80 showed saved capsule/blade
agreement without edits. Old unused contact-API tests still parse-fail; no clean
whole-editor/full-suite claim. Audio was captured but not auditioned; no audio
change or comfort claim. Synthetic input is not physical-controller acceptance.

Apart from the stated X5 timing candidate, this record accepts no new AI policy,
artwork, other Fire timing, native geometry/lunge values, damage/Impact/Poise,
Heat/orb/input, Cast timing, defence or dodge changes. The
exact synchronized GDD still awaits user verification. Final controller feel,
camera comfort, rendered left-viewport clamp stress/high-Heat live-enemy coverage, wider creature
alignment, short-target/floor registration and inherited fixture/exit warnings
remain open. Earlier records below retain their original scope and evidence;
their old pending-merge wording is historical, not the current handoff.

## Castle/Necropolis roster and number-row cycles — October 23

Status: `AWAITING_USER_VALIDATION`. The user approved all fourteen Necropolis
bindings and seven Castle upgrades, plus plain1–7 faction-base cycling and
Shift+1–7 base/upgrade toggling within the selected faction. The three-step
cycle is superseded. This candidate is local to the Art worktree based on
42775d9e. The user subsequently authorized its local commit/merge into main and
selected Art's remastered presentation and controls over the overlapping original-
sprite/ranged-Lich draft. Preserve that superseded draft recoverably and leave
unrelated research/department work unchanged. No push or engine run is authorized.

- Added 21 inherited scenes and 23 native clips: fourteen Necropolis melee,
  seven Castle upgrade melee and two upgrade shooting. The shared catalog now
  supplies 28 IDs to both Portals/config validation. Pikeman remains the saved
  default; preference format, selection/save/retry and restart owners are unchanged.
- Necropolis uses the current grounded CombatEnemy/shared settings, including
  Liches and winged creatures. Castle upgrades inherit their base actor's behavior;
  Marksman retains Archer's arrow, Zealot retains Monk's bolt. No new ability,
  flight, stat, behavior tree, projectile or combat rule. The original seven
  Castle actors, their resources and combat tuning are unchanged.
- Bound 70 existing Necropolis atlases in place and copied 37 selected Castle
  upgrade atlases byte-for-byte. Seven provenance notes/manifests retain package
  paths, source-index/manifest/PNG hashes, block IDs, geometry and frame counts.
  Original drawings, complete collections and remaster validation are unchanged.
- The existing PrototypeArena shortcut table owns all seven four-ID tier maps.
  Plain presses alternate faction bases at that tier; entering from another
  tier starts at Castle base. Either variant identifies its faction. Shift
  preserves faction and toggles the requested pair; Shift+another tier selects
  that faction's upgrade. There is no persistent cycle cursor or new setting.
- Both paths use Spawn / Restart in Gym/Final Arena, not live-actor replacement.
  Echo/release, Alt/Ctrl/Meta, numpad, pause/Portal, transition and missing
  FinalEnemy safeguards remain; only Shift is newly permitted. D-pad selection,
  practice targets, completion identity and Shift's defence binding are unchanged.
  GDD, TDR and GYM/control guide record this final mapping and scope.

Checks: standalone gdtoolkit4.5 grammar parsing passed for both changed scripts
with caching disabled; this is not Godot type/import checking. Static inspection
matched all 28 catalog IDs/seven tier mappings, 21 new scenes, 23 clips,
151 external references, 107 atlas headers/SHA256 values and 790 selected source
positions. State frame counts, attack frame order/bounds, resource IDs, actor
inheritance, clocks/markers and nonvisual tracks matched their source data.
No missing references/mismatches; `git diff --check` passed. Source tracing
covered config validation, Portal options, selected ID, spawn, Gym retry metadata,
Final Arena restart and Save ownership. No game code, Godot import/editor/runtime,
build or automated tests were run.

User validation after local integration into main: stop/rerun Gym, alternate faction bases
with each plain number and toggle each faction's pair with Shift+that number.
Check Shift+another tier, a plain press from an upgrade, held/numpad/modified
keys and pause/open-unpaused-Portal safeguards. Confirm full reset, retry/save/
relaunch, both facings, feet, hurt/death and attack frames; check the existing
Marksman/Zealot ranged/close-melee paths and inherited projectiles. Repeat in
Final Arena while retaining practice targets/completion. Large/mounted/winged
bodies still use inherited collision, label/warning positions and temporary query
geometry; alignment remains unverified. Appearance masters and isolated asset
checks do not establish human motion, actor runtime, final art or original timing.

## Documentation update — attack feel reference, October 23

Added [Laema attack feel guidelines](ATTACK_FEEL_GUIDELINES.md) from the user's
supplied six-page transcript. Linked it from the GDD, attack-authoring guide and
document map, and recorded the adopted reference in Combat continuity. The guide
was reconciled with source `a41c900d`, including active-window contact, shared
motion/stun parameters, existing post-reaction AI wait and original Heroes III
SFX. This is documentation only: gameplay, assets and tuning remain unchanged.
No engine/editor runs or automated gameplay tests were made for this update.
Earlier test counts below belong to their stated source work; they do not
establish the new guideline's subjective feel goals.

## Native Player registration migration — October 22

Status: `AWAITING_USER_VALIDATION`. The user approved moving the existing Fire
and legacy alignment values into native Godot properties/animations, removing
runtime alignment overrides, preserving current hitbox tuning and integrating
locally into main. Push, export, Godot/editor/runtime and tests remain outside
this authorization. This slice follows local-main basis1debd6a5 and retains the
earlier isolated practice-target rest-pose correction ee686162.

- scenes/player/player.tscn now saves the actual Fire registration and a complete
  native RESET. Its existing main AnimationPlayer and AttackCast node/shape
  settings are retained. Sprite/CastOrigin is a visible Marker2D.
- All26 existing Player native clips (20X, four Cast, attack_clock and Fire
  Dodge) receive time0 registration properties only. Existing geometry, frame
  keys, markers, lengths and timings are preserved. The five current manual Fire
  files were saved without changing working-file bytes in local authoring
  checkpoint479d1a3c7c8ba786d464736c449b5d4f100ffc9e, then three-way merged.
- config/player_presentation/ contains the fixed Fire/legacy rectangles, the
  preserved outline shader and four saved legacy school materials. Fire remains
  offset(0,-124)/body30x90 at(0,-19); legacy remains offset0/body26x30 at(0,11).
  Both bottoms remain localY26/worldY52 at the unchanged root2/Sprite0.5 scales.
- A separate native PresentationPlayer applies saved setup/palette clips for
  code-driven Idle/Walk/Hurt/guard without changing Might's assigned animation,
  speed, sample clock or action callbacks. Code selects saved data, not offsets
  or constructed shapes. Legacy selected-school palette behaviour is retained.
- Player launch reads the native CastOrigin marker and retains facing. Its Fire
  right-facing offset remains(-19,-113)world; legacy remains(42,0). No projectile
  timing/size, input, damage, Heat, lunge or shared reaction tuning is changed.
- The confirmed practice-target flinch correction captures its scene-authored
  BodyVisual rest position rather than forcing zero; flinch distance/duration,
  audio and collision remain. Enemy authored registration, legitimate mirroring,
  body motion, native query sampling, level-dependent effects and logs remain.

Static evidence: standalone GDScript grammar parsing passes for player.gd using
the existing gdtoolkit4.5 dependency, not Godot's type/import checker; enemy.gd
also parses. After the guarded authoring merge, all26 original animation texts
are identical after removing only the appended setup tracks/resources and
load_steps bookkeeping: five match the user's actual working-file snapshots,
and21 match the preserved base. All52 original dirty-file SHA256 values remained
unchanged before final fast-forward; only the five Fire files were committed.
Resource-ID/reference review passes:34 native data documents,76 unique paths.
Protected Scene AttackCast, its circle shape and main AnimationPlayer blocks are
unchanged. Source arithmetic preserves floor/emission offsets; whitespace checks
pass. No editor preview, running gameplay, automated test or build pass is claimed.

User validation after integration: stop/rerun; scrub FireX2 at0.2798 and across
its active window, then FireX1–X5, legacy clips, Cast and Dodge. Compare sprite,
body and hitbox registration in-game in both facings. Check Idle/Walk/Hurt/guard,
mid-action school selection, interruption, retry and marker emission. Confirm
manual hitbox tuning survives. Remaining risk is unrun engine import/property
application and transition behaviour, not authorization to retune geometry.

## Player-X geometry / shared reaction reconciliation — October 22

Status: `AWAITING_USER_VALIDATION`; exact GDD wording remains
`AWAITING_GDD_VERIFICATION`. The user approved the exact 46-file plan.
Source basis: committed `1141f574eca95a147b7d3e30ddd3848276b865bf`, which
already contains the X-direction fix and tooltip companion, in the isolated
`codex/movestyle-shared-reactions` branch. Combat owns review and safe local-main
integration. Shared-main dirty tuning/import/art is not copied or edited here.
Local commit/handoff is authorized; push/export is not.

Current result:
- Player-X geometry comes only from its saved native Animation position,
  target and radius curves, including every later active pose. Scalar
  reach/radius, global fallback, native-key writeback and runtime size replacement
  are retired. Enemy/Pikeman size controls and their guarded save path remain.
- MoveStyle retains Animation/identity links, windup/recovery and attacker lunge
  distance/start/end, with existing tooltip meanings and Heat semantics.
  Its per-attack push scale and motion-time controls/fields/transport are removed,
  including the earlier Fire-X5 0.15s exception.
- Shared reaction Levels 1–5 own victim distance, positive motion duration and
  separate existing stun duration. Initial motion seconds are
  0.25/0.55/0.85/1.15/1.45. Existing distances 5/10/15/20/25, stun values,
  range starts, eligibility and clash rules are not retuned. Motion is uniform
  and capped at stun lifetime; shorter motion does not shorten hurt, control
  lock, invulnerability or the separate Enemy post-reaction wait.
- Legacy full JSON initializes missing motion time from its own level duration,
  not a Fire-X5 override. Config validation, retained-dictionary copies,
  three-way save merges and Portal enumeration remove only retired Player-X
  fields. Startup/reload stays read-only; no schema-wide rewrite or hidden
  per-move equivalent is added.

Exact changed-file inventory (18 scripts, 23 Resources, 5 documents):
- `scripts/combat/attack_style.gd`: timing/lunge capture and narrow retired-key cleanup.
- `scripts/combat/attack_geometry.gd`: native Player-X sampling/validation only;
  retain Enemy size/save behavior.
- `scripts/combat/might_component.gd`: remove scalar geometry preview and
  per-attack reaction payload; other action/contact/dodge logic unchanged.
- `scripts/config/move_style_tuning.gd`: retain seven exported identity,
  Animation, timing/lunge fields; remove four retired controls.
- `scripts/config/player_combat_settings.gd`: prevent retired move/global
  fields from being reapplied or saved.
- `scripts/config/developer_config_store.gd`: retire cached fields during
  existing merge/copy paths without removing unrelated leaves.
- `addons/laema_dev_portal/move_style_inspector.gd`: native-editor help, no size
  writeback claim.
- `scripts/config/combat_reaction_level_tuning.gd`: shared motion-time export
  and distinct stun/motion/distance tooltips.
- `scripts/config/character_reaction_settings.gd`: shared motion mapping.
- `scripts/config/combat_tuning_settings.gd`: mirror/Inspector/save mapping,
  retaining the established nonauthoritative mirror.
- `scripts/config/prototype_config_loader.gd`: retired-field and missing-motion
  migration, positive finite motion validation, unchanged save guards.
- `scripts/entities/health_event.gd`: remove attack-owned shove payload.
- `scripts/entities/health_resolver.gd`: retain strongest value/direction,
  remove per-attack shove transport.
- `scripts/entities/entity.gd`: value/direction reaction request only.
- `scripts/enemy/combat_enemy.gd`: shared-value capture through existing
  pending/tree dispatch; no alignment/AI/physics-consumer edit.
- `scripts/entities/hit_reaction.gd`: capture shared distance/motion/lifetime,
  retain collision-motion consumption and stun completion.
- `scripts/config/developer_settings_catalog.gd`: five style controls per move
  (100 total), four shared fields per level and distinct tooltips.
- `scripts/ui/developer_settings_fields.gd`: preserve the specific reaction
  field descriptions when dynamic ranges refresh.
- All twenty existing `config/attack_styles/{fire,water,air,earth}_x{1..5}.tres`:
  remove 58 serialized retired-property lines only; preserve every other value,
  UID and Animation link.
- `config/characters/player.tres`: remove only the two retired global shape keys.
- `config/characters/hit_reaction.tres` and `config/combat_tuning.tres`: add
  the five explicit shared motion times, preserving all existing properties.
- `docs/GAME_DESIGN.md`, `docs/TECH_ARCHITECTURE.md`,
  `docs/ATTACK_STYLES.md`, `docs/GYM.md` and this status: exact current
  ownership, editing instructions and evidence boundaries. Earlier X5 shove
  records below are historical and superseded, not a current control/API.

Checks actually run: read-only source/diff inspection, producer-to-consumer and
complete changed-function/caller inspection, Resource text comparison and
`git diff --check`. All 23 Resources match exactly the scoped line removals or
motion additions; all 35 tracked files under `config/attack_animations/` match
their base Git blob byte hashes. No native key/marker/frame, scene, art, body
profile, player.gd, movement owner, audio, input or test file is edited.
Retired production identifiers remain only as narrow migration keys, not
controls or reaction consumers. Existing IMPACT/TRACE instrumentation is retained.

Static distinguishing trace, not an executed gameplay scenario: a hypothetical
Level 2 with distance10, motion0.10 and stun0.55 captures 10px/0.10s movement
while keeping the full0.55s stun lifetime. Motion above0.55 is capped. A legacy
level with duration1.23 and no motion key obtains1.23; stale scalar geometry or
push fields cannot change native curves or reaction distance.

No Godot/editor/game, build, compiler or automated test was run, created or
modified. No standalone gdparse/gdlint/gdtoolkit checker is available, so grammar,
types, Resource import and runtime behavior remain unverified. Existing
attack_authoring, attack_style, clash_formula, dev_portal and gym_encounter
fixtures still contain retired-field/control-count assumptions; they require
separately authorized maintenance/execution. Old check totals and rendered
observations below do not validate this reconciliation. Inherited X5 UID-path
fallback warnings remain outside this cleanup.

Manual validation after Combat integration:
1. Restart Godot/Gym. Inspect Player styles and both Portals: only timing/lunge
   numerical style controls remain; shared levels expose starting value, stun,
   motion time and distance. Hover each to check units/meaning.
2. Scrub a Player-X clip with distinct early/later geometry; save native edits
   separately, restart and compare the active-window overlay in both facings.
   Portal timing/reaction saves must leave every Player-X native key unchanged.
3. In an unsaved live draft, shorten one shared level's motion time while
   retaining its distance/stun. Trigger that level on Player and Enemy: movement
   ends earlier but hurt/control lock/invulnerability finish at stun end. Check
   motion longer than stun is capped, walls consume blocked motion, subsequent
   tuning does not change an active capture, and lower-band X5 uses the same level.
   Retry/reload to restore saved tuning.
4. Save/reload deliberately chosen shared values and style timing/lunge, compare
   both Portals and Inspector, and verify no retired fields return. Review a
   retained legacy full profile separately if migration coverage is required.
   Recheck X direction/buffering, raised-hand Cast, dodge, ordinary/clash contact,
   practice recoil, pause and retry as unchanged regression boundaries.

Residual risk: Godot/import/runtime and user feel remain unverified; legacy
fixtures are stale. Main has overlapping user-owned Resource/Animation tuning
and separate authored-alignment work: Combat must preserve unrelated fields,
UIDs and all native keys, never force/stash/reset or replace whole dirty files.
This isolated patch supplies no main-merge, remote-publication or Ultron clearance
receipt.

## X input direction capture — October 22

Status: `AWAITING_USER_VALIDATION`; exact GDD wording remains
`AWAITING_GDD_VERIFICATION`. Approved five-file follow-up based on committed
main `7e9dff463efb61473133a2c313a93a46b744fb71`, prepared in the isolated
`codex/combat-feedback-fixes` checkout. Shared-main tuning/imports are not copied
or edited; Combat owns review and eventual local integration. No push/export.

- `scripts/player/movement_controller.gd`: the previously unused attack sampler
  now reads existing mapped horizontal input/deadzones without changing facing;
  held input returns its normalized direction, neutral returns facing. A separate
  explicit commit applies captured horizontal facing only at actual X start.
- `scripts/player/player.gd`: only X requests use that pure sampler. The existing
  light-action start event commits facing; Cast and other input retain their
  previous route. An accepted queued/buffered X cannot turn the current swing.
- `docs/GAME_DESIGN.md` and `docs/TECH_ARCHITECTURE.md`: synchronize stick-first X,
  neutral fallback, existing immutable buffer intention and actual-start commit.
  This status is the fifth approved file. No Might/CombatController, input-map,
  timing/window, tuning, asset, Cast or dodge implementation edits are included.

Source trace: pure X sample -> existing Combat/Might acceptance -> stored
buffer/pending direction -> actual attack_started -> facing commit. Presentation,
hitbox mirroring, contact direction and lunge continue reading that same action
direction. Rejected input has no sampler-side facing event; first-wins and buffer
promotion remain unchanged. Neutral after a new X retains its committed facing
rather than an older Movement direction.

Checks: source/data-flow and complete changed-function inspection plus
`git diff --check`. No Godot, editor, game, build or automated test is run or
created for this slice. A standalone GDScript checker was not available in the
current Python/PATH; this is not a grammar/type or runtime pass. Earlier dodge/
shared/combat observations below do not validate this new direction change.

Tooltip-only companion: `scripts/config/move_style_tuning.gd` now documents all
11 exported Inspector fields, including units, timing phases and zero behavior.
Source comparison with documentation comments removed confirms unchanged
declarations/logic/defaults; whitespace check passes. Inspector hover display
has not been run. The user authorized committing this companion together with
the five-file X fix for Combat's local-main integration, with no push.

Manual validation on the review source: face right and press left+X, then check
the reverse case; hold opposite direction during a swing without X and verify
it does not turn. Queue/buffer opposite-direction X: the old action stays locked,
the new action turns only at its own start, and releasing/changing the stick
after capture cannot retarget it. Check neutral follow-up, rejected early/full-
queue X, both-facing visual/hitbox/lunge agreement, and unchanged Cast/dodge.

## Local main review handoff — October 22

The user requested immediate integration for review. Local `main` was
fast-forwarded to the reconciled combat candidate `d51235af`, retaining the
completed creature/art/shortcut changes. The X5-only preservation commit is
`5bcd0c7b`; all 30 other uncommitted tuning files passed a before/after SHA-256
comparison and remain uncommitted. No push or live export was performed.

Rules and implementation scope were approved; human play/feel validation remains
pending. The final candidate passed 513 focused dodge checks and 87 shared-combat
checks. Combat's rendered X5 and both-facing Fireball evidence is from
`cfa537d`, not the later dodge revision. No rendered replay of the final dodge
build is claimed. The existing legacy test failures and UID fallback warnings
are not cleared by this merge. The sections below retain the detailed source
and evidence boundaries.

## One-time Fire dodge end-overlap extension — October 22

Status: implemented approved rule/technical/file/test scope,
`AWAITING_USER_VALIDATION` for the resulting candidate.
Exact GDD wording remains `AWAITING_GDD_VERIFICATION`; design approval does not
mean the user has played this version. Source basis: `cfa537d` on
`codex/combat-feedback-fixes`; main's dirty files remain outside this slice.

Clear rolls retain0.4s. At the real final body-step boundary, overlap with an
already exception-owned combat Enemy grants one0.1s of captured movement,
invulnerability and action suppression. The native final pose is held; the
clip is not stretched/replayed. Actual completion alone restores collision,
rearms input and begins the existing0.37s cooldown. Remaining overlap at0.5s
restores normally, even if that permits correction. No repeat/indefinite
extension or new0.5s gameplay cooldown is approved.

Exact product scope: `scripts/combat/might_component.gd`,
`scripts/player/movement_controller.gd`, `scripts/player/player.gd`.
Exact test scope: only the two fixed160->161 count assertions in
`tools/tests/attack_style_test.gd`, plus new
`tools/tests/fire_dodge_overlap_test.gd` and its `.gd.uid`.
Exact documentation scope: GDD, TDR, this status and Gym. No authored assets, attack
timing, damage/Health/Heat, AI, non-Fire or shared-main edits. Existing X5 shove
and raised-hand Fireball implementation remain unchanged.

The brief acceptance of immediate overlap correction in the cfa537d record
below is historical and superseded by this selected exception. Only isolated
headless checks run here; Combat owns rendered observation and local merge.
Before main reconciliation: isolated Godot4.7.1 import and focused suite passed
513 assertions, process/runner exit0; shared-combat suite passed87, exit0.
These are controlled real-physics fixtures with a post-contact observer and a
zero-delta presentation-selector call, not rendered/controller/feel proof.
They cover both facings, clear24-tick/120-unit and overlap30-tick/150-unit rolls,
high-Heat clear rolls, final-body-step selection, actual resolver protection,
ignored actions, final native pose/completion handoff, full post-end cooldown,
wall/remaining-wide-overlap bound, pause/resume, reset/stage cancellation and
preservation of preexisting exceptions. The initial8 endpoint assertions exposed
normal stop resetting to cell0; normal completion now preserves visual state.
The two earlier failed focused runs remain distinct from the passing rerun.
The test then gained a frame-rate-derived boundary selector; final source is
rechecked after committed-main reconciliation below.

Only the approved two legacy attack-style assertions were updated160->161.
Its 205 failure/error entries match clean fd72 exactly; unrelated removed-clock/
contact/art assumptions are not repaired or presented as a green suite. The new
test UID comes from the isolated Godot import, not an editor run in the branch.
No human/controller/feel validation of this extension is claimed.

Committed-main reconciliation: authored patch `89610a01` was normally merged
with committed main `5bcd0c7b` as `7028a5f`. This preserves the accepted HD
Archer/Griffin art, levels4–7, seven-creature shortcuts and X5 UID/precision
serialization. The two canonical-document insertion conflicts retain both
accepted scopes; other incoming creature/art/shortcut records are unchanged.
Main's unsaved work was not copied, stashed, reset or staged. Relative to its
preserved X5 Resource, the only additional line is `push_motion_duration=0.15`.

Fresh isolated checks against reconciled `7028a5f`: focused513 and shared87,
both runner/process exit0 with zero assertion failures or script errors.
The legacy style suite still exits1 with exactly the same205 diagnostic entries
as clean fd72; its two approved count assertions now pass. These results remain
separate from Combat's earlier cfa537d rendered observations.

Reconciliation warning, left outside approved authored scope: committed
`config/characters/player.tres:18` and `config/combat_tuning.tres:21` still refer
to X5 UID `7aaccg6wkqwp`, while the preserved Resource UID is `poa2y4kef1av`.
Godot reports invalid-UID warnings and successfully falls back to the existing
text path. Focused/shared runs contain13/20 such runtime warnings respectively;
this is not warning-free validation. No reference-file fix or UID rollback is
hidden in this slice. Rendered/human/controller/feel checks remain with Combat
and the user; source review and a safe local-main fast-forward remain pending.

## Fire X5 shove and raised-hand Fireball candidate — October 22

Status: `AWAITING_USER_VALIDATION`; exact GDD synchronization awaits user
verification. Isolated source basis: `fd72f4e2a83960abb862da09ae98fb210c5c8410`
on `codex/combat-feedback-fixes`. This bounded follow-up does not reopen or
overwrite the closed daytime run, main's dirty tuning/art, or Art's worktree.

- Existing style/configuration path: `scripts/combat/attack_style.gd`,
  `scripts/config/move_style_tuning.gd`, `scripts/config/player_combat_settings.gd`,
  `scripts/config/prototype_config_loader.gd`,
  `scripts/config/developer_settings_catalog.gd` and `config/attack_styles/fire_x5.tres` carry
  Fire X5's captured `push_motion_duration=0.15`. Zero/omitted values retain
  full-reaction motion; other moves validate as zero and expose no new control.
- Existing reaction path: `scripts/combat/might_component.gd`,
  `scripts/entities/health_event.gd`, `scripts/entities/health_resolver.gd`,
  `scripts/entities/entity.gd`, `scripts/enemy/combat_enemy.gd` and
  `scripts/entities/hit_reaction.gd`
  forward that value through contact, strongest-reaction batching and captured
  Enemy execution. All qualifying X5 bands retain their distance/eligibility
  but deliver motion in 0.15s capped at lifetime. Full hurt, control lock,
  invincibility and AI recovery remain unchanged. Other attacks keep old motion.
- `scripts/player/player.gd` maps Fire's source hand pixel (205,235) through the actual Sprite
  transform and committed-facing reflection. Both drawing and collider now
  originate there. Non-Fire origin, launch marker, travel/range, damage, drawing
  scale and audio are unchanged. The user accepted short-dummy misses without
  modifying targets. No dodge source, collision policy or timing changes.
  The brief acceptance of immediate physical correction after dodge was later
  superseded by the one-time-extension rule above. The earlier fd72 footage is
  not validation of either follow-up or a blanket controller/art pass.
- `docs/GAME_DESIGN.md`, `docs/TECH_ARCHITECTURE.md`, `docs/ATTACK_STYLES.md`,
  `docs/GYM.md` and this `docs/IMPLEMENTATION_STATUS.md` record the exact scope.

Checks: scoped source/diff, whitespace and producer-to-consumer inspection;
isolated Godot 4.7.1 headless imports; existing shared-combat suite 87 checks;
existing full Fire geometry/input suites X1=1741, X2=1236, X3=1337, X4=1185,
X5=1536 (7035 total). Each suite reached zero assertion failures and a process
exit 0, with X1 requiring a fresh rerun. These controlled fixtures are not
rendered/controller/feel or explicit lower-band-shove/hand-anchor acceptance.

Validation is not blanket green: the first X1 run printed its 1741 pass then
exited 0xC0000005 during native shutdown; clean baseline and fresh candidate X1
reruns exited 0. Cause remains unclassified. The geometry runs retain ObjectDB /
resource-at-exit diagnostics (X1 rerun 26/16, X2–X5 each 14/10), and import emitted
Unicode warnings. The legacy clash suite has the same 15 failure/error entries
as clean fd72; legacy Portal also fails on its removed Geometry.contact API in
both trees. Legacy attack-style has 205 baseline failure/error entries plus two
candidate fixed-160-field assertions: the approved single X5 control makes 161.
Its other failures include removed Might._physics_process and old contact/frame
assumptions. No test or runner is created/modified, and these failures are not
repaired incidentally. The first clash wrapper also hit Windows console encoding
while printing; comparison uses the retained engine logs.

Combat owns rendered Windows observation and review before local merge. No
main merge, push, export or human-feel acceptance is claimed. Preserve main's
overlapping `fire_x5.tres` changes when integrating only the new field. Faster
displacement can change follow-up contact/spacing; it does not guarantee a
subsequent Cast hit. Human/controller/feel acceptance remains pending.

Later Combat-reported agent-rendered evidence applies **only to cfa537d**:
clean isolated Godot4.7.1 Windows Gym, ordinary bound inputs, no forced actor/AI/
resource/clock writes, unexpected inputs0. Both left and right FireLv1 shots
were observed at raised-hand height. One earlier right-facing attempt was
legitimately rejected during hurt, not an origin failure. A normal five-X chain
landed all five hits (Player100, Enemy200->150); X5's ordinary Level4 reaction
retained distance40/duration1.15 while motion finished early and HIT_REACTING
continued. A separate natural active-opponent attempt produced difference20,
Level2, distance20/duration0.55, likewise separating fast motion from retained
reaction. Its simultaneous incoming hit correctly reduced Player100->90 and
removed charged orbs without cancelling X5. These observations support those
two reaction cases, not every configurable band, the new dodge candidate,
reconciled-main runtime, human controller/feel or a fresh headless result.

## Castle levels 4–7 prototype — October 22

Status: `AWAITING_USER_VALIDATION`. The user approved existing high-resolution
assets, current grounded melee for Swordsman/Cavalier/Angel, Archer-style ranged
and close melee for Monk, one shared Dev Portal selector and one subagent per
creature. The user authorized the scoped creature and top-row1–7 shortcut
commit and merge into local `main`. This slice originates on
`codex/castle-creatures-4-7` over `5fe2886f`; ongoing combat tuning remains
outside the commit. Remote publication was not requested.

| Creature | Character atlases | Selected frame positions | Prototype |
| --- | ---: | ---: | --- |
| Swordsman | 5 | 35 | Current grounded melee |
| Monk | 6 | 49 | Current ranged/close melee |
| Cavalier | 5 | 38 | Current grounded melee |
| Angel | 5 | 35 | Current grounded melee |

The four scenes reuse shared Settings/tree/collider/reactions. Their own native
Animation resources retain 1.0s clocks and existing marker/temporary-geometry
contracts while mapping each selected source sequence's frame count. The one
catalog now supplies all seven choices to both Portals and the existing
Spawn / Restart path. The saved default/preference format is unchanged.

The shared ranged actor has an exported projectile PackedScene with the same
Archer default. Monk binds a separate bolt scene using the existing projectile
script and original CPRZEAX horizontal source frame. Its character animations
are high-resolution; the source collection has no detached high-resolution
projectile. All four new creatures have unassigned SFX and null inherited
Pikeman streams.

Validation covers selected source bytes, 21 character atlases/157 frame cells,
resource paths, frame bounds, animation data, shared-script grammar and source
data flow. These are static checks; no Godot/editor/runtime, build or automated
gameplay tests were run. Animation/art/balance and human/controller acceptance
remain pending. Temporary sword/lance/melee geometry, mounted walk/collision
and Angel's airborne drawings under grounded physics require a user review.

Your validation: stop/rerun Gym, select each new creature in General / Creature
to spawn, use Spawn / Restart, and check both facings, feet, attack presentation,
damage/reactions, death, retry/save and Final Arena completion. For Monk also
check range-to-melee choice, muzzle/bolt, wall collision, defence, interruption
before/after launch and projectile cleanup.

## Creature number-row shortcuts — October 22

Historical initial slice: the October23 candidate above supersedes this fixed
seven-base mapping; its earlier evidence does not validate the expanded roster.

Status: `AWAITING_USER_VALIDATION`. The user approved top-row **1 = Pikeman**,
**2 = Archer**, **3 = Griffin**, followed by **4 = Swordsman**, **5 = Monk**,
**6 = Cavalier**, **7 = Angel**, through the existing Spawn / Restart flow, and
removal of the former 1–4 keyboard school-selection defaults. Controller D-pad
school selection is unchanged. No new creatures, assets, AI or tuning are added.

- `scripts/prototype/prototype_arena.gd` owns the physical-key mapping and
  `_unhandled_key_input` handler. Fresh, unmodified presses use the same creature
  request/restart path as the Portal. Key releases, echoes/holding, numpad keys,
  open pause/Portal UI, missing areas/transitions and training areas without
  `FinalEnemy` do not trigger the shortcut.
- Input setup removes the retired school-key bindings even when retained in
  InputMap from an earlier arena. It preserves controller bindings and the
  existing school-selection implementation. Key4 now selects Swordsman.
- Existing Gym reload/Final Arena restart restores fighters, authored initial
  school, Health, positions, empty orbs, zero Heat, reactions and buffered
  actions. Selection remains run-only until Save Tuning; no mid-attack actor
  replacement or automatic save is introduced. Existing unsaved-tuning reload
  behavior is unchanged.
- GDD, TDR and Gym control records are synchronized for this exact change.
  Concurrent high-resolution creature presentation and user tuning are preserved.

Checks: focused source/data-flow and seven-choice catalog/scene-reference
inspection, standalone GDScript grammar parsing and `git diff --check` pass.
Standalone parsing establishes no Godot type/import or runtime validation. No
Godot/editor/runtime, build or automated tests were run for this slice. The user
authorized committing these shortcuts with levels4–7 and merging into local
main; remote publication was not requested.

User validation: stop/rerun Gym, press each top-row key1–7 and verify the chosen
opponent and full encounter reset. Hold a key and verify no repeat restart.
Check key4 now spawns Swordsman, D-pad still selects schools, and numeric
entry in the open Portal (including unpaused Portal) does not restart play.
Repeat the shortcuts in Final Arena; practice targets/completion identity must
remain intact. Engine input dispatch and restart behavior remain unverified.

## High-resolution creature presentation correction — October 22

Status: `AWAITING_USER_VALIDATION`. After the user identified the original
low-resolution flipbooks in Gym, the existing selected high-resolution animation
collection was located in Art's saved outputs. The user authorized its scoped
commit and merge into local `main` on October 22. The correction originates on
`codex/castle-creature-hires`, based on roster merge `fd72f4e2`; other ongoing
tuning and keyboard-shortcut edits remain outside this commit. No push or new
runtime-validation evidence is authorized by the local merge request.

- Archer binds six existing generated character sheets: Idle/Walk/Hurt/Death,
  close melee and shooting. Griffin binds five: Idle/Walk/Hurt/Death/Attack.
  All 11 copied atlases retain their selected source bytes; 79 source frame
  positions were compared with the collection's individual PNGs.
- Both use four-column 768 x 640 cells, sprite scale 1, offset (0, -128) and
  anchor (384, 448) at the inherited BodyVisual position. Sprite-frame rectangles
  in the three attack resources use that layout.
- Timing, marker/key times, AttackCast geometry, collision bodies, AI, shared
  settings, selector/restart behavior and sound assignments are preserved.
  Archer's detached arrow remains its original source sprite. Native character
  PNGs are preserved at their earlier paths; the new sheets and compact source
  hashes live under each creature's `highres_v01/` folder.
- The static masters were accepted in Art; their generated animation collection
  is explicitly a prototype review candidate. This binding change grants no
  final animation, art, engine-import, gameplay or balance approval.

Checks are source/resource/frame-bound comparisons only; no Godot, editor,
runtime, build or automated gameplay tests were run. User validation remains:
stop/rerun Gym, select each creature and inspect motion, both facings, feet,
close melee/shot presentation, weapon/hitbox and muzzle alignment.

## Selectable Castle creatures — October 22

Status: `AWAITING_USER_VALIDATION`. The user authorized a scoped creature commit
and merge into local `main` on October 22. This slice originates on
`codex/castle-creature-roster`, based on `dda30976`; unrelated existing Fire/player
tuning remains outside its commit. Push and live publication were not requested.
The merge grants no new gameplay-validation or submission-clearance evidence.

- One shared catalog/Portal preference selects Pikeman, Archer or Griffin.
  Runtime General and editor General / UI & debug expose **Creature to spawn**
  plus **Spawn / Restart**. Legacy configuration defaults to Pikeman; Save Tuning
  remembers the preference through the existing config save flow.
- PrototypeArena replaces the preplaced FinalEnemy before entering the tree,
  preserving its name, transform, encounter ID and final/refill roles. Gym retry
  carries the unsaved selection while retaining the disk value as Save's merge
  base. Final Arena's practice targets and objective identity are preserved.
- Griffin inherits CombatEnemy/shared Settings and existing grounded melee,
  timing, collider, reactions, damage and Impact. Five byte-identical original
  sheets and four decoded original-source SFX cues are copied under
  `assets/prototype/enemy/griffin/`; its provenance records hashes, frame mapping
  and foot registration. The new native melee clip retains the existing
  active0.5..1.0s clock and AttackCast geometry.
- CombatEnemy presentation exports preserve Pikeman defaults and support native
  layouts/mirrored offsets. Animation cloning follows the source resource path,
  preserving creature-specific aliases. Native creature geometry is protected
  from Pikeman size overrides/saves. Root cleanup also removes enemy arrows.
- The independent Archer task supplied its ranged/melee subclass, native clips,
  projectile and provenance through the same catalog. It captures attack type
  and facing at commitment: shared attack_range selects close melee; the
  existing awareness range permits shooting. Its six-frame melee and eight-frame
  shooting clips use the provisional1.0s baseline; one arrow launches at0.5s.
  The root-owned arrow uses a Player/level ray sweep and existing direct
  HealthEvent resolution, with first-contact consumption and no melee-clash
  participation. Seven source PNGs are byte-identical to the original
  collections. Archer SFX remain unassigned, with inherited null-stream playback
  skipped. The Archer chat completed grammar/reference/frame-bound/source-byte
  checks; those establish no engine or gameplay validation.

Checks: grammar parsing of twelve changed/new scripts, JSON inspection, asset hashes and native
resource/reference review. These are static checks, not Godot type/import/editor
or runtime validation. No build, automated test or game run was requested or run.
User validation remains: select each creature, spawn/retry/save/relaunch, verify
both facings and feet, fight through attacks/reactions/death, and check Final
Arena completion. Griffin's inherited melee geometry is temporary and may need
later creature-specific visual tuning; this change grants no final art or balance
acceptance.

## Daytime candidate — October 22, C7 timing over retained C4 source

Status: `AWAITING_USER_VALIDATION`. The captured prepublication baseline was
HEAD921fd1ae plus dirty work, not a tested commit identity. First retained C2
source/report/evidence publication is **05fb22b819e95919da74bcd7c0b57587b5e6f95b**,
verified by Main at **12:03:26 HKT October22**: push exit0 and independent remote
main/local HEAD equality. See the [publication receipt](iterations/2026-10-22-fire-combat-daytime/PUBLICATION.md).
That first lunch receipt is historical; later candidate publication state belongs
to Main's receipts/source identities. Repository publication is source publication,
not Web export, whole-tree/submission, art, numerical or human-feel clearance.
Main's isolated Godot4.7.1 rendered bound-input
runs, source snapshots and captures are recorded in the
[daytime ledger](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md); the
[iteration report](iterations/2026-10-22-fire-combat-daytime/REPORT.md) is Main-owned.
Source review/agent play is not user controller, numerical, art or comfort acceptance.

| Current daytime unit | Bounded source change | SHA-256 prefix |
| --- | --- | --- |
| `scripts/player/player.gd` | C2: retain native dodge ownership and final pose for the completion physics frame, then actual-motion locomotion; new action/school/hurt/stage/reset precedence retained | `9b705e0d` |
| `scripts/combat/spell_projectile.gd` | Fire child drawing1.5x baseline, retaining level ratio; Lv1 36x27/Lv3 72x54, collider/origin/flight/lifetime unchanged | `cc1101fc` |
| `config/attack_styles/fire_x4.tres` | Windup0.33/recovery0.36, base0.69s; only recovery changed from0.51 | `90f963de` |
| `config/attack_styles/fire_x5.tres` | C7: windup0.30/recovery1.10, base1.40s; only windup changed from D0.45 | `651d9978` |
| `scripts/ui/objective_widget.gd` | Retained C4 row-label wrapping/bounded width; tokens/evaluator/font/strings/flinch unchanged | `e91201b5` |
| `config/prototype_combat.json` | Saved SFX volume_db0->-6 only; original clips/pitches/ducking and Ambient/BGM preserved | `ddab1126` |
| `tools/tests/overnight_fire_playtest.gd` | Optional Master WAV capture0..30s, default off; bounded2s ring/2048-frame drain, actual-rate stereo PCM16, loss/timing/cleanup metrics | `63409fd5` |

At the October22 daytime closure X5 was C7 as above; the later October24 T1
candidate is recorded at the top of this file. D0.45/1.10 (base1.55s,57aef5ab) remains historical
comparison evidence. Enemy attack_range72/A9682BE0 was restored after the
[rejected range96 trial](iterations/2026-10-22-fire-combat-daytime/ITERATION6_REVIEW.md).
The other retained overnight repairs/evidence below are preserved. Daytime source changes add no new art, AI
spacing policy, physical dodge safe-end rule, Cast-origin relocation or visual afterlife.

- **X4 comparison:** baseline and C1 pure uncharged0.65s-cadence chains accepted
  and landed all five X, ending P100/E150/queue5. X5 started3.543s versus3.697s
  (about0.154s earlier). Native normalized windows are unchanged, but shorter
  phase duration also shortens their wall time; Enemy-relative timing is not fixed.
- **C2 dodge:** C1's stationary-wall Dodge->Walk->Idle flash was rejected. Fresh
  C2 shows final Dodge pose->Idle with no false Walk in inspected wall frames.
  Three repeated wall dodges each lasted24 physics ticks/0.4s; the following X
  was accepted at2.521s during cooldown. The continued encounter won P60. Main
  additionally reports13 requested pressure-trial dodges,10 executions and three
  player_hit interruptions, ending P70/E200; this is not all-case invulnerability
  or controller/feel clearance. The later C2 connection list was empty, unlike C1.
- **Cast/audio:** selected in-flight Lv1/Lv3 drawings are larger, but ranges were
  not matched; hip-level origin and zero-flight point-blank disappearance remain.
  Main recorded exact12s/48000Hz/stereo PCM16 WAVs,576000 frames, with no discarded,
  invalid or unwritten frames. Encoder-observed over-full-scale samples fell
  3500->2 and recorded RMS -12.7066->-18.3606dBFS at SFX-6. This is mix/headroom
  evidence, not hardware clipping, SFX isolation or audition/comfort acceptance.
  The true early-quit probe saved48128 frames/1.00267s with a valid uninterrupted
  header/prefix and duration_complete=false; it is not a completed30s capture.

Open: full120-unit baseline dodge travel can be followed by about28.14 units of
collision-restoration recovery when ending inside Enemy; C2 presentation does not
fix it. Human safe-end and AI-spacing decisions remain pending. Charging/hurt
failures and other prior waivers remain; small unseeded fight results establish
no survival superiority. The prepublication synchronization used static checks only, no new
Godot/tests/audition/export, and no commit/push or blanket source/authority clearance.

### C7 timing evidence — October 22 afternoon, provisional human review

Main's fresh normal-input Right openings both landed all five X, P100/E137:
D/C7 X5 starts3.523/3.531s, contacts4.000/3.877s, empowered Lv5 launches5.350/5.201s,
both APPLIED13. Both continuous encounters finished70HP; these small unseeded
results are not causal survival improvement. A separate C7 Retry/Circle-cross/
left-reface opening landed all five, launched empowered Lv5 at4.916/APPLIED13,
then took a real10-damage hit; that same continued encounter also won70HP.
Overlay-hidden Right and visible Left captures were inspected without forced state.

C7 advances preparation into the existing thrust; it does not add art/strength or
prove that X4->X5 detachment is aesthetically solved. Faster pre-split playback
advances lunge/contact and real input-window timing without changing normalized
rules, geometry or numerical lunge/push. Recovery stays1.10, but earlier completion
does not guarantee Cast safety. Retention is provisional for human review only.

Main's explicitly waited controlled X5 rerun exited0:1545 checks, zero assertion
failures, retained14 ObjectDB/10 resource shutdown warnings. Forced Heat/seeks are
supplementary, not primary play, a full C7 suite or live high-Heat protection.
Rendered processes closed normally with the usual13/9 warnings. See the
[daytime ledger](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md); Main owns
the [Iteration7 review](iterations/2026-10-22-fire-combat-daytime/ITERATION7_REVIEW.md)
and source identity. No controller, human aesthetics, audition,
whole-tree/submission or new gameplay-policy acceptance is established.

Main's final changed-window trial PID41128/session41128_645991: X5 start3.541s/Circle3.661s pre-active; Dodge ended4.056s/24 physics ticks.
Four hits left P100/E160/queue4; charged4->0/chain reset, with held full pressure not restarting Charging.
Neutral release/repress rearmed without failed Cast; Left all-five hits plus empowered FireLv8 launched4.915/impacted4.966/APPLIED13.
A later real hit left P90/E97/Heat11; the SAME fight then won P50/E0/Heat1/queue6/ext0, without Retry/heal/forced states.
Main inspected before/during/post-Dodge and target FireLv8/13 frames in the [archived evidence](iterations/2026-10-22-fire-combat-daytime/c7-x5-dodge-01/).
Normal quit5 explicitly exited0; this session retained25 ObjectDB/15 resources-in-use warnings, NOT13/9; no cause or leak fix is inferred.
Source C7651/Enemy72 stayed unchanged. This finite agent observation grants no whole-Dodge/controller/human acceptance; status AWAITING_USER_VALIDATION.

### Final current-C7 regressions — October 22,17:09 HKT

After all rendered games closed, Main ran the five existing full headless suites
sequentially on frozen C7, explicitly WaitForExit for each and loop exit0:

| Suite | Checks | Assertion failures | Exit | ObjectDB / resource warnings |
| --- | --- | --- | --- | --- |
| Fire X1 | 1741 | 0 | 0 | 14 / 10 |
| Fire X2 | 1236 | 0 | 0 | 26 / 16 |
| Fire X3 | 1337 | 0 | 0 | 24 / 15 |
| Fire X4 | 1185 | 0 | 0 | 14 / 10 |
| Fire X5 | 1545 | 0 | 0 | 14 / 10 |

**Total7044, zero assertion failures**; not the historical C2 total7116 or
overnight7212. The initial15:48 X5-only selection result above retains its scope.
The [final manifest](iterations/2026-10-22-fire-combat-daytime/FINAL_REGRESSION_MANIFEST.json)
and [suite records](iterations/2026-10-22-fire-combat-daytime/final-regressions-c7/)
retain exact reports. Main's FAILED/SCRIPTERROR/ParseError/InvalidCall scans found
no hits; shutdown warnings remain and no cause or cleanup is established.
Existing fixtures were mechanically copied to an isolated alias without script
edits. Forced Heat/preparation/seeks/collectors are supplementary, not primary
play, tutorial reachability, NPC safety, controller or human acceptance. The
OPEN Fire-dummy finding and unanswered human choices remain; no repair was
accepted. Status AWAITING_USER_VALIDATION; this document update ran no tests/runtime.

### C7 genuine-Heat and Lv8 observations — October 22 afternoon

Product source remains unchanged C7; Main verified source publication1404d0ab
and receipt632efc44 (see [C7 publication](iterations/2026-10-22-fire-combat-daytime/C7_PUBLICATION.md)).
These later Main-run observations add evidence, not new tests or source changes:

- Stage7 dummy practice PID70896/session70896_641622 closed exit0 after48 normal
  Lv1 Casts across three batches, Heat4->36->68->100/P100/no failed Casts. Known
  external counter7 stayed stable during commands. At100/150% speed,0.43s cadence
  accepted all five X positions/full35 lunge; onlyX3 hit. A subsequent charged
  chain committed empowered Lv2 at2.522s, launched3.118/impacted3.141/APPLIED13,
  queue2->0/Heat100; ordinary post-Cast Left movement returned30 units. This is
  not all-five-hit/objective completion or high-Heat NPC invulnerability clearance.
- Separate Gym PID24872/session24872_1016458 earned queue10 from14 ordinary melee
  contacts, P80/E60/Heat0, with three actual overflow events. Normal retreat while
  Charging selected8; Right-reface/release4.5 committed FireLv8, launched4.792/
  impacted5.054/APPLIED10, P80/E50/Heat16/queue1. Main inspected8/8-ring, projectile
  and target FireLv8 images. The SAME fight later won P60/E0/Heat16/queue1/ext0,
  without mid-fight Retry/heal/forces; normal quit5 exited0 with13 ObjectDB/9
  resource warnings. No survival-superiority, controller, audio-scale audition or
  human acceptance follows from this bounded maximum-charge case.

**OPEN compatibility:** the [tutorial target finding](iterations/2026-10-22-fire-combat-daytime/TUTORIAL_TARGET_FINDING.md)
records a source-grounded21.61px vertical gap between grounded Fire X1's full
active sweep and the legacy dummy. The inferred default Fire-only Stage1/7 route
is unreachable at ordinary horizontal spacing, not every school/tutorial route
or the tall NPC, and not a C7 regression. Separate visible-art/matching-collision
repair authorization is unanswered; no target, sword query or objective rule was changed.

Details remain in the [daytime ledger](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md);
Main owns the new high-Heat/Lv8 reports and evidence. Status stays
AWAITING_USER_VALIDATION. No human feel, all-case NPC safety, eight-note listening
or new design/mechanism is accepted by this static document synchronization.

### Final daytime evidence addendum — October 22, prepublication

Main completed all five C2 controlled headless suites, explicitly waiting for
each process: **7,116 checks, zero assertion failures, all five exits0**. These
forced-preparation regressions are supplementary, not primary rendered play or
human acceptance. Retained shutdown warnings are ObjectDB/resource counts:

| Suite | Checks | Shutdown warnings |
| --- | --- | --- |
| Fire X1 | 1741 | 14 / 10 |
| Fire X2 | 1236 | 14 / 10 |
| Fire X3 | 1337 | 24 / 15 |
| Fire X4 | 1185 | 22 / 14 |
| Fire X5 | 1617 | 22 / 14 |

C3 tested only X5 recovery0.85 instead of D1.10. Fresh matched first-five/full
Charging/release-at4.5s rendered trials both landed all five X, P100, charged5
and empowered Lv5. C3 launched5.116s and contacted INVINCIBLE0; D launched5.350s
and contacted APPLIED13. Main observed the earlier projectile arriving during
X5 reaction invulnerability, rejected C3 and restored exact D57aef5ab. No rule
workaround was added; the four-document candidate representation remains C2.

The [daytime report](iterations/2026-10-22-fire-combat-daytime/REPORT.md) records
the comparison; [lunch source identity](iterations/2026-10-22-fire-combat-daytime/LUNCH_SOURCE_IDENTITY.json)
records Main's11:44 check of692 root/runtime paths with zero mismatches after
rollback. The prior [bounded implementation review](iterations/2026-10-22-fire-combat-daytime/IMPLEMENTATION_REVIEW.md)
applies to restored C2 only, not whole-tree/submission or human feel acceptance.
This addendum records existing evidence; it ran no new tests/runtime and makes
no commit/push or publication-success claim. Status remains AWAITING_USER_VALIDATION.

### Afternoon C4 objective-fit candidate — October 22

`scripts/ui/objective_widget.gd` E91201B5 adds only WORD_SMART wrapping and row
Label custom_maximum_size (max(1, widget width minus actual StyleBox horizontal margins),
-1). Current width330 gives326px content; height is unbounded and the panel grows
down. Width is sampled at row rebuild, not generic dynamic resizing. Strings,
fonts/colors, token HBoxes/order, evaluator/progress, prompt and flinch are untouched.
This is an addition to the retained lunch C2 source, not new acceptance; publication state is recorded in the Main-owned receipt.

Main's isolated Godot4.7.1 PID49476/session49476_718694 rendered observations:

- Stage7's whole long sentence fits at1280x720 below80 and at naturally earned100
  Heat. Forty-eight normal Lv1 Casts had zero failures; this is not Stage7's
  all-five-hit completion. With developer overlay/hitboxes actually off, ordinary
  idle changed the first Heat row green->white below80; P100/E190 stayed unchanged.
- Normal Portal Stage2 entry and ten uncharged five-X attempts earned five FIFO
  orbs. Full Charging then standalone exact FireLv5 committed/launched, turned
  the widget green and displayed `moving on ->`. Ordinary right movement entered
  Stage3; its label and compact token row fit in the inspected frame.
- Stage2->3 also emitted stderr about set_lifecycle changing monitoring/monitorable
  through a physics body_entered path. Visible Stage3 activation is not an error-free
  transition pass. Separate read-only diagnosis owns that issue; no repair is
  claimed here. Full-motion flinch, generic resizing and all token rows remain
  outside the observed fit coverage.

See [daytime progress](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md).
Main owns report/evidence and subsequent disposition/publication. This document
update ran no runtime/tests and changes no gameplay. Human acceptance remains
pending; status AWAITING_USER_VALIDATION. Earlier lunch publication/hashes remain
their historical snapshot, not evidence that C4 is already published.

### Retained-C4 encounter review — October 22, through14:01 HKT

Main's [post-C5 play review](iterations/2026-10-22-fire-combat-daytime/POST_C5_PLAY_REVIEW.md)
records one isolated Godot4.7.1 Gym encounter, PID77216/session77216_597317,
on unchanged retained-C4 source (b57d1b3f;26fa5890 adds evidence only). Normal bound
inputs reached victory37.5/0 without Retry, healing or actor/resource/AI/clock writes:

- Front block dealt actual2.5 chip. One parry dealt zero and gave Enemy Level1
  reaction0.25s/about5 push, with Enemy Health200/Heat0/orbs0. Enemy refaced after
  its committed attack/recovery when Laema dodged across. Real wall contact
  resolved INVINCIBLE0; the same still-active attack caused no later damage in
  that observed once-per-target case, not an all-contact-time clearance.
- Late X4 Circle was correctly ignored. Early X5 Circle reset the chain and
  cleared charged4/partial progress while retaining queue4; held full pressure
  did not auto-restart Charging. Prelaunch Cast cancellation consumed queue4->3
  only, with no double spend/projectile and commitment Heat2 retained. Postlaunch
  Circle did not execute; a later real hit interrupted the Cast, so uninterrupted
  completion was not established by that case.
- Ordinary refacing returned to a left-facing all-five-hit X chain and empowered
  Lv7/APPLIED13, followed by victory in the same encounter. This is bounded agent
  evidence, not a causal difficulty comparison or a new implementation round.

Product source hashes are unchanged; no new automated-test result, audition or
human pass is claimed. No controller was connected. Status remains AWAITING_USER_VALIDATION;
all-case/controller clearance, AI retreat, physical dodge safe-end, fresh art
direction and the unrelated tutorial-transition errors remain unsettled/unfixed.

## Retained overnight candidate — October 22, rendered evidence through 07:19 HKT

Historical source/evidence snapshot: the daytime entry above supersedes its
Player identity and adds the bounded daytime candidates without erasing this record.

Status: `AWAITING_USER_VALIDATION`; final supplementary regression execution is
complete, with the scope/limits below. These
are provisional agent-tested implementation/tuning/presentation candidates, not
user-verified design acceptance, final numerical/art direction or submission
clearance. Root HEAD921fd1ae plus dirty work is not a tested-tree identity; use
the isolated run records and per-file identities in the
[overnight ledger](iterations/2026-10-21-fire-combat-overnight/PROGRESS.md).
Only the five deltas below and directly stale current-state text are synchronized
here; unrelated dirty work and all accepted waivers remain unchanged.

[Final source identity](iterations/2026-10-21-fire-combat-overnight/FINAL_SOURCE_IDENTITY.json)
reports root/tested-runtime agreement across690 baseline non-document paths and
only the five retained product deltas versus the frozen post-dodge baseline.
This is not a clean-Git, all-scenes-tested or human-accepted identity claim.

| Retained delta / source | Overnight readback | SHA-256 prefix |
| --- | --- | --- |
| `config/attack_styles/fire_x5.tres` | D: windup0.45/recovery1.10, base1.55s; native timing/geometry, lunge and locked values unchanged | `57aef5ab` |
| `scripts/combat/might_component.gd` | Common _start_action reasserts movement_lock_changed(true); actual X/Cast reacquires lock after a preserved gap; gap unlocks unchanged | `f43a49a3` |
| `scripts/combat/magic_component.gd` | Normal initialized RELEASE stops Charging/depleting updater flags before arbitration; retained resources/startup/dodge rearm unchanged | `8d18216e` |
| `scripts/ui/prototype_hud.gd` | Faint ten empty-slot rings plus immediate orb-slot detachment before queue_free; occupied drawing, authored layout and overflow flinch unchanged | `1914f762` |
| `scripts/player/player.gd` | Existing empowered square: half-size6 local, facingX8/Y-66,0.45s; original event/school color/z4/audio unchanged | `bd68f162` |

**Timing comparison:** with the same repaired Might, current-source A0.95 cohort
won80/70/90HP, with6 APPLIED13 and1 INVINCIBLE0 among7 valid high-level Cast
contacts. D won80/90/80HP, with7/7 APPLIED13. First release-to-launch was about
0.960s versus0.831s: D adds about0.13s waiting. The small unseeded cohorts do not
establish causal survival/difficulty superiority or human latency preference.
Natural press-during-hurt/no_marked_orbs failures occurred in both cohorts; D does
not repair that seam or guarantee high-Heat Enemy protection clearance. A remains
a restorable comparison; B/C were reverted. Earlier-source results are not
relabeled as current-source D evidence.

**Motion/Heat evidence:** earlier same-Might A practice, entered through normal
Stage7 UI, earned Heat4->36->68->100 over48 normal Fire Lv1 Casts, with Player100
and stable position around275. No resources/positions/AI/clocks were injected.
The authored short target refilled itself. Only X3 connected at the selected
spacing; this is not all-five-hit Stage7 completion or high-Heat Pikeman protection.
At genuinely earned100, normal0.43s X input accepted all five positions/full35
lunge. A preserved gap allowed about30 movement; a normal Lv2 Cast from that gap
reacquired lock, opposite movement during Cast moved0, and fresh post-Cast movement
returned about30. Held/fresh dodge produced two24-tick0.4s executions without repeat.
These observations support the technical lock repair; they do not transfer all
high-Heat coverage to the later D timing or establish physical analog priority.

**Fresh-D practice addendum (PROGRESS07:38):** exact retained D/Mightf43 in
`final-d-practice-01/session58100_1058658` completed48 normal Fire Lv1 Casts over
three120s ordinary-input batches, Heat4->36->68->100, no failed Cast, Player100,
stable X around275 and unchanged known UI counter5; maximum edge lateness18/17/19ms.
At naturally earned100, no-Charging0.43s cadence accepted X1–X5/full35 lunge
(max13ms); a preserved gap moved30, normal Lv2 Cast from the gap locked movement
against held opposite input, and normal post-Cast movement returned30 (max16ms).
Two fresh24-tick/0.4s dodges showed no held-repeat and ignored X. Only X3 hits the
legacy short target: this is neither Stage7 completion nor high-Heat Enemy
protection, physical analog or incoming-Pikeman validation. Exit0 retained13
ObjectDB/9 resource warnings. Archived `final-d-practice-01/` evidence supports
fresh D rather than borrowed A coverage; earlier07:19 cohort labels stay historical
and no human/submission clearance follows.

**Current-D encounter checks:** held front block produced two2.5-chip hits and
control returned to movement/X and a completed same encounter. Dodge cancelled
windup before active_start, ignored an active-frame request, cleared charged
coverage/progress while retaining the generated orb, and required normal release
before a new hold. A prelaunch normal Lv1 commitment consumed1 once, was discarded
by dodge with no refund/projectile, and retained its existing Heat accounting.
Postlaunch recovery ignored Circle while the actual Cast remained playing. A real
wall contact during active dodge resolved INVINCIBLE0 while Player position/Health
stayed unchanged; the same encounter later finished through normal pressure.
The earlier late wall attempt was hit before dodge and is not an iframe pass.
Current-source R1 tap attempts produced no PARRIED result; parry remains uncleared.

**Final rendered addendum:** current-D cmd24 won80HP with two empowered Lv7 Casts
and one no_marked_orbs failure after opening hurt; known native Portal setup
counter2 stayed stable. Cmd26 after normal Retry won80HP left-facing with two
empowered Lv5/one normal Lv4 and no failed Cast. The run-only hitbox-Off choice
from cmd24 did not survive Retry, so cmd26 is not a second debug-hidden pass.
The rendered process closed normally07:19 HKT, exit0 with existing13 ObjectDB/
9 resources-in-use warnings. No blanket input/audio/human-feel clearance is inferred.

**Later current-source parry addendum:** unchanged retained D/helper1547 in
`final-d-parry-01/session30520_767456`, after ordinary Retry, demonstrated one
pause-assisted normal R1 tap from an observed windup triangle/spear preparation:
engine PARRIED/health_delta0 with Player100 unchanged; actual full frames
cmd_5_frame_000026/000027/000029 show PARRY->PARRIED->READY. This supports one
current-source input path, not human reaction/controller usability or blanket
clearance; the earlier five missed taps and prior-cutoff uncleared statements
remain historical evidence. The same encounter continued through normal X/
Charging/Casts to Player70/Enemy0 in cmd6, max22ms/zero external inputs, retaining
one no_marked_orbs failure. Startup idle defeat before command1 is excluded from
active-play/difficulty claims; ordinary Retry2 restored the authored100/200 start.
Evidence archive: `final-d-parry-01/`; closure/archive was pending at this handoff,
so no new warning-free exit or acceptance claim is made.

**Presentation checks:** actual1280x720 both-facing cue2 images support on-Player
placement clear of the intervening weapon/Enemy; the first96bd placement is
superseded, not a final art choice. Fresh HUD1914 ordinary-generation runs retained
500px native width through overflow instead of old740, and showed ten stored/eight
charged, eight-orb consumption, leftovers and empty rings. The transient20-child
minimum-size explanation is source-derived, not a live child-count probe. Normal
inputs and visible frames are agent evidence, not human-controller/feel acceptance.

**Final supplementary regressions:** after rendered closure, Main ran the five
existing full suites sequentially on retained D/Mightf43. These include forced
initial positions, Heat, animation seeks and input-path branches with controlled
preparation. They are not earlier fixtures-only counts, primary rendered play,
human controller evidence or AI/feel/parry/high-Heat protection acceptance.

| Existing full suite / report | Checks | Assertion failures | Exit |
| --- | ---: | ---: | ---: |
| [Fire X1](iterations/2026-10-21-fire-combat-overnight/final-regressions/fire_x1/report.json) | 1741 | 0 | 0 |
| [Fire X2](iterations/2026-10-21-fire-combat-overnight/final-regressions/fire_x2/report.json) | 1236 | 0 | 0 |
| [Fire X3](iterations/2026-10-21-fire-combat-overnight/final-regressions/fire_x3/report.json) | 1337 | 0 | 0 |
| [Fire X4](iterations/2026-10-21-fire-combat-overnight/final-regressions/fire_x4/report.json) | 1281 | 0 | 0 |
| [Fire X5](iterations/2026-10-21-fire-combat-overnight/final-regressions/fire_x5/report.json) | 1617 | 0 | 0 |
| Total | 7212 | 0 | all0 |

Reports/stdout/stderr are retained under final-regressions/. Shutdown warnings
persist there with varying counts; exit0/zero assertions is not warning-free
teardown or blanket runtime clearance. Execution is complete, not human acceptance.

**Open boundaries / morning findings:**

- Physical analog-stick/controller priority, audio audition and
  human latency/feel/presentation acceptance remain pending. Some normal-input
  checks were pause-assisted; no human reaction-performance claim follows.
- A new full Charging press during hurt is semantically classified before the
  eligibility gate, may not start the updater, and is not retried by an unchanged
  hold; later release can fail no_marked_orbs. Incoming-hit removal does not itself
  stop already-running Charging or establish a new rearm policy. No rule was changed.
- Cast levels5–8 intentionally retain missing-override fallback Impact1. Against
  non-active Enemy Poise10, applied damage can produce no reaction; fixed Level4
  protection remains1.15s. Neither Impact nor protection was retuned.
- Legacy target/body versus tall Fire blade compatibility remains spacing-specific;
  X3 can hit at closer spacing. No target resize/query widening was implemented.
- Player Health remains developer telemetry when F4 is hidden. The accepted recent
  event-confirmation lane remains an implementation gap: its existing widget only
  receives completed chains. No new Health UI/event formatter/history was added.
- Cast-level text can overlap Pikeman's face/weapon. The shared-offset-254 proposal
  overlapped the HP row and was cancelled before editing; FeedbackComponent remains
  `834925ff`. Shared anchor/other actor-size handling remains a morning proposal.
- Some exits report21 ObjectDB/13 resources versus the pre-existing13/9, including
  a completed-job Arena quit217s after its last capture. No encoder was in flight
  there; identities/cause remain unknown. Do not call shutdown clean or claim that
  completed-job quit universally prevents the warning. No teardown cleanup occurred.

Evidence source: PROGRESS.md through the07:20 rendered addendum and07:24 final
controlled-regression entry, plus the named isolated sessions/reports. The elapsed
overnight window is not claimed as continuous active gameplay time.
The normal-input recorder remains support-only (`1547b225`), with timestamps,
state observations and bounded private-image encoding; telemetry never schedules
actions. Heavy-capture late/coalesced trials are not precision-input/iframe passes.
This documentation update ran read-only source/hash/diff/link checks only, not
Godot, builds, tests or new playtests. No commit/push/publication or blanket
canonical/source/submission clearance is claimed.

## Fire dodge first-slice integration — October 21

Status: `AWAITING_USER_VALIDATION`. The human approved the complete Fire-only
contract in Combat, then verified the exact GDD synchronization and approved U's
bounded implementation plan. The previous missing-Combat-approval blocker is
superseded. The recurring wait was deleted when the implementation gate was
presented; the chat remains open. No duplicate design or artwork approval was
requested.

Might now owns Circle fresh-press dodge, locked direction, its fixed0.4-second
native clock and0.37-second post-completion cooldown. Movement alone applies
0.4 seconds of captured normal movement speed, including from idle; wall-blocked
motion is consumed. Temporary two-way enemy-body exceptions preserve contact
query layers and restore only this dodge's owned exceptions. Player's existing
Fire body/feet profile and Sprite.flip_h are retained. Entity/HealthResolver
include active dodge in both ordinary-hit and pre-clash invincibility rejection;
the existing spent-contact rule remains.

Pre-active Fire X and pre-launch Cast can be cancelled; active/recovery X and
post-launch Cast reject Circle without queuing. Starting dodge resets the combo,
clears pending/buffered actions through interruption outcomes, and clears charged
coverage/partial progress without removing queue entries or resetting front
lifetime. Already committed Cast orbs are neither refunded nor spent again.
Source trace, not runtime evidence: with8 stored/5 charged, commitment leaves3;
dodging before launch discards that commitment and leaves those3 stored orbs.
All gameplay action input/pressure dispatch is suppressed during dodge; a held
Charging input must release before a later press can charge. That rearm release
does not trigger a stale/empty Cast. A previously held successful-parry latch is
reconciled on exit without replaying ignored defence presses. Pause uses the
existing scene lifetime; stage lock/death/reset restore collision/input state.

Exact integration files and outcomes:

- `scripts/combat/might_component.gd`: action/cancellation/cooldown, native clock
  and existing body-motion provider; observational dodge start/end outcomes.
- `scripts/combat/combat_controller.gd`: input/pressure gates, lifecycle forwarding
  and release rearm; remains a thin facade.
- `scripts/combat/magic_component.gd`: non-consuming Charging interruption/rearm.
- `scripts/player/movement_controller.gd`: stick-first/facing fallback, normal
  speed capture and owned enemy-body exception cleanup.
- `scripts/player/player.gd`: input context, art/facing/lifecycle forwarding and
  Player-specific invincibility extension.
- `scripts/entities/entity.gd` and `scripts/entities/health_resolver.gd`: shared
  invincibility query and its ordinary/pre-clash consumers.
- `scripts/prototype/prototype_arena.gd`: Circle binding only; no keyboard mapping
  or change to existing L2/right-mouse Charging, R1 defence or menu controls.
- `scenes/player/player.tscn` and new `config/attack_animations/fire_dodge.tres`:
  private-library registration and12 discrete grid cells over0.4 seconds, with no
  attack geometry, launch, damage or Heat scaling. Only the original idle-exit
  atlas is used; normal locomotion resumes through the existing path.
- `assets/prototype/player/fire_sword_shield_v01/dodge_v01/asset-manifest.json`
  and `PROVENANCE.md`: current binding/authority/evidence, with all4 PNGs unchanged.
- `docs/GAME_DESIGN.md`, `docs/TECH_ARCHITECTURE.md` and this status: approved
  rules, selected ownership and candidate/validation boundaries respectively.

Initial integration checks: source/diff/caller inspection; whitespace checks; manifest
JSON parsing and4 PNG SHA-256 comparisons;12 native grid-cell bounds,0.4-second
length and Player-library binding inspection; all referenced scene/clip resource
paths exist. Fourteen protected-file hashes match the pre-integration tree,
including current Fire X1–X5/Cast clips, Player settings, Enemy/projectile/defence/
HitReaction/contact-evaluator source, ATTACK_STYLES and project.godot. `gdlint`
was not found on PATH; no parser/linter was run by that initial integration. It
ran no Godot/editor/import/compiler/build/tests/runtime and created no tests or
publication. Main's later scoped rendered dodge observations are recorded in the
October22 entry above; other geometry tests below do not validate this dodge.

User validation: open `scenes/gym.tscn` and run F6. Select Fire, press Circle from
idle and while moving in both directions; neutral stick uses facing, opposite
stick during dodge cannot turn it, and travel lasts0.4 seconds. Hold/repress Circle
during dodge/cooldown: no repeat or queue; a fresh press after the0.37-second
cooldown works. Dodge through the Enemy and against walls: pass bodies, remain on
the floor, stop at walls while the animation/protection continues, and restore
ordinary collision afterward. Confirm no damage/reaction during dodge and normal
damage afterward. Check X before/after active_start, Cast before/after launch,
stored-orb/Charging preservation/rearm, ignored school/X/defence inputs, pause,
Retry/stage reset and another-school rejection. Inspect normal idle/run return.
Risks: physical-controller timing, body exceptions near/inside an Enemy at exit,
grid/ground-contact continuity and interruption/reset behavior remain unverified.
Artwork detail/center-of-mass limits from the approved source package remain.

## Fire X1–X5 blade alignment — October 21

Status: bounded implementation/combined review passed; `AWAITING_USER_VALIDATION`.
Only the five native Animation position/target key blocks changed. Current art,
Sprite keys, UIDs, length/markers, radius3.5, body/floor, AI and all combat
settings are preserved. Source origin(224,348) is distinct from feet(224,400).

| Move / detailed evidence | Active holds | Implementer headless / rendered | Supervisor final-tree |
| --- | ---: | ---: | ---: |
| [X1](iterations/2026-10-21-fire-hitbox-polish/x1-candidate/README.md) | 7 | 1741 / 1592 | 1741 |
| [X2](iterations/2026-10-21-fire-hitbox-polish/x2-candidate/README.md) | 4 | 1236 / 1093 | 1236 |
| [X3](iterations/2026-10-21-fire-hitbox-polish/x3-candidate/README.md) | 5 | 1337 / 1369 | 1337 |
| [X4](iterations/2026-10-21-fire-hitbox-polish/x4-candidate/README.md) | 4 (3 cells) | 1281 / 1136 | 1281 |
| [X5](iterations/2026-10-21-fire-hitbox-polish/x5-candidate/README.md) | 4 | 1341 / 1192 | 1341 |

Listed positive runs exit0 with no failed assertions/reported engine errors.
Independent source-pixel truth, negative pristine fixtures,2688 real point probes,
both facings/Heat0/100, held/boundary samples, late/rejected/spent/cancelled
contacts and40 ordinary input scenarios are retained. The detailed evidence
distinguishes manual fixtures from ordinary input and implementer from supervisor.
An early isolated fixture shutdown failure is recorded, not counted as clean.

Supervisor-run final-tree checks additionally pass shared combat87, AI baseline14,
rendered input pressure44, and a300-frame native Gym smoke run without a testscript
(three Enemy contacts at10damage). Pressure suppresses attacks under existing
reaction/wait rules; after stopping, all tested cases resume three attack cycles.
High-Heat reaction invincibility may consume a contact for0damage; no gameplay
workaround was introduced. No persistent AI deadlock was demonstrated.

[Final files, hashes, evidence and human validation](iterations/2026-10-21-fire-hitbox-polish/IMPLEMENTATION-REPORT.md).
The narrow TDD Fire paragraph was synchronized by Combat. Product/helper are
frozen; no commit, push, export or publication. Human feel/transition acceptance
and submission clearance remain open.

## Pikeman approach/attack diagnosis — October 21

Status: `PRESSURE_SUPPRESSION_REPRODUCED`; `NO_PERSISTENT_DEADLOCK` in the
tested cases on saved source `921fd1ae`, using an isolated Godot
4.7.1 project/profile. No AI, range, timing, collision, geometry or tuning change
was justified or made. The actual Gym completes at least three autonomous
approach/windup/active/recovery/wait cycles with a passive Player on either side;
each case applies three saved 10-damage contacts (100 to 70 HP). Real scene Retry,
ordinary input-driven Player approach, and autonomous recovery after an injected
HealthEvent interrupts a natural windup are also covered. The interruption is a
controlled fixture, not evidence of an input-driven Player attack.

Repeated ordinary Fire X/XXXXX inputs on both sides reproduce interruption-driven
suppression, not a demonstrated AI scheduling fault. X1's value0 gives the
existing player-zero-advantage Level1 reaction; natural committed windups can be
cancelled before they hit. All pressure cases resume at least three full attacks
and waits after inputs stop. No armour, AI, timing or range workaround was added.

Rendered Compatibility/OpenGL captures show native thrust/return poses and
pressure/interruption in both directions. Focused checks pass 14 baseline
headless, 31 baseline rendered, 50 repeated-X/five-X, 22 standalone-X1 and 20
natural-windup X1 assertions, each with exit0 and no reported errors.
This is bounded agent-run evidence, not user acceptance,
active-editor reproduction or overall gameplay clearance. Retained report,
logs and captures: [Pikeman AI phase](iterations/2026-10-21-fire-hitbox-polish/pikeman-ai/README.md).
Combat reviewed the first phase and authorized a separate X2-only geometry
iteration; other Fire geometry remains outside that iteration.

## Parried Enemy Level 1 reaction — October 21

Status: `AWAITING_USER_VALIDATION`. The user approved adding the existing Level1
reaction to the attacking Enemy after a successful Fire parry, with no
counterdamage or resource reward. This supersedes the initial defence slice's
absence of an attacker reaction.

CombatEnemy now consumes the existing outgoing Fire PARRIED HealthResult,
cancels its attack and requests combat reaction value0, directed away from
Laema. The shared Level1 profile supplies its captured duration/distance
(currently0.25s/5px); no tuning values are changed or duplicated in the handler.
The ordinary LimboAI reaction task, body movement, reaction invincibility and
post-reaction wait are retained. Defeated, already invincible or pending-reaction
Enemies are left to those existing guards. BLOCKED, misses and unrelated results
do not request a parry reaction. No new HealthEvent or health/resource mutation
is introduced; Player defence rules and the current art bindings are unchanged.

The approved five-file scope is CombatEnemy plus GDD, technical record, Gym
guide and this status. Evidence is source/caller/settings inspection and scoped
whitespace checks, not Godot/parser/runtime or automated-test validation. No
tests were added or run. User checks: successful front parry in both facings
interrupts and pushes the Enemy away with unchanged Enemy HP; block/miss gives
no parry reaction; ordinary follow-up attacks, AI recovery and Retry still work.
No commit, push or live publication occurred.

## Fire Shield Catch parry-only spark mapping — October 21

Status: `AWAITING_USER_VALIDATION`. The user approved this seven-file slice and
its record synchronization after specifying held guard, no spark on misses and
spark only on successful parry. It supersedes the initial binding below for
spark routing, visual cadence and active texture path.

Player now preloads the byte-identical accepted atlas from
`assets/prototype/player/fire_sword_shield_v01/shield_catch/shield-catch-8x448.png`.
Its SHA-256 is `59a118996c31e83633291876951e5b6601d793f0dee33ed829e2842feda60333`.
At the existing10fps sprite cadence, frames1–4 raise/hold, successful Fire PARRIED
results alone start5–8, and miss/release uses6–8 without the baked spark. Ordinary
blocks keep guard. Frame numbers here are one-based. Movement after control return,
attacks/Casts and Hurt can interrupt cosmetic recovery; the existing reset,
school-change and stage-lock paths clear it. No new gameplay lock or timer is added.

Runtime code changes are confined to Player presentation, reusing the existing
read-only controller snapshot. The selected PNG/provenance, assets README, GDD,
technical record and this status are the approved seven-file scope. The concurrent
initial defence_v03 integration remains preserved as earlier candidate history.
Current defence rules/settings and latest native attack bindings, including
overnight_v04, are preserved; the existing Fire body/facing/registration is reused.

Evidence is source/caller inspection and image checks: exact source-copy hash,
RGBA3584×448/eight448px cells, alpha bounds and matching opening/closing pixels.
Scoped whitespace checks pass. Hash comparison preserves all30,650 pre-existing
files outside this slice after the concurrent writer finished, including all46
attack Animation/style resources and the current defence controller/settings.
No Godot parser/compiler/import/editor/runtime, build or automated tests ran;
none were created. Source alpha extends3–4px below the nominal foot anchor;
accepted pixels/registration are unchanged. User checks remain for both facings,
held block, tap miss, successful parry, immediate movement/attack, Hurt, school
switches, Retry and existing attack/Cast transitions. No commit/push/publication.

## Fire Shield Catch artwork binding — October 21

Historical initial binding: its block-contact spark, captured-window playback
and active texture path are superseded by the user-approved mapping above.

Status: `AWAITING_USER_VALIDATION`. The user's request to put the accepted art
into the new defend feature is implemented. The refined eight-frame transparent
atlas is copied byte-for-byte to
`assets/prototype/player/fire_sword_shield_v01/defence_v03/shield_catch.png`.
SHA-256: `59a118996c31e83633291876951e5b6601d793f0dee33ed829e2842feda60333`.

Player presentation uses frames0..3 for raise/held guard, frame4's spark only
on actual Fire PARRIED/BLOCKED results, and frames5..7 for release/recovery.
Success feedback yields immediately to actions; held block returns to guard.
The read-only controller snapshot exposes captured timing/state; it adds no
mechanical change. Visual contact/release uses one captured early-window
interval; tap-miss recovery maps the existing remaining control commitment.
The Art GIF's review pauses are not used and shield reuse adds no visual lock.
Hurt/attack takes priority. New attempts, school changes, stage lock/death and
retry clear stale presentation. Existing Fire registration/facing is reused.

Changed runtime scope: scripts/player/player.gd presentation, one read-only
getter in scripts/combat/defence_controller.gd, and the copied PNG/provenance.
No defence absorption/timing/reward/rearm/input/hitbox rule, native attack clip,
move setting, scene, AI, Water or other-school presentation changes are included.
Source metadata/readme, GDD, technical record and asset records are synchronized.

Evidence: source/caller inspection, PNG RGBA/dimensions/bounds, exact source-copy
hash, exact first/last-frame pixels, controller comparison with only the getter
removed, and scoped whitespace checks. No Godot parser/compiler/import/editor,
runtime, build or automated tests were run and no tests were added. User checks:
tap miss, hold/release, front parry, partial block, rear hit, immediate attack
after success, school switch, hit interruption, death/retry and both facings.
Fine generated sword/shield/hair/garment continuity remains provisional. No
commit, push or live publication occurred.

## Fire overnight X1/X4/X5 artwork integration — October 21

Status: `AWAITING_USER_VALIDATION`. The user requested implementation after the
readiness review. X1 R05, X4 R02 and X5 R04 now have transparent registered
derivatives in `assets/prototype/player/fire_sword_shield_v01/overnight_v04/`.
Built-in imagegen produced cutouts; technical crops, fixed sequence scales and
translations assembled 448px cells at anchor(224,400). Generated details can
differ from the opaque masters; this is not pixel-identical alpha extraction.

Only three native texture paths and X4 image-region values change. All frame-key
times, Animation UIDs, markers, geometry tracks and move settings remain. X1 uses
eight poses. X4 maps six keys to chamber/chamber/chamber/thrust/recoil/recoil.
X5 uses R04 poses1/2/3/4/6/7/9; poses5/8 remain reference only. R05's isolated
recovery study and rejected R06 are not adopted. X2/X3 are untouched and retain
their unapproved-alternative/unresolved status. Prior PNGs and Idle/Walk/Hurt/Cast
remain. No attack direction, hitbox, timing, gameplay code or AI edit is included.

Review commit: `3894773c003265878be3b9c99c2e6137a0540574`; source artwork commit:
`f277903b0f7f9995f9dc715a273427999af01111`. Prompts/lineage, alpha masters,
registration, phase mapping and light/dark composites are in
`art/preparation/2026-10-21-fire-v01/`; the runtime manifest records sheet hashes.

Evidence is source/image inspection: transparency, atlas bounds, measured anchors,
retained native clocks/markers/geometry and protected-file comparisons. No Godot
import/editor/runtime, builds or tests were run. Check both facings, baseline/high
Heat, chains, feet, returns to Idle/Walk/Hurt/Cast, interruptions and retry.
Material/weapon transitions, held X4 anticipation, X5 recovery and existing pose/
query mismatches remain provisional. Concurrent defence work is preserved, not
validated here. No commit, push or publication occurred.

## Fire R1 defence prototype — October 21

Status: AWAITING_USER_VALIDATION. The user approved implementation first, then
synchronization of the named records and Ultron tech-postflight review.

Fire now uses R1/Shift press-parry/hold-block: early parry 0.20s; quick-release
parry endpoint 0.37s from press; control commitment 0.50s from press; missed-tap
reuse penalty 0.60s from expiry; held front absorption 75%. Values are captured
on press, tunable in Player Settings/Dev Portal, validated and saved through the
existing character Resource path. Older full JSON profiles receive missing
values in memory; supplied longer early windows are respected when deriving
missing endpoint/commitment defaults.

Successful parry prevents the hit and unlocks immediately, with release/repress
required. Fire partial block applies chip damage as a defended event without
normal-hit resource/status/Endurance delivery or legacy blocked-hit flinch.
Rear direct hits and DoT bypass Fire. Eligible melee windup can be cancelled
before active_start; buffered/queued Cast commitments are protected. Five-position
X/Cast rules, optional sixth Cast endpoint, Charging, projectile logic, native
animations and attack-style settings are unchanged by this implementation.

The initial mechanics slice used existing defence text, guard audio and damage
feedback. The later Shield Catch presentation binding is recorded above. No scene
change, dodge, counterdamage, attacker stun, reflection or Enemy/AI edits were
included in that initial slice. The later approved Level1 attacker reaction is
recorded above. Water retains its guard/Heat behavior with R1 as shared defence.
Retry/stage lock clears Fire state; an incoming hit preserves an already-running
reuse penalty. Movement-lock composition prevents defence timers unlocking a
new attack or stage lock.

Changed implementation scope: prototype_arena.gd input registration;
combat/defence_controller.gd, combat_controller.gd and might_component.gd;
entities/health_event.gd and health_resolver.gd; player/player.gd;
config/characters/player.tres; config/prototype_config_loader.gd and
config/developer_settings_catalog.gd. GDD, technical record and Gym instructions
are synchronized to this candidate. Existing unrelated working-tree changes are
preserved, including Fire style tuning, Player scene and Art exploration.

Validation: current source/value-flow inspection and scoped git diff --check.
No Godot parser/compiler, build, automated tests, editor/runtime, controller or
playtest validation was run; no tests were created/changed. User comparison and
verification of this updated specification remain pending. These limits are
carried into Ultron's bounded implementation review, not submission clearance.

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
