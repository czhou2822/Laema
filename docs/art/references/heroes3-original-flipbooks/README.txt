HEROES III — UBISOFT ORIGINAL FLIPBOOKS

Open index.html in a browser to search and play every extracted animation group.
Keep the complete folder together. The viewer needs no internet or installation.

SOURCE
C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\games\Heroes of Might and Magic 3 Complete Edition

All .lod files beneath this installation were inventoried, including both bitmap
archives. Every .def animation/static-sprite resource was extracted. This is a
fresh extraction of this installation; no earlier collection was substituted.
The installation is read-only throughout this process.

FILES
- originals/<archive>/: byte-preserved decompressed DEF, MSK and PAL resources.
- sprites/<archive>/<DEF name>/metadata.json: source frame names/order, group IDs,
  frame offsets, compression modes, canvas sizes, signed margins and pixel hashes.
- palette.rgb: all 256 original RGB colors, 768 bytes in palette-index order.
- *_indexed.png: lossless indexed PNG sheets, with original RGB palette and exact
  indices. No transparency chunk; special colors remain visible for preservation.
- Other group PNGs: convenient transparent RGBA sheets at native resolution.
- manifest.json: totals, archive SHA-256 hashes, source provenance and any errors.
- archive-inventory.json: every LOD directory entry, not just sprite entries.
- extract.py: reproducible archive/DEF extraction and preservation verification.

PRESERVATION AND VERIFICATION
Every decoded frame is checked for the expected pixel count. Every indexed sheet
is reopened and each stored frame crop is compared with its decoded pixel hash.
Original DEFs preserve the exact decompressed resource bytes, including headers,
palettes, duplicate frame references and legacy data. Archive SHA-256 hashes are
recorded; those hashes identify this installed copy, not an independently verified
historical retail release. The original LOD archives remain at the source path.

Frame cells preserve the original canvas and margins. When a stored image extends
outside its declared canvas, the sheet cell expands and metadata records its
origin; source pixels are not clipped. Group and frame numbering are source IDs
and zero-based indexes. Static interface DEFs are included to avoid omissions.

TRANSPARENT PREVIEW LIMITS
The indexed PNGs and DEFs are the preservation masters. RGBA previews interpret
index 0 as transparent. For types 0x40-0x45 and 0x49, indices 1/2/3/4 become black
with alpha 64/128/192/128. Creature type 0x42 additionally hides selection index 5
and treats indices 6/7 as shadow alpha 128/64. This is a documented viewing
approximation, not a claim that every asset is composed exactly as in the engine.
Choose Original palette to inspect the preserved colors without that conversion.
Player recoloring, palette cycling, dynamic effects and engine-generated mirroring
are not baked into these exports. No repainting, AI recreation or upscaling occurs.

TIMING
The parsed DEF format contains frame sequences but no per-frame playback times.
The viewer defaults to an adjustable 10 fps; this is preview timing, not original
game timing. Group IDs are retained without guessing action labels.

SCOPE
This covers all DEF flipbook/sprite resources in this installation. Standalone PCX
backgrounds, audio, SMK/cutscene video and executable-generated visual states are
different resource types and are not represented as original DEF flipbooks here.
All resource types are accounted for in archive-inventory.json.

FORMAT REFERENCES
https://github.com/vcmi/vcmi/blob/develop/lib/filesystem/CArchiveLoader.cpp
https://github.com/vcmi/vcmi/blob/develop/client/render/CDefFile.cpp
The extractor independently implements the documented binary layouts.
Original game artwork remains the property of its respective rights holders.

COMPLETED EXTRACTION
2,912 DEF files; 39,939 frames; 6,050 groups; 6,054 sheet pages per format.
4,233 groups have multiple frames. Every source DEF was decoded with zero errors.
The independent verifier checked all 39,939 frames and confirmed source LOD hashes
were unchanged. There are 2,901 distinct DEF byte hashes; archive duplicates are
retained with provenance. Twelve legacy-header frames were decoded successfully.

VIEWER
Search, group selection, playback/pause, magnification and background changes were
checked in Microsoft Edge. Fit subject removes unused canvas margins consistently
across each group; Original canvas shows the complete preserved frame cell.
The PNG sheets always keep original canvas placement regardless of viewer crop.
