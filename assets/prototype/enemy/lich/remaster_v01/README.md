# Base Lich remaster v01

Complete **worker-reviewed candidate** coverage: 74 newly drawn poses, 18 original CLICH groups and 120 timeline positions, with exact mirrors. Human animation acceptance and engine checks are pending with the parent operation.

- `source_manifest.json`: source order, repeated positions, native occurrence pointers, geometry, coverage and selected artwork provenance.
- `group_*_block_*.png` / `*_mirror.png`: independent source/mirror atlases, four columns of 1024×768 cells.
- `frames/source/` and `frames/mirror/`: 120 frame PNGs per facing.
- `previews/`: 36 GIFs; 10fps review timing only, not original timing.
- `contacts/`: 18 full source-ordered original/candidate comparisons.
- `original_groups.tres` and `original_groups_mirrored.tres`: 18-group preview libraries; no actor/state mapping or verified Godot import.
- `_source/`: byte-exact raw pages, exact prompts, guides, isolated inputs, old selections and static review diagnostics. Preserve these for offline repacking and repairs.

From the complete repository root, existing isolated artwork can be repacked offline using Python and Pillow:

```text
python -B tools/art/necropolis_remaster.py build lich
python -B tools/art/necropolis_remaster.py validate lich
python -B tools/art/necropolis_remaster.py spriteframes lich
python -B tools/art/necropolis_remaster.py validate lich
```

Keep the repository generation plan and original reference tree at their existing relative paths. Build uses the preserved isolated images; NumPy/SciPy is needed only for optional strict component re-ingestion of raw pages. No offline drawing model, weights, deterministic generation seed or replacement for the built-in image tool is supplied.

Production report and per-pose/group evidence: `docs/art/remasters/necropolis-v01/creatures/lich/production-report.md` and `visual-review.json`. The parent owns the combined portable package and publication.
