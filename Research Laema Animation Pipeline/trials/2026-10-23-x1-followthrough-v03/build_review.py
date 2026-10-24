"""Adapt the existing browser and Godot comparison without touching product files."""
from pathlib import Path
import json,shutil,re
ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-ai-refine-v02'
data=json.loads((ROOT/'outputs/clips.json').read_text())
s=(PRIOR/'review.template.html').read_text(encoding='utf-8')
s=s.replace('Laema — current game versus AI animation studies','Laema — X1 follow-through correction')
s=s.replace('<h1>Current game versus AI studies</h1>','<h1>X1: correcting the downward sword drop</h1>')
s=s.replace('The previous screen showed three R&amp;D outputs. It did not include the existing game animation. The current game is now the left column.','Your feedback: refinement improved the first study but is still below expectation. This revision changes the follow-through and recovery; the earlier anticipation and release are retained.')
a=s.index('<div class="actions"');b=s.index('<div class="controls"',a)
s=s[:a]+'<p id="legend">Left: current game X1 · Middle: previous AI refinement · Right: shallower follow-through revision</p>\n'+s[b:]
s=s.replace('Loading existing-game and trial sprite atlases…','Loading the existing game and two AI revisions…')
s=s.replace('Cast: 1.200s / .800s. ','')
a=s.index('<details>');b=s.index('</main>',a)
s=s[:a]+'''<details open><summary>What changed</summary><ul><li>Seven drawings from .210–.620s replace the steep downward follow-through with a shallow diagonal, elbow brake and return toward guard. Nine existing cells, including anticipation/release and the final guard, are retained exactly.</li><li>The original pose plan reached an85° downward blade around .340s. Revised pose targets peak at30°. The rendered drawings are a new review candidate; target coordinates are not proof of exact artwork correspondence.</li><li>Same .720/.480s action duration, active window, frame times, foot registration and character reference. No game animation, collision path, lunge or other gameplay setting has changed.</li><li>New drawings can still show face, body and material changes. Judge the correction at normal speed and both facings; this is not production approval.</li></ul></details>
<p><a href="../2026-10-23-ai-refine-v02/review.html">Previous review, first study and Cast comparison</a> · <a href="preview/project.godot">This comparison in Godot</a> · <a href="README.md">Correction record</a> · <a href="outputs/clips.json">Export measurements</a></p>
'''+s[b:]
s=s.replace('const all=[...data.game,...data.trial]','const all=data.clips')
s=s.replace("function selected(){return action==='x1'?[data.game[0],data.trial[0],data.trial[1]]:[data.game[1],data.trial[2]];}",'function selected(){return data.clips;}')
s=s.replace("function duration(){return action==='x1'?.72:1.2;}",'function duration(){return .72;}')
s=s.replace("const names=action==='x1'?['1 · Current game X1','2 · First AI X1 study','3 · Refined AI X1 study']:['1 · Current game Cast','2 · New AI Cast study'];",'const names=data.clips.map(c=>c.label);')
a=s.index('function choose(value)');b=s.index("$('play').onclick",a)
s=s[:a]+s[b:]
s=s.replace('Current-game X1 and Cast loaded unchanged, alongside the three R&D clips.','Current game, previous refinement and follow-through revision loaded; source timing retained.')
s=s.replace('Current game X1, first AI X1 study, and refined AI X1 study at native size','Current game X1, previous refinement, and corrected follow-through at native size')
s=s.replace('__REVIEW_DATA__',json.dumps(data,separators=(',',':')))
(ROOT/'review.html').write_text(s,encoding='utf-8',newline='\n')

dest=ROOT/'preview';dest.mkdir(exist_ok=True)
shutil.copy2(PRIOR/'preview/main.tscn',dest/'main.tscn')
project=(PRIOR/'preview/project.godot').read_text(encoding='utf-8')
project=re.sub(r'config/name="[^"]+"','config/name="Laema X1 follow-through RND v03"',project)
(dest/'project.godot').write_text(project,encoding='utf-8',newline='\n')
gd=(PRIOR/'preview/main.gd').read_text(encoding='utf-8')
gd=re.sub(r'const LABELS := .*','const LABELS := ["Current game X1", "Previous AI refinement", "Shallower follow-through"]',gd)
gd=re.sub(r'const FILES := .*','const FILES := ["current-game-x1.png", "x1-refined-v02.png", "x1-followthrough.png"]',gd)
gd=gd.replace('const DURATIONS := [0.72,0.72,1.2]','const DURATIONS := [0.72,0.72,0.72]').replace('const COLUMNS := [5,8,4]','const COLUMNS := [8,8,8]')
gd=gd.replace('LAEMA / AI REFINEMENT + SECOND ACTION','LAEMA / X1 FOLLOW-THROUGH CORRECTION')
gd=gd.replace('X1 before/refined:0.720s | original Cast trial:1.200s | shared reference and export workflow','Current game / previous refinement / shallower follow-through | same0.720s action')
gd=gd.replace('AI_BEFORE=%d AI_REFINED=%d CAST=%d','GAME_X1=%d PREVIOUS=%d CORRECTION=%d')
gd=gd.replace('if t > 1.62:','if t > 1.14:').replace(',1.86)-0.24',',1.38)-0.24')
gd=gd.replace('1.2','0.72')
gd=gd.replace('Gold=X1 active time. Cast launch=.288s at Heat0. Review holds are outside each action.','Gold=X1 active time only. No contact curves changed. Review holds outside the action.')
gd=gd.replace('Trial artwork: compare continuity/grip/scale; actual game-copy tests are recorded separately.','Visual correction candidate; v02 gameplay evidence is separate. No v03 integration claim.')
(dest/'main.gd').write_text(gd,encoding='utf-8',newline='\n')
print('Reused browser/native Godot renderers for current game, previous refinement and motion correction.')
