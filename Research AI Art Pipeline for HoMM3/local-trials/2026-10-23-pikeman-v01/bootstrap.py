"""Install a pinned, isolated ComfyUI runtime. Requires network; never edits the host Python."""
from pathlib import Path
import hashlib, json, subprocess, sys, urllib.request, urllib.parse, zipfile, time, concurrent.futures, os, re, html

HERE=Path(__file__).resolve().parent
CACHE=Path(os.environ.get('LAEMA_HOMM3_CACHE',str(HERE)))
RUNTIME=CACHE/'.runtime'; COMFY=RUNTIME/'ComfyUI'; ENV=RUNTIME/'venv'
COMMIT='d07dff4565ea9804277fff8cdfa0c817e08c3d44'
EDIT_REV='f68ace85e60b4a02a323e394253731947657b7d2'
IMAGE_REV='1f12b17be14c89b026c51a91d67c32f84bb047bc'

def fetch_json(url):
    return json.load(urllib.request.urlopen(url,timeout=45))

def download(url,path,sha=None):
    path.parent.mkdir(parents=True,exist_ok=True)
    if path.exists() and (not sha or hashlib.file_digest(path.open('rb'),'sha256').hexdigest()==sha): return
    part=path.with_suffix(path.suffix+'.part');start=part.stat().st_size if part.exists() else 0
    req=urllib.request.Request(url,headers={'Range':f'bytes={start}-'} if start else {})
    t=time.monotonic();last=t
    with urllib.request.urlopen(req,timeout=120) as r:
        if start and r.status!=206: start=0
        with part.open('ab' if start else 'wb') as out:
            total=start
            while b:=r.read(4*1024*1024):
                out.write(b);total+=len(b)
                if time.monotonic()-last>25:
                    print(f'{path.name}: {total/1e9:.2f} GB, {(total-start)/1e6/(time.monotonic()-t):.2f} MB/s',flush=True);last=time.monotonic()
    actual=hashlib.file_digest(part.open('rb'),'sha256').hexdigest()
    if sha and actual!=sha: raise RuntimeError(f'Hash mismatch: {path.name}: {actual}')
    part.rename(path)
    print(f'Verified {path.name}: {actual}',flush=True)

def setup():
    RUNTIME.mkdir(exist_ok=True)
    archive=RUNTIME/'comfyui.zip'
    download(f'https://codeload.github.com/comfyanonymous/ComfyUI/zip/{COMMIT}',archive)
    if not COMFY.exists():
        with zipfile.ZipFile(archive) as z:
            for n in z.namelist():
                resolved=(RUNTIME/n).resolve()
                if not resolved.is_relative_to(RUNTIME.resolve()): raise RuntimeError('Unsafe zip path')
            z.extractall(RUNTIME)
        (RUNTIME/f'ComfyUI-{COMMIT}').rename(COMFY)
    if not ENV.exists():subprocess.run([sys.executable,'-m','venv','--system-site-packages',str(ENV)],check=True)
    py=ENV/'Scripts/python.exe'
    index=urllib.request.urlopen('https://download.pytorch.org/whl/cu128/torch/',timeout=45).read().decode()
    link=next(html.unescape(x) for x in re.findall(r'href="([^"]+)"',index) if 'torch-2.9.1%2Bcu128-cp312-cp312-win_amd64.whl' in x)
    url,fragment=urllib.parse.urldefrag(link)
    if not url.startswith('https:'):url=urllib.parse.urljoin('https://download.pytorch.org/whl/cu128/torch/',url)
    sha=fragment.split('sha256=')[1]
    wheel=RUNTIME/urllib.parse.unquote(urllib.parse.urlparse(url).path.rsplit('/',1)[1])
    row={'url':url,'bytes':2862033275,'sha256':sha,'destination':str(wheel)}
    (HERE/'runtime_lock.json').write_text(json.dumps({'comfyui_commit':COMMIT,'archive_sha256':hashlib.file_digest(archive.open('rb'),'sha256').hexdigest(),'torch_wheel':row},indent=2),encoding='utf-8')
    ranged_downloads([row],12)
    subprocess.run([str(py),'-m','pip','install','--disable-pip-version-check','--no-cache-dir',str(wheel),'torchvision==0.24.1','--index-url','https://download.pytorch.org/whl/cu128'],check=True)
    requirements=(COMFY/'requirements.txt').read_text(encoding='utf-8')
    # Gallery templates pull large example-media wheels. API graphs are explicitly
    # saved in this trial and do not use the gallery. Keep upstream source intact.
    requirements='\n'.join(x for x in requirements.splitlines() if not x.startswith('comfyui-workflow-templates'))+'\n'
    selected=HERE/'runtime-requirements.txt';selected.write_text(requirements,encoding='utf-8')
    locked=HERE/'requirements-inference-lock.txt'
    if locked.exists():selected=locked
    subprocess.run([str(py),'-m','pip','install','--disable-pip-version-check','--cache-dir',str(RUNTIME/'pip-cache'),'-r',str(selected)],check=True)
    (HERE/'requirements_freeze.txt').write_text(subprocess.check_output([str(py),'-m','pip','freeze'],text=True),encoding='utf-8')
    print('RUNTIME_READY',flush=True)

