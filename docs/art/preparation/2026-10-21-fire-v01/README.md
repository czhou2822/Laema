# Overnight Fire artwork integration

The user's October 21 implementation request authorizes X1 R05, X4 R02 and X5
R04 integration. Status: `AWAITING_USER_VALIDATION`.

The four ZIPs at review commit `3894773c003265878be3b9c99c2e6137a0540574` contain
46 unique files. All archive/listed file hashes match. Their v03 source sheets
match the starting active textures; all original artwork is preserved.

Runtime files: `assets/prototype/player/fire_sword_shield_v01/overnight_v04/`
from repository root. The three native Animations now use the transparent sheets.
X1 uses eight poses; X4 maps R02 poses1/1/1/2/3/3 across six existing keys; X5 uses
R04 poses1/2/3/4/6/7/9 across seven existing keys. No new key times, code or
geometry. R04 poses5/8 remain reference only; R05/R06 are not adopted. X2/X3 stay.

- `sources/`: selected imagegen alpha masters copied without alteration.
- `generation-provenance.json`: tool, prompts, lineage and hashes.
- `registration.json`: exact crops/scales/anchors/translations. Components only
  locate full-pose crops; source alpha is preserved, not thresholded for output.
- `phase-map.json`: actual cell/pose selection at every unchanged native time.
- `fire_x1_review.png`, `fire_x4_review.png`, `fire_x5_review.png`: full cells
  on light/dark backgrounds with floor/anchor guides and unused study references.

Generated cutouts can differ from the opaque artwork. Registration uses one
scale per sequence with raster rounding, not independent pose fitting. Existing
presentation code owns runtime registration. No old artwork PNG or gameplay code was
overwritten; no Godot import/editor/runtime/build/tests, commit or push occurred.
User review remains for both facings, Heat, chaining, floor stability, held X4
motion, X5 recovery, nonattack transitions, interruption and retry. Equipment/
material drift and existing pose/query disagreement remain provisional.
