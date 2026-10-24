"""Versioned ComfyUI API graphs and bounded local Qwen 2511 experiments.

Server: python run_local.py server
Scouts: python run_local.py run reference 0 5
Mask:   python run_local.py run masked 0 1 2 3 4 5
Never overwrites a completed raw trial. Model setup is separate from inference.
"""
from pathlib import Path
import argparse, datetime, hashlib, json, os, shutil, subprocess, sys, time, urllib.request

HERE=Path(__file__).resolve().parent
CACHE=Path(os.environ.get('LAEMA_HOMM3_CACHE',str(HERE)))
URL='http://127.0.0.1:8189'
PROMPT=(
 'Edit Picture 1 only. Picture 1 is the exact historical sprite pose and registration authority. '
 'Picture 2 is the same Pikeman appearance reference, not a pose reference. '
 'Refine the existing tiny soldier in Picture 1 into a detailed painted game sprite with the '
 'face, brown-bronze helmet, silver shoulder armor, white tabard with blue organic crest, '
 'blue sleeves and trousers with narrow gold stripes, brown leather boots, and wooden pike '
 'materials of Picture 2. Keep the exact original silhouette, body proportions, torso angle, '
 'head position, bent knees, two hands, boot contacts, pike angle, pike endpoints, grip spacing '
 'and occlusions in Picture 1. The soldier faces right. Do not copy Picture 2 standing pose. '
 'Keep the single continuous straight pike and its existing silver spearhead. Do not enlarge, '
 'recenter, rotate, reframe or redesign the figure. Preserve all empty margins and the exact '
 'flat RGB 127 gray background. No text, extra person, shield, sword, cape, floor, effects, '
 'cast shadow or new ornament. Restrained upper-left lighting and historically compatible '
 'painted sprite shading. Preserve pose before adding any detail.'
)

def request(path, data=None):
    body=json.dumps(data).encode() if data is not None else None
    req=urllib.request.Request(URL+path,data=body,headers={'Content-Type':'application/json'})
    try:
        return json.load(urllib.request.urlopen(req,timeout=30))
    except urllib.error.HTTPError as e:
        raise RuntimeError(e.read().decode()) from e

def build_graph(method,frame):
    is_reference=method.startswith('reference')
    image=f'pose_{frame:02d}_gray.png' if is_reference else f'restored_{frame:02d}_gray.png'
    g={
      '1':{'class_type':'UNETLoader','inputs':{'unet_name':'qwen_image_edit_2511_fp8mixed.safetensors','weight_dtype':'default'}},
      '2':{'class_type':'CLIPLoader','inputs':{'clip_name':'qwen_2.5_vl_7b_fp8_scaled.safetensors','type':'qwen_image','device':'default'}},
      '3':{'class_type':'VAELoader','inputs':{'vae_name':'qwen_image_vae.safetensors'}},
      '4':{'class_type':'LoadImage','inputs':{'image':image}},
      '5':{'class_type':'LoadImage','inputs':{'image':'master_right_gray.png'}},
      '6':{'class_type':'TextEncodeQwenImageEditPlus','inputs':{'clip':['2',0],'vae':['3',0],'prompt':PROMPT,'image1':['4',0],'image2':['5',0]}},
      '7':{'class_type':'TextEncodeQwenImageEditPlus','inputs':{'clip':['2',0],'vae':['3',0],'prompt':' ','image1':['4',0],'image2':['5',0]}},
      '8':{'class_type':'ModelSamplingAuraFlow','inputs':{'model':['1',0],'shift':3.1}},
      '9':{'class_type':'CFGNorm','inputs':{'model':['8',0],'strength':1.0,'pre_cfg':False}},
      '10':{'class_type':'VAEEncode','inputs':{'pixels':['4',0],'vae':['3',0]}},
      '11':{'class_type':'KSampler','inputs':{'model':['9',0],'positive':['6',0],'negative':['7',0],'latent_image':['10',0],'seed':42,'steps':40,'cfg':4.0,'sampler_name':'euler','scheduler':'simple','denoise':1.0 if is_reference or method=='masked-full' else (0.65 if method=='masked-high' else 0.35)}},
      '12':{'class_type':'VAEDecode','inputs':{'samples':['11',0],'vae':['3',0]}},
      '13':{'class_type':'SaveImage','inputs':{'images':['12',0],'filename_prefix':f'{method}/unique_{frame:02d}'}},
    }
    if method in ['masked','masked-high','masked-full']:
        g['14']={'class_type':'LoadImageMask','inputs':{'image':f'edit_mask_{frame:02d}.png','channel':'red'}}
        g['15']={'class_type':'SetLatentNoiseMask','inputs':{'samples':['10',0],'mask':['14',0]}}
        g['11']['inputs']['latent_image']=['15',0]
    if method=='reference-2x':
        g['16']={'class_type':'ImageScale','inputs':{'image':['4',0],'upscale_method':'lanczos','width':1216,'height':832,'crop':'disabled'}}
        for n in ['6','7']:g[n]['inputs']['image1']=['16',0]
        g['10']['inputs']['pixels']=['16',0]
    return g