def model_rows():
    choices=[('Comfy-Org/Qwen-Image-Edit',EDIT_REV,'split_files/diffusion_models/qwen_image_edit_2511_fp8mixed.safetensors','diffusion_models'),('Comfy-Org/Qwen-Image',IMAGE_REV,'split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors','text_encoders'),('Comfy-Org/Qwen-Image',IMAGE_REV,'split_files/vae/qwen_image_vae.safetensors','vae')]
    rows=[]
    for repo,revision,file,kind in choices:
        tree=fetch_json(f'https://huggingface.co/api/models/{repo}/tree/{revision}/{file.rsplit("/",1)[0]}')
        info=next(x for x in tree if x['path']==file)
        rows.append({'repo':repo,'revision':revision,'file':file,'sha256':info['lfs']['oid'],'bytes':info['size'],'destination':str(CACHE/'.models'/kind/file.rsplit('/',1)[1]),'url':f'https://huggingface.co/{repo}/resolve/{revision}/{file}'})
    (HERE/'model_lock.json').write_text(json.dumps({'comfyui_commit':COMMIT,'torch':'2.9.1+cu128','models':rows,'precision':'2511 FP8 mixed visual model + FP8 scaled encoder; not equivalent to BF16','controlnet_attached':False},indent=2),encoding='utf-8')
    return rows

def ranged_downloads(rows,workers=12):
    jobs=[]
    chunk_size=64*1024*1024
    for row in rows:
        p=Path(row['destination'])
        if p.exists():
            assert hashlib.file_digest(p.open('rb'),'sha256').hexdigest()==row['sha256']
            continue
        chunks=p.parent/(p.name+'.chunks');chunks.mkdir(exist_ok=True,parents=True)
        for start in range(0,row['bytes'],chunk_size):
            end=min(start+chunk_size,row['bytes'])-1
            jobs.append((row,chunks/f'{start:012d}.bin',start,end))
    def chunk(job):
        row,p,start,end=job
        if p.exists() and p.stat().st_size==end-start+1:return
        for attempt in range(4):
            try:
                # Cache key includes the byte range so redirects cannot reuse another range.
                existing=p.stat().st_size if p.exists() else 0
                if existing>end-start+1:raise RuntimeError('Oversized partial range')
                offset=start+existing
                req=urllib.request.Request(row['url']+f'?range_start={offset}',headers={'Range':f'bytes={offset}-{end}'})
                with urllib.request.urlopen(req,timeout=120) as r:
                    if r.status!=206 or not r.headers.get('Content-Range','').startswith(f'bytes {offset}-{end}/'):raise RuntimeError('Server did not honor exact range')
                    with p.open('ab') as out:
                        while b:=r.read(1024*1024):out.write(b)
                if p.stat().st_size!=end-start+1:raise RuntimeError('Incomplete range')
                return
            except Exception:
                if attempt==3:raise
                time.sleep(2+attempt)
    t=time.monotonic();done=0;last=t
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as pool:
        for f in concurrent.futures.as_completed([pool.submit(chunk,j) for j in jobs]):
            f.result();done+=1
            if time.monotonic()-last>20:
                print(f'Ranges complete: {done}/{len(jobs)}, elapsed {time.monotonic()-t:.0f}s',flush=True);last=time.monotonic()
    for row in rows:
        p=Path(row['destination'])
        if p.exists():continue
        chunks=p.parent/(p.name+'.chunks');part=p.with_suffix('.assembled')
        h=hashlib.sha256()
        with part.open('wb') as out:
            for start in range(0,row['bytes'],chunk_size):
                with (chunks/f'{start:012d}.bin').open('rb') as src:
                    while b:=src.read(4*1024*1024):out.write(b);h.update(b)
        if h.hexdigest()!=row['sha256']:raise RuntimeError(f'Hash mismatch {p.name}')
        part.rename(p)
        print(f'Verified {p.name}: {h.hexdigest()}',flush=True)

def models():
    ranged_downloads(model_rows(),48)
    print('MODELS_READY',flush=True)

if __name__=='__main__':
    {'setup':setup,'models':models}[sys.argv[1]]()
