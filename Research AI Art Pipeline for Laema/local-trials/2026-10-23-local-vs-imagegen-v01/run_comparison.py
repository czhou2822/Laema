"""Isolated, first-result comparison using an already installed ComfyUI cache.

Set LAEMA_AI_CACHE (or the older LAEMA_HOMM3_CACHE). No model downloads.
Commands: prepare, server, run, status, stop. Never overwrites a completed trial.
"""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PORT = 8192
URL = f"http://127.0.0.1:{PORT}"
CACHE_VALUE = os.environ.get("LAEMA_AI_CACHE", os.environ.get("LAEMA_HOMM3_CACHE"))
CACHE = Path(CACHE_VALUE).resolve() if CACHE_VALUE else None
REFERENCE_FILES = [
    ("docs/art/references/2026-10-18-character-concepts/laema-r5-01-laema-open.png", "01-laema-open.png", "Character identity and costume authority; one of three approved Laema alternatives, not a final outfit selection."),
    ("docs/art/references/2026-10-19-laema-hammer-accepted/01-laema-hammer-hero.png", "02-laema-hammer.png", "Accepted-for-preservation hammer concept and material reference; not a final production weapon lock."),
]
COMMON = (
    "Use case: stylized-concept. Asset type: finished original fantasy game character illustration. "
    "Create one new illustration of our original character Laema. Image 1 is the authority for her "
    "character identity and costume. Image 2 supplies the hammer construction and materials. "
    "Preserve the same recognizable young adult woman's face, curious alert expression, platinum-white "
    "high ponytail, fitted blue sleeveless waistcoat, cream rolled-sleeve shirt, red waist sash, "
    "brown leather cross-body strap and pouch, brown trousers, fingerless gloves and tall brown boots. "
    "Preserve the hammer's broad double-ended geometric head, dark inset panels, steel plates, bronze "
    "faceted fittings and narrow orange-red luminous seams. Improve the finish through confident painted "
    "shapes, fine modeled-volume shading, convincing cloth/leather/metal separation, clear anatomy and "
    "expressive facial drawing. Keep restrained base colors and concentrated metal highlights. "
    "Use a polished painterly fantasy illustration finish, without coarse pixel blocks or plastic-looking skin. "
    "Composition: a single full-body figure on a plain medium neutral-gray studio background, soft upper-left "
    "lighting and a subtle contact shadow. Portrait 2:3 canvas, requested 1024 by 1536 pixels. Keep the "
    "whole ponytail, both hands, both boots and the complete hammer comfortably inside the frame. "
    "No text, labels, border, extra person, new equipment, scenery, attack effects or motion blur. "
)
TASKS = {
    "hero": {
        "title": "Finished character illustration",
        "prompt": COMMON + "Pose: an upright three-quarter hero stance looking toward the right, feet planted naturally, "
        "shoulders relaxed, holding the hammer diagonally across the front of her body with two anatomically "
        "clear hands on the shaft. Make a fresh finished illustration while retaining the supplied design.",
    },
    "action": {
        "title": "New action key pose",
        "prompt": COMMON + "Pose: an original grounded combat anticipation pose facing toward the right in three-quarter "
        "view, knees bent, weight visibly supported over the rear leg, front foot stepping to the right. "
        "Both hands grip separated positions on the shaft; the hammer is held low in front of her, ready "
        "to swing. Keep the face readable and separate the limbs and hammer in silhouette. This must be a "
        "new pose, not a copy of either reference's standing pose. Avoid extreme foreshortening.",
    },
}


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False), encoding="utf-8")


def sha(path):
    with path.open("rb") as handle:
        return hashlib.file_digest(handle, "sha256").hexdigest()


def require_cache():
    if CACHE is None or not (CACHE / ".runtime/ComfyUI/main.py").is_file():
        raise RuntimeError("Set LAEMA_AI_CACHE to the existing homm3-cache installation.")


