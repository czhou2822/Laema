"""Execute hidden/off-screen staged GPU captures from the disposable project."""
from pathlib import Path
import datetime, json, os, subprocess, sys, shutil
HERE=Path(__file__).resolve().parent
BASE=HERE.parents[1]
CACHE=Path(os.environ.get('LAEMA_HOMM3_CACHE',str(HERE)))
phase=sys.argv[1] if len(sys.argv)>1 else 'baseline'
out=HERE/('engine-'+phase)
if (out/'capture-report.json').exists():raise RuntimeError('Use a new phase name; do not overwrite an executed capture')
specs=[{'label':'nearest','pattern':str(BASE/'a-restoration/nearest/crop/frame_{frame}.png')},
       {'label':'restoration','pattern':str(BASE/'a-restoration/realesrgan/crop/frame_{frame}.png')}]
if phase.startswith('baseline'):
    for kind,file in [('builtin-raw','normalized_raw_05.png'),('builtin-alpha','source_alpha_05.png'),('builtin-weapon','weapon_fallback_05.png')]:
        specs.append({'label':kind,'pattern':str(HERE/'builtin-scout'/file),'frames':[5]})
else:
    for method in ['reference','masked','masked-full']:
        if (HERE/method/'source-alpha/crop/frame_09.png').exists():specs.append({'label':method,'pattern':str(HERE/method/'source-alpha/crop/frame_{frame}.png')})
    for method in ['reference','reference-2x','restored-unmasked','masked-high','masked-full']:
        if (HERE/method/'source-alpha/crop/frame_09.png').exists():continue
        for frame in [0,5]:
            file=HERE/method/f'source-alpha/crop/unique_{frame:02d}.png'
            if file.exists():specs.append({'label':method+'-scout','pattern':str(file),'frames':[frame]})
out.mkdir(exist_ok=True)
spec=out/'spec.json';spec.write_text(json.dumps(specs,indent=2),encoding='utf-8')
engine=os.environ.get('LAEMA_GODOT_PATH') or shutil.which('godot')
if not engine:raise RuntimeError('Set LAEMA_GODOT_PATH to the installed Godot executable')
cmd=[engine,'--path',str(CACHE/'.runtime/engine-project'),
     '--rendering-method','gl_compatibility','--audio-driver','Dummy','--position','-30000,-30000',
     '--resolution','1280x720','--script',str(HERE/'research_capture.gd'),'--',f'--out={out}',f'--spec={spec}']
(out/'command.json').write_text(json.dumps({'command':cmd,'started_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'purpose':'Staged actual GPU appearance at fixed pose; no production import/playtest','window':'Off-screen no-focus window; console hidden'},indent=2),encoding='utf-8')
with (out/'engine.log').open('w',encoding='utf-8') as log:
    p=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
print(json.dumps({'exit_code':p.returncode,'png_files':len(list(out.rglob('*.png'))),'report_exists':(out/'capture-report.json').exists()}))
