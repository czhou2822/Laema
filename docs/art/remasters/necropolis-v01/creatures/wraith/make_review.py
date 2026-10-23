"""Mechanical review presentations only; no artwork construction or alteration."""
import importlib.util
import json
import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
DEST = ROOT / "assets/prototype/enemy/wraith/remaster_v01"
OUT = Path(__file__).resolve().parent / "review-images"
spec = importlib.util.spec_from_file_location("wraith_pack_readonly", ROOT / "tools/art/necropolis_remaster.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
c = h.creature("wraith")
pm = h.posemap(c)
OUT.mkdir(parents=True, exist_ok=True)
CROP = (350, 215, 675, 540)


def canvas_crop(im, mirrored=False):
    if mirrored:
        region = (1024 - CROP[2], CROP[1], 1024 - CROP[0], CROP[3])
    else:
        region = CROP
    return h.matte(im).crop(region)


for batch in range(math.ceil(len(pm) / 4)):
    ids = list(pm)[batch * 4:batch * 4 + 4]
    sheet = Image.new("RGB", (1952, 515 * math.ceil(len(ids) / 2)), (23, 36, 49))
    d = ImageDraw.Draw(sheet)
    for i, pid in enumerate(ids):
        x, y = i % 2 * 976, i // 2 * 515
        original = canvas_crop(h.projected_original(pm[pid]))
        candidate = canvas_crop(Image.open(DEST / "poses" / (pid + ".png")).convert("RGBA"))
        sheet.paste(original.resize((488, 488), Image.Resampling.NEAREST), (x, y + 25))
        sheet.paste(candidate.resize((488, 488), Image.Resampling.NEAREST), (x + 488, y + 25))
        d.text((x + 5, y + 5), pid + " ORIGINAL left / CANDIDATE right; 1.5x registered pixels", fill="white")
    sheet.save(OUT / f"poses-{batch:03d}.png")

# All timeline positions in source order; both facings from full-resolution frame PNGs.
manifest = json.loads((DEST / "source_manifest.json").read_text())
for g in manifest["groups"]:
    count = g["frame_count"]
    base = f'g{g["group_id"]:02d}_b{g["original_block"]:02d}'
    sheet = Image.new("RGB", (2600, 360 * math.ceil(count / 4)), (23, 36, 49))
    d = ImageDraw.Draw(sheet)
    for i, pid in enumerate(g["pose_ids_in_source_order"]):
        x, y = i % 4 * 650, i // 4 * 360
        for orient, off in [("source", 0), ("mirror", 325)]:
            im = Image.open(DEST / "frames" / orient / base / f"{i:03d}.png").convert("RGBA")
            sheet.paste(canvas_crop(im, orient == "mirror"), (x + off, y + 30))
        d.text((x + 4, y + 5), f'G{g["group_id"]} F{i} {pid} | right / exact left mirror', fill="white")
    sheet.save(OUT / f"sequence-{base}.png")
    # Decode every stored GIF frame, including duration-collapsed holds; no playback claim.
    previews = []
    for orient in ["source", "mirror"]:
        gif = Image.open(ROOT / g["preview" if orient == "source" else "mirror_preview"])
        for i in range(gif.n_frames):
            gif.seek(i)
            region = tuple(round(v / 2) for v in ((1024 - CROP[2], CROP[1], 1024 - CROP[0], CROP[3]) if orient == "mirror" else CROP))
            previews.append((orient, i, gif.info.get("duration", 0), gif.convert("RGB").crop(region)))
    sheet = Image.new("RGB", (1000, 200 * math.ceil(len(previews) / 5)), (23, 36, 49))
    d = ImageDraw.Draw(sheet)
    for i, (orient, index, duration, im) in enumerate(previews):
        x, y = i % 5 * 200, i // 5 * 200
        sheet.paste(im, (x + 18, y + 25))
        d.text((x + 3, y + 3), f"{orient} GIF{index} {duration}ms", fill="white")
    sheet.save(OUT / f"gif-{base}.png")
print(json.dumps({"pose_sheets": math.ceil(len(pm) / 4), "sequence_sheets": len(manifest["groups"]),
                  "gif_sheets": len(manifest["groups"]), "output": str(OUT)}))
