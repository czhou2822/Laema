"""Offline evidence from saved atlas/geometry; this is not a Godot capture.

The scene's Fire rendering maps source pixels to world pixels at 1:1; attack
geometry is in Player-local pixels at scale 2. Artwork feet anchor is (224,400),
but floor offset (0,26) at Sprite scale .5 maps the actor root to source (224,348).
This helper exposes saved misalignment, not independent blade truth.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import math
import re
import shutil
from pathlib import Path

from PIL import Image, ImageDraw


def numbers(text: str) -> list[float]:
    return [float(v) for v in re.findall(r"[-+]?(?:\d*\.)?\d+(?:[eE][-+]?\d+)?", text)]


def tracks(text: str) -> dict[str, dict]:
    result = {}
    for found in re.finditer(r'tracks/(\d+)/path = NodePath\("([^"]+)"\)', text):
        index, path = found.groups()
        key = re.search(rf'tracks/{index}/keys = \{{(.*?)\n\}}', text, re.S)
        if not key:
            continue
        times = re.search(r'"times": PackedFloat32Array\(([^)]*)\)', key[1])
        raw = re.search(r'"values": \[(.*?)\]\s*$', key[1], re.S)
        if times and raw:
            if path.endswith("region_rect"):
                values = [numbers(v) for v in re.findall(r"Rect2\(([^)]*)\)", raw[1])]
            elif "Vector2(" in raw[1]:
                values = [numbers(v) for v in re.findall(r"Vector2\(([^)]*)\)", raw[1])]
            else:
                values = numbers(raw[1])
            interp = re.search(rf"tracks/{index}/interp = (\d+)", text)
            update = re.search(r'"update": (\d+)', key[1])
            result[path] = {"times": numbers(times[1]), "values": values,
                            "interp": int(interp[1]) if interp else 1,
                            "update": int(update[1]) if update else 0}
    return result


def sample(track: dict, time: float):
    i = max((i for i, t in enumerate(track["times"]) if t <= time + 1e-8), default=0)
    value = track["values"][i]
    if track["update"] == 1 or track["interp"] == 0 or i + 1 >= len(track["times"]):
        return value
    span = track["times"][i + 1] - track["times"][i]
    alpha = max(0.0, min(1.0, (time - track["times"][i]) / span)) if span else 0.0
    nxt = track["values"][i + 1]
    return ([a + (b - a) * alpha for a, b in zip(value, nxt)]
            if isinstance(value, list) else value + (nxt - value) * alpha)


def capsule(draw: ImageDraw.ImageDraw, origin, target, radius):
    a = (224 + origin[0] * 2, 348 + origin[1] * 2)
    b = (a[0] + target[0] * 2, a[1] + target[1] * 2)
    r = radius * 2
    length = math.dist(a, b)
    if length:
        normal = (-(b[1] - a[1]) / length * r, (b[0] - a[0]) / length * r)
        pts = [(a[0]+normal[0], a[1]+normal[1]), (b[0]+normal[0], b[1]+normal[1]),
               (b[0]-normal[0], b[1]-normal[1]), (a[0]-normal[0], a[1]-normal[1])]
        draw.polygon(pts, fill=(255, 180, 0, 35), outline=(255, 180, 0, 230), width=2)
        draw.line([a, b], fill=(255, 90, 0, 240), width=2)
    for point in (a, b):
        draw.ellipse((point[0]-r, point[1]-r, point[0]+r, point[1]+r),
                     fill=(255, 180, 0, 35), outline=(255, 180, 0, 230), width=2)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument("--label", required=True)
    args = parser.parse_args()
    output = Path(__file__).parent / args.label
    output.mkdir(parents=True, exist_ok=True)
    reference = output / "saved-inputs"
    reference.mkdir(exist_ok=True)
    report = {"kind": "offline saved-source overlay, not runtime evidence",
              "source_root_origin": [224, 348], "source_feet_anchor": [224, 400], "moves": []}
    for number in range(1, 6):
        move = f"fire_x{number}"
        path = args.root / f"config/attack_animations/{move}.tres"
        text = path.read_text(encoding="utf-8")
        saved_animation = reference / path.name
        if saved_animation.exists() and saved_animation.read_bytes() != path.read_bytes():
            raise RuntimeError(f"Evidence label {args.label} already contains different inputs; use a new label")
        texture_path = re.search(r'path="(res://[^"]+\.png)"', text)[1]
        atlas_path = args.root / texture_path[6:]
        atlas = Image.open(atlas_path).convert("RGBA")
        data = tracks(text)
        start = float(re.search(r'"name": &"active_start",\s*"time": ([\d.]+)', text)[1])
        end = float(re.search(r'"name": &"active_end",\s*"time": ([\d.]+)', text)[1])
        frames = data["Sprite:region_rect"]
        poses = [(time, region) for time, region in zip(frames["times"], frames["values"])]
        if all(abs(t - start) > 1e-6 for t, _ in poses):
            poses.append((start, sample(frames, start)))
        poses.sort(key=lambda v: v[0])
        canvas = Image.new("RGB", (448 * 3, 476 * math.ceil(len(poses) / 3)), (28, 33, 43))
        samples = []
        for i, (time, region) in enumerate(poses):
            x, y, w, h = map(int, region)
            frame = Image.new("RGBA", (448, 448), (28, 33, 43, 255))
            frame.alpha_composite(atlas.crop((x, y, x+w, y+h)))
            overlay = Image.new("RGBA", (448, 448), (0, 0, 0, 0))
            draw = ImageDraw.Draw(overlay)
            active = start - 1e-7 <= time <= end + 1e-7
            position = sample(data["AttackCast:position"], time)
            target = sample(data["AttackCast:target_position"], time)
            radius = sample(data["AttackCast:shape:radius"], time)
            if active:
                capsule(draw, position, target, radius)
            draw.line((0, 400, 448, 400), fill=(30, 200, 180, 150))
            draw.line((224, 388, 224, 410), fill=(30, 200, 180, 200))
            frame.alpha_composite(overlay)
            column, row = i % 3, i // 3
            canvas.paste(frame.convert("RGB"), (column * 448, row * 476 + 28))
            label = f"{move} t={time:.5f} frame={x // 448 + 1} " + ("ACTIVE" if active else "inactive")
            ImageDraw.Draw(canvas).text((column*448+8, row*476+8), label, fill=(255, 190, 30))
            samples.append({"time": time, "region": region, "active": active,
                            "position": position, "target": target, "radius": radius})
        image_path = output / f"{move}-saved-overlay.png"
        canvas.save(image_path)
        shutil.copy2(path, reference / path.name)
        shutil.copy2(atlas_path, reference / f"{move}-source.png")
        report["moves"].append({"move": move, "animation_sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                                "texture": texture_path, "texture_sha256": hashlib.sha256(atlas_path.read_bytes()).hexdigest(),
                                "active_start": start, "active_end": end, "samples": samples,
                                "overlay": str(image_path)})
        print(image_path)
    (output / "saved-source-report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
