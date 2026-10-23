"""Decode actual review GIFs into static source-ordered dual-facing frame sheets."""
import json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[6]
DD = ROOT / 'assets/prototype/enemy/lich/remaster_v01'
manifest = json.loads((DD / 'source_manifest.json').read_text(encoding='utf-8'))
outdir = DD / '_source/review/gif-frames'
outdir.mkdir(parents=True, exist_ok=True)
records = []
for group in manifest['groups']:
    if not group['complete']:
        raise ValueError('Incomplete group')
    sides, mappings = [], []
    for key in ('preview', 'mirror_preview'):
        frames, mapping = [], []
        with Image.open(ROOT / group[key]) as gif:
            for i in range(gif.n_frames):
                gif.seek(i)
                ms = gif.info.get('duration', 0)
                if ms <= 0 or ms % 100:
                    raise ValueError('Unexpected review frame duration')
                frame = gif.convert('RGB').copy()
                for _ in range(ms // 100):
                    frames.append(frame)
                    mapping.append({'encoded_frame': i, 'duration_ms': ms})
        if len(frames) != group['frame_count']:
            raise ValueError('GIF/source timeline mismatch')
        sides.append(frames)
        mappings.append(mapping)
    width, height = 1760, 225 * ((group['frame_count'] + 3) // 4)
    sheet = Image.new('RGB', (width, height), (23, 36, 49))
    draw = ImageDraw.Draw(sheet)
    for i, pid in enumerate(group['pose_ids_in_source_order']):
        x, y = i % 4 * 440, i // 4 * 225
        draw.text((x + 3, y + 3), f'G{group["group_id"]} F{i} {pid}: source | mirror', fill='white')
        for side in range(2):
            # Constant crop of already-rendered preview: no pose normalization or artwork edits.
            tile = sides[side][i].crop((150, 80, 370, 280))
            sheet.paste(tile, (x + side * 220, y + 22))
    path = outdir / f'g{group["group_id"]:02d}_b{group["original_block"]:02d}.png'
    sheet.save(path)
    records.append({'group_id': group['group_id'], 'original_block': group['original_block'],
                    'positions': group['frame_count'], 'sheet': path.relative_to(ROOT).as_posix(),
                    'actual_gif_source': group['preview'], 'actual_gif_mirror': group['mirror_preview'],
                    'source_order': group['pose_ids_in_source_order'], 'decoded_mapping': mappings,
                    'method': 'Static decoded GIF frames; 100ms preview units expanded to inspect source repeats; not browser or engine playback'})
print(json.dumps({'creature_id': 'lich', 'group_count': len(records), 'records': records}, indent=2))
