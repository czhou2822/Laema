# Local alternatives for original Laema artwork

The user asked why Qwen was chosen, what alternatives exist, and to try the practical alternatives for comparison. Qwen was named in the supplied continuation brief and had a compatible native reference-editing workflow on the RTX4090. It was a first test, not the outcome of a model survey or proof of superiority.

This round tests the existing Qwen workflow, FLUX.2 Klein4B Base and Distilled, LongCat Image Edit, and a separately labelled Z-Image Turbo text-only path. Two first outputs per configuration are planned: a finished full-body character and a new action pose. All new results are isolated here. No hosted image-generation call is used for this survey.

The four reference-capable configurations use the **same single saved Laema-with-hammer hero reference** and exact positive prompts. This permits a comparable native single-reference LongCat workflow. The earlier two-reference Qwen/built-in experiment remains separate evidence. Z-Image receives the same written identity/pose description without image input; its character fidelity is not represented as equivalent reference conditioning.

Native settings differ by model: Qwen40steps/CFG4; FLUX Base20steps/CFG5; FLUX Distilled4steps/CFG1; LongCat50steps/CFG4.5; Z-Image8steps/CFG1. Each saved API graph is the execution authority. Requested canvas1024x1536, seed42. One completed result per cell, no artistic rerolls or repair before review. Native internal image encoding and preprocessing differ. See experiment-plan.json and prompts.json.

The survey reuses the installed ComfyUI runtime and downloads41.73GB of public, ungated official model files into the existing cache outside OneDrive. Each repository revision and SHA256 is pinned before execution. Current repository metadata marks FLUX.2 Klein9B, FLUX3 Klein and FLUX.1 Kontext as gated; their weights are not downloaded or run. They require user-controlled repository access and acceptance of the applicable terms. This is a bounded survey of practical families, not every checkpoint, LoRA, paid service or model ever released.

No Hugging Face authentication was configured when checked. access-boundary.json records that presence check without credential values. After full model hashes were reverified,43,966,202,964bytes of redundant download ranges/quarantined staging were removed. All seven model files and all artwork were retained; see cache-cleanup.json.

One downloader restart command failed during shell quoting and briefly started duplicate range writers. All owned helpers were stopped.40 temporary ranges touched during the overlap were quarantined outside the source tree, a single-writer lock was added, and downloads resumed with48workers. All completed weights must pass their pinned full-file SHA256 before use. See download-resume.json and download-quarantine.json. This was a download/setup issue; it produced no artwork and no artistic selection retry.

The survey runner initially stopped after both Qwen outputs because it tried to decode the empty successful response from ComfyUI's /free endpoint as JSON. Empty responses are now handled. The completed Qwen files were preserved; this did not rerun or select artwork.

Run with the existing cache environment and its Python interpreter:

```powershell
python prepare_models.py
python survey.py prepare
python survey.py run qwen flux-base flux-fast longcat z-image
```

The reusable local ComfyUI app must be running at http://127.0.0.1:8188. See ../../ComfyUI-Laema/README.md. Run skips completed outputs. Executed graphs and per-image histories, durations, GPU samples and hashes are saved beside each method. Human art review is separate from a successful generation or workflow setup.

Sources: [FLUX.2 Klein native workflows](https://docs.comfy.org/tutorials/flux/flux-2-klein), [official FLUX4B model](https://huggingface.co/black-forest-labs/FLUX.2-klein-4B), [LongCat original](https://huggingface.co/meituan-longcat/LongCat-Image-Edit), [official LongCat package](https://huggingface.co/Comfy-Org/LongCat-Image), [Z-Image Turbo](https://huggingface.co/Tongyi-MAI/Z-Image-Turbo), [FLUX3 native workflow/access reference](https://docs.comfy.org/tutorials/flux/flux-3-klein). official-source-index.json pins the actual template repository revision read for this round. Model cards' capability claims are research context, not results from this computer.
