"""Pin and download ungated official model files for the requested local survey."""
from pathlib import Path
import concurrent.futures
import hashlib
import importlib.util
import json
import os
import urllib.error
import urllib.request
from filelock import FileLock

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
CACHE=Path(os.environ["LAEMA_AI_CACHE"])
CHOICES=[
    ("black-forest-labs/FLUX.2-klein-base-4b-fp8","flux-2-klein-base-4b-fp8.safetensors","diffusion_models"),
    ("black-forest-labs/FLUX.2-klein-4b-fp8","flux-2-klein-4b-fp8.safetensors","diffusion_models"),
    ("Comfy-Org/z_image_turbo","split_files/text_encoders/qwen_3_4b.safetensors","text_encoders"),
    ("Comfy-Org/flux2-dev","split_files/vae/flux2-vae.safetensors","vae"),
    ("Comfy-Org/LongCat-Image","split_files/diffusion_models/longcat_image_edit_bf16.safetensors","diffusion_models"),
    ("Comfy-Org/z_image_turbo","split_files/vae/ae.safetensors","vae"),
    ("Comfy-Org/z_image_turbo","split_files/diffusion_models/z_image_turbo_bf16.safetensors","diffusion_models"),
]


def fetch(url):
    request=urllib.request.Request(url,headers={"User-Agent":"Laema-local-art-research"})
    with urllib.request.urlopen(request,timeout=60) as response:return json.load(response)


def main():
    infos={}
    for repo in sorted({item[0] for item in CHOICES}|{"black-forest-labs/flux-3-image-klein-comfy","black-forest-labs/FLUX.2-klein-9B","black-forest-labs/FLUX.1-Kontext-dev"}):
        try:
            item=fetch("https://huggingface.co/api/models/"+repo)
            infos[repo]={"revision":item["sha"],"gated":item.get("gated"),"license":item.get("cardData",{}).get("license"),"siblings":[s["rfilename"] for s in item.get("siblings",[])]}
        except urllib.error.HTTPError as error:
            infos[repo]={"metadata_error_status":error.code}
    (HERE/"repository-access.json").write_text(json.dumps(infos,indent=2),encoding="utf-8")
    rows=[]
    for repo,file,category in CHOICES:
        info=infos[repo]
        if info.get("gated") or "metadata_error_status" in info:
            print("NOT DOWNLOADED: repository requires access or metadata unavailable: "+repo,flush=True)
            continue
        directory=file.rsplit("/",1)[0] if "/" in file else ""
        tree=fetch("https://huggingface.co/api/models/"+repo+"/tree/"+info["revision"]+("/"+directory if directory else ""))
        entry=next(item for item in tree if item.get("path")==file)
        rows.append({"repo":repo,"revision":info["revision"],"file":file,"sha256":entry["lfs"]["oid"],"bytes":entry["size"],
                     "destination":str(CACHE/".models"/category/Path(file).name),"url":"https://huggingface.co/"+repo+"/resolve/"+info["revision"]+"/"+file,
                     "license":info.get("license"),"gated":False})
    (HERE/"model-download-lock.local.json").write_text(json.dumps(rows,indent=2),encoding="utf-8")
    (HERE/"model-lock.json").write_text(json.dumps([{k:v for k,v in r.items() if k!="destination"} for r in rows],indent=2),encoding="utf-8")
    print(json.dumps({"new_files":len(rows),"bytes":sum(r["bytes"] for r in rows),"models":[{"name":Path(r["file"]).name,"GB":round(r["bytes"]/1e9,2)} for r in rows]}),flush=True)
    source=ROOT/"Research AI Art Pipeline for HoMM3/local-trials/2026-10-23-pikeman-v01/bootstrap.py"
    spec=importlib.util.spec_from_file_location("previous_download_helper",source)
    helper=importlib.util.module_from_spec(spec);spec.loader.exec_module(helper)
    for label, subset in [("FLUX models",rows[:4]),("LongCat model",rows[4:6]),("Z-Image model",rows[6:])]:
        helper.ranged_downloads(subset,workers=48)
        print(label+" READY: pinned files SHA256 verified",flush=True)
    print("ALL SELECTED MODEL HASHES VERIFIED",flush=True)


if __name__=="__main__":
    with FileLock(str(HERE/".download.lock"),timeout=0):main()
