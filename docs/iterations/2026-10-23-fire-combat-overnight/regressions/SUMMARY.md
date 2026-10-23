# Limited regression evidence — October 24

All images are unedited original1280×720 captures from Windows Godot4.7.1.
Inputs were normal bound hardware events. No Health, Heat, resources, positions,
AI or clocks were forced. These are agent synthetic-input observations, not
controller usability, final art, balance or whole-roster acceptance.

## Archer / legacy preferences

Trial101712_771010, retained f6+M1+U/C7 effective source. The three new cosmetic
keys were absent. Loader normalized contact/camera off and Precise in memory;
the JSON SHA256 remained unchanged through the encounter, with no startup Save.
Passive play received two10damage arrows; the shooting native frame is retained.
Normal approach switched the existing actor from shooting to close melee.
Held defence produced blocked chip; normal dodge crossed the body. Melee
knockback reopened range and the existing actor resumed shooting. The agent
adapted with closing/guard/dodge, rather than changing AI or forcing position.
Some committed Casts were interrupted before launch by actual incoming hits.
The completed fight ended Player5/Enemy0/Heat9/unexpected inputs0.

archer-shoot-native.png: command2/frame30, actual1815ms.
archer-close-native.png: command4/frame141, actual2218ms.

## Archangel / large grounded presentation

Trial92712_757592 used the existing Archangel prefab, stats and grounded policy,
with optional effects enabled/Weight. Passive attacks, repeated dodge/cooldown,
guard and a mixed Water4/Fire2 Cast were observed. A misfaced Air attempt missed;
it is NOT Air contact validation. Corrected Fire play completed the encounter
at Player42.5/Enemy0/Heat10/unexpected inputs0. No flight or new spacing policy.
archangel-mixed-native.png: command4/frame175, actual5016ms.

Separate partial diagnostic125468_760598 enabled engine body outlines and used
only passive normal input. The three body-debug originals show approach263ms,
active strike1527ms and idle/recovery2119ms. At strike, roots were PlayerX-80
and EnemyX-8.500; the Enemy's native melee clock was0.5 and face-left true.
The humanoid torso/legs visibly sit left of its cyan body capsule across these
samples, while Laema remains associated with her own outline. This establishes
a presentation-registration separation, not coincident physics roots or an
invalid-contact verdict. Mali's read-only review agreed it predates the new
contact/label treatment. Cause/remedy, right-facing behavior and gameplay
consequences remain unknown. No collider, artwork, offset or AI correction.
Diagnostic ended Player80/Enemy200, not a completed encounter.

## Earth and Air normal practice

Trial126140_734824 selected the existing Stage1 startup preference in the isolated
copy, not a forced actor/position fixture. Normal walk closed the initial160px
gap; all five Earth X actions physically hit its one training target. Generated
orbs supported a genuine empowered EarthLv5 endpoint Cast, launched6200ms and
impacted6221ms; Player100/target137/Heat10/unexpected0.

Then normal Air selection produced five separate X hits. At the faster pace,
only three orbs were charged before release. A normal, non-empowered AirLv3
Cast launched2216ms/impacted2236ms, leaving two generated orbs. Player100/
target77/Heat16/unexpected0. This does not validate Air/Earth against an attacking
Enemy or complete the Fire-only Stage1 objective. Source defaults were restored
before final replay. Earth/Air originals show the inherited small legacy body,
not a new art or scale change.

No trial above produced engine/script errors. Existing16ObjectDB/9resource exit
diagnostics remain separate; their absence is not claimed.

## Later current-source room-left / Dodge regression

31548_741224 used product3200279f (X5T1.55/sharedLevel4motion.15/R1), with only
isolated contact+camera enabled/Weight. Normal walk/dodge/guard reached the
room's left boundary and moved Pikeman nearX-539. Incoming hits interrupted the
first Cast; retained FIFO orbs also changed the expected composition. Those
attempts are not reported as successful mixed impacts. The later normal escape
and five Fire hits produced genuineFireLv6/WaterLv1, separate13/10 and two
captions with8px outlined gaps and one contact accent. That mixed impact was
center-right, NOT left-viewport clamp stress. The fight completedP37.5/E0/H15/
unexpected0. Sampled camera peak1.84px, then0. New effects caused no actor/clock
change. Original final-mixed-fire6-water1-native.png preserves the visible case.

Normal-input Dodge/accounting observations:

- While Charging, two charged statuses cleared on Dodge; all five queue orbs
  remained. This is the current GDD contract, not consumption of Charging orbs.
  Release during the roll produced no Cast.
- Before launch: Cast committed2586ms, spent two orbs once (5→3), then Dodge
  interrupted2685ms. No projectile launched; three unconsumed orbs and Heat4
  remained. Native commitment/roll originals are preserved.
- After launch: Water2/Fire1 launched1683ms. A fresh Circle around1718ms was
  ignored through Cast recovery2435ms; no roll was queued. Only the later fresh
  Circle2718ms rolled. The projectile missed while fired away from Pikeman;
  Heat persisted and no ordinary impact cue was invented.

After that completed fight, normal Retry began a separate PARTIAL diagnostic:
an X accepted120ms was cancelled by Dodge166ms before active frames. The next X
accepted1036ms was position1 and physically hit. Attack and school-switch inputs
inside the roll were ignored. Circle during that next X's active frames did not
queue; a later fresh2134ms press rolled. Two actual overlapping rolls lasted
approximately0.5s, retaining0.37s cooldown afterward. The far-left wall roll
5334–5717ms lasted the ordinary approximately0.4s while X stayed-557.924927 in
every captured before/during/after sample. Native texture transitioned Idle →
Dodge → Idle, without a false Walk handoff. See three dodge-wall originals.
EndP100/E190/unexpected0 is not another completed fight. Normalquit13 stopped.

The current-source focused fixture independently passed1,998checks/0failures/no
stderr after these replays. Physical analog input, complete immunity timing,
rendered recovery-only melee-cancel and left-viewport-clamp stress still require
separate evidence; controlled fixtures are not silently promoted to human play.
