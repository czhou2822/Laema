"""Mechanical Zombie source/candidate contact extraction; never draws artwork."""
import importlib.util
import math
import sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageOps, ImageSequence

ROOT = Path(__file__).resolve().parents[6]
spec = importlib.util.spec_from_file_location('necropolis_parent_readonly', ROOT / 'tools/art/necropolis_remaster.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
CID = 'zombie'
DD = helper.dest(CID)
OUT = DD / '_source/review'
OUT.mkdir(parents=True, exist_ok=True)

def pair(pid, mirrored=False):
    pose = helper.posemap(helper.creature(CID))[pid]
    og = helper.projected_original(pose)
    new = Image.open(DD / 'poses' / (pid + '.png')).convert('RGBA')
    if mirrored:
        og, new = ImageOps.mirror(og), ImageOps.mirror(new)
    panel = Image.new('RGB', (1120, 410), (23,36,49))
    for k, im in enumerate([og, new]):
        panel.paste(helper.matte(im).crop((240,180,800,560)), (560*k,30))
    ImageDraw.Draw(panel).text((10,8), pid + (' mirror' if mirrored else ' source') + '  ORIGINAL                                           CANDIDATE (registered pixels 1:1)', fill='white')
    return panel

def poses(ids, name):
    sheet = Image.new('RGB', (2240, 410*math.ceil(len(ids)/2)), (23,36,49))
    for i,pid in enumerate(ids):
        sheet.paste(pair(pid), (i%2*1120, i//2*410))
    path = OUT / (name+'.png')
    sheet.save(path)
    print(path)

def groups():
    manifest = helper.read(DD/'source_manifest.json')
    for g in manifest['groups']:
        if not g['complete']:
            continue
        name = 'g%02d_b%02d' % (g['group_id'],g['original_block'])
        # Every ordered position in each facing, without animated playback claims.
        sheet = Image.new('RGB',(2240,410*len(g['pose_ids_in_source_order'])),(23,36,49))
        for i,pid in enumerate(g['pose_ids_in_source_order']):
            sheet.paste(pair(pid), (0,i*410))
            sheet.paste(pair(pid,True), (1120,i*410))
        sheet.save(OUT/(name+'-both-facing-comparison.png'))
        # Decode every actual GIF frame for both facings into a compact strip.
        for facing in ['source','mirror']:
            gif = Image.open(DD/'previews'/('group_%02d_block_%02d_%s.gif' % (g['group_id'],g['original_block'],facing)))
            frames=[]
            for j,frame in enumerate(ImageSequence.Iterator(gif)):
                im=frame.convert('RGB').crop((120,90,400,280)).resize((560,380),Image.Resampling.NEAREST)
                panel=Image.new('RGB',(560,405),(23,36,49)); panel.paste(im,(0,25))
                ImageDraw.Draw(panel).text((8,6),name+' '+facing+' decoded GIF frame '+str(j),fill='white')
                frames.append(panel)
            sheet=Image.new('RGB',(2240,405*math.ceil(len(frames)/4)),(23,36,49))
            for j,im in enumerate(frames): sheet.paste(im,(j%4*560,j//4*405))
            sheet.save(OUT/(name+'-'+facing+'-gif-frames.png'))
        contact=Image.open(ROOT/g['contact']).convert('RGB')
        contact=contact.resize((1024,round(contact.height/2)),Image.Resampling.LANCZOS)
        strips=[]
        for facing in ['source','mirror']:
            strip=Image.open(OUT/(name+'-'+facing+'-gif-frames.png')).convert('RGB')
            strip=strip.resize((1120,round(strip.height/2)),Image.Resampling.LANCZOS)
            strips.append(strip)
        board=Image.new('RGB',(2160,max(contact.height,sum(s.height for s in strips))+40),(23,36,49))
        ImageDraw.Draw(board).text((8,8),name+'  LEFT: all original/candidate contact positions. RIGHT TOP/BOTTOM: decoded source/mirror GIF frames. Static review; not timed playback.',fill='white')
        board.paste(contact,(0,40))
        yy=40
        for strip in strips:
            board.paste(strip,(1040,yy)); yy+=strip.height
        board.save(OUT/(name+'-group-review-board.png'))
        print(name)

if sys.argv[1]=='poses':
    poses(sys.argv[2].split(','),sys.argv[3])
elif sys.argv[1]=='groups':
    groups()
