#!/usr/bin/env python3
"""Mechanical native-scale standing comparison; never draws or normalizes bodies."""
import hashlib
import json
import math
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).resolve().parents[2]
DOC=ROOT/'docs/art/remasters/necropolis-v01'


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    plan=json.loads((DOC/'generation-plan.json').read_text(encoding='utf-8'))
    benchmark=ROOT/'docs/art/production/necropolis-creature-assets-v01/references/pikeman-registered-180px.png'
    entries=[]
    def entry(label,path,anchor,**extra):
        if not path.exists():return {'label':label,'missing':True,'anchor':anchor,**extra}
        im=Image.open(path).convert('RGBA');bb=im.getchannel('A').getbbox()
        if not bb:raise ValueError('Empty registered image: '+str(path))
        return {'label':label,'path':path.relative_to(ROOT).as_posix(),'sha256':sha(path),'anchor':anchor,'bounds':bb,'missing':False,'image':im,**extra}
    pike=entry('Pikeman rendering / size benchmark',benchmark,(384,448),benchmark=True)
    for c in plan['creatures']:
        pid=c['og_idle_reference_pose_id'];path=ROOT/'assets/prototype/enemy'/c['creature_id']/'remaster_v01/poses'/(pid+'.png')
        entries.append(entry(c['creature'],path,(512,512),creature_id=c['creature_id'],pose_id=pid))
    all_entries=[pike]+entries;present=[x for x in all_entries if not x['missing']]
    half_width=max(320,max(max(x['anchor'][0]-x['bounds'][0],x['bounds'][2]-x['anchor'][0]) for x in present)+40)
    top_space=max(440,max(x['anchor'][1]-x['bounds'][1] for x in present)+70)
    bottom_space=max(70,max(x['bounds'][3]-x['anchor'][1] for x in present)+50)
    cw=half_width*2;ch=top_space+bottom_space;header=80;outputs=[]
    font=ImageFont.load_default(size=18);small=ImageFont.load_default(size=14)
    # Repeat benchmark on both pages; no creature-specific rescaling or cropping.
    for page,start in enumerate(range(0,len(entries),8),1):
        cards=[pike]+entries[start:start+8];rows=math.ceil(len(cards)/3)
        sheet=Image.new('RGB',(cw*3,header+ch*rows),(23,36,49));draw=ImageDraw.Draw(sheet)
        draw.text((24,14),'Necropolis selected idle poses - common source-relative scale',fill='white',font=font)
        draw.text((24,42),'Unresized registered pixels; benchmark repeated. Candidate art, not motion acceptance. Source scale 180/73.',fill='#bdc8d1',font=small)
        for i,item in enumerate(cards):
            x=i%3*cw;y=header+i//3*ch;baseline=y+top_space;center=x+half_width
            draw.line((x+20,baseline,x+cw-20,baseline),fill=(78,94,106))
            draw.text((x+16,y+12),item['label'],fill='white',font=font)
            draw.text((x+16,y+38),item.get('pose_id','Existing approved reference; unchanged'),fill='#aebdc8',font=small)
            if item['missing']:
                draw.text((x+24,y+100),'MISSING CANDIDATE — no master substituted',fill='#ffc773',font=small);continue
            bb=item['bounds'];art=item['image'].crop(bb);left=center-item['anchor'][0]+bb[0];top=baseline-item['anchor'][1]+bb[1]
            if left<x or top<y+60 or left+art.width>x+cw or top+art.height>y+ch:raise ValueError('Comparison framing failed: '+item['label'])
            sheet.paste(art,(left,top),art)
        output=DOC/f'standing-lineup-{page:02d}.png';sheet.save(output)
        outputs.append({'path':output.relative_to(ROOT).as_posix(),'sha256':sha(output),'size':list(sheet.size),'creatures':[x.get('creature_id','pikeman benchmark') for x in cards]})
    record={'scope':'Mechanical standing identity/material/scale comparison; not playback or human motion acceptance',
        'uniform_resize_applied':False,'complete_candidates':sum(not e['missing'] for e in entries)==14,
        'source_scale':180/73,'benchmark_reference_unchanged':True,'outputs':outputs,
        'entries':[{k:v for k,v in x.items() if k!='image'} for x in all_entries]}
    (DOC/'standing-lineup.json').write_text(json.dumps(record,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'supplied_idle_candidates':sum(not e['missing'] for e in entries),'outputs':outputs}))


if __name__=='__main__':main()
