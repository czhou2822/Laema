#!/usr/bin/env python3
"""Isolated Godot4.7 resource/import validation; never loads the game or its actors."""
import argparse
import hashlib
import datetime
import json
import os
import re
import shutil
import subprocess
import uuid
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
DOC=ROOT/'docs/art/remasters/necropolis-v01'

CHECK_SCRIPT='''extends SceneTree
func _initialize() -> void:
    var specs = JSON.parse_string(FileAccess.get_file_as_string("res://checks.json"))
    var failures: Array[String] = []
    var groups_checked := 0
    var frames_checked := 0
    var libraries_checked := 0
    for spec in specs:
        var resource = load(spec.path) as SpriteFrames
        if resource == null:
            failures.append("SpriteFrames load failed: " + str(spec.path))
            continue
        libraries_checked += 1
        if resource.get_animation_names().size() != spec.groups.size():
            failures.append("Group count: " + str(spec.path))
        for group in spec.groups:
            var animation := StringName(group.name)
            if not resource.has_animation(animation):
                failures.append("Missing animation: " + str(animation))
                continue
            groups_checked += 1
            if resource.get_frame_count(animation) != int(group.frames):
                failures.append("Frame count: " + str(animation))
            if not is_equal_approx(resource.get_animation_speed(animation), 10.0):
                failures.append("Preview fps: " + str(animation))
            if resource.get_animation_loop(animation) != bool(group.loop):
                failures.append("Preview loop: " + str(animation))
            for frame in range(resource.get_frame_count(animation)):
                var texture := resource.get_frame_texture(animation, frame) as AtlasTexture
                if texture == null or texture.atlas == null:
                    failures.append("Texture load: " + str(animation) + ":" + str(frame))
                    continue
                var expected := Rect2((frame % 4) * 1024, (frame / 4) * 768, 1024, 768)
                if texture.region != expected:
                    failures.append("Atlas region: " + str(animation) + ":" + str(frame))
                if texture.get_width() != 1024 or texture.get_height() != 768:
                    failures.append("Cell geometry: " + str(animation))
                frames_checked += 1
        resource = null
    var report = {"libraries_loaded":libraries_checked, "groups_loaded":groups_checked,
        "frame_regions_checked":frames_checked,"failures":failures,
        "engine_version":Engine.get_version_info(),"test_scope":"isolated asset import/resource load only",
        "human_gameplay_validation":false,"original_timing_verified":false}
    var file := FileAccess.open("res://engine-result.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(report, "  "))
    file.close()
    print(JSON.stringify(report))
    quit(0 if failures.is_empty() else 1)
'''

