"""Install presentation-only trial atlases in the bounded copied project."""
from pathlib import Path
import json,re,hashlib,shutil
ROOT=Path(__file__).parent
REPO=ROOT.parents[2]
GAME=ROOT/'gameplay-preview'
assert GAME.resolve().is_relative_to(ROOT.resolve())
data=json.loads((ROOT/'outputs/clips.json').read_text())
changes=[]
for clip_id,filename,resource in [('x1_refined','x1-refined.png','fire_x1.tres'),('cast_reuse','cast-reuse.png','cast_fire.tres')]:
    clip=next(c for c in data['clips'] if c['id']==clip_id)
    target=GAME/'assets/prototype/player/fire_sword_shield_v01/rnd_ai_v02'/filename;target.parent.mkdir(parents=True,exist_ok=True)
    shutil.copy2(ROOT/'outputs'/filename,target)
    original=(REPO/'config/attack_animations'/resource).read_text(encoding='utf-8')
    texture_pattern=r'\[ext_resource type="Texture2D"[^\n]+\]'
    updated=re.sub(texture_pattern,f'[ext_resource type="Texture2D" path="res://assets/prototype/player/fire_sword_shield_v01/rnd_ai_v02/{filename}" id="1_sheet"]',original,count=1)
    times=[t/.21*.6 if t<=.21 else .6+(t-.21)/.51*.4 for t in clip['times']] if clip_id=='x1_refined' else [t/1.2 for t in clip['times']]
    rects=[f'Rect2({i%clip["columns"]*448}, {i//clip["columns"]*448}, 448, 448)' for i in range(len(times))]
    new_keys='tracks/2/keys = {\n"times": PackedFloat32Array('+', '.join(f'{t:.11g}' for t in times)+'),\n"transitions": PackedFloat32Array('+', '.join(['1']*len(times))+'),\n"update": 1,\n"values": ['+', '.join(rects)+']\n}'
    keys_pattern=r'tracks/2/keys = \{.*?\n\}'
    updated=re.sub(keys_pattern,lambda _:new_keys,updated,count=1,flags=re.S)
    def strip_presentation(s):return re.sub(keys_pattern,'FRAME_KEYS',re.sub(texture_pattern,'TEXTURE_REFERENCE',s,count=1),count=1,flags=re.S)
    assert strip_presentation(original)==strip_presentation(updated),resource
    (GAME/'config/attack_animations'/resource).write_text(updated,encoding='utf-8',newline='\n')
    changes.append({'file':f'config/attack_animations/{resource}','allowed_changes':['Texture2D reference only','Sprite region frame keys only'],'all_other_resource_text_identical':True,'source_sha256':hashlib.sha256(original.encode()).hexdigest(),'copy_sha256':hashlib.sha256(updated.encode()).hexdigest()})
# Unique user-data profile prevents test runs reading/writing the user's game profile.
project=(GAME/'project.godot').read_text(encoding='utf-8').replace('config/name="Laema"','config/name="Laema RND AI v02 isolated"')
(GAME/'project.godot').write_text(project,encoding='utf-8',newline='\n')
driver=GAME/'tools/tests/overnight_fire_playtest.gd';driver.parent.mkdir(parents=True,exist_ok=True)
shutil.copy2(REPO/'tools/tests/overnight_fire_playtest.gd',driver)
report={'scope':'isolated copied game only','artwork_resources':changes,'gameplay_code_changed':False,'queries_markers_body_CastOrigin_lunge_damage_settings_changed':False,'project_metadata_change':'unique application name/user-data profile only','recorder':'byte-identical existing overnight_fire_playtest.gd; ordinary bound input events; no forced state','recorder_sha256':hashlib.sha256(driver.read_bytes()).hexdigest()}
(ROOT/'evidence/art-only-copy-patch.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Installed only trial sprite texture/frame keys in copied X1 and Cast; other native resource text is identical.')
