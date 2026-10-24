from pathlib import Path
import json, hashlib, sys
import numpy as np
from PIL import Image

ROOT=Path(__file__).parent
metrics=json.loads((ROOT/'outputs/metrics.json').read_text())
if (ROOT/'user-feedback.json').exists():
    metrics['human_visual_feedback']=json.loads((ROOT/'user-feedback.json').read_text())
comparisons={}
for name,a,b in [('AI','ai-strip-attempt01.png','ai-strip-attempt02-cleanup.png'),('rig_parts','rig-parts-attempt01.png','rig-parts-attempt02-cleanup.png')]:
    x=np.array(Image.open(ROOT/'raw'/a));y=np.array(Image.open(ROOT/'raw'/b))
    m=x[:,:,3]>127;n=y[:,:,3]>127
    comparisons[name]={'alpha_iou':float((m&n).sum()/(m|n).sum()),'changed_rgba_pixels_above_8':int((np.abs(x.astype(float)-y)>8).any(axis=2).sum()),'total_pixels':int(m.size)}
metrics['targeted_edit_comparison']=comparisons
(ROOT/'outputs/metrics.json').write_text(json.dumps(metrics,indent=2)+'\n',encoding='utf-8',newline='\n')
(ROOT/'comparison.html').write_text((ROOT/'comparison.template.html').read_text(encoding='utf-8').replace('__METRICS__',json.dumps(metrics,separators=(',',':'))),encoding='utf-8',newline='\n')
capture=ROOT/'captures-v03'
for folder in capture.iterdir() if capture.exists() and '--html-only' not in sys.argv else []:
    paths=sorted(folder.glob('frame_*.png'))
    if paths:
        frames=[Image.open(p).convert('RGB') for p in paths]
        durations=[round((i+1)*1000/60)-round(i*1000/60) for i in range(len(frames))]
        frames[0].save(ROOT/(folder.name+'.webp'),save_all=True,append_images=frames[1:],duration=durations,loop=0,lossless=True,method=3)
        for f in frames:f.close()
files=[]
for p in sorted(ROOT.rglob('*')):
    if p.is_file() and '.godot' not in p.parts and 'captures' not in p.parts and '__pycache__' not in p.parts and p.name!='artifact-manifest.json':
        files.append({'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(ROOT/'artifact-manifest.json').write_text(json.dumps({'scope':'local isolated trial files only','files':files},indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'targeted_edits':comparisons,'manifest_files':len(files)},indent=2))