def server():
    p=CACHE/'.runtime/model_paths.yaml'
    p.write_text('research:\n  base_path: '+(CACHE/'.models').as_posix()+'\n  diffusion_models: diffusion_models\n  text_encoders: text_encoders\n  vae: vae\n',encoding='utf-8')
    py=CACHE/'.runtime/venv/Scripts/python.exe'
    args=[str(py),'-u',str(CACHE/'.runtime/ComfyUI/main.py'),'--listen','127.0.0.1','--port','8189',
          '--extra-model-paths-config',str(p),'--input-directory',str(HERE/'inputs'),
          '--output-directory',str(CACHE/'.runtime/outputs'),'--disable-all-custom-nodes',
          '--offline','--preview-method','none','--cache-lru',os.environ.get('LAEMA_COMFY_CACHE_NODES','12'),'--bf16-vae','--reserve-vram',os.environ.get('LAEMA_COMFY_RESERVE_GB','2')]
    if os.environ.get('LAEMA_COMFY_STATIC')=='1':args += ['--disable-dynamic-vram','--disable-async-offload']
    (HERE/'server-command.json').write_text(json.dumps({'argv':args,'env':{'HF_HUB_OFFLINE':'1','TRANSFORMERS_OFFLINE':'1'},'network':'127.0.0.1 only; partner nodes/custom nodes disabled'},indent=2),encoding='utf-8')
    env=os.environ.copy();env.update(HF_HUB_OFFLINE='1',TRANSFORMERS_OFFLINE='1',PYTHONUTF8='1')
    with (HERE/'server.log').open('w',encoding='utf-8') as log:
        process=subprocess.Popen(args,cwd=CACHE/'.runtime/ComfyUI',env=env,stdout=log,stderr=subprocess.STDOUT,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
        (CACHE/'.runtime/server.pid').write_text(str(process.pid))
        print(f'Server PID {process.pid}, log server.log',flush=True)
        code=process.wait()
        print(f'Server exit {code}',flush=True)
        sys.exit(code)

def run(method,frames):
    info=request('/object_info')
    raw=HERE/method/'raw';raw.mkdir(exist_ok=True,parents=True)
    workflow=HERE/method/'workflows';workflow.mkdir(exist_ok=True)
    for frame in frames:
        if frame not in range(6):raise ValueError('Only six original unique drawings are allowed')
        output=raw/f'unique_{frame:02d}.png';record=raw/f'unique_{frame:02d}.json'
        if output.exists() or record.exists():
            print(f'SKIP existing {method}/{frame}',flush=True);continue
        g=build_graph(method,frame)
        for n in g.values():
            if n['class_type'] not in info:raise RuntimeError(f'Missing node {n["class_type"]}')
        graphpath=workflow/f'unique_{frame:02d}.api.json';graphpath.write_text(json.dumps(g,indent=2),encoding='utf-8')
        (workflow/'node_definitions.json').write_text(json.dumps({n['class_type']:info[n['class_type']] for n in g.values()},indent=2),encoding='utf-8')
        start=time.monotonic();utc=datetime.datetime.now(datetime.timezone.utc).isoformat();response=request('/prompt',{'prompt':g,'client_id':'homm3-pikeman-local-v01'})
        prompt_id=response['prompt_id'];samples=[];last=start
        print(f'START {method}/{frame:02d} prompt {prompt_id}',flush=True)
        while True:
            history=request('/history/'+prompt_id)
            try:
                gpu=subprocess.check_output(['nvidia-smi','--query-gpu=memory.used,utilization.gpu','--format=csv,noheader,nounits'],text=True).strip()
                samples.append({'elapsed_s':round(time.monotonic()-start,2),'gpu_memory_mib_util_percent':gpu})
            except Exception:pass
            if prompt_id in history:
                h=history[prompt_id]
                if h['status']['status_str']!='success':
                    record.write_text(json.dumps({'status':'failed','history':h,'seconds':time.monotonic()-start},indent=2),encoding='utf-8')
                    raise RuntimeError(json.dumps(h['status']))
                saved=h['outputs']['13']['images'][0]
                src=CACHE/'.runtime/outputs'/saved['subfolder']/saved['filename']
                shutil.copy2(src,output)
                from PIL import Image
                with Image.open(output) as im:
                    dimensions=list(im.size);mode=im.mode
                expected=[1216,832] if method=='reference-2x' else [608,416]
                if dimensions!=expected:raise RuntimeError(f'Unexpected raw dimensions {dimensions}')
                guidance={'reference':'Soft source/master reference conditioning, original pose initialization, denoise1.0','reference-2x':'Larger-canvas scout: exactly2x scaling of the entire padded pose canvas to1216x832 before conditioning/latent encoding. Denoise1.0; same prompt, seed, model and sampler. No frame fit or ControlNet.','masked':'Restoration-initialized img2img, denoise0.35, original opaque mask dilated4px at4x guide resolution limits latent noise. Generic mask is not ControlNet and does not lock internal anatomy.','masked-full':'Full-strength endpoint with the same restored input and dilated mask, denoise1.0.','masked-high':'Paired strength scout: same restoration and dilated source mask as masked, denoise0.65 instead of0.35.','restored-unmasked':'Paired ablation: same restoration initialization and denoise0.35 as masked, but no SetLatentNoiseMask.'}[method]
                result={'status':'executed','method':method,'unique_source_frame':frame,'started_utc':utc,'duration_seconds':round(time.monotonic()-start,3),'raw_file':output.relative_to(HERE).as_posix(),'raw_sha256':hashlib.file_digest(output.open('rb'),'sha256').hexdigest(),'raw_dimensions':dimensions,'raw_mode':mode,'model_lock':'model_lock.json','workflow':graphpath.relative_to(HERE).as_posix(),'history':h,'gpu_samples':samples,'gpu_sample_interval_seconds':2,'manual_drawing_cleanup_seconds':0,'manual_cleanup_status':'No artist drawing correction performed; production cleanup time remains unmeasured.','guidance':guidance,'output_alpha':'RGB raw; no native alpha. Source-alpha derivatives are separate.'}
                record.write_text(json.dumps(result,indent=2),encoding='utf-8')
                print(f'DONE {method}/{frame:02d}: {result["duration_seconds"]} seconds',flush=True)
                break
            if time.monotonic()-last>20:
                print(f'RUNNING {method}/{frame:02d}: {time.monotonic()-start:.0f}s, GPU {samples[-1] if samples else "unavailable"}',flush=True);last=time.monotonic()
            time.sleep(2)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('action',choices=['server','run','graphs']);p.add_argument('method',nargs='?',choices=['reference','reference-2x','masked','masked-high','masked-full','restored-unmasked']);p.add_argument('frames',nargs='*',type=int);a=p.parse_args()
    if a.action=='server':server()
    elif a.action=='run':run(a.method,a.frames or list(range(6)))
    else:
        for method in ['reference','masked']:
            p=HERE/method/'workflows';p.mkdir(exist_ok=True,parents=True)
            for i in range(6):(p/f'unique_{i:02d}.api.json').write_text(json.dumps(build_graph(method,i),indent=2),encoding='utf-8')
        print('Graphs written; not inference evidence.')
