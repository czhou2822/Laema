"""Original full-body weight-transfer and braking targets; no gameplay mutation."""
from pathlib import Path
from datetime import datetime,timezone
import json,math,hashlib,shutil
import numpy as np
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-x1-followthrough-v03'
for folder in ['inputs','raw','outputs','prompts','evidence']:(ROOT/folder).mkdir(exist_ok=True)
# t, pelvis, neck, hand, blade degrees (right=0/down=90), rear knee, front knee, rear heel lift
spec=[
 (0,(0,-88),(0,-145),(34,-126),-42,(-25,-43),(29,-44),0),
 (.05,(-9,-82),(-13,-140),(-2,-149),-108,(-34,-39),(22,-42),0),
 (.075,(-13,-79),(-18,-137),(-18,-150),-123,(-36,-37),(18,-42),0),
 (.1,(-15,-78),(-19,-136),(-22,-150),-126,(-37,-37),(17,-41),0),
 (.126,(-10,-81),(-10,-139),(3,-153),-82,(-29,-40),(23,-42),0),
 (.142,(-5,-84),(0,-143),(24,-142),-50,(-23,-41),(27,-43),2),
 (.158,(2,-86),(10,-146),(44,-126),-18,(-17,-42),(31,-42),4),
 (.184,(10,-85),(17,-145),(51,-117),18,(-11,-42),(36,-40),6),
 (.21,(16,-82),(20,-142),(52,-110),42,(-6,-41),(41,-38),7),
 (.265,(18,-78),(19,-138),(50,-108),52,(-4,-39),(43,-35),6),
 (.34,(15,-77),(11,-137),(44,-105),48,(-8,-38),(41,-35),4),
 (.425,(9,-82),(4,-141),(38,-114),30,(-16,-40),(35,-39),2),
 (.5075,(3,-86),(1,-144),(34,-122),-4,(-22,-42),(31,-43),0),
 (.565,(1,-87),(0,-145),(34,-124),-22,(-24,-42),(30,-43),0),
 (.62,(0,-88),(0,-145),(34,-126),-33,(-25,-43),(29,-44),0),
 (.72,(0,-88),(0,-145),(34,-126),-42,(-25,-43),(29,-44),0)
]
phases=['READY','REAR LOAD','COMPRESS','DEEPEST LOAD','HIP LEADS','DRIVE','RELEASE','FOLLOW THROUGH','DOWNWARD CUT','BLADE BRAKE','BODY ABSORBS','SETTLE','RECOVER','GUARD RETURN','NEAR READY','READY']
keys=[]
for i,(t,hip,neck,hand,angle,ka,kb,heel) in enumerate(spec):
    shoulder=np.array(neck,dtype=float)+[0,6];hand=np.array(hand,dtype=float)
    v=hand-shoulder;dist=float(np.linalg.norm(v));assert dist<68
    elbow=(shoulder+hand)/2+np.array([-v[1],v[0]])/dist*math.sqrt(max(0,34**2-dist**2/4))
    shield=np.array(neck,dtype=float)+[5,25]
    p={'hip':hip,'neck':neck,'head':np.array(neck)+[4,-19],'shoulder':shoulder,'elbow':elbow,'hand':hand,'knee_a':ka,'ankle_a':[-30,-heel],'knee_b':kb,'ankle_b':[32,0],'rear_toe':[-16,0],'front_toe':[51,0],'shield':shield,'sword_tip':hand+88*np.array([math.cos(math.radians(angle)),math.sin(math.radians(angle))])}
    keys.append({'t':t,'mode':'smooth','phase':phases[i],'rear_heel_lift':heel,'blade_angle_down_from_right':angle,'points':{k:[round(float(v),3) for v in xy] for k,xy in p.items()}})

