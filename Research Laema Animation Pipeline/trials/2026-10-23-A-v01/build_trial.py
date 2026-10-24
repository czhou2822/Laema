"""Measured sprite extraction and an actual raster cutout rig. Isolated R&D only."""
from pathlib import Path
import json, math, time, hashlib
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageChops

ROOT=Path(__file__).parent
SOURCE=ROOT.parents[1]
OUT=ROOT/'outputs'
OUT.mkdir(exist_ok=True)
DATA=json.loads((SOURCE/'study-data.json').read_text())
A=DATA['proposals'][0]
CELL=448
ORIGIN=np.array([224.,400.])
START=time.perf_counter()

def components(im, threshold=127):
    """Connected alpha components via scanline runs, retaining source coordinates."""
    mask=np.asarray(im.getchannel('A'))>threshold
    parent=[]; all_runs=[]; previous=[]
    def find(x):
        while parent[x]!=x:parent[x]=parent[parent[x]];x=parent[x]
        return x
    def union(a,b):
        a,b=find(a),find(b)
        if a!=b:parent[b]=a
    for y,row in enumerate(mask):
        edges=np.diff(np.r_[False,row,False].astype(np.int8))
        starts=np.flatnonzero(edges==1);ends=np.flatnonzero(edges==-1)
        current=[];j=0
        for x0,x1 in zip(starts,ends):
            x0,x1=int(x0),int(x1)
            while j<len(previous) and previous[j][1]<x0:j+=1
            overlap=[];k=j
            while k<len(previous) and previous[k][0]<=x1:
                overlap.append(previous[k][2]);k+=1
            if overlap:
                label=find(overlap[0])
                for other in overlap[1:]:union(label,other)
            else:label=len(parent);parent.append(label)
            current.append((x0,x1,label));all_runs.append((y,x0,x1,label))
        previous=current
    groups={}
    for y,x0,x1,label in all_runs:
        root=find(label)
        g=groups.setdefault(root,{'area':0,'bbox':[im.width,im.height,0,0],'runs':[]})
        g['area']+=x1-x0;g['runs'].append((y,x0,x1));b=g['bbox']
        b[0]=min(b[0],x0);b[1]=min(b[1],y);b[2]=max(b[2],x1);b[3]=max(b[3],y+1)
    return sorted(groups.values(),key=lambda g:g['area'],reverse=True)

def component_crop(im,g):
    x0,y0,x1,y1=g['bbox'];mask=Image.new('L',(x1-x0,y1-y0));d=ImageDraw.Draw(mask)
    for y,a,b in g['runs']:d.line((a-x0,y-y0,b-x0-1,y-y0),fill=255)
    crop=im.crop(g['bbox']);crop.putalpha(ImageChops.multiply(crop.getchannel('A'),mask))
    return crop

def sample(t):
    keys=A['keys']
    if t<=0:return {k:np.array(v,dtype=float) for k,v in keys[0]['points'].items()}
    if t>=.72:return {k:np.array(v,dtype=float) for k,v in keys[-1]['points'].items()}
    i=0
    while i<len(keys)-2 and t>keys[i+1]['t']:i+=1
    a,b=keys[i:i+2];u=(t-a['t'])/(b['t']-a['t'])
    if a['mode']=='smooth':u=u*u*(3-2*u)
    p={k:np.array(v)*(1-u)+np.array(b['points'][k])*u for k,v in a['points'].items()}
    va=np.array(a['points']['sword_tip'])-a['points']['hand'];vb=np.array(b['points']['sword_tip'])-b['points']['hand']
    aa,bb=math.atan2(va[1],va[0]),math.atan2(vb[1],vb[0])
    angle=aa+math.atan2(math.sin(bb-aa),math.cos(bb-aa))*u
    p['sword_tip']=p['hand']+88*np.array([math.cos(angle),math.sin(angle)])
    return p

def place(canvas,im,center,size):
    im=im.resize(tuple(max(1,round(v)) for v in size),Image.Resampling.LANCZOS)
    xy=np.array(center)+ORIGIN-np.array(im.size)/2
    canvas.alpha_composite(im,(round(xy[0]),round(xy[1])))

