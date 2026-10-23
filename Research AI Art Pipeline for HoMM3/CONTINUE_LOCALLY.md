# Prompt for the local Codex session

Continue the HoMM3 AI art and animation pipeline research in this existing Laema
checkout. Our objective is a faithful 1:1 high-resolution remaster of the original
creature animations. The purpose is to validate better art quality and fidelity,
not generate the full roster faster. Do not replace production assets yet.

Read the repository's applicable `AGENTS.md` and inspect Git status first. Preserve
unrelated local work. Then read `Research AI Art Pipeline for HoMM3/README.md`, the
research report, `project_render_audit.md`, `visual_audit/observations.md`,
`inputs/source_contract.json`, and `workflows/README.txt`. Resolve all research
paths relative to this checkout; `/workspace/...` paths in saved provenance refer
to the earlier cloud machine, not this computer.

Carry forward these established results without rerunning them unnecessarily:

- The representative group is Castle Pikeman, `CPKMAN`, group 12/block 11: ten
  frames, six unique drawings. Preserve mapping `[0,1,2,3,4,5,4,3,2,1]`, original
  poses, canvas offsets and anchors. The existing generated repaint has incorrect
  recovery correspondence despite its correct frame count.
- Actual RealESRGAN_x4plus restoration and nearest/Lanczos controls are supplied.
  Source alpha was preserved exactly. Surface detail improved, while inferred
  detail cannot be called recovered historical detail.
- The earlier frame-edit experiment used an opaque image-tool backend with source
  pose/reference images and instructions. It was not Qwen or hard ControlNet.
  It added detail but changed silhouettes and identity details.
- Whole-strip editing crossed cell boundaries and changed layout and repeated
  poses. Do not adopt whole-sheet prompting as the default production workflow.
- No Qwen/ControlNet, EbSynth/TokenFlow or rigging experiment has been run. The
  supplied local workflows are proposed and syntax checked only.
- The one-second base attack duration is documented, but original per-frame dwell
  is not verified. Ten 100 ms dwells are a labeled comparison assumption. Do not
  claim exact original timing until it is recovered from authoritative evidence.

Now inspect this computer's GPU/VRAM, RAM, disk capacity, installed image tools and
available models. Locate the complete `castle-creature-assets-v01` and
`pikeman-flipbook-assets-v02` packages, approved high-resolution character masters,
and previous generation prompts/graphs if present. Do not treat the included
generated idle proxy as an approved master. If something remains unavailable,
state it and continue useful independent work.

Run a controlled local frame-editing trial on the same Pikeman source group if
hardware and tools permit. Start from the pinned Qwen-Image-Edit-2511 workflow or
another demonstrably suitable implementation. Use the source pose as structural
authority and a faithful approved master as appearance authority. Test stronger
edge/lineart/mask guidance where a compatible implementation exists. The provided
InstantX Union example pairs with base `Qwen/Qwen-Image`; do not silently attach
it to 2511 or 2.1. A text instruction or fixed seed is not a hard pose constraint.
Qwen-Image-2.1 has different architecture and model-use licensing from 2511.

Keep raw outputs before alpha enforcement, resizing or alignment. Use one fixed
documented group transform; do not hide drift with per-frame recentering. Reuse
exact repeated source poses. Record model revisions, workflow/node versions,
prompts, seeds, dimensions, hardware, duration, rejection counts and actual manual
cleanup effort. Keep each trial in a new isolated research subfolder. Do not
overwrite the published baseline evidence.

Compare against the supplied restoration baseline and existing artwork using
all-frame sheets, synchronized previews, silhouette/landmark overlays and actual
gameplay-scale rendering where available. Evaluate historical fidelity, identity,
anatomy, motion correspondence, pike/hand/foot continuity, alpha/shadows, placement
and timing. Separate measured failures from aesthetic judgments requiring my
review. If controlled editing still needs extensive repairs, evaluate approved
keyframe propagation or deterministic 2D/3D pose-matched rendering as alternatives.

Finish with actual candidate assets, reproducible workflows, visual comparisons,
clear executed-versus-researched status, unresolved limits and a revised production
recommendation. Ask for my art review before claiming that any method is accepted.
Do not modify the full creature roster, production gameplay or production assets,
and do not publish subsequent local work unless I request it.
