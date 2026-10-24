# Pikeman corrected repaint v02 — runtime presentation

User-approved Art package: `pikeman-flipbook-assets-v02`, version 2, task
`01a07f41-7159-70f1-ac7d-e6217941c130`. HANDOFF.md, manifest.json and
motion-review.json are the source contract. v01 is historical and was not used
for this integration. This is a generated reinterpretation of the approved
Pikeman repaint and original H3 pose references, not an authentic recovered
Heroes III sprite. Original game rights are not granted by the package.

Only the five right atlases are copied into runtime. Every copy is byte-identical
to Art's PNG. Left sheets/individual originals remain in the Art package; runtime
uses Sprite2D.flip_h once, not a left sheet plus another flip.

| Atlas | Frames | SHA-256 |
|---|---:|---|
| idle_right_sheet.png | 7 | 6ac371daf3d58a87e92a0a0fc41c7ffe31f611fdfb1ed7a4f02caf0ef08837af |
| walk_right_sheet.png | 6 | a7ea7013ee948508dbb26f64e73def72404da6d2865844ca28eb266db35daa08 |
| attack_right_sheet.png | 10 | be39d07e53554c7ce7941442823d72a4e78343004a199127ac50d2a6426422f4 |
| hurt_right_sheet.png | 6 | b8f7580ff86fcfc557b0308fe87a8cb502534008c144e34aa801329e11084475 |
| death_right_sheet.png | 5 | 7215db7cdfda1596b83cf4291ea70c4d476ae10cacd1932a5d58dd97752ac9aa |

Cells are 768 × 512, four columns, row-major, with transparent unused cells.
Existing frame-count guards exclude padding. The image-space foot/root anchor is
(384,448), 192 pixels below cell center. The unchanged collider is centered at
(-11,-3.35), height 68.7, so its bottom is (-11,31). The centered BodyVisual uses
position (-11,31), offset (0,-192), and unit scale: both right and mirrored left
anchors land on that collider-bottom reference. Actor-root scale, collision and
spawns are unchanged. On the Gym floor, settling places the root at y21 and the
visual foot at world y52 / screen y610. Standing body is approximately 180px;
pike height and crouching/death silhouettes are not scaled independently.

Idle stays 8fps, walk 9fps, death 8fps with its existing terminal hold. Hurt still
spans the captured reaction duration. Native melee_swing retains every key time,
marker and AttackCast track; only its texture and region rectangles change.
Frame 5 remains full thrust at 0.5s and the clip ends at 1.0s. GIF timing is not
used. Existing death/result freeze and reset owners are unchanged; this does not
promise the Gym result screen allows uninterrupted death playback.

With user approval, only the HP label and windup marker are repositioned above
the enlarged actor and existing floating-damage lane. Their triggers are unchanged.
The player, practice targets, Gym v02 environment/HUD, SFX and gameplay are intact.

Known visual/physical mismatch: the full-thrust frame's right alpha edge projects
to actor-local x211; the unchanged right-facing query reaches x96 (72 + radius24).
The drawing therefore extends about 115px beyond that physical envelope (left
extent differs because the collider/visual anchor is x-11 while the query mirrors
about root x0). Pike height also differs from the legacy query's y8 lane. No
hitbox, attack range, damage, timing or movement retuning is included. Use the
existing hitbox overlay for user comparison, not the drawing as collision truth.

Art reports 34 reviewed frames, 68 atlas-cell matches, 34 exact mirrors, 20 empty
padding cells and six exact ready-boundary matches. Those are Art's mechanical
and stepwise-review results, not DUM-E runtime evidence. DUM-E inspected the ready
and full-thrust frames and checked copy hashes, PNG headers, frame rectangles,
registration arithmetic and preservation of nonvisual source sections. No export
validator, automated tests, Godot/import/editor/build/runtime or playback was run.

User validation remains for both facings, floor contact, idle/walk against actual
movement, full thrust/recovery, interruption/reset, Hurt recovery, Death hold,
HP/warning/damage-label clearance and Gym retry. Small generated material/crest
variation and the coarse five-frame death remain prototype limits. Earlier native
PNG assets and their provenance remain intact in the parent folder.
