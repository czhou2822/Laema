# Castle remasters — offline handoff

Main integration amendment, October 24: the user authorized merging the Castle
candidate into main. Follow the current canonical records for main's 28-creature
catalog, upgrades/Necropolis controls, camera-authoring settings and tuning.
This package updates seven Castle base-actor bindings, not every current actor.
The original branch baseline and validation below remain historical/scoped;
publication or integration does not grant final visual/runtime acceptance.

Prepared 23 October 2026, Hong Kong time. This records the Castle asset task, not
an all-project checkpoint or restoration of other chat threads.

## Repository and publication

- Repository: https://github.com/czhou2822/Laema
- Publication branch: `codex/castle-remasters-2026-10-23`.
- Asset investigation/implementation baseline: `a41c900de771cea55e3c1819f1c77ff16d8101b5`.
- Publication also preserves the newer remote documentation through `d97c7280`:
  attack-feel guidance and the independent HoMM3 art-pipeline research.
- Resolve the exact Castle handoff commit with:

  ```sh
  git log -1 --format=%H -- docs/art/remasters/castle-v01/OFFLINE_HANDOFF.md
  ```

The user requested committing and publishing this candidate. That request is not
human visual acceptance or certification of original HoMM3 timing. Publishing the
source branch does not export or replace the hosted Godot game.

## Goal and current state

Every original HoMM3 Castle flipbook must have a high-resolution counterpart,
including base and upgraded creatures, with original frame order, repeated poses,
registration and animation coverage. Reuse suitable existing high-resolution
artwork. The user subsequently authorized generating missing artwork directly
from OG pose references. Generated artwork must not be described as recovered
masters or as enlarged OG pixels.

**Asset coverage is complete: 14 creatures, 225 groups, 1,324 frame positions.**
There are 847 distinct registered poses: 633 newly painted and 214 reused from
existing high-resolution sheets. Every original group has its own PNG, including
exact aliases. Original artistic/timing parity and all gameplay integration are
not complete.

| Creature | OG DEF | Groups | Frame positions | New / reused poses |
| --- | --- | ---: | ---: | ---: |
| Pikeman | CPKMAN | 13 | 80 | 25 / 25 |
| Halberdier | chalbd | 13 | 67 | 50 / 0 |
| Archer | CLCBOW | 18 | 100 | 40 / 37 |
| Marksman | CHCBOW | 18 | 101 | 75 / 0 |
| Griffin | CGRIFF | 15 | 91 | 27 / 26 |
| Royal Griffin | Crgrif | 15 | 91 | 53 / 0 |
| Swordsman | Csword | 15 | 80 | 22 / 32 |
| Crusader | Ccrusd | 15 | 80 | 54 / 0 |
| Monk | Cmonkk | 17 | 113 | 25 / 27 |
| Zealot | Czealt | 20 | 154 | 69 / 0 |
| Cavalier | CCAVLR | 15 | 87 | 36 / 37 |
| Champion | CCHAMP | 15 | 87 | 73 / 0 |
| Angel | cangel | 18 | 98 | 27 / 30 |
| Archangel | CRANGL | 18 | 95 | 57 / 0 |
| **Total** | | **225** | **1,324** | **633 / 214** |

Phases 1, 3 and 4 have inventory/gap-analysis/report artifacts. Phase 2 establishes
source groups, counts, order, aliases and original coordinates; original timing
remains unresolved. Phase 5 supplies all candidate artwork/group assets and
updates the seven existing gameplay creatures. Final art review, matching-version
gameplay checks and the unsupported upgraded actors/special states remain open.

## Files to read and preserve

Read repository `AGENTS.md`, `docs/GAME_DESIGN.md`, `docs/TECH_ARCHITECTURE.md` and
`docs/IMPLEMENTATION_STATUS.md` first. Paths below are relative to the checkout;
the files travel with Git and do not require the earlier cloud workspace.

- [Current report](README.md), [inventory CSV](inventory.csv),
  [inventory JSON](inventory.json), [comparison viewer](preview.html).
- [Full original-to-pose plan](generation-plan.json): all 225 group identities,
  every source occurrence, aliases, original signatures and reuse references.
- `docs/art/references/heroes3-original-flipbooks/`: original DEF files, indexed
  master sheets, decoded reference sheets and extraction metadata. Preserve these.
- `assets/prototype/enemy/<creature_id>/remaster_v01/`: the completed assets.
  IDs are `pikeman`, `halberdier`, `archer`, `marksman`, `griffin`,
  `royal_griffin`, `swordsman`, `crusader`, `monk`, `zealot`, `cavalier`,
  `champion`, `angel`, `archangel`.
- Each folder contains `group_XX_block_YY.png`, matching Godot `.import`
  descriptors, `original_groups.tres`, `source_manifest.json`, registered
  `poses/` and retained `_source/` artwork/provenance. The two source folders are
  Godot-ignored, not Git-ignored; keep them when copying or cloning.
- Exact drawing prompts, guide references and generated source hashes are in
  `_source/*.prompt.txt` and/or each creature's provenance JSON. Some early
  prompts were not retained verbatim; the raw artwork and pose registration were.
  Do not reconstruct a missing seed/model/workflow and call it original evidence.
- [Portable tool and usage](../../../../tools/art/README.md),
  `tools/art/castle_remaster.py`.
- [Original audit snapshot](../../reviews/2026-10-23-castle-animation-parity-audit/README.md)
  and its Phase 2/5 follow-up are historical evidence, not the current coverage count.

The independently published `Research AI Art Pipeline for HoMM3/` folder contains
controlled restoration/frame-edit experiments, limitations and a local research
prompt. Preserve that separate work. Its conclusions are not approval to replace
this candidate or proof that a particular local generation workflow has run.

