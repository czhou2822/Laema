"""Present a visibly structural still-pose test, not a cosmetic strip revision."""
from pathlib import Path
import json,re,shutil
ROOT=Path(__file__).parent
V06=ROOT.parent/'2026-10-23-x1-grip-v06'
data=json.loads((ROOT/'outputs/clips.json').read_text())
s=(V06/'review.html').read_text(encoding='utf-8')
s=s.replace('Laema — one-pose wrist and grip proof','Laema — structural wrist pose comparison')
s=s.replace('<h1>X1: wrist-to-hilt proof / one pose only</h1>','<h1>X1: structural wrist/arm pose — still proof</h1>')
a=s.index('<p>',s.index('<h1>'));b=s.index('<p id="legend">',a)
s=s[:a]+'''<p>v06 changed grip detail while leaving the wrist pose unchanged. You reported no visible difference. v08 allows the arm and hand silhouette to change: the elbow is higher and the forearm slopes down into the grip. This is ONE re-rendered pose, not a corrected animation.</p>
<div style="display:flex;flex-wrap:wrap;gap:18px"><figure style="margin:0"><figcaption>v05 · original arm/wrist · 4× native pixels</figcaption><img src="outputs/v05-arm-grip-4x.png" width="384" height="288" alt="v05 arm and wrist before structural correction" style="image-rendering:pixelated"></figure><figure style="margin:0"><figcaption id="proposal-caption">v08 · changed arm/wrist pose · 4× native pixels</figcaption><img id="proposal-zoom" src="outputs/v08-arm-grip-4x.png" width="384" height="288" alt="One structural arm/grip proposal; wrist silhouette is allowed to change" style="image-rendering:pixelated"></figure></div>
<p class="limits">Same native-pixel enlargement. The full-pose re-render also changes some body/equipment details; these are open defects, not accepted changes. <a href="inputs/original-grip-construction.png">Original wrist/palm/hilt guide</a>.</p>
<h2>Frozen key7 comparison / optional motion context</h2>
'''+s[b:]
s=s.replace('Left: current game / preferred · Middle: v05 / wrist rejected · Right: v06 / one-key proof','Left: current game / preferred · Middle: v05 source · Right: v08 structural pose')
s=s.replace('v06 proof','v08 proof').replace('Jump to v06 proof drawing','Jump to v08 proof drawing')
s=s.replace('Key #7 · inspect the grip proof','Key #7 · freeze structural proof')
s=s.replace('<button id="pin-grip">Key #7 · freeze structural proof</button>','<button id="pin-grip">Key #7 · freeze structural proof</button><button id="blink" aria-pressed="false">Blink v05 ↔ v08 / inspection only</button>')
a=s.index('<details');b=s.index('</main>',a)
s=s[:a]+'''<details open><summary>What changed and what is still open</summary><p>v06 held the old alpha/silhouette and only changed757 RGB pixels. v08 does not clamp to that alpha: the registered pose changes486 arm-region silhouette pixels. These counts establish a visible structural change, not anatomical correctness. The model did not reproduce every guide point exactly. Fifteen other keys are untouched. Full motion, grip quality, character/equipment consistency and contact correspondence remain unapproved.</p><p>The blink holds key7 and alternates reference/proposal every650ms for inspection. It is not gameplay timing. Optional playback changes only that one key and must not be read as a solved motion trial.</p></details>
<details><summary>Provenance and reference limits</summary><p>One original R&amp;D sprite and one original code-authored elbow/wrist/palm/hilt guide were supplied to image generation. Static instruction text was consulted for general grip construction; no external photo or motion sequence was used as input or traced. This is an original2D construction test;3D has not been tested.</p><p><a href="outputs/registration.json">Normalization and silhouette changes</a> · <a href="raw/attempt01.png">Raw generated pose</a> · <a href="prompts/attempt01.txt">Exact prompt</a></p></details>
<p><a href="../2026-10-23-x1-grip-v06/review.html">v06 cosmetic proof / preserved</a> · <a href="../2026-10-23-x1-opening-v05/review.html">Source v05 motion</a> · <a href="preview/project.godot">One-pose proof in Godot</a> · <a href="README.md">Trial record</a></p>
'''+s[b:]
a=s.index('<script id="review-data" type="application/json">')+len('<script id="review-data" type="application/json">');b=s.index('</script>',a)
s=s[:a]+json.dumps(data,separators=(',',':'))+s[b:]
s=s.replace('Loaded: current game / unchanged v05 / one-key RGB grip proof. No gameplay or clock changes.','Loaded: preferred game / v05 source / one structural pose. Source game and clocks unchanged.')
s=s.replace('Current game, original v05 and one-key wrist repair proof at native size','Current game, original v05 and one structural wrist pose at native size')
(ROOT/'review.html').write_text(s,encoding='utf-8',newline='\n')
dest=ROOT/'preview';dest.mkdir(exist_ok=True);shutil.copy2(V06/'preview/main.tscn',dest/'main.tscn')
p=(V06/'preview/project.godot').read_text(encoding='utf-8').replace('Laema one-key grip proof RND v06','Laema structural grip pose RND v08')
(dest/'project.godot').write_text(p,encoding='utf-8',newline='\n')
gd=(V06/'preview/main.gd').read_text(encoding='utf-8')
gd=re.sub(r'const LABELS := .*','const LABELS := ["Current game / user preferred", "v05 / original wrist pose", "v08 / ONE structural pose"]',gd)
gd=re.sub(r'const FILES := .*','const FILES := ["current-game-x1.png", "x1-opening-v05.png", "x1-one-pose-structural-v08.png"]',gd)
gd=gd.replace('LAEMA / ONE-KEY WRIST + GRIP PROOF','LAEMA / STRUCTURAL WRIST POSE PROOF')
gd=gd.replace('Only key7 locally repaired; source blade angle and other keys unchanged | .720s action','Only key7 re-rendered; new arm silhouette + open detail drift | .720s source action')
gd=gd.replace('GRIP_PROOF_V06=%d','STRUCTURAL_V08=%d')
gd=gd.replace('One local RGB grip test only. No whole-strip correction, visual acceptance or integrated combat claim.','One structural still-pose proof only; no whole-motion, anatomical, art or combat acceptance.')
(dest/'main.gd').write_text(gd,encoding='utf-8',newline='\n')
print('Prepared source/proposal still comparison, native-pixel zoom and inspection-only blink.')
