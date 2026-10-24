"""Fixed-coordinate exports, raw RGB diagnostics and synchronized review.

Source masks are imposed derivatives, never evidence that a model preserved alpha.
No frame-wise recentering, scale fitting, deformation or motion interpolation.
"""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import json, hashlib, time, math
import numpy as np

HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]
MAP=[0,1,2,3,4,5,4,3,2,1]
SIZE=(292,208)
FONT=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',14)
SMALL=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',12)

def sha(p):return hashlib.file_digest(p.open('rb'),'sha256').hexdigest()
def save(p,obj):p.write_text(json.dumps(obj,indent=2),encoding='utf-8')

def checker(size):
    im=Image.new('RGB',size,(48,52,58));d=ImageDraw.Draw(im)
    for y in range(0,size[1],12):
        for x in range(0,size[0],12):
            if (x//12+y//12)%2:d.rectangle((x,y,x+11,y+11),fill=(60,64,70))
    return im

def foreground(rgb):
    a=np.asarray(rgb.convert('RGB')).astype(np.int16)
    corners=np.concatenate([a[:8,:8].reshape(-1,3),a[-8:,:8].reshape(-1,3),a[:8,-8:].reshape(-1,3),a[-8:,-8:].reshape(-1,3)])
    bg=np.median(corners,axis=0)
    # This is a threshold diagnostic; no claim of native/model-produced alpha.
    m=np.max(np.abs(a-bg),axis=-1)>24
    return Image.fromarray((m*255).astype(np.uint8)),bg.tolist()

def metric(im,source):
    a=np.asarray(im.getchannel('A'));s=np.asarray(source.getchannel('A'))
    m=a>200;sm=s>200
    yy,xx=np.where(m);sy,sx=np.where(sm)
    return {'silhouette_iou':float(np.sum(m&sm)/max(1,np.sum(m|sm))),
            'alpha_changed_pixels':int(np.sum(a!=s)),
            'opaque_bottom_delta_px':int(yy.max()-sy.max()) if len(yy) else None,
            'centroid_delta_px':[float(xx.mean()-sx.mean()),float(yy.mean()-sy.mean())] if len(yy) else None,
            'opaque_bbox':Image.fromarray((m*255).astype('uint8')).getbbox(),
            'foreground_outside_source_px':int(np.sum(m&~sm)),
            'source_opaque_without_candidate_px':int(np.sum(sm&~m)),
            'diagnostic_foreground_border_pixels':int(m[0,:].sum()+m[-1,:].sum()+m[:,0].sum()+m[:,-1].sum())}

def imposed(rgb,source,nearest):
    a=np.asarray(source.getchannel('A'))
    arr=np.array(rgb.convert('RGBA'))
    arr[:,:,3]=a
    shadow=(a>0)&(a<=200)
    original=np.asarray(nearest)
    arr[shadow,:3]=original[shadow,:3]
    arr[a==0,:3]=0
    return Image.fromarray(arr)

def export_method(method):
    folder=HERE/method
    available=[i for i in range(6) if (folder/f'raw/unique_{i:02d}.png').exists()]
    if not available:return None
    for name in ['diagnostic','source-alpha/crop','source-alpha/full']:(folder/name).mkdir(exist_ok=True,parents=True)
    records=[]
    for i in available:
        start=time.perf_counter()
        raw=Image.open(folder/f'raw/unique_{i:02d}.png').convert('RGB')
        expected=(1216,832) if method=='reference-2x' else (608,416)
        assert raw.size==expected
        if method=='reference-2x':raw=raw.resize((608,416),Image.Resampling.LANCZOS)
        rgb=raw.crop((12,0,596,416)).resize(SIZE,Image.Resampling.LANCZOS)
        mask,bg=foreground(raw)
        diag=raw.convert('RGBA');diag.putalpha(mask)
        diag=diag.crop((12,0,596,416)).resize(SIZE,Image.Resampling.LANCZOS)
        diag.save(folder/f'diagnostic/unique_{i:02d}.png')
        original=Image.open(BASE/f'a-restoration/nearest/crop/frame_{i:02d}.png').convert('RGBA')
        input_file=f'pose_{i:02d}_gray.png' if method.startswith('reference') else f'restored_{i:02d}_gray.png'
        initial=Image.open(HERE/'inputs'/input_file).convert('RGB')
        initial_mask,initial_bg=foreground(initial)
        initial_diag=initial.convert('RGBA');initial_diag.putalpha(initial_mask)
        initial_diag=initial_diag.crop((12,0,596,416)).resize(SIZE,Image.Resampling.LANCZOS)
        initial_rgb=np.asarray(initial.crop((12,0,596,416)).resize(SIZE,Image.Resampling.LANCZOS)).astype(np.int16)
        delta=np.abs(np.asarray(rgb).astype(np.int16)-initial_rgb)
        opaque=np.asarray(original.getchannel('A'))>200
        output_bg_like=np.max(np.abs(np.asarray(rgb).astype(np.float32)-np.array(bg)),axis=-1)<=8
        input_bg_like=np.max(np.abs(initial_rgb.astype(np.float32)-np.array(initial_bg)),axis=-1)<=8
        candidate=imposed(rgb,original,original)
        candidate.save(folder/f'source-alpha/crop/unique_{i:02d}.png')
        full=Image.new('RGBA',(900,800));full.paste(candidate,(300,344));full.save(folder/f'source-alpha/full/unique_{i:02d}.png')
        records.append({'unique_frame':i,'diagnostic_foreground_rule':'max channel distance >24 from median RGB of four8x8 corners; not semantic segmentation','estimated_background_rgb':bg,
                        'raw_diagnostic':metric(diag,original),'input_same_foreground_diagnostic':metric(initial_diag,original),'source_alpha_derivative':metric(candidate,original),
                        'opaque_rgb_mean_absolute_change_8bit':float(delta[opaque].mean()),'source_opaque_pixels_near_output_background_fraction':float(output_bg_like[opaque].mean()),'source_opaque_pixels_near_input_background_fraction':float(input_bg_like[opaque].mean()),'opaque_pixels_changed_by_gt8_any_channel_fraction':float(np.mean(np.max(delta,axis=-1)[opaque]>8)),
                        'automated_export_seconds':time.perf_counter()-start,'manual_drawing_cleanup_seconds':0,
                        'cleanup_caveat':'Artist anatomy/color/edge repair and acceptance still unmeasured. Applying a mask is automated packaging, not artist cleanup.'})
    complete=available==list(range(6))
    if complete:
        for i,j in enumerate(MAP):
            for kind in ['crop','full']:
                src=folder/f'source-alpha/{kind}/unique_{j:02d}.png'
                dst=folder/f'source-alpha/{kind}/frame_{i:02d}.png'
                dst.write_bytes(src.read_bytes())
        atlas=Image.new('RGBA',(3600,2400))
        for i in range(10):atlas.paste(Image.open(folder/f'source-alpha/full/frame_{i:02d}.png'),((i%4)*900,(i//4)*800))
        atlas.save(folder/'source-alpha/attack_4col.png')
        contract=json.loads((BASE/'inputs/source_contract.json').read_text())
        animation={'creature':'CPKMAN','group':12,'block':11,'count':10,'unique_count':6,'map':MAP,'source_canvas':[450,400],'export_canvas':[900,800],'export_scale':2,'anchor':[392,536],'duration_ms':1000,'frame_duration_ms':[100]*10,'timing_status':'Provisional equal dwell; original executable frame timing unresolved.','frames':[{'index':i,'source_unique':j,'source_name':contract['source_frames'][i]['name'],'source_index_sha256':contract['source_frames'][i]['index_sha256'],'source_original_rect':{k:contract['source_frames'][i][k] for k in ['left','top','width','height']},'file':f'full/frame_{i:02d}.png'} for i,j in enumerate(MAP)],'acceptance':'Research candidate; user review required; not a replacement for current runtime atlas format.'}
        save(folder/'source-alpha/animation.json',animation)
        checks={'timeline_count':10,'mapping':MAP,'full_canvas':[900,800],'atlas_columns':4,'atlas_rows':3,'source_native_offsets_preserved_by_uniform_scale':2,
                'fixed_crop_origin':[300,344],'anchor':[392,536],'unused_cells':2,'per_frame_transform':False,
                'duplicates':{f'{a}-{b}':sha(folder/f'source-alpha/full/frame_{a:02d}.png')==sha(folder/f'source-alpha/full/frame_{b:02d}.png') for a,b in [(1,9),(2,8),(3,7),(4,6)]},
                'alpha_exact':all(np.array_equal(np.asarray(Image.open(folder/f'source-alpha/full/frame_{i:02d}.png').getchannel('A')),np.asarray(Image.open(BASE/f'a-restoration/nearest/full/frame_{i:02d}.png').getchannel('A'))) for i in range(10)),
                'timing':'100ms equal dwells for comparison only; original dwell unresolved','acceptance':'Awaiting user visual review'}
        save(folder/'export-checks.json',checks)
    result={'method':method,'complete_ten_frame_sequence':complete,'unique_frames_executed':available,'measurements':records,'model':'model_lock.json','mask_warning':'Source alpha imposes IoU1; inspect raw diagnostic for actual model drift.'}
    save(folder/'metrics.json',result)
    return result

def registered_current():
    atlas=Image.open(BASE.parent/'assets/prototype/enemy/pikeman/repaint_v02/attack_right_sheet.png').convert('RGBA')
    s=148/180
    frames=[]
    for i in range(10):
        cell=atlas.crop(((i%4)*768,(i//4)*512,(i%4+1)*768,(i//4+1)*512))
        # Map source anchor(384,448) to diagnostic(92,192) with one group scale.
        out=cell.transform(SIZE,Image.Transform.AFFINE,(1/s,0,384-92/s,0,1/s,448-192/s),Image.Resampling.BICUBIC)
        frames.append(out)
    return frames

def overlay(src,candidate):
    sm=np.asarray(src.getchannel('A'))>200;m=np.asarray(candidate.getchannel('A'))>200
    a=np.zeros((208,292,4),dtype=np.uint8)
    a[sm]=[0,210,225,210];a[m]=[235,30,180,210];a[sm&m]=[235,240,245,240]
    im=checker(SIZE).convert('RGBA');im.alpha_composite(Image.fromarray(a));d=ImageDraw.Draw(im)
    d.line((92,0,92,207),fill=(255,210,50,160));d.line((0,192,291,192),fill=(255,210,50,160))
    return im.convert('RGB')

def build_review():
    source=[Image.open(BASE/f'a-restoration/nearest/crop/frame_{i:02d}.png').convert('RGBA') for i in range(10)]
    seqs={'Source 2x':source,'Supplied restoration':[Image.open(BASE/f'a-restoration/realesrgan/crop/frame_{i:02d}.png').convert('RGBA') for i in range(10)],'Existing repaint (original mapping)':registered_current(),'Earlier proxy edit':[Image.open(BASE/f'b-edit/crop/frame_{i:02d}.png').convert('RGBA') for i in range(10)]}
    for method in ['reference','masked','masked-full']:
        p=HERE/method/'source-alpha/crop'
        if (p/'frame_09.png').exists():
            rawseq=[]
            for j in MAP:
                raw=Image.open(HERE/method/f'raw/unique_{j:02d}.png').convert('RGB')
                rawseq.append(raw.crop((12,0,596,416)).resize(SIZE,Image.Resampling.LANCZOS).convert('RGBA'))
            seqs['Qwen '+method+' / raw RGB']=rawseq
            seqs['Qwen '+method+' / alpha imposed']=[Image.open(p/f'frame_{i:02d}.png').convert('RGBA') for i in range(10)]
    baseline_metrics={}
    for name,seq in seqs.items():
        rows=[metric(im,source[i]) for i,im in enumerate(seq)]
        baseline_metrics[name]={'frames':rows,'mean_iou':float(np.mean([x['silhouette_iou'] for x in rows])),'duplicates':{f'{a}-{b}':seq[a].tobytes()==seq[b].tobytes() for a,b in [(1,9),(2,8),(3,7),(4,6)]},'iou_caveat':'Correspondence only; exact alpha derivatives impose geometry. Not an aesthetic score.'}
    save(HERE/'comparison_metrics.json',baseline_metrics)
    # Every row has exactly the same source frame, timeline position and fixed transform.
    names=list(seqs);w=292*len(names);h=52+234*10
    sheet=Image.new('RGB',(w,h),(20,24,29));d=ImageDraw.Draw(sheet)
    for j,name in enumerate(names):d.text((j*292+6,8),name,font=SMALL,fill='white')
    rendered=[];overlays=[]
    for i in range(10):
        row=Image.new('RGB',(w,246),(20,24,29));rd=ImageDraw.Draw(row)
        ov=Image.new('RGB',(w,246),(20,24,29));od=ImageDraw.Draw(ov)
        for j,name in enumerate(names):
            im=seqs[name][i];p=checker(SIZE);p.paste(im,(0,0),im)
            sheet.paste(p,(j*292,52+i*234));d.text((j*292+6,52+i*234+211),f'Frame {i:02d} -> source {MAP[i]:02d}',font=SMALL,fill='white')
            row.paste(p,(j*292,28));rd.text((j*292+6,4),name,font=SMALL,fill='white')
            ov.paste(overlay(source[i],im),(j*292,28));od.text((j*292+6,4),name,font=SMALL,fill='white')
        rendered.append(row);overlays.append(ov)
    sheet.save(HERE/'comparison_all_frames.png')
    rendered[0].save(HERE/'comparison_sync.webp',save_all=True,append_images=rendered[1:],duration=[100]*10,loop=0,lossless=True)
    rendered[0].save(HERE/'comparison_sync.gif',save_all=True,append_images=rendered[1:],duration=[100]*10,loop=0,disposal=2)
    overlays[0].save(HERE/'silhouette_sync.webp',save_all=True,append_images=overlays[1:],duration=[100]*10,loop=0,lossless=True)
    key=Image.new('RGB',(w,246*3),(20,24,29))
    for k,i in enumerate([0,4,5]):key.paste(rendered[i],(0,246*k))
    key.save(HERE/'keyframes.png')
    assets=HERE/'review-assets';assets.mkdir(exist_ok=True)
    entries=[]
    for j,(name,seq) in enumerate(seqs.items()):
        files=[]
        for i,im in enumerate(seq):
            p=assets/f'{j}_{i:02d}.png';im.save(p);files.append(p.relative_to(HERE).as_posix())
        entries.append({'name':name,'frames':files})
    review={'entries':entries,'frame_ms':[100]*10,'map':MAP,'acceptance':'No method accepted. Visual review requested.','coordinate_contract':'Fixed crop [150,172,296,276],2x; anchor(92,192). Yellow axes mark expected anchor/ground. No recentering.','timing_caveat':'100ms per frame is provisional, not recovered original executable timing.'}
    save(HERE/'review-data.json',review)
    data=json.dumps(review)
    html='''<!doctype html><meta charset="utf-8"><title>Pikeman local controlled trials</title>
<style>body{font:16px system-ui;background:#161c24;color:#e3ebf4;margin:24px}button,select,input{font:inherit}button,select{padding:8px;background:#263443;color:white;border:1px solid #58718d;border-radius:6px}#panels{display:flex;flex-wrap:wrap;gap:16px}figure{margin:0;padding:12px;background:#222b36;border-radius:10px}canvas{image-rendering:auto;background-color:#383e46;background-image:conic-gradient(#30363e 25%,transparent 0 50%,#30363e 0 75%,transparent 0);background-size:24px 24px;max-width:100%}label{margin-right:20px}.note{color:#ffc666;max-width:1000px}p{max-width:1000px;line-height:1.5}</style>
<h1>Pikeman: controlled local trials</h1><p class="note">Research candidates only. Production assets remain unchanged. Source-alpha derivatives impose silhouette; they do not prove raw model adherence. Original per-frame timing remains unresolved.</p>
<p><button id="play">Pause</button> <label>Frame <input id="frame" type="range" min="0" max="9" value="0"> <b id="readout"></b></label><label><input id="overlay" type="checkbox">Source silhouette + anchor</label><label>Zoom <select id="zoom"><option value="1">1x exported pixels</option><option value="2">2x</option><option value="1.216216216">180px body gameplay size</option></select></label><label>Matte <select id="bg"><option value="checker">Checker</option><option value="#fff">White</option><option value="#090b10">Dark</option><option value="#606b49">Green</option></select></label></p>
<p>Shared playback: 10 x 100ms, a comparison assumption. Repeats: [0,1,2,3,4,5,4,3,2,1]. See <a href="comparison_all_frames.png">all frames</a>, <a href="silhouette_sync.webp">silhouettes</a>, <a href="REPORT.md">report</a> and the raw PNGs/workflows in each trial folder.</p><div id="panels"></div>
<script>const D=DATA;let frame=0,playing=true,last=performance.now();const imgs=D.entries.map(e=>e.frames.map(u=>{let i=new Image();i.src=u;return i}));const canvases=D.entries.map(e=>{let f=document.createElement('figure'),t=document.createElement('figcaption'),c=document.createElement('canvas');t.textContent=e.name;c.width=292;c.height=208;f.append(t,c);panels.append(f);return c});const mask=document.createElement('canvas');mask.width=292;mask.height=208;function draw(){readout.textContent=String(frame).padStart(2,'0')+' / source '+D.map[frame];document.getElementById('frame').value=frame;canvases.forEach((c,j)=>{let x=c.getContext('2d');x.clearRect(0,0,292,208);if(imgs[j][frame].complete)x.drawImage(imgs[j][frame],0,0);if(overlay.checked){let m=mask.getContext('2d');m.clearRect(0,0,292,208);m.drawImage(imgs[0][frame],0,0);let a=m.getImageData(0,0,292,208);for(let k=0;k<a.data.length;k+=4){a.data[k]=0;a.data[k+1]=230;a.data[k+2]=245;a.data[k+3]=a.data[k+3]>200?105:0}m.putImageData(a,0,0);x.drawImage(mask,0,0);x.strokeStyle='#ffd63f';x.beginPath();x.moveTo(92,0);x.lineTo(92,208);x.moveTo(0,192);x.lineTo(292,192);x.stroke()}c.style.width=292*Number(zoom.value)+'px';c.style.height=208*Number(zoom.value)+'px';c.style.backgroundColor=bg.value==='checker'?'#383e46':bg.value;c.style.backgroundImage=bg.value==='checker'?'':'none'})}document.getElementById('frame').oninput=e=>{frame=+e.target.value;playing=false;play.textContent='Play';draw()};play.onclick=()=>{playing=!playing;play.textContent=playing?'Pause':'Play';last=performance.now()};[overlay,zoom,bg].forEach(e=>e.onchange=draw);function tick(t){if(playing&&t-last>=100){frame=(frame+1)%10;last=t;draw()}requestAnimationFrame(tick)}Promise.all(imgs.flat().map(i=>i.decode().catch(()=>{}))).then(draw);requestAnimationFrame(tick);</script>'''.replace('DATA',data)
    html=html.replace('<style>','<style>a{color:#8dcfff}img{max-width:100%;height:auto}')
    html=html.replace('<script>const D=', '<h2>Why imposed alpha is not a quality score</h2><a href="alpha_metric_trap.png"><img src="alpha_metric_trap.png" alt="A perfect imposed silhouette score over an incomplete generated figure"></a><h2>Recovered-master full-thrust scout</h2><p>One executed frame only. Source-alpha and weapon-fallback derivatives are partial repairs, with internal pose mismatch remaining.</p><a href="builtin-scout/comparison_frame05.png"><img src="builtin-scout/comparison_frame05.png" alt="Original, restoration, raw edit and two cleanup derivatives"></a><p><a href="builtin-scout/landmarks_05.png">Source landmark overlay</a> · <a href="builtin-scout/cleanup-effort.json">Timed intervention record</a> · <a href="engine-baseline-gpu/comparison_detail05.png">Actual Gym render comparison</a></p><script>const D=')
    html=html.replace('<h2>Why imposed alpha is not a quality score</h2><a href="alpha_metric_trap.png"><img src="alpha_metric_trap.png" alt="A perfect imposed silhouette score over an incomplete generated figure"></a><h2>Recovered-master full-thrust scout</h2>', '<h2>Executed Qwen scouts</h2><p>Seventeen local Qwen outputs. Both complete sequences above are unaccepted research trials. The full-strength group has incomplete figure parts in early poses; source alpha cannot repair them. See <a href="QWEN_RESULTS.md">executed results and recommendation</a>.</p><p><a href="scouts_pose_00.png">Ready pose: canvas-size comparison</a> · <a href="scouts_pose_05.png">Thrust: strength and mask comparison</a> · <a href="landmarks_all_frames.png">All-frame source landmarks</a> · <a href="engine-final-complete/comparison_detail05.png">Final actual Gym comparison</a> · <a href="engine-final-complete/comparison_sync.webp">Synchronized engine preview</a></p><a href="scouts_pose_05.png"><img src="scouts_pose_05.png" alt="All executed full-thrust Qwen configurations"></a><h2>Why imposed alpha is not a quality score</h2><a href="alpha_metric_trap.png"><img src="alpha_metric_trap.png" alt="A perfect imposed silhouette score over an incomplete generated figure"></a><h2>Recovered-master full-thrust scout</h2>')
    (HERE/'review.html').write_text(html,encoding='utf-8')
    save(HERE/'review-checks.json',{'compared_methods':names,'timing_ms':[100]*10,'webp_frames':Image.open(HERE/'comparison_sync.webp').n_frames,'gif_frames':Image.open(HERE/'comparison_sync.gif').n_frames,'html_all_frame_links_exist':all((HERE/f).exists() for x in entries for f in x['frames']),'current_repaint_transform':{'scale':148/180,'source_anchor':[384,448],'target_anchor':[92,192]},'production_asset_modified':False})

if __name__=='__main__':
    result=[x for method in ['reference','reference-2x','masked','masked-high','masked-full','restored-unmasked'] if (x:=export_method(method))]
    build_review()
    print(json.dumps([{'method':x['method'],'complete':x['complete_ten_frame_sequence'],'frames':x['unique_frames_executed']} for x in result]))
