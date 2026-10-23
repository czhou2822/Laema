"""Reconstruct a diagnostic reference from the frozen exact pre-edit candidate."""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
from PIL import Image, ImageDraw
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[6]
BASE=ROOT/'assets/prototype/enemy/bone_dragon/remaster_v01'
spec=importlib.util.spec_from_file_location('remaster_readonly',ROOT/'tools/art/necropolis_remaster.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
p=h.posemap(h.creature('bone_dragon'))['bone_dragon_p002']
before=BASE/'_source/frozen/pilot-p002-a03-registered-before-wing-edit.png'
im=Image.open(before).convert('RGBA');og=h.projected_original(p)
out=Image.new('RGB',(2048,768),(23,36,49));out.paste(h.matte(og),(0,0));out.paste(h.matte(im),(1024,0))
d=ImageDraw.Draw(out);d.text((20,20),'bone_dragon_p002 | original projected reference',fill='white')
d.text((1044,20),'registered candidate | 1024 x 768 | same shared transform',fill='white')
path=BASE/'_source/frozen/pilot-p002-a03-comparison-before-wing-edit.png'
out.save(path)
actual=hashlib.sha256(path.read_bytes()).hexdigest()
expected='1aa783ee3597e0f2719ac95a19f386bb86a6ef9b84c3ebcf5689e9f9fbc6fded'
assert actual==expected,(actual,expected)
print(json.dumps({'archived_snapshot':path.relative_to(ROOT).as_posix(),'sha256':actual,
    'matches_hash_observed_before_a04_call':True,'method':'Reconstructed diagnostic image from frozen exact candidate and unchanged OG projection; no artwork changed.'},indent=2))
