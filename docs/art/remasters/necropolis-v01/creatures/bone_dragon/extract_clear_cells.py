"""Exact whole-cell reuse with wide verified gutters, no component deletion."""
import argparse
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from PIL import Image

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[6]
BASE=ROOT/'assets/prototype/enemy/bone_dragon/remaster_v01'
spec=importlib.util.spec_from_file_location('remaster_readonly',ROOT/'tools/art/necropolis_remaster.py')
h=importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
parser=argparse.ArgumentParser()
parser.add_argument('--raw',required=True)
parser.add_argument('--guide',required=True)
parser.add_argument('--batch',required=True)
parser.add_argument('--prompt',required=True)
a=parser.parse_args()
raw_path=ROOT/a.raw
im=Image.open(raw_path).convert('RGBA')
g=json.loads((ROOT/a.guide).read_text(encoding='utf-8'))
alpha=im.getchannel('A').point(lambda v:255 if v>8 else 0)

def cuts(n,axis):
    length=im.width if axis==0 else im.height
    out=[0]
    for i in range(1,n):
        center=round(length*i/n)
        radius=round(length/n*.18)
        options=sorted(range(max(6,center-radius),min(length-6,center+radius)+1),key=lambda x:abs(x-center))
        good=[q for q in options if alpha.crop((q-5,0,q+5,im.height) if axis==0 else (0,q-5,im.width,q+5)).getbbox() is None]
        if not good:raise ValueError('No verified wide transparent gutter: no guessing')
        out.append(good[0])
    return out+[length]

xs=cuts(g['columns'],0);ys=cuts(g['rows'],1)
dest=BASE/'_source/derived'/a.batch
dest.mkdir(parents=True,exist_ok=True)
records=[]
for i,pid in enumerate(g['pose_ids']):
    col=i%g['columns'];row=i//g['columns']
    rect=[xs[col],ys[row],xs[col+1]-xs[col],ys[row+1]-ys[row]]
    fp=dest/(pid+'.png')
    if fp.exists():raise RuntimeError('Derivative already exists; preserve attempt')
    h.crop(im,rect).save(fp)
    result=subprocess.run([sys.executable,str(ROOT/'tools/art/necropolis_remaster.py'),'ingest','bone_dragon',str(fp),
        '--pose-ids',pid,'--cols','1','--rows','1','--batch',a.batch+'-'+pid,'--prompt-file',a.prompt,'--adaptive-grid'],capture_output=True,text=True)
    records.append({'pose_id':pid,'page_sha256':h.sha(raw_path),'exact_crop':rect,'derivative':fp.relative_to(ROOT).as_posix(),
        'derivative_sha256':h.sha(fp),'ingested':result.returncode==0,'helper_output':result.stdout if result.returncode==0 else result.stderr})
report={'source':a.raw,'method':'Exact complete-cell crop; 10px bands verified alpha<=8; all detached pieces retained; unchanged helper clipping/registration checks',
    'x_cuts':xs,'y_cuts':ys,'records':records}
(dest/'crop-provenance.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps(report,indent=2))
