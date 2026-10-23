# Actual engine appearance preview

Final review outputs are in `normalized/`:

- `engine-comparison-detail.png`: Current vs A restoration vs B edit vs C strip, same scene crop.
- `engine-comparison-fullthrust.png`: four complete Gym views at half display size.
- `engine-comparison-fiveway.png`: adds nearest source-alpha baseline.
- `engine-comparison-animated.webp` / `.gif`: synchronized ten-frame,100ms comparison.
- `*-engine-preview.webp`: each full Gym view, ten frames100ms each.
- `capture-report.json`: engine version, renderer, transforms, source anchor, floor settling and all55 successful capture writes.

These are **actual rendered Godot Gym scenes**, staged for appearance comparison. They are not captures of ordinary combat input/playtesting. Physics first settled both actors on the real floor; a private fixture reduced perception and movement, moved Player to x-240 and Pikeman to x120, froze processing, selected right facing and sampled the native current attack or candidate frames0..9. Camera remains(0,-198), zoom1, viewport1280x720, existing background/ground/filter. HUD developer readouts hidden through the existing in-memory setting. Current atlas uses its actual native scale1. All candidates receive exactly one fixed scale180/148 and original anchor196,268 (shared crop anchor92,192; centered offset54,-88). No frame is individually repositioned. `Image.fix_alpha_edges()` matches the imported art's alpha-border RGB fix and does not change candidate alpha.

Godot4.6.3 official, X11 dummy display, Mesa llvmpipe, GL compatibility were available. Project setting names4.7/Forward Plus. The unchanged ObjectiveWidget uses4.7-only `custom_maximum_size`, producing a script error under4.6.3; the top-right objective box is incomplete in these captures. Texture/scene loading and all55 capture writes succeeded. Shutdown logs contain resource/RID leak warnings. These limits prevent claiming full runtime compatibility or gameplay validation; they do not invalidate the visible sprite render comparison.

The full project copy in `project/` excludes docs and Git metadata. Imports, caches, XDG data and every script/output are outside `/workspace/Laema`. No production assets or gameplay code were modified. Earlier PNGs and frames directly in this directory are preliminary scale1 candidate previews; use `normalized/` for the final fair-size comparison.

## Reproduce

1. Copy `assets`, `scripts`, `scenes`, `config`, `ai`, `addons`, and `project.godot` from the source project to `project/`. Keep research-only `project/research_capture.gd`.
2. Create writable `xdg-data`, `xdg-config`, `xdg-cache`. Use the corresponding XDG environment variables when running Godot. Never run the import against the production project.
3. Run Godot headless editor import on `project/`, then start the dummy Xorg display using supplied `xorg.conf`. In this sandbox, local display sockets require network-enabled execution permission. The display command binds no TCP listener:

   `/usr/lib/xorg/Xorg :99 -config /workspace/homm3-research/gameplay-preview/xorg.conf -logfile /workspace/homm3-research/gameplay-preview/xorg.log -nolisten tcp -noreset`

4. Run `run_capture.sh`, then `python make_comparisons.py`. `candidates.json` supplies absolute research candidate file paths. All candidate textures load from those paths and stay in memory; no production substitution occurs.

Timing100ms is the agreed comparison contract. Although the known Pikeman base action length is1.00s, this does not establish original executable per-frame dwell or battle-speed behavior. Human art/motion/gameplay acceptance remains open.
