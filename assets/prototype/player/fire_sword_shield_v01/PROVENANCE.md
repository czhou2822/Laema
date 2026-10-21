# Fire Laema sword-and-shield presentation v01

Current attack binding — October 21: X1/X4/X5 use transparent derivatives of
the overnight R05/R02/R04 studies in `overnight_v04/`; X2/X3 retain v03 in
`angle_proofs_v03/`. The new manifest/provenance records selected poses and
unchanged clocks/geometry. All original v01/v03 PNGs and the original integration
record below remain preserved; v01 Idle/Walk/Hurt/Cast are still active.

Fire defence also uses the accepted eight-frame Shield Catch refinement in
`defence_v03/`, copied byte-for-byte from the October21 Art export. Its own
manifest/provenance records state-driven playback and pending user validation.

User-authorized prototype integration, October 20, 2026, from Art task
`01a15800-6824-7d03-aee8-9e7ad7ef3885`, package
`laema-player-flipbooks-v01`. The user's later “okay hand over to U” authorizes
this integration; the package's earlier ART_REVIEW_CANDIDATE / not-runtime-ready
labels remain limits on production/runtime acceptance, not a new gameplay rule.
Fire sword and shield supersede the initial hammer brief for this pass only.
Other school appearance and weapon decisions remain outside scope.

Only the nine selected sheets named by clip-metadata.json are copied. They are
byte-identical to those selected exports; raw generations, superseded hammer
images, source pose strips and review GIFs are not runtime textures. Art retains
HANDOFF.md, clip-metadata.json, qa-report.json, source-inventory.json,
generation-provenance.json and prompt/repair ancestry in its source package.
Images are generated reinterpretations: accepted Laema concepts supply identity,
Heroes III samples supply material/style reference, and current Craftpix sheets
supply pose order. These are not authentic recovered H3 or Craftpix originals.

| Runtime sheet | Frames | SHA-256 |
|---|---:|---|
| fire_x1.png | 4 | 09189c3c88facc7673a8ced91025c49b336a7ac391a898fbcd73cd959d3add72 |
| fire_x2.png | 3 | 93fecbe6566eb53814edda543b7a2885262ea593e41102cd2981e5d0c8bef2ed |
| fire_x3.png | 4 | a8d31bb2b720edffdc5d1c6083554dd36afe9e45bbb5f19c8e9c35280c808ba1 |
| fire_x4.png | 5 | 5c18475797d1a4c3bf7c2e3a05c1cdccefeb306c2089d25dab831a802e5d4f11 |
| fire_x5.png | 4 | b76fd02e84c8956e6b53bf70c5892b9435ab81331b4b8cdae2d1aea2e165932c |
| shared_idle.png | 6 | 9dbbd4ed6159ea7f30728ab7875c80c3096979d4ea3be0505ae5df00a7a11d3e |
| shared_walk.png | 12 | a7ba9a39d30bce0938e63c2aaf487beb9874d4290e3f661c99d2af076db1bea5 |
| hurt.png | 4 | 4a20e4d6a133973e53390f9d676f77778c36a667157448ce4e6e5316cce64b8f |
| cast_fire.png | 10 | 77eeb74a5f656eb8831a470e75e85949bda3a77f7cc71a148ac9153926e69030 |

All sheets are single-row RGBA atlases, 448×448 per cell, total 52 frames. The
shared foot anchor is (224,400); standing body is approximately180px excluding
weapon. Crouch/recoil height changes and the reported one-raster-pixel variation
in contact rows are retained. No pose is independently rescaled.

## Runtime bindings and registration

- fire_x1..fire_x5 native Animations now point here, replacing only their previous
  earth_x1..earth_x5 texture references and region rectangle payloads. Move IDs,
  native Animation UIDs, every current frame-key time, marker, geometry track,
  gameplay duration/Heat/lunge/Impact/damage remain unchanged. Old textures remain.
