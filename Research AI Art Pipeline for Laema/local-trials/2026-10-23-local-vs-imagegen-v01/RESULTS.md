# Executed comparison: original Laema art

Status: all four first outputs executed; human visual review pending. No model or method is accepted.

The user requested a practical comparison of the installed local model and the assistant's image generation using Laema, to judge which produces better artwork. The two tasks are a finished character illustration and a new action anticipation pose. Existing character and equipment concepts supply the design; there is no HoMM3 source-pose or alpha constraint in this experiment.

## Review

Open [review.html](review.html). A is local Qwen; B is built-in image generation. The page offers equal whole-canvas scaling, native original-file links, reduced previews, shared references, exact prompts, optional tool-name hiding and downloadable user review notes. Review the overall finish, face/identity, hands/anatomy, costume/hammer consistency and clarity of the new pose. The page does not select a winner or send feedback automatically.

Automatic opening of the local HTML was blocked by the in-app browser's protocol policy. Static comparison sheets and original PNGs are provided for review instead. The HTML remains saved for the user to open manually; browser interaction was not verified in this round.

- [Finished-character contact sheet](comparison-hero.jpg)
- [New-action contact sheet](comparison-action.jpg)
- [Local raw hero](local/raw/hero.png) and [local raw action](local/raw/action.png)
- [Built-in raw hero](builtin/raw/hero.png) and [built-in raw action](builtin/raw/action.png)

## What actually ran

Both tools received the exact same two unmodified 1024x1536 reference PNGs in the same order and the exact same positive prompt for each task. The delivered outputs are 1024x1536. Only one completed image per task per tool was generated; all four first results are retained, with no artistic selection retries. Neither method received the other's output.

Visible prompt-following observation: both local Qwen images look toward the left despite the rightward brief; the built-in images look right. No mirroring, pose fitting or corrective generation was applied. This is a review observation, not a numerical quality score or model-wide failure rate.

Local: Qwen Image Edit 2511 FP8 mixed, FP8-scaled Qwen 2.5-VL encoder and Qwen VAE, ComfyUI 0.42.0 at commit`d07dff4565ea9804277fff8cdfa0c817e08c3d44`, Torch 2.9.1+cu128, RTX 4090. All three model SHA256 digests were reverified this round before inference. 40 steps, seed 42, CFG 4, Euler/simple, shift 3.1, CFGNorm 1.0, denoise 1, fresh EmptySD3LatentImage 1024x1536, TextEncodeQwenImageEditPlus reference conditioning. No ControlNet, Lightning LoRA, source mask or generative correction. The stable memory policy uses static loading, async offload disabled, 32-node cache and 6 GB VRAM reserve. The existing runtime and model files were reused without additional downloads. The cu128-compatible PyTorch fallback executes the installed model; optimized Comfy-Kitchen CUDA kernels remain disabled.

Built-in: image_gen with the matching prompts and explicit local reference paths, transparent_background=false. The tool's exact backend model/version, seed, sampler and reference preprocessing are unexposed. Records identify the actual generated files without inventing those parameters. The tool delivered the requested resolution.

The sandboxed local startup did not become available; client attempts encountered socket-access/refused-connection errors before any generation request was accepted. The server and client were relaunched with the required GPU/loopback access. This startup issue produced no raw artwork and was not an artistic reroll. server-sandbox-attempt.log preserves that attempt; server.log and the successful execution histories record the working run.

## Observed effort and duration

| Task | Local request through saved output | Built-in tool-call wall time | Manual art repair: local / built-in |
| --- | ---: | ---: | ---: |
| Finished character | 344.9s | 30.8s | 0s / 0s |
| New action pose | 334.7s | 33.2s | 0s / 0s |

Successful local request time totals 679.6s (11.33 minutes); built-in observed tool-call time totals 64.0s. The largest sampled whole-GPU allocation was 20,138 MiB. GPU samples were taken about every 5 seconds and include other allocations; this is not a per-process Torch peak.

The local first request includes model loading; the second can benefit from caching. Server startup, previous installation/downloads, failed startup attempts and review-page preparation are excluded. Built-in queue/compute/transfer times cannot be separated. These are end-to-end observations of the actual workflows, not controlled GPU speed benchmarks. No monetary or electricity cost was measured.

Manual painting, anatomy repair, edge cleanup, background extraction, palette adjustment and per-character registration performed before review: 0 seconds on every output. Original PNGs are untouched. Contact sheets only resize the entire image with Lanczos for presentation. Time to an accepted production asset remains unmeasured; zero intervention is not a zero-cleanup estimate.

## Interpretation limits

These four images let the user compare these two configured workflows on this existing character and two briefs. Two first outputs do not establish either model's statistical reliability, best possible result or suitability for animation. Local precision is quantized; the built-in backend is opaque. The references are prior generated concepts, so common ancestry/style familiarity may favor a similar rendering. No new models were tuned to either image and no pose/quality measurements are substituted for human preference.

Laema Open is one of three approved Laema outfit alternatives. The hammer concept was accepted for preservation, not locked as the final production weapon. Using those references here does not change their approval scope. Other saved references remain valid. Source files remain byte-identical, production assets/gameplay were not replaced, and no animation/Godot/runtime acceptance is claimed.

## Reproduction and evidence

See [README](README.md), [predeclared experiment plan](experiment-plan.json), [shared prompts](prompts.json), [reference provenance and hashes](references.json), [verified model lock](model-lock.json), [local hero API graph](local/workflows/hero.api.json), [local action API graph](local/workflows/action.api.json), [node definitions](local/workflows/node-definitions.json), per-image JSON execution records beside each raw PNG, [verification](verification.json), and [artifact hashes](artifact-manifest.json).

Workflow ancestry: [official ComfyUI Qwen 2511 example](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511). The pinned installed checkpoint and saved graph define what ran here; this reference is not evidence that the two tools use identical internal processing.
