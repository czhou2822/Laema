"""Creature-local provenance/registration/export audit, without engine execution."""
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path
from PIL import Image, ImageChops, ImageOps

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
sys.path.insert(0, str(ROOT/'tools/art'))
import necropolis_remaster as h

report = Path(__file__).resolve().parent
dd = h.dest('black_knight')
c = h.creature('black_knight')
m = h.read(dd/'source_manifest.json')
v = h.read(report/'visual-review.json')
errors = []
def check(value, message):
    if not value:
        errors.append(message)

check(m['coverage']['available_poses']==58 and m['coverage']['reviewed_poses']==58, 'Pose/review coverage')
check(m['coverage']['complete_groups']==15 and not m['coverage']['missing_pose_ids'], 'Group coverage')
pose_records = {p['pose_id']:p for p in m['poses']}
visual_records = {p['pose_id']:p for p in v['poses']}
for p in c['poses']:
    pid = p['pose_id']
    r = h.read(dd/'poses'/(pid+'.json'))
    actual = h.sha(ROOT/r['registered_pose_file'])
    mirror_sha = h.sha(ROOT/r['mirror_file'])
    check(r['visual_review']['source_sha256_at_review']==actual, 'Stale source review '+pid)
    check(r['visual_review']['mirror_sha256_at_review']==mirror_sha, 'Stale mirror review '+pid)
    check(visual_records[pid]['registered_pose_sha256']==actual, 'Stale report source '+pid)
    check(visual_records[pid]['mirror_sha256']==mirror_sha, 'Stale report mirror '+pid)
    check(h.sha(ROOT/r['raw_source'])==r['raw_sha256'], 'Raw SHA '+pid)
    check(h.sha(ROOT/r['isolated_source'])==r['isolated_sha256'], 'Isolated SHA '+pid)
    raw = Image.open(ROOT/r['raw_source']).convert('RGBA')
    isolated = Image.open(ROOT/r['isolated_source']).convert('RGBA')
    x,y,w,hh = r['source_grid_region']
    if r['component_isolation']:
        check(isolated.size==(w+4,hh+4), 'Isolated padding '+pid)
        retained = isolated.crop((2,2,w+2,hh+2))
        native_raw = raw.crop((x,y,x+w,y+hh))
        check(retained.convert('RGB').tobytes()==native_raw.convert('RGB').tobytes(), 'Isolated RGB differs from raw '+pid)
        aa = retained.getchannel('A').tobytes()
        bb = native_raw.getchannel('A').tobytes()
        check(all(a==0 or a==b for a,b in zip(aa,bb)), 'Painted/altered isolated alpha '+pid)
    regenerated,registration = h.register(p,isolated)
    exported = Image.open(ROOT/r['registered_pose_file']).convert('RGBA')
    check(regenerated.tobytes()==exported.tobytes(), 'Registration regeneration '+pid)
    check(registration==r['registration'], 'Registration metadata '+pid)
    check(ImageOps.mirror(exported).tobytes()==Image.open(ROOT/r['mirror_file']).convert('RGBA').tobytes(), 'Exact mirror '+pid)

attempts = []
invented_figures = 0
for path in sorted((dd/'_source').glob('*.request.json')):
    attempt = path.name.replace('.request.json','')
    request = h.read(path)
    tool_record = h.read(path.with_name(attempt+'.tool.json'))
    archive_record = h.read(dd/'_source/raw'/(attempt+'.submission.json'))
    raw_copy = path.with_name(attempt+'.png')
    tool_path = Path(re.search(r'as (C:\\[^\r\n]+?\.png) by default',tool_record['returned_metadata']['output_hint']).group(1))
    actual = h.sha(raw_copy)
    check(h.sha(tool_path)==actual, 'Tool output copy differs '+attempt)
    check(h.sha(ROOT/archive_record['raw_source'])==actual, 'Archive copy differs '+attempt)
    check(archive_record['raw_sha256']==actual, 'Submission SHA differs '+attempt)
    prompt_file = ROOT/tool_record['prompt_file']
    check(request['prompt'].strip()==prompt_file.read_text(encoding='utf-8-sig').strip(), 'Prompt content differs '+attempt)
    check(request['transparent_background'] is True, 'Transparency not requested '+attempt)
    refs = [{'path':h.rel(p),'sha256':h.sha(p)} for p in request['referenced_image_paths']]
    invented_figures += len(archive_record['pose_ids'])
    attempts.append({'attempt':attempt,'request':h.rel(path),'request_sha256':h.sha(path),'exact_tool_prompt_utf8_sha256':hashlib.sha256(request['prompt'].encode('utf-8')).hexdigest(),'reference_hashes':refs,'raw_source':h.rel(raw_copy),'raw_sha256':actual,'tool_output_copy_matches':True,'pose_ids':archive_record['pose_ids']})

