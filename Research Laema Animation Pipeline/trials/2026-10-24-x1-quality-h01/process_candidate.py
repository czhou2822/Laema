"""Normalize the AI crop strip, register at fixed guards, composite bounded edits."""
from pathlib import Path
import json,hashlib,time
import numpy as np
from PIL import Image,ImageDraw,ImageFilter,ImageFont
ROOT=Path(__file__).resolve().parent
started=time.perf_counter()
spec=json.loads((ROOT/'inputs/construction.json').read_text())
baseline=Image.open(ROOT/'inputs/baseline-v08.png').convert('RGBA')
raw=Image.open(ROOT/'raw/attempt01.png').convert('RGBA')
assert abs(raw.width/raw.height-3)<.02,'Reject the layout instead of stretching anatomy.'
normalized=raw.resize((384,128),Image.Resampling.LANCZOS)
normalized.save(ROOT/'outputs/generated-crops-native.png')
candidate=baseline.copy();records=[];font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',15)
proof=Image.new('RGB',(1200,580),'#17212c');pd=ImageDraw.Draw(proof)
for col,k in enumerate(spec['keys']):
 index=k['key']-1;origin=(index%8*448,index//8*448)
 source=baseline.crop((*origin,origin[0]+448,origin[1]+448))
 native=normalized.crop((col*128,0,(col+1)*128,128))
 gx,gy=k['guard'];region=(slice(max(208,gy-14),min(336,gy+11)),slice(max(196,gx-17),min(324,gx+17)))
 def gold(im):
  a=np.asarray(im).astype(float);r,g,b=a[:,:,:3].transpose(2,0,1)
  return (a[:,:,3]>100)&(r>g*1.08)&(g>b*1.65)&(g>65)&(b<135)
 source_gold=gold(source)[region];best=None
 for dy in range(-7,8):
  for dx in range(-7,8):
   proposal=Image.new('RGBA',(448,448));proposal.paste(native,(196+dx,208+dy))
   target_gold=gold(proposal)[region]
   dice=2*np.count_nonzero(source_gold&target_gold)/max(1,np.count_nonzero(source_gold)+np.count_nonzero(target_gold))
   score=dice-.001*(abs(dx)+abs(dy))
   if best is None or score>best[0]:best=(score,dx,dy,dice)
 _,dx,dy,dice=best
 proposal=Image.new('RGBA',(448,448));proposal.paste(native,(196+dx,208+dy))
 proposal.save(ROOT/'outputs'/f'key{k["key"]:02}-registered-proposal.png')
 mask=Image.new('L',(448,448));ImageDraw.Draw(mask).polygon([tuple(p) for p in k['mask']],fill=255)
 mask=mask.filter(ImageFilter.GaussianBlur(.65))
 m=np.array(mask);yy,xx=np.mgrid[:448,:448];axis=k['blade_axis']
 protected=((xx-gx)*axis[0]+(yy-gy)*axis[1]>=-2.5)
 px,py=k['pommel'];protected|=((xx-px)**2+(yy-py)**2<=2.5**2)
 m[protected]=0;mask=Image.fromarray(m)
 mask.save(ROOT/'outputs'/f'key{k["key"]:02}-edit-mask.png')
 corrected=Image.composite(proposal,source,mask)
 corrected.save(ROOT/'outputs'/f'key{k["key"]:02}-candidate.png')
 old,new=np.asarray(source),np.asarray(corrected)
 assert np.array_equal(old[m==0],new[m==0])
 assert np.array_equal(old[protected],new[protected])
 changed=np.any(old!=new,axis=2)
 records.append({'key':k['key'],'translation_native_px':[dx,dy],'guard_gold_template_dice':dice,
                 'registration':'Translation only maximizing fixed-guard gold overlap; one common strip scale, no per-key rescale or anatomical warp.',
                 'changed_rgba_pixels':int(changed.sum()),'alpha_silhouette_pixels_changed':int(np.count_nonzero((old[:,:,3]>127)!=(new[:,:,3]>127))),
                 'outside_mask_rgba_exact':True,'protected_blade_guard_halfplane_and_pommel_exact':True})
 candidate.paste(corrected,origin)
 for row,img in enumerate([source,corrected]):
  crop=img.crop((196,220,296,320)).resize((400,400),Image.Resampling.NEAREST)
  # Crops overlap vertically only in source data; review board uses two200px rows.
  crop=img.crop((196,230,296,300)).resize((400,280),Image.Resampling.NEAREST)
  proof.paste(crop,(col*400,row*290+20),crop)
  pd.text((col*400+6,row*290),f'{"v08 baseline" if row==0 else "H01 candidate"} · drawing{k["key"]}',font=font,fill='white')
candidate.save(ROOT/'outputs/x1-h01-grip-continuity.png')
proof.save(ROOT/'evidence/arm-comparison-4x.png')
edited={4,5,6}
for i in range(16):
 box=(i%8*448,i//8*448,i%8*448+448,i//8*448+448)
 if i not in edited:assert baseline.crop(box).tobytes()==candidate.crop(box).tobytes()
clip=json.loads((ROOT.parent/'2026-10-23-x1-structural-grip-v08/outputs/clips.json').read_text())['clips'][2]
exp=json.loads((ROOT/'experiment.json').read_text())
assert exp['baseline']['times']==clip['times']
exp['actual_modifications']={'keys':records,'other_cells_exact':13,'saved_key_times_exact':True,
 'candidate':'outputs/x1-h01-grip-continuity.png','raw_size':list(raw.size),'one_strip_scale_to_native':128/raw.height,
 'bounds':'Explicit polygons with feathered edges. Source alpha is allowed to change inside them; protected source pixels are restored exactly.',
 'processing_seconds':time.perf_counter()-started}
exp['technical_result']='Candidate exported; scope preservation passes. Anatomical correctness and quality are not established by these assertions.'
exp['generation_calls']=[{'tool':'built-in image_gen','model_revision':'not exposed','seed':'not exposed',
 'prompt':'prompts/attempt01.txt','inputs':['inputs/release-arms-edit-target-4x.png','inputs/release-grip-construction.png'],
 'raw':'raw/attempt01.png','started_at_utc':'2026-10-24T03:43:53Z','completed_at_utc':'2026-10-24T03:44:21Z',
 'elapsed_wall_seconds_UTC_1s_resolution':28,'human_artist_labor':False}]
(ROOT/'experiment.json').write_text(json.dumps(exp,indent=2)+'\n',encoding='utf-8')
print(json.dumps(records,indent=2))
