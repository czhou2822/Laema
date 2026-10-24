"""Standalone local ComfyUI launcher; no OpenAI service or API dependency."""
from pathlib import Path
import argparse
import datetime
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request
import webbrowser

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
PORT = 8188
URL = f"http://127.0.0.1:{PORT}"
WORKFLOW_NAME = "Laema - Qwen Reference Art"
EXAMPLE = "Create a new full-body illustration of Laema in a relaxed, alert three-quarter stance, holding her hammer naturally. Plain gray background, soft studio lighting, complete figure and hammer visible."
GUIDE = (
    "Create an original illustration of Laema following the request below. Image 1 supplies her identity and costume. "
    "Image 2 supplies the saved hammer design when the request includes her hammer. Keep her recognizable face, "
    "platinum-white high ponytail, blue sleeveless waistcoat, cream rolled-sleeve shirt, red waist sash, brown "
    "trousers, leather strap/pouch, fingerless gloves and brown boots unless the request explicitly changes them. "
    "Render clear anatomy, convincing materials, finely modeled volumes and expressive facial drawing. "
    "No text or watermark. Follow the requested pose, framing, setting and lighting.\n\nUSER REQUEST:\n"
)


def save(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, ensure_ascii=False), encoding="utf-8")


def config():
    local = HERE / "config.local.json"
    data = json.loads(local.read_text(encoding="utf-8-sig")) if local.exists() else {}
    root = os.environ.get("LAEMA_AI_CACHE", data.get("cache_root"))
    if not root:
        raise RuntimeError("Set LAEMA_AI_CACHE or configure config.local.json; see README.md.")
    root = Path(root).resolve()
    if not (root / ".runtime/ComfyUI/main.py").is_file():
        raise RuntimeError("The configured ComfyUI installation was not found.")
    return root


