"""Source-timed three-version character review; no scene capture or new artwork."""
from pathlib import Path
import json,re,hashlib,shutil,subprocess
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parent;REPO=ROOT.parents[2]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
native=(REPO/'config/attack_animations/fire_x1.tres').read_text(encoding='utf-8')
style=(REPO/'config/attack_styles/fire_x1.tres').read_text(encoding='utf-8')
texture=re.search(r'\[ext_resource type="Texture2D"[^\n]*path="res://([^"]+)"',native)[1]
keys=re.search(r'tracks/2/keys = \{(.*?)\n\}',native,re.S)[1]
native_times=[float(v) for v in re.search(r'"times": PackedFloat32Array\((.*?)\)',keys)[1].split(',')]
rects=[[float(x.strip()) for x in v.split(',')] for v in re.findall(r'Rect2\((.*?)\)',keys)]
split=float(re.search(r'"name": &"timing_split",\s*"time": ([\d.]+)',native)[1])
windup=float(re.search(r'^windup_duration = ([\d.]+)',style,re.M)[1]);recovery=float(re.search(r'^recovery_duration = ([\d.]+)',style,re.M)[1])
assert abs(windup+recovery-.72)<1e-6,'Current action contract differs; do not silently normalize it.'
times=[v/split*windup if v<=split else windup+(v-split)/(1-split)*recovery for v in native_times]
shutil.copy2(REPO/texture,ROOT/'inputs/current-game-x1.png')
exp=json.loads((ROOT/'experiment.json').read_text())
trial_times=exp['baseline']['times'];trial_rects=[[i%8*448,i//8*448,448,448] for i in range(16)]
versions=[];bounds=[]
for vid,label,caption,path,url,ts,rs in [
 ('game','Current game','Installed X1 artwork',ROOT/'inputs/current-game-x1.png','../inputs/current-game-x1.png',times,rects),
 ('v08','v08 · previous','Previous iteration',ROOT/'inputs/baseline-v08.png','../inputs/baseline-v08.png',trial_times,trial_rects),
 ('h01','H01 · this iteration','Only frames5–7 edited',ROOT/'outputs/x1-h01-grip-continuity.png','x1-h01-grip-continuity.png',trial_times,trial_rects)]:
 im=Image.open(path).convert('RGBA')
 for x,y,w,h in rs:
  a=np.asarray(im.crop((int(x),int(y),int(x+w),int(y+h))))[:,:,3]
  yy,xx=np.where(a>16);bounds.append([int(xx.min()),int(yy.min()),int(xx.max()+1),int(yy.max()+1)])
 versions.append({'id':vid,'label':label,'caption':caption,'sprite':url,'sprite_sha256':sha(path),'times':ts,'rects':rs,'duration':.72})
half=max(224-min(b[0] for b in bounds),max(b[2] for b in bounds)-224)+12
top=max(0,min(b[1] for b in bounds)-12);bottom=min(448,max(416,max(b[3] for b in bounds)+12))
edit_bounds={str(i):list(Image.open(ROOT/'outputs'/f'key{i:02}-edit-mask.png').getbbox()) for i in [5,6,7]}
data={'experiment_id':'H01','duration':.72,'heat100_multiplier':1.5,'foot_anchor':[224,400],
 'view_box':[224-half,top,half*2,bottom-top],'versions':versions,'changed_frames':[5,6,7],'edit_bounds':edit_bounds,
 'focus':{'5':'Fingers around the upright handle','6':'Grip connection while the blade turns','7':'Forearm → wrist → palm → hilt'},
 'reference':'../inputs/release-grip-construction.png','notes_api':'/api/review-notes/H01',
 'source_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),
 'current_game_source':{'resource':'config/attack_animations/fire_x1.tres','resource_sha256':sha(REPO/'config/attack_animations/fire_x1.tres'),'texture':texture,'texture_sha256':sha(REPO/texture)},
 'scope':'Character-only source flipbooks at original drawing times. No scene, HUD, camera, hit-stop, root lunge, contact or gameplay simulation.'}
(ROOT/'outputs/character-data.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'versions':[(v['id'],len(v['times'])) for v in versions],'view_box':data['view_box'],'source_timing_s':windup+recovery}))
