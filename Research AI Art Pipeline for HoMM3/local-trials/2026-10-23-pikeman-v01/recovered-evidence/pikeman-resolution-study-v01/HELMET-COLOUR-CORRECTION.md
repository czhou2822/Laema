# Helmet colour correction

The user rejected the bright silver helmet. Original imported Pikeman pixels were inspected directly in the head region. They show dark warm brown/olive metal with restrained light accents; sampled values are retained in original-helmet-pixel-colours.json, and the unmodified head crop is original-head-colour-reference.png.

The built-in image tool produced a colour correction. The selected head region was then mechanically composited onto the prior mockup so every pixel outside that region remains unchanged. This preserves the surrounding image against incidental generative changes.

Current proposed result: 07-helmet-colour-corrected-mockup.png. Inspection crop: helmet-colour-detail.png. Pixel-boundary checks: helmet-colour-checks.json.

This remains a generated one-pose interpretation; no animation or game files were changed.

## Exact prompt

Use case: precise-object-edit. HELMET COLOUR CORRECTION ONLY. Image1 is the current full Laema mockup and edit target. Image2 is a nearest-neighbor crop of the ORIGINAL Pikeman head and is the authoritative colour reference. The open-faced helmet on the enemy at screen-right in image1 is incorrectly BRIGHT SILVER. Recolour ONLY that helmet to match image2's DARK WARM BROWN-BRONZE METAL with muted OLIVE/CHARCOAL shadows and very small pale khaki/grey specular glints. Main helmet tones should resemble deep earthy brown #3b291c and olive-brown #313426, with deep shadows around #211810; keep highlights restrained. It must read as an aged dark bronze/brown metal helmet, NOT as hair, leather, bright yellow gold, orange copper, or polished silver. Preserve the current helmet shape, visible hard metal rim and readable open face. Do not change his skin or hair outside the helmet.
Every other pixel region should remain visually unchanged: pose, face shape, pike, blue-and-white uniform, silver chest/shoulder protection, boots, character size and location, player placeholder, background architecture/foliage, thin foreground framing, all HUD and text, camera and lighting. Do not apply the bronze colour to his chest armor or pike point. Same16:9 image. This is one narrowly targeted palette correction, not a new design.
