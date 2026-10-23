# Necropolis v01 — offline asset handoff

Status: **asset production and asset-only validation complete; human motion
acceptance remains open**. Full independent and isolated Godot 4.7.1 checks passed.
Consult `PRODUCTION_STATUS.json`, `inventory.json` and the actual validation reports;
remote publication is verified separately, not inferred from this document.
The approved scope is 14 creatures / 228 original groups / 1,378 timeline positions /
856 registered source-pose signatures. Appearance approval is not motion acceptance.

## Obtain a complete checkout before disconnecting

The intended publication repository is `https://github.com/czhou2822/Laema`, branch
`codex/necropolis-creature-assets`, with a subsequent validated asset-only merge to
`main`. Do not assume a production folder has been uploaded merely because this
document exists. A final publication record must identify and verify both remote
commit references. The earlier appearance package is already frozen at
`72bfc2853ac4258391be6a3c905b62328cac53ee`.

Once the complete package is published, use a normal complete Git clone, not a
sparse checkout or selected browser downloads:

```sh
git clone --branch codex/necropolis-creature-assets https://github.com/czhou2822/Laema.git Laema-necropolis-review
cd Laema-necropolis-review
git rev-parse HEAD
git status --short
```

An existing checkout may fetch the approved published revision only after its own
dirty-tree review. Do not reset, stash or discard unrelated work to obtain assets.
Keep the baseline commit reachable: independent validation checks its Git blobs.

## Install and verify prerequisites while online

- Python 3.12 and Pillow 12.3.0. The default prepare/ingest/build/check path uses
  Pillow only; the scripts do not download packages automatically.
- Optionally NumPy 2.3.5 and SciPy 1.17.0 for strict Castle-style component isolation.
  This is only needed when ingesting separate figures whose page layout needs it.
  Missing optional libraries are reported, not silently approximated.
- A local browser for the HTTP viewer. No CDN or web account is used.
- Godot 4.7.x for isolated texture/resource validation. The production host has
  actually exercised a task-local official 4.7.1 binary; availability elsewhere
  must be checked rather than assumed.
- Git, with the referenced original appearance commit and ordinary files present.

Use a private virtual environment rather than changing system/game dependencies:

```sh
python -m venv ../Laema-necropolis-tools
# Windows PowerShell (environment is outside the Git checkout):
& ../Laema-necropolis-tools/Scripts/python.exe -m pip install -r tools/art/requirements-necropolis.txt
# Unix uses ../Laema-necropolis-tools/bin/python instead.
```

For optional isolation, install `requirements-necropolis-components.txt` into the
same private environment, or use an explicitly supplied `--dependency-path` overlay.
If this environment must be rebuilt fully offline, download compatible wheels for
the intended OS/Python beforehand and verify an installation with network disabled.
No wheel cache, Godot binary or private host environment is promised by the Git repo.
Below, `python` means this prepared environment's executable. Use its full path if
it is not activated; changing the host's script-execution policy is unnecessary.
Confirm the actual interpreter and library before disconnecting:

```sh
python -c "import sys, PIL; print(sys.version); print(PIL.__version__)"
```

## Retained files and authority

| Location | Purpose |
|---|---|
| `docs/art/references/heroes3-original-flipbooks/` | Original DEF/indexed bytes, extraction metadata and interpreted RGBA references; immutable source poses/order. |
| `docs/art/production/necropolis-creature-assets-v01/` | Frozen published appearance masters and their original provenance. |
| `docs/art/remasters/necropolis-v01/master-approval.json` | Exact approved appearance hashes; no implied motion acceptance. |
| `generation-plan.json` in this directory | All source signatures, occurrences, coordinates, aliases and source ordering. |
| `assets/prototype/enemy/<creature_id>/remaster_v01/` | Selected registered poses, group atlases, exact mirrors, frames, GIFs, contacts and editor libraries. |
| Each creature's `_source/` | Exact prompts, raw output attempts, guides, isolated figures, submission records and superseded selections. |
| `creatures/<creature_id>/` here | Worker verification, actual observations, repairs, provenance and explicit review limits. |
| `tools/art/` | Portable packing, indexing, independent verification and isolated Godot checks. |
| `validation/` here | Mechanical, browser and engine evidence; partial/failed attempts remain distinguishable. |

