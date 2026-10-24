"""Read the currently bound game artwork/timing; export an unmodified review baseline."""
from pathlib import Path
import hashlib,json,re,shutil,subprocess
from PIL import Image

ROOT=Path(__file__).parent
REPO=ROOT.parents[2]
OUT=ROOT/'outputs'
def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()
def number(text,key,default=None):
    match=re.search(r'^'+re.escape(key)+r' = ([\d.eE+-]+)$',text,re.M)
    if match:return float(match.group(1))
    if default is not None:return default
    raise ValueError(key)

clips=[]
for action,resource in [('x1','fire_x1.tres'),('cast','cast_fire.tres')]:
    path=REPO/'config/attack_animations'/resource
    text=path.read_text(encoding='utf-8')
    texture=re.search(r'\[ext_resource type="Texture2D"[^\n]*path="res://([^"]+)"',text).group(1)
    source=REPO/texture
    track=re.search(r'tracks/(\d+)/path = NodePath\("Sprite:region_rect"\)',text).group(1)
    keys=re.search(r'tracks/'+track+r'/keys = \{(.*?)\n\}',text,re.S).group(1)
    native=[float(v) for v in re.search(r'"times": PackedFloat32Array\(([^)]+)\)',keys).group(1).split(',')]
    rects=[[int(float(v)) for v in item.split(',')] for item in re.findall(r'Rect2\(([^)]+)\)',keys)]
    length=number(text,'length',1.0)
    if action=='x1':
        style_path=REPO/'config/attack_styles/fire_x1.tres'
        style=style_path.read_text(encoding='utf-8')
        windup=number(style,'windup_duration');recovery=number(style,'recovery_duration')
        split=float(re.search(r'"name": &"timing_split",\s*"time": ([\d.]+)',text).group(1))
        times=[t/split*windup if t<=split else windup+(t-split)/(length-split)*recovery for t in native]
        duration=windup+recovery
        timing_source={'file':style_path.relative_to(REPO).as_posix(),'sha256':sha(style_path),'windup':windup,'recovery':recovery,'native_split':split}
    else:
        tuning_path=REPO/'config/characters/player.tres'
        tuning=tuning_path.read_text(encoding='utf-8')
        duration=float(re.search(r'"attack_duration": ([\d.]+)',tuning).group(1))
        assert re.search(r'"cast": \{[^}]*"duration_key": "attack_duration"',tuning,re.S)
        times=[t/length*duration for t in native]
        timing_source={'file':tuning_path.relative_to(REPO).as_posix(),'sha256':sha(tuning_path),'duration_key':'attack_duration'}
    filename=f'current-game-{action}.png'
    shutil.copyfile(source,OUT/filename)
    assert sha(source)==sha(OUT/filename)
    with Image.open(source) as im:
        columns=im.width//448
        assert all(r==[i%columns*448,i//columns*448,448,448] for i,r in enumerate(rects))
    clips.append({'id':'game_'+action,'label':'Current game '+('X1' if action=='x1' else 'Cast'),'file':filename,'columns':columns,'duration':duration,'times':times,'native_times':native,'native_rects':rects,'resource':path.relative_to(REPO).as_posix(),'resource_sha256':sha(path),'texture':texture,'texture_sha256':sha(source),'copied_texture_byte_identical':True,'timing_source':timing_source})

data={'scope':'Currently bound resources in the main local checkout; source-timed browser reconstruction, not recorded gameplay or a published-build capture.','source_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),'cell':[448,448],'foot_anchor':[224,400],'draw_scale':1,'source_files_modified':False,'clips':clips}
(OUT/'game-baselines.json').write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8',newline='\n')
trial=json.loads((OUT/'clips.json').read_text())
review={'game':clips,'trial':trial['clips'],'baseline_scope':data['scope']}
template=(ROOT/'review.template.html').read_text(encoding='utf-8')
(ROOT/'review.html').write_text(template.replace('__REVIEW_DATA__',json.dumps(review,separators=(',',':'))),encoding='utf-8',newline='\n')
print('Current-game X1/Cast exported byte-identically, with their native frame exposure and action clocks.')
