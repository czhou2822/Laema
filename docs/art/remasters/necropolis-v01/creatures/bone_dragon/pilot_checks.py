"""Mechanical pilot comparisons and alpha/padding measurements; never draws art."""
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageOps

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
ASSET = ROOT / 'assets/prototype/enemy/bone_dragon/remaster_v01'
CONTACTS = ASSET / 'contacts/pilot'
IDS = ['bone_dragon_p000', 'bone_dragon_p002', 'bone_dragon_p042']
spec = importlib.util.spec_from_file_location('necropolis_readonly', ROOT / 'tools/art/necropolis_remaster.py')
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)


def relative(path):
    return Path(path).relative_to(ROOT).as_posix()


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def matte(im, color=(23, 36, 49, 255)):
    result = Image.new('RGBA', im.size, color)
    result.alpha_composite(im)
    return result.convert('RGB')


def alpha_stats(im):
    alpha = im.getchannel('A')
    bb = alpha.getbbox()
    bb8 = alpha.point(lambda a: 255 if a > 8 else 0).getbbox()
    histogram = alpha.histogram()
    margins = [bb[0], bb[1], im.width - bb[2], im.height - bb[3]]
    pixels = im.get_flattened_data() if hasattr(im, 'get_flattened_data') else im.getdata()
    red = sum(a > 16 and r > 180 and g < 80 and b < 80 for r, g, b, a in pixels)
    return {'size': list(im.size), 'alpha_extrema': list(alpha.getextrema()),
            'transparent_pixels': histogram[0], 'opaque_pixels': histogram[255],
            'partial_alpha_pixels': sum(histogram[1:255]), 'alpha_gt_0_bbox': list(bb),
            'alpha_gt_8_bbox': list(bb8), 'padding_ltrb_all_nonzero_alpha': margins,
            'fits_40px_padding_all_nonzero_alpha': min(margins) >= 40,
            'saturated_red_pixels_alpha_gt_16': red}


def main():
    CONTACTS.mkdir(parents=True, exist_ok=True)
    creature = helper.creature('bone_dragon')
    poses = helper.posemap(creature)
    native_sheet = Image.new('RGB', (450 * 3, 400 * 2), (23, 36, 49))
    records = []
    for index, pid in enumerate(IDS):
        data_path = ASSET / 'poses' / (pid + '.json')
        data = json.loads(data_path.read_text(encoding='utf-8'))
        new = Image.open(ROOT / data['registered_pose_file']).convert('RGBA')
        mirror = Image.open(ROOT / data['mirror_file']).convert('RGBA')
        raw_path = ROOT / data['raw_source']
        raw = Image.open(raw_path).convert('RGBA')
        source = helper.projected_original(poses[pid])
        native = helper.opaque_reference(poses[pid])
        native_new = new.transform((450, 400), Image.Transform.AFFINE,
            (helper.SCALE, 0, helper.ANCHOR[0] - helper.SOURCE_ANCHOR[0] * helper.SCALE,
             0, helper.SCALE, helper.ANCHOR[1] - helper.SOURCE_ANCHOR[1] * helper.SCALE),
            resample=Image.Resampling.BICUBIC)
        comparison = Image.new('RGB', (2048, 768), (23, 36, 49))
        comparison.paste(matte(source), (0, 0))
        comparison.paste(matte(new), (1024, 0))
        draw = ImageDraw.Draw(comparison)
        draw.text((20, 20), pid + ' | original projected reference', fill='white')
        draw.text((1044, 20), 'registered candidate | 1024 x 768 | same shared transform', fill='white')
        comparison_path = CONTACTS / (pid + '-registered-comparison.png')
        comparison.save(comparison_path)
        native_sheet.paste(matte(native), (index * 450, 0))
        native_sheet.paste(matte(native_new), (index * 450, 400))
        draw_native = ImageDraw.Draw(native_sheet)
        draw_native.text((index * 450 + 10, 10), pid + ' ORIGINAL native 1:1', fill='white')
        draw_native.text((index * 450 + 10, 410), 'CANDIDATE backprojected native scale', fill='white')
        union = ImageChops.lighter(source.getchannel('A'), new.getchannel('A')).getbbox()
        region = (max(0, union[0] - 15), max(0, union[1] - 15),
                  min(1024, union[2] + 15), min(768, union[3] + 15))
        og_zoom = matte(source).crop(region).resize(((region[2]-region[0])*2, (region[3]-region[1])*2), Image.Resampling.NEAREST)
        new_zoom = matte(new).crop(region).resize(og_zoom.size, Image.Resampling.NEAREST)
        zoom = Image.new('RGB', (og_zoom.width * 2, og_zoom.height))
        zoom.paste(og_zoom, (0, 0))
        zoom.paste(new_zoom, (og_zoom.width, 0))
        zoom_path = CONTACTS / (pid + '-2x-detail.png')
        zoom.save(zoom_path)
        matte(raw).save(CONTACTS / (pid + '-raw-dark-matte.png'))
        matte(new, (235, 235, 230, 255)).save(CONTACTS / (pid + '-light-matte.png'))
        records.append({'pose_id': pid, 'group': poses[pid]['representative']['group_id'],
            'frame_index': poses[pid]['representative']['frame_index'],
            'raw': relative(raw_path), 'raw_sha256': digest(raw_path),
            'registered': data['registered_pose_file'], 'registered_sha256': digest(ROOT/data['registered_pose_file']),
            'registration': data['registration'], 'raw_alpha': alpha_stats(raw),
            'registered_alpha': alpha_stats(new),
            'mirror_exact_rgba': ImageChops.difference(ImageOps.mirror(new), mirror).getbbox() is None,
            'comparison': relative(comparison_path), 'detail_comparison': relative(zoom_path)})
    native_path = CONTACTS / 'pilot-native-size.png'
    native_sheet.save(native_path)
    inputs = [ROOT / creature['appearance_reference'], ROOT / creature['original_metadata'],
              ROOT / creature['original_def'], ROOT / 'docs/art/remasters/necropolis-v01/generation-plan.json',
              ASSET / '_source/guides/pilot-extents.png', ASSET / '_source/guides/pilot-extents.json',
              ROOT / 'tools/art/necropolis_remaster.py']
    for pid in IDS:
        for name in ['rgba_sheet', 'indexed_sheet']:
            path = ROOT / poses[pid]['representative'][name]
            if path not in inputs:
                inputs.append(path)
    builtin_copies = []
    for meta_path in sorted((ASSET / '_source/prompts').glob('*.tool-result.json')):
        meta = json.loads(meta_path.read_text(encoding='utf-8'))
        original = Path(meta['builtin_saved_png'])
        archived = ROOT / meta['raw_png']
        builtin_copies.append({'metadata': relative(meta_path), 'archived': relative(archived),
            'sha256': digest(archived), 'byte_identical_to_builtin_png': digest(original) == digest(archived)})
    report = {'creature_id': 'bone_dragon', 'scope': 'three-pose pilot only',
        'native_comparison': relative(native_path), 'poses': records, 'builtin_raw_copies': builtin_copies,
        'inputs_sha256': {relative(path): digest(path) for path in inputs},
        'full_creature_complete': False, 'human_animation_acceptance': False,
        'runtime_checked': False, 'original_timing_verified': False,
        'note': 'Mechanical image checks only. Pose comparisons still require actual visual inspection.'}
    (REPORT / 'pilot-mechanical-checks.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
