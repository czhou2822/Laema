# School attack styles

## Current ownership — October 20

Numerical combat settings belong to Player and CombatEnemy root **Settings**,
with the former Gym baseline used in all rooms. Portal saves update those same
native Resources. The old Gym-only multiplier and run-only save restriction are
retired. Historical overnight comparisons below retain their original context.


Status: implemented candidate; numeric presets await user playtesting.

## Daytime timing candidate — October 22

Fire X4 now reads windup0.33/recovery0.36 from
`config/attack_styles/fire_x4.tres` (90f963de; base0.69s before Heat), replacing
only recovery0.51. Native timing_split0.70, active0.36..0.8666667, Sprite/geometry
keys, lunge10/0.15..0.55 and push0.75 remain. Recovery includes late active frames;
its shorter duration also shortens real-time input/contact windows. X5 can begin
0.15/Heat-multiplier seconds earlier, not with guaranteed Enemy-relative safety.
X5 remains D0.45/1.10, base1.55s, as described below.

Main's pure uncharged0.65s-cadence baseline/C1 comparisons both accepted and
landed all five X, P100/E150/queue5; X5 began3.543s versus3.697s. This supports
that scoped continuation, not final late-chain feel, pose continuity or all input
cadences. No pose/weapon/art key or normalized rule was changed. See the
[daytime ledger](iterations/2026-10-22-fire-combat-daytime/PROGRESS.md).
These timing candidates remain pending user controller acceptance.

## Retained overnight timing candidate — October 22

Fire X5 currently reads windup0.45/recovery1.10 from
`config/attack_styles/fire_x5.tres` (candidate D,57aef5ab; base1.55s before Heat).
Native length1, timing_split0.60, active_start0.36, active_end0.80, Sprite/geometry
keys and lunge12/0.15..0.55 remain unchanged. Recovery stretches native0.60..1.00,
including late active frames; it is not an added post-hit pause. Cast retains
shared1.2s base and native launch0.24. Captured phase durations scale once with
live Heat; increasing X5 recovery also delays a queued endpoint Cast.

Main's current-source small low-Heat D cohort had7/7 valid high-level Cast contacts
APPLIED13 versus same-Might A0.95's6/7, with first release-to-launch about0.960s
versus0.831s. This supports a provisional mechanical-margin comparison, not
statistical survival superiority, human feel acceptance or high-Heat Enemy
protection clearance. A remains a comparison; B/C were reverted. Evidence cutoff
is07:19 HKT for rendered play. The later five existing full headless suites
completed7212 checks/zero assertion failures/all exit0 as supplementary controlled
regressions; forced preparation/seeks and retained shutdown warnings prevent any
human-controller/AI/blanket runtime clearance claim. See
[Implementation Status](IMPLEMENTATION_STATUS.md) and the
[overnight ledger](iterations/2026-10-21-fire-combat-overnight/PROGRESS.md).

The retained common-start repair reasserts Movement's lock for every actual X/Cast
start, including a COMBO_ACTIVE preserved-gap continuation. Gaps stay unlocked;
queued starts reassert true. Movement's provider and authored distances3/8/2/10/12
are unchanged; collision can still consume blocked motion. No new FSM/window,
Heat, dodge or other-school tuning policy is introduced.

## Current animation geometry

Melee uses animated hitboxes throughout `active_start` to `active_end`, with
one contact allowance per target per attack. The native geometry below is the
current active-start readback; later keyed poses also matter during the window.
Human feel acceptance and final numeric tuning remain pending.

| Move | Local active-start position | Radius | Target vector |
| --- | --- | ---: | --- |
| fire_x1 | (-17.60, -66.97) | 3.5 | (22.21, -15.07) |
| fire_x2 | (-23.80, -31.17) | 3.5 | (-22.91, -8.15) |
| fire_x3 | (-0.30, -31.23) | 3.5 | (26.61, -22.04) |
| fire_x4 | (5.25, -45.81) | 3.5 | (29.51, -11.88) |
| fire_x5 | (-14.55, -63.89) | 3.5 | (19.10, -12.23) |
| melee_swing | (58, -67) | 6 | (147, 0) |

