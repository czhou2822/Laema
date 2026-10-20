# School attack styles

Status: implemented candidate; numeric presets await user playtesting.

## Retained overnight Fire Cast anticipation — 2026-10-19

Supervisor provisionally retained the reviewed Fire Cast B resource; morning
human feel/controller acceptance remains pending. `cast_fire` active_start and
contact are 0.24, active_end and length stay 1.0. Every existing sprite pose
remains in order. Old t≤0.36 maps to t×0.24/0.36; later t maps to
0.24+(t−0.36)×0.76/0.64. Geometry key timestamps at 0.36 move to 0.24, without
changing geometry values. The original contact pose remains at launch.

This changes anticipation/launch timing while preserving total configured Cast
duration, Gym 1.5× scale, Heat, normalized queue windows and completion/melee
handoff. Water/Air/Earth Casts and all X clips are unchanged. At matched levels,
launch is eight physics ticks earlier; the tested spacing policy is faster but
takes more damage. Final tuning is open; see the overnight ledger and GYM.md.

## Current Fire contact geometry — retained overnight candidate, October20

Exact supervisor-reviewed D resources put X2/X3 at localX40, matching X1.
The3/2-local-pixel inward shifts become6/4 world pixels at current Player scale2,
gaining close coverage while losing the same outer reach. Human morning
controller/feel acceptance remains pending. Radius, poses, contact clocks,
lunge/Impact/damage and once-only resolution remain unchanged; overlap during
invincibility still applies neither damage nor generation.

| Move | Native contact-time local position | Radius | Target vector |
| --- | --- | ---: | --- |
| fire_x1 | (40,11) |16|(0,0)|
| fire_x2 | (40,11) |16|(0,0)|
| fire_x3 | (40,11) |16|(0,0)|
| fire_x4 | (30,11) |16|(0,0)|
| fire_x5 | (35,11) |16|(0,0)|

These are current native contact samples, not the historical scalar reach
presets below. X4's later position key remains(−11,11); X4/X5 data was not
copied from old prose or edited by the coverage change. Scrub/key/save the
native resources for authoring. Old A/D/C/E copies remain comparison evidence;
current retained Enemy package is GymPoise10/contact1.1/end1.3, speed1/no tail;
the separate earlier Poise10-only/recovery-tail comparisons remain rejected.

## Fire / Earth benchmark artwork — 2026-10-19

Fire X1–X5 now use the former Earth sword flipbooks, matching Laema's benchmark
weapon. Earth X1–X5 use the former Fire flipbooks. Sprite-sheet references and
frame tracks/pacing move together at each corresponding X position. Animation
IDs, contact/active markers, hitbox tracks, actual windup/recovery durations,
lunge, Impact and damage stay with their original schools. Water, Air, Cast and
locomotion assignments are unchanged. The underlying PNGs retain their original
filenames; edit `fire_x1` to tune Fire even though its texture is `earth_x1.png`.
The initial numeric presets below therefore still apply to the same move IDs.

## Scrub and visually edit an attack

1. In the Local Inspector, open a move resource such as `config/attack_styles/fire_x1.tres` and click **Edit fire_x1 animation & hitbox**. The existing Laema editor plugin opens `scenes/player/player.tscn`, selects AnimationPlayer and assigns that clip. The move's **Animation** property also links directly to its native Animation resource.
2. In the bottom **Animation** panel, select `fire_x1` if needed and scrub the timeline. The sprite changes frames without running the game. Pin the Animation panel so it stays available when selecting other nodes.
3. Scrub to the **contact** marker. Select **AttackCast** in the scene tree. Move its origin and drag the ShapeCast/shape handles in the 2D viewport, or edit **Transform → Position**, **Target Position**, and **Shape → Radius** in the Inspector.
4. Insert/update keys for the properties you changed, using the Inspector key icons. The existing tracks are `AttackCast:position`, `AttackCast:target_position`, and `AttackCast:shape:radius`. Moving a handle alone does not save a per-move key. Author the attack facing right; gameplay mirrors its horizontal coordinates for left-facing attacks.
5. Save the external Animation resource (`config/attack_animations/fire_x1.tres`) and save the scene if marked modified. Save native animation edits before making a Portal draft. Rerun the Gym to compare. Geometry at the contact marker is what the single melee query uses; other keyed poses help author the motion but do not introduce extra hits.

