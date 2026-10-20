# DUM-E handoff — Fire VFX, 20 October 2026

The user viewed the mini/full side-by-side animation, said **“okay hand over to dum-e”**, then explicitly added **“have him implement the level 3 fire ball as well”**. The selected visual mappings are now **Level1 Fire = mini** and **Level3 Fire = full Fireball**. This authorizes both implementation requests and their handoff; it does not supply an exact multi-file plan, engine/test permission, publication permission or additional spell behavior. Keep existing DUM-E scope/approval gates; prepare the smallest concrete plan from current source before any uncovered multi-file edit.

## User-directed visual result

Use original Heroes III **Level 3 Fireball** as visual inspiration for a **mini fireball for Laema Level 1 Fire magic**. The earlier Magic Arrow direction was superseded. The user then requested the original full Fireball and a Laema adaptation, reviewed both adaptations side by side, and explicitly requested implementation of **Level3 Fireball as well**. Level3 mapping is now confirmed by that user instruction, not inferred from the source game. No area, extra target count, persistent effect or new damage behavior is assigned.

Implementation scope is **Level1 Fire mini presentation plus Level3 Fireball presentation**. Diagnose current bindings and prepare their exact integration plan. The full packet contains a burst only; do not silently treat it as a sustained flight loop or invent an unrelated Level3 travel design. Identify any genuinely missing artwork before dependent work. Earlier four-school draft folders are not selected by this handoff.

## Assets and review pointers

All paths below are relative to this packet, in the live main Laema checkout. Read `INVENTORY.md`, both asset READMEs and manifests, and open actual preview PNGs/GIFs before proposing import.

| Asset | Transparent export | Fixed geometry | Playback intent / proposed visible scale |
|---|---|---|---|
| Level 1 Fire travel | `mini-fireball-level1-v01/travel-strip.png`; individual `travel/00.png`–`07.png` | 1024×128 strip;8 cells128×128; pivot(64,64) |8-frame loop; approximately32px body. |
| Level 1 Fire impact | `mini-fireball-level1-v01/impact-strip.png`; individual `impact/00.png`–`08.png` |1152×128 strip;9 cells128×128; pivot(64,64) | One-shot;8 generated poses plus transparent endpoint; peak52×47px. |
| Level3 Fireball burst | `full-fireball-v01/burst-strip.png`; individual `burst/00.png`–`16.png` |4352×256 strip;17 cells256×256; pivot(128,128) | One-shot;16 generated poses plus transparent endpoint; peak about105px. User-assigned to Level3 Fire. |

`mini-versus-full.gif` is the side-by-side the user reviewed. It aligns peaks and briefly shows mini travel before impact; that alignment is a comparison edit, not action timing. `mini-versus-full-peak.png` is its static peak. Each asset folder includes `gameplay-scale.gif`, `contact-dark-light.png`, exact prompts, master PNG and manifest. Use the PNGs, not GIFs or baked scene composites, as asset candidates.

## Source, scene and checks

Principal original reference: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/C13SPF/`,13 frames in142×155 cells. Its rendered sheet/metadata and the alternative C13SPF0 were inspected; only C13SPF was attached to the original generation calls. Original reference pixels and source-referenced generated adaptations have separate provenance in the READMEs/manifests. Original-source authority is not blanket runtime import permission. Do not import original Heroes reference sheets as substitutes.

Scene target:1280×720, approximately180px standing body, feet y610 and compact lower HUD. Preview backdrops contain provisional static actors and do not represent the separate in-progress player flipbook. Preserve all existing identities, source changes and other chats' work.

Actually checked: PNG decoding, strip/cell dimensions, output hashes, frame-order/adjacent-pose review, alpha on light/dark mattes, source/export cell margins, growth/breakup/transparent endpoints and static scene peaks. Both selected atlases have zero source-cell edge pixels above alpha8. Full atlas initially had crossing wisps; the selected repair is recorded. Generated motion remains subject to user judgment; no engine playback, controller acceptance or scenario coverage is established.

## Integration constraints and unresolved items

- Read current `AGENTS.md`, Git status and relevant diffs, current GDD/TDR/status, then trace the active projectile/impact path. These art files remain scratch under an ancestor `.gdignore`; copy only selected transparent exports into an approved runtime folder as part of the exact plan.
- Current Casting is generic direct damage for primary and optional secondary layers; one combined projectile uses resolved-level-weighted school color. Do not change damage, Impact, collision, travel distance/speed, target selection, Cast/launch timings, orb transactions, action durations or school rules to fit these previews.
- Colored fire art does **not** settle how to preserve existing mixed-school weighted blending. Diagnose the existing path. Do not silently drop the secondary color, add a second projectile or introduce a shader/component/lifecycle contract; surface any material architecture choice to Friday.
- Impact is a separate visual layer; preserve first-hit/expiry behavior and distinguish projectile contact from successful damage. Do not imply successful damage on blocked/parried/missed layers. Use the current accepted result/feedback contract, with any missing trigger decision stated explicitly.
- All90ms preview steps, frame holds and side-by-side alignment are illustrative. They do not authorize retiming gameplay or imply original Heroes timing.
- No burn/DoT, persistent field, area damage, extra status or inferred intensity ladder is supplied. Only Fire Level1 and Level3 visual mappings are selected; preserve other levels and keep Air/Water/Earth present and unchanged.
- Synchronize any affected canonical technical/presentation records only within the user's exact approved scope; retain obligations rather than claiming closure from imported artwork.

No runtime imports, gameplay/scenes/runtime-script edits, Godot/builds/tests, commit or push were performed by this Art chat. The handoff transfers recoverable art and known limits; it is not implementation or runtime completion.
