"""Read-only HoMM3 LOD/DEF extraction. Output stays beside this script.

Format references (independent implementation, no executable disassembly):
https://github.com/vcmi/vcmi/blob/develop/lib/filesystem/CArchiveLoader.cpp
https://github.com/vcmi/vcmi/blob/develop/client/render/CDefFile.cpp
"""
from pathlib import Path
import struct, zlib, json, hashlib, math, time, collections, concurrent.futures, traceback
from PIL import Image

ROOT = Path(__file__).resolve().parent
SOURCE = Path(r'C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Heroes of Might and Magic 3 Complete Edition')
TYPES = {64:'spell effects',65:'sprites',66:'creatures',67:'map objects',68:'map heroes',69:'terrain',70:'cursors',71:'interface',72:'sprite frames',73:'battle heroes'}

def sha(b): return hashlib.sha256(b).hexdigest()
def dump(p, d): p.write_text(json.dumps(d, ensure_ascii=False, indent=2), encoding='utf-8')
def u32(d, p): return struct.unpack_from('<I', d, p)[0]
def u16(d, p): return struct.unpack_from('<H', d, p)[0]

def entries(path):
    d = path.read_bytes()
    assert d[:4] == b'LOD\0', (path, d[:4])
    n = u32(d, 8)
    out=[]
    for i in range(n):
        name, off, size, unknown, packed = struct.unpack_from('<16sIIII', d, 92+i*32)
        name=name.split(b'\0')[0].decode('ascii')
        assert Path(name).name == name and '/' not in name and '\\' not in name
        assert off+(packed or size) <= len(d)
        out.append(dict(name=name,offset=off,size=size,compressed_size=packed,unknown=unknown))
    return d,out

def header(d):
    typ,w,h,n=struct.unpack_from('<4I',d,0)
    pal=d[16:784]
    assert len(pal)==768
    p=784; groups=[]
    for g in range(n):
        gid,count,a,b=struct.unpack_from('<4I',d,p); p+=16
        names=[d[p+i*13:p+(i+1)*13].split(b'\0')[0].decode('cp1252') for i in range(count)]; p+=count*13
        offsets=struct.unpack_from('<'+'I'*count,d,p); p+=count*4
        groups.append(dict(id=gid,unknown=[a,b],names=names,offsets=offsets))
    return typ,w,h,pal,groups