For Enemy melee, open `scenes/enemy/combat_enemy.tscn`, select **AnimationPlayer → melee_swing**, and follow the same scrub/select/key/save workflow. Its hitbox reach/radius are separate from **Enemy AI → Attack range**, which only controls when the enemy approaches/starts windup.

Player timelines use the existing normalized one-second clocks. Actual Player windup/recovery duration still comes from move tuning, Heat and the Gym's duration scale; their timeline seconds are not wall-clock combat seconds. Sprite-frame key spacing belongs to the assigned flipbook; Fire/Earth exchanged those frame tracks for the sword benchmark. Cast artwork uses the corresponding `cast_fire`, `cast_water`, `cast_air` or `cast_earth` clip; projectile damage keeps its existing path.

Enemy's `melee_swing` instead plays at authored speed: timeline seconds are combat
seconds in both Gym and tutorial. To adjust its timing:

1. Open `scenes/enemy/combat_enemy.tscn`, select **AnimationPlayer**, and choose **melee_swing**.
2. Scrub the **BodyVisual:region_rect** track and edit frame-key times to pace preparation, strike and follow-through.
3. Set **active_start** at the beginning of hit-capable frames, **contact** at the one damage query, and **active_end** at the end of hit-capable frames. These markers also govern interruption/clash phases.
4. Author any recovery poses between **active_end** and **Length**. Current retained
   Enemy active_start/contact are1.1 and active_end/Length1.3, so there is no tail.
   Length1.3 alone does not imply recovery. Existing sprite keys were retimed to
   0/.34375/.6875/1.03125, geometry contact keys to1.1; values/poses stay unchanged.
   Extending a clip beyond active_end would create a separate future tail.
5. Save the external `config/attack_animations/melee_swing.tres`, open the Gym scene, and press **F6** to compare one change.

The separate Enemy windup/recovery controls and the Gym's Enemy timing multiplier
are removed. Old JSON duration fields are compatibility data and cannot rescale
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

The current preset preserves radius `12.4`, height `68.7` and X offset `-11`.
Its Y offset is `-3.35`: half-height `34.35` puts the bottom at local Y `31`, with
idle feet at Y `43` for BodyVisual at Y `-21` in a centered 128-pixel cell. Both
actors' feet therefore meet the visible floor while their bodies meet its
collision surface. The earlier advice to align the bottom directly with the feet
missed this floor-art offset. If you change sprite transforms or capsule height,
retain the 12-world-pixel difference; there is no runtime auto-alignment.

## Tune numerical settings

- Both editor and in-game Dev Portals expose **Combat → Attack styles**. Reach/radius show the native contact pose. Save updates only the changed contact-size keys, preserving authored offsets, angle, other frames and sprite tracks. **General → Final Enemy** exposes its separate hitbox reach/radius.
- With `scenes/prototype_arena.tscn` open, **CombatTuning → Settings → School Attack Styles - X1 to X5** provides the same bridge-backed numerical editing. Saving a standalone move-settings `.tres` without that bridge does not update gameplay.
- Saved native animations own geometry and sprite frames. JSON owns timing, lunge, Impact and other combat settings; stored geometry scalars are compatibility/readback mirrors. A native save overrides stale JSON geometry at the next read, without writing files on startup.
- The Portal and active Inspector bridge watch both JSON and animation-file changes. Reload the Portal after saving native edits if it has an unsaved draft; stale changes to the same contact size are rejected.
- Gym/Remote edits remain run-only and affect private Animation copies. Rerun/retry restores saved authoring. Active attacks retain their committed geometry; edits affect subsequent attacks.

## Locate the underlying files

Each `config/attack_styles/<move_id>.tres` settings resource links to
`config/attack_animations/<move_id>.tres`. The latter contains the real native
Animation tracks, including the sprite-sheet texture reference. The Player and
move-settings Inspector share that Animation asset. Right-click either external
resource and use **Show in FileSystem** to reveal it. Remote Gym copies have no
persistent file paths; use Local assets for navigation.

