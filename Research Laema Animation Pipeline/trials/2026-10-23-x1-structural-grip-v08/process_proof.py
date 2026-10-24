"""Register one re-rendered structural pose, allowing changed arm/hand alpha."""
from pathlib import Path
import ast,json,hashlib,time,shutil
import numpy as np
from PIL import Image,ImageDraw,ImageChops
ROOT=Path(__file__).parent
V05=ROOT.parent/'2026-10-23-x1-opening-v05'
V04=ROOT.parent/'2026-10-23-x1-weight-transfer-v04'
started=time.perf_counter()
for n in ast.parse((ROOT.parent/'2026-10-23-A-v01/build_trial.py').read_text(encoding='utf-8')).body:
    if isinstance(n,ast.FunctionDef) and n.name in ['components','component_crop']:
        exec(compile(ast.Module(body=[n],type_ignores=[]),'reused_alpha_decoder','exec'))
for n in ast.parse((V04/'process_outputs.py').read_text(encoding='utf-8')).body:
    if isinstance(n,ast.FunctionDef) and n.name=='front_sole_landmark':exec(compile(ast.Module(body=[n],type_ignores=[]),'reused_sole_landmark','exec'))
source=Image.open(ROOT/'inputs/v05-key07.png').convert('RGBA');raw=Image.open(ROOT/'raw/attempt01.png').convert('RGBA')
source_group=components(source)[0];group=components(raw)[0];piece=component_crop(raw,group)
sx,sy,sr,sb=source_group['bbox'];rx,ry,rr,rb=group['bbox']
scale=(sb-sy)/(rb-ry)
sized=piece.resize((round(piece.width*scale),round(piece.height*scale)),Image.Resampling.LANCZOS)
proposal=Image.new('RGBA',(448,448));proposal.alpha_composite(sized,(sx,sy))
target=front_sole_landmark(source);current=front_sole_landmark(proposal);shift=np.rint(target-current).astype(int)
registered=Image.new('RGBA',(448,448));registered.alpha_composite(proposal,tuple(shift.tolist()))
registered.save(ROOT/'outputs/key07-structural.png')
old=Image.open(V05/'outputs/x1-opening-v05.png').convert('RGBA');atlas=old.copy();atlas.paste(registered,(6*448,0))
atlas.save(ROOT/'outputs/x1-one-pose-structural-v08.png')
for name,img in [('v05',source),('v08',registered)]:
    box=(208,234,304,306);crop=img.crop(box);matte=Image.new('RGB',crop.size,'#17212c');matte.paste(crop,(0,0),crop)
    matte.resize((384,288),Image.Resampling.NEAREST).save(ROOT/'outputs'/(name+'-arm-grip-4x.png'))
    bg=Image.new('RGB',(448,448),'#17212c');bg.paste(img,(0,0),img);bg.save(ROOT/'outputs'/(name+'-pose-native.png'))
    bg.resize((896,896),Image.Resampling.NEAREST).save(ROOT/'outputs'/(name+'-pose-2x.png'))
o=np.asarray(source);n=np.asarray(registered);roi=(slice(235,300),slice(210,295))
alpha_change=int(np.count_nonzero((o[roi][:,:,3]>127)!=(n[roi][:,:,3]>127)))
changed=int(np.count_nonzero(np.any(o!=n,axis=2)))
assert alpha_change>20,'No material arm-region silhouette change; reject this as structural proof.'
record={'scope':'One whole re-rendered pose; arm/wrist silhouette may change. Not an isolated RGB-detail patch.','source_key_1_based':7,'source_time_heat0':.158,'raw_size':list(raw.size),'raw_component_bbox':group['bbox'],'source_component_bbox':source_group['bbox'],'whole_proposal_scale':scale,'proposal_translation_to_source_front_sole':shift.tolist(),'source_front_sole':target.tolist(),'registration_method':'Match one foreground height then one forward-sole landmark; no old-alpha clamp','arm_region_alpha_pixels_changed':alpha_change,'whole_pose_rgba_pixels_changed':changed,'other_keys_unchanged':15,'body_or_equipment_pixel_preservation':False,'body_equipment_drift_is_open':True,'anatomical_or_visual_acceptance':False,'machine_export_seconds':time.perf_counter()-started}
(ROOT/'outputs/registration.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
for file in ['current-game-x1.png','x1-opening-v05.png']:shutil.copy2(V05/'outputs'/file,ROOT/'outputs'/file)
data=json.loads((V05/'outputs/clips.json').read_text());game=data['clips'][0];repo=ROOT.parents[2]
for p,h in [(game['resource'],game['resource_sha256']),(game['texture'],game['texture_sha256'])]:assert hashlib.sha256((repo/p).read_bytes()).hexdigest()==h
clips=[{**game,'label':'1 · Current game / preferred'},{**data['clips'][2],'label':'2 · v05 / source wrist'},{**data['clips'][2],'id':'structural_v08','label':'3 · v08 / ONE structural pose','file':'x1-one-pose-structural-v08.png'}]
(ROOT/'outputs/clips.json').write_text(json.dumps({'clips':clips,'duration':.72,'foot_anchor':[224,400],'proof_key_1_based':7,'other_keys_unapproved':True,'whole_motion_approved':False,'gameplay_changes':False},indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps(record,indent=2))
