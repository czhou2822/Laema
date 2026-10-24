# Executed local Qwen results

**No method is accepted. User visual review is pending.** Seventeen Qwen outputs were executed on the RTX 4090, plus one separate built-in image-tool scout. This extends the earlier report; its baseline evidence was not overwritten.

## What ran

The runtime was ComfyUI 0.42.0, commit`d07dff4565ea9804277fff8cdfa0c817e08c3d44`, Torch 2.9.1+cu128 and Python 3.12.14. The visual checkpoint was official Comfy FP8-mixed Qwen-Image-Edit-2511, with the matching FP8-scaled Qwen 2.5-VL encoder and Qwen VAE. All three SHA256 values passed. Exact model revisions, hashes, package versions and graph ancestry are in [model_lock.json](model_lock.json), [runtime_lock.json](runtime_lock.json), [inference dependency lock](requirements-inference-lock.txt), [full environment freeze](requirements_freeze.txt) and [workflow-contract.json](workflow-contract.json).

This is a quantized Comfy execution, distinct from the earlier unexecuted BF16 Diffusers proposal. The newer optimized Comfy-Kitchen CUDA backend was disabled undercu128; PyTorch attention and dynamic disk-backed VRAM loading were used. The optional workflow-gallery media package was omitted. Every required API node was available and the saved graphs actually executed; see [runtime-node-checks.json](runtime-node-checks.json), [runtime-status.json](runtime-status.json) and [server.log](server.log).

All tests used40 steps, CFG 4, seed 42, Euler/simple, AuraFlow shift 3.1, CFGNorm 1, the same source group and the recovered appearance master. No Lightning LoRA, previous generated frame, temporal model or ControlNet was used. Raw RGB PNGs were saved before normalization, alpha enforcement or alignment.

| Configuration | Executed drawings | Result |
|---|---|---|
| Reference-only,608×416, denoise 1 | Ready00 and thrust05 | Detailed reinterpretations; changed pose, grip spacing and/or registration, with added shadows |
| Reference-only,1216×832, denoise 1 | Ready00 | Upright master-like appearance, but recentered/enlarged figure, shifted feet and pike at canvas edge |
| Restored input, no mask, denoise 0.35 | Thrust05 | Also retains the restored pose closely; useful paired control |
| Restored input + latent noise mask, denoise 0.35 | All six unique drawings | Complete ten-frame candidate; conservative changes and retained source pixel contours |
| Same mask, denoise 0.65 | Thrust05 | More surface change, still close to source; one frame only |
| Same mask, denoise 1 | All six unique drawings | Complete ten-frame trial; stronger thrust detail, but incomplete/misplaced figures in early poses |

The mask is the original opaque silhouette, dilated4 pixels at the4x guide resolution, applied with `SetLatentNoiseMask`. It restricts latent noise; it is not a ControlNet and does not certify internal anatomy. The larger scout uses one exact2x whole-canvas transform before latent encoding. No per-frame fitting or recentering was applied to any saved comparison.

Total server execution time was **56.57 minutes** across 17 outputs, excluding installation, downloads, comparisons and human work. The largest whole-GPU sample was **23,678MiB**. Samples were taken about every2s and include other allocations; this is not an exact per-process Torch peak. Individual execution and submission-to-save durations are in [execution_summary.json](execution_summary.json).

## Runtime recovery and limits

Two pose03 attempts were interrupted without producing an image: the dynamic loader stalled before its first sampler step, and a static loader with2GB reserve showed the same symptom. The successful retry used static loading, async offload disabled, a32-node cache and6GB VRAM reserve. The API graph, model, prompt, seed and sampling parameters were byte-identical across the retry. Successful poses03/04 used this memory profile; the earlier outputs used the original dynamic profile. See [runtime-policy-by-run.json](runtime-policy-by-run.json) and [interrupted-attempt records](masked-full/attempts/). Observed interrupted durations were at least667s and207s; these are operational overhead, not art rejection counts or artist time. Loader policy/cache state and available resources varied, so the measured times are not causal speed comparisons. Numerical equivalence across memory profiles was not separately tested.

## What the measurements establish

Both sets of six unique outputs were assembled into exactly ten frames with mapping`[0,1,2,3,4,5,4,3,2,1]`. The900×800 full frames preserve2x source offsets and anchor(392,536). All four repeated pairs are exact. The3600×2400 four-column atlas has ten exact occupied cells and two transparent padding cells. Every output alpha sample equals the supplied nearest2x source, including64/128-alpha shadows with original RGB. [validation.json](validation.json), [atlas-readback.json](atlas-readback.json) and [animation.json](masked/source-alpha/animation.json) record these checks.