def decode(d, off):
    size,fmt,fw,fh,w,h,left,top=struct.unpack_from('<6I2i',d,off)
    base=off+32; legacy=False
    if fmt==1 and w>fw and h>fh:
        # Two legacy town DEFs have a 16-byte header.
        w,h,left,top=fw,fh,0,0; base=off+16; legacy=True
    assert 0<fw<=10000 and 0<fh<=10000 and w<=10000 and h<=10000, (off,fw,fh,w,h)
    assert fmt in range(4),fmt
    def run(pos, wanted, wide):
        row=bytearray()
        while len(row)<wanted:
            if wide:
                code,length=d[pos],d[pos+1]+1; pos+=2; raw=code==255
            else:
                token=d[pos]; pos+=1; code=token>>5; length=(token&31)+1; raw=code==7
            assert len(row)+length<=wanted, ('RLE overrun',off,fmt,len(row),length,wanted)
            if raw:
                row.extend(d[pos:pos+length]); pos+=length
            else: row.extend(bytes([code])*length)
        return bytes(row),pos
    pixels=bytearray()
    if w and h:
        if fmt==0: pixels.extend(d[base:base+w*h])
        elif fmt==1:
            for y in range(h): pixels.extend(run(base+u32(d,base+y*4),w,True)[0])
        elif fmt==2:
            pos=base+u16(d,base)
            for y in range(h):
                row,pos=run(pos,w,False); pixels.extend(row)
        elif fmt==3:
            assert w%32==0, ('format3 width',w)
            for y in range(h):
                for x in range(w//32): pixels.extend(run(base+u16(d,base+2*(y*(w//32)+x)),32,False)[0])
    assert len(pixels)==w*h, (off,fmt,len(pixels),w*h)
    meta=dict(offset=off,stored_size=size,format=fmt,full_width=fw,full_height=fh,width=w,height=h,left=left,top=top,legacy_header=legacy,index_sha256=sha(pixels))
    return bytes(pixels),meta

def rgba_palette(pal,typ):
    lut=[tuple(pal[i*3:i*3+3])+(255,) for i in range(256)]
    # An explicitly labeled preview interpretation. Exact indices/palette remain separate.
    lut[0]=(0,0,0,0)
    if typ in (64,65,66,67,68,69,73):
        for idx,alpha in ((1,64),(2,128),(3,192),(4,128)):
            lut[idx]=(0,0,0,alpha)
    if typ==66:
        lut[5]=(0,0,0,0); lut[6]=(0,0,0,128); lut[7]=(0,0,0,64)
    return bytes(v for c in lut for v in c)

def process(job):
    archive,name=job
    raw=ROOT/'originals'/archive/name
    d=raw.read_bytes()
    typ,hw,hh,pal,groups=header(d)
    folder=ROOT/'sprites'/archive/Path(name).stem
    folder.mkdir(parents=True,exist_ok=True)
    (folder/'palette.rgb').write_bytes(pal)
    lut=rgba_palette(pal,typ)
    rgba_lut=Image.frombytes('RGBA',(256,1),lut)
    channel_luts=[list(rgba_lut.getdata(band=i)) for i in range(4)]
    result=dict(name=name,archive=archive,type=typ,category=TYPES.get(typ,'unknown'),header_width=hw,header_height=hh,def_sha256=sha(d),original=str(raw.relative_to(ROOT)).replace('\\','/'),palette='palette.rgb',groups=[])
    total=0; formats=collections.Counter(); cache={}
    for gno,g in enumerate(groups):
        decoded=[]
        for off in g['offsets']:
            if off not in cache: cache[off]=decode(d,off)
            decoded.append(cache[off])
        if not decoded: continue
        ox=min(0,min(m['left'] for _,m in decoded)); oy=min(0,min(m['top'] for _,m in decoded))
        cw=max(max(m['full_width'],m['left']+m['width']) for _,m in decoded)-ox
        ch=max(max(m['full_height'],m['top']+m['height']) for _,m in decoded)-oy
        # Keep ordinary groups together and cap pathological sheet sizes.
        cols=max(1,min(8,2048//cw,len(decoded)))
        max_per_page=max(cols,cols*max(1,2048//ch))
        gm=dict(id=g['id'],block=gno,unknown=g['unknown'],cell_width=cw,cell_height=ch,origin_x=ox,origin_y=oy,frames=[],pages=[])
        prefix=f"group_{g['id']:02d}_block_{gno:02d}"
        for start in range(0,len(decoded),max_per_page):
            chunk=decoded[start:start+max_per_page]; rows=math.ceil(len(chunk)/cols)
            sheet=Image.new('P',(cw*cols,ch*rows),0); sheet.putpalette(pal)
            page_index=len(gm['pages'])
            for local,(pixels,m) in enumerate(chunk):
                frame=start+local; x=(local%cols)*cw; y=(local//cols)*ch
                if m['width'] and m['height']:
                    crop=Image.frombytes('P',(m['width'],m['height']),pixels); crop.putpalette(pal)
                    sheet.paste(crop,(x+m['left']-ox,y+m['top']-oy))
                gm['frames'].append(dict(index=frame,name=g['names'][frame],page=page_index,x=x,y=y,**m))
                formats[m['format']]+=1
            indexed=f'{prefix}_page_{page_index:02d}_indexed.png'
            preview=f'{prefix}_page_{page_index:02d}.png'
            sheet.save(folder/indexed,optimize=False)
            rgba=Image.merge('RGBA',tuple(sheet.point(c,'L') for c in channel_luts))
            rgba.save(folder/preview,optimize=False)
            # Verify preservation export against every decoded frame, not just its appearance.
            with Image.open(folder/indexed) as check:
                assert check.mode=='P' and bytes(check.getpalette()[:768])==pal
                for fm in gm['frames'][start:start+len(chunk)]:
                    if fm['width'] and fm['height']:
                        px=fm['x']+fm['left']-ox; py=fm['y']+fm['top']-oy
                        recovered=check.crop((px,py,px+fm['width'],py+fm['height'])).tobytes()
                        assert sha(recovered)==fm['index_sha256']
            gm['pages'].append(dict(indexed=indexed,preview=preview,columns=cols,rows=rows,width=sheet.width,height=sheet.height,start_frame=start,frame_count=len(chunk)))
        result['groups'].append(gm); total+=len(decoded)
    result['frame_count']=total
    dump(folder/'metadata.json',result)
    # Small first-frame thumbnail, rendered without interpolation.
    if result['groups']:
        gg=result['groups'][0]; ff=gg['frames'][0]
        with Image.open(folder/gg['pages'][0]['preview']) as src:
            thumb=src.crop((ff['x'],ff['y'],ff['x']+gg['cell_width'],ff['y']+gg['cell_height']))
            thumb.thumbnail((160,120),Image.Resampling.NEAREST)
            thumb.save(folder/'thumbnail.png')
    return dict(name=name,archive=archive,type=typ,category=TYPES.get(typ,'unknown'),frame_count=total,group_count=len(result['groups']),path=str(folder.relative_to(ROOT)).replace('\\','/'),groups=result['groups'],formats=dict(formats),sha256=result['def_sha256'])

def main():
    started=time.time(); jobs=[]; inventory=[]; archives=[]
    for ap in sorted(SOURCE.rglob('*.lod')):
        data,table=entries(ap)
        ar=dict(path=str(ap),relative_path=str(ap.relative_to(SOURCE)),size=len(data),sha256=sha(data),entries=len(table),def_count=0)
        out=ROOT/'originals'/ap.stem; out.mkdir(parents=True,exist_ok=True)
        for e in table:
            e=dict(e,archive=ap.stem)
            if Path(e['name']).suffix.lower() in ('.def','.msk','.pal'):
                b=data[e['offset']:e['offset']+(e['compressed_size'] or e['size'])]
                if e['compressed_size']: b=zlib.decompress(b)
                assert len(b)==e['size']
                dest=out/e['name']; dest.write_bytes(b); assert sha(dest.read_bytes())==sha(b)
                e['sha256']=sha(b)
                if e['name'].lower().endswith('.def'):
                    ar['def_count']+=1; jobs.append((ap.stem,e['name']))
            inventory.append(e)
        archives.append(ar)
        print(f"Indexed {ap.name}: {ar['entries']} entries, {ar['def_count']} DEFs",flush=True)
    dump(ROOT/'archive-inventory.json',dict(archives=archives,entries=inventory))
    exported=[]; errors=[]
    with concurrent.futures.ProcessPoolExecutor(max_workers=6) as pool:
        futures={pool.submit(process,j):j for j in jobs}
        for i,f in enumerate(concurrent.futures.as_completed(futures),1):
            try: exported.append(f.result())
            except Exception:
                errors.append(dict(job=futures[f],error=traceback.format_exc()))
                print('ERROR',futures[f],errors[-1]['error'],flush=True)
            if i%100==0 or i==len(jobs): print(f'Converted {i}/{len(jobs)}, errors={len(errors)}, elapsed={time.time()-started:.0f}s',flush=True)
    exported.sort(key=lambda s:(s['archive'].lower(),s['name'].lower()))
    formats=collections.Counter()
    for e in exported: formats.update({int(k):v for k,v in e['formats'].items()})
    summary=dict(defs_found=len(jobs),defs_exported=len(exported),frames=sum(e['frame_count'] for e in exported),groups=sum(e['group_count'] for e in exported),sheet_pages=sum(len(g['pages']) for e in exported for g in e['groups']),errors=len(errors),formats=dict(formats),elapsed_seconds=round(time.time()-started,1))
    manifest=dict(source=str(SOURCE),archives=archives,summary=summary,assets=exported,errors=errors,preview_fps=10,preview_fps_is_original=False,notes=['All .lod archives recursively inventoried; every .def exported, including static interface DEFs.','Indexed PNGs preserve exact palette indices and RGB palette; DEFs preserve the full source representation.','Preview transparency/shadows are an interpretation. Indexed PNGs carry no tRNS chunk.','No original per-frame timing is stored in the parsed DEF structure. Player recoloring, palette cycling, dynamic effects and engine-generated mirroring are not baked into previews.','Source is this installed Ubisoft copy. Historical retail-byte authenticity is not independently established.'])
    dump(ROOT/'manifest.json',manifest)
    (ROOT/'catalog.js').write_text('window.H3_CATALOG='+json.dumps(manifest,ensure_ascii=False,separators=(',',':'))+';',encoding='utf-8')
    print(json.dumps(summary),flush=True)
    if errors: raise SystemExit(1)

if __name__=='__main__': main()
