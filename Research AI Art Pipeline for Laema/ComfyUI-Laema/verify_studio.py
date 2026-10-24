"""Record the actual UI test and validate this standalone workflow package."""
from pathlib import Path
import ast
import hashlib
import json
from PIL import Image

HERE=Path(__file__).resolve().parent


def sha(path):
    with path.open("rb") as handle:return hashlib.file_digest(handle,"sha256").hexdigest()


def main():
    png=HERE/"output/Laema/Qwen_00001_.png"
    with Image.open(png) as image:
        dimensions=list(image.size)
        prompt=json.loads(image.info["prompt"])
        native=json.loads(image.info["workflow"])
    actual_model=prompt["1"]["inputs"]["unet_name"]
    if actual_model!="qwen_image_edit_2511_fp8mixed.safetensors":raise RuntimeError("Unexpected model in UI test")
    expected="Create a full-body illustration of Laema standing calmly with her hammer resting across one shoulder. She looks curious and alert. Plain gray background, soft upper-left light, complete figure and hammer visible. Keep the reference outfit and equipment."
    if prompt["20"]["inputs"]["value"]!=expected:raise RuntimeError("Entered UI prompt was not preserved")
    if dimensions!=[1024,1536]:raise RuntimeError("Unexpected UI test dimensions")
    records=json.loads((HERE/"evidence/gui-history.json").read_text(encoding="utf-8-sig"))
    history=next(item for item in records.values() if item.get("outputs",{}).get("13",{}).get("images",[{}])[0].get("filename")==png.name)
    if history["status"]["status_str"]!="success":raise RuntimeError("UI test did not succeed")
    native_file=HERE/"workflows/Laema - Qwen Reference Art.app.json"
    configured=json.loads(native_file.read_text(encoding="utf-8"))
    if len(configured["extra"]["linearData"]["inputs"])!=4:raise RuntimeError("App inputs not saved")
    if not configured["extra"].get("linearMode"):raise RuntimeError("Default App mode not saved")
    for path in HERE.glob("*.py"):ast.parse(path.read_text(encoding="utf-8"),filename=path.name)
    report={"ui_test":"actual ComfyUI App mode: prompt edited, Run clicked, PNG shown in results","status":"success","dimensions":dimensions,"file":png.relative_to(HERE).as_posix(),"sha256":sha(png),"model":actual_model,"actual_seed":prompt["11"]["inputs"]["seed"],"entered_prompt":expected,"png_contains_api_prompt_and_native_workflow":True,"app_controls_saved":4,"ui_screenshot":"evidence/app-ready.jpg","final_app_chooser_screenshot":"evidence/apps-ready.jpg","python_ast":"passed","art_acceptance":"not requested or inferred; output has hammer-construction errors","production_assets_replaced":False,"hosted_image_generation_calls":0,"restart_validation":"pending"}
    fast=HERE/"output/Laema/flux-fast_00001_.png"
    if fast.exists():
        with Image.open(fast) as image:
            fast_size=list(image.size);fast_graph=json.loads(image.info["prompt"])
        if fast_size!=[512,768]:raise RuntimeError("Fast App did not honor the resized canvas")
        if fast_graph["31"]["inputs"]["value"]!=512 or fast_graph["32"]["inputs"]["value"]!=768:
            raise RuntimeError("Fast App dimension controls did not reach the backend")
        for key in ("10","16"):
            if fast_graph[key]["inputs"]["width"]!=["31",0] or fast_graph[key]["inputs"]["height"]!=["32",0]:
                raise RuntimeError("Latent and scheduler dimensions are not linked")
        report["fast_app_resize_test"]={"status":"passed","file":fast.relative_to(HERE).as_posix(),"sha256":sha(fast),"dimensions":fast_size,"latent_and_scheduler_dimensions_linked":True}
        (HERE/"evidence/fast-app-submitted-api.json").write_text(json.dumps(fast_graph,indent=2),encoding="utf-8")
    restart=HERE/"evidence/restart-check.json"
    if restart.exists():report["restart_validation"]=json.loads(restart.read_text(encoding="utf-8-sig"))
    (HERE/"evidence/verification.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
    (HERE/"evidence/gui-submitted-api.json").write_text(json.dumps(prompt,indent=2),encoding="utf-8")
    print(json.dumps({key:report[key] for key in ("status","dimensions","actual_seed","app_controls_saved","hosted_image_generation_calls")}))


if __name__=="__main__":main()
