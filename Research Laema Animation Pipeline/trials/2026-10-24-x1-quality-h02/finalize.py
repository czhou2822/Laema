from pathlib import Path
import json,hashlib,datetime,csv
ROOT=Path(__file__).resolve().parent;RESEARCH=ROOT.parents[1];REPO=RESEARCH.parent;PREVIOUS=ROOT.parent/'2026-10-24-x1-quality-h01'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
exp=json.loads((ROOT/'experiment.json').read_text());now=datetime.datetime.now(datetime.timezone.utc)
assert exp['human_verdict']['decision']=='pending','Preserve a received human verdict; reconcile it explicitly.'
for call in exp['generation_calls']:
 call['model_revision']='not exposed';call['seed']='not exposed';call['input_sha256']=[sha(ROOT/p) for p in call['inputs']];call['raw_sha256']=sha(ROOT/call['raw'])
exp['agent_elapsed_wall_seconds']=(now-datetime.datetime.fromisoformat(exp['created_at_utc'])).total_seconds()
exp['effort_limit']='Includes agent reasoning, generation waits, source correction and separately reusable overlay implementation. Not active artist labor or a per-action production benchmark.'
exp['human_artist_minutes']=0;exp['human_review_minutes']=None
exp['review']={'url':'../2026-10-23-v08-game-integration/review.html?experiment=H02','mode':'character-only three versions plus optional aligned overlays','annotations':'annotations.json','prior_annotations':'../2026-10-24-x1-quality-h01/annotations.json','gameplay_run_this_trial':False}
source=PREVIOUS/'annotations.json';snapshot=json.loads((ROOT/'inputs/feedback-snapshot.json').read_text());live=json.loads(source.read_text())
exp['feedback_preservation']={'original_snapshot_revision':snapshot['source_revision'],'current_revision':live['revision'],'file_unchanged_since_snapshot':sha(source)==snapshot['source_sha256'],'all_snapshot_note_ids_present':all(any(n['id']==old['id'] for n in live['notes']) for old in snapshot['active_notes'])}
(ROOT/'experiment.json').write_text(json.dumps(exp,indent=2)+'\n',encoding='utf-8',newline='\n')
with (ROOT/'effort.csv').open('w',encoding='utf-8',newline='') as f:
 w=csv.writer(f);w.writerow(['category','item','value','unit','limit']);w.writerow(['per_action','Image requests',2,'requests','First rejected; guide/framing corrected before retry']);w.writerow(['per_action','Image service wait',57,'wall seconds','UTC1s resolution; not artist labor']);w.writerow(['per_action','Preparation drawings',3,'drawings','13 non-preparation cells and all key times exact']);w.writerow(['per_action','Registration and sole cleanup',3,'frames','Before/corrected outputs preserved']);w.writerow(['reusable_setup','Overlay/annotation comparison controls','','','Separate UI capability requested by user']);w.writerow(['agent_elapsed','Experiment through technical handoff',exp['agent_elapsed_wall_seconds'],'wall seconds',exp['effort_limit']]);w.writerow(['human_artist','Pixel painting',0,'minutes','None performed']);w.writerow(['human_review','Artistic judgment','','','Pending; no time invented'])
summary=('H02 preparation correction from saved annotations: [current character review](trials/2026-10-23-v08-game-integration/review.html?experiment=H02) shows Current game / H01 / H02. '
 'Five H01/v08 notes were read with version/frame scope preserved. H02 replaces only preparation2–4 with proposed load/coil/drive drawings;1 and5–16 plus all times are source-exact. '
 'The first generation was rejected after an agent guide-landmark error and reframing; the retry uses corrected source landmarks/tight crop. Sole cleanup and remaining boot/appearance/4→5 risks are explicit. '
 'Drag a character/handle onto another for a foot-aligned transparent overlay; notes can target base or overlay and retain both version hashes, frames, time and opacity. '
 'Read active [H02 notes](trials/2026-10-24-x1-quality-h02/annotations.json) and the preserved [H01 notes](trials/2026-10-24-x1-quality-h01/annotations.json) before another art change. '
 'The game-reference elbow3–4→5 and thrust6 concerns remain separate. H01 grip benefit is unestablished, not a blanket approval/rejection inferred from the ambiguous release note. '
 'No H02 Godot/gameplay run, main install, gameplay change, artistic acceptance, workflow winner or publication exists. Start review_server.py for both annotation stores. '
 'See [H02 report](trials/2026-10-24-x1-quality-h02/README.md).')
for name in ['CONTINUE_LOCAL.md','FINDINGS.md']:
 p=RESEARCH/name;text=p.read_text(encoding='utf-8')
 if summary not in text:
  first,rest=text.split('\n',1);p.write_text(first+'\n\n'+summary+'\n'+rest,encoding='utf-8',newline='\n')
p=RESEARCH/'README.md';parts=p.read_text(encoding='utf-8').split('\n\n');i=next(i for i,t in enumerate(parts) if t.startswith('**Local status:'));parts[i]='**Local status: H02 preparation candidate and aligned drag overlays are ready for artistic review.** '+summary;p.write_text('\n\n'.join(parts),encoding='utf-8',newline='\n')
p=RESEARCH/'evidence/round-record.json';record=json.loads(p.read_text());record.update(updated_at_utc=now.isoformat(),local_source_revision=exp['source_revision'],latest_trial='trials/2026-10-24-x1-quality-h02',latest_artwork_trial='trials/2026-10-24-x1-quality-h02',latest_focused_hypothesis_id='H02',latest_trial_gameplay_run=False,primary_review_mode='character_only_with_optional_aligned_overlay',annotation_file='trials/2026-10-24-x1-quality-h02/annotations.json',previous_annotation_file='trials/2026-10-24-x1-quality-h01/annotations.json',quality_assessment='H02 blocking proposal: different preparation poses demonstrated; artistic quality remains pending human review.',awaiting_user='Judge H02 preparation2–4 and4→5 at normal1x; annotate directly. Preserve prior source-specific notes and do not infer broad approval.')
record['files'].update(current_review='trials/2026-10-23-v08-game-integration/review.html?experiment=H02',current_report='trials/2026-10-24-x1-quality-h02/README.md');p.write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
p=REPO/'docs/departments/combat.md';text=p.read_text(encoding='utf-8');entry=('\n- Animation H02: read five saved source-version annotations. Preparation2–4 was one held drawing inherited by H01; H02 proposes three load/coil/drive drawings while retaining13 other cells and all timing. Original-game elbow/thrust observations stay separate. '
 'Attempt1 rejected for agent guide-mapping error and output reframing; retry/registration/sole cleanup remain recorded. Artist verdict pending; no main/gameplay change or new H02 engine run. '
 'Character drag overlays, opacity and comparison-bound annotations are available; H01 notes remain intact and H02 uses its own store. Source: Research Laema Animation Pipeline/trials/2026-10-24-x1-quality-h02/README.md.\n')
if entry not in text:p.write_text(text.replace('\n## Resume point',entry+'\n## Resume point',1),encoding='utf-8',newline='\n')
files=[]
for p in sorted(ROOT.rglob('*')):
 if p.is_file() and '__pycache__' not in p.parts and p.name not in ['artifact-manifest.json','annotations.json','annotations.backup.json']:
  files.append({'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':sha(p)})
(ROOT/'artifact-manifest.json').write_text(json.dumps({'files':files,'mutable_annotations':['annotations.json','annotations.backup.json']},indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'H02_ready_for_human_review':True,'prior_feedback_preserved':exp['feedback_preservation'],'gameplay_changed':False}))
