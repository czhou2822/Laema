"""Keep the same review tool; clearly separate one-grip proof from motion context."""
from pathlib import Path
import json,re,shutil
ROOT=Path(__file__).parent
PRIOR=ROOT.parent/'2026-10-23-x1-opening-v05'
data=json.loads((ROOT/'outputs/clips.json').read_text())
s=(PRIOR/'review.html').read_text(encoding='utf-8')
s=s.replace('Laema — X1 opening pose review','Laema — one-pose wrist and grip proof')
s=s.replace('<h1>X1: focused opening correction</h1>','<h1>X1: wrist-to-hilt proof / one pose only</h1>')
a=s.index('<p>',s.index('<h1>'));b=s.index('<p id="legend">',a)
s=s[:a]+'''<p>v05's sword angle changed, but its wrist-to-sword relationship is still rejected. This proof changes one local wrist/fist/hilt drawing while holding the blade angle and body fixed. It has not been propagated through the strip.</p>
<div style="display:flex;flex-wrap:wrap;gap:18px"><figure style="margin:0"><figcaption>v05 key7 · source grip · 4× native pixels</figcaption><img src="outputs/grip-before-4x.png" width="512" height="384" alt="Original v05 key7 wrist and hilt, source pixels enlarged four times" style="max-width:100%;height:auto;image-rendering:pixelated"></figure><figure style="margin:0"><figcaption>v06 key7 · local AI repair proof · 4× native pixels</figcaption><img src="outputs/grip-after-4x.png" width="512" height="384" alt="One-key wrist/fist repair proof, downsampled to sprite resolution then enlarged four times" style="max-width:100%;height:auto;image-rendering:pixelated"></figure></div>
<p class="limits">These views use the actual exported sprite pixels. <a href="outputs/grip-generated-detail.png">Generated high-resolution detail</a> is separate. The proof changes757 RGB pixels; source alpha, the protected blade/guard and all other keys are preserved.</p>
<h2>Motion context — only key7 differs</h2>
'''+s[b:]
s=s.replace('Left: current game / preferred · Middle: v03 / opening references · Right: v05 / focused correction','Left: current game / preferred · Middle: v05 / wrist rejected · Right: v06 / one-key proof')
s=s.replace('Loading current game, v03 references and v05 correction…','Loading the preferred game baseline, unchanged v05 and one-key grip proof…')
s=s.replace('>v03 drawing <','>v05 source <').replace('>v05 drawing <','>v06 proof <')
s=s.replace('id="pose-v03"','id="pose-source"').replace('id="pose-v05"','id="pose-proof"')
s=s.replace('Jump to v03 drawing','Jump to v05 source drawing').replace('Jump to v05 drawing','Jump to v06 proof drawing')
a=s.index('<div class="controls"><button id="pin-v03-2"');b=s.index('<p id="pose-jump-status"',a)
s=s[:a]+'<div class="controls"><button id="pin-grip">Key #7 · inspect the grip proof</button></div>'+s[b:]
a=s.index('<details');b=s.index('</main>',a)
s=s[:a]+'''<details open><summary>Scope and what remains</summary><p>This is one static grip-construction test. The original blade angle, protected forward sword/guard pixels, source alpha and body outside the local repair mask remain exact. Fifteen other keys are unchanged. New hand detail does not establish correct wrist anatomy, a good moving grip or a successful whole-strip correction. The current game remains the preferred benchmark.</p></details>
<details><summary>Repair evidence</summary><p>The AI redraw was made from an enlarged opaque diagnostic crop, then downsampled and placed through one bounded RGB mask. Its high-resolution face/body redraw is not used. One manual local alignment of−1/+1px was applied to the proposal; there is no whole-pose recentering or rescaling.</p><p><a href="outputs/key07-rgb-repair-mask.png">Exact RGB repair mask</a> · <a href="outputs/repair-record.json">Placement and preservation record</a> · <a href="raw/attempt01.png">Raw AI proof</a> · <a href="prompts/attempt01.txt">Exact prompt</a></p></details>
<p><a href="../2026-10-23-x1-opening-v05/review.html">Source v05 review</a> · <a href="preview/project.godot">One-key proof in Godot</a> · <a href="README.md">Trial record</a></p>
'''+s[b:]
a=s.index('<script id="review-data" type="application/json">')+len('<script id="review-data" type="application/json">');b=s.index('</script>',a)
s=s[:a]+json.dumps(data,separators=(',',':'))+s[b:]
s=re.sub(r'^const unaligned=.*?;\n','',s,flags=re.M)
s=s.replace('const all=[...data.clips,unaligned]','const all=data.clips')
s=s.replace('function selected(){return [data.clips[0],data.clips[1],$("unaligned").checked?unaligned:data.clips[2]];}','function selected(){return data.clips;}')
s=s.replace('$("unaligned").onchange=()=>{draw();};\n','')
s=s.replace("let action='x1',t=0,heat=0,playing=true","let action='x1',t=.158,heat=0,playing=false")
s=s.replace('Current game, v03 references and v05 trial loaded; no gameplay or timing changes.','Loaded: current game / unchanged v05 / one-key RGB grip proof. No gameplay or clock changes.')
s=s.replace('Current game preferred baseline, v03 reference and v05 opening trial at native size','Current game, original v05 and one-key wrist repair proof at native size')
(ROOT/'review.html').write_text(s,encoding='utf-8',newline='\n')

dest=ROOT/'preview';dest.mkdir(exist_ok=True);shutil.copy2(PRIOR/'preview/main.tscn',dest/'main.tscn')
project=(PRIOR/'preview/project.godot').read_text(encoding='utf-8').replace('Laema X1 opening RND v05','Laema one-key grip proof RND v06')
(dest/'project.godot').write_text(project,encoding='utf-8',newline='\n')
gd=(PRIOR/'preview/main.gd').read_text(encoding='utf-8')
gd=re.sub(r'const LABELS := .*','const LABELS := ["Current game / user preferred", "v05 / wrist still rejected", "v06 / ONE-key grip proof"]',gd)
gd=re.sub(r'const FILES := .*','const FILES := ["current-game-x1.png", "x1-opening-v05.png", "x1-grip-proof-v06.png"]',gd)
gd=gd.replace('LAEMA / OPENING CORRECTION','LAEMA / ONE-KEY WRIST + GRIP PROOF')
gd=gd.replace('Current game preferred | v03 reference | v05 trial | same0.720s action','Only key7 locally repaired; source blade angle and other keys unchanged | .720s action')
gd=gd.replace('OPENING_V05=%d','GRIP_PROOF_V06=%d')
gd=gd.replace('Preferred v03 #2 held at keys2-4;3 new release drawings; later v04 poses remain unapproved.','One local RGB grip test only. No whole-strip correction, visual acceptance or integrated combat claim.')
(dest/'main.gd').write_text(gd,encoding='utf-8',newline='\n')
print('Prepared the same viewer with native-pixel grip zooms and one-key motion context.')
