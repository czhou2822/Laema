# One-pose wrist-to-hilt proof

Later outcome: the user said the close-up grip connection read better, then said v05/v06 had no difference. The wrist pose and motion had indeed been preserved; this was not a structural correction. Further cosmetic propagation stopped before generation. Continue from [v08](../2026-10-23-x1-structural-grip-v08/README.md), with both feedback statements retained in human-review.json. v06 is not an approved moving grip or a resolved wrist-pose fix.

The user rejected v05's wrist-to-sword relationship despite its changed blade angle. Current-game preference remains the last overall quality judgment. This slice isolates one grip construction before propagating another correction across a strip.

Open [the same review tool](review.html). It starts paused at key7 (.158s at Heat0), showing v05 and a local one-key repair at native size and4× native pixels. The motion context below compares current game / unchanged v05 / v06 proof. Only key7 differs; fifteen other keys are unchanged and unapproved. This is not a corrected whole animation.

## What was actually made

The source is a128×96 crop at(196,218) from original R&D v05 key7, enlarged8× onto the review matte for a local built-in image-generation edit. The [exact prompt](prompts/attempt01.txt) asks for a coherent forearm/wrist/fist/hilt, curled fingers and thumb around a continuous straight handle while retaining blade angle and pose. No current-game animation sequence or outside motion was used as generation input. The opaque matte belongs only to the diagnostic crop; original sprite alpha remains preserved.

The [raw AI proof](raw/attempt01.png) is1448×1086. It was downsampled to the source128×96 crop resolution. A recorded−1/+1px local placement and a bounded feathered RGB mask transfer the proposed wrist/fist/hilt drawing into one isolated research key. The AI's high-resolution face/body redraw is not transferred. Source alpha stays exact; source pixels outside the mask and the protected forward sword/guard region x≥267 remain exact. The [mask](outputs/key07-rgb-repair-mask.png) and [repair record](outputs/repair-record.json) are recoverable. The repair changes757 RGB pixels. Fifteen other atlas keys remain byte-identical as RGBA cells.

The [before](outputs/grip-before-4x.png) and [after](outputs/grip-after-4x.png) comparisons are the actual exported native pixels enlarged4×, not the higher-resolution proposal presented as final sprite quality. The [generated detail](outputs/grip-generated-detail.png) is separate. A more readable finger wrap does not establish correct wrist anatomy or a successful grip in motion. Holding the original silhouette and blade fixed deliberately limits this proof: it is not a solved forearm/wrist-pose redesign.

One image request took20.823s observed service wall time. One manually chosen repair mask and one local alignment were used; their active setup/assessment time was not separately timed. No human pixel painting occurred. Mechanical export took about0.24s in the recorded pass, separate from setup, image wait and review. See [effort.csv](effort.csv). This is a local AI-edit/compositing experiment, not a successful polished rig/hybrid trial or a production workflow winner.

## Verification and limits

[Verification](evidence/verification.json) records source/alpha/mask preservation and native proof rendering. Static Godot snapshots are deliberately separate from new motion validation. The main game, gameplay resources, current animation bindings and v05 source files are untouched. Action/key times, .720/.480s duration, .126–.5075s active window, .210s pacing split, actor/foot registration, lunge, damage, inputs, queues, Dodge and Cast remain unchanged. No contact adaptation or integrated combat run occurs.

Human grip acceptance is still required before treating this drawing as a reference for other poses. There is no production readiness or whole-strip correction claim. The source v05 body/arm/motion problems remain open. 3D remains not tested.

Rebuild with `python process_proof.py` and `python build_review.py`; open `preview/project.godot` for this partial one-key proof in Godot. The root .gdignore continues to exclude all R&D from the main project.
