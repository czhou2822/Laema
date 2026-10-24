"""Local review assets plus a small version-bound annotation store. Loopback only."""
from pathlib import Path
from http.server import SimpleHTTPRequestHandler,ThreadingHTTPServer
from urllib.parse import urlparse
import argparse,bisect,datetime,hashlib,json,math,shutil,threading,uuid
ROOT=Path(__file__).resolve().parent
TRIAL=ROOT/'trials/2026-10-24-x1-quality-h01'

class ConflictError(ValueError):pass

class NoteStore:
 def __init__(self,path,config):
  self.path=Path(path);self.experiment_id=config.get('experiment_id','H01');self.versions={v['id']:v for v in config['versions']};self.lock=threading.Lock()
 def _load(self):
  if not self.path.exists():return {'schema_version':1,'experiment_id':self.experiment_id,'revision':0,'notes':[],'history':[]}
  data=json.loads(self.path.read_text(encoding='utf-8'))
  if data.get('experiment_id')!=self.experiment_id or not isinstance(data.get('notes'),list):raise ValueError('Annotation file has an unexpected format; preserving it unchanged.')
  return data
 def read(self):
  with self.lock:return self._load()
 def apply(self,payload):
  with self.lock:
   if not isinstance(payload,dict):raise ValueError('Expected an annotation operation object.')
   data=self._load();operation=payload.get('operation');now=datetime.datetime.now(datetime.timezone.utc).isoformat()
   if operation=='save':
    incoming=payload.get('note',{})
    if not isinstance(incoming,dict):raise ValueError('Expected a note object.')
    vid=incoming.get('version_id');version=self.versions.get(vid)
    if not version or incoming.get('sprite_sha256')!=version['sprite_sha256']:raise ValueError('The sprite version differs. Reload the review before saving.')
    text=incoming.get('text','')
    if not isinstance(text,str) or not text.strip() or len(text)>4000:raise ValueError('Enter a note of1–4000 characters.')
    first=incoming.get('from_frame');last=incoming.get('through_frame',first);count=len(version['times'])
    if type(first)!=int or type(last)!=int or not 1<=first<=last<=count:raise ValueError('Drawing range is outside this version.')
    point=incoming.get('point')
    if point is not None and (not isinstance(point,list) or len(point)!=2 or any(type(p) not in (int,float) or not math.isfinite(p) or not 0<=p<=448 for p in point)):raise ValueError('The marked point is outside the sprite cell.')
    heat=incoming.get('heat',0);facing=incoming.get('facing','right')
    if heat not in [0,100] or facing not in ['left','right']:raise ValueError('Invalid review orientation.')
    comparison=incoming.get('comparison')
    if comparison is not None:
     if not isinstance(comparison,dict):raise ValueError('Invalid overlay comparison.')
     base=self.versions.get(comparison.get('base_version_id'));overlay=self.versions.get(comparison.get('overlay_version_id'))
     if not base or not overlay or base['id']==overlay['id'] or vid not in [base['id'],overlay['id']]:raise ValueError('The annotation must target a version in its overlay comparison.')
     if comparison.get('base_sprite_sha256')!=base['sprite_sha256'] or comparison.get('overlay_sprite_sha256')!=overlay['sprite_sha256']:raise ValueError('Overlay artwork version differs; preserve the draft and reload.')
     opacity=comparison.get('overlay_opacity');moment=comparison.get('action_time_heat0_s')
     if type(opacity) not in (int,float) or not math.isfinite(opacity) or not 0<=opacity<=1 or type(moment) not in (int,float) or not math.isfinite(moment) or not 0<=moment<=version['duration']:raise ValueError('Invalid overlay time or opacity.')
     base_frame=max(1,bisect.bisect_right(base['times'],moment));overlay_frame=max(1,bisect.bisect_right(overlay['times'],moment))
     if (base_frame if vid==base['id'] else overlay_frame)!=first:raise ValueError('Overlay time does not match the annotation drawing.')
     comparison={'base_version_id':base['id'],'base_sprite_sha256':base['sprite_sha256'],'base_frame':base_frame,'overlay_version_id':overlay['id'],'overlay_sprite_sha256':overlay['sprite_sha256'],'overlay_frame':overlay_frame,'overlay_opacity':opacity,'action_time_heat0_s':moment}
    identifier=incoming.get('id');old=next((n for n in data['notes'] if n['id']==identifier),None) if identifier else None
    if identifier and old is None:raise ValueError('The edited note no longer exists.')
    if old and incoming.get('expected_updated_at')!=old['updated_at']:raise ConflictError('This note changed in another view. Reload notes before editing it.')
    if not old and len(data['notes'])>=2000:raise ValueError('Annotation store is full. Export notes before adding more.')
    note={'id':identifier or str(uuid.uuid4()),'version_id':vid,'version_label':version['label'],'sprite_sha256':version['sprite_sha256'],
          'from_frame':first,'through_frame':last,'start_time_heat0_s':version['times'][first-1],
          'end_time_heat0_s':version['times'][last] if last<count else version['duration'],
          'point':point,'heat':heat,'facing':facing,'comparison':comparison,'text':text.strip(),'created_at':old['created_at'] if old else now,'updated_at':now,'deleted':False}
    if old:data['notes'][data['notes'].index(old)]=note
    else:data['notes'].append(note)
   elif operation in ['remove','restore']:
    old=next((n for n in data['notes'] if n['id']==payload.get('id')),None)
    if old is None:raise ValueError('Note not found.')
    note=dict(old,deleted=operation=='remove',updated_at=now);data['notes'][data['notes'].index(old)]=note
   else:raise ValueError('Unsupported annotation operation.')
   data.setdefault('history',[]).append({'at_utc':now,'operation':operation,'note_id':note['id'],'previous':old})
   data['revision']+=1;self.path.parent.mkdir(parents=True,exist_ok=True)
   temporary=self.path.with_name(self.path.name+'.tmp')
   temporary.write_text(json.dumps(data,indent=2)+'\n',encoding='utf-8')
   if self.path.exists():shutil.copy2(self.path,self.path.with_name(self.path.stem+'.backup.json'))
   temporary.replace(self.path)
   return data

