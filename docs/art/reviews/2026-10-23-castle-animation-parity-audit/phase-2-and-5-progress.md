# Castle Phase 2 specification work and Phase 5 playback repair

**Later Phase 5 work:** [The complete 225-group remaster asset set](../../remasters/castle-v01/README.md)
supersedes the missing-artwork blocker described in this earlier receipt. The user
authorized source-guided generation; original timing and human acceptance remain open.

**Date:** 23 October 2026, Hong Kong time. **Source baseline:**
`a41c900de771cea55e3c1819f1c77ff16d8101b5`, with the uncommitted audit alongside
this follow-up. The user requested the remaining Phase 2 work followed by Phase 5.

**Phase 2 remains partial:** original Castle timing rows and original-executable
playback evidence were not recovered. Primary-source research clarifies the
missing fields and separates reimplementation behavior from original evidence.
**Phase 5 has a bounded live repair:** Pikeman's front-thrust recovery samples
the correct existing high-resolution cells. Full 225-group parity remains
blocked; no missing original pose or timing value was fabricated.

The [original audit](README.md), [CSV](inventory.csv) and [evidence](evidence.json)
retain the pre-repair snapshot. This follow-up and
[phase-2-and-5-status.json](phase-2-and-5-status.json) record subsequent findings
and validation; they do not retroactively promote the original audit to parity.

## Phase 2: what the additional research establishes

The local source still establishes all 225 group identities, ordered frame
references, original margins and exact within-creature aliases. Those source
checks passed in the original audit. Numeric durations, original event triggers,
loop policies and a semantic foot pivot are not encoded in those DEF exports.

