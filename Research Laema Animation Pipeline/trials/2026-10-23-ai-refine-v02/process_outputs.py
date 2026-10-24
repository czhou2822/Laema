"""Reusable measured extraction for the two AI trial strips. Preserves all raw files."""
from pathlib import Path
import ast,json,time,hashlib
import numpy as np
from PIL import Image,ImageDraw,ImageChops,ImageFont
ROOT=Path(__file__).parent
RESEARCH=ROOT.parents[1]
PRIOR=RESEARCH/'trials/2026-10-23-A-v01'
contract=json.loads((ROOT/'contract.json').read_text())
# Reuse the executed v01 decoder definitions without running its old build script.
source=(PRIOR/'build_trial.py').read_text(encoding='utf-8')
tree=ast.parse(source)
for node in tree.body:
    if isinstance(node,ast.FunctionDef) and node.name in ['components','component_crop']:
        exec(compile(ast.Module(body=[node],type_ignores=[]),'reused_v01_decoder','exec'))
def decode(filename):
    started=time.perf_counter();im=Image.open(ROOT/'raw'/filename).convert('RGBA')
    groups=components(im)[:8]
    assert len(groups)==8
    top=sorted(groups,key=lambda g:g['bbox'][3])[:4]
    bottom=[g for g in groups if not any(g is h for h in top)]
    groups=sorted(top,key=lambda g:g['bbox'][0])+sorted(bottom,key=lambda g:g['bbox'][0])
    pitch_x=im.width/4;feet=[g['bbox'][3] for g in groups]
    pitch_y=float(np.median(feet[4:])-np.median(feet[:4]));foot_y=float(feet[0])
    alpha=np.asarray(im.getchannel('A'))
    stripe=alpha[:int(foot_y),int(pitch_x*(.5-.12)):int(pitch_x*(.5+.12))]>127
    head_y=int(np.nonzero(stripe)[0].min())
    scale=180/(foot_y-head_y)
    frames=[];records=[]
    for i,g in enumerate(groups):
        piece=component_crop(im,g);x,y,_,_=g['bbox'];row,col=i//4,i%4
        anchor=np.array([pitch_x*(col+.5),foot_y+row*pitch_y])
        xy=np.array([224,400])+(np.array([x,y])-anchor)*scale
        tile=Image.new('RGBA',(448,448));sized=piece.resize((round(piece.width*scale),round(piece.height*scale)),Image.Resampling.LANCZOS)
        tile.alpha_composite(sized,tuple(round(v) for v in xy));frames.append(tile)
        records.append({'frame':i,'source_bbox':g['bbox'],'lowest_opaque_row_drift_world':(feet[i]-anchor[1])*scale})
    return frames,{'raw_file':filename,'raw_size':im.size,'raw_sha256':hashlib.sha256((ROOT/'raw'/filename).read_bytes()).hexdigest(),'reused_decoder_definitions':['components','component_crop'],'new_decoder_algorithm':False,'global_scale':scale,'column_pitch':pitch_x,'row_pitch':pitch_y,'guard_head_y_from_fixed_center_stripe':head_y,'guard_foot_y':foot_y,'per_frame_recentering':False,'frames':records,'machine_extract_seconds':time.perf_counter()-started}
def atlas(frames,name,cols=8):
    sheet=Image.new('RGBA',(cols*448,((len(frames)+cols-1)//cols)*448))
    for i,frame in enumerate(frames):sheet.alpha_composite(frame,(i%cols*448,i//cols*448))
    sheet.save(ROOT/'outputs'/f'{name}.png')
baseline_sheet=Image.open(PRIOR/'outputs/ai-corrected.png').convert('RGBA')
baseline=[baseline_sheet.crop((i%5*448,i//5*448,i%5*448+448,i//5*448+448)) for i in range(10)]
added,added_metrics=decode('x1-inbetweens-attempt02.png')
cast,cast_metrics=decode('cast-attempt02.png')
items=[(k['t'],baseline[i],'preferred_original_key') for i,k in enumerate(contract['x1_baseline_keys'])]
items += [(t,added[i+1],'new_AI_inbetween') for i,t in enumerate(contract['x1_added_times'])]
items.sort(key=lambda x:x[0]);refined=[x[1] for x in items]
cast[0]=baseline[0].copy();cast[-1]=baseline[0].copy()
cast[3]=cast[2].copy();cast[4]=cast[2].copy()
atlas(baseline,'x1-before',5);atlas(refined,'x1-refined');atlas(cast,'cast-reuse',4)
data={'selected_method':'AI strip; user-authorized refinement/reuse trial','cell':[448,448],'foot_anchor':[224,400],'clips':[{'id':'x1_before','label':'X1 preferred / 10 keys','file':'x1-before.png','columns':5,'duration':.72,'times':[k['t'] for k in contract['x1_baseline_keys']]},{'id':'x1_refined','label':'X1 refinement / 16 keys','file':'x1-refined.png','columns':8,'duration':.72,'times':[x[0] for x in items]},{'id':'cast_reuse','label':'Second action / original Cast','file':'cast-reuse.png','columns':4,'duration':1.2,'times':[k['t'] for k in contract['cast_keys']]}],'added_drawing_origins':[{'t':x[0],'source':x[2]} for x in items],'x1':added_metrics,'cast':cast_metrics,'explicit_endpoint_reuses':{'cast':[0,7]},'explicit_peak_reuses':{'cast':{'source_frame':2,'reused_frames':[3,4],'reason':'Stable ear-height grip through launch; avoids the clipped tip of generated frame3 and unnecessary high-hold drift.'}},'gameplay_changes':False,'human_visual_acceptance':False,'notes':['Ten preferred original X1 drawings are byte-preserved as normalized source cells; six generated inbetweens added.','The second action was authored from new joint targets and a fixed existing launch anchor, not an old Cast sequence.','Extraction head-stripe calibration is a measured trial assumption requiring visual QA.']}
(ROOT/'outputs/clips.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
# Two labeled inspection boards at 1x, without changing sprite data.
for frames,name,keys in [(added,'x1-added-poses',contract['x1_inbetween_guide_keys']),(cast,'cast-poses',contract['cast_keys'])]:
    board=Image.new('RGB',(1792,896),'#17212c');draw=ImageDraw.Draw(board)
    for i,frame in enumerate(frames):
        xy=(i%4*448,i//4*448);board.paste(frame,xy,frame)
        draw.text((xy[0]+12,xy[1]+12),f'{i+1} / {keys[i]["t"]:.4f}s',fill='#e4c28d',font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',18))
    board.save(ROOT/'outputs'/f'{name}.png')
print(json.dumps({'X1_keys':len(refined),'Cast_keys':len(cast),'X1_scale':added_metrics['global_scale'],'Cast_scale':cast_metrics['global_scale'],'X1_foot_drift':[r['lowest_opaque_row_drift_world'] for r in added_metrics['frames']],'Cast_foot_drift':[r['lowest_opaque_row_drift_world'] for r in cast_metrics['frames']]},indent=2))
