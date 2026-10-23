#!/usr/bin/env python3
"""Isolated CPKMAN group 12 / block 11 restoration experiment.

Uses official BasicSR RRDBNet with an import-only compatibility shim. No game files
are written. Pytorch CPU FP32 inference, x4 native network -> x2 Lanczos target.
"""
from pathlib import Path
import hashlib, json, platform, subprocess, time
import numpy as np
from PIL import Image, ImageDraw, ImageFont
from scipy.ndimage import distance_transform_edt
import torch
from torch import nn
from torch.nn import functional as F

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'a-restoration'
INPUT=ROOT/'inputs'
CONTRACT=json.loads((INPUT/'source_contract.json').read_text())
CROP=tuple(CONTRACT['shared_crop'])
N=CONTRACT['count']
SCALE=2

def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def commit(path):
    return subprocess.check_output(['git','-C',str(path),'rev-parse','HEAD'],text=True).strip()

def make_layer(block, count, **kw):
    return nn.Sequential(*(block(**kw) for _ in range(count)))

def init_weights_unused(*args, **kwargs):
    # All parameters are replaced by strict checkpoint loading below.
    pass

def load_arch():
    path=ROOT/'runtime/BasicSR/basicsr/archs/rrdbnet_arch.py'
    source=path.read_text()
    source=source.replace('from basicsr.utils.registry import ARCH_REGISTRY\n','')
    source=source.replace('from .arch_util import default_init_weights, make_layer, pixel_unshuffle\n','')
    source=source.replace('@ARCH_REGISTRY.register()\n','')
    env={'__name__':'official_rrdb_arch_import_adapted','default_init_weights':init_weights_unused,
         'make_layer':make_layer,'pixel_unshuffle':F.pixel_unshuffle}
    exec(compile(source,str(path),'exec'),env)
    return env['RRDBNet'],path

def rgb_bleed(rgba):
    """Nearest valid straight RGB outside alpha support prevents black RGB halos."""
    a=np.asarray(rgba,dtype=np.uint8)
    valid=a[:,:,3]>0
    _,inds=distance_transform_edt(~valid,return_indices=True)
    rgb=a[:,:,:3].copy()
    rgb[~valid]=rgb[inds[0][~valid],inds[1][~valid]]
    return Image.fromarray(rgb)

def rgba_result(rgb, original):
    rgb=np.asarray(rgb).copy()
    src=np.asarray(original)
    alpha=src[:,:,3].repeat(SCALE,0).repeat(SCALE,1)
    nn_rgb=src[:,:,:3].repeat(SCALE,0).repeat(SCALE,1)
    semi=(alpha>0)&(alpha<255)
    # Palette shadow opacity/color is metadata, not texture to hallucinate.
    rgb[semi]=nn_rgb[semi]
    rgb[alpha==0]=0
    return Image.fromarray(np.dstack((rgb,alpha)).astype(np.uint8))

