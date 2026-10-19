# Laema Dev Portal

Godot editor plugin, enabled in this project's `project.godot`. After reloading the
project, choose the **Laema Dev Portal** tab beside the Inspector. The native dock uses
the editor's theme and can be moved with Godot's normal dock controls.

## Editing

Choose a section (**General**, **Combat**, **Schools**, **Audio**, **Tutorial** or
**Session**), then use the category tabs directly beneath the main section tabs.
The category row scrolls horizontally when the dock is narrow. Single-page sections
open directly. The dock remembers the last category in each section; switching pages
preserves the draft. Change a draft, then use **Review & save**. **Revert draft** and
**Reload file** return to the file's saved state. The editor dock does not require
the Arena scene to be open or the game to be running.

Drag a main section button onto another section to rearrange the two-row grid.
Drag category tabs left or right to rearrange that section's second-level row.
Both orders are saved locally in `.godot/editor/laema_dev_portal_layout.cfg` and
restored when the dock reopens, along with the last selected section and each
section's last selected category. Without a saved selection, the first tab in your
arranged order opens. Each section has its own category order. Rearranging
tabs preserves the selected page and unsaved edits; it does not change gameplay
configuration. New categories append after your saved tabs; removed tabs are ignored.

`config/prototype_combat.json` is the persisted authority. Both the editor and
in-game Portal use `developer_settings_catalog.gd` and
`developer_settings_fields.gd`, including all existing Portal controls, move
Impacts, five reaction duration/distance pairs, nested school levels, audio mix,
startup stage, transition duration and saved attack-hitbox visibility. Fixed
gameplay invariants stay fixed. Gravity and compatibility fields retain their
intentional Portal exclusions. Stage definitions and animation markers retain
their existing JSON/scene authoring workflows. School names are Fire, Water, Air
and Earth. Only individual effect settings not consumed by current Casting carry
**Not used by current Casting**; active attack-presentation settings are unmarked.

### Developer overlay visibility

**General → UI & debug → Developer Overlay Visible** is the single switch for
developer telemetry and the gym formula panel. **F4** toggles both together during
a gym run, including while paused. Captured hit values keep updating while hidden;
Retry gym clears history and retains the shared visibility choice. Gameplay HUD
stays visible. The Dev Portal window uses its separate backtick shortcut.

Use editor Review & save to persist the choice for future Gym launches.
The tutorial also supports Save Tuning in-game; the Gym uses run-only previews. The shortcut does not save unrelated draft tuning automatically. Older
formula-only settings migrate in memory: the existing developer-overlay preference
wins when both are present, and the duplicate field is no longer shown or saved.

### Collapsible reactions and Impact

**Combat → Hit-reaction levels** is the dedicated configuration for Levels 1–5.
Each entry has **Starting value**, **Duration** and **Distance**. The displayed
range ends one below the next level's start; Level 5 extends upward without a
ceiling. Starting values must be whole numbers in increasing order. Level 1 is
anchored at 0; these ranges choose the level only after hit eligibility is decided.
The initial starts (0, 11, 21, 31, 41) preserve the earlier behavior.

All five entries live inside one collapsed **Levels 1–5** section, with plain
level headings. **Combat → Legacy reactions** contains the four older
practice/defence/failed-Cast controls separately. Expansion state is remembered
while navigating and refreshing fields. Both editor and in-game Portal use the
same configuration; the combat Inspector exposes the same starting values.

**Combat → Impact** groups the five individual X attacks under Fire, Water, Air
and Earth. Expand a school to edit X1, X2, X3, X4 and X5 independently. Cast and
Final Enemy attack have separate groups. These are the existing non-negative
integer Impact values read by combat, not a second set of tuning values.

Each school's **Fill X1–X5 series…** uses the shared start/increment preview,
restricted to that school. It preserves other schools, Cast, Enemy attack,
animation/source links and unrelated settings. Fill changes the draft; review,
save and live apply remain separate. The in-game Portal uses the same grouped
Impact controls and collapsible reaction groups.

### Fill a level series

Choose **Fill series…** on a page containing an editable numeric level table.
Currently this includes **Combat → Hit-reaction levels**, **Schools → Water**, and
**Schools → Earth**. The tool discovers columns and limits from the same field
catalogue used by the ordinary controls; new exposed numeric level tables can
reuse it without a separate dialog implementation.
The same dialog also serves each school's ordered X1–X5 Impact controls above.

Pick one or more columns, then set a starting value and an amount to add per
level. Initial rules are inferred from the first two editable values, like
Excel's numeric series fill. For example, `0.6 s + 0.3 s per level` previews
`0.6, 0.9, 1.2, 1.5, 1.8` for combat reaction duration.

