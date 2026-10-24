# Paste this prompt into the local coding assistant

Continue the existing Laema Castle-creature remaster work in this checkout.
Read `AGENTS.md` and inspect Git status before doing anything. Preserve local
changes and other tasks. Do not reset, clean, stash or overwrite work to obtain
a clean tree. This is task continuity, not an instruction to load a project
checkpoint, deploy a site or restore other chat threads.

Read:

1. `docs/art/remasters/castle-v01/OFFLINE_HANDOFF.md` and `README.md`.
2. `docs/GAME_DESIGN.md`, `docs/TECH_ARCHITECTURE.md` and
   `docs/IMPLEMENTATION_STATUS.md`.
3. `docs/art/remasters/castle-v01/inventory.json`, `generation-plan.json` and
   `validation/independent-asset-qa.json`.
4. `tools/art/README.md`, the relevant creature's `source_manifest.json`, its
   retained `_source/` prompts/artwork and actual gameplay bindings.
5. The separate `Research AI Art Pipeline for HoMM3/README.md`, research report
   and local-research prompt when evaluating a different generation method.

The published branch is `codex/castle-remasters-2026-10-23` in
`https://github.com/czhou2822/Laema`. All paths in this prompt are checkout-relative;
older `/workspace/...` strings in evidence refer to the earlier cloud machine.
The complete source/artwork is in Git; no prior cloud scratch folder is required.

Carry forward these established facts without starting the inventory or artwork
generation over:

- All 14 Castle base/upgraded creatures have all 225 original group counterparts,
  preserving 1,324 frame positions and original aliases/order. There are 847
  registered poses: 633 generated and 214 reused high-resolution drawings.
- Assets are in `assets/prototype/enemy/<id>/remaster_v01/`, including per-group
  PNGs, 225 import descriptors, 14 native SpriteFrames resources, manifests,
  registered pose PNGs, raw generated/isolated artwork and provenance.
- Seven existing actual gameplay enemies use 37 updated idle/walk/hurt/death/
  attack bindings through the existing controllers and nine Animation resources.
  Preserve AI, collision, combat settings, hitbox curves and accepted clocks.
- Upgraded creatures currently have assets only. Additional original animation
  slots do not create abilities or gameplay states. Do not invent upgrade stats,
  flyers, extra attacks, shooters or encounters; Angel shooting-numbered groups
  are actual melee aliases. No next faction has been completed by this task.
- Registration v2 excludes OG palette shadows with alpha>160 and records source
  body bounds/coordinates. Target anchor is(384,448), four columns, 768×512 cells
  for Pikeman and 768×640 for others. Repack from retained raw sources, not from
  resized outputs. Do not substitute low-resolution OG enlargement for new art.
- Pikeman front attack uses `[0,1,2,3,4,5,4,3,2,1]`; native 0.8/0.9s address
  rebuilt cells8/9 containing original poses2/1. The one-hand hurt recovery and
  Griffin frontal-turn corrections are already supplied. Preserve those fixes.
- Independent source/asset checks passed for all 225 groups/1,324 frames/847 poses.
  Godot 4.6.3 loaded the14 libraries and sampled 392 state frames plus 168 native
  attack keys across the seven real actors and both facings. Chromium checked all
  225 group comparisons. These are agent checks, not human visual acceptance.
- Godot 4.7, the declared project version, was unavailable in the cloud. A known
  earlier 4.6 ObjectiveWidget UI API error persists. Exact OG dwell/timing was not
  recovered; SpriteFrames 10 fps is explicitly provisional. Final artistic parity,
  natural transitions, contact alignment, balance and user approval remain open.
- Whole-page image generation can drift in identity, anatomy, pose or layout.
  Packing and correct counts do not certify fidelity. The independent research
  contains stricter controlled-method experiments; do not treat proposed Qwen,
  ControlNet or propagation workflows as already executed or approved.

Now continue a focused local quality pass:

1. Verify that this local copy contains the225 groups and retained source artwork.
   Identify the engine/dependencies and actual offline image tools installed.
2. Use the supplied original-versus-remaster viewer, individual source frames,
   synchronized clips and real actor presentation to inspect specific groups.
   Judge silhouette, camera direction, armor/colors, grips, weapon angles, feet,
   wings, transparency, scale, registration and sequence continuity. Start with
   a representative Pikeman sequence; report measured defects separately from
   aesthetic judgments. Do not assume every existing candidate has been accepted.
3. Correct only identified art/packing defects within the established pipeline.
   Preserve raw outputs and exact prompts/settings actually available. Reuse exact
   repeated poses; rebuild all groups sharing a changed pose and update manifests.
   Do not overwrite OG sources or archived baseline evidence. Keep new trials and
   visual comparisons separately. Preserve current gameplay behavior/timing.
4. The existing task authorizes relevant asset/import/playback validation. Use
   compatible local Godot where available, rerun the relevant checks after real
   changes, and distinguish headless sampling from rendered and human gameplay
   evidence. Record actual failures; do not repair unrelated game systems.
5. If new drawings are needed offline, use an already installed suitable local
   workflow or manual artwork. Do not assume access to the cloud image-generation
   tool, model weights, seeds, nodes or network. If unavailable, state the missing
   prerequisite and continue useful review/packing work without fabricating art.

Ask for an actual design decision before adding unsupported gameplay actors or
states. Report counts, precise changed assets, relevant checks and residual art/
timing limitations. Do not claim full Phase 5 acceptance. Do not commit, push,
merge or export subsequent local work unless I request it.

## Optional prompt for a single replacement drawing

Use this with the actual OG pose and an appropriate high-resolution appearance
reference in the chosen image tool. It is a prompt template, not a recorded model
workflow or a guarantee of structural control.

> Repaint this one original HoMM3 Castle [CREATURE] pose as detailed,
> high-resolution game artwork. The original frame is the authority for camera,
> silhouette, limb positions, hand grips, weapon angle, wing/foot placement and
> action. The appearance reference supplies the same creature's colors, equipment
> and rendering style; it must not override the original pose or upgrade identity.
> Draw one complete figure, with every weapon tip and appendage visible inside
> generous transparent margins. Preserve the original facing and posture. Use
> true RGBA transparency, without a ground shadow, floor, labels, grid or backdrop.
> Produce newly drawn detail; do not enlarge the original pixels or substitute a
> generic idle pose. Keep the raw output before any crop, alpha processing or
> registration. Compare the result against the source before accepting it.
