"""Set the official app-mode flags on this setup's five saved app files."""
from pathlib import Path
import json

HERE=Path(__file__).resolve().parent
records=[]
for folder in (HERE/"workflows",HERE/"user/default/workflows"):
    for path in folder.glob("Laema - *.app.json"):
        data=json.loads(path.read_text(encoding="utf-8"))
        data["extra"].update(linearMode=True,workflowRendererVersion="Vue",frontendVersion="1.57.1")
        for node in data["nodes"]:
            if node["type"]=="PrimitiveInt":
                if len(node.get("widgets_values",[]))>1:node["widgets_values"][1]="fixed"
                if "control_after_generate" in node.get("widgets_values_named",{}):
                    node["widgets_values_named"]["control_after_generate"]="fixed"
        for entry in data["extra"]["linearData"]["inputs"]:
            if not entry[0].startswith(data["id"]+":"):
                raise RuntimeError("Input identifier mismatch: "+path.name)
        path.write_text(json.dumps(data,indent=2),encoding="utf-8")
        records.append(path.relative_to(HERE).as_posix())
(HERE/"evidence/app-defaults.json").write_text(json.dumps({"app_files":records,"linearMode":True,"workflowRendererVersion":"Vue","source":"official ComfyUI app template extra flags; installed frontend1.57.1"},indent=2),encoding="utf-8")
print(json.dumps({"app_files_updated":len(records)}))
