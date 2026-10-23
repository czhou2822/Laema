"""Enlarge review comparisons only; never modify artwork."""
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parents[6]
folder=root/'assets/prototype/enemy/bone_dragon/remaster_v01/contacts/full-review'
for number in [46,47,51,52,53,54]:
    name='bone_dragon_p'+str(number).zfill(3)
    im=Image.open(folder/(name+'-comparison.png'))
    im.resize((im.width*2,im.height*2),Image.Resampling.NEAREST).save(folder/(name+'-limb-detail-2x.png'))
