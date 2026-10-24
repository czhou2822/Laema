"""Finalize local comparisons and preservation checks; no model execution or publication."""
from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json
from compare import export_method,build_review,checker,SMALL,MAP,SIZE,BASE,HERE

METHODS=['reference','reference-2x','restored-unmasked','masked-high','masked-full','masked']
def save(p,obj):p.write_text(json.dumps(obj,indent=2),encoding='utf-8')
def digest(p):return hashlib.file_digest(p.open('rb'),'sha256').hexdigest()
def raw_crop(method,i):
    im=Image.open(HERE/method/f'raw/unique_{i:02d}.png').convert('RGB')
    if method=='reference-2x':im=im.resize((608,416),Image.Resampling.LANCZOS)
    return im.crop((12,0,596,416)).resize(SIZE,Image.Resampling.LANCZOS)

def main():
    for candidate in ['masked','masked-full']:
        for i in range(6):
            p=HERE/candidate/f'raw/unique_{i:02d}.json'
            if not p.exists() or json.loads(p.read_text())['status']!='executed':raise RuntimeError('Six-pose candidate execution is incomplete')
    for method in METHODS:export_method(method)
    build_review()
    summary=[]
    for method in METHODS:
        for p in sorted((HERE/method/'raw').glob('unique_*.json')):
            r=json.loads(p.read_text())
            stamps={n:d['timestamp'] for n,d in r['history']['status']['messages'] if 'timestamp' in d}
            gpu=[int(x['gpu_memory_mib_util_percent'].split(',')[0]) for x in r['gpu_samples']]
            summary.append({'method':method,'source_unique':r['unique_source_frame'],'server_execution_seconds':(stamps['execution_success']-stamps['execution_start'])/1000,'submission_to_saved_seconds':r['duration_seconds'],'sampled_gpu_memory_used_mib_max':max(gpu) if gpu else None,'raw_dimensions':r['raw_dimensions'],'raw_sha256':r['raw_sha256'],'workflow':r['workflow'],'manual_painting_seconds':0})
    save(HERE/'execution_summary.json',{'executed_qwen_outputs':len(summary),'runs':summary,'total_server_execution_seconds':sum(x['server_execution_seconds'] for x in summary),'gpu_memory_caveat':'Whole-GPU usage sampled about every2s, not an exact per-process allocated-memory peak.','controlnet_executed':False,'artist_time_to_acceptance':None})
    atlas=Image.open(HERE/'masked/source-alpha/attack_4col.png').convert('RGBA')
    cells=[]
    for i in range(10):
        cell=atlas.crop(((i%4)*900,(i//4)*800,(i%4+1)*900,(i//4+1)*800))
        frame=Image.open(HERE/f'masked/source-alpha/full/frame_{i:02d}.png').convert('RGBA')
        cells.append(cell.tobytes()==frame.tobytes())
    padding=[atlas.crop(((i%4)*900,(i//4)*800,(i%4+1)*900,(i//4+1)*800)).getchannel('A').getbbox() is None for i in [10,11]]
    unique=len({digest(HERE/f'masked/source-alpha/full/frame_{i:02d}.png') for i in range(10)})
    save(HERE/'atlas-readback.json',{'size':list(atlas.size),'occupied_cells_exact':cells,'padding_cells_transparent':padding,'unique_images':unique})
    assert all(cells) and all(padding) and unique==6
    full_atlas=Image.open(HERE/'masked-full/source-alpha/attack_4col.png').convert('RGBA')
    full_cells=[]
    for i in range(10):
        cell=full_atlas.crop(((i%4)*900,(i//4)*800,(i%4+1)*900,(i//4+1)*800))
        frame=Image.open(HERE/f'masked-full/source-alpha/full/frame_{i:02d}.png').convert('RGBA')
        full_cells.append(cell.tobytes()==frame.tobytes())
    full_padding=[full_atlas.crop(((i%4)*900,(i//4)*800,(i%4+1)*900,(i//4+1)*800)).getchannel('A').getbbox() is None for i in [10,11]]
    full_unique=len({digest(HERE/f'masked-full/source-alpha/full/frame_{i:02d}.png') for i in range(10)})
    save(HERE/'full-strength-atlas-readback.json',{'size':list(full_atlas.size),'occupied_cells_exact':full_cells,'padding_cells_transparent':full_padding,'unique_images':full_unique})
    assert all(full_cells) and all(full_padding) and full_unique==6
    for i in [0,5]:
        entries=[('Original',Image.open(BASE/f'a-restoration/nearest/crop/frame_{i:02d}.png').convert('RGBA')),('Restoration',Image.open(BASE/f'a-restoration/realesrgan/crop/frame_{i:02d}.png').convert('RGBA'))]
        for method in METHODS:
            if (HERE/method/f'raw/unique_{i:02d}.png').exists():entries.append((method+' / RAW',raw_crop(method,i)))
        sheet=Image.new('RGB',(292*len(entries),264),(20,24,29));d=ImageDraw.Draw(sheet)
        for j,(label,im) in enumerate(entries):
            panel=Image.new('RGB',SIZE,(127,127,127))
            if im.mode=='RGBA':panel.paste(im,(0,0),im)
            else:panel.paste(im,(0,0))
            sheet.paste(panel,(292*j,34));d.text((292*j+5,7),label,font=SMALL,fill='white');d.text((292*j+5,246),f'Original source pose{i:02d}',font=SMALL,fill='white')
        sheet.save(HERE/f'scouts_pose_{i:02d}.png')
    landmarks=json.loads((HERE/'source-landmarks.json').read_text())['frames']
    sheet=Image.new('RGB',(584,2340),(20,24,29));d=ImageDraw.Draw(sheet)
    for i,j in enumerate(MAP):
        src=Image.open(BASE/f'a-restoration/nearest/crop/frame_{i:02d}.png').convert('RGBA')
        for col,im in enumerate([src,raw_crop('masked',j)]):
            panel=checker(SIZE)
            if im.mode=='RGBA':panel.paste(im,(0,0),im)
            else:panel.paste(im,(0,0))
            pd=ImageDraw.Draw(panel)
            for x,y in landmarks[str(j)].values():pd.line((x-3,y,x+3,y),fill=(255,215,50));pd.line((x,y-3,x,y+3),fill=(255,215,50))
            sheet.paste(panel,(col*292,i*234+23));d.text((col*292+5,i*234+3),f'{["Source","Masked raw RGB"][col]} {i:02d} / pose{j}',font=SMALL,fill='white')
    sheet.save(HERE/'landmarks_all_frames.png')
    preservation=json.loads((HERE/'preservation.json').read_text());changed=[]
    for relative,expected in preservation['baseline_hashes'].items():
        p=(BASE/relative).resolve();assert p.is_relative_to(BASE.resolve())
        if not p.is_file() or digest(p)!=expected:changed.append(relative)
    checks=json.loads((HERE/'masked/export-checks.json').read_text())
    save(HERE/'validation.json',{'supplied_baseline_files_checked':len(preservation['baseline_hashes']),'supplied_baseline_changed_paths':changed,'candidate':checks,'full_strength_candidate':json.loads((HERE/'masked-full/export-checks.json').read_text()),'atlas_readback_pass':all(cells) and all(padding),'qwen_successful_images':len(summary),'controlnet_executed':False,'propagation_or_rig_executed':False,'production_replaced':False,'acceptance':'User visual review pending'})
    assert not changed,'Baseline changed; inspect without overwriting'
    print(json.dumps({'qwen_outputs':len(summary),'model_minutes':sum(x['server_execution_seconds'] for x in summary)/60,'baseline_changed':changed,'export_checks':checks},indent=2))

if __name__=='__main__':main()
