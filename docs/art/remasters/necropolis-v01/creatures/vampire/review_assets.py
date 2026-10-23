"""Mechanical Vampire-only comparison layouts; never paints or alters sprite art."""

import argparse
import importlib.util
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
ASSET = ROOT / "assets/prototype/enemy/vampire/remaster_v01"
spec = importlib.util.spec_from_file_location("vampire_readonly_packing", ROOT / "tools/art/necropolis_remaster.py")
packing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(packing)
creature = packing.creature("vampire")
poses = packing.posemap(creature)


def pose_comparisons(ids):
    directory = REPORT / "review-images"
    directory.mkdir(parents=True, exist_ok=True)
    outputs = []
    for offset in range(0, len(ids), 4):
        batch = ids[offset:offset + 4]
        sheet = Image.new("RGB", (1680, 376 * len(batch)), (23, 36, 49))
        draw = ImageDraw.Draw(sheet)
        for row, pid in enumerate(batch):
            original = packing.projected_original(poses[pid])
            candidate = Image.open(ASSET / "poses" / (pid + ".png")).convert("RGBA")
            mirror = Image.open(ASSET / "poses" / (pid + "_mirror.png")).convert("RGBA")
            for column, (label, image) in enumerate([
                ("OG", original), ("candidate", candidate),
                ("OG mirrored", ImageOps.mirror(original)), ("candidate mirrored", mirror)
            ]):
                tile = packing.matte(image).crop((302, 210, 722, 570))
                sheet.paste(tile, (column * 420, row * 376 + 16))
                draw.text((column * 420 + 6, row * 376 + 3), pid + " / " + label + " / 1:1 output pixels", fill="white")
        path = directory / (batch[0] + "-" + batch[-1] + "-comparison.png")
        sheet.save(path)
        outputs.append(packing.rel(path))
    print(json.dumps(outputs, indent=2))


def gif_samples():
    manifest = packing.read(ASSET / "source_manifest.json")
    directory = REPORT / "review-images"
    directory.mkdir(parents=True, exist_ok=True)
    records = []
    for group in manifest["groups"]:
        if not group["complete"]:
            continue
        sheet = Image.new("RGB", (1440, 420), (23, 36, 49))
        draw = ImageDraw.Draw(sheet)
        record = {"group_id": group["group_id"], "orientations": []}
        for row, key in enumerate(["preview", "mirror_preview"]):
            gif = Image.open(ROOT / group[key])
            indices = sorted(set([0, gif.n_frames // 2, gif.n_frames - 1]))
            frames = []
            for column, index in enumerate(indices):
                gif.seek(index)
                duration = gif.info.get("duration", 0)
                tile = gif.convert("RGB").crop((136, 94, 392, 286)).resize((480, 360), Image.Resampling.NEAREST)
                # Display only; two GIF rows do not change any sprite source.
                tile.thumbnail((480, 190), Image.Resampling.LANCZOS)
                sheet.paste(tile, (column * 480, row * 210 + 20))
                draw.text((column * 480 + 5, row * 210 + 3), f'G{group["group_id"]} {key} GIF frame {index} / {duration}ms', fill="white")
                frames.append({"gif_frame_index": index, "duration_ms": duration})
            record["orientations"].append({"file": group[key], "physical_gif_frames": gif.n_frames,
                                            "sampled_frames": frames})
        output = directory / f'g{group["group_id"]:02d}-gif-decoded-samples.png'
        sheet.save(output)
        record["sample_image"] = packing.rel(output)
        records.append(record)
    output = REPORT / "gif-sampling-index.json"
    output.write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"groups": len(records), "index": packing.rel(output)}, indent=2))


parser = argparse.ArgumentParser()
parser.add_argument("command", choices=["poses", "gif-samples"])
parser.add_argument("--ids")
args = parser.parse_args()
if args.command == "poses":
    pose_comparisons(args.ids.split(",") if args.ids else [p for p in poses if (ASSET / "poses" / (p + ".png")).exists()])
else:
    gif_samples()
