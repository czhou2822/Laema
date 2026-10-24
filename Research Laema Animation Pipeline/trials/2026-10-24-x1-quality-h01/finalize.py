from pathlib import Path
import json,hashlib,datetime,csv
ROOT=Path(__file__).resolve().parent
RESEARCH=ROOT.parents[1];REPO=RESEARCH.parent
exp=json.loads((ROOT/'experiment.json').read_text())
assert 'review_interface' not in exp,'A newer review direction exists; preserve it and reconcile through the current character-review records.'
assert exp['human_verdict']['decision']=='pending','Preserve a received human verdict; reconcile it explicitly.'
now=datetime.datetime.now(datetime.timezone.utc)
started=datetime.datetime.fromisoformat(exp['created_at_utc'])
exp['agent_total_elapsed_seconds']=(now-started).total_seconds()
exp['elapsed_measurement_limit']='Wall time from experiment preparation through first completed technical handoff; includes reasoning, tools and waits. Not active artist labor. Investigation before experiment creation was not separately timed.'
exp.setdefault('verdict_history',[]).append({'at_utc':now.isoformat(),'source':'agent evidence review','decision':'inconclusive_pending_human_review','scope':'Bounded export/runtime/browser conformance established; normal-speed artistic improvement not accepted.'})
exp.setdefault('human_observations',[])
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
exp['actual_modifications']['candidate_sha256']=sha(ROOT/exp['actual_modifications']['candidate'])
for call in exp['generation_calls']:
 call['input_sha256']=[sha(ROOT/p) for p in call['inputs']]
 call['raw_sha256']=sha(ROOT/call['raw'])
assert exp['runtime_evidence']['runs'][0]['outcomes']==exp['runtime_evidence']['runs'][1]['outcomes']
exp['runtime_evidence']['outcome_counts_equal']=True
(ROOT/'experiment.json').write_text(json.dumps(exp,indent=2)+'\n',encoding='utf-8')
with (ROOT/'effort.csv').open('w',encoding='utf-8',newline='') as f:
 w=csv.writer(f);w.writerow(['category','item','value','unit','limit'])
 w.writerow(['per_action','Image requests',1,'request','Built-in image_gen; raw and prompt preserved'])
 w.writerow(['per_action','Image request elapsed',28,'wall seconds','UTC1s resolution; not artist labor'])
 w.writerow(['per_action','Localized edited drawings',3,'drawings','Other13 drawings and all key times remain exact'])
 w.writerow(['per_action','Guard registrations',3,'translations','No per-pose scaling or anatomical warping'])
 w.writerow(['reusable_setup','Crop/mask export, fixture and viewer reuse','','','Setup/per-action active time not separately clocked'])
 w.writerow(['agent_elapsed','Preparation through first technical handoff',exp['agent_total_elapsed_seconds'],'wall seconds',exp['elapsed_measurement_limit']])
 w.writerow(['human_artist','Pixel cleanup',0,'minutes','No human pixel painting'])
 w.writerow(['human_review','Artistic verdict','','','Pending user; time unknown'])
summary=('H01 quality experiment: [pipeline audit](PIPELINE_AUDIT.md) completed before correction. '
 '[Three-stage criteria](QUALITY_WORKFLOW.md) and [H01](trials/2026-10-24-x1-quality-h01/README.md) '
 'test local wrist/palm/hilt construction in v08 release drawings5–7, preserving other cells, timing and protected source pixels. '
 '[The existing viewer](trials/2026-10-23-v08-game-integration/review.html?experiment=H01) shows paired actual-game recordings. '
 'The agent sees clearer close-up grip detail, but no normal-speed artistic improvement is accepted; cuff shading, body stiffness/braking and prior appearance drift remain open. '
 'Human verdict is pending. No workflow winner or production installation is inferred. The original game/v08 comparison remains available. '
 'The runtime fixture is frozen atd97c7280, not a validation of later main574270f6 changes.')
for name in ['CONTINUE_LOCAL.md','FINDINGS.md']:
 path=RESEARCH/name;text=path.read_text(encoding='utf-8');first,rest=text.split('\n',1)
 if summary not in text:path.write_text(first+'\n\n'+summary+'\n'+rest,encoding='utf-8',newline='\n')
path=RESEARCH/'README.md';text=path.read_text(encoding='utf-8');parts=text.split('\n\n')
i=next(i for i,p in enumerate(parts) if p.startswith('**Local status:'))
parts[i]='**Local status: H01 controlled grip experiment ready for human review; no production-quality win established.** '+summary
path.write_text('\n\n'.join(parts),encoding='utf-8',newline='\n')
path=RESEARCH/'evidence/round-record.json';record=json.loads(path.read_text())
record.update(updated_at_utc=now.isoformat(),latest_trial='trials/2026-10-24-x1-quality-h01',
 latest_artwork_trial='trials/2026-10-24-x1-quality-h01',latest_focused_hypothesis_id='H01',
 latest_trial_gameplay_run=True,latest_integration_trial='trials/2026-10-24-x1-quality-h01',
 isolated_copy_gameplay_trial='trials/2026-10-24-x1-quality-h01',
 quality_assessment='Inconclusive pending human normal-speed judgment; source/export/runtime checks are not artistic acceptance.',
 awaiting_user='Judge H01 grip continuity versus v08 at normal speed/native scale. Do not promote it or polish the unresolved body performance without an artistic verdict.')
record['files'].update(current_review='trials/2026-10-23-v08-game-integration/review.html?experiment=H01',current_report='trials/2026-10-24-x1-quality-h01/README.md',pipeline_audit='PIPELINE_AUDIT.md',quality_workflow='QUALITY_WORKFLOW.md')
path.write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
department=REPO/'docs/departments/combat.md';text=department.read_text(encoding='utf-8')
marker='\n## Resume point';assert marker in text
entry=('\n- Animation quality R&D, H01: investigation found reference-guided AI raster flipbooks with procedural pose guides and mechanical export, not a constrained painted skeleton. '
 'The user requested hypothesis-driven quality work with final human artistic judgment. H01 changes three release-arm crops with protected body/blade pixels and unchanged key times; a frozen older Gym fixture provides paired real-game captures. '
 'Bounded export/runtime checks pass, but normal-speed quality improvement is unaccepted; cuff shading and existing body/braking/drift remain open. '
 'Blocking/refinement/polish criteria and a small experiment record were added; no annotation system, new rig architecture, gameplay change or production winner. '
 'Source: Research Laema Animation Pipeline/trials/2026-10-24-x1-quality-h01/README.md.\n')
if entry not in text:department.write_text(text.replace(marker,entry+marker,1),encoding='utf-8',newline='\n')
files=[]
for p in sorted(ROOT.rglob('*')):
 if p.is_file() and not set(p.parts)&{'.godot','__pycache__','captures','gameplay-preview'} and p.name!='artifact-manifest.json':
  files.append({'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(ROOT/'artifact-manifest.json').write_text(json.dumps({'kind':'H01 experiment artifacts','files':files,'exclusions':'Game copy and raw capture directories remain preserved and separately inventoried/indexed.'},indent=2)+'\n',encoding='utf-8')
print('H01 records reconciled. Human quality verdict remains pending.')
