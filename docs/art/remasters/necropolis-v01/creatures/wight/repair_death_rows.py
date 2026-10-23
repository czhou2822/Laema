"""Wight-only original-row separation to repair observed fragment ownership."""
import importlib.util
from pathlib import Path
import sys
from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
spec = importlib.util.spec_from_file_location("wight_row_helper", ROOT / "tools/art/necropolis_remaster.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
sys.path.insert(0, "C:/Users/zhouc/.codex/visualizations/2026/09/08/01a07f41-7159-70f1-ac7d-e6217941c130/necropolis-validation-v01/python-deps")
dest = h.dest("wight")
page = dest / "_source/page-003-attempt-01.png"
raw = Image.open(page).convert("RGBA")
band = raw.getchannel("A").crop((0, 477, raw.width, 479))
if band.point(lambda a: 255 if a > 8 else 0).getbbox() is not None:
    raise ValueError("The proposed row boundary is not empty; refuse to crop")
records = []
for suffix, region, start in [
    ("defence", (0, 0, raw.width, 478), 24),
    ("death", (0, 478, raw.width, raw.height), 28),
]:
    row = raw.crop(region)
    padded = Image.new("RGBA", (row.width + 16, row.height + 16))
    padded.paste(row, (8, 8))
    fp = dest / "_source/recovered" / f"page-003-{suffix}-row.png"
    padded.save(fp)
    ids = [f"wight_p{i:03d}" for i in range(start, start + 4)]
    h.ingest("wight", h.rel(fp), ids, 4, 1, f"page-003-{suffix}-row", "assets/prototype/enemy/wight/remaster_v01/_source/prompts/page-003-attempt-01.txt", components=True)
    records.append({"file": h.rel(fp), "sha256": h.sha(fp), "original_crop_ltrb": list(region), "transparent_padding": 8, "pose_ids": ids})
h.write(Path(__file__).parent / "death-fragment-membership-repair.json", {"original_page": h.rel(page), "original_sha256": h.sha(page), "verified_empty_band_y": [477, 479], "alpha_threshold": 8, "purpose": "Return the stray p026 speck to its original p030 bone. Shared strict ingestion checks unchanged; no painted, recoloured or warped pixels.", "rows": records})
print("Re-ingested p024-p031 from two verified source rows")
