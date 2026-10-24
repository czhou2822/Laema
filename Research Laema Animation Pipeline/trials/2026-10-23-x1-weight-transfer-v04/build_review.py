"""Reuse the established browser/Godot review with a visible alignment audit option."""
from pathlib import Path
import json,shutil,re
ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-x1-followthrough-v03'
data=json.loads((ROOT/'outputs/clips.json').read_text())
s=(PRIOR/'review.html').read_text(encoding='utf-8')
s=s.replace('Laema — X1 follow-through correction','Laema — X1 weight transfer and braking')
s=s.replace('<h1>X1: correcting the downward sword drop</h1>','<h1>X1: weight transfer, braking and a stronger downward cut</h1>')
s=s.replace('Your feedback: refinement improved the first study but is still below expectation. This revision changes the follow-through and recovery; the earlier anticipation and release are retained.','Your feedback: the sword path is better, but the body feels stiff. The new candidate adds rear-leg loading, a drive onto the front leg and compression as the swing stops. Its downward cut is steeper than the previous version.')
s=s.replace('Left: current game X1 · Middle: previous AI refinement · Right: shallower follow-through revision','Left: current game X1 · Middle: previous shallow-path revision · Right: new weight-transfer candidate')
s=s.replace('Loading the existing game and two AI revisions…','Loading the game, previous revision and new body-motion candidate…')
a=s.index('<details');b=s.index('</main>',a)
s=s[:a]+'''<details open><summary>What to judge</summary><ul><li>Does the rear-leg load lead into the cut, with the body moving onto the front leg?</li><li>As the sword stops, do the knee bend, pelvis compression and elbow brake feel connected, rather than everything freezing together?</li><li>Does the steeper downward blade feel stronger without returning to the old near-vertical drop?</li><li>Fourteen working drawings are new; the original guard is reused at both ends. Same .720/.480s action and frame timing. Gameplay and hit queries are unchanged.</li></ul></details>
<details><summary>Inspect the export corrections</summary><p>The generated sheet needed four row origins and14 explicit front-sole translations (up to23px horizontally and3px vertically). These stabilize the planted front foot; they do not repaint anatomy or establish correct rear-foot contact. Remaining rear-foot/shape changes need visual review. No per-frame rescaling is used.</p>
<label><input type="checkbox" id="unaligned">Show the new candidate before front-foot alignment</label>
<p><a href="outputs/x1-weight-transfer-before-foot-registration.png">Before-alignment atlas</a> · <a href="raw/attempt01.png">Raw AI sheet</a> · <a href="outputs/clips.json">Measured corrections</a></p></details>
<p><a href="../2026-10-23-x1-followthrough-v03/review.html">Previous comparison</a> · <a href="../2026-10-23-ai-refine-v02/review.html">First AI study and Cast</a> · <a href="preview/project.godot">This comparison in Godot</a> · <a href="README.md">Trial record and prompt</a></p>
'''+s[b:]
a=s.index('<script id="review-data" type="application/json">')+len('<script id="review-data" type="application/json">');b=s.index('</script>',a)
s=s[:a]+json.dumps(data,separators=(',',':'))+s[b:]
s=s.replace('const all=data.clips,images=new Map(all.map(c=>','const unaligned={...data.clips[2],id:"weight_v04_unaligned",label:"3 · Before foot alignment",file:"x1-weight-transfer-before-foot-registration.png"};\nconst all=[...data.clips,unaligned],images=new Map(all.map(c=>')
s=s.replace('function selected(){return data.clips;}','function selected(){return [data.clips[0],data.clips[1],$("unaligned").checked?unaligned:data.clips[2]];}')
s=s.replace('const names=data.clips.map(c=>c.label);','const names=clips.map(c=>c.label);')
s=s.replace("$('play').onclick=",'$("unaligned").onchange=()=>{draw();};\n'+"$('play').onclick=")
s=s.replace('Current game, previous refinement and follow-through revision loaded; source timing retained.','Current game, previous shallow path and new weight-transfer candidate loaded; original action timing retained.')
s=s.replace('Current game X1, previous refinement, and corrected follow-through at native size','Current game X1, previous shallow path, and new weight-transfer candidate at native size')
(ROOT/'review.html').write_text(s,encoding='utf-8',newline='\n')

dest=ROOT/'preview';dest.mkdir(exist_ok=True)
shutil.copy2(PRIOR/'preview/main.tscn',dest/'main.tscn')
project=(PRIOR/'preview/project.godot').read_text(encoding='utf-8').replace('Laema X1 follow-through RND v03','Laema X1 weight transfer RND v04')
(dest/'project.godot').write_text(project,encoding='utf-8',newline='\n')
gd=(PRIOR/'preview/main.gd').read_text(encoding='utf-8')
gd=re.sub(r'const LABELS := .*','const LABELS := ["Current game X1", "Previous: shallow path", "Weight transfer + steeper cut"]',gd)
gd=re.sub(r'const FILES := .*','const FILES := ["current-game-x1.png", "x1-followthrough-v03.png", "x1-weight-transfer.png"]',gd)
gd=gd.replace('LAEMA / X1 FOLLOW-THROUGH CORRECTION','LAEMA / WEIGHT TRANSFER + BRAKING')
gd=gd.replace('Current game / previous refinement / shallower follow-through | same0.720s action','Current game / v03 shallow path / v04 weight + steeper cut | same0.720s action')
gd=gd.replace('CORRECTION=%d','WEIGHT_TRANSFER=%d')
gd=gd.replace('Visual correction candidate; v02 gameplay evidence is separate. No v03 integration claim.','14 new drawings + explicit front-foot alignment; standalone review, no v04 integration claim.')
(dest/'main.gd').write_text(gd,encoding='utf-8',newline='\n')
print('Prepared reused browser and native Godot comparison; unaligned export remains inspectable.')
