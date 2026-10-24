"""Correct the mislocated guide landmarks and prevent whole-cell zoom reframing."""
from pathlib import Path
import json,datetime
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent
baseline=Image.open(ROOT/'inputs/baseline-h01.png').convert('RGBA');tile=baseline.crop((448,0,896,448))
crop=(140,140,310,410);target=Image.new('RGBA',(1020,540));guide=Image.new('RGB',(1020,540),'#17212c')
targets=[
 {'frame':2,'name':'LOAD','head':[223,239],'neck':[221,254],'shoulder':[214,265],'hip':[215,313],'rear_knee':[185,350],'front_knee':[258,346],'rear_foot':[180,400],'front_foot':[275,400],'hand':[234,247],'blade_tip':[204,161]},
 {'frame':3,'name':'PEAK COIL','head':[213,244],'neck':[212,259],'shoulder':[205,270],'hip':[207,318],'rear_knee':[181,354],'front_knee':[253,347],'rear_foot':[180,400],'front_foot':[275,400],'hand':[225,250],'blade_tip':[195,164]},
 {'frame':4,'name':'BEGIN DRIVE','head':[228,238],'neck':[227,253],'shoulder':[220,264],'hip':[220,312],'rear_knee':[190,348],'front_knee':[261,345],'rear_foot':[180,400],'front_foot':[275,400],'hand':[237,247],'blade_tip':[207,161]}
]
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',17)
for i,p in enumerate(targets):
 image=tile.crop(crop).resize((340,540),Image.Resampling.NEAREST);target.paste(image,(i*340,0))
 bg=Image.new('RGB',(340,540),'#17212c');bg.paste(image,(0,0),image);bg=Image.blend(bg,Image.new('RGB',bg.size,'#17212c'),.65);d=ImageDraw.Draw(bg)
 def point(name):return tuple((p[name][j]-crop[j])*2 for j in [0,1])
 for a,b in [('neck','hip'),('hip','rear_knee'),('rear_knee','rear_foot'),('hip','front_knee'),('front_knee','front_foot'),('shoulder','hand')]:d.line([point(a),point(b)],fill='#67dce8',width=6)
 hx,hy=point('head');d.ellipse((hx-17,hy-22,hx+17,hy+22),outline='#67dce8',width=4)
 d.line([point('hand'),point('blade_tip')],fill='#f3d16d',width=4)
 d.text((5,492),f'{p["frame"]} · {p["name"]}',font=font,fill='white')
 guide.paste(bg,(i*340,0))
target.save(ROOT/'inputs/preparation-cropped-target.png');guide.save(ROOT/'inputs/corrected-preparation-guide.png')
(ROOT/'inputs/corrected-body-targets.json').write_text(json.dumps({'crop':list(crop),'targets':targets,'source_landmark_basis':'Source torso/hip around309, knees around345–350, not the earlier326/369 guide coordinates. These remain original proposed poses, not measured motion capture.'},indent=2)+'\n',encoding='utf-8',newline='\n')
rejection={'attempt':1,'decision':'rejected_before_candidate_export','reason':['Original guide placed hips and knees below their intended source-anatomy locations; this was an agent guide error.','Full448px-cell input caused output figures to be enlarged/reframed; this violates fixed-scale/registration controls.'],'raw':'raw/attempt01.png','prompt':'prompts/attempt01.txt','source_reference':'inputs/preparation-edit-target.png','corrective_action':'Correct guide against source landmarks and use a tight source crop with unchanged scale/boot contacts.'}
(ROOT/'evidence/rejected-attempt01.json').write_text(json.dumps(rejection,indent=2)+'\n',encoding='utf-8',newline='\n')
prompt='''Use case: precise-object-edit. Image1 is the edit target: three identical TIGHTLY CROPPED original preparation sprites in one horizontal row. Image2 is a CORRECTED ORIGINAL load/coil/drive pose guide in exactly the same crop layout. Return ONE three-panel row with the SAME aspect ratio and crop positions, real transparent alpha.
The input crop is already tightly framed. PRESERVE ITS FRAMING AND CHARACTER SCALE. Do not enlarge figures to fill cells, change camera, recenter individual figures or move the boots. Each original crop represents source coordinates x140..310, y140..410. In each cropped cell, rear/front boot contacts remain at original x40/135, y260. Maintain the original foot separation and shoe sizes.

Replace only these three PREPARATION poses with an original, readable LOAD → PEAK COIL → BEGIN DRIVE progression. Left/frame2: modest rear-leg loading, pelvis/head/shoulders about8px back and4px down at native source size. Middle/frame3: visibly stronger rear load, about16–18px back and8–9px lower, with rear knee flexing and front leg braced/long. Right/frame4: rear leg begins extending, body travels forward/up from the coil toward the existing upright release; remain in compact chamber, no early slash or thrust. The pelvis in the source is around y309; knees around y345–350. Do not put knees inside the boot shafts or make a deep squat. Keep normal body/limb proportions, not a shrunken torso or oversized thighs.

The whole body shifts its weight INSIDE the same planted stance. Hip, torso and head must visibly progress, not three identical poses with different texture/hair. The arm/hand and chamber sword follow the load naturally, with continuous elbow/wrist and closed grip; keep the face clear and avoid a crossed arm across the eyes. Blade stays up-left, same steel sword length and crossguard; no floor stab or forward thrust. These are preparation frames only; the subsequent release is not being changed.

Preserve Image1's exact character identity and painted sprite style: face, ivory ponytail volume, blue vest, cream rolled sleeves, red sash, brown trousers/gloves/boots, small round blue shield and existing straight sword. No new ears/accessories/armor/cape, no enlarged shield/boots, no extra limb/fingers, no blur/trails/glow/shadow/background. Shield remains on the left forearm and follows torso. Remove all diagram labels, dots, lines and text. Keep full boots and blade within their original crop edges. The three intended body-load silhouettes must remain distinctly readable at native size without appearance drift.
'''
(ROOT/'prompts/attempt02.txt').write_text(prompt,encoding='utf-8',newline='\n')
print('Corrected source landmarks and tighter same-scale crop prepared; attempt01 remains rejected.')
