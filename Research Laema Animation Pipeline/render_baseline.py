"""Render unchanged live sprite cells at source-derived combat exposure.

This is a source-timed reconstruction, not a Godot gameplay recording.
"""
import bisect
import hashlib
import json
import re
import subprocess
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).parent
REPO=ROOT.parent if (ROOT.parent/'config/attack_animations/fire_x1.tres').is_file() else ROOT.parent/'Laema'
OUT=ROOT/'evidence'
OUT.mkdir(exist_ok=True)
FONT='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
font=lambda size: ImageFont.truetype(FONT,size)
def number(text,key,default=None):
    m=re.search(r'^'+re.escape(key)+r' = ([0-9.]+)',text,re.M)
    return float(m[1]) if m else default
def marker(text,name):
    return float(re.search(r'"name": &?"'+name+r'",\s*"time": ([0-9.]+)',text)[1])
actions=[]
for name in ['fire_x1','fire_x2','fire_x3','fire_x4','fire_x5','cast_fire']:
    path=REPO/'config/attack_animations'/f'{name}.tres'
    text=path.read_text()
    texture=re.search(r'path="res://([^"]+\.png)"',text)[1]
    block=text.split('tracks/2/keys = {',1)[1].split('\n}',1)[0]
    native=[float(x) for x in re.search(r'"times": PackedFloat32Array\(([^)]+)\)',block)[1].split(',')]
    rects=[tuple(map(float,r.split(','))) for r in re.findall(r'Rect2\(([^)]+)\)',block)]
    if name.startswith('fire_x'):
        style=(REPO/'config/attack_styles'/f'{name}.tres').read_text()
        windup=number(style,'windup_duration')
        recovery=number(style,'recovery_duration')
        split=marker(text,'timing_split')
        def seconds(n):
            return n/split*windup if n<=split else windup+(n-split)/(1-split)*recovery
        duration=windup+recovery
        bounds=[seconds(marker(text,'active_start')),seconds(marker(text,'active_end'))]
    else:
        duration=1.2
        def seconds(n): return n*duration
        bounds=[marker(text,'launch')*duration]
    sheet=Image.open(REPO/texture).convert('RGBA')
    cells=[sheet.crop((int(x),int(y),int(x+w),int(y+h))) for x,y,w,h in rects]
    actions.append(dict(name=name,texture=texture,cells=cells,times=list(map(seconds,native)),duration=duration,bounds=bounds,sha256=hashlib.sha256((REPO/texture).read_bytes()).hexdigest()))
records=[]
for action in actions:
    records.append({k:v for k,v in action.items() if k!='cells'})
(OUT/'live-contract.json').write_text(json.dumps({'source_revision':'16b4c3b7199589439a276881eca7516cc0f7401c','evidence_type':'Source-timed reconstruction, no Godot capture','fixed_heat_only':True,'actions':records},indent=2)+'\n')

def frame(time,heat):
    speed=1+heat*.005
    img=Image.new('RGB',(1280,720),'#101923')
    d=ImageDraw.Draw(img)
    d.text((30,18),'Current live sheets / source-timed diagnostic',font=font(26),fill='#e7edf4')
    d.text((30,57),f'Fixed Heat {heat}  |  1 source px = 1 world px  |  unchanged artwork  |  not recorded gameplay',font=font(15),fill='#9aaec2')
    for i,a in enumerate(actions):
        col,row=i%3,i//3
        left,top=col*420+16,90+row*290
        x,y=left+175,top+232
        cycle=a['duration']/speed+.32
        elapsed=time%cycle
        base=min(elapsed*speed,a['duration']-.00001)
        idx=max(0,bisect.bisect_right(a['times'],base)-1)
        d.rounded_rectangle((left,top,left+410,top+280),radius=12,fill='#192634')
        d.text((left+14,top+12),a['name'].replace('_',' ').upper(),font=font(19),fill='#e7edf4')
        d.text((left+14,top+41),f'{a["duration"]/speed:.3f}s / {len(a["cells"])} keys / pose {idx+1}',font=font(14),fill='#9aaec2')
        d.line((left+12,y,left+398,y),fill='#466176',width=1)
        cell=a['cells'][idx]
        img.paste(cell,(x-224,y-400),cell)
        bar_y=top+260
        width=380
        d.line((left+14,bar_y,left+14+width,bar_y),fill='#3a4d60',width=4)
        d.line((left+14,bar_y,left+14+base/a['duration']*width,bar_y),fill='#6ed1bd',width=4)
        for bound in a['bounds']:
            xx=left+14+bound/a['duration']*width
            d.line((xx,bar_y-5,xx,bar_y+5),fill='#efbe75',width=2)
    d.text((30,685),'Gold ticks: existing contact window (melee) or launch (Cast). Loops include 320 ms review gap.',font=font(14),fill='#9aaec2')
    return img

frame(.18,0).save(OUT/'live-baseline.png')
process=subprocess.Popen(['ffmpeg','-y','-hide_banner','-loglevel','error','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24','-s','1280x720','-r','60','-i','-','-an','-c:v','libx264','-preset','fast','-crf','21','-pix_fmt','yuv420p','-movflags','+faststart',str(OUT/'live-baseline.mp4')],stdin=subprocess.PIPE)
for n in range(720):
    heat=0 if n<360 else 100
    process.stdin.write(frame((n%360)/60,heat).tobytes())
process.stdin.close()
assert process.wait()==0
print('Rendered 12s source-timed baseline at60fps; JSON pins cells, exposures and hashes.')
