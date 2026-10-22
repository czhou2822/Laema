"""Inspect current Fire art independently; verify only approved geometry-key edits."""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
from pathlib import Path

from PIL import Image, ImageDraw


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("move")
    parser.add_argument("--verify-native", action="store_true")
    parser.add_argument("--steel-box", action="append", default=[], help="frame,left,top,right,bottom")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    directory = Path(__file__).parent
    path = root / f"config/attack_animations/{args.move}.tres"
    text = path.read_text(encoding="utf-8")
    source = root / re.search(r'path="res://([^\"]+\.png)"', text)[1]
    atlas = Image.open(source).convert("RGBA")
    point_file = directory / f"{args.move}-blade-points.json"
    truth = json.loads(point_file.read_text(encoding="utf-8")) if point_file.exists() else None
    output = directory / f"{args.move}-source-measurements"
    output.mkdir(exist_ok=True)
    frames = [tuple(int(float(v)) for v in raw.split(",")) for raw in re.findall(r"Rect2\((.*?)\)", text)]
    if truth:
        assert hashlib.sha256(source.read_bytes()).hexdigest() == truth["atlas_sha256"]
    for frame, (x, y, width, height) in enumerate(frames):
        crop = atlas.crop((x, y, x + width, y + height))
        for raw_box in args.steel_box:
            selected, left, top, right, bottom = map(int, raw_box.split(","))
            if selected != frame:
                continue
            vertical = bottom - top > right - left
            print("Steel runs frame", frame, "axis", "y" if vertical else "x")
            for major in range(top if vertical else left, bottom if vertical else right, 5):
                values = []
                for minor in range(left if vertical else top, right if vertical else bottom):
                    pixel = crop.getpixel((minor, major) if vertical else (major, minor))
                    if pixel[3] > 128 and min(pixel[:3]) > 75 and max(pixel[:3]) - min(pixel[:3]) < 45:
                        values.append(minor)
                if values:
                    print(major, min(values), max(values), round(sum(values) / len(values), 2))
        canvas = Image.new("RGBA", (width, height), (32, 38, 46, 255))
        canvas.alpha_composite(crop)
        canvas.convert("RGB").save(output / f"frame-{frame}-plain.png")
        grid = canvas.resize((width * 3, height * 3), Image.Resampling.NEAREST)
        draw = ImageDraw.Draw(grid)
        for gx in range(40, 421, 10):
            draw.line((gx * 3, 90 * 3, gx * 3, 420 * 3), fill=(75, 90, 105))
            draw.text((gx * 3 + 1, 85 * 3), str(gx), fill="white")
        for gy in range(90, 421, 10):
            draw.line((40 * 3, gy * 3, 420 * 3, gy * 3), fill=(75, 90, 105))
            draw.text((30 * 3, gy * 3 + 1), str(gy), fill="white")
        grid.crop((25 * 3, 80 * 3, 430 * 3, 430 * 3)).convert("RGB").save(output / f"frame-{frame}-grid.png")
        source_cell = int(x / width) + int(y / height) * int(atlas.width / width)
        pose = next((p for p in truth["poses"] if p.get("cell", p.get("frame")) == source_cell), None) if truth else None
        if pose:
            draw = ImageDraw.Draw(canvas)
            for key, color in (("base", "cyan"), ("middle", "lime"), ("tip", "magenta")):
                px, py = pose[key]
                draw.ellipse((px - 2, py - 2, px + 2, py + 2), outline=color, width=1)
                draw.text((px + 3, py + 4), key, fill=color)
            canvas.convert("RGB").save(output / f"frame-{frame}-measured.png")
    print("Atlas:", source.relative_to(root))
    print("Atlas SHA256:", hashlib.sha256(source.read_bytes()).hexdigest())
    if truth:
        for pose in truth["poses"]:
            base, tip = pose["base"], pose["tip"]
            length = math.dist(base, tip)
            unit = [(b - a) / length for a, b in zip(base, tip)]
            position = [(p + u * 7 - r) / 2 for p, u, r in zip(base, unit, (224, 348))]
            target = [u * (length - 14) / 2 for u in unit]
            print("Measured pose", pose.get("cell", pose.get("frame")), "position", position, "target", target)
    if args.verify_native:
        baseline = directory / "baseline/saved-inputs" / path.name
        before = baseline.read_text(encoding="utf-8")
        strip = lambda value: re.sub(r"tracks/[34]/keys = \{.*?\n\}", "<allowed geometry keys>", value, flags=re.S)
        assert strip(before) == strip(text), "Change outside position/target key data"
        for track in (3, 4):
            block = re.search(rf"tracks/{track}/keys = \{{(.*?)\n\}}", text, re.S)[1]
            times = [float(value) for value in re.search(r'"times": PackedFloat32Array\((.*?)\)', block)[1].split(",")]
            values = [tuple(float(v) for v in value.split(",")) for value in re.findall(r"Vector2\((.*?)\)", block)]
            for pose in truth["poses"]:
                key = min(range(len(times)), key=lambda index: abs(times[index] - pose["active_from"]))
                assert abs(times[key] - pose["active_from"]) < 0.000001, "Missing held-pose boundary"
                base, tip = pose["base"], pose["tip"]
                length = math.dist(base, tip)
                unit = [(b - a) / length for a, b in zip(base, tip)]
                expected = ([(p + u * 7 - r) / 2 for p, u, r in zip(base, unit, (224, 348))]
                            if track == 3 else [u * (length - 14) / 2 for u in unit])
                assert math.dist(values[key], expected) < 0.000001, (track, pose["frame"])
        report = {"result": "PASS", "move": args.move, "only_changed_tracks": ["position key data", "target_position key data"],
                  "atlas_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                  "baseline_animation_sha256": hashlib.sha256(baseline.read_bytes()).hexdigest(),
                  "candidate_animation_sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
        (output / "static-checks.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print("PASSED: all non-position/target data unchanged")


if __name__ == "__main__":
    main()
