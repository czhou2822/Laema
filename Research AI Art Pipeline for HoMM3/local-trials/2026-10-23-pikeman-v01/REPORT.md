# Local Pikeman pipeline continuation — 23 October 2026

**Status: controlled local experiments complete; user visual review pending. No method accepted.**

The low-strength treatment retains source arrangements but adds limited detail. The stronger treatment produces incomplete figures in early poses.

The final local execution report is [QWEN_RESULTS.md](QWEN_RESULTS.md):17 actual Qwen outputs, two complete ten-frame trial exports, mask/size/strength comparisons, measured time and final renderer evidence. This folder is a new isolated trial. The supplied research evidence and production assets are preserved. Nothing has been committed, pushed or published by this operation.

The scope remains `CPKMAN`, group12/block11, ten positions with six unique drawings, mapped `[0,1,2,3,4,5,4,3,2,1]`. The native450×400 canvas, source offsets and anchor(196,268) remain authoritative. All review playback uses the provisional ten100ms dwells. Exact original executable dwell remains unresolved.

## Recovered inputs and prior workflow

Both missing complete packages were located under the local Art scratch root recorded in [package-inventory.json](package-inventory.json):

- `castle-creature-assets-v01`: 7,422 files,1,251,527,073 bytes.
- `pikeman-flipbook-assets-v02`: 94 files,7,605,812 bytes.
- The earlier Pikeman v01 and static-master packages are also present.

The untouched master generation is1024×1536, and the processed full-resolution Pikeman master is770×1485, with an exact copied original and a mechanically mirrored right-facing reference in [inputs/](inputs/). It is the previously approved **prototype character appearance**, rather than a historical high-resolution ground truth or an accepted faithful-remaster method. The earlier cropped idle proxy is not substituted for this master.

Recovered prompts, source-guide records, export scripts, v02 handoff and the recoil repair prompt are copied byte-for-byte under [recovered-evidence/](recovered-evidence/), with hashes in [preservation.json](preservation.json). They establish built-in image-tool whole-strip generation followed by deterministic registration, pose replacement and targeted recoil repair. The v02 handoff explicitly replaces attack0/9 with ready and redistributes the penultimate recovery pose. This explains its departure from the original repeat mapping. No original Qwen/ControlNet/ComfyUI generation graph was found in those records. Unavailable backend versions/seeds cannot be reconstructed from a saved prompt.

## Hardware and actual execution

This computer has an NVIDIA RTX 4090,24,564MiB reported VRAM,31.1GiB physical RAM and about297GiB free disk at the initial audit. The initial bundled Python 3.12.14 had Pillow/NumPy but no Torch, Diffusers, Transformers, OpenCV or model weights in the inspected locations. [hardware.json](hardware.json) records the measurements and search scope. Godot 4.7.1 is installed locally. No Blender, ComfyUI installation or diffusion checkpoint was found in that scoped inventory; this is not a claim about every location on the computer.

The isolated Qwen runtime/models were installed and used in a task cache outside OneDrive. See [model_lock.json](model_lock.json), [runtime_lock.json](runtime_lock.json), bootstrap logs and [bootstrap.py](bootstrap.py). Full BF1620B weights alone would exceed24GB VRAM. The selected experiment uses the official Comfy FP8-mixed 2511 visual model and matching FP8-scaled Qwen 2.5-VL encoder, with exact revisions and SHA256 values. This precision choice is a distinct experiment, not an equivalent execution of the earlier BF16 proposal.

| Experiment | Current evidence | Acceptance |
|---|---|---|
| Supplied Real-ESRGAN / nearest / Lanczos | Reused, not rerun | Baseline only |
| Recovered-master built-in reference edit | One full-thrust scout executed; raw RGBA retained | Fails strict pose preservation |
| Source-alpha + weapon fallback | Executed on scout; separate derivatives | Partial repair; still unaccepted |
| Qwen 2511 reference-only editing | Executed; see QWEN_RESULTS.md | User review pending |
| Qwen 2511 restoration-initialized mask editing | Executed; see QWEN_RESULTS.md | User review pending |
| InstantX Union on base Qwen | Researched / earlier proposal only; not executed | No claim of compatibility with2511 |
| EbSynth propagation / deterministic rig | Not executed | Requires source-matched approved keyframes/rig |

## New executed scout and bounded cleanup

The built-in tool received the original full-thrust pose and recovered master, prioritizing original silhouette, head/hands/feet, weapon endpoints and canvas placement. [prompt.txt](builtin-scout/prompt.txt) and [generation.json](builtin-scout/generation.json) retain the request and hashes. The tool exposes no backend revision, seed, sampler or inference hardware. This was not local4090 inference, Qwen or ControlNet.

