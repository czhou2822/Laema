"""Non-destructive local input recovery and preservation audit. No inference."""
from pathlib import Path
from PIL import Image, ImageOps, ImageFilter
import ctypes, hashlib, json, shutil, subprocess, sys, datetime, os

HERE = Path(__file__).resolve().parent
BASE = HERE.parents[1]
REPO = BASE.parent
ART = Path(os.environ['LAEMA_ART_SCRATCH']) if 'LAEMA_ART_SCRATCH' in os.environ else None

def digest(p):
    return hashlib.file_digest(p.open('rb'), 'sha256').hexdigest()

def save_json(p, obj):
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(obj, indent=2), encoding='utf-8')

def main():
    if ART is None: raise RuntimeError('Set LAEMA_ART_SCRATCH to the recovered Art package root before regenerating inputs')
    inp = HERE/'inputs'; inp.mkdir(exist_ok=True)
    provenance = HERE/'recovered-evidence'; provenance.mkdir(exist_ok=True)
    recovered = []
    packages = ['castle-creature-assets-v01', 'pikeman-flipbook-assets-v02', 'pikeman-flipbook-assets-v01', 'pikeman-sprite-assets-v01']
    inventory = []
    for name in packages:
        p = ART/name
        files = sorted(x for x in p.rglob('*') if x.is_file())
        inventory.append({'package':name,'path':str(p),'file_count':len(files),'bytes':sum(x.stat().st_size for x in files),'files':[{'path':x.relative_to(p).as_posix(),'bytes':x.stat().st_size} for x in files]})
    selected = {
      'castle-creature-assets-v01':['master-approval.json','masters-manifest.json','master-prompts.json','master-export-spec.json','generation-files.json','README.md'],
      'pikeman-flipbook-assets-v01':['generation-spec.json','source-pose-guides.json','generated-source-report.json','export-spec.json','repair-prompts.json','prepare-guides.cjs','export-flipbooks.cjs'],
      'pikeman-flipbook-assets-v02':['HANDOFF.md','manifest.json','motion-review.json','repair-record.json','correct-motion.cjs'],
      'pikeman-sprite-assets-v01':['asset-spec.json','manifest.json','README.md','export-idle.cjs']}
    for name, names in selected.items():
        for filename in names:
            src = ART/name/filename
            if not src.exists(): continue
            dst = provenance/name/filename; dst.parent.mkdir(exist_ok=True, parents=True)
            if not dst.exists(): shutil.copy2(src,dst)
            assert digest(src)==digest(dst)
            recovered.append({'source':str(src),'copy':dst.relative_to(HERE).as_posix(),'sha256':digest(src)})
    master = ART/'pikeman-sprite-assets-v01/pikeman_idle_master_rgba.png'
    target = inp/'master_original_left.png'
    if not target.exists(): shutil.copy2(master,target)
    rgba = Image.open(target).convert('RGBA')
    ImageOps.mirror(rgba).save(inp/'master_right_rgba.png')
    bg = Image.new('RGBA',rgba.size,(127,127,127,255)); bg.alpha_composite(ImageOps.mirror(rgba));bg.convert('RGB').save(inp/'master_right_gray.png')
    recovered.append({'source':str(master),'copy':'inputs/master_original_left.png','sha256':digest(master),'approval_boundary':'Recovered user-approved prototype Pikeman identity; not historical high-resolution ground truth or acceptance of a remaster method.'})
    contract = json.loads((BASE/'inputs/source_contract.json').read_text())
    mapping = [0,1,2,3,4,5,4,3,2,1]
    for i in range(6):
        src = Image.open(BASE/f'inputs/pose_{i:02d}.png').convert('RGBA')
        bg = Image.new('RGBA',(608,416),(127,127,127,255));bg.alpha_composite(src,(12,0));bg.convert('RGB').save(inp/f'pose_{i:02d}_gray.png')
        # Same fixed crop, 2x supplied restoration -> 4x reference pixels.
        a = Image.open(BASE/f'a-restoration/realesrgan/crop/frame_{i:02d}.png').convert('RGBA').resize((584,416),Image.Resampling.LANCZOS)
        # Restore exact source alpha at guide resolution after RGB resizing.
        a.putalpha(src.getchannel('A'))
        bg = Image.new('RGBA',(608,416),(127,127,127,255));bg.alpha_composite(a,(12,0));bg.convert('RGB').save(inp/f'restored_{i:02d}_gray.png')
        mask = Image.new('L',(608,416));mask.paste(src.getchannel('A').point(lambda v:255 if v>200 else 0),(12,0))
        mask.save(inp/f'mask_{i:02d}.png')
        mask.filter(ImageFilter.MaxFilter(9)).save(inp/f'edit_mask_{i:02d}.png')
    source = [Image.open(BASE/f'inputs/source_full_{i:02d}.png').convert('RGBA') for i in range(10)]
    assert all(source[i].tobytes()==source[j].tobytes() for i,j in enumerate(mapping))
    save_json(HERE/'preservation.json',{'source_contract':contract,'map':mapping,'source_anchor_native':[196,268],'fixed_transform':{'native_to_guide':{'scale':4,'translate':[-588,-688]},'guide_padding_ltrb':[12,0,12,0],'model_canvas':[608,416],'comparison_crop':[12,0,596,416],'export_native_scale':2,'export_crop_origin':[300,344],'export_full_canvas':[900,800],'export_anchor':[392,536]},'baseline_hashes':{p.relative_to(BASE).as_posix():digest(p) for p in sorted(BASE.rglob('*')) if p.is_file() and 'local-trials' not in p.parts},'recovered_files':recovered})
    save_json(HERE/'package-inventory.json',inventory)
    class Mem(ctypes.Structure):
        _fields_=[('length',ctypes.c_ulong),('load',ctypes.c_ulong)]+[(x,ctypes.c_ulonglong) for x in ['total','available','page_total','page_available','virtual_total','virtual_available','extended']]
    m=Mem();m.length=ctypes.sizeof(m);ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(m))
    hardware={'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'python':sys.version,'gpu':subprocess.check_output(['nvidia-smi','--query-gpu=name,memory.total,memory.free,driver_version','--format=csv'],text=True),'ram_total':m.total,'ram_available':m.available,'disk':dict(zip(['total','used','free'],shutil.disk_usage(HERE))),'source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),'tools':{'python':sys.executable,'godot':os.environ.get('LAEMA_GODOT_PATH') or shutil.which('godot')},'initial_diffusion_modules':{'torch':False,'diffusers':False,'transformers':False,'comfyui':False},'search_scope':['Laema checkout','OneDrive Documents','Documents/Codex','Downloads','Desktop','C:/Tools','.cache','AppData/Local/Programs','.codex/worktrees','.codex/visualizations Art scratch (located through Art chat)']}
    save_json(HERE/'hardware.json',hardware)
    print(json.dumps({'packages':[{k:v for k,v in x.items() if k!='files'} for x in inventory],'master_size':rgba.size,'recovered_files':len(recovered),'protected_evidence':len(json.loads((HERE/'preservation.json').read_text())['baseline_hashes'])},indent=2))

if __name__=='__main__': main()
