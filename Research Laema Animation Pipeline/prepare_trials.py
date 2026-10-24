"""Create deterministic original-motion guides and local review media. No production writes."""
from pathlib import Path
import json, hashlib, math
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).parent
REPO=ROOT.parent
TRIAL=ROOT/'trials'/'2026-10-23-A-v01'
INPUT=TRIAL/'inputs'
INPUT.mkdir(parents=True,exist_ok=True)
FONT_PATH=Path('C:/Windows/Fonts/segoeui.ttf')
def font(n): return ImageFont.truetype(str(FONT_PATH),n)
raw=(ROOT/'study-data.json').read_bytes().replace(b'\r\n',b'\n')
assert hashlib.sha256(raw).hexdigest()=='b19776e41fd6fec613c208c145e07b4345581c53eef3e54224f84280b676667d'
data=json.loads(raw)
a=data['proposals'][0]
assert a['id']=='A'
guide=Image.new('RGB',(2880,1152),'#17212c')
d=ImageDraw.Draw(guide)
for i,k in enumerate(a['keys']):
    ox=(i%5)*576+288; oy=(i//5)*576+540
    def p(name): return (ox+k['points'][name][0]*2,oy+k['points'][name][1]*2)
    x0,y0=(i%5)*576,(i//5)*576
    d.rectangle((x0,y0,x0+575,y0+575),outline='#465566',width=2)
    d.text((x0+16,y0+12),f'{i+1:02d}   A   {k["t"]:.4f}s',font=font(21),fill='#e0c693')
    d.line((x0+16,oy,x0+560,oy),fill='#677f8e',width=2)
    for n,m,w in [('hip','knee_a',30),('knee_a','ankle_a',22),('hip','knee_b',30),('knee_b','ankle_b',22),('hip','neck',48),('shoulder','elbow',22),('elbow','hand',18),('shoulder','shield',17)]:
        d.line((p(n),p(m)),fill='#dce4e4',width=w)
    for n in ['ankle_a','ankle_b']:
        x,y=p(n);d.line((x,y-5,x+27,y-5),fill='#dce4e4',width=10)
    x,y=p('head');d.ellipse((x-26,y-32,x+26,y+32),fill='#dce4e4')
    x,y=p('shield');d.ellipse((x-29,y-45,x+29,y+45),fill='#67879b',outline='#a7bac2',width=3)
    d.line((p('hand'),p('sword_tip')),fill='#e6b87e',width=7)
    for n in ['hip','neck','shoulder','elbow','hand','knee_a','knee_b','ankle_a','ankle_b']:
        x,y=p(n);d.ellipse((x-4,y-4,x+4,y+4),fill='#d16b66')
guide.save(INPUT/'A-pose-guide-5x2.png')
idle=Image.open(REPO/'assets/prototype/player/fire_sword_shield_v01/shared_idle.png').convert('RGBA')
# One static appearance frame only; no existing animation sequence supplies new motion.
idle.crop((0,0,448,448)).save(INPUT/'appearance-idle-cell0.png')
contract={'selected_motion':'A','selection_evidence':'User reply A on 2026-10-23','department':'combat','source_data_sha256':hashlib.sha256(raw).hexdigest(),'source_revision':'16b4c3b7199589439a276881eca7516cc0f7401c','local_source_revision':'d97c728021ec0cbc3a5e3a6483620150d7ab18a6','times_heat0':[k['t'] for k in a['keys']],'heat100_speed_multiplier':1.5,'frame_cell':[448,448],'foot_anchor':[224,400],'actor_origin':[224,348],'blade_length_world':88,'gameplay_edits':False,'appearance_reference_status':'Provisional experiment context; no final outfit or weapon decision','motion_provenance':data['provenance'],'phase3_status':'starting actual trials','method_winner':None}
(TRIAL/'contract.json').write_text(json.dumps(contract,indent=2)+'\n',encoding='utf-8',newline='\n')
# Recovered template is distinct from the original complete cloud HTML.
(ROOT/'preview/study-data.json').write_bytes(raw)
(ROOT/'review.html').write_text((ROOT/'review.template.html').read_text(encoding='utf-8').replace('__STUDY_JSON__',json.dumps(data,separators=(',',':'))),encoding='utf-8',newline='\n')
for name in ['heat0-right','heat100-right','heat0-left','heat100-left']:
    paths=sorted((ROOT/'local-review'/'captures'/name).glob('frame_*.png'))
    if len(paths)>=90:
        frames=[Image.open(p).convert('RGB') for p in paths[:90]]
        durations=[round((i+1)*1000/60)-round(i*1000/60) for i in range(90)]
        frames[0].save(ROOT/'local-review'/f'{name}.webp',save_all=True,append_images=frames[1:],duration=durations,loop=0,lossless=True,method=3)
        for f in frames:f.close()
print('Prepared exact A guides, reference crop, contract and native review media.')
