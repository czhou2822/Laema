"""Install model-specific native ComfyUI Apps without overwriting saved user copies."""
from pathlib import Path
import copy
import importlib.util
import json
import os
import uuid

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
STUDIO=ROOT/"Research AI Art Pipeline for Laema/ComfyUI-Laema"


def module(name,path):
    spec=importlib.util.spec_from_file_location(name,path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result)
    return result


def main():
    studio=module("studio_launcher",STUDIO/"studio.py")
    survey=module("survey_recipes",HERE/"survey.py")
    definitions=studio.api("/object_info")
    names={"flux-base":"Laema - FLUX2 Base Reference Art","flux-fast":"Laema - FLUX2 Fast Reference Art","longcat":"Laema - LongCat Reference Art","z-image":"Laema - Z-Image Text Only"}
    installed=[]
    for method,name in names.items():
        if not all(path.exists() for path in survey.model_files(method)):
            print("Not installed yet: "+method,flush=True);continue
        graph=survey.graph(method,"hero")
        is_text=method=="z-image"
        guide=("No reference image is used. " if is_text else "The reference supplies Laema's identity, costume and hammer construction. ")+survey.DESCRIPTION+"Follow the user's requested pose, expression, framing and setting. Use a plain gray background only if no setting is requested. No text or watermark.\n\nUSER REQUEST:\n"
        example="Create a full-body illustration of Laema in a relaxed, alert three-quarter stance, holding her hammer naturally. Plain gray background, complete figure and hammer visible."
        graph["20"]={"class_type":"PrimitiveStringMultiline","inputs":{"value":example}}
        graph["21"]={"class_type":"PrimitiveStringMultiline","inputs":{"value":guide}}
        graph["22"]={"class_type":"StringConcatenate","inputs":{"string_a":["21",0],"string_b":["20",0],"delimiter":""}}
        graph["6"]["inputs"]["text" if method.startswith("flux") or is_text else "prompt"]=["22",0]
        graph["13"]["inputs"]["filename_prefix"]="Laema/"+method
        if method.startswith("flux"):
            graph["31"]={"class_type":"PrimitiveInt","inputs":{"value":1024}}
            graph["32"]={"class_type":"PrimitiveInt","inputs":{"value":1536}}
            for node_id in ("10","16"):
                graph[node_id]["inputs"]["width"]=["31",0]
                graph[node_id]["inputs"]["height"]=["32",0]
            seed_node,seed_widget="17","noise_seed"
            width_node,width_widget,height_node,height_widget="31","value","32","value"
        else:
            seed_node,seed_widget="11","seed"
            width_node,width_widget,height_node,height_widget="10","width","10","height"
        native=studio.workflow_from_api(graph,definitions)
        native_id=str(uuid.uuid4());native["id"]=native_id;native["revision"]=0
        native["extra"]["linearData"]={"inputs":[[native_id+":20:value","value"],[f"{native_id}:{seed_node}:{seed_widget}",seed_widget],[f"{native_id}:{width_node}:{width_widget}",width_widget],[f"{native_id}:{height_node}:{height_widget}",height_widget]],"outputs":["13"]}
        native["extra"].update(linearMode=True,workflowRendererVersion="Vue",frontendVersion="1.57.1")
        for node_id,field,label in [("20","value","Your prompt"),(seed_node,seed_widget,"Seed"),(width_node,width_widget,"Width"),(height_node,height_widget,"Height")]:
            node=next(n for n in native["nodes"] if str(n["id"])==node_id)
            if not any(item["name"]==field for item in node["inputs"]):
                node["inputs"].append({"name":field,"label":label,"type":"STRING" if node_id=="20" else "INT","widget":{"name":field},"link":None})
        package=STUDIO/"workflows"/(name+".app.json")
        api_package=STUDIO/"workflows"/(name+".api.json")
        if not package.exists():studio.save(package,native)
        if not api_package.exists():studio.save(api_package,graph)
        user=STUDIO/"user/default/workflows"/(name+".app.json")
        if not user.exists():user.write_bytes(package.read_bytes())
        installed.append({"method":method,"name":name,"reference_images":0 if is_text else 1,"workflow":package.relative_to(STUDIO).as_posix()})
        print("Installed: "+name,flush=True)
    studio.save(STUDIO/"installed-alternatives.json",installed)


if __name__=="__main__":main()
