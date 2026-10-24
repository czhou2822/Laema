"""Stop only this directory's model downloader before a controlled resume."""
from pathlib import Path
import datetime
import json
import psutil

HERE=Path(__file__).resolve().parent
stopped=[]
for process in psutil.process_iter(["pid","name"]):
    try:
        if process.info["name"].lower()!="python.exe":continue
        if not any(Path(part).name=="prepare_models.py" for part in process.cmdline()):continue
        if Path(process.cwd()).resolve()!=HERE:continue
        process.terminate()
        process.wait(timeout=15)
        stopped.append(process.pid)
    except (psutil.NoSuchProcess,psutil.AccessDenied):
        continue
result={"stopped_owned_download_helpers":stopped,"stopped_utc":datetime.datetime.now(datetime.timezone.utc).isoformat()}
(HERE/"download-resume.json").write_text(json.dumps(result,indent=2),encoding="utf-8")
print(json.dumps(result))
