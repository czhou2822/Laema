"""Inspect a builtin edit without rescaling or promoting packed artwork."""
import hashlib
import json
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[6]
ASSET = ROOT / 'assets/prototype/enemy/bone_dragon/remaster_v01'
BEFORE = ASSET / '_source/frozen/pilot-p002-a03-registered-before-wing-edit.png'
RAW = ASSET / '_source/raw/pilot-p002-a04-wing-only.png'
OUTPUT = ASSET / 'contacts/pilot/bone_dragon_p002-a04-native-canvas-comparison.png'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def metrics(im):
    a = im.getchannel('A')
    bb = a.point(lambda v: 255 if v > 8 else 0).getbbox()
    return {'size': list(im.size), 'alpha_gt_8_bbox': list(bb),
            'alpha_extrema': list(a.getextrema()), 'body_bottom_y_exclusive': bb[3]}

def matte(im):
    bg = Image.new('RGBA', im.size, (23, 36, 49, 255))
    bg.alpha_composite(im)
    return bg.convert('RGB')

before = Image.open(BEFORE).convert('RGBA')
after = Image.open(RAW).convert('RGBA')
contact = Image.new('RGB', (before.width + after.width, max(before.height, after.height) + 40), (23,36,49))
contact.paste(matte(before), (0,40))
contact.paste(matte(after), (before.width,40))
draw = ImageDraw.Draw(contact)
draw.text((10,10), 'CURRENT REGISTERED 1024x768 | unchanged', fill='white')
draw.text((before.width + 10,10), 'A04 RAW EDIT | native returned pixels | NOT REGISTERED / NOT RESCALED', fill='white')
contact.save(OUTPUT)
expected = {'bone_dragon_p000': '32e2ffbba4130db1b47a26ed19266fba83402f05a436c3f1c10b76d260624f86',
            'bone_dragon_p002': 'cbd9988e431e65aaae82df26865d3344dd7ac21a4bc5d24f7af324ff75d99fb8',
            'bone_dragon_p042': '81fbd2cabb4d8646af5ee0b26cca79fd9a7f4fb4defcbdacd9671c3ce70cf1f8'}
result = {'attempt': 'pilot-p002-a04-wing-only', 'requested_builtin_edit_count': 1,
          'before': metrics(before), 'raw_edit': metrics(after),
          'same_canvas_dimensions': before.size == after.size,
          'registration_preservation_pass': False, 'promoted_to_registered_pose': False,
          'packed_image_rescaled': False, 'raw_sha256': sha(RAW),
          'current_registered_poses_unchanged': {pid: sha(ASSET/'poses'/(pid+'.png')) == value for pid,value in expected.items()},
          'comparison': OUTPUT.relative_to(ROOT).as_posix(),
          'status': 'Reject promotion: builtin changed canvas dimensions and figure layout; preserve current registration.'}
print(json.dumps(result, indent=2))
