"""Keep the established review UI; add exact drawing keys and version labels."""
from pathlib import Path
import json,shutil,re
ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-x1-weight-transfer-v04'
data=json.loads((ROOT/'outputs/clips.json').read_text())
s=(PRIOR/'review.html').read_text(encoding='utf-8')
s=s.replace('Laema — X1 weight transfer and braking','Laema — X1 opening pose review')
s=s.replace('<h1>X1: weight transfer, braking and a stronger downward cut</h1>','<h1>X1: focused opening correction</h1>')
s=s.replace('Your feedback: the sword path is better, but the body feels stiff. The new candidate adds rear-leg loading, a drive onto the front leg and compression as the swing stops. Its downward cut is steeper than the previous version.','Current game is still your preference. v04 drawings2–7 are awkward; v03 drawing2 is relatively better, while drawing3 has the wrong arm/sword position. This trial keeps drawing2 exactly and tests a compact chamber hold followed by three new release drawings.')
s=s.replace('Left: current game X1 · Middle: previous shallow-path revision · Right: new weight-transfer candidate','Left: current game / preferred · Middle: v03 / opening references · Right: v05 / focused correction')
s=s.replace('Loading the game, previous revision and new body-motion candidate…','Loading current game, v03 references and v05 correction…')
s=s.replace('← Frame','← 1/60s').replace('Frame →','1/60s →')
s=s.replace('aria-label="Previous frame"','aria-label="Step back 1/60 second"').replace('aria-label="Next frame"','aria-label="Step forward 1/60 second"')
start=s.index('<div class="time">')
controls='''<div class="controls" style="margin-top:10px"><label>Game drawing <select id="pose-game" aria-label="Jump to current game drawing"></select></label><label>v03 drawing <select id="pose-v03" aria-label="Jump to v03 drawing"></select></label><label>v05 drawing <select id="pose-v05" aria-label="Jump to v05 drawing"></select></label></div>
<p class="limits">Drawing jumps use saved pose-key times (shown at Heat0). The1/60s buttons step time, which may keep the same held drawing.</p>
<div class="controls"><button id="pin-v03-2">v03 #2 · better</button><button id="pin-v03-3">v03 #3 · arm/sword rejected</button><button id="pin-v05-5">v05 #5 · new release</button></div><p id="pose-jump-status" role="status">Loading drawing keys…</p>
'''
s=s[:start]+controls+s[start:]
a=s.index('<details');b=s.index('</main>',a)
s=s[:a]+'''<details open><summary>Scope of this trial</summary><p>v05 keys2–4 reuse your relatively preferred v03 drawing2 exactly, holding that chamber from .050 to .126s. Keys5–7 use three new release drawings. Keys1 and8–16 retain v04 artwork for context; they remain unapproved. No trial is recorded as better than the current game.</p></details>
<details><summary>Inspect the export corrections</summary><p>The new release cells use one shared scale, two row origins and three recorded front-sole translations. A failed calibration export is preserved. No per-frame scaling or anatomy warping is used.</p><label><input type="checkbox" id="unaligned">Show v05 before front-foot alignment</label>
<p><a href="outputs/x1-opening-before-foot-registration.png">Before-alignment atlas</a> · <a href="raw/attempt01.png">Raw AI sheet</a> · <a href="outputs/clips.json">Export measurements</a></p></details>
<details><summary>Exact feedback poses</summary><div class="viewport"><img src="inputs/opening-feedback-board.png" alt="v03 drawings2 and3 plus rejected v04 drawings2–7; exact saved poses, no new artwork" style="display:block;width:1344px;height:704px"></div></details>
<p><a href="../2026-10-23-x1-weight-transfer-v04/review.html">v04 rejected opening</a> · <a href="../2026-10-23-x1-followthrough-v03/review.html">v03 comparison</a> · <a href="preview/project.godot">Native Godot comparison</a> · <a href="README.md">Trial record and prompt</a></p>
'''+s[b:]
a=s.index('<script id="review-data" type="application/json">')+len('<script id="review-data" type="application/json">');b=s.index('</script>',a)
s=s[:a]+json.dumps(data,separators=(',',':'))+s[b:]
s=s.replace('weight_v04_unaligned','opening_v05_unaligned').replace('x1-weight-transfer-before-foot-registration.png','x1-opening-before-foot-registration.png')
s=s.replace('Current game, previous shallow path and new weight-transfer candidate loaded; original action timing retained.','Current game, v03 references and v05 trial loaded; no gameplay or timing changes.')
s=s.replace('Current game X1, previous shallow path, and new weight-transfer candidate at native size','Current game preferred baseline, v03 reference and v05 opening trial at native size')
s=s.replace('</script></html>','</script><script src="pose-review.js"></script></html>')
(ROOT/'review.html').write_text(s,encoding='utf-8',newline='\n')
dest=ROOT/'preview';dest.mkdir(exist_ok=True);shutil.copy2(PRIOR/'preview/main.tscn',dest/'main.tscn')
project=(PRIOR/'preview/project.godot').read_text(encoding='utf-8').replace('Laema X1 weight transfer RND v04','Laema X1 opening RND v05')
(dest/'project.godot').write_text(project,encoding='utf-8',newline='\n')
gd=(PRIOR/'preview/main.gd').read_text(encoding='utf-8')
gd=re.sub(r'const LABELS := .*','const LABELS := ["Current game / user preferred", "v03 / opening references", "v05 / focused opening correction"]',gd)
gd=re.sub(r'const FILES := .*','const FILES := ["current-game-x1.png", "x1-followthrough-v03.png", "x1-opening-v05.png"]',gd)
gd=gd.replace('LAEMA / WEIGHT TRANSFER + BRAKING','LAEMA / OPENING CORRECTION')
gd=gd.replace('Current game / v03 shallow path / v04 weight + steeper cut | same0.720s action','Current game preferred | v03 reference | v05 trial | same0.720s action')
gd=gd.replace('WEIGHT_TRANSFER=%d','OPENING_V05=%d')
gd=gd.replace('14 new drawings + explicit front-foot alignment; standalone review, no v04 integration claim.','Preferred v03 #2 held at keys2-4;3 new release drawings; later v04 poses remain unapproved.')
(dest/'main.gd').write_text(gd,encoding='utf-8',newline='\n')
print('Prepared version-labeled comparison with exact drawing jumps and preserved user feedback.')
