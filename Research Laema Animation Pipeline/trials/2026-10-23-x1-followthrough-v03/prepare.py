"""Bounded original motion correction from the user's review; no gameplay edits."""
from pathlib import Path
from datetime import datetime,timezone
import ast,json,math,hashlib,shutil
import numpy as np
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).parent
RESEARCH=ROOT.parents[1]
PRIOR=ROOT.parent/'2026-10-23-ai-refine-v02'
for folder in ['inputs','raw','outputs','prompts','evidence']:(ROOT/folder).mkdir(exist_ok=True)
source=ast.parse((PRIOR/'prepare.py').read_text(encoding='utf-8'))
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',n)
for node in source.body:
    if isinstance(node,ast.FunctionDef) and node.name in ['sample','guide']:
        exec(compile(ast.Module(body=[node],type_ignores=[]),'reused_v02_guide','exec'))

A=json.loads((RESEARCH/'study-data.json').read_text())['proposals'][0]
previous=json.loads((PRIOR/'outputs/clips.json').read_text())
times=previous['clips'][1]['times']
# Blade angles are original art targets in screen coordinates: right=0, down=90.
# Keep anticipation/release through .184 and the final .720 guard untouched.
corrections=[(.21,22,(46,-117)),(.265,30,(44,-115)),(.34,26,(40,-117)),(.425,16,(35,-120)),(.5075,-4,(34,-122)),(.565,-22,(34,-124)),(.62,-33,(34,-125))]
keys=[]
for t in times:
    p=sample(A['keys'],t)
    replacement=next((c for c in corrections if c[0]==t),None)
    if replacement:
        _,angle,hand=replacement
        hand=np.array(hand,dtype=float);shoulder=p['shoulder'];v=hand-shoulder;dist=max(1,float(np.linalg.norm(v)))
        p['hand']=hand
        p['elbow']=(shoulder+hand)/2+np.array([-v[1],v[0]])/dist*math.sqrt(max(0,34**2-dist**2/4))
        p['sword_tip']=hand+88*np.array([math.cos(math.radians(angle)),math.sin(math.radians(angle))])
    keys.append({'t':t,'mode':'smooth','points':{k:[round(float(n),3) for n in v] for k,v in p.items()}})
guide_keys=[keys[0]]+[next(k for k in keys if k['t']==c[0]) for c in corrections]
guide(guide_keys,'X1-shallow-followthrough')
im=Image.open(PRIOR/'outputs/x1-refined.png').convert('RGBA')
im.crop((0,0,448,448)).save(ROOT/'inputs/appearance-guard.png')
shutil.copy2(PRIOR/'outputs/x1-refined.png',ROOT/'inputs/previous-refined-X1.png')
contract={'created_at_utc':datetime.now(timezone.utc).isoformat(),'scope':'Proposed original follow-through correction, awaiting visual review','feedback':'Refined improves first AI study but remains below expectation; near-ground vertical sword drop feels unnatural. User likes the synchronized review tool.','source_motion':'Original A; unchanged anticipation/release through .184s','duration':.72,'heat100_multiplier':1.5,'active_window':[.126,.5075],'pacing_split':.21,'foot_anchor':[224,400],'actor_origin':[224,348],'keys':keys,'guide_keys':guide_keys,'replaced_times':[c[0] for c in corrections],'target_angles_degrees_down_from_right':[c[1] for c in corrections],'minimum_target_tip_height_above_foot':min(-k['points']['sword_tip'][1] for k in guide_keys),'previous_atlas_sha256':hashlib.sha256((PRIOR/'outputs/x1-refined.png').read_bytes()).hexdigest(),'gameplay_changes':False,'contact_curve_adaptation':False,'production_approval':False}
(ROOT/'contract.json').write_text(json.dumps(contract,indent=2)+'\n',encoding='utf-8',newline='\n')
(ROOT/'user-feedback.json').write_text(json.dumps({'date_local':'2026-10-23','source':'direct user review of v02 browser tool','relative_assessment':'refined AI better than first study; both below expectation','specific_correction':'Sword goes almost directly to the ground; feels unnatural','review_process_preference':'Keep synchronized native-size review tool; user says it makes review easier and straightforward','production_art_approved':False,'motion_correction_accepted_for_trial':'Revise the excessive downward follow-through, with gameplay unchanged'},indent=2)+'\n',encoding='utf-8',newline='\n')
print('Prepared seven original follow-through/recovery targets; shallowest retained lower tip target remains %.1fpx above foot.' % contract['minimum_target_tip_height_above_foot'])
