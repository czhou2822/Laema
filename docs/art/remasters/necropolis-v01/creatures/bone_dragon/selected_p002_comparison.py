"""Labeled diagnostic of the selected A06 artwork; no artwork modification."""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path
from PIL import Image, ImageDraw
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[6]
BASE=ROOT/'assets/prototype/enemy/bone_dragon/remaster_v01'
spec=importlib.util.spec_from_file_location('remaster_readonly',ROOT/'tools/art/necropolis_remaster.py')
h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
pose=h.posemap(h.creature('bone_dragon'))['bone_dragon_p002']
record=json.loads((BASE/'poses/bone_dragon_p002.json').read_text(encoding='utf-8'))
assert record['raw_source'].endswith('full-p002-a06-far-wing.png')
source=h.projected_original(pose);new=Image.open(ROOT/record['registered_pose_file']).convert('RGBA')
out=Image.new('RGB',(2048,820),(23,36,49));out.paste(h.matte(source),(0,52));out.paste(h.matte(new),(1024,52))
d=ImageDraw.Draw(out);d.text((16,10),'ORIGINAL CNDRGN G0 F2 | pose authority',fill='white')
d.text((1040,10),'FINAL SELECTED P002: A06 FAR-WING REPAIR',fill='white')
d.text((1040,28),'full-p002-a06-far-wing.png | baseline y423 | fixed source calibration',fill='white')
path=BASE/'contacts/full-review/bone_dragon_p002-SELECTED-A06.png';out.save(path)
proof={'pose_id':'bone_dragon_p002','selected_attempt':'full-p002-a06-far-wing',
 'raw_source':record['raw_source'],'raw_sha256':record['raw_sha256'],'registered_pose':record['registered_pose_file'],
 'registered_pose_sha256':record['registered_pose_sha256'],'comparison':path.relative_to(ROOT).as_posix(),
 'comparison_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'source_near_far_tip_y_approx':[187,191],
 'candidate_near_far_tip_y_approx':[186,195],'feet_baseline_y':423,
 'worker_original_low_sweep_defect_repaired':True,
 'parent_original_wing_concern_resolved':True,
 'parent_confirmed_registered_sha256':'6ce2514eb8e4a25997ada878085dcdbe3efd781f6c5d81494745e0fb99a4f0f3',
 'parent_statement':'Original p002 low/shallow wing-sweep concern resolved for selected A06; no additional p002 redraw needed. Separate remaining issues and whole-creature review are not cleared.',
 'parent_motion_acceptance':False}
(Path(__file__).resolve().parent/'selected-p002-repair.json').write_text(json.dumps(proof,indent=2)+'\n',encoding='utf-8')
print(json.dumps(proof,indent=2))