def request(path, data=None):
    body = json.dumps(data).encode() if data is not None else None
    req = urllib.request.Request(URL + path, data=body, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        raise RuntimeError(error.read().decode()) from error


def graph(task):
    return {
        "1": {"class_type": "UNETLoader", "inputs": {"unet_name": "qwen_image_edit_2511_fp8mixed.safetensors", "weight_dtype": "default"}},
        "2": {"class_type": "CLIPLoader", "inputs": {"clip_name": "qwen_2.5_vl_7b_fp8_scaled.safetensors", "type": "qwen_image", "device": "default"}},
        "3": {"class_type": "VAELoader", "inputs": {"vae_name": "qwen_image_vae.safetensors"}},
        "4": {"class_type": "LoadImage", "inputs": {"image": "01-laema-open.png"}},
        "5": {"class_type": "LoadImage", "inputs": {"image": "02-laema-hammer.png"}},
        "6": {"class_type": "TextEncodeQwenImageEditPlus", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "prompt": TASKS[task]["prompt"], "image1": ["4", 0], "image2": ["5", 0]}},
        "7": {"class_type": "TextEncodeQwenImageEditPlus", "inputs": {"clip": ["2", 0], "vae": ["3", 0], "prompt": " ", "image1": ["4", 0], "image2": ["5", 0]}},
        "8": {"class_type": "ModelSamplingAuraFlow", "inputs": {"model": ["1", 0], "shift": 3.1}},
        "9": {"class_type": "CFGNorm", "inputs": {"model": ["8", 0], "strength": 1.0, "pre_cfg": False}},
        "10": {"class_type": "EmptySD3LatentImage", "inputs": {"width": 1024, "height": 1536, "batch_size": 1}},
        "11": {"class_type": "KSampler", "inputs": {"model": ["9", 0], "positive": ["6", 0], "negative": ["7", 0], "latent_image": ["10", 0], "seed": 42, "steps": 40, "cfg": 4.0, "sampler_name": "euler", "scheduler": "simple", "denoise": 1.0}},
        "12": {"class_type": "VAEDecode", "inputs": {"samples": ["11", 0], "vae": ["3", 0]}},
        "13": {"class_type": "SaveImage", "inputs": {"images": ["12", 0], "filename_prefix": f"laema-comparison-v01/{task}"}},
    }


