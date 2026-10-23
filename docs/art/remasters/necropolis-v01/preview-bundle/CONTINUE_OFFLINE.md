# Continue Necropolis asset production offline

Read `OFFLINE_HANDOFF.md`, `PRODUCTION_STATUS.json`, `inventory.json`, the selected
creature report and current source manifest first. The complete asset candidate
has passed independent and isolated engine checks; verify current evidence after
any edits rather than carrying that clearance onto changed files.
The original sources and approved appearance package must stay unchanged.

## Resume the current selection

```sh
python tools/art/necropolis_remaster.py inspect skeleton
python tools/art/necropolis_remaster.py prepare skeleton
```

`prepare` resumes missing-pose guides instead of clearing supplied art. Pose IDs
are stable first-source-occurrence IDs. The plan retains every occurrence, repeat,
group alias, original coordinate, indexed source hash and native metadata record.
Do not rename groups into guessed gameplay states or add actors/abilities.

The target is all 14 forms, 228 source groups and 1,378 positions from 856 distinct
registered signatures. Keep one dedicated worker and disjoint output folders per
creature; shared tooling, collection QA and publication belong to the parent.
Do not overwrite a sibling's work or run broad Git staging from a worker.

## Repair one pose without inventing animation

1. Identify the concrete defect against the actual original frame, not a folder
   label. Inspect the approved master for appearance and the original for action,
   camera, grip, wing/limb/weapon placement and content. Disintegration, corpse
   fragments and effects-only source cells must not become standing idle bodies.
2. Create a guide, retaining source and appearance references:

   ```sh
   python tools/art/necropolis_remaster.py guide skeleton --pose-ids skeleton_p000 --name repair-p000-reference
   ```

3. New painting requires an actually available art workflow. Retain the exact
   prompt, reference paths and hashes, unmodified raw attempt, tool-returned
   metadata and selection history. Do not fabricate model IDs/seeds. Never use OG
   enlargement or a code-warped master as new art. An approved master may only be
   reused for its actually matching original idle reference pose.
4. Ingest a separate transparent drawing, with a unique attempt name:

   ```sh
   python tools/art/necropolis_remaster.py ingest skeleton /path/to/raw.png --pose-ids skeleton_p000 --cols 1 --rows 1 --batch repair-p000-attempt01 --prompt-file /path/to/exact-prompt.txt --adaptive-grid
   ```

   Up to eight clearly separated row-major figures may share a page. Use strict
   `--components` only with an actually installed NumPy/SciPy environment; global
   `--dependency-path /path/to/overlay` goes **before** `ingest`. Wrong counts,
   ambiguous overlap and clipping are failures, not reasons to weaken extraction.
   Disconnected corpse/effect content may need one whole-cell figure instead.
5. Inspect the new registration on dark/light/checker mattes and at game viewing
   size. Check both facings, source-relative scale, anatomical/equipment continuity,
   all dependent action contacts and transition entries/exits. Only then record
   actual observations:

   ```sh
   python tools/art/necropolis_remaster.py review skeleton --pose-ids skeleton_p000 --note "Specific observations and actual remaining limitations"
   python tools/art/necropolis_remaster.py build skeleton
   python tools/art/necropolis_remaster.py validate skeleton
   python tools/art/necropolis_remaster.py spriteframes skeleton
   python tools/art/necropolis_lineup.py
   python tools/art/necropolis_review.py
   ```

A selected replacement preserves previous provenance in `_source/history/` and
rebuilds every group using that shared pose. Keep unsuccessful raw attempts; do not
erase selection history merely to simplify the directory. A mechanical rebuild
does not establish that its new content has been visually accepted.

## Geometry and interpretation are fixed

- RGBA 1024×768 cells, four columns, target anchor `(512,512)`, original reference
  `(196,268)`, shared scale `180/73`, transparent margin checked mechanically.
- Alpha >160 measures original opaque body bounds and excludes palette shadows.
  Generated transparency is retained; native phase/death content still needs
  source inspection. Do not infer missing palette/engine behavior from this rule.
- Do not independently enlarge crouching, flying or dying frames to standing size.
- Keep exact original orientation plus exact per-cell mirror. Do not call every
  original group “right-facing,” and never reverse atlas order when mirroring.
- Maintain separate aliases and repeated timeline cells, even where drawing reuse
  is legitimate. All original groups remain present independently.
- Provisional 10 fps is for review, not original timing or gameplay. Only movement
  and idle loop in SpriteFrames; no new state transitions or mechanics are implied.

## Finish only with explicit evidence

Run the complete independent checker and isolated Godot fixture described in the
handoff. Exercise every group, both facings and viewer controls, record actual
failures/repairs and do not claim browser or engine coverage not performed. A partial
smoke test cannot clear the full collection. Zero missing poses, broken references,
incorrect frame mappings or unresolved blocking anatomy/clipping defects is the
completion gate. Human motion acceptance stays separate.

Publication is authorized for the complete validated asset package, not unfinished
coverage. Reconcile with fresh `origin/main` while preserving unrelated dirty
checkouts. Commit/upload raw art, prompts, provenance, tools and handoff; then use a
clean integration checkout for the asset-only main merge. Never reset, stash,
force-push or bring Castle gameplay integration into this task. Verify both remote
commit references and report any publication failure accurately.

No new actors, AI, encounters, ranged/flight mechanics, collisions, gameplay APIs,
standalone projectiles, standalone spell VFX or audio belong to this continuation.
Runtime integration follows separately. No full-game playtest is implied.
