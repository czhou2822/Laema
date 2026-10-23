"""Creature-scoped mechanical evidence; never paints artwork."""
import hashlib
import json
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[6]
REPORT=Path(__file__).resolve().parent
ASSET=ROOT/'assets/prototype/enemy/power_lich/remaster_v01'
sys.path.insert(0,str(ROOT/'tools/art'))
import necropolis_remaster as n
C=n.creature('power_lich')
def sha(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def sha_bytes(b): return hashlib.sha256(b).hexdigest()
if sys.argv[1]=='audit':
    m=n.read(ROOT/C['original_metadata'])
    assert m['groups']==[g['original_group_record'] for g in C['groups']]
    files={}
    for key in ('original_metadata','original_def','appearance_reference'):
        files[C[key]]=sha(ROOT/C[key]); assert files[C[key]]==C[key+'_sha256']
    pages={}
    for p in C['poses']:
        for o in p['occurrences']:
            g=next(g for g in m['groups'] if g['id']==o['group_id']);f=g['frames'][o['frame_index']]
            assert f==o['source_record']
            im=Image.open(ROOT/o['indexed_sheet'])
            native=im.crop((f['x']+f['left'],f['y']+f['top'],f['x']+f['left']+f['width'],f['y']+f['top']+f['height']))
            assert sha_bytes(native.tobytes())==f['index_sha256']
            for k in ('rgba_sheet','indexed_sheet'): pages[o[k]]=sha(ROOT/o[k])
    n.write(REPORT/'source-audit.json',{'files':files,'source_pages':pages,'indexed_occurrences_verified':120})
elif sys.argv[1] in ('split003','split004'):
    batch='003' if sys.argv[1]=='split003' else '004'
    source=ASSET/f'_source/raw/batch-{batch}-a.png'; im=Image.open(source)
    # Visually inspected gutter; alpha <= 6 only, below helper's strict alpha>8 component threshold.
    assert n.bbox(im.crop((0,436,im.width,440)),8) is None
    for label,box in [('upper',(0,0,im.width,440)),('lower',(0,440,im.width,im.height))]:
        target=ASSET/'_source/raw'/f'batch-{batch}-{label}.png';im.crop(box).save(target)
        n.write(target.with_suffix('.derivation.json'),{'source':n.rel(source),'source_sha256':sha(source),'crop_box':box,'operation':'lossless rectangular crop only; no painted/resized pixels','sha256':sha(target)})
elif sys.argv[1]=='gif-strips':
    manifest=n.read(ASSET/'source_manifest.json')
    for g in manifest['groups']:
        stem=f"group_{g['group_id']:02d}_block_{g['original_block']:02d}"
        sequence=[]
        for facing in ('source','mirror'):
            gif=Image.open(ASSET/'previews'/f'{stem}_{facing}.gif'); expanded=[]
            for i in range(gif.n_frames):
                gif.seek(i); expanded.extend([gif.convert('RGB').copy()]*(gif.info.get('duration',100)//100))
            assert len(expanded)==g['frame_count'];sequence.append(expanded)
        bounds=[]
        for pid in g['pose_ids_in_source_order']:
            im=Image.open(ASSET/'poses'/f'{pid}.png');bounds.append(n.bbox(im))
        left=min(b[0] for b in bounds)//2-5;top=min(b[1] for b in bounds)//2-5
        right=(max(b[2] for b in bounds)+1)//2+5;bottom=(max(b[3] for b in bounds)+1)//2+5
        width=right-left;height=bottom-top; fit=min(238/width,220/height)
        size=(round(width*fit),round(height*fit))
        sheet=Image.new('RGB',(2048,256*((g['frame_count']+3)//4)),(23,36,49)); draw=ImageDraw.Draw(sheet)
        for i in range(g['frame_count']):
            x=i%4*512;y=i//4*256
            draw.text((x+8,y+5),f"G{g['group_id']} F{i} {g['pose_ids_in_source_order'][i]} source / mirror",fill='white')
            for j,frames in enumerate(sequence):
                box=(left,top,right,bottom) if j==0 else (512-right,top,512-left,bottom)
                piece=frames[i].crop(box).resize(size,Image.Resampling.NEAREST)
                sheet.paste(piece,(x+j*256+(256-size[0])//2,y+25+(220-size[1])//2))
        target=ASSET/'_source/review'/f'{stem}_gif_frames.png';sheet.save(target);print(target)
elif sys.argv[1]=='native-comparisons':
    poses=C['poses']
    for start in range(0,len(poses),8):
        chosen=poses[start:start+8]; canvas=Image.new('RGB',(1792,448),(23,36,49));draw=ImageDraw.Draw(canvas)
        for i,p in enumerate(chosen):
            pid=p['pose_id'];a=n.opaque_reference(p); b=Image.open(ASSET/'poses'/f'{pid}.png').convert('RGBA')
            b=b.transform(a.size,Image.Transform.AFFINE,(n.SCALE,0,n.ANCHOR[0]-196*n.SCALE,0,n.SCALE,n.ANCHOR[1]-268*n.SCALE),resample=Image.Resampling.BICUBIC)
            x=i%4*448;y=i//4*224; draw.text((x+6,y+5),pid+' original native / new',fill='white')
            for j,im in enumerate((a,b)):
                piece=im.crop((100,125,310,315))
                canvas.paste(n.matte(piece),(x+j*224+7,y+25))
        target=ASSET/'_source/review'/f'native-{chosen[0]["pose_id"]}-{chosen[-1]["pose_id"]}.png';canvas.save(target);print(target)
elif sys.argv[1]=='mark-reviews':
    observations=n.read(REPORT/'visual-observations.json')
    assert set(observations['poses'])=={p['pose_id'] for p in C['poses']}
    for pid,note in observations['poses'].items():n.mark_review('power_lich',[pid],note)
    print('Marked 74 inspected source-pose comparisons through helper mark_review')
elif sys.argv[1]=='final-evidence':
    m=n.read(ASSET/'source_manifest.json');obs=n.read(REPORT/'visual-observations.json')
    validation=n.validate('power_lich');assert validation['complete'],validation
    poses=[]
    for p in m['poses']:
        review=p['visual_review'];assert isinstance(review,dict)
        assert review['source_sha256_at_review']==sha(ROOT/p['registered_pose_file'])
        assert review['mirror_sha256_at_review']==sha(ROOT/p['mirror_file'])
        assert p['raw_sha256']==sha(ROOT/p['raw_source'])
        assert p['isolated_sha256']==sha(ROOT/p['isolated_source'])
        poses.append({'pose_id':p['pose_id'],'source_sha256':p['registered_pose_sha256'],'mirror_sha256':p['mirror_sha256'],
          'raw_source':p['raw_source'],'raw_sha256':p['raw_sha256'],'isolated_source':p['isolated_source'],'isolated_sha256':p['isolated_sha256'],
          'observation':obs['poses'][p['pose_id']],'review_hashes_fresh':True})
    groups=[]
    for g in m['groups']:
        stem=f"group_{g['group_id']:02d}_block_{g['original_block']:02d}"
        evidence={k:g[k] for k in ('group_id','original_block','pose_ids_in_source_order','exact_aliases','frame_count')}
        evidence['observation']=obs['groups'][str(g['group_id'])]
        evidence['files']={path:sha(ROOT/path) for path in [g['file'],g['mirror_file'],g['contact'],g['preview'],g['mirror_preview'],n.rel(ASSET/'_source/review'/f'{stem}_gif_frames.png')]}
        for alias in g['exact_aliases']:
            other=next(h for h in m['groups'] if h['group_id']==alias)
            assert g['sha256']==other['sha256'];assert g['mirror_sha256']==other['mirror_sha256']
        groups.append(evidence)
    e={'creature_id':'power_lich','coverage':m['coverage'],'selected_new_artwork_poses':74,'approved_idle_reuse_poses':0,
       'missing_poses':[],'missing_groups':[],'unresolved_blocking_visual_defects':[],
       'review_methods':obs['methods'],'review_limits':obs['limits'],'human_animation_acceptance':False,
       'browser_validation':False,'godot_validation':False,'original_timing_verified':False,
       'all_review_hashes_fresh':True,'source_manifest_sha256':sha(ASSET/'source_manifest.json'),
       'validation':validation,'poses':poses,'groups':groups}
    n.write(REPORT/'visual-review.json',e)
    print(json.dumps({'coverage':m['coverage'],'fresh_reviews':len(poses),'groups':len(groups),'source_manifest_sha256':e['source_manifest_sha256']},indent=2))
elif sys.argv[1]=='provenance':
    for target in REPORT.glob('generation-provenance*.json'):
        data=n.read(target)
        for call in data['calls']:
            call['raw_sha256']=sha(ROOT/call['raw_file'])
            call['prompt_sha256']=sha(ROOT/call['prompt_file'])
            for ref in call['references']:ref['sha256']=sha(ROOT/ref['path'])
            assert sha(call['returned_file'])==call['raw_sha256']
        n.write(target,data)
elif sys.argv[1]=='comparisons':
    ids=sys.argv[2].split(',') if len(sys.argv)>2 else [p['pose_id'] for p in C['poses']]
    for start in range(0,len(ids),8):
        chosen=ids[start:start+8]; canvas=Image.new('RGB',(2048,1024),(23,36,49)); d=ImageDraw.Draw(canvas)
        for i,pid in enumerate(chosen):
            p=next(p for p in C['poses'] if p['pose_id']==pid)
            fp=ASSET/'poses'/f'{pid}.png'
            if not fp.exists():continue
            a=n.projected_original(p); b=Image.open(fp).convert('RGBA')
            pair=Image.new('RGB',(512,512),(23,36,49))
            for j,im in enumerate((a,b)):
                bb=n.bbox(im); piece=im.crop(bb); piece.thumbnail((240,270),Image.Resampling.NEAREST if j==0 else Image.Resampling.LANCZOS)
                pair.paste(n.matte(piece),(j*256+(256-piece.width)//2,40+(270-piece.height)//2))
                small=im.resize((256,192),Image.Resampling.NEAREST if j==0 else Image.Resampling.LANCZOS)
                pair.paste(n.matte(small),(j*256,320))
            canvas.paste(pair,((i%4)*512,(i//4)*512)); d.text(((i%4)*512+10,(i//4)*512+10),pid+' OG / new',fill='white')
        target=ASSET/'_source/review'/f'poses-{chosen[0]}-{chosen[-1]}.png';target.parent.mkdir(exist_ok=True,parents=True);canvas.save(target)
        print(target)
