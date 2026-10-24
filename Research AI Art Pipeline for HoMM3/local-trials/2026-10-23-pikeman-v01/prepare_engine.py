"""Copy only tracked engine dependencies to a disposable project, never import production."""
from pathlib import Path
import os, subprocess, shutil, hashlib, json
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]
CACHE=Path(os.environ.get('LAEMA_HOMM3_CACHE',str(HERE)))
TARGET=CACHE/'.runtime/engine-project'
paths=subprocess.check_output(['git','ls-files','-z','--','assets','addons','scripts','scenes','config','ai','project.godot','icon.svg'],cwd=REPO).decode().split('\0')
records=[]
for name in paths:
    if not name:continue
    src=REPO/name
    if not src.is_file():continue
    dst=TARGET/name;dst.parent.mkdir(exist_ok=True,parents=True)
    if not dst.exists():shutil.copy2(src,dst)
    src_sha=hashlib.file_digest(src.open('rb'),'sha256').hexdigest()
    assert hashlib.file_digest(dst.open('rb'),'sha256').hexdigest()==src_sha
    records.append({'path':name,'sha256':src_sha,'bytes':src.stat().st_size})
(HERE/'engine-source-lock.json').write_text(json.dumps({'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),'copied_project':str(TARGET),'files':records,'boundary':'Disposable copy. No production cache/import or gameplay mutation.'},indent=2),encoding='utf-8')
engine_path=os.environ.get('LAEMA_GODOT_PATH') or shutil.which('godot')
if not engine_path: raise RuntimeError('Set LAEMA_GODOT_PATH to the installed Godot executable')
engine=Path(engine_path)
with (HERE/'engine-import.log').open('w',encoding='utf-8') as log:
    p=subprocess.run([str(engine),'--headless','--editor','--import','--path',str(TARGET)],stdout=log,stderr=subprocess.STDOUT)
print(json.dumps({'copied_files':len(records),'copied_bytes':sum(x['bytes'] for x in records),'import_exit_code':p.returncode}))
