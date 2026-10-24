"""Finalize the app-file format and stable input identifiers created in this setup."""
from pathlib import Path
import hashlib
import json
import uuid

HERE=Path(__file__).resolve().parent
USER=(HERE/"user/default/workflows").resolve()
PACKAGE=(HERE/"workflows").resolve()


def checked(path,root):
    resolved=path.resolve()
    if not resolved.is_relative_to(root):raise RuntimeError("Workflow path escaped its package directory")
    return resolved


def main():
    if (HERE/"evidence/app-configuration-checks.json").exists():
        print("This one-time app conversion is already complete; saved workflows were not changed.")
        return
    base="Laema - Qwen Reference Art"
    source=json.loads((USER/(base+".json")).read_text(encoding="utf-8"))
    app_path=USER/(base+".app.json")
    if app_path.exists() and not (HERE/"evidence/save-as-before-id-repair.json").exists():
        (HERE/"evidence/save-as-before-id-repair.json").write_bytes(app_path.read_bytes())
    new_id=str(uuid.uuid4())
    source["id"]=new_id
    for item in source["extra"]["linearData"]["inputs"]:
        item[0]=new_id+":"+item[0].split(":",1)[1]
    for target in (app_path,PACKAGE/(base+".app.json")):
        checked(target,USER if target.parent==USER else PACKAGE).write_text(json.dumps(source,indent=2),encoding="utf-8")
    names=["Laema - FLUX2 Base Reference Art","Laema - FLUX2 Fast Reference Art","Laema - LongCat Reference Art","Laema - Z-Image Text Only"]
    for root in (USER,PACKAGE):
        for name in names:
            old,new=checked(root/(name+".json"),root),checked(root/(name+".app.json"),root)
            if old.exists():
                if new.exists():raise RuntimeError("Both legacy and app-form workflow exist; refusing to overwrite")
                old.rename(new)
    checks=[]
    for path in sorted(PACKAGE.glob("*.app.json")):
        value=json.loads(path.read_text(encoding="utf-8"))
        fields=value["extra"]["linearData"]["inputs"]
        valid=all(item[0].startswith(value["id"]+":") for item in fields)
        if not valid:raise RuntimeError("App field identifier mismatch: "+path.name)
        checks.append({"file":path.name,"id":value["id"],"inputs":len(fields),"identifiers_match":valid})
    (HERE/"evidence/app-configuration-checks.json").write_text(json.dumps(checks,indent=2),encoding="utf-8")
    print(json.dumps({"apps":len(checks),"all_input_identifiers_match":True}))


if __name__=="__main__":main()
