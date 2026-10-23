# Zealot prototype presentation

The user approved this Castle upgrade's actor/presentation binding on October23,
2026, alongside the 1–7 faction cycle and Shift+number base/upgrade toggle.
The actor inherits `monk.tscn` and its existing shared combat contract.
It retains the base actor's existing ranged and close-melee behavior, projectile and timing.
No original-game ability, flight, stat, AI, projectile artwork or new sound is added.

## Selected source

The PNGs in `highres_v01/` are byte-identical copies of the selected generated
Castle review collection, not original low-resolution sheets or rejected attempts.
`highres_v01/source-manifest.json` retains the portable collection paths,
source-index/creature-manifest digests, original group/block IDs, counts and
selected PNG hashes. Original frames, masters, prompts and raw attempts remain
in the separate Art collection; no source artwork was overwritten.

| Local sheet | Selected collection sheet | Group / block | Frames |
| --- | --- | --- | ---: |
| Walk.png | zealot/group_00_block_00/atlas_source.png | 0 / 0 | 6 |
| Idle.png | zealot/group_02_block_02/atlas_source.png | 2 / 2 | 6 |
| Hurt.png | zealot/group_03_block_03/atlas_source.png | 3 / 3 | 8 |
| Dead.png | zealot/group_05_block_05/atlas_source.png | 5 / 5 | 11 |
| Melee.png | zealot/group_12_block_11/atlas_source.png | 12 / 11 | 8 |
| Shoot.png | zealot/group_15_block_14/atlas_source.png | 15 / 14 | 14 |

Cells are768x640, four columns, anchor(384,448), scale1, offset(0,-128).
Facing reflection uses the existing Sprite2D owner. The inherited body, combat
settings, native attack markers, query geometry and restart lifecycle are unchanged.
Only the presentation frames are remapped to their own source sequence counts.
Unassigned inherited audio streams are null.

## Acceptance and rights

Static masters were approved as appearance references; these generated animations
remain prototype review candidates, not human-approved motion or final Laema art.
The collection's10fps previews are illustrative and do not establish original
or gameplay timing. Godot import, both facings, feet/ground contact, body/weapon
alignment, transitions and actual gameplay-speed playback require separate
validation. Original Heroes III references and generated reinterpretations retain
separate provenance; no source-game redistribution entitlement is established.
