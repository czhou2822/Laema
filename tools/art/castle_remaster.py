#!/usr/bin/env python3
"""Castle original-pose remaster: reference preparation and technical PNG packing only.
Artwork must be drawn with imagegen; this program never upscales original sprites as deliverables.
"""
import argparse, hashlib, json, math, shutil, sys, tempfile
from functools import lru_cache
from pathlib import Path
from PIL import Image, ImageDraw
LOCATION=argparse.ArgumentParser(add_help=False)
LOCATION.add_argument('--root',type=Path,default=Path(__file__).resolve().parents[2])
LOCATION.add_argument('--plan',type=Path,default=Path('docs/art/remasters/castle-v01/generation-plan.json'))
LOCATION.add_argument('--work',type=Path,default=Path(tempfile.gettempdir())/'laema-castle-remaster')
_location,_unknown=LOCATION.parse_known_args()
ROOT=_location.root.resolve()
PLAN=_location.plan if _location.plan.is_absolute() else ROOT/_location.plan
WORK=_location.work.resolve()
DATA=json.loads(PLAN.read_text())
BASE_FOR={'halberdier':'pikeman','marksman':'archer','royal_griffin':'griffin','crusader':'swordsman','zealot':'monk','champion':'cavalier','archangel':'angel'}
CREATURES={c['creature_id']:c for c in DATA['creatures']}

def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def jwrite(p,x):
 p=Path(p);p.parent.mkdir(parents=True,exist_ok=True);p.write_text(json.dumps(x,indent=2)+'\n')
def rel(p):
 try:return str(Path(p).relative_to(ROOT))
 except ValueError:return str(p)
def get(c):
 if c not in CREATURES:raise ValueError('Unknown creature '+c)
 return CREATURES[c]
def dest(c):return ROOT/'assets/prototype/enemy'/c/'remaster_v01'
def scratch(c):return WORK/c
def posemap(c):return {p['pose_id']:p for p in get(c)['poses']}
def crop_region(path,r):
 x,y,w,h=r;return Image.open(ROOT/path).convert('RGBA').crop((x,y,x+w,y+h))
@lru_cache(maxsize=1024)
def original_body_rect_key(c,pid):
 p=posemap(c)[pid];r=p['representative'];im=crop_region(r['rgba_sheet'],r['sheet_cell_region'])
 bb=bbox(im,160)
 if not bb:raise ValueError('No opaque original body pixels '+pid)
 return {'left':bb[0],'top':bb[1],'width':bb[2]-bb[0],'height':bb[3]-bb[1],'alpha_threshold':160,'coordinate_space':'original registered 450x400 frame; shadow palette alpha excluded'}
def body_rect(c,p):return original_body_rect_key(c,p['pose_id'])
def original_pose(p):
 r=p['representative']; im=crop_region(r['rgba_sheet'],r['sheet_cell_region'])
 # Reference guide only: remove decoded semitransparent palette-shadow pixels.
 im.putalpha(im.getchannel('A').point(lambda v:v if v>160 else 0))
 bb=bbox(im,160)
 return im.crop(bb) if bb else im

def bbox(im,threshold=8):return im.getchannel('A').point(lambda v:255 if v>threshold else 0).getbbox()
def reference(c):
 ca=get(c); base=get(BASE_FOR.get(c,c));return base['existing_hi_res_identity_reference']
