# Heroes III original sound effects — Ubisoft copy

Extracted from the user's installed **Heroes of Might and Magic III Complete Edition** and published as an unpacked reference collection at the user's explicit request on October 20, 2026.

The collection covers every entry in both installed sound banks:

| Source archive | Entries |
| --- | ---: |
| `en/Data/Heroes3.snd` | 1,115 |
| `Data/H3ab_ahd.snd` | 117 |
| **Total** | **1,232** |

- Open [index.html](index.html) in a browser to search original filenames, filter by bank/duration, inspect waveforms and play sounds.
- [originals/](originals/) contains the exact archived WAV bytes, including original IMA ADPCM compression, RIFF chunks and sample-length metadata. Source filenames keep their original case; `.wav` is appended to extensionless sound-bank names.
- [preview-pcm/](preview-pcm/) contains decoded 16-bit PCM WAVs for convenient playback. Original sample rate and channel layout are preserved. Decoder block padding is trimmed to the original WAV `fact` sample-frame count; no normalization, resampling, remixing or added processing is applied.
- [manifest.json](manifest.json) records every archive entry, byte offset, size, archive/resource hashes, WAV format, duration, PCM hashes, decoder versions, waveform peaks and duplicate-name information.
- [catalog.csv](catalog.csv) provides a compact sortable catalog.
- [verification.json](verification.json) records archive-slice equality, unchanged source bank hashes, WAV structure checks and decoded PCM roundtrip checks for every sound.

The original bank identity is retained for every entry, including duplicate names and duplicate contents. The collection does not guess which bank the game prefers or silently merge duplicate names. Browser previews play the decoded copies; the original compressed WAVs remain the preservation masters. The waveform is only a visual peak summary.

This is the installed SND sound-bank collection. Standalone soundtrack/music-directory MP3s and cutscene audio are outside its scope. Standalone audio filenames and sizes are inventoried in the manifest to make that boundary explicit. Historical retail-byte authenticity and subjective in-game audio behavior are not independently established.

The `.gdignore` marker keeps the reference collection out of Godot's asset import scan. These third-party reference assets are not approved Laema production sounds or a gameplay change. Original audio remains attributable to its respective rights holders; the source installation was not modified.

To reproduce extraction, install [requirements.txt](requirements.txt), then run `python extract.py --source "INSTALLATION_DIRECTORY"`. Output is written beside the script. The source directory is read-only. [VCMI's SND archive reader](https://github.com/vcmi/vcmi/blob/develop/lib/filesystem/CArchiveLoader.cpp) documents the archive layout; decoding uses SoundFile/libsndfile.
