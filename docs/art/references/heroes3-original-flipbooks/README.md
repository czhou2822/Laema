# Heroes III original flipbooks — Ubisoft copy

Fresh extraction from the user's installed **Heroes of Might and Magic III Complete Edition**, retained in this repository at the user's explicit request on October 20, 2026. This is a separate extraction from the earlier `Heroes3-original-sprites` collection referenced in the Art Direction record.

**2,912 DEF resources · 39,939 frames · 6,050 groups · 4,233 groups with multiple frames.** All four installed LOD archives were inventoried; every DEF was extracted from `en/Data/H3sprite.lod` and `en/Data/H3ab_spr.lod`. Both bitmap archives contained no DEF resources.

- Open [index.html](index.html) in a browser to search, play, pause and scrub sequences, inspect original palette colors, or open PNG sheets.
- [sprites/](sprites/) contains native-resolution transparent PNG sheets, lossless indexed preservation sheets, original RGB palettes, and per-resource frame/group metadata.
- [originals/](originals/) contains the exact decompressed DEF, MSK and PAL resource bytes, separated by source archive.
- [manifest.json](manifest.json) records coverage, source archive hashes, sequence metadata and extraction limits.
- [verification.json](verification.json) records the second decoder's agreement with all 39,939 frames, the indexed export checks, and unchanged source archive hashes.
- [README.txt](README.txt) explains encoding, canvas placement, transparency treatment and scope. [contact-sheet.png](contact-sheet.png) provides a static sample.

The original ZIP's 25,439 files were unpacked and checked byte-for-byte before this publication. The repository adds only this overview, scoped Git attributes and `.gdignore`; Godot excludes the collection from its asset import scan.

The DEFs and indexed PNGs are the preservation masters. Preview transparency/shadows and the adjustable playback speed are interpretations; the files do not establish original engine timing, player recoloring, palette cycling or generated mirroring. Standalone PCX backgrounds, cutscene video and audio are outside this DEF extraction. Historical retail-byte authenticity has not been independently established.

These are third-party reference assets, not approved Laema production artwork or a gameplay change. Original artwork remains attributable to its respective rights holders. No game executable was modified.
