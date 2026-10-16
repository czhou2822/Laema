# Development gym

Open `scenes/gym.tscn` in Godot and run the current scene (F6), or use **Laema Dev
Portal → Run gym** in the bottom action area. The regular main scene and saved startup-stage
setting remain unchanged.

The gym contains the current Player and one instance of the existing Final
Enemy, with no practice targets. PlayerSpawn is at `(-80, 0)` and FinalEnemy at
`(80, 16)`: the horizontal starting gap is 160 pixels. With the current 90 px/s
approach and 72 px attack range, the nominal walk to attack range is about one
second. Timing is an estimate from configuration, not a gameplay-feel result.

Press controller **Start** or keyboard **Esc** for the pause menu. Use **Resume**
or press Start/Esc again to continue. **Reset gym** starts another round
of the same gym. Menu buttons support controller directional input and confirm.

The room reuses the prototype backdrop and floor, with a stationary camera and
side boundaries. Shared saved combat, movement, audio and debug settings still
apply, including the AI enable flag and the current Final Enemy's Endurance.
The gym enemy has unlimited training health: damage still reduces the displayed
Health, but reaching zero immediately refills it. It keeps fighting and never
completes a defeat objective. Normal hit/reaction/resistance rules still apply.
The ordinary tutorial Final Enemy remains killable; shared tuning is unchanged.

## Combat formula readout

A gym-only panel below the ordinary telemetry shows each fighter's current melee
move Impact and Poise. The two **Last hit received by** cards display the actual
resolver values captured at contact:

Incoming Impact − receiver Poise − receiver active-move Impact = hit-reaction value → level.

For example, **60 − 20 − 15 = 25 → Level 3** with the initial configured ranges.
The active-move contribution is 0 during windup/recovery. Captured math remains
visible after the attack is cancelled or its reaction ends. Live stats can change
without rewriting that last-hit snapshot. Non-positive contacts show **No reaction**;
the exact Player-winning 0/0 exception is explicitly labeled. Invincible/blocked/
parried/cancelled attempts show their status and preserve the last evaluated math.

The formula panel is part of **Developer Overlay Visible**, alongside the normal
telemetry panels. **F4** hides/shows them together while the gym is focused,
including while paused. The same single switch is in **General → UI & debug**
in both the editor and in-game Portal. Gameplay Health/Heat/orb/objective UI remains
visible. The Dev Portal window still uses its separate backtick open/close shortcut.

Captured values keep updating while the overlay is hidden. Reset gym clears the
cards and reconnects the Enemy while retaining your shared visibility choice.
The shortcut changes the current run; use **Save Tuning** in-game or **Review & save**
in the editor to remember it. The obsolete formula-only preference is ignored when
an existing Developer Overlay Visible preference is present. No combat values or
rules are changed by toggling the overlay.

Use the running gym's **Load stage in current session** action to reload its
single encounter for a fresh round. Health refill keeps the same enemy alive
without respawning it or resetting combat state. To
change the gap, open `scenes/stages/gym_area.tscn` and move PlayerSpawn or
FinalEnemy.

The root inherits `prototype_arena.tscn`; its small `gym.gd` script supplies a
single in-memory encounter descriptor derived from the canonical final stage.
It retains the shared Player, HUD, audio, projectile routing, Portal and tuning
bridge. StageDirector remains the lifecycle owner. Gym descriptor selection is
never written into `prototype_combat.json` by starting or saving gym tuning.

Validation boundaries are recorded in IMPLEMENTATION_STATUS.md. Headless scene
and approach checks do not establish visual composition or game feel.
