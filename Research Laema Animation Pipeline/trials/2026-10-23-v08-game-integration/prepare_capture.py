"""A faster viewport recorder; input scheduling and gameplay remain unchanged."""
from pathlib import Path
import json, hashlib, shutil
from prepare_game import ROOT, REPO, GAME, V02

source = (REPO / 'tools/tests/overnight_fire_playtest.gd').read_text(encoding='utf-8')
changes = [
    ('paths["review"] = stem + ".png"', 'paths["review"] = stem + ".jpg"'),
    ('review.save_png(paths["review"])', 'review.save_jpg(paths["review"], 0.96)'),
    ('review_png_save_us', 'review_jpeg_save_us'),
    ('clampf(float(raw.get("capture_every_ms", 125.0)), 50.0, 5000.0)', 'clampf(float(raw.get("capture_every_ms", 125.0)), 16.0, 5000.0)'),
    ('"res://tools/tests/overnight_fire_playtest.gd"', '"res://tools/tests/rnd_gameplay_capture.gd"'),
    ('"input_mode": "scheduled bound hardware events; wall-clock only; no state-oracle timing"', '"input_mode": "scheduled action events via isolated device7; wall-clock only; no state-oracle timing"'),
]
updated = source
for before, after in changes:
    assert before in updated, before
    updated = updated.replace(before, after)
(GAME / 'tools/tests/rnd_gameplay_capture.gd').write_text(updated, encoding='utf-8', newline='\n')
wrapper = (V02 / 'isolated_input_recorder.gd').read_text(encoding='utf-8').replace(
    'extends "res://tools/tests/overnight_fire_playtest.gd"', 'extends "res://tools/tests/rnd_gameplay_capture.gd"')
(GAME / 'tools/tests/rnd_isolated_input.gd').write_text(wrapper, encoding='utf-8', newline='\n')
baseline = ROOT / 'inputs/current-game-fire_x1.tres'
shutil.copy2(baseline, GAME / 'config/attack_animations/fire_x1.tres')
command = next(json.loads(s)['requested'] for s in (ROOT / 'evidence/baseline-run/events.jsonl').read_text().splitlines()
               if json.loads(s)['kind'] == 'command_accepted' and json.loads(s)['id'] == 1)
command.update(capture_every_ms=16, capture_scale=1, keyframes_ms=[])
for run in ['baseline-motion-run', 'v08-motion-run']:
    folder = ROOT / 'evidence' / run
    assert not folder.exists(), 'Preserve existing recordings.'
    folder.mkdir()
    (folder / 'command.json').write_text(json.dumps(command, indent=2) + '\n', encoding='utf-8')
report = {'purpose': 'Actual viewport recording for motion review. Earlier PNG captures were too sparse and remain preserved.',
          'capture_only_changes': changes, 'jpeg_quality': .96, 'requested_interval_ms': 16,
          'native_viewport': [1280, 720], 'full_png_keyframes_disabled_for_throughput': True,
          'gameplay_or_clock_changes': False, 'input_schedule_changes': False,
          'source_recorder_sha256': hashlib.sha256(source.encode()).hexdigest(),
          'derived_recorder_sha256': hashlib.sha256(updated.encode()).hexdigest(),
          'limits': 'Captured frame intervals are measured; no stable FPS or physical-controller acceptance claim.'}
(ROOT / 'evidence/recording-fixture.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print('Prepared faster recording fixture and restored copied baseline art for the paired recordings.')
