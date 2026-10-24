"""Read public official workflow/model metadata; no weight downloads or gated access."""
from pathlib import Path
import hashlib
import json
import re
import urllib.request

HERE=Path(__file__).resolve().parent


def fetch(url):
    req=urllib.request.Request(url,headers={"User-Agent":"Laema-local-art-research"})
    with urllib.request.urlopen(req,timeout=60) as response:return response.read()


def objects(value):
    if isinstance(value,dict):
        yield value
        for item in value.values():yield from objects(item)
    elif isinstance(value,list):
        for item in value:yield from objects(item)


def main():
    HERE.mkdir(parents=True,exist_ok=True)
    tree=json.loads(fetch("https://api.github.com/repos/Comfy-Org/workflow_templates/git/trees/main?recursive=1"))
    candidates=[]
    for item in tree["tree"]:
        name=item["path"].lower()
        if name.endswith(".json") and name.startswith("templates/") and (
            ("klein" in name and ("4b" in name or "flux3" in name or "flux_3" in name)) or
            ("longcat" in name) or ("z_image_turbo" in name and "control" not in name)):
            candidates.append(item["path"])
    entries=[]
    for path in candidates:
        data=fetch("https://raw.githubusercontent.com/Comfy-Org/workflow_templates/"+tree["sha"]+"/"+path)
        target=HERE/"official-templates"/Path(path).name
        target.parent.mkdir(exist_ok=True)
        target.write_bytes(data)
        workflow=json.loads(data)
        models=[]
        for obj in objects(workflow):
            if isinstance(obj.get("models"),list):
                for model in obj["models"]:
                    if isinstance(model,dict) and model.get("url") and model not in models:models.append(model)
        entries.append({"file":path,"local":target.relative_to(HERE).as_posix(),"sha256":hashlib.sha256(data).hexdigest(),"models":models})
    manifest={"repository":"Comfy-Org/workflow_templates","revision":tree["sha"],"templates":entries}
    (HERE/"official-source-index.json").write_text(json.dumps(manifest,indent=2),encoding="utf-8")
    for item in entries:
        print(json.dumps({"file":item["file"],"models":[{"name":m.get("name"),"url":m["url"]} for m in item["models"]]}),flush=True)


if __name__=="__main__":main()
