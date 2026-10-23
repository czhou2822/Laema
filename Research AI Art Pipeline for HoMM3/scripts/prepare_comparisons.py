"""Rebuild B/C packaging, measurements and cross-method visual diagnostics.

No model inference here. B/C raw images came from image_gen; their model seed and
version are unavailable. All coordinate normalization is recorded explicitly.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json, hashlib, shutil, numpy as np

ROOT=Path(__file__).resolve().parents[1]
manifest=json.loads((ROOT/'generation_manifest.json').read_text())
contract=json.loads((ROOT/'inputs/source_contract.json').read_text())
crop=contract['shared_crop']; target=(292,208)
mapping=[0,1,2,3,4,5,4,3,2,1]
font=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',14)
small=ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',12)
raw_sources={0:manifest['b00_path'],**{i['frame']:i['path'] for i in manifest['b_other_frames']}}
raw_sources={i:Path(p) if Path(p).exists() else ROOT/f'b-edit/raw/unique_{i:02d}.png' for i,p in raw_sources.items()}
packaging={'B':{'raw_dimensions':{},'normalization':'One whole-canvas Lanczos resize to292x208; no per-frame translation, crop-to-subject or deformation. Input aspect matches output to rounding. Source repeats reuse identical edited pixels.'},
 'C':{'normalization':'Raw sheet split on rounded equal5x2 grid. One fixed scale208/(raw_sheet_height/2), rounded width shared by all cells; horizontal letterbox centered in292x208 slot. No per-frame subject fitting, translation, or stretching.'}}
for sub in ['b-edit','c-strip']:
 for kind in ['raw','crop','full']:(ROOT/sub/kind).mkdir(parents=True,exist_ok=True)
for i,p in raw_sources.items():
 if p.resolve()!=(ROOT/f'b-edit/raw/unique_{i:02d}.png').resolve():shutil.copyfile(p,ROOT/f'b-edit/raw/unique_{i:02d}.png')
 packaging['B']['raw_dimensions'][i]=list(Image.open(p).size)
for i,j in enumerate(mapping):
 raw=Image.open(raw_sources[j]).convert('RGBA')
 image=raw.resize(target,Image.Resampling.LANCZOS)
 image.save(ROOT/f'b-edit/crop/frame_{i:02d}.png')
 full=Image.new('RGBA',(900,800));full.alpha_composite(image,(300,344));full.save(ROOT/f'b-edit/full/frame_{i:02d}.png')
cpath=Path(manifest['c_path'])
if not cpath.exists():cpath=ROOT/'c-strip/raw/sheet.png'
craw=Image.open(cpath).convert('RGBA')
if cpath.resolve()!=(ROOT/'c-strip/raw/sheet.png').resolve():shutil.copyfile(cpath,ROOT/'c-strip/raw/sheet.png')
packaging['C']['raw_dimensions']=list(craw.size)
cw,ch=craw.width/5,craw.height/2
ratio=208/ch; ow=round(cw*ratio);ox=(292-ow)//2
packaging['C']['slot_size']=[ow,208];packaging['C']['slot_offset']=[ox,0];packaging['C']['scale']=ratio
packaging['C']['raw_cell_border_alpha_gt127']=[]
for i in range(10):
 x=i%5;y=i//5
 box=(round(x*cw),round(y*ch),round((x+1)*cw),round((y+1)*ch))
 raw=craw.crop(box);raw.save(ROOT/f'c-strip/raw/cell_{i:02d}.png')
 a=np.asarray(raw.getchannel('A'))
 packaging['C']['raw_cell_border_alpha_gt127'].append({'frame':i,'left':int(np.sum(a[:,0]>127)),'right':int(np.sum(a[:,-1]>127)),'top':int(np.sum(a[0,:]>127)),'bottom':int(np.sum(a[-1,:]>127))})
 image=Image.new('RGBA',target);image.alpha_composite(raw.resize((ow,208),Image.Resampling.LANCZOS),(ox,0));image.save(ROOT/f'c-strip/crop/frame_{i:02d}.png')
 full=Image.new('RGBA',(900,800));full.alpha_composite(image,(300,344));full.save(ROOT/f'c-strip/full/frame_{i:02d}.png')
(ROOT/'packaging.json').write_text(json.dumps(packaging,indent=2))
grid=craw.copy();gd=ImageDraw.Draw(grid)
for x in range(1,5):gd.line((round(x*cw),0,round(x*cw),craw.height),fill=(255,50,65,255),width=3)
gd.line((0,round(ch),craw.width,round(ch)),fill=(255,50,65,255),width=3)
for i in range(10):gd.text((round(i%5*cw)+8,round(i//5*ch)+8),f'{i:02d}',font=font,fill=(255,255,255,255),stroke_width=2,stroke_fill=(0,0,0,255))
bg=Image.new('RGBA',grid.size,(35,39,43,255));bg.alpha_composite(grid);bg.convert('RGB').save(ROOT/'c-strip/grid_failure.png')

names=['Original 2x','A Real-ESRGAN','B Frame edit','C Whole sheet']
paths=[ROOT/'a-restoration/nearest/crop',ROOT/'a-restoration/realesrgan/crop',ROOT/'b-edit/crop',ROOT/'c-strip/crop']
sequences=[[Image.open(p/f'frame_{i:02d}.png').convert('RGBA') for i in range(10)] for p in paths]

def checker(size):
 im=Image.new('RGB',size,(49,53,58));d=ImageDraw.Draw(im)
 for y in range(0,size[1],16):
  for x in range(0,size[0],16):
   if (x//16+y//16)%2:d.rectangle((x,y,x+15,y+15),fill=(57,61,66))
 return im

def metric(im,src):
 a=np.asarray(im.getchannel('A')); s=np.asarray(src.getchannel('A'))
 mask=a>200; smask=s>200
 ys,xs=np.where(mask);sy,sx=np.where(smask)
 return {'silhouette_iou':float(np.sum(mask&smask)/max(1,np.sum(mask|smask))),
  'alpha_difference_pixels':int(np.count_nonzero(a!=s)),
  'opaque_bbox':list(Image.fromarray((mask*255).astype('uint8')).getbbox()),
  'centroid_delta_px':[float(xs.mean()-sx.mean()),float(ys.mean()-sy.mean())],
  'opaque_bottom_delta_px':int(ys.max()-sy.max()),
  'fractional_alpha_pixels':int(np.sum((a>0)&(a<255))),
  'border_nonzero_pixels':int(np.count_nonzero(a[0,:])+np.count_nonzero(a[-1,:])+np.count_nonzero(a[:,0])+np.count_nonzero(a[:,-1]))}

metrics={'contract':contract,'interpretation':'IoU is correspondence, not aesthetic quality. All masks threshold>200 excludes64/128-alpha source shadows consistently. B/C normalized by fixed documented packaging, never fit per subject. Bottom delta is opaque support baseline, not foot landmarks. No highres ground truth or perceptual quality score.', 'methods':{}}
for n,seq in zip(names,sequences):
 rec=[metric(im,sequences[0][i]) for i,im in enumerate(seq)]
 dup={f'{a}-{b}':seq[a].tobytes()==seq[b].tobytes() for a,b in [(1,9),(2,8),(3,7),(4,6)]}
 metrics['methods'][n]={'frames':rec,'mean_silhouette_iou':float(np.mean([x['silhouette_iou'] for x in rec])), 'bottom_delta_range':[min(x['opaque_bottom_delta_px'] for x in rec),max(x['opaque_bottom_delta_px'] for x in rec)],'duplicate_pairs_exact':dup}
(ROOT/'experiment_metrics.json').write_text(json.dumps(metrics,indent=2))

sheet=Image.new('RGB',(4*292,10*234+56),(23,26,30));d=ImageDraw.Draw(sheet)
for j,n in enumerate(names):d.text((j*292+10,12),n,font=font,fill='white')
for i in range(10):
 for j,seq in enumerate(sequences):
  panel=checker(target);panel.paste(seq[i],(0,0),seq[i]);sheet.paste(panel,(j*292,56+i*234))
  d.text((j*292+8,56+i*234+211),f'Frame {i:02d}  |  {i*100}-{(i+1)*100} ms',font=small,fill=(199,209,219))
sheet.save(ROOT/'comparison_all_methods.png')
key=Image.new('RGB',(1168,3*234+56),(23,26,30));d=ImageDraw.Draw(key)
for j,n in enumerate(names):d.text((j*292+10,12),n,font=font,fill='white')
for k,i in enumerate([0,4,5]):
 for j,seq in enumerate(sequences):
  panel=checker(target);panel.paste(seq[i],(0,0),seq[i]);key.paste(panel,(j*292,56+k*234))
  d.text((j*292+8,56+k*234+211),f'Frame {i:02d}',font=small,fill='white')
key.save(ROOT/'comparison_keyframes.png')
animations=[]; overlays=[]
for i in range(10):
 frame=Image.new('RGB',(1168,250),(23,26,30));d=ImageDraw.Draw(frame)
 ov=Image.new('RGB',(1168,250),(23,26,30));od=ImageDraw.Draw(ov)
 for j,(n,seq) in enumerate(zip(names,sequences)):
  panel=checker(target);panel.paste(seq[i],(0,0),seq[i]);frame.paste(panel,(j*292,36));d.text((j*292+7,8),f'{n}  / {i:02d}',font=font,fill='white')
  s=np.asarray(sequences[0][i].getchannel('A'))>200;a=np.asarray(seq[i].getchannel('A'))>200
  rgb=np.zeros((208,292,3),dtype='uint8');rgb[s]=[0,210,230];rgb[a]=[240,0,190];rgb[s&a]=[242,242,242]
  ov.paste(Image.fromarray(rgb),(j*292,36));od.text((j*292+7,8),f'{n}  / {i:02d}',font=font,fill='white')
 animations.append(frame);overlays.append(ov)
for filename,frames in [('comparison_animated',animations),('silhouette_overlay',overlays)]:
 frames[0].save(ROOT/f'{filename}.webp',save_all=True,append_images=frames[1:],duration=100,loop=0,lossless=True)
 frames[0].save(ROOT/f'{filename}.gif',save_all=True,append_images=frames[1:],duration=100,loop=0,optimize=False)
overlays[5].save(ROOT/'silhouette_overlay_frame05.png')
# Export atlas packing is mechanical; B/C remain failed fidelity candidates.
for sub in ['b-edit','c-strip']:
 atlas=Image.new('RGBA',(4*292,3*208))
 for i in range(10):atlas.alpha_composite(Image.open(ROOT/sub/f'crop/frame_{i:02d}.png'),(i%4*292,i//4*208))
 atlas.save(ROOT/sub/'diagnostic_atlas_4col.png')

check={}
for name in ['comparison_animated.webp','comparison_animated.gif','silhouette_overlay.webp']:
 im=Image.open(ROOT/name);dur=[]
 for i in range(im.n_frames):im.seek(i);im.load();dur.append(im.info.get('duration'))
 check[name]={'frames':im.n_frames,'durations_ms':dur,'size':im.size}
(ROOT/'preview_checks.json').write_text(json.dumps(check,indent=2))
print(json.dumps({'packaging':packaging,'metrics':{k:{z:v for z,v in m.items() if z!='frames'} for k,m in metrics['methods'].items()},'playback':check},indent=2))
