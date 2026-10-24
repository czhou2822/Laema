"""Copy an untouched image_gen result and record its exposed execution details."""
from pathlib import Path
import argparse
import hashlib
import json
import shutil
from PIL import Image

HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument("task", choices=["hero", "action"])
parser.add_argument("source", type=Path)
parser.add_argument("started_utc")
parser.add_argument("tool_call_seconds", type=float)
args = parser.parse_args()
destination = HERE / "builtin/raw" / (args.task + ".png")
record = destination.with_suffix(".json")
if destination.exists() or record.exists():
    raise RuntimeError("A completed built-in trial already exists; refusing to overwrite.")
destination.parent.mkdir(parents=True, exist_ok=True)
shutil.copy2(args.source, destination)
with destination.open("rb") as handle:
    digest = hashlib.file_digest(handle, "sha256").hexdigest()
with Image.open(destination) as image:
    dimensions, mode = list(image.size), image.mode
references = json.loads((HERE / "references.json").read_text(encoding="utf-8"))
entry = {
    "status": "executed", "task": args.task, "tool": "built-in image_gen",
    "source_generated_file": "generated_images/" + "/".join(args.source.parts[-2:]),
    "started_utc": args.started_utc, "tool_call_seconds": args.tool_call_seconds,
    "timing_limit": "Observed tool-call wall time; server execution, queue and transfer are not separately exposed.",
    "raw_file": destination.relative_to(HERE).as_posix(), "raw_sha256": digest,
    "dimensions": dimensions, "mode": mode, "requested_dimensions": [1024,1536],
    "prompt_file": f"prompts/{args.task}.txt", "referenced_image_paths": [item["input"] for item in references],
    "transparent_background": False, "model_revision": "not exposed", "seed": "not exposed",
    "sampling_parameters": "not exposed", "reference_preprocessing": "not exposed",
    "manual_art_cleanup_seconds": 0, "art_acceptance": "pending user review",
    "postprocessing": "Untouched file copy only. No image editing or alpha replacement."
}
record.write_text(json.dumps(entry, indent=2), encoding="utf-8")
print(json.dumps({"task": args.task, "dimensions": dimensions, "sha256": digest}))
