"""Build the focused AI review and actual-engine capture summaries."""
from pathlib import Path
import json,re,shutil,collections,hashlib,sys
import numpy as np
from PIL import Image
ROOT=Path(__file__).parent
import runpy
runpy.run_path(str(ROOT/'export_game_baselines.py'),run_name='__main__')
if '--html-only' in sys.argv:
    print('Refreshed review HTML with current-game baselines; unchanged test media retained.')
    raise SystemExit(0)

run=ROOT/'evidence/gameplay-run-03'
rows=[json.loads(line) for line in (run/'events.jsonl').read_text().splitlines()]
in_command=[r for r in rows if r.get('command_id')==1]
captures=[r for r in in_command if r['kind']=='capture' and r.get('paths',{}).get('review_error')==0]
outcomes=[{'t_ms':r['command_elapsed_ms'],**r['outcome']} for r in in_command if r['kind']=='combat_outcome']
finished=next(r for r in rows if r['kind']=='command_finished' and r.get('id')==1)
summary={'scope':'actual rendered isolated game copy; action-level input fixture; source gameplay unchanged','engine':'Godot4.7.1','external_inputs_during_command':sum(r.get('source')=='unexpected_external' for r in in_command),'input_delivery':'InputEventAction with original names and strengths; hardware bindings isolated inside this process only','outcomes':outcomes,'terminal_player_hp':finished['state']['player']['hp'],'terminal_enemy_hp':finished['state']['enemy']['hp'],'captured_frames':len(captures),'capture_resolution':'640x360 periodic review plus selected1280x720 frames','source_action_clock':'real engine/physics, no forced Heat, queue, or health state','capture_timestamps_ms':[r['capture_stamp']['command_elapsed_ms'] for r in captures],'max_scheduled_input_lateness_ms':max(r.get('lateness_ms',0) for r in in_command if r['kind']=='scheduled_input'),'limits':['Synthetic action-level input is not physical-controller acceptance.','Variable-interval diagnostic captures are not a frame-rate or input-latency benchmark.','Hit-query paths were preserved; successful hits do not clear the known visual/query mismatch.','Existing Idle/Walk/X2/Dodge/hurt artwork remains unchanged and may have visible handoff differences.']}
(ROOT/'evidence/gameplay-summary.json').write_text(json.dumps(summary,indent=2)+'\n',encoding='utf-8',newline='\n')
if captures:
    frames=[Image.open(r['paths']['review']).convert('RGB') for r in captures]
    ts=summary['capture_timestamps_ms'];dur=[max(20,ts[i+1]-ts[i]) for i in range(len(ts)-1)]+[300]
    frames[0].save(ROOT/'outputs/gameplay-diagnostic.webp',save_all=True,append_images=frames[1:],duration=dur,loop=0,quality=88,method=2)
    for frame in frames:frame.close()
    for wanted in [1700,3200]:
        matching=[r for r in captures if wanted in r.get('keyframes_ms',[]) and 'full' in r['paths']]
        if matching:shutil.copy2(matching[0]['paths']['full'],ROOT/'outputs'/f'gameplay-{wanted}.png')

for folder in (ROOT/'evidence/comparison-captures').iterdir() if (ROOT/'evidence/comparison-captures').exists() else []:
    if not folder.is_dir():continue
    paths=sorted(folder.glob('frame_*.png'))
    if paths:
        frames=[Image.open(p).convert('RGB') for p in paths]
        dur=[round((i+1)*1000/60)-round(i*1000/60) for i in range(len(frames))]
        frames[0].save(ROOT/'outputs'/(folder.name+'.webp'),save_all=True,append_images=frames[1:],duration=dur,loop=0,lossless=True,method=2)
        for frame in frames:frame.close()
print(json.dumps({'observed_outcomes':collections.Counter(r['kind'] for r in outcomes),'external_inputs_during_command':summary['external_inputs_during_command'],'diagnostic_frames':len(captures),'max_input_lateness_ms':summary['max_scheduled_input_lateness_ms']},indent=2))
