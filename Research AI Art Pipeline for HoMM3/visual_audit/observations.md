# Existing Castle drawing comparison

Read-only inspection of `/workspace/Laema`, 2026-10-23. Git status was clean before inspection. No production assets or project files were changed. Contact sheets and GIFs were made with Pillow by cropping, fixed scaling, compositing and layout; no generated drawing was altered.

Frame indices below are zero-based.

## Coordinate and preview contract

`create_comparisons.py` recreates all sheets/GIFs. Source is the preserved RGBA runtime copy of the original DEF extraction. Existing generated comparison is the currently bound high-resolution atlas. Both use their entire atlas cells before applying a single constant root/scale transform for the entire group; there is no per-frame centering, fitting or deformation.

- Griffin Attack: original 450x400 cells, anchor (218,267), scale 180/89; generated 768x640, anchor (384,448), scale1. These derive from documented native presentation sizes. The generated crest/wing silhouette is visibly larger than the nominal original standing silhouette; this comparison intentionally shows the selected asset registration rather than hiding that with a per-frame crop fit.
- Archer Shoot: original 450x400, anchor (196,267), scale180/76; generated768x640, anchor(384,448), scale1.
- Pikeman Attack: original450x400, anchor(196,268), constant scale180/74; generated768x512, anchor(384,448), scale1. Source74px is a manual helmet-top-to-foot measurement of ready frame0 (y194 to268), excluding the pike; the generated ready body is approximately180px (y268 to448). Using the original idle alpha-bounding height95px as body height would incorrectly include the raised weapon and make the original person too small. `pikeman_original00_grid.png` and `pikeman_generated00_grid.png` document the measurement.

All GIFs use equal100ms dwells to inspect correspondence. This is an illustrative diagnostic rate for Griffin/Archer and the documented one-second equal-dwell comparison contract for Pikeman; it does not recover original executable per-frame timing.

## Objective findings

1. **Pikeman recovery pose sequence differs from the source.** Original group12 frame1 equals9,2 equals8,3 equals7,4 equals6. Generated repaint_v02 frame0 equals9,1 equals8,3 equals7,4 equals6. Therefore repaint frame8 returns to generated pose1 where original8 is original2; repaint9 returns to generated0 where original9 is original1. This is exact RGBA pixel equality of full cells, recorded in `duplicate_frame_audit.json`, and visually apparent in `pikeman_attack_contact.png`. The generated recovery raises the pike to the ready angle sooner. Its10-frame count alone does not establish1:1 pose preservation.

2. **Repeated-frame patterns are correctly preserved for the other selected groups.** Griffin group12 original0=8 and generated0=8; Archer group15 original3=4=5 and generated3=4=5. These repeated holds should not automatically be labeled generation failures: they already exist in source.

3. **There is appreciable silhouette change at fixed registration.** `silhouette_correspondence.json` measures silhouette IoU without fitting: mean0.458 for the body-height-normalized Pikeman;0.474 Archer and0.296 Griffin under their documented fixed presentation sizes. These numbers are shape correspondence diagnostics, not art-quality scores. Original alpha>200 excludes its64/128 shadow pixels; generated alpha>127. Shape, size, proportion and small registration differences all affect this measure. Griffin's larger selected generated silhouette depresses its score, so do not rank creature quality from these values.

4. **The original and generated shadow treatments differ.** The extracted originals include distinct64/128 alpha shadow pixels while these generated sheets primarily provide the character with antialiased alpha. Griffin attack frames show a large original projected shadow under flight poses; generated corresponding frames have no comparable shadow. Whether a separate gameplay shadow is desired is art direction, but deleting/changing this component is an objective difference from a composited1:1 source sprite.

## Visual observations requiring human judgment

### Pikeman, `pikeman_attack_contact.png`

- The generated ready posture (0) changes the source's more frontal torso into a clearer side-facing, broad-shouldered figure. Its face, helmet and armor are well resolved, but their new details are interpretations because the tiny original cannot settle them uniquely.
- The full thrust(5) uses a much deeper, wider lunge and a more horizontally extended torso/arms than the source5. The source's rear knee/body position and arm reach are different even after shared body-height normalization. This is a fidelity issue, independent of whether the lunge is judged visually stronger.
- The apparent pike length and grip spacing vary through the generated set; frame1 and frame5 read longer than ready0. A physical-length failure is **not proven** by this view because perspective and foreshortening also vary in the source. A stable rigid weapon layer/3D guide would make this easier to control and inspect.
- Face, armor colors, lion emblem and general costume remain substantially recognizable across this selected set. I do not find a defensible gross extra-limb or missing-weapon failure here. The strongest concrete concern is pose preservation and redesigned proportions, rather than declaring every frame poor.

### Archer, `archer_shoot_contact.png`

- Source0 has one hand near the hip/side and the crossbow lowered; generated0 places both hands on the crossbow in front of the waist. Generated1 remains close to that same ready configuration, while original1 starts extending the forward arm. Early windup hand choreography has therefore been simplified/reinterpreted.
- The silhouette in2-5 becomes broader and more muscular, with larger arms, boots, weapon and torso than the slim original at approximately equal standing height. Costume and blue/white heraldic identity remain coherent.
- Generated3/4/5 are intentionally exact repeats matching the original repeat set. This is source-faithful holding, not evidence of frozen accidental duplicates.
- Source6's raised crossbow/arm pose and generated6 correspond reasonably at a coarse level. Fine finger/string/weapon geometry needs close art review; do not claim functional crossbow mechanics from this sheet.

### Griffin, `griffin_attack_contact.png`

- The selected generated9-frame group is visually much cleaner and more detailed than nearest-enlarged source pixels. Broad wing-up, airborne strike and recovery sequence correspond well. This is a useful counterexample to blanket claims that all selected output is unusable.
- The creature is more muscular, with a larger gold-feather chest, stronger hooked beak, prominent swept crest and larger claws. These design decisions and larger silhouette reduce literal1:1 fidelity even where the poses broadly match.
- Original attack shadow is absent in generated art. The flight/height impression depends on how gameplay supplies ground/shadow context; the generated sheet alone cannot answer that.
- No conclusive extra limb or broken wing topology was visible in this contact-sheet review. Feather grouping, face styling and whether the stronger contours match the intended historical art direction require the user's review.

## Limits

This is an asset-level visual comparison, not actual Godot gameplay. It does not establish appearance under scene scaling, filtering, camera transforms, backgrounds, shadows, motion blur or contact effects. Current Art high-resolution masters are not present in the inspected package, so no comparison claims about their quality or consistency can be made. Refer to the independent runtime audit for selected hashes, binding, alpha-boundary and timing evidence. The images support specific pose/style differences; they do not prove that an alternative model would produce better art without executing that comparison.