These are **imposed-alpha derivatives**. Their silhouette IoU1 is a packaging constraint, not proof that the generator followed anatomy. Raw Qwen images are RGB, so raw foreground diagnostics estimate segmentation from corner-background color. They can include baked shadows or miss gray object pixels. Their IoU is not equivalent to the earlier RGBA edit's alpha metric, and neither is an aesthetic score.

The complete low-strength group's mean interior RGB change from its restored input is10.67/255. In the paired thrust test, masked0.35 gives9.24/255, unmasked0.35 gives11.27, masked0.65 gives19.19 and masked1 gives45.74. These quantify edit magnitude, not improved art quality. The no-mask control shows that initialization/low edit strength substantially contributes to pose retention; the mask alone cannot receive credit for that result.

Static inspection found the source arrangements recognizable across the completed low-strength group, with no conclusive gross extra-limb defect. Source pixel steps remain, and the full high-resolution master detail is not reproduced. Higher-strength thrust changes helmet, face and armor treatment; the brighter helmet differs from the brown-bronze master. Fine anatomy, identity consistency and whether these changes improve the historical appearance require the user's review. See [observations.json](observations.json).

The unrestricted608 scouts failed the strict structural gate2/2; the larger ready scout failed fixed registration1/1. These are configuration/sample results, not model-wide failure rates. No off-record seed selection or replacement occurred. The low-strength group is a conservative review candidate. The completed full-strength trial fails structural fidelity in early poses; no method is accepted.

The full-strength raw ready image leaves approximately 48.6% of originally opaque source pixels close to the background color, versus 0.82% in its input. This RGB diagnostic is not an anatomical segmentation, but static inspection confirms incomplete figure parts at poses 00–02. [The alpha-metric example](alpha_metric_trap.png) shows how imposing the original mask still gives IoU1 over an incomplete drawing.

## Review files

- [Synchronized viewer](review.html), [all frames](comparison_all_frames.png), [animated comparison](comparison_sync.webp).
- [Ready scouts](scouts_pose_00.png), [full-thrust scouts](scouts_pose_05.png), [all-frame source landmark overlays](landmarks_all_frames.png).
- [Low-strength PNGs and atlas](masked/source-alpha/) and [full-strength trial PNGs and atlas](masked-full/source-alpha/), with untouched model results under each method's `raw/` directory and executed graphs under `workflows/`.
- [Actual final Gym renderer comparison](engine-final-complete/comparison_detail05.png), [synchronized engine preview](engine-final-complete/comparison_sync.webp) and [capture report](engine-final-complete/capture-report.json). These are staged appearance renders, not combat playtests or user validation.

The equal100ms dwells remain a comparison assumption. Exact original executable frame timing is unresolved. Source-mask outlines also retain the original pixel steps; alpha/offset success must not be mistaken for a complete high-resolution remaster.

## Cleanup and revised recommendation

The separate built-in scout used the recovered master and still changed the full-thrust silhouette: RGBA overlap0.63076 under fixed canvas normalization. Its raw result, prompt, overlays and partial weapon repair are retained in [builtin-scout/](builtin-scout/).

The measured analyst intervention window was96.948s, including inspection, source-region selection, repair-script implementation and tool execution. Automatic export took about0.06s. Manual painting was0s. The partial weapon fallback did not fix internal body/hand differences. **Time to an artist-accepted frame remains unmeasured**; no roster cost or accepted-frame productivity estimate follows from these numbers.

Keep the supplied restoration as the fidelity control. Review both complete motions and the raw failure examples. The full-strength thrust alone was misleading as a selection basis.  Completing the stronger group exposed missing or misplaced parts at poses 00–02 that the thrust still did not reveal. Source-matched approved structural keyframes, contour/hand/weapon cleanup and consistent shadow rules remain the next quality gate. The recovered standing prototype master is an appearance reference, not that approved pose set.

Compatible base-Qwen + InstantX Union, approved-keyframe propagation and calibrated2D/3D rendering remain **researched alternatives, not executed results**. The [InstantX model card](https://huggingface.co/InstantX/Qwen-Image-ControlNet-Union) pairs its model with base `Qwen/Qwen-Image`; it was not attached to2511. The [official2511 workflow](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511) is the source template for these adapted API graphs. No conclusion here establishes that a rig or propagation will look better without its own test.

No production replacement or roster expansion is recommended from this evidence alone. Please review fidelity, materials, hands, weapon continuity and the synchronized motion before choosing a method or next trial.

The source-keyframe/propagation and deterministic-rendering assessment is [ALTERNATIVES.md](ALTERNATIVES.md). These remain unexecuted proposals.
