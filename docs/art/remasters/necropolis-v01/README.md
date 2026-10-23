# Necropolis original-pose remasters — v01

Status: **complete worker-reviewed asset candidate; independent and isolated Godot
validation passed. Human motion acceptance remains open.**

The user approved the 14 published masters as **appearance references**, then
authorized producing all original flipbooks, asset-only validation, uploading the
complete package and merging the asset result into main. Appearance approval is
not animation acceptance. No new actors, AI, encounters or gameplay are included.

## Sources and deliverables

- Master baseline: `72bfc2853ac4258391be6a3c905b62328cac53ee`, preserved unchanged at
  `../../production/necropolis-creature-assets-v01/`; approval hashes are in
  [master-approval.json](master-approval.json).
- Original DEF/indexed/RGBA metadata: `../../references/heroes3-original-flipbooks/`.
- [Generation plan](generation-plan.json): **14 creatures, 228 original groups,
  1,378 timeline positions and 856 registered source-pose signatures**. It retains
  every source occurrence, original coordinates, aliases and repeated cells.
- [Current inventory](inventory.json), [CSV](inventory.csv), [worker status](PRODUCTION_STATUS.json)
  and [comparison viewer](preview.html). Missing artwork stays explicitly missing.
- Standing/appearance scale comparisons: [lineup one](standing-lineup-01.png),
  [lineup two](standing-lineup-02.png), [pixel/placement record](standing-lineup.json).
  These retain unresized registered pixels beside the frozen approved Pikeman
  benchmark; initial candidate presence does not establish animation acceptance.
- New files go to `assets/prototype/enemy/<creature_id>/remaster_v01/`, using
  underscore-separated creature IDs; original published master slugs use hyphens.
- Packing tool: `tools/art/necropolis_remaster.py`; viewer-index builder:
  `tools/art/necropolis_review.py`. Both infer the checkout root from their location.

The mechanical workflow follows the pinned Castle tool/handoff at
`f6d2c8ec38568597a72090dd3a6045117cbf8be7`. Castle's actor integration and its
smaller output geometry are **not** copied into this asset-only task.

## Frozen original inventory

These counts describe original groups and registered pose signatures, not new
abilities or human-accepted animations. Every repeated timeline position remains.

| Creature | Original groups | Source positions | Registered poses |
|---|---:|---:|---:|
| Skeleton | 15 | 86 | 57 |
| Skeleton Warrior | 15 | 86 | 57 |
| Walking Dead | 15 | 86 | 60 |
| Zombie | 15 | 86 | 60 |
| Wight | 18 | 102 | 57 |
| Wraith | 18 | 102 | 57 |
| Vampire | 15 | 90 | 56 |
| Vampire Lord | 18 | 111 | 62 |
| Lich | 18 | 120 | 74 |
| Power Lich | 18 | 120 | 74 |
| Black Knight | 15 | 92 | 58 |
| Dread Knight | 18 | 125 | 62 |
| Bone Dragon | 15 | 84 | 61 |
| Ghost Dragon | 15 | 88 | 61 |
| Total | 228 | 1,378 | 856 |

Final source-plus-mirror exports are 456 group atlases, 1,712 registered pose PNGs,
2,756 ordered frame PNGs, 456 review GIFs, 228 source/candidate contacts and 28
SpriteFrames libraries. Additional guides, raw attempts and review images remain
retained. Wight/Wraith ranged-numbered groups are exact original melee aliases,
not new ranged actions. Group labels are interpretations, not gameplay mappings.

## Registration and provenance

Four-column **1024×768 RGBA cells**, anchor **(512,512)**, original reference
**(196,268)** and shared scale **180/73**. Body rectangles are measured from opaque
original pixels (**alpha >160**) to exclude decoded palette shadows. New artwork
aspect-fits those source rectangles without stretching; source-coordinate placement
is preserved. Do not normalize crouching, flight or death to standing height.

Actual new drawings use the built-in image tool, not original-pixel enlargement.
Masters supply appearance only; original poses supply action, direction, grips,
wings and feet. Raw attempts, exact prompts, guides, isolated figures and previous
selection provenance remain in `_source/`, which is Godot-ignored, not Git-ignored.
Original game artwork remains third-party reference material; no commercial-use
or redistribution entitlement has been established by this generation work.

All original groups retain independent atlas files, even exact aliases. Mirrors
reflect each frame, not the whole atlas layout. Frame PNGs, GIF reviews, contacts
and both source/mirror SpriteFrames libraries cover every original group.
Preview playback is **10fps review only**; original timing is unknown.
Only movement and idle loop in editor libraries; none are gameplay state mappings.

## Local review

Build the self-contained art-only bundle, then serve only that folder:

```sh
python tools/art/necropolis_review.py
python -m http.server 8000 --bind 127.0.0.1 --directory docs/art/remasters/necropolis-v01/preview-bundle
```

Open `http://127.0.0.1:8000/index.html`. See [Offline handoff](OFFLINE_HANDOFF.md)
and [Continuation](CONTINUE_OFFLINE.md) for prerequisites and exact commands.

Existing artwork can be reviewed and repacked offline. New offline drawing needs
an actually available local art workflow; this package promises no offline model,
weights, seed or deterministic reproduction of cloud generation.

## Actual verification and limits

- [Independent QA](validation/independent-asset-qa.json): all 228 groups / 1,378
  original positions / 856 registered mirror pairs, plus 2,756 decoded logical GIF
  positions; zero missing poses or errors. All 652 frozen master-package files match.
- [Isolated Godot 4.7.1](validation/engine/validation-summary.json): all 456 textures
  imported losslessly with mipmaps off; 28 actual native libraries / 456 mirrored
  and source group instances / 2,756 frame regions loaded, zero errors.
- [Parent visual/control review](validation/collection-review.json) and
  [observations](validation/PARENT_REVIEW.md): all 14 worker static-sequence passes,
  parent sampled comparisons and actual browser controls for all 228 groups.
  Release gates additionally require current atlas hashes for browser evidence.
- [Retained release gates](validation/release-gates.json) and `payload-sha256.json`
  record the final offline package after assembly. Remote publication is verified
  separately; file existence alone is not a publication receipt.

These are generated reinterpretations, not original sprites or final Laema art.
Human motion acceptance, exact original timing, actor integration and full-game
playtesting remain separate. Fine surface/contour variations and the Ghost Dragon
dither-to-continuous-alpha interpretation are documented, not hidden.
