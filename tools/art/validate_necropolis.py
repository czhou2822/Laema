#!/usr/bin/env python3
"""Independent source/asset checks; intentionally does not import the packer."""
import argparse
import hashlib
import json
import math
import re
import subprocess
from pathlib import Path
from PIL import Image,ImageOps

ROOT=Path(__file__).resolve().parents[2]
DOC=ROOT/'docs/art/remasters/necropolis-v01'
CELL=(1024,768);SCALE=180/73

def read(path):return json.loads(Path(path).read_text(encoding='utf-8-sig'))
def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()
def key(f):return ':'.join(str(f[x]) for x in ['index_sha256','left','top','width','height','full_width','full_height'])
def body(im):return im.getchannel('A').point(lambda a:255 if a>160 else 0).getbbox()
def crop(im,r):x,y,w,h=r;return im.crop((x,y,x+w,y+h))

def main():
    plan=read(DOC/'generation-plan.json')
    ap=argparse.ArgumentParser();ap.add_argument('--allow-incomplete',action='store_true')
    ap.add_argument('--creature',action='append',choices=[c['creature_id'] for c in plan['creatures']],help='Validate a finished subset without racing other workers; omit for the complete collection')
    args=ap.parse_args();errors=[];missing=[];records=[];indexed_checked=0;cells=0;mirrors=0;gif_positions=0
    selected=[c for c in plan['creatures'] if not args.creature or c['creature_id'] in args.creature]
    for c in selected:
        cid=c['creature_id'];native=read(ROOT/c['original_metadata']);dd=ROOT/'assets/prototype/enemy'/cid/'remaster_v01'
        if sha(ROOT/c['original_def'])!=c['original_def_sha256']:errors.append(cid+': original DEF hash')
        if sha(ROOT/c['original_metadata'])!=c['original_metadata_sha256']:errors.append(cid+': original metadata hash')
        if sha(ROOT/c['appearance_reference'])!=c['appearance_reference_sha256']:errors.append(cid+': approved master changed')
        signatures={};native_groups={};page_cache={};metadata_dir=(ROOT/c['original_metadata']).parent
        for group in native['groups']:
            sequence=[]
            for frame in group['frames']:
                page=group['pages'][frame['page']];indexed=metadata_dir/page['indexed']
                if indexed not in page_cache:page_cache[indexed]=Image.open(indexed).copy()
                rect=(frame['x']+frame['left'],frame['y']+frame['top'],frame['x']+frame['left']+frame['width'],frame['y']+frame['top']+frame['height'])
                if hashlib.sha256(page_cache[indexed].crop(rect).tobytes()).hexdigest()!=frame['index_sha256']:
                    errors.append(f'{cid}: indexed pixels G{group["id"]} F{frame["index"]}')
                indexed_checked+=1;signature=key(frame);signatures[signature]=frame;sequence.append(signature)
            native_groups[(group['id'],group['block'])]=sequence
        if len(signatures)!=c['unique_registered_poses']:errors.append(cid+': unique original signatures')
        by_id={p['pose_id']:p for p in c['poses']}
        for group in c['groups']:
            expected=native_groups[(group['group_id'],group['original_block'])]
            got=[by_id[p]['original_signature'] for p in group['pose_ids_in_source_order']]
            if expected!=got:errors.append(cid+': plan source order G'+str(group['group_id']))
            aliases=sorted(gid for (gid,block),seq in native_groups.items() if gid!=group['group_id'] and seq==expected)
            if aliases!=sorted(group['exact_aliases']):errors.append(cid+': alias map G'+str(group['group_id']))
            for index,pid in enumerate(group['pose_ids_in_source_order']):
                occurrence=[r for r in by_id[pid]['occurrences'] if r['group_id']==group['group_id'] and r['original_block']==group['original_block'] and r['frame_index']==index]
                original_group=next(g for g in native['groups'] if g['id']==group['group_id'] and g['block']==group['original_block'])
                if len(occurrence)!=1 or occurrence[0]['source_record']!=original_group['frames'][index]:errors.append(cid+': lost native occurrence '+pid)
        mf=dd/'source_manifest.json'
        if not mf.exists():missing.extend(cid+':'+p for p in by_id);records.append({'creature_id':cid,'available_poses':0,'complete_groups':0});continue
        manifest=read(mf);pose_records={p['pose_id']:p for p in manifest['poses']}
        available={}
        for pid,source_pose in by_id.items():
            p=pose_records.get(pid)
            if not p:missing.append(pid);continue
            actual=Image.open(ROOT/p['registered_pose_file']).convert('RGBA');mirror=Image.open(ROOT/p['mirror_file']).convert('RGBA')
            if actual.size!=CELL or mirror.size!=CELL:errors.append(pid+': cell size')
            if sha(ROOT/p['registered_pose_file'])!=p['registered_pose_sha256'] or sha(ROOT/p['mirror_file'])!=p['mirror_sha256']:errors.append(pid+': pose hash')
            if p['original_signature']!=source_pose['original_signature']:errors.append(pid+': source signature')
            if ImageOps.mirror(actual).tobytes()!=mirror.tobytes():errors.append(pid+': exact mirror')
            mirrors+=1
            bounds=actual.getchannel('A').getbbox()
            if not bounds or bounds[0]<40 or bounds[1]<40 or bounds[2]>984 or bounds[3]>728:errors.append(pid+': alpha/padding')
            if sha(ROOT/p['raw_source'])!=p['raw_sha256'] or sha(ROOT/p['isolated_source'])!=p['isolated_sha256']:errors.append(pid+': raw/isolation provenance')
            if p['artwork_origin'] not in ['built-in image-generation artwork','approved high-resolution idle master reuse']:errors.append(pid+': unsupported artwork origin')
            if p['artwork_origin']=='approved high-resolution idle master reuse':
                if pid!=c['og_idle_reference_pose_id'] or p['raw_sha256']!=c['appearance_reference_sha256']:errors.append(pid+': invalid idle reuse')
            elif not p.get('prompt') or not (ROOT/p['prompt']).is_file():errors.append(pid+': exact prompt missing')
            # Recompute opaque source bounds from the original page, not saved packing bounds.
            r=source_pose['representative'];native_cell=crop(Image.open(ROOT/r['rgba_sheet']).convert('RGBA'),r['sheet_cell_region']);bb=body(native_cell)
            source_rect=[bb[0],bb[1],bb[2]-bb[0],bb[3]-bb[1]]
            if source_rect!=source_pose['opaque_body_rect'] or source_rect!=p['registration']['source_body_rect']:errors.append(pid+': original body measurement')
            isolated=Image.open(ROOT/p['isolated_source']).convert('RGBA')
            ab=isolated.getchannel('A').point(lambda a:255 if a>8 else 0).getbbox();art=isolated.crop(ab)
            x,y,w,h=source_rect;fit=min(max(1,round(w*SCALE))/art.width,max(1,round(h*SCALE))/art.height)
            size=(max(1,round(art.width*fit)),max(1,round(art.height*fit)))
            pos=(round(512+(x+w/2-196)*SCALE-size[0]/2),round(512+(y+h-268)*SCALE-size[1]))
            expected=Image.new('RGBA',CELL);expected.alpha_composite(art.resize(size,Image.Resampling.LANCZOS),pos)
            if expected.tobytes()!=actual.tobytes():errors.append(pid+': independent raw-to-registration equality')
            review=p.get('visual_review')
            if not isinstance(review,dict) or review.get('source_sha256_at_review')!=p['registered_pose_sha256'] or review.get('mirror_sha256_at_review')!=p['mirror_sha256']:errors.append(pid+': visual review missing/stale')
            available[pid]=(actual,mirror)
        complete=0;preview_hashes={}
        for group in manifest['groups']:
            original_group=next(g for g in c['groups'] if g['group_id']==group['group_id'] and g['original_block']==group['original_block'])
            if group['pose_ids_in_source_order']!=original_group['pose_ids_in_source_order']:errors.append(cid+': manifest source order')
            if not group['complete']:continue
            complete+=1
            atlases=[Image.open(ROOT/group[k]).convert('RGBA') for k in ['file','mirror_file']]
            for k in ['file','mirror_file']:
                expected_hash=group['sha256'] if k=='file' else group['mirror_sha256']
                if sha(ROOT/group[k])!=expected_hash:errors.append(cid+': atlas hash '+str(group['group_id']))
            n=group['frame_count'];expected_size=(4096,math.ceil(n/4)*768)
            if any(im.size!=expected_size for im in atlases):errors.append(cid+': atlas size')
            for i,pid in enumerate(group['pose_ids_in_source_order']):
                region=[i%4*1024,i//4*768,1024,768]
                for orientation,atlas,picture in zip(['source','mirror'],atlases,available.get(pid,(None,None))):
                    if picture is None:errors.append(pid+': false group completion');continue
                    fp=dd/'frames'/orientation/f'g{group["group_id"]:02d}_b{group["original_block"]:02d}'/f'{i:03d}.png'
                    if crop(atlas,region).tobytes()!=picture.tobytes():errors.append(pid+': atlas/frame equality')
                    if not fp.exists() or Image.open(fp).convert('RGBA').tobytes()!=picture.tobytes():errors.append(pid+': individual timeline frame')
                cells+=1
            for i in range(n,math.ceil(n/4)*4):
                if any(crop(atlas,[i%4*1024,i//4*768,1024,768]).getbbox() for atlas in atlases):errors.append(cid+': atlas padding')
            for orientation,suffix in enumerate(['source','mirror']):
                fp=dd/'previews'/f'group_{group["group_id"]:02d}_block_{group["original_block"]:02d}_{suffix}.gif'
                gif=Image.open(fp);duration=0;logical=0
                for i in range(gif.n_frames):
                    gif.seek(i);hold=gif.info.get('duration',0);duration+=hold
                    if hold<=0 or hold%100:errors.append(cid+': GIF nonintegral review hold');continue
                    decoded=hashlib.sha256(gif.convert('RGB').tobytes()).hexdigest()
                    for _ in range(hold//100):
                        if logical>=n:errors.append(cid+': GIF extra timeline position');break
                        pid=group['pose_ids_in_source_order'][logical];cache_key=(pid,orientation)
                        if pid not in available:errors.append(pid+': GIF unavailable pose');logical+=1;continue
                        if cache_key not in preview_hashes:
                            picture=available[pid][orientation];matte=Image.new('RGBA',CELL,(23,36,49,255));matte.alpha_composite(picture)
                            # Independently reproduce half-size RGB preview and GIF palette conversion.
                            expected=matte.convert('RGB').resize((512,384),Image.Resampling.LANCZOS).convert('P',palette=Image.Palette.ADAPTIVE).convert('RGB')
                            preview_hashes[cache_key]=hashlib.sha256(expected.tobytes()).hexdigest()
                        if decoded!=preview_hashes[cache_key]:errors.append(f'{cid}: GIF content/order G{group["group_id"]} {suffix} F{logical}')
                        logical+=1;gif_positions+=1
                if gif.size!=(512,384) or duration!=n*100:errors.append(cid+': GIF framing/timeline duration')
                if logical!=n:errors.append(cid+': GIF missing logical positions')
        if complete==c['original_group_slots']:
            for name in ['original_groups.tres','original_groups_mirrored.tres']:
                resource=dd/name
                if not resource.exists():errors.append(cid+': SpriteFrames missing '+name);continue
                text=resource.read_text()
                if text.count('[sub_resource type="AtlasTexture"')!=c['original_frame_positions']:errors.append(cid+': SpriteFrames cell count')
                if text.count('"speed": 10.0')!=c['original_group_slots']:errors.append(cid+': SpriteFrames group count')
                for path in re.findall(r'path="res://([^"]+)"',text):
                    if not (ROOT/path).is_file():errors.append(cid+': SpriteFrames path '+path)
        records.append({'creature_id':cid,'available_poses':len(available),'complete_groups':complete,'source_signatures':len(signatures),'manifest_sha256':sha(mf)})
    # Compare the entire frozen published master package byte-for-byte to Git's blobs.
    baseline='72bfc2853ac4258391be6a3c905b62328cac53ee';preserved=0
    listing=subprocess.run(['git','ls-tree','-r','-z',baseline,'--','docs/art/production/necropolis-creature-assets-v01'],cwd=ROOT,capture_output=True,check=True).stdout
    for entry in listing.split(b'\0'):
        if not entry:continue
        header,path=entry.split(b'\t',1);expected=header.split()[2].decode();fp=ROOT/path.decode('utf-8');blob=fp.read_bytes()
        if hashlib.sha1(b'blob '+str(len(blob)).encode()+b'\0'+blob).hexdigest()!=expected:errors.append('Frozen master-package file changed: '+str(fp.relative_to(ROOT)))
        preserved+=1
    full=len(records)==14 and sum(r['complete_groups'] for r in records)==228 and cells==1378 and not missing
    selection_complete=len(records)==len(selected) and sum(r['complete_groups'] for r in records)==sum(c['original_group_slots'] for c in selected) and not missing
    report={'scope':'independent source and asset file checks; not human acceptance or engine/browser proof',
        'selection':[c['creature_id'] for c in selected],'collection_run':not bool(args.creature),
        'generation_plan_sha256':sha(DOC/'generation-plan.json'),'validator_sha256':sha(Path(__file__)),
        'source_indexed_crops_rehashed':indexed_checked,'source_groups':sum(c['original_group_slots'] for c in selected),'source_pose_signatures':sum(c['unique_registered_poses'] for c in selected),
        'registered_mirror_pairs_checked':mirrors,'source_timeline_cells_verified':cells,
        'gif_logical_positions_content_verified':gif_positions,
        'frozen_master_package_files_checked':preserved,'full_coverage':full,'errors':errors,'missing_pose_ids':missing,'creatures':records,
        'selection_complete':selection_complete,'passed':selection_complete and not errors,'original_timing_verified':False,'human_animation_acceptance':False}
    name='independent-asset-qa.json' if not args.creature else 'independent-'+ '-'.join(c['creature_id'] for c in selected)+'-qa.json'
    if len(name)>90:name='independent-subset-'+hashlib.sha256('|'.join(c['creature_id'] for c in selected).encode()).hexdigest()[:12]+'-qa.json'
    output=DOC/'validation'/name;output.parent.mkdir(parents=True,exist_ok=True)
    if output.exists():
        archive=output.parent/'attempts'/(output.stem+'-'+sha(output)[:16]+'.json')
        archive.parent.mkdir(exist_ok=True)
        if not archive.exists():archive.write_bytes(output.read_bytes())
    output.write_text(json.dumps(report,indent=2)+'\n')
    summary={k:v for k,v in report.items() if k not in ['missing_pose_ids','creatures','errors']}
    summary.update(error_count=len(errors),missing_pose_count=len(missing),errors_sample=errors[:20],report_path=output.relative_to(ROOT).as_posix());print(json.dumps(summary))
    if errors or (not selection_complete and not args.allow_incomplete):raise SystemExit(1)

if __name__=='__main__':main()
