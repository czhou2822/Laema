"""Remove only verified redundant range staging; retain all models and artwork."""
from pathlib import Path
import hashlib
import json
import os
import shutil

HERE=Path(__file__).resolve().parent
CACHE=Path(os.environ["LAEMA_AI_CACHE"]).resolve()
MODELS=(CACHE/".models").resolve()
rows=json.loads((HERE/"model-download-lock.local.json").read_text(encoding="utf-8"))
targets=[]
verified=[]
for row in rows:
    model=Path(row["destination"]).resolve()
    if not model.is_relative_to(MODELS):raise RuntimeError("Model path escaped the intended cache")
    with model.open("rb") as handle:digest=hashlib.file_digest(handle,"sha256").hexdigest()
    if digest!=row["sha256"]:raise RuntimeError("Model hash mismatch; refusing staging cleanup")
    verified.append({"name":model.name,"bytes":model.stat().st_size,"sha256":digest})
    staging=model.parent/(model.name+".chunks")
    if staging.exists():
        resolved=staging.resolve()
        if not resolved.is_relative_to(MODELS) or resolved.name!=model.name+".chunks" or resolved.parent!=model.parent:
            raise RuntimeError("Staging path escaped its verified model directory")
        targets.append(resolved)
quarantine=(CACHE/".runtime/survey-download-quarantine").resolve()
if quarantine.exists():
    if not quarantine.is_relative_to((CACHE/".runtime").resolve()) or quarantine.name!="survey-download-quarantine":
        raise RuntimeError("Unexpected quarantine path")
    targets.append(quarantine)
records=[]
for target in targets:
    files=list(target.rglob("*"))
    for item in files:
        if item.is_symlink() or (hasattr(item,"is_junction") and item.is_junction()) or not item.resolve().is_relative_to(target):
            raise RuntimeError("Unsafe link in temporary download staging")
    records.append({"path_relative_to_cache":target.relative_to(CACHE).as_posix(),"bytes":sum(item.stat().st_size for item in files if item.is_file())})
# All absolute targets and full-file model hashes are verified before deletion.
for target in targets:shutil.rmtree(target)
result={"removed_temporary_bytes":sum(r["bytes"] for r in records),"targets":records,"retained_verified_models":verified,"artwork_deleted":False}
(HERE/"cache-cleanup.json").write_text(json.dumps(result,indent=2),encoding="utf-8")
print(json.dumps({"removed_temporary_bytes":result["removed_temporary_bytes"],"model_files_kept":len(verified)}))