## Actual gameplay integration

Pikeman, Archer, Griffin, Swordsman, Monk, Cavalier and Angel use the new group
textures in their real reusable enemy scenes/controllers. The Gym and Final Arena
load those actors through the existing creature catalog.

- Groups 0/2/3/5 supply movement/idle/hurt/death.
- Group 12 supplies front melee; Archer and Monk also use group 15 for shooting.
- The 37 actual visual bindings use the existing Sprite2D state playback and nine
  native `config/attack_animations/*.tres` resources.
- Seven scenes, four Pikeman texture defaults and nine attack resources changed.
  Behavior, collision, settings, attack duration, markers and hitbox curves were
  preserved. Practice targets retain their separate visuals.
- Pikeman group12 has source order `[0,1,2,3,4,5,4,3,2,1]`. At 0.8/0.9 seconds,
  the native resource now addresses physical cells8/9, containing source poses2/1.
  Do not reintroduce the earlier incorrect recovery drawings.
- Seven upgraded variants currently have assets, not gameplay actors. Additional
  original turn/angle/special slots have no new execution states. Do not invent
  abilities, stats, flying movement or encounters to consume them.
- Angel/Archangel groups14–16 are original melee aliases, not shooting abilities.

## Registration and generation limits

Four-column RGBA sheets use 768×512 cells for Pikeman and 768×640 for the others,
with target anchor `(384,448)`. Existing actor scale/offset conventions remain.
Registration version 2 measures opaque original body bounds (alpha greater than
160), excluding palette shadows, and uses a shared original-coordinate transform.
Generated/reused crops aspect-fit their registered source body rectangles. This
technical alignment does not prove identical anatomy, grip, silhouette or motion.

Rebuild from retained raw generated/isolated artwork or the original high-res
reuse source. Never enlarge an already packed output or turn OG pixel enlargement
into a claimed remaster. Preserve all source aliases/repeated pose references.
The final Griffin frontal turn correction is included in groups7/8/9/10.

DEF metadata supplies no frame durations. The original Castle CrAnim rows and
executable timing have not been recovered. `original_groups.tres` uses explicitly
provisional 10 fps editor previews; the actual gameplay clocks remain unchanged.
Do not infer original dwell/loop behavior from the preview settings.

New drawings were made with the available image-generation tool, not a recorded
local Qwen/ControlNet workflow. No deterministic regeneration, model weights,
seed record or fully offline drawing backend is promised by this handoff.

## Validation already performed

- [Independent QA](validation/independent-asset-qa.json): all 14 original DEFs and
  1,324 indexed source crops rehashed; 225 groups, 847 registered poses,
  38 alias pairs, 332 padding cells, 37 bindings and 17 integration files checked;
  zero errors. All 14 idle designs plus 28 death and 14 turn samples inspected.
- [Engine summary](validation/engine/validation-summary.json): installed Godot
  4.6.3 loaded all 14 native SpriteFrames libraries, 225 groups and 1,324 cells;
  zero final art import, parse or load failures. All 225 PNG imports are lossless
  with mipmaps disabled.
- Seven real selected/configured Gym actors: 392 state-frame and 168 private
  attack-key samples across both facings; nine native attack marker/duration/key
  times preserved. These are agent-run sampled-state checks, not a human playtest.
- [Viewer checks](validation/viewer/results.json): all 225 group comparisons loaded
  in Chromium with nonempty original/remaster canvases and no page errors.

Project Godot 4.7 was unavailable. The pre-existing Godot 4.6
`ObjectiveWidget.custom_maximum_size` UI API error and unrelated editor/exit
warnings remain recorded. Human visual acceptance, contact alignment, natural
transition review, original timing and final balance are still open. Do not mark
them passed because publication or technical checks succeeded.

## Prepare the local copy before disconnecting

For a fresh checkout while online:

```sh
git clone --single-branch --branch codex/castle-remasters-2026-10-23 https://github.com/czhou2822/Laema.git Laema-Castle
cd Laema-Castle
git status --short
```

For an existing checkout, inspect `git status` first and preserve local work.
Fetch the publication branch, then switch/create a local tracking branch only
when doing so will not overwrite changes. Do not automatically reset, stash,
clean, rebase unrelated work or invoke the separate checkpoint-load workflow.

Copy the complete checkout rather than just the Markdown files. Git includes
the PNGs, sources, original references, manifests, tools and engine resources;
the handoff alone does not contain those binaries. This repository is large.
Have compatible Godot/LimboAI binaries and any Python dependencies installed
before losing network access. Current packing dependencies were Python 3 with
Pillow 12.3.0; component isolation also used NumPy 2.3.5 and SciPy 1.17.0.

Existing assets can be reviewed and packed offline. Cloud image generation cannot
run offline. New drawings require an already installed local workflow or manual
artwork; inspect actual local tools/hardware before assuming one is available.

From the checkout root, these optional checks require no network:

```sh
python tools/art/castle_remaster.py validate all
python -m http.server 8000 --bind 127.0.0.1
```

Open `http://127.0.0.1:8000/docs/art/remasters/castle-v01/preview.html` in a browser.
The 10 fps control is for comparison only. Use the saved engine evidence first;
repeat only relevant checks when artwork or bindings change.

## Resume point

Paste [CONTINUE_OFFLINE.md](CONTINUE_OFFLINE.md) into the local coding assistant.
Start with original-versus-remaster visual/playback review on the local machine,
preserving all 225 counterparts and their provenance. Correct specific rejected
poses in small increments; rebuild every group sharing that pose. Keep fresh
trials separate from the archived originals. Additional gameplay actors/states
and new factions require their actual intended behavior to be settled first.
Do not regenerate the whole Castle roster merely to restart this task.
