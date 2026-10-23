"""Lossless pixel-region extraction for inspected raw pages; never paint or pad."""
import hashlib
import json
import sys
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
DD = ROOT / 'assets/prototype/enemy/lich/remaster_v01/_source'
source = (ROOT / sys.argv[1]).resolve()
target = (ROOT / sys.argv[2]).resolve()
box = tuple(map(int, sys.argv[3].split(',')))
if not source.is_relative_to(DD) or not target.is_relative_to(DD):
    raise ValueError('Lich source-folder boundary')
if target.exists():
    raise ValueError('Preserve existing crop attempts')
im = Image.open(source).convert('RGBA')
piece = im.crop(box)
alpha = piece.getchannel('A').point(lambda a: 255 if a > 16 else 0)
bb = alpha.getbbox()
if not bb or bb[0] <= 1 or bb[1] <= 1 or bb[2] >= piece.width-1 or bb[3] >= piece.height-1:
    raise ValueError('Crop would cut or touch visible artwork')
target.parent.mkdir(parents=True, exist_ok=True)
piece.save(target)
print(json.dumps({'operation': 'unmodified RGBA pixel-region crop; no padding/painting/warping', 'source': source.relative_to(ROOT).as_posix(), 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'region_ltrb': box, 'output': target.relative_to(ROOT).as_posix(), 'output_sha256': hashlib.sha256(target.read_bytes()).hexdigest()}))
