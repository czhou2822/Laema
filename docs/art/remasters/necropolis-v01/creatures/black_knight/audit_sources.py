"""Read-only source audit, with evidence saved only under this creature report."""
import hashlib
import json
import sys
from pathlib import Path
from PIL import Image

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
sys.path.insert(0, str(ROOT / 'tools/art'))
import necropolis_remaster as helper

c = helper.creature('black_knight')
m = helper.read(ROOT / c['original_metadata'])
checks = []
for path_key, hash_key in [('original_metadata', 'original_metadata_sha256'), ('original_def', 'original_def_sha256'), ('appearance_reference', 'appearance_reference_sha256')]:
    actual = helper.sha(ROOT / c[path_key])
    assert actual == c[hash_key], path_key
    checks.append({'path': c[path_key], 'sha256': actual, 'matches_plan': True})
pages = {}
occurrences = []
for p in c['poses']:
    for r in p['occurrences']:
        g = next(g for g in m['groups'] if g['id'] == r['group_id'] and g['block'] == r['original_block'])
        f = g['frames'][r['frame_index']]
        assert f == r['source_record']
        assert helper.signature(f) == p['original_signature']
        sheet = Image.open(ROOT / r['indexed_sheet'])
        x,y,w,h = r['sheet_cell_region']
        indices = sheet.crop((x+f['left'], y+f['top'], x+f['left']+f['width'], y+f['top']+f['height'])).tobytes()
        # The export hash covers the complete native logical frame, not its stored crop.
        full_indices = sheet.crop((x,y,x+w,y+h)).tobytes()
        candidates = [hashlib.sha256(indices).hexdigest(), hashlib.sha256(full_indices).hexdigest()]
        assert f['index_sha256'] in candidates, (p['pose_id'], r['group_id'], r['frame_index'])
        occurrences.append({'pose_id': p['pose_id'], 'group_id': g['id'], 'block': g['block'], 'frame_index': f['index'], 'source_record_matches': True, 'indexed_pixels_sha256_matches': True})
        for key in ['rgba_sheet','indexed_sheet']:
            pages[r[key]] = helper.sha(ROOT / r[key])
    print(p['pose_id'], p['original_signature'], p['opaque_body_rect'], [(r['group_id'],r['frame_index']) for r in p['occurrences']])
result = {'creature_id': 'black_knight', 'checks': checks, 'source_pages': pages, 'occurrences': occurrences, 'groups': [{k:v for k,v in g.items() if k != 'original_group_record'} for g in c['groups']], 'counts': {'poses':len(c['poses']),'groups':len(c['groups']),'occurrences':len(occurrences)}, 'metadata_header': {k:v for k,v in m.items() if k not in ['groups','palette']}, 'palette_entries':len(m['palette'])}
helper.write(Path(__file__).with_name('source-audit.json'), result)
print(json.dumps(result['counts']))
