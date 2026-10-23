HoMM3 AI ART AND ANIMATION PIPELINE RESEARCH — 23 October 2026

Start with report.html (standalone interactive report) or report.pdf (17 pages).
The HTML embeds its figures and animation frames; no server or internet is needed
to read it in a browser that allows local HTML/JavaScript. The PDF is the static
version. Primary-source references open external pages when clicked.

Actual experiments
  A: RealESRGAN_x4plus, plus nearest and Lanczos controls.
  B: Six unique reference-guided image edits via the available image tool, then
     original duplicate reuse to create ten output frame positions. Pose guidance
     was source-image + instructions; no hard ControlNet was run.
  C: One whole-sheet reference edit. Raw grid failed, including cell-crossing pikes.
All candidates are experimental. Production roster/assets were not modified.

All comparison animations use ten100ms dwells, matching the documented1s Pikeman
base attack duration only. Exact original executable per-frame timing remains
unverified. The external character-master packages were unavailable; B/C used an
explicitly labeled current generated idle proxy. Qwen/ControlNet/rigging/temporal
alternatives were researched or prepared, not executed.

Visual review
  comparison_all_methods.png — every experimental frame, same crop.
  comparison_keyframes.png — frames00,04,05.
  comparison_animated.webp/.gif — synchronized experimental animation.
  silhouette_overlay.webp — source/candidate opaque-mask correspondence.
  c-strip/grid_failure.png — raw sheet with fixed grid inspection overlay.
  visual_audit/ — original vs current Pikeman, Archer and Griffin comparisons.
  gameplay-preview/normalized/engine-comparison-animated.webp — actual staged
    Gym renderer, same candidate scales/anchor. Not a combat playtest.

Reproduction
  a-restoration/README.txt — actual pinned CPU inference and alpha policy.
  workflows/README.txt — proposed, unexecuted Qwen2511 and separate base-Qwen
    ControlNet examples; includes an untouched official ComfyUI graph.
  scripts/prepare_comparisons.py — rebuild B/C packaging, measured comparisons
    and previews from the supplied raw PNGs. Falls back to bundled raw files when
    original generation-service file paths are unavailable.
  scripts/build_report.py — rebuild standaloneHTML from evidence files.
  scripts/export_report.py — browser-check controls and exportPDF using local
    Chromium/Playwright; serves only the report on a temporary loopback port.
  gameplay-preview/README.md — isolated engine capture and version limitations.

Portable ZIP exclusions
  Downloaded model weights, Python virtual environment, original game's complete
  project copy/cache, redundant full-scene frame PNGs and preliminary captures
  are omitted. Download official weights using a-restoration/config.json and
  verify SHA256. Recreate the isolated project from the existing Laema checkout.
  Upstream model-card and Diffusers-source snapshots referenced in the workflow
  manifest can be downloaded by their recorded URLs; only the official workflow
  JSON and its license are bundled here. Original source pixels retain original
  provenance; generated candidates are reinterpretations, not recovered masters.

Evidence status
  report_checks.json — interactive controls, image load and PDF export QA.
  preview_checks.json — ten-frame duration readback.
  experiment_metrics.json — all methods; IoU is correspondence, not aesthetic.
  runtime-sheet-audit.json —32 atlases/236 populated frame positions.
  project_render_audit.md — code/file references and timing/registration audit.
  generation_manifest.json — prompts, reference inputs and unavailable-backend
    reproducibility limitations.

The report separates measured facts, visual observations and human art-direction
decisions. No candidate has final visual or gameplay approval.