def prepare():
    from PIL import Image
    require_cache()
    references = []
    for source, target, role in REFERENCE_FILES:
        src, dst = ROOT / source, HERE / "inputs" / target
        dst.parent.mkdir(parents=True, exist_ok=True)
        if dst.exists() and sha(dst) != sha(src):
            raise RuntimeError(f"Existing input differs: {dst}")
        if not dst.exists():
            shutil.copy2(src, dst)
        with Image.open(dst) as image:
            dimensions, mode = list(image.size), image.mode
        references.append({"source": source, "input": "inputs/" + target, "role": role, "sha256": sha(dst), "dimensions": dimensions, "mode": mode})
    save(HERE / "references.json", references)
    save(HERE / "prompts.json", TASKS)
    for task in TASKS:
        (HERE / "prompts").mkdir(exist_ok=True)
        (HERE / "prompts" / (task + ".txt")).write_text(TASKS[task]["prompt"], encoding="utf-8")
        save(HERE / "local/workflows" / (task + ".api.json"), graph(task))
    previous = ROOT / "Research AI Art Pipeline for HoMM3/local-trials/2026-10-23-pikeman-v01"
    lock = json.loads((previous / "model_lock.json").read_text(encoding="utf-8"))
    verified = []
    for item in lock["models"]:
        filename = Path(item["file"]).name
        category = "diffusion_models" if "diffusion_models" in item["file"] else ("text_encoders" if "text_encoders" in item["file"] else "vae")
        path = CACHE / ".models" / category / filename
        actual = sha(path)
        if actual != item["sha256"]:
            raise RuntimeError(f"Model hash mismatch: {filename}")
        verified.append({key: value for key, value in item.items() if key != "destination"} | {"sha256_verified_this_round": actual})
    save(HERE / "model-lock.json", {"comfyui_commit": lock["comfyui_commit"], "torch": lock["torch"], "precision": lock["precision"], "models": verified})
    save(HERE / "experiment-plan.json", {
        "planned_before_generation": True, "tasks": list(TASKS), "outputs_per_tool_per_task": 1,
        "tools": ["Local Qwen Image Edit 2511 FP8 mixed via installed ComfyUI", "Built-in image_gen"],
        "shared": "Exact same two reference PNGs, ordered roles, positive prompt and requested 1024x1536 canvas; one fresh result per task, no artistic selection reruns.",
        "local_settings": {"seed": 42, "steps": 40, "cfg": 4, "sampler": "euler", "scheduler": "simple", "denoise": 1, "latent": "EmptySD3LatentImage", "shift": 3.1},
        "memory_policy": {"dynamic_vram": False, "async_offload": False, "cache_lru_nodes": 32, "reserve_vram_gb": 6},
        "builtin_limitations": "Exact model/version, seed, sampler and internal reference resizing are not exposed by the tool. Requested size may differ from delivered size.",
        "review": ["Overall artistic finish", "Recognizable Laema identity", "Face and expression", "Hands and anatomy", "Costume and hammer consistency", "New-pose clarity", "Readability when reduced"],
        "cleanup": "Keep raw results unchanged. No manual painting, anatomy repair, alpha extraction, generative correction, color grading, or per-character fitting before review. Only equal-canvas display and whole-image thumbnails are comparison derivatives.",
        "limits": "Two first-result tasks compare these configured workflows, not every capability of either model. Existing generated reference ancestry may favor a similar rendering. No model winner, production art, weapon/outfit lock, animation or runtime acceptance is established. Human review remains pending.",
    })
    status = subprocess.check_output(["git", "status", "--short"], cwd=ROOT, text=True)
    save(HERE / "initial-git-state.json", {"head": subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(), "status": status})
    print("Prepared exact references, two shared prompts, graphs, model hashes and predeclared comparison plan.", flush=True)


def server():
    require_cache()
    config = HERE / "model_paths.local.yaml"
    config.write_text("research:\n  base_path: " + (CACHE / ".models").as_posix() + "\n  diffusion_models: diffusion_models\n  text_encoders: text_encoders\n  vae: vae\n", encoding="utf-8")
    python = CACHE / ".runtime/venv/Scripts/python.exe"
    args = [str(python), "-u", str(CACHE / ".runtime/ComfyUI/main.py"), "--listen", "127.0.0.1", "--port", str(PORT),
            "--extra-model-paths-config", str(config), "--input-directory", str(HERE / "inputs"),
            "--output-directory", str(HERE / "local/server-output"), "--disable-all-custom-nodes", "--disable-api-nodes", "--offline",
            "--preview-method", "none", "--cache-lru", "32", "--bf16-vae", "--reserve-vram", "6", "--disable-dynamic-vram", "--disable-async-offload"]
    env = os.environ.copy()
    env.update(HF_HUB_OFFLINE="1", TRANSFORMERS_OFFLINE="1", PYTHONUTF8="1")
    with (HERE / "server.log").open("w", encoding="utf-8") as log:
        process = subprocess.Popen(args, cwd=CACHE / ".runtime/ComfyUI", env=env, stdout=log, stderr=subprocess.STDOUT,
                                   creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0))
        save(HERE / "server.local.json", {"pid": process.pid, "port": PORT, "argv": args})
        print(f"Research ComfyUI PID {process.pid}; localhost:{PORT}; server.log", flush=True)
        code = process.wait()
        print(f"Server exited {code}", flush=True)


