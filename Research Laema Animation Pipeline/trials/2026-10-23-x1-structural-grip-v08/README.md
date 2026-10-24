# Structural wrist/arm pose proof

The user first said v06's close-up grip connection read better, then reported that v05 and v06 had no difference. Both are preserved: v06 changed757 RGB pixels but held the wrist silhouette and motion fixed. That cosmetic proof did not resolve the requested structural wrist-to-sword relationship. Planned propagation in v07 stopped before any image requests.

Open [the current review](review.html). It starts frozen at key7 (.158s at Heat0), with4× native-pixel crops, current-game comparison and an inspection-only blink between v05 and v08. The blink holds the pose; it is not action timing. The source game remains preferred. This is one structural pose proposal, not a corrected animation.

## Structural change

The original guide treats the hand as one endpoint from which the blade also extends, without an explicit wrist/palm/knuckle/handle construction. [This new original guide](inputs/original-grip-construction.png) separates elbow, wrist, palm, knuckle axis, grip center, guard and pommel. It asks for a higher elbow, forearm descending into the wrist, and palm/fingers wrapping obliquely across the hilt. A hand point plus a blade angle was insufficient to constrain that relationship.

The [raw edit](raw/attempt01.png) changes the arm's visible geometry. After normalization,486 alpha pixels differ in the inspected arm region and15,137 RGBA pixels differ across the whole pose. The forearm now visibly slopes down into the grip rather than retaining the old profile. Counts establish a change, not anatomical correctness or a quality win. The generated pose does not reproduce every target coordinate exactly. It also drifts in body/equipment details, including the sword presentation; those remain defects and are not accepted changes.

The proposal is registered by matching one foreground height and one forward-sole landmark. The shared proposal scale is about0.24206, followed by a−6px horizontal translation. The old wrist alpha is deliberately not imposed. Fifteen other keys are source-exact in the optional context atlas; only key7 is replaced by this full re-render. Appearance/transition pops and old grips remain unresolved, so contextual playback must not be treated as a solved moving grip.

## Provenance and effort

One built-in image-generation request used the original R&D v05 pose and this original code-authored guide. The [exact prompt](prompts/attempt01.txt), input hashes, raw result, [contract](contract.json), [registration](outputs/registration.json), [effort](effort.csv) and [verification](evidence/verification.json) are retained. Request service wall time was40.199s. No human pixel painting was performed. Active guide authoring, reference inspection, normalization, review-tool work and user review were not separately timed; do not present the service wait as total production labor.

General static instruction text was consulted: [Fencing Victoria's sabre workbook](https://fencingvictoria.org.au/wp-content/uploads/2022/07/sabre.pdf) and [Sydney Sabre's grip discussion](https://sydneysabre.com/2015/06/22/this-is-how-to-hold-your-sabre-redux/). These concern sporting sabre, not an authoritative Laema style. No external photo, drawing or animation was supplied to generation or traced. An unrelated wrist-lock photo and unavailable image/PDF views were not usable visual references. The construction coordinates are original proposals.3D has not been tested; this is a2D construction test, not a3D/rig success.

## Verification boundary

Godot4.7.1 imports this isolated preview and saves the same still pose at Heat0/100 and both facings. These are static rendering checks, not continuous-motion, integrated-combat or human-grip validation. The browser comparison/blink is checked separately.

Game source, installed animation resources, hit queries, body, damage, input, queue, Dodge, lunge and Cast are untouched. Source/action/key clocks retain .720/.480s, the .126–.5075s active interval and .210s pacing split. The standalone renderer does not simulate combat or the3px lunge. The new blade path is not approved against native queries. No complete strip correction, human art acceptance, production readiness, commit, push or live publication is claimed.

Rebuild with `python process_proof.py` then `python build_review.py`; open `preview/project.godot` for the isolated proof. Review this wrist/arm construction before propagating it across poses.
