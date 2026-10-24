"""Meaningful persistence/version/range checks in an isolated test file, not user notes."""
from pathlib import Path
import importlib.util,json,uuid
ROOT=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('review_server',ROOT.parents[1]/'review_server.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
config=json.loads((ROOT/'outputs/character-data.json').read_text())
path=ROOT/'evidence'/f'annotation-test-{uuid.uuid4().hex[:8]}.json';store=module.NoteStore(path,config)
version=next(v for v in config['versions'] if v['id']=='h01');checks=[]
def save(**kw):
 note={'version_id':'h01','sprite_sha256':version['sprite_sha256'],'from_frame':7,'through_frame':7,'point':[254,275],'heat':0,'facing':'right','text':'TOOL VALIDATION ONLY — not artistic feedback'};note.update(kw);return store.apply({'operation':'save','note':note})
a=save();note=a['notes'][0];assert note['start_time_heat0_s']==.158 and note['end_time_heat0_s']==.184;checks.append('Frame7 binds to the current H01 sprite digest and exact exposure interval')
reloaded=module.NoteStore(path,config).read();assert reloaded['notes'][0]==note;checks.append('Annotation round-trip survives a new store instance')
b=save(id=note['id'],expected_updated_at=note['updated_at'],text='TOOL VALIDATION ONLY — edited');edited=b['notes'][0];assert edited['created_at']==note['created_at'] and b['history'][-1]['previous']['text']==note['text'];checks.append('Editing preserves identity and prior text')
old_bytes=path.read_bytes()
try:save(id=note['id'],expected_updated_at=note['updated_at'],text='stale overwrite');raise AssertionError('Stale overwrite accepted')
except module.ConflictError:pass
assert path.read_bytes()==old_bytes;checks.append('Concurrent stale edits are rejected without modifying the file')
for payload in [dict(sprite_sha256='0'*64),dict(from_frame=17),dict(from_frame=7,through_frame=5),dict(point=[999,1])]:
 old_bytes=path.read_bytes()
 try:save(**payload);raise AssertionError('Invalid note accepted')
 except ValueError:pass
 assert path.read_bytes()==old_bytes
checks.append('Wrong sprite versions, invalid ranges and out-of-cell pins cannot corrupt notes')
range_data=save(from_frame=5,through_frame=7);assert range_data['notes'][-1]['start_time_heat0_s']==.126 and range_data['notes'][-1]['end_time_heat0_s']==.184;checks.append('Frame-range5–7 uses source times rather than captured-game frame numbers')
removed=store.apply({'operation':'remove','id':note['id']});assert removed['notes'][0]['deleted']
restored=store.apply({'operation':'restore','id':note['id']});assert not restored['notes'][0]['deleted'] and restored['notes'][0]['text']==edited['text'];checks.append('Removal is reversible and preserves the edited observation')
assert path.with_name(path.stem+'.backup.json').is_file();checks.append('Previous committed JSON state is backed up')
(ROOT/'evidence/annotation-store-verification.json').write_text(json.dumps({'passed':checks,'test_file':path.name,'live_user_annotations_modified':False},indent=2)+'\n',encoding='utf-8')
print(json.dumps({'checks_passed':len(checks),'live_user_annotations_modified':False}))
