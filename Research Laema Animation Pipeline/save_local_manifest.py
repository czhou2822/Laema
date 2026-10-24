"""Inventory merged R&D continuity; never stages, commits or changes product files."""
from pathlib import Path
import hashlib,json,subprocess
ROOT=Path(__file__).parent
protected=['scenes','scripts','config','assets','project.godot','docs/GAME_DESIGN.md','docs/TECH_ARCHITECTURE.md','docs/IMPLEMENTATION_STATUS.md']
changed=subprocess.check_output(['git','diff','--name-only','--',*protected],cwd=ROOT.parent,text=True).splitlines()
assert not changed,changed
data=ROOT/'study-data.json'
assert hashlib.sha256(data.read_bytes()).hexdigest()=='b19776e41fd6fec613c208c145e07b4345581c53eef3e54224f84280b676667d'
record_path=ROOT/'evidence/round-record.json'
record=json.loads(record_path.read_text())
feedback=ROOT/'trials/2026-10-23-A-v01/user-feedback.json'
if feedback.exists():record.setdefault('human_visual_feedback',json.loads(feedback.read_text()))
record.setdefault('awaiting_user','Visual review; no production-art or gameplay approval inferred.')
record['gameplay_changes']=False
record_path.write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8',newline='\n')
files=[]
for p in sorted(ROOT.rglob('*')):
    if p.is_file() and not set(p.parts)&{'.godot','__pycache__','captures','captures-v03'} and p.name!='artifact-manifest.json':
        files.append({'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
manifest={'kind':'current reconciled local/cloud R&D inventory; not original cloud manifest or project checkpoint','source_data_sha256':hashlib.sha256(data.read_bytes()).hexdigest(),'product_protected_diff_paths':changed,'cloud_publication_revision':'3fd153b68f2666059bb768f90ff0898fc7f74120','original_cloud_snapshot':'history/cloud-publication-3fd153b6','excluded_inventory':'Derived PNG capture folders, engine caches and artifact-manifest.json files are excluded; originals remain preserved. Compressed review media and restored cloud files are included.','files':files}
(ROOT/'artifact-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Local inventory saved; protected product/canonical paths unchanged; exact original motion data verified.')
