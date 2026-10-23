"""Apply only the worker's explicitly recorded observations through the shared helper."""
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
sys.path.insert(0, str(ROOT/'tools/art'))
import necropolis_remaster as h

report = Path(__file__).resolve().parent
observations = h.read(report/'review-observations.json')
c = h.creature('black_knight')
dd = h.dest('black_knight')
assert set(observations['pose_observations']) == {p['pose_id'] for p in c['poses']}
assert set(observations['group_observations']) == {str(g['group_id']) for g in c['groups']}
for pid,note in observations['pose_observations'].items():
    h.mark_review('black_knight', [pid], note+' Source/mirror comparison and static decoded preview inspected; no playback or human acceptance claimed.')
m = h.read(dd/'source_manifest.json')
pose_reviews = []
for p in c['poses']:
    r = h.read(dd/'poses'/(p['pose_id']+'.json'))
    pose_reviews.append({'pose_id':p['pose_id'],'observation':observations['pose_observations'][p['pose_id']], 'status':'worker reviewed candidate', 'registered_pose_file':r['registered_pose_file'],'registered_pose_sha256':r['registered_pose_sha256'],'mirror_file':r['mirror_file'],'mirror_sha256':r['mirror_sha256'],'raw_source':r['raw_source'],'raw_sha256':r['raw_sha256'],'isolated_source':r['isolated_source'],'isolated_sha256':r['isolated_sha256'],'original_signature':p['original_signature'],'all_occurrences':p['occurrences'],'review_record':r['visual_review'],'blocking_defects_identified':[]})
preview_index = h.read(report/'review-panels/index.json')
group_reviews = []
for g in m['groups']:
    gid = g['group_id']
    panels = [r for r in preview_index['groups'] if r['group_id']==gid]
    group_reviews.append({'group_id':gid,'original_block':g['original_block'],'observation':observations['group_observations'][str(gid)],'pose_ids_in_source_order':g['pose_ids_in_source_order'],'exact_aliases':g['exact_aliases'],'source_atlas_sha256':g['sha256'],'mirror_atlas_sha256':g['mirror_sha256'],'comparison_panels':[{'path':r['source_ordered_comparison'],'sha256':h.sha(ROOT/r['source_ordered_comparison'])} for r in panels], 'decoded_gif_evidence':panels,'preview_sha256':h.sha(ROOT/g['preview']),'mirror_preview_sha256':h.sha(ROOT/g['mirror_preview']),'blocking_defects_identified':[]})
h.write(report/'visual-review.json', {'creature_id':'black_knight','worker_review_complete':True,'human_animation_acceptance':False,'playback_observed':False,'browser_validation':False,'godot_validation':False,'original_timing_verified':False,'inspection':observations['inspection'],'limits':observations['limits'],'poses':pose_reviews,'groups':group_reviews,'repairs':observations['repairs'],'remaining_blocking_defects_identified':[]})
print(json.dumps({'reviewed_poses':len(pose_reviews),'reviewed_groups':len(group_reviews),'facings_per_group':2}))