These are rounded right-facing active-start readbacks. Fire's world scale is2,
so radius3.5 means7 world pixels. X2's October21 candidate follows the current
backward preparation blade, then the forward blade in its later active poses;
active-start alone does not describe maximum reach. Its four independently
measured poses and engine evidence are in the
[X2 iteration record](iterations/2026-10-21-fire-hitbox-polish/x2-candidate/README.md).
X1's October21 candidate follows all seven current overnight_v04 active cells;
its added geometry poses at0.45,0.53 and0.711878675 retain the original Sprite
holds and active/pacing markers. See the
[X1 iteration record](iterations/2026-10-21-fire-hitbox-polish/x1-candidate/README.md).
X4's October21 candidate maps its native0/0/0/1/2/2 Sprite keys to three measured
source cells over four active holds, with the repeated final cell retaining one
physical pose. Its key times and radius are unchanged. See the
[X4 iteration record](iterations/2026-10-21-fire-hitbox-polish/x4-candidate/README.md).
X5's October21 candidate matches its four active cells, including the vertical
pose at0.5 and final forward thrust. Its0.8 active end and later return frames
stay unchanged. See the
[X5 iteration record](iterations/2026-10-21-fire-hitbox-polish/x5-candidate/README.md).
X3's October21 candidate follows all five active source cells, including the
lower follow-through at0.711878675 and the short opening/return holds. See the
[X3 iteration record](iterations/2026-10-21-fire-hitbox-polish/x3-candidate/README.md).
All five Fire resources have bounded source/engine review; human feel acceptance
remains open. Pikeman mirrors
around localX-11; its full-thrust outer tip isX211 right orX-233 left, symmetric
about that visual anchor. Native key times/markers and the one-contact allowance are unchanged.

For this Fire artwork, the feet source anchor is(224,400), but the existing
Sprite offset(0,-124) maps the actor root to source(224,348). Actor scale2 and
Sprite scale0.5 combine to one world pixel per source pixel. Convert source
points to actor-local coordinates with `(source - Vector2(224,348)) / 2`, then
mirror localX for left-facing attacks. Do not use the feet anchor as the geometry
origin or move the body/floor registration to fit a weapon. X2 retains radius3.5;
its capsule centers are inset7 source pixels at each measured blade end. Its
position/target keys hold with each displayed pose, including the key at0.6;
Sprite timing, active bounds and the radius track are unchanged. Near-key
float tolerance is checked against the actual native Sprite region, separately
from unambiguous held-pose interiors.

Fire Cast uses `launch` at 0.24 on its normalized one-second clip; other schools'
clips retain their authored timing. Enemy uses the Pikeman 0.5/1.0-second active
window at native speed 1. The optional melee `timing_split` controls existing
Player phase-duration mapping; it does not emit a hit. Cast emission is once-only
at `launch`.

Earlier Fire Cast anticipation, X2/X3 coverage comparisons, Enemy 1.1/1.3-second
package and initial scalar presets are preserved in the
[pre-housekeeping guide](history/2026-10-20-document-housekeeping/sources/docs/ATTACK_STYLES.md)
and [overnight ledger](iterations/2026-10-19-overnight.md). Their historical
Gym-only multiplier and contact-query workflow are superseded.

## Fire / Earth benchmark artwork — historical October 19

The October19 benchmark exchanged Fire/Earth flipbook assignments while retaining
their school-owned move rules. That is history, not the current Fire file list.
Current Fire X1/X4/X5 use `fire_sword_shield_v01/overnight_v04/`; X2/X3 use
`fire_sword_shield_v01/angle_proofs_v03/`. This alignment pass changed none of
those PNGs or Sprite tracks, nor Earth/Water/Air, Cast or locomotion bindings.
Edit the native `fire_xN` Animation to author that Fire move. Earlier numeric
presets and the older `earth_x1.png` Fire example are not current defaults.

## Scrub and visually edit an attack

