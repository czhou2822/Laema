from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,hashlib,math
R=Path('/workspace/Laema'); O=Path('/workspace/homm3-research/visual_audit')
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',16)
small=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',13)
W,H=450,300
specs=[
 dict(name='griffin_attack',source='assets/prototype/enemy/griffin/Attack.png',generated='assets/prototype/enemy/griffin/highres_v01/Attack.png',sourcecell=(450,400),generatedcell=(768,640),n=9,anchor=(218,267),source_scale=180/89,generatedanchor=(384,448),generated_scale=1,root=(200,265)),
 dict(name='archer_shoot',source='assets/prototype/enemy/archer/Shoot.png',generated='assets/prototype/enemy/archer/highres_v01/Shoot.png',sourcecell=(450,400),generatedcell=(768,640),n=8,anchor=(196,267),source_scale=180/76,generatedanchor=(384,448),generated_scale=1,root=(185,265)),
 dict(name='pikeman_attack',source='assets/prototype/enemy/pikeman/Attack.png',generated='assets/prototype/enemy/pikeman/repaint_v02/attack_right_sheet.png',sourcecell=(450,400),generatedcell=(768,512),n=10,anchor=(196,268),source_scale=180/74,generatedanchor=(384,448),generated_scale=1,root=(180,265)),
]
def frame(path,sz,i):
 im=Image.open(R/path).convert('RGBA'); w,h=sz; x=(i%4)*w;y=(i//4)*h
 return im.crop((x,y,x+w,y+h))
def rendered(fr,anchor,scale,root,label):
 out=Image.new('RGBA',(W,H),(34,37,43,255))
 trans=fr.transform((W,H),Image.Transform.AFFINE,(1/scale,0,anchor[0]-root[0]/scale,0,1/scale,anchor[1]-root[1]/scale),resample=Image.Resampling.NEAREST)
 out.alpha_composite(trans)
 d=ImageDraw.Draw(out); d.line((0,root[1],W,root[1]),fill=(70,85,95),width=1);d.line((root[0]-5,root[1],root[0]+5,root[1]),fill=(255,120,80),width=2); d.text((8,5),label,font=small,fill='white')
 return out.convert('RGB')
metrics=[]
for s in specs:
 pairs=[]; records=[]
 for i in range(s['n']):
  a=frame(s['source'],s['sourcecell'],i); b=frame(s['generated'],s['generatedcell'],i)
  pa=rendered(a,s['anchor'],s['source_scale'],s['root'],f"{i:02d} original, fixed scale {s['source_scale']:.3f}")
  pb=rendered(b,s['generatedanchor'],s['generated_scale'],s['root'],f"{i:02d} existing generated, scale 1.000")
  pair=Image.new('RGB',(W,H*2));pair.paste(pa,(0,0));pair.paste(pb,(0,H));pairs.append(pair)
  records.append({'frame':i,'source_alpha_bbox':a.getchannel('A').point(lambda v:255 if v>127 else 0).getbbox(),'generated_alpha_bbox':b.getchannel('A').point(lambda v:255 if v>127 else 0).getbbox()})
 cols=3;rows=math.ceil(s['n']/cols);sheet=Image.new('RGB',(W*cols,H*2*rows+70),(20,22,26));d=ImageDraw.Draw(sheet)
 d.text((12,6),s['name']+' | original above / existing generated below',font=font,fill='white')
 d.text((12,29),'Fixed transform for entire group; no per-frame recenter, crop fit, or pose normalization.',font=small,fill='white')
 d.text((12,48),'Root cross and floor line are presentation guides. Fixed source scales; Pikeman uses measured helmet-to-foot 74px, generated body 180px.',font=small,fill='white')
 for i,p in enumerate(pairs):sheet.paste(p,((i%cols)*W,70+(i//cols)*H*2))
 sheet.save(O/(s['name']+'_contact.png'))
 animated=[]
 for i in range(s['n']):
  left=pairs[i].crop((0,0,W,H));right=pairs[i].crop((0,H,W,H*2));p=Image.new('RGB',(W*2,H+50),(20,22,26));p.paste(left,(0,50));p.paste(right,(W,50));dd=ImageDraw.Draw(p);dd.text((10,7),s['name']+f' frame {i:02d}: original / existing generated',font=font,fill='white');dd.text((10,29),'Equal 100ms/frame diagnostic preview; not a recovered original-engine timing claim.',font=small,fill='white');animated.append(p)
 animated[0].save(O/(s['name']+'_comparison.gif'),save_all=True,append_images=animated[1:],loop=0,duration=100,disposal=2)
 ss=dict(s);ss['frame_bounds']=records;ss['source_sha256']=hashlib.sha256((R/s['source']).read_bytes()).hexdigest();ss['generated_sha256']=hashlib.sha256((R/s['generated']).read_bytes()).hexdigest();metrics.append(ss)
(O/'comparison_manifest.json').write_text(json.dumps(metrics,indent=2))
print('Created:',', '.join(p.name for p in O.iterdir()))
