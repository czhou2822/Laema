# Original Heroes III source audit — 2026-09-16

## Current result and evidence boundary

Every active source use is inventoried below. Slide 26 now uses FOUR authentic extracted opening frames, not a movie player. Previous files remain for history; a copy of the prior ledger is in `hmm3-source/archive/AUTHENTIC-SOURCES.pre-audit.md`.

Active sources are under `hmm3-source/`. Original-game media was not generated, repainted, recoloured, relit, sharpened, AI-upscaled or restored. PNG extraction preserves the decoded archive frame. Source movies are community transcodes identified as original RoE resources, not raw SMKs independently checked against a retail-CD hash. Dimensions below are archive/file dimensions, not a claim about original SMK encoding. Storefront JPEG resizing/compression is inherited rather than an agent enhancement.

Confidence: HIGH means identity/context is corroborated; MEDIUM indicates a material lineage, semantic or variant limitation; LOW means insufficient evidence. Confidence is not user approval. Local browser preview remains blocked; media was inspected directly and source/code checked without circumventing that restriction.

## Complete active-use inventory

Keys resolve to exact filenames, game/version, context, URLs, origin, alternatives and limitations in the registry below.

| Slide / slot | Purpose | Previous asset | Selected | KEEP / REPLACE and reason | Confidence |
| --- | --- | --- | --- | --- | --- |
| 2 / adventure map | Strategy-layer world | `h3-adventure-map-manual-source.jpg` | M | REPLACE monochrome manual picture with colour original-game map and its UI. | HIGH game/context; MEDIUM exact scenario |
| 2 / town | Castle → lived-in place | `hmm3-castle-source.png` | C | KEEP pixels; developed Castle scene is stronger than the sparse official-store alternative. | HIGH faction; MEDIUM capture lineage |
| 2 / hero | Hero experienced on the map | `h3-catherine-portrait-source.png` | M, CSS detail | REPLACE isolated character portrait with a mounted hero beside a town in the strategy view. | HIGH role; individual map-hero identity unclaimed |
| 2 / creature | Small original unit | `h3-griffin-source.png` | G | KEEP base Griffin, not Royal Griffin. | HIGH variant |
| 6 / Griffin | Unit → creature | `h3-griffin-source.png` | G | KEEP verified static frame; no authenticated attack animation obtained. | MEDIUM semantic coverage |
| 25 / world-map | Familiar POIs | Monochrome manual picture | M | REPLACE with colour structures/resources/terrain context; no exact four-object pairing claimed. | HIGH general role |
| 26 / opening-frame-1 | Catherine / setup | Full movie and small Catherine poster | O1 | REPLACE player with a selected original setup frame. | HIGH scene; MEDIUM archive lineage |
| 26 / opening-frame-2 | Arrival | Full movie | O2 | Curated landing shot, in original order. | HIGH scene; MEDIUM archive lineage |
| 26 / opening-frame-3 | Aftermath | 2:18 Griffin-dominated thumbnail | O3 | REPLACE with ruins/fallen statue; enlarges on beat 2. | HIGH scene; MEDIUM archive lineage |
| 26 / opening-frame-4 | Historical response | Full movie | O4 | Catherine's resolve in the opening, not a later campaign victory. | HIGH scene; MEDIUM archive lineage |
| 27 / memory-aftermath | Opening callback | `h3-cloudfire-intro-source.jpg` | O3 | REPLACE consistently with Slide 26's selected aftermath. | HIGH scene |
| 27 / king-nicolas | Reference to the dead king | 360×180 tomb thumbnail | N | REPLACE with full archive-frame extraction; qualified death reference, not evidence of poisoning. | MEDIUM role fit |
| 27 / remembered-opening | Return of the opening as memory | Old Cloudfire thumbnail | O3 | REPLACE with the same audited aftermath frame. | HIGH scene |
| 28 / war-origin | Historical devastation | Old Cloudfire thumbnail | O3 | REPLACE; shows devastation, but cannot prove a refugee route toward Mirham. | MEDIUM narrative inference |
| 29 / Catherine | Known story begins | 328px shipboard thumbnail | O4 | REPLACE with Catherine confronting the devastation, strengthening the handoff. | HIGH period/function |
| 30 / town | Recall upstream source | `hmm3-castle-source.png` | C | KEEP the Slide 2 Castle selection. | HIGH faction |
| 30 / creature | Recall upstream unit | `h3-griffin-source.png` | G | KEEP the same base variant as 2/6. | HIGH variant |
| 30 / map | Recall strategy world | Monochrome manual picture | M | REPLACE with the same upstream colour capture. | HIGH general role |