1. In the Local Inspector, open a move resource such as `config/attack_styles/fire_x1.tres` and click **Edit fire_x1 animation & hitbox**. The existing Laema editor plugin opens `scenes/player/player.tscn`, selects AnimationPlayer and assigns that clip. The move's **Animation** property also links directly to its native Animation resource.
2. In the bottom **Animation** panel, select `fire_x1` if needed and scrub the timeline. The sprite changes frames without running the game. Pin the Animation panel so it stays available when selecting other nodes.
3. Scrub across **active_start** through **active_end**, checking the intended hitbox poses. Select **AttackCast** in the scene tree. Move its origin and drag the ShapeCast/shape handles in the 2D viewport, or edit **Transform → Position**, **Target Position**, and **Shape → Radius** in the Inspector.
4. Insert/update keys for the properties you changed, using the Inspector key icons. The existing tracks are `AttackCast:position`, `AttackCast:target_position`, and `AttackCast:shape:radius`. Moving a handle alone does not save a per-move key. Author the attack facing right; gameplay mirrors its horizontal coordinates for left-facing attacks.
5. Save the external Animation resource (`config/attack_animations/fire_x1.tres`) and save the scene if marked modified. Save native animation edits before making a Portal draft. Rerun the Gym to compare. Gameplay samples the saved geometry across the active interval. Extra keyed poses do not permit repeated hits on the same target within one attack.

For Enemy melee, open `scenes/enemy/combat_enemy.tscn`, select **AnimationPlayer → melee_swing**, and follow the same scrub/select/key/save workflow. Its hitbox reach/radius are separate from **Enemy AI → Attack range**, which only controls when the enemy approaches/starts windup.

Player timelines use the existing normalized one-second clocks. Actual Player windup/recovery duration still comes from move tuning, Heat; their timeline seconds are not wall-clock combat seconds. Sprite-frame key spacing belongs to the assigned flipbook; Fire/Earth exchanged those frame tracks for the sword benchmark. Cast artwork uses the corresponding `cast_fire`, `cast_water`, `cast_air` or `cast_earth` clip; projectile damage keeps its existing path.

Enemy's `melee_swing` instead plays at authored speed: timeline seconds are combat
seconds in both Gym and tutorial. To adjust its timing:

1. Open `scenes/enemy/combat_enemy.tscn`, select **AnimationPlayer**, and choose **melee_swing**.
2. Scrub the **BodyVisual:region_rect** track and edit frame-key times to pace preparation, strike and follow-through.
3. Set **active_start** at the beginning of hit-capable frames and **active_end** at their end. These bounds govern contact checks and active-move resistance. Do not add a `contact` marker. `timing_split`, when present, is pacing-only.
4. Author recovery poses between **active_end** and **Length** if needed. The current Pikeman clip has active_start 0.5 and active_end/Length 1.0, so it has no recovery tail. Preserve the intended sprite/geometry alignment when editing keys.

5. Save the external `config/attack_animations/melee_swing.tres`, open the Gym scene, and press **F6** to compare one change.

The separate Enemy windup/recovery controls and the Gym's Enemy timing multiplier
are removed. Old JSON snapshots retain compatibility data; they cannot rescale
the Enemy animation.

The button is navigation into Godot's built-in animation editor, not a custom flipbook tool. If that editor is pinned to another AnimationPlayer, unpin it before switching scenes.

## Align the Enemy body with the floor

Open `scenes/enemy/combat_enemy.tscn` in the Local editor. Its default **BodyVisual**
shows the standing Idle sprite. Position, scale and rotation are authored in the
scene. The rest position is captured when the Enemy becomes ready, before stage
preparation can reset it, and retained by configuration and hurt/stage recovery.

Select **CollisionShape2D** to edit the stable capsule: radius30, height180 and
position(-11,-59), bottomY31. Repaint v02 uses768×512 cells, BodyVisual position
(-11,31), offset(0,-192) and foot anchor(384,448). Both visible feet and the body
bottom map to the Gym floorY52 (screenY610). The older12-pixel visible-floor-art
offset belongs to the previous artwork and must not be reapplied to this repaint.
Keep attack geometry in **AttackCast** and its native Animation tracks.

