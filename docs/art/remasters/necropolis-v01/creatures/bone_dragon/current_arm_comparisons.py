"""True-alpha matte review, not artwork modification."""
import importlib.util
import sys
from pathlib import Path
from PIL import Image, ImageChops
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[6]
BASE=ROOT/'assets/prototype/enemy/bone_dragon/remaster_v01'
spec=importlib.util.spec_from_file_location('remaster_readonly',ROOT/'tools/art/necropolis_remaster.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
pm=h.posemap(h.creature('bone_dragon'))
for number in [25,46,47,51,52,53,54]:
    pid='bone_dragon_p'+str(number).zfill(3)
    new=Image.open(BASE/'poses'/(pid+'.png')).convert('RGBA');og=h.projected_original(pm[pid])
    bb=ImageChops.lighter(new.getchannel('A'),og.getchannel('A')).getbbox()
    region=(max(0,bb[0]-8),max(0,bb[1]-8),min(1024,bb[2]+8),min(768,bb[3]+8))
    a=h.matte(og).crop(region);b=h.matte(new).crop(region)
    pair=Image.new('RGB',(a.width*2,a.height));pair.paste(a,(0,0));pair.paste(b,(a.width,0))
    pair.resize((pair.width*2,pair.height*2),Image.Resampling.NEAREST).save(BASE/'contacts/full-review'/(pid+'-current-matte-2x.png'))