def run():
    from PIL import Image
    startup = time.monotonic()
    while True:
        try:
            definitions = request("/object_info")
            break
        except urllib.error.URLError:
            if time.monotonic() - startup > 90:
                raise
            print("Waiting for this comparison's local ComfyUI server...", flush=True)
            time.sleep(3)
    for task in TASKS:
        out = HERE / "local/raw" / (task + ".png")
        record = HERE / "local/raw" / (task + ".json")
        if out.exists() or record.exists():
            print(f"SKIP existing {task}", flush=True)
            continue
        workflow = graph(task)
        for node in workflow.values():
            if node["class_type"] not in definitions:
                raise RuntimeError("Missing node: " + node["class_type"])
        save(HERE / "local/workflows/node-definitions.json", {node["class_type"]: definitions[node["class_type"]] for node in workflow.values()})
        started = time.monotonic()
        started_utc = datetime.datetime.now(datetime.timezone.utc).isoformat()
        response = request("/prompt", {"prompt": workflow, "client_id": "laema-local-vs-imagegen-v01"})
        prompt_id = response["prompt_id"]
        save(HERE / "local" / (task + "-submission.json"), {"prompt_id": prompt_id, "started_utc": started_utc, "response": response})
        print(f"START {task}: {prompt_id}", flush=True)
        samples, last_progress = [], started
        while True:
            history = request("/history/" + prompt_id)
            gpu = subprocess.check_output(["nvidia-smi", "--query-gpu=memory.used,utilization.gpu", "--format=csv,noheader,nounits"], text=True).strip()
            samples.append({"elapsed_seconds": round(time.monotonic() - started, 2), "whole_gpu_memory_mib_util_percent": gpu})
            if prompt_id in history:
                item = history[prompt_id]
                if item["status"]["status_str"] != "success":
                    save(HERE / "local/attempts" / (task + "-failed.json"), {"status": "failed", "history": item, "gpu_samples": samples})
                    raise RuntimeError(str(item["status"]))
                saved = item["outputs"]["13"]["images"][0]
                src = HERE / "local/server-output" / saved["subfolder"] / saved["filename"]
                out.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(src, out)
                with Image.open(out) as image:
                    dimensions, mode = list(image.size), image.mode
                save(record, {"status": "executed", "task": task, "tool": "local Qwen Image Edit 2511 FP8 mixed", "started_utc": started_utc,
                              "submission_to_save_seconds": round(time.monotonic() - started, 3), "raw_sha256": sha(out), "dimensions": dimensions,
                              "mode": mode, "prompt_file": f"prompts/{task}.txt", "workflow": f"local/workflows/{task}.api.json", "history": item,
                              "gpu_samples": samples, "gpu_sample_interval_seconds": 5, "manual_art_cleanup_seconds": 0, "art_acceptance": "pending user review"})
                print(f"DONE {task}: {time.monotonic() - started:.1f}s; {dimensions}", flush=True)
                break
            if time.monotonic() - last_progress >= 30:
                save(HERE / "local/progress.json", {"task": task, "prompt_id": prompt_id, "elapsed_seconds": round(time.monotonic() - started), "gpu": gpu})
                print(f"RUNNING {task}: {time.monotonic() - started:.0f}s, GPU {gpu}", flush=True)
                last_progress = time.monotonic()
            time.sleep(5)


def stop():
    import psutil
    entry = json.loads((HERE / "server.local.json").read_text(encoding="utf-8"))
    process = psutil.Process(entry["pid"])
    if process.cmdline() != entry["argv"]:
        raise RuntimeError("Recorded PID no longer matches this comparison server; refusing to stop it.")
    children = process.children(recursive=True)
    for child in children:
        child.terminate()
    process.terminate()
    gone, alive = psutil.wait_procs([process] + children, timeout=10)
    if alive:
        raise RuntimeError("Some comparison processes did not terminate.")
    save(HERE / "server-stop.json", {"status": "stopped", "pid": entry["pid"], "command_line_verified": True,
                                      "stopped_utc": datetime.datetime.now(datetime.timezone.utc).isoformat()})
    print("Stopped this comparison's verified ComfyUI process.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=["prepare", "server", "run", "status", "stop"])
    action = parser.parse_args().action
    if action == "prepare": prepare()
    elif action == "server": server()
    elif action == "run": run()
    elif action == "status": print(json.dumps(request("/queue"), indent=2))
    elif action == "stop": stop()
