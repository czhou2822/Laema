from pathlib import Path
from PIL import Image
OUT=Path(__file__).parent
source=Image.open(OUT/'generation-02-shield-correction.png').convert('RGBA')
w,h=source.width//3,source.height//2
source.crop((w*2,0,w*3,h)).save(OUT/'pose3-edit-target.png')
original=Image.open(OUT/'original-pose-03.png').convert('RGBA').resize((512,512),Image.Resampling.NEAREST)
original.save(OUT/'pose3-original-authority-4x.png')
