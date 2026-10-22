"""Pair unmodified Godot plain/overlay viewport crops; no source-art editing."""
from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image, ImageDraw


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("capture_directory", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    for plain_path in sorted(args.capture_directory.glob("x*_*_plain.png")):
        overlay_path = plain_path.with_name(plain_path.name.replace("_plain.png", "_overlay.png"))
        plain, overlay = Image.open(plain_path), Image.open(overlay_path)
        assert plain.size == overlay.size == (1280, 720)
        # Fixed screen crop contains both facing directions at the fixture's
        # recorded screen origin. Enlarge nearest-neighbor for honest pixels.
        crop_box = (390, 350, 890, 650)
        sheet = Image.new("RGB", (2000, 650), (22, 27, 35))
        sheet.paste(plain.crop(crop_box).resize((1000, 600), Image.Resampling.NEAREST), (0, 50))
        sheet.paste(overlay.crop(crop_box).resize((1000, 600), Image.Resampling.NEAREST), (1000, 50))
        draw = ImageDraw.Draw(sheet)
        draw.text((12, 10), plain_path.stem.replace("_plain", "") + " | native Godot capture, no overlay", fill="white")
        draw.text((1012, 10), "Same frozen fixture clock | actual Player hitbox overlay", fill="white")
        draw.text((12, 30), "2x nearest-neighbor crop of 1280x720 game viewport; source artwork unchanged", fill="white")
        sheet.save(args.output / plain_path.name.replace("_plain.png", "_pair.png"))
        print("Paired capture:", plain_path.stem)


if __name__ == "__main__":
    main()
