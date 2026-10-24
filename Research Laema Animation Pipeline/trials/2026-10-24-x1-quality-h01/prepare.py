"""Freeze H01's baseline and prepare local release-arm edit targets."""
from pathlib import Path
import json, hashlib, shutil, datetime, subprocess
from PIL import Image

ROOT=Path(__file__).resolve().parent
RESEARCH=ROOT.parents[1]
BASE=ROOT.parent/'2026-10-23-x1-structural-grip-v08'
for folder in ['inputs','raw','outputs','prompts','evidence']:(ROOT/folder).mkdir(exist_ok=True)
assert not (ROOT/'experiment.json').exists(), 'Preserve an existing experiment; do not overwrite it.'
source=BASE/'outputs/x1-one-pose-structural-v08.png'
shutil.copy2(source,ROOT/'inputs/baseline-v08.png')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(source)=='530b98887f3b9b3285f154e6715960c74d86a7da3ac52c4791071198b1c3283d'
im=Image.open(source).convert('RGBA')
crop=[196,208,324,336]
board=Image.new('RGBA',(1536,512))
for col,key in enumerate([5,6,7]):
 i=key-1;tile=im.crop((i%8*448,i//8*448,i%8*448+448,i//8*448+448))
 tile.save(ROOT/'inputs'/f'key{key:02}.png')
 patch=tile.crop(crop)
 patch.save(ROOT/'inputs'/f'arm-key{key:02}-native.png')
 board.paste(patch.resize((512,512),Image.Resampling.NEAREST),(col*512,0))
board.save(ROOT/'inputs/release-arms-edit-target-4x.png')
clips=json.loads((BASE/'outputs/clips.json').read_text())
clip=next(c for c in clips['clips'] if c['id']=='structural_v08')
experiment={'id':'H01','created_at_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'source_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=RESEARCH.parent,text=True).strip(),
 'stage':'blocking correction, tested in complete X1 context; not polish',
 'problem':'The user reports an unconvincing wrist-to-sword relationship; local hand detail alone did not fix the pose.',
 'competing_explanations':{'H1':'Incoherent wrist/palm/handle construction across the three release drawings.','H2':'Torso/hip sequencing and body weight are the principal cause.','H3':'Whole-character redraw drift produces the perceived hitch.'},
 'selected_hypothesis':'H1',
 'hypothesis':'Consistent closed-hand/handle construction and connected forearms across drawings5–7 will make the release read more convincingly without changing the blade path or body performance.',
 'intended_modification':'AI edits of the three local sword-arm crops, composited through explicit arm-only masks. Source alpha may change inside masks; surrounding body and weapon pixels are protected.',
 'predicted_improvement':'At native scale and normal speed the fist stays attached to the hilt and the wrist/forearm relationship reads coherently through release.',
 'baseline':{'file':'inputs/baseline-v08.png','sha256':sha(source),'times':clip['times'],'duration':.72,'columns':8},
 'changed_keys_1_based':[5,6,7],'crop_in_source_cell':crop,
 'protected_variables':['Other13 cells exact','All16 key times exact','Body/feet/equipment outside masks exact','Blade/guard outside glove exact','Native gameplay source, clocks, active window, contact curves, lunge, input, damage and other actions exact'],
 'reference':{'kind':'Original manually specified wrist/palm/hilt construction; no downloaded sequence','file':'inputs/release-grip-construction.png','purpose':'Closed fingers enclose handle, guard beyond thumb/index side, continuous wrist/forearm; existing blade axes retained'},
 'actual_modifications':None,'technical_result':'not run','observed_improvement':None,'regressions':None,
 'remaining_problems':['Existing body stiffness/braking','v08 body/equipment drift in key7','Unapproved surrounding poses and art/contact mismatch'],
 'human_verdict':{'decision':'pending','quality_improved':None,'source':None},
 'agent_assessment':{'hypothesis_verdict':'pending','quality_improved':None},
 'generation_calls':[],'human_artist_minutes':0,'human_review_minutes':None,'agent_total_elapsed_seconds':None,
 'production_approved':False,'gameplay_changed':False,'workflow_winner':None}
(ROOT/'experiment.json').write_text(json.dumps(experiment,indent=2)+'\n',encoding='utf-8')
print(ROOT/'inputs/release-arms-edit-target-4x.png')
