"""Mechanical source comparisons, native indexed evidence and decoded GIF witnesses."""
import hashlib
import importlib.util
import json
import math
import sys
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageOps

sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[6]
REPORT=Path(__file__).resolve().parent
BASE=ROOT/'assets/prototype/enemy/bone_dragon/remaster_v01'
OUT=BASE/'contacts/full-review'
OUT.mkdir(parents=True,exist_ok=True)
spec=importlib.util.spec_from_file_location('remaster_readonly',ROOT/'tools/art/necropolis_remaster.py')
h=importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
c=h.creature('bone_dragon');pm=h.posemap(c)
m=json.loads((BASE/'source_manifest.json').read_text(encoding='utf-8'))

def rel(p):return p.relative_to(ROOT).as_posix()
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def matte(im):
    bg=Image.new('RGBA',im.size,(23,36,49,255));bg.alpha_composite(im)
    return bg.convert('RGB')

pairs=[];records=[]
for p in c['poses']:
    pid=p['pose_id'];fp=BASE/'poses'/(pid+'.png')
    if not fp.exists():continue
    rec=json.loads(fp.with_suffix('.json').read_text(encoding='utf-8'))
    new=Image.open(fp).convert('RGBA');og=h.projected_original(p)
    mask=ImageChops.lighter(new.getchannel('A'),og.getchannel('A')).point(lambda v:255 if v>16 else 0)
    bb=mask.getbbox();region=(max(0,bb[0]-12),max(0,bb[1]-12),min(1024,bb[2]+12),min(768,bb[3]+12))
    left=matte(og).crop(region);right=matte(new).crop(region)
    pair=Image.new('RGB',(left.width*2,left.height+24),(23,36,49))
    pair.paste(left,(0,24));pair.paste(right,(left.width,24))
    d=ImageDraw.Draw(pair);d.text((5,5),pid+' ORIGINAL',fill='white');d.text((left.width+5,5),'CANDIDATE fixed game scale',fill='white')
    path=OUT/(pid+'-comparison.png');pair.save(path);pairs.append((pid,pair))
    r=p['representative'];sr=r['source_record']
    indexed=h.crop(Image.open(ROOT/r['indexed_sheet']),r['sheet_cell_region'])
    trimmed=indexed.crop((sr['left'],sr['top'],sr['left']+sr['width'],sr['top']+sr['height']))
    index_sha=hashlib.sha256(trimmed.tobytes()).hexdigest()
    alpha_bb=new.getchannel('A').getbbox()
    margins=[alpha_bb[0],alpha_bb[1],1024-alpha_bb[2],768-alpha_bb[3]]
    mirror=Image.open(ROOT/rec['mirror_file']).convert('RGBA')
    records.append({'pose_id':pid,'registered':rel(fp),'registered_sha256':sha(fp),'mirror_sha256':sha(ROOT/rec['mirror_file']),
      'raw_source':rec['raw_source'],'raw_sha256_matches':sha(ROOT/rec['raw_source'])==rec['raw_sha256'],
      'isolated_sha256_matches':sha(ROOT/rec['isolated_source'])==rec['isolated_sha256'],
      'native_indexed_trim_sha256':index_sha,'native_indexed_expected_sha256':sr['index_sha256'],
      'native_indexed_hash_matches':index_sha==sr['index_sha256'],'padding_ltrb':margins,'fits_40px':min(margins)>=40,
      'exact_rgba_mirror':ImageOps.mirror(new).tobytes()==mirror.tobytes(),'comparison':rel(path),
      'comparison_sha256':sha(path),'original_group':r['group_id'],'original_frame':r['frame_index'],
      'registration':rec['registration'],'source_projected_bbox':list(og.getchannel('A').getbbox()),
      'candidate_bbox':list(alpha_bb),'top_delta_vs_source':alpha_bb[1]-og.getchannel('A').getbbox()[1]})

