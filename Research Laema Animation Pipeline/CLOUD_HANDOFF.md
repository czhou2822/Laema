# Animation R&D — prepared cloud continuation

Prepared 24 October 2026, Hong Kong. **Local handoff preparation only: no cloud task, remote branch, deployment, or new artistic approval is established by this file.**

Continue the independent task `original_character_animation_pipeline_rnd_2026_10_23`, department **Combat**. Preserve its existing cloud and local bindings in `docs/departments/task-departments.json`; a new execution is a continuation binding, not another task's identity. Read AGENTS.md and the current relevant canonical records first.

## Resume point

H02 is awaiting the user's artistic review. First reproduce the existing **Current game / H01 / H02** character-only comparison, including synchronized playback, source frame counts, scrubbing, linked pan, transparent drag overlays and version-bound annotations. Do not generate another iteration merely because the execution moved online.

Read `README.md`, `CONTINUE_LOCAL.md`, `FINDINGS.md`, `PIPELINE_AUDIT.md`, `QUALITY_WORKFLOW.md`, `report.html`, `evidence/round-record.json`, and the H01/H02 reports and annotation stores. Earlier evidence is scoped to its recorded source revision. The original inspected revision was `16b4c3b7199589439a276881eca7516cc0f7401c`; this preparation inspected local HEAD `98676e1e4aefcb9453040ae24bd1c30a9dcc4bfd`. Additional unrelated local tuning/resource edits exist and are excluded from this handoff's proposed changes. Do not reset or overwrite them.

The user chose A, then the AI-strip route. The installed game remains their last stated overall preference. H01's release/grip edit has no established artistic win. H02 changes preparation drawings2–4 only; drawings1 and5–16 and all key times remain exact H01 pixels/data. Focus on3 and the2→3→4→5 progression. Boot/appearance drift and the handoff into5 remain open. H02 has not received a new Godot integration run or artistic acceptance.

At preparation, H01 annotations are revision9 with five active notes; H02 is revision0 with no notes. Read the live stores again before acting. Preserve deleted-note history but do not treat tool-validation notes as artistic feedback. Game drawing numbers differ from trial drawing numbers. The game-reference elbow/thrust comments are separate from H02 preparation feedback.

## Existing method and smallest cloud experiment

The current method is original authored pose guides → reference-guided built-in AI raster generation → explicit extraction/registration/compositing → timed Godot flipbooks. The painted anatomy is not constrained by a persistent skeleton. Broad regeneration causes equipment/anatomy drift; bounded correction and protected-pixel checks reduce that risk but do not prove quality. The earlier cutout trial is not a successful polished rig baseline. No workflow winner or3D result exists.

The smallest cloud experiment is **carry over and review the exact H02 assets and notes**, using the existing viewer. Avoid a new review framework, database or full-game web build. The user's next visual feedback selects the next art correction. Measure generation retries and correction work separately from reusable hosting setup. Technical checks never substitute for the user's artistic judgment.

## Bring up the same review

From the repository root:

```sh
python "Research Laema Animation Pipeline/review_server.py" --port 58929
```

The review path is:

```text
/trials/2026-10-23-v08-game-integration/review.html?experiment=H02
```

H01 remains available with `?experiment=H01`. This server, rather than a plain static file server, provides `/api/review-notes/H01` and `/api/review-notes/H02` and preserves edit/removal history.

**Cloud hosting compatibility is pending.** The current server binds127.0.0.1 and accepts localhost origins. Use the cloud environment's authenticated preview/forwarding facility if available. Check whether its proxy needs a different bind address or exact allowed origin before making the smallest explicit adapter change. Do not expose an anonymous writable note endpoint or tunnel the user's computer as a substitute for a cloud deployment. A static host can play the images but cannot execute this Python annotation backend.

Verify in the actual cloud environment: assets load; all three versions play/scrub together; drag overlays and opacity work; both original note stores load; a scratch note survives save/reload without touching user stores. Establish persistence and note export before calling online review complete. Distinguish a task preview from an always-available website. The cloud task's availability, preview URL and persistent hosting have not been verified locally.

Probe the cloud task's actual image-editing tools before promising continued AI generation. Prefer the existing built-in image tool when present. Do not silently replace it with a paid API or claim that a different generator is the same experiment. Keep raw outputs, rejected attempts, references, exact prompts and correction records. Browser sprite playback is not a Godot gameplay test.

## Gameplay and source boundaries

Keep X1 duration0.720s at Heat0 /0.480s at fixedHeat100; Heat0 continuous contact window0.126–0.5075s. The0.210s pacing split is not a hit marker. Preserve input, queue, dodge, movement, damage, lunge and Cast rules. Native attack resources remain geometry authority; blade/contact adaptation is unapproved. Foot anchor(224,400) differs from actor/query origin(224,348). Read the registration details in FINDINGS.md.

Keep all art corrections in this research folder, which has `.gdignore`. Do not replace installed art, alter gameplay, publish a live game, merge, or claim production readiness. Existing Godot runs belong to their recorded frozen fixtures; H02 source playback adds no runtime evidence. Historical duplicate game fixtures/captures omitted from a compact transfer remain preserved locally and must be labelled unavailable in the cloud rather than silently represented as copied or rerun.

## Publication proposal requiring explicit commit/push authorization

Proposed branch: `codex/laema-animation-cloud-2026-10-24`, based on the inspected HEAD, with only the reviewed animation-research delta. Keep the working checkout on its existing branch; do not stage unrelated gameplay/configuration work. The preparation manifest lists the exact included files, hashes and excluded local artifacts. No commit or push has been made. AGENTS.md requires separate explicit authorization for commit/push outside a checkpoint command.

After source transfer is authorized and verified, start the cloud continuation with this file as its resume point. Verify the published branch's exact assets/notes before starting any further artwork. Update the continuation binding only from the task actually created; do not invent a cloud task ID or claim this chat's full transcript was moved.

Official capability references checked during preparation: [Codex Cloud](https://learn.chatgpt.com/docs/cloud), [cloud environments and saved state](https://learn.chatgpt.com/docs/environments/cloud-environments). These describe remote tasks; they do not establish this account's environment configuration or an always-on review host.
