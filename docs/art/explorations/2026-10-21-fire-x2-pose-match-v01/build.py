from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageFilter,ImageChops
import subprocess,io,json,shutil,importlib.util,hashlib

OUT=Path(__file__).parent
ROOT=OUT.parents[3]
WORK=Path(r'C:\Users\ckzhou\.codex\visualizations\2026\08\20\01a01d0a-ced6-77c0-a98a-e94ec3c5c10e')

def prepare():
    shutil.copy2(WORK/'x1-pose-match-reference/laema-appearance-only.png',OUT/'appearance-reference.png')
    data=subprocess.check_output(['git','show','9f9d9bba:assets/prototype/player/animation/earth_x2.png'],cwd=ROOT)
    (OUT/'original-x2-128-atlas.png').write_bytes(data)
    atlas=Image.open(io.BytesIO(data)).convert('RGBA')
    grid=Image.new('RGBA',(1536,512),(0,0,0,0))
    for i in range(3):
        f=atlas.crop((i*128,0,(i+1)*128,128)).resize((384,384),Image.Resampling.NEAREST)
        cell=Image.new('RGBA',(512,512),(0,0,0,0));cell.alpha_composite(f,(64,0));cell.save(OUT/f'original-pose-{i+1}.png')
        grid.alpha_composite(cell,(i*512,0))
    grid.save(OUT/'original-x2-pose-authority.png')
    grey=Image.new('RGBA',grid.size,'#505961');grey.alpha_composite(grid);grey.convert('RGB').save(OUT/'original-x2-pose-authority-grey.png')
    print(OUT)

