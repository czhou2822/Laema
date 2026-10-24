"""Bounded actual-game trial: source copy, baseline recording, X1-only art patch."""
from pathlib import Path
import hashlib, json, re, shutil, subprocess, sys

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[2]
GAME = ROOT / 'gameplay-preview'
V08 = ROOT.parent / '2026-10-23-x1-structural-grip-v08'
V02 = ROOT.parent / '2026-10-23-ai-refine-v02'
EVIDENCE = ROOT / 'evidence'
EVIDENCE.mkdir(exist_ok=True)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
resource_rel = 'config/attack_animations/fire_x1.tres'

def prepare():
    assert GAME.is_relative_to(ROOT)
    if GAME.exists():
        raise SystemExit('Existing game copy preserved; refusing to overwrite.')
    GAME.mkdir()
    records = []
    for name in ['addons', 'scenes', 'scripts', 'config', 'assets', 'ai']:
        shutil.copytree(REPO / name, GAME / name,
                        ignore=shutil.ignore_patterns('.godot', '__pycache__'))
    for name in ['project.godot', 'icon.svg']:
        shutil.copy2(REPO / name, GAME / name)
    for path in list(GAME.rglob('*')):
        if path.is_file() and path.suffix in ['.gd', '.tscn', '.tres', '.godot', '.gdextension']:
            for rel in re.findall(r'res://([^"\n]+)', path.read_text(encoding='utf-8', errors='replace')):
                source, target = REPO / rel, GAME / rel
                if source.is_file() and source.resolve().is_relative_to(REPO) and not target.exists():
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(source, target)
    for name in ['addons', 'scenes', 'scripts', 'config', 'assets', 'ai', 'project.godot', 'icon.svg']:
        paths = sorted((REPO / name).rglob('*')) if (REPO / name).is_dir() else [REPO / name]
        for source in paths:
            if source.is_file() and '.godot' not in source.parts and '__pycache__' not in source.parts:
                rel = source.relative_to(REPO).as_posix()
                assert sha(source) == sha(GAME / rel), rel
                records.append({'path': rel, 'source_sha256': sha(source)})
    project = GAME / 'project.godot'
    project.write_text(project.read_text(encoding='utf-8').replace(
        'config/name="Laema"', 'config/name="Laema RND v08 game trial"'), encoding='utf-8', newline='\n')
    driver = GAME / 'tools/tests/overnight_fire_playtest.gd'
    driver.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(REPO / 'tools/tests/overnight_fire_playtest.gd', driver)
    shutil.copy2(V02 / 'isolated_input_recorder.gd', driver.with_name('rnd_isolated_input.gd'))
    (ROOT / 'inputs').mkdir(exist_ok=True)
    shutil.copy2(REPO / resource_rel, ROOT / 'inputs/current-game-fire_x1.tres')
    events = [json.loads(line) for line in (V02 / 'evidence/gameplay-run-03/events.jsonl').read_text(encoding='utf-8').splitlines()]
    old = next(e['requested'] for e in events if e['kind'] == 'command_accepted' and e['id'] == 1)
    command = dict(old, id=1, capture_every_ms=75, capture_scale=1.0,
                   keyframes_ms=[1450, 1580, 1615, 1640, 1700, 1900, 2200, 3200, 5000])
    for run in ['baseline-run', 'v08-run']:
        folder = EVIDENCE / run
        folder.mkdir(exist_ok=True)
        (folder / 'command.json').write_text(json.dumps(command, indent=2) + '\n', encoding='utf-8', newline='\n')
    manifest = {'source_revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=REPO, text=True).strip(),
                'copied_files': records, 'policy': 'Actual game copy. Only copied X1 texture and sprite-region keys may change. Unique app name isolates user data. The copied recorder is action-level input and viewport observation only.',
                'recorder_sha256': sha(driver), 'routing_sha256': sha(driver.with_name('rnd_isolated_input.gd'))}
    (EVIDENCE / 'source-copy.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(f'Copied and verified {len(records)} source files. Ready for baseline actual-game recording.')

def install():
    resource = GAME / resource_rel
    original = (ROOT / 'inputs/current-game-fire_x1.tres').read_text(encoding='utf-8')
    assert resource.read_text(encoding='utf-8') == original, 'Expected preserved baseline resource.'
    clip = next(c for c in json.loads((V08 / 'outputs/clips.json').read_text())['clips'] if c['id'] == 'structural_v08')
    rel = 'assets/prototype/player/fire_sword_shield_v01/rnd_v08/x1-one-pose-structural-v08.png'
    target = GAME / rel
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(V08 / 'outputs' / clip['file'], target)
    texture = r'\[ext_resource type="Texture2D"[^\n]+\]'
    keys = r'tracks/2/keys = \{.*?\n\}'
    updated = re.sub(texture, f'[ext_resource type="Texture2D" path="res://{rel}" id="1_sheet"]', original, count=1)
    times = [t/.21*.6 if t <= .21 else .6+(t-.21)/.51*.4 for t in clip['times']]
    rects = [f'Rect2({i%8*448}, {i//8*448}, 448, 448)' for i in range(len(times))]
    values = 'tracks/2/keys = {\n"times": PackedFloat32Array(' + ', '.join(f'{t:.11g}' for t in times) + '),\n"transitions": PackedFloat32Array(' + ', '.join(['1']*len(times)) + '),\n"update": 1,\n"values": [' + ', '.join(rects) + ']\n}'
    updated = re.sub(keys, lambda _: values, updated, count=1, flags=re.S)
    def masked(s):
        return re.sub(keys, 'FRAME_KEYS', re.sub(texture, 'TEXTURE_REFERENCE', s, count=1), count=1, flags=re.S)
    assert masked(original) == masked(updated)
    resource.write_text(updated, encoding='utf-8', newline='\n')
    report = {'changed_resource': resource_rel, 'allowed_changes': ['X1 Sprite texture', 'X1 Sprite region rectangles and drawing-exposure keys'],
              'all_other_resource_text_identical': True, 'new_texture_sha256': sha(target),
              'gameplay_code_or_settings_changed': False, 'contact_curves_or_markers_changed': False,
              'actor_registration_changed': False, 'Cast_and_other_actions_changed': False,
              'X1_Heat0_duration_s': .72, 'fixed_Heat100_duration_s': .48,
              'Heat0_active_window_s': [.126, .5075], 'v08_change_vs_v05': 'Only drawing7 at .158s; entire trial strip remains unapproved.'}
    (EVIDENCE / 'art-only-patch.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    verify()
    print('Installed v08 X1 art in copied game. Native markers/geometry/settings and all other actions are exact.')

def verify():
    manifest = json.loads((EVIDENCE / 'source-copy.json').read_text())
    different = []
    managed_aliases = []
    for record in manifest['copied_files']:
        rel = record['path']
        assert sha(REPO / rel) == record['source_sha256'], f'Source changed during trial: {rel}'
        if rel == 'addons/limboai/bin/~liblimboai.windows.editor.x86_64.dll' and not (GAME / rel).exists():
            canonical = 'addons/limboai/bin/liblimboai.windows.editor.x86_64.dll'
            assert sha(GAME / canonical) == record['source_sha256']
            managed_aliases.append({'path': rel, 'observation': 'Copied byte-identical editor DLL alias absent after Godot import. Canonical DLL retained byte-identical.'})
            continue
        if sha(GAME / rel) != record['source_sha256']:
            different.append(rel)
    assert set(different) <= {resource_rel, 'project.godot'}, different
    result = {'source_files_unchanged': len(manifest['copied_files']), 'copied_files_different': different,
              'source_revision': manifest['source_revision'], 'source_gameplay_unchanged': True,
              'engine_managed_alias_observations': managed_aliases}
    (EVIDENCE / 'preservation.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(result))

if __name__ == '__main__':
    {'prepare': prepare, 'install': install, 'verify': verify}[sys.argv[1]]()
