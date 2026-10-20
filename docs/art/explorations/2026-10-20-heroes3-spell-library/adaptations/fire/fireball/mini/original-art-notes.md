# Level 1 Fire — mini fireball candidate

User direction, 20 October 2026: use Heroes III Level 3 Fireball as inspiration for a mini fireball for Level 1 Fire. This supersedes the earlier Magic Arrow shape/color study. The artwork is a proposal for that requested direction; final visual acceptance is pending.

## Review

- `gameplay-scale.gif`: animated art composite at 1280×720. Static existing framing05 backdrop with provisional actors; about180px standing-body target and feet y610. No new player animation is represented.
- `travel-dark-light.gif`: native-scale loop on dark/light mattes.
- `impact-dark-light.gif`: native-scale burst on dark/light mattes; preview repeats after the transparent endpoint, while the asset is a one-shot.
- `travel-2x-inspection.gif`: nearest-neighbor enlarged travel loop.
- `contact-dark-light.png`: all sixteen generated poses at proposed native size, dark/light comparison.

## Transparent outputs and geometry

| Layer | PNG strip | Cells | Pivot per cell | Playback intent |
|---|---|---|---|---|
| Travel | `travel-strip.png`, 1024×128 | 8 × 128×128 | (64,64) | Loop until existing hit/expiry; do not alter projectile travel/collision. |
| Impact | `impact-strip.png`, 1152×128 | 9 × 128×128 | (64,64) | One-shot; 8 generated poses plus one transparent export endpoint. |

Individual RGBA PNGs are under `travel/` and `impact/`. Keep fixed cells and pivots; do not trim frames independently. Visible travel widths are31–33px; visible travel heights29–33px. Peak impact footprint is52×47px, a presentation footprint with no implied damage/area radius. Artwork sits inside larger transparent cells. All GIF timing is illustrative at90ms per authored review frame; repeated identical hold frames may be merged by GIF encoding. No original-game or accepted action timing is asserted. Do not retime the Cast action, launch marker, speed or lifetime to fit these previews.

## Original source versus generated artwork

Principal visual input: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/C13SPF/group_00_block_00_page_00.png`, with sibling metadata and indexed preservation sheet. It is13 source frames in142×155 cells, source DEF SHA-256 `251b03415e8dd334c350a728b6ee1b901fdfc55b96b5b149d3dc5b596f6e297a`. Original pixels remain in the reference collection. `C13SPF0` was also inspected:19 frames in119×151 cells; it was not attached to the generation call. These are separate resources, not interchangeable frame sets.

Name mapping is cross-checked with VCMI `config/spells/offensive.json`, whose fireball entry uses C13SPF as its hit animation: https://github.com/vcmi/vcmi/blob/develop/config/spells/offensive.json . The Heroes III original manual lists Fireball under Fire Level III. This mapping identifies the artistic reference; it imports no Heroes III mechanics.

Observed source qualities: rounded mottled flame volume, concentrated pale ignition, orange turbulent body, holes opening into fragments. The generated mini adapts those qualities with red-orange edges and a restrained bright center. The original source is a burst; the8-frame sustained flight treatment is generated adaptation, not an extracted original Fireball flight animation.

`generated-master.png` is the unmodified built-in image_gen result, generated filename `exec-f97fdde5-a8a0-4142-a644-cc95ae62736b.png`. `prompt.txt` preserves the exact prompt and the manifest identifies the attached source. Mechanical exports normalize the atlas grid, reduce its cells uniformly, and pad to128×128; no character/background/UI is baked into the transparent PNGs. Generated source-informed art and original-game references retain separate provenance; no licensing/redistribution clearance is claimed.

## Visual check and DUM-E / U handoff boundary

All16 source cells and native exports were examined together in temporal frame order on light/dark mattes. Native source-cell edge counts above alpha8 are zero; exported frames have safe margins. Adjacent travel frames retain a compact round silhouette, with changing flame texture and minor size variation; these are generated poses, not a simulated/advection-verified fire flow. Loop seam and surface flicker still need user motion review. Impact grows once, opens holes, reduces to fragments and embers, then reaches an explicit transparent frame. No large smoke/glow layer survives. Peak in the selected scene keeps target head/feet, above-target feedback and lower HUD legible. A static peak/frame-order check is not engine playback or human acceptance.

Candidate integration target: current generic Fire projectile presentation only. A separate impact cue is proposed visual art and needs its accepted success-trigger mapping; do not display successful-hit effects for blocked/parried/missed damage layers. Mixed-school color blending remains an integration question: these colored fireball frames are not a verified replacement for the current weighted blended polygon. No independent secondary projectile, intensity ladder, persistent burn, area, defence effect or new spell behavior is supplied. No cast aura or actor motion is included.

No engine import, gameplay/scenes/runtime scripts, Godot, tests, commit or push. No other chat was messaged. `manifest.json` records dimensions, alpha bounds and output hashes. The ancestor `.gdignore` excludes this scratch packet from Godot import.
