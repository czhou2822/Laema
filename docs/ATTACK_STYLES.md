# School attack styles

Status: implemented candidate; numeric presets await user playtesting.

## Tune a move

- In the in-game Dev Portal, open **Combat → Attack styles** and expand one school/X position. Gym edits remain run-only. The editor Portal's Attack styles page is currently absent from its navigation; use the Inspector path below for persistent style editing.
- Open `scenes/prototype_arena.tscn` and select **CombatTuning → Settings → School Attack Styles - X1 to X5** in the Local Inspector. Expand a MoveStyleTuning entry. JSON remains the persisted authority through the existing bridge.
- Changes affect subsequent X actions. The current action retains its captured style. Heat still changes playback speed during an action.

## Locate a move in FileSystem

Each of the 20 move-style entries references its own file at
`res://config/attack_styles/<move_id>.tres`. Right-click the resource name, such
as **fire_x1**, and select **Show in FileSystem**. Godot reveals
`config/attack_styles/fire_x1.tres`. The resource dropdown exposes the same action.

These are move-settings assets, not animation clips or a flipbook editor.
Persistent Inspector edits still require the active CombatTuning bridge described
above; saving a `.tres` alone does not change the authoritative JSON. Inspector
and Portal configuration saves synchronize the external move files and their
parent mirror. Portal saves do not apply changes to a running game automatically.
The Gym's Remote Inspector contains private, run-only copies without file paths;
use the Local Inspector to locate the original assets.

| Setting | Meaning |
|---|---|
| Windup duration | Seconds until the native contact marker, before Heat scaling. |
| Recovery duration | Post-contact playback until action completion and the queued next action. The active interval still follows native Animation markers. |
| Shape reach / radius | Forward ShapeCast reach and capsule radius in pixels; debug geometry uses the same values. |
| Lunge distance | Total attacker-body displacement in pixels over the selected phase interval. |
| Lunge start/end phase | Normalized animation-clock interval; start must precede end. |
| Push scale | Multiplier on the existing qualifying combat reaction distance. It changes neither eligibility nor duration/invincibility; stationary practice targets retain legacy recoil. |

A zero timing value inherits that phase of the shared duration. Zero geometry inherits the shared query value. Zero lunge distance disables forward motion. Walls consume blocked motion rather than storing it for later.

## Initial presets

These values are a starting point for the approved feel references, not copies of Dead Cells mechanics or final balance. All lunges initially span animation phases 0.15–0.55.

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
