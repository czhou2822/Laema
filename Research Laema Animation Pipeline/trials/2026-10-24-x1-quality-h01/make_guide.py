from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json, math
ROOT=Path(__file__).resolve().parent
specs=[
 {'key':5,'elbow':[225,283],'wrist':[242,270],'palm':[249,262],'guard':[248,251],'pommel':[252,275],'blade_axis':[-.06,-.998],
  'mask':[[217,269],[226,267],[235,272],[242,260],[243,252],[252,251],[258,255],[260,268],[255,278],[245,281],[234,292],[222,292],[215,282]]},
 {'key':6,'elbow':[226,284],'wrist':[242,275],'palm':[251,267],'guard':[253,258],'pommel':[263,275],'blade_axis':[.68,-.73],
  'mask':[[216,269],[226,267],[235,274],[244,263],[250,255],[259,255],[267,264],[268,274],[255,281],[242,292],[228,297],[216,289]]},
 {'key':7,'elbow':[231,258],'wrist':[245,269],'palm':[255,275],'guard':[264,269],'pommel':[247,281],'blade_axis':[.94,-.34],
  'mask':[[218,250],[230,248],[240,255],[249,262],[261,263],[267,270],[265,282],[253,288],[242,282],[232,273],[222,270]]}
]
guide=Image.new('RGB',(1536,512),'#17212c');font=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',18)
for col,s in enumerate(specs):
 raw=Image.open(ROOT/'inputs'/f'arm-key{s["key"]:02}-native.png').convert('RGBA')
 panel=Image.new('RGB',(512,512),'#17212c');panel.paste(raw.resize((512,512),Image.Resampling.NEAREST),(0,0),raw.getchannel('A').resize((512,512),Image.Resampling.NEAREST));panel=Image.blend(panel,Image.new('RGB',panel.size,'#17212c'),.5)
 d=ImageDraw.Draw(panel)
 def xy(p):return((p[0]-196)*4,(p[1]-208)*4)
 d.line([xy(s[p]) for p in ['elbow','wrist','palm']],fill='#62d9e8',width=6)
 d.line([xy(s[p]) for p in ['pommel','guard']],fill='#f7d26a',width=7)
 for p in ['elbow','wrist','palm']:
  x,y=xy(s[p]);d.ellipse((x-6,y-6,x+6,y+6),fill='#62d9e8')
 x,y=xy(s['palm']);d.ellipse((x-17,y-24,x+17,y+24),outline='#9de892',width=3)
 d.text((12,12),f'Key {s["key"]}: original grip construction',font=font,fill='white')
 d.text((12,448),'Cyan: elbow / wrist / palm',font=font,fill='#62d9e8')
 d.text((12,477),'Gold: fixed hilt. Green: closed fingers.',font=font,fill='#f7d26a')
 guide.paste(panel,(col*512,0))
guide.save(ROOT/'inputs/release-grip-construction.png')
(ROOT/'inputs/construction.json').write_text(json.dumps({'source_crop':[196,208,324,336],'scale':4,'keys':specs,'source':'Original manual targets; diagnostic construction, not traced external movement or an anatomical acceptance claim.'},indent=2)+'\n',encoding='utf-8')
prompt='''Use case: precise-object-edit. Asset: one three-panel local sword-arm correction strip for an original 2D sprite animation.
Image1 is the EDIT TARGET, three equal square close-ups in one horizontal row. Each panel is an existing original Laema R&D release drawing, in order keys5,6,7. Image2 is a new ORIGINAL CONSTRUCTION GUIDE for those same three panels, not another animation to copy.

Return the SAME three-panel horizontal layout, same canvas aspect3:1, with the unchanged crop positions and scale, on real transparent alpha. Repair ONLY each right sword forearm, wrist and closed leather-gloved hand. The hand must visibly ENCLOSE the handle, rather than appear attached to a blade emerging from the wrist or front knuckles. Make a different structural hand/forearm silhouette where needed, not just added finger texture. Four fingers curl around the handle; the index/thumb sit immediately behind the guard, the little finger is toward the pommel. The hilt crosses the curled palm obliquely. Keep a relaxed continuous wrist from forearm into palm, not an overextended hinge, circular ball or disconnected cuff.

Follow Image2's cyan elbow/wrist/palm chain, gold fixed handle axis and green closed-finger envelope in each panel. The hand/palm axis and sword axis are DIFFERENT. Frame5 forearm/palm rise diagonally into an almost vertical handle. Frame6 forearm/palm rise diagonally into a diagonally sloping handle. Frame7 forearm/palm descend gently right into the closed hand while the blade points up-right. Do not simply rotate the entire arm to align with the blade.

Strict invariants: do NOT move/rotate/redesign the blade, guard or pommel. Keep their current positions, length, thickness and perspective in each panel. Do NOT change head, face, ponytail, blue vest, cream sleeve outside the edited forearm, round blue shield, red sash or torso. Same camera, same lighting, same painted sprite rendering and same character size. No extra limb, fingers, accessories, other full characters, motion trails, glow, smearing, outlines or background. Do NOT fill transparent gaps with black. Remove ALL guide markings, labels, dots, grid and text from the result. The only desired differences are three coherent anatomically readable forearm/wrist/closed-hand constructions, attached to the existing fixed swords. Keep all original crop edges and layout.
'''
(ROOT/'prompts/attempt01.txt').write_text(prompt,encoding='utf-8')
print('Original construction and exact localized edit prompt saved.')
