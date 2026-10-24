"""Focused release export; exact preferred chamber reuse and explicit sole registration."""
from pathlib import Path
import ast,json,hashlib,time,shutil
import numpy as np
from PIL import Image,ImageDraw,ImageChops,ImageFont
ROOT=Path(__file__).parent
V04=ROOT.parent/'2026-10-23-x1-weight-transfer-v04'
started=time.perf_counter()
contract=json.loads((ROOT/'contract.json').read_text())
for n in ast.parse((ROOT.parent/'2026-10-23-A-v01/build_trial.py').read_text(encoding='utf-8')).body:
    if isinstance(n,ast.FunctionDef) and n.name in ['components','component_crop']:
        exec(compile(ast.Module(body=[n],type_ignores=[]),'reused_alpha_decoder','exec'))
for n in ast.parse((V04/'process_outputs.py').read_text(encoding='utf-8')).body:
    if isinstance(n,ast.FunctionDef) and n.name=='front_sole_landmark':
        exec(compile(ast.Module(body=[n],type_ignores=[]),'reused_sole_landmark','exec'))
raw=Image.open(ROOT/'raw/attempt01.png').convert('RGBA')
groups=sorted(components(raw)[:8],key=lambda g:g['bbox'][3]);assert len(groups)==8
groups=[g for row in range(2) for g in sorted(groups[row*4:row*4+4],key=lambda g:g['bbox'][0])]
feet=[g['bbox'][3] for g in groups];rows=[float(np.median(feet[r*4:r*4+4])) for r in range(2)];pitch_x=raw.width/4
guard=Image.open(ROOT/'inputs/appearance-guard.png').convert('RGBA');preferred=Image.open(ROOT/'inputs/previous-drawing02.png').convert('RGBA')
target_head=int(np.nonzero(np.asarray(guard.getchannel('A'))[:400,170:278]>127)[0].min())
guard_left=int(pitch_x*3.38);guard_right=int(pitch_x*3.62)
# Isolate the last guard component before stripe calibration. The upper row's
# boots can extend below half-height and must not be mistaken for its head.
guard_piece=component_crop(raw,groups[7]);gx,gy,_,_=groups[7]['bbox']
guard_mask=np.asarray(guard_piece.getchannel('A'))[:,max(0,guard_left-gx):min(guard_piece.width,guard_right-gx)]
raw_guard_head=int(np.nonzero(guard_mask>127)[0].min()+gy)
scale=(400-target_head)/(feet[7]-raw_guard_head)
source_frames=[];registrations=[]
for i,g in enumerate(groups):
    x,y,_,_=g['bbox'];piece=component_crop(raw,g);anchor=np.array([pitch_x*(i%4+.5),rows[i//4]])
    xy=np.array([224,400])+(np.array([x,y])-anchor)*scale
    tile=Image.new('RGBA',(448,448));piece=piece.resize((round(piece.width*scale),round(piece.height*scale)),Image.Resampling.LANCZOS)
    tile.alpha_composite(piece,tuple(round(v) for v in xy));source_frames.append(tile)
    registrations.append({'source_cell':i,'source_bbox':g['bbox'],'sole_row_deviation_world':(feet[i]-rows[i//4])*scale})

prior=Image.open(V04/'outputs/x1-weight-transfer.png').convert('RGBA')
frames=[prior.crop((i%8*448,i//8*448,i%8*448+448,i//8*448+448)) for i in range(16)]
for i in [1,2,3]:frames[i]=preferred.copy()
# The generator's chamber cells were near repetitions. Use the exact preferred
# drawing as an intentional .050-.126s hold, then three new release drawings.
for i,source in [(4,3),(5,4),(6,5)]:frames[i]=source_frames[source]
def atlas(frames,name):
    im=Image.new('RGBA',(3584,896))
    for i,frame in enumerate(frames):im.alpha_composite(frame,(i%8*448,i//8*448))
    im.save(ROOT/'outputs'/name)
atlas(frames,'x1-opening-before-foot-registration.png')
target=front_sole_landmark(guard);repairs=[]
for i in [4,5,6]:
    old=front_sole_landmark(frames[i]);delta=np.rint(target-old).astype(int);aligned=Image.new('RGBA',(448,448));aligned.alpha_composite(frames[i],tuple(delta.tolist()));frames[i]=aligned
    repairs.append({'key_index_0_based':i,'source_landmark':old.tolist(),'target_landmark':target.tolist(),'translation':delta.tolist(),'residual':(front_sole_landmark(aligned)-target).tolist()})
atlas(frames,'x1-opening-v05.png')
for file in ['current-game-x1.png','x1-followthrough-v03.png']:shutil.copy2(V04/'outputs'/file,ROOT/'outputs'/file)
old_data=json.loads((V04/'outputs/clips.json').read_text());game=old_data['clips'][0];repo=ROOT.parents[2]
for p,expected in [(game['texture'],game['texture_sha256']),(game['resource'],game['resource_sha256'])]:assert hashlib.sha256((repo/p).read_bytes()).hexdigest()==expected,p
clips=[{**game,'label':'1 · Current game / preferred'},
       {**old_data['clips'][1],'label':'2 · v03 / opening reference'},
       {'id':'opening_v05','label':'3 · v05 / opening correction','file':'x1-opening-v05.png','columns':8,'times':contract['times'],'duration':.72}]
d={'clips':clips,'duration':.72,'cell':[448,448],'foot_anchor':[224,400],'heat100_multiplier':1.5,'current_game_still_user_preferred':True,'new_drawing_keys_0_based':[4,5,6],'preferred_v03_drawing2_exact_hold_keys_0_based':[1,2,3],'preferred_hold_time':[.05,.126],'retained_v04_keys_0_based':[0,7,8,9,10,11,12,13,14,15],'registration':{'scale':scale,'scale_reference':'last raw ready-guard cell against static guard; shared across generated sheet','raw_guard_head_y':raw_guard_head,'raw_guard_foot_y':feet[7],'source_row_origins':rows,'source_column_pitch':pitch_x,'source_frames':registrations,'front_sole_repairs':repairs,'per_frame_rescaling_or_anatomy_warp':False,'before_file':'x1-opening-before-foot-registration.png'},'unused_generated_cells_0_based':[0,1,2,6,7],'unused_reason':'Three context/calibration cells plus two near-repeated chamber cells; exact preferred drawing intentionally reused instead','other_poses_approved':False,'gameplay_changes':False,'production_approved':False,'machine_export_seconds':time.perf_counter()-started}
(ROOT/'outputs/clips.json').write_text(json.dumps(d,indent=2)+'\n',encoding='utf-8',newline='\n')
board=Image.new('RGB',(1792,896),'#17212c');dr=ImageDraw.Draw(board)
for i in range(8):
    xy=(i%4*448,i//4*448);board.paste(frames[i],xy,frames[i]);dr.text((xy[0]+10,xy[1]+10),'v05 #%d / %.4fs'%(i+1,contract['times'][i]),fill='#e4c28d',font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',17))
board.save(ROOT/'outputs/opening-board.png')
print(json.dumps({'new_drawings':3,'exact_preferred_reuse_keys':[2,3,4],'retained_v04_keys':10,'scale':scale,'sole_repairs':repairs},indent=2))
