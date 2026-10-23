#!/usr/bin/env python3
"""Necropolis source-pose remasters. Packing only: artwork is supplied separately.

Adapted from the pinned Castle workflow at f6d2c8ec38568597a72090dd3a6045117cbf8be7.
No drawing backend, original-pixel upscale deliverable, or gameplay assignment.
"""
import argparse
import csv
import hashlib
import io
import json
import math
import shutil
import sys
from functools import lru_cache
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[2]
DOC = Path('docs/art/remasters/necropolis-v01')
MASTERS = Path('docs/art/production/necropolis-creature-assets-v01')
ORIGINALS = Path('docs/art/references/heroes3-original-flipbooks')
CELL = (1024, 768)
ANCHOR = (512, 512)
SOURCE_ANCHOR = (196, 268)
SCALE = 180 / 73
CASTLE_COMMIT = 'f6d2c8ec38568597a72090dd3a6045117cbf8be7'
PLAN = DOC / 'generation-plan.json'
ROLES = {0:'movement',1:'idle gesture',2:'idle',3:'hurt',4:'defensive reaction',5:'death',6:'alternate death',7:'turn part 1',8:'turn part 2',9:'legacy turn',10:'legacy turn',11:'melee upper',12:'melee front',13:'melee lower',14:'ranged-numbered upper slot',15:'ranged-numbered front slot',16:'ranged-numbered lower slot',17:'special upper slot',18:'special front slot',19:'special lower slot',20:'movement start',21:'movement end'}

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def read(path):
    return json.loads(Path(path).read_text(encoding='utf-8-sig'))

