"""Keep five visibly separate repair figures; reject unsafe rectangular crops."""
import importlib.util
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
spec = importlib.util.spec_from_file_location("necropolis_remaster", ROOT / "tools/art/necropolis_remaster.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
dd = h.dest("vampire_lord")
src = dd / "_source/repair-special-b.png"
raw = Image.open(src).convert("RGBA")
for slot, number in [(1,48),(2,49),(5,52),(6,53),(7,54)]:
    x0 = round((slot%4)*raw.width/4)
    x1 = round((slot%4+1)*raw.width/4)
    y0 = round((slot//4)*raw.height/2)
    y1 = round((slot//4+1)*raw.height/2)
    piece = raw.crop((x0,y0,x1,y1))
    bb = h.bbox(piece,8)
    assert bb and min(bb[0],bb[1],piece.width-bb[2],piece.height-bb[3]) > 2, (number,bb)
    output = dd / f"_source/repair-special-b-cell-{slot}.png"
    piece.save(output)
    pid = f"vampire_lord_p{number:03d}"
    print({"pose":pid,"source":h.rel(src),"source_sha256":h.sha(src),
           "derived":h.rel(output),"derived_sha256":h.sha(output),
           "crop_xyxy":[x0,y0,x1,y1],"alpha_bbox_in_crop":bb})
    print(h.ingest("vampire_lord",str(output),[pid],1,1,f"repair-special-b-cell-{slot}",
                   str(dd/"_source/prompts/repair-special-b.txt")))
