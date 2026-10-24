"""Isolate temporary ranges touched during the interrupted duplicate restart."""
from pathlib import Path
import datetime
import json
import os

HERE=Path(__file__).resolve().parent
CACHE=Path(os.environ["LAEMA_AI_CACHE"]).resolve()
MODELS=(CACHE/".models").resolve()
QUARANTINE=(CACHE/".runtime/survey-download-quarantine").resolve()
# Conservative cutoff predates the downloader restart; source edit time was
# 12:22 UTC. All temporary ranges touched from then until the stop are isolated.
CUTOFF=datetime.datetime(2026,10,23,12,21,0,tzinfo=datetime.timezone.utc).timestamp()
records=[]
for chunk_dir in MODELS.glob("*/*.safetensors.chunks"):
    for path in chunk_dir.glob("*.bin"):
        if path.stat().st_mtime<CUTOFF:continue
        source=path.resolve()
        target=(QUARANTINE/chunk_dir.name/path.name).resolve()
        if not source.is_relative_to(MODELS) or not target.is_relative_to(QUARANTINE):
            raise RuntimeError("Temporary range escaped its verified cache roots")
        target.parent.mkdir(parents=True,exist_ok=True)
        if target.exists():raise RuntimeError("Quarantine entry already exists")
        records.append({"model":chunk_dir.name,"range":path.name,"bytes":path.stat().st_size})
        source.rename(target)
report={"cutoff_utc":"2026-10-23T12:21:00Z","range_count":len(records),"bytes":sum(r["bytes"] for r in records),"records":records,"model_weights_removed":False}
(HERE/"download-quarantine.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
print(json.dumps({"quarantined_ranges":len(records),"bytes":report["bytes"]}))
