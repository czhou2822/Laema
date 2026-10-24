"""Publish H02's character-only comparison without changing the H01 review."""
from pathlib import Path
import json,hashlib,shutil
import numpy as np
from PIL import Image
ROOT=Path(__file__).resolve().parent;PREVIOUS=ROOT.parent/'2026-10-24-x1-quality-h01';REPO=ROOT.parents[2]
old=json.loads((PREVIOUS/'outputs/character-data.json').read_text());exp=json.loads((ROOT/'experiment.json').read_text())
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
game=dict(old['versions'][0]);shutil.copy2(PREVIOUS/'inputs/current-game-x1.png',ROOT/'inputs/current-game-x1.png')
assert sha(REPO/old['current_game_source']['texture'])==game['sprite_sha256'],'The installed reference changed: refresh its source timing explicitly.'
times=exp['baseline']['times'];rects=[[i%8*448,i//8*448,448,448] for i in range(16)]
versions=[game,
 {'id':'h01','label':'H01 · previous','caption':'Previous working iteration','sprite':'../inputs/baseline-h01.png','sprite_sha256':sha(ROOT/'inputs/baseline-h01.png'),'times':times,'rects':rects,'duration':.72},
 {'id':'h02','label':'H02 · preparation test','caption':'New loading in frames2–4','sprite':'x1-h02-preparation.png','sprite_sha256':sha(ROOT/'outputs/x1-h02-preparation.png'),'times':times,'rects':rects,'duration':.72}]
bounds=[]
for v in versions:
 path=(ROOT/'outputs'/v['sprite']).resolve();im=Image.open(path).convert('RGBA')
 for x,y,w,h in v['rects']:
  a=np.asarray(im.crop((int(x),int(y),int(x+w),int(y+h))))[:,:,3];yy,xx=np.where(a>16);bounds.append([int(xx.min()),int(yy.min()),int(xx.max()+1),int(yy.max()+1)])
half=max(224-min(b[0] for b in bounds),max(b[2] for b in bounds)-224)+12;top=max(0,min(b[1] for b in bounds)-12);bottom=min(448,max(416,max(b[3] for b in bounds)+12))
data={'experiment_id':'H02','candidate_id':'h02','duration':.72,'heat100_multiplier':1.5,'foot_anchor':[224,400],
 'view_box':[224-half,top,half*2,bottom-top],'versions':versions,'changed_frames':[2,3,4],
 'edit_bounds':{str(i):[140,140,310,393] for i in [2,3,4]},
 'focus':{'2':'Load onto the rear leg','3':'Peak loaded coil','4':'Begin drive into frame5'},
 'review':{'summary':'H02 replaces the static preparation with a load → coil → begin-release progression in frames2–4.',
 'detail':'Focus on3, then2 →3 →4 →5. The other13 frames and all key times are unchanged. Appearance and foot/boot continuity still need review.',
 'focus_frames':[2,3,4],'main_focus':3,'previous_review':'review.html?experiment=H01'},
 'reference':'../inputs/corrected-preparation-guide.png','notes_api':'/api/review-notes/H02',
 'current_game_source':old['current_game_source'],'source_revision':exp['source_revision'],
 'scope':'Source flipbook only. H02 has not been installed into the primary game or newly tested in Godot. H01 gameplay recordings remain historical.'}
(ROOT/'outputs/character-data.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'review':'H02','versions':[v['id'] for v in versions],'frames_changed':[2,3,4]}))
