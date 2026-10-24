"""H02: original preparation loading, based on version-bound user annotations."""
from pathlib import Path
import json,hashlib,shutil,datetime,subprocess
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent;PREVIOUS=ROOT.parent/'2026-10-24-x1-quality-h01';REPO=ROOT.parents[2]
for name in ['inputs','outputs','raw','prompts','evidence']:(ROOT/name).mkdir(exist_ok=True)
assert not (ROOT/'experiment.json').exists(),'Preserve an existing H02 experiment.'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
source=PREVIOUS/'outputs/x1-h01-grip-continuity.png'
assert sha(source)=='9162558ffc4a38ae67da020f2c7617885ff68d020e031e26a0086762c6730eb8'
shutil.copy2(source,ROOT/'inputs/baseline-h01.png')
notes=json.loads((PREVIOUS/'annotations.json').read_text(encoding='utf-8'));active=[n for n in notes['notes'] if not n.get('deleted')]
(ROOT/'inputs/feedback-snapshot.json').write_text(json.dumps({'source':'../2026-10-24-x1-quality-h01/annotations.json','source_revision':notes['revision'],'source_sha256':sha(PREVIOUS/'annotations.json'),'active_notes':active},indent=2)+'\n',encoding='utf-8',newline='\n')
atlas=Image.open(source).convert('RGBA');target=Image.new('RGBA',(1344,448))
tiles=[atlas.crop((i*448,0,(i+1)*448,448)) for i in [1,2,3]]
assert len({t.tobytes() for t in tiles})==1,'The reviewed hold is no longer the same baseline.'
for i,tile in enumerate(tiles):target.paste(tile,(448*i,0))
target.save(ROOT/'inputs/preparation-edit-target.png')
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',15)
guide=Image.new('RGB',(1344,448),'#17212c')
targets=[
 {'frame':2,'name':'LOAD','head':[225,234],'neck':[224,253],'shoulder':[217,268],'hip':[218,326],'rear_knee':[194,366],'front_knee':[259,361],'rear_foot':[180,400],'front_foot':[275,400],'hand':[235,244],'blade_tip':[205,158]},
 {'frame':3,'name':'PEAK COIL','head':[214,242],'neck':[214,260],'shoulder':[207,275],'hip':[207,334],'rear_knee':[189,369],'front_knee':[252,365],'rear_foot':[180,400],'front_foot':[275,400],'hand':[225,249],'blade_tip':[195,163]},
 {'frame':4,'name':'DRIVE BEGINS','head':[229,233],'neck':[228,252],'shoulder':[221,268],'hip':[223,326],'rear_knee':[198,366],'front_knee':[259,361],'rear_foot':[180,400],'front_foot':[275,400],'hand':[237,246],'blade_tip':[207,160]}
]
for i,p in enumerate(targets):
 bg=Image.new('RGB',(448,448),'#17212c');bg.paste(tiles[i],(0,0),tiles[i]);bg=Image.blend(bg,Image.new('RGB',bg.size,'#17212c'),.66);d=ImageDraw.Draw(bg)
 for a,b in [('neck','hip'),('hip','rear_knee'),('rear_knee','rear_foot'),('hip','front_knee'),('front_knee','front_foot'),('shoulder','hand')]:d.line([tuple(p[a]),tuple(p[b])],fill='#5bd9e8',width=4)
 hx,hy=p['head'];d.ellipse((hx-9,hy-12,hx+9,hy+12),outline='#5bd9e8',width=3)
 d.line([tuple(p['hand']),tuple(p['blade_tip'])],fill='#f3d16d',width=3)
 for name in ['hip','shoulder','rear_knee','front_knee']:
  x,y=p[name];d.ellipse((x-3,y-3,x+3,y+3),fill='#9ae1b4')
 d.line((155,400,300,400),fill='#acb6c5',width=1)
 d.text((12,12),f'FRAME {p["frame"]} · {p["name"]}',font=font,fill='white')
 d.text((12,35),'Original body-load targets. Feet stay planted.',font=font,fill='#b5c9da')
 guide.paste(bg,(i*448,0))
