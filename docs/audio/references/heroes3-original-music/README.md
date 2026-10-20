# Heroes III original music — Ubisoft copy

Collected from the user's installed **Heroes of Might and Magic III Complete Edition** and published as an unpacked reference collection at the user's explicit request on October 20, 2026.

The collection preserves all **57 installed MP3 music files**, including short music cues, and the embedded **`Default.xmi`** sequenced resource found in `en/Data/H3bitmap.lod`. All four installed LOD archives were checked for music entries. Source filenames, spelling and capitalization are preserved.

- Open [index.html](index.html) in a browser to search, play, pause, seek and loop original tracks.
- [originals/mp3/](originals/mp3/) contains the installed music files, byte-for-byte.
- [originals/embedded/H3bitmap/Default.xmi](originals/embedded/H3bitmap/Default.xmi) contains the exact decompressed legacy resource. No synthesized rendition was generated.
- [manifest.json](manifest.json) records original hashes, source paths, decoded durations, sample rates, channels, waveform peaks, decoder versions, legacy resources and the LOD inventory.
- [catalog.csv](catalog.csv) provides a sortable track catalog.
- [verification.json](verification.json) records source-byte equality, full-track decoding with SoundFile and FFmpeg, streamed/full decode agreement, source hashes and the playback payload check.

## One wrapped music file

The installed `BladeFWCampaign.mp3` is a one-entry SND container: a 52-byte directory/header followed by the MPEG audio. The complete installed file remains untouched in `originals/mp3/`. Its audio is also saved in [playback-extracted/BladeFWCampaign.mp3](playback-extracted/BladeFWCampaign.mp3), exactly matching that original file's payload slice, so browsers can play it reliably. Both hashes and the wrapper directory are recorded. This extraction does not re-encode audio.

The other 56 tracks play directly from the preserved originals. No normalization, resampling, remixing or added effects are applied. Decoding is used only for verification, durations and cached waveforms. Some legacy MP3 headers report estimated lengths; metadata records estimated and actual decoded frames. SoundFile and FFmpeg can differ by a padding frame, so their frame counts and decoded hashes are recorded separately rather than claiming exact agreement between decoders. Streamed verification is limited to the actual full-decode frame count, excluding zeros padded to an estimated length. Browser durations may likewise vary slightly.

These are the music resources present in this installed copy. Cutscene video/audio and the SND sound-effect banks are separate collections. Historical retail-byte authenticity, original composition/mastering sources and in-game music behavior are not independently established.

The `.gdignore` marker excludes this reference collection from Godot imports. These third-party reference files are not approved Laema production music or a gameplay change. Original audio remains attributable to its respective rights holders; the installation was read-only throughout collection.

To reproduce, install [requirements.txt](requirements.txt) and run `python extract.py --source "INSTALLATION_DIRECTORY"`. Output is written beside the script. [VCMI's archive reader](https://github.com/vcmi/vcmi/blob/develop/lib/filesystem/CArchiveLoader.cpp) provides the LOD/SND layout reference.