Fire Player uses a30×90-local rectangle at(0,-19), root scale2, bottomY26. Its
existing Fire sprite offset(0,-124) stays unchanged. Other-school artwork restores
the26×30 rectangle at(0,11). These stable body profiles exclude weapons and are
not keyed to individual poses. Preserve the authored floor relationship. Older
calculations remain in the [historical guide](history/2026-10-20-document-housekeeping/sources/docs/ATTACK_STYLES.md#align-the-enemy-body-with-the-floor).

## Tune numerical settings

- Both editor and in-game Dev Portals expose **Combat → Attack styles**. Reach/radius show the native active-start pose. Save updates only the changed active-start size keys, preserving authored offsets, angle, other frames and sprite tracks. **General → Final Enemy** exposes its separate hitbox reach/radius.
- Open `scenes/player/player.tscn`, select **Player → Settings → Moves → Attack Styles**, then expand the move. Saving its external `.tres` updates the settings read by both scenes.
- Saved native animations own geometry and sprite frames. Player/CombatEnemy Settings own timing, lunge, Impact and other combat settings; stored geometry scalars are compatibility/readback mirrors. A native animation save overrides stale geometry mirrors at the next read, without writing files on startup.
- The Portal and active Inspector bridge watch character Settings and animation-file changes. Reload the Portal after saving native edits if it has an unsaved draft; stale changes to the same active-start size are rejected.
- Unsaved runtime edits affect the current run and private Animation copies. Portal Save persists the shared character assets; retry loads saved authoring. Active attacks retain their captured geometry curves; edits affect subsequent attacks.

## Locate the underlying files

Each `config/attack_styles/<move_id>.tres` settings resource links to
`config/attack_animations/<move_id>.tres`. The latter contains the real native
Animation tracks, including the sprite-sheet texture reference. The Player and
move-settings Inspector share that Animation asset. Right-click either external
resource and use **Show in FileSystem** to reveal it. Use Local assets for persistent authoring/navigation.

| Setting | Meaning |
|---|---|
| Windup duration | Player phase duration up to the optional pacing-only timing_split (active_start if absent), before Heat scaling. |
| Recovery duration | Player playback after the pacing split until completion. It can include active frames; the hit window independently follows active_start/active_end. |
| Shape reach / radius | Active-start ShapeCast target-vector length and circle radius, in local pixels. Native tracks own the full curve; debug geometry follows active-window samples. |
| Lunge distance | Total attacker-body displacement in pixels over the selected phase interval. |
| Lunge start/end phase | Normalized animation-clock interval; start must precede end. |
| Push scale | Multiplier on the existing qualifying combat reaction distance. It changes neither eligibility nor duration/invincibility; stationary practice targets retain legacy recoil. |

A zero timing value inherits that phase of the shared duration. Native zero reach is a point query; radius must be positive. Legacy custom JSON profiles with omitted geometry retain their shared fallback. Zero lunge distance disables forward motion. Walls consume blocked motion rather than storing it for later.

## Initial presets — historical reference

The full twenty-move starting table is preserved in the
[pre-housekeeping guide](history/2026-10-20-document-housekeeping/sources/docs/ATTACK_STYLES.md#initial-presets).
Read current values from the assigned character/style Resources and native
Animations. Old scalar reach/radius columns are not current animated positions.

## Preserved chain and Casting behavior

Positions 1–5 remain global X/Cast positions. School changes select the new school’s move for the current position, not a local counter. Casts retain their shared duration, composition, orb commitment and optional sixth-slot endpoint behavior. Existing damage, Impact/Poise, reaction bands and reaction durations were not retuned.

## First playtest

Compare the four rhythms against a stationary practice target, then test forward spacing and qualifying push against the attacking enemy and a wall. Keep Heat consistent when comparing. Existing reaction invincibility can reject later contacts in a fast sequence; inspect rejected hits separately from input acceptance. Use active_start/active_end to tune hit-capable frames, the optional timing_split for Player pacing, and launch for once-only Cast emission.