def checker(size):
    w,h=size
    yy,xx=np.indices((h,w))
    v=np.where(((xx//16+yy//16)%2)==0,190,225).astype(np.uint8)
    return Image.fromarray(np.dstack((v,v,v,np.full_like(v,255))))

def main():
    started=time.perf_counter()
    OUT.mkdir(parents=True,exist_ok=True)
    for method in ('nearest','lanczos','realesrgan'):
        (OUT/method/'full').mkdir(parents=True,exist_ok=True)
        (OUT/method/'crop').mkdir(parents=True,exist_ok=True)
    torch.set_num_threads(4)
    torch.set_num_interop_threads(1)
    torch.use_deterministic_algorithms(True)
    torch.manual_seed(0)
    RRDBNet,archpath=load_arch()
    net=RRDBNet(num_in_ch=3,num_out_ch=3,num_feat=64,num_block=23,num_grow_ch=32,scale=4)
    weights=OUT/'models/RealESRGAN_x4plus.pth'
    checkpoint=torch.load(weights,map_location='cpu',weights_only=True)
    state=checkpoint['params_ema'] if 'params_ema' in checkpoint else checkpoint['params']
    result=net.load_state_dict(state,strict=True)
    assert not result.missing_keys and not result.unexpected_keys
    net.eval()
    config={
      'status':'running','source_contract':CONTRACT,'target_scale':SCALE,
      'model':'RealESRGAN_x4plus','model_url':'https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth',
      'model_sha256':sha(weights),'realesrgan_commit':commit(ROOT/'runtime/Real-ESRGAN'),
      'basicsr_commit':commit(ROOT/'runtime/BasicSR'),'architecture_source_sha256':sha(archpath),
      'torch':torch.__version__,'python':platform.python_version(),'device':'cpu','dtype':'float32','threads':4,
      'implementation':'Official BasicSR RRDBNet; removed registry/helper imports and registry decorator; initialization skipped because strict loading replaces all weights; make_layer matches upstream; forward source unchanged.',
      'network_input':'shared group crop, nearest-neighbor nonzero-alpha RGB bleed, reflect prepad10',
      'network_output':'x4 RGB clipped to0..1 and rounded8bit; crop prepad; Lanczos downsample x4->x2',
      'alpha_policy':'Original alpha nearest2x exactly; semitransparent palette shadow RGB nearest2x; zero RGB under alpha0',
      'timing':'No new frames/interpolation;100ms dwell from shared contract, provisional equal dwell rather than verified original executable capture',
      'baseline_lanczos':'Same RGB bleed and alpha/shadow lock; native crop RGB Lanczos2x',
      'architecture_loading':str(result),
    }
    (OUT/'config.json').write_text(json.dumps(config,indent=2))
    frames={m:[] for m in ('nearest','lanczos','realesrgan')}
    cache={}
    logs=[]
    cw,ch=CROP[2]-CROP[0],CROP[3]-CROP[1]
    for i in range(N):
        full=Image.open(INPUT/f'source_full_{i:02d}.png').convert('RGBA')
        original=full.crop(CROP)
        filled=rgb_bleed(original)
        enlarged=filled.resize((cw*SCALE,ch*SCALE),Image.Resampling.LANCZOS)
        nearest=rgba_result(original.convert('RGB').resize((cw*SCALE,ch*SCALE),Image.Resampling.NEAREST),original)
        lanczos=rgba_result(enlarged,original)
        key=hashlib.sha256(np.asarray(original).tobytes()).hexdigest()
        tick=time.perf_counter()
        duplicate=key in cache
        if duplicate:
            restored=cache[key].copy()
        else:
            arr=np.asarray(filled).astype(np.float32)/255
            ten=torch.from_numpy(arr.transpose(2,0,1)).unsqueeze(0).contiguous()
            ten=F.pad(ten,(10,10,10,10),mode='reflect')
            with torch.inference_mode():
                pred=net(ten).clamp_(0,1)[0,:,40:-40,40:-40]
            a=(pred.permute(1,2,0).numpy()*255).round().astype(np.uint8)
            rgb=Image.fromarray(a).resize((cw*SCALE,ch*SCALE),Image.Resampling.LANCZOS)
            restored=rgba_result(rgb,original)
            cache[key]=restored.copy()
        elapsed=time.perf_counter()-tick
        rec={'frame':i,'source_name':CONTRACT['source_frames'][i]['name'],'source_sha256':sha(INPUT/f'source_full_{i:02d}.png'),
             'reused_identical_input':duplicate,'inference_seconds':elapsed,'outputs':{}}
        expected=np.asarray(original.getchannel('A')).repeat(SCALE,0).repeat(SCALE,1)
        for method,img in [('nearest',nearest),('lanczos',lanczos),('realesrgan',restored)]:
            frames[method].append(img)
            cropfile=OUT/method/'crop'/f'frame_{i:02d}.png'
            fullfile=OUT/method/'full'/f'frame_{i:02d}.png'
            img.save(cropfile)
            canvas=Image.new('RGBA',(full.width*SCALE,full.height*SCALE))
            canvas.paste(img,(CROP[0]*SCALE,CROP[1]*SCALE))
            canvas.save(fullfile)
            mismatch=int(np.count_nonzero(np.asarray(img.getchannel('A'))!=expected))
            assert mismatch==0
            rec['outputs'][method]={'alpha_mismatched_pixels':mismatch,'crop_sha256':sha(cropfile),'full_sha256':sha(fullfile),
                                    'crop_bbox':img.getchannel('A').getbbox(),'full_bbox':canvas.getchannel('A').getbbox()}
        logs.append(rec)
        print(json.dumps({'frame':i,'seconds':round(elapsed,3),'duplicate':duplicate}),flush=True)
    # Comparison of all 10 frames at matching scale, fixed crop and baseline.
    w,h=cw*SCALE,ch*SCALE
    sheet=Image.new('RGB',(w*5,(h+28)*6),(38,43,52))
    draw=ImageDraw.Draw(sheet)
    for row,method in enumerate(frames):
        for i,img in enumerate(frames[method]):
            x=(i%5)*w;y=(row*2+i//5)*(h+28)
            sheet.paste(Image.alpha_composite(checker((w,h)),img).convert('RGB'),(x,y+28))
            draw.text((x+6,y+6),f'{method}  frame{i:02d}',fill='white')
    sheet.save(OUT/'comparison_all_frames.png')
    # Same method side-by-side, synchronized preview; shared contract dwell.
    animation=[]
    for i in range(N):
        panel=Image.new('RGBA',(w*3,h+28),(38,43,52,255));d=ImageDraw.Draw(panel)
        for j,method in enumerate(frames):
            panel.alpha_composite(Image.alpha_composite(checker((w,h)),frames[method][i]),(j*w,28))
            d.text((j*w+6,6),f'{method}  frame{i:02d}',fill='white')
        animation.append(panel.convert('RGB'))
    animation[0].save(OUT/'comparison_animated.webp',save_all=True,append_images=animation[1:],duration=CONTRACT['frame_duration_ms'],loop=0,lossless=True)
    animation[0].save(OUT/'comparison_animated.gif',save_all=True,append_images=animation[1:],duration=CONTRACT['frame_duration_ms'],loop=0,disposal=2)
    for method,imgs in frames.items():
        imgs[0].save(OUT/method/'preview.webp',save_all=True,append_images=imgs[1:],duration=CONTRACT['frame_duration_ms'],loop=0,lossless=True)
    repeat_pairs=[(1,9),(2,8),(3,7),(4,6)]
    repeat_checks={m:{f'{a}-{b}':bool(np.array_equal(np.asarray(frames[m][a]),np.asarray(frames[m][b]))) for a,b in repeat_pairs} for m in frames}
    assert all(all(v.values()) for v in repeat_checks.values())
    config['status']='completed';config['elapsed_seconds']=time.perf_counter()-started
    config['unique_inference_inputs']=len(cache);config['duplicate_checks']=repeat_checks
    config['alpha_total_mismatched_pixels']=sum(o['alpha_mismatched_pixels'] for r in logs for o in r['outputs'].values())
    (OUT/'config.json').write_text(json.dumps(config,indent=2))
    (OUT/'metrics.json').write_text(json.dumps(logs,indent=2))
    freeze=subprocess.check_output([str(ROOT/'runtime/bin/pip'),'freeze'],text=True)
    (OUT/'requirements_freeze.txt').write_text(freeze)
    print(json.dumps({'completed':True,'total_seconds':config['elapsed_seconds'],'unique_inferences':len(cache),'alpha_mismatched_pixels':config['alpha_total_mismatched_pixels']}),flush=True)

if __name__=='__main__':
    main()