@lru_cache(maxsize=32)
def geometry(c):
 ca=get(c); cm=posemap(c);idle=body_rect(c,cm[ca['og_idle_reference_pose_id']]);ref=reference(c)
 ri=crop_region(ref['file'],ref['atlas_region']); rb=bbox(ri)
 cell=(768,512 if c=='pikeman' else 640)
 # Use corresponding base high-res idle height, then one global fit over every original pose.
 scale=(rb[3]-rb[1])/idle['height']
 ox=idle['left']+idle['width']/2; oy=idle['top']+idle['height']
 anchor=(384,448)
 limits=[]
 for po in ca['poses']:
  s=body_rect(c,po);l=s['left']-ox;r=l+s['width'];t=s['top']-oy;b=t+s['height']
  if l<0:limits.append((anchor[0]-16)/-l)
  if r>0:limits.append((cell[0]-anchor[0]-16)/r)
  if t<0:limits.append((anchor[1]-16)/-t)
  if b>0:limits.append((cell[1]-anchor[1]-16)/b)
 fitted=min([scale]+limits)
 return {'geometry_version':2,'original_body_alpha_threshold':160,'cell_size':list(cell),'columns':4,'anchor':list(anchor),'source_anchor':[ox,oy], 'uniform_scale':fitted,'idle_height_scale':scale,'scale_clamped_for_all_original_pose_extents':fitted<scale-1e-6,'registration':'One creature-wide uniform original-coordinate transform using opaque OG body bounds (alpha>160), excluding decoded palette shadows; generated/existing RGBA crop aspect-fits its original opaque body rectangle, centered horizontally and bottom-aligned; no stretching. Original durations unknown.'}
