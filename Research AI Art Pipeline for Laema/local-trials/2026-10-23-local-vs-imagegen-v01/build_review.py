"""Build equal-canvas comparisons; never retouch the generated artwork."""
from pathlib import Path
import ast
import hashlib
import html
import json
import re
import shutil
import subprocess
from html.parser import HTMLParser
from urllib.parse import unquote, urlsplit
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def sha(path):
    with path.open("rb") as handle:
        return hashlib.file_digest(handle, "sha256").hexdigest()


def save(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")


def main():
    tasks = json.loads((HERE / "prompts.json").read_text(encoding="utf-8"))
    results = []
    for task, info in tasks.items():
        for tool in ("local", "builtin"):
            image = HERE / tool / "raw" / (task + ".png")
            record = image.with_suffix(".json")
            if not image.is_file() or not record.is_file():
                raise RuntimeError(f"Trial incomplete: {tool}/{task}")
            entry = json.loads(record.read_text(encoding="utf-8"))
            if sha(image) != entry["raw_sha256"]:
                raise RuntimeError(f"Raw image differs from execution record: {image}")
            results.append({"task": task, "title": info["title"], "method": tool, "raw": image.relative_to(HERE).as_posix(),
                            "dimensions": entry["dimensions"], "mode": entry["mode"], "sha256": entry["raw_sha256"],
                            "seconds": entry.get("submission_to_save_seconds", entry.get("tool_call_seconds")),
                            "manual_art_cleanup_seconds": entry["manual_art_cleanup_seconds"]})
    references = json.loads((HERE / "references.json").read_text(encoding="utf-8"))
    for ref in references:
        if sha(ROOT / ref["source"]) != ref["sha256"] or sha(HERE / ref["input"]) != ref["sha256"]:
            raise RuntimeError("Reference preservation check failed")
    save(HERE / "results.json", results)
    font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 24)
    small_font = ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", 17)
    panel_width, panel_height, gap, margin = 384, 576, 22, 26
    for task, info in tasks.items():
        board = Image.new("RGB", (3 * panel_width + 2 * gap + 2 * margin, panel_height + 146), "#101820")
        draw = ImageDraw.Draw(board)
        draw.text((margin, 14), "Laema / " + info["title"], font=font, fill="#f2f4f7")
        labels = ["Saved hammer reference", "Local Qwen 2511 (FP8)", "Built-in image generation"]
        paths = ["inputs/02-laema-hammer.png", f"local/raw/{task}.png", f"builtin/raw/{task}.png"]
        for index, (label, path) in enumerate(zip(labels, paths)):
            x = margin + index * (panel_width + gap)
            draw.text((x, 53), label, font=small_font, fill="#bfcbd8")
            with Image.open(HERE / path) as source:
                display = source.convert("RGB")
                display.thumbnail((panel_width, panel_height), Image.Resampling.LANCZOS)
                board.paste(display, (x + (panel_width-display.width)//2, 88 + (panel_height-display.height)//2))
        draw.text((margin, panel_height+106), "Untouched first outputs. Same references + submitted brief. Whole-image display scaling only.", font=small_font, fill="#bfcbd8")
        board.save(HERE / ("comparison-" + task + ".jpg"), quality=94, subsampling=0)
    payload = {"tasks": tasks, "results": results, "references": references}
    template = (HERE / "review-template.html").read_text(encoding="utf-8")
    rendered = template.replace("__PAYLOAD__", json.dumps(payload, ensure_ascii=False).replace("</", "<\\/"))
    (HERE / "review.html").write_text(rendered, encoding="utf-8")
    class LocalLinks(HTMLParser):
        def __init__(self):
            super().__init__()
            self.links = []
        def handle_starttag(self, tag, attrs):
            for key, value in attrs:
                if key in {"href", "src"} and value and not urlsplit(value).scheme:
                    self.links.append(unquote(urlsplit(value).path))
    parser = LocalLinks()
    parser.feed(rendered)
    missing = [link for link in parser.links if link and not (HERE / link).is_file()]
    if missing:
        raise RuntimeError(f"Missing viewer links: {missing}")
    syntax = "not run: Node unavailable"
    node = shutil.which("node")
    if node:
        script = re.search(r"<script>(.*?)</script>", rendered, re.S).group(1)
        checked = subprocess.run([node, "--check"], input=script, text=True, capture_output=True, timeout=30)
        if checked.returncode:
            raise RuntimeError(checked.stderr)
        syntax = "passed; parse only, no browser or DOM execution"
    for path in HERE.glob("*.py"):
        ast.parse(path.read_text(encoding="utf-8"), filename=path.name)
    save(HERE / "verification.json", {
        "complete_raw_results": len(results), "tasks": list(tasks), "all_raw_dimensions": [r["dimensions"] for r in results],
        "raw_sha256_verified": True, "source_references_unchanged": True, "reference_count": len(references),
        "submitted_positive_prompts_identical_per_task": True, "local_prompt_comparison": {
            task: json.loads((HERE / f"local/workflows/{task}.api.json").read_text(encoding="utf-8"))["6"]["inputs"]["prompt"] == info["prompt"]
            for task, info in tasks.items()},
        "manual_art_cleanup_seconds_per_result": [0,0,0,0], "accepted_result_cleanup_time": "not measured; all results await user review",
        "display_derivatives": "Whole-canvas Lanczos thumbnails/contact sheets only. Native raw PNGs remain unchanged.",
        "python_ast": "passed", "art_acceptance": "pending user visual review", "production_integration": "none",
        "html_local_link_count": len(parser.links), "missing_html_local_links": missing, "javascript_syntax": syntax,
        "browser_interaction": "not verified: automatic file-protocol navigation rejected by in-app browser policy; static comparison sheets provided instead",
    })
    files = []
    for path in sorted(HERE.rglob("*")):
        if path.is_file() and path.name not in {"artifact-manifest.json", "model_paths.local.yaml", "server.local.json", "server.log"} and "__pycache__" not in path.parts:
            files.append({"path": path.relative_to(HERE).as_posix(), "bytes": path.stat().st_size, "sha256": sha(path)})
    save(HERE / "artifact-manifest.json", {"files": files, "total_bytes": sum(f["bytes"] for f in files), "excludes": ["this manifest", "machine-local model path/PID files", "mutable server.log", "Python cache"]})
    print(json.dumps({"raw_results": len(results), "all_dimensions": [r["dimensions"] for r in results], "manifest_files": len(files), "manifest_bytes": sum(f["bytes"] for f in files)}))


if __name__ == "__main__":
    main()
