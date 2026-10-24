# Laema: local Qwen versus built-in image generation

Status: all four raw outputs executed. [Initial user feedback](USER_REVIEW.md): little visible difference between the built-in and local Qwen examples; no preference or method acceptance recorded. Open [the comparison](review.html) and [executed results](RESULTS.md).

The user clarified that this research concerns creating better original art for Laema. HoMM3 was a technical benchmark, not the intended remastering deliverable. This isolated trial compares the installed local model with the assistant's built-in image generation using the original Laema concept references.

Two tests use the same ordered reference PNGs and exact positive prompt on both tools: a finished full-body illustration and a new combat anticipation pose. One first completed result per tool per test is retained. There is no artistic selection rerun or corrective painting before review. These requests develop an existing character treatment and do not choose a final outfit or weapon.

The references are Laema Open and the accepted-for-preservation hammer hero concept. Other approved character alternatives remain valid. Source approval roles, dimensions and SHA256 values are recorded in references.json. The inputs are exact file copies. See experiment-plan.json and prompts/ for the predeclared comparison and shared briefs.

The local side reuses the installed Qwen Image Edit 2511 FP8 mixed checkpoint, FP8 text encoder, Qwen VAE, ComfyUI and Python environment. No additional model download is required. Set LAEMA_AI_CACHE to that existing cache directory and run its Python interpreter:

```powershell
python run_comparison.py prepare
python run_comparison.py server
# In another terminal with the same cache environment:
python run_comparison.py run
# After all trials finish:
python run_comparison.py stop
python finalize_study.py
```

ComfyUI listens on loopback port8192, with offline mode and custom/partner API nodes disabled. The saved API graphs use seed42,40steps, CFG4, Euler/simple, denoise1 and a fresh1024x1536 latent. Character/reference conditioning is supplied by TextEncodeQwenImageEditPlus. This is original reference-guided generation; no HoMM3 poses, source alpha masks or source-sprite restoration are used.

The built-in side is executed through image_gen with the exact shared prompt and reference files. Its exact backend/model revision, seed, sampling and reference-resizing behavior are not exposed. Requested pixel dimensions are checked against actual output. Both methods' untouched raw images are retained. Whole-image display scaling and inspection crops will be separately identified; they do not repair either result.

This is a practical comparison of these two configured workflows on two first-result tasks. It is not a statistical model ranking or proof that either workflow is production-ready. The inputs are earlier generated concepts, so possible ancestry/style familiarity is a limitation. User visual review is required before accepting any result or method. Production assets and gameplay remain unchanged.

Workflow ancestry: [official ComfyUI Qwen2511 example](https://docs.comfy.org/tutorials/image/qwen/qwen-image-edit-2511). The installed quantized checkpoint and recorded API graph, rather than the page's current model defaults, define this executed trial.
