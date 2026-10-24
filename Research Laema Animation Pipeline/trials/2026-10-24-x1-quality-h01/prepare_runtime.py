"""Reuse the preserved game fixture in a new bounded copy; never patch main or v08."""
from pathlib import Path
import json,hashlib,re,shutil,sys
ROOT=Path(__file__).resolve().parent
PREVIOUS=ROOT.parent/'2026-10-23-v08-game-integration'
SOURCE=PREVIOUS/'gameplay-preview'
GAME=ROOT/'gameplay-preview'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
resource='config/attack_animations/fire_x1.tres'

def prepare():
 assert not GAME.exists(),'Preserve existing experiment copies.'
 shutil.copytree(SOURCE,GAME,ignore=shutil.ignore_patterns('.godot','__pycache__','~*'))
 records=[]
 for name in ['scripts','scenes','config','assets','ai','addons']:
  for path in sorted((SOURCE/name).rglob('*')):
   if path.is_file() and not path.name.startswith('~'):
    rel=path.relative_to(SOURCE).as_posix();assert sha(path)==sha(GAME/rel)
    records.append({'path':rel,'sha256':sha(path)})
 (ROOT/'evidence/frozen-fixture.json').write_text(json.dumps({'source_fixture':'../2026-10-23-v08-game-integration/gameplay-preview',
  'fixture_source_revision':'d97c728021ec0cbc3a5e3a6483620150d7ab18a6','current_main_revision':'574270f66bcbeed72db07778ef612ee37ea8d932',
  'boundary':'Older preserved Gym fixture, used identically for A/B. Does not test later main feedback/roster changes.',
  'files':records},indent=2)+'\n',encoding='utf-8')
 project=GAME/'project.godot';text=project.read_text(encoding='utf-8');text=re.sub(r'config/name="[^"]+"','config/name="Laema H01 X1 quality experiment"',text,count=1);project.write_text(text,encoding='utf-8',newline='\n')
 source_resource=(GAME/resource).read_text(encoding='utf-8')
 (ROOT/'inputs/baseline-fire_x1.tres').write_text(source_resource,encoding='utf-8',newline='\n')
 old_events=(PREVIOUS/'evidence/v08-motion-run/events.jsonl').read_text().splitlines()
 command=next(json.loads(s)['requested'] for s in old_events if json.loads(s)['kind']=='command_accepted' and json.loads(s)['id']==1)
 for name in ['baseline-run','candidate-run']:
  folder=ROOT/'evidence'/name;folder.mkdir()
  (folder/'command.json').write_text(json.dumps(command,indent=2)+'\n',encoding='utf-8')
 # Observer-only fixture: initialize paused until hardware bindings are excluded,
 # then run the original wall-time schedule and quit after its completion.
 wrapper='''extends "res://tools/tests/rnd_gameplay_capture.gd"
const RND_DEVICE := 7
var _rnd_routed := false
var _h01_started := false

func _initialize() -> void:
\troot.set_flag(Window.FLAG_NO_FOCUS, true)
\tpaused = true
\tsuper._initialize()

func _tick() -> void:
\tif not _rnd_routed and InputMap.has_action(&"casting") and not InputMap.action_get_events(&"casting").is_empty():
\t\tfor action in InputMap.get_actions():
\t\t\tInputMap.action_erase_events(action)
\t\t\tInput.action_release(action)
\t\t_rnd_routed = true
\t\t_metadata["input_routing_fixture"] = "H01 initialized paused until synthetic device7 routing was installed; original scheduled action events then run at normal clock. Normal gameplay code/settings unchanged. Not physical-controller validation."
\t\tpaused = false
\t\t_record("rnd_device_routing", {"device":7,"startup_pause_released":true,"gameplay_rules_changed":false})
\tsuper._tick()
\tif not _command.is_empty():
\t\t_h01_started = true
\telif _h01_started and not _stopping:
\t\t_stop(0)

func _binding(action: StringName, analog: bool) -> InputEvent:
\tvar event := InputEventAction.new()
\tevent.action = action
\tevent.device = RND_DEVICE
\treturn event

func _send_control(scheduled: Dictionary, late_ms := 0) -> void:
\tvar action: StringName = scheduled["action"]
\tvar pressed: bool = scheduled["pressed"]
\tvar value := float(scheduled["value"])
\tvar event := InputEventAction.new()
\tevent.action = action
\tevent.device = RND_DEVICE
\tevent.pressed = pressed
\tevent.strength = value if pressed else 0.0
\tevent.set_meta(INPUT_TAG, _session)
\t_held[action] = {"pressed":pressed,"value":value,"binding":event}
\t_record("scheduled_input", {"action":action,"pressed":pressed,"value":value,"at_ms":scheduled.get("at_ms",-1),"lateness_ms":late_ms,"event":event.as_text()})
\tInput.parse_input_event(event)
'''
 (GAME/'tools/tests/rnd_h01_input.gd').write_text(wrapper,encoding='utf-8',newline='\n')
 print('Prepared a fresh copy of the frozen game fixture and paired input schedule.')

def install():
 original=(ROOT/'inputs/baseline-fire_x1.tres').read_text()
 assert (GAME/resource).read_text()==original
 rel='assets/prototype/player/fire_sword_shield_v01/rnd_h01/x1-h01-grip-continuity.png'
 dest=GAME/rel;dest.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(ROOT/'outputs/x1-h01-grip-continuity.png',dest)
 old='res://assets/prototype/player/fire_sword_shield_v01/rnd_v08/x1-one-pose-structural-v08.png'
 assert original.count(old)==1
 updated=original.replace(old,'res://'+rel)
 assert updated.replace('res://'+rel,old)==original
 (GAME/resource).write_text(updated,encoding='utf-8',newline='\n')
 print('Candidate installed in H01 copy: texture path only. Every drawing key/clock/geometry track remains exact.')

def verify():
 m=json.loads((ROOT/'evidence/frozen-fixture.json').read_text());changed=[];missing=[]
 for f in m['files']:
  assert sha(SOURCE/f['path'])==f['sha256'],f"Historical fixture changed: {f['path']}"
  dest=GAME/f['path']
  if not dest.exists():missing.append(f['path'])
  elif sha(dest)!=f['sha256']:changed.append(f['path'])
 assert not missing,missing
 assert changed==[resource],changed
 result={'compared_source_files':len(m['files']),'changed_existing_resource':[resource],
 'only_change':'X1 Texture2D path; every saved drawing time/rectangle and every other native track exact',
 'gameplay_code_settings_geometry_and_other_actions_exact':True,'historical_fixture_unchanged':True,
 'added_files':'One candidate texture, observer/input driver and generated import metadata',
 'application_metadata':'Unique user-data profile name only'}
 (ROOT/'evidence/runtime-preservation.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
 print(json.dumps(result))

if __name__=='__main__':{'prepare':prepare,'install':install,'verify':verify}[sys.argv[1]]()
