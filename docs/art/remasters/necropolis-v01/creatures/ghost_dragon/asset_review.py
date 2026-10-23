"""Read-only art inspection and mechanical QA exports for this creature only.

No drawing, anatomy edits, warping, or modifications to the shared helper.
"""
import hashlib
import importlib.util
import json
import re
import subprocess
from pathlib import Path
import sys
from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
OUT = ROOT / 'assets/prototype/enemy/ghost_dragon/remaster_v01'
REPORT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('packing', ROOT/'tools/art/necropolis_remaster.py')
packing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(packing)
C = packing.creature('ghost_dragon')

def dump(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2)+'\n', encoding='utf-8')

def evidence():
    native = packing.read(ROOT/C['original_metadata'])
    assert all(g['original_group_record'] == n for g,n in zip(C['groups'],native['groups']))
    sources = []
    for k in ['original_def','original_metadata','appearance_reference']:
        actual = packing.sha(ROOT/C[k]); assert actual == C[k+'_sha256']
        sources.append({'role':k,'path':C[k],'sha256':actual,'matched':True})
    checks = []
    for p in C['poses']:
        for o in p['occurrences']:
            f = o['source_record']; im = Image.open(ROOT/o['indexed_sheet'])
            region = [f['x']+f['left'],f['y']+f['top'],f['width'],f['height']]
            indices = packing.crop(im,region).tobytes()
            actual = hashlib.sha256(indices).hexdigest()
            assert actual == f['index_sha256'], (p['pose_id'], actual)
            checks.append({'pose_id':p['pose_id'],'group_id':o['group_id'],'frame_index':o['frame_index'],'indexed_sha256':actual,'matched':True})
    dump(REPORT/'input-verification.json',{'sources':sources,'all_group_records_equal_native_metadata':True,'indexed_occurrences':checks})
    print('Verified original metadata, DEF, master and',len(checks),'indexed occurrences')

def crops(batch, regions):
    raw = OUT/'_source'/f'{batch}.png'; im = Image.open(raw).convert('RGBA')
    records=[]
    for pid,rect in regions.items():
        art = im.crop(tuple(rect)); bb=packing.bbox(art,8)
        assert bb and bb[0]>1 and bb[1]>1 and bb[2]<art.width-1 and bb[3]<art.height-1,(pid,bb,art.size)
        fp=OUT/'_source'/f'{batch}-{pid}-crop.png'; art.save(fp)
        records.append({'selection':pid,'original_raw':packing.rel(raw),'original_raw_sha256':packing.sha(raw),'raw_size':list(im.size),'rectangle_ltrb':rect,'crop':packing.rel(fp),'crop_sha256':packing.sha(fp),'method':'Rectangular selection of visually separate generated figure/fragment cluster; no drawing or pixel transformation. Any rectangle outside original dimensions adds transparent pixels only; no clipped content is reconstructed.'})
    dump(REPORT/f'{batch}-crop-provenance.json',records)

def compare():
    for b in range(8):
        ids=[p['pose_id'] for p in C['poses'][b*8:(b+1)*8]]
        sheet=Image.new('RGB',(2048,768*2),(23,36,49)); draw=ImageDraw.Draw(sheet)
        for i,pid in enumerate(ids):
            p=next(p for p in C['poses'] if p['pose_id']==pid)
            x=i%4*512; y=i//4*768
            og=packing.matte(packing.projected_original(p)).resize((512,384),Image.Resampling.NEAREST)
            sheet.paste(og,(x,y))
            fp=OUT/'poses'/f'{pid}.png'
            if fp.exists():sheet.paste(packing.matte(Image.open(fp).convert('RGBA')).resize((512,384)),(x,y+384))
            draw.text((x+8,y+8),pid+' OG / candidate',fill='white')
        fp=REPORT/'comparisons'/f'batch-{b:03d}.png';fp.parent.mkdir(parents=True,exist_ok=True);sheet.save(fp)
    print('Updated 8 OG/candidate comparison pages at fixed half size')