## Registry: originals, selection and alternatives

### M — `h3-adventure-map-colour-gog.jpg`

**Identity/version/context:** original Heroes III Complete adventure-map interface, green/swamp terrain, roads, structures, resources and treasure chests. A mounted figure is beside a blue-flagged town at left; the right UI names Mirlanda. The identity of that particular map figure is not asserted. Exact map/scenario and patch are unknown; this is not labelled as a specific RoE campaign map.

**Provenance:** [official GOG Complete listing](https://www.gog.com/en/game/heroes_of_might_and_magic_3_complete_edition), original-game product gallery; [downloaded image](https://images.gog-statics.com/8e401209b82f9a43ff803287e3970e703b1eaeb505ae25c96108499dd7a210e5.jpg). Supplied JPEG is 710×533. It is an official-distributor reproduction, not an agent-run capture or raw game resource.

**Selection:** colour and recognizable original UI better support the strategy-layer thesis. HERO uses a CSS zoom of the same full file, preserving surrounding map context. No pixels were removed from the stored image.

**Alternatives:** 1999 manual screenshot rejected as authentic but monochrome/weak; GOG snow map was less useful for this comparison; GOG desert/Necropolis capture was a larger but visibly enlarged and faction-specific alternative; Catherine portrait was authentic but semantically poor for HERO. The four LAEMA location concepts are illustrative, not verified one-to-one replicas of four objects in this capture. The small hero remains low-resolution honestly.

### C — `h3-castle-town-original.png`

**Identity/version/context:** developed original Heroes III Castle town scene, including the original Grail Colossus. RoE/Complete Castle assets; exact capture scenario/patch not established. It is not a picture of Cloudfire or Mirham.

**Provenance:** copied unchanged from the existing local file; [Castle reference](https://heroes.thelazy.net/index.php/Castle), [recorded original download](https://heroes.thelazy.net/images/5/57/Castle-in.png). Cross-compared with the [GOG original-game Castle capture](https://images.gog-statics.com/9b2cf8f995903d3c50fb6f9d8bc461b69b49819d27d7cb917094b892c8ffdccf.jpg).

**Selection/alternatives:** KEEP the 800×374 developed scene. The sparse early Castle town in the storefront has less useful town detail and a large UI region. This source retains the correct faction and familiar buildings. **Limit:** wiki reproduction is not independently matched to a raw resource/CD hash; exact patch is not claimed. Buildings shown are not claims about LAEMA mechanics.

### G — `h3-griffin-base-sprite.png`

**Identity/version/context:** brown base Griffin, original Heroes III Castle unit present in RoE. This 100×130 PNG has ONE frame. It is not an attack animation and not the silver/white Royal Griffin.

**Provenance:** existing pixels retained; [Griffin / Royal Griffin reference](https://heroes.thelazy.net/index.php/Griffin_and_Royal_Griffin), [base sprite](https://heroes.thelazy.net/images/4/44/Creature_Griffin.png). Compared directly with the separately identified [Royal Griffin sprite](https://heroes.thelazy.net/images/7/75/Creature_Royal_Griffin.png).

**Alternatives:** [Spriters Resource Griffin sheet, asset 42156](https://www.spriters-resource.com/pc_computer/heroes3/asset/42156/) is indexed as an original-game Castle-unit rip by Cyrus Annihilator, 1635×1203. Access was blocked, so its pixels, groups and timings were not verified. No guessed GIF was assembled. Royal Griffin promotional renders and fan animation were not substituted for the base battle unit.

**Selection/limit:** KEEP static verified identity and reuse consistently in 2/6/30. It supports the small-unit comparison but does not demonstrate the spoken attack-animation reference. The cream-headed/golden concept is stylized and does not conclusively lock base versus Royal identity; user confirmation remains OPEN. Original local Griffin DEF/game resources could support a reliable animation later.

### O1–O4 — original RoE opening storyboard

**Identity/version:** 1999 Restoration of Erathia opening, `H3INTRO.SMK` sequence, preserved as a community transcode.

**Archived input:** `archive/roe-h3intro-community-transcode.webm`; SHA-256 `e265fd365699a4d8523f7ca1f3e8b948ae1be4abc49db50f03ed2d94b36888e4`. [File URL](https://heroes.thelazy.net/images/0/02/RoE_1.0_CD-Heroes3-DATA-HEROES3_VID-H3INTRO-smk-H3INTRO.webm); [archive file record](https://heroes.thelazy.net/index.php/File:RoE_1.0_CD-Heroes3-DATA-HEROES3_VID-H3INTRO-smk-H3INTRO.webm). The record identifies RoE 1.0 CD resources, uploader Imahero, revision comment v3, 11 February 2024. Inspected archive: VP9/Opus, 640×352, approximately 15 fps, about 161.73 seconds. Raw CD/SMK hash is unavailable; do not imply bit-identical raw extraction.

**Cross-checks:** direct scene inspection, [Cloudfire reference](https://heroes.thelazy.net/index.php/Cloudfire), [Catherine gallery](https://heroes.thelazy.net/index.php/Catherine), and [Celestial Heavens campaign compilation](https://www.celestialheavens.com/homm3/HoMM%20III%20Campaigns.pdf), PDF page 6. The compilation is a secondary transcription of game narration, not the original recording.

**Sequence:** shipboard context and landing, investigation of the devastated settlement, intercut reconstruction of the preceding battle, then Catherine's resolve/banner. Selected frames avoid presenting battle-reconstruction shots as Catherine witnessing an ongoing invasion.

| Frame / exact filename | Actual source PTS | Requested seek | Identification | Purpose |
| --- | --- | --- | --- | --- |
| O1 `roe-opening-catherine-0018.png` | **00:17.998** | 00:18.00 | Catherine aboard ship | Return setup / recognizable protagonist |
| O2 `roe-opening-arrival-0032.png` | **00:31.997** | 00:32.00 | Catherine and troops landing beside battlefield remains | Arrival into an already damaged situation |
| O3 `roe-opening-aftermath-0050.png` | **00:49.995** | 00:50.00 | Catherine, ruined masonry and fallen statue at Cloudfire | Main aftermath proof; beat-2 enlargement and 27–28 callbacks |
| O4 `roe-opening-resolve-0150.png` | **02:30.052** | 02:30.00 | Catherine beside the raised Erathian banner | Response / resolve; Slide 29 handoff |

**Why four:** identity, arrival, existing damage and response can be pointed to immediately. The scene order is the original order. Extra shots did not add another pitch idea. An earlier reflective shot at 02:00.055 was compared and retained only as an inactive candidate; the final 02:30.052 banner shot gives Catherine a clearer, more recognisable handoff. All four are 640×352 PNGs; source PTS records the selected discrete frame, which can differ slightly from the requested seek.

**Exact process:** `ffmpeg -ss SECONDS -copyts -i SOURCE.webm -vf showinfo -frames:v 1 -fps_mode passthrough OUTPUT.png`. FFmpeg 7.1 via a temporary imageio-ffmpeg tool; no deck dependency. `showinfo` only logs metadata. No scale, crop, colour, generative or restoration filter. Full frame is retained. Commands, scenes, purposes, timestamps and hashes are in `frame-provenance.json`.

**Rejected previous choices:** full movie for normal pitching (timing burden); the small shipboard thumbnail for Slide 29 (weak handoff context); the late 2:18 Griffin-dominated thumbnail as aftermath proof (correct general scene, poor subject emphasis and needless downsampling). Both source movies remain archived for provenance/backup; no cinematic player remains in the main deck.

### N — `roe-nicolas-tomb-0000.png`

**Identity/version/context:** Nicolas Gryphonheart's tomb at Stonecastle, original RoE A Gryphon's Heart prologue. It is death/tomb context, not a living portrait, poisoning scene or Laema's local incident.

**Archived source:** `archive/roe-gryphons-heart-prologue-community-transcode.webm`; [file URL](https://heroes.thelazy.net/images/5/51/RoE_1.0_CD-Heroes3-DATA-HEROES3_SND-E2A-smk-EVIL2A.webm); SHA-256 `0fcd8f721fe818d98b3cc824c3561030b8def3d09e91b8e69d1154e9c352be0d`. [Nicolas reference](https://heroes.thelazy.net/index.php/Nicolas), [A Gryphon's Heart](https://heroes.thelazy.net/index.php/A_Gryphon%27s_Heart), and campaign compilation pages 46–47 corroborate the scene.

**Timestamp/process:** first source video frame, **00:00.007**, extracted at the archive's 800×400 dimensions using `ffmpeg -copyts -i SOURCE.webm -vf showinfo -frames:v 1 -fps_mode passthrough OUTPUT.png`. No resizing here; original SMK resolution/encoding is not independently established.

**Compared alternatives:** no verified living original-H3 portrait found. Later lich/resurrection/finale imagery is chronologically wrong for illustrating the earlier death. Unused promotional or later-game portraits are not original in-game living Nicolas imagery. Campaign text supports poisoning more precisely but would create a text-heavy source region; that is an option for user direction, not an automatic narrative rewrite.

**Decision/limit:** replace the 360×180 thumbnail with the full archived frame, but keep the tomb only as a qualified death reference. It cannot authenticate the local-poison connection. MEDIUM semantic fit; not claimed to be ideal visual evidence of poisoning.

## Potential content issues — anchors were NOT silently rewritten

| Current claim / implication | Evidence and confidence | Follow-up |
| --- | --- | --- |
| Cloudfire is the opening's devastated location | HIGH: the opening narration names Cloudfire; the campaign transcription and location reference agree. It is a wizard outpost, not an original Castle town screen. | Keep the name on the original aftermath; do not present the LAEMA concept street as a canonical reconstruction. |
| Survivors move from Cloudfire toward Mirham | The opening reports **“no survivors”** found by Catherine. HIGH for that account, not proof nobody escaped beforehand. The specific refugee route is not established by original material. | Clarify earlier escape, people from elsewhere, or wider consequences. Existing pitch remains unchanged. |
| Laema's local poison later kills Nicolas | HIGH: RoE Safe Passage / For King and Country establish poisoning and Haart's involvement; SoD Poison Fit for a King adds original-expansion background. No checked OG source establishes Laema's incident or its poison's identity. | Treat the local connection as LAEMA-authored narrative, not verified OG canon. Confirm it occurs before the king's death. |
| Fallen king → collapsed kingdom | Broad chronology is supported: the king is already dead before Catherine returns to the invasion/Restoration situation. The proposed local plot's detailed timing is not established. | Separate timeline review; no automatic rewrite. |
| The concept exactly reinterprets the base Griffin | HIGH original base/Royal distinction; LOW certainty about the stylized concept's intended upgrade variant. | Confirm intended variant; do not change it casually. |
| Four concepts match four specific OG map objects | Not verified and not asserted. | Keep the source map general; no invented original-looking glyphs. |

Poison cross-checks: [Safe Passage](https://heroes.thelazy.net/index.php/Safe_Passage), [For King and Country](https://heroes.thelazy.net/index.php/For_King_and_Country), [Poison Fit for a King](https://heroes.thelazy.net/index.php/Poison_Fit_for_a_King); campaign compilation pages 55, 59–60, 225. RoE and SoD evidence are kept distinct. No named chemical or living-portrait claim is invented.

## Preservation / validation

`hmm3-source/asset-manifest.json` contains file dimensions, sizes and SHA-256 hashes. `hmm3-source/frame-provenance.json` contains every extraction's input, timestamp, scene, purpose, command and hash. Prior assets remain unchanged at their old paths for history; active references point to the audited directory.

Static validation checks local references, 31-slide numbering, unchanged beat sets and anchors, unchanged concept references, no full cinematic player, and unchanged presentation.js. It does not prove rendering: local browser preview is unavailable and was not bypassed. Legacy pixel dimensions and archive compression remain visible honestly.

## Earlier pre-audit ledger — superseded by the inventory above

Retrieved online for the user's requested source-media pass. These are original-game media reproduced by the Heroes 3 wiki, plus an embedded screenshot extracted from the publisher-hosted 1999 manual. They are not generated replacements, remakes, HotA/DoR assets or gameplay captures made by this task. Heroes of Might and Magic III / New World Computing / 3DO; current franchise rights Ubisoft. Community hosting is not a free-asset licence.

Files are local so the deck does not depend on live remote image links. Original pixels were preserved; the manual screenshot was extracted as its embedded JPEG without redrawing or recolouring. CSS contains full source frames and scales pixel art explicitly. Legacy resolution is retained.

| Local asset | Provenance and direct source | Placement |
| --- | --- | --- |
| `h3-adventure-map-manual-source.jpg` | Embedded `Im11.jpg`, PDF page 14 (index 13), [publisher-hosted original 1999 manual](https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/297000/manuals/BONUS_Heroes_of_Might_and_Magic_III_HDEdition_OldManual1999_EN.pdf). The printed manual image is monochrome. | Slides 2, 25, 30 |
| `h3-catherine-portrait-source.png` | [Catherine page](https://heroes.thelazy.net/index.php/Catherine), explicitly Restoration of Erathia variant: [original portrait](https://heroes.thelazy.net/images/8/8e/Hero_Catherine_%28RoE%29.png). | Slide 2 hero detail |
| `h3-griffin-source.png` | [Griffin and Royal Griffin](https://heroes.thelazy.net/index.php/Griffin_and_Royal_Griffin): [original Griffin sprite](https://heroes.thelazy.net/images/4/44/Creature_Griffin.png), not the HotA variant. | Slides 2, 6, 30 |
| `h3-roe-intro-source.webm` | [Original RoE H3INTRO movie](https://heroes.thelazy.net/images/0/02/RoE_1.0_CD-Heroes3-DATA-HEROES3_VID-H3INTRO-smk-H3INTRO.webm), documented in the Catherine and Griffin galleries as the Restoration of Erathia intro; wiki transcode of the original SMK. | Slide 26, muted, existing video visibility controller |
| `h3-catherine-intro-source.jpg` | [Catherine intro frame at 0:18](https://heroes.thelazy.net/images/thumb/0/02/RoE_1.0_CD-Heroes3-DATA-HEROES3_VID-H3INTRO-smk-H3INTRO.webm/328px-seek%3D18-RoE_1.0_CD-Heroes3-DATA-HEROES3_VID-H3INTRO-smk-H3INTRO.webm.jpg), served as the Catherine gallery's video poster. | Slide 26 poster and Slide 29 Catherine half |
| `h3-cloudfire-intro-source.jpg` | [Original intro frame at 2:18](https://heroes.thelazy.net/images/thumb/0/02/RoE_1.0_CD-Heroes3-DATA-HEROES3_VID-H3INTRO-smk-H3INTRO.webm/409px-seek%3D138-RoE_1.0_CD-Heroes3-DATA-HEROES3_VID-H3INTRO-smk-H3INTRO.webm.jpg). The Griffin gallery explicitly identifies this shot as Catherine astride a Griffin at Cloudfire. Ruined town visible behind her; not a clean town-only establishing view. | Slides 26–28 source/aftermath slots |
| `h3-nicolas-tomb-source.jpg` | [Nicolas page](https://heroes.thelazy.net/index.php/Nicolas) identifies the A Gryphon's Heart prologue as King Nicolas Gryphonheart's tomb in Stonecastle. [Original cinematic poster](https://heroes.thelazy.net/images/thumb/5/51/RoE_1.0_CD-Heroes3-DATA-HEROES3_SND-E2A-smk-EVIL2A.webm/360px--RoE_1.0_CD-Heroes3-DATA-HEROES3_SND-E2A-smk-EVIL2A.webm.jpg). Depicts his tomb, not a living portrait or the poisoning. | Slide 27 King Nicolas slot |

Existing `hmm3-castle-source.png` retains the provenance already recorded in `GENERATED-ART.md` and the marketing-town handoff.

## Review boundary

Downloaded stills were inspected individually. File links and markup were checked. Browser Use still blocks the local deck; the newly linked movie's actual playback and post-edit slide crops have not been verified. No AI enhancement was applied. The opening movie is approximately 162 seconds and muted by the existing slot; advance to the second build when ready rather than waiting for the whole movie.
