# Magic VFX inventory — source inspection, 20 October 2026

Art-only production scratch. No runtime import, implementation, gameplay edit or acceptance is implied.

| Current need | Source-backed implemented representation | Art scope/status |
|---|---|---|
| Fire, Water, Air, Earth Cast actor motion | Shared 10-frame Craftpix Casting Spell actor sheet; school-specific native clips retain their own pacing | Actor motion belongs to separate player-animation chat. Detached local cast accents here are proposals. |
| One combined flying projectile | `scenes/combat/spell_projectile.tscn`: 24×18 polygon, radius-12 collision. `scripts/combat/spell_projectile.gd`: primary color blended with optional secondary by resolved levels | Four original travel loops proposed as visual candidates. No collision, movement, range or speed change. |
| Successful impact | `MagicComponent._apply_equipped_spell`: generic damage per primary/optional secondary layer; applied negative Health result shows school and level. Projectile disappears at first valid Entity contact | Small detached impact one-shots are visual proposals; their exact trigger requires integration review. Do not play a successful-hit cue for a blocked/parried/missed layer. |
| Levels 1–8; empowered primary | Existing payload resolves primary and optional secondary levels; empowered multiplier belongs to primary | No eight-step size ladder, extra spell list or new intensity tier inferred. One base treatment per school. |
| Mixed Cast presentation | One projectile, primary/secondary color interpolation weighted by resolved levels | Do not spawn two flying objects or independently stack school shots. Proposed colored/textured candidates are not drop-in support for the current single blended polygon. A neutral tintable alternative remains open. |
| Generating / Charging / charged | Ten storage slots; up to eight charged; HUD owns existing queue/progress presentation | No new orb sprites, orb behavior, counting cues or character animation in this packet. |
| Guard warning / defence | Fire parry and Water block; near-break VFX warning specified. Air/Earth defence deferred | Existing warning meaning is retained; no defence redesign or new school-defence asset proposed here. |
| Persistent school effects | No active generic Cast dispatch to specialty resolvers | No burn loop, freeze shell, lightning chain, Earth field, lingering area, status icon or duration authored. |

## Current versus historical

Current GDD sections Prototype scope, Mixed-School Resolution, Prototype School-and-Level Cast Feedback and Casting Projectile preserve all four schools. The October 19 Fire-only sword benchmark and Fire/Earth actor-sheet swap did not delete the other schools. Current shared-character baseline removed the Gym-only restriction. Historical Fire X1–X5 GIFs, one/three/five-orb studies and older specialty descriptions do not define today's spell inventory.

The GDD explicitly defers Fire DoT, Water Wet/Slow/Frozen, Air Heat/chain lightning and Earth area/Slow. TDR Generic projectile impact and feedback and Configuration confirm that retained school configuration/resolvers are dormant. Their files and Portal controls are not permission to restore them.

## Existing imported artwork — preserved, not reused in generated output

`assets/README.md` identifies membership Fantasy Platformer Fire/Water/Ice sequences and user-confirmed entitlement; source redistribution is restricted. `scripts/enemy/enemy.gd` has a legacy effect-applied callback and frame counts Fire 10, Water 11, Ice 13. Its Fire path responds to fire_dot; its Water path responds to water_status, then Ice for frozen. The active generic Cast does not issue those instructions. Inspected `fire/fire1.png`, `water/water6.png`, `ice/ice6.png`: tiny flame/splash and ice-spike shapes on padded cells. Not current school-level spell bindings and not four-school production coverage.

## Original reference observations — not spell-name claims

Root: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/`.

| Pointer | Metadata | Observed sheet content / progression |
|---|---|---|
| C01SPF0 | 61×99 cells; group 0; 12 frames | Slender red curled ribbons with narrow pale pink-white highlights. Shape loops and folds; no broad orange cloud. |
| C01SPW0 | 43×123 cells; group 0; 20 frames | Gold chalice, concentrated bright highlights and falling star-like sparkles; stippled build and dissolve. This is not evidence for a blue Water projectile. |
| C01SPA0 | 88×81 cells; group 0; 15 frames | Shield emblem surrounded by tight white moving strands; stippled entry/exit. White edges and grey interior differ from broad bloom. |
| C01SPE0 | 98×95 cells; group 0; 20 frames | Grey smoky sphere with a bright inner figure/symbol; fades through stippling. Not a brown Earth projectile. |

Each inspected file is `group_00_block_00_page_00.png` plus `metadata.json`. Palettes retained in sibling `palette.rgb`; the visual observations above describe rendered palette progression, not palette cycling or inferred original timing. Original indexed sheets and DEF masters remain authoritative preservation sources. No source art is copied into generated effect pixels. The collection README distinguishes Ubisoft extraction from the earlier external collection. No original-game import/distribution authorization is inferred.

## Scene references and validation boundary

1280×720 selected framing05; feet y610; intended body about180px. `town-edge-yard-assets-v02/HANDOFF.md` and `town-edge-yard-framing-round-02/mockup-05.png` in the existing Art scratch root were read/viewed. The preview uses that unchanged static mockup as a readability backdrop. It includes provisional old actor representations and HUD; those are not effect exports or the separate new player flipbook.

Accepted hammer gameplay-scale concept was inspected at `docs/art/references/2026-10-19-laema-hammer-accepted/02-laema-hammer-gameplay-scale.png`; it guides scale/material restraint and establishes no final weapon lock. No character or weapon repaint is included here.

Source reads: `AGENTS.md`, `docs/README.md`, `docs/departments/Art.md`, `docs/art/ART_DIRECTION.md`, relevant current GDD/TDR/Implementation Status sections, `scripts/combat/magic_component.gd`, `scripts/combat/spell_projectile.gd`, `scripts/prototype/prototype_arena.gd`, `scripts/enemy/enemy.gd`, projectile scene and assets README. The tree was already dirty; unrelated work was preserved. Source inspection establishes bindings, not Godot playback.
