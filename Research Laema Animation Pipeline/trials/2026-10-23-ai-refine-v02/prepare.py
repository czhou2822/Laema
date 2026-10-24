"""Original A inbetweens and original Cast reuse trial; no production writes."""
from pathlib import Path
import json,math,hashlib,time
import numpy as np
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).parent
RESEARCH=ROOT.parents[1]
PRIOR=RESEARCH/'trials/2026-10-23-A-v01'
for name in ['inputs','raw','outputs','prompts','evidence']:(ROOT/name).mkdir(parents=True,exist_ok=True)
A=json.loads((RESEARCH/'study-data.json').read_text())['proposals'][0]
def sample(keys,t):
    if t<=keys[0]['t']:return {k:np.array(v,dtype=float) for k,v in keys[0]['points'].items()}
    if t>=keys[-1]['t']:return {k:np.array(v,dtype=float) for k,v in keys[-1]['points'].items()}
    i=0
    while i<len(keys)-2 and t>keys[i+1]['t']:i+=1
    a,b=keys[i:i+2];u=(t-a['t'])/(b['t']-a['t'])
    if a.get('mode')=='smooth':u=u*u*(3-2*u)
    p={k:np.array(v)*(1-u)+np.array(b['points'][k])*u for k,v in a['points'].items()}
    va=np.array(a['points']['sword_tip'])-a['points']['hand'];vb=np.array(b['points']['sword_tip'])-b['points']['hand']
    aa,bb=math.atan2(va[1],va[0]),math.atan2(vb[1],vb[0])
    angle=aa+math.atan2(math.sin(bb-aa),math.cos(bb-aa))*u
    p['sword_tip']=p['hand']+88*np.array([math.cos(angle),math.sin(angle)])
    return p
def pose(t,hand=(34,-126),angle=-42,lean=0,sink=0,hip_x=0,shield=(5,-120)):
    shoulder=np.array([lean,-139+sink]);hand=np.array(hand,dtype=float)
    v=hand-shoulder;dist=max(1,float(np.linalg.norm(v)));height=math.sqrt(max(0,34**2-dist**2/4))
    elbow=(shoulder+hand)/2+np.array([-v[1],v[0]])/dist*height
    p={'hip':[hip_x,-88+sink],'neck':[lean,-145+sink],'head':[lean+4,-164+sink],'shoulder':shoulder,'elbow':elbow,'hand':hand,'shield':shield,'knee_a':[-25+hip_x*.25,-43+sink*.4],'ankle_a':[-30,0],'knee_b':[29+hip_x*.25,-44+sink*.4],'ankle_b':[32,0],'sword_tip':hand+88*np.array([math.cos(math.radians(angle)),math.sin(math.radians(angle))])}
    return {'t':t,'mode':'smooth','points':{k:[round(float(n),3) for n in v] for k,v in p.items()}}

cast=[pose(0),pose(.12,hand=(18,-143),angle=-70,lean=-3,sink=3,hip_x=-2),pose(.24,hand=(-16,-162),angle=-84,lean=-3,sink=0,hip_x=-1),pose(.288,hand=(-19,-165),angle=-90,lean=-3,sink=-2,hip_x=-1),pose(.42,hand=(-12,-161),angle=-85,lean=1,sink=-1),pose(.68,hand=(14,-146),angle=-62,lean=2,sink=1),pose(.92,hand=(30,-130),angle=-45,sink=1),pose(1.2)]
inbetween_times=[0,.075,.142,.184,.265,.425,.565,.72]
inbetween=[{'t':t,'mode':'smooth','points':{k:v.tolist() for k,v in sample(A['keys'],t).items()}} for t in inbetween_times]
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',n)
def guide(keys,name):
    im=Image.new('RGB',(2304,1152),'#17212c');d=ImageDraw.Draw(im)
    for i,key in enumerate(keys):
        left,top=i%4*576,i//4*576;ox,oy=left+288,top+540
        def p(n):return tuple(np.array(key['points'][n])*2+[ox,oy])
        d.rectangle((left,top,left+575,top+575),outline='#465566',width=2)
        d.text((left+14,top+12),f'{i+1:02d} / {name} / {key["t"]:.4f}s',font=font(21),fill='#dfbf88')
        d.line((left+15,oy,left+561,oy),fill='#617b8f',width=2)
        for a,b,w in [('hip','knee_a',30),('knee_a','ankle_a',22),('hip','knee_b',30),('knee_b','ankle_b',22),('hip','neck',48),('shoulder','elbow',22),('elbow','hand',18),('shoulder','shield',17)]:d.line((p(a),p(b)),fill='#dce4e4',width=w)
        for n in ['ankle_a','ankle_b']:
            x,y=p(n);d.line((x,y-5,x+27,y-5),fill='#dce4e4',width=10)
        x,y=p('head');d.ellipse((x-26,y-32,x+26,y+32),fill='#dce4e4')
        x,y=p('shield');d.ellipse((x-29,y-45,x+29,y+45),fill='#67879b',outline='#a7bac2',width=3)
        d.line((p('hand'),p('sword_tip')),fill='#e6b87e',width=7)
        for n in ['hip','shoulder','elbow','hand','knee_a','knee_b']:
            x,y=p(n);d.ellipse((x-4,y-4,x+4,y+4),fill='#d16b66')
    im.save(ROOT/'inputs'/f'{name}-guide.png')
guide(inbetween,'X1-inbetweens');guide(cast,'Cast-original')
baseline=Image.open(PRIOR/'outputs/ai-corrected.png').convert('RGBA')
baseline.crop((0,0,448,448)).save(ROOT/'inputs/appearance-guard.png')
baseline.save(ROOT/'inputs/preferred-A-artwork.png')
contract={'status':'user-authorized AI refinement and second-action experiment; no production approval','source_revision':'d97c728021ec0cbc3a5e3a6483620150d7ab18a6','motion_A_selected':True,'x1_baseline_keys':A['keys'],'x1_inbetween_guide_keys':inbetween,'x1_added_times':inbetween_times[1:-1],'x1_duration':.72,'x1_active':[.126,.5075],'x1_split':.21,'cast_keys':cast,'cast_duration':1.2,'cast_launch':.288,'cast_launch_hand_foot_space':[-19,-165],'cast_status':'original R&D gesture trial, not a final motion/outfit decision','heat100_multiplier':1.5,'foot_anchor':[224,400],'actor_origin_in_cell':[224,348],'no_existing_sequence_as_motion_input':True,'no_gameplay_changes':True,'source_contract':'native geometry, markers, timings, lunge, input, queue, damage, body and CastOrigin remain unchanged'}
(ROOT/'contract.json').write_text(json.dumps(contract,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Prepared six original A inbetweens and an original eight-key Cast trial with unchanged duration/launch anchor.')