def pilot_resource(groups,mirror=False):
    count=sum(g['frame_count'] for g in groups)
    lines=[f'[gd_resource type="SpriteFrames" load_steps={1+len(groups)+count} format=3]','']
    for i,g in enumerate(groups,1):
        file=g['mirror_file'] if mirror else g['file']
        lines.append(f'[ext_resource type="Texture2D" path="res://{file}" id="{i}"]')
    for i,g in enumerate(groups,1):
        for frame in range(g['frame_count']):
            key=f'g{g["group_id"]}_b{g["original_block"]}_f{frame}'
            lines += ['',f'[sub_resource type="AtlasTexture" id="{key}"]',f'atlas = ExtResource("{i}")',f'region = Rect2({frame%4*1024}, {frame//4*768}, 1024, 768)']
    lines+=['','[resource]','animations = [']
    for i,g in enumerate(groups):
        frames=[f'{{"duration":1.0,"texture":SubResource("g{g["group_id"]}_b{g["original_block"]}_f{f}")}}' for f in range(g['frame_count'])]
        lines += ['{','"frames":['+','.join(frames)+'],',f'"loop":{str(g["group_id"] in [0,2]).lower()},',f'"name":&"og_{g["group_id"]:02d}_block_{g["original_block"]:02d}",','"speed":10.0','}'+(',' if i<len(groups)-1 else '')]
    lines+= [']'];return '\n'.join(lines)+'\n'

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--godot',type=Path,required=True)
    parser.add_argument('--fixture-root',type=Path,required=True);parser.add_argument('--pilot',action='store_true')
    parser.add_argument('--creature',action='append',help='Pilot-only finished subset; omit for full collection validation')
    parser.add_argument('--copy-import-descriptors',action='store_true');args=parser.parse_args()
    if args.creature and not args.pilot:raise SystemExit('Subset selection is pilot-only, never full collection clearance')
    receipt_dir=DOC/'validation/engine'
    stem='pilot-validation' if args.pilot else 'validation-summary'
    prior=receipt_dir/(stem+'.json')
    if prior.exists():
        old=json.loads(prior.read_text());old_id=Path(old.get('fixture_path','previous')).name
        archive=receipt_dir/'attempts'/old_id;archive.mkdir(parents=True,exist_ok=True)
        for suffix in ['.json','-import.log','-resource.log']:
            previous=receipt_dir/(stem+suffix)
            if previous.exists() and not (archive/previous.name).exists():shutil.copy2(previous,archive/previous.name)
    if not args.godot.is_file():raise SystemExit('Godot executable unavailable; no engine result claimed')
    version=subprocess.run([str(args.godot),'--headless','--version'],capture_output=True,text=True,timeout=30)
    if version.returncode or not version.stdout.strip().startswith('4.7.'):
        raise SystemExit('Compatible Godot4.7.x required; observed '+version.stdout.strip())
    plan=json.loads((DOC/'generation-plan.json').read_text());specs=[];images=set();resources=[]
    if args.creature and any(cid not in [c['creature_id'] for c in plan['creatures']] for cid in args.creature):raise SystemExit('Unknown selected creature')
    for creature in plan['creatures']:
        if args.creature and creature['creature_id'] not in args.creature:continue
        dd=ROOT/'assets/prototype/enemy'/creature['creature_id']/'remaster_v01';mf=dd/'source_manifest.json'
        if not mf.exists():
            if args.pilot:continue
            raise SystemExit('Full validation requires every creature manifest')
        manifest=json.loads(mf.read_text());groups=[g for g in manifest['groups'] if g['complete']]
        if not args.pilot and len(groups)!=creature['original_group_slots']:raise SystemExit('Full validation requires all groups: '+creature['creature_id'])
        if not groups:continue
        for group in groups:
            images.add(group['file']);images.add(group['mirror_file'])
        for mirror in [False,True]:
            name='original_groups_mirrored.tres' if mirror else 'original_groups.tres'
            path=dd/name
            temporary=args.pilot and not path.exists()
            if not path.exists() and not temporary:raise SystemExit('Native preview resource missing: '+str(path))
            relative=path.relative_to(ROOT).as_posix()
            resources.append((relative,pilot_resource(groups,mirror) if temporary else None))
            specs.append({'path':'res://'+relative,'pilot_generated_resource':temporary,
                'groups':[{'name':f'og_{g["group_id"]:02d}_block_{g["original_block"]:02d}','frames':g['frame_count'],'loop':g['group_id'] in [0,2]} for g in groups]})
    if not specs:raise SystemExit('No supplied groups to validate')
    fixture_base=args.fixture_root.resolve();fixture_base.mkdir(parents=True,exist_ok=True)
    fixture=fixture_base/('pilot-' if args.pilot else 'full-')/uuid.uuid4().hex
    fixture.mkdir(parents=True,exist_ok=False)
    local_environment=dict(os.environ)
    for variable,folder in [('APPDATA','userdata-roaming'),('LOCALAPPDATA','userdata-local'),('TEMP','temp'),('TMP','temp')]:
        directory=fixture/folder;directory.mkdir(exist_ok=True);local_environment[variable]=str(directory)
    for relative in sorted(images):
        src=(ROOT/relative).resolve()
        if not src.is_relative_to(ROOT.resolve()):raise SystemExit('Outside asset source scope')
        target=fixture/relative;target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(src,target)
    for relative,temporary in resources:
        target=fixture/relative;target.parent.mkdir(parents=True,exist_ok=True)
        if temporary:target.write_text(temporary)
        else:shutil.copy2(ROOT/relative,target)
    asset_inputs=[{'path':relative,'sha256':hashlib.sha256((fixture/relative).read_bytes()).hexdigest(),'bytes':(fixture/relative).stat().st_size}
        for relative in sorted(images|{relative for relative,_ in resources})]
    (fixture/'project.godot').write_text('config_version=5\n[application]\nconfig/name="Necropolis isolated asset validation"\n[rendering]\nrenderer/rendering_method="gl_compatibility"\n[debug]\nfile_logging/enable_file_logging=false\n')
    (fixture/'checks.gd').write_text(CHECK_SCRIPT)
    (fixture/'checks.json').write_text(json.dumps(specs,indent=2)+'\n')
    imported=subprocess.run([str(args.godot),'--headless','--log-file',str(fixture/'godot-import-output.log'),'--editor','--path',str(fixture),'--import'],capture_output=True,text=True,timeout=600,env=local_environment)
    (fixture/'import.log').write_text(imported.stdout+'\n'+imported.stderr)
    if imported.returncode:raise SystemExit('Godot import failed; evidence retained at '+str(fixture))
    descriptors=[];settings_errors=[]
    for relative in sorted(images):
        fp=fixture/(relative+'.import')
        if not fp.exists():settings_errors.append(relative+': descriptor missing');continue
        text=fp.read_text()
        if not re.search(r'^compress/mode\s*=\s*0\s*$',text,re.M):settings_errors.append(relative+': not lossless')
        if not re.search(r'^mipmaps/generate\s*=\s*false\s*$',text,re.M):settings_errors.append(relative+': mipmaps not disabled')
        descriptors.append(relative+'.import')
    run=subprocess.run([str(args.godot),'--headless','--log-file',str(fixture/'godot-resource-output.log'),'--path',str(fixture),'--script','res://checks.gd'],capture_output=True,text=True,timeout=600,env=local_environment)
    (fixture/'resource-check.log').write_text(run.stdout+'\n'+run.stderr)
    result_path=fixture/'engine-result.json'
    result=json.loads(result_path.read_text()) if result_path.exists() else {'failures':['Engine produced no result JSON']}
    errors=settings_errors+result.get('failures',[])
    if run.returncode:errors.append('Engine resource runner exit '+str(run.returncode))
    if re.search(r'SCRIPT ERROR|Parse Error|ERROR:',run.stderr+'\n'+run.stdout):errors.append('Engine emitted an error diagnostic')
    if re.search(r'SCRIPT ERROR|Parse Error|ERROR:',imported.stderr+'\n'+imported.stdout):errors.append('Engine import emitted an error diagnostic')
    summary={'mode':'pilot subset smoke check; temporary resources only where native library absent' if args.pilot else 'full source/mirror native libraries',
        'collection_run':not args.pilot,'temporary_library_count':sum(s['pilot_generated_resource'] for s in specs),
        'selected_creatures':sorted({relative.split('/')[3] for relative,_ in resources}),
        'godot_version':version.stdout.strip(),'compatible_declared_engine':True,'fixture_path':str(fixture),
        'texture_imports':len(descriptors),'expected_libraries':len(specs),'expected_groups':sum(len(s['groups']) for s in specs),
        'expected_frame_regions':sum(g['frames'] for s in specs for g in s['groups']),
        'import_exit':imported.returncode,'resource_exit':run.returncode,'result':result,
        'errors':errors,'passed':not errors,'human_gameplay_validation':False,'original_timing_verified':False,
        'original_game_project_loaded':False,'project_code_changed':False}
    summary['engine_userdata_and_cache']='Task-local child-process APPDATA/LOCALAPPDATA/TEMP/TMP, self-contained editor copy where configured; no host preferences changed'
    summary['asset_inputs']=asset_inputs
    summary['validator_sha256']=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    out=DOC/'validation/engine';out.mkdir(parents=True,exist_ok=True)
    stem='pilot-validation' if args.pilot else 'validation-summary'
    (out/(stem+'.json')).write_text(json.dumps(summary,indent=2)+'\n')
    shutil.copy2(fixture/'import.log',out/(stem+'-import.log'));shutil.copy2(fixture/'resource-check.log',out/(stem+'-resource.log'))
    if args.copy_import_descriptors:
        if args.pilot or errors:raise SystemExit('Do not publish descriptors from partial/failed validation')
        for relative in descriptors:shutil.copy2(fixture/relative,ROOT/relative)
    print(json.dumps({k:v for k,v in summary.items() if k!='asset_inputs'},indent=2))
    if errors:raise SystemExit(1)

if __name__=='__main__':main()
