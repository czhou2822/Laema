"""Mechanical Walking Dead evidence only: no drawing, recoloring or warping art."""
import argparse
import hashlib
import importlib.util
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
ASSET = ROOT / 'assets/prototype/enemy/walking_dead/remaster_v01'
spec = importlib.util.spec_from_file_location('necropolis_worker_parent', ROOT / 'tools/art/necropolis_remaster.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)

def save_data(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')

def relative(path):
    return Path(path).resolve().relative_to(ROOT).as_posix()

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def union_box(images, threshold=8):
    boxes = [helper.bbox(im, threshold) for im in images]
    boxes = [b for b in boxes if b]
    return (max(0,min(b[0] for b in boxes)-12),max(0,min(b[1] for b in boxes)-12),
            min(images[0].width,max(b[2] for b in boxes)+12),min(images[0].height,max(b[3] for b in boxes)+12))

def paste_fit(canvas, im, region, tile, method):
    im = helper.matte(im.crop(region))
    scale=min((tile[2]-12)/im.width,(tile[3]-28)/im.height)
    im=im.resize((max(1,round(im.width*scale)),max(1,round(im.height*scale))),method)
    canvas.paste(im,(tile[0]+(tile[2]-im.width)//2,tile[1]+22+(tile[3]-28-im.height)//2))

def comparisons():
    creature = helper.creature('walking_dead')
    poses = helper.posemap(creature)
    output = ASSET / '_source/review'
    output.mkdir(parents=True,exist_ok=True)
    index = {'creature_id':'walking_dead','method':'Static comparison images and decoded GIF frames; no playback or human acceptance','groups':[]}
    for group in creature['groups']:
        stem = f'group_{group["group_id"]:02d}_block_{group["original_block"]:02d}'
        ids = group['pose_ids_in_source_order']
        ogs = [helper.projected_original(poses[pid]) for pid in ids]
        news = [Image.open(ASSET/'poses'/f'{pid}.png').convert('RGBA') for pid in ids]
        region = union_box(ogs+news)
        count = len(ids)
        cols = min(4,count)
        rows = math.ceil(count/cols)
        # Same union crop and same fit for both figures: do not normalize each pose.
        comparison = Image.new('RGB',(cols*512,rows*640),(23,36,49))
        draw = ImageDraw.Draw(comparison)
        for i,(pid,og,new) in enumerate(zip(ids,ogs,news)):
            x=(i%cols)*512;y=(i//cols)*640
            draw.text((x+8,y+5),f'F{i:02d} {pid}: original | candidate',fill='white')
            paste_fit(comparison,og,region,(x,y+10,256,610),Image.Resampling.NEAREST)
            paste_fit(comparison,new,region,(x+256,y+10,256,610),Image.Resampling.LANCZOS)
        cp=output/(stem+'_enlarged_comparison.png');comparison.save(cp)
        gif_records=[]
        decoded=[]
        for facing in ['source','mirror']:
            path=ASSET/'previews'/(stem+'_'+facing+'.gif')
            frames=[];durations=[]
            with Image.open(path) as gif:
                for i in range(gif.n_frames):
                    gif.seek(i)
                    frames.append(gif.convert('RGBA').copy())
                    durations.append(gif.info.get('duration',0))
            decoded.append(frames)
            gif_records.append({'facing':facing,'path':relative(path),'sha256':sha(path),
                'decoded_frames':len(frames),'durations_ms':durations,'total_duration_ms':sum(durations)})
        # GIFs are already matte; derive shared crop from the corresponding pose bounds.
        candidate_region=union_box(news+[ImageOps.mirror(im) for im in news])
        small_region=tuple(round(v/2) for v in candidate_region)
        max_frames=max(len(frames) for frames in decoded)
        gcols=min(5,max_frames);grows=math.ceil(max_frames/gcols)
        strip=Image.new('RGB',(gcols*300,grows*2*360),(23,36,49));draw=ImageDraw.Draw(strip)
        for orientation,frames in enumerate(decoded):
            for i,frame in enumerate(frames):
                x=i%gcols*300;y=(orientation*grows+i//gcols)*360
                piece=frame.crop(small_region).convert('RGB')
                scale=min(288/piece.width,324/piece.height)
                piece=piece.resize((max(1,round(piece.width*scale)),max(1,round(piece.height*scale))),Image.Resampling.LANCZOS)
                strip.paste(piece,(x+(300-piece.width)//2,y+28+(324-piece.height)//2))
                draw.text((x+6,y+6),f'{["source","mirror"][orientation]} GIF frame {i}',fill='white')
        gp=output/(stem+'_decoded_gif_both_facings.png');strip.save(gp)
        index['groups'].append({'group_id':group['group_id'],'original_block':group['original_block'],
            'pose_ids_in_source_order':ids,'source_positions':count,'helper_contact':relative(ASSET/'contacts'/(stem+'.png')),
            'enlarged_comparison':relative(cp),'decoded_gif_both_facings':relative(gp),'gif_records':gif_records,
            'visual_inspection_status':'pending'})
    save_data(REPORT/'review-artifact-index.json',index)
    print(json.dumps({'comparison_groups':len(index['groups']),'output':relative(output)},indent=2))

def provenance():
    records=[]
    for path in sorted((ASSET/'_source/tool-metadata').glob('*.json')):
        metadata=helper.read(path)
        refs=[]
        for ref in metadata['referenced_image_paths']:
            fp=ROOT/ref
            refs.append({'path':ref,'sha256':sha(fp)})
        prompt=ASSET/'_source/prompts'/(metadata['attempt']+'.txt')
        record={'attempt':metadata['attempt'],'tool_metadata':relative(path),'references':refs,
                'prompt':relative(prompt),'prompt_sha256':sha(prompt) if prompt.exists() else None}
        records.append(record)
    save_data(REPORT/'generation-reference-provenance.json',{
        'creature_id':'walking_dead','helper_current_sha256':sha(ROOT/'tools/art/necropolis_remaster.py'),
        'plan_sha256':sha(ROOT/'docs/art/remasters/necropolis-v01/generation-plan.json'),
        'attempts':records,'seeds_or_models_invented':False})
    print(json.dumps({'attempts':len(records)},indent=2))

def record_reviews():
    creature=helper.creature('walking_dead')
    observations=helper.read(REPORT/'visual-observations.json')
    required={p['pose_id'] for p in creature['poses']}
    if set(observations['pose_notes'])!=required:
        raise ValueError('Visual observations must cover exactly the assigned creature poses')
    if set(observations['group_notes'])!={str(g['group_id']) for g in creature['groups']}:
        raise ValueError('Group observations must cover exactly the assigned creature groups')
    results=[]
    for pose in creature['poses']:
        pid=pose['pose_id']
        note=observations['pose_notes'][pid]+' Static OG/candidate and both-facing frame inspection only; candidate, not human animation acceptance.'
        results.append(helper.mark_review('walking_dead',[pid],note))
    save_data(REPORT/'review-marking-result.json',{'creature_id':'walking_dead',
        'reviewed_pose_ids':[p['pose_id'] for p in creature['poses']],
        'method':'Parent helper mark_review, one explicit observation per pose',
        'observations_sha256':sha(REPORT/'visual-observations.json')})
    print(json.dumps({'reviewed_poses':len(results)},indent=2))

def evidence():
    creature=helper.creature('walking_dead')
    manifest=helper.read(ASSET/'source_manifest.json')
    observations=helper.read(REPORT/'visual-observations.json')
    index=helper.read(REPORT/'review-artifact-index.json')
    reviews=[]
    for pose in manifest['poses']:
        review=pose['visual_review']
        if not isinstance(review,dict) or review['source_sha256_at_review']!=pose['registered_pose_sha256']:
            raise ValueError('Missing/stale visual review '+pose['pose_id'])
        reviews.append({'pose_id':pose['pose_id'],'status':'worker_reviewed_candidate',
            'observation':observations['pose_notes'][pose['pose_id']],
            'artwork_origin':pose['artwork_origin'],'original_signature':pose['original_signature'],
            'original_group_id':pose['original_representative']['group_id'],
            'original_frame_index':pose['original_representative']['frame_index'],
            'raw_source':pose['raw_source'],'raw_sha256':pose['raw_sha256'],
            'isolated_source':pose['isolated_source'],'isolated_sha256':pose['isolated_sha256'],
            'registered_pose_file':pose['registered_pose_file'],'registered_pose_sha256':pose['registered_pose_sha256'],
            'mirror_file':pose['mirror_file'],'mirror_sha256':pose['mirror_sha256'],
            'registration':pose['registration'],'component_isolation':pose['component_isolation'],
            'human_animation_acceptance':False})
    group_reviews=[]
    for group,artifacts in zip(manifest['groups'],index['groups']):
        if group['group_id']!=artifacts['group_id']:raise ValueError('Review artifact order mismatch')
        artifacts['visual_inspection_status']='source contact and every decoded GIF frame inspected with view_image'
        group_reviews.append({'group_id':group['group_id'],'original_block':group['original_block'],
            'frame_count':group['frame_count'],'pose_ids_in_source_order':group['pose_ids_in_source_order'],
            'exact_aliases':group['exact_aliases'],'status':'worker_reviewed_candidate',
            'observation':observations['group_notes'][str(group['group_id'])],
            'source_contact_viewed':True,'contact':group['contact'],'contact_sha256':sha(ROOT/group['contact']),
            'enlarged_comparison':artifacts['enlarged_comparison'],
            'enlarged_comparison_viewed':group['group_id'] not in [9,10],
            'decoded_gif_both_facings_viewed':True,'decoded_gif_sheet':artifacts['decoded_gif_both_facings'],
            'gif_records':artifacts['gif_records'],'real_time_playback_performed':False,
            'atlas':group['file'],'atlas_sha256':group['sha256'],
            'mirror_atlas':group['mirror_file'],'mirror_atlas_sha256':group['mirror_sha256']})
    returned_raw=[]
    import re
    for metadata_file in sorted((ASSET/'_source/tool-metadata').glob('*.json')):
        metadata=helper.read(metadata_file)
        source=re.search(r'as (C:\\[^\n]+?\.png) by default',metadata['returned_metadata']['output_hint'])
        if not source:raise ValueError('Returned PNG path unavailable: '+metadata['attempt'])
        archive=ASSET/'_source/raw'/(metadata['attempt']+'.png')
        if sha(source.group(1))!=sha(archive):raise ValueError('Raw output copy mismatch: '+metadata['attempt'])
        returned_raw.append({'attempt':metadata['attempt'],'raw':relative(archive),
            'sha256':sha(archive),'byte_identical_to_returned_file':True})
    origins={label:sum(p['artwork_origin']==label for p in manifest['poses'])
             for label in sorted({p['artwork_origin'] for p in manifest['poses']})}
    result={'creature_id':'walking_dead','status':'complete_worker_candidate_awaiting_parent_checks',
        'coverage':manifest['coverage'],'new_artwork_poses':origins.get('built-in image-generation artwork',0),
        'approved_idle_reused_poses':origins.get('approved high-resolution idle master reuse',0),
        'generation_calls':len(returned_raw),'original_timing_verified':False,'human_animation_acceptance':False,
        'browser_validation_performed':False,'godot_validation_performed':False,
        'review_basis':observations['review_basis'],'unresolved_blocking_defects':observations['unresolved_blocking_defects'],
        'review_limits':observations['review_limits'],'repairs':observations['repairs'],
        'poses':reviews,'groups':group_reviews,'returned_raw_copy_verification':returned_raw,
        'source_manifest_sha256':sha(ASSET/'source_manifest.json'),
        'spriteframes':[{ 'path':relative(ASSET/name),'sha256':sha(ASSET/name)}
                        for name in ['original_groups.tres','original_groups_mirrored.tres']],
        'file_counts':{'group_atlases':len(list(ASSET.glob('group_*.png'))),
            'frame_pngs':len(list((ASSET/'frames').rglob('*.png'))),
            'gif_previews':len(list((ASSET/'previews').glob('*.gif'))),
            'helper_contacts':len(list((ASSET/'contacts').glob('*.png'))),
            'source_plus_mirrored_positions':creature['original_frame_positions']*2,
            'decoded_gif_frames_both_facings':sum(gif['decoded_frames'] for g in index['groups'] for gif in g['gif_records'])}}
    save_data(REPORT/'review-artifact-index.json',index)
    save_data(REPORT/'visual-review.json',result)
    print(json.dumps({'coverage':manifest['coverage'],'origins':origins,'file_counts':result['file_counts'],
        'generation_calls':len(returned_raw),'raw_copies_verified':len(returned_raw)},indent=2))

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('command',choices=['comparisons','provenance','record-reviews','evidence'])
    args=parser.parse_args()
    {'comparisons':comparisons,'provenance':provenance,'record-reviews':record_reviews,'evidence':evidence}[args.command]()