def bone(canvas,im,a,b,width):
    a,b=np.array(a)+ORIGIN,np.array(b)+ORIGIN
    v=b-a;length=float(np.linalg.norm(v))
    if length<.01:return
    side=np.array([v[1],-v[0]])/length
    m=np.column_stack((side*width/im.width,v/im.height))
    offset=a-m[:,0]*im.width/2
    inv=np.linalg.inv(m);translation=-inv@offset
    coeff=(inv[0,0],inv[0,1],translation[0],inv[1,0],inv[1,1],translation[1])
    layer=im.transform((CELL,CELL),Image.Transform.AFFINE,coeff,Image.Resampling.BICUBIC)
    canvas.alpha_composite(layer)

raw=Image.open(ROOT/'raw/ai-strip-attempt01.png').convert('RGBA')
clean=Image.open(ROOT/'raw/ai-strip-attempt02-cleanup.png').convert('RGBA')
groups=components(clean)[:10]
assert len(groups)==10
groups=sorted(groups,key=lambda g:(round((g['bbox'][1]+g['bbox'][3])/2/400),g['bbox'][0]))
# Explicit layout repair: decode whole connected figures rather than chopping a failed grid.
top=sorted(groups,key=lambda g:g['bbox'][3])[:5]
bottom=[g for g in groups if not any(g is x for x in top)]
groups=sorted(top,key=lambda g:g['bbox'][0])+sorted(bottom,key=lambda g:g['bbox'][0])
feet=[g['bbox'][3] for g in groups]
row_pitch=float(np.median(feet[5:])-np.median(feet[:5]))
reference_foot=float(feet[0]);col_pitch=clean.width/5
# One manually documented guard head landmark, one group scale. No per-frame centering.
reference_head_y=123.0
global_scale=180/(reference_foot-reference_head_y)
ai=[];ai_metrics=[]
for i,g in enumerate(groups):
    im=component_crop(clean,g);x,y,_,_=g['bbox'];col,row=i%5,i//5
    global_anchor=np.array([col_pitch*(col+.5),reference_foot+row*row_pitch])
    xy=ORIGIN+(np.array([x,y])-global_anchor)*global_scale
    tile=Image.new('RGBA',(CELL,CELL))
    resized=im.resize((round(im.width*global_scale),round(im.height*global_scale)),Image.Resampling.LANCZOS)
    tile.alpha_composite(resized,(round(xy[0]),round(xy[1])));ai.append(tile)
    ai_metrics.append({'frame':i,'source_bbox':g['bbox'],'source_component_area':g['area'],'foot_error_world_y':(feet[i]-global_anchor[1])*global_scale})
ai_uncorrected=[im.copy() for im in ai]
ai[-1]=ai[0].copy() # One explicit endpoint reuse correction; raw last frame remains preserved.

