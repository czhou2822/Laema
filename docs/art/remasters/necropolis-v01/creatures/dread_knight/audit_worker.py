"""Read-only source checks and mechanical review contacts; never draws artwork."""
import hashlib
import importlib.util
import json
import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
DEST = ROOT / 'assets/prototype/enemy/dread_knight/remaster_v01'
spec = importlib.util.spec_from_file_location('packing', ROOT / 'tools/art/necropolis_remaster.py')
packing = importlib.util.module_from_spec(spec)
sys.dont_write_bytecode = True
spec.loader.exec_module(packing)
c = packing.creature('dread_knight')
pm = packing.posemap(c)

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def save_json(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')

def check_sources():
    checks = []
    for pkey, hkey in [('original_def','original_def_sha256'), ('original_metadata','original_metadata_sha256'), ('appearance_reference','appearance_reference_sha256')]:
        actual = sha(ROOT / c[pkey])
        checks.append({'file':c[pkey], 'expected_sha256':c[hkey], 'actual_sha256':actual, 'match':actual == c[hkey]})
    meta = packing.read(ROOT / c['original_metadata'])
    assert meta['groups'] == [g['original_group_record'] for g in c['groups']]
    images = {}
    occurrences = []
    for p in c['poses']:
        for occurrence in p['occurrences']:
            name = occurrence['indexed_sheet']
            if name not in images:
                images[name] = Image.open(ROOT / name)
            f = occurrence['source_record']
            x,y,_,_ = occurrence['sheet_cell_region']
            bb = (x+f['left'],y+f['top'],x+f['left']+f['width'],y+f['top']+f['height'])
            actual = hashlib.sha256(images[name].crop(bb).tobytes()).hexdigest()
            occurrences.append({'pose_id':p['pose_id'],'group_id':occurrence['group_id'],'frame_index':occurrence['frame_index'],'original_index_sha256':f['index_sha256'],'actual_index_sha256':actual,'match':actual == f['index_sha256']})
    references=[]
    for path in sorted((DEST / '_source/guides').glob('*.png')):
        references.append({'path':packing.rel(path),'sha256':sha(path)})
    references.append({'path':packing.rel(DEST/'_source/appearance-master.png'),'sha256':sha(DEST/'_source/appearance-master.png')})
    result={'checks':checks,'metadata_group_records_match_plan':True,'indexed_occurrences':occurrences,'references':references,'all_match':all(i['match'] for i in checks+occurrences)}
    save_json(REPORT / 'input-verification.json', result)
    print(json.dumps({'source_checks':len(checks),'indexed_occurrences':len(occurrences),'all_match':result['all_match']}))

def render_reviews():
    out=REPORT/'review-images'
    out.mkdir(exist_ok=True)
    poses=c['poses']
    for start in range(0,len(poses),8):
        page=Image.new('RGB',(1600,1200),(25,38,51));draw=ImageDraw.Draw(page)
        for i,p in enumerate(poses[start:start+8]):
            x=i%4*400;y=i//4*600
            og=packing.projected_original(p)
            candidate=Image.open(DEST/'poses'/(p['pose_id']+'.png')).convert('RGBA')
            bounds=Image.new('L',og.size)
            bounds=Image.frombytes('L',og.size,bytes(max(a,b) for a,b in zip(og.getchannel('A').tobytes(),candidate.getchannel('A').tobytes())))
            bb=bounds.getbbox()
            padded=(bb[0]-8,bb[1]-8,bb[2]+8,bb[3]+8)
            for col,im in enumerate([og,candidate]):
                crop=im.crop(padded)
                crop.thumbnail((190,440),Image.Resampling.NEAREST if col==0 else Image.Resampling.LANCZOS)
                tile=packing.matte(crop)
                page.paste(tile,(x+col*200+(200-tile.width)//2,y+40+(440-tile.height)//2))
            draw.text((x+5,y+5),p['pose_id']+'  OG | candidate',fill='white')
            # Both facings at the constant native body scale, without per-pose rescaling.
            for col,im in enumerate([candidate,ImageOps.mirror(candidate)]):
                native=im.resize((415,312),Image.Resampling.LANCZOS)
                crop=native.crop(native.getchannel('A').getbbox())
                page.paste(packing.matte(crop),(x+col*200+(200-crop.width)//2,y+485))
            draw.text((x+5,y+580),'native source-facing | exact mirror',fill='white')
        page.save(out/f'poses-{start:03d}-{min(start+7,len(poses)-1):03d}.png')
    summary=[]
    for g in c['groups']:
        base=f'group_{g["group_id"]:02d}_block_{g["original_block"]:02d}'
        n=g['frame_count'];sheet=Image.new('RGB',(2048,math.ceil(n/4)*420),(25,38,51));draw=ImageDraw.Draw(sheet)
        decoded=[]
        for orientation in ['source','mirror']:
            gif=Image.open(DEST/'previews'/f'{base}_{orientation}.gif')
            elapsed=0;logical=[]
            for index in range(gif.n_frames):
                gif.seek(index)
                duration=gif.info.get('duration',0)
                frame=gif.convert('RGB').copy()
                repeat=duration//100
                for _ in range(repeat):logical.append(frame.copy())
                elapsed+=duration
            assert len(logical)==n
            decoded.append(logical)
            summary.append({'group_id':g['group_id'],'orientation':orientation,'gif_file':packing.rel(DEST/'previews'/f'{base}_{orientation}.gif'),'encoded_frames':gif.n_frames,'source_positions_after_decoding_holds':len(logical),'duration_ms':elapsed,'continuous_playback_observed':False})
        for i in range(n):
            x=i%4*512;y=i//4*420
            for orientation in range(2):
                frame=decoded[orientation][i].resize((256,192),Image.Resampling.LANCZOS)
                sheet.paste(frame,(x+orientation*256,y+25))
            draw.text((x+8,y+5),f'G{g["group_id"]} F{i} {g["pose_ids_in_source_order"][i]}',fill='white')
            # Enlarged transparent-body crops for anatomy and framing inspection.
            for orientation in range(2):
                path=DEST/'frames'/('source' if orientation==0 else 'mirror')/f'g{g["group_id"]:02d}_b{g["original_block"]:02d}'/f'{i:03d}.png'
                im=Image.open(path).convert('RGBA');im=im.crop(im.getchannel('A').getbbox())
                im.thumbnail((248,190),Image.Resampling.LANCZOS)
                sheet.paste(packing.matte(im),(x+orientation*256+(256-im.width)//2,y+225))
        sheet.save(out/f'{base}-both-facings-decoded.png')
    save_json(REPORT/'gif-decode-evidence.json',{'method':'All GIFs decoded into source positions including duration-preserved repeats, then rendered as static frame contacts. No continuous playback, browser or Godot observation.','groups':summary})
    print(json.dumps({'pose_comparison_pages':math.ceil(len(poses)/8),'group_frame_contacts':len(c['groups']),'gif_files_decoded':len(summary)}))

def mark_observed_reviews():
    observed=packing.read(REPORT/'visual-review-observations.json')
    assert {p['pose_id'] for p in observed['poses']} == set(pm)
    for p in observed['poses']:
        packing.mark_review('dread_knight',[p['pose_id']],p['observations']+' Static native/enlarged source and exact-mirror review; no continuous playback, engine or human acceptance.')
    print(json.dumps({'helper_reviewed_pose_ids':len(observed['poses'])}))

def finalize_evidence():
    manifest=packing.read(DEST/'source_manifest.json')
    observed=packing.read(REPORT/'visual-review-observations.json')
    validations=packing.validate('dread_knight')
    assert validations['complete'] and not validations['errors']
    assert manifest['coverage']['reviewed_poses']==62
    provenance=[]
    for path in sorted((DEST/'_source/prompts').glob('*.tool.json')):
        tool=packing.read(path)
        reference_paths=tool.get('references',tool.get('reference_paths'))
        references=[{'file':packing.rel(DEST/ref),'sha256':sha(DEST/ref)} for ref in reference_paths]
        prompt=path.with_name(path.name.replace('.tool.json','.txt'))
        provenance.append({'tool':'built-in image_gen','transparent_background_requested':tool['transparent_background'],'tool_metadata':packing.rel(path),'tool_metadata_sha256':sha(path),'returned_output_hint':tool['output_hint'],'exact_prompt_file':packing.rel(prompt),'exact_prompt_sha256':sha(prompt),'actual_reference_paths_and_sha256':references,'seed_reported':False,'model_identifier_reported':False})
    submissions=[]
    for path in sorted((DEST/'_source/raw').glob('*.submission.json')):
        record=packing.read(path)
        assert sha(ROOT/record['raw_source'])==record['raw_sha256']
        submissions.append({'record':packing.rel(path),'raw_source':record['raw_source'],'raw_sha256':record['raw_sha256'],'pose_ids':record['pose_ids'],'components':record['components']})
    save_json(REPORT/'generation-provenance.json',{'creature_id':'dread_knight','built_in_calls':len(provenance),'generated_figure_attempts':68,'new_selected_poses':62,'approved_master_reused_poses':0,'calls':provenance,'retained_submissions':submissions,'failed_ingestion':{'batch':'batch-000-v01','method':'Pillow adaptive clear gutters','error':'Figure touches raw/grid boundary: dread_knight_p000; preserve attempt and regenerate','resolution':'Same byte-identical raw page successfully isolated with user-approved strict components as batch-000-v01-components; no image pixels painted.'},'pose_repairs':{'pose_ids':['dread_knight_p008','dread_knight_p017','dread_knight_p030','dread_knight_p031','dread_knight_p041','dread_knight_p055'],'selected_batch':'repair-six-v02','original_raw_and_pose_metadata_retained':True}})
    evidence=[]
    for p in observed['poses']:
        record=packing.read(DEST/'poses'/(p['pose_id']+'.json'))
        evidence.append(dict(p,registered_pose_sha256=record['registered_pose_sha256'],mirror_sha256=record['mirror_sha256'],raw_source=record['raw_source'],raw_sha256=record['raw_sha256'],isolated_source=record['isolated_source'],isolated_sha256=record['isolated_sha256']))
    groups=[]
    for observation in observed['groups']:
        g=next(g for g in manifest['groups'] if g['group_id']==observation['group_id'])
        base=f'group_{g["group_id"]:02d}_block_{g["original_block"]:02d}'
        groups.append(dict(observation,source_order=g['pose_ids_in_source_order'],exact_aliases=g['exact_aliases'],atlas_sha256=g['sha256'],mirror_atlas_sha256=g['mirror_sha256'],source_contact=g['contact'],source_contact_sha256=sha(ROOT/g['contact']),decoded_both_facings=packing.rel(REPORT/'review-images'/f'{base}-both-facings-decoded.png')))
    resources=[]
    for name in ['original_groups.tres','original_groups_mirrored.tres']:
        path=DEST/name
        text=path.read_text(encoding='utf-8')
        assert text.count('[ext_resource ')==18
        assert text.count('[sub_resource type="AtlasTexture"')==125
        assert text.count('"name": &"og_')==18
        resources.append({'file':packing.rel(path),'sha256':sha(path),'animation_count':18,'atlas_frame_subresources':125,'text_structure_checked':True,'engine_load_checked':False})
    save_json(REPORT/'visual-review-evidence.json',{'creature_id':'dread_knight','coverage':manifest['coverage'],'method':observed['method'],'source_manifest_sha256':sha(DEST/'source_manifest.json'),'poses':evidence,'groups':groups,'spriteframes':resources,'blocking_defects':observed['remaining_blocking_defects'],'nonblocking_limits':observed['nonblocking_limits'],'human_animation_acceptance':False,'browser_review':False,'godot_validation':False,'continuous_playback_observed':False,'original_timing_verified':False})
    save_json(REPORT/'validation-final.json',validations)
    print(json.dumps({'coverage':manifest['coverage'],'complete':validations['complete'],'errors':validations['errors'],'spriteframes_resources':len(resources),'calls_with_exact_prompts_and_reference_hashes':len(provenance)}))

if __name__=='__main__':
    if len(sys.argv)>1 and sys.argv[1]=='mark':
        mark_observed_reviews()
    elif len(sys.argv)>1 and sys.argv[1]=='finalize':
        finalize_evidence()
    else:
        check_sources()
        if (DEST/'source_manifest.json').exists():render_reviews()
