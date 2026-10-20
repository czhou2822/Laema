"""Independent row-oriented DEF decode plus export/reference and source checks."""
from pathlib import Path
import json,struct,hashlib,collections
from PIL import Image,ImageDraw,ImageFont

ROOT=Path(__file__).resolve().parent
def digest(b):return hashlib.sha256(b).hexdigest()
def readnum(d,p,n):return int.from_bytes(d[p:p+n],'little')

def second_decode(d,off):
    _,fmt,fw,fh,w,h,l,t=struct.unpack_from('<6I2i',d,off)
    base=off+32
    if fmt==1 and w>fw and h>fh:w,h,l,t,base=fw,fh,0,0,off+16
    if not w or not h:return b''
    if fmt==0:return d[base:base+w*h]
    rows=[]; cursor=base+readnum(d,base,2) if fmt==2 else 0
    for y in range(h):
        if fmt==1:cursor=base+readnum(d,base+y*4,4)
        if fmt==3:cursor=base+readnum(d,base+y*2*(w//32),2)
        values=[]
        while len(values)<w:
            tag=d[cursor];cursor+=1
            if fmt==1:
                count=d[cursor]+1;cursor+=1;literal=tag==255;value=tag
            else:count=(tag%32)+1;literal=tag//32==7;value=tag//32
            if literal:values.extend(d[cursor:cursor+count]);cursor+=count
            else:values.extend([value]*count)
        assert len(values)==w
        rows.append(bytes(values))
    return b''.join(rows)

def main():
    m=json.loads((ROOT/'manifest.json').read_text('utf-8'))
    verified=0;defs=0;legacy=0;overflow=0;dupes=0;seen={}; samples=[]
    for archive in m['archives']:
        assert digest(Path(archive['path']).read_bytes())==archive['sha256'],archive['path']
    for asset in m['assets']:
        d=(ROOT/'originals'/asset['archive']/asset['name']).read_bytes()
        assert digest(d)==asset['sha256']
        metadata=json.loads((ROOT/asset['path']/'metadata.json').read_text('utf-8'))
        assert metadata['groups']==asset['groups']
        assert (ROOT/asset['path']/'palette.rgb').read_bytes()==d[16:784]
        for group in asset['groups']:
            images=[Image.open(ROOT/asset['path']/p['indexed']) for p in group['pages']]
            for image in images:assert image.mode=='P' and bytes(image.getpalette()[:768])==d[16:784]
            for frame in group['frames']:
                px=second_decode(d,frame['offset'])
                assert digest(px)==frame['index_sha256'],(asset['name'],group['id'],frame['index'])
                if frame['width'] and frame['height']:
                    x=frame['x']+frame['left']-group['origin_x'];y=frame['y']+frame['top']-group['origin_y']
                    assert images[frame['page']].crop((x,y,x+frame['width'],y+frame['height'])).tobytes()==px
                legacy+=frame['legacy_header'];overflow+=(frame['left']<0 or frame['top']<0 or frame['left']+frame['width']>frame['full_width'] or frame['top']+frame['height']>frame['full_height'])
                verified+=1
            for image in images:image.close()
        defs+=1
        if asset['sha256'] in seen:dupes+=1
        seen[asset['sha256']]=asset['name']
    chosen=['Csword.def','Ccrusd.def','Cmonkk.def','CFELEM.def','CADVL.def','C01SPF0.def','C01SPW0.def','AH00_E.def','TBCSCSTL.def','TBCSTVRN.def','AVWmrnd0.def','SGTWMTA.def']
    byname={a['name'].lower():a for a in m['assets']}
    for name in chosen:
        if name.lower() in byname:samples.append(byname[name.lower()])
    for category in sorted(set(a['category'] for a in m['assets'])):
        if not any(a['category']==category for a in samples):samples.append(next(a for a in m['assets'] if a['category']==category))
    samples=samples[:16]; cols=4;cw,ch=300,245
    image=Image.new('RGB',(cols*cw,math_ceil(len(samples),cols)*ch),(34,41,44));draw=ImageDraw.Draw(image)
    for i,a in enumerate(samples):
        g=a['groups'][0];f=g['frames'][0];x=i%cols*cw;y=i//cols*ch
        draw.text((x+12,y+9),a['name'],fill=(240,216,165))
        draw.text((x+12,y+28),a['category'],fill=(163,178,182))
        with Image.open(ROOT/a['path']/g['pages'][0]['preview']) as src:
            im=src.crop((f['x'],f['y'],f['x']+g['cell_width'],f['y']+g['cell_height']))
            scale=min(2,276/im.width,173/im.height)
            im=im.resize((max(1,int(im.width*scale)),max(1,int(im.height*scale))),Image.Resampling.NEAREST)
            image.paste(im,(x+(cw-im.width)//2,y+52+(173-im.height)//2),im)
        draw.text((x+12,y+229),f"{a['frame_count']} frames / {a['group_count']} groups",fill=(150,165,169))
    image.save(ROOT/'contact-sheet.png')
    report=dict(defs_verified=defs,frames_verified=verified,independent_decoder_matches=True,indexed_export_matches=True,all_source_lod_hashes_unchanged=True,legacy_header_frames=legacy,frames_extending_declared_canvas=overflow,byte_identical_def_duplicates=dupes,unique_def_hashes=len(seen))
    (ROOT/'verification.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(report),flush=True)

def math_ceil(n,d):return (n+d-1)//d
if __name__=='__main__':main()