sheet=Image.open(ROOT/'raw/rig-parts-attempt02-cleanup.png').convert('RGBA')
parts=[];part_metrics=[]
for i in range(16):
    x0=round((i%4)*sheet.width/4);y0=round((i//4)*sheet.height/4)
    cell=sheet.crop((x0,y0,round((i%4+1)*sheet.width/4),round((i//4+1)*sheet.height/4)))
    group=components(cell)[0];piece=component_crop(cell,group);parts.append(piece)
    part_metrics.append({'part_index':i,'cell_bbox':group['bbox'],'source_part_size':list(piece.size)})
    (OUT/'rig-parts').mkdir(exist_ok=True);piece.save(OUT/'rig-parts'/f'part-{i:02d}.png')

def rig(t):
    p=sample(t);im=Image.new('RGBA',(CELL,CELL))
    # The actual render is textured raster parts, not the earlier silhouette blocking rig.
    place(im,parts[15],p['head']+[-18,20],(28,62))
    for thigh,shin,boot,knee,ankle,hx in [(10,11,13,'knee_b','ankle_b',8),(8,9,12,'knee_a','ankle_a',-8)]:
        bone(im,parts[thigh],p['hip']+[hx,3],p[knee]+[0,5],16)
        bone(im,parts[shin],p[knee]+[0,-2],p[ankle]+[0,-13],13)
        place(im,parts[boot],p[ankle]+[7,-11],(26,23))
    bone(im,parts[2],p['hip']+[0,-8],p['hip']+[0,24],38)
    bone(im,parts[1],p['neck']+[0,-1],p['hip']+[0,7],39)
    # Shield arm is a separate pair of reusable textured cutouts.
    far_shoulder=p['shoulder']+[-5,2];far_elbow=(far_shoulder+p['shield'])/2+[-9,8]
    bone(im,parts[6],far_shoulder,far_elbow,12)
    bone(im,parts[7],far_elbow,p['shield'],11)
    place(im,parts[3],p['shield'],(31,46))
    place(im,parts[0],p['head']+[1,0],(29,37))
    # Reconstruct a constant two-bone sword arm from the original targets.
    shoulder,hand,hint=p['shoulder'],p['hand'],p['elbow']
    v=hand-shoulder;length=np.linalg.norm(v);side=np.array([-v[1],v[0]])/max(length,.001)
    h=math.sqrt(max(0,34**2-length**2/4));mid=(shoulder+hand)/2
    candidates=[mid+side*h,mid-side*h];elbow=min(candidates,key=lambda e:np.linalg.norm(e-hint))
    bone(im,parts[4],shoulder,elbow+[0,2],14)
    bone(im,parts[5],elbow,hand+(hand-elbow)/np.linalg.norm(hand-elbow)*3,12)
    sword_dir=(p['sword_tip']-hand)/88
    bone(im,parts[14],p['sword_tip'],hand-sword_dir*(88/9),20)
    return im

times=sorted(set([round(i/60,8) for i in range(44)]+[k['t'] for k in A['keys']]+[.72]))
rig_frames=[rig(t) for t in times]

def atlas(frames,name,cols):
    out=Image.new('RGBA',(cols*CELL,math.ceil(len(frames)/cols)*CELL))
    for i,im in enumerate(frames):out.alpha_composite(im,(i%cols*CELL,i//cols*CELL))
    out.save(OUT/(name+'.png'))
atlas(ai_uncorrected,'ai-extracted-before-endpoint',5)
atlas(ai,'ai-corrected',5)
atlas(rig_frames,'rig-cutout',8)
rig(.1).save(OUT/'rig-pose-load.png');rig(.21).save(OUT/'rig-pose-brake.png')
patch_board=Image.new('RGBA',(896,448));patch_board.alpha_composite(rig(.1),(0,0));patch_board.alpha_composite(rig(.21),(448,0));patch_board.save(OUT/'hybrid-repair-input.png')

# Fixed-grid extraction is retained as a rejected diagnostic; no hidden per-frame repair.
fixed=[]
for i in range(10):
    col,row=i%5,i//5
    cell=clean.crop((round(col*clean.width/5),round(row*clean.height/2),round((col+1)*clean.width/5),round((row+1)*clean.height/2)))
    tile=Image.new('RGBA',(448,448));scaled=cell.resize((round(cell.width*global_scale),round(cell.height*global_scale)),Image.Resampling.LANCZOS)
    tile.alpha_composite(scaled,(round(224-col_pitch/2*global_scale),round(400-reference_foot*global_scale)));fixed.append(tile)
atlas(fixed,'ai-fixed-grid-rejected',5)

metadata={'scope':'isolated A artwork trial; no combat integration','selected_motion':'A','ai_times':[k['t'] for k in A['keys']],'rig_times':times,'cell':[448,448],'foot_anchor':[224,400],'rig_parts':part_metrics,'ai_extraction':{'method':'largest connected alpha components; one group scale and row/column pitch; no per-frame recentering','alpha_component_threshold':127,'global_scale':global_scale,'row_pitch':row_pitch,'column_pitch':col_pitch,'reference_foot_y':reference_foot,'manually_annotated_guard_head_y':reference_head_y,'frames':ai_metrics,'endpoint_reused_frames':[9],'max_foot_drift_world_y':max(abs(m['foot_error_world_y']) for m in ai_metrics)},'rig_method':'15 calibrated raster parts plus ponytail; 2-bone arm; original continuous targets; 88px blade; no replacement drawings yet','corrections':{'AI_generation_attempts':2,'rig_part_generation_attempts':2,'rig_master_part_calibrations':16,'AI_endpoint_reuses':1,'AI_layout_decoders':1,'human_minutes':None},'remaining_defects':['Colored matte fringe remains in generated inputs','AI blade/body correspondence requires visual review','Rig seam/occlusion and material scale need visual review','Contact curves and real action transitions not adapted/tested'],'machine_build_seconds':time.perf_counter()-START}
if (ROOT/'raw/hybrid-repair-attempt01.png').exists():
    repair=Image.open(ROOT/'raw/hybrid-repair-attempt01.png').convert('RGBA')
    groups2=sorted(components(repair)[:2],key=lambda g:g['bbox'][0])
    hybrid=[im.copy() for im in rig_frames];repairs=[]
    # Two explicitly registered replacement drawings, not evidence of a fully repaired action.
    for j,(t,g) in enumerate(zip([.1,.21],groups2)):
        piece=component_crop(repair,g)
        alpha=np.asarray(piece.getchannel('A'))
        yy,xx=np.where(alpha[-8:]>127)
        sole_x=(float(xx.min())+float(xx.max()))/2
        reference_body_height=546.0
        replacement_scale=180/reference_body_height
        pose=sample(t)
        # Each replacement asset has an explicit registration; no automatic whole-animation recentering.
        x=224+(pose['ankle_a'][0]+pose['ankle_b'][0])/2-sole_x*replacement_scale
        y=400-piece.height*replacement_scale
        layer=Image.new('RGBA',(448,448))
        resized=piece.resize((round(piece.width*replacement_scale),round(piece.height*replacement_scale)),Image.Resampling.LANCZOS)
        layer.alpha_composite(resized,(round(x),round(y)))
        index=times.index(t)
        support=Image.new('L',(448,448));sd=ImageDraw.Draw(support)
        hx,hy=pose['head']+ORIGIN;px,py=pose['hip']+ORIGIN
        sd.rectangle((min(hx,px)-24,hy-23,max(hx,px)+24,py+12),fill=255)
        sd.line([tuple(pose[n]+ORIGIN) for n in ['shoulder','elbow','hand']],fill=255,width=20)
        sx,sy=pose['shield']+ORIGIN;sd.ellipse((sx-18,sy-26,sx+18,sy+26),fill=255)
        layer.putalpha(ImageChops.multiply(layer.getchannel('A'),support))
        hybrid[index].putalpha(ImageChops.multiply(hybrid[index].getchannel('A'),ImageChops.invert(support)))
        hybrid[index].alpha_composite(layer)
        hand,tip=pose['hand'],pose['sword_tip'];sword_dir=(tip-hand)/88
        bone(hybrid[index],parts[14],tip,hand-sword_dir*(88/9),20)
        repairs.append({'t':t,'frame_index':index,'source_bbox':g['bbox'],'calibrated_scale':replacement_scale,'translated_crop_origin':[x,y],'support_mask':'head/torso/arm/shield region only; rig retained below and outside; intact rig sword redrawn over repair'})
    atlas(hybrid,'hybrid-two-key-repair',8)
    metadata['hybrid']={'status':'executed limited two-key correction trial; residual seams/pops expected','replacement_drawings':repairs,'corrected_frames':2,'total_export_frames':len(times),'motion_correspondence':'same requested targets; generated replacement contours are not constrained rig geometry'}
    metadata['corrections']['hybrid_generation_attempts']=1
    metadata['corrections']['replacement_asset_registrations']=2
    metadata['corrections']['hybrid_compositing_repairs']=2
    metadata['remaining_defects'].append('Only two hybrid keys have replacement drawings; uncorrected inbetweens and patch boundary/style pops remain')
(OUT/'metrics.json').write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'AI_components':len(ai),'rig_frames':len(times),'AI_max_foot_drift_world_y':metadata['ai_extraction']['max_foot_drift_world_y'],'machine_build_seconds':metadata['machine_build_seconds']},indent=2))