def write_guide(c,ids,path):
 # References only: enlarged nearest-neighbour native pixels show exact pose silhouettes.
 pm=posemap(c);cols=min(4,len(ids));rows=math.ceil(len(ids)/cols);cw,ch=512,512
 canvas=Image.new('RGB',(cols*cw,rows*ch),(38,43,50));d=ImageDraw.Draw(canvas)
 for i,pid in enumerate(ids):
  po=pm[pid];im=original_pose(po);bb=bbox(im)
  if bb:im=im.crop(bb)
  scale=min(440/im.width,440/im.height);im=im.resize((max(1,round(im.width*scale)),max(1,round(im.height*scale))),Image.Resampling.NEAREST)
  x=(i%cols)*cw+(cw-im.width)//2;y=(i//cols)*ch+42+(440-im.height)//2
  canvas.paste(im,(x,y),im);g=po['representative']['group_id'];f=po['representative']['frame_index']
  d.text(((i%cols)*cw+10,(i//cols)*ch+10),f'{i+1}: {pid} | OG group {g}, frame {f}',fill=(255,255,255))
 canvas.save(path)
 return cols,rows

def prepare(c):
 ca=get(c);sd=scratch(c);sd.mkdir(parents=True,exist_ok=True);dd=dest(c);dd.mkdir(parents=True,exist_ok=True)
 for sub in ['poses','_source']:
  (dd/sub).mkdir(exist_ok=True);(dd/sub/'.gdignore').write_text('')
 ref=reference(c);ri=crop_region(ref['file'],ref['atlas_region']);identity=sd/'appearance-reference.png';ri.save(identity)
 ogidle=sd/'og-idle-reference.png';write_guide(c,[ca['og_idle_reference_pose_id']],ogidle)
 batches=[]
 for bi,ids in enumerate(ca['suggested_generation_batches_of_eight']):
  guide=sd/f'batch-{bi:02d}-og-reference.png';cols,rows=write_guide(c,ids,guide)
  batch={'creature_id':c,'batch_index':bi,'pose_ids':ids,'cols':cols,'rows':rows,'guide':str(guide),'appearance_reference':str(identity),'og_idle_reference':str(ogidle),'generated_output_expected':'Transparent RGBA grid, exactly one separately drawn remastered pose in every occupied reference cell; no labels, shadows, background or separators. Same row-major pose order. Original pixels are pose reference only; do not enlarge pixel art as output.'}
  jwrite(sd/f'batch-{bi:02d}.json',batch);batches.append(batch)
 out={'creature':ca['creature'],'creature_id':c,'upgraded':ca['upgraded'],'geometry':geometry(c),'appearance_reference':str(identity),'og_idle_reference':str(ogidle),'batches':batches,'note':'Upgraded creatures must follow their OG design/colors; appearance-reference is base counterpart style only. Generate upgraded identity before remaining batches if needed.'}
 jwrite(sd/'preparation.json',out);return out

def registered(c,p,art):
 bb=bbox(art)
 if not bb:raise ValueError('Empty artwork '+p['pose_id'])
 art=art.crop(bb);g=geometry(c);s=body_rect(c,p);sc=g['uniform_scale'];ox,oy=g['source_anchor'];ax,ay=g['anchor'];cw,ch=g['cell_size']
 target_w=max(1,round(s['width']*sc));target_h=max(1,round(s['height']*sc));fit=min(target_w/art.width,target_h/art.height)
 # Existing/new high-res artwork may downsample or modestly scale to shared native registration; no OG artwork enters here.
 size=(max(1,round(art.width*fit)),max(1,round(art.height*fit)));art=art.resize(size,Image.Resampling.LANCZOS)
 x=round(ax+(s['left']+s['width']/2-ox)*sc-size[0]/2);y=round(ay+(s['top']+s['height']-oy)*sc-size[1])
 if x<0 or y<0 or x+size[0]>cw or y+size[1]>ch:raise ValueError('Registered artwork outside cell '+p['pose_id'])
 out=Image.new('RGBA',(cw,ch));out.alpha_composite(art,(x,y));return out

def grid_boundaries(raw,n,axis,adaptive):
 length=raw.width if axis==0 else raw.height
 cuts=[0]
 for i in range(1,n):
  nominal=round(i*length/n);chosen=nominal
  if adaptive:
   # A transparent gutter across the entire row/column cannot sever any sprite.
   radius=max(2,round(length/n*.18));lo=max(cuts[-1]+2,nominal-radius);hi=min(length-2,nominal+radius)
   alpha=raw.getchannel('A').point(lambda v:255 if v>16 else 0)
   zeros=[]
   for q in range(lo,hi+1):
    strip=alpha.crop((q,0,q+1,raw.height) if axis==0 else (0,q,raw.width,q+1))
    if strip.getbbox() is None:zeros.append(q)
   runs=[]
   for q in zeros:
    if not runs or q>runs[-1][-1]+1:runs.append([q])
    else:runs[-1].append(q)
   if runs:
    # Choose the nearest clear gutter, staying close to the requested grid.
    run=min(runs,key=lambda r:abs((r[0]+r[-1])/2-nominal))
    chosen=round((run[0]+run[-1])/2)
  cuts.append(chosen)
 cuts.append(length);return cuts

def isolate_components(raw,cols,rows,count):
 import numpy as np
 from scipy import ndimage
 from scipy.optimize import linear_sum_assignment
 rgba=np.asarray(raw);alpha=rgba[:,:,3];lab,n=ndimage.label(alpha>8,structure=np.ones((3,3)));sizes=np.bincount(lab.ravel());ordered=np.argsort(sizes[1:])[::-1]+1
 if len(ordered)<count:raise ValueError('Too few separate foreground figures for component isolation')
 prim=ordered[:count]
 if sizes[prim[-1]]<max(300,raw.width*raw.height*.0006):raise ValueError('Missing figure or ambiguous small primary component')
 if len(ordered)>count and sizes[ordered[count]]>sizes[prim[-1]]*.20:raise ValueError('Ambiguous extra large component; inspect sprite/page counts')
 centers=[]
 for q in prim:
  ys,xs=np.where(lab==q);centers.append(((xs.min()+xs.max()+1)/2/raw.width*cols,(ys.min()+ys.max()+1)/2/raw.height*rows))
 targets=[(i%cols+.5,i//cols+.5) for i in range(count)]
 costs=np.array([[(x-tx)**2+(y-ty)**2 for tx,ty in targets] for x,y in centers]);r,c=linear_sum_assignment(costs)
 if any(costs[ri,ci]>.60 for ri,ci in zip(r,c)):raise ValueError('Figures too far from requested row-major grid; inspect pose order')
 primary=np.zeros(lab.shape,dtype=np.int32)
 for ri,ci in zip(r,c):primary[lab==prim[ri]]=int(ci)+1
 # Attribute antialias fringe and tiny detached details to the nearest whole figure.
 nearest=ndimage.distance_transform_edt(primary==0,return_distances=False,return_indices=True)
 owner=primary[nearest[0],nearest[1]]
 outputs=[]
 for i in range(count):
  arr=rgba.copy();arr[:,:,3]=np.where(owner==i+1,alpha,0);im=Image.fromarray(arr,'RGBA');bb=bbox(im,16)
  if not bb:raise ValueError('Empty isolated figure')
  if bb[0]<=0 or bb[1]<=0 or bb[2]>=raw.width or bb[3]>=raw.height:raise ValueError('Actual global image-edge clipping on component '+str(i+1))
  # A transparent pad makes the standard per-cell edge check meaningful after isolation.
  crop=im.crop(bb);padded=Image.new('RGBA',(crop.width+4,crop.height+4));padded.alpha_composite(crop,(2,2));outputs.append((padded,list(bb),int(prim[list(c).index(i)]),int(sizes[prim[list(c).index(i)]])))
 return outputs

def ingest(c,bi,image,cols=None,rows=None,pose_ids=None,adaptive_grid=False,components=False):
 ca=get(c);sd=scratch(c);dd=dest(c)
 if not (sd/'preparation.json').exists():prepare(c)
 if pose_ids:ids=pose_ids.split(',')
 else:ids=ca['suggested_generation_batches_of_eight'][int(bi)]
 cols=cols or min(4,len(ids));rows=rows or math.ceil(len(ids)/cols);pm=posemap(c)
 if len(ids)>cols*rows:raise ValueError('Grid capacity too small')
 raw=Image.open(image).convert('RGBA');amin,amax=raw.getchannel('A').getextrema()
 if amin!=0 or amax<128:raise ValueError('Expected real transparent RGBA artwork')
 # Preflight every crop before changing depot to keep a failed batch atomic.
 pieces=[]
 xcuts=grid_boundaries(raw,cols,0,adaptive_grid);ycuts=grid_boundaries(raw,rows,1,adaptive_grid)
 rowcuts_by_column=[grid_boundaries(raw.crop((xcuts[q],0,xcuts[q+1],raw.height)),rows,1,True) if adaptive_grid else ycuts for q in range(cols)]
 isolated=isolate_components(raw,cols,rows,len(ids)) if components else None
 for i,pid in enumerate(ids):
  if pid not in pm:raise ValueError('Unknown pose '+pid)
  l=xcuts[i%cols];r=xcuts[(i%cols)+1];t=rowcuts_by_column[i%cols][i//cols];b=rowcuts_by_column[i%cols][(i//cols)+1]
  im=isolated[i][0] if isolated else raw.crop((l,t,r,b));bb=bbox(im,16)
  if not bb:raise ValueError('Empty grid cell '+pid)
  # Exact edge coverage indicates a severed sprite or opaque grid; do not silently ship it.
  if bb[0]<=0 or bb[1]<=0 or bb[2]>=im.width or bb[3]>=im.height:raise ValueError('Artwork touches cell edge; inspect/regenerate '+pid+' bbox='+str(bb))
  region=([isolated[i][1][0],isolated[i][1][1],isolated[i][1][2]-isolated[i][1][0],isolated[i][1][3]-isolated[i][1][1]] if isolated else [l,t,r-l,b-t])
  pieces.append((pid,im,registered(c,pm[pid],im),region,list(bb)))
 source=dd/'_source'/f'batch-{int(bi):02d}-{digest(image)[:12]}.png';shutil.copyfile(image,source)
 for pid,im,out,region,bb in pieces:
  fp=dd/'poses'/(pid+'.png');out.save(fp)
  provenance={'pose_id':pid,'artwork_origin':'imagegen-generated remaster based on original pose','generated_source_file':rel(source),'generated_source_sha256':digest(source),'source_grid':[cols,rows],'component_isolation':components,'source_grid_boundaries':{'x':xcuts,'y':ycuts,'y_by_column':rowcuts_by_column,'adaptive_transparent_gutter_search':adaptive_grid},'source_grid_region':region,'source_grid_region_format':'xywh','source_alpha_bbox':bb,'registered_pose_file':rel(fp),'registered_pose_png_sha256':digest(fp),'original_signature':pm[pid]['original_signature'],'registration_geometry_version':2,'original_opaque_body_rect':body_rect(c,pm[pid]),'original_representative':pm[pid]['representative'],'review_status':'Generated candidate; technical alignment applied. Exact limb/gear fidelity and sequence playback require visual review; original timings unavailable.'}
  if components:
   isolated_source=dd/'_source'/f'batch-{int(bi):02d}-{pid}-isolated.png';im.save(isolated_source);provenance['isolated_source_file']=rel(isolated_source);provenance['isolated_source_sha256']=digest(isolated_source);provenance['isolation_method']='Alpha connected components: dominant complete figures assigned one-to-one to row-major cells; tiny disconnected details and existing antialias alpha assigned nearest figure, no drawn or recolored pixels. Padding added only outside extracted artwork.'
  jwrite(dd/'poses'/(pid+'.json'),provenance)
 return {'creature':c,'ingested_pose_ids':ids,'raw_source':rel(source),'raw_size':list(raw.size),'component_isolation':components,'grid_boundaries':{'x':xcuts,'y':ycuts,'y_by_column':rowcuts_by_column,'adaptive_transparent_gutter_search':adaptive_grid}}

def reuse(c):
 dd=dest(c);(dd/'poses').mkdir(parents=True,exist_ok=True);(dd/'poses'/'.gdignore').write_text('');count=0
 for p in get(c)['poses']:
  fp=dd/'poses'/(p['pose_id']+'.png');jp=fp.with_suffix('.json')
  if fp.exists() and jp.exists():continue
  cand=p.get('preferred_existing_hires_candidate')
  if not cand:continue
  art=crop_region(cand['file'],cand['atlas_region']);out=registered(c,p,art);out.save(fp)
  jwrite(jp,{'pose_id':p['pose_id'],'artwork_origin':'existing high-resolution remaster candidate reused','existing_source':cand,'existing_source_png_sha256':digest(ROOT/cand['file']),'registered_pose_file':rel(fp),'registered_pose_png_sha256':digest(fp),'original_signature':p['original_signature'],'registration_geometry_version':2,'original_opaque_body_rect':body_rect(c,p),'original_representative':p['representative'],'review_status':'Existing candidate; source-order mapping proven, exact visual parity not certified.'});count+=1
 return count

def reregister(c):
 dd=dest(c);count=0
 for p in get(c)['poses']:
  fp=dd/'poses'/(p['pose_id']+'.png');jp=fp.with_suffix('.json')
  if not jp.exists():continue
  provenance=json.loads(jp.read_text())
  if provenance.get('component_isolation') and not provenance.get('source_grid_region_format'):
   l,t,r,b=provenance['source_grid_region'];provenance['source_grid_region']=[l,t,r-l,b-t];provenance['source_grid_region_format']='xywh'
  if provenance['artwork_origin'].startswith('existing'):
   src=provenance['existing_source'];art=crop_region(src['file'],src['atlas_region'])
  elif provenance.get('isolated_source_file'):
   art=Image.open(ROOT/provenance['isolated_source_file']).convert('RGBA')
  else:
   src=provenance['generated_source_file'];art=crop_region(src,provenance['source_grid_region'])
  out=registered(c,p,art);out.save(fp);provenance.update({'registered_pose_png_sha256':digest(fp),'registration_geometry_version':2,'original_opaque_body_rect':body_rect(c,p)});jwrite(jp,provenance);count+=1
 return count

def build(c):
 ca=get(c);dd=dest(c);dd.mkdir(parents=True,exist_ok=True);reuse(c);reregister(c);pm=posemap(c);g=geometry(c);cw,ch=g['cell_size'];manifest={'schema_version':1,'creature':ca['creature'],'creature_id':c,'original_def_id':ca['original_def_id'],'original_metadata':ca['original_metadata'],'original_metadata_sha256':digest(ROOT/ca['original_metadata']),'generation_plan_sha256':digest(PLAN),'geometry':g,'original_timing':'Not encoded by DEF extraction; no invented timing or gameplay state assignment. Group sheets preserve every source frame in order.','quality_status':'Generated/reused art candidates; technical coverage is not visual parity certification.','original_group_slots':ca['original_group_slots'],'original_frame_positions':ca['original_frame_positions'],'unique_registered_poses':ca['unique_registered_poses'],'groups':[],'poses':[]}
 missing=[]
 for p in ca['poses']:
  fp=dd/'poses'/(p['pose_id']+'.png');jp=fp.with_suffix('.json')
  if not fp.exists() or not jp.exists():missing.append(p['pose_id'])
  else:manifest['poses'].append(json.loads(jp.read_text()))
 for group in ca['groups']:
  ids=group['pose_ids_in_source_order'];absent=[x for x in ids if x in missing];entry=dict(group);entry['missing_pose_ids']=absent;entry['complete']=not absent
  if not absent:
   rows=math.ceil(len(ids)/4);out=Image.new('RGBA',(cw*4,ch*rows))
   for i,pid in enumerate(ids):out.alpha_composite(Image.open(dd/'poses'/(pid+'.png')).convert('RGBA'),((i%4)*cw,(i//4)*ch))
   fp=dd/f"group_{group['group_id']:02d}_block_{group['original_block']:02d}.png";out.save(fp)
   entry.update({'file':rel(fp),'sha256':digest(fp),'atlas_size':list(out.size),'columns':4,'cell_size':[cw,ch],'anchor':g['anchor'],'frame_regions':[[i%4*cw,i//4*ch,cw,ch] for i in range(len(ids))],'padding_frames':rows*4-len(ids)})
  manifest['groups'].append(entry)
 manifest['coverage']={'complete_groups':sum(x['complete'] for x in manifest['groups']),'total_groups':len(manifest['groups']),'available_poses':len(manifest['poses']),'total_poses':len(ca['poses']),'missing_pose_ids':missing,'generated_poses':sum(x['artwork_origin'].startswith('imagegen') for x in manifest['poses']),'reused_poses':sum(x['artwork_origin'].startswith('existing') for x in manifest['poses'])}
 jwrite(dd/'source_manifest.json',manifest);return manifest['coverage']

def validate(c):
 dd=dest(c);mp=dd/'source_manifest.json'
 if not mp.exists():return {'creature':c,'errors':['No source_manifest.json']}
 m=json.loads(mp.read_text());errors=[];checks=0
 for p in m['poses']:
  fp=ROOT/p['registered_pose_file']
  if not fp.exists() or digest(fp)!=p['registered_pose_png_sha256']:errors.append('Pose missing/hash mismatch '+p['pose_id']);continue
  im=Image.open(fp).convert('RGBA');bb=bbox(im)
  if tuple(im.size)!=tuple(m['geometry']['cell_size']) or not bb:errors.append('Bad pose geometry '+p['pose_id'])
 for gr in m['groups']:
  if not gr['complete']:continue
  fp=ROOT/gr['file'];im=Image.open(fp).convert('RGBA')
  if digest(fp)!=gr['sha256']:errors.append('Atlas hash mismatch '+str(gr['group_id']))
  for i,pid in enumerate(gr['pose_ids_in_source_order']):
   x,y,w,h=gr['frame_regions'][i];a=im.crop((x,y,x+w,y+h));b=Image.open(dd/'poses'/(pid+'.png')).convert('RGBA')
   if a.tobytes()!=b.tobytes():errors.append('Atlas order/cell mismatch '+str(gr['group_id'])+':'+str(i))
   checks+=1
  w,h=gr['cell_size'];n=len(gr['pose_ids_in_source_order'])
  for i in range(n,math.ceil(n/4)*4):
   if im.crop((i%4*w,i//4*h,(i%4+1)*w,(i//4+1)*h)).getbbox():errors.append('Nontransparent padding '+str(gr['group_id']))
 return {'creature':c,'coverage':m['coverage'],'frame_cells_verified':checks,'errors':errors}

def spriteframes(c):
 ca=get(c);dd=dest(c);dd.mkdir(parents=True,exist_ok=True);g=geometry(c);cw,ch=g['cell_size'];groups=ca['groups']
 total=sum(gr['frame_count'] for gr in groups);lines=[f'[gd_resource type="SpriteFrames" load_steps={1+len(groups)+total} format=3]', '']
 for i,gr in enumerate(groups,1):
  path=f"res://assets/prototype/enemy/{c}/remaster_v01/group_{gr['group_id']:02d}_block_{gr['original_block']:02d}.png"
  lines.append(f'[ext_resource type="Texture2D" path="{path}" id="{i}"]')
 lines.append('')
 for i,gr in enumerate(groups,1):
  for f in range(gr['frame_count']):
   sid=f"AtlasTexture_g{gr['group_id']:02d}_b{gr['original_block']:02d}_f{f:02d}"
   lines.extend([f'[sub_resource type="AtlasTexture" id="{sid}"]',f'atlas = ExtResource("{i}")',f'region = Rect2({f%4*cw}, {f//4*ch}, {cw}, {ch})',''])
 lines.extend(['[resource]',f'resource_name = "Castle {ca["creature"]} original-group remaster previews"','metadata/preview_timing_status = "Provisional 10 fps editor preview; original DEF extraction has no frame timing. This resource is not a gameplay state machine."','metadata/original_timing_verified = false','metadata/preview_only = true','metadata/source_order_preserved = true','animations = ['])
 for gi,gr in enumerate(groups):
  lines.extend(['{','"frames": ['])
  for f in range(gr['frame_count']):
   sid=f"AtlasTexture_g{gr['group_id']:02d}_b{gr['original_block']:02d}_f{f:02d}"
   lines.append('{"duration": 1.0, "texture": SubResource("'+sid+'")}'+(',' if f<gr['frame_count']-1 else ''))
  lines.extend(['],','"loop": '+('true' if gr['group_id'] in [0,2] else 'false')+',',f'"name": &"og_{gr["group_id"]:02d}_block_{gr["original_block"]:02d}",','"speed": 10.0','}'+(',' if gi<len(groups)-1 else '')])
 lines.append(']');fp=dd/'original_groups.tres';fp.write_text('\n'.join(lines)+'\n')
 return {'creature':c,'resource':rel(fp),'groups':len(groups),'frames':total,'preview_fps':10,'original_timing_verified':False}

def main():
 ap=argparse.ArgumentParser(parents=[LOCATION]);ap.add_argument('command',choices=['prepare','ingest','build','validate','inspect','spriteframes']);ap.add_argument('creature');ap.add_argument('batch',nargs='?');ap.add_argument('image',nargs='?');ap.add_argument('--cols',type=int);ap.add_argument('--rows',type=int);ap.add_argument('--pose-ids');ap.add_argument('--adaptive-grid',action='store_true');ap.add_argument('--components',action='store_true');args=ap.parse_args()
 if args.command=='prepare':result=prepare(args.creature)
 elif args.command=='ingest':result=ingest(args.creature,args.batch,args.image,args.cols,args.rows,args.pose_ids,args.adaptive_grid,args.components)
 elif args.command=='build':result=build(args.creature)
 elif args.command=='spriteframes':result=[spriteframes(c) for c in CREATURES] if args.creature=='all' else spriteframes(args.creature)
 elif args.command=='validate':result=[validate(c) for c in CREATURES] if args.creature=='all' else validate(args.creature)
 else:result={k:v for k,v in get(args.creature).items() if k not in ['poses','groups']}
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
