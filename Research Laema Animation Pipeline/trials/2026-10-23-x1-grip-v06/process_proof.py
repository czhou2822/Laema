"""Place an AI-generated local grip repair in one R&D key; preserve source alpha."""
from pathlib import Path
import json,hashlib,time,shutil
import numpy as np
from PIL import Image,ImageDraw,ImageFilter
ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-x1-opening-v05'
started=time.perf_counter()
contract=json.loads((ROOT/'contract.json').read_text())
raw=Image.open(ROOT/'raw/attempt01.png').convert('RGB')
assert abs(raw.width/raw.height-4/3)<.01,'Proof aspect differs; do not stretch anatomy.'
raw.resize((1024,768),Image.Resampling.LANCZOS).save(ROOT/'outputs/grip-generated-detail.png')
native=raw.resize((128,96),Image.Resampling.LANCZOS)
native.save(ROOT/'outputs/grip-native-proposal.png')
source=Image.open(PRIOR/'outputs/x1-opening-v05.png').convert('RGBA')
key=source.crop((6*448,0,7*448,448))
proposal=key.convert('RGB')
crop_origin=contract['source_crop'][:2]
# Approximate crossguard-center alignment read from the two enlarged images.
# Only the proposed wrist/fist RGB will be used; the blade/guard stay source-exact.
alignment=(-1,1)
proposal.paste(native,(crop_origin[0]+alignment[0],crop_origin[1]+alignment[1]))
polygon=[(235,263),(247,259),(258,259),(266,263),(266,269),(263,280),(248,282),(236,277)]
mask=Image.new('L',(448,448));ImageDraw.Draw(mask).polygon(polygon,fill=255)
mask=mask.filter(ImageFilter.GaussianBlur(.7))
# Source sword/crossguard forward of the hand is protected, including the blade.
ImageDraw.Draw(mask).rectangle((267,0,447,447),fill=0)
mask.save(ROOT/'outputs/key07-rgb-repair-mask.png')
repaired=Image.composite(proposal,key.convert('RGB'),mask).convert('RGBA')
repaired.putalpha(key.getchannel('A'))
repaired.save(ROOT/'outputs/key07-repaired.png')
atlas=source.copy();atlas.paste(repaired,(6*448,0))
atlas.save(ROOT/'outputs/x1-grip-proof-v06.png')
box=tuple(contract['source_crop'])
for name,im in [('grip-before',key),('grip-after',repaired)]:
    crop=im.crop(box);matte=Image.new('RGB',crop.size,'#17212c');matte.paste(crop,(0,0),crop)
    matte.save(ROOT/'outputs'/(name+'-native.png'))
    matte.resize((512,384),Image.Resampling.NEAREST).save(ROOT/'outputs'/(name+'-4x.png'))
old=np.asarray(key);new=np.asarray(repaired);m=np.asarray(mask)
assert np.array_equal(old[:,:,3],new[:,:,3])
assert np.array_equal(old[m==0],new[m==0])
assert np.array_equal(old[:,267:],new[:,267:])
records={'source_key_1_based':7,'source_time_heat0':.158,'source_crop':list(box),'generated_image_size':list(raw.size),'generated_native_crop_size':[128,96],'whole_pose_rescaled':False,'local_proof_alignment_pixels':list(alignment),'alignment_basis':'Approximate crossguard-center location in enlarged before/after images; manual static registration, not automated skeleton tracking','rgb_repair_polygon':polygon,'feather_radius_native_pixels':.7,'protected_right_region_x_from':267,'source_alpha_exact':True,'outside_mask_rgba_exact':True,'changed_rgb_pixels':int(np.any(old[:,:,:3]!=new[:,:,:3],axis=2).sum()),'other_keys_unchanged':15,'source_motion_file_modified':False,'proof_only':True,'whole_strip_grip_corrected':False,'production_approved':False,'machine_export_seconds':time.perf_counter()-started}
(ROOT/'outputs/repair-record.json').write_text(json.dumps(records,indent=2)+'\n',encoding='utf-8',newline='\n')
data=json.loads((PRIOR/'outputs/clips.json').read_text())
for file in ['current-game-x1.png','x1-opening-v05.png','x1-opening-before-foot-registration.png']:shutil.copy2(PRIOR/'outputs'/file,ROOT/'outputs'/file)
game=data['clips'][0];repo=ROOT.parents[2]
for p,h in [(game['resource'],game['resource_sha256']),(game['texture'],game['texture_sha256'])]:assert hashlib.sha256((repo/p).read_bytes()).hexdigest()==h
clips=[{**game,'label':'1 · Current game / preferred'},
       {**data['clips'][2],'label':'2 · v05 / wrist rejected'},
       {**data['clips'][2],'id':'grip_v06','label':'3 · v06 / ONE-key grip proof','file':'x1-grip-proof-v06.png'}]
(ROOT/'outputs/clips.json').write_text(json.dumps({'clips':clips,'duration':.72,'foot_anchor':[224,400],'source_trial':'v05','proof_key_1_based':7,'only_key7_changed':True,'all_other_keys_unapproved':True,'gameplay_changes':False,'human_visual_approval':False},indent=2)+'\n',encoding='utf-8',newline='\n')
contract.update({'proof_integrated_into_sprite':'One isolated research key only; no product installation','source_motion_file_unchanged':True,'whole_strip_corrected':False})
(ROOT/'contract.json').write_text(json.dumps(contract,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(records,indent=2))
