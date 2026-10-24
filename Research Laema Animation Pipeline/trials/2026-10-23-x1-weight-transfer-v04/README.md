# X1 weight transfer, braking and a steeper cut

The user judged v03's sword path better but its body stiff, requesting improved weight transfer and stopping, a more downward sword for power, the same review tool, and unchanged gameplay. These authorize this corrective candidate, not production acceptance.

Open [the moving review](review.html): **current game / previous shallow-path revision / new weight-transfer candidate**. The established controls retain native size, normal/slow speed, frame stepping, Heat0/100 and both facings. An optional “before front-foot alignment” view exposes the export correction rather than concealing the generator's foot drift.

## Motion changes

Sixteen new original joint targets use the existing16 frame times. The plan shifts the pelvis from15px behind center during rear-leg loading to18px ahead during the drive, then sinks and settles after the blade brakes. Front-knee bend, rear-leg extension/heel roll and a compact elbow participate in the stop. Torso/head and secondary cloth/hair are asked to settle after the initial blade brake. These are guide targets, not measured physical center of mass or proof of exact generated joint correspondence.

The maximum planned blade angle is52° down from forward, versus v03's30° target and the rejected original85° drop. The planned minimum tip clearance is about39px above the foot; the generated blade/hand do not reproduce every target exactly. The new drawings show greater knee/body compression and a steeper blade, but naturalness, power and stiffness remain human visual judgments. Neither a deeper crouch nor more drawings establishes a good stop by itself.

One built-in image-generation request produced16 figures from the [original guide](inputs/X1-weight-transfer-guide.png) and the same single static appearance master. Fourteen working cells are new. The existing guard is reused exactly at0 and .720s. No pre-existing animation sequence was imported, traced or retargeted. [Exact prompt](prompts/attempt01.txt), [raw output](raw/attempt01.png), [contract](contract.json), [generation provenance](generation-provenance.json), before/corrected exports and scripts remain preserved. Model revision and seed are not exposed; source processing is reproducible, generation is not deterministic from a recorded seed.

## Correction effort and remaining defects

The request took45.953s observed service wall time, not artist labor. There was one image request in this slice. No human pixel painting was performed. Active art direction, code setup and user review were not separately timed and must not be reported as zero labor.

The first generated sheet failed uniform row spacing: source foot-baseline intervals are327 /293.5 /284.5px. Extraction therefore reuses the connected-alpha decoder with one common scale/column pitch and four explicitly recorded row origins. It also required14 per-frame front-sole translations, ranging from−23 to+6px horizontally and−2 to+3px vertically. The exported forward-foot landmark has less than0.5px horizontal residual and zero vertical residual after integer translations.

This is an **additional registration repair**, unlike v03's group-only export. The fixed forward-boot ROI and bottom-four-row landmark are recoverable in [processing code](process_outputs.py) and [measurements](outputs/clips.json). It translates complete drawings without per-frame rescaling, body warping or anatomy repainting. The [before-alignment atlas](outputs/x1-weight-transfer-before-foot-registration.png) remains inspectable in the tool. Pinning one sole does not establish a physically planted whole foot, constant stance width, correct rear-toe contact, stable body volume or grip quality. Those remain visual limitations to assess. The raw sheet alone is not a clean production flipbook.

Generalizing multi-row extraction and forward-foot registration is reusable setup. Executing that export on this action took about0.22s machine time in the recorded pass; implementation, landmark choice and validation are separate labor. The14 recorded translations are actual correction operations, not a claim that manual art cleanup is finished. See [effort.csv](effort.csv).

## Verification boundary

Godot4.7.1 imported and graphically rendered the isolated comparison at fixed Heat0/100 and both facings,120 captures per condition. Source PNG bytes/native frame exposure are retained for the current-game baseline. Browser loading, synchronized stepping and the before-alignment toggle are checked separately. [Verification](evidence/verification.json) records the exact scope.

All candidates retain .720s at Heat0 / .480s at fixed Heat100, the .126–.5075s active window, .210s pacing split, original frame times and registration convention. No original game source, texture binding, query curve, body, input, queue, dodge, damage, Cast rule or3px lunge is changed. The standalone renderer does not simulate combat or that lunge. v02's previous game-copy integration evidence does not validate v04's new motion/contact correspondence; no v04 integrated combat run or human acceptance is claimed. 3D remains not tested.

Rebuild with `python process_outputs.py` then `python build_review.py`. Open `preview/project.godot` for the native comparison. Earlier trials remain unchanged as visual/evidence history; their status records may link forward to this candidate.
