# LAEMA editable opening draft

Open `index.html` directly in a modern browser, or serve this folder with any static web server. No installation, dependency, or build step is needed. Thirteen separate 16:9 slides scale with the browser width.

Edit text in `index.html`; shared colors, fonts, dimensions and spacing are in `styles.css`. The draft uses system serif fonts and approximate Unicode icons. It does not bake slide text into screenshots or use external dependencies.

## Replace artwork

Each `.art` element is an independent image slot. Insert `<img src="assets/your-image.jpg" alt="Description">` inside it and remove its placeholder span (the label also hides automatically when an image exists). Create an `assets` folder beside the HTML for your source images. Images use `object-fit: cover`; set `style="object-position: 65% 50%"` on an image to adjust the crop. Gradients above the artwork retain text contrast.

Needed assets:

- 01: Heroes-inspired mountain castle panorama, with Laema explicitly depicted as a female protagonist overlooking the world at lower left.
- 02: supplied strategy-layer world/town/hero view; no fabricated original Heroes screenshot.
- 03: a living town and a combat-toy visual, using female-protagonist placeholders.
- 04: three media slots for market, blacksmith as a person, and connected streets.
- 05: the same building, camera and location at foundation, under-construction and finished stages.
- 06: authentic original Heroes creature-animation source clip, plus ground-level encounter, confrontation and non-combat interaction placeholders with the female protagonist.
- Original LAEMA wordmark, display font and gold pictogram assets would improve the smaller details. The current wordmark is editable text.

## Reference and review status

The supplied montage has differently proportioned panels (top row approximately 4:3). This draft follows the explicit 16:9 requirement and preserves relative placement while adapting typography to avoid stretching text. All reference wording is treated as supplied pitch copy, not a change to canonical game design.

This Act I fast first pass has not received a complete visual review. No polished artwork was searched for or generated. The supplied storyboard guides the layout, while the written click map remains authoritative. The current 13-slide page was served locally and checked for file loading, Present mode, keyboard beat advance, slide-menu navigation, direct navigation to Slide 13, and Escape exit. This is a functional web check, not a full visual review of every slide or runtime gameplay validation.

## Presentation mode

Click **Present** to present inside the browser's webpage area at slide 1. Browser chrome stays visible; neither F11 nor the Fullscreen API is used.

The collapsed **☰ Slides** button at the upper left opens the slide navigation only when clicked. Select a slide to jump to it and close the panel. In presentation mode, the selected slide starts at its entry state; in preview, the page scrolls to it. The panel overlays the page without resizing the canvas. Click the toggle again, click outside the panel, or press Escape while focused inside the open panel to close it.

- Click / Space / Right / Down = advance one beat.
- Left / Up = reverse one beat.
- Mouse wheel down = advance one beat.
- Mouse wheel up = reverse one beat.
- Escape = exit presentation and restore the preview scroll position.

Wheel navigation handles dominant vertical movement only while presenting, ignores tiny events and Ctrl-wheel zoom, and accumulates a 32-pixel-equivalent threshold. Accepted beats start a fixed 250 ms cooldown for the same direction; additional events cannot extend it. Reversing direction bypasses the cooldown once the movement threshold is met. Sustained scrolling can advance multiple beats, while normal preview scrolling is unchanged. The existing next()/previous() functions handle all navigation, and the final slide stays on screen until you exit or go back.

Act I build counts are Slide 1: 1; Slide 2: 2; Slide 3: 2; Slide 4: 3; Slide 5: 4; Slide 6: 4. The combat slides are described below. To add builds, put `data-build="1"`, `data-build="2"`, etc. on existing elements; equal numbers reveal together. Builds only hide content during presentation, leaving normal preview unchanged. Going back from the start of a slide shows the previous slide with all its builds revealed.

Presentation uses a fixed 1920×1080 canvas, scaled as one unit by `Math.min(window.innerWidth / 1920, window.innerHeight / 1080)`. The canvas stays centered with black unused space and recalculates its scale on browser resize. Slide contents retain their layout rather than reflowing. Page scrolling is disabled during presentation; Escape restores normal preview scrolling.

Windowed sizing was checked using browser viewport overrides at 1920×1000 (maximized-like content area), 960×1000 (half-width), 2400×700 (wide), and 600×1000 (tall/narrow), plus the default 1280×720 viewport. The fixed canvas, centering, proportional scale, unchanged internal font size, slide navigation after resizing, and stateful morph reversal were checked without entering fullscreen. OS-window maximization and monitor movement were not exercised directly. This focused sizing check does not constitute a new visual review of all slide content.

## Act I — Slides 1–6