The raw result is1485×1059 rather than584×416. A single whole-canvas normalization to292×208, without subject fitting or recentering, gives opaque silhouette IoU**0.63076**, and opaque bottom displacement−2px against the source. IoU is shape/placement correspondence, not an aesthetic score. The source and normalized output plus source landmark overlays are retained in [the scout folder](builtin-scout/).

Applying exact source alpha forces silhouette agreement but cuts through the shifted shaft and body pixels. A bounded analyst intervention selects two source-coordinate rectangles and restores the supplied restoration's weapon pixels there. The shaft repairs are visible, while the altered body/hand pose remains. This is a failed structural scout, not proof that a differently configured editor will fail.

The measured intervention window was**96.948s**, covering analyst inspection, source-region selection, script implementation and tool execution. Automatic export took about0.06s. Manual painting time was0s, and time to an artist-accepted frame remains **unmeasured**. These are different quantities; do not extrapolate96.948s to a roster-production estimate. [cleanup-effort.json](builtin-scout/cleanup-effort.json) and [measure_scout.py](builtin-scout/measure_scout.py) preserve the actual operation.

Review [the five-way scout comparison](builtin-scout/comparison_frame05.png), [raw overlay](builtin-scout/silhouette_overlay_05.png) and [expected source landmark overlays](builtin-scout/landmarks_05.png). One scout was rejected for strict source structure; a sample of one is not a model-wide rejection rate. No additional seeds were selected off-record.

## Actual renderer comparison

The final-complete phase added 55 successful captures covering both Qwen sequences and the remaining scouts. The three local phases contain 33, 46 and 55 captures: 134 staged render images in total. All are 1280×720 and nonblank. See [final comparison](engine-final-complete/comparison_detail05.png), [synchronized final preview](engine-final-complete/comparison_sync.webp) and [final capture report](engine-final-complete/capture-report.json). These remain appearance evidence only.

The local Godot 4.7.1 OpenGL Compatibility renderer produced33 saved1280×720 captures from an isolated132.7MB source copy. Both actors settled on the floor, then the fixture froze; ten current-repaint, nearest and restoration positions plus the scout's three full-thrust variants were rendered at one actor/camera position. Candidate crop anchor(92,192), offset(54,−88) and scale180/148 are constant across the group. No per-frame correction is applied. [engine-source-lock.json](engine-source-lock.json) records copied source hashes.

See [engine-baseline-gpu/comparison_detail05.png](engine-baseline-gpu/comparison_detail05.png), [synchronized baseline preview](engine-baseline-gpu/comparison_sync.webp) and [capture report](engine-baseline-gpu/capture-report.json). These are actual scene renders, not background composites. They are **staged appearance evidence**, not ordinary input/combat playtests, both-facing/contact verification or user acceptance. Compatibility differs from the project's ForwardPlus renderer. The initial restricted renderer crashed before output; the subsequent GPU-enabled run saved all33 captures successfully. Shutdown resource-leak warnings remain recorded. The old cloud4.6.3 UI error was not observed in this4.7.1 capture.

## Reproduction and review

Use [README.md](README.md) for commands. The synchronized [review.html](review.html) has common scrubbing, source-silhouette overlays, anchor guides, alternate mattes and a gameplay-size option. Full sheets, lossless raw results and workflow JSON remain separately recoverable. Its current panels include only completed sequences; incomplete scouts are not filled with invented frames.

The current production recommendation is to keep the restoration as a source-fidelity control and review the completed mask-guided trial and the complete stronger trial before selecting a generation method. A source mask can enforce geometry while concealing wrong anatomy or material. Do not expand to the roster from a detailed still or a forced-alpha score. Because the stronger trial loses or shifts figure parts, obtain source-pose-matched approved keyframes before propagation or a calibrated rig trial; the recovered standing prototype master alone is not that set of keyframes.

**Your visual review is required before any method is accepted.** Historical fidelity, costume/identity, anatomy, hands, weapon continuity, shadows, edge treatment, floor placement and motion must be judged together. Original dwell, accepted-frame artist cost, both-facing behavior and final art acceptance remain open.

Primary implementation sources: [official2511 workflow](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511), [Comfy model package](https://huggingface.co/Comfy-Org/Qwen-Image-Edit), [InstantX base-Qwen Union model](https://huggingface.co/InstantX/Qwen-Image-ControlNet-Union). Saved revisions/hashes, rather than a mutable current page, identify executed model bytes.

The post-test feasibility assessment for source-matched keyframe propagation and deterministic pose rendering is [ALTERNATIVES.md](ALTERNATIVES.md). These remain proposals, not executed alternatives.
