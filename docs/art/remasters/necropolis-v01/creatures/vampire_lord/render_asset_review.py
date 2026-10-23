"""Mechanical comparison presentations only; never paints production artwork."""

import argparse
import importlib.util
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
spec = importlib.util.spec_from_file_location("necropolis_remaster", ROOT / "tools/art/necropolis_remaster.py")
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
CID = "vampire_lord"
DD = helper.dest(CID)
OUT = DD / "_source/review"


def matte(im, color=(23, 36, 49, 255)):
    bg = Image.new("RGBA", im.size, color)
    bg.alpha_composite(im)
    return bg.convert("RGB")


def poses():
    creature = helper.creature(CID)
    for start in range(0, len(creature["poses"]), 4):
        page = Image.new("RGB", (1536, 4*540), (23, 36, 49))
        draw = ImageDraw.Draw(page)
        for i, pose in enumerate(creature["poses"][start:start+4]):
            pid = pose["pose_id"]
            source = helper.projected_original(pose)
            candidate = Image.open(DD / "poses" / (pid + ".png")).convert("RGBA")
            mirror = Image.open(DD / "poses" / (pid + "_mirror.png")).convert("RGBA")
            for j, (name, im) in enumerate([("original fixed projection", source), ("new registered", candidate), ("new exact mirror", mirror)]):
                draw.text((j*512+10, i*540+5), f"{pid} / {name} / native pixels", fill="white")
                # Central 512-square contains the fixed placement without rescaling.
                page.paste(matte(im.crop((256,128,768,640))), (j*512, i*540+25))
        page.save(OUT / f"poses-{start:03d}-{min(start+3,61):03d}.png")


def groups():
    manifest = helper.read(DD / "source_manifest.json")
    for group in manifest["groups"]:
        ids = group["pose_ids_in_source_order"]
        # Three source-ordered rows, fixed native pixels: original/new/mirror.
        page = Image.new("RGB", (256*len(ids), 3*280), (23,36,49))
        draw = ImageDraw.Draw(page)
        for index, pid in enumerate(ids):
            pose = helper.posemap(helper.creature(CID))[pid]
            source = helper.projected_original(pose)
            new = Image.open(DD / "poses" / f"{pid}.png").convert("RGBA")
            for row, im in enumerate([source, new, ImageOps.mirror(new)]):
                # 512 center square scaled 1/2, matching helper GIF preview scale.
                region = im.crop((256,128,768,640)).resize((256,256), Image.Resampling.NEAREST if row == 0 else Image.Resampling.LANCZOS)
                page.paste(matte(region),(index*256,row*280+24))
                draw.text((index*256+4,row*280+5),f"G{group['group_id']} F{index} {pid[-4:]} "+["OG","NEW","MIRROR"][row],fill="white")
        page.save(OUT / f"sequence-g{group['group_id']:02d}-b{group['original_block']:02d}.png")


def gif_frames():
    manifest = helper.read(DD / "source_manifest.json")
    for group in manifest["groups"]:
        for orientation, key in [("source", "preview"), ("mirror", "mirror_preview")]:
            gif = Image.open(ROOT / group[key])
            count = gif.n_frames
            page = Image.new("RGB", (256*count, 280), (23,36,49))
            draw = ImageDraw.Draw(page)
            for i in range(count):
                gif.seek(i)
                im = gif.convert("RGB").crop((128,48,384,304))
                page.paste(im,(256*i,24))
                draw.text((256*i+4,4),f"G{group['group_id']} {orientation} GIF F{i} {gif.info.get('duration')}ms",fill="white")
            page.save(OUT / f"gif-g{group['group_id']:02d}-b{group['original_block']:02d}-{orientation}.png")


def collages():
    manifest = helper.read(DD / "source_manifest.json")
    for group in manifest["groups"]:
        gid, block = group["group_id"], group["original_block"]
        contact = Image.open(ROOT / group["contact"]).convert("RGB")
        frames = [Image.open(OUT / f"gif-g{gid:02d}-b{block:02d}-{side}.png").convert("RGB") for side in ["source", "mirror"]]
        page = Image.new("RGB", (max(im.width for im in [contact,*frames]), contact.height+560), (23,36,49))
        y = 0
        for im in [contact,*frames]:
            page.paste(im,(0,y))
            y += im.height
        page.save(OUT / f"group-review-g{gid:02d}-b{block:02d}.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument("mode", choices=["poses", "groups", "gif-frames", "collages"])
    args = parser.parse_args()
    OUT.mkdir(parents=True, exist_ok=True)
    {"poses": poses, "groups": groups, "gif-frames": gif_frames, "collages":collages}[args.mode]()
    print(json.dumps({"presentation": args.mode, "output": helper.rel(OUT)}))
