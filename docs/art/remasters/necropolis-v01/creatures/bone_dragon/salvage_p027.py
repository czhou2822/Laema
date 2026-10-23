"""Extend an exact crop only into a proven empty gutter; preserve every pixel."""
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT=Path(__file__).resolve().parents[6]
BASE=ROOT/'assets/prototype/enemy/bone_dragon/remaster_v01'
source=BASE/'_source/raw/full-batch-003-a01.png'
raw=Image.open(source).convert('RGBA')
assert raw.getchannel('A').crop((906,0,915,444)).point(lambda a:255 if a>8 else 0).getbbox() is None
target=BASE/'_source/derived/batch-003/bone_dragon_p027-wide-gutter-a02.png'
assert not target.exists()
raw.crop((459,0,915,444)).save(target)
print(json.dumps({'source':source.relative_to(ROOT).as_posix(),'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
 'exact_crop':[459,0,456,444],'extra_gutter':[906,0,9,444],'extra_gutter_has_alpha_gt8':False,
 'derivative':target.relative_to(ROOT).as_posix(),'derivative_sha256':hashlib.sha256(target.read_bytes()).hexdigest()},indent=2))
