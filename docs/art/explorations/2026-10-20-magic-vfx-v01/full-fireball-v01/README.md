# Full Fireball — Laema visual adaptation

Art adaptation requested20 October2026 after viewing the original Heroes III Fireball. After reviewing the mini/full comparison, the user explicitly requested DUM-E to implement **Level3 Fireball as well**. This full burst is now assigned to **Level3 Fire presentation**; preserve the separately requested Level1 mini. No additional damage, area, target count, timing or status behavior is assigned. Implementation/runtime validation remains pending.

The existing preview captions and generation prompts predate the later Level3 assignment. Their earlier unassigned-study wording is historical; the user's explicit instruction and `../HANDOFF-DUM-E.md` now control the visual mapping. Exact generation prompts are preserved unchanged.

## Review and transparent assets

- `gameplay-scale.gif`: burst composited into the selected1280×720 framing05 static review scene; illustrative90ms review steps. This is an art composite, not Godot footage.
- `mini-versus-full.png`: native-scale mini/full visual comparison; approximately32px mini versus105px full peak. Size is a presentation proposal, not collision/damage radius.
- `burst-dark-light.gif`: native-scale one-shot on light/dark mattes, repeated for review.
- `contact-dark-light.png`: all16 generated poses in temporal order on both mattes.
- `burst-strip.png`: transparent4352×256 PNG,17 horizontal256×256 cells. Pivot(128,128) in every cell. Frames0–15 are generated poses; frame16 is an explicit transparent mechanical endpoint. Playback intent is one-shot; the GIF repeats for review only.
- `burst/00.png` through `burst/16.png`: individual fixed-cell RGBA frames. Do not trim independently or shift pivots.
- `generated-master.png`: unmodified selected image_gen result; `manifest.json`: dimensions, bounds, alpha-edge counts and output hashes.

## Source and adaptation

Original reference: `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/C13SPF/group_00_block_00_page_00.png`, sibling metadata/indexed PNG and original DEF.13 extracted frames,142×155 source cells. DEF SHA-256 `251b03415e8dd334c350a728b6ee1b901fdfc55b96b5b149d3dc5b596f6e297a`. Name identity cross-check: VCMI `config/spells/offensive.json` Fireball hit binding uses C13SPF. Original-game references stay in their separate reference collection.

Built-in image_gen produced a source-referenced adaptation with rounded mottled flame volume, hot accents, red-orange outer body, opening holes and ember breakup. This is generated derivative artwork, not unmodified original pixels or a claim of exact original palette/motion. The first atlas (`exec-b86eef25-7197-4ad4-9b9d-8ca4e0976ddd.png`) had two cells with crossing wisps and was not selected. A targeted padding repair produced `exec-26e0955d-65d6-4a53-a563-057dabfca5ef.png`, the selected master. `prompt.txt` and `repair-prompt.txt` preserve exact prompts. No licensing/redistribution clearance is asserted.

## Visual review and integration boundary

All16 source cells and native exports were inspected in temporal order on light/dark mattes. The repaired source cells have zero edge pixels above alpha8, and padded exports retain clear margins. Footprints build from32×30 to a104×105 peak, then open holes, diminish into fragments and embers and finish transparent. No obvious matte fringe or broad opaque halo is visible in the checked contact sheet. Generated flame texture changes and the near-peak pose transition still need user motion judgment; frame-order inspection is not engine playback.

The scene peak covers the target's torso while leaving most of its head, feet, above-target feedback and lower HUD clear. This is a proposed size tradeoff and still needs user visual acceptance. Existing provisional actors/background/HUD appear only in review composites, not effect PNGs. The separate player-animation chat and accepted character/weapon references are unchanged.

This packet supplies the source-inspired BURST only, now user-assigned to Level3 Fire presentation. The original source does not supply a travelling fireball loop. Do not stretch the one-shot into a persistent field, infer an area radius from its pixels or retime existing actions. Diagnose any missing travel artwork before dependent implementation. It is not a replacement for the32px Level1 mini. Preview timing is illustrative; GIF encoding may merge identical pause frames.

Prepared for later DUM-E/U review; no other chat was messaged. No runtime import, gameplay/scenes/runtime-script edits, Godot, builds/tests, commit or push. Ancestor `.gdignore` keeps this scratch packet out of Godot import.
