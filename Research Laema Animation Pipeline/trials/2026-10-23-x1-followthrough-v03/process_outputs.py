"""Reuse connected-alpha export and one group registration; preserve untouched cells."""
from pathlib import Path
import ast,json,hashlib,time,shutil
import numpy as np
from PIL import Image,ImageDraw,ImageChops,ImageFont
ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-ai-refine-v02'
started=time.perf_counter()
contract=json.loads((ROOT/'contract.json').read_text())
old=json.loads((PRIOR/'outputs/clips.json').read_text())['clips'][1]
for node in ast.parse((ROOT.parent/'2026-10-23-A-v01/build_trial.py').read_text(encoding='utf-8')).body:
    if isinstance(node,ast.FunctionDef) and node.name in ['components','component_crop']:
        exec(compile(ast.Module(body=[node],type_ignores=[]),'reused_v01_decoder','exec'))

raw=Image.open(ROOT/'raw/followthrough-attempt01.png').convert('RGBA')
groups=components(raw)[:8]
assert len(groups)==8
top=sorted(groups,key=lambda g:g['bbox'][3])[:4]
bottom=[g for g in groups if not any(g is h for h in top)]
groups=sorted(top,key=lambda g:g['bbox'][0])+sorted(bottom,key=lambda g:g['bbox'][0])
pitch_x=raw.width/4
feet=[g['bbox'][3] for g in groups]
pitch_y=float(np.median(feet[4:])-np.median(feet[:4]));foot_y=float(feet[0])
alpha=np.asarray(raw.getchannel('A'))
head_y=int(np.nonzero(alpha[:int(foot_y),int(pitch_x*.38):int(pitch_x*.62)]>127)[0].min())
guard=Image.open(ROOT/'inputs/appearance-guard.png').convert('RGBA')
guard_alpha=np.asarray(guard.getchannel('A'))
target_head_y=int(np.nonzero(guard_alpha[:400,170:278]>127)[0].min())
scale=(400-target_head_y)/(foot_y-head_y)
new_frames=[];registrations=[]
for i,g in enumerate(groups):
    piece=component_crop(raw,g);x,y,_,_=g['bbox']
    anchor=np.array([pitch_x*(i%4+.5),foot_y+i//4*pitch_y])
    xy=np.array([224,400])+(np.array([x,y])-anchor)*scale
    tile=Image.new('RGBA',(448,448));piece=piece.resize((round(piece.width*scale),round(piece.height*scale)),Image.Resampling.LANCZOS)
    tile.alpha_composite(piece,tuple(round(v) for v in xy));new_frames.append(tile)
    registrations.append({'guide_cell':i,'source_bbox':g['bbox'],'foot_row_drift_world':(feet[i]-anchor[1])*scale})

previous=Image.open(PRIOR/'outputs/x1-refined.png').convert('RGBA')
items=[];preserved=[]
for i,t in enumerate(old['times']):
    before=previous.crop((i%8*448,i//8*448,i%8*448+448,i//8*448+448))
    if t in contract['replaced_times']:
        replacement=contract['replaced_times'].index(t)+1
        items.append(new_frames[replacement])
    else:
        items.append(before)
        preserved.append({'time':t,'rgba_exact':True})
atlas=Image.new('RGBA',(3584,896))
for i,im in enumerate(items):atlas.alpha_composite(im,(i%8*448,i//8*448))
atlas.save(ROOT/'outputs/x1-followthrough.png')
shutil.copy2(PRIOR/'outputs/x1-refined.png',ROOT/'outputs/x1-refined-v02.png')
shutil.copy2(PRIOR/'outputs/current-game-x1.png',ROOT/'outputs/current-game-x1.png')
baseline=json.loads((PRIOR/'outputs/game-baselines.json').read_text())
game=baseline['clips'][0]
# Baseline must still match the actual bound main-checkout resource and texture.
repo=ROOT.parents[2]
for path,expected in [(game['texture'],game['texture_sha256']),(game['resource'],game['resource_sha256'])]:
    assert hashlib.sha256((repo/path).read_bytes()).hexdigest()==expected,path
clips=[{**game,'label':'1 · Current game X1'},
       {**old,'id':'refined_v02','label':'2 · Previous AI refinement','file':'x1-refined-v02.png'},
       {**old,'id':'followthrough_v03','label':'3 · Shallower follow-through','file':'x1-followthrough.png'}]
data={'clips':clips,'duration':.72,'cell':[448,448],'foot_anchor':[224,400],'heat100_multiplier':1.5,'unchanged_source_cells':preserved,'changed_times':contract['replaced_times'],'registration':{'method':'Reused connected-alpha extraction; one group transform with fixed column/row pitch, calibrated to the retained static guard','raw_size':raw.size,'global_scale':scale,'reference_guard_head_y':target_head_y,'raw_guard_head_y':head_y,'raw_guard_foot_y':foot_y,'column_pitch':pitch_x,'row_pitch':pitch_y,'per_frame_recentering':False,'frames':registrations},'gameplay_changed':False,'production_approved':False,'machine_export_seconds':time.perf_counter()-started}
(ROOT/'outputs/clips.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
board=Image.new('RGB',(1792,896),'#17212c');d=ImageDraw.Draw(board)
for i,im in enumerate(new_frames):
    xy=(i%4*448,i//4*448);board.paste(im,xy,im)
    d.text((xy[0]+10,xy[1]+10),'%d / %.4fs'%(i+1,contract['guide_keys'][i]['t']),fill='#e4c28d',font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',17))
board.save(ROOT/'outputs/correction-poses.png')
print(json.dumps({'preserved_cells':len(preserved),'changed_cells':len(contract['replaced_times']),'global_scale':scale,'foot_drifts':[r['foot_row_drift_world'] for r in registrations],'export_seconds':data['machine_export_seconds']},indent=2))
