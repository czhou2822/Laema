"""Mechanical visual diagnostics only: original/registered pose pairs, no artwork edits."""
import importlib.util
import json
import sys
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[6]
spec = importlib.util.spec_from_file_location('nr', ROOT / 'tools/art/necropolis_remaster.py')
nr = importlib.util.module_from_spec(spec)
spec.loader.exec_module(nr)
cid = 'lich'
dd = nr.dest(cid)
c = nr.creature(cid)
pm = nr.posemap(c)
outdir = dd / '_source/review'
outdir.mkdir(parents=True, exist_ok=True)
ids = sys.argv[1].split(',') if len(sys.argv) > 1 else list(pm)
for start in range(0, len(ids), 8):
    batch = ids[start:start + 8]
    sheet = Image.new('RGB', (1760, 410 * ((len(batch) + 1) // 2)), (23, 36, 49))
    draw = ImageDraw.Draw(sheet)
    for i, pid in enumerate(batch):
        x, y = (i % 2) * 880, (i // 2) * 410
        draw.text((x + 8, y + 5), pid + ' : ORIGINAL | CANDIDATE at target pixels', fill='white')
        for j, im in enumerate([nr.projected_original(pm[pid]), Image.open(dd / 'poses' / (pid + '.png')).convert('RGBA')]):
            tile = nr.matte(im).crop((300, 180, 740, 560))
            sheet.paste(tile, (x + j * 440, y + 25))
    name = 'comparison-' + batch[0] + '-' + batch[-1] + '.png'
    sheet.save(outdir / name)
    print((outdir / name).relative_to(ROOT).as_posix())