def main():
 parser=argparse.ArgumentParser();parser.add_argument('--port',type=int,default=58929);args=parser.parse_args()
 stores={}
 for experiment in ['H01','H02']:
  trial=ROOT/'trials'/f'2026-10-24-x1-quality-{experiment.lower()}'
  config_path=trial/'outputs/character-data.json'
  if not config_path.exists():continue
  config=json.loads(config_path.read_text(encoding='utf-8'));store=NoteStore(trial/'annotations.json',config)
  if not store.path.exists():store.path.write_text(json.dumps(store.read(),indent=2)+'\n',encoding='utf-8',newline='\n')
  stores[f'/api/review-notes/{experiment}']=store
 class Handler(SimpleHTTPRequestHandler):
  def __init__(self,*a,**kw):super().__init__(*a,directory=str(ROOT),**kw)
  def _json(self,status,data):
   encoded=json.dumps(data).encode();self.send_response(status);self.send_header('Content-Type','application/json; charset=utf-8');self.send_header('Cache-Control','no-store');self.send_header('Content-Length',str(len(encoded)));self.end_headers();self.wfile.write(encoded)
  def do_GET(self):
   endpoint=urlparse(self.path).path
   if endpoint in stores:
    try:self._json(200,stores[endpoint].read())
    except (ValueError,OSError) as e:self._json(500,{'error':str(e)})
   else:super().do_GET()
  def do_POST(self):
   endpoint=urlparse(self.path).path
   if endpoint not in stores:self._json(404,{'error':'Unknown endpoint'});return
   if self.headers.get('Origin') not in [None,f'http://127.0.0.1:{args.port}',f'http://localhost:{args.port}']:self._json(403,{'error':'Local review origin required'});return
   try:
    length=int(self.headers.get('Content-Length','0'))
    if not 0<length<=32768:raise ValueError('Annotation request is too large or empty.')
    payload=json.loads(self.rfile.read(length));self._json(200,stores[endpoint].apply(payload))
   except ConflictError as e:self._json(409,{'error':str(e)})
   except (ValueError,TypeError,KeyError) as e:self._json(400,{'error':str(e)})
   except OSError as e:self._json(500,{'error':f'Could not save annotations: {e}'})
  def end_headers(self):
   if urlparse(self.path).path.endswith(('.html','.js','character-data.json')):self.send_header('Cache-Control','no-cache')
   super().end_headers()
 server=ThreadingHTTPServer(('127.0.0.1',args.port),Handler)
 print(f'Laema review ready on http://127.0.0.1:{args.port}; annotation stores: {len(stores)}',flush=True)
 try:server.serve_forever()
 except KeyboardInterrupt:pass
 finally:server.server_close()
if __name__=='__main__':main()
