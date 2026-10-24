import time,json
from run_local import run,HERE
deadline=time.monotonic()+900
while not (HERE/'masked/raw/unique_04.json').exists():
    if time.monotonic()>deadline:raise RuntimeError('Preceding sequence incomplete')
    time.sleep(2)
assert all(json.loads((HERE/f'masked/raw/unique_{i:02d}.json').read_text())['status']=='executed' for i in range(6))
run('masked-full',[5])
print('FINAL_SCOUT_COMPLETE',flush=True)
