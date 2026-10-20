# Heroes III → Laema spell-art library

**Current review gate: Fire.** The original70-spell roster and source-mapping catalogue are built. The Fire batch has14 source-backed spell entries and21 exported layers, plus two source gaps. Water, Air, Earth and shared spells remain queued; no later batch was generated before Fire disposition.

## Open and review

Open **[index.html](index.html)** in a browser, keeping this folder together. It uses local scripts and images, without a server or external dependency. Search/filter by school, original level and coverage; choose an original layer and an adapted layer; play/pause, scrub, step and switch native/enlarged/1280×720 scene views. Shared spells appear once.

Browser-tool playback could not be verified here: the browser security policy blocked local-file navigation, and this environment denied loopback connections. No bypass was attempted. JavaScript syntax and file references were checked, but that is not successful UI validation. Direct review files are available independently:

- [Animated Fire overview](fire-overview.gif) and [static overview](fire-overview.png). Cards are fitted for comparison, not a common native scale.
- Each adaptation's `contact-dark-light.png`, role GIFs, `scene-preview.gif` and `scene-peak.png`.
- Each of the19 current Fire reference resources has `original-preview.gif`, its unmodified RGBA source sheet, metadata and palette.
- [Complete roster](ROSTER.md), [source gaps](SOURCE-GAPS.md), [Fire review notes](FIRE-REVIEW.md) and [verification record](verification.json).

## Coverage and identity

Installed Complete Edition SPTRAITS.TXT supplies the roster:10 adventure and60 combat spells, original indices0–69, with separately listed creature abilities excluded. Magic Arrow and Visions retain one shared identity each. Spell levels remain original Heroes III levels; they do not automatically bind to Laema Levels1–8.

VCMI's spell configurations provide a primary implementation cross-reference for resource names/roles. Original extracted PNGs and metadata provide the actual visual authority. A cross-reference does not establish original engine timing or prove absence when a binding is missing. The catalogue currently maps79 unique extracted resources to52 spell entries;18 entries have no verified standalone binding. Non-Fire mappings still await their batch's visual inspection.

**Only confirmed Laema assignments:** the carried mini Fireball for Fire Level1, and full Fireball burst for Fire Level3. Their selected files were copied byte-for-byte; originals remain unchanged. The mini flight is a separately requested derivative, not an extracted original Fireball flight sequence.

## Outputs and provenance

- `references/`: copied original RGBA preview sheets, palettes and metadata. Original indexed PNG/DEF preservation masters remain in `docs/art/references/heroes3-original-flipbooks/`; preview alpha is an extraction interpretation.
- `adaptations/fire/`: source-informed generated candidates. Each folder includes the unmodified selected image_gen PNG, exact prompt, transparent strips/individual frames, pivot/cell/role metadata, hashes and review exports. Rejected initial Berserk/Armageddon masters remain explicitly labelled.
- `catalogue.json` / `catalogue.js`: portable identity, source, adaptation, gap and review metadata. Original identity, Laema assignment and user acceptance are separate fields.
- `evidence/`: upstream cross-reference snapshots, retained with upstream authorship; they are research evidence, not Laema runtime code or a claim of relicensing.

Magic accents follow red-orange Fire while source bone/wood/steel/smoke materials remain distinguishable. No source gap was filled with invented artwork. Multi-part original effects retain separate roles. No character animation, summoned-creature art, spellbook icons or audio was created.

## Validation boundary and continuation

PNG/strip geometry, source/export cell margins, terminal transparency, references and hashes were checked. All current Fire contact sheets and original sheets were visually inspected in frame order on dark/light mattes, with static scene peaks checked at the selected180px actor / feet-y610 framing. Source and generated motion timings remain illustrative. Browser motion, loop seams in actual playback, user acceptance and Godot/runtime behavior remain unverified.

Frenzy has two explicitly recorded opacity-derived tail frames before its transparent endpoint; these are mechanical export fades, not newly generated poses. Ground phases share a stable proposed floor pivot while each phase retains its own source-supported shape. Armageddon preserves sparse diagonal streaks after repair; Inferno's display size was reduced for scene readability. These are art placement/scale proposals, not gameplay geometry.

Review the Fire batch and record the user's keep/revise decisions in FIRE-REVIEW.md/catalogue metadata before generating Water. No batch is marked accepted automatically. No further DUM-E message was sent for this library. Existing Fire Level1/3 implementation handoff remains separate.

The root `.gdignore` excludes this entire library from Godot import. No gameplay/runtime files, canonical design/technical records, tests, Godot launch, commit or push were performed by this task.