def write(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary=path.with_name(path.name+'.tmp')
    temporary.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')
    temporary.replace(path)

def rel(path):
    return Path(path).resolve().relative_to(ROOT.resolve()).as_posix()

def abs_path(path):
    path = Path(path)
    return path if path.is_absolute() else ROOT / path

def signature(f):
    return ':'.join(str(f[k]) for k in ['index_sha256','left','top','width','height','full_width','full_height'])

def bbox(image, threshold=8):
    return image.getchannel('A').point(lambda x:255 if x>threshold else 0).getbbox()

def crop(image, region):
    x,y,w,h = region
    return image.crop((x,y,x+w,y+h))

@lru_cache(maxsize=8)
def rgba(path):
    return Image.open(abs_path(path)).convert('RGBA')

def original(pose):
    r = pose['representative']
    return crop(rgba(r['rgba_sheet']), r['sheet_cell_region']).copy()

def opaque_reference(pose):
    im = original(pose)
    im.putalpha(im.getchannel('A').point(lambda a:a if a>160 else 0))
    return im

def projected_original(pose):
    return opaque_reference(pose).transform(CELL, Image.Transform.AFFINE,
        (1/SCALE,0,SOURCE_ANCHOR[0]-ANCHOR[0]/SCALE,0,1/SCALE,SOURCE_ANCHOR[1]-ANCHOR[1]/SCALE),
        resample=Image.Resampling.NEAREST)

def geometry():
    return {'geometry_version':2,'cell_size':list(CELL),'columns':4,'anchor':list(ANCHOR),
        'source_anchor':list(SOURCE_ANCHOR),'uniform_scale':SCALE,'original_body_alpha_threshold':160,
        'registration':'Fixed shared source-coordinate transform. RGBA artwork aspect-fits opaque native body bounds; horizontal center and bottom follow native coordinates; no stretching or per-action normalization.'}

def load_plan():
    return read(abs_path(PLAN))

def creature(cid):
    matches = [c for c in load_plan()['creatures'] if c['creature_id']==cid]
    if len(matches)!=1:
        raise ValueError('Unknown creature: '+cid)
    return matches[0]

def dest(cid):
    return ROOT / 'assets/prototype/enemy' / cid / 'remaster_v01'

def posemap(c):
    return {p['pose_id']:p for p in c['poses']}

def initialize(cid):
    dd = dest(cid)
    for sub in ['poses','_source','frames','previews','contacts']:
        directory = dd / sub
        directory.mkdir(parents=True, exist_ok=True)
        (directory/'.gdignore').touch()
    attributes=dd/'.gitattributes'
    if not attributes.exists():
        attributes.write_text('# Keep raw prompts, provenance and generated asset bytes exact.\n* -text\n*.png binary\n*.gif binary\n')
    return dd

def make_plan():
    source = read(ROOT/MASTERS/'source-inventory.json')
    selected = read(ROOT/MASTERS/'selected-masters.json')
    result = {'schema_version':1,'scope':'All original Necropolis base/upgraded creature groups',
        'original_root':ORIGINALS.as_posix(),'master_baseline_commit':'72bfc2853ac4258391be6a3c905b62328cac53ee',
        'castle_workflow_commit':CASTLE_COMMIT,'geometry':geometry(),'original_timing_verified':False,'creatures':[]}
    approved = []
    for unit in source['roster']:
        slug = unit['slug']; cid = slug.replace('-','_')
        job = read(ROOT/MASTERS/slug/'job.json')
        md = (ROOT/MASTERS/job['source_metadata']).resolve()
        native = read(md)
        original_def = (ROOT/MASTERS/job['original_def']).resolve()
        if sha(original_def)!=job['original_def_sha256'] or sha(md)!=job['source_metadata_sha256']:
            raise ValueError('Original changed: '+cid)
        chosen = next(x for x in selected['entries'] if x['slug']==slug)
        master = ROOT/MASTERS/chosen['master']
        if sha(master)!=chosen['master_sha256']:
            raise ValueError('Approved master hash mismatch: '+cid)
        by_signature = {}; poses = []; groups = []
        for g in native['groups']:
            ids = []
            for f in g['frames']:
                key = signature(f)
                pg = g['pages'][f['page']]
                r = {'group_id':g['id'],'original_block':g['block'],'frame_index':f['index'],
                    'rgba_sheet':rel(md.parent/pg['preview']),'indexed_sheet':rel(md.parent/pg['indexed']),
                    'sheet_cell_region':[f['x'],f['y'],g['cell_width'],g['cell_height']],
                    'source_record':f}
                if key not in by_signature:
                    pid = f'{cid}_p{len(poses):03d}'
                    p = {'pose_id':pid,'original_signature':key,'representative':r,'occurrences':[]}
                    bb = bbox(original(p),160)
                    if not bb: raise ValueError('No opaque body: '+pid)
                    p['opaque_body_rect'] = [bb[0],bb[1],bb[2]-bb[0],bb[3]-bb[1]]
                    mapped = [ANCHOR[0]+(bb[0]-196)*SCALE,ANCHOR[1]+(bb[1]-268)*SCALE,
                              ANCHOR[0]+(bb[2]-196)*SCALE,ANCHOR[1]+(bb[3]-268)*SCALE]
                    if mapped[0]<40 or mapped[1]<40 or mapped[2]>984 or mapped[3]>728:
                        raise ValueError('Original body does not fit padded cell: '+pid)
                    poses.append(p); by_signature[key] = p
                p = by_signature[key]
                p['occurrences'].append(r)
                ids.append(p['pose_id'])
            groups.append({'group_id':g['id'],'original_block':g['block'],
                'purpose_interpretation':ROLES.get(g['id'],'unknown original slot'),
                'original_timing_verified':False,'frame_count':len(ids),'pose_ids_in_source_order':ids,
                'original_group_record':g})
        for group in groups:
            group['exact_aliases'] = [h['group_id'] for h in groups if h is not group and h['pose_ids_in_source_order']==group['pose_ids_in_source_order']]
        idle_group = next(g for g in groups if g['group_id']==2)
        c = {'creature':unit['name'],'creature_id':cid,'master_slug':slug,'original_def_id':unit['source_id'],
            'original_metadata':rel(md),'original_metadata_sha256':sha(md),
            'original_def':rel(original_def),'original_def_sha256':sha(original_def),
            'appearance_reference':rel(master),'appearance_reference_sha256':sha(master),
            'appearance_reference_approved':True,'og_idle_reference_pose_id':idle_group['pose_ids_in_source_order'][0],
            'original_group_slots':len(groups),'original_frame_positions':sum(g['frame_count'] for g in groups),
            'unique_registered_poses':len(poses),'geometry':geometry(),'groups':groups,'poses':poses}
        result['creatures'].append(c)
        approved.append({'creature_id':cid,'master':rel(master),'sha256':sha(master),'source_commit':result['master_baseline_commit']})
    result['totals'] = {'creatures':len(result['creatures']),
        'groups':sum(c['original_group_slots'] for c in result['creatures']),
        'frame_positions':sum(c['original_frame_positions'] for c in result['creatures']),
        'registered_source_signatures':sum(c['unique_registered_poses'] for c in result['creatures'])}
    if result['totals']!={'creatures':14,'groups':228,'frame_positions':1378,'registered_source_signatures':856}:
        raise ValueError('Inventory totals changed: '+str(result['totals']))
    write(abs_path(PLAN),result)
    write(ROOT/DOC/'master-approval.json',{'appearance_approved':True,'animation_approved':False,
        'authority':'User selected Use current 14 as approved appearance references, then explicitly requested implementation of the full plan.',
        'date_hong_kong':'2026-10-23','entries':approved})
    return result['totals']

def guide(cid, ids, name):
    c = creature(cid); pm = posemap(c); dd = initialize(cid)
    columns = min(4,len(ids)); rows = math.ceil(len(ids)/columns)
    sheet = Image.new('RGB',(512*columns,512*rows),(28,39,49)); draw = ImageDraw.Draw(sheet)
    for i,pid in enumerate(ids):
        p = pm[pid]; im = opaque_reference(p); im = im.crop(bbox(im,160))
        im.thumbnail((440,440),Image.Resampling.NEAREST)
        # Upscale native pixels only in the explicitly labeled reference guide.
        s = min(440/im.width,440/im.height)
        im = im.resize((round(im.width*s),round(im.height*s)),Image.Resampling.NEAREST)
        x = (i%columns)*512+(512-im.width)//2; y = (i//columns)*512+45+(440-im.height)//2
        sheet.paste(im,(x,y),im)
        r = p['representative']; draw.text(((i%columns)*512+10,(i//columns)*512+10),f'{i+1}: {pid} / OG G{r["group_id"]} F{r["frame_index"]}',fill='white')
    output = dd/'_source/guides'/f'{name}.png'; output.parent.mkdir(parents=True,exist_ok=True);sheet.save(output)
    request = {'creature_id':cid,'pose_ids':ids,'columns':columns,'rows':rows,'guide':rel(output),
        'appearance_reference':c['appearance_reference'],'appearance_reference_sha256':c['appearance_reference_sha256'],
        'purpose':'Reference only. Generate newly drawn transparent figures in exactly this row-major source-pose order. Appearance is not pose authority.'}
    write(output.with_suffix('.json'),request)
    return request

def prepare(cid):
    c = creature(cid); dd = initialize(cid)
    shutil.copy2(ROOT/c['appearance_reference'],dd/'_source/appearance-master.png')
    pending = [p['pose_id'] for p in c['poses'] if not (dd/'poses'/(p['pose_id']+'.json')).exists()]
    batches = [guide(cid,pending[i:i+8],f'batch-{i//8:03d}') for i in range(0,len(pending),8)]
    write(dd/'_source/preparation.json',{'creature_id':cid,'geometry':geometry(),'pending_pose_ids':pending,'batches':batches})
    return {'creature_id':cid,'pending_poses':len(pending),'batches':len(batches)}

def register(p, artwork):
    bb = bbox(artwork)
    if not bb: raise ValueError('Empty artwork: '+p['pose_id'])
    artwork = artwork.crop(bb)
    x,y,w,h = p['opaque_body_rect'];tw=max(1,round(w*SCALE));th=max(1,round(h*SCALE))
    fit = min(tw/artwork.width,th/artwork.height)
    size = (max(1,round(artwork.width*fit)),max(1,round(artwork.height*fit)))
    im = artwork.resize(size,Image.Resampling.LANCZOS)
    xx = round(ANCHOR[0]+(x+w/2-196)*SCALE-size[0]/2)
    yy = round(ANCHOR[1]+(y+h-268)*SCALE-size[1])
    if xx<40 or yy<40 or xx+size[0]>984 or yy+size[1]>728:
        raise ValueError('Insufficient padding: '+p['pose_id'])
    out = Image.new('RGBA',CELL);out.alpha_composite(im,(xx,yy))
    return out,{'source_body_rect':p['opaque_body_rect'],'artwork_crop':list(bb),'registered_rect':[xx,yy,*size], 'uniform_artwork_fit':fit}

def boundaries(im,n,axis,adaptive):
    length = im.width if axis==0 else im.height
    cuts = [0]
    alpha = im.getchannel('A').point(lambda a:255 if a>16 else 0)
    for i in range(1,n):
        center = round(length*i/n)
        options = [center]
        if adaptive:
            radius = max(4,round(length/n*.18))
            options = sorted(range(max(cuts[-1]+4,center-radius),min(length-4,center+radius)+1),key=lambda k:abs(k-center))
        valid = [q for q in options if alpha.crop((q-1,0,q+1,im.height) if axis==0 else (0,q-1,im.width,q+1)).getbbox() is None]
        if not valid: raise ValueError('No clear transparent gutter; regenerate individual poses instead of clipping')
        cuts.append(valid[0])
    return cuts+[length]

def isolate_components(raw,cols,rows,count):
    """Castle's strict alpha component assignment; no drawing or recoloring."""
    try:
        import numpy as np
        from scipy import ndimage
        from scipy.optimize import linear_sum_assignment
    except ImportError as error:
        raise RuntimeError('Optional component isolation requires NumPy/SciPy. Supply an installed dependency path or use the default Pillow-only clear-gutter/single-pose route.') from error
    array=np.asarray(raw);alpha=array[:,:,3]
    labels,_=ndimage.label(alpha>8,structure=np.ones((3,3)))
    sizes=np.bincount(labels.ravel());ordered=np.argsort(sizes[1:])[::-1]+1
    if len(ordered)<count:raise ValueError('Too few independent foreground figures')
    primary_ids=ordered[:count]
    if sizes[primary_ids[-1]]<max(300,raw.width*raw.height*.0006):raise ValueError('Missing figure or ambiguous primary component')
    if len(ordered)>count and sizes[ordered[count]]>sizes[primary_ids[-1]]*.20:raise ValueError('Ambiguous extra large component; inspect instead of guessing')
    centers=[]
    for label in primary_ids:
        yy,xx=np.where(labels==label)
        centers.append(((xx.min()+xx.max()+1)/2/raw.width*cols,(yy.min()+yy.max()+1)/2/raw.height*rows))
    targets=[(i%cols+.5,i//cols+.5) for i in range(count)]
    costs=np.array([[(x-tx)**2+(y-ty)**2 for tx,ty in targets] for x,y in centers])
    rr,cc=linear_sum_assignment(costs)
    if any(costs[r,c]>.60 for r,c in zip(rr,cc)):raise ValueError('Figure too far from requested row-major slot')
    seeds=np.zeros(labels.shape,dtype=np.int32)
    for r,c in zip(rr,cc):seeds[labels==primary_ids[r]]=int(c)+1
    nearest=ndimage.distance_transform_edt(seeds==0,return_distances=False,return_indices=True)
    owner=seeds[nearest[0],nearest[1]]
    outputs=[]
    for i in range(count):
        retained=array.copy();retained[:,:,3]=np.where(owner==i+1,alpha,0)
        im=Image.fromarray(retained,'RGBA');bb=bbox(im,16)
        if not bb:raise ValueError('Empty isolated figure')
        if bb[0]<=0 or bb[1]<=0 or bb[2]>=raw.width or bb[3]>=raw.height:
            raise ValueError('Actual global image-edge clipping on component '+str(i+1))
        piece=im.crop(bb);padded=Image.new('RGBA',(piece.width+4,piece.height+4));padded.paste(piece,(2,2))
        outputs.append({'image':padded,'source_region':[bb[0],bb[1],bb[2]-bb[0],bb[3]-bb[1]],
            'component_pixels':int(sizes[primary_ids[list(cc).index(i)]])})
    return outputs

def ingest(cid, image, ids, cols, rows, batch, prompt=None, adaptive=False, components=False, reuse=False):
    c=creature(cid);pm=posemap(c);dd=initialize(cid);src=abs_path(image)
    if any(pid not in pm for pid in ids) or len(set(ids))!=len(ids): raise ValueError('Unknown/duplicate pose IDs')
    raw = Image.open(src).convert('RGBA')
    if not bbox(raw): raise ValueError('Empty raw artwork')
    if raw.getchannel('A').getextrema()[0]!=0: raise ValueError('No true transparent background')
    # Preserve every submission before geometric rejection, without overwriting attempts.
    archive=dd/'_source/raw'/f'{batch}.png';archive.parent.mkdir(parents=True,exist_ok=True)
    if archive.exists() and sha(archive)!=sha(src): raise ValueError('Batch name already exists with different bytes')
    if not archive.exists(): shutil.copy2(src,archive)
    if prompt:
        prompt_path=dd/'_source/raw'/f'{batch}.prompt.txt'
        text=abs_path(prompt).read_text(encoding='utf-8-sig')
        if prompt_path.exists() and prompt_path.read_text(encoding='utf-8')!=text:raise ValueError('Prompt name collision')
        prompt_path.write_text(text,encoding='utf-8')
    write(dd/'_source/raw'/f'{batch}.submission.json',{'creature_id':cid,'pose_ids':ids,'columns':cols,'rows':rows,
        'raw_source':rel(archive),'raw_sha256':sha(archive),'adaptive_grid':adaptive,'components':components,
        'prompt':rel(dd/'_source/raw'/f'{batch}.prompt.txt') if prompt else None,
        'appearance_reference':c['appearance_reference'],'appearance_reference_sha256':c['appearance_reference_sha256'],
        'source_plan':rel(abs_path(PLAN)),'source_plan_sha256':sha(abs_path(PLAN)),
        'note':'Submission retained even when geometric ingestion fails. Built-in image generation is external to this mechanical tool.'})
    if reuse and sha(src)!=c['appearance_reference_sha256']:
        raise ValueError('Idle reuse input must be byte-identical to the approved high-resolution master')
    if len(ids)>cols*rows:raise ValueError('Too many IDs for grid')
    pieces=isolate_components(raw,cols,rows,len(ids)) if components else None
    xs=boundaries(raw,cols,0,adaptive) if not components else []
    ys=boundaries(raw,rows,1,adaptive) if not components else []
    extracted=[]
    for i,pid in enumerate(ids):
        region=pieces[i]['source_region'] if components else [xs[i%cols],ys[i//cols],xs[i%cols+1]-xs[i%cols],ys[i//cols+1]-ys[i//cols]]
        art=pieces[i]['image'] if components else crop(raw,region)
        bb=bbox(art,16)
        if not bb:raise ValueError('Missing figure in cell '+pid)
        if not reuse and (bb[0]<=1 or bb[1]<=1 or bb[2]>=art.width-1 or bb[3]>=art.height-1):
            raise ValueError('Figure touches raw/grid boundary: '+pid+'; preserve attempt and regenerate')
        out,registration=register(pm[pid],art)
        extracted.append((pid,art,out,registration,region))
    for pid,art,out,registration,region in extracted:
        previous=dd/'poses'/f'{pid}.json'
        if previous.exists():
            old=read(previous);write(dd/'_source/history'/pid/(old['raw_sha256']+'.json'),old)
        isolated=dd/'_source/isolated'/f'{batch}-{pid}.png';isolated.parent.mkdir(parents=True,exist_ok=True)
        art.save(isolated)
        fp=dd/'poses'/f'{pid}.png';out.save(fp)
        mirror=dd/'poses'/f'{pid}_mirror.png';ImageOps.mirror(out).save(mirror)
        write(fp.with_suffix('.json'),{'pose_id':pid,'artwork_origin':'approved high-resolution idle master reuse' if reuse else 'built-in image-generation artwork',
            'original_signature':pm[pid]['original_signature'],'original_representative':pm[pid]['representative'],
            'raw_source':rel(archive),'raw_sha256':sha(archive),'prompt':rel(dd/'_source/raw'/f'{batch}.prompt.txt') if prompt else None,
            'isolated_source':rel(isolated),'isolated_sha256':sha(isolated),'source_grid_region':region,
            'component_isolation':components,'isolation_method':'Strict alpha connected components, row-major assignment, nearest antialias ownership; ambiguous counts/clipping rejected; no painted/recolored pixels' if components else 'Transparent rectangular gutters',
            'registered_pose_file':rel(fp),'registered_pose_sha256':sha(fp),'mirror_file':rel(mirror),'mirror_sha256':sha(mirror),
            'registration':registration,'geometry':geometry(),'visual_review':'pending','human_animation_acceptance':False})
    return {'creature_id':cid,'ingested_pose_ids':ids,'raw_source':rel(archive)}

def mark_review(cid,ids,note):
    dd=dest(cid)
    for pid in ids:
        fp=dd/'poses'/f'{pid}.json';record=read(fp)
        record['visual_review']={'status':'worker reviewed source comparison; candidate, not human acceptance','note':note,
            'source_sha256_at_review':record['registered_pose_sha256'],'mirror_sha256_at_review':record['mirror_sha256']}
        write(fp,record)
    return {'reviewed_pose_ids':ids}

def build(cid):
    c=creature(cid);dd=initialize(cid);pm=posemap(c);records=[];missing=[];groups=[]
    for p in c['poses']:
        fp=dd/'poses'/f'{p["pose_id"]}.json'
        if not fp.exists():missing.append(p['pose_id'])
        else:
            record=read(fp)
            isolated=ROOT/record['isolated_source']
            if sha(isolated)!=record['isolated_sha256']:raise ValueError('Isolated raw source changed: '+p['pose_id'])
            regenerated,registration=register(p,Image.open(isolated).convert('RGBA'))
            target=ROOT/record['registered_pose_file'];mirror_target=ROOT/record['mirror_file']
            regenerated.save(target);ImageOps.mirror(regenerated).save(mirror_target)
            updated_sha=sha(target)
            if updated_sha!=record['registered_pose_sha256']:record['visual_review']='pending after registration change'
            record.update({'registered_pose_sha256':updated_sha,'mirror_sha256':sha(mirror_target),'registration':registration})
            write(fp,record);records.append(record)
    for g in c['groups']:
        entry={k:v for k,v in g.items() if k!='original_group_record'}
        entry['missing_pose_ids']=[pid for pid in g['pose_ids_in_source_order'] if pid in missing]
        entry['complete']=not entry['missing_pose_ids']
        if entry['complete']:
            n=g['frame_count'];height=math.ceil(n/4)*CELL[1];source=Image.new('RGBA',(CELL[0]*4,height));mirror=source.copy()
            previews=[];mirror_previews=[];native_previews=[]
            for i,pid in enumerate(g['pose_ids_in_source_order']):
                im=Image.open(dd/'poses'/f'{pid}.png').convert('RGBA');mi=ImageOps.mirror(im)
                # copy/paste rather than alpha-over: preserve every RGBA channel in the atlas cell.
                source.paste(im,((i%4)*CELL[0],(i//4)*CELL[1]));mirror.paste(mi,((i%4)*CELL[0],(i//4)*CELL[1]))
                for orientation,frame in [('source',im),('mirror',mi)]:
                    out=dd/'frames'/orientation/f'g{g["group_id"]:02d}_b{g["original_block"]:02d}'/f'{i:03d}.png';out.parent.mkdir(parents=True,exist_ok=True);frame.save(out)
                previews.append(matte(im).resize((512,384),Image.Resampling.LANCZOS))
                mirror_previews.append(matte(mi).resize((512,384),Image.Resampling.LANCZOS))
                native_previews.append(projected_original(pm[pid]))
            base=f'group_{g["group_id"]:02d}_block_{g["original_block"]:02d}'
            sp=dd/(base+'.png');mp=dd/(base+'_mirror.png');source.save(sp);mirror.save(mp)
            for suffix,frames in [('source',previews),('mirror',mirror_previews)]:
                frames[0].save(dd/'previews'/f'{base}_{suffix}.gif',save_all=True,append_images=frames[1:],duration=100,loop=0,disposal=2)
            # Every source position, original above candidate, at half-size, with a constant projection.
            contact=Image.new('RGB',(512*4,384*2*math.ceil(n/4)),(20,31,42))
            for i,(og,new) in enumerate(zip(native_previews,previews)):
                x=i%4*512;y=i//4*768
                contact.paste(matte(og).resize((512,384),Image.Resampling.NEAREST),(x,y));contact.paste(new,(x,y+384))
            contact_path=dd/'contacts'/(base+'.png');contact.save(contact_path)
            entry.update({'file':rel(sp),'sha256':sha(sp),'mirror_file':rel(mp),'mirror_sha256':sha(mp),
                'columns':4,'cell_size':list(CELL),'anchor':list(ANCHOR),'atlas_size':list(source.size),
                'frame_regions':[[i%4*1024,i//4*768,1024,768] for i in range(n)],'padding_frames':math.ceil(n/4)*4-n,
                'contact':rel(contact_path),'preview':rel(dd/'previews'/f'{base}_source.gif'),'mirror_preview':rel(dd/'previews'/f'{base}_mirror.gif')})
        groups.append(entry)
    result={'schema_version':1,'creature':c['creature'],'creature_id':cid,'original_def_id':c['original_def_id'],
        'original_metadata':c['original_metadata'],'original_metadata_sha256':c['original_metadata_sha256'],
        'original_def':c['original_def'],'original_def_sha256':c['original_def_sha256'],
        'appearance_reference':c['appearance_reference'],'appearance_reference_sha256':c['appearance_reference_sha256'],
        'appearance_reference_approved':True,'human_animation_acceptance':False,'original_timing_verified':False,
        'geometry':geometry(),'groups':groups,'poses':records,
        'coverage':{'complete_groups':sum(g['complete'] for g in groups),'total_groups':len(groups),'available_poses':len(records),'total_poses':len(c['poses']),
            'missing_pose_ids':missing,'frame_positions':c['original_frame_positions'],'reviewed_poses':sum(isinstance(p['visual_review'],dict) for p in records)}}
    write(dd/'source_manifest.json',result)
    return result['coverage']

def matte(im):
    out=Image.new('RGBA',im.size,(23,36,49,255));out.alpha_composite(im);return out.convert('RGB')

def spriteframes(cid):
    c=creature(cid);dd=dest(cid);manifest=read(dd/'source_manifest.json')
    groups=[g for g in manifest['groups'] if g['complete']]
    if len(groups)!=len(c['groups']):raise ValueError('Do not export a partial library: '+cid)
    outputs=[]
    for mirrored in [False,True]:
        count=sum(g['frame_count'] for g in groups)
        lines=[f'[gd_resource type="SpriteFrames" load_steps={1+len(groups)+count} format=3]','']
        for i,g in enumerate(groups,1):
            file=g['mirror_file'] if mirrored else g['file']
            lines.append(f'[ext_resource type="Texture2D" path="res://{file}" id="{i}"]')
        for i,g in enumerate(groups,1):
            for f in range(g['frame_count']):
                sid=f'g{g["group_id"]:02d}_b{g["original_block"]:02d}_f{f:03d}'
                lines += ['',f'[sub_resource type="AtlasTexture" id="{sid}"]',f'atlas = ExtResource("{i}")',f'region = Rect2({f%4*1024}, {f//4*768}, 1024, 768)']
        lines += ['','[resource]',f'resource_name = "Necropolis {c["creature"]} original group previews"',
            'metadata/preview_only = true','metadata/original_timing_verified = false',
            'metadata/preview_timing_status = "10 fps review only; original timing unknown"',f'metadata/exact_mirror = {str(mirrored).lower()}','animations = [']
        for gi,g in enumerate(groups):
            lines += ['{','"frames": [']
            for f in range(g['frame_count']):
                sid=f'g{g["group_id"]:02d}_b{g["original_block"]:02d}_f{f:03d}'
                lines.append('{"duration": 1.0, "texture": SubResource("'+sid+'")}'+(',' if f<g['frame_count']-1 else ''))
            lines += ['],',f'"loop": {str(g["group_id"] in [0,2]).lower()},',f'"name": &"og_{g["group_id"]:02d}_block_{g["original_block"]:02d}",','"speed": 10.0','}'+(',' if gi<len(groups)-1 else '')]
        lines += [']']
        fp=dd/('original_groups_mirrored.tres' if mirrored else 'original_groups.tres');fp.write_text('\n'.join(lines)+'\n',encoding='utf-8');outputs.append(rel(fp))
    return {'resources':outputs,'groups_per_resource':len(groups),'positions_per_resource':count}

def validate(cid):
    c=creature(cid);dd=dest(cid);path=dd/'source_manifest.json';errors=[];checked=0
    if not path.exists():return {'creature_id':cid,'errors':['Manifest missing'],'complete':False}
    m=read(path)
    if sha(ROOT/c['original_def'])!=c['original_def_sha256'] or sha(ROOT/c['original_metadata'])!=c['original_metadata_sha256']:errors.append('Original changed')
    for p in m['poses']:
        fp=ROOT/p['registered_pose_file'];mp=ROOT/p['mirror_file']
        if sha(fp)!=p['registered_pose_sha256'] or sha(mp)!=p['mirror_sha256']:errors.append('Pose hash '+p['pose_id'])
        a=Image.open(fp).convert('RGBA');b=Image.open(mp).convert('RGBA')
        bb=bbox(a,0)
        if a.size!=CELL or not bb or bb[0]<40 or bb[1]<40 or bb[2]>984 or bb[3]>728:errors.append('Padding/geometry '+p['pose_id'])
        if ImageOps.mirror(a).tobytes()!=b.tobytes():errors.append('Mirror '+p['pose_id'])
    for g in m['groups']:
        if not g['complete']:continue
        a=Image.open(ROOT/g['file']).convert('RGBA');b=Image.open(ROOT/g['mirror_file']).convert('RGBA')
        if sha(ROOT/g['file'])!=g['sha256'] or sha(ROOT/g['mirror_file'])!=g['mirror_sha256']:errors.append('Atlas hash '+str(g['group_id']))
        for i,pid in enumerate(g['pose_ids_in_source_order']):
            aa=crop(a,g['frame_regions'][i]);bb=crop(b,g['frame_regions'][i]);po=Image.open(dd/'poses'/f'{pid}.png').convert('RGBA')
            if aa.tobytes()!=po.tobytes() or ImageOps.mirror(po).tobytes()!=bb.tobytes():errors.append(f'Cell order/mirror G{g["group_id"]} F{i}')
            checked+=1
        n=g['frame_count']
        for i in range(n,math.ceil(n/4)*4):
            for atlas in [a,b]:
                if atlas.crop((i%4*1024,i//4*768,(i%4+1)*1024,(i//4+1)*768)).getbbox():errors.append('Nontransparent padding')
        for suffix in ['source','mirror']:
            gif=Image.open(dd/'previews'/f'group_{g["group_id"]:02d}_block_{g["original_block"]:02d}_{suffix}.gif')
            duration=0
            for index in range(gif.n_frames):gif.seek(index);duration+=gif.info.get('duration',0)
            if duration!=n*100:errors.append('GIF review duration')
    complete=m['coverage']['complete_groups']==c['original_group_slots'] and not m['coverage']['missing_pose_ids']
    return {'creature_id':cid,'coverage':m['coverage'],'frame_cells_verified':checked,'errors':errors,'complete':complete and not errors}

def inspect(cid):
    c=creature(cid)
    return {k:v for k,v in c.items() if k not in ['poses','groups']}

def main():
    global ROOT,PLAN,DOC
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--root',type=Path,default=ROOT);parser.add_argument('--plan',type=Path,default=PLAN)
    parser.add_argument('--dependency-path',type=Path,help='Optional preinstalled dependency overlay; no packages are installed by this tool')
    sub=parser.add_subparsers(dest='command',required=True)
    sub.add_parser('plan')
    for name in ['prepare','build','validate','spriteframes','inspect']:
        p=sub.add_parser(name);p.add_argument('creature')
    p=sub.add_parser('guide');p.add_argument('creature');p.add_argument('--pose-ids',required=True);p.add_argument('--name',required=True)
    p=sub.add_parser('ingest');p.add_argument('creature');p.add_argument('image');p.add_argument('--pose-ids',required=True);p.add_argument('--cols',type=int,default=1);p.add_argument('--rows',type=int,default=1);p.add_argument('--batch',required=True);p.add_argument('--prompt-file');p.add_argument('--adaptive-grid',action='store_true');p.add_argument('--components',action='store_true');p.add_argument('--reuse-approved-idle',action='store_true')
    p=sub.add_parser('review');p.add_argument('creature');p.add_argument('--pose-ids',required=True);p.add_argument('--note',required=True)
    args=parser.parse_args();ROOT=args.root.resolve();PLAN=args.plan
    if args.dependency_path:sys.path.insert(0,str(args.dependency_path.resolve()))
    if args.command=='plan':result=make_plan()
    elif args.command=='guide':result=guide(args.creature,args.pose_ids.split(','),args.name)
    elif args.command=='ingest':
        if args.reuse_approved_idle:
            c=creature(args.creature)
            if args.pose_ids!=c['og_idle_reference_pose_id']:raise ValueError('Master reuse is restricted to the exact original idle reference pose')
        result=ingest(args.creature,args.image,args.pose_ids.split(','),args.cols,args.rows,args.batch,args.prompt_file,args.adaptive_grid,args.components,args.reuse_approved_idle)
    elif args.command=='review':result=mark_review(args.creature,args.pose_ids.split(','),args.note)
    else:
        fn={'prepare':prepare,'build':build,'validate':validate,'spriteframes':spriteframes,'inspect':inspect}[args.command]
        result=[fn(c['creature_id']) for c in load_plan()['creatures']] if args.creature=='all' else fn(args.creature)
    print(json.dumps(result,indent=2))
    if args.command=='validate' and any(r['errors'] or not r['complete'] for r in (result if isinstance(result,list) else [result])):sys.exit(1)

if __name__=='__main__':
    main()