- cast_fire likewise uses this sheet at its exact existing ten frame times and
  unchanged launch0.24 marker. Other school Cast clips and attack_clock are intact.
  Cast classification, primary-school selection, commitment, emission and impact
  mechanics are not modified.
- Player chooses these Idle/Walk/Hurt textures only when selected school is Fire.
  All other schools retain their previous shared128px sheets and legacy styling.
  Existing Idle6/8fps, Walk12/10fps and Hurt4/captured-duration pacing are retained.
- Actual texture identity selects the sprite profile/cell format, including native
  attacks/Casts. Selecting another school during a committed Fire action does not
  recrop the still-playing Fire atlas as128px. Returning to a legacy texture
  restores its saved offset/filter/material and selected-school tint.
- Player root scale2, Sprite scale0.5 and collision rectangle26×30 at(0,11) remain
  unchanged. Collider floor is local y26. Existing scales give net screen scale1;
  the Fire-only centered Sprite offset is therefore(0,-124):
  (400 - 224 - 124) × 0.5 = 26 local, × root2 = 52 world.
  With the Gym camera, this projects to screen y610. The X anchor is cell center,
  so the existing one runtime flip retains the same foot point.
- Fire uses the approved image colors without the legacy school-tint/outline
  shader, with linear texture filtering. Other schools restore their original
  shader, tint, filter, offset and128px cells. Original material capture is retained
  separately so changing schools from Fire cannot dereference a cleared material.
  Input, facing locks and action/reaction state ownership are unchanged.

Registration is selected by the existing runtime Player presentation owner.
Standalone native-editor scrubbing does not execute that profile; when inspecting
Fire art there, account for the documented offset rather than moving AttackCast
geometry to fit an unconfigured preview. This integration does not add an editor
preview controller or change the original scene's other-school default transform.

## Known art / physical limits

Art reports imperfect fine sword/guard/shield/strap/face/hair continuity,
particularly X3's separate low-sweep correction and X5's shield grip. Walk rhythm,
loop seams and transitions still need playback review. Cast's held-sword gesture
is presentation only, not a new strike or launch event. Fire X2 intentionally
retains the source-backed backward-pointing sweep; its forward gameplay coverage
has not been reversed to match the blade.

Drawings are not collision geometry. For example, Fire X1 frame2 reaches image
x408, approximately+184 world pixels from its anchored root, while its unchanged
point-query circle reaches+112 world pixels. Fire X2's extended blade is behind
the right-facing actor while its existing query remains forward. The approximately
180px body is also taller than the unchanged 60-world-pixel collision rectangle.
No hitbox, collision, reach, root motion, reaction, input or tuning is reconciled
silently to those images. Existing floating feedback placement remains separate.

The selected Walk and Cast atlases are5376×448 and4480×448; engine/Web/GPU import
and size compatibility are unverified. No silent resampling/repacking was applied.
Godot generates ordinary imports on the user's next project open.

## Evidence and user validation

Art reported static file QA for52 frames/nine clips (RGBA decode, matching atlas
cells, no border/crop clipping and distinct frame pixels). Those reports are not
final visual approval or runtime evidence. DUM-E checked selected-copy hashes and
PNG headers, current frame-time agreement, texture/region-only native-resource
differences, protected other-school/Pikeman/Gym/gameplay source and call paths.
No Godot, editor/import, continuous GIF playback, build, game tests, live publish,
commit or push was run.

User checks: Fire Idle/Walk, X1–X5 and both facing directions; Hurt/failed-Cast
self-flinch, Cast launch/finish, school changes before/during/after actions,
interruption/reset/death/Retry and return to each legacy school's Idle/Walk/Hurt/
attacks/Cast. Compare the existing hitbox overlay with the retained pose mismatches.
Check feet against y610 and inspect X3/X5 handling and loop transitions. Leave
remaining art or gameplay dispositions with their respective owners.
