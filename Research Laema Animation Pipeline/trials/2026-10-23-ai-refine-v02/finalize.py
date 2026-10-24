"""Inventory the completed local slice and its actual elapsed/repair evidence."""
from pathlib import Path
from datetime import datetime,timezone
import hashlib,json,ast,csv
from PIL import Image
import numpy as np
ROOT=Path(__file__).parent;RESEARCH=ROOT.parents[1]
data=json.loads((ROOT/'outputs/clips.json').read_text())
prior=Image.open(ROOT.parent/'2026-10-23-A-v01/outputs/ai-corrected.png').convert('RGBA')
refined=Image.open(ROOT/'outputs/x1-refined.png').convert('RGBA')
preserved=[]
for k in json.loads((ROOT/'contract.json').read_text())['x1_baseline_keys']:
    i=next(i for i,c in enumerate(data['added_drawing_origins']) if c['t']==k['t'])
    j=next(j for j,c in enumerate(json.loads((ROOT/'contract.json').read_text())['x1_baseline_keys']) if c['t']==k['t'])
    a=prior.crop((j%5*448,j//5*448,j%5*448+448,j//5*448+448))
    b=refined.crop((i%8*448,i//8*448,i%8*448+448,i//8*448+448))
    preserved.append(bool(np.array_equal(np.asarray(a),np.asarray(b))))
assert all(preserved)
for p in ROOT.glob('*.py'):ast.parse(p.read_text(encoding='utf-8'))
captures={d.name:len(list(d.glob('frame_*.png'))) for d in (ROOT/'evidence/comparison-captures').iterdir() if d.is_dir()}
assert all(n==120 for n in captures.values()) and len(captures)==4
summary=json.loads((ROOT/'evidence/gameplay-summary.json').read_text())
assert summary['external_inputs_during_command']==0
assert sum(x['kind']=='cast_launched' for x in summary['outcomes'])==1
assert any(x['kind']=='spell_projectile_impacted' for x in summary['outcomes'])
now=datetime.now(timezone.utc)
elapsed=(now-datetime.fromtimestamp((ROOT/'contract.json').stat().st_mtime,timezone.utc)).total_seconds()
verification={'verified_at_utc':now.isoformat(),'preferred_source_cells_preserved_rgba':preserved,'native_comparison_capture_counts':captures,'controlled_cast_launches':1,'controlled_spell_impacts':1,'external_inputs_during_controlled_command':0,'observed_lab_elapsed_seconds_since_pose_contract_creation':elapsed,'elapsed_scope':'Includes agent analysis, implementation, one-time integration/input-fixture setup, generation waits, rendering and documentation. Not active human artist time or per-action production cost.','remaining_quality':'Visual acceptance, residual detail/sole drift, original-art handoffs and visual/query alignment remain open.'}
(ROOT/'evidence/final-verification.json').write_text(json.dumps(verification,indent=2)+'\n',encoding='utf-8',newline='\n')
with (ROOT/'effort.csv').open('w',encoding='utf-8',newline='') as f:
    w=csv.writer(f);w.writerow(['action','image_requests','rejected_initial_passes','new_inbetween_drawings','explicit_guard_reuses','explicit_peak_reuses','human_pixel_paint_minutes','active_human_review_minutes','finished_quality_accepted'])
    w.writerow(['X1 refinement',2,1,6,0,0,0,'',False]);w.writerow(['Cast reuse',2,1,0,2,2,0,'',False])
files=[]
for p in sorted(ROOT.rglob('*')):
    if not p.is_file() or set(p.parts)&{'.godot','__pycache__','gameplay-preview','captures','comparison-captures'} or p.name=='artifact-manifest.json':continue
    files.append({'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(ROOT/'artifact-manifest.json').write_text(json.dumps({'kind':'local refinement/reuse evidence; generated game copy and derived capture sequences retained locally but inventoried via their source/capture reports','files':files},indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'source_cells_preserved':sum(preserved),'comparison_conditions':captures,'image_requests':4,'controlled_cast_launches':1,'external_inputs':0,'observed_lab_wall_minutes':round(elapsed/60,2),'inventoried_files':len(files)},indent=2))