group_records = {g['group_id']:g for g in m['groups']}
frames_checked = 0
alias_checks = []
for g in m['groups']:
    original = next(x for x in c['groups'] if x['group_id']==g['group_id'])
    check(g['pose_ids_in_source_order']==original['pose_ids_in_source_order'], 'Original order '+str(g['group_id']))
    for alias in g['exact_aliases']:
        other = group_records[alias]
        check(g['sha256']==other['sha256'] and g['mirror_sha256']==other['mirror_sha256'], 'Alias bytes '+str(g['group_id']))
        alias_checks.append([g['group_id'],alias])
    for i,pid in enumerate(g['pose_ids_in_source_order']):
        for facing in ['source','mirror']:
            fp = dd/'frames'/facing/f'g{g["group_id"]:02d}_b{g["original_block"]:02d}'/f'{i:03d}.png'
            expected = dd/'poses'/(pid+('_mirror' if facing=='mirror' else '')+'.png')
            check(Image.open(fp).convert('RGBA').tobytes()==Image.open(expected).convert('RGBA').tobytes(), f'Frame order {g["group_id"]}/{i}/{facing}')
            frames_checked += 1

resources = []
for name in ['original_groups.tres','original_groups_mirrored.tres']:
    path = dd/name
    text = path.read_text(encoding='utf-8')
    check(text.count('[sub_resource type="AtlasTexture"')==92, 'SpriteFrames frame count '+name)
    check(text.count('[ext_resource type="Texture2D"')==15, 'SpriteFrames group count '+name)
    check('metadata/preview_only = true' in text and 'metadata/original_timing_verified = false' in text, 'Preview timing metadata '+name)
    for target in re.findall(r'path="res://([^"]+)"',text):
        check((ROOT/target).is_file(), 'Missing SpriteFrames atlas '+target)
    resources.append({'path':h.rel(path),'sha256':h.sha(path),'groups':15,'positions':92,'engine_import_checked':False})

result = {'creature_id':'black_knight','complete':not errors,'coverage':m['coverage'],'errors':errors,'raw_attempts':len(attempts),'new_figure_drawings_across_all_attempts':invented_figures,'final_new_art_poses':sum(p['artwork_origin']=='built-in image-generation artwork' for p in m['poses']),'approved_idle_reuse_count':sum(p['artwork_origin']=='approved high-resolution idle master reuse' for p in m['poses']),'retained_first_pass_poses':sum('/batch-' in p['raw_source'] for p in m['poses']),'repaired_final_poses':sum('/repair-' in p['raw_source'] for p in m['poses']),'frame_pngs_verified':frames_checked,'alias_checks':alias_checks,'all_registration_regenerations_match':not any('Registration' in e for e in errors),'review_hashes_fresh':not any('Stale' in e for e in errors),'attempts':attempts,'spriteframes':resources,'validation_boundary':'Asset files, hashes, indexed source audit, static source/mirror comparisons, decoded GIF frames. No native/browser playback, Godot import/runtime or human acceptance.'}
h.write(report/'final-asset-audit.json',result)
print(json.dumps({k:val for k,val in result.items() if k not in ['attempts','spriteframes']},indent=2))
if errors:
    sys.exit(1)
