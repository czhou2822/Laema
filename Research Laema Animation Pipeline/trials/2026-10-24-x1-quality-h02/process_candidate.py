"""Export three corrected preparation drawings; preserve the H01 remainder."""
from pathlib import Path
import json,hashlib,time
import numpy as np
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parent;started=time.perf_counter()
source=Image.open(ROOT/'inputs/baseline-h01.png').convert('RGBA');raw=Image.open(ROOT/'raw/attempt02.png').convert('RGBA')
assert abs(raw.width/raw.height-510/270)<.02,'Reject mismatched crop geometry.'
normalized=raw.resize((510,270),Image.Resampling.LANCZOS)
normalized.save(ROOT/'outputs/generated-native-crops.png')
candidate=source.copy();unregistered=source.copy();records=[];new_tiles=[]
def sole(im,front):
 a=np.asarray(im)[:,:,3]>127;yy,xx=np.where(a&(np.indices(a.shape)[0]>=380)&((np.indices(a.shape)[1]>=224) if front else (np.indices(a.shape)[1]<224)))
 assert len(xx),'Missing boot contact region.'
 bottom=int(yy.max());row=xx[yy>=bottom-1]
 return np.array([float(np.median(row)),float(bottom)])
for i in range(3):
 frame=i+2;original=source.crop((frame%8*448-448,0,frame%8*448,448))
 piece=normalized.crop((i*170,0,(i+1)*170,270));proposal=Image.new('RGBA',(448,448));proposal.paste(piece,(140,140))
 unregistered.paste(proposal,((frame-1)*448,0))
 target_front=sole(original,True);before_front=sole(proposal,True);shift=np.rint(target_front-before_front).astype(int)
 registered=Image.new('RGBA',(448,448));registered.paste(proposal,tuple(shift))
 front=sole(registered,True);rear=sole(registered,False);rear_target=sole(original,False)
 registered.save(ROOT/'outputs'/f'frame{frame:02}-before-sole-cleanup.png')
 # Preserve the planted sole pixels instead of silently warping a leg. The
 # narrow transition is recorded, and pre-cleanup images remain inspectable.
 mask=Image.new('L',(448,448),255);m=np.asarray(mask).copy()
 for y in range(388,393):m[y,:]=round(255*(392-y)/4)
 m[393:,:]=0
 corrected=Image.composite(registered,original,Image.fromarray(m))
 assert np.array_equal(np.asarray(corrected)[393:],np.asarray(original)[393:])
 corrected.save(ROOT/'outputs'/f'frame{frame:02}-candidate.png');candidate.paste(corrected,((frame-1)*448,0));new_tiles.append(corrected)
 old,new=np.asarray(original),np.asarray(corrected)
 region=(slice(265,385),slice(150,300))
 records.append({'frame':frame,'translation_native_px':shift.tolist(),'front_sole_before':before_front.tolist(),'front_sole_target':target_front.tolist(),
 'front_registration_residual':(front-target_front).tolist(),'rear_registration_residual_before_sole_cleanup':(rear-rear_target).tolist(),
 'raw_rear_contact_registration_is_not_anatomical_validation':True,
 'source_sole_pixels_y393_to447_exact':True,'sole_transition_rows':[388,392],
 'body_alpha_pixels_changed':int(np.count_nonzero((old[region][:,:,3]>127)!=(new[region][:,:,3]>127))),
 'changed_rgba_pixels':int(np.count_nonzero(np.any(old!=new,axis=2)))})
candidate.save(ROOT/'outputs/x1-h02-preparation.png');unregistered.save(ROOT/'outputs/x1-h02-before-registration.png')
for i in range(16):
 box=(i%8*448,i//8*448,i%8*448+448,i//8*448+448)
 if i not in [1,2,3]:assert source.crop(box).tobytes()==candidate.crop(box).tobytes()
assert len({im.tobytes() for im in new_tiles})==3
body_pair=[]
for a,b in zip(new_tiles,new_tiles[1:]):
 aa=np.asarray(a)[265:385,150:300,3]>127;bb=np.asarray(b)[265:385,150:300,3]>127;body_pair.append(int(np.count_nonzero(aa!=bb)))
font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',15);board=Image.new('RGB',(840,620),'#17212c');d=ImageDraw.Draw(board)
for row in range(2):
 for i in range(3):
  tile=source.crop(((i+1)*448,0,(i+2)*448,448)) if row==0 else new_tiles[i]
  crop=tile.crop((140,140,310,410)).resize((189,300),Image.Resampling.NEAREST)
  board.paste(crop,(i*280+40,row*310+20),crop);d.text((i*280+5,row*310),f'{"H01 baseline" if row==0 else "H02 candidate"} · frame{i+2}',font=font,fill='white')
board.save(ROOT/'evidence/preparation-comparison.png')
exp=json.loads((ROOT/'experiment.json').read_text())
exp['actual_modifications']={'candidate':'outputs/x1-h02-preparation.png','candidate_sha256':hashlib.sha256((ROOT/'outputs/x1-h02-preparation.png').read_bytes()).hexdigest(),
 'changed_frames':records,'other_cells_exact':13,'all_key_times_unchanged':True,'one_common_crop_scale':510/raw.width,'raw_size':list(raw.size),
 'pairwise_core_body_silhouette_change_pixels':body_pair,'processing_seconds':time.perf_counter()-started,
 'scope':'Preparation whole-pose redraw; body/arm/shield/chamber placement may move. Release and recovery5–16 remain source-exact. Sole cleanup is explicit, not proof of perfect generated registration.'}
exp['generation_calls']=[
 {'attempt':1,'tool':'built-in image_gen','prompt':'prompts/attempt01.txt','inputs':['inputs/preparation-edit-target.png','inputs/original-preparation-guide.png'],'raw':'raw/attempt01.png','elapsed_wall_seconds_UTC_1s_resolution':30,'decision':'rejected','reason':'Guide landmark error and enlarged/reframed output'},
 {'attempt':2,'tool':'built-in image_gen','prompt':'prompts/attempt02.txt','inputs':['inputs/preparation-cropped-target.png','inputs/corrected-preparation-guide.png'],'raw':'raw/attempt02.png','elapsed_wall_seconds_UTC_1s_resolution':27,'decision':'exported for human review','model_revision':'not exposed','seed':'not exposed'}]
exp['agent_assessment']={'hypothesis_verdict':'pending_human_review','quality_improved':None,'observation':'Three preparation drawings now differ in core body silhouette. Native-speed power and transition quality require human judgment. Appearance/cuff/boot shape drift remains a review risk.'}
(ROOT/'experiment.json').write_text(json.dumps(exp,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'frames':records,'pairwise_core_body_silhouette_change':body_pair},indent=2))
