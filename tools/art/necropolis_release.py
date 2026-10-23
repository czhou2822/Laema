#!/usr/bin/env python3
"""Check retained collection evidence and hash the complete asset-only payload.

This does not approve artwork, draw, invoke Git publication or run the game.
"""
import hashlib
import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
DOC=ROOT/'docs/art/remasters/necropolis-v01'


def read(path):
    return json.loads(path.read_text(encoding='utf-8-sig'))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    plan=read(DOC/'generation-plan.json');failures=[];checks=[];seen={}
    independent=DOC/'validation/independent-asset-qa.json'
    engine=DOC/'validation/engine/validation-summary.json'
    for label,path in [('independent collection QA',independent),('full engine validation',engine)]:
        if not path.is_file():failures.append(label+': no result');continue
        result=read(path)
        if not result.get('passed'):failures.append(label+': not passed')
        if label.startswith('independent'):
            if not (result.get('collection_run') and result.get('full_coverage')):failures.append(label+': partial result')
            if result.get('gif_logical_positions_content_verified')!=2756:failures.append(label+': complete decoded GIF content check missing')
            if not result.get('generation_plan_sha256'):failures.append(label+': source plan hash evidence missing')
            elif result['generation_plan_sha256']!=digest(DOC/'generation-plan.json'):failures.append(label+': changed source plan')
            for creature in result.get('creatures',[]):
                path=ROOT/'assets/prototype/enemy'/creature['creature_id']/'remaster_v01/source_manifest.json'
                if not creature.get('manifest_sha256'):failures.append(label+': manifest hash evidence missing '+creature['creature_id'])
                elif not path.exists() or creature['manifest_sha256']!=digest(path):failures.append(label+': changed manifest '+creature['creature_id'])
        if label.startswith('full engine'):
            if (result.get('expected_libraries'),result.get('expected_groups'),result.get('expected_frame_regions'),result.get('texture_imports'))!=(28,456,2756,456):failures.append(label+': incomplete counts')
            if len(result.get('asset_inputs',[]))!=484:failures.append(label+': missing exact input inventory')
            for asset in result.get('asset_inputs',[]):
                path=(ROOT/asset['path']).resolve()
                if not path.is_relative_to(ROOT.resolve()) or not path.is_file() or digest(path)!=asset['sha256']:failures.append(label+': stale input '+asset['path'])
        checks.append({'check':label,'path':path.relative_to(ROOT).as_posix(),'sha256':digest(path)})
    for evidence in sorted((DOC/'validation/viewer').glob('*-ui-checks.json')):
        result=read(evidence)
        for row in result.get('checks',[]):
            match=re.match(r'(.+) / (\w+) / group (\d+) block (\d+)',row.get('readout','').split('\n')[0])
            if match:seen[(match[1],int(match[3]),int(match[4]))]=(row,evidence)
    fresh=[]
    for creature in plan['creatures']:
        cid=creature['creature_id'];mf=ROOT/'assets/prototype/enemy'/cid/'remaster_v01/source_manifest.json'
        if not mf.exists():failures.append(cid+': manifest missing');continue
        manifest=read(mf);groups={g['group_id']:g for g in manifest['groups']}
        if not manifest['coverage'].get('missing_pose_ids') and manifest['coverage'].get('reviewed_poses')==creature['unique_registered_poses']:pass
        else:failures.append(cid+': pose coverage/review incomplete')
        for group in creature['groups']:
            gid=group['group_id'];key=(creature['creature'],gid,group['original_block']);tested=seen.get(key);actual=groups.get(gid)
            if not tested or not actual or not actual.get('complete'):failures.append(f'{cid} G{gid}: missing complete browser group');continue
            row,evidence=tested
            source_hash=digest(ROOT/actual['file']);mirror_hash=digest(ROOT/actual['mirror_file'])
            if not row.get('loaded_both') or not row.get('pause_button_returned_to_play'):failures.append(f'{cid} G{gid}: UI load/play-state check missing')
            if Path(row.get('atlas','')).stem!=source_hash or Path(row.get('mirror_atlas','')).stem!=mirror_hash:failures.append(f'{cid} G{gid}: stale browser atlas evidence')
            expected_next=1%group['frame_count']+1
            if row.get('start')!=f'1 / {group["frame_count"]}' or row.get('next')!=f'{expected_next} / {group["frame_count"]}' or row.get('previous')!=row.get('start'):failures.append(f'{cid} G{gid}: frame-step evidence mismatch')
            if not row.get('played') or not row.get('mirror_next'):failures.append(f'{cid} G{gid}: playback/facing evidence missing')
            fresh.append({'creature_id':cid,'group_id':gid,'evidence':evidence.relative_to(ROOT).as_posix(),'source_sha256':source_hash,'mirror_sha256':mirror_hash})
    parent=DOC/'validation/collection-review.json'
    if not parent.exists():failures.append('Parent collection visual review absent')
    else:
        record=read(parent)
        reviewed=record.get('creatures',[])
        if not record.get('complete_review') or record.get('unresolved_blocking_defects') or len(reviewed)!=14 or {c['creature_id'] for c in reviewed}!={c['creature_id'] for c in plan['creatures']} or any(c.get('parent_observed_blocking_defects') for c in reviewed):failures.append('Parent collection visual review incomplete/blocked')
        checks.append({'check':'parent actual visual review','path':parent.relative_to(ROOT).as_posix(),'sha256':digest(parent)})
    lineup=DOC/'standing-lineup.json'
    if not lineup.exists():failures.append('Standing scale/material lineup absent')
    else:
        record=read(lineup)
        if not record.get('complete_candidates') or record.get('uniform_resize_applied'):failures.append('Standing lineup incomplete or individually resized')
        for item in record.get('entries',[])+record.get('outputs',[]):
            if item.get('missing'):failures.append('Standing lineup missing '+item.get('label','entry'));continue
            path=(ROOT/item['path']).resolve()
            if not path.is_relative_to(ROOT.resolve()) or not path.is_file() or digest(path)!=item['sha256']:failures.append('Stale standing lineup '+item['path'])
        checks.append({'check':'unresized standing comparison','path':lineup.relative_to(ROOT).as_posix(),'sha256':digest(lineup)})
    report={'scope':'retained asset-only release evidence; no Git mutation or human motion approval',
        'checks':checks,'browser_groups':fresh,'browser_group_count':len(fresh),'errors':failures,
        'passed':not failures and len(fresh)==228,'human_animation_acceptance':False,'original_timing_verified':False}
    out=DOC/'validation/release-gates.json'
    if out.exists():
        archive=out.parent/'attempts'/(out.stem+'-'+digest(out)[:16]+'.json');archive.parent.mkdir(exist_ok=True)
        if not archive.exists():archive.write_bytes(out.read_bytes())
    out.write_text(json.dumps(report,indent=2)+'\n')
    if not report['passed']:
        print(json.dumps({'passed':False,'browser_group_count':len(fresh),'error_count':len(failures),'errors_sample':failures[:20]}));raise SystemExit(1)
    roots=[DOC,ROOT/'tools/art',ROOT/'docs/art/production/necropolis-creature-assets-v01']
    roots.extend(ROOT/'assets/prototype/enemy'/c['creature_id']/'remaster_v01' for c in plan['creatures'])
    payload=[]
    for base in roots:
        for path in sorted(base.rglob('*')):
            if not path.is_file() or path.name=='payload-sha256.json' or '__pycache__' in path.parts or path.suffix in ['.pyc','.tmp']:continue
            payload.append({'path':path.relative_to(ROOT).as_posix(),'bytes':path.stat().st_size,'sha256':digest(path)})
    manifest={'scope':'complete retained new asset/tool/report package and frozen approved-master package; immutable original references are required in the checkout separately',
        'files':payload,'file_count':len(payload),'bytes':sum(x['bytes'] for x in payload),
        'manifest_self_excluded':True,'remote_publication_verification_is_separate':True}
    (DOC/'payload-sha256.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps({'passed':True,'browser_groups':len(fresh),'payload_files':len(payload),'payload_bytes':manifest['bytes']}))


if __name__=='__main__':main()
