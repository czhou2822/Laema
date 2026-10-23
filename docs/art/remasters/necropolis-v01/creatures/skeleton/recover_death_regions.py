"""Mechanical extraction of two visually reviewed regions; no painting/warping.

The strict generic component extractor split the released p030 sword between
p026 and p030. Both correct complete poses lie in disjoint transparent-margin
rectangles in the original built-in output. Preserve every RGBA byte in each crop.
"""
import hashlib
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
ASSETS = ROOT / "assets/prototype/enemy/skeleton/remaster_v01"
source = ASSETS / "_source/full-batch-003-a01.png"
image = Image.open(source).convert("RGBA")
assert image.size == (1774, 887), image.size
regions = {"skeleton_p026": (887, 0, 1330, 452),
           "skeleton_p030": (887, 452, 1330, 887)}
evidence = []
for pid, region in regions.items():
    crop = image.crop(region)
    box = crop.getchannel("A").point(lambda a: 255 if a > 16 else 0).getbbox()
    assert box and box[0] > 1 and box[1] > 1 and box[2] < crop.width - 1 and box[3] < crop.height - 1, (pid, box)
    target = ASSETS / "_source" / ("full-death-region-" + pid + "-c01.png")
    crop.save(target)
    assert crop.tobytes() == image.crop(region).tobytes()
    evidence.append({"pose_id": pid, "raw_page": source.relative_to(ROOT).as_posix(),
                     "raw_page_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
                     "explicit_xyxy_region": region, "crop": target.relative_to(ROOT).as_posix(),
                     "crop_sha256": hashlib.sha256(target.read_bytes()).hexdigest(),
                     "rgba_crop_identical": True,
                     "reason": "Released sword split by nearest component ownership; manually reviewed nonoverlapping whole-pose rectangles"})
print(json.dumps(evidence, indent=2))
