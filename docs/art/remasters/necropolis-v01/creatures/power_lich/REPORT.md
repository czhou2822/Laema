# Power Lich — complete worker asset pass

Status: **complete for parent QA**, not human animation acceptance.

All **74/74 distinct poses**, **18/18 original groups** and **120/120 source
timeline positions** are supplied. Missing poses/groups: zero. Worker review found
no unresolved blocking anatomy, clipping, source-order or fragment-assignment
defects in the final selected artwork. All 74 pose review hashes are fresh.

The selected set contains 74 newly drawn built-in-imagegen poses and zero reused
approved-idle poses. The approved master remains appearance reference only.
Nineteen built-in calls, exact prompts, returned metadata, reference hashes,
verbatim raw PNGs, failed ingestion attempts and selection history are retained.
No seed or model identifier was supplied by the tool; none was invented.

Outputs are under `assets/prototype/enemy/power_lich/remaster_v01/`: 36 source/mirror
group atlases, 148 selected pose PNGs, 240 source/mirror frame PNGs, 36 review GIFs,
18 source/candidate contacts, manifest and two SpriteFrames libraries. Each alias
keeps its own atlas. Group 7 equals 9; group 8 equals 10. All source repeats remain.
Cells remain 1024x768, four columns, anchor (512,512), source anchor (196,268),
uniform source scale 180/73, with original opaque-body bounds and no independent
pose normalization.

Repairs corrected walking orb colors and p002's free forearm; purple defensive
orbs/reflections; p058's dark opening orb; p027's arm foreshortening; p034/p036
camera; narrow front/back and low-strike silhouettes; green-gesture spacing; and
p070/p071 movement-start stature, arm and foot continuity. No original pixels,
master warping or idle placeholders fill different poses.

The first fragmented death page exposed a component-owner error: later crown/hand
pieces attached to an earlier pose. This was corrected using retained raw row
crops and whole rectangular fragment cells. All detached skull/coif, hand/bracer,
armor, robe and staff arrangements remain. The mixed fragment page rejected as
ambiguous was preserved. The final selection uses strict component separation
only where separate figures were unambiguous, otherwise transparent gutters.
No helper checks or dependencies were changed or installed.

The apparent brown backdrop in the single-pose tool display was checked by RGBA
sampling and alpha-matted preview: sampled background alpha is zero. Its RGB is
retained in transparent pixels; it is not visible sprite glow.

Verification order was complete `build power_lich`, successful `validate
power_lich`, `spriteframes power_lich`, then successful final `validate power_lich`.
Both validations verified 120 timeline cells with no errors. Independent worker
checks also verified all 120 native indexed crops, original/master hashes, raw
and isolated-source hashes, exact alias bytes and review-hash freshness.

Actual visual review covered every raw page, all 74 native-size and enlarged
source/candidate poses, every source-ordered group contact, and all 120 positions
in both source and mirrored GIFs through decoded static frame strips. Repaired
poses and every dependent group were rebuilt and revisited. This is static
asset/sequence inspection, **not real-time playback**. Rendered surface/detail
variation remains subject to parent/human motion review. Original timing is
unknown; GIFs and libraries use 10 fps for review only. No browser, Godot, actor
integration, gameplay, engine-import or human acceptance is claimed.

Evidence: `visual-review.json` (per-pose/group observations and final hashes),
`visual-observations.json`, `source-audit.json`, `validation-sequence.json`, and
the three `generation-provenance*.json` files. `asset_checks.py` regenerates only
this creature's mechanical review/evidence files. Publication belongs to parent.
