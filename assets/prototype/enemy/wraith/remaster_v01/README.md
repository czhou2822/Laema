# Wraith original-pose remaster v01

Complete asset candidate: **57 poses, 18 original groups, 102 timeline positions**, with exact horizontal mirrors. All selected art is newly drawn through built-in imagegen. Appearance approval is not human animation acceptance.

- `source_manifest.json`: source identity, occurrence order, geometry, exact aliases, selected provenance and worker review hashes.
- `group_*.png`: four-column transparent atlases, source and mirror files.
- `frames/`: all 102 source and 102 mirrored timeline PNGs.
- `previews/`: 36 GIFs at 10fps review speed; original timing unknown.
- `contacts/`: original-above-candidate source-order comparisons.
- `poses/`: registered individual poses, exact mirrors and selection records.
- `_source/`: original-reference guides, unmodified raw attempts, exact prompts, isolated artwork and superseded selection history. Reference enlargements are not deliverable artwork.
- `original_groups.tres`, `original_groups_mirrored.tres`: complete preview-only libraries, without gameplay assignments.

The report and machine-readable per-pose/group evidence are in `docs/art/remasters/necropolis-v01/creatures/wraith/` from the checkout root. No browser/Godot/runtime or human playback acceptance is claimed.

## Repack existing artwork locally

Run from the complete checkout with Python and Pillow available:

```text
python -B tools/art/necropolis_remaster.py build wraith
python -B tools/art/necropolis_remaster.py validate wraith
python -B tools/art/necropolis_remaster.py spriteframes wraith
python -B tools/art/necropolis_remaster.py validate wraith
```

The shared generation plan and native reference sheets must remain at their recorded relative paths. Repacking uses retained isolated PNGs and does not require new image generation or the optional SciPy component-ingestion overlay. New artwork requires an available approved drawing workflow; no local model/weights or deterministic offline reproduction of cloud artwork is included. Parent coordination assembles and publishes the portable project package.
