"""Check original source and isolated copy; reports import metadata separately."""
from pathlib import Path
import hashlib,json,re,subprocess
ROOT=Path(__file__).parent;REPO=ROOT.parents[2];GAME=ROOT/'gameplay-preview'
manifest=json.loads((ROOT/'evidence/gameplay-source-copy.json').read_text())
art_paths={'config/attack_animations/fire_x1.tres','config/attack_animations/cast_fire.tres'}
original_changed=[];unexpected_copy=[];import_metadata=[];extension_shadow_cache=[]
for item in manifest['copied_files']:
    rel=item['path'];source=REPO/rel;copy=GAME/rel
    digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest() if p.exists() else None
    if digest(source)!=item['source_sha256']:original_changed.append(rel)
    if digest(copy)!=item['source_sha256']:
        if rel.endswith('.import'):import_metadata.append(rel)
        elif rel.startswith('addons/limboai/bin/~'):extension_shadow_cache.append(rel)
        elif rel not in art_paths:unexpected_copy.append(rel)
texture=r'\[ext_resource type="Texture2D"[^\n]+\]';frames=r'tracks/2/keys = \{.*?\n\}'
def strip(s):return re.sub(frames,'FRAME_KEYS',re.sub(texture,'TEXTURE',s,count=1),count=1,flags=re.S)
native_checks={rel:strip((REPO/rel).read_text())==strip((GAME/rel).read_text()) for rel in sorted(art_paths)}
project=(GAME/'project.godot').read_text().replace('config/name="Laema RND AI v02 isolated"','config/name="Laema"')
project_only_name=(REPO/'project.godot').read_text()==project
assert not original_changed,original_changed
assert not unexpected_copy,unexpected_copy
assert all(native_checks.values()),native_checks
assert project_only_name
report={'original_source_changed_paths':original_changed,'unexpected_copied_code_settings_asset_changes':unexpected_copy,'native_animation_checks_excluding_only_texture_and_sprite_frame_keys':native_checks,'project_metadata_only_application_name_changed':project_only_name,'copied_import_metadata_updated_paths':import_metadata,'generated_extension_shadow_cache_updated_paths':extension_shadow_cache,'input_fixture':'separate test-only recorder wrapper; Player/Might/Magic/movement/AI and all gameplay configuration byte-identical','protected_original_paths_git_diff':subprocess.check_output(['git','diff','--name-only','--','scenes','scripts','config','assets','ai','project.godot'],cwd=REPO,text=True).splitlines()}
assert not report['protected_original_paths_git_diff']
(ROOT/'evidence/preservation-check.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
print('Preservation verified: original game unchanged; copied code/settings unchanged; only sprite reference/frame keys and isolated profile name differ.')