def api(path, data=None):
    body = json.dumps(data).encode() if data is not None else None
    request = urllib.request.Request(URL + path, data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(request, timeout=30) as response:
        return json.load(response) if response.headers.get_content_type() == "application/json" else response.read().decode()


def ready():
    try:
        api("/system_stats")
        return True
    except (OSError, urllib.error.URLError):
        return False


def copy_references():
    refs = [
        (ROOT / "docs/art/references/2026-10-18-character-concepts/laema-r5-01-laema-open.png", "01-laema-open.png"),
        (ROOT / "docs/art/references/2026-10-19-laema-hammer-accepted/01-laema-hammer-hero.png", "02-laema-hammer.png"),
    ]
    records = []
    for source, name in refs:
        target = HERE / "references" / name
        target.parent.mkdir(exist_ok=True)
        if not target.exists():
            shutil.copy2(source, target)
        with source.open("rb") as handle:
            original = hashlib.file_digest(handle, "sha256").hexdigest()
        with target.open("rb") as handle:
            copied = hashlib.file_digest(handle, "sha256").hexdigest()
        if copied != original:
            raise RuntimeError(f"Reference differs from preserved original: {name}")
        records.append({"file": "references/" + name, "source": source.relative_to(ROOT).as_posix(), "sha256": copied})
    save(HERE / "reference-provenance.json", records)


def build_graph():
    packaged=HERE/"workflows"/(WORKFLOW_NAME+".api.json")
    if packaged.exists():
        return json.loads(packaged.read_text(encoding="utf-8"))
    baseline = ROOT / "Research AI Art Pipeline for Laema/local-trials/2026-10-23-local-vs-imagegen-v01/local/workflows/hero.api.json"
    graph = json.loads(baseline.read_text(encoding="utf-8"))
    graph["4"]["inputs"]["image"] = "01-laema-open.png"
    graph["5"]["inputs"]["image"] = "02-laema-hammer.png"
    graph["20"] = {"class_type": "PrimitiveStringMultiline", "inputs": {"value": EXAMPLE}}
    graph["21"] = {"class_type": "PrimitiveStringMultiline", "inputs": {"value": GUIDE}}
    graph["22"] = {"class_type": "StringConcatenate", "inputs": {"string_a": ["21", 0], "string_b": ["20", 0], "delimiter": ""}}
    graph["6"]["inputs"]["prompt"] = ["22", 0]
    graph["13"]["inputs"]["filename_prefix"] = "Laema/Qwen"
    return graph


def workflow_from_api(graph, definitions):
    placements = {
        "20": ([40,80],[500,300],"1. YOUR PROMPT - edit this",False),
        "4": ([40,500],[280,440],"Reference 1 - Laema identity",False),
        "5": ([350,500],[280,440],"Reference 2 - saved hammer",False),
        "13": ([690,80],[590,860],"3. RESULT - saved in output/Laema",False),
        "11": ([1350,80],[310,300],"2. SETTINGS - seed / steps",False),
        "10": ([1350,470],[310,150],"CANVAS - portrait 1024 x 1536",False),
    }
    nodes, index, links = [], {}, []
    for order, (key, spec) in enumerate(graph.items()):
        meta = definitions[spec["class_type"]]
        pos,size,title,collapsed = placements.get(key, ([-500,80+order*65],[340,180],"Advanced - "+spec["class_type"],True))
        node = {"id": int(key), "type": spec["class_type"], "pos": pos, "size": size, "flags": {"collapsed": collapsed},
                "order": order, "mode": 0, "title": title, "inputs": [], "outputs": [],
                "properties": {"Node name for S&R": spec["class_type"], "cnr_id": "comfy-core"}, "widgets_values": []}
        if key == "20": node.update(color="#243f2d",bgcolor="#172b20")
        inputs = meta.get("input", {})
        for category in ("required", "optional"):
            names = meta.get("input_order", {}).get(category, list(inputs.get(category, {})))
            for name in names:
                definition = inputs.get(category, {}).get(name)
                if not definition or name not in spec["inputs"]:
                    continue
                value = spec["inputs"][name]
                datatype = definition[0]
                widget_type = isinstance(datatype,list) or datatype in {"STRING","INT","FLOAT","BOOLEAN","COMBO"}
                if isinstance(value,list) and len(value)==2 and str(value[0]) in graph and isinstance(value[1],int):
                    field={"name":name,"type":datatype if isinstance(datatype,str) else "COMBO","link":None}
                    if widget_type: field["widget"]={"name":name}
                    node["inputs"].append(field)
                elif widget_type:
                    node["widgets_values"].append(value)
                    if (spec["class_type"] == "KSampler" and name == "seed") or (len(definition)>1 and isinstance(definition[1],dict) and definition[1].get("control_after_generate")):
                        node["widgets_values"].append("fixed" if spec["class_type"]=="PrimitiveInt" else "randomize")
        for slot, datatype in enumerate(meta.get("output", [])):
            node["outputs"].append({"name":meta.get("output_name",meta["output"])[slot],"type":datatype,"links":[],"slot_index":slot})
        nodes.append(node)
        index[key]=node
    for key, spec in graph.items():
        for target_slot, field in enumerate(index[key]["inputs"]):
            origin, source_slot = spec["inputs"][field["name"]]
            link_id=len(links)+1
            field["link"]=link_id
            datatype=index[str(origin)]["outputs"][source_slot]["type"]
            links.append([link_id,int(origin),source_slot,int(key),target_slot,datatype])
            index[str(origin)]["outputs"][source_slot]["links"].append(link_id)
    return {"last_node_id":max(n["id"] for n in nodes),"last_link_id":len(links),"nodes":nodes,"links":links,
            "groups":[{"title":"YOUR REQUEST + REFERENCES","bounding":[15,25,640,950],"color":"#3d7051","font_size":24,"flags":{}},
                      {"title":"GENERATED ART","bounding":[665,25,640,950],"color":"#3f6180","font_size":24,"flags":{}},
                      {"title":"OPTIONAL SETTINGS","bounding":[1325,25,370,680],"color":"#715d3a","font_size":24,"flags":{}}],
            "config":{},"extra":{"ds":{"scale":0.65,"offset":[70,50]}},"version":0.4}


def install_workflows():
    definitions = api("/object_info")
    graph = build_graph()
    missing = [spec["class_type"] for spec in graph.values() if spec["class_type"] not in definitions]
    if missing:
        raise RuntimeError("Missing built-in nodes: "+str(missing))
    template_path=HERE/"workflows"/(WORKFLOW_NAME+".json")
    if template_path.exists():
        workflow=json.loads(template_path.read_text(encoding="utf-8"))
    else:
        workflow=workflow_from_api(graph, definitions)
        save(template_path,workflow)
    save(HERE / "workflows" / (WORKFLOW_NAME+".api.json"), graph)
    destination=HERE/"user/default/workflows"/(WORKFLOW_NAME+".json")
    if not destination.exists(): save(destination, workflow)
    for template in (HERE/"workflows").glob("*.json"):
        if template.name.endswith(".api.json"):continue
        saved=destination.parent/template.name
        if not saved.exists():saved.write_bytes(template.read_bytes())
    save(HERE/"workflow-node-definitions.json",{spec["class_type"]:definitions[spec["class_type"]] for spec in graph.values()})
    print("Laema workflow installed in ComfyUI's Workflows library.",flush=True)


def start(open_browser=True):
    cache=config()
    copy_references()
    for folder in ("logs","output","user"):(HERE/folder).mkdir(exist_ok=True)
    if ready():
        if not (HERE/"server.local.json").exists():
            raise RuntimeError(f"Port {PORT} belongs to another server. Stop it or change this launcher's port.")
        import psutil
        owned=json.loads((HERE/"server.local.json").read_text(encoding="utf-8"))
        try: owned_process=psutil.Process(owned["pid"])
        except psutil.NoSuchProcess: raise RuntimeError("The saved Laema process is gone; another server is using its port.")
        if owned_process.cmdline()!=owned["argv"]:
            raise RuntimeError("The running service does not match this Laema launcher's saved process.")
    else:
        model_paths=HERE/"model-paths.local.yaml"
        model_paths.write_text("laema:\n  base_path: "+(cache/".models").as_posix()+"\n  diffusion_models: diffusion_models\n  text_encoders: text_encoders\n  vae: vae\n",encoding="utf-8")
        stamp=datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        log_path=HERE/"logs"/("server-"+stamp+".log")
        args=[str(cache/".runtime/venv/Scripts/python.exe"),"-u",str(cache/".runtime/ComfyUI/main.py"),
              "--listen","127.0.0.1","--port",str(PORT),"--extra-model-paths-config",str(model_paths),
              "--input-directory",str(HERE/"references"),"--output-directory",str(HERE/"output"),"--user-directory",str(HERE/"user"),
              "--offline","--disable-all-custom-nodes","--disable-auto-launch","--preview-method","none","--cache-lru","32",
              "--bf16-vae","--reserve-vram","6","--disable-dynamic-vram","--disable-async-offload"]
        env=os.environ.copy();env.update(HF_HUB_OFFLINE="1",TRANSFORMERS_OFFLINE="1",PYTHONUTF8="1")
        with log_path.open("w",encoding="utf-8") as log:
            process=subprocess.Popen(args,cwd=cache/".runtime/ComfyUI",env=env,stdout=log,stderr=subprocess.STDOUT,
                                     creationflags=getattr(subprocess,"CREATE_NO_WINDOW",0))
        save(HERE/"server.local.json",{"pid":process.pid,"argv":args,"url":URL,"log":log_path.relative_to(HERE).as_posix()})
        began=time.monotonic()
        while not ready():
            if process.poll() is not None:raise RuntimeError(f"ComfyUI exited {process.returncode}. See {log_path}")
            if time.monotonic()-began>120:raise RuntimeError(f"Startup is taking longer than expected. See {log_path}")
            print("Starting local ComfyUI...",flush=True);time.sleep(3)
    install_workflows()
    print("Ready: "+URL,flush=True)
    print("Choose Workflows > "+WORKFLOW_NAME+", edit YOUR PROMPT, then click Run.",flush=True)
    if open_browser:webbrowser.open(URL)


def stop():
    import psutil
    path=HERE/"server.local.json"
    if not path.exists():print("No Laema server is recorded.");return
    record=json.loads(path.read_text(encoding="utf-8"))
    try:process=psutil.Process(record["pid"])
    except psutil.NoSuchProcess:print("Laema server is already stopped.");return
    if process.cmdline()!=record["argv"]:raise RuntimeError("Recorded PID no longer matches this Laema server; refusing to stop it.")
    processes=[process]+process.children(recursive=True)
    for entry in reversed(processes):
        try:entry.terminate()
        except psutil.NoSuchProcess:pass
    _,alive=psutil.wait_procs(processes,timeout=10)
    if alive:raise RuntimeError("Some Laema server processes did not terminate.")
    print("Laema server stopped. Existing output PNGs are preserved.")


if __name__=="__main__":
    parser=argparse.ArgumentParser();parser.add_argument("action",choices=["start","stop","status","workflows"]);parser.add_argument("--no-browser",action="store_true")
    options=parser.parse_args()
    if options.action=="start":
        from filelock import FileLock
        with FileLock(str(HERE/".server-start.lock"),timeout=180):start(not options.no_browser)
    elif options.action=="stop":stop()
    elif options.action=="workflows":install_workflows()
    else:print(json.dumps({"url":URL,"running":ready()}))