guide.save(ROOT/'inputs/original-preparation-guide.png')
(ROOT/'inputs/body-targets.json').write_text(json.dumps(targets,indent=2)+'\n',encoding='utf-8',newline='\n')
prompt='''Use case: precise-object-edit / original 2D sprite blocking correction. Image1 is the EDIT TARGET: three identical original H01 preparation drawings in three448px square cells, left to right. Image2 is an ORIGINAL BODY-LOAD CONSTRUCTION GUIDE, not a traced animation.
Produce ONE three-panel horizontal sprite strip, aspect3:1, with three clearly distinct preparation poses for the SAME Laema character. This is a whole-body PERFORMANCE correction to a weak static preparation, not a costume/detail repaint. Preserve the cell origins, camera, figure scale and exact two boot contact positions of Image1. Real transparent alpha. All figures and whole blades fit within their own cells.

Pose2 / LEFT: load onto the rear LEFT leg. Move pelvis/upper body visibly back about8–10 source pixels, soften the rear knee and lower the body slightly. Keep the front RIGHT boot planted. Compact sword chamber beside the cheek, clear face, elbow comfortably bent.
Pose3 / MIDDLE: the peak loaded/COILED pose must be visibly different. Pelvis and shoulders shift farther toward the rear leg, about18 source pixels back and8–10 pixels lower than the source. Torso recoils slightly against the coming down-right cut; bend the rear knee, retain a long bracing front leg. The arm and sword move with the loaded torso, without a broken wrist or floating grip. This is the strongest compressed silhouette, not an upright duplicate.
Pose4 / RIGHT: drive begins. The rear leg starts extending and pelvis/shoulders move forward/up toward the source release pose while the front boot stays planted. Head, torso and hips visibly depart from the peak coil; preserve the compact chamber until the next existing release drawing. Do NOT swing or thrust early. The three poses must read LOAD → PEAK COIL → START UNCOIL when played in order.

The cyan/green construction in Image2 gives intended body staging; retain the same body proportions rather than copying diagram stick thickness. Keep both boots on the same source ground line at the same original x positions. Do NOT move the whole character across the cell to fake a weight shift. The weight change is inside the planted stance. Keep the same straight sword length, crossguard/handle, and closed leather grip. Chamber blade stays up-left; do not introduce a downward floor stab or a forward thrust in these preparation cells. Shield remains strapped to the left forearm and follows the torso naturally.

Use Image1 as the ONLY appearance master: same ivory ponytail/face, blue vest, cream rolled sleeves, red sash, brown trousers/gloves/boots, round blue shield and straight plain steel sword. Same painted sprite finish, face, hair volume, equipment scale and lighting. No new armor, cape, accessory, weapon, extra finger or extra limb. No artificial blur/trails/glow/shadow/background. Remove ALL guide lines, labels, dots and grids. Do not return three nearly identical upright drawings; the body-load silhouettes and rear-knee/hip/shoulder positions must genuinely progress. Only these three preparation frames are being proposed; no later action or gameplay change.
'''
(ROOT/'prompts/attempt01.txt').write_text(prompt,encoding='utf-8',newline='\n')
baseline_exp=json.loads((PREVIOUS/'experiment.json').read_text())
exp={'id':'H02','created_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'source_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),
 'baseline':{'id':'h01','file':'inputs/baseline-h01.png','sha256':sha(source),'times':baseline_exp['baseline']['times'],'duration':.72,'columns':8},
 'feedback_snapshot':'inputs/feedback-snapshot.json','feedback_interpretation':'v08 preparation2–4 criticism transfers to H01 because those cells are byte-identical. The game2 preparation is a quality/principle reference only, not a generation/tracing input. Game3–4 elbow and6 thrust observations remain separate. The v08 release-comparison note does not establish a positive H01 verdict.',
 'stage':'Blocking / preparation performance','problem':'The inherited three-key chamber is one static pose and reads weaker than the preferred game preparation.',
 'hypothesis':'A clear rear-leg load, peak coil and beginning drive within the existing preparation span will read more powerful than the static H01 chamber.',
 'scope':'Replace only preparation frames2–4. Coordinated body/arm/sword loading is one phase treatment; this is not a pure hip-only causal test.',
 'changed_frames':[2,3,4],'protected':['All16 saved key times','13 non-preparation cells exact, including H01 grip edits5–7','Duration.720/.480 at fixed Heat0/100','Gameplay code/settings, contact geometry, active window, lunge, input and damage unchanged','Both source boot contact positions are registration targets'],
 'intended_modification':'Three distinct original body-load poses following the guide, with consistent character/equipment and planted feet.',
 'predicted_improvement':'At native size/normal speed the preparation visibly loads then releases, without foot skating or an abrupt return into frame5.',
 'remaining_feedback':['Game reference elbow handoff3–4→5','Game reference6 reads as thrust','H01 grip improvement not established','Later body braking and appearance drift'],
 'actual_modifications':None,'generation_calls':[],'human_verdict':{'decision':'pending','quality_improved':None},'agent_assessment':{'quality_improved':None,'hypothesis_verdict':'pending'},'gameplay_changed':False,'production_approved':False,'workflow_winner':None}
(ROOT/'experiment.json').write_text(json.dumps(exp,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'active_feedback':len(active),'prior_hold_cells_identical':True,'target_frames':[2,3,4]}))
