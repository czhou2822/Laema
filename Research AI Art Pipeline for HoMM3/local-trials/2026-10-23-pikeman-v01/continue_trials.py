"""Execute the remaining bounded size/strength/mask tests, then finish six unique poses."""
from pathlib import Path
import datetime,json,time
from run_local import run,HERE
plan=[('reference-2x',[0]),('restored-unmasked',[5]),('masked-high',[5]),('masked',[1,2,3,4])]
(HERE/'remaining-execution-plan.json').write_text(json.dumps({'created_utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'scope':'CPKMAN group12/block11 only','plan':[{'method':m,'unique_frames':f} for m,f in plan],'constraint':'No acceptance or production change implied; per-frame raw execution records determine actual status.'},indent=2),encoding='utf-8')
predecessor=HERE/'masked/raw/unique_05.json'
deadline=time.monotonic()+300
while not predecessor.exists():
    if time.monotonic()>deadline:raise RuntimeError('Earlier masked scout did not complete; inspect it before proceeding')
    time.sleep(2)
if json.loads(predecessor.read_text())['status']!='executed':raise RuntimeError('Earlier scout failed; inspect before proceeding')
for method,frames in plan:
    run(method,frames)
print('BOUNDED_TRIALS_COMPLETE',flush=True)