pages=[]
for offset in range(0,len(pairs),4):
    group=pairs[offset:offset+4];w=max(im.width for _,im in group);height=max(im.height for _,im in group)
    sheet=Image.new('RGB',(w*2,height*2),(23,36,49))
    for i,(_,im) in enumerate(group):sheet.paste(im,((i%2)*w,(i//2)*height))
    fp=OUT/('pose-page-'+str(offset//4).zfill(3)+'.png');sheet.save(fp)
    pages.append({'page':rel(fp),'sha256':sha(fp),'pose_ids':[pid for pid,_ in group]})

groups=[]
for g in m['groups']:
    if not g['complete']:continue
    witnesses=[];gif_meta=[]
    for suffix in ['source','mirror']:
        path=BASE/'previews'/('group_'+str(g['group_id']).zfill(2)+'_block_'+str(g['original_block']).zfill(2)+'_'+suffix+'.gif')
        gif=Image.open(path);frames=[];meta=[]
        for i in range(gif.n_frames):
            gif.seek(i);im=gif.convert('RGB');frames.append(im.copy())
            meta.append({'decoded_frame':i,'duration_ms':gif.info.get('duration',0),'rgb_sha256':hashlib.sha256(im.tobytes()).hexdigest()})
        witnesses.append(frames);gif_meta.append({'orientation':suffix,'path':rel(path),'sha256':sha(path),'frames':meta})
    rows=math.ceil(max(len(frames) for frames in witnesses)/4)
    witness=Image.new('RGB',(2048,rows*2*408),(23,36,49))
    draw=ImageDraw.Draw(witness)
    for orientation,frames in enumerate(witnesses):
        for i,im in enumerate(frames):
            x=i%4*512;y=(orientation*rows+i//4)*408
            draw.text((x+5,y+5),'G'+str(g['group_id'])+' '+('SOURCE' if orientation==0 else 'MIRROR')+' GIF decoded '+str(i),fill='white')
            witness.paste(im,(x,y+24))
    path=OUT/('group-'+str(g['group_id']).zfill(2)+'-gif-witness.png');witness.save(path)
    original=next(a for a in c['groups'] if a['group_id']==g['group_id'])
    groups.append({'group_id':g['group_id'],'original_block':g['original_block'],'frame_count':g['frame_count'],
       'source_order':g['pose_ids_in_source_order'],'source_order_matches':g['pose_ids_in_source_order']==original['pose_ids_in_source_order'],
       'exact_aliases':g['exact_aliases'],'contact':g['contact'],'contact_sha256':sha(ROOT/g['contact']),
       'atlas_sha256':g['sha256'],'mirror_atlas_sha256':g['mirror_sha256'],
       'gif_witness':rel(path),'gif_witness_sha256':sha(path),'gif_metadata':gif_meta})

builtin=[];invocations=[]
for path in sorted((BASE/'_source/prompts').glob('*.tool-result.json')):
    result=json.loads(path.read_text(encoding='utf-8'));raw=ROOT/result['raw_png'];saved=Path(result['builtin_saved_png'])
    builtin.append({'metadata':rel(path),'archived':rel(raw),'raw_sha256':sha(raw),'byte_identical':sha(raw)==sha(saved)})
    request_path=path.with_name(path.name.replace('.tool-result.json','.request.json'))
    request=json.loads(request_path.read_text(encoding='utf-8'))
    references=[]
    for original_path in request.get('referenced_image_paths',[]):
        archived=Path(original_path)
        snapshot=False
        if path.name=='pilot-p002-a04-wing-only.tool-result.json':
            if original_path.replace('\\','/').endswith('/poses/bone_dragon_p002.png'):
                archived=BASE/'_source/frozen/pilot-p002-a03-registered-before-wing-edit.png';snapshot=True
            elif original_path.replace('\\','/').endswith('/contacts/pilot/bone_dragon_p002-registered-comparison.png'):
                archived=BASE/'_source/frozen/pilot-p002-a03-comparison-before-wing-edit.png';snapshot=True
        references.append({'original_request_path':original_path,'recoverable_reference':rel(archived),
                           'reference_sha256':sha(archived),'frozen_pre_edit_snapshot':snapshot})
    invocations.append({'metadata':rel(path),'raw':rel(raw),'raw_sha256':sha(raw),'request':rel(request_path),
        'request_sha256':sha(request_path),'references':references,
        'reference_evidence':'Immutable source/raw references or hash-verified frozen snapshots; original request retained exactly.'})
requests=[]
for path in sorted((BASE/'_source/prompts').glob('*.request.json')):
    request=json.loads(path.read_text(encoding='utf-8'))
    requests.append({'request':rel(path),'request_sha256':sha(path),'references':[{'path':rel(Path(p)), 'sha256':sha(Path(p))} for p in request.get('referenced_image_paths',[])]})

proof={'creature_id':'bone_dragon','coverage':m['coverage'],'poses':records,'pose_pages':pages,'groups':groups,
    'builtin_raw_archives':builtin,'executed_invocations':invocations,'requests_and_current_reference_hashes':requests,
    'source_plan_sha256':sha(ROOT/'docs/art/remasters/necropolis-v01/generation-plan.json'),
    'appearance_sha256':sha(ROOT/c['appearance_reference']),
    'all_native_indexed_crops_match':all(r['native_indexed_hash_matches'] for r in records),
    'all_registered_padding_pass':all(r['fits_40px'] for r in records),'all_mirrors_exact':all(r['exact_rgba_mirror'] for r in records),
    'note':'Mechanical evidence and offline decoded GIF frame contacts only; no browser/engine/human playback or original timing proof.'}
(REPORT/'full-mechanical-checks.json').write_text(json.dumps(proof,indent=2)+'\n',encoding='utf-8')
print(json.dumps({'poses':len(records),'groups':len(groups),'pose_pages':len(pages),
    'native_indexed_crops_match':proof['all_native_indexed_crops_match'],'all_padding_pass':proof['all_registered_padding_pass'],
    'all_mirrors_exact':proof['all_mirrors_exact'],'builtin_raw_archives':len(builtin)},indent=2))
