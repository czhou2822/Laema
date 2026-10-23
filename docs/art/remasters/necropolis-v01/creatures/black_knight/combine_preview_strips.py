"""Tile existing decoded review previews without changing any artwork."""
from pathlib import Path
import json
from PIL import Image, ImageDraw

report = Path(__file__).resolve().parent
data = json.loads((report/'review-panels/index.json').read_text())
root = report.parents[5]
ids = sorted({g['group_id'] for g in data['groups']})
for page in range(3):
    selected = ids[page*5:page*5+5]
    records = [g for gid in selected for g in data['groups'] if g['group_id']==gid]
    images = [Image.open(root/g['decoded_gif_frames']).convert('RGB') for g in records]
    sheet = Image.new('RGB',(max(im.width for im in images),210*len(images)),(23,36,49))
    draw = ImageDraw.Draw(sheet)
    for i,(g,im) in enumerate(zip(records,images)):
        draw.text((6,i*210+5),f'G{g["group_id"]} {g["facing"]}: decoded GIF frames; ms={g["gif_durations_ms"]}; NO playback claim',fill='white')
        sheet.paste(im,(0,i*210+30))
    sheet.save(report/'review-panels'/f'preview-sequences-{page:02d}.png')
print('Created three static decoded-GIF review plates for all 30 group/facing pairs.')
