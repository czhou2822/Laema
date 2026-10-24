"""Reconcile this authorized isolated game trial without product changes."""
from pathlib import Path
import json, hashlib, datetime
ROOT = Path(__file__).resolve().parent
RESEARCH = ROOT.parents[1]
REPO = RESEARCH.parent
TRIAL = ROOT.relative_to(RESEARCH).as_posix()
summary = ('Latest integration: the user requested "put it into the game and lets see". '
           f'[{"v08 actual-game trial"}]({TRIAL}/README.md) is a fresh isolated Gym copy. '
           f'[{"The current replay"}]({TRIAL}/review.html) compares real current-art/v08 viewports; '
           'a separate normal-controls playable window was opened. Only copied X1 artwork/drawing keys '
           'changed. Both sequences observed X1 contact/orb/Charging/Cast impact/Dodge/incoming interruption. '
           'Source gameplay is unchanged. Variable sample intervals, pre-command controller events, '
           'scheduling limits and retained shutdown warnings are recorded in its evidence. '
           'Human visual acceptance remains pending; this test request does not approve artwork or propagation. '
           'Current game remains the last stated overall preference. This newer run supersedes older '
           '"last integration v02" statements only within its stated scope.')
for name in ['CONTINUE_LOCAL.md', 'FINDINGS.md', 'LOCAL_RECONCILIATION.md']:
    path = RESEARCH / name
    text = path.read_text(encoding='utf-8')
    first, rest = text.split('\n', 1)
    assert summary not in text
    path.write_text(first + '\n\n' + summary + '\n' + rest, encoding='utf-8', newline='\n')
path = RESEARCH / 'README.md'
text = path.read_text(encoding='utf-8')
parts = text.split('\n\n')
index = next(i for i, p in enumerate(parts) if p.startswith('**Local status:'))
parts[index] = ('**Local status: v08 now has an actual isolated game trial; human visual approval is pending.** '
                + summary)
path.write_text('\n\n'.join(parts), encoding='utf-8', newline='\n')
record_path = RESEARCH / 'evidence/round-record.json'
record = json.loads(record_path.read_text())
record.update(updated_at_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
              latest_integration_trial=TRIAL, isolated_copy_gameplay_trial=TRIAL,
              latest_trial_gameplay_run=True, latest_trial=TRIAL,
              latest_artwork_trial='trials/2026-10-23-x1-structural-grip-v08',
              phase4='v08 X1 actual copied Gym runs and normal-controls interactive launch; human visual acceptance pending. Source gameplay unchanged. See current trial evidence for precise coverage and limits.',
              awaiting_user='Judge v08 in the actual game; request permits testing, not pose propagation or artwork acceptance.')
record['files'].update(current_review=TRIAL+'/review.html', current_report=TRIAL+'/README.md')
record_path.write_text(json.dumps(record, indent=2)+'\n', encoding='utf-8', newline='\n')
status = {'status':'AWAITING_USER_VALIDATION', 'artwork_source':'../2026-10-23-x1-structural-grip-v08',
          'actual_game_copy_run':True, 'gameplay_changed':False, 'primary_game_changed':False,
          'human_visual_approval':False, 'workflow_winner':None, 'generation_calls_this_round':0}
(ROOT/'trial-status.json').write_text(json.dumps(status, indent=2)+'\n', encoding='utf-8')
department = REPO/'docs/departments/combat.md'
text = department.read_text(encoding='utf-8')
entry = ('\n- Original-character animation R&D, v08 game integration: user requested an actual-game test. '
         'A fresh isolated Gym copy changes only X1 art/drawing keys and application identity. '
         'Both current-art/v08 action-level sequences observed X1 contact/orb/Charging/Cast impact/Dodge/reaction interruption. '
         'Actual viewport comparison and a normal-controls playable window are available. Source gameplay/art bindings remain unchanged. '
         'Pre-command input, variable capture intervals and warnings are retained in evidence. '
         'Human visual approval, new spatial contact adaptation and workflow selection remain open. '
         'Source: Research Laema Animation Pipeline/trials/2026-10-23-v08-game-integration/README.md.\n')
marker = '\n## Resume point'
assert marker in text
text = text.replace(marker, entry+marker, 1)
department.write_text(text, encoding='utf-8', newline='\n')
files=[]
for p in sorted(ROOT.rglob('*')):
    if p.is_file() and not set(p.parts)&{'.godot','__pycache__','captures','gameplay-preview'} and p.name!='artifact-manifest.json':
        files.append({'path':p.relative_to(ROOT).as_posix(),'bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(ROOT/'artifact-manifest.json').write_text(json.dumps({'files':files,'exclusions':'Engine cache, source copy and raw capture folders remain locally preserved; copy and frame identities recorded separately.'},indent=2)+'\n', encoding='utf-8')
print('Updated R&D continuation and Combat development record; source game untouched.')
