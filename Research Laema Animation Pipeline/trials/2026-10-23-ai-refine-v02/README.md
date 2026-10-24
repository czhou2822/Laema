# AI strip refinement and repeatability

Later human review: current game remains preferred over the later R&D candidates. v04's opening2–7 was rejected; [v05](../2026-10-23-x1-opening-v05/README.md) is a focused corrective trial. The working recommendation below remains a historical R&D candidate, not a demonstrated production-quality improvement over the game.

The user chose the AI strip for continued R&D on23 October2026 and asked for refinement, Godot testing, a second action and unchanged gameplay. These are review candidates; no production art or complete production pipeline is approved.

Open [the moving review](review.html). X1 now shows **current game / first AI study / refined AI study**. The Cast button shows **current game / new AI Cast study**. The previous three-panel screen contained only R&D clips; its “before” label referred to the first AI study, not existing game artwork. The refined study retains those ten drawings and adds six new inbetweens.

The existing-game baseline comes from the main local checkout, not the patched game copy or a published-build capture. [Baseline provenance](outputs/game-baselines.json) records the bound resources, source PNG hashes and native frame times. PNG copies are byte-identical; playback preserves the saved frame exposure, registration and action clock. X1 remains0.720s at Heat0 /0.480s at fixed Heat100. Cast remains1.200s /0.800s, with native launch0.24 (0.288s at Heat0). The existing X1 and selected A have different swing paths, so this is a practical same-action baseline; first/refined AI is the closer refinement comparison.

The [standalone Godot project](preview/project.godot) retains the earlier three-R&D-clip arrangement used for the saved engine captures. Run `python export_game_baselines.py` to rebuild the browser baseline comparison without generating artwork or modifying gameplay files.

## What was produced

- **X1:** The ten preferred normalized source drawings are retained. Six newly generated inbetweens bring the candidate to16 keys, using the selected A's original interpolated motion rather than a new swing. Original action duration, active window and pacing split are unchanged.
- **Second action:** A new eight-key Cast gesture was authored around the existing launch-hand position. It uses the same static appearance reference, pose-guide format, connected-alpha decoder, registration/export convention and review renderer. Ready endpoints reuse the preferred guard. Two high-hold keys reuse a good peak drawing; this avoids a clipped generated tip and reduces unnecessary grip drift.
- Both raw first attempts and retries, [prompts](prompts/), [generation provenance](generation-provenance.json), [pose contract](contract.json), [extraction measurements](outputs/clips.json) and scripts are preserved.

## Godot test with unchanged gameplay

An isolated copy of the current game runs the actual Player, combat components, AI, collisions and transitions. Only the copied X1/Cast texture references and sprite-frame keys change. Existing query curves, markers, body, CastOrigin, lunge, timing, settings and damage remain exact. Trial textures stay under the existing Fire-art prefix so no player code or registration rule needs alteration. The application name selects a separate test profile.

[Preservation checks](evidence/preservation-check.json) verify that original source files were not changed and copied gameplay code/settings are identical. The two native animation resources are text-identical after excluding only texture references and Sprite frame keys. Godot-generated import metadata and the Windows GDExtension shadow-library cache are identified separately.

The controlled [run03](evidence/gameplay-summary.json) observed:

- X1 accepted and hit, creating an orb;
- Charging started and charged the orb;
- normal Fire Cast committed, launched exactly once and impacted FinalEnemy;
- Dodge started/ended, ordinary movement, and a later incoming hit interrupted X1 into the existing reaction path;
- zero external inputs during the sequence; maximum scheduled input lateness4ms;63 recorded captures;
- terminal snapshot Player87.5HP / Enemy180HP. This is a bounded sequence, not encounter completion.

[Full-resolution X1](outputs/gameplay-1700.png) and [Cast launch](outputs/gameplay-3200.png) frames accompany a variable-interval [diagnostic animation](outputs/gameplay-diagnostic.webp). The live actor snapshots confirm the trial texture paths and existing Idle/Walk/Dodge/hurt textures were used. A supplementary run02 also observed X1/X2/X3 handoffs; its two startup external events and failed charging attempt are retained as limits. Run01 was contaminated by external controller activity and is rejected as controlled evidence.

Run03 uses scheduled InputEventAction names/strengths inside a test-only recorder wrapper, with hardware bindings excluded only in that process. It does not alter OS controller settings or gameplay code. The inherited recorder's generic hardware-input label is superseded by the wrapper description and gameplay summary. This is action-level integration evidence, not physical-controller, human feel or input-latency acceptance.

Standalone comparisons were graphically captured in Godot4.7.1 at fixed Heat0/100, both facings and1280x720. Those fixed-speed comparisons are distinct from the resource-earned Heat and ordinary combat actions in the game-copy run. Existing shutdown resource warnings remain in the logs; they were not treated as cleared engine issues.

## Correction effort actually observed

| Work | X1 refinement | Cast reuse |
| --- | --- | --- |
| Image requests |2 |2 |
| Rejected first pass | Copied old poses instead of new inbetweens | Raised grip above fixed launch point |
| Retry | Guide made primary edit target plus explicit sword directions | Guide made primary edit target plus explicit ear-height grip |
| Export repairs | One shared sheet transform; existing10 drawings retained | One shared sheet transform;2 guard and2 peak reuses |
| New export code | Shared decoder functions reused; fixed-stripe calibration generalized once | Same generalized decoder/export contract reused |

The initial two requests ran concurrently and took57s observed wall time. The X1 retry took36s and Cast retry37s:130s of generation-phase wall time. These are service waits, not artist labor. Model revision, seed and server hardware were not exposed. No human pixel-paint cleanup was performed or timed, and labor to final acceptance remains unknown. The clone/import/input-isolation harness is reusable test setup, not per-action art labor.

Residual lowest-opaque-row variation is up to1.68world pixels in the new X1 sheet and0.56px in Cast before explicit pose reuses. No per-frame recentering conceals this. RGB/material/face details can still drift between new and retained drawings. More frames alone do not prove better motion: judge the first/refined AI playback at normal speed, then compare against the existing game baseline.

## Working recommendation

Continue with an original pose-guide-first AI frame workflow, one fixed appearance master, explicit registration, intentional repeated-pose reuse and per-frame/engine QA. This has now produced candidates for two actions and survived an actual Player integration sequence with unchanged gameplay. The retry changed both input priority and wording; it does not isolate which factor caused better correspondence.

Use this as the next Laema animation-production workflow candidate, with human quality review per action. Do not treat free-form whole-sheet prompting as unattended production, the rejected cutout rig as a mature rig benchmark, or this two-action sample as proof for the whole animation set. 3D was not tested; no demonstrated depth/volume failure justified it here.

## Remaining review

The user still needs to judge whether the new inbetweens improve X1 without distracting style/shape pops and whether Cast's compact raised grip/recovery is acceptable. Existing Idle/Walk/X2 and reaction art remains different and can show handoff discontinuities. Successful hits/launches do not clear the known visual/query mismatch; geometry was deliberately not retuned. No production files, live build, commit or push were changed by this R&D.

Reproduce exports with `python process_outputs.py`, `python install_art_in_copy.py`, `python make_preview.py`, then run the saved Godot projects. The processing is reproducible from preserved raw images; the image generations are not deterministic from unexposed seeds.
