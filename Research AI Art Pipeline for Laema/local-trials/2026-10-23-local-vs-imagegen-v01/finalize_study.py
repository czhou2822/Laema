"""Write factual execution results after all four raw outputs exist."""
from pathlib import Path
import json
from build_review import main as build

HERE = Path(__file__).resolve().parent


def gpu_peak(record):
    return max(int(s["whole_gpu_memory_mib_util_percent"].split(",")[0]) for s in record["gpu_samples"])


def main():
    rows = []
    total_local = 0
    total_builtin = 0
    peaks = []
    for task, name in [("hero", "Finished character"), ("action", "New action pose")]:
        local = json.loads((HERE / f"local/raw/{task}.json").read_text(encoding="utf-8"))
        builtin = json.loads((HERE / f"builtin/raw/{task}.json").read_text(encoding="utf-8"))
        total_local += local["submission_to_save_seconds"]
        total_builtin += builtin["tool_call_seconds"]
        peaks.append(gpu_peak(local))
        rows.append(f"| {name} | {local['submission_to_save_seconds']:.1f}s | {builtin['tool_call_seconds']:.1f}s | 0s / 0s |")
    report = """# Executed comparison: original Laema art

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

Both tools received the exact same two unmodified1024x1536 reference PNGs in the same order and the exact same positive prompt for each task. The delivered outputs are1024x1536. Only one completed image per task per tool was generated; all four first results are retained, with no artistic selection retries. Neither method received the other's output.

Visible prompt-following observation: both local Qwen images look toward the left despite the rightward brief; the built-in images look right. No mirroring, pose fitting or corrective generation was applied. This is a review observation, not a numerical quality score or model-wide failure rate.

Local: Qwen Image Edit2511 FP8 mixed, FP8-scaled Qwen2.5-VL encoder and Qwen VAE, ComfyUI0.42.0 at commit`d07dff4565ea9804277fff8cdfa0c817e08c3d44`, Torch2.9.1+cu128, RTX4090. All three model SHA256 digests were reverified this round before inference.40 steps, seed42, CFG4, Euler/simple, shift3.1, CFGNorm1.0, denoise1, fresh EmptySD3LatentImage1024x1536, TextEncodeQwenImageEditPlus reference conditioning. No ControlNet, Lightning LoRA, source mask or generative correction. The stable memory policy uses static loading, async offload disabled,32-node cache and6GB VRAM reserve. The existing runtime and model files were reused without additional downloads. The cu128-compatible PyTorch fallback executes the installed model; optimized Comfy-Kitchen CUDA kernels remain disabled.

Built-in: image_gen with the matching prompts and explicit local reference paths, transparent_background=false. The tool's exact backend model/version, seed, sampler and reference preprocessing are unexposed. Records identify the actual generated files without inventing those parameters. The tool delivered the requested resolution.

The sandboxed local startup did not become available; client attempts encountered socket-access/refused-connection errors before any generation request was accepted. The server and client were relaunched with the required GPU/loopback access. This startup issue produced no raw artwork and was not an artistic reroll. server-sandbox-attempt.log preserves that attempt; server.log and the successful execution histories record the working run.

## Observed effort and duration

| Task | Local request through saved output | Built-in tool-call wall time | Manual art repair: local / built-in |
| --- | ---: | ---: | ---: |
""" + "\n".join(rows) + f"""

Successful local request time totals {total_local:.1f}s ({total_local/60:.2f} minutes); built-in observed tool-call time totals {total_builtin:.1f}s. The largest sampled whole-GPU allocation was {max(peaks):,} MiB. GPU samples were taken about every 5 seconds and include other allocations; this is not a per-process Torch peak.

The local first request includes model loading; the second can benefit from caching. Server startup, previous installation/downloads, failed startup attempts and review-page preparation are excluded. Built-in queue/compute/transfer times cannot be separated. These are end-to-end observations of the actual workflows, not controlled GPU speed benchmarks. No monetary or electricity cost was measured.

Manual painting, anatomy repair, edge cleanup, background extraction, palette adjustment and per-character registration performed before review:0seconds on every output. Original PNGs are untouched. Contact sheets only resize the entire image with Lanczos for presentation. Time to an accepted production asset remains unmeasured; zero intervention is not a zero-cleanup estimate.

## Interpretation limits

These four images let the user compare these two configured workflows on this existing character and two briefs. Two first outputs do not establish either model's statistical reliability, best possible result or suitability for animation. Local precision is quantized; the built-in backend is opaque. The references are prior generated concepts, so common ancestry/style familiarity may favor a similar rendering. No new models were tuned to either image and no pose/quality measurements are substituted for human preference.

Laema Open is one of three approved Laema outfit alternatives. The hammer concept was accepted for preservation, not locked as the final production weapon. Using those references here does not change their approval scope. Other saved references remain valid. Source files remain byte-identical, production assets/gameplay were not replaced, and no animation/Godot/runtime acceptance is claimed.

## Reproduction and evidence

See [README](README.md), [predeclared experiment plan](experiment-plan.json), [shared prompts](prompts.json), [reference provenance and hashes](references.json), [verified model lock](model-lock.json), [local hero API graph](local/workflows/hero.api.json), [local action API graph](local/workflows/action.api.json), [node definitions](local/workflows/node-definitions.json), per-image JSON execution records beside each raw PNG, [verification](verification.json), and [artifact hashes](artifact-manifest.json).

Workflow ancestry: [official ComfyUI Qwen2511 example](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511). The pinned installed checkpoint and saved graph define what ran here; this reference is not evidence that the two tools use identical internal processing.
"""
    for old, new in {
        "unmodified1024": "unmodified 1024", "are1024": "are 1024", "Edit2511": "Edit 2511",
        "Qwen2.5": "Qwen 2.5", "ComfyUI0.42": "ComfyUI 0.42", "Torch2.9": "Torch 2.9",
        "RTX4090": "RTX 4090", "inference.40": "inference. 40", "seed42": "seed 42", "CFG4": "CFG 4",
        "shift3.1": "shift 3.1", "CFGNorm1.0": "CFGNorm 1.0", "denoise1": "denoise 1",
        "LatentImage1024": "LatentImage 1024", "disabled,32": "disabled, 32", "and6GB": "and 6 GB",
        "review:0seconds": "review: 0 seconds",
        "ComfyUI Qwen2511": "ComfyUI Qwen 2511",
    }.items():
        report = report.replace(old, new)
    (HERE / "RESULTS.md").write_text(report, encoding="utf-8")
    readme = (HERE / "README.md").read_text(encoding="utf-8")
    readme = readme.replace("Status: matched trial prepared; generation and user review pending.", "Status: all four raw outputs executed; user visual review pending. Open [the comparison](review.html) and [executed results](RESULTS.md).")
    (HERE / "README.md").write_text(readme, encoding="utf-8")
    build()


if __name__ == "__main__":
    main()
