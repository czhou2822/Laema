# Fire overnight X1/X4/X5 integration — October 21

User-authorized implementation of X1 R05, X4 R02 and X5 R04 from review commit
`3894773c003265878be3b9c99c2e6137a0540574`, artwork snapshot
`f277903b0f7f9995f9dc715a273427999af01111`.

Built-in imagegen produced transparent derivatives of the opaque masters. Fine
details can change; these are not byte-identical extractions. Technical assembly
uses complete-pose crops, one uniform scale per sequence with raster rounding,
and translation into 448px cells at anchor(224,400). The existing Fire prefix
selects the same offset(0,-124), root2/Sprite0.5, body profile and facing.

X1 uses all eight R05 poses. X4 contains R02 chamber/thrust/recoil, held over six
existing keys as0/0/0/1/2/2. X5 uses R04 poses1/2/3/4/6/7/9 at its existing seven
times. R04 poses5/8 remain reference only. R05 recovery and rejected R06 are not
adopted. X2/X3, all older PNGs and active Idle/Walk/Hurt/Cast remain unchanged.

Only three texture paths and X4 region values change. Every Animation UID,
frame-key time, marker, hitbox, move duration, Heat, lunge, direction, damage,
input and code remains unchanged by this task.

`manifest.json` records runtime hashes/selection. From repository root,
`docs/art/preparation/2026-10-21-fire-v01/` contains full generation prompts,
source alpha masters, exact registration, phase maps and light/dark composites.

Status: `AWAITING_USER_VALIDATION`. No Godot import/editor/runtime/build/tests
were run. Fine equipment/face continuity, material transitions, held X4 motion,
X5 recovery and existing artwork/query mismatches remain provisional. No final
artwork approval, physical alignment, runtime clearance or publication is claimed.