The preview shows each current value and its replacement. **Fill draft** updates
only selected editable numeric values. **Cancel** changes nothing. Generated
values must respect each field's limits, including when using a negative
increment. Slow ratios stay within `0..1`. Water's slow column starts at Level 3,
with Level 4 as its second editable value; fixed Wet/Frozen entries and all status
names are preserved and marked in the preview. A skipped level does not renumber
the remaining levels: increments follow the original level spacing. Range
starts can also be filled; Level 1 stays at 0 and non-increasing starts are
rejected. Separate legacy reaction scalars are not part of the fill.
These are one-off editing rules; only resulting values are saved through
**Review & save**. Live apply remains separate.

The preview uses single-line table cells with minimum column widths. The dialog
is resizable and bounded to the editor window; smaller windows scroll the form
instead of wrapping numeric values vertically. Fill/Cancel remain outside the
scrolling content.

The existing combat Inspector Resource is a view of JSON. Startup and file reload
read JSON; file timestamps never select a competing source. Inspector edits merge
their changed fields back into fresh JSON. No scene or Resource file is saved
merely by opening the dock or starting the game.

## During play

### Gym

Use **Run gym**, F5, or open `scenes/gym.tscn` and press F6. These launch the
same canonical Fire-only Gym: one Player and one killable opponent, 160 pixels
apart, with slower attack timings, unchanged Charging, victory/defeat and retry.
The separate benchmark entry point is retired. The contact-time formula panel
and ordinary telemetry share Developer Overlay Visible/F4.

**Retry gym** and **Load stage in current session** reload the complete encounter,
restore its local profile and clear captured hit history while retaining run
visibility. Runtime Portal and Remote Inspector edits are previews for the
current attempt. Gym refuses Save Tuning, Inspector mirror saves and shared
editor apply. Use the Gym root Inspector for its encounter values and the normal
editor Review & save for shared future-run defaults. Edit starting positions in
`scenes/stages/gym_area.tscn`. See `docs/GYM.md` for controls and observation goals.

### Connected session

Run the game from Godot. **Apply saved to game** sends an explicit request over
Godot's debugger connection. A connected debug game reports its active values,
unsaved state, pause state and available stages. **Session / Actions** loads a
stage or pauses/resumes the game. No additional server, port or Codex connection
is installed. Release builds do not register the debugger capture.

Editor pause/resume uses the game's visible pause HUD, also opened by controller
Start or keyboard Esc. Its Resume and Restart encounter controls work while
gameplay is paused. The pause menu and in-game Portal replace one another rather
than stacking conflicting pause states.

Saving the editor draft does not automatically apply it. Changing settings in the
in-game Portal retains its immediate-preview behavior. The tutorial can persist
changes through **Save Tuning** and apply saved editor configuration; the Gym
rejects both shared persistence and saved-editor apply. Multiple game sessions disable editor
commands rather than selecting one implicitly.

Startup stage and initial school affect the next run. Reaction changes affect
subsequent reactions; they do not retime active reactions. Tutorial stage-schema
changes require a restart. Existing AI decision-tuning resets remain intact.

## Files changed elsewhere

The dock watches the config while stopped or running. A clean draft reloads a
valid external change. An edited draft is preserved. Saving merges independent
field edits, rejects conflicting changes to the same field and validates the
whole result. Saves use a temporary sibling file and rename, with a file-identity
check before replacing the original. An invalid file is reported and not
overwritten. Reload deliberately after resolving a same-field conflict.

## Validation

Run `python tools/test-dev-portal.py --godot <Godot executable>`. When needed, add
`--work-root output` to keep isolated copies in a writable workspace. The runner
copies the project and engine, uses a separate editor profile and runs the editor
import plus config, offline-dock and headless-runtime checks. It does not test
against the working project or change the developer's Godot profile. Generated
copies contain `.gdignore` so they are not imported by the working project.

Headless checks do not establish visual usability, interactive debugger round
trips, gameplay feel or Web export success. Verify those separately in the editor.

Godot API references: [EditorPlugin](https://docs.godotengine.org/en/stable/classes/class_editorplugin.html)
and [EditorDebuggerPlugin](https://docs.godotengine.org/en/stable/classes/class_editordebuggerplugin.html).

Older saved files without any range starts receive the previous five starts in
memory on load. Loading does not rewrite the file; the next explicit save includes
them. A partially specified or invalid table is rejected. Range, duration and
distance edits affect subsequent combat reactions; an active reaction retains its
captured duration and motion. The receiver-side clash calculation uses incoming Attack Impact minus receiver
Poise minus receiver move Impact only during hit-capable active frames. Attack
Impact and Poise are constrained to 0–100. Other than the exact 0/0 Player-winning
active-clash exception, non-positive values do not cause a reaction; connected
hits still deal damage and both moves continue.