The [VCMI legacy-table reader](https://github.com/vcmi/vcmi/blob/develop/lib/CCreatureHandler.cpp)
identifies fidget, walk and ranged/special rate parameters, missile offsets and
angles, and a projectile climax frame. The fourteen original Castle rows are
imported separately; the [Castle definitions](https://github.com/vcmi/vcmi/blob/develop/config/creatures/castle.json)
do not recover their values. The reverse-engineered
[H3API structures](https://github.com/RoseKavalier/H3Plugins/blob/master/H3API/lib/h3api/H3Structures/H3Structures.hpp)
confirm legacy animation fields and three speed-delay slots, without those
fourteen numeric rows.

The current [VCMI animation controller](https://github.com/vcmi/vcmi/blob/develop/client/battle/CreatureAnimation.cpp)
uses a speed-controlled base rate. Walk and ranged/special parameters divide
their respective frame rates; melee does not use the attack parameter as a
whole-clip duration. Consequently the carried Pikeman table value of 1.00 does
not independently establish one-second original melee playback. Its source
comments also acknowledge uncertainty in the original speed ratios. These are
reimplementation facts, not original-executable certification.

The [VCMI action orchestration](https://github.com/vcmi/vcmi/blob/develop/client/battle/BattleAnimationClasses.cpp)
also shows why a constant FPS is insufficient: shots may hold at their climax
while a projectile travels; turn phases surround a facing change; optional
movement start/end groups play only when present. A terminal death pose can be
held. These conditional transitions need original-version/settings evidence
before they can be adopted as original HoMM3 behavior. No new Laema trigger or
ability was inferred from them.

Idle looping is particularly uncertain: the
[H3Plugins description](https://github.com/RoseKavalier/H3Plugins#description)
describes standing-frame cycling as an added original-game plugin feature.
Current VCMI idle behavior therefore cannot establish stock-original looping.
Groups 9/10 remain exact stored aliases of 7/8 with unresolved original trigger
semantics. The observed upstream `develop`/`master` references are mutable and
were not pinned; they are dated research references, not installed-copy dumps.

### Missing timing authority

The actual installed-copy `CrAnim.txt` bytes remain absent. The archive inventory
records 16,231 unpacked bytes / 1,958 packed bytes in both sources:

| Archive | Entry | Directory offset |
|---|---|---:|
| H3ab_bmp | CrAnim.txt | 6,645,963 |
| H3bitmap | CRANIM.TXT | 19,049,525 |

Those are resource offsets in the recorded LOD inventory, not durations. Neither
source LOD is available here. Search results containing modified fast-animation
tables were excluded. All fourteen row values remain explicitly null in the
status JSON. Original executable/version, battle-speed selection and plugin
state also remain unverified. The selected one-second Laema attack is preserved
as the user's accepted game setting; its earlier original-timing attribution is
qualified in the current GDD.

## Phase 5: actual Pikeman front-thrust playback repair

The only changed runtime resource is
[melee_swing.tres](../../../../config/attack_animations/melee_swing.tres).
It continues to use the same v02 PNG. Two region keys now select already-present
high-resolution recovery drawings:

| Native key time | Previous atlas cell | Corrected atlas cell | Rect2 |
|---|---:|---:|---|
| 0.8 s | 8 | 2 | `(1536, 0, 768, 512)` |
| 0.9 s | 9 | 1 | `(768, 0, 768, 512)` |

The original sequence's recovery repeats source poses 4,3,2,1. Existing hi-res
cells 6=4 and 7=3 already agree; old cells 8/9 instead returned to poses 1/0.
The corrected native timeline samples atlas cells
`0,1,2,3,4,5,6,7,2,1`, whose pixel identities follow
`0,1,2,3,4,5,4,3,2,1`. The existing frame-0 reset remains at 1.0 s.

This is an actual enemy playback repair, not a new demonstration entity:
[CombatEnemy](../../../../scripts/enemy/combat_enemy.gd) loads the native
resource through the existing private animation/geometry clone path, and
[PrototypeArena](../../../../scripts/prototype/prototype_arena.gd) spawns the
real Pikeman scene through the shared catalog. Archer, Griffin, Swordsman, Monk,
Cavalier and Angel retain their own native resources.

All runtime resource bytes outside the two region values remain identical:
length, key times, markers, texture path, AttackCast curves, collision and combat
values are preserved. No script, scene, PNG or import descriptor changed. All 37
hi-res PNGs retain their audited hashes. The physical v02 atlas still contains
the old, now-unused recovery cells; it is not described as a repaired master
atlas. The resource fixes live sampling without claiming full pose/timing parity.

## Missing art and current classification

Further direct inspection confirms a source-art gap in Pikeman Hurt, group 3.
Original frames 4/5 recover with a trailing free arm; hi-res frame 4 has already
returned to a two-hand spear grip, and hi-res frame 5 repeats ready frame 0.
The present Pikeman frames do not provide source-verified replacements for both
recovery positions. This is now **Partial**, rather than merely an unknown
correspondence. Unrelated idle/walk drawings were not substituted.

Static pose review now covers all 37 selected sequences and 270 original/hi-res
frame positions. Beyond the Pikeman attack/recovery findings, no additional
unambiguous order error or safe existing-cell repair was identified. Broad
action phases correspond, but finer grip, limb, silhouette and effect-treatment
differences remain unverified. Angel's original bright attack highlighting is
not identically reproduced. Group-union crops were independently normalized for
pose visibility, so this review does not certify scale, pivots or original
placement. The updated group-slot classification is:

| Status | Slots | Reason |
|---|---:|---|
| Complete | 0 | Original timing, full pose fidelity and original-runtime parity are still unverified. |
| Partial | 1 | Pikeman Hurt requires genuine missing recovery-pose equivalents. |
| Not converted | 0 | No verified complete independent master/frame source without a usable atlas was recovered. |
| Missing source | 187 | No located hi-res counterpart or exact-alias candidate. |
| Needs verification | 37 | Remaining existing atlas-backed slots plus Angel G15 alias candidate. |
| Total | 225 | Original identities are all retained. |

The live G12 correction does not add artwork or increase group coverage.
Angel G15 remains an exact-original-alias reuse candidate from G12; adding a
shooting state or projectile would invent behavior, so none was introduced.
The 187 missing-source slots still correspond to 151 distinct ordered sequences
after proven aliases, in addition to the specific partial Hurt recovery gap.

## Validation and practical limits

The working project was not opened by the validation engine. A separate copy
with the actual scripts, scenes, configuration, AI, addons and runtime assets was
used. Cached user data, editor settings and generated imports stayed in scratch
directories outside the project.

- Static resource comparison confirms that only recovery rectangle values 8/9
  changed; every other runtime resource byte is identical to the before-snapshot.
- Isolated headless import completed with Godot 4.6.3 without script, parse,
  GDExtension or resource-load failures. This project declares Godot 4.7, so this
  does not certify target-version compatibility.
- The actual baseline Gym started, spawned Pikeman, progressed through
  IDLE/APPROACH/WINDUP/ACTIVE and hit the Player under the available engine.
- The corrected actual Gym actor's private native animation was sampled at
  0.8, 0.9 and 1.0 s in both facings. All six rectangle/facing checks passed;
  its texture remained the existing v02 attack PNG.
- A corrected 360-frame headless Gym smoke run completed three full
  WINDUP/ACTIVE/RECOVERY/IDLE cycles and three melee hits. All three native
  marker lookups remain identical to baseline at 0.5/0.5/1.0 s. This is a bounded
  agent-run state/resource check, not rendered animation acceptance.
- Baseline runtime already reports an unsupported
  `Label.custom_maximum_size` assignment in ObjectiveWidget under Godot 4.6.3.
  This unrelated target-version issue is preserved and limits a clean gameplay
  validation claim. Quit-time object leaks and editor socket/export warnings
  were also recorded separately from the resource repair.
- No display/Xvfb path was available, so no rendered playback or final visual
  acceptance is claimed. Human validation in the project's intended engine
  remains outstanding.

The final machine-readable engine evidence and pose-review findings are recorded
in the accompanying status JSON. [Saved engine logs](validation-logs/) retain
baseline and corrected import/runtime results with isolated-directory prefixes
anonymized. Engine checks are
agent-run evidence and do not replace the user's required Godot acceptance.

## Remaining completion requirements

1. Recover the original installed timing rows and executable/version/settings
   evidence; do not treat modified mod tables or current VCMI rates as stock
   timing.
2. Recover the full approved Castle source package and upgraded-variant masters,
   plus the missing Pikeman recovery artwork. Existing atlas pixels can be reused
   where the original source proves the same pose; absent artwork remains an
   explicit source requirement.
3. Review the recorded pose comparisons and resolve their fidelity limits,
   then convert only genuinely supported source sequences. Full original state orchestration and
   upgraded actor behavior need source-grounded integration, not new abilities
   inferred from numeric group labels.
4. Validate actual playback and transitions in the intended Godot version, both
   facings and actual encounters, before certifying any group Complete.

No commit, push or live publication is included. This is a bounded Phase 5
repair with explicit blockers on the remainder of Phase 2 and full remastering.

For user validation in the intended engine: run the actual Gym with Pikeman,
inspect the last two recovery poses before the 1.0-second ready reset in both
facings, and compare weapon/body/query alignment with the existing overlays.
Attack timing and collision should retain the current accepted behavior. Hurt
remains partial and no original-speed parity is claimed.
