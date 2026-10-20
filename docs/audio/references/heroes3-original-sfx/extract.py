"""Extract all installed HoMM3 SND entries, preserve WAV bytes, decode previews.

Install requirements.txt, then run with --source INSTALLATION_DIRECTORY.
An optional --decoder-tools DIRECTORY adds a temporary dependency directory.
Archive layout reference:
https://github.com/vcmi/vcmi/blob/develop/lib/filesystem/CArchiveLoader.cpp
"""
from pathlib import Path
import argparse, sys, struct, io, json, hashlib, collections, wave, csv

ROOT=Path(__file__).resolve().parent
DEFAULT_SOURCE=r'C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Heroes of Might and Magic 3 Complete Edition'

def sha(b):return hashlib.sha256(b).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8',newline='\n')

def parse_wave(b):
    assert b[:4]==b'RIFF' and b[8:12]==b'WAVE'
    assert int.from_bytes(b[4:8],'little')+8==len(b)
    q=12;chunks=[];info={}
    while q+8<=len(b):
        cid,size=struct.unpack_from('<4sI',b,q);start=q+8
        assert start+size<=len(b)
        chunks.append(dict(id=cid.decode('ascii'),offset=start,size=size))
        if cid==b'fmt ':
            fmt,channels,rate,byte_rate,align,bits=struct.unpack_from('<HHIIHH',b,start)
            info.update(format_tag=fmt,channels=channels,sample_rate=rate,byte_rate=byte_rate,block_align=align,bits_per_sample=bits)
            if size>=20:info['samples_per_block']=struct.unpack_from('<H',b,start+18)[0]
        elif cid==b'fact':info['fact_sample_frames']=struct.unpack_from('<I',b,start)[0]
        elif cid==b'data':info.update(data_offset=start,data_bytes=size)
        q=start+size+(size%2)
    assert q==len(b)
    assert info['format_tag']==17 and info['channels'] in (1,2)
    info['chunks']=chunks
    return info

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,default=Path(DEFAULT_SOURCE))
    parser.add_argument('--decoder-tools',type=Path)
    args=parser.parse_args()
    if args.decoder_tools:sys.path.insert(0,str(args.decoder_tools))
    import soundfile as sf
    import numpy as np
    source=args.source.resolve();assets=[];archives=[];errors=[];verified=0
    snds=sorted(p for p in source.rglob('*') if p.is_file() and p.suffix.lower()=='.snd')
    assert snds,'No SND archives found'
    for ap in snds:
        data=ap.read_bytes();count=int.from_bytes(data[:4],'little');directory_end=4+count*48
        assert directory_end<=len(data)
        bank=ap.stem;originals=ROOT/'originals'/bank;previews=ROOT/'preview-pcm'/bank
        originals.mkdir(parents=True,exist_ok=True);previews.mkdir(parents=True,exist_ok=True)
        archive=dict(path=ap.relative_to(source).as_posix(),bytes=len(data),sha256=sha(data),entry_count=count,bank=bank)
        archives.append(archive);names=set();spans=[]
        for i in range(count):
            try:
                raw_name,offset,size=struct.unpack_from('<40sII',data,4+i*48)
                name=raw_name.split(b'\0')[0].decode('cp1252')
                assert name and Path(name).name==name and '/' not in name and '\\' not in name
                filename=name if name.lower().endswith('.wav') else name+'.wav'
                assert filename.lower() not in names,(ap.name,filename)
                names.add(filename.lower());assert offset>=directory_end and offset+size<=len(data)
                spans.append((offset,offset+size));b=data[offset:offset+size];info=parse_wave(b)
                original=originals/filename;original.write_bytes(b);assert original.read_bytes()==b
                pcm,rate=sf.read(io.BytesIO(b),dtype='int16',always_2d=True)
                assert rate==info['sample_rate'] and pcm.shape[1]==info['channels']
                decoded_frames=len(pcm);frames=info['fact_sample_frames']
                assert 0<frames<=decoded_frames,(filename,frames,decoded_frames)
                # IMA block padding is not part of the audible source length.
                pcm=pcm[:frames];pcm_bytes=pcm.astype('<i2',copy=False).tobytes()
                preview=previews/filename
                with wave.open(str(preview),'wb') as out:
                    out.setnchannels(info['channels']);out.setsampwidth(2);out.setframerate(rate);out.writeframes(pcm_bytes)
                with wave.open(str(preview),'rb') as check:
                    assert check.getparams()[:4]==(info['channels'],2,rate,frames)
                    assert check.readframes(frames)==pcm_bytes
                # Positive magnitude envelope preserves multichannel peaks for visualization.
                amplitude=np.max(np.abs(pcm.astype(np.int32)),axis=1)
                edges=np.linspace(0,len(pcm),193,dtype=np.int64)
                peaks=[round(float(amplitude[a:max(a+1,b)].max())/32768,5) for a,b in zip(edges[:-1],edges[1:]) if a<len(pcm)]
                entry=dict(name=filename,source_name=name,bank=bank,archive=archive['path'],directory_index=i,directory_name_bytes_hex=raw_name.hex(),offset=offset,bytes=size,sha256=sha(b),original=original.relative_to(ROOT).as_posix(),preview=preview.relative_to(ROOT).as_posix(),preview_sha256=sha(preview.read_bytes()),decoded_pcm_sha256=sha(pcm_bytes),decoded_frames_before_padding_trim=decoded_frames,trimmed_padding_frames=decoded_frames-frames,sample_frames=frames,duration_seconds=frames/rate,preview_bits_per_sample=16,peak_amplitude=round(float(amplitude.max())/32768,7),waveform=peaks,**info)
                assets.append(entry);verified+=1
            except Exception as exc:
                errors.append(dict(archive=archive['path'],index=i,error=repr(exc)))
                print('ERROR',errors[-1],flush=True)
        ordered=sorted(spans)
        assert all(a[1]<=b[0] for a,b in zip(ordered[:-1],ordered[1:])), 'Overlapping archive entries'
        assert sha(ap.read_bytes())==archive['sha256']
        print(f'{ap.name}: {count} entries processed; total verified={verified}; errors={len(errors)}',flush=True)
    assets.sort(key=lambda a:(a['bank'].lower(),a['name'].lower()))
    byname=collections.defaultdict(list)
    for a in assets:byname[a['name'].lower()].append(a)
    collisions=[dict(name=k,banks=[a['bank'] for a in v],identical_bytes=len({a['sha256'] for a in v})==1) for k,v in byname.items() if len(v)>1]
    omitted=[dict(path=p.relative_to(source).as_posix(),bytes=p.stat().st_size,reason='Standalone audio outside the SND sound-bank extraction') for p in sorted(source.rglob('*')) if p.is_file() and p.suffix.lower() in ('.mp3','.wav','.ogg','.flac','.aif','.aiff','.voc')]
    summary=dict(sound_bank_entries=sum(a['entry_count'] for a in archives),sounds_exported=len(assets),unique_original_hashes=len({a['sha256'] for a in assets}),channels=dict(collections.Counter(a['channels'] for a in assets)),total_duration_seconds=round(sum(a['duration_seconds'] for a in assets),3),original_bytes=sum(a['bytes'] for a in assets),preview_bytes=sum((ROOT/a['preview']).stat().st_size for a in assets),cross_archive_filename_collisions=len(collisions),errors=len(errors))
    manifest=dict(source_installation='Ubisoft Heroes of Might and Magic 3 Complete Edition',source_paths_relative_to_installation=True,archives=archives,summary=summary,decoder=dict(python_soundfile=sf.__version__,libsndfile=sf.__libsndfile_version__,preview_encoding='signed 16-bit little-endian PCM WAV',padding_policy='Trim decoded IMA block padding to the original fact chunk sample-frame count',sample_rate_and_channels_preserved=True,normalization_or_resampling=False),assets=assets,cross_archive_filename_collisions=collisions,standalone_audio_not_included=omitted,errors=errors)
    dump(ROOT/'manifest.json',manifest)
    (ROOT/'catalog.js').write_text('window.H3_SFX='+json.dumps(manifest,ensure_ascii=False,separators=(',',':'))+';',encoding='utf-8',newline='\n')
    with (ROOT/'catalog.csv').open('w',encoding='utf-8',newline='') as f:
        cols=['bank','name','duration_seconds','sample_rate','channels','sample_frames','bytes','sha256','original','preview']
        writer=csv.DictWriter(f,fieldnames=cols,extrasaction='ignore');writer.writeheader();writer.writerows(assets)
    report=dict(original_archive_slices_match=True,original_wav_files_verified=verified,pcm_preview_roundtrips_verified=verified,source_archive_hashes_unchanged=True,riff_structures_checked=True,fact_lengths_preserved=True,errors=errors)
    dump(ROOT/'verification.json',report)
    print(json.dumps(summary),flush=True)
    if errors:raise SystemExit(1)

if __name__=='__main__':main()
