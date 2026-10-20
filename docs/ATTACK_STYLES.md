# School attack styles

## Current ownership — October 20

Numerical combat settings belong to Player and CombatEnemy root **Settings**,
with the former Gym baseline used in all rooms. Portal saves update those same
native Resources. The old Gym-only multiplier and run-only save restriction are
retired. Historical overnight comparisons below retain their original context.


Status: implemented candidate; numeric presets await user playtesting.

## Current animation geometry

Melee uses animated hitboxes throughout `active_start` to `active_end`, with
one contact allowance per target per attack. The native geometry below is the
current active-start readback; later keyed poses also matter during the window.
Human feel acceptance and final numeric tuning remain pending.

| Move | Local active-start position | Radius | Target vector |
| --- | --- | ---: | --- |
| fire_x1 | (40, 11) | 16 | (0, 0) |
| fire_x2 | (40, 11) | 16 | (0, 0) |
| fire_x3 | (40, 11) | 16 | (0, 0) |
| fire_x4 | (30, 11) | 16 | (0, 0) |
| fire_x5 | (35, 11) | 16 | (0, 0) |

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

## Fire / Earth benchmark artwork — 2026-10-19

Fire X1–X5 now use the former Earth sword flipbooks, matching Laema's benchmark
weapon. Earth X1–X5 use the former Fire flipbooks. Sprite-sheet references and
frame tracks/pacing move together at each corresponding X position. Animation
IDs, contact/active markers, hitbox tracks, actual windup/recovery durations,
lunge, Impact and damage stay with their original schools. Water, Air, Cast and
locomotion assignments are unchanged. The underlying PNGs retain their original
filenames; edit `fire_x1` to tune Fire even though its texture is `earth_x1.png`.
Historical numeric presets refer to those same move IDs; they are not current defaults.

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

Select **CollisionShape2D** to edit the body capsule. Match the Player's existing
ground alignment: the capsule bottom sits **12 world pixels above the visible
idle feet**. The shared floor collision is at Y `52`, while its artwork starts at
Y `64`; the Player already accounts for this offset. Then save the scene. This
body collider needs no animation keys. Keep attack geometry in **AttackCast**
and its native Animation tracks.

The current body capsule retains radius 12.4, height 68.7 and position
(-11, -3.35). Pikeman artwork uses 450×400 source cells and its own common feet
anchor/scene scale; do not reuse the earlier fighter's 128-pixel-cell calculation.
Preserve the authored floor/body relationship when editing. Exact older
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