Storyboard layout refinement: Slide 1 keeps the protagonist region left of the title; Slide 2 uses three Towns/Heroes/Creatures thumbnails with a strategy-map slot on the right; Slide 3 uses two large image cards with bottom anchors; Slide 4 uses three place cards; Slide 5 uses four sequential image panels (building need, resource delivery, construction, visible result); Slide 6 uses an original-unit-to-creature inset on the left and three later encounter cues over the right-hand artwork slot. The heading/comparison on Slide 6 is its first build, preserving four beats total. On Slide 5, the final build adds the completed-building panel and the FOUNDATION → UNDER CONSTRUCTION → FINISHED summary. All imagery remains clearly labeled production placeholders, including the authentic Heroes clip slot. The storyboard's bottom continuation strip is not an additional slide. No combat content, navigation or build counts changed during this layout refinement.

1. **LAEMA** — entry: LAEMA. One build: “A SINGLE-PLAYER ACTION RPG / IN THE HEROES OF MIGHT & MAGIC UNIVERSE,” with “SAME WORLD. A NEW PERSPECTIVE.” The existing female-protagonist cover placeholder is retained.
2. **A WORLD I'VE KNOWN FROM ABOVE** — title and strategy-view media slot on entry. Build 1: “TOWNS · HEROES · CREATURES.” Build 2: “WHAT'S IT LIKE DOWN THERE?”
3. **LAEMA'S ANSWER** — two major media cards. Build 1: “A LIVING TOWN / PEOPLE · NEEDS · CONTRIBUTION.” Build 2: “A COMBAT TOY / LEARN · MANAGE · MASTER.”
4. **FROM TOWN SCREEN → REAL PLACE** — title on entry; three independent visual areas. Build 1: “THE MARKET BECOMES A PLACE.” Build 2: “THE BLACKSMITH BECOMES A PERSON.” Build 3: “THE STREETS CONNECT IT ALL.”
5. **CONTRIBUTION → CONSTRUCTION → CHANGE** — title on entry. Build 1: “THE TOWN NEEDS A BUILDING.” Build 2: “I BRING THE RESOURCES.” Build 3: “CONSTRUCTION TAKES TIME.” Build 4: “MY CONTRIBUTION BECOMES VISIBLE,” revealing FOUNDATION → UNDER CONSTRUCTION → FINISHED together. These are the same building/location at different times, not building placement or city-management controls.
6. **FROM UNIT → CREATURE** — static original-animation source slot; four beats. Build 1: “FROM UNIT → CREATURE.” Build 2: “WHAT IS IT LIKE UP CLOSE?” with the large close encounter. Build 3: “FACE IT MYSELF,” switching to confrontation. Build 4: “PART OF THE WORLD,” switching to a non-combat interaction. No creature-settlement mechanics are implied.

The original-animation slot reads “OG HEROES CREATURE ANIMATION / REPLACE WITH SOURCE CLIP.” It is an empty muted inline video, not fabricated footage. Add the user's supplied MP4/WebM with `src` or source children and remove the label when ready. Existing playback handling applies. Encounter and construction images use the reusable `.art` and `.act-media` containers.

Act I ends directly at the existing ATTACK CHAIN slide, now Slide 7. No teaser or extra transition slide was added. Its five-hit diagram remains on entry, with the explicitly requested single build “SOMETHING FAMILIAR.” That cue was absent from the preceding working markup and was added in this pass.

The former Slides 5–11 are now Slides 7–13. Existing combat content and stateful effects are retained, apart from that requested Attack Chain cue and numbering/reference updates. `presentation.js` is unchanged: sidebar entries are generated from slide labels, and the controller derives build counts from the HTML. The current present-in-window behavior and fixed-cooldown mouse-wheel navigation are preserved.

“At a glance” remains removed. No product-summary slide or ~20-hour scope statement was reintroduced.

## Slides 7–9

- Slide 7 — ATTACK CHAIN: complete five-hit sequence and numbered chain visible immediately; click 1 reveals “SOMETHING FAMILIAR,” then the next click advances to Slide 8. Supply a wide five-stage melee composite or real gameplay clip in a dark town street.
- Slide 8 — ATTACKS CREATE ORBS: attack visual and numbers are visible on entry. All five HTML orbs share `data-build="1"`; one click reveals them together, the next advances to Slide 9. Supply an attack/orb-generation clip or wide cinematic artwork without baked-in labels, numbers or explanatory orbs.
- Slide 9 — COMBAT FLOW: title and top labels remain visible. Build 1 reveals combo, numbered chain and generated orbs; build 2 reveals the charge artwork, R2 HOLD and explanation; build 3 reveals the cast artwork, R2 RELEASE and explanation. Supply three text-free images: five-stage melee sequence, traveller charging with gold orbs and blue-gold energy, and traveller casting a blue blast at an enemy. Left/Up reverses these builds; the next click advances to Slide 10.

