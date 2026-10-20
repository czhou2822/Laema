"""Preserve installed Heroes III music bytes, decode MP3s for verification only.

Install requirements.txt and run with --source INSTALLATION_DIRECTORY.
Optional --decoder-tools DIRECTORY adds an existing temporary dependency folder.
LOD layout reference:
https://github.com/vcmi/vcmi/blob/develop/lib/filesystem/CArchiveLoader.cpp
"""
from pathlib import Path
import argparse,sys,struct,zlib,hashlib,json,collections,csv,io,subprocess,wave

ROOT=Path(__file__).resolve().parent
DEFAULT_SOURCE=r'C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Heroes of Might and Magic 3 Complete Edition'
SUFFIXES={'.mp3','.ogg','.flac','.mid','.midi','.xmi','.hmi','.hmp','.mus'}

def sha(b):return hashlib.sha256(b).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,ensure_ascii=False,indent=2),encoding='utf-8',newline='\n')
def preserve(path,b):
    path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(b)
    assert path.read_bytes()==b

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source',type=Path,default=Path(DEFAULT_SOURCE))
    parser.add_argument('--decoder-tools',type=Path)
    parser.add_argument('--ffmpeg-tools',type=Path)
    args=parser.parse_args()
    if args.decoder_tools:sys.path.insert(0,str(args.decoder_tools))
    if args.ffmpeg_tools:sys.path.insert(0,str(args.ffmpeg_tools))
    import soundfile as sf
    import imageio_ffmpeg
    import numpy as np
    ffmpeg=imageio_ffmpeg.get_ffmpeg_exe()
    ffmpeg_version=subprocess.check_output([ffmpeg,'-version'],text=True).splitlines()[0]
    source=args.source.resolve();tracks=[];legacy=[];archives=[];errors=[];standalone_inventory=[]
    files=sorted(p for p in source.rglob('*') if p.is_file() and p.suffix.lower() in SUFFIXES)
    for p in files:
        rel=p.relative_to(source);b=p.read_bytes();target=ROOT/'originals'/rel
        preserve(target,b)
        item=dict(name=p.name,source=rel.as_posix(),original=target.relative_to(ROOT).as_posix(),bytes=len(b),sha256=sha(b))
        standalone_inventory.append(dict(source=rel.as_posix(),bytes=len(b),sha256=sha(b)))
        if p.suffix.lower() in ('.mp3','.ogg','.flac'):
            try:
                playable=b;playback=target
                # One installed .mp3 is actually a one-entry SND container.
                if len(b)>=52 and int.from_bytes(b[:4],'little')==1:
                    wrapper_name,po,ps=struct.unpack_from('<40sII',b,4)
                    assert po==52 and po+ps==len(b) and b[po]==255 and b[po+1]&224==224
                    playable=b[po:po+ps];playback=ROOT/'playback-extracted'/p.name;preserve(playback,playable)
                    item['container']=dict(type='single-entry SND wrapper',entry_name=wrapper_name.split(b'\0')[0].decode('cp1252'),directory_name_bytes_hex=wrapper_name.hex(),payload_offset=po,payload_bytes=ps,payload_sha256=sha(playable))
                item.update(playback=playback.relative_to(ROOT).as_posix(),playback_sha256=sha(playable))
                info=sf.info(io.BytesIO(playable))
                samples,rate=sf.read(io.BytesIO(playable),dtype='int16',always_2d=True)
                assert len(samples)>0 and rate==info.samplerate and samples.shape[1]==info.channels
                frames=len(samples);edges=np.linspace(0,frames,257,dtype=np.int64)
                amplitude=np.max(np.abs(samples.astype(np.int32)),axis=1)
                peaks=[round(float(amplitude[a:max(a+1,b)].max())/32768,5) for a,b in zip(edges[:-1],edges[1:]) if a<frames]
                pcm_bytes=samples.astype('<i2',copy=False).tobytes()
                # A streamed second decode must produce the same samples and frame count.
                h=hashlib.sha256();stream_frames=0
                with sf.SoundFile(io.BytesIO(playable)) as stream:
                    for block in stream.blocks(blocksize=32768,dtype='int16',always_2d=True):
                        # Block reads can pad to a legacy header's estimated length.
                        # Verify only the actual frames returned by the full decode.
                        block=block[:max(0,frames-stream_frames)]
                        if not len(block):break
                        h.update(block.astype('<i2',copy=False).tobytes());stream_frames+=len(block)
                assert stream_frames==frames and h.hexdigest()==sha(pcm_bytes)
                second=subprocess.run([ffmpeg,'-v','error','-i',str(playback),'-vn','-c:a','pcm_s16le','-f','wav','pipe:1'],capture_output=True)
                assert second.returncode==0 and not second.stderr,second.stderr.decode('utf-8','replace')
                with wave.open(io.BytesIO(second.stdout),'rb') as decoded:
                    assert decoded.getnchannels()==info.channels and decoded.getframerate()==rate
                    second_pcm=decoded.readframes(decoded.getnframes())
                second_frames=len(second_pcm)//(2*info.channels)
                assert second_frames>0
                item.update(format=info.format,subtype=info.subtype,sample_rate=rate,channels=info.channels,header_estimated_sample_frames=info.frames,decoded_sample_frames=frames,duration_seconds=frames/rate,decoded_pcm_sha256=sha(pcm_bytes),ffmpeg_decoded_sample_frames=second_frames,ffmpeg_frame_delta=second_frames-frames,ffmpeg_decoded_pcm_sha256=sha(second_pcm),waveform=peaks)
                tracks.append(item)
                print(f'Decoded and verified {p.name}: {frames/rate:.3f} s',flush=True)
            except Exception as exc:
                errors.append(dict(source=rel.as_posix(),error=repr(exc)));print('ERROR',errors[-1],flush=True)
        else:
            item.update(playback_supported=False,header_hex=b[:16].hex(),note='Preserved sequenced resource; no synthesized or rendered audio was generated')
            legacy.append(item)
        assert sha(p.read_bytes())==item['sha256']
    for ap in sorted(source.rglob('*.lod')):
        data=ap.read_bytes();count=int.from_bytes(data[8:12],'little')
        assert data[:4]==b'LOD\0' and 92+count*32<=len(data)
        ar=dict(source=ap.relative_to(source).as_posix(),bytes=len(data),sha256=sha(data),entries=count,music_entries=0)
        for i in range(count):
            raw_name,offset,size,unknown,packed=struct.unpack_from('<16sIIII',data,92+i*32)
            name=raw_name.split(b'\0')[0].decode('ascii')
            if Path(name).suffix.lower() not in SUFFIXES:continue
            assert Path(name).name==name and '/' not in name and '\\' not in name
            assert offset+(packed or size)<=len(data)
            b=data[offset:offset+(packed or size)]
            if packed:b=zlib.decompress(b)
            assert len(b)==size
            target=ROOT/'originals'/'embedded'/ap.stem/name;preserve(target,b)
            legacy.append(dict(name=name,source=ar['source']+'::'+name,original=target.relative_to(ROOT).as_posix(),bytes=size,sha256=sha(b),archive=ar['source'],directory_index=i,directory_name_bytes_hex=raw_name.hex(),offset=offset,compressed_bytes=packed,unknown=unknown,playback_supported=False,header_hex=b[:16].hex(),note='Embedded sequenced resource preserved; no synthesized or rendered audio was generated'))
            ar['music_entries']+=1
        assert sha(ap.read_bytes())==ar['sha256'];archives.append(ar)
    assert tracks,'No playable music found'
    summary=dict(playable_tracks=len(tracks),legacy_sequenced_resources=len(legacy),original_files=len(tracks)+len(legacy),unwrapped_playback_payloads=sum('container' in a for a in tracks),unique_track_hashes=len({a['sha256'] for a in tracks}),total_duration_seconds=round(sum(a['duration_seconds'] for a in tracks),3),original_bytes=sum(a['bytes'] for a in tracks+legacy),sample_rates=dict(collections.Counter(a['sample_rate'] for a in tracks)),channels=dict(collections.Counter(a['channels'] for a in tracks)),decoder_frame_deltas=dict(collections.Counter(a['ffmpeg_frame_delta'] for a in tracks)),errors=len(errors))
    manifest=dict(source_installation='Ubisoft Heroes of Might and Magic 3 Complete Edition',source_paths_relative_to_installation=True,summary=summary,decoder=dict(python_soundfile=sf.__version__,libsndfile=sf.__libsndfile_version__,ffmpeg=ffmpeg_version,decode_purpose='Integrity checks and cached waveform only; playback uses original MPEG bytes, unwrapped when needed',duration_policy='Decoded SoundFile sample frames divided by sample rate; browser/FFmpeg durations can differ slightly with MP3 padding interpretation. Both decoder frame counts and hashes are retained.',normalization_resampling_reencoding=False),tracks=tracks,legacy_resources=legacy,standalone_inventory=standalone_inventory,lod_archives_checked=archives,errors=errors)
    dump(ROOT/'manifest.json',manifest)
    (ROOT/'catalog.js').write_text('window.H3_MUSIC='+json.dumps(manifest,ensure_ascii=False,separators=(',',':'))+';',encoding='utf-8',newline='\n')
    with (ROOT/'catalog.csv').open('w',encoding='utf-8',newline='') as f:
        writer=csv.DictWriter(f,fieldnames=['name','source','duration_seconds','sample_rate','channels','bytes','sha256','original','playback'],extrasaction='ignore');writer.writeheader();writer.writerows(tracks)
    dump(ROOT/'verification.json',dict(original_files_byte_verified=len(tracks)+len(legacy),playable_tracks_fully_decoded=len(tracks),streamed_pcm_decode_matches=len(tracks),streamed_decode_sample_limit='Actual full-decode frames; exclude zeros from legacy length estimates',ffmpeg_full_decode_verified=len(tracks),ffmpeg_had_no_error_diagnostics=True,unwrapped_payloads_byte_verified=sum('container' in a for a in tracks),source_file_and_lod_hashes_unchanged=True,legacy_bytes_preserved=True,no_audio_reencoding=True,errors=errors))
    print(json.dumps(summary),flush=True)
    if errors:raise SystemExit(1)

if __name__=='__main__':main()
