"""First-output local model survey using the reusable localhost ComfyUI backend."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import time
import urllib.error
import urllib.request
from PIL import Image

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
STUDIO=ROOT/"Research AI Art Pipeline for Laema/ComfyUI-Laema"
URL="http://127.0.0.1:8188"
CACHE=Path(os.environ["LAEMA_AI_CACHE"])
METHODS=["qwen","flux-base","flux-fast","longcat","z-image"]
DESCRIPTION=("Laema is the same young adult woman with a curious alert expression, platinum-white high ponytail, "
    "fitted blue sleeveless waistcoat, cream rolled-sleeve shirt, red waist sash, brown leather cross-body "
    "strap and pouch, brown trousers, fingerless gloves and tall brown boots. Her hammer has a broad "
    "double-ended geometric head, dark inset panels, steel plates, bronze faceted fittings and narrow "
    "orange-red luminous seams. Render confident painted shapes, fine modeled-volume shading, convincing "
    "cloth/leather/metal separation, clear anatomy and expressive facial drawing. Use restrained base colors "
    "and concentrated metal highlights, without coarse pixel blocks or plastic-looking skin. ")
COMPOSITION=("Create one finished original fantasy game character illustration. Show a single full-body figure "
    "on a plain medium neutral-gray background, soft upper-left lighting and a subtle contact shadow. "
    "Portrait 2:3 canvas, 1024 by 1536 pixels. Keep the whole ponytail, both hands, both boots and the complete "
    "hammer comfortably inside the frame. No text, labels, border, extra person, new equipment, scenery, "
    "attack effects or motion blur. ")
TASKS={
    "hero":"Pose: an upright three-quarter hero stance looking toward the right, feet planted naturally, shoulders relaxed, holding the hammer diagonally across the front of her body with two anatomically clear hands on the shaft. Make a fresh finished illustration while retaining the supplied design.",
    "action":"Pose: an original grounded combat anticipation pose facing right in three-quarter view, knees bent, weight supported over the rear leg, front foot stepping right. Both hands grip separated positions on the shaft; the hammer is held low in front, ready to swing. Keep the face readable and separate the limbs and hammer in silhouette. Make a new pose rather than copying the reference's standing pose. Avoid extreme foreshortening."
}


def save(path,value):
    path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text(json.dumps(value,indent=2,ensure_ascii=False),encoding="utf-8")


def sha(path):
    with path.open("rb") as handle:return hashlib.file_digest(handle,"sha256").hexdigest()


def api(path,data=None):
    body=json.dumps(data).encode() if data is not None else None
    req=urllib.request.Request(URL+path,data=body,headers={"Content-Type":"application/json"})
    try:
        with urllib.request.urlopen(req,timeout=60) as response:
            body=response.read()
            return json.loads(body) if body else None
    except urllib.error.HTTPError as error:raise RuntimeError(error.read().decode()) from error


def prompt(task,method):
    role="The supplied reference image is the authority for Laema's identity, costume and hammer construction. " if method!="z-image" else "This is text-only generation; no reference image is supplied. "
    return role+DESCRIPTION+COMPOSITION+TASKS[task]


def base_nodes(method,task):
    return {
        "4":{"class_type":"LoadImage","inputs":{"image":"02-laema-hammer.png"}},
        "10":{"class_type":"EmptySD3LatentImage","inputs":{"width":1024,"height":1536,"batch_size":1}},
        "13":{"class_type":"SaveImage","inputs":{"images":["19",0],"filename_prefix":f"Survey/{method}/{task}"}},
    }


def graph(method,task):
    if method=="qwen":
        original=ROOT/"Research AI Art Pipeline for Laema/local-trials/2026-10-23-local-vs-imagegen-v01/local/workflows/hero.api.json"
        g=json.loads(original.read_text(encoding="utf-8"))
        del g["5"]
        g["4"]["inputs"]["image"]="02-laema-hammer.png"
        for key in ("6","7"):g[key]["inputs"].pop("image2",None)
        g["6"]["inputs"]["prompt"]=prompt(task,method)
        g["13"]["inputs"]["filename_prefix"]=f"Survey/{method}/{task}"
        return g
    g=base_nodes(method,task)
    if method.startswith("flux"):
        fast=method=="flux-fast"
        g.update({
            "1":{"class_type":"UNETLoader","inputs":{"unet_name":"flux-2-klein-4b-fp8.safetensors" if fast else "flux-2-klein-base-4b-fp8.safetensors","weight_dtype":"default"}},
            "2":{"class_type":"CLIPLoader","inputs":{"clip_name":"qwen_3_4b.safetensors","type":"flux2","device":"default"}},
            "3":{"class_type":"VAELoader","inputs":{"vae_name":"flux2-vae.safetensors"}},
            "6":{"class_type":"CLIPTextEncode","inputs":{"clip":["2",0],"text":prompt(task,method)}},
            "7":{"class_type":"CLIPTextEncode","inputs":{"clip":["2",0],"text":""}},
            "8":{"class_type":"ImageScaleToTotalPixels","inputs":{"image":["4",0],"upscale_method":"nearest-exact","megapixels":1.0,"resolution_steps":1}},
            "9":{"class_type":"VAEEncode","inputs":{"pixels":["8",0],"vae":["3",0]}},
            "14":{"class_type":"ReferenceLatent","inputs":{"conditioning":["6",0],"latent":["9",0]}},
            "15":{"class_type":"ReferenceLatent","inputs":{"conditioning":["7",0],"latent":["9",0]}},
            "11":{"class_type":"CFGGuider","inputs":{"model":["1",0],"positive":["14",0],"negative":["15",0],"cfg":1.0 if fast else 5.0}},
            "12":{"class_type":"KSamplerSelect","inputs":{"sampler_name":"euler"}},
            "16":{"class_type":"Flux2Scheduler","inputs":{"steps":4 if fast else 20,"width":1024,"height":1536}},
            "17":{"class_type":"RandomNoise","inputs":{"noise_seed":42}},
            "18":{"class_type":"SamplerCustomAdvanced","inputs":{"noise":["17",0],"guider":["11",0],"sampler":["12",0],"sigmas":["16",0],"latent_image":["10",0]}},
            "19":{"class_type":"VAEDecode","inputs":{"samples":["18",0],"vae":["3",0]}},
        })
        g["10"]["class_type"]="EmptyFlux2LatentImage"
    elif method=="longcat":
        g.update({
            "1":{"class_type":"UNETLoader","inputs":{"unet_name":"longcat_image_edit_bf16.safetensors","weight_dtype":"default"}},
            "2":{"class_type":"CLIPLoader","inputs":{"clip_name":"qwen_2.5_vl_7b_fp8_scaled.safetensors","type":"longcat_image","device":"default"}},
            "3":{"class_type":"VAELoader","inputs":{"vae_name":"ae.safetensors"}},
            "6":{"class_type":"TextEncodeQwenImageEdit","inputs":{"clip":["2",0],"vae":["3",0],"prompt":prompt(task,method),"image":["4",0]}},
            "7":{"class_type":"TextEncodeQwenImageEdit","inputs":{"clip":["2",0],"vae":["3",0],"prompt":"","image":["4",0]}},
            "8":{"class_type":"FluxGuidance","inputs":{"conditioning":["6",0],"guidance":4.5}},
            "9":{"class_type":"FluxGuidance","inputs":{"conditioning":["7",0],"guidance":4.5}},
            "14":{"class_type":"FluxKontextMultiReferenceLatentMethod","inputs":{"conditioning":["8",0],"reference_latents_method":"index"}},
            "15":{"class_type":"FluxKontextMultiReferenceLatentMethod","inputs":{"conditioning":["9",0],"reference_latents_method":"index"}},
            "11":{"class_type":"KSampler","inputs":{"model":["1",0],"positive":["14",0],"negative":["15",0],"latent_image":["10",0],"seed":42,"steps":50,"cfg":4.5,"sampler_name":"euler","scheduler":"simple","denoise":1.0}},
            "19":{"class_type":"VAEDecode","inputs":{"samples":["11",0],"vae":["3",0]}},
        })
    elif method=="z-image":
        del g["4"]
        g.update({
            "1":{"class_type":"UNETLoader","inputs":{"unet_name":"z_image_turbo_bf16.safetensors","weight_dtype":"default"}},
            "2":{"class_type":"CLIPLoader","inputs":{"clip_name":"qwen_3_4b.safetensors","type":"lumina2","device":"default"}},
            "3":{"class_type":"VAELoader","inputs":{"vae_name":"ae.safetensors"}},
            "6":{"class_type":"CLIPTextEncode","inputs":{"clip":["2",0],"text":prompt(task,method)}},
            "7":{"class_type":"ConditioningZeroOut","inputs":{"conditioning":["6",0]}},
            "8":{"class_type":"ModelSamplingAuraFlow","inputs":{"model":["1",0],"shift":3.0}},
            "11":{"class_type":"KSampler","inputs":{"model":["8",0],"positive":["6",0],"negative":["7",0],"latent_image":["10",0],"seed":42,"steps":8,"cfg":1.0,"sampler_name":"res_multistep","scheduler":"simple","denoise":1.0}},
            "19":{"class_type":"VAEDecode","inputs":{"samples":["11",0],"vae":["3",0]}},
        })
    return g


def prepare():
    target=HERE/"inputs/reference.png"
    target.parent.mkdir(exist_ok=True)
    if not target.exists():shutil.copy2(STUDIO/"references/02-laema-hammer.png",target)
    save(HERE/"reference.json",{"file":"inputs/reference.png","sha256":sha(target),"source":"docs/art/references/2026-10-19-laema-hammer-accepted/01-laema-hammer-hero.png","approval":"accepted for preservation; not a final weapon lock"})
    save(HERE/"prompts.json",{task:{method:prompt(task,method) for method in METHODS} for task in TASKS})
    save(HERE/"experiment-plan.json",{
        "planned_before_generation":True,"methods":METHODS,"tasks":list(TASKS),"outputs_per_task_per_method":1,
        "primary_track":"qwen, flux-base, flux-fast, longcat: identical single approved hero reference, identical submitted positive prompt, requested1024x1536, seed42. Single reference enables direct native LongCat comparison.",
        "secondary_track":"z-image: text-only; receives the same written character/pose description but no image. Its identity fidelity is not compared as equivalent reference conditioning.",
        "native_sampling":"Qwen40steps CFG4; FLUX base20steps CFG5; FLUX fast4steps CFG1; LongCat50steps CFG4.5; ZImage8steps CFG1. Native model samplers/schedules are recorded in each graph.",
        "reference_processing":"Qwen/LongCat use native vision/text conditioning and VAE references; Flux reference image uses official1MP preprocessing. LongCat uses a fresh output latent at the shared target size. Full Flux2 VAE used for both Flux variants; current base template's small-decoder optimization is not used.",
        "selection":"First completed result per cell. No artistic rerolls, retouching or selection. Resource failures recorded separately. No hosted image-generation calls.",
        "limits":"New single-reference round; previous two-reference Qwen/built-in results are separate historical evidence. First-pass workflow comparison, not statistical ranking or production acceptance.",
    })
    for method in METHODS:
        for task in TASKS:save(HERE/method/"workflows"/(task+".api.json"),graph(method,task))
    print("Survey plan, shared prompts and ten API graphs prepared.",flush=True)


def model_files(method):
    g=graph(method,"hero")
    for node in g.values():
        kind=node["class_type"];data=node["inputs"]
        if kind=="UNETLoader":yield CACHE/".models/diffusion_models"/data["unet_name"]
        elif kind=="CLIPLoader":yield CACHE/".models/text_encoders"/data["clip_name"]
        elif kind=="VAELoader":yield CACHE/".models/vae"/data["vae_name"]


def run(methods):
    for method in methods:
        began=time.monotonic()
        while not all(p.is_file() for p in model_files(method)):
            print("WAITING for verified model files: "+method,flush=True)
            time.sleep(30)
        definitions=api("/object_info")
        for task in TASKS:
            output=HERE/method/"raw"/(task+".png")
            record=output.with_suffix(".json")
            if output.exists() or record.exists():print("SKIP existing "+method+"/"+task,flush=True);continue
            g=graph(method,task)
            for node in g.values():
                if node["class_type"] not in definitions:raise RuntimeError("Missing node: "+node["class_type"])
            save(HERE/method/"workflows/node-definitions.json",{n["class_type"]:definitions[n["class_type"]] for n in g.values()})
            started=time.monotonic();utc=datetime.datetime.now(datetime.timezone.utc).isoformat()
            response=api("/prompt",{"prompt":g,"client_id":"laema-local-model-survey-v01"})
            prompt_id=response["prompt_id"]
            save(HERE/method/(task+"-submission.json"),{"prompt_id":prompt_id,"started_utc":utc,"response":response})
            print("START "+method+"/"+task+" "+prompt_id,flush=True)
            samples=[];last=started
            while True:
                history=api("/history/"+prompt_id)
                gpu=subprocess.check_output(["nvidia-smi","--query-gpu=memory.used,utilization.gpu","--format=csv,noheader,nounits"],text=True).strip()
                samples.append({"elapsed_seconds":round(time.monotonic()-started,2),"whole_gpu_memory_mib_util_percent":gpu})
                if prompt_id in history:
                    result=history[prompt_id]
                    if result["status"]["status_str"]!="success":
                        save(HERE/method/"attempts"/(task+"-failed.json"),{"status":"failed","history":result,"seconds":time.monotonic()-started,"gpu_samples":samples})
                        print("FAILED "+method+"/"+task,flush=True);break
                    item=result["outputs"]["13"]["images"][0]
                    source=STUDIO/"output"/item["subfolder"]/item["filename"]
                    output.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(source,output)
                    with Image.open(output) as image:dimensions=list(image.size);mode=image.mode
                    save(record,{"status":"executed","method":method,"task":task,"started_utc":utc,"submission_to_save_seconds":round(time.monotonic()-started,3),"dimensions":dimensions,"mode":mode,"raw_sha256":sha(output),"reference_input_count":0 if method=="z-image" else 1,"reference_sha256":None if method=="z-image" else sha(HERE/"inputs/reference.png"),"history":result,"gpu_samples":samples,"manual_art_cleanup_seconds":0,"art_acceptance":"pending user review"})
                    print(f"DONE {method}/{task}: {time.monotonic()-started:.1f}s {dimensions}",flush=True);break
                if time.monotonic()-last>=30:
                    print(f"RUNNING {method}/{task}: {time.monotonic()-started:.0f}s GPU {gpu}",flush=True);last=time.monotonic()
                time.sleep(5)
        queue=api("/queue")
        if not queue.get("queue_running") and not queue.get("queue_pending"):
            api("/free",{"unload_models":True,"free_memory":True})
            time.sleep(8)


if __name__=="__main__":
    parser=argparse.ArgumentParser();parser.add_argument("action",choices=["prepare","run"]);parser.add_argument("methods",nargs="*",choices=METHODS)
    args=parser.parse_args()
    if args.action=="prepare":prepare()
    else:run(args.methods or METHODS)
