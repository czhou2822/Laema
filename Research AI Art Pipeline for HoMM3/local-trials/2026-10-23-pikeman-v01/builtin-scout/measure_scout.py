"""One recovered-master scout, fixed canvas normalization and timed weapon fallback."""
from pathlib import Path
import sys, json, hashlib, time, datetime
from PIL import Image, ImageDraw
import numpy as np
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
from compare import checker,metric,imposed,overlay,FONT,SMALL
BASE=HERE.parents[2]
raw=Image.open(HERE/'raw_unique_05.png').convert('RGBA')
original=Image.open(BASE/'a-restoration/nearest/crop/frame_05.png').convert('RGBA')
restored=Image.open(BASE/'a-restoration/realesrgan/crop/frame_05.png').convert('RGBA')
start=time.perf_counter()
normalized=raw.resize((292,208),Image.Resampling.LANCZOS)
normalized.save(HERE/'normalized_raw_05.png')
locked=imposed(normalized,original,original);locked.save(HERE/'source_alpha_05.png')
# Two manually chosen fixed rectangles on the documented group crop.
# They retain original weapon pixels before the rear hand and beyond the front hand.
# No fit, translation, hand deformation, extra frame or generated inpainting.
restore_mask=Image.new('L',(292,208));d=ImageDraw.Draw(restore_mask)
d.rectangle((74,129,115,143),fill=255)
d.rectangle((152,129,280,143),fill=255)
restore_mask.save(HERE/'weapon_restore_mask.png')
cleaned=locked.copy();cleaned.paste(restored,(0,0),restore_mask)
# The restored rectangles contain background as well; restore the exact source alpha.
cleaned=imposed(cleaned,original,original);cleaned.save(HERE/'weapon_fallback_05.png')
full=Image.new('RGBA',(900,800));full.paste(cleaned,(300,344));full.save(HERE/'candidate_full_frame_05.png')
names=['Source 2x','Supplied restoration','Raw edit / fixed scale','Source alpha imposed','Weapon fallback cleanup']
ims=[original,restored,normalized,locked,cleaned]
sheet=Image.new('RGB',(292*5,278),(20,24,29));sd=ImageDraw.Draw(sheet)
for j,(name,im) in enumerate(zip(names,ims)):
    panel=checker((292,208));panel.paste(im,(0,0),im);sheet.paste(panel,(j*292,35));sd.text((j*292+5,8),name,font=SMALL,fill='white')
    sd.text((j*292+5,249),'Frame05 only / source pose05',font=SMALL,fill='white')
sheet.save(HERE/'comparison_frame05.png')
o=overlay(original,normalized);o.save(HERE/'silhouette_overlay_05.png')
# Approximate analyst-identified source landmarks. Support alone does not identify anatomy.
landmarks={'head_center':[113,70],'rear_hand':[121,134],'front_hand':[146,136],'rear_boot_contact':[56,192],'front_boot_contact':[134,192],'pike_tip':[274,136]}
landmark_sheet=Image.new('RGB',(584,256),(20,24,29));ld=ImageDraw.Draw(landmark_sheet)
for j,im in enumerate([original,normalized]):
    p=checker((292,208));p.paste(im,(0,0),im);draw=ImageDraw.Draw(p)
    for label,(x,y) in landmarks.items():
        draw.line((x-4,y,x+4,y),fill=(255,216,60));draw.line((x,y-4,x,y+4),fill=(255,216,60))
    landmark_sheet.paste(p,(j*292,30));ld.text((j*292+5,7),['Source expected landmarks','Same coordinates over raw edit'][j],font=SMALL,fill='white')
ld.text((6,242),'Approximate source annotations; no per-frame correction.',font=SMALL,fill='white')
landmark_sheet.save(HERE/'landmarks_05.png')
elapsed=time.perf_counter()-start
metrics={'status':'executed single frame scout, not a complete animation','source_frame':5,'inputs':['../../../inputs/pose_05.png','../inputs/master_right_rgba.png'],'method':'Built-in image_gen, source pose plus recovered master reference; soft image/text constraints only','model_revision':None,'seed':None,'sampler':None,'backend_caveat':'Backend/version/seed unavailable; prompt/input bytes reproducible, output pixels not reproducible. Not Qwen, ControlNet or local GPU inference.','raw_size':raw.size,'normalization':f'Whole{raw.width}x{raw.height} canvas resized to292x208; same uniform frame convention as earlier B; no subject fitting or recentering. Aspect rounding disclosed.','raw_sha256':hashlib.file_digest((HERE/'raw_unique_05.png').open('rb'),'sha256').hexdigest(),'raw_vs_source':metric(normalized,original),'source_alpha_vs_source':metric(locked,original),'weapon_fallback_vs_source':metric(cleaned,original),'landmarks_source_crop_px':landmarks,'landmark_caveat':'Approximate analyst annotations, not candidate anatomical point estimates. Matching image support does not prove matching hands/feet.','cleanup':{'automated_export_seconds':elapsed,'manual_painting_seconds':0,'source_region_selection':'Two rectangles [74,129,115,143] and[152,129,280,143] in292x208 crop; original-restoration weapon pixels substituted, not newly drawn detail.','artist_time_to_accepted_result':None,'acceptance':'Unreviewed; not claimed complete.'}}
(HERE/'metrics.json').write_text(json.dumps(metrics,indent=2),encoding='utf-8')
print(json.dumps({'raw_size':raw.size,'raw_iou':metrics['raw_vs_source']['silhouette_iou'],'bottom_delta':metrics['raw_vs_source']['opaque_bottom_delta_px'],'automated_export_s':elapsed},indent=2))
