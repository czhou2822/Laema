"""Make a bounded isolated game copy for art-only integration; never alter source."""
from pathlib import Path
import shutil,json,hashlib,re,subprocess
ROOT=Path(__file__).parent
REPO=ROOT.parents[2]
DEST=ROOT/'gameplay-preview'
assert DEST.resolve().is_relative_to(ROOT.resolve())
if DEST.exists():raise SystemExit('Integration destination exists: inspect it before reuse; refusing overwrite.')
DEST.mkdir()
copied=[]
for name in ['addons','scenes','scripts','config','assets','ai']:
    shutil.copytree(REPO/name,DEST/name,ignore=shutil.ignore_patterns('.godot','__pycache__'))
for name in ['project.godot','icon.svg']:
    shutil.copy2(REPO/name,DEST/name)
for path in list(DEST.rglob('*')):
    if path.is_file() and path.suffix in ['.gd','.tscn','.tres','.godot','.gdextension']:
        for rel in re.findall(r'res://([^"\n]+)',path.read_text(encoding='utf-8',errors='replace')):
            candidate=REPO/rel
            target=DEST/rel
            if candidate.is_file() and not target.exists() and candidate.resolve().is_relative_to(REPO.resolve()):
                target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(candidate,target)
records=[]
for name in ['scripts','scenes','config','assets','ai','addons']:
    for path in sorted((DEST/name).rglob('*')):
        if path.is_file():records.append({'path':path.relative_to(DEST).as_posix(),'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
manifest={'kind':'isolated source copy before artwork-only patch','source_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),'copied_files':records,'gameplay_patch_policy':'Only Sprite texture and frame-rectangle keys may change in two copied native animations; code, settings, queries, markers, body, lunge and launch anchor stay exact.'}
(ROOT/'evidence/gameplay-source-copy.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print(f'Copied {len(records)} files into the isolated game project; original working tree untouched.')
