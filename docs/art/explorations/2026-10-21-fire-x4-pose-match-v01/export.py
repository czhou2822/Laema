from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import importlib.util,json,hashlib,shutil
OUT=Path(__file__).parent
WORK=Path(r'C:\Users\ckzhou\.codex\visualizations\2026\08\20\01a01d0a-ced6-77c0-a98a-e94ec3c5c10e')
spec=importlib.util.spec_from_file_location('gifhelper',WORK/'build-fire-defence-v02.py')
gifhelper=importlib.util.module_from_spec(spec);spec.loader.exec_module(gifhelper)
SOURCE=Path(r'C:\Users\ckzhou\.codex\generated_images\01a15c2d-53e5-7d43-9902-c8a8a8a42738\exec-2095728a-5a77-4f06-b2cd-b9f5f3247693.png')
FIRST=SOURCE.with_name('exec-79584e6e-c2c4-4a5b-bb3b-3c16dc241697.png')
POSE3=SOURCE.with_name('exec-13840720-de86-4d65-a250-272da3a38035.png')
SCALE=180/338
DURATIONS=[480,300,270,240,450]

def main():
    before=OUT/'before-isolated-pose3-correction'
    if not before.exists():
        before.mkdir()
        for name in ['frame-01.png','frame-02.png','frame-03.png','frame-04.png','frame-05.png','fire-x4-5x448.png','fire-x4-preview.gif','fire-x4-review.gif','original-vs-laema-x4.gif','original-vs-laema-x4-poses.png','metadata.json']:
            if (OUT/name).exists():shutil.copy2(OUT/name,before/name)
    shutil.copy2(FIRST,OUT/'generation-01.png');shutil.copy2(SOURCE,OUT/'generation-02-shield-correction.png')
    shutil.copy2(POSE3,OUT/'generation-03-isolated-pose3.png')
    source=Image.open(SOURCE).convert('RGBA')
    assert source.getchannel('A').getextrema()[0]==0
    cw,ch=round(source.width/3),round(source.height/2)
    frames=[];registration=[]
    for i in range(5):
        col,row=i%3,i//3
        rect=[round(col*source.width/3),round(row*source.height/2),round((col+1)*source.width/3),round((row+1)*source.height/2)]
        # Pose4's tip/trail overhangs into the otherwise empty left gutter of
        # pose5. Extract its whole pose; exclude only that detached neighbour
        # fragment from pose5, without painting or warping either drawing.
        if i==3:rect[2]+=48
        raw=source.crop(tuple(rect))
        if i==2:
            # The tool returned a square full-cell edit at a larger resolution.
            # Uniform whole-cell resampling restores the original512px canvas;
            # it is not per-pose anatomical normalization.
            raw=Image.open(POSE3).convert('RGBA').resize((512,512),Image.Resampling.LANCZOS)
        if i==4:
            clean=Image.new('RGBA',raw.size,(0,0,0,0))
            clean.alpha_composite(raw.crop((48,0,raw.width,raw.height)),(48,0))
            raw=clean
        alpha=raw.getchannel('A').point(lambda a:255 if a>=160 else 0)
        feet=alpha.crop((0,round(ch*.72),cw,ch)).getbbox()
        assert feet
        footx=(feet[0]+feet[2])/2
        footy=round(ch*.72)+feet[3]
        scaled=raw.resize((round(raw.width*SCALE),round(raw.height*SCALE)),Image.Resampling.LANCZOS)
        offset=(round(224-footx*SCALE),round(400-footy*SCALE))
        frame=Image.new('RGBA',(448,448),(0,0,0,0));frame.alpha_composite(scaled,offset)
        frame.save(OUT/f'frame-{i+1:02}.png');frames.append(frame)
        registration.append({'source_cell':[col,row],'source_rect':rect,'isolated_pose_source':'generation-03-isolated-pose3.png' if i==2 else None,'neighbour_gutter_excluded_left_px':48 if i==4 else 0,'source_foot_anchor':[footx,footy],'translation':offset,'alpha96_bounds':frame.getchannel('A').point(lambda a:255 if a>=96 else 0).getbbox()})
    strip=Image.new('RGBA',(2240,448),(0,0,0,0))
    for i,f in enumerate(frames):strip.alpha_composite(f,(i*448,0))
    strip.save(OUT/'fire-x4-5x448.png')
    gifhelper.save_gif(frames,OUT/'fire-x4-preview.gif',DURATIONS)
    originals=[]
    for i in range(5):
        f=Image.open(OUT/f'original-pose-{i+1:02}.png').convert('RGBA').resize((384,384),Image.Resampling.NEAREST)
        canvas=Image.new('RGBA',(448,448),(0,0,0,0));canvas.alpha_composite(f,(32,16));originals.append(canvas)
    font=ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf',22)
    small=ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf',14)
    comparison=[];new_reviews=[]
    crop=(64,112,416,416);target=(480,415)
    for i,(old,new) in enumerate(zip(originals,frames)):
        panel=Image.new('RGBA',(1024,512),'#29313a');draw=ImageDraw.Draw(panel)
        for col,(f,label) in enumerate([(old,'ORIGINAL X4'),(new,'LAEMA X4 — POSE-MATCH STUDY')]):
            x=col*512
            draw.text((x+16,12),label,fill='white',font=font)
            draw.text((x+16,43),f'POSE {i+1} / 5',fill='#b7cbd8',font=small)
            im=f.crop(crop).resize(target,Image.Resampling.NEAREST)
            panel.alpha_composite(im,(x+16,75))
        comparison.append(panel);new_reviews.append(panel.crop((512,0,1024,512)))
    gifhelper.save_gif(comparison,OUT/'original-vs-laema-x4.gif',DURATIONS)
    gifhelper.save_gif(new_reviews,OUT/'fire-x4-review.gif',DURATIONS)
    contact=Image.new('RGBA',(1600,790),'#29313a');d=ImageDraw.Draw(contact)
    for i,(old,new) in enumerate(zip(originals,frames)):
        x=i*320
        d.text((x+12,10),f'ORIGINAL — {i+1}',fill='white',font=small)
        d.text((x+12,404),f'LAEMA — {i+1}',fill='white',font=small)
        contact.alpha_composite(old.crop(crop).resize((320,276),Image.Resampling.NEAREST),(x,70))
        contact.alpha_composite(new.crop(crop).resize((320,276),Image.Resampling.NEAREST),(x,464))
    contact.convert('RGB').save(OUT/'original-vs-laema-x4-poses.png')
    checks={}
    for p in OUT.glob('*.gif'):
        gif=Image.open(p)
        for n in range(gif.n_frames):gif.seek(n);gif.convert('RGBA').load()
        assert gif.n_frames==5 and gif.info.get('loop')==0
        checks[p.name]={'size':gif.size,'frames':gif.n_frames,'loop':0}
    for i,f in enumerate(frames):
        assert f.size==(448,448) and f.mode=='RGBA'
        b=registration[i]['alpha96_bounds'];assert b[0]>0 and b[1]>0 and b[2]<448 and b[3]<448
    unchanged=[]
    for i in [1,2,4,5]:
        name=f'frame-{i:02}.png'
        assert (OUT/name).read_bytes()==(before/name).read_bytes(),f'Unrelated pose changed: {name}'
        unchanged.append(name)
    meta={'move':'Fire X4','historical_revision':'9f9d9bba','historical_texture':'assets/prototype/player/animation/earth_x4.png','native_source_frame_count':5,'original_native_times':[0,0.316763922,0.519705289,0.694283122,0.852665247],'export_frames':5,'frame_dimensions':[448,448],'strip_dimensions':[2240,448],'foot_anchor':[224,400],'shared_scale':SCALE,'registration':registration,'source_dimensions':source.size,'source_grid':[3,2],'source_cell_order_zero_based':[0,1,2,3,4],'review_durations_ms':DURATIONS,'checks':checks,'source_sha256':hashlib.sha256(SOURCE.read_bytes()).hexdigest(),'isolated_pose3_source_sha256':hashlib.sha256(POSE3.read_bytes()).hexdigest(),'unchanged_after_isolated_correction':unchanged,'runtime_integrated':False,'runtime_validated':False,'live_playback_reviewed':False,'fidelity_status':'review candidate; five original phase directions and turn-away restored, pose3 shield side corrected in isolated edit; exact silhouette/landmark fidelity not established','known_limits':['Source crops lower legs/tips; completed portions inferred.','Pose3 shield now appears on original screen-left side, but exact silhouette/occlusion is not pixel-matched.','Original arm reach, torso silhouette and knee bends differ at fine level.','Clothing/hair/weapon consistency is generated, not rig-locked.','Shared scaling and per-frame foot-root translation; no body warping or painting.']}
    (OUT/'metadata.json').write_text(json.dumps(meta,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'folder':str(OUT),'gif_checks':checks,'registration':registration},indent=2))

if __name__=='__main__':main()