cell=640;scale=2.3
im=Image.new('RGB',(cell*4,cell*4),'#17212c');draw=ImageDraw.Draw(im)
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',n)
for i,key in enumerate(keys):
    left,top=i%4*cell,i//4*cell;origin=np.array([left+320,top+600])
    p=lambda n:tuple(np.array(key['points'][n])*scale+origin)
    draw.rectangle((left,top,left+cell-1,top+cell-1),outline='#465566',width=2)
    draw.text((left+12,top+10),'%02d / %.4fs / %s'%(i+1,key['t'],key['phase']),fill='#dfbf88',font=font(20))
    draw.line((left+14,top+600,left+cell-14,top+600),fill='#617b8f',width=2)
    for a,b,w in [('hip','knee_a',31),('knee_a','ankle_a',25),('hip','knee_b',33),('knee_b','ankle_b',25),('shoulder','elbow',23),('elbow','hand',20),('shoulder','shield',18)]:draw.line((p(a),p(b)),fill='#dce4e4',width=w)
    sx,sy=p('shoulder');hx,hy=p('hip')
    # Torso follows the hip/shoulder targets rather than translating a rigid cutout.
    draw.polygon([(sx-37,sy-9),(sx+37,sy-9),(hx+29,hy+9),(hx-29,hy+9)],fill='#dce4e4')
    x,y=p('head');draw.ellipse((x-29,y-34,x+29,y+34),fill='#dce4e4')
    for ankle,toe in [('ankle_a','rear_toe'),('ankle_b','front_toe')]:
        ax,ay=p(ankle);tx,ty=p(toe)
        draw.polygon([(ax-12,ay-14),(ax+9,ay-10),(tx+6,ty-9),(tx+6,ty),(ax-12,ay)],fill='#dce4e4')
    x,y=p('shield');draw.ellipse((x-32,y-48,x+32,y+48),fill='#67879b',outline='#a7bac2',width=3)
    a=np.array(p('hand'));b=np.array(p('sword_tip'));v=(b-a)/np.linalg.norm(b-a);side=np.array([-v[1],v[0]])
    draw.line((tuple(a-v*12),tuple(b)),fill='#e6b87e',width=8)
    draw.line((tuple(a+side*16),tuple(a-side*16)),fill='#e6b87e',width=6)
    for name in ['hip','shoulder','elbow','hand','knee_a','knee_b']:
        x,y=p(name);draw.ellipse((x-4,y-4,x+4,y+4),fill='#d16b66')
im.save(ROOT/'inputs/X1-weight-transfer-guide.png')
shutil.copy2(PRIOR/'inputs/appearance-guard.png',ROOT/'inputs/appearance-guard.png')
contract={'created_at_utc':datetime.now(timezone.utc).isoformat(),'status':'Requested weight-transfer/braking/downward-cut correction; candidate awaiting visual review','source':'New original joint targets authored for this feedback; no imported animation','duration':.72,'heat100_multiplier':1.5,'active_window':[.126,.5075],'pacing_split':.21,'cell':[448,448],'foot_anchor':[224,400],'actor_origin':[224,348],'keys':keys,'planned_pelvis_x_range':[-15,18],'planned_pelvis_y_range':[-88,-77],'planned_max_downward_blade_angle':52,'planned_min_downward_tip_clearance':min(-k['points']['sword_tip'][1] for k in keys if k['blade_angle_down_from_right']>=0),'endpoint_reuse':[0,15],'planned_rendered_cells':14,'front_foot_fixed':True,'rear_heel_roll_is_art_only':True,'gameplay_changes':False,'contact_geometry_adapted':False,'root_lunge_or_actor_motion_changed':False,'production_art_accepted':False,'previous_candidate_sha256':hashlib.sha256((PRIOR/'outputs/x1-followthrough.png').read_bytes()).hexdigest()}
(ROOT/'contract.json').write_text(json.dumps(contract,indent=2)+'\n',encoding='utf-8',newline='\n')
feedback={'date_local':'2026-10-23','source':'Direct user review of v03 moving comparison','relative_assessment':'Sword path is better; body still feels stiff','requested_corrections':['Improve weight transfer','Improve how the swing stops','More downward sword direction for power','Show in same review tool','Keep gameplay unchanged'],'production_approval':False}
(ROOT/'user-feedback.json').write_text(json.dumps(feedback,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Prepared16 original keys: pelvis target travel33px, body compression11px, maximum blade52deg down; duration/gameplay unchanged.')
