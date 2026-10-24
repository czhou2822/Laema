"""Focused original opening correction from exact user-identified drawings."""
from pathlib import Path
from datetime import datetime,timezone
import ast,json,math,shutil,hashlib
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).parent
V03=ROOT.parent/'2026-10-23-x1-followthrough-v03'
V04=ROOT.parent/'2026-10-23-x1-weight-transfer-v04'
for name in ['inputs','raw','outputs','prompts','evidence']:(ROOT/name).mkdir(exist_ok=True)
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',n)
for n in ast.parse((ROOT.parent/'2026-10-23-ai-refine-v02/prepare.py').read_text(encoding='utf-8')).body:
    if isinstance(n,ast.FunctionDef) and n.name=='guide':exec(compile(ast.Module(body=[n],type_ignores=[]),'reused_original_guide','exec'))
prior=json.loads((V03/'contract.json').read_text())
body=json.loads((V04/'contract.json').read_text())
preferred=next(k for k in prior['keys'] if k['t']==.05)
spec=[(.075,(-5,-85),(-7,-142),(16,-152),-106,(-27,-41.5),(26,-43)),
      (.1,(-6,-84),(-8,-142),(17,-152),-108,(-28,-41),(25,-42.5)),
      (.126,(-3,-85),(-4,-143),(21,-149),-78,(-26,-42),(28,-43)),
      (.142,(1,-86),(3,-144),(30,-140),-47,(-22,-42),(30,-42)),
      (.158,(5,-86),(10,-145),(44,-127),-16,(-18,-42),(33,-42))]
new=[]
for t,hip,neck,hand,angle,ka,kb in spec:
    shoulder=np.array(neck)+[0,6];hand=np.array(hand,dtype=float);v=hand-shoulder;dist=float(np.linalg.norm(v))
    elbow=(hand+shoulder)/2+np.array([-v[1],v[0]])/dist*math.sqrt(max(0,34**2-dist**2/4))
    p={'hip':hip,'neck':neck,'head':np.array(neck)+[4,-19],'shoulder':shoulder,'elbow':elbow,'hand':hand,'knee_a':ka,'ankle_a':[-30,0],'knee_b':kb,'ankle_b':[32,0],'shield':np.array(neck)+[5,25],'sword_tip':hand+88*np.array([math.cos(math.radians(angle)),math.sin(math.radians(angle))])}
    new.append({'t':t,'mode':'smooth','points':{k:[round(float(n),3) for n in xy] for k,xy in p.items()},'blade_angle':angle})
context=next(k for k in body['keys'] if k['t']==.184)
guard=prior['keys'][0]
guide_keys=[preferred]+new+[context,{**guard,'t':.72}]
guide(guide_keys,'X1-opening-correction')
shutil.copy2(V03/'inputs/appearance-guard.png',ROOT/'inputs/appearance-guard.png')
atlas=Image.open(V04/'outputs/x1-followthrough-v03.png').convert('RGBA')
for i in [1,2]:atlas.crop((i*448,0,(i+1)*448,448)).save(ROOT/'inputs'/('previous-drawing%02d.png'%(i+1)))
contract={'created_at_utc':datetime.now(timezone.utc).isoformat(),'status':'Focused opening correction; no candidate has beaten the current game per user','feedback_source':'Direct user feedback and explicit arm/sword clarification','current_game_preferred':True,'v04_awkward_drawings_1_based':[2,3,4,5,6,7],'v03_drawing2_relatively_better':True,'v03_drawing3_rejected_reason':'Arm / sword position','scope':'Keep v03 drawing2 exactly; replace v04 drawings3-7 only. Later v04 poses remain provisional and are not approved.','times':body['keys'] and [k['t'] for k in body['keys']],'duration':.72,'heat100_multiplier':1.5,'active_window':[.126,.5075],'pacing_split':.21,'foot_anchor':[224,400],'actor_origin':[224,348],'new_keys':new,'guide_keys':guide_keys,'new_indices_0_based':[2,3,4,5,6],'retained_v03_indices_0_based':[1],'retained_v04_indices_0_based':[0,7,8,9,10,11,12,13,14,15],'original_gameplay_changed':False,'current_game_sequence_used_as_generation_reference':False,'production_approved':False}
(ROOT/'contract.json').write_text(json.dumps(contract,indent=2)+'\n',encoding='utf-8',newline='\n')
feedback={'date_local':'2026-10-23','source':'Direct user review of v04 tool and follow-up clarification','overall_preference':'Current game','v04_opening_drawings_2_to_7':'Awkward','v03_drawing2':'Relatively better; not whole-action approval','v03_drawing3':'Not good; specifically arm / sword position','workflow_implication':'No R&D candidate has demonstrated user-preferred improvement over the game','other_poses':'Not approved by omission','production_approval':False}
(ROOT/'user-feedback.json').write_text(json.dumps(feedback,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Prepared5 new opening poses; v03 drawing2 retained exactly, v04 later poses provisional.')
