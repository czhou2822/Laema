from pathlib import Path
from PIL import Image
import subprocess,io,json
OUT=Path(__file__).parent
ROOT=OUT.parents[3]
data=subprocess.check_output(['git','show','9f9d9bba:assets/prototype/player/animation/earth_x4.png'],cwd=ROOT)
atlas=Image.open(io.BytesIO(data)).convert('RGBA')
atlas.save(OUT/'original-x4-atlas.png')
grid=Image.new('RGBA',(1536,1024),(0,0,0,0))
for i in range(5):
    f=atlas.crop((i*128,0,(i+1)*128,128))
    f.save(OUT/f'original-pose-{i+1:02}.png')
    grid.alpha_composite(f.resize((384,384),Image.Resampling.NEAREST),((i%3)*512+64,(i//3)*512+32))
grid.save(OUT/'original-five-pose-authority.png')
bg=Image.new('RGBA',grid.size,'#505961');bg.alpha_composite(grid);bg.convert('RGB').save(OUT/'original-five-pose-grey.png')
print(OUT)
