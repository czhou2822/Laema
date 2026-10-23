# Castle remaster asset packing

`castle_remaster.py` prepares original-pose references and packs independently drawn high-resolution artwork into source-ordered group atlases. It does not generate or enlarge original pixel art as a deliverable. Artwork was drawn with imagegen; existing high-resolution candidates are identified separately in each source manifest.

Requires Python 3 and Pillow. The optional `--components` isolation path also requires NumPy and SciPy.

```sh
python tools/art/castle_remaster.py prepare griffin
python tools/art/castle_remaster.py ingest griffin 0 /path/to/generated.png --components
python tools/art/castle_remaster.py build griffin
python tools/art/castle_remaster.py validate griffin
python tools/art/castle_remaster.py spriteframes all
```

`--root`, `--plan` and `--work` override locations. The repository is inferred from the script; the default plan is `docs/art/remasters/castle-v01/generation-plan.json`; scratch references default to the system temporary directory.

Generation guides use up to eight poses in a four-column grid. `--adaptive-grid` finds nearby clear gutters. `--components` isolates complete foreground figures that cross nominal grid cells; it rejects ambiguous large-component counts and actual clipping at the outer image edge. Raw pages and isolated artwork are retained with hashes. A single identity pose can be imported with `--cols 1 --rows 1 --pose-ids griffin_p025` and a distinct batch number.

Registration version 2 measures opaque original body pixels (alpha greater than 160), excluding original palette shadows. One uniform original-coordinate transform per creature preserves frame positions relative to its idle foot anchor. Artwork aspect-fits those registered body bounds without stretching. `build` always registers from the original generated page, isolated source, or existing high-resolution source; it does not resize a previously resized output.

Each source group receives its own four-column RGBA PNG, including exact aliases, and preserves every original frame position. `source_manifest.json` records source identities, frame order, body bounds, artwork provenance, hashes, geometry and coverage. `validate` checks atlas cells and padding against registered pose files. Coverage and technical registration do not certify exact visual parity or recovered original timing.

`original_groups.tres` is an editor preview SpriteFrames resource with every original group. Its 10 fps speed is explicitly provisional. Only groups 0 and 2 loop. These preview resources do not assign gameplay states or replace the existing native animation clocks.