def export():
    source_path=Path(r'C:\Users\ckzhou\.codex\generated_images\01a15c2c-ef9a-7092-8a1e-2e2d404c37e3\exec-8b1002ea-ae4f-4f51-88cc-f2364d6d5d5b.png')
    shutil.copy2(source_path,OUT/'source-three-pose-sheet.png')
    source=Image.open(source_path).convert('RGBA')
    sw,sh=source.width//3,source.height
    assert source.width%3==0 and source.getchannel('A').getextrema()[0]==0
    raw=[source.crop((i*sw,0,(i+1)*sw,sh)) for i in range(3)]
    spec=importlib.util.spec_from_file_location('oldexport',WORK/'build-fire-defence-v02.py')
    helper=importlib.util.module_from_spec(spec);spec.loader.exec_module(helper)
    analyses=[]
    for f in raw:
        box,fx,fy=helper.analyse(f)
        mask=f.getchannel('A').point(lambda a:255 if a>=160 else 0)
        # Both perspective-offset boots belong to the stance root; the lowest
        # 10px alone would capture only the nearer boot and shift the whole body.
        band=mask.crop((0,max(0,fy-round((fy-box[1])*.22)),sw,fy)).getbbox()
        fx=(band[0]+band[2])/2
        analyses.append((box,fx,fy))
    heights=[a[2]-a[0][1] for a in analyses]
    # Shared scale; no independent pose fitting or repainting. Detached white
    # motion strokes are deliberately retained, unlike component-isolated guards.
    scale=180/sorted(heights)[1]
    frames=[]
    for i,(f,(box,fx,fy)) in enumerate(zip(raw,analyses)):
        r=f.resize((round(sw*scale),round(sh*scale)),Image.Resampling.LANCZOS)
        native=Image.new('RGBA',(448,448),(0,0,0,0))
        native.alpha_composite(r,(round(224-fx*scale),round(400-fy*scale)))
        native.save(OUT/f'frame-{i+1:02}.png');frames.append(native)
    strip=Image.new('RGBA',(1344,448),(0,0,0,0))
    for i,f in enumerate(frames):strip.alpha_composite(f,(i*448,0))
    strip.save(OUT/'fire-x2-3x448.png')
    durations=[680,440,380]
    helper.save_gif(frames,OUT/'fire-x2-preview.gif',durations)
    font=ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf',19)
    small=ImageFont.truetype(r'C:\Windows\Fonts\segoeui.ttf',14)
    original=Image.open(OUT/'original-x2-128-atlas.png').convert('RGBA')
    native_old=[]
    for i in range(3):
        # Presentation aligns visible hip/head region; original feet do not exist
        # in the retained source, so no old foot-root equivalence is claimed.
        f=original.crop((i*128,0,(i+1)*128,128)).resize((256,256),Image.Resampling.NEAREST)
        old=Image.new('RGBA',(448,448),(0,0,0,0));old.alpha_composite(f,(96,90));native_old.append(old)
    panels=[]
    for i,(old,new) in enumerate(zip(native_old,frames)):
        bg=Image.new('RGBA',(896,500),'#29313a')
        d=ImageDraw.Draw(bg);d.text((16,12),'ORIGINAL X2',font=font,fill='white');d.text((464,12),'LAEMA X2 — POSE-MATCH STUDY',font=font,fill='white')
        d.text((16,40),f'POSE {i+1} / original lower legs cropped',font=small,fill='#b5c6d5')
        d.text((464,40),'Completed boots are inferred',font=small,fill='#b5c6d5')
        bg.alpha_composite(old,(0,52));bg.alpha_composite(new,(448,52));panels.append(bg)
    helper.save_gif(panels,OUT/'original-vs-laema-x2.gif',durations)
    contact=Image.new('RGBA',(1344,1000),'#29313a')
    for i,(old,new) in enumerate(zip(native_old,frames)):
        contact.alpha_composite(old,(i*448,52));contact.alpha_composite(new,(i*448,552))
    d=ImageDraw.Draw(contact);d.text((16,12),'ORIGINAL X2 — three native key poses, lower legs cropped in source',font=font,fill='white')
    d.text((16,512),'LAEMA X2 — same leftward sweep; review candidate, not exact trace',font=font,fill='white')
    contact.convert('RGB').save(OUT/'original-vs-laema-x2.png')
    checks={}
    for name in ['fire-x2-preview.gif','original-vs-laema-x2.gif']:
        gif=Image.open(OUT/name)
        for n in range(gif.n_frames):gif.seek(n);gif.convert('RGBA').load()
        checks[name]={'size':list(gif.size),'frames':gif.n_frames,'loop':gif.info.get('loop')}
        assert gif.n_frames==3 and gif.info.get('loop')==0
    bounds=[f.getchannel('A').point(lambda a:255 if a>=96 else 0).getbbox() for f in frames]
    assert all(b[0]>0 and b[1]>0 and b[2]<448 and b[3]<448 for b in bounds)
    metadata={'status':'review candidate only; no runtime integration','historical_revision':'9f9d9bba','historical_animation':'config/attack_animations/fire_x2.tres','historical_texture':'assets/prototype/player/animation/earth_x2.png','native_key_times':[0,0.456246036,0.748549508],'original_frame_count':3,'frame_count':3,'frame_size':[448,448],'atlas_size':[1344,448],'foot_anchor':[224,400],'shared_scale':scale,'target_body_height':180,'review_durations_ms':durations,'source_dimensions':list(source.size),'selected_source':source_path.name,'generated_sources':['exec-09fd5817-6bda-49e3-a2c3-af02c9c3324f.png','exec-fa7837a3-0a90-4a14-8a35-156011e6b660.png',source_path.name],'bounds':[list(b) for b in bounds],'qa':checks,'known_limits':['Original lower legs and feet are cropped; completed boots inferred.','Visible pose/sword directions are matched approximately, not traced pixel-exactly.','First pose still crouches slightly more than original; fine shoulder, shield and wrist angles require review.','White crescent is still thicker than original thin pixel strokes.','One global scale and foot translation do not guarantee identical generated anatomy.'],'runtime_validated':False,'live_playback_reviewed':False}
    (OUT/'metadata.json').write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(metadata,indent=2))

if __name__=='__main__':
    import sys
    if len(sys.argv)>1 and sys.argv[1]=='export':export()
    else:prepare()