The reference titles and supporting copy use a spaced system sans-serif approximation of the attached references. All explanatory text, numbers, controls and orb overlays remain HTML/CSS; no reference screenshot is used as slide artwork. The combat designs and state logic are retained, with numbering updates and the requested single Attack Chain cue.

## Slides 10–13

- Slide 10 — THE AHA MOMENT: enters in the completed Slide 9 serial arrangement. Build 1 replaces the serial heading with `SIMPLE INPUTS. PARALLEL DECISIONS.` Build 2 moves R2 HOLD beneath the attack chain, extends the Hold lane from X1 to RELEASE and adds FIGHT/PREPARE labels. Build 3 adds `TWO THINGS TO MANAGE AT ONCE`.
- Slide 11 — WHERE THE CHALLENGE MOVES: build 1 reveals a generic illustrative command sequence; build 2 reveals LAEMA's simpler FIGHT and PREPARE commands; build 3 reveals substantial `LESS INPUT COMPLEXITY → MORE ATTENTION MANAGEMENT` blocks and the explanatory sentence below. The moving attention pill has been removed.
- Slide 12 — WHY MULTITASKING FEELS DIFFERENT: four representative foreground demands replace the numbered combo entirely: ATTACK, READ ENEMY, DEFEND / AVOID, RE-ENGAGE. They are not literal combo positions. Build 1 highlights Attack/Read Enemy; build 2 highlights the enemy telegraph and Defend/Avoid; build 3 strongly illuminates the continuous Cast preparation lane and displays `BUT THE CAST IS STILL THERE`; build 4 highlights Re-engage and Release, asks `WHEN DO I RELEASE?`, and reveals the concluding two sentences. Supply four text-free images for the existing `.demand-art` slots.
- Slide 13 — THE CLIMAX: build 1 reveals `THIS IS WHY CASTING FEELS REWARDING.` Build 2 adds `THE FIGHT NEVER STOPPED. THE CAST STAYED ALIVE.` Build 3 dramatically recedes those cues, brightens the hero visual, and reveals the section's largest statement: `I KEPT BOTH UNDER CONTROL.` Build 4 adds `THAT IS THE MASTERY.` The final slide holds. The media region accepts a text-free successful-Cast image or real gameplay clip.

Slides 10–13 use `data-state` alongside the existing numbered builds. The controller derives the state from the current build count, so click/Space/Right/Down advances and Left/Up reverses the same deterministic states. CSS transitions explain the Slide 10 reconfiguration; there are no timed or autoplay animation sequences.

This fast first pass preserves the existing controller and its wheel handling. Slide 10 copies the completed Slide 9 layout at state 0; its chain expands during the morph while X1 keeps its horizontal position. Text fades take about 320–380 ms, the morph 750 ms, and the climax emphasis 600 ms. Reduced-motion preferences remove transition durations without changing build order.

Slide 13 uses `assets/cast-climax-v1.png` as its video poster. This is illustrative artwork edited from the supplied approved climax mockup using the built-in image-generation tool; it is not gameplay footage. Its text, border, icons and ornaments were removed, leaving the cinematic Cast scene. All presentation wording is separate HTML. Add a real video `src` later to replace the poster during playback.

Artwork edit prompt: “Produce a standalone 16:9 text-free background from the approved LAEMA successful-Cast mockup. Remove all typography, slide number, gold frame, icon circles, dividing lines and diamonds, inpainting naturally. Preserve the centre-right swordsman, rightward blue-white/gold spell discharge, armoured enemy, dark medieval town, debris, original pose and composition. Keep the left third dark. No text, logos, UI or borders; illustrative pitch artwork, not gameplay footage.”

### Gameplay video slots

Slides 7 and 8 each contain a reusable `.gameplay-slot` with a muted, inline `<video>`. Set `src="assets/attack-chain.mp4"` on the video, or add `<source src="assets/attack-chain.webm" type="video/webm">` and an MP4 fallback. The placeholder hides when a source is present. Use a text-free 16:9 clip and adjust `object-position` if necessary. To use a static image instead, replace the empty video with an image as described above. No footage has been supplied or fabricated.

The existing controller pauses non-current and pending-build videos. On entry or reveal, it restarts eligible videos and attempts playback; autoplay denial is handled without disrupting navigation. Add `data-resume` to a video to retain playback position on re-entry. Put a video inside any numbered build container to delay playback until that reveal. Exiting presentation pauses all videos. Keep `muted playsinline`; do not add native `autoplay`, which would bypass slide visibility handling. Preview shows all build content; video playback is managed during presentation.
