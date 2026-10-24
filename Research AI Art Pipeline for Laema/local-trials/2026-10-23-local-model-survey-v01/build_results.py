"""Build static art comparisons and an honest execution report from saved records."""
from pathlib import Path
import ast
import hashlib
import json
from PIL import Image,ImageDraw,ImageFont

HERE=Path(__file__).resolve().parent
METHODS=[("qwen","Qwen Edit 2511"),("flux-base","FLUX2 Klein Base"),("flux-fast","FLUX2 Klein Fast"),("longcat","LongCat Edit")]


def sha(path):
    with path.open("rb") as handle:return hashlib.file_digest(handle,"sha256").hexdigest()


def main():
    records=[]
    for method,label in METHODS+[("z-image","Z-Image (text only)")]:
        for task in ("hero","action"):
            png=HERE/method/"raw"/(task+".png")
            record=json.loads(png.with_suffix(".json").read_text(encoding="utf-8"))
            if sha(png)!=record["raw_sha256"]:raise RuntimeError("Raw image changed: "+str(png))
            if record["dimensions"]!=[1024,1536]:raise RuntimeError("Unexpected output dimensions")
            records.append({"method":method,"label":label,"task":task,"file":png.relative_to(HERE).as_posix(),"sha256":record["raw_sha256"],"seconds":record["submission_to_save_seconds"],"peak_whole_gpu_mib":max(int(item["whole_gpu_memory_mib_util_percent"].split(",")[0]) for item in record["gpu_samples"]),"reference_images":record["reference_input_count"],"manual_art_cleanup_seconds":0})
    font=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf",23)
    small=ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf",16)
    cols=[("inputs/reference.png","Saved reference")]+[(f"{method}/raw/{{task}}.png",label) for method,label in METHODS]
    for task in ("hero","action"):
        for view in ("whole","upper-body"):
            width=320;height=480 if view=="whole" else 320;gap=18;margin=22
            sheet=Image.new("RGB",(len(cols)*width+(len(cols)-1)*gap+margin*2,height+128),"#101820")
            draw=ImageDraw.Draw(sheet);draw.text((margin,10),"Laema / "+task+" / "+view,font=font,fill="#f2f4f7")
            for index,(path,label) in enumerate(cols):
                x=margin+index*(width+gap)
                draw.text((x,48),label,font=small,fill="#c2cfdd")
                with Image.open(HERE/path.format(task=task)) as source:
                    image=source.convert("RGB")
                    if view=="upper-body":image=image.crop((256,0,896,640))
                    image.thumbnail((width,height),Image.Resampling.LANCZOS)
                    sheet.paste(image,(x+(width-image.width)//2,78+(height-image.height)//2))
            caption="First raw outputs / same reference + positive prompt / no art repair" if view=="whole" else "Same fixed canvas crop for all images: [256,0,896,640] / inspection only"
            draw.text((margin,height+93),caption,font=small,fill="#c2cfdd")
            sheet.save(HERE/("comparison-"+task+"-"+view+".jpg"),quality=95,subsampling=0)
    text_sheet=Image.new("RGB",(724,650),"#101820");draw=ImageDraw.Draw(text_sheet)
    draw.text((22,10),"Z-Image Turbo / separate text-only track",font=font,fill="#f2f4f7")
    for index,task in enumerate(("hero","action")):
        draw.text((22+index*350,48),task+" / no reference image",font=small,fill="#c2cfdd")
        with Image.open(HERE/f"z-image/raw/{task}.png") as source:
            image=source.convert("RGB");image.thumbnail((320,480),Image.Resampling.LANCZOS);text_sheet.paste(image,(22+index*350,78))
    draw.text((22,590),"Written description only; not equivalent identity conditioning.",font=small,fill="#c2cfdd")
    text_sheet.save(HERE/"comparison-z-image-text-only.jpg",quality=95,subsampling=0)
    table=[]
    for method,label in METHODS+[("z-image","Z-Image (text only)")]:
        selected=[r for r in records if r["method"]==method]
        table.append(f"| {label} | {selected[0]['seconds']:.1f}s | {selected[1]['seconds']:.1f}s | {selected[0]['reference_images']} |")
    report="""# Local model comparison — executed results

All ten first outputs completed on the RTX4090. No artistic winner or production method is accepted. Manual painting/repair performed before review:0seconds for every output. Time to an accepted asset remains unmeasured.

The same single saved Laema hero reference and positive prompt were used for Qwen, FLUX Base, FLUX Fast and LongCat. This is a new matched round; the earlier two-reference Qwen/built-in comparison is separate. Z-Image is a separately labelled text-only experiment and received no reference image. All outputs are1024x1536. Model-native sampling settings differ and are saved in each API graph.

## Review the artwork

The columns below are saved reference, Qwen, FLUX Base, FLUX Fast and LongCat. Whole-image comparisons use equal canvas scaling. Upper-body sheets use the exact same fixed crop on every image; no model-specific alignment or repair.

![Finished character](comparison-hero-whole.jpg)

![Finished character upper body](comparison-hero-upper-body.jpg)

![Action pose](comparison-action-whole.jpg)

![Action upper body](comparison-action-upper-body.jpg)

Z-Image's result belongs to a different input track:

![Z-Image text-only](comparison-z-image-text-only.jpg)

Judge artistic finish, recognizable identity, face/expression, anatomy and hands, costume/hammer construction and response to the requested pose. No automatic aesthetic score substitutes for that review. Single outputs per cell do not establish statistical reliability or best possible quality.

## Observed request duration

| Configuration | Character | Action | Reference images |
| --- | ---: | ---: | ---: |
"""+"\n".join(table)+"""

These are request-through-save observations on this installation, including model loading where needed and5second polling. Later requests can benefit from caching. Model downloads ran concurrently during some requests. These are not controlled hardware speed benchmarks. Exact histories and sampled whole-GPU allocations are in each raw image's JSON record.

## Original files

"""
    for method,label in METHODS+[("z-image","Z-Image (text only)")]:report+=f"- {label}: [character PNG]({method}/raw/hero.png), [action PNG]({method}/raw/action.png)\n"
    report+="""
## Scope and access limits

Five configurations across four model families were executed: Qwen, FLUX2Klein Base/Fast, LongCat and Z-Image. FLUX3Klein, FLUX2Klein9B and FLUX1Kontext were researched but not downloaded or run because their official repositories require gated access. SDXL/reference adapters, other checkpoints/LoRAs, and paid hosted alternatives are not tested here. This is a bounded first survey of practical native workflows, not a claim to have tested every image model.

The seven new model files total41,727,872,544bytes. All were pinned by repository revision and passed full-file SHA256 checks. The existing runtime and Qwen model were reused. Raw outputs and source references are untouched. No production asset, gameplay or canonical art decision was changed. No hosted image-generation calls were made for this survey.

The reusable Apps are installed in [the local ComfyUI package](../../ComfyUI-Laema/README.md). Model selection is a user choice; a working app is not art acceptance. See [method and source notes](README.md), experiment-plan.json, prompts.json, model-lock.json and repository-access.json for details.
"""
    (HERE/"REVIEW.md").write_text(report,encoding="utf-8")
    (HERE/"results.json").write_text(json.dumps(records,indent=2),encoding="utf-8")
    for path in HERE.glob("*.py"):ast.parse(path.read_text(encoding="utf-8"),filename=path.name)
    source=json.loads((HERE/"reference.json").read_text(encoding="utf-8"))
    if sha(HERE/source["file"])!=source["sha256"]:raise RuntimeError("Benchmark reference changed")
    summary={"successful_raw_outputs":len(records),"all_dimensions":[1024,1536],"raw_hashes_verified":True,"reference_hash_verified":True,"artist_cleanup_seconds":0,"acceptance":"pending user visual review","python_ast":"passed","whole_gpu_peak_mib":max(r["peak_whole_gpu_mib"] for r in records)}
    (HERE/"verification.json").write_text(json.dumps(summary,indent=2),encoding="utf-8")
    print(json.dumps(summary))


if __name__=="__main__":main()
