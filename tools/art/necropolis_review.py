#!/usr/bin/env python3
"""Build a checkout-relative, original-versus-remaster Necropolis review index."""
import csv
import json
import copy
import hashlib
import shutil
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
DOC=ROOT/'docs/art/remasters/necropolis-v01'

def build():
    plan=json.loads((DOC/'generation-plan.json').read_text(encoding='utf-8'))
    creatures=[];groups=[]
    for c in plan['creatures']:
        mf=ROOT/'assets/prototype/enemy'/c['creature_id']/'remaster_v01/source_manifest.json'
        m=json.loads(mf.read_text()) if mf.exists() else {'groups':[],'coverage':{}}
        available={g['group_id']:g for g in m['groups']}
        entry={k:v for k,v in c.items() if k not in ['poses','groups']}
        entry['coverage']=m['coverage'];entry['groups']=[]
        for g in c['groups']:
            source_frames=[]
            for i,pid in enumerate(g['pose_ids_in_source_order']):
                pose=next(p for p in c['poses'] if p['pose_id']==pid)
                occurrence=next(r for r in pose['occurrences'] if r['group_id']==g['group_id'] and r['original_block']==g['original_block'] and r['frame_index']==i)
                source_frames.append({k:occurrence[k] for k in ['rgba_sheet','indexed_sheet','sheet_cell_region','source_record']})
            saved=available.get(g['group_id'],{})
            item={'creature_id':c['creature_id'],'creature':c['creature'],'original_def_id':c['original_def_id'],
                'group_id':g['group_id'],'original_block':g['original_block'],'frame_count':g['frame_count'],
                'purpose_interpretation':g['purpose_interpretation'],'exact_aliases':g['exact_aliases'],
                'pose_ids_in_source_order':g['pose_ids_in_source_order'],'source_frames':source_frames,
                'complete':saved.get('complete',False),'file':saved.get('file'),'mirror_file':saved.get('mirror_file'),
                'preview':saved.get('preview'),'mirror_preview':saved.get('mirror_preview'),'contact':saved.get('contact'),
                'original_timing_verified':False}
            entry['groups'].append(item);groups.append(item)
        creatures.append(entry)
    inventory={'schema_version':1,'scope':plan['scope'],'geometry':plan['geometry'],
        'totals':{**plan['totals'],'complete_groups':sum(g['complete'] for g in groups),
                  'supplied_frame_positions':sum(g['frame_count'] for g in groups if g['complete']),
                  'registered_poses':sum(c['coverage'].get('available_poses',0) for c in creatures),
                  'human_animation_acceptance':False,'original_timing_verified':False},
        'creatures':creatures}
    (DOC/'inventory.json').write_text(json.dumps(inventory,indent=2)+'\n',encoding='utf-8')
    # Serve only this self-contained review bundle, never the entire checkout.
    # Exact-byte image copies deduplicate by SHA-256 and preserve their origin map.
    bundle=DOC/'preview-bundle';files=bundle/'files';files.mkdir(parents=True,exist_ok=True)
    standalone=copy.deepcopy(inventory);mapping={}
    def include(relative):
        if not relative:return None
        original=(ROOT/relative).resolve()
        if not original.is_relative_to(ROOT.resolve()) or original.suffix.lower() not in ['.png','.gif','.webp','.jpg','.jpeg']:
            raise ValueError('Outside review image allowlist: '+str(relative))
        if not original.is_file():raise FileNotFoundError(original)
        digest=hashlib.sha256(original.read_bytes()).hexdigest();target=files/(digest+original.suffix.lower())
        if not target.exists():shutil.copy2(original,target)
        mapped='files/'+target.name;mapping[relative]=mapped;return mapped
    for c in standalone['creatures']:
        for g in c['groups']:
            for frame in g['source_frames']:
                frame['rgba_sheet']=include(frame['rgba_sheet'])
                frame['indexed_sheet']=include(frame['indexed_sheet'])
            for k in ['file','mirror_file','preview','mirror_preview','contact']:
                g[k]=include(g.get(k))
    (bundle/'inventory.json').write_text(json.dumps(standalone,indent=2)+'\n',encoding='utf-8')
    (bundle/'file-map.json').write_text(json.dumps(mapping,indent=2)+'\n',encoding='utf-8')
    html=(DOC/'preview.html').read_text(encoding='utf-8').replace("root=new URL('../../../../',location.href)","root=new URL('./',location.href)")
    (bundle/'index.html').write_text(html,encoding='utf-8')
    for name in ['README.md','generation-plan.json','master-approval.json','PRODUCTION_STATUS.json','OFFLINE_HANDOFF.md','CONTINUE_OFFLINE.md','standing-lineup-01.png','standing-lineup-02.png','standing-lineup.json']:
        source=DOC/name
        if source.exists():
            if name=='README.md':
                (bundle/name).write_text(source.read_text(encoding='utf-8').replace('(preview.html)','(index.html)'),encoding='utf-8')
            else:shutil.copy2(source,bundle/name)
    with (DOC/'inventory.csv').open('w',newline='',encoding='utf-8') as f:
        w=csv.writer(f);w.writerow(['creature','id','original_def','group','block','source_positions','complete','atlas','mirror','aliases'])
        for g in groups:w.writerow([g['creature'],g['creature_id'],g['original_def_id'],g['group_id'],g['original_block'],g['frame_count'],g['complete'],g['file'],g['mirror_file'],','.join(map(str,g['exact_aliases']))])
    shutil.copy2(DOC/'inventory.csv',bundle/'inventory.csv')
    print(json.dumps({**inventory['totals'],'review_bundle_files':len(mapping),'review_bundle':'docs/art/remasters/necropolis-v01/preview-bundle'}))

if __name__=='__main__':build()