| Setting | Meaning |
|---|---|
| Windup duration | Seconds until the native contact marker, before Heat scaling. |
| Recovery duration | Post-contact playback until action completion and the queued next action. The active interval still follows native Animation markers. |
| Shape reach / radius | Contact-time ShapeCast target-vector length and circle radius, in local pixels. Native tracks own the pose; debug geometry shows the committed query. |
| Lunge distance | Total attacker-body displacement in pixels over the selected phase interval. |
| Lunge start/end phase | Normalized animation-clock interval; start must precede end. |
| Push scale | Multiplier on the existing qualifying combat reaction distance. It changes neither eligibility nor duration/invincibility; stationary practice targets retain legacy recoil. |

A zero timing value inherits that phase of the shared duration. Native zero reach is a point query; radius must be positive. Legacy custom JSON profiles with omitted geometry retain their shared fallback. Zero lunge distance disables forward motion. Walls consume blocked motion rather than storing it for later.

## Initial presets

These values are a starting point for the approved feel references, not copies of Dead Cells mechanics or final balance. All lunges initially span animation phases 0.15–0.55.

This table preserves the historical starting presets. Current native contact
positions/radius/zero targets are authoritative in the table above; do not read
these old reach/radius columns as current point-circle positions.

| Move | Windup s | Post-contact s | Lunge px | Reach px | Radius px | Push × |
|---|---:|---:|---:|---:|---:|---:|
| earth_x1 | 0.48 | 0.42 | 4 | 52 | 24 | 1 |
| earth_x2 | 0.54 | 0.42 | 4 | 54 | 24 | 1 |
| earth_x3 | 0.28 | 0.38 | 2 | 42 | 20 | 0.7 |
| earth_x4 | 0.62 | 0.42 | 5 | 58 | 26 | 1.2 |
| earth_x5 | 0.74 | 0.46 | 7 | 62 | 28 | 1.5 |
| fire_x1 | 0.14 | 0.34 | 3 | 40 | 16 | 0.5 |
| fire_x2 | 0.16 | 0.34 | 8 | 43 | 16 | 0.5 |
| fire_x3 | 0.13 | 0.3 | 2 | 42 | 18 | 0.4 |
| fire_x4 | 0.22 | 0.34 | 10 | 46 | 18 | 0.75 |
| fire_x5 | 0.3 | 0.42 | 12 | 50 | 20 | 2 |
| water_x1 | 0.3 | 0.32 | 3 | 66 | 10 | 0.6 |
| water_x2 | 0.15 | 0.28 | 4 | 68 | 10 | 0.6 |
| water_x3 | 0.16 | 0.3 | 1 | 48 | 12 | 0.5 |
| water_x4 | 0.22 | 0.31 | 7 | 74 | 10 | 0.75 |
| water_x5 | 0.34 | 0.38 | 12 | 80 | 11 | 1.2 |
| air_x1 | 0.12 | 0.16 | 5 | 42 | 14 | 0.5 |
| air_x2 | 0.11 | 0.16 | 2 | 43 | 14 | 0.5 |
| air_x3 | 0.1 | 0.16 | 8 | 44 | 14 | 0.5 |
| air_x4 | 0.12 | 0.16 | 2 | 45 | 14 | 0.5 |
| air_x5 | 0.18 | 0.22 | 7 | 50 | 17 | 1 |

## Preserved chain and Casting behavior

Positions 1–5 remain global X/Cast positions. School changes select the new school’s move for the current position, not a local counter. Casts retain their shared duration, composition, orb commitment and optional sixth-slot endpoint behavior. Existing damage, Impact/Poise, reaction bands and reaction durations were not retuned.

## First playtest

Compare the four rhythms against a stationary practice target, then test forward spacing and qualifying push against the attacking enemy and a wall. Keep Heat consistent when comparing. Existing reaction invincibility can reject later contacts in a fast sequence; inspect rejected hits separately from input acceptance. Native active_start/contact/active_end markers retain their authored positions and remain available for marker tuning.
