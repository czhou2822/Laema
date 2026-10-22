"""Independent source-pixel inspection; never reads or derives blade points from geometry."""
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
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument("--verify-native", action="store_true")
    args = parser.parse_args()
    atlas_path = args.root / "assets/prototype/player/fire_sword_shield_v01/angle_proofs_v03/fire_x2.png"
    atlas = Image.open(atlas_path).convert("RGBA")
    assert atlas.size == (2688, 448)
    truth = json.loads(Path(__file__).with_name("x2-blade-points.json").read_text(encoding="utf-8"))
    assert hashlib.sha256(atlas_path.read_bytes()).hexdigest() == truth["atlas_sha256"]
    output = Path(__file__).parent / "x2-source-measurements"
    output.mkdir(exist_ok=True)
    for frame in range(6):
        crop = atlas.crop((448 * frame, 0, 448 * (frame + 1), 448))
        if frame in (1, 2, 3, 4):
            boxes = {1: (120, 255, 195, 300), 2: (220, 280, 320, 325),
                     3: (285, 265, 390, 300), 4: (270, 250, 355, 300)}
            left, top, right, bottom = boxes[frame]
            print("Steel pixel inspection, frame", frame)
            for x in range(left, right, 5):
                ys = [y for y in range(top, bottom)
                      if (lambda p: p[3] > 128 and min(p[:3]) > 75 and max(p[:3]) - min(p[:3]) < 45)(crop.getpixel((x, y)))]
                if ys:
                    print(x, min(ys), max(ys), round(sum(ys) / len(ys), 2))
        canvas = Image.new("RGBA", (448, 448), (32, 38, 46, 255))
        canvas.alpha_composite(crop)
        canvas.convert("RGB").save(output / f"frame-{frame}-plain.png")
        enlarged = canvas.resize((1344, 1344), Image.Resampling.NEAREST)
        draw = ImageDraw.Draw(enlarged)
        for x in range(80, 391, 10):
            draw.line((x * 3, 210 * 3, x * 3, 340 * 3), fill=(90, 120, 140, 65))
            draw.text((x * 3 + 2, 205 * 3), str(x), fill="white")
        for y in range(210, 341, 10):
            draw.line((80 * 3, y * 3, 390 * 3, y * 3), fill=(90, 120, 140, 65))
            draw.text((72 * 3, y * 3 + 2), str(y), fill="white")
        enlarged.crop((70 * 3, 195 * 3, 405 * 3, 350 * 3)).convert("RGB").save(output / f"frame-{frame}-grid.png")
        pose = next((p for p in truth["poses"] if p["frame"] == frame), None)
        if pose:
            draw = ImageDraw.Draw(canvas)
            for key, color in (("base", "cyan"), ("middle", "lime"), ("tip", "magenta")):
                x, y = pose[key]
                draw.ellipse((x - 2, y - 2, x + 2, y + 2), outline=color, width=1)
                draw.text((x + 3, y + 4), key, fill=color)
            canvas.convert("RGB").save(output / f"frame-{frame}-measured.png")
            base, tip = pose["base"], pose["tip"]
            length = math.dist(base, tip)
            unit = [(b - a) / length for a, b in zip(base, tip)]
            # Retain radius3.5 local (7 source/world pixels). Inset both centers
            # so the endcaps terminate at, rather than extend past, the steel.
            origin = [(v + u * 7 - r) / 2 for v, u, r in zip(base, unit, (224, 348))]
            target = [u * (length - 14) / 2 for u in unit]
            print("Measured pose", frame, "position", origin, "target", target)
    print("Source SHA256:", hashlib.sha256(atlas_path.read_bytes()).hexdigest())
    print("Independent inspection frames:", output)
    if args.verify_native:
        path = args.root / "config/attack_animations/fire_x2.tres"
        baseline_path = Path(__file__).parent / "baseline/saved-inputs/fire_x2.tres"
        before, after = baseline_path.read_text(encoding="utf-8"), path.read_text(encoding="utf-8")
        strip_allowed = lambda text: re.sub(r"tracks/[34]/keys = \{.*?\n\}", "<allowed position/target keys>", text, flags=re.S)
        assert strip_allowed(before) == strip_allowed(after), "Change outside X2 position/target keys"
        for track in (3, 4):
            block = re.search(rf"tracks/{track}/keys = \{{(.*?)\n\}}", after, re.S)[1]
            times = [float(v) for v in re.search(r'"times": PackedFloat32Array\((.*?)\)', block)[1].split(",")]
            values = [tuple(float(v) for v in value.split(",")) for value in re.findall(r"Vector2\((.*?)\)", block)]
            assert times == [0.0, 0.2, 0.36, 0.45624605, 0.6, 0.7485495, 0.8333333]
            for index, pose in enumerate(truth["poses"], 2):
                base, tip = pose["base"], pose["tip"]
                length = math.dist(base, tip)
                unit = [(b - a) / length for a, b in zip(base, tip)]
                expected = ([(v + u * 7 - r) / 2 for v, u, r in zip(base, unit, (224, 348))]
                            if track == 3 else [u * (length - 14) / 2 for u in unit])
                assert math.dist(values[index], expected) < 0.000001, (track, pose["frame"])
        report = {"result": "PASS", "only_changed_tracks": ["AttackCast:position keys", "AttackCast:target_position keys"],
                  "unchanged": ["UID", "length", "all markers", "Sprite texture/region keys", "radius track bytes", "all non-geometry metadata"],
                  "atlas_sha256": truth["atlas_sha256"], "baseline_animation_sha256": hashlib.sha256(baseline_path.read_bytes()).hexdigest(),
                  "candidate_animation_sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
        (output / "static-checks.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
        print("PASSED: native invariant and independent-measurement conversion checks")


if __name__ == "__main__":
    main()
