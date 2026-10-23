"""Read-only, creature-scoped final artifact audit; JSON is emitted to stdout."""
import hashlib
import json
import re
from pathlib import Path
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
BASE = ROOT / 'assets/prototype/enemy/bone_dragon/remaster_v01'


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def rel(path):
    return path.relative_to(ROOT).as_posix()


plan = read(ROOT / 'docs/art/remasters/necropolis-v01/generation-plan.json')
c = next(x for x in plan['creatures'] if x['creature_id'] == 'bone_dragon')
m = read(BASE / 'source_manifest.json')
proof = read(REPORT / 'full-mechanical-checks.json')
errors = []


def check(condition, label):
    if not condition:
        errors.append(label)


check(sha(ROOT / c['original_def']) == c['original_def_sha256'], 'Original DEF changed')
check(sha(ROOT / c['original_metadata']) == c['original_metadata_sha256'], 'Original metadata changed')
check(sha(ROOT / c['appearance_reference']) == c['appearance_reference_sha256'], 'Approved master changed')
check(sha(ROOT / 'docs/art/remasters/necropolis-v01/generation-plan.json') == proof['source_plan_sha256'], 'Plan changed')
check(m['coverage']['available_poses'] == m['coverage']['reviewed_poses'] == 61, 'Pose coverage/reviews')
check(m['coverage']['complete_groups'] == 15 and not m['coverage']['missing_pose_ids'], 'Group coverage')

occurrences = []
for p in c['poses']:
    pid = p['pose_id']
    r = read(BASE / 'poses' / (pid + '.json'))
    rv = r['visual_review']
    check(isinstance(rv, dict), 'Missing review ' + pid)
    check(rv['source_sha256_at_review'] == sha(ROOT / r['registered_pose_file']), 'Stale pose review ' + pid)
    check(rv['mirror_sha256_at_review'] == sha(ROOT / r['mirror_file']), 'Stale mirror review ' + pid)
    check(sha(ROOT / r['raw_source']) == r['raw_sha256'], 'Raw changed ' + pid)
    check(sha(ROOT / r['isolated_source']) == r['isolated_sha256'], 'Isolated source changed ' + pid)
    check(r['artwork_origin'] == 'built-in image-generation artwork', 'Non-generated replacement ' + pid)
    for o in p['occurrences']:
        sr = o['source_record']
        x, y, w, h = o['sheet_cell_region']
        indexed = Image.open(ROOT / o['indexed_sheet'])
        check(indexed.mode == 'P', 'Not native indexed ' + pid)
        cell = indexed.crop((x, y, x + w, y + h))
        trim = cell.crop((sr['left'], sr['top'], sr['left'] + sr['width'], sr['top'] + sr['height']))
        digest = hashlib.sha256(trim.tobytes()).hexdigest()
        check(digest == sr['index_sha256'], 'Native indexed crop ' + pid)
        occurrences.append({'group_id': o['group_id'], 'original_block': o['original_block'],
                            'frame_index': o['frame_index'], 'pose_id': pid,
                            'native_indexed_trim_sha256': digest, 'matches_original_record': digest == sr['index_sha256']})

group_by_id = {g['group_id']: g for g in m['groups']}
timeline_frames = 0
for expected in c['groups']:
    g = group_by_id[expected['group_id']]
    check(g['pose_ids_in_source_order'] == expected['pose_ids_in_source_order'], 'Group source order ' + str(g['group_id']))
    check(g['exact_aliases'] == expected['exact_aliases'], 'Alias metadata ' + str(g['group_id']))
    for i, pid in enumerate(g['pose_ids_in_source_order']):
        po = Image.open(BASE / 'poses' / (pid + '.png')).convert('RGBA')
        for side in ['source', 'mirror']:
            fp = BASE / 'frames' / side / ('g%02d_b%02d' % (g['group_id'], g['original_block'])) / ('%03d.png' % i)
            frame = Image.open(fp).convert('RGBA')
            expected_im = po if side == 'source' else ImageOps.mirror(po)
            check(frame.tobytes() == expected_im.tobytes(), 'Frame PNG order/mirror ' + rel(fp))
            timeline_frames += 1
    for alias in g['exact_aliases']:
        check(g['sha256'] == group_by_id[alias]['sha256'], 'Alias source atlas ' + str(g['group_id']))
        check(g['mirror_sha256'] == group_by_id[alias]['mirror_sha256'], 'Alias mirror atlas ' + str(g['group_id']))

resources = []
expected_ids = ['g%02d_b%02d_f%03d' % (g['group_id'], g['original_block'], i)
                for g in c['groups'] for i in range(g['frame_count'])]
