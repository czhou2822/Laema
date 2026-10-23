"""Mechanical review presentation only; no artwork synthesis or pose modification."""
import json
import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps, ImageSequence

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
sys.path.insert(0, str(ROOT / 'tools/art'))
import necropolis_remaster as h

CID = 'black_knight'
dd = h.dest(CID)
out = Path(__file__).with_name('review-panels')
out.mkdir(exist_ok=True)
c = h.creature(CID)
pm = h.posemap(c)
manifest = h.read(dd / 'source_manifest.json')
index = []
for g in manifest['groups']:
    if not g['complete']:
        continue
    n = g['frame_count']
    for facing in ['source', 'mirror']:
        rect = (340,190,780,550) if facing == 'source' else (244,190,684,550)
        board = Image.new('RGB', (440*min(4,n), 752*math.ceil(n/4)), (23,36,49))
        draw = ImageDraw.Draw(board)
        for i,pid in enumerate(g['pose_ids_in_source_order']):
            og = h.projected_original(pm[pid])
            candidate = Image.open(dd/'poses'/f'{pid}.png').convert('RGBA')
            if facing == 'mirror':
                og = ImageOps.mirror(og)
                candidate = ImageOps.mirror(candidate)
            x = i%4*440
            y = i//4*752
            draw.text((x+8,y+5), f'G{g["group_id"]} F{i} {pid} OG {facing}', fill='white')
            board.paste(h.matte(og).crop(rect), (x,y+24))
            draw.text((x+8,y+381), 'CANDIDATE; fixed registered scale', fill='white')
            board.paste(h.matte(candidate).crop(rect), (x,y+400))
        path = out/f'g{g["group_id"]:02d}-{facing}.png'
        board.save(path)
        # Decode the actual GIF, preserving every stored GIF frame and duration.
        gif = Image.open(ROOT / g['preview' if facing == 'source' else 'mirror_preview'])
        frames = []
        duration = 0
        durations = []
        for frame in ImageSequence.Iterator(gif):
            durations.append(frame.info.get('duration', 0))
            duration += durations[-1]
            frames.append(frame.convert('RGB').crop(tuple(round(v/2) for v in rect)))
        strip = Image.new('RGB',(220*len(frames),180),(23,36,49))
        for i,frame in enumerate(frames):
            strip.paste(frame,(i*220,0))
        strip_path = out/f'g{g["group_id"]:02d}-{facing}-gif-decoded.png'
        strip.save(strip_path)
        index.append({'group_id':g['group_id'],'facing':facing,'source_ordered_comparison':h.rel(path),'decoded_gif_frames':h.rel(strip_path),'gif_frame_count':len(frames),'gif_durations_ms':durations,'total_preview_duration_ms':duration,'playback_observed':False})
h.write(out/'index.json', {'presentation_only':True,'groups':index,'limits':'Static inspection of decoded GIF frames; no browser, native playback, engine or human animation acceptance.'})
provenance = []
for path in sorted((dd/'_source').glob('*.tool.json')):
    record = h.read(path)
    record['reference_hashes'] = [{'path':p,'sha256':h.sha(ROOT/p)} for p in record['references']]
    record['prompt_sha256'] = h.sha(ROOT/record['prompt_file'])
    raw_path = dd/'_source'/(record['attempt']+'.png')
    record['saved_raw'] = h.rel(raw_path)
    record['raw_sha256'] = h.sha(raw_path)
    provenance.append(record)
h.write(Path(__file__).with_name('generation-provenance.json'), {'creature_id':CID,'attempts':provenance})
print(json.dumps({'group_facing_boards':len(index),'raw_attempts':len(provenance)}))
