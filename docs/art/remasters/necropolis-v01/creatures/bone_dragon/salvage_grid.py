"""Reuse complete guide-assigned figures by exact clear-gutter crops, never paint."""
import argparse
import hashlib
import importlib.util
import json
import subprocess
import sys
from pathlib import Path
from PIL import Image

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
ASSET = ROOT / 'assets/prototype/enemy/bone_dragon/remaster_v01'
spec = importlib.util.spec_from_file_location('remaster_readonly', ROOT/'tools/art/necropolis_remaster.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
parser=argparse.ArgumentParser()
parser.add_argument('batch_number')
parser.add_argument('--skip', default='')
args=parser.parse_args()
n=args.batch_number
skip=set(filter(None,args.skip.split(',')))
guide=json.loads((ASSET/'_source/guides'/('batch-'+n+'.json')).read_text(encoding='utf-8'))
raw_path=ASSET/'_source/raw'/('full-batch-'+n+'-a01.png')
raw=Image.open(raw_path).convert('RGBA')
xs=helper.boundaries(raw,guide['columns'],0,True)
ys=helper.boundaries(raw,guide['rows'],1,True)
dest=ASSET/'_source/derived'/('batch-'+n)
dest.mkdir(parents=True,exist_ok=True)
records=[]
for i,pid in enumerate(guide['pose_ids']):
    c=i%guide['columns'];r=i//guide['columns']
    rect=[xs[c],ys[r],xs[c+1]-xs[c],ys[r+1]-ys[r]]
    cell=helper.crop(raw,rect)
    bb=helper.bbox(cell,16)
    complete=bool(bb) and bb[0]>1 and bb[1]>1 and bb[2]<cell.width-1 and bb[3]<cell.height-1
    fp=dest/(pid+'.png')
    if fp.exists():
        raise RuntimeError('Refusing to overwrite previous derivative '+str(fp))
    cell.save(fp)
    rec={'pose_id':pid,'verbatim_page':raw_path.relative_to(ROOT).as_posix(),
         'verbatim_page_sha256':helper.sha(raw_path),'exact_clear_gutter_crop':rect,
         'derivative':fp.relative_to(ROOT).as_posix(),'derivative_sha256':helper.sha(fp),
         'passes_unchanged_clipping_check':complete,'skipped_for_visual_repair':pid in skip}
    if complete and pid not in skip:
        cmd=[sys.executable,str(ROOT/'tools/art/necropolis_remaster.py'),'ingest','bone_dragon',str(fp),
            '--pose-ids',pid,'--cols','1','--rows','1','--batch','full-batch-'+n+'-cell-'+pid+'-a01',
            '--prompt-file',str(ASSET/'_source/prompts'/('full-batch-'+n+'-a01.prompt.txt')),'--adaptive-grid']
        result=subprocess.run(cmd,capture_output=True,text=True)
        rec['ingested']=result.returncode==0
        rec['helper_output']=result.stdout if result.returncode==0 else result.stderr
    else:
        rec['ingested']=False
    records.append(rec)
out={'batch':n,'method':'Exact crops at the unchanged helper transparent-gutter boundaries. No padding, painting, clipping or rescaling.',
     'records':records}
(dest/'crop-provenance.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
print(json.dumps(out,indent=2))
