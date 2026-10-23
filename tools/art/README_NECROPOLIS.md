# Necropolis original-pose remaster tools

These are mechanical asset tools, not an image-generation API or game controller.
The original DEF/indexed extraction is immutable. All newly painted artwork is
provided separately through the built-in image workflow and retains provenance.
Task-local `.gitattributes` disable text normalization so retained prompt/provenance
bytes and payload hashes survive checkouts on other operating systems.

## Requirements

- Python 3.12 and Pillow 12.3.0 were used on this Windows host.
- Optional strict component isolation additionally uses NumPy 2.3.5 and
  SciPy 1.17.0. Missing optional dependencies produce an explicit error. The default
  clear-gutter grid and individual-pose route needs Pillow only.
- Browser review needs a local HTTP server; no CDN, account or network image fetch
  is required. Godot checks need an available Godot 4.7.x binary.

The user separately approved installing SciPy into a **task-local overlay**, not
system Python or the game. No model weights or local image-generation backend were
installed. Optional overlay location is supplied with `--dependency-path`; it is
not hardcoded into the portable tool.

## Workflow

Run from any complete checkout; the script infers the root from its own file.
`--root` and `--plan` override inputs. Options before the subcommand are global.

```sh
python tools/art/necropolis_remaster.py inspect skeleton
python tools/art/necropolis_remaster.py prepare skeleton
python tools/art/necropolis_remaster.py guide skeleton --pose-ids skeleton_p000,skeleton_p001 --name repair-reference
python tools/art/necropolis_remaster.py ingest skeleton /path/to/raw.png --pose-ids skeleton_p000,skeleton_p001 --cols 2 --rows 1 --batch unique-attempt --prompt-file /path/to/exact-prompt.txt --adaptive-grid
```

For an approved, actually installed dependency overlay:

```sh
python tools/art/necropolis_remaster.py --dependency-path /path/to/python-deps ingest skeleton /path/to/raw.png --pose-ids skeleton_p000,skeleton_p001 --cols 2 --rows 1 --batch unique-components-attempt --prompt-file /path/to/exact-prompt.txt --components
```

Component extraction uses the pinned Castle algorithm: independent alpha figures,
strict figure counts, row-major assignment and preservation of antialias pixels.
It rejects ambiguous extra components and actual outer-edge clipping. It neither
paints nor recolors. Death fragments or native embedded effects may require one
whole reference cell rather than connected-component extraction. Wrong anatomy or
pose is not repaired by successful extraction: redraw the rejected pose.

Only after actual visual inspection of those specific poses:

```sh
python tools/art/necropolis_remaster.py review skeleton --pose-ids skeleton_p000,skeleton_p001 --note "Actual source-versus-candidate observations and limitations"
python tools/art/necropolis_remaster.py build skeleton
python tools/art/necropolis_remaster.py validate skeleton
python tools/art/necropolis_remaster.py spriteframes skeleton
python tools/art/necropolis_lineup.py
python tools/art/necropolis_review.py
python tools/art/validate_necropolis.py
```

`build` always re-registers from retained isolated high-resolution source artwork,
not a previously packed output. Repeated/aliased source poses share the same pose
file but retain all original frame occurrences. Mirrors reflect each cell, never
reverse the atlas's frame order. `validate` returns failure on incomplete coverage.

The fixed transform is 1024×768 cells / four columns / target anchor(512,512) /
original reference(196,268) / scale180/73. Original body bounds use alpha>160 to
exclude decoded palette shadows. Generated RGBA retains its own alpha and aspect
ratio. Do not stretch a pose or resize it independently to standing height.

## Resumption and review

`necropolis_lineup.py` makes two mechanical, unresized selected-idle comparison
sheets beside the unchanged registered Pikeman benchmark. It records actual input
hashes and retains common relative scale, rather than fitting every creature to a
card. Regenerate it after repairs; a complete idle lineup is not complete animation
coverage or human motion acceptance.

`prepare` skips supplied pose records; every raw attempt has a unique archive name,
prompt and submission map. A replacement preserves earlier provenance under
`_source/history/`. Inspect the current inventory and worker reports before resume;
presence or complete counts alone do not mean visual or human acceptance.

`necropolis_review.py` also assembles a self-contained **art-only preview bundle**.
It copies only allowlisted required images, deduplicated by SHA-256, and rewrites
viewer paths. Serve this folder rather than exposing the entire checkout:

```sh
python -m http.server 8000 --bind 127.0.0.1 --directory docs/art/remasters/necropolis-v01/preview-bundle
```

Open `http://127.0.0.1:8000/index.html`. Controls select creature/group, source or
mirrored orientation, playback/pause, previous/next frame, 10fps review speed,
zoom and matte. Original turn/angle slots retain their own orientation; do not call
them uniformly right-facing. Missing artwork is labeled, not replaced by OG pixels.

## Independent and engine checks

GIF verification expands stored review holds and independently compares every
logical source/mirror position with its half-size, palette-converted sprite
preview. This checks actual content/order, not duration alone, while keeping the
preview's quantization separate from the exact RGBA sprite/mirror checks.

The independent checker does not import the packing tool. It rehashes all original
indexed crops, checks source records/order/aliases, reproduces registration from raw
sources, checks mirrors/atlas/frame PNGs/padding/GIF durations and preserves all
652 files in the frozen master package against Git's original blob IDs.
`--allow-incomplete` permits inspecting a partial run but never marks it passed.
While other workers are still writing, `--creature skeleton --creature dread_knight`
checks only a finished subset. Its report says `collection_run=false` and
`full_coverage=false`; a successful subset is not a collection clearance.

```sh
python tools/art/necropolis_engine_validation.py --godot /path/to/godot --fixture-root /path/to/task-scratch/fixtures
```

Use `--pilot` only for explicitly partial smoke checks. It creates temporary
partial libraries in the fixture, not in the asset package. Full validation loads
the actual original/mirrored libraries. `--copy-import-descriptors` is only allowed
after a successful full run and writes only the validated texture `.import` files.
The fixture has no actors, addons or gameplay scripts. Child-process data/cache/log
paths are isolated; host Godot preferences and the actual game are not modified.

Godot's documented [self-contained editor mode](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#self-contained-mode)
was used for the task-local binary copy. Earlier failed/successful evidence remains
under validation attempts. Resource loading is not rendered gameplay or human
acceptance. All preview timing stays provisional; DEF extraction has no timings.

After complete independent QA, final engine validation and all-group browser
evidence, `python tools/art/necropolis_release.py` checks the retained release gates
and creates `payload-sha256.json`. It refuses partial collection evidence or stale
browser atlas hashes. It does not publish Git or establish human motion approval.
Run it again after any included report/tool/asset changes so the payload inventory
reflects the final retained bytes. Git publication and remote verification remain
separate explicit authorized operations.
