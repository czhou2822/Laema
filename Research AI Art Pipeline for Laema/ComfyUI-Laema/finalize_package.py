"""Finalize evidence formats and hash the delivered workflow package."""
from pathlib import Path
import hashlib
import json
import subprocess
import sys
from PIL import Image

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
old=HERE/"evidence/app-ready.png"
if old.exists():
    with Image.open(old) as image:kind=image.format
    if kind!="JPEG":raise RuntimeError("Unexpected initial screenshot encoding")
    target=HERE/"evidence/app-ready.jpg"
    if old.resolve().parent!=(HERE/"evidence").resolve() or target.exists():raise RuntimeError("Unexpected screenshot rename target")
    old.rename(target)
subprocess.run([sys.executable,str(HERE/"verify_studio.py")],check=True)


def manifest(folder,exclusions):
    records=[]
    for path in sorted(folder.rglob("*")):
        if not path.is_file():continue
        rel=path.relative_to(folder)
        if any(part in {"__pycache__","logs"} for part in rel.parts):continue
        if path.name in exclusions or path.name.endswith(".lock"):continue
        if rel.parts[0]=="user" and "workflows" not in rel.parts:continue
        if rel.parts[0]=="user" and path.name.startswith("."):continue
        with path.open("rb") as handle:digest=hashlib.file_digest(handle,"sha256").hexdigest()
        records.append({"path":rel.as_posix(),"bytes":path.stat().st_size,"sha256":digest})
    payload={"files":records,"total_bytes":sum(item["bytes"] for item in records),"excludes":sorted(exclusions)}
    (folder/"artifact-manifest.json").write_text(json.dumps(payload,indent=2),encoding="utf-8")
    return {"files":len(records),"bytes":payload["total_bytes"]}


launchers=[]
for name in ("Start-Laema-Art.cmd","Stop-Laema-Art.cmd"):
    path=ROOT/name
    with path.open("rb") as handle:digest=hashlib.file_digest(handle,"sha256").hexdigest()
    launchers.append({"path":name,"sha256":digest})
(HERE/"evidence/root-launcher-hashes.json").write_text(json.dumps(launchers,indent=2),encoding="utf-8")
bundle=manifest(HERE,{"artifact-manifest.json","config.local.json","model-paths.local.yaml","server.local.json"})
survey=ROOT/"Research AI Art Pipeline for Laema/local-trials/2026-10-23-local-model-survey-v01"
research=manifest(survey,{"artifact-manifest.json","model-download-lock.local.json"})
print(json.dumps({"workflow_package":bundle,"model_survey":research}))
