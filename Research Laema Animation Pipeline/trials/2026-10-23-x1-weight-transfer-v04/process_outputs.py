"""Measured multi-row extraction with shared scale; explicit grid-layout repair."""
from pathlib import Path
import ast,json,hashlib,time,shutil
import numpy as np
from PIL import Image,ImageDraw,ImageChops,ImageFont
ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-x1-followthrough-v03'
started=time.perf_counter()
contract=json.loads((ROOT/'contract.json').read_text())
for n in ast.parse((ROOT.parent/'2026-10-23-A-v01/build_trial.py').read_text(encoding='utf-8')).body:
    if isinstance(n,ast.FunctionDef) and n.name in ['components','component_crop']:
        exec(compile(ast.Module(body=[n],type_ignores=[]),'reused_connected_alpha_decoder','exec'))
raw=Image.open(ROOT/'raw/attempt01.png').convert('RGBA')
groups=sorted(components(raw)[:16],key=lambda g:g['bbox'][3]);assert len(groups)==16
groups=[g for row in range(4) for g in sorted(groups[row*4:row*4+4],key=lambda g:g['bbox'][0])]
feet=[g['bbox'][3] for g in groups]
row_baselines=[float(np.median(feet[r*4:r*4+4])) for r in range(4)]
pitch_x=raw.width/4
alpha=np.asarray(raw.getchannel('A'))
head_y=int(np.nonzero(alpha[:feet[0],int(pitch_x*.38):int(pitch_x*.62)]>127)[0].min())
guard=Image.open(ROOT/'inputs/appearance-guard.png').convert('RGBA')
target_head_y=int(np.nonzero(np.asarray(guard.getchannel('A'))[:400,170:278]>127)[0].min())
scale=(400-target_head_y)/(feet[0]-head_y)
frames=[];records=[]
for i,g in enumerate(groups):
    x,y,_,_=g['bbox'];piece=component_crop(raw,g)
    anchor=np.array([pitch_x*(i%4+.5),row_baselines[i//4]])
    xy=np.array([224,400])+(np.array([x,y])-anchor)*scale
    tile=Image.new('RGBA',(448,448));piece=piece.resize((round(piece.width*scale),round(piece.height*scale)),Image.Resampling.LANCZOS)
    tile.alpha_composite(piece,tuple(round(v) for v in xy));frames.append(tile)
    records.append({'frame':i,'time':contract['keys'][i]['t'],'source_bbox':g['bbox'],'row_anchor_y':row_baselines[i//4],'source_sole_row_drift_world':(feet[i]-row_baselines[i//4])*scale})

def atlas(frames,name):
    sheet=Image.new('RGBA',(3584,896))
    for i,im in enumerate(frames):sheet.alpha_composite(im,(i%8*448,i//8*448))
    sheet.save(ROOT/'outputs'/name)
atlas(frames,'x1-all-generated-layout.png')
frames[0]=guard.copy();frames[-1]=guard.copy()
atlas(frames,'x1-weight-transfer-before-foot-registration.png')
def front_sole_landmark(im):
    # Bottom four opaque rows of the forward boot, in a fixed source-space ROI.
    # This is an export landmark, not a body joint or center-of-mass measurement.
    alpha=np.asarray(im.getchannel('A'))
    yy,xx=np.nonzero(alpha[375:414,224:342]>127)
    assert len(xx)>0
    bottom=int(yy.max()+375)
    yy,xx=np.nonzero(alpha[max(375,bottom-3):bottom+1,224:342]>127)
    return np.array([float(xx.mean()+224+.5),float(bottom+1)])
target_sole=front_sole_landmark(guard)
foot_repairs=[]
for i in range(1,15):
    source_sole=front_sole_landmark(frames[i]);delta=np.rint(target_sole-source_sole).astype(int)
    aligned=Image.new('RGBA',(448,448));aligned.alpha_composite(frames[i],tuple(delta.tolist()))
    foot_repairs.append({'frame':i,'time':contract['keys'][i]['t'],'source_sole_landmark':source_sole.tolist(),'target_sole_landmark':target_sole.tolist(),'translation_world_pixels':delta.tolist(),'residual_sole_landmark':(front_sole_landmark(aligned)-target_sole).tolist()})
    frames[i]=aligned
atlas(frames,'x1-weight-transfer.png')
shutil.copy2(PRIOR/'outputs/x1-followthrough.png',ROOT/'outputs/x1-followthrough-v03.png')
shutil.copy2(PRIOR/'outputs/current-game-x1.png',ROOT/'outputs/current-game-x1.png')
before=json.loads((PRIOR/'outputs/clips.json').read_text())
game=before['clips'][0]
repo=ROOT.parents[2]
for path,expected in [(game['texture'],game['texture_sha256']),(game['resource'],game['resource_sha256'])]:
    assert hashlib.sha256((repo/path).read_bytes()).hexdigest()==expected,path
times=[k['t'] for k in contract['keys']]
clips=[{**game,'label':'1 · Current game X1'},
       {**before['clips'][2],'label':'2 · Previous: shallow path','id':'followthrough_v03','file':'x1-followthrough-v03.png'},
       {'id':'weight_v04','label':'3 · Weight + steeper cut','file':'x1-weight-transfer.png','columns':8,'duration':.72,'times':times}]
data={'clips':clips,'cell':[448,448],'foot_anchor':[224,400],'duration':.72,'heat100_multiplier':1.5,'generated_cells':16,'new_cells_used':14,'endpoint_reuses':[0,15],'registration':{'shared_scale':scale,'raw_size':raw.size,'reference_guard_head_y':target_head_y,'raw_guard_head_y':head_y,'raw_guard_foot_y':feet[0],'column_pitch':pitch_x,'row_foot_baselines':row_baselines,'row_pitch_intervals':np.diff(row_baselines).tolist(),'layout_repair':'Four shared row origins because source row pitch is not uniform; one common scale and column pitch','per_frame_front_sole_registration':True,'per_frame_rescaling_or_body_centering':False,'before_registration_file':'x1-weight-transfer-before-foot-registration.png','front_sole_landmark_method':'Mean x of bottom4 opaque rows in fixed forward-boot ROI x224:342/y375:414; integer translation to static guard sole landmark','front_sole_repairs':foot_repairs,'frames':records},'gameplay_changes':False,'human_visual_approval':False,'machine_export_seconds':time.perf_counter()-started}
(ROOT/'outputs/clips.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
board=Image.new('RGB',(1792,1792),'#17212c');d=ImageDraw.Draw(board)
for i,im in enumerate(frames):
    xy=(i%4*448,i//4*448);board.paste(im,xy,im)
    d.text((xy[0]+8,xy[1]+8),'%02d / %.4fs / %s'%(i+1,times[i],contract['keys'][i]['phase']),fill='#e4c28d',font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',14))
board.save(ROOT/'outputs/pose-board.png')
print(json.dumps({'shared_scale':scale,'row_origins':row_baselines,'row_intervals':np.diff(row_baselines).tolist(),'maximum_sole_row_drift_world':max(abs(r['source_sole_row_drift_world']) for r in records),'new_cells_used':14,'endpoint_reuse':2,'export_seconds':data['machine_export_seconds']},indent=2))
