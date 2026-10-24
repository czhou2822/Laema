"""Review derivatives from actual saved engine captures; no synthetic scene compositing."""
from pathlib import Path
from PIL import Image,ImageDraw,ImageFont
import json,sys
HERE=Path(__file__).resolve().parent
phase=sys.argv[1] if len(sys.argv)>1 else 'baseline-gpu'
folder=HERE/('engine-'+phase)
font=ImageFont.truetype('C:/Windows/Fonts/arial.ttf',16)
report=json.loads((folder/'capture-report.json').read_text())
assert all(x['save_error']==0 for x in report['captures'])
names=['current','nearest','restoration']
names += [x for x in ['reference','masked','masked-full'] if (folder/x/'frame_09.png').exists()]
full05=names+[x for x in ['builtin-raw','builtin-alpha','builtin-weapon','reference-scout','restored-unmasked-scout','masked-high-scout','masked-full-scout'] if (folder/x/'frame_05.png').exists()]
sheet=Image.new('RGB',(430*len(full05),268),(18,23,30));d=ImageDraw.Draw(sheet)
for j,n in enumerate(full05):
    im=Image.open(folder/n/'frame_05.png').convert('RGB')
    assert im.size==(1280,720)
    sheet.paste(im.crop((650,400,1080,630)),(j*430,32));d.text((j*430+8,7),n+' / pose05',font=font,fill='white')
sheet.save(folder/'comparison_detail05.png')
frames=[]
for i in range(10):
    row=Image.new('RGB',(430*len(names),268),(18,23,30));d=ImageDraw.Draw(row)
    for j,n in enumerate(names):
        im=Image.open(folder/n/f'frame_{i:02d}.png').convert('RGB')
        row.paste(im.crop((650,400,1080,630)),(j*430,32));d.text((j*430+8,7),f'{n} / frame{i:02d}',font=font,fill='white')
    frames.append(row)
frames[0].save(folder/'comparison_sync.webp',save_all=True,append_images=frames[1:],duration=[100]*10,loop=0,lossless=True)
frames[0].save(folder/'comparison_sync.gif',save_all=True,append_images=frames[1:],duration=[100]*10,loop=0,disposal=2)
checks={'actual_engine_captures':len(report['captures']),'all_save_errors_zero':True,'all_dimensions_1280x720':all(Image.open(x['file']).size==(1280,720) for x in report['captures']),'nonblank_captures':all(Image.open(x['file']).convert('L').getextrema()[0]!=Image.open(x['file']).convert('L').getextrema()[1] for x in report['captures']),'preview_frames':Image.open(folder/'comparison_sync.webp').n_frames,'preview_duration_ms':1000,'timing_status':'Assumed comparison timing only','no_new_playtest_evidence':True,'engine_boundary':report['limits']}
(folder/'preview-checks.json').write_text(json.dumps(checks,indent=2),encoding='utf-8')
if (folder/'masked-full/frame_09.png').exists():
    focus_names=['restoration','masked','masked-full']
    focus=[]
    for i in range(10):
        row=Image.new('RGB',(430*3,268),(18,23,30));d=ImageDraw.Draw(row)
        for j,n in enumerate(focus_names):
            im=Image.open(folder/n/f'frame_{i:02d}.png').convert('RGB')
            row.paste(im.crop((650,400,1080,630)),(j*430,32));d.text((j*430+7,7),f'{n} / frame{i:02d}',font=font,fill='white')
        focus.append(row)
    focus[0].save(folder/'focused_sync.webp',save_all=True,append_images=focus[1:],duration=[100]*10,loop=0,lossless=True)
    focus[0].save(folder/'focused_sync.gif',save_all=True,append_images=focus[1:],duration=[100]*10,loop=0,disposal=2)

print(json.dumps(checks,indent=2))