Raw/pose/frame working folders are **Godot-ignored but Git-tracked**. Keep them for
offline repair and provenance. Generated reinterpretations are not originals and
are not final Laema creature decisions. Original game artwork remains third-party
material; this workflow establishes no commercial-use/redistribution entitlement.

## Review without the network

From the complete checkout, using the prepared Python environment:

```sh
python tools/art/necropolis_review.py
python -m http.server 8000 --bind 127.0.0.1 --directory docs/art/remasters/necropolis-v01/preview-bundle
```

Open `http://127.0.0.1:8000/index.html`. Serve only the art bundle, not an unrelated
home/project root. The bundle includes exact-byte, hash-named copies of required
images and `file-map.json` maps them back to their checkout-relative originals.

Choose creature, original group and source/mirrored facing. Inspect play/pause,
previous/next frame, zoom and dark/light/checker mattes. Original and candidate
advance synchronously. The viewer does not substitute original pixels or idle for
missing candidate artwork. Turns and angled actions retain their source facing;
“original orientation” does not mean uniformly right-facing.

Each cell is 1024×768, four columns, target anchor `(512,512)`, source reference
`(196,268)`, shared scale `180/73`. Original body bounds use alpha >160 to exclude
decoded palette shadows. Registered art keeps aspect ratio and source placement;
crouching/flying/dying drawings are not independently normalized to standing height.

Review speed is **10 fps provisionally**, not recovered original timing or an
accepted gameplay clock. Only movement and idle loop in the editor resources.

## Validate or repack retained artwork

```sh
python tools/art/necropolis_remaster.py inspect skeleton
python tools/art/necropolis_remaster.py build all
python tools/art/necropolis_remaster.py validate all
python tools/art/necropolis_remaster.py spriteframes all
python tools/art/validate_necropolis.py
python tools/art/necropolis_lineup.py
python tools/art/necropolis_review.py
```

`build` reconstructs registration from retained isolated high-resolution figures,
then all group occurrences, mirrors and previews. It does not draw. A rebuild that
changes a reviewed pose invalidates the stale review hash; inspect the change
before marking that pose reviewed again. Partial coverage is a validation failure,
not a successful final package.

For a separately available Godot binary and task-local fixture location:

```sh
python tools/art/necropolis_engine_validation.py --godot /path/to/godot --fixture-root /path/to/scratch/necropolis-fixtures
```

The isolated project copies only atlases and libraries, imports losslessly with
mipmaps disabled, and loads each source/mirrored animation resource. It does not
load the game, actors, addons, AI or encounters. A `--pilot` result is explicitly
partial. `--copy-import-descriptors` is allowed only after successful full validation.
Resource loading is not gameplay, rendered-motion acceptance or a full-game test.

## Evidence and acceptance remain separate

1. Mechanical checks: coverage, signatures, source order, repeats/aliases, raw
   registration, mirrors, padding, atlas/frame equality and preview duration.
2. Artist review: actual anatomy, identity, materials, grips/weapons, feet/wings,
   phase/death content and transitions. Count equality cannot establish these.
3. Browser/engine evidence: only the groups and controls actually exercised in
   recorded runs; do not extrapolate a pilot to the whole collection.
4. Human motion acceptance: a separate user decision. Approved appearance masters
   and a successful import do not establish this.

Retained artwork can be reviewed and repacked offline. **New offline drawing needs
a separately available local art workflow.** No local model, weights, seed,
deterministic cloud regeneration or offline image-generation service is promised.
See `CONTINUE_OFFLINE.md` for exact continuation and repair boundaries.
