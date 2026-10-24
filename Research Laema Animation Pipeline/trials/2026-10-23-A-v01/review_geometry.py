"""Read-only comparison of original A blade targets with unchanged native X1 queries."""
from pathlib import Path
import json,re,math,bisect,hashlib
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).parent
RESEARCH=ROOT.parents[1]
REPO=RESEARCH.parent
source=REPO/'config/attack_animations/fire_x1.tres'
text=source.read_text()
data=json.loads((RESEARCH/'study-data.json').read_text())['proposals'][0]
metrics=json.loads((ROOT/'outputs/metrics.json').read_text())

def track(index):
    body=re.search(r'tracks/'+str(index)+r'/keys = \{(.*?)\n\}',text,re.S)[1]
    times=list(map(float,re.search(r'PackedFloat32Array\(([^)]+)\)',body)[1].split(',')))
    values=[np.array(list(map(float,v.split(',')))) for v in re.findall(r'Vector2\(([^)]+)\)',body)]
    assert re.search(r'tracks/'+str(index)+r'/interp = 0',text)
    assert '"update": 1' in body
    return times,values
position=track(3);target=track(4)
def held(track,time):return track[1][max(0,bisect.bisect_right(track[0],time)-1)]
def blade(t):
    keys=data['keys'];i=min(len(keys)-2,max(0,bisect.bisect_right([k['t'] for k in keys],t)-1))
    a,b=keys[i:i+2];u=min(1,max(0,(t-a['t'])/(b['t']-a['t'])))
    if a['mode']=='smooth':u=u*u*(3-2*u)
    hand=np.array(a['points']['hand'])*(1-u)+np.array(b['points']['hand'])*u
    va=np.array(a['points']['sword_tip'])-a['points']['hand'];vb=np.array(b['points']['sword_tip'])-b['points']['hand']
    aa,bb=math.atan2(va[1],va[0]),math.atan2(vb[1],vb[0]);angle=aa+math.atan2(math.sin(bb-aa),math.cos(bb-aa))*u
    return hand,hand+88*np.array([math.cos(angle),math.sin(angle)])
def query(t):
    phase=t/.21*.6 if t<=.21 else .6+(t-.21)/.51*.4
    start=held(position,phase)*2+np.array([0,-52])
    return start,start+held(target,phase)*2
def distance(p,a,b):
    v=b-a;u=min(1,max(0,float((p-a)@v/(v@v))))
    return float(np.linalg.norm(p-(a+u*v)))
samples=[]
for t in np.linspace(.126,.50749995,201):
    hand,tip=blade(float(t));q0,q1=query(float(t))
    distances=[distance(hand*(1-u)+tip*u,q0,q1) for u in np.linspace(0,1,11)]
    samples.append({'t_heat0':float(t),'blade_hand':hand.tolist(),'blade_tip':tip.tolist(),'native_query_start_foot_space':q0.tolist(),'native_query_end_foot_space':q1.tolist(),'hand_gap_beyond_radius':max(0,distances[0]-7),'tip_gap_beyond_radius':max(0,distances[-1]-7),'fraction_sampled_blade_inside_capsule':sum(d<=7 for d in distances)/len(distances)})
report={'scope':'source-sampled geometry correspondence only; not collision/playtest proof','source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'sample_count':len(samples),'query_conversion':'native actor-local positions/targets * root scale2, then actor origin(0,-52) relative to foot; discrete held tracks; circle world radius7','root_lunge':'omitted from relative comparison; actor and query share it','unchanged_gameplay':True,'max_hand_gap_beyond_query_radius':max(s['hand_gap_beyond_radius'] for s in samples),'max_tip_gap_beyond_query_radius':max(s['tip_gap_beyond_radius'] for s in samples),'full_blade_inside_query_samples':sum(s['fraction_sampled_blade_inside_capsule']==1 for s in samples),'samples':samples}
(ROOT/'outputs/contact-correspondence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
proposal=[]
for t in metrics['rig_times']:
    hand,tip=blade(t)
    phase=t/.21*.6 if t<=.21 else .6+(t-.21)/.51*.4
    proposal.append({'time_heat0':t,'normalized_phase':phase,'position_actor_local':((hand+np.array([0,52]))/2).tolist(),'target_actor_local':((tip-hand)/2).tolist(),'radius_actor_local':3.5})
(ROOT/'outputs/contact-adaptation-PROPOSAL.json').write_text(json.dumps({'status':'UNAPPROVED_SPATIAL_CHANGE_NOT_INSTALLED','purpose':'Concrete contact-geometry candidate for user review; not runtime validated','preserved':{'windup':.21,'recovery':.51,'active_start_normalized':.36,'timing_split_normalized':.6,'active_end_normalized':.8333333,'heat_multiplier':1.5,'local_radius':3.5,'input_queue_dodge_damage_lunge_Cast_rules':'unchanged'},'change':'query line would follow original A hand-to-tip; changes spatial contact trajectory and may change hit outcomes','keys':proposal},indent=2)+'\n',encoding='utf-8',newline='\n')
font=lambda n:ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',n)
board=Image.new('RGB',(1280,900),'#111b25');d=ImageDraw.Draw(board)
d.text((24,12),'A blade targets vs unchanged native X1 query',fill='#e4ebf0',font=font(26))
d.text((24,48),'Green: original A hand-to-tip. Red: existing query capsule. Static source comparison; no runtime contact result.',fill='#a6b8c7',font=font(16))
atlas=Image.open(ROOT/'outputs/rig-cutout.png').convert('RGBA')
for j,t in enumerate([.126,.158,.34,.5075]):
    left=(j%2)*640;top=85+(j//2)*400;foot=np.array([left+290,top+310])
    index=min(range(len(metrics['rig_times'])),key=lambda i:abs(metrics['rig_times'][i]-t))
    tile=atlas.crop((index%8*448,index//8*448,index%8*448+448,index//8*448+448))
    board.paste(tile,(int(foot[0]-224),int(foot[1]-400)),tile)
    d.text((left+22,top+16),f'Heat 0 / {t:.4f}s',fill='#dec18b',font=font(20))
    q0,q1=query(t);hand,tip=blade(t)
    qa,qb=foot+q0,foot+q1
    d.line((tuple(qa),tuple(qb)),fill='#e77d79',width=14)
    for q in [qa,qb]:d.ellipse((q[0]-7,q[1]-7,q[0]+7,q[1]+7),fill='#e77d79')
    d.line((tuple(foot+hand),tuple(foot+tip)),fill='#8ce0bd',width=3)
    d.line((left+50,foot[1],left+600,foot[1]),fill='#506b7f',width=1)
    d.text((left+22,top+350),'Foot origin Y0 / actor-query origin Y-52',fill='#9eb1c1',font=font(15))
board.save(ROOT/'contact-correspondence.png')
print(json.dumps({k:v for k,v in report.items() if k not in ['samples']},indent=2))
