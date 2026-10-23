# Original Fire X1 motion study player

Open `project.godot` with Godot 4.6 or later and run the project. This standalone
preview is isolated from the main Laema Godot project by the research-folder .gdignore; it does not replace any game assets or alter
the combat implementation. It uses original low-fidelity joint/pose data from
`study-data.json` and draws silhouettes. No existing animation sequence is used.

The initial view compares A/B/C at approximately 180-pixel body height in a
1280×720 viewport. Heat 0 uses a 0.72-second attack; Heat 100 uses 0.48 seconds.
The ¼× setting is explicitly slow review playback. Ground anchors remain fixed;
the game's existing 3-pixel root lunge is not simulated. Normal playback adds
0.24 seconds of guard before the attack and 0.42 seconds after it so loops can
be compared without immediately repeating the strike.

Controls: Space pauses; Enter restarts; Left/Right step 1/60 second; H switches
Heat; F mirrors facing; Z switches the 1× comparison to a 2× selected study;
1/2/3 select a study; J shows joint guides. Click the timeline to scrub.

Gold on the timeline is the existing contact-time window, not verified contact
geometry for the proposed sword arcs. No damage, reach, collision, input buffer,
cancel, enemy reaction or transition rules are simulated. The shared first and
last poses expose the neutral guard entry/exit. Actual X2, Casting, defence,
dodge and hit-reaction transitions still need integration after motion approval.

## Verification

Godot 4.6.3 headless import and 120-frame execution completed. The data check
sampled all three proposals at 219 time points and verified the fixed 88-pixel
blade length. No engine screenshot or visual gameplay acceptance is claimed:
this machine has no graphical session, and a dummy X server could not open its
local listening socket in the sandbox. The browser review supplied alongside
this project is a separate renderer of the same motion data.

For a headless data check:

```sh
godot --headless --path . -- --check
```

On a machine with a display, optional capture arguments are supported:

```sh
godot --path . -- --snapshot /absolute/path/study.png
godot --path . -- --capture-dir /absolute/path/frames --capture-frames 180
```

Use `--heat100`, `--slow` or `--left` to alter capture playback. Frame output is
60 fps by default. These capture paths were implemented but not exercised here.

In a filesystem sandbox, set `XDG_DATA_HOME`, `XDG_CONFIG_HOME` and
`XDG_CACHE_HOME` to writable task directories before launching Godot.
