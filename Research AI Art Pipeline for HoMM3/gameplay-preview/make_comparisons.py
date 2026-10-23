from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent / 'normalized'
METHODS = [
    ('current', 'Current repaint v02'),
    ('a-realesrgan', 'A: Real-ESRGAN + source alpha'),
    ('b-edit', 'B: reference-guided edit'),
    ('c-strip', 'C: whole-strip extraction'),
]
FONT = ImageFont.truetype('/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf', 18)

def labelled(image, text):
    out = Image.new('RGB', (image.width, image.height + 30), '#152030')
    out.paste(image.convert('RGB'), (0, 30))
    ImageDraw.Draw(out).text((8, 4), text, font=FONT, fill='white')
    return out

def grid(items):
    width = max(im.width for im in items)
    height = max(im.height for im in items)
    out = Image.new('RGB', (width * 2, height * 2), '#152030')
    for index, im in enumerate(items):
        out.paste(im, ((index % 2) * width, (index // 2) * height))
    return out

def main():
    panels = []
    details = []
    roi = (590, 360, 1100, 630)
    for method, label in METHODS:
        image = Image.open(ROOT / f'{method}-fullthrust.png').convert('RGB')
        panels.append(labelled(image.resize((640, 360), Image.Resampling.LANCZOS), label))
        details.append(labelled(image.crop(roi), label))
        frames = [Image.open(ROOT / 'frames' / method / f'frame_{i:02d}.png').convert('RGB') for i in range(10)]
        frames[0].save(ROOT / f'{method}-engine-preview.webp', save_all=True, append_images=frames[1:], duration=100, loop=0, lossless=True)
    grid(panels).save(ROOT / 'engine-comparison-fullthrust.png')
    grid(details).save(ROOT / 'engine-comparison-detail.png')
    nearest_image = Image.open(ROOT / 'a-nearest-fullthrust.png').convert('RGB')
    five = details[:1] + [labelled(nearest_image.crop(roi), 'A control: nearest + source alpha')] + details[1:]
    fiveway = Image.new('RGB', (five[0].width * 3, five[0].height * 2), '#152030')
    for index, image in enumerate(five):
        fiveway.paste(image, ((index % 3) * image.width, (index // 3) * image.height))
    fiveway.save(ROOT / 'engine-comparison-fiveway.png')
    nearest_frames = [Image.open(ROOT / 'frames' / 'a-nearest' / f'frame_{i:02d}.png').convert('RGB') for i in range(10)]
    nearest_frames[0].save(ROOT / 'a-nearest-engine-preview.webp', save_all=True, append_images=nearest_frames[1:], duration=100, loop=0, lossless=True)
    previews = []
    for index in range(10):
        items = [labelled(Image.open(ROOT / 'frames' / method / f'frame_{index:02d}.png').crop(roi), label) for method, label in METHODS]
        previews.append(grid(items))
    previews[0].save(ROOT / 'engine-comparison-animated.webp', save_all=True, append_images=previews[1:], duration=100, loop=0, lossless=True)
    previews[0].save(ROOT / 'engine-comparison-animated.gif', save_all=True, append_images=previews[1:], duration=100, loop=0, disposal=2)
    print('Saved normalized engine comparison sheets and ten-frame100ms previews.')

if __name__ == '__main__':
    main()
