"""Version-bound H02/overlay annotation checks using an isolated test store."""
from pathlib import Path
import importlib.util,json,hashlib,uuid
ROOT=Path(__file__).resolve().parent;OLD=ROOT.parent/'2026-10-24-x1-quality-h01'
before=hashlib.sha256((OLD/'annotations.json').read_bytes()).hexdigest()
spec=importlib.util.spec_from_file_location('review_server',ROOT.parents[1]/'review_server.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
config=json.loads((ROOT/'outputs/character-data.json').read_text());versions={v['id']:v for v in config['versions']}
path=ROOT/'evidence'/f'overlay-note-test-{uuid.uuid4().hex[:8]}.json';store=module.NoteStore(path,config)
comparison={'base_version_id':'game','base_sprite_sha256':versions['game']['sprite_sha256'],'overlay_version_id':'h02','overlay_sprite_sha256':versions['h02']['sprite_sha256'],'overlay_opacity':.5,'action_time_heat0_s':.075}
note={'version_id':'h02','sprite_sha256':versions['h02']['sprite_sha256'],'from_frame':3,'through_frame':3,'point':[210,318],'heat':0,'facing':'right','comparison':comparison,'text':'TOOL VALIDATION ONLY — isolated overlay metadata test'}
saved=store.apply({'operation':'save','note':note});n=saved['notes'][0]
assert saved['experiment_id']=='H02' and n['comparison']['base_frame']==2 and n['comparison']['overlay_frame']==3
assert n['comparison']['overlay_opacity']==.5
assert module.NoteStore(path,config).read()['notes'][0]==n
bytes_before=path.read_bytes()
bad=dict(note,comparison=dict(comparison,overlay_sprite_sha256='0'*64))
try:store.apply({'operation':'save','note':bad});raise AssertionError('Wrong overlay version accepted')
except ValueError:pass
assert path.read_bytes()==bytes_before
bad=dict(note,from_frame=4)
try:store.apply({'operation':'save','note':bad});raise AssertionError('Wrong overlay frame accepted')
except ValueError:pass
assert path.read_bytes()==bytes_before
assert hashlib.sha256((OLD/'annotations.json').read_bytes()).hexdigest()==before
result={'checks':['H02 store is separate from H01','Source/overlay hashes are retained','Game2 and H02 frame3 at.075s are recorded correctly','Opacity and point persist across reload','Wrong version/time association cannot modify the file','Existing user H01 annotations are untouched'],'user_notes_modified':False,'test_file':path.name}
(ROOT/'evidence/annotation-verification.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({'checks_passed':len(result['checks']),'user_notes_modified':False}))
