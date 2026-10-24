# Pikeman resolution study v01

User selected framing05 (180px body target, approximately15% foreground, compact HUD) and reported that the enlarged original Pikeman looked poor.

## Outputs

- [Comparison](comparison.png): native pixels, soft resampling, and new interpreted repaint at approximately the same180px body target.
- [Repaint inside selected framing05](05-higher-resolution-pikeman-mockup.png):1280×720 static mockup.
- original-pikeman-6x-reference.png: nearest-neighbor reference enlargement only.

## Artistic proposal

A faithful repaint at the chosen display resolution preserves the recognizable blue/silver/brown unit and pike while giving the silhouette, face, cloth and equipment enough detail to read at the larger size. The soft-resampling control illustrates that filtering reduces block edges without supplying missing structure.

The repaint is newly generated interpretation. Facial detail, garment construction and small heraldic markings are inferred, not recovered authentic source pixels. The selected environment/framing and player placeholder are retained as context; the image tool may alter incidental surrounding pixels.

## Scope and validation

This is one idle-pose art study. It is not a transparent production sprite, animation sheet, temporally consistent redraw pipeline, imported replacement or runtime result. Walk, thrust/attack, hurt and death would all need a consistent treatment before replacement is usable. Native reference files remain unchanged.

Built-in image generation produced the repaint. Mechanical nearest/Lanczos comparisons, resampling to1280×720 and comparison layout use the retained scripts. Both deliverable PNGs were decoded and visually inspected. No game files, imports, scenes, gameplay, current actor presentation or canonical art records were changed. No implementation handoff was dispatched for this unaccepted repaint.

## Sources

Edit target:
C:\Users\zhouc\.codex\visualizations\2026\09\08\01a07f41-7159-70f1-ac7d-e6217941c130\town-edge-yard-framing-round-02\mockup-05.png

Native frame:
C:\Users\zhouc\.codex\visualizations\2026\09\08\01a07f41-7159-70f1-ac7d-e6217941c130\town-edge-yard-framing-round-02\pikeman-idle-native.png

Nearest-neighbor reference enlargement:
C:\Users\zhouc\.codex\visualizations\2026\09\08\01a07f41-7159-70f1-ac7d-e6217941c130\pikeman-resolution-study-v01\original-pikeman-6x-reference.png

Generated source:
C:\Users\zhouc\.codex\generated_images\01a07f41-7159-70f1-ac7d-e6217941c130\exec-942abe7b-d57f-4861-b454-6176802d5f41.png

## Exact generation prompt

Use case: precise-object-edit / style-transfer. Image1 is the EDIT TARGET: selected Laema gameplay-framing mockup05. Image2 is the original Heroes III Pikeman sprite, and image3 is an unmodified nearest-neighbour enlargement of that SAME sprite, used as authoritative costume, weapon and pose reference. Create one targeted HIGHER-RESOLUTION PIKEMAN PAINTOVER STUDY inside image1. Change ONLY the small Pikeman enemy on the RIGHT at screen center x about750, with boot soles at y610 in the1280x720 target. Its standing BODY height, excluding pike tip, must remain approximately180px. Preserve exactly the selected thin15% foreground framing, all scenery, sky, player placeholder silhouette on LEFT, HUD boxes, all displayed words/numbers, enemy HP marker position and canvas composition. Do NOT redraw the player or change the environment.
The only correction: faithfully redraw the existing Pikeman at the display resolution with fine, clean shaded detail rather than enlarged pixel blocks or smearing. Keep the original unit's identity: same adult male proportions, blue long split surcoat, small silver/grey chest and shoulder protection, leather belt, dark-brown boots, brown wood pike shaft and simple long bright steel spearhead, same head profile and short dark/brown hair, same restrained blue/silver/brown palette. No giant new plate armor, gold decoration, shield, helmet redesign, cape, horns, monster, glowing weapon or fantasy redesign. The pose remains the same upright idle guard with pike angled above the shoulder, MIRRORED to face LEFT toward the player. Boots grounded exactly where the existing enemy stands. Match the original slender silhouette and pike length/angle; do not make a hero portrait or increase the enemy's on-screen size.
Rendering: follow original Heroes III modeled-volume shading and fine material highlights, translated to a clean roughly180px-tall body. Firm readable silhouette, subtle metallic glints, cloth folds, no thick outlines, no chunky pixel clusters, no plastic 3D or photographic character. Lighting upper left to match the yard. This is a newly interpreted repaint, not a claim of recovering lost source pixels. No new UI or captions. Preserve every other part of image1.

