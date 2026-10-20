from pathlib import Path
import struct, collections
root=Path(r'C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Heroes of Might and Magic 3 Complete Edition')
for p in root.rglob('*.lod'):
 d=p.read_bytes(); n=struct.unpack_from('<I',d,8)[0]; names=[struct.unpack_from('<16sIIII',d,92+i*32)[0].split(b'\0')[0].decode('ascii') for i in range(n)]
 print(p.relative_to(root),len(d),n,dict(collections.Counter(Path(s).suffix.lower() for s in names)),flush=True)