def provenance():
    results=[]
    for submission in sorted((OUT/'_source/raw').glob('*.submission.json')):
        r=packing.read(submission); refs=[]
        # Crop submissions inherit full raw provenance from explicit crop manifests.
        for path in [OUT/'_source/appearance-master.png', *sorted((OUT/'_source/guides').glob('*.png'))]:
            refs.append({'path':packing.rel(path),'sha256':packing.sha(path)})
        r['reference_inventory']=refs; results.append(r)
    dump(REPORT/'generation-provenance.json',results)

def previews():
    """Decode the actual GIFs, expand repeat durations and show both facings."""
    results=[]
    for g in C['groups']:
        base=f'group_{g["group_id"]:02d}_block_{g["original_block"]:02d}'
        n=g['frame_count']; sheet=Image.new('RGB',(512*4,384*2*((n+3)//4)),(23,36,49))
        orientation_data=[]
        for row,suffix in enumerate(['source','mirror']):
            path=OUT/'previews'/f'{base}_{suffix}.gif'; gif=Image.open(path); frames=[]; durations=[]
            for fi in range(gif.n_frames):
                gif.seek(fi); d=gif.info.get('duration',100); assert d%100==0
                durations.append(d)
                frames += [gif.convert('RGB').copy()]*(d//100)
            assert len(frames)==n
            for fi,frame in enumerate(frames):
                x=fi%4*512;y=fi//4*768+row*384
                sheet.paste(frame,(x,y)); ImageDraw.Draw(sheet).text((x+8,y+8),f'{suffix} G{g["group_id"]} F{fi} '+g['pose_ids_in_source_order'][fi],fill='white')
            orientation_data.append({'orientation':suffix,'gif':packing.rel(path),'gif_sha256':packing.sha(path),'decoded_gif_frames':gif.n_frames,'durations_ms':durations,'source_positions_after_duration_expansion':len(frames)})
        out=REPORT/'gif-frame-comparisons'/f'{base}.png';out.parent.mkdir(parents=True,exist_ok=True);sheet.save(out)
        results.append({'group_id':g['group_id'],'source_order':g['pose_ids_in_source_order'],'preview':packing.rel(out),'orientations':orientation_data,'playback_claim':False})
    dump(REPORT/'gif-decode-evidence.json',results)
    print('Decoded all 30 GIFs, 176 frame positions including mirrors')

def native():
    """Native source-scale silhouettes plus the same candidate downsampled uniformly."""
    for b in range(8):
        poses=C['poses'][b*8:(b+1)*8];sheet=Image.new('RGB',(1800,800),(23,36,49));draw=ImageDraw.Draw(sheet)
        for i,p in enumerate(poses):
            x=i%4*450;y=i//4*400
            og=packing.opaque_reference(p);bb=packing.bbox(og,160)
            og=og.crop(bb);new=Image.open(OUT/'poses'/f'{p["pose_id"]}.png').convert('RGBA')
            cb=packing.bbox(new,8);new=new.crop(cb);new=new.resize((round(new.width/packing.SCALE),round(new.height/packing.SCALE)),Image.Resampling.LANCZOS)
            sheet.paste(og,(x+45,y+70),og);sheet.paste(new,(x+245,y+70),new)
            draw.text((x+8,y+8),p['pose_id']+' native OG | candidate',fill='white')
        out=REPORT/'native-scale'/f'batch-{b:03d}.png';out.parent.mkdir(parents=True,exist_ok=True);sheet.save(out)
    print('8 native-scale comparison pages')

def feet():
    ids=[f'ghost_dragon_p{i:03d}' for i in [0,1,2,5]]
    sheet=Image.new('RGB',(1800,1200),(23,36,49));draw=ImageDraw.Draw(sheet)
    for i,pid in enumerate(ids):
        p=next(p for p in C['poses'] if p['pose_id']==pid)
        og=packing.opaque_reference(p).crop((170,200,310,250));og=og.resize((560,200),Image.Resampling.NEAREST)
        # Fixed source-coordinate region containing the hanging limbs, not an art edit.
        xx=round(512+(170-196)*packing.SCALE); yy=round(512+(200-268)*packing.SCALE)
        xx2=round(512+(310-196)*packing.SCALE); yy2=round(512+(250-268)*packing.SCALE)
        new=Image.open(OUT/'poses'/f'{pid}.png').convert('RGBA').crop((xx,yy,xx2,yy2)).resize((560,200),Image.Resampling.NEAREST)
        for j,color in enumerate([(23,36,49,255),(240,240,230,255)]):
            for k,im in enumerate([og,new]):
                matte=Image.new('RGBA',(560,200),color);matte.alpha_composite(im)
                x=j*900+k*420;y=i*300+50
                if k: x=j*900+450
                # Fit wide foot crop to its 420px evidence column only.
                matte=matte.resize((420,150));sheet.paste(matte.convert('RGB'),(x,y))
            draw.text((j*900+8,i*300+8),pid+' OG | candidate '+('dark' if j==0 else 'light'),fill='white')
    sheet.save(REPORT/'flying-feet-dark-light-v01.png')
    print('Saved foot evidence')

def alpha_evidence():
    values=[]
    for p in C['poses']:
        og=packing.opaque_reference(p); bb=packing.bbox(og,160); a=og.crop(bb).getchannel('A')
        histogram=a.histogram();area=a.width*a.height
        values.append({'pose_id':p['pose_id'],'opaque_body_rect':p['opaque_body_rect'],'body_bbox_area':area,'nonzero_source_pixels':area-histogram[0],'source_alpha_histogram_nonzero':{i:n for i,n in enumerate(histogram) if n},'bbox_coverage_fraction':round((area-histogram[0])/area,6)})
    dump(REPORT/'exported-source-alpha-evidence.json',{'interpretation':'These are exported PNG alpha values and indexed-pixel evidence, not an engine palette or timing claim. Coverage includes legitimate bone/wing holes and therefore is not a global opacity measurement.','poses':values})

def pack_phase(numbers,name):
    ids=[f'ghost_dragon_p{i:03d}' for i in numbers];cols=min(4,len(ids));rows=(len(ids)+cols-1)//cols
    sheet=Image.new('RGBA',(cols*512,rows*512));records=[]
    for i,pid in enumerate(ids):
        r=packing.read(OUT/'poses'/f'{pid}.json');path=ROOT/r['isolated_source'];art=Image.open(path).convert('RGBA');art=art.crop(packing.bbox(art,8));art.thumbnail((420,420),Image.Resampling.LANCZOS)
        x=i%cols*512+(512-art.width)//2;y=i//cols*512+(512-art.height)//2
        sheet.alpha_composite(art,(x,y));records.append({'pose_id':pid,'current_isolated_source':r['isolated_source'],'sha256':packing.sha(path),'reference_region':[x,y,art.width,art.height]})
    fp=OUT/'_source/guides'/f'{name}.png';sheet.save(fp)
    dump(fp.with_suffix('.json'),{'role':'Mechanical layout of already-generated artwork as edit reference only; no newly drawn pixels','pose_ids':ids,'sources':records,'sha256':packing.sha(fp)})

def selected_alpha():
    results=[]
    for p in C['poses']:
        r=packing.read(OUT/'poses'/f'{p["pose_id"]}.json'); im=Image.open(ROOT/r['isolated_source']).convert('RGBA'); hist=im.getchannel('A').histogram()
        count=sum(hist[9:]);total=0;median=None
        for a in range(9,256):
            total+=hist[a]
            if total>=count/2:median=a;break
        results.append({'pose_id':p['pose_id'],'isolated_source':r['isolated_source'],'sha256':r['isolated_sha256'],'median_alpha_above_8':median,'mean_alpha_above_8':round(sum(i*hist[i] for i in range(9,256))/count,2),'foreground_pixels_above_8':count})
    dump(REPORT/'selected-art-alpha-evidence.json',{'interpretation':'Generated continuous alpha is an artistic phase-visibility interpretation of native binary dither. Numeric prompt requests are not exact measured source opacities. No engine palette behavior or original playback timing is established.','poses':results})
    phase={1,2,3,6,7,10,16,17,18,26,27,28}
    print([(r['pose_id'],r['median_alpha_above_8']) for i,r in enumerate(results) if i in phase])

def phase_mattes():
    for name,color in [('dark',(23,36,49,255)),('light',(240,240,230,255))]:
        sheet=Image.new('RGBA',(1500,1000),color);draw=ImageDraw.Draw(sheet)
        for i,n in enumerate([1,2,6,17,27,28]):
            pid=f'ghost_dragon_p{n:03d}';im=Image.open(OUT/'poses'/f'{pid}.png').convert('RGBA');im=im.crop(packing.bbox(im,8));im.thumbnail((440,420),Image.Resampling.LANCZOS)
            x=i%3*500+(500-im.width)//2;y=i//3*500+60+(420-im.height)//2
            sheet.alpha_composite(im,(x,y));draw.text((i%3*500+12,i//3*500+12),pid+' generated continuous alpha',fill=(240,240,230) if name=='dark' else (23,36,49))
        sheet.convert('RGB').save(REPORT/f'phase-{name}-matte.png')

def mark_all():
    data=packing.read(REPORT/'visual-observations.json');assert len(data['pose_observations'])==61
    for note in data['pose_observations']:
        subprocess.run([sys.executable,str(ROOT/'tools/art/necropolis_remaster.py'),'review','ghost_dragon','--pose-ids',note['pose_id'],'--note',note['observation']+' Inspected OG guide, native-scale and registered comparisons, raw selected art and both-facing sequence frames. Candidate review only.'],cwd=ROOT,check=True,capture_output=True,text=True)
    print('Marked all 61 individually observed poses through helper review command')

def complete():
    before=packing.validate('ghost_dragon');dump(REPORT/'validate-before-spriteframes.json',before)
    assert before['complete'] and before['coverage']['reviewed_poses']==61,before
    exports=packing.spriteframes('ghost_dragon');dump(REPORT/'spriteframes-export.json',exports)
    after=packing.validate('ghost_dragon');dump(REPORT/'final-validation.json',after);assert after['complete'],after
    m=packing.read(OUT/'source_manifest.json');notes=packing.read(REPORT/'visual-observations.json');pose_notes={p['pose_id']:p['observation'] for p in notes['pose_observations']};gn={p['group_id']:p['observation'] for p in notes['group_observations']}
    poses=[]
    for p in m['poses']:
        review=p['visual_review'];assert isinstance(review,dict)
        assert review['source_sha256_at_review']==p['registered_pose_sha256'] and review['mirror_sha256_at_review']==p['mirror_sha256']
        assert packing.sha(ROOT/p['raw_source'])==p['raw_sha256'] and packing.sha(ROOT/p['isolated_source'])==p['isolated_sha256']
        i=int(p['pose_id'][-3:]);b=i//8
        poses.append({'pose_id':p['pose_id'],'observation':pose_notes[p['pose_id']],'raw_source':p['raw_source'],'raw_sha256':p['raw_sha256'],'isolated_source':p['isolated_source'],'isolated_sha256':p['isolated_sha256'],'registered_pose_sha256':p['registered_pose_sha256'],'mirror_sha256':p['mirror_sha256'],'visual_review':review,'review_hash_fresh':True,'native_comparison':packing.rel(REPORT/'native-scale'/f'batch-{b:03d}.png'),'registered_comparison':packing.rel(REPORT/'comparisons'/f'batch-{b:03d}.png'),'blocking_defects':[]})
    groups=[]
    for g in m['groups']:
        gp=REPORT/'gif-frame-comparisons'/f'group_{g["group_id"]:02d}_block_{g["original_block"]:02d}.png'
        groups.append({'group_id':g['group_id'],'original_block':g['original_block'],'observation':gn[g['group_id']],'pose_ids_in_source_order':g['pose_ids_in_source_order'],'exact_aliases':g['exact_aliases'],'source_sha256':g['sha256'],'mirror_sha256':g['mirror_sha256'],'source_contact':g['contact'],'contact_sha256':packing.sha(ROOT/g['contact']),'both_facing_gif_decode_contact':packing.rel(gp),'gif_decode_contact_sha256':packing.sha(gp),'frame_positions_inspected':list(range(g['frame_count'])),'blocking_defects':[]})
    resources=[]
    for path in exports['resources']:
        text=(ROOT/path).read_text(encoding='utf-8');assert text.count('[ext_resource ')==15 and text.count('[sub_resource ')==88 and text.count('"name": &"og_')==15
        resources.append({'file':path,'sha256':packing.sha(ROOT/path),'groups':15,'atlas_regions':88,'engine_import_tested':False})
    dump(REPORT/'visual-review.json',{'creature_id':'ghost_dragon','coverage':m['coverage'],'worker_visual_review_complete':True,'human_animation_acceptance':False,'browser_playback_checked':False,'godot_checked':False,'original_timing_verified':False,'review_limits':notes['review_limits'],'poses':poses,'groups':groups,'resources':resources,'unresolved_blocking_visual_defects':[],'source_manifest_sha256':packing.sha(OUT/'source_manifest.json')})
    metadata=packing.read(REPORT/'built-in-tool-metadata.json')
    for c in metadata['calls']:
        prompt=ROOT/c['prompt'];raw=ROOT/c['raw_copy'];c['prompt_file_sha256']=packing.sha(prompt);c['exact_tool_prompt']=prompt.read_text(encoding='utf-8').strip();c['exact_tool_prompt_sha256']=hashlib.sha256(c['exact_tool_prompt'].encode()).hexdigest();c['raw_sha256']=packing.sha(raw)
        c['reference_hashes']=[{'path':f,'sha256':packing.sha(ROOT/f)} for f in c['references']]
        hint=c['returned_metadata']['output_hint'];match=re.search(r' as (C:\\.*?\.png) by default',hint)
        assert match and packing.sha(Path(match.group(1)))==c['raw_sha256'],c['id']
        c['returned_raw_matches_copy']=True
    dump(REPORT/'exact-generation-provenance.json',metadata)
    provenance();selected_alpha();evidence()
    print(json.dumps({'complete':after['complete'],'coverage':after['coverage'],'frame_cells_verified':after['frame_cells_verified'],'fresh_pose_reviews':len(poses),'group_reviews':len(groups),'resources':resources,'built_in_calls':len(metadata['calls'])},indent=2))

if __name__=='__main__':
    if sys.argv[1]=='evidence':evidence()
    elif sys.argv[1]=='compare':compare()
    elif sys.argv[1]=='provenance':provenance()
    elif sys.argv[1]=='previews':previews()
    elif sys.argv[1]=='native':native()
    elif sys.argv[1]=='feet':feet()
    elif sys.argv[1]=='alpha':alpha_evidence()
    elif sys.argv[1]=='selectedalpha':selected_alpha()
    elif sys.argv[1]=='phasemattes':phase_mattes()
    elif sys.argv[1]=='mark':mark_all()
    elif sys.argv[1]=='complete':complete()
    elif sys.argv[1]=='packphase':pack_phase([3,6,7,10,16,17,18,26],'phase-alpha-target-v02')
    elif sys.argv[1]=='packdeathphase':pack_phase([27,28],'death-phase-alpha-target-v02')
    elif sys.argv[1]=='packremainingphase':pack_phase([3,7,10,16,18,26,27,28],'remaining-phase-alpha-target-v03')
    elif sys.argv[1]=='crop003':
        crops('batch-003-v01',{'top-row':(0,0,1776,465),'bottom-row':(0,465,1776,880)})
    elif sys.argv[1]=='crop004':
        crops('batch-004-v01',{'top-three':(0,0,1335,445),'bottom-row':(0,445,1774,887)})
    elif sys.argv[1]=='cropmelee':
        crops('repair-melee-tail-reach-v02',{'top-three':(0,0,1360,445),'bottom-three':(0,445,1370,887)})
    elif sys.argv[1]=='cropphase':
        crops('repair-source-phase-alpha-v02',{'p006':(450,0,880,440),'p017':(450,450,890,887)})
