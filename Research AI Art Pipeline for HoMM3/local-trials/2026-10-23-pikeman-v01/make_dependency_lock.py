from pathlib import Path
from importlib.metadata import distribution
from packaging.requirements import Requirement
from packaging.utils import canonicalize_name
HERE=Path(__file__).resolve().parent
pending=[]
for line in (HERE/'runtime-requirements.txt').read_text().splitlines():
    if line.strip() and not line.lstrip().startswith('#'):pending.append(Requirement(line).name)
seen={}
while pending:
    name=pending.pop();key=canonicalize_name(name)
    if key in seen:continue
    d=distribution(name);seen[key]=d.version
    for line in d.requires or []:
        r=Requirement(line)
        if r.marker is None or r.marker.evaluate():pending.append(r.name)
(HERE/'requirements-inference-lock.txt').write_text('\n'.join(f'{k}=={v}' for k,v in sorted(seen.items()))+'\n')
print('Locked inference packages:',len(seen))