for mirrored, filename in [(False, 'original_groups.tres'), (True, 'original_groups_mirrored.tres')]:
    fp = BASE / filename
    content = fp.read_text(encoding='utf-8')
    paths = re.findall(r'path="res://([^"]+)"', content)
    check(paths == [g['mirror_file'] if mirrored else g['file'] for g in m['groups']], 'SpriteFrames texture paths ' + filename)
    check(re.findall(r'SubResource\("([^"]+)"\)', content) == expected_ids, 'SpriteFrames timeline order ' + filename)
    check(re.findall(r'"name": &"([^"]+)"', content) == ['og_%02d_block_%02d' % (g['group_id'], g['original_block']) for g in c['groups']], 'SpriteFrames group names ' + filename)
    check(content.count('[sub_resource type="AtlasTexture"') == 84, 'SpriteFrames atlas cells ' + filename)
    check('metadata/original_timing_verified = false' in content, 'Timing claim ' + filename)
    resources.append({'path': rel(fp), 'sha256': sha(fp), 'groups': len(paths), 'source_ordered_positions': 84,
                      'mirrored': mirrored, 'static_resource_checks_pass': True})

for invocation in proof['executed_invocations']:
    check(sha(ROOT / invocation['raw']) == invocation['raw_sha256'], 'Builtin archive changed')
    check(sha(ROOT / invocation['request']) == invocation['request_sha256'], 'Builtin request changed')
    for reference in invocation['references']:
        check(sha(ROOT / reference['recoverable_reference']) == reference['reference_sha256'], 'Generation reference changed')
check(len(proof['builtin_raw_archives']) == 44 and all(x['byte_identical'] for x in proof['builtin_raw_archives']), 'Builtin byte identity')
check(len(occurrences) == 84 and timeline_frames == 168, 'Timeline occurrence/frame coverage')
p002 = read(BASE / 'poses/bone_dragon_p002.json')
check(p002['registered_pose_sha256'] == '6ce2514eb8e4a25997ada878085dcdbe3efd781f6c5d81494745e0fb99a4f0f3', 'Parent-selected p002 changed')

visual = read(REPORT / 'visual-review.json')
check(visual['schema_version'] == 2 and len(visual['poses']) == 61 and len(visual['all_groups']) == 15, 'Full visual evidence coverage')
for p in visual['poses']:
    check(sha(ROOT / p['registered']) == p['source_sha256_at_review'] == p['registered_sha256'], 'Visual pose hash ' + p['pose_id'])
    check(sha(BASE / 'poses' / (p['pose_id'] + '_mirror.png')) == p['mirror_sha256_at_review'], 'Visual mirror hash ' + p['pose_id'])
    check(sha(ROOT / p['comparison']) == p['comparison_sha256'], 'Visual comparison hash ' + p['pose_id'])
for page in visual['pose_pages']:
    check(sha(ROOT / page['page']) == page['sha256'], 'Visual page hash')
for g in visual['all_groups']:
    check(sha(ROOT / g['contact']) == g['contact_sha256'], 'Visual contact hash')
    check(sha(ROOT / g['gif_witness']) == g['gif_witness_sha256'], 'Visual GIF witness hash')
    actual = group_by_id[g['group_id']]
    check(sha(ROOT / actual['file']) == g['atlas_sha256'], 'Visual atlas hash')
    check(sha(ROOT / actual['mirror_file']) == g['mirror_atlas_sha256'], 'Visual mirror atlas hash')
    for gif in g['gif_previews']:
        check(sha(ROOT / gif['path']) == gif['sha256'], 'Visual GIF hash')

result = {'creature_id': 'bone_dragon', 'complete': not errors, 'errors': errors,
          'coverage': m['coverage'], 'native_timeline_crops_checked': len(occurrences),
          'exported_frame_pngs_checked': timeline_frames, 'fresh_pose_and_mirror_reviews': 61,
          'fresh_visual_review_pose_comparisons': 61, 'fresh_visual_review_pages': 16,
          'fresh_visual_review_group_contacts': 15, 'fresh_visual_review_gif_witnesses': 15,
          'fresh_visual_review_gif_previews': 30,
          'exact_alias_pairs': [[7, 9], [8, 10]], 'builtin_raw_outputs_verified': 44,
          'native_timeline_crops': sorted(occurrences, key=lambda x: (x['original_block'], x['frame_index'])),
          'resources': resources, 'source_manifest_sha256': sha(BASE / 'source_manifest.json'),
          'mechanical_evidence_sha256': sha(REPORT / 'full-mechanical-checks.json'),
          'human_animation_acceptance': False, 'browser_playback_performed': False,
          'godot_smoke_performed': False, 'original_timing_verified': False}
print(json.dumps(result, indent=2))
raise SystemExit(1 if errors else 0)
