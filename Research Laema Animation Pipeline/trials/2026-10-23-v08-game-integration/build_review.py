"""Index actual captured viewport frames. Never reconstruct gameplay from sprites."""
from pathlib import Path
import json, statistics, collections, shutil

ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / 'outputs'
OUTPUT.mkdir(exist_ok=True)
catalog, results = [], []
for run, label in [('baseline-motion-run', 'Current game'), ('v08-motion-run', 'v08 in game')]:
    events = [json.loads(line) for line in (ROOT / 'evidence' / run / 'events.jsonl').read_text().splitlines()]
    accepted = next(e for e in events if e['kind'] == 'combat_outcome' and e.get('command_id') == 1
                    and e['outcome']['kind'] == 'action_accepted' and e['outcome'].get('action_kind') == 'light')
    origin = accepted['command_elapsed_ms']
    captures = [e for e in events if e['kind'] == 'capture' and e.get('command_id') == 1]
    finished = next(e for e in events if e['kind'] == 'command_finished' and e['id'] == 1)
    frames = []
    for capture in captures:
        path = Path(capture['paths']['review'])
        assert path.is_file()
        sprite = capture['state']['player']['sprite']
        frames.append({'t': capture['command_elapsed_ms'] - origin,
                       'src': path.relative_to(ROOT).as_posix(),
                       'region': sprite['region'], 'texture': sprite['texture'],
                       'heat': capture['state']['heat']})
    intervals = [b['t'] - a['t'] for a, b in zip(frames, frames[1:])]
    external = [e for e in events if e['kind'] == 'input_observed' and e.get('source') == 'unexpected_external']
    outcomes = collections.Counter(e['outcome']['kind'] for e in events
                                   if e['kind'] == 'combat_outcome' and e.get('command_id') == 1)
    result = {'run': run, 'captured_frames': len(frames), 'capture_interval_median_ms': statistics.median(intervals),
              'capture_interval_max_ms': max(intervals), 'max_scheduled_input_lateness_ms': max(e['lateness_ms'] for e in events if e['kind'] == 'scheduled_input'),
              'unexpected_events_before_command': len([e for e in external if e.get('command_id') is None]),
              'unexpected_events_during_command': len([e for e in external if e.get('command_id') == 1]),
              'outcome_counts': dict(outcomes), 'player_hp_at_command_end': finished['state']['player']['hp'],
              'enemy_hp_at_command_end': finished['state']['enemy']['hp'],
              'alignment': 'First accepted X1 action, not frame-perfect deterministic encounter replay',
              'first_X1_accepted_command_ms': origin}
    results.append(result)
    catalog.append({'label': label, 'run': run, 'frames': frames, 'stats': result})
v08 = catalog[1]
proof = next(f for f in v08['frames'] if f['texture'].endswith('x1-one-pose-structural-v08.png') and f['region'] == [2688., 0., 448., 448.])
shutil.copy2(ROOT / proof['src'], OUTPUT / 'v08-grip-in-game.jpg')
baseline = min(catalog[0]['frames'], key=lambda f: abs(f['t'] - proof['t']))
shutil.copy2(ROOT / baseline['src'], OUTPUT / 'current-game-near-grip-time.jpg')
data = {'runs': catalog, 'proof_t_ms': proof['t'], 'X1_loop_ms': [-350, 1250], 'encounter_ms': [-1400, 6700],
        'captured_viewport': [1280, 720], 'real_gameplay': True, 'art_approved': False,
        'limits': 'Measured irregular viewport samples. Playback uses the recorded timestamps; it is not a 60fps performance measurement. Heat and hit-stop follow actual gameplay.'}
(OUTPUT / 'replay-data.json').write_text(json.dumps(data) + '\n', encoding='utf-8')
report = {'runs': results, 'scope': 'Real copied Gym, Godot4.7.1, existing action-level input schedule. Only X1 artwork changes.',
          'first_PNG_runs': 'Preserved diagnostic captures; too sparse for motion judging. Not used in the moving comparison.',
          'gameplay_changes': False, 'human_approval': False, 'workflow_winner': None,
          'startup_input_limit': 'External controller events occurred before command/device isolation. None during either recorded command. Separate runs are not identical initial-state or hardware-controller tests.',
          'shutdown': 'All recorder sessions retained the existing13 ObjectDB /9 resource shutdown warnings. Not resolved here.',
          'import': 'First v08 editor pass reported PNG not yet imported before filesystem import; subsequent game runs loaded the expected v08 texture. Initial log preserved.',
          'key7_observed_in_actual_capture': proof,
          'interaction': 'Ordinary copied game launched separately with normal hardware bindings; human play/visual acceptance pending.'}
(ROOT / 'evidence/verification.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({'proof_t_ms': proof['t'], 'runs': results}, indent=2))
