"""Index the paired real-game recordings for the existing comparison viewer."""
from pathlib import Path
import json,statistics,collections,shutil,datetime
ROOT=Path(__file__).resolve().parent
catalog=[];results=[]
for name,label,suffix in [('baseline-run','v08 baseline','/x1-one-pose-structural-v08.png'),('candidate-run','H01 candidate','/x1-h01-grip-continuity.png')]:
 events=[json.loads(s) for s in (ROOT/'evidence'/name/'events.jsonl').read_text().splitlines()]
 accepted=next(e for e in events if e['kind']=='combat_outcome' and e.get('command_id')==1 and e['outcome']['kind']=='action_accepted' and e['outcome'].get('action_kind')=='light')
 origin=accepted['command_elapsed_ms']
 captures=[e for e in events if e['kind']=='capture' and e.get('command_id')==1]
 finished=next(e for e in events if e['kind']=='command_finished' and e['id']==1)
 frames=[]
 for e in captures:
  path=Path(e['paths']['review']);assert path.is_file()
  sprite=e['state']['player']['sprite']
  frames.append({'t':e['command_elapsed_ms']-origin,'src':path.relative_to(ROOT).as_posix(),'region':sprite['region'],'texture':sprite['texture'],'heat':e['state']['heat']})
 gaps=[b['t']-a['t'] for a,b in zip(frames,frames[1:])]
 external=[e for e in events if e['kind']=='input_observed' and e.get('source')=='unexpected_external']
 outcomes=collections.Counter(e['outcome']['kind'] for e in events if e['kind']=='combat_outcome' and e.get('command_id')==1)
 bookmarks=[{'name':e['outcome']['kind'],'t_from_first_X1_ms':e['command_elapsed_ms']-origin,'source':'observed combat_outcome, not an inferred impact drawing'} for e in events
             if e['kind']=='combat_outcome' and e.get('command_id')==1 and e['outcome']['kind'] in ['light_contact_resolved','action_finished','cast_launched','spell_projectile_impacted']]
 stats={'run':name,'captured_frames':len(frames),'sample_interval_median_ms':statistics.median(gaps),'sample_interval_max_ms':max(gaps),
        'input_lateness_max_ms':max(e['lateness_ms'] for e in events if e['kind']=='scheduled_input'),
        'external_events_before_command':len([e for e in external if e.get('command_id') is None]),
        'external_events_during_command':len([e for e in external if e.get('command_id')==1]),
        'outcomes':dict(outcomes),'player_hp_at_command_end':finished['state']['player']['hp'],'enemy_hp_at_command_end':finished['state']['enemy']['hp'],
        'observed_events':bookmarks,'startup':'Paused only during fixture initialization; original clock after synthetic action routing.',
        'scope':'Real game fixture from d97c7280; not current-main gameplay acceptance or hardware validation'}
 results.append(stats)
 catalog.append({'label':label,'summary':'Frozen Gym fixture · same timing/body/blade path · '+('original v08 arms' if name=='baseline-run' else 'local edits in drawings5–7 only'),
                 'drawing':{'suffix':suffix,'count':16,'columns':8,'cell':448},'frames':frames,'stats':stats})
def grip_windows(run):
 return [(f['t'],run['frames'][i+1]['t']) for i,f in enumerate(run['frames'][:-1])
         if f['t']<1000 and f['texture'].endswith(run['drawing']['suffix']) and f['region']==[2688.,0.,448.,448.]]
overlaps=[(max(a,c),min(b,d)) for a,b in grip_windows(catalog[0]) for c,d in grip_windows(catalog[1]) if max(a,c)<min(b,d)]
assert overlaps,'No shared recorded drawing7 interval: do not label different poses as a matched inspection.'
left,right=max(overlaps,key=lambda p:p[1]-p[0]);bookmark=(left+right)//2
proof=max((f for f in catalog[1]['frames'] if f['t']<=bookmark),key=lambda f:f['t'])
shutil.copy2(ROOT/proof['src'],ROOT/'outputs/candidate-grip-in-game.jpg')
comparison=max((f for f in catalog[0]['frames'] if f['t']<=bookmark),key=lambda f:f['t'])
shutil.copy2(ROOT/comparison['src'],ROOT/'outputs/baseline-near-grip-time.jpg')
data={'runs':catalog,'duration':.72,'proof_t_ms':bookmark,'X1_loop_ms':[-350,1250],'encounter_ms':[-1400,6700],
      'grip_bookmark_basis':{'recorded_drawing7_overlap_ms':[left,right],'bookmark_ms':bookmark,'meaning':'Both sampled viewports show the same saved drawing7; this is not a contact event.'},
      'captured_viewport':[1280,720],'real_gameplay':True,'human_art_approved':False,
      'experiment':{'title':'H01 · release grip continuity','question':'H01: does a consistent closed grip make X1’s release more convincing?',
                    'fixed':'Only sword-arm pixels in drawings5–7 change. Body outside masks, blade path, all key times and gameplay are fixed.',
                    'verdict':'Quality verdict: awaiting your judgment. Body stiffness and v08’s existing appearance drift remain open.',
                    'reference':'../inputs/release-grip-construction.png','record':'../experiment.json'},
      'limits':'Variable measured viewport samples, aligned at first accepted X1; separate runs are not identical-state deterministic playback. No stable FPS claim.'}
(ROOT/'outputs/replay-data.json').write_text(json.dumps(data)+'\n',encoding='utf-8')
exp=json.loads((ROOT/'experiment.json').read_text())
exp['runtime_evidence']={'runs':results,'viewer':'../2026-10-23-v08-game-integration/review.html?experiment=H01','matched_pose_bookmark':data['grip_bookmark_basis'],
                         'source_revision_boundary':'Frozen d97c7280 game copy; main574270f6 left unchanged.',
                         'shutdown_warnings':'Both retain13 ObjectDB /9 resources in use at exit; not resolved here.',
                         'import_warning':'Candidate first editor pass attempted loading its PNG before import. Actual game subsequently loaded it.'}
exp['observed_improvement']={'objective':'Edits stay bounded; the13 untouched cells and source pixels outside masks remain exact. All drawing times and native game tracks remain exact.',
                             'agent_closeup_impression':'Closed fingers/hilt overlap appears clearer; subjective and not a whole-action quality verdict.'}
exp['regressions']={'observed':'Glove/cuff/sleeve shading changes inside the edit masks; assess the new local seams. No outside-mask body or blade-path drift.',
                    'risk':'The correction may be too subtle at normal speed, especially drawing6 whose alpha silhouette changes by only1 pixel.'}
exp['agent_assessment']={'hypothesis_verdict':'inconclusive_pending_human_review','quality_improved':None,
 'reason':'Close-up detail improvement is insufficient evidence for a convincing normal-speed action. H01 does not address body stiffness, braking or the existing key7 whole-body drift.'}
exp['technical_result']='Bounded candidate exported and exercised in paired real-game runs. Does not establish artistic quality, production acceptance or a workflow winner.'
(ROOT/'experiment.json').write_text(json.dumps(exp,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'proof_t_ms':bookmark,'runs':[{k:v for k,v in r.items() if k not in ['outcomes','observed_events']} for r in results]},indent=2))
