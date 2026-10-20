# Laema Art Direction

## Visual Reference Authority — 2026-10-16

Decision: the user designated the **HMM3** task (`01a142bd-e72a-7f03-b3fb-1b28d222492b`) and its extracted original Heroes of Might and Magic III assets as the source of truth for visual style. Actual source artwork takes precedence over earlier AI interpretations of that style.

### Source and evidence

- Reference collection: `Heroes3-original-sprites`, exported by the HMM3 task from the user's installed Complete Edition `Data/H3sprite.lod` and `Data/H3ab_spr.lod`. Its `README.txt`, `manifest.json`, original files, indexed preservation PNGs and per-sprite metadata carry provenance.
- Reported export coverage: 2,912 DEF files, 39,923 frames, 3,121 PNG sheets. The Art task read the HMM3 conversation and export README, inspected source sheets and metadata, and compared unmodified native frame crops.
- Inspected references include `H3sprite/creatures/Csword`, `Ccrusd`, `Cmonkk`, `CFELEM`; `H3sprite/interface/TBCSCSTL`, `TBCSTVRN`; and spell-effect sequences `C01SPF0`, `C01SPW0`. Asset identifiers are reference pointers, not inferred spell names or animation timings.
- The export excludes HD/HotA replacement assets and standalone PCX images from bitmap archives. The export README cautions that installed archives may contain prior changes; historical retail byte identity is not established. Viewable transparency/shadow handling is an export interpretation; preserved indexed pixels and original files remain the fidelity reference.
- This decision establishes artistic reference authority. It does not approve importing original game artwork into Laema, adopting Heroes III gameplay, or changing the approved combat camera.

### Reconciled artistic direction

- Preserve the user's selected textured direction A, but match the original sprites' fine modeled-volume shading and material treatment. Earlier generated blocky pixels and enlarged clusters are not a precise Heroes III style reference.
- Favor readable silhouettes with subtly shaded volumes, concentrated steel highlights, restrained cloth/leather base colors, and small purposeful color accents. Judge at native visible sprite scale as well as enlarged inspection scale; padded export canvas dimensions are not visible character dimensions.
- For Castle-inspired architecture, use original stone, timber, roof, cloth and heraldic treatment as the reference. Adapt its perspective and detail density to Laema's side-scrolling combat view.
- Reference actual effect shapes and palette transitions before polishing Laema's magic. Preserve the four-school identity while keeping the actor and weapon readable; a generated large glow is not evidence of a match to the originals.
- Previously generated character, courtyard and sword sheets remain exploratory proposals. Their presence does not establish approved production sprites, final animation, or runtime acceptance.

### Carried weapon decisions and open work

- Historical direction: Laema has no staff; the sword study was provisional. Later hammer/lance baselines and the accepted-for-preservation hammer set below remain valid; no final production weapon is locked.
- The user prefers edge-to-edge joining (candidate 1) and compact-to-extended transformation (candidate 4). The physical/visual split, joining and extension sequence is not yet solved or validated.
- The lit-seam treatment is selected for first development. Magic is visible across Fire, Water, Air and Earth. The existing Laema palette is red-orange, blue, white and brown-ochre respectively; application to final sprites remains to be tested.
- Light dual blades, medium one-handed use and heavy two-handed use describe the desired weapon presentation. They do not add new attack rules through this art record.
- Show five candidates per comparison round. A selected direction can be developed without reopening the five-way choice.
- Open production work: native-scale sprite validation, exact pixel dimensions, transformation animation, effect intensity and final assets. Concept iteration is paused under the later accepted-for-preservation hammer entry; this list does not restart it.

## Approved character concept direction — 2026-10-18

Decision: the user locked the current character direction. The complete
[five-image reference set](references/2026-10-18-character-concepts/README.md)
is retained with provenance: Laema options 1–3 (Open, Wrap, Cutaway) and the female
local lord she advises as options 4–5 (Facet, Mantle). No numbered outfit was
selected; the assistant's recommended 1 and 5 are not user choices.

Laema is curious and alert. The female local lord's direction is a natural face,
short asymmetric silver-white bob, knowing half-smile, and confident, lightly
skeptical expression. Preserve existing lore alongside the explicit local-lord
advisory relationship. These are concept references, not runtime sprites or
rig-ready assets. No weapon is locked by this approval. The earlier original
Heroes III visual-style authority remains in force.

## Working weapon concept baselines — pass 3

Decision: preserve the last positively reviewed
[Hammer Crown and solid tapered Lance references](references/2026-10-18-pass-3-weapon-baselines/README.md)
for continued refinement. The user's feedback was that the hammer looked fine
and the lance was closer; neither is a final locked weapon. Weapon pass 5,
delivered October 18 at 11:42 UTC, was rejected. No pass-4 or pass-5 images are
included. These working concepts establish no runtime assets or new gameplay
rules. The five locked character references above remain unchanged.

## Accepted Laema-with-hammer concept set — 2026-10-19

Decision: preserve the [five combined character/weapon concepts](references/2026-10-19-laema-hammer-accepted/README.md)
following the user's “okay looks good, save it for now” at 08:09 UTC. Iteration
is paused; this acceptance is not a final production weapon lock. The set records
hero, gameplay-scale, paired sword/scabbard, downward-strike and shoulder-carry
views. The gameplay-scale view is a concept, not runtime evidence. Immediate
hammer ancestry is pass 6; character ancestry is Laema Open. All five earlier
character alternatives and the historical pass-3 weapon baselines remain valid
in their documented roles. These images establish no new gameplay rules or
production assets.

## Prototype Combat HUD Layout

Status: Approved visual direction for the prototype HUD layout.

### Player-facing HUD

- Upper-right: current stage objective.
- Above the target: target Health and Cast-result feedback.
- Bottom-left: persistent Heat and attack speed.
- Bottom-center: ten generated-orb slots and Charging progress.
- Player-facing terminology uses **generated**, **Charging**, and **charged** rather than `MARK`.

### Optional developer overlay

- Upper-left: Player and Enemy Health, Heat, speed, and Defence diagnostics.
- Top-middle: active school and chain state.
- Upper-right: raw L2 pressure and semantic pressure state.
- Diagnostics form one orderly top rail or aligned diagnostic group.
- Enabling the overlay must not obscure the objective or core combat HUD.
- Disabling the overlay leaves no empty diagnostic frames behind.

#### Live-combat priority

- The overlay prioritizes glanceable live telemetry while combat continues.
- It uses a fixed top rail with stable geometry and compact label-value pairs.
- Left: Player and Enemy Health, Heat, speed, and Defence state.
- Center: active school, five attack positions, and Cast endpoint; the current position receives the strongest emphasis.
- Right: raw L2 pressure and its semantic state.
- The objective moves below the rail while the overlay is enabled.
- Developer and player-facing HUD panels must not overlap or clip at supported display widths.

#### Event confirmations

- A fixed lane beneath the live telemetry shows recent system events.
- The newest event is prominent for approximately one second; up to two older events remain briefly at reduced emphasis.
- Repeated high-frequency results are aggregated where practical.
- Events include orb generation, Charging completion, Cast commitment, chain advancement or break, and applied or blocked damage.
- Normal events remain neutral, school actions receive the school accent, warnings use amber, and failures use red.
- Meaning is always reinforced with text and shape rather than color alone.
- Event activity never changes the rail’s dimensions.

### Open visual work

- Final visual styling, typography, icons, materials, motion, and polish.
- Final Laema art and final UI assets.
